tool
extends Node2D

export(int) var radius = 10 setget _set_radius
export(Color, RGBA) var color

func _set_radius(r):
  radius = r
  update()

func _draw():
  draw_circle(Vector2(0, 0), radius, color)
