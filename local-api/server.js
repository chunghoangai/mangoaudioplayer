const http = require('node:http');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const port = Number(process.env.PORT || 3000);
const audioDirectory = path.join(__dirname, 'audio');
const trackId = '7e2f61e4-0f65-4d3e-9e73-8a3abf8a1201';
const tracks = new Map([[trackId, {
  id: trackId,
  name: 'Sample Audio',
  thumbnailUrl: 'https://placehold.co/600x600/png?text=Sample+Audio',
  audioMetadataUrl: `/audio/v1/${trackId}/metadata`,
  audioFile: process.env.SAMPLE_AUDIO_FILE || 'sample.mp3',
}]]);

const metadata = {
  id: '5af19909-72db-4ba9-8ba5-bf9e8526c620',
  trackID: trackId,
  author: 'Sample Artist',
  releaseDay: '2024-01-01T00:00:00.000Z',
  isSubtitleSupport: true,
  isFavorite: false,
  created_at: '2024-01-01T00:00:00.000Z',
};
const lyric = {
  id: '8fa164a3-1cd6-4ea5-9a5b-9de48d9017a2',
  trackId,
  content: 'Sample lyric line one.\nSample lyric line two.',
};

function json(response, status, body) {
  response.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
  });
  response.end(JSON.stringify(body));
}

const clients = new Set();

function frame(text) {
  const payload = Buffer.from(text);
  let header;
  if (payload.length < 126) {
    header = Buffer.from([0x81, payload.length]);
  } else if (payload.length <= 0xffff) {
    header = Buffer.alloc(4);
    header[0] = 0x81;
    header[1] = 126;
    header.writeUInt16BE(payload.length, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x81;
    header[1] = 127;
    header.writeBigUInt64BE(BigInt(payload.length), 2);
  }
  return Buffer.concat([header, payload]);
}

function send(socket, value) {
  if (!socket.destroyed) socket.write(frame(JSON.stringify(value)));
}

function broadcast(value) {
  for (const socket of clients) send(socket, value);
}

function publicUrl(request, pathname) {
  const host = request.headers.host || `localhost:${port}`;
  return `http://${host}${pathname}`;
}

function trackResponse(request) {
  return [...tracks.values()].map(track => ({
    id: track.id,
    name: track.name,
    streamingUrl: publicUrl(request, `/audio/v1/${track.id}/stream`),
    thumbnailUrl: track.thumbnailUrl,
    audioMetadataUrl: publicUrl(request, track.audioMetadataUrl),
  }));
}

function streamAudio(request, response, track) {
  const audioFile = path.basename(track.audioFile);
  if (!/\.(mp3|m4a|aac|wav|aiff|aif|caf|flac|ogg)$/i.test(audioFile)) {
    return json(response, 500, { error: 'Configured audio file must use a supported audio extension.' });
  }
  const filename = path.join(audioDirectory, audioFile);
  if (!fs.existsSync(filename) || !fs.statSync(filename).isFile()) {
    return json(response, 404, { error: `Audio file not found: local-api/audio/${audioFile}` });
  }
  const stat = fs.statSync(filename);
  const extension = path.extname(filename).toLowerCase();
  const contentType = ({
    '.mp3': 'audio/mpeg', '.m4a': 'audio/mp4', '.aac': 'audio/aac', '.wav': 'audio/wav',
    '.aiff': 'audio/aiff', '.aif': 'audio/aiff', '.caf': 'audio/x-caf', '.flac': 'audio/flac', '.ogg': 'audio/ogg',
  })[extension] || 'application/octet-stream';
  const headers = {
    'Content-Type': contentType,
    'Accept-Ranges': 'bytes',
    'Cache-Control': 'no-cache',
  };

  const range = request.headers.range;
  const match = range && range.match(/^bytes=(\d*)-(\d*)$/);
  if (range && !match) {
    response.writeHead(416, { ...headers, 'Content-Range': `bytes */${stat.size}` });
    return response.end();
  }
  if (match) {
    let start = match[1] ? Number(match[1]) : null;
    let end = match[2] ? Number(match[2]) : null;
    if (start === null && end !== null) {
      const suffixLength = end;
      if (suffixLength === 0) start = stat.size;
      else start = Math.max(0, stat.size - suffixLength);
      end = stat.size - 1;
    } else {
      start ??= 0;
      end ??= stat.size - 1;
    }
    if (!Number.isSafeInteger(start) || !Number.isSafeInteger(end) || start >= stat.size || start > end) {
      response.writeHead(416, { ...headers, 'Content-Range': `bytes */${stat.size}` });
      return response.end();
    }
    end = Math.min(end, stat.size - 1);
    response.writeHead(206, {
      ...headers,
      'Content-Length': end - start + 1,
      'Content-Range': `bytes ${start}-${end}/${stat.size}`,
    });
    if (request.method === 'HEAD') return response.end();
    return fs.createReadStream(filename, { start, end }).pipe(response);
  }

  response.writeHead(200, { ...headers, 'Content-Length': stat.size });
  if (request.method === 'HEAD') return response.end();
  fs.createReadStream(filename).pipe(response);
}

function parseFrames(socket, chunk) {
  socket.buffer = Buffer.concat([socket.buffer, chunk]);
  while (socket.buffer.length >= 2) {
    const first = socket.buffer[0];
    const second = socket.buffer[1];
    const opcode = first & 0x0f;
    const masked = (second & 0x80) !== 0;
    let length = second & 0x7f;
    let offset = 2;
    if (length === 126) {
      if (socket.buffer.length < 4) return;
      length = socket.buffer.readUInt16BE(2);
      offset = 4;
    } else if (length === 127) {
      if (socket.buffer.length < 10) return;
      const largeLength = socket.buffer.readBigUInt64BE(2);
      if (largeLength > 1024n * 1024n) return socket.destroy();
      length = Number(largeLength);
      offset = 10;
    }
    const maskOffset = offset;
    if (masked) offset += 4;
    if (socket.buffer.length < offset + length) return;
    let payload = socket.buffer.subarray(offset, offset + length);
    if (masked) {
      payload = Buffer.from(payload);
      const mask = socket.buffer.subarray(maskOffset, maskOffset + 4);
      for (let index = 0; index < payload.length; index++) payload[index] ^= mask[index % 4];
    }
    socket.buffer = socket.buffer.subarray(offset + length);
    if (opcode === 0x8) {
      socket.end(Buffer.from([0x88, 0x00]));
      return;
    }
    if (opcode === 0x9) {
      socket.write(Buffer.from([0x8a, payload.length, ...payload]));
      continue;
    }
    if (opcode !== 0x1) continue;
    let message;
    try {
      message = JSON.parse(payload.toString('utf8'));
    } catch {
      send(socket, { type: 'error', error: 'Expected a JSON message' });
      continue;
    }
    if (message.type === 'ping') {
      send(socket, { type: 'pong', timestamp: Date.now() });
    } else if (message.type === 'setPlaybackState' && ['playing', 'paused', 'stopped'].includes(message.state)) {
      broadcast({ type: 'playbackState', state: message.state, trackId: message.trackId || trackId });
    } else if (message.type === 'emit') {
      broadcast({ type: 'event', name: String(message.name || 'test'), payload: message.payload ?? null });
    } else {
      send(socket, { type: 'error', error: 'Unknown message type' });
    }
  }
}

const server = http.createServer((request, response) => {
  if (request.method === 'OPTIONS') {
    response.writeHead(204, { 'Access-Control-Allow-Origin': '*' });
    return response.end();
  }
  if (request.method !== 'GET' && request.method !== 'HEAD') return json(response, 405, { error: 'Method not allowed' });

  const path = new URL(request.url, `http://${request.headers.host}`).pathname;
  const streamMatch = path.match(/^\/audio\/v1\/([0-9a-f-]+)\/stream$/i);
  if (streamMatch) {
    const track = tracks.get(streamMatch[1].toLowerCase());
    if (!track) return json(response, 404, { error: 'Track not found' });
    return streamAudio(request, response, track);
  }
  if (request.method === 'HEAD') {
    response.writeHead(405, { Allow: 'GET' });
    return response.end();
  }
  if (path === '/audio/v1/tracks') return json(response, 200, trackResponse(request));
  const match = path.match(/^\/audio\/v1\/([0-9a-f-]+)\/(metadata|lyric)$/i);
  if (match && tracks.has(match[1].toLowerCase())) {
    if (match[2] === 'metadata') return json(response, 200, metadata);
    if (match[2] === 'lyric') return json(response, 200, lyric);
  }
  return json(response, 404, { error: 'Not found' });
});

server.on('upgrade', (request, socket) => {
  const path = new URL(request.url, `http://${request.headers.host}`).pathname;
  const key = request.headers['sec-websocket-key'];
  if (path !== '/socket' || !key || request.headers['upgrade']?.toLowerCase() !== 'websocket') {
    socket.write('HTTP/1.1 404 Not Found\r\n\r\n');
    return socket.destroy();
  }
  const accept = crypto.createHash('sha1')
    .update(`${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`)
    .digest('base64');
  socket.write([
    'HTTP/1.1 101 Switching Protocols',
    'Upgrade: websocket',
    'Connection: Upgrade',
    `Sec-WebSocket-Accept: ${accept}`,
    '\r\n',
  ].join('\r\n'));
  socket.buffer = Buffer.alloc(0);
  clients.add(socket);
  socket.on('data', chunk => parseFrames(socket, chunk));
  socket.on('close', () => clients.delete(socket));
  socket.on('error', () => clients.delete(socket));
  send(socket, { type: 'connected', trackId, message: 'Local test socket ready' });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Mango Audio API listening at http://localhost:${port}`);
  console.log(`Mango Audio socket available at ws://localhost:${port}/socket`);
});
