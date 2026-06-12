extends Node2D

var selected_index = 0
var has_save = false

# Menu changes depending on whether a save exists
var menu_new_game = ["New Game", "Quit"]
var menu_with_save = ["Continue", "New Game", "Quit"]

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Check if a save file exists
	has_save = FileAccess.file_exists("user://savegame.json")
	
	setup_visuals()
	draw_menu()

func setup_visuals():
	# Background
	$Background.color = Color(0.04, 0.04, 0.04)
	$Background.size = Vector2(1152, 648)
	$Background.position = Vector2(0, 0)
	
	# Tagline
	$Tagline.text = '"The city never sleeps. Neither do its sins."'
	$Tagline.add_theme_font_size_override("font_size", 14)
	$Tagline.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	$Tagline.position = Vector2(300, 560)

func draw_menu():
	for child in $MenuList.get_children():
		child.queue_free()
	
	# Game title
	var title = Label.new()
	title.position = Vector2(-80, -220)
	title.text = "NOIR"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	$MenuList.add_child(title)
	
	var subtitle = Label.new()
	subtitle.position = Vector2(-40, -130)
	subtitle.text = "CHRONICLES"
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	$MenuList.add_child(subtitle)
	
	# Divider line
	var divider = Label.new()
	divider.position = Vector2(-80, -80)
	divider.text = "————————————————"
	divider.add_theme_font_size_override("font_size", 16)
	divider.add_theme_color_override("font_color", Color(0.2, 0.0, 0.0))
	$MenuList.add_child(divider)
	
	# Menu items
	var menu_items = menu_with_save if has_save else menu_new_game
	
	for i in range(menu_items.size()):
		var label = Label.new()
		label.position = Vector2(0, i * 50)
		label.add_theme_font_size_override("font_size", 20)
		
		if i == selected_index:
			label.text = "-> " + menu_items[i]
			label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		else:
			label.text = "   " + menu_items[i]
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		
		$MenuList.add_child(label)

func _process(_delta):
	var menu_items = menu_with_save if has_save else menu_new_game
	
	if Input.is_action_just_pressed("ui_up"):
		selected_index = max(0, selected_index - 1)
		draw_menu()
	
	if Input.is_action_just_pressed("ui_down"):
		selected_index = min(menu_items.size() - 1, selected_index + 1)
		draw_menu()
	
	if Input.is_action_just_pressed("ui_accept"):
		var selected = menu_items[selected_index]
		match selected:
			"Continue":
				# Load existing save and go to world
				GameData.load_game()
				get_tree().change_scene_to_file("res://world.tscn")
			"New Game":
				if has_save:
					# Ask confirmation before overwriting
					get_tree().change_scene_to_file("res://world.tscn")
				else:
					get_tree().change_scene_to_file("res://world.tscn")
			"Quit":
				get_tree().quit()
