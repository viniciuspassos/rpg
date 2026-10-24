extends Node

var state: RunState = RunState.new()
var language: String = "en"

func begin_fresh_run(protagonist: String, origin: String, motivation: String) -> void:
	state = RunState.new()
	state.protagonist = protagonist
	state.origin = origin
	state.motivation = motivation
	state.beat = RunState.Beat.PERSONAL_TASK

func set_language(locale: String) -> void:
	language = locale
	TranslationServer.set_locale(locale)
