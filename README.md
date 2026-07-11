<div align="center">

<img src="poster.png" alt="Nocturnal Reign" width="256" height="256">

# Nocturnal Reign

**Zombies fear the sun and rule the night.**

A day/night zombie AI overhaul for Project Zomboid Build 42 — with a rare, terrifying apex predator: the **Zombie Lord**.

[![Project Zomboid Build 42](https://img.shields.io/badge/Project%20Zomboid-Build%2042-red)](https://projectzomboid.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/Lua-Kahlua-2C2D72?logo=lua&logoColor=white)](media/lua)

[Features](#features) • [Installation](#installation) • [Sandbox Options](#sandbox-options) • [How It Works](#how-it-works) • [FAQ](#faq) • [Contributing](#contributing)

</div>

---

## The Premise

By day, the dead are weak. Any zombie caught standing in direct outdoor sunlight slows to a crippled shamble and desperately seeks shelter indoors — clear a street at noon and it stays clear, but every building becomes a den of lurking dead.

By night, the equation flips. At dusk the horde mutates: every zombie becomes a fast, sharp-eyed, keen-eared sprinter. Daytime is for looting. Nighttime is for barricading the doors and praying.

And sometimes — rarely — a zombie rises as something worse.

## Features

### ☀️ Daytime Photophobia
- Zombies in direct outdoor sunlight are forced into the slowest possible shamble.
- Sunlit zombies actively retreat to the nearest **deep interior** — genuinely inside buildings, not hovering at broken windows.
- Sheltered zombies hold their position indoors instead of wandering back into the sun.
- Zombies with a live target still fight: sunlight weakens the horde, it doesn't pacify it.
- Cloud cover matters — deep dusk/dawn gloom and heavy fog shield zombies even outdoors.
- Optional (**off by default**): sunlight slowly burns exposed zombies to death.

### 🌙 Nightfall Mutation
- Between dusk and dawn every zombie becomes a **sprinter** with senses turned up to maximum.
- Speed, sight, hearing, and tracking memory all revert at sunrise.
- Day and night boundaries are fully configurable.

### 👑 The Zombie Lord
A rare alpha predator (default: 0.5% of zombies) that plays by its own rules:

- **Immune to daylight.** The sun means nothing to it.
- **Unmistakable.** Dressed in skull mask, bone armour, and a black robe; tinted blood-red and casting an eerie red glow across the ground around it.
- **A stalker, not a sprinter.** It senses the closest survivor from hundreds of tiles away and walks — slowly, deliberately, inevitably — toward them.
- **A pack leader.** It silently calls every zombie it passes into a loose escort formation, arriving with a horde in tow.
- **A coordinator.** The moment it spots you, it broadcasts your position to every zombie in a wide radius — the whole pack converges at once.
- **It calls the fog.** While a Lord is engaged, thick fog rolls in and shields its horde from the sun; the pack fights at full nighttime ferocity until it lifts.
- **It opens doors.** Unlocked doors don't stop it — it turns the knob and walks in. Locked and barricaded doors still hold. *(Dormant on builds without a per-zombie cognition API, including 42.19 — re-activates automatically when the game exposes one.)*
- **It raises the dead.** Once per day (configurable), an engaged Lord lets out a blood-curdling shriek and a horde claws its way up out of the earth around it — rising from among the dead at reduced health, hidden by the fog the Lord has already called. The horde scales with the Lord: base size × the town's tier, so Louisville's Lord answers with four times what Rosewood's can call.
- **A boss fight, not a speed bump.** 10× health by default (instant-kill criticals still work), and its corpse carries rare high-value loot — plus its full regalia as lootable trophies.

### 🏰 Territorial Lords & Liberation

Every major town is the domain of its own named Lord — the first phase of a boss-progression campaign across the map:

- **12 built-in territories** spanning the Build 42 map, tiered 1–4 by difficulty: start in Rosewood or Riverside, work up through Muldraugh and West Point, and face the endgame in Louisville.
- **The Lord rises on arrival.** Enter a town whose Lord is unslain and it spawns somewhere out of sight, then starts stalking.
- **Leashed to its domain.** A territorial Lord hunts within (and slightly beyond) its town's borders and walks home rather than being kited across the map. The classic free-roaming Lord still haunts the wilderness between towns.
- **Tier-scaled fights.** Higher-tier towns host tougher Lords (+25% health per tier above 1).
- **Liberation.** Slay a town's Lord and the town is freed: its zombies stop mutating into night sprinters (toggleable), permanently — or until the Lord respawns, if you enable a respawn timer. Liberation state persists in the save.

### ⚔️ The Lord's Chosen (Mini-Bosses)

Towns of tier 2 and above are also guarded by the Lord's court — one fewer chosen than the town's tier, so Rosewood is a clean duel while Louisville fields the Lord and three lieutenants:

| Chosen | Look | Its power |
|---|---|---|
| **The Shepherd** | Priest's cassock | Gathers and commands the escort pack |
| **The Herald** | Cultist's hood | Broadcasts your position to the horde |
| **The Gravedigger** | Scarecrow's rags | Shrieks the dead up out of the earth (at base strength — the apprentice, never the equal) |
| **The Brute** | Spiked armour | Nothing clever — it's the Lord's bulwark, and very hard to put down |

Every chosen you slay **strips that power from the town's Lord**: kill the Herald and the Lord can no longer call the swarm onto you; kill the Gravedigger and the dead stay dead; kill the Brute and the Lord rises without its tier health bonus. Powers default ON — the chosen are strategic prep, not a gate. Thin the court first, or rush the throne at full strength: your call. Mini-bosses glow ember-amber (Lords glow blood-red) and each drops one bundle of boss loot.

And don't trust a chosen that goes down easy: once per life, a chosen dropped to half health or knocked off its feet **feigns death** — the glow goes dark, it lies among the corpses, and it waits for you to come loot it.

Every timing, damage, chance, and radius value above is exposed in [Sandbox Options](#sandbox-options).

## Installation

### Manual (recommended for now)

1. Download or clone this repository:
   ```sh
   git clone https://github.com/CosmicQ/pz-nocturnal-reign.git
   ```
2. Copy (or symlink) `Contents/mods/NocturnalReign` into your Zomboid mods directory:

   | OS | Mods directory |
   |---|---|
   | Linux | `~/Zomboid/mods/` |
   | Windows | `C:\Users\<you>\Zomboid\mods\` |
   | macOS | `~/Zomboid/mods/` |

   ```sh
   ln -s /path/to/pz-nocturnal-reign/Contents/mods/NocturnalReign ~/Zomboid/mods/NocturnalReign
   ```
3. Enable **Nocturnal Reign** in the in-game **Mods** menu.
4. Start a new game, or add it to an existing save — both work. Tune everything under **Sandbox Options → Nocturnal Reign**.

> **Note:** Adding the mod to an in-progress save works out of the box; sandbox values fall back to sane defaults until the schema merges in on the next full reload.

### Requirements

- Project Zomboid **Build 42** (developed and tested against **42.19**).
- No dependencies. No new assets — the Lord's regalia and loot are built entirely from vanilla items.

## Sandbox Options

All options live under **Sandbox Options → Nocturnal Reign**.

### Day / Night Cycle

| Option | Default | Range | Description |
|---|---|---|---|
| Day Start Hour | `5` | 0–23 | Hour the photophobia window begins |
| Night Start Hour | `20` | 0–23 | Hour the nightfall mutation window begins |

### Daytime Photophobia

| Option | Default | Range | Description |
|---|---|---|---|
| Enable Daytime Photophobia | `on` | — | Sunlit zombies slow to a crawl and retreat indoors |
| Sunlight Damages Zombies | `off` | — | Exposed zombies also slowly lose health |
| Sunburn Tick Rate (seconds) | `10` | 1–300 | In-game seconds between burn damage applications |
| Sunburn Damage (% per tick) | `2` | 1–100 | Percent of max health removed per burn tick |

### Nightfall Mutation

| Option | Default | Range | Description |
|---|---|---|---|
| Enable Nightfall Mutation | `on` | — | Zombies become sprinters with maxed senses at night |
| Sprinter Speed Multiplier | `2.0` | 1.0–5.0 | Sprinter speed, where the build's zombie API exposes a direct multiplier |

### The Zombie Lord

| Option | Default | Range | Description |
|---|---|---|---|
| Enable Zombie Lord | `on` | — | Master toggle for Lord spawns |
| Zombie Lord Chance (%) | `0.5` | 0–100 | Per-zombie promotion chance, rolled once when first simulated |
| Zombie Lord Health Multiplier | `10` | 1–100 | Toughness relative to a normal zombie |
| Zombie Lord Red Glow | `on` | — | Blood-red tint and ground glow |
| Zombie Lord Opens Doors | `on` | — | Lords open unlocked doors regardless of world Cognition lore |
| Zombie Lords Call Fog | `on` | — | Fog rolls in while a Lord is engaged, sun-shielding its horde |
| Zombie Lord Trophies | `on` | — | A slain Lord's corpse carries rare high-value loot |
| Zombie Lord Command Radius (tiles) | `25` | 5–50 | Range at which a Lord gathers nearby zombies into its pack |
| Zombie Lord Alert Radius (tiles) | `40` | 10–100 | Range of the "player spotted" broadcast to the horde |
| Zombie Lord Seek Radius (tiles) | `400` | 0–2000 | Range of the Lord's long-distance prey sense (`0` disables stalking) |

### Raise the Dead

| Option | Default | Range | Description |
|---|---|---|---|
| Enable Raise the Dead | `on` | — | Summoners shriek a horde up out of the earth |
| Cooldown (days) | `1` | 1–30 | In-game days between casts per summoner |
| Base Horde Size | `10` | 1–50 | Zombies raised by a tier-1 summoner; a territorial Lord raises base × its town's tier (hard cap 60 per cast) |
| Raised Zombie Health (%) | `50` | 1–100 | Health of the risen |
| Radius (tiles) | `25` | 5–50 | Radius around the summoner in which the horde surfaces |

### Territorial Lords & The Chosen

| Option | Default | Range | Description |
|---|---|---|---|
| Enable Territorial Lords | `on` | — | Every major town hosts its own named Lord |
| Territorial Lord Respawn (days) | `0` | 0–365 | Days until a slain town's Lord returns (`0` = liberation is permanent) |
| Liberation Calms the Night | `on` | — | Zombies in a liberated town stop mutating at night |
| Enable Mini-Bosses | `on` | — | Tier 2+ towns field the Lord's chosen |

## How It Works

The mod is five Lua files with no assets beyond the poster. The repository is laid out in Build 42's versioned Workshop format, so the repo root doubles as a Steam Workshop staging folder:

```
workshop.txt                                # Steam Workshop metadata
preview.png                                 # Workshop thumbnail
Contents/mods/NocturnalReign/
├── common/                                 # Shared-across-builds folder (empty)
└── 42/                                     # Build 42 version folder
    ├── mod.info
    ├── poster.png
    └── media/
        ├── sandbox-options.txt                     # Sandbox schema (27 options)
        └── lua/
            ├── shared/
            │   ├── NocturnalReign_SandboxOptions.lua   # Config layer + day/night logic
            │   ├── NocturnalReign_Zones.lua            # Town territories (name, box, tier)
            │   ├── NocturnalReign_Mutation.lua         # Photophobia/night stat rules (run on every machine)
            │   └── Translate/EN/Sandbox_EN.txt         # Option labels & tooltips
            ├── server/
            │   └── NocturnalReign_Server.lua           # Authoritative simulation (bosses, campaign, pathing)
            └── client/
                └── NocturnalReign_Client.lua           # Glow/warnings/banners + the MP client legs
```

Design decisions worth knowing about:

- **Authority follows the engine's ownership model.** Campaign state, boss AI, pathing orders, and damage are server-authoritative. But PZ multiplayer hands each zombie's moment-to-moment simulation to the *client nearest to it* — so the day/night stat rules live in a shared module as deterministic functions of the world clock and climate, and every machine (server and each client) applies them to the zombies it simulates. No per-zombie state crosses the network, and all machines agree by construction.
- **Explicit sync for everything else.** Object ModData is never synchronized in multiplayer, so the server pushes a once-per-second `state` command: live boss roster (matched client-side by onlineID), fog state, and liberated zones. Players who join mid-fight get the fog and the glow within a second.
- **Performance-first scheduling.** The mod never hooks `OnZombieUpdate` (which fires per zombie *per tick*). The population sweeps run once per in-game minute; the rare bosses tick on a ~1-second cadence. A city full of zombies costs almost nothing.
- **The Lord commands through the engine, not around it.** Pack gathering and player broadcasts use `addSound()` — the same mechanism as gunshots and car alarms — so commanded zombies path with the engine's own behaviour tree instead of fighting it, and the design can't desync from how zombie movement works on a given build.
- **The risen come up out of the ground.** Raise the Dead spawns its horde through the engine's MP-safe helper, born in the engine's own fake-dead state — sprawled among the corpses until the summoner's shriek (or your footsteps) stirs them to their feet.
- **API probing over hard-coding.** Build 42 is still reworking parts of the zombie API. Gait changes prefer the official 42.18+ methods (`doSprinter()` and friends) and fall back to probing legacy setter names (`trySetters`), so a renamed method degrades gracefully instead of erroring.

## FAQ

**Does it work in multiplayer?**
Yes — the mod is architected for Build 42's unstable multiplayer (42.13+): deterministic day/night rules run on every machine so client-simulated zombies behave correctly, and boss identity/fog/liberation state is broadcast to clients every second. Tested in co-op hosting and against a dedicated server on 42.19. Note that B42 MP itself is still stress-test quality (The Indie Stone's words), and its known zombie desync issues are engine-level, not mod-level. Reports welcome — [open an issue](../../issues).

**Can I add it to an existing save?**
Yes. Zombies are initialized (and roll their Lord chance) the first time the mod sees them.

**How do I know it's running?**
Check `~/Zomboid/console.txt` for `[NocturnalReign]` lines — the sweep logs a heartbeat on load and once per in-game hour, and announces every Lord that rises or falls.

**A Lord spawned during the day and the horde isn't burning — bug?**
Check the weather. Heavy fog (natural or Lord-called) shields zombies from the sun by design.

**Sprinters at night are too much for my playstyle.**
Everything is a sandbox option. Turn off Nightfall Mutation and keep only the photophobia + Lord mechanics (or vice versa) — the modules are fully independent.

## Compatibility

- Built for **Build 42**; verified against **42.19**.
- Should coexist with most mods. Expect interactions with other mods that rewrite zombie speed/senses per-zombie (last writer wins on any given sweep).
- No vanilla files are overwritten and no new items are defined.

## Contributing

Bug reports, balance feedback, and pull requests are all welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for dev setup, code conventions, and how to QA changes against a live game.

## License

[MIT](LICENSE) — do whatever you like, including reusing pieces in your own mods. Attribution appreciated.

---

<div align="center">

*The sun is your shield. The night is theirs. And somewhere out there, something is already walking toward you.*

</div>
