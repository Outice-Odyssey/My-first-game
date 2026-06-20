# Noir Chronicles — Game Architecture

## Scene Flow

```
title_screen.tscn
    │
    ├─ Continue ──► world.tscn ◄──────────────────────┐
    │                   │                              │
    └─ New Game ─────►  │  (random encounter)          │
                        ├─► battle.tscn ───► win/lose ─┘
                        │
                        ├─► inventory.tscn (open_inventory key)
                        │
                        └─► game_menu.tscn (open_menu key)
```

## Scripts at a Glance

| File | Extends | Role |
|---|---|---|
| `title_screen.gd` | Node2D | Main menu: Continue / New Game / Quit |
| `player.gd` | CharacterBody2D | Tile movement, footstep SFX, random encounter trigger |
| `PlayerStats.gd` | Node | Global singleton (`GameData`): all player data, save/load |
| `battle.gd` | Node2D | Turn-based combat loop, skill/item usage, win/lose |
| `inventory.gd` | Node2D | Equipment and consumables viewer/equip screen |
| `game_menu.gd` | Node2D | Pause menu: resume, delete save, quit |
| `items.gd` | Node | Static item database (`Items` autoload) |
| `data/enemies.gd` | Node | Static enemy database (`Enemies` autoload) |
| `data/skills.gd` | Node | Static skill database (`Skills` autoload) |
| `EnemyData.gd` | Node | Resource class for individual enemy instances (unused at runtime) |

## Global Singletons (Autoloads)

These are registered in **Project → Project Settings → Autoload** and are
accessible from any script by their name.

| Autoload name | Script | What it holds |
|---|---|---|
| `GameData` | `PlayerStats.gd` | Level, HP, ATK, DEF, gold, inventory, equipment slots, active buffs, save/load |
| `Items` | `items.gd` | Dictionary of every item keyed by ID |
| `Enemies` | `data/enemies.gd` | Dictionary of every enemy keyed by ID |
| `Skills` | `data/skills.gd` | Dictionary of every skill keyed by ID |

## Data Layer

All game data lives in plain `const` dictionaries. To add content, just add
a new entry to the matching dictionary — no code changes needed anywhere else.

**items.gd** — three item types:
- `weapon` → fills `weapon_slot`, adds ATK
- `armor` → fills `armor_slot`, adds DEF / max HP
- `accessory` → fills `accessory_slot`, adds a mix of stats
- `consumable` → stored in `GameData.consumables` (keyed by count), used in battle

**data/enemies.gd** — each enemy has `name`, `max_hp`, `attack`, `defense`,
`xp`, `gold`, and a `drops` list of item IDs awarded on defeat.

**data/skills.gd** — each skill has a `type` (`damage`, `heal`, or `dodge`),
a `cooldown` (turns), and type-specific fields (`multiplier`, `heal_amount`).

## Player Stats & Equipment

`PlayerStats.gd` (autoloaded as `GameData`) is the single source of truth for
everything about the player. Equipment bonus stats are computed at read time:

```
get_total_attack()  → base attack + weapon.attack + armor.attack + accessory.attack + active buff
get_total_defense() → base defense + all equipment defense
get_total_max_hp()  → base max_hp + all equipment max_hp
```

Equipping an item via `GameData.equip(item_id)` simply overwrites the matching
slot (`weapon_slot`, `armor_slot`, or `accessory_slot`).

## Battle System

`battle.gd` runs a simple state machine:

```
BattleState { PLAYER_TURN → ENEMY_TURN → PLAYER_TURN … → WIN | LOSE }
```

Turn sequence:
1. Player chooses **Attack**, **Skills**, or an **Item** via keyboard.
2. Damage/heal/dodge is applied and the state switches to `ENEMY_TURN`.
3. After a 1-second delay, the enemy attacks (or misses if the player dodged).
4. Skill cooldowns tick down each enemy turn.
5. `WIN` → save progress, return to world. `LOSE` → reset HP to 1, save, return.

## Save System

Save file: `user://savegame.json` (Godot's user data directory).

`GameData.save()` serializes the stats dictionary to JSON.
`GameData.load_game()` deserializes it back on startup.

The title screen calls `load_game()` when the player picks **Continue**.
The game menu's **Delete Save** option resets all `GameData` fields to defaults
and removes the file from disk.

## Random Encounter Flow

```
player.gd  _physics_process()
    └─ check_for_encounter()   every STEPS_BEFORE_CHECK (3) steps on grass
           └─ randi_range(1, 100) ≤ ENCOUNTER_CHANCE (20)
                  └─ change_scene_to_file("res://battle.tscn")
```

`battle.gd._ready()` then calls `Enemies.get_random_enemy()` to pick a
random entry from the enemy dictionary.
