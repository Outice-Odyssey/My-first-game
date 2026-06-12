extends Node

const SKILLS = {
	"power_strike": {
		"name": "Power Strike",
		"description": "Deal double damage.",
		"cooldown": 2,
		"type": "damage",
		"multiplier": 2.0
	},
	"patch_up": {
		"name": "Patch Up",
		"description": "Heal 15 HP.",
		"cooldown": 3,
		"type": "heal",
		"heal_amount": 15
	},
	"shadow_step": {
		"name": "Shadow Step",
		"description": "Dodge the next attack.",
		"cooldown": 2,
		"type": "dodge"
	}
}

func get_skill(skill_id):
	if SKILLS.has(skill_id):
		return SKILLS[skill_id]
	return null
