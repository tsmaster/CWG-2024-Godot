extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c:Node in get_children():
		print("considering node ", c.name)
		if c.name == "Player Car":
			gBulletMgr.addTarget(c, BulletMgr.BulletTeam.TEAM_PLAYER)
		elif c.name == "Enemy Car2D 1":
			gBulletMgr.addTarget(c, BulletMgr.BulletTeam.TEAM_ENEMY)
	gBulletMgr.PlayerDiedSignal.connect(on_player_died)
	
	gGameMgr.last_arena_result = GameMgr.ArenaResult.RESULT_UNKNOWN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isPlayerLastStanding():
		print("player wins!")
		gGameMgr.last_arena_result = GameMgr.ArenaResult.RESULT_WIN
		get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/BattleCompleteScene.tscn")
	
func on_player_died():
	print("PLAYER DIED")
	gGameMgr.last_arena_result = GameMgr.ArenaResult.RESULT_LOSS
	
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/BattleCompleteScene.tscn")


func _on_area_2d_body_entered_exit(body: Node2D) -> void:
	print ("body entered ", body)
	var car_body:PlayerCar2D = body as PlayerCar2D
	if car_body:
		print("car entered exit")
		gGameMgr.last_arena_result = GameMgr.ArenaResult.RESULT_ESCAPE
		get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/BattleCompleteScene.tscn")

func isPlayerLastStanding():
	if gBulletMgr.anyEnemies():
		return false
	return true
