extends Node

const HelpMenuScene = preload("res://scenes/help/help_menu.tscn")
const HelpTopicsData = preload("res://data/HelpTopics.gd")
const HelpProgressData = preload("res://systems/HelpProgress.gd")

func _ready() -> void:
	FeatureManager.reset_progression()

	var initial_topics := HelpProgressData.get_visible_topics(HelpTopicsData.TOPICS)
	var initial_ids := _topic_ids(initial_topics)
	for required_id in ["terminal", "input", "send", "print", "simple_client"]:
		assert(initial_ids.has(required_id), "Tópico básico ausente: %s" % required_id)
	assert(not initial_ids.has("sentinel_client"), "Sentinela apareceu antes do desbloqueio")
	assert(not initial_ids.has("stock"), "Estoque apareceu antes do desbloqueio")

	var help_menu := HelpMenuScene.instantiate()
	add_child(help_menu)
	help_menu.open_menu()
	assert(help_menu.visible, "Menu não abriu")
	assert(not get_tree().paused, "Menu de ajuda pausou a execução do jogo")

	FeatureManager.unlock_feature(FeatureManager.FEATURE_CART)
	var cart_ids := _topic_ids(help_menu.get("_visible_topics"))
	for unlocked_id in ["sentinel_client", "while", "for"]:
		assert(cart_ids.has(unlocked_id), "Tópico não desbloqueado: %s" % unlocked_id)

	help_menu.close_menu()
	FeatureManager.unlock_feature(FeatureManager.FEATURE_IF)
	UpgradeManager.upgrade_comprado.emit("lang_if")
	assert(help_menu.visible, "Compra de upgrade com tópico não abriu a ajuda")
	assert(help_menu.get("_selected_topic_id") == "discount", "Upgrade de if não abriu o tópico de desconto")

	FeatureManager.unlock_feature(FeatureManager.FEATURE_SENSOR)
	FeatureManager.unlock_feature(FeatureManager.FEATURE_CHANGE)
	FeatureManager.unlock_feature(FeatureManager.FEATURE_STOCK)
	var all_ids := _topic_ids(help_menu.get("_visible_topics"))
	assert(all_ids.has("stock"), "Tópico de estoque não foi desbloqueado")
	assert(all_ids.size() == HelpTopicsData.TOPICS.size(), "Nem todos os tópicos foram liberados")

	help_menu.call("_show_topic", "sentinel_client")
	var hint_panel := help_menu.get_node("%HintPanel") as PanelContainer
	var hint_label := help_menu.get_node("%HintLabel") as RichTextLabel
	assert(not hint_panel.visible, "A dica apareceu sem o jogador pedir")
	help_menu.call("_toggle_hint")
	assert(hint_panel.visible, "O botão não revelou a dica")
	assert(hint_label.text.contains("while"), "A dica esperada não foi exibida")
	assert(not hint_label.text.contains("int main"), "A dica entregou um código completo")

	help_menu.close_menu()
	assert(not help_menu.visible, "Menu não fechou")

	print("HELP_MENU_SMOKE_TEST_OK")

func _topic_ids(topics: Array) -> Array:
	var ids: Array = []
	for topic in topics:
		ids.append(str(topic.get("id", "")))
	return ids
