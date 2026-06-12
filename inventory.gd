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

func draw_inventory():
	for child in $ItemList.get_children():
		child.queue_free()
	
	# Draw tab headers
	var tab_label = Label.new()
	tab_label.position = Vector2(0, -60)
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
		label.position = Vector2(0, i * 35)
		label.add_theme_font_size_override("font_size", 16)
		
		if current_tab == "equipment":
			var equipped = ""
			if GameData.weapon_slot == item_id:
				equipped = " [W]"
			elif GameData.armor_slot == item_id:
				equipped = " [A]"
			elif GameData.accessory_slot == item_id:
				equipped = " [X]"
			label.text = item["name"] + equipped
		else:
			var count = GameData.get_consumable_count(item_id)
			label.text = item["name"] + " x" + str(count)
		
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
			desc_label.position = Vector2(0, 400)
			desc_label.add_theme_font_size_override("font_size", 14)
			desc_label.text = item["description"]
			desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			$ItemList.add_child(desc_label)

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
