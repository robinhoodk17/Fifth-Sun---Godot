extends Node3D

signal go

func emit_go():
	go.emit()

func destroy_self():
	queue_free()
