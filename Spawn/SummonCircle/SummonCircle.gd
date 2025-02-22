extends Node2D

onready var summon_circle_small = $SummonCircleSmall
onready var summon_circle_big = $SummonCircleBig
onready var fade_tween = $FadeTween

var theta = 0

export var angular_velocity = 1.5
export var fade_duration = 0.5

signal fade_finished

var target_color = Color(1, 1, 1, 1)

func _ready():
  fade_tween.connect("tween_completed", self, "_on_FadeTween_tween_completed")
  modulate = Color(target_color.r, target_color.g, target_color.b, 0)

func _process(delta):
  theta += delta * angular_velocity * TAU

  summon_circle_small.rotation = theta
  summon_circle_big.rotation = -theta

func fade_in():
  fade_tween.interpolate_property(
      self,
      "modulate",
      Color(target_color.r, target_color.g, target_color.b, 0),
      target_color,
      fade_duration,
      Tween.TRANS_QUART,
      Tween.EASE_OUT)

  fade_tween.start()

func fade_out():
  fade_tween.interpolate_property(
      self,
      "modulate",
      target_color,
      Color(target_color.r, target_color.g, target_color.b, 0),
      fade_duration,
      Tween.TRANS_QUART,
      Tween.EASE_OUT)

  fade_tween.start()

func _on_FadeTween_tween_completed(_object, _key):
  emit_signal("fade_finished")
