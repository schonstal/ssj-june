extends Node2D

onready var collision = $Enemy/CollisionShape2D
onready var appear_sound = $AppearSound
onready var disappear_sound = $DisappearSound
onready var idle_timer = $IdleTimer
onready var fade_tween = $FadeTween
onready var fade_in_tween = $FadeInTween
onready var move_tween = $MoveTween
onready var animation = $Enemy/Sprite/AnimationPlayer
onready var enemy = $Enemy
onready var appear_sprite = $AppearSprite
onready var appear_animation = $AppearSprite/AnimationPlayer
onready var sprite = $Enemy/Sprite
onready var wait_timer

export var idle_time = 2.0
export var fade_duration = 0.3
export var health = 50
export var index = 0

export var brightness = 1.5
export var overlay_on_attack = false

var max_health = 50

signal move_completed
signal fade_out_completed
signal fade_in_completed

var upgrade_scene = preload("res://Items/Upgrade/Upgrade.tscn")
var health_scene = preload("res://Items/Health/HealthPickup.tscn")

func _ready():
  move_tween.connect("tween_completed", self, "_on_MoveTween_tween_completed")
  fade_tween.connect("tween_completed", self, "_on_FadeTween_tween_completed")
  fade_in_tween.connect("tween_completed", self, "_on_FadeInTween_tween_completed")
  idle_timer.connect("timeout", self, "_on_IdleTimer_timeout")
  animation.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
  enemy.connect("hurt", self, "_on_Enemy_hurt")
  enemy.connect("died", self, "_on_Enemy_died")

  enemy.health = health

  modulate = Color(brightness, brightness, brightness, 0)
  idle_timer.start(idle_time)

  max_health = health
  EventBus.emit_signal("boss_start", health, index)

func _on_IdleTimer_timeout():
  fade_in()

func _on_FadeInTween_tween_completed(_object, _key):
  if appear_sprite != null:
    appear_sprite.modulate = Color(1, 1, 1, 10)
    appear_animation.play("Appear")

  emit_signal("fade_in_completed")

func _on_FadeTween_tween_completed(_object, _key):
  collision.disabled = true
  emit_signal("fade_out_completed")

func _on_AnimationPlayer_animation_finished(name):
  if name == "Attack":
    animation.play("Idle")

func _on_MoveTween_tween_completed(_object, _key):
  emit_signal("move_completed")

func move_to(target, duration = 0.5):
  move_tween.stop_all()
  move_tween.interpolate_property(
      self,
      "position",
      position,
      target,
      duration,
      Tween.TRANS_QUART,
      Tween.EASE_OUT)
  move_tween.start()

func start_attack():
  if overlay_on_attack:
    appear_sprite.modulate = Color(1, 1, 1, 1)
    appear_animation.play("Appear")
  else:
    animation.play("Attack")

func fade_in():
  animation.play("Idle")
  collision.disabled = false
  appear_sound.play()
  fade_in_tween.interpolate_property(
      self,
      "modulate",
      Color(brightness, brightness, brightness, 0),
      Color(brightness, brightness, brightness, 1),
      fade_duration,
      Tween.TRANS_QUART,
      Tween.EASE_OUT)

  fade_in_tween.start()

func fade_out():
  move_tween.stop_all()
  disappear_sound.play()
  fade_tween.interpolate_property(
      self,
      "modulate",
      Color(brightness, brightness, brightness, 1),
      Color(brightness, brightness, brightness, 0),
      fade_duration,
      Tween.TRANS_QUART,
      Tween.EASE_OUT)

  fade_tween.start()

func _on_Enemy_hurt(health, _max_health):
  EventBus.emit_signal("boss_hurt", health)

func _on_Enemy_died():
  EventBus.emit_signal("chapter_complete")
  EventBus.emit_signal("boss_defeated")

  var upgrade = upgrade_scene.instance()
  upgrade.global_position = global_position
  Game.scene.items.call_deferred("add_child", upgrade)

  Engine.time_scale = 0.05
  Game.scene.shake(0.25)
  Overlay.fade(Color(1, 1, 1, 0.4), Color(1, 1, 1, 0), 0.3)

  for i in range(0, 2):
    var health = health_scene.instance()
    Game.scene.items.call_deferred("add_child", health)
    health.global_position = Vector2(1920 / 2 - 100 + 100 * i, 100)

  queue_free()
