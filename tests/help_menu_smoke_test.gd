extends Node

const HelpMenuScene = preload("res://scenes/help/help_menu.tscn")
const HelpTopicsData = preload("res://data/HelpTopics.gd")
const HelpProgressData = preload("res://systems/HelpProgress.gd")
const UpgradeData = preload("res://data/UpgradeData.gd")

func _ready() -> void:
	FeatureManager.reset_progression()

	var initial_topics := HelpProgressData.get_visible_topics(HelpTopicsData.TOPICS)
	var initial_ids := _topic_ids(initial_topics)
	for required_id in ["terminal", "input", "send", "print", "simple_client"]:
		assert(initial_ids.has(required_id), "Tópico básico ausente: %s" % required_id)
	assert(not initial_ids.has("sentinel_client"), "Sentinela apareceu antes do desbloqueio")
	assert(not initial_ids.has("stock"), "Estoque apareceu antes do desbloqueio")
	assert(not initial_ids.has("await"), "await() apareceu antes do desbloqueio")
	assert(not initial_ids.has("delivery_overview"), "Delivery apareceu antes do desbloqueio")

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
	assert(str(UpgradeData.UPGRADES["lang_if"]["descricao"]).contains("10%"), "Upgrade de if não informou o percentual do desconto")
	var discount_body := help_menu.get_node("%BodyLabel") as RichTextLabel
	assert(discount_body.text.contains("10%"), "Ajuda de desconto não informou o percentual")

	FeatureManager.unlock_feature(FeatureManager.FEATURE_SENSOR)
	FeatureManager.unlock_feature(FeatureManager.FEATURE_CHANGE)
	FeatureManager.unlock_feature(FeatureManager.FEATURE_STOCK)
	UpgradeManager.upgrade_comprado.emit("gameplay_stock")
	assert(help_menu.get("_selected_topic_id") == "stock", "Upgrade de estoque não abriu o tópico principal de estoque")
	var all_ids := _topic_ids(help_menu.get("_visible_topics"))
	assert(all_ids.has("stock"), "Tópico de estoque não foi desbloqueado")
	assert(all_ids.has("await"), "Tópico de await() não foi desbloqueado")
	var stock_body := help_menu.get_node("%BodyLabel") as RichTextLabel
	assert(stock_body.text.contains("recompensa de cada atendimento vale 1,5x"), "Ajuda de estoque não explicou o bônus sem alterar o total")
	assert(not all_ids.has("delivery_overview"), "Delivery apareceu antes do upgrade")

	DeliverySystem.unlock(false)
	var delivery_ids := _topic_ids(help_menu.get("_visible_topics"))
	for delivery_topic in ["delivery_overview", "delivery_commands", "recursion_delivery"]:
		assert(delivery_ids.has(delivery_topic), "Tópico de Delivery não foi desbloqueado: %s" % delivery_topic)
	assert(delivery_ids.size() == HelpTopicsData.TOPICS.size(), "Nem todos os tópicos foram liberados")
	help_menu.call("_show_topic", "delivery_commands")
	var delivery_body := help_menu.get_node("%BodyLabel") as RichTextLabel
	assert(delivery_body.text.contains("L(n) = 2 * L(n - 1) + b"), "Ajuda do Delivery não exibiu a fórmula recorrente do lucro")
	assert(delivery_body.text.contains("L(n) = b * (2^n - 1)"), "Ajuda do Delivery não exibiu a fórmula direta do lucro")
	assert(delivery_body.text.contains("serve apenas para conferir"), "Ajuda do Delivery não diferenciou a fórmula direta da solução exigida")
	help_menu.call("_show_topic", "delivery_overview")
	assert(delivery_body.text.contains("for") and delivery_body.text.contains("while"), "Ajuda do Delivery não informou o requisito de loop")

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
	await get_tree().process_frame
	get_tree().quit()

func _topic_ids(topics: Array) -> Array:
	var ids: Array = []
	for topic in topics:
		ids.append(str(topic.get("id", "")))
	return ids
