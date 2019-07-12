tool
extends Area2D

export var length = 500.0
export var shoot_duration = 0.5

var distance = 0.0

onready var chain_links = $ChainLinks
onready var chain_blade = $ChainBlade
onready var link_animation = $ChainLinks/AnimationPlayer
onready var blade_animation = $ChainBlade/AnimationPlayer

onready var collision = $CollisionShape2D
onready var shoot_tween = $ShootTween
onready var daddy = $'..'

export(Resource) var explosion_scene = preload("res://Projectiles/Chain/ChainExplosion.tscn")

func _ready():
  if !Engine.editor_hint:
    $'..'.remove_child(self)
    Game.scene.lasers.add_child(self)

    link_animation.play("Idle")
    blade_animation.play("Idle")

    distance = 0
    shoot_tween.interpolate_property(
        self,
        "distance",
        0,
        length,
        shoot_duration,
        Tween.TRANS_QUAD,
        Tween.EASE_IN)

    shoot_tween.start()

    shoot_tween.connect("tween_completed", self, "_on_ShootTween_tween_completed")
    daddy.connect("died", self, "_on_parent_died")

    connect("body_entered", self, "_on_body_enter")

func _process(delta):
  if Engine.editor_hint:
    distance = length
  else:
    if Game.scene != null && Game.scene.player != null:
      if overlaps_body(Game.scene.player):
        Game.scene.player.hurt(1)

  chain_links.region_rect = Rect2(0, 0, 104, distance)
  chain_links.offset.y = -distance / 2
  chain_blade.position.y = chain_links.position.y - distance
  chain_blade.position.x = chain_links.position.x

  collision.shape.extents.y = distance / 2 + 25
  collision.position.y = -distance / 2 - 25

func _on_ShootTween_tween_completed(object, key):
  pass

func _on_body_enter(body):
  if body.has_method("hurt"):
    body.hurt(1)

func _on_parent_died():
  var explosion = explosion_scene.instance()
  explosion.global_position = global_position
  explosion.rotation = rotation
  explosion.region_rect = Rect2(0, 0, 198, distance)
  explosion.offset = chain_links.offset
  Game.scene.explosions.add_child(explosion)
