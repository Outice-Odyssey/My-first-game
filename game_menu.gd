extends Node2D

var selected_index = 0
var confirming_delete = false
var confirm_index = 0

const MENU_ITEMS = [
	"Resume",
	"Delete Save",
	"Quit Game"
]

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	draw_menu()

func draw_menu():
	for child in $MenuList.get_children():
		child.queue_free()
	
	# Title
	var title = Label.new()
	title.position = Vector2(0, -100)
	title.text = "— MENU —"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	$MenuList.add_child(title)
	
	if confirming_delete:
		draw_confirm_screen()
		return
	
	# Menu options
	for i in range(MENU_ITEMS.size()):
		var label = Label.new()
		label.position = Vector2(0, i * 50)
		label.add_theme_font_size_override("font_size", 20)
		
		if i == selected_index:
			label.text = "-> " + MENU_ITEMS[i]
			label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		else:
			label.text = "   " + MENU_ITEMS[i]
			label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		
		$MenuList.add_child(label)
	
	# Hint
	var hint = Label.new()
	hint.position = Vector2(0, 250)
	hint.text = "↑↓ Navigate   Enter: Select   Esc: Close"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	$MenuList.add_child(hint)

func draw_confirm_screen():
	var msg = Label.new()
	msg.position = Vector2(-50, 0)
	msg.text = "Delete save file?\nThis cannot be undone."
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	$MenuList.add_child(msg)
	
	var yes = Label.new()
	yes.position = Vector2(0, 120)
	yes.add_theme_font_size_override("font_size", 16)
	if confirm_index == 0:
		yes.text = "-> YES — Delete everything"
		yes.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		yes.text = "   YES — Delete everything"
		yes.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	$MenuList.add_child(yes)
	
	var no = Label.new()
	no.position = Vector2(0, 160)
	no.add_theme_font_size_override("font_size", 16)
	if confirm_index == 1:
		no.text = "-> NO — Go back"
		no.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		no.text = "   NO — Go back"
		no.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	$MenuList.add_child(no)
	
	var hint = Label.new()
	hint.position = Vector2(0, 250)
	hint.text = "↑↓ Navigate   Enter: Confirm   Esc: Cancel"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	$MenuList.add_child(hint)
	
	var hint2 = Label.new()
	hint2.position = Vector2(0, 250)
	hint2.text = "Enter: Confirm   Esc: Cancel"
	hint2.add_theme_font_size_override("font_size", 13)
	hint2.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	$MenuList.add_child(hint2)

func _process(_delta):
	if confirming_delete:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			confirm_index = 1 - confirm_index
			draw_menu()
		elif Input.is_action_just_pressed("ui_accept"):
			if confirm_index == 0:
				delete_save()
			else:
				confirming_delete = false
				confirm_index = 0
				draw_menu()
		elif Input.is_action_just_pressed("ui_cancel"):
			confirming_delete = false
			confirm_index = 0
			draw_menu()
		return

	if Input.is_action_just_pressed("ui_up"):
		selected_index = max(0, selected_index - 1)
		draw_menu()
	
	if Input.is_action_just_pressed("ui_down"):
		selected_index = min(MENU_ITEMS.size() - 1, selected_index + 1)
		draw_menu()
	
	if Input.is_action_just_pressed("ui_accept"):
		match selected_index:
			0:
				get_tree().change_scene_to_file("res://world.tscn")
			1:
				confirming_delete = true
				draw_menu()
			2:
				get_tree().quit()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://world.tscn")

func delete_save():
	# Delete the save file
	var save_path = "user://savegame.json"
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(
			OS.get_user_data_dir() + "/savegame.json"
		)
	
	# Reset all GameData to defaults
	GameData.level = 1
	GameData.xp = 0
	GameData.xp_to_next = 10
	GameData.current_hp = 30
	GameData.max_hp = 30
	GameData.attack = 8
	GameData.defense = 2
	GameData.gold = 0
	GameData.weapon_slot = "rusty_revolver"
	GameData.armor_slot = "trench_coat"
	GameData.accessory_slot = "lucky_coin"
	GameData.inventory = ["rusty_revolver", "trench_coat", "lucky_coin"]
	GameData.consumables = {"bandage": 3, "health_potion": 1}
	
	print("Save deleted! Starting fresh.")
	get_tree().change_scene_to_file("res://world.tscn")
