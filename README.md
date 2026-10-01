# Latency Compensation

A Roblox resource that predicts where each player really is on their own screen, so server-side hit detection lines up with what players see. The prediction is capped by how fast the character is allowed to move, which keeps a client from abusing it.

[Play the demo on Roblox](https://www.roblox.com/games/98196192889917)

## Why

The server always sees a player’s character slightly in the past, by about that player’s ping. If hitboxes are checked against that position, attacks aimed at what the attacker saw can miss. Predicting ahead along the character’s velocity closes that gap.

## How it works

Every frame, for every player, the server:

1. **Scales the look-ahead by ping.** It reads the player’s network ping, refreshed every 10 seconds, and turns it into a compensation factor clamped between 75 and 180 ms.
2. **Finds the speed limit.** It checks for an active `BodyPosition`, `BodyVelocity`, `AlignPosition`, or `LinearVelocity` on the character, and falls back to the humanoid’s `WalkSpeed`.
3. **Predicts, then caps.** It moves the position forward along the character’s velocity, but never further than the speed limit allows in that time. A client reporting impossible movement cannot push its prediction beyond its real top speed.
4. **Stops at walls.** A `Blockcast` the size of the character checks the predicted move and stops it at anything in the way.

## Seeing it

The demo draws three boxes for your character:

| Box | Placed by | Shows |
| --- | --- | --- |
| Client | Your client | Where you are on your own screen |
| Server | The server | Where the server currently sees you |
| Predicted | The server | The latency-compensated position |

At higher ping, the predicted box leads the server box further, because it has more latency to make up. A settings panel lets you change walk speed and jump power to test different speeds.

## Files

| File | Runs on | Purpose |
| --- | --- | --- |
| `src/ServerScriptService/ServerCFrame.server.luau` | Server | Ping tracking, prediction, and the server and predicted boxes |
| `src/ReplicatedStorage/ClientCFrame.client.luau` | Client | Draws the client box |
| `src/StarterGui/Settings.client.luau` | Client | The walk speed and jump power controls |
| `place/LatencyCompensation.rbxlx` | Studio | The complete, ready-to-run place |

## Getting started

Open `place/LatencyCompensation.rbxlx` in Roblox Studio and press Play. The place includes the box parts, the `Hurtboxes` folder, the settings remote, and the UI that the scripts expect.

The `src` folder holds the same scripts as plain files for reading or for use with Rojo.

## Using it in your game

Swap the debug boxes for your own hurtboxes, and run your hit detection against the predicted position. It works with BodyMovers and Constraints out of the box, and the speed-limit lookup is easy to extend with your own movement types.

The settings remote lets any player set their own walk speed and jump power. That is intended for the demo. Remove or validate it before using this in a game.

## License

[MIT](LICENSE) © 2026 Anthony Saade
