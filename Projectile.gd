extends Area2D

export var velocity = Vector2(0, -1000)

export var damage = 1

func _ready():
  connect("body_entered", self, "_on_body_enter")

func _physics_process(delta):
  position += velocity * delta

  if position.y < -100:
    self.queue_free()

  if position.y > 1200:
    self.queue_free()

  if position.x < -100:
    self.queue_free()

  if position.x > 2020:
    self.queue_free()

func _on_body_enter(body):
  body.hurt(damage)
