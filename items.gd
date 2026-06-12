extends Node

const ITEMS = {
	# WEAPONS
	"rusty_revolver": {
		"name": "Rusty Revolver",
		"type": "weapon",
		"description": "An old gun. Still shoots.",
		"attack": 3,
		"defense": 0,
		"max_hp": 0,
		"price": 0  # starter item, free
	},
	"noir_pistol": {
		"name": "Noir Pistol",
		"type": "weapon",
		"description": "Sleek and deadly. Like the city.",
		"attack": 7,
		"defense": 0,
		"max_hp": 0,
		"price": 50
	},
	"shadow_blade": {
		"name": "Shadow Blade",
		"type": "weapon",
		"description": "Forged in darkness.",
		"attack": 12,
		"defense": 0,
		"max_hp": 0,
		"price": 120
	},

	# ARMOR
	"trench_coat": {
		"name": "Trench Coat",
		"type": "armor",
		"description": "Standard issue for the city's forgotten.",
		"attack": 0,
		"defense": 2,
		"max_hp": 5,
		"price": 0  # starter item
	},
	"reinforced_coat": {
		"name": "Reinforced Coat",
		"type": "armor",
		"description": "Lined with steel plates. Heavy but worth it.",
		"attack": 0,
		"defense": 5,
		"max_hp": 15,
		"price": 80
	},
	"shadow_cloak": {
		"name": "Shadow Cloak",
		"type": "armor",
		"description": "Woven from darkness itself.",
		"attack": 0,
		"defense": 8,
		"max_hp": 25,
		"price": 150
	},

	# ACCESSORIES
	"lucky_coin": {
		"name": "Lucky Coin",
		"type": "accessory",
		"description": "Heads you win. Tails they lose.",
		"attack": 1,
		"defense": 1,
		"max_hp": 5,
		"price": 0  # starter item
	},
	"noir_badge": {
		"name": "Noir Badge",
		"type": "accessory",
		"description": "Authority in the dark city.",
		"attack": 2,
		"defense": 2,
		"max_hp": 10,
		"price": 100
		},
		# CONSUMABLES
"health_potion": {
	"name": "Health Potion",
	"type": "consumable",
	"description": "Restores 30 HP.",
	"effect": "heal",
	"value": 30,
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"price": 20
},
"noir_whiskey": {
	"name": "Noir Whiskey",
	"type": "consumable",
	"description": "Burns going down. Heals 15 HP, boosts ATK by 3 for 3 turns.",
	"effect": "heal_and_buff",
	"value": 15,
	"attack_buff": 3,
	"buff_turns": 3,
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"price": 35
},
"smoke_bomb": {
	"name": "Smoke Bomb",
	"type": "consumable",
	"description": "Guarantees escape from battle.",
	"effect": "escape",
	"value": 0,
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"price": 25
},
"adrenaline_shot": {
	"name": "Adrenaline Shot",
	"type": "consumable",
	"description": "Doubles ATK for 2 turns.",
	"effect": "attack_buff",
	"value": 0,
	"attack_buff": 8,
	"buff_turns": 2,
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"price": 40
},
"bandage": {
	"name": "Bandage",
	"type": "consumable",
	"description": "Cheap. Heals 10 HP.",
	"effect": "heal",
	"value": 10,
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"price": 10
},
	
}

func get_item(item_id):
	if ITEMS.has(item_id):
		return ITEMS[item_id]
	return null
