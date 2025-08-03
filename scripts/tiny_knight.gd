extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var normalknightcollision: CollisionShape2D = $normalknightcollision
@onready var tinyknightcollision: CollisionShape2D = $tinyknightcollision
var knightstate = 0 # turn this into an enum to keep track of states
# for better readability + more states. Look into state machine.


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations in normal state (0)
	if is_on_floor() and knightstate == 0 and animated_sprite.animation != "shrink":
		if direction == 0 and animated_sprite.animation != "shrink":
			animated_sprite.play("idle")
		elif animated_sprite.animation != "shrink":
			animated_sprite.play("run")
	elif !is_on_floor() and knightstate == 0 and animated_sprite.animation != "shrink":
		animated_sprite.play("jump")
	
	# Play animations in shrink state (1)
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Shrink action
	if Input.is_action_just_pressed("shrink"):
		if knightstate == 0:
			get_node("normalknightcollision").disabled = true
			get_node("tinyknightcollision").disabled = false
			animated_sprite.play("shrink")
			knightstate = 1
		elif knightstate == 1:
			get_node("tinyknightcollision").disabled = true
			get_node("normalknightcollision").disabled = false
			if animated_sprite.is_playing():
				return
			animated_sprite.play_backwards("shrink")
			knightstate = 0
			
	
	if knightstate == 0:
		if is_on_floor() and !animated_sprite.is_playing():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
	

	move_and_slide()
	
