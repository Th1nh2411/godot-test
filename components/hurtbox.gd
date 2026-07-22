extends Area2D
class_name HurtboxComponent

# Lát nữa ta sẽ kéo thả file Combat của Player/Enemy vào biến này trên Inspector
@export var combat: CombatComponent 

func take_damage(amount: int, knockback_force: Vector2 = Vector2.ZERO) -> void:
	if combat:
		combat.take_damage(amount, knockback_force)
