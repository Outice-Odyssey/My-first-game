extends CharacterBody2D

@onready var footstep_player = $FootstepPlayer
var sound_footstep = preload("res://assets/audio/sfx/footstep.wav")
const TILE_SIZE = 16
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 17.0
var steps_on_grass = 0
const STEPS_BEFORE_CHECK = 3
const ENCOUNTER_CHANCE = 20

# Reference to the AnimatedSprite2D
@onready var anim = $AnimatedSprite2D

func _ready():
	target_position = global_position
	anim.play("walk_down")

func _physics_process(delta):
	global_position = global_position.lerp(target_position, delta * move_speed)

	if not is_moving:
		var direction = Vector2.ZERO

		if Input.is_action_pressed("ui_right"):
			direction = Vector2(1, 0)
			anim.play("walk_right")
		elif Input.is_action_pressed("ui_left"):
			direction = Vector2(-1, 0)
			anim.play("walk_left")
		elif Input.is_action_pressed("ui_down"):
			direction = Vector2(0, 1)
			anim.play("walk_down")
		elif Input.is_action_pressed("ui_up"):
			direction = Vector2(0, -1)
			anim.play("walk_up")
		else:
			# Standing still — show first frame of current animation
			anim.stop()
			anim.frame = 0
		if Input.is_action_just_pressed("open_inventory"):
			get_tree().change_scene_to_file("res://inventory.tscn")
		if Input.is_action_just_pressed("open_menu"):
			get_tree().change_scene_to_file("res://game_menu.tscn")


		if direction != Vector2.ZERO:
			target_position = global_position + direction * TILE_SIZE
			is_moving = true
		 # Press S to save manually
	if Input.is_action_just_pressed("ui_select"):
		GameData.save()
		print("Game saved!")
	

	if global_position.distance_to(target_position) < 1.0:
		global_position = target_position
		if is_moving:
			is_moving = false
			footstep_player.stream = sound_footstep
			footstep_player.play()
			check_for_encounter()

func check_for_encounter():
	steps_on_grass += 1
	if steps_on_grass % STEPS_BEFORE_CHECK != 0:
		return
	var roll = randi_range(1, 100)
	print("Encounter roll: ", roll)
	if roll <= ENCOUNTER_CHANCE:
		print("Battle triggered!")
		start_battle()

func start_battle():
	get_tree().change_scene_to_file("res://battle.tscn")
