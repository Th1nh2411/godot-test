extends Node
class_name CombatComponent

## Owns HP and damage logic. Minimal placeholder; extend for Hit later.

signal died
signal hp_changed(current: int, maximum: int)

@export var max_hp: int = 100

@onready var player: Player = owner

var hp: int = max_hp


func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return
	hp = mini(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)


func is_alive() -> bool:
	return hp > 0
