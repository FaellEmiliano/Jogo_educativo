extends Node

const UPGRADES = {
	"premium_1": {
		"nome": "Atendimento Premium I",
		"categoria": "economia",
		"descricao": "+20% de recompensa por cliente",
		"preco": 140,
		"dinheiro_minimo": 0,
		"efeito": {"tipo": "reward_multiplier", "valor": 0.2}
	},
	"lang_if": {
		"nome": "Conceito: if()",
		"categoria": "linguagem",
		"descricao": "Libera decisões condicionais",
		"preco": 360,
		"dinheiro_minimo": 0,
		"efeito": {"tipo": "unlock_feature", "feature": "if"}
	},
	"marketing_1": {
		"nome": "Marketing I",
		"categoria": "fluxo",
		"descricao": "Clientes chegam em 4s a 6s",
		"preco": 650,
		"dinheiro_minimo": 320,
		"requer": ["lang_if"],
		"efeito": {"tipo": "spawn_delay", "min": 4.0, "max": 6.0}
	},
	"premium_2": {
		"nome": "Atendimento Premium II",
		"categoria": "economia",
		"descricao": "+25% de recompensa por cliente",
		"preco": 900,
		"dinheiro_minimo": 520,
		"requer": ["premium_1"],
		"efeito": {"tipo": "reward_multiplier", "valor": 0.25}
	},
	"lang_sensor": {
		"nome": "Conceito: sensor()",
		"categoria": "linguagem",
		"descricao": "Libera leitura de sensores do jogo",
		"preco": 1250,
		"dinheiro_minimo": 850,
		"requer": ["lang_if"],
		"efeito": {"tipo": "unlock_feature", "feature": "sensor"}
	},
	"marketing_2": {
		"nome": "Marketing II",
		"categoria": "fluxo",
		"descricao": "Clientes chegam em 2.5s a 4.5s",
		"preco": 1500,
		"dinheiro_minimo": 1150,
		"requer": ["marketing_1", "lang_sensor"],
		"efeito": {"tipo": "spawn_delay", "min": 2.5, "max": 4.5}
	},
	"gameplay_change": {
		"nome": "Desafio: Troco",
		"categoria": "gameplay",
		"descricao": "Clientes podem pagar a mais e pedir troco",
		"preco": 1850,
		"dinheiro_minimo": 1500,
		"requer": ["lang_sensor"],
		"efeito": {"tipo": "unlock_feature", "feature": "change"}
	},
	"gameplay_stock": {
		"nome": "Sistema: Estoque",
		"categoria": "gameplay",
		"descricao": "Clientes podem pedir ingredientes",
		"preco": 2300,
		"dinheiro_minimo": 1900,
		"requer": ["gameplay_change"],
		"efeito": {"tipo": "unlock_feature", "feature": "stock"}
	},
	"premium_3": {
		"nome": "Atendimento Premium III",
		"categoria": "economia",
		"descricao": "+30% de recompensa por cliente",
		"preco": 3100,
		"dinheiro_minimo": 2600,
		"requer": ["premium_2", "gameplay_stock"],
		"efeito": {"tipo": "reward_multiplier", "valor": 0.3}
	},
	"marketing_3": {
		"nome": "Marketing III",
		"categoria": "fluxo",
		"descricao": "Clientes chegam em 1s a 3s",
		"preco": 4200,
		"dinheiro_minimo": 3400,
		"requer": ["marketing_2", "gameplay_stock"],
		"efeito": {"tipo": "spawn_delay", "min": 1.0, "max": 3.0}
	}
}
