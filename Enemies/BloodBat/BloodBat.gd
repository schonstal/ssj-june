extends Node2D

onready var enemy = $Enemy
onready var animation = $Enemy/Sprite/AnimationPlayer

var shoot_timer:Timer

var started = false
var theta =  PI + PI / 2
var original_position:Vector2
var shooting = false
var flying = true
var pattern = null
var full_period = false

export var period = 2.0
export var movement = Vector2(100, 100)
export var velocity = Vector2(0, 0)
export var shoot_time = 0.5
export var shoot_immediately = false

export(Resource) var bullet_pattern = preload("res://Enemies/BloodBat/Lines.tscn")
export(Resource) var movement_pattern = preload("res://Enemies/Movement/Movement.tscn")
export(Resource) var attack_sound_scene = preload("res://Enemies/BloodBat/AttackSound.tscn")

signal died

func _ready():
  shoot_timer = Timer.new()
  shoot_timer.set_name("ShootTimer")
  if shoot_immediately:
    shoot_timer.wait_time = 0.01
  else:
    shoot_timer.wait_time = period / 2
  shoot_timer.one_shot = true
  shoot_timer.start()
  add_child(shoot_timer)

  shoot_timer.connect("timeout", self, "_on_ShootTimer_timeout")
  animation.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

  enemy.connect("died", self, "_on_Enemy_died")
  original_position = global_position

func _physics_process(delta):
  if flying:
    theta += (delta * TAU) / period
    original_position += velocity * delta

  global_position.x = original_position.x + ((sin(theta) + 1) * movement.x)
  global_position.y = original_position.y + (abs(cos(theta)) * movement.y)

  if global_position.y > 1120:
    die()

func die():
  emit_signal("died")
  queue_free()

func _on_Enemy_died():
  EventBus.emit_signal("enemy_died", enemy.wave_name, name)
  die()

func _on_ShootTimer_timeout():
  shooting = !shooting

  if shooting:
    flying = false
    animation.play("AttackStart")

    if full_period:
      theta = PI + PI / 2
    else:
      theta = PI / 2

    full_period = !full_period
  else:
    animation.play("AttackEnd")
    if pattern != null:
      pattern.queue_free()


func _on_AnimationPlayer_animation_finished(name):
  if name == "AttackStart":
    Game.scene.sound.play_scene(attack_sound_scene, "bat_attack")
    animation.play("Attack")
    if position.y > 0:
      pattern = bullet_pattern.instance()
      call_deferred("add_child", pattern)

    shoot_timer.start(shoot_time)

  if name == "AttackEnd":
    flying = true
    animation.play("Fly")
    shoot_timer.start(period / 2)
