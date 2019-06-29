extends Node2D

export var summon_time = 2.0
export var delay = 0.0

export(Resource) var spawn_scene
export(Resource) var enemy_scene

onready var summon_timer = $SummonTimer
onready var delay_timer = $DelayTimer
onready var summon_circle = $SummonCircle
onready var black_hole = $BlackHole
onready var black_hole_animation = $BlackHole/AnimationPlayer
onready var placeholder = $Placeholder
onready var enemy = $Enemy

var finished = false

func _ready():
  # Editor only
  if placeholder != null:
    placeholder.queue_free()

  if enemy != null:
    remove_child(enemy)

  summon_timer.connect("timeout", self, "_on_SummonTimer_timeout")
  black_hole_animation.connect("animation_finished", self, "_on_BlackHole_animation_finished")

  if delay == 0:
    begin()
  else:
    delay_timer.connect("timeout", self, "_on_DelayTimer_timeout")
    delay_timer.start(delay)

  summon_circle.connect("fade_finished", self, "_on_SummonCircle_fade_finished")

func _on_DelayTimer_timeout():
  begin()

func begin():
  summon_circle.fade_in()
  summon_timer.start(summon_time)

func _on_SummonTimer_timeout():
  black_hole.visible = true
  black_hole_animation.play("Spawn")

func _on_SummonCircle_fade_finished():
  if finished:
    queue_free()

func _on_BlackHole_animation_finished(name):
  if name == "Spawn":
    black_hole_animation.play("Fade")

    if spawn_scene != null:
      var scene = spawn_scene.instance()
      scene.connect("spawn", self, "_on_spawn")

      scene.global_position = global_position
      Game.scene.current_wave.call_deferred('add_child', scene)

  if name == "Fade":
    summon_circle.fade_out()
    finished = true
    black_hole.queue_free()

func _on_spawn():
  if enemy != null:
    Game.scene.current_wave.add_child(enemy)
    enemy.global_position = global_position
  elif enemy_scene != null:
    var enemy = enemy_scene.instance()
    enemy.global_position = global_position
    Game.scene.current_wave.call_deferred('add_child', enemy)
  else:
    print("Enemy not configured!")
