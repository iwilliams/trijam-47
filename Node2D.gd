extends KinematicBody2D

export var base_speed = 50
var velocity = Vector2(0, 0)
var force = Vector2(0, 0)
var is_dieing = false

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func _physics_process(delta):
  velocity = Vector2(0, 0)
  if Input.is_action_pressed("move_n"):
    velocity.y -= base_speed
  if Input.is_action_pressed("move_s"):
    velocity.y += base_speed
  if Input.is_action_pressed("move_e"):
    velocity.x += base_speed
  if Input.is_action_pressed("move_w"):
    velocity.x -= base_speed
    
  velocity += force
  if !is_dieing:
    move_and_slide(velocity)
    
func die():
  is_dieing = true
  $AnimationPlayer.play("Die")

