extends Node
class_name BulletMgr

const BULLET_PROXIMITY:float = 70
const BULLET_PROXIMITY_SQUARED:float = BULLET_PROXIMITY * BULLET_PROXIMITY

signal PlayerDiedSignal

enum BulletTeam {
	TEAM_PLAYER,
	TEAM_ENEMY
}

var BULLET_SPEED_MG: float = 1000.0
var LIFE_TIME_MG: float = 4.0

var bullet_list: Array = []
var target_list: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dead_index_pool: Array = []
	var dead_target_index_list: Array = []
	
	var time_now = gGameMgr.getTimeNow()
	
	for bullet_index:int in range(len(bullet_list)):
		var target_index = findTargetIndexThatOverlapsBulletIndex(bullet_index)
		if target_index >= 0:
			var target = target_list[target_index][0]
			var target_player_car: PlayerCar2D = target as PlayerCar2D
			if target_player_car:
				target_player_car.takeDamage()
				if target_player_car.isDead():
					PlayerDiedSignal.emit()
					shutdown()
					return
					
			var target_enemy_car: AiCar2D = target as AiCar2D
			if target_enemy_car:
				target_enemy_car.takeDamage()
				if target_enemy_car.isDead():
					dead_target_index_list.append(target_index)
								
			dead_index_pool.append(bullet_index)
			continue
		var record = bullet_list[bullet_index]
		var new_pos = record.game_object.position + record.velocity * delta
		record.game_object.position = new_pos
		if record.start_time + record.life_time < time_now:
			dead_index_pool.append(bullet_index)		
			
	dead_target_index_list.reverse()
	for idx in dead_target_index_list:
		target_list[idx][0].queue_free()
		target_list.remove_at(idx)
		print("removed target at idx ", idx)
			
	dead_index_pool.reverse()
	for idx in dead_index_pool:
		bullet_list[idx].game_object.queue_free()
		bullet_list.remove_at(idx)
		print("removed bullet at idx ", idx)
		
	if !anyEnemies():
		shutdown()

	
func findTargetIndexThatOverlapsBulletIndex(index: int) -> int:
	var bullet_record:BulletRecord = bullet_list[index]
	var bullet_pos = bullet_record.game_object.position
	
	for rec_idx in range(len(target_list)):
		var rec = target_list[rec_idx]
		var obj = rec[0]
		var team: BulletTeam = rec[1]
		if team == bullet_record.team:
			continue
		var obj_node = obj  as Node2D
		var obj_position = obj_node.position
		var vect:Vector2 = obj_position - bullet_pos
		if vect.length_squared() < BULLET_PROXIMITY_SQUARED:
			print("bullet collide")
			return rec_idx
	return -1
	
func addTarget(obj: Node2D, team: BulletTeam):
	var target_record = [obj, team]
	target_list.append(target_record)
	
func addBullet(owning_team: BulletTeam, position: Vector2, velocity: Vector2, obj: Node2D):
	var new_bullet = BulletRecord.new()
	new_bullet.game_object = obj
	new_bullet.game_object.position = position
	new_bullet.velocity = velocity.normalized() * BULLET_SPEED_MG
	new_bullet.team = owning_team
	new_bullet.start_time = gGameMgr.getTimeNow()
	new_bullet.life_time = LIFE_TIME_MG
	
	bullet_list.append(new_bullet)
	print("added bullet at index ", len(bullet_list) - 1)

func anyEnemies() -> bool:
	for r in target_list:
		var target_team:BulletTeam = r[1]
		if target_team == BulletTeam.TEAM_ENEMY:
			return true
	return false
	
func shutdown(): 
	for idx in range(len(bullet_list)):
		var b_rec:BulletRecord = bullet_list[idx]
		b_rec.game_object.queue_free()
	bullet_list = []
	target_list = []	
