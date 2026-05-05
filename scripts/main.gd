extends Node2D

@onready var score_label: Label = $HUD/Panel/ScoreLabel
@onready var fade: ColorRect = $HUD/Fade

var level: int = 1
var score: int = 0
var current_level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(level, true, false)

func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:
	if not first_load:
		await _fade(1.0)
	
	if reset_score:
		score = score - 1
	
	if current_level_root:
		current_level_root.queue_free()
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	await _fade(0.0)

func _setup_level(level_root: Node) -> void:
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	var apples = level_root.get_node_or_null("Apples")
	if apples:
		for apple in apples.get_children():
			apple.collected.connect(increase_score)
	
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)


func _on_player_died(body):
	body.die()
	print("Debug info death")
	print("Player was attacked by Snail")
	print(body)
	await _load_level(level, false, true)

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Debug info level")
		print(body)
		level += 1
		print(level)
		body.can_move = false
		await _load_level(level, false, false)

func increase_score() -> void:
	score += 1
	print(score)
	score_label.text = "SCORE: %s" % score

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished
