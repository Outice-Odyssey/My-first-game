extends Node
# Enemy definitions — add new enemies here!
# Access with: Enemies.get_enemy("slime")

const ENEMIES = {
	"slime": {
		"name": "Slime",
		"max_hp": 20,
		"attack": 5,
		"defense": 1,
		"xp": 5,
		"gold": 3,
		"sprite": "res://assets/slime.png",
		"drops": ["noir_pistol"]
	},
	"shadow": {
		"name": "Shadow",
		"max_hp": 30,
		"attack": 8,
		"defense": 3,
		"xp": 10,
		"gold": 6,
		"sprite": "res://assets/slime.png",  # reuse slime for now
		"drops": ["reinforced_coat"]
	},
	"crimson_bat": {
		"name": "Crimson Bat",
		"max_hp": 15,
		"attack": 12,
		"defense": 1,
		"xp": 8,
		"gold": 4,
		"sprite": "res://assets/slime.png",  # reuse slime for now
		"drops": ["noir_badge"]
	}
}

func get_random_enemy():
	var keys = ENEMIES.keys()
	var random_key = keys[randi_range(0, keys.size() - 1)]
	return ENEMIES[random_key]
