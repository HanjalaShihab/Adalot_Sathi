# TODO — Fix "Could not reach the server" on login/register

## Steps
- [x] Investigate root cause of connection error
- [x] Update mobile app base URL to the machine's real LAN IP (`192.168.0.104`)
- [x] Restart backend bound to `0.0.0.0:8000` (reachable over LAN)
- [x] Update README to document `--host=0.0.0.0` for physical-device testing
- [x] Verify backend reachable via `http://192.168.0.104:8000`
- [x] Open port 8000 in firewalld (was blocking inbound LAN connections)

## Remaining (phone side, user action)
- [ ] Rebuild & reinstall the Flutter app so it uses the new `192.168.0.104` URL
- [ ] Ensure the phone is on the same Wi-Fi network as the backend machine
