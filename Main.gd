extends Node2D
signal restart
var save_file_path = "user://save.json"
var save_data = { 
  "high_score": 0
}
var is_loading = false
var high_score = 0
var score = 0


var rng = RandomNumberGenerator.new()
var on_surfaces = 0
var wind = Vector2(0, 25)
var planks = []
var is_dieing = false

export (PackedScene) var plank_scene

onready var air = $CanvasLayer/Air
onready var player = $Player


# Called when the node enters the scene tree for the first time.
func _ready():
  load_save_data()
  rng.randomize()
  for i in range(0, 50):
    create_plank()

func create_plank():
  var plank = plank_scene.instance()
  if planks.size() <= 0:
    plank.position = Vector2(160, 360)
  else:
    var last_plank = planks[planks.size() - 1]
    plank.position = last_plank.get_node("Top").global_position
    if last_plank.rotation_degrees < 0:
      plank.rotation_degrees = rng.randi_range(0, 60)
    elif last_plank.rotation_degrees > 0:
      plank.rotation_degrees = rng.randi_range(-60, 0)
    else:
      plank.rotation_degrees = rng.randi_range(-60, 60)
  $Planks.add_child(plank)
  planks.push_back(plank)
  connect_plank(plank.get_node("Area2D"))
    
func connect_plank(plank):
  plank.connect("body_entered", self, "_on_body_entered")
  plank.connect("body_exited", self, "_on_body_exited")
  
func _physics_process(delta):
  $Player.force = Vector2(wind.x, wind.y)
  air.texture_offset.x -= wind.x * delta * 2
  air.texture_offset.y -= wind.y * delta * 2
  
  var current_score = max(0, floor(($Player.position.y - 400)/10 * -1))
  
  if current_score > high_score:
    high_score = current_score
    update_high_score_label()
  score = current_score
  $CanvasLayer2/MarginContainer/Score.text = "SCORE:" + str(score)

func check_death():
  if on_surfaces <= 0 && !is_dieing:
    is_dieing = true
    player.die()
    $AudioStreamPlayer.play()
    save_game()
    yield(get_tree().create_timer(2), "timeout")
    emit_signal("restart")
#    get_tree().reload_current_scene()

func _on_body_entered(body):
  if body == player:
    on_surfaces += 1
    check_death()

func _on_body_exited(body):
  if body == player:
    on_surfaces -= 1
    check_death()

func _on_Timer_timeout():
  wind = Vector2(rng.randi_range(-45, 45), rng.randi_range(-45, 45))
  pass # Replace with function body.
  
func load_save_data():
  if !OS.is_userfs_persistent():
    return
  is_loading = true
  var save_file = File.new()
  if not save_file.file_exists(save_file_path):
    return
    
  save_file.open(save_file_path, File.READ)
  var json_string = parse_json(save_file.get_as_text())
  save_file.close()
  print(json_string)
  save_data["high_score"] = json_string["high_score"]
  high_score = save_data["high_score"]
  print(high_score)
  update_high_score_label()
  is_loading = false
  pass
  
func save_game():
  if !OS.is_userfs_persistent() || is_loading:
    return
  var save_file = File.new()
  save_file.open(save_file_path, File.WRITE)
  save_file.store_string(to_json({ "high_score": high_score }))
  save_file.close()
  
func update_high_score_label():
  $CanvasLayer2/MarginContainer/HighScore.text = "BEST:" + str(high_score)


func _on_Timer2_timeout():
  create_plank()
  pass # Replace with function body.
