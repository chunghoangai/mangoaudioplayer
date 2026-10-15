# Local API

Run from this directory with `npm start`. The server listens on port 3000 and serves:

- `GET /audio/v1/tracks`
- `GET /audio/v1/:trackId/metadata`
- `GET /audio/v1/:trackId/lyric`

The track list returns a `streamingUrl` for each track. The server builds it from the incoming request host, so a simulator request gets a localhost URL and a phone request to the Mac's LAN IP gets a LAN URL.

## Local audio streaming

Create `local-api/audio/` and put `sample.mp3` there, or set `SAMPLE_AUDIO_FILE` to a different filename. The sample track maps to that exact file, and its `streamingUrl` points to `/audio/v1/7e2f61e4-0f65-4d3e-9e73-8a3abf8a1201/stream`. The endpoint supports HTTP byte ranges (`Range` requests and `206 Partial Content`) so audio players can seek. If the configured file is missing, it returns `404` naming the expected path.

The `/audio/v1/tracks` response includes the per-track `streamingUrl` and `audioMetadataUrl`. On a physical iPhone, fetch the track list using the Mac's LAN IP (same network); the returned URLs will then use that same reachable host.

## Socket test endpoint

The same server also accepts WebSocket connections at `ws://localhost:3000/socket` (or `ws://<mac-lan-ip>:3000/socket` from a device). On connection it sends:

```json
{"type":"connected","trackId":"7e2f61e4-0f65-4d3e-9e73-8a3abf8a1201","message":"Local test socket ready"}
```

Send JSON text messages to drive app tests:

- `{"type":"ping"}` replies with `{"type":"pong","timestamp":...}`.
- `{"type":"setPlaybackState","state":"playing"}` broadcasts a `playbackState` event. Supported states are `playing`, `paused`, and `stopped`; optional `trackId` defaults to the sample track.
- `{"type":"emit","name":"test-event","payload":{"value":1}}` broadcasts a generic `event` to every connected client.

This endpoint is a test fixture for playback-state events. Audio bytes are delivered by the HTTP `streamingUrl` in the track response; the WebSocket does not carry audio data.
