extends Node
class_name EnemyState

# Ссылка на Slime и его StateMachine
var slime: Slime
var state_machine: Node

# Методы, которые будут вызываться StateMachine
func enter(): pass
func exit(): pass
func physics_update(delta): pass
func update(delta): pass
