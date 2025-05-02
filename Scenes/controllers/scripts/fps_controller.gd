extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCELERATION = 10.0
const DECELERATION = 8.0
const JUMP_VELOCITY = 4.5

@onready var head: Node3D = $CameraController
var mouse_sens = 0.1
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# For smooth camera
var mouse_delta := Vector2.ZERO
var smoothed_mouse := Vector2.ZERO
var smoothing_factor := 0.15  # Lower = smoother, Higher = more responsive

# ==========================================================
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ==========================================================
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calculate desired horizontal velocity
	var desired_velocity = move_dir * MAX_SPEED

	# Smooth acceleration and deceleration
	var accel: float
	if move_dir.length() > 0.1:
		accel = ACCELERATION
	else:
		accel = DECELERATION

	velocity.x = move_toward(velocity.x, desired_velocity.x, accel * delta)
	velocity.z = move_toward(velocity.z, desired_velocity.z, accel * delta)

	move_and_slide()

# ==========================================================
func _process(delta):
	# Smooth the mouse movement
	smoothed_mouse = lerp(smoothed_mouse, mouse_delta, smoothing_factor)

	# Rotate body (left-right)
	rotate_y(deg_to_rad(-smoothed_mouse.x * mouse_sens))

	# Rotate head (up-down)
	head.rotate_x(deg_to_rad(-smoothed_mouse.y * mouse_sens))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	# Reset mouse delta after applying
	mouse_delta = Vector2.ZERO

# ==========================================================
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

	if event.is_action_pressed("exit"):
		get_tree().quit()
