extends Node
class_name PlayerStats

# Basic stats
@export var level: int = 1
@export var xp = 0
@export var xp_to_next = 10

# HP
@export var max_hp = 30
@export var current_hp = 30

# Combat stats
@export var attack = 8
@export var defense = 2
# Equipment slots — store item IDs
@export var weapon_slot = "rusty_revolver"    # starter weapon
@export var armor_slot = "trench_coat"         # starter armor
@export var accessory_slot = "lucky_coin"      # starter accessory
# Skills the player knows
@export var known_skills = ["power_strike", "patch_up"]

# Cooldowns — tracks turns remaining for each skill
var skill_cooldowns = {}

# Inventory — list of item IDs the player owns
@export var inventory = ["rusty_revolver", "trench_coat", "lucky_coin"]
# Separate consumables inventory — stores item_id and quantity
@export var consumables = {
	"bandage": 3,
	"health_potion": 1
}

# Active buffs — tracks ongoing effects
var active_buffs = {
	"attack_buff": 0,    # bonus attack
	"buff_turns": 0      # turns remaining
}

# Currency
@export var gold = 0
func _ready():
	load_game()

# Called when player levels up
func gain_xp(amount):
	xp += amount
	print("Gained ", amount, " EXP! Total: ", xp, "/", xp_to_next)
	
	# Keep levelling up as long as we have enough exp
	while xp >= xp_to_next:
		level_up()

func level_up():
	xp -= xp_to_next
	level += 1
	
	# Each level increases stats
	max_hp += 5
	current_hp = max_hp    # full heal on level up!
	attack += 2
	defense += 1
	
	# Next level requires more exp (gets harder each time)
	xp_to_next = int(xp_to_next * 1.5)
	
	print("LEVEL UP! Now level ", level)
	print("HP: ", max_hp, " ATK: ", attack, " DEF: ", defense)
	# Where the save file lives on disk
	# Get total attack including equipment
func add_consumable(item_id, amount = 1):
	if consumables.has(item_id):
		consumables[item_id] += amount
	else:
		consumables[item_id] = amount

func remove_consumable(item_id, amount = 1):
	if consumables.has(item_id):
		consumables[item_id] -= amount
		if consumables[item_id] <= 0:
			consumables.erase(item_id)

func get_consumable_count(item_id):
	return consumables.get(item_id, 0)

# Override get_total_attack to include buffs
func get_total_attack():
	var total = attack
	if weapon_slot != "":
		total += Items.get_item(weapon_slot)["attack"]
	if armor_slot != "":
		total += Items.get_item(armor_slot)["attack"]
	if accessory_slot != "":
		total += Items.get_item(accessory_slot)["attack"]
	total += active_buffs["attack_buff"]
	return total
# Get total defense including equipment
func get_total_defense():
	var total = defense
	if weapon_slot != "":
		total += Items.get_item(weapon_slot)["defense"]
	if armor_slot != "":
		total += Items.get_item(armor_slot)["defense"]
	if accessory_slot != "":
		total += Items.get_item(accessory_slot)["defense"]
	return total

# Get total max HP including equipment
func get_total_max_hp():
	var total = max_hp
	if weapon_slot != "":
		total += Items.get_item(weapon_slot)["max_hp"]
	if armor_slot != "":
		total += Items.get_item(armor_slot)["max_hp"]
	if accessory_slot != "":
		total += Items.get_item(accessory_slot)["max_hp"]
	return total

# Equip an item from inventory
func equip(item_id):
	var item = Items.get_item(item_id)
	if item == null:
		return
	
	# Put it in the right slot
	match item["type"]:
		"weapon":
			weapon_slot = item_id
		"armor":
			armor_slot = item_id
		"accessory":
			accessory_slot = item_id
	
	print("Equipped ", item["name"])
	print("ATK: ", get_total_attack(), " DEF: ", get_total_defense(), " HP: ", get_total_max_hp())
const SAVE_PATH = "user://savegame.json"

func save():
	# Create a dictionary of all data to save
	var data = {
		"level": level,
		"xp": xp,
		"xp_to_next": xp_to_next,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"gold": gold,
		"weapon_slot": weapon_slot,
		"armor_slot": armor_slot,
		"accessory_slot": accessory_slot,
		"inventory": inventory,
		"consumables": consumables,
	}
	
	# Open the file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	# Convert dictionary to JSON text and write it
	file.store_string(JSON.stringify(data))
	
	# Close the file
	file.close()
	
	print("Game saved!")

func load_game():
	# Check if a save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found — starting fresh")
		return
	
	# Open the file for reading
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	# Read the text and convert back to dictionary
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		print("Save file corrupted!")
		return
	
	var data = json.get_data()
	
	# Load all values back
	level = int(data["level"])
	xp = int(data["xp"])
	xp_to_next = int(data["xp_to_next"])
	current_hp = int(data["current_hp"])
	max_hp = int(data["max_hp"])
	attack = int(data["attack"])
	defense = int(data["defense"])
	gold = int(data["gold"])
	weapon_slot = data["weapon_slot"]
	armor_slot = data["armor_slot"]
	accessory_slot = data["accessory_slot"]
	inventory = data["inventory"]
	consumables = data["consumables"]
	
	print("Game loaded! Level ", level, " | HP ", current_hp, "/", max_hp)
