extends Node2D

var selected_index = 0
var current_tab = "equipment"  # "equipment" or "consumables"
var inventory_items = []
var consumable_items = []

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	refresh_lists()
	draw_inventory()

func refresh_lists():
	inventory_items = GameData.inventory
	consumable_items = GameData.consumables.keys()

func draw_stats():
	print("weapon: ", GameData.weapon_slot)
	print("armor: ", GameData.armor_slot)  
	print("accessory: ", GameData.accessory_slot)
	var hovered_id = ""
	if current_tab == "equipment" and inventory_items.size() > 0:
		hovered_id = inventory_items[selected_index]
	var hovered_item = Items.get_item(hovered_id)
	var current_slot_id = ""
	if hovered_item != null:
		match hovered_item["type"]:
			"weapon":    current_slot_id = GameData.weapon_slot
			"armor":     current_slot_id = GameData.armor_slot
			"accessory": current_slot_id = GameData.accessory_slot
	var d_atk = 0
	var d_def = 0
	var d_hp  = 0

	if hovered_item != null and current_slot_id != hovered_id:
		var current_item = Items.get_item(current_slot_id)
		if current_item != null:
			d_atk = hovered_item["attack"]  - current_item["attack"]
			d_def = hovered_item["defense"] - current_item["defense"]
			d_hp  = hovered_item["max_hp"]  - current_item["max_hp"]

	var hp_label = Label.new()
	hp_label.position = Vector2(30, 50)
	hp_label.text = "HP   " + str(GameData.get_total_max_hp())
	hp_label.add_theme_font_size_override("font_size", 16)
	hp_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	$ItemList.add_child(hp_label)
	if d_hp != 0:
		var diff = Label.new()
		diff.position = Vector2(130, 50)
		diff.text = ("▲ +" if d_hp > 0 else "▼ ") + str(d_hp)
		diff.add_theme_font_size_override("font_size", 14)
		diff.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2) if d_hp > 0 else Color(0.7, 0.1, 0.1))
		$ItemList.add_child(diff)

	var atk_label = Label.new()
	atk_label.position = Vector2(30, 80)
	atk_label.text = "ATK  " + str(GameData.get_total_attack())
	atk_label.add_theme_font_size_override("font_size", 16)
	atk_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	$ItemList.add_child(atk_label)
	if d_atk != 0:
		var diff = Label.new()
		diff.position = Vector2(130, 80)
		diff.text = ("▲ +" if d_atk > 0 else "▼ ") + str(d_atk)
		diff.add_theme_font_size_override("font_size", 14)
		diff.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2) if d_atk > 0 else Color(0.7, 0.1, 0.1))
		$ItemList.add_child(diff)

	var def_label = Label.new()
	def_label.position = Vector2(30, 110)
	def_label.text = "DEF  " + str(GameData.get_total_defense())
	def_label.add_theme_font_size_override("font_size", 16)
	def_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	$ItemList.add_child(def_label)
	if d_def != 0:
		var diff = Label.new()
		diff.position = Vector2(130, 110)
		diff.text = ("▲ +" if d_def > 0 else "▼ ") + str(d_def)
		diff.add_theme_font_size_override("font_size", 14)
		diff.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2) if d_def > 0 else Color(0.7, 0.1, 0.1))
		$ItemList.add_child(diff)

func draw_inventory():
	for child in $ItemList.get_children():
		child.queue_free()
	
	# Draw tab headers
	var tab_label = Label.new()
	tab_label.position = Vector2(400, 30)
	tab_label.add_theme_font_size_override("font_size", 18)
	
	if current_tab == "equipment":
		tab_label.text = "[ EQUIPMENT ]  Items"
		tab_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		tab_label.text = "  Equipment  [ ITEMS ]"
		tab_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	$ItemList.add_child(tab_label)
	
	# Draw items based on current tab
	var items_to_show = inventory_items if current_tab == "equipment" else consumable_items
	
	for i in range(items_to_show.size()):
		var item_id = items_to_show[i]
		var item = Items.get_item(item_id)
		if item == null:
			continue
		
		var label = Label.new()
		label.position = Vector2(400,70 + i * 35)
		label.add_theme_font_size_override("font_size", 16)
		
		if current_tab == "equipment":
			var equipped = ""
			if GameData.weapon_slot == item_id or GameData.armor_slot == item_id or GameData.accessory_slot == item_id:
				equipped = " [E]"
			label.text = item["name"] + equipped

			if i == selected_index:
				var type_label = Label.new()
				type_label.position = Vector2(410, 70 + i * 35 + 18)
				type_label.text = item["type"].capitalize()
				type_label.add_theme_font_size_override("font_size", 11)
				type_label.add_theme_color_override("font_color", Color(0.55, 0.25, 0.1))
				$ItemList.add_child(type_label)
		else:
			var count = GameData.get_consumable_count(item_id)
			label.text = item["name"] + " x" + str(count)

			if i == selected_index:
				var effect_map = {
					"heal": "Healing",
					"heal_and_buff": "Healing / Buff",
					"attack_buff": "Buff",
					"escape": "Utility"
				}
				var effect_label = Label.new()
				effect_label.position = Vector2(400, 70 + i * 35 + 18)
				effect_label.text = effect_map.get(item["effect"], "Item")
				effect_label.add_theme_font_size_override("font_size", 11)
				effect_label.add_theme_color_override("font_color", Color(0.55, 0.25, 0.1))
				$ItemList.add_child(effect_label)
		
		if i == selected_index:
			label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		else:
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		
		$ItemList.add_child(label)
	
	# Draw item description at bottom
	var items_to_show2 = inventory_items if current_tab == "equipment" else consumable_items
	if items_to_show2.size() > 0 and selected_index < items_to_show2.size():
		var item = Items.get_item(items_to_show2[selected_index])
		if item != null:
			var desc_label = Label.new()
			desc_label.position = Vector2(400, 310)
			desc_label.add_theme_font_size_override("font_size", 14)
			desc_label.text = item["description"]
			desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			$ItemList.add_child(desc_label)
	if current_tab == "equipment":
		draw_stats()
	
	var hint = Label.new()
	hint.position = Vector2(30, 380)
	if current_tab == "equipment":
		hint.text = "← → Switch Tab    ↑↓ Navigate    Enter: Equip    Esc: Close"
	else:
		hint.text = "← → Switch Tab    ↑↓ Navigate    Esc: Close"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	$ItemList.add_child(hint)

func _process(_delta):
	var items_to_show = inventory_items if current_tab == "equipment" else consumable_items
	
	# Switch tabs with left/right
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		current_tab = "consumables" if current_tab == "equipment" else "equipment"
		selected_index = 0
		draw_inventory()
	
	if Input.is_action_just_pressed("ui_up"):
		selected_index = max(0, selected_index - 1)
		draw_inventory()
	
	if Input.is_action_just_pressed("ui_down"):
		selected_index = min(items_to_show.size() - 1, selected_index + 1)
		draw_inventory()
	
	if Input.is_action_just_pressed("ui_accept"):
		if items_to_show.size() > 0 and selected_index < items_to_show.size():
			if current_tab == "equipment":
				GameData.equip(items_to_show[selected_index])
				GameData.save()
				draw_inventory()
			else:
				# Can't use consumables outside battle for now
				pass
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://world.tscn")
