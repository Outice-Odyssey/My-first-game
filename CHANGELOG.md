# CHANGELOG — Noir Chronicles

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) conventions adapted for game development.

Versioning: `MAJOR.MINOR.PATCH`
- **MAJOR** — complete overhaul or new chapter/act
- **MINOR** — new gameplay system or feature
- **PATCH** — bug fixes, balance tweaks, small improvements

---

## [Unreleased]
- Battle music (noir jazz loop)
- Town map and shop
- NPC dialogue system
- Overworld music
- Game export

---

## [0.7.0] — 2026-06-20
### Added
- Title screen with NOIR CHRONICLES branding
- Continue / New Game / Quit options on title screen
- Title screen detects existing save file automatically

---

## [0.6.0] — 2026-06-20
### Added
- Game menu accessible via Escape key (Resume, Delete Save, Quit)
- Delete save confirmation screen with YES/NO navigation
- Tabbed inventory screen — Equipment tab and Items tab
- Consumables system: Bandage, Health Potion, Noir Whiskey, Smoke Bomb, Adrenaline Shot
- Attack buffs from consumable items with turn duration
- Smoke Bomb allows escape from battle
- Item drops from enemies after battle victory
- Equipment system — weapon, armor, accessory slots
- Items autoload (Items.gd) for global item data access
- Skills autoload (Skills.gd) for global skill data access

### Changed
- Battle Item option now uses consumables instead of a fixed potion
- Inventory opens with I key, Game Menu opens with Escape key

---

## [0.5.0] — 2026-06-20
### Added
- Skills system — Power Strike (2x damage), Patch Up (heal 15 HP), Shadow Step (dodge)
- Skill cooldown system — skills unavailable for N turns after use
- Skills submenu in battle accessible from main battle menu
- Dodge mechanic — enemy misses if Shadow Step was used
- Defense stat reduces incoming enemy damage

---

## [0.4.0] — 2026-06-20
### Added
- Save and load system (user://savegame.json)
- Auto-save after every battle win or loss
- Manual save with ui_select key on world map
- PlayerStats autoload (GameData) for persistent player data across scenes
- Enemies autoload for global enemy data access
- Multiple random enemies — Slime, Shadow, Crimson Bat
- EXP system — earn experience from winning battles
- Level up system — stats increase automatically on level up
- Gold rewards from battles
- Victory message shows EXP gained, gold gained, and level up notification

### Fixed
- Level up text no longer shows when player doesn't level up
- Level number no longer displays with .0 suffix

---

## [0.3.0] — 2026-06-20
### Added
- Full turn-based battle system with player and enemy turns
- Attack action deals random damage within range
- Item action heals 10 HP
- Enemy AI attacks back automatically after player turn
- 1 second delay between turns for readability
- Battle state machine (PLAYER_TURN, ENEMY_TURN, WIN, LOSE)
- HP bars for both player and enemy using ColorRect
- Victory text on winning
- Noir red and black battle UI using hand-drawn panel.png asset
- Red demon slime enemy sprite on battle screen
- Battle start, attack hit, damage, and victory sound effects
- Hand-composed noir victory jingle (LMMS)
- Footstep sounds when walking

### Fixed
- Victory message no longer gets overwritten by "your turn" text

---

## [0.2.0] — 2026-06-20
### Added
- Random encounter system — rolls dice every 3 steps
- 20% encounter chance per roll
- Scene switching — world map to battle scene and back
- Hand-drawn noir cobblestone world tiles (16x16, purple-grey)
- Hand-drawn red demon slime enemy sprite (32x32)
- Hand-drawn noir panel UI asset for battle screen
- HP bar background and fill assets

---

## [0.1.0] — 2026-06-20
### Added
- Top-down grid movement (tile-by-tile like Final Fantasy)
- Smooth lerp sliding between tiles
- 4-directional movement (up, down, left, right)
- Animated noir detective player sprite (128x128 spritesheet, 4 directions × 4 frames)
- Walking animation plays correct direction, idles on frame 0 when still
- Camera2D follows player
- TileMapLayer world painted with cobblestone tiles
- Pixel-perfect rendering (Nearest filter)
- CharacterBody2D with CollisionShape2D

---

## [0.0.1] — 2026-06-20
### Base Features (Foundation)
- Godot 4.6.3 project initialized
- Project structure: assets/, data/, sprites/, tilesets/, audio/sfx/, audio/music/
- Ubuntu development environment configured
- Git repository initialized, SSH connected to GitHub (Outice-Odyssey)
- VS Code with GDScript extension
- Aseprite for pixel art
- LMMS for music composition
- jsfxr for sound effects
