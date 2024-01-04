extends Node2D

const p = preload("res://Assets/Enemy/PoisionParticles/PoisionParticle.tscn")
var on = false

func _on_Timer_timeout():
	if on:
		add_child(p.instance())
