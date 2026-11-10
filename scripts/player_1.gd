extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -450.0

const COYOTE_TIME: float = 0.15
var coyote_timer: float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else: 
		coyote_timer -= delta
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept", true) and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	else:
		if direction != 0:
			sprite.play("run")
		else:
			sprite.play("idle")	
	
