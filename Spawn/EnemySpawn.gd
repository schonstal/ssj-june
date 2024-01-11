extends Node2D

@export var flash_time = 0.025
@export var spawn_time = 0.3

@export var enemy_scene: Resource

@onready var placeholder = $Placeholder

var flashed = false
var flash_timer:Timer
var spawn_timer:Timer

signal spawn

func _ready():
  spawn_timer = Timer.new()
  spawn_timer.one_shot = true
  spawn_timer.connect("timeout", Callable(self, "_on_Spawn_timer_timeout"))
  spawn_timer.set_name("SpawnTimer")
  add_child(spawn_timer)

  spawn_timer.start(spawn_time)

  placeholder.modulate = Color(10, 10, 10, 0.5)

func _on_Spawn_timer_timeout():
  emit_signal("spawn")
  queue_free()
