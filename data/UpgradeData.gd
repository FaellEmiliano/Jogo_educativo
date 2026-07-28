extends Node

const UPGRADES = {
	"premium_1": {
		"nome": "Caixa mais esperto I",
		"categoria": "economia",
		"descricao": "+20% no dinheiro que cada cliente deixa",
		"preco": 80,
		"dinheiro_minimo": 0,
		"efeito": {"tipo": "reward_multiplier", "valor": 0.2}
	},
	"lang_if": {
		"nome": "Aprender if()",
		"categoria": "linguagem",
		"descricao": "Libera decisões no código e a regra de desconto acima de R$50",
		"preco": 260,
		"dinheiro_minimo": 120,
		"help_topic": "discount",
		"efeito": {"tipo": "unlock_feature", "feature": "if"}
	},
	"lang_while": {
		"nome": "Aprender while()",
		"categoria": "linguagem",
		"descricao": "Clientes podem mandar vários preços; -1 avisa que a lista acabou",
		"preco": 340,
		"dinheiro_minimo": 220,
		"requer": ["lang_if"],
		"help_topic": "sentinel_client",
		"efeito": {"tipo": "unlock_feature", "feature": "cart"}
	},
	"marketing_1": {
		"nome": "Boca a boca I",
		"categoria": "fluxo",
		"descricao": "Clientes aparecem a cada 4s a 6s",
		"preco": 160,
		"dinheiro_minimo": 0,
		"efeito": {"tipo": "spawn_delay", "min": 4.0, "max": 6.0}
	},
	"premium_2": {
		"nome": "Caixa mais esperto II",
		"categoria": "economia",
		"descricao": "+25% no dinheiro que cada cliente deixa",
		"preco": 420,
		"dinheiro_minimo": 240,
		"requer": ["premium_1"],
		"efeito": {"tipo": "reward_multiplier", "valor": 0.25}
	},
	"lang_sensor": {
		"nome": "Aprender sensor()",
		"categoria": "linguagem",
		"descricao": "Permite o código olhar se tem cliente esperando",
		"preco": 580,
		"dinheiro_minimo": 360,
		"requer": ["lang_while"],
		"help_topic": "sensor",
		"efeito": {"tipo": "unlock_feature", "feature": "sensor"}
	},
	"marketing_2": {
		"nome": "Boca a boca II",
		"categoria": "fluxo",
		"descricao": "Clientes aparecem a cada 2.5s a 4.5s",
		"preco": 720,
		"dinheiro_minimo": 520,
		"requer": ["marketing_1", "lang_sensor"],
		"efeito": {"tipo": "spawn_delay", "min": 2.5, "max": 4.5}
	},
	"gameplay_change": {
		"nome": "Cliente com troco",
		"categoria": "gameplay",
		"descricao": "Clientes passam a pagar a mais e esperar o troco certo",
		"preco": 900,
		"dinheiro_minimo": 680,
		"requer": ["lang_sensor"],
		"help_topic": "change_client",
		"efeito": {"tipo": "unlock_feature", "feature": "change"}
	},
	"gameplay_stock": {
		"nome": "Abrir estoque",
		"categoria": "gameplay",
		"descricao": "Clientes começam a pedir produtos com quantidade",
		"preco": 1120,
		"dinheiro_minimo": 860,
		"requer": ["gameplay_change"],
		"help_topic": "stock",
		"efeito": {"tipo": "unlock_feature", "feature": "stock"}
	},
	"premium_3": {
		"nome": "Caixa mais esperto III",
		"categoria": "economia",
		"descricao": "+30% no dinheiro que cada cliente deixa",
		"preco": 1500,
		"dinheiro_minimo": 1150,
		"requer": ["premium_2", "gameplay_stock"],
		"efeito": {"tipo": "reward_multiplier", "valor": 0.3}
	},
	"marketing_3": {
		"nome": "Boca a boca III",
		"categoria": "fluxo",
		"descricao": "Clientes aparecem a cada 1s a 3s",
		"preco": 2000,
		"dinheiro_minimo": 1500,
		"requer": ["marketing_2", "gameplay_stock"],
		"efeito": {"tipo": "spawn_delay", "min": 1.0, "max": 3.0}
	}
}
