extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -450.0

const COYOTE_TIME: float = 0.15
var coyote_timer: float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var gun: Sprite2D = $Gun
const BANANA_BULLET = preload("res://scenes/banana_bullet.tscn")
@onready var muzzle = $Gun/Muzzle

var ammo: int = 10

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_shoot") or Input.is_physical_key_pressed(KEY_J):
		shoot()

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
		
		if direction < 0:
			gun.scale.x = -1
			gun.position.x = -abs(gun.position.x)
		else: 
			gun.scale.x = 1
			gun.position.x = abs(gun.position.x)
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
	

func add_ammo(amount: int) -> void:
	ammo += amount

func shoot() -> void:
	if ammo <= 0:
		return
	ammo -= 1
	var bullet = BANANA_BULLET.instantiate()
	bullet.global_position = muzzle.global_position
	if sprite.flip_h:
		bullet.direction = -1
	else:
		bullet.direction = 1
	get_parent().add_child(bullet)
