extends Node2D

var is_restarting = false
export (PackedScene) var game_scene
var game = null

func _ready():
  start_game()

func start_game():
  is_restarting = false
  game = game_scene.instance()
  game.connect("restart", self, "restart_game")
  add_child(game)

func restart_game():
  if !is_restarting:
    is_restarting = true
    remove_child(game)
    game.queue_free()
    game = null
    call_deferred("start_game")