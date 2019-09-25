extends Node2D

onready var blue_lord = $'..'

var wait_timer:Timer
var shoot_timer:Timer

export var wait_time = 0.25
export var bullet_count = 18
export var distance = 50
export var offset_increment = 0.1
export var radius = 30.0
export var bullet_speed = 100
export var center = Vector2(1920 / 2, 1080 / 2 - 200)
export var spawn_offset = Vector2(0, -82)

var offset = 0.0
var shots = 0
var max_shots = 6
var shoot_time = 0.02

export(Resource) var blue_bullet_scene = preload("res://Projectiles/BlueFireball/EnemyFireball.tscn")
export(Resource) var purple_bullet_scene = preload("res://Projectiles/PitLordFireball/PitLordFireball.tscn")
export(Resource) var red_bullet_scene = preload("res://Projectiles/BatFireball/BatFireball.tscn")
var bullet_scenes = [blue_bullet_scene, purple_bullet_scene, red_bullet_scene]

func _ready():
  wait_timer = Timer.new()
  wait_timer.set_name("WaitTimer")
  wait_timer.wait_time = wait_time
  wait_timer.one_shot = true
  wait_timer.start()
  add_child(wait_timer)

  shoot_timer = Timer.new()
  shoot_timer.set_name("ShootTimer")
  shoot_timer.wait_time = shoot_time
  shoot_timer.one_shot = true
  add_child(shoot_timer)

  wait_timer.connect("timeout", self, "_on_WaitTimer_timeout")
  shoot_timer.connect("timeout", self, "_on_ShootTimer_timeout")
  blue_lord.connect("move_completed", self, "_on_BlueLord_move_completed")

func _on_WaitTimer_timeout():
  var direction = Vector2(rand_range(-1, 1), rand_range(-1, 1))
  direction = direction.normalized()

  blue_lord.move_to(center + distance * direction, 1)

func _on_BlueLord_move_completed():
  blue_lord.start_attack()
  shots = 0
  shoot()

func _on_ShootTimer_timeout():
  shots += 1
  if shots < max_shots:
    shoot()
  else:
    offset_increment = -offset_increment
    wait_timer.start()
    EventBus.emit_signal("boss_pattern_complete")

func shoot():
  offset += offset_increment * TAU
  var speed = bullet_speed

  Util.spawn_full_circle({
      "position": global_position + spawn_offset,
      "scene": bullet_scenes[shots % 3],
      "count": bullet_count,
      "radius": radius,
      "speed": bullet_speed,
      "rotation": offset,
      "acceleration": 50 + shots * 100
    })

  shoot_timer.start()
