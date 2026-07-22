extends Node
class_name CombatComponent

## Owns HP and damage logic. Minimal placeholder; extend for Hit later.

signal died
signal hp_changed(current: int, maximum: int)
signal knockback_received(force: Vector2)

@export var max_hp: int = 100



var hp: int = max_hp
var is_invincible: bool = false

func take_damage(amount: int, knockback_force: Vector2 = Vector2.ZERO) -> void:
	if amount <= 0 or is_invincible or not is_alive():
		return
		
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	
	if knockback_force != Vector2.ZERO:
		knockback_received.emit(knockback_force)
	
	if hp == 0:
		died.emit()
	else:
		# Bật trạng thái bất tử
		is_invincible = true
		# Chờ 0.5 giây
		await get_tree().create_timer(0.5).timeout
		# Tắt trạng thái bất tử
		is_invincible = false


func heal(amount: int) -> void:
	if amount <= 0:
		return
	hp = mini(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)


func is_alive() -> bool:
	return hp > 0
