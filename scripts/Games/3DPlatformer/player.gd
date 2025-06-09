class_name Player
extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 5.0
const RESPAWN_TICK = 2

@export 
var player_id: int = 1
@export
var player_label: Label
@export
var footstep_sfx: AudioStreamPlayer 
@export
var jump_sfx: AudioStreamPlayer 

# Game Components
@onready
var animation_tree: AnimationTree = $AnimationTree
@onready
var respawn_timer: Timer = $Respawn

# Game Variables
var can_move: bool 
var checkpoint: Vector3
var rng: RandomNumberGenerator

# Movement Variables
var up_strength: float 
var down_strength: float 
var left_strength: float 
var right_strength: float 

# Respawn Tick
var respawn_tick: int = 0

func _ready() -> void:
	checkpoint = global_position
	rng = RandomNumberGenerator.new()
	respawn_timer.timeout.connect(_on_respawn_timer)

func _physics_process(delta: float) -> void:
	# Check
	if not visible:
		return
	
	if not can_move:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir = Vector2(-left_strength + right_strength, -up_strength + down_strength)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Move Player Character
	# Note: delta is not needed since it's applied internally by move_and_slide()
	move_and_slide()
	
	# Handle Animation
	handle_animation()
	
	# Handle SFX
	if (velocity.x != 0 || velocity.z != 0):
		if (not footstep_sfx.playing && is_on_floor()):
			footstep_sfx.pitch_scale = 1.0 + rng.randf_range(-0.1, 0.1)
			footstep_sfx.play()
		elif (footstep_sfx.playing && not is_on_floor()):
			footstep_sfx.stop()

func _input(event: InputEvent) -> void:
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Get Movement Actions
	if (event.is_action_pressed("player_action_10")):
		up_strength = event.get_action_strength("player_action_10")
	elif (event.is_action_released("player_action_10")):
		up_strength = 0
		
	if (event.is_action_pressed("player_action_12")):
		down_strength = event.get_action_strength("player_action_12")
	elif (event.is_action_released("player_action_12")):
		down_strength = 0
		
	if (event.is_action_pressed("player_action_9")):
		left_strength = event.get_action_strength("player_action_9")
	elif (event.is_action_released("player_action_9")):
		left_strength = 0
		
	if (event.is_action_pressed("player_action_11")):
		right_strength = event.get_action_strength("player_action_11")
	elif (event.is_action_released("player_action_11")):
		right_strength = 0
	
	# Handle jump.
	if event.is_action("player_action_8") and is_on_floor():
		# Apply Velocity
		velocity.y = JUMP_VELOCITY
		
		# Play SFX
		jump_sfx.pitch_scale = 1.0 + rng.randf_range(-0.1, 0.1)
		jump_sfx.play()

func handle_animation():
	# Handles Jumping/Falling
	if is_on_floor():
		animation_tree.set("parameters/JumpBlend/blend_amount", -1.0)
	else:
		if (velocity.y >= 1):
			animation_tree.set("parameters/JumpBlend/blend_amount", 1.0)
		elif (velocity.y >= 0):
			animation_tree.set("parameters/JumpBlend/blend_amount", velocity.y)
		else:
			animation_tree.set("parameters/JumpBlend/blend_amount", 0.0)
	
	# Handles Movement
	if (velocity.x != 0 && velocity.z != 0):
		animation_tree.set("parameters/MoveBlend/blend_amount", 1.0)
	else:
		animation_tree.set("parameters/MoveBlend/blend_amount", 0.0)

func respawn():
	# Reset Params
	visible = false
	can_move = false
	respawn_tick = 0
	velocity = Vector3.ZERO
	
	# Start Timer
	respawn_timer.start()

func _on_respawn_timer():
	# Update Tick
	respawn_tick += 1
	
	# Respawn check
	match respawn_tick:
		RESPAWN_TICK:
			# Update Params
			visible = true
			can_move = true
			global_position = checkpoint
			
			# Stop Timer
			respawn_timer.stop()
