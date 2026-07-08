extends RefCounted
class_name HelpTopics

const TOPICS = [
	{
		"id": "terminal",
		"title": "Como usar o terminal",
		"category": "Primeiros passos",
		"requirement": "start",
		"text": """[b]Painel de trabalho[/b]
O painel de script é a bancada onde você escreve a automação da loja. Tudo começa dentro da função [code]main()[/code].

[b]Ritmo básico[/b]
Leia o pedido com [code]input()[/code], guarde valores em variáveis, faça as contas e termine com [code]send()[/code]. O botão RODAR executa o script. O retorno do sistema fica logo abaixo do editor.

[b]Conferência rápida[/b]
Se algo não rodar, olhe primeiro os pontos e vírgulas, parênteses e chaves. Quase todo tropeço inicial mora ali.""",
		"hint": "Abra uma [code]main()[/code], coloque um [code]print()[/code] simples dentro dela e rode para conferir se o painel está respondendo."
	},
	{
		"id": "input",
		"title": "input()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Pegar o próximo valor[/b]
[code]input()[/code] pega o próximo número que o cliente mandou para o atendimento.

[b]Na prática[/b]
Cada chamada consome uma entrada. Se o pedido tem dois preços, você chama duas vezes. Se tem pagamento depois, ele vem numa chamada separada.

[b]Cuidado de balcão[/b]
Chamar [code]input()[/code] demais puxa valores que não fazem parte daquela conta. Chamar de menos deixa parte do pedido sem entrar no cálculo.""",
		"hint": "Guarde o retorno de [code]input()[/code] em uma variável e use [code]print()[/code] para ver se chegou o valor esperado."
	},
	{
		"id": "send",
		"title": "send()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Entregar a resposta[/b]
[code]send()[/code] é o momento de passar a resposta final para o cliente.

[b]Antes de enviar[/b]
Faça as contas primeiro. Depois envie só o que o desafio pede. Alguns pedidos querem um valor; outros querem dois, como total e troco.

[b]Cuidado de balcão[/b]
[code]print()[/code] mostra informação para você. [code]send()[/code] valida o atendimento. Enviar valor extra, fora de ordem ou cedo demais derruba a venda.""",
		"hint": "Calcule em uma variável separada e passe essa variável para [code]send()[/code]."
	},
	{
		"id": "print",
		"title": "print()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Olhar por dentro[/b]
[code]print()[/code] escreve uma mensagem no retorno do sistema.

[b]Quando usar[/b]
Use para conferir valores no meio da conta: total parcial, pagamento lido, troco calculado e qualquer variável suspeita.

[b]Cuidado de balcão[/b]
Imprimir não responde ao cliente. Depois de conferir, ainda falta mandar a resposta com [code]send()[/code].""",
		"hint": "Imprima a variável do resultado antes de enviar. Assim você compara o que o script calculou com o pedido."
	},
	{
		"id": "simple_client",
		"title": "Cliente simples",
		"category": "Clientes",
		"requirement": "start",
		"text": """[b]Pedido de entrada[/b]
O cliente simples manda dois preços e espera receber a soma.

[b]Caminho seguro[/b]
Leia o primeiro preço, leia o segundo, some os dois e envie um único total.

[b]Cuidado de balcão[/b]
Enviar os preços separados não fecha a compra. O cliente quer o total final.""",
		"hint": "Use duas chamadas a [code]input()[/code], some os valores e envie apenas a soma."
	},
	{
		"id": "change_client",
		"title": "Cliente com troco",
		"category": "Clientes",
		"requirement": "troco",
		"text": """[b]Compra e pagamento[/b]
Esse cliente manda vários preços, encerra a lista com [code]-1[/code] e depois informa quanto pagou.

[b]Ordem do atendimento[/b]
Some os produtos até encontrar [code]-1[/code]. Depois leia o pagamento, calcule [code]pagamento - total[/code] e envie primeiro o total, depois o troco.

[b]Cuidado de balcão[/b]
Troco não é [code]total - pagamento[/code]. A ordem em [code]send(total, troco)[/code] também conta.""",
		"hint": "Depois que o laço encontrar [code]-1[/code], leia mais um valor para o pagamento. Só então calcule o troco."
	},
	{
		"id": "sentinel_client",
		"title": "Cliente com sentinela",
		"category": "Clientes",
		"requirement": "sentinela",
		"text": """[b]Lista de tamanho variável[/b]
Alguns clientes não dizem antes quantos produtos vão comprar. O valor [code]-1[/code] avisa que a lista acabou.

[b]Jeito limpo de ler[/b]
Leia o primeiro valor antes do laço. Enquanto ele for diferente de [code]-1[/code], some ao total e leia o próximo.

[b]Cuidado de balcão[/b]
A sentinela nunca entra na soma. Se você esquecer o novo [code]input()[/code] dentro do laço, o script fica preso repetindo o mesmo valor.""",
		"hint": "Use um [code]while[/code] controlado pelo valor atual. Some primeiro o valor válido e, no fim do bloco, leia o próximo."
	},
	{
		"id": "discount",
		"title": "Desconto acima de R$50",
		"category": "Mecânicas da loja",
		"requirement": "desconto",
		"text": """[b]Regra da loja[/b]
Compras acima de R$50 recebem 10% de desconto.

[b]Como aplicar[/b]
Calcule o total cheio. Se ele passar de 50, mantenha 90% do valor multiplicando por [code]0.9[/code].

[b]Cuidado de balcão[/b]
O desconto vale para valores acima de 50, não para exatamente 50. Aplicar o desconto dentro do laço pode descontar mais de uma vez.""",
		"hint": "Feche o total primeiro. Depois use um [code]if[/code] para decidir se o valor vira [code]total * 0.9[/code]."
	},
	{
		"id": "stock",
		"title": "Estoque",
		"category": "Mecânicas da loja",
		"requirement": "estoque",
		"text": """[b]Prateleira da loja[/b]
O estoque guarda produtos para pedidos específicos. Repor custa dinheiro, e clientes de estoque consomem produtos quando o atendimento dá certo.

[b]Repor produtos[/b]
Abra o menu Estoque, escolha quantas unidades comprar e confirme. Cada produto mostra quantidade atual e limite, como [code]4/10[/code].

[b]Atender pedido[/b]
O cliente envia pares de valores: preço e quantidade. Multiplique cada par, some os subtotais e envie o total.

[b]Bônus de prateleira cheia[/b]
Quando todos os produtos estão no máximo, as recompensas dos clientes valem 1.5x. Se algum produto for consumido, reponha tudo para ativar o bônus de novo.

[b]Cuidado de balcão[/b]
Somar só os preços ignora as quantidades. Também confira o saldo antes de repor, porque estoque cheio tem limite e compra custa dinheiro.""",
		"hint": "Leia em pares: preço, quantidade. Cada subtotal é [code]preço * quantidade[/code]. Some os subtotais e envie o total."
	},
	{
		"id": "if",
		"title": "if",
		"category": "Controle de fluxo",
		"requirement": "if",
		"text": """[b]Tomar uma decisão[/b]
[code]if[/code] executa um bloco somente quando a condição for verdadeira.

[b]Formato[/b]
A pergunta fica entre parênteses. A ação fica entre chaves. Comparações comuns usam [code]>[/code], [code]<[/code], [code]==[/code] e [code]!=[/code].

[b]Cuidado de balcão[/b]
Para comparar, use [code]==[/code]. Um único [code]=[/code] guarda valor em uma variável.""",
		"hint": "Escreva uma pergunta que tenha resposta verdadeira ou falsa e coloque a ação dentro das chaves do [code]if[/code]."
	},
	{
		"id": "sensor",
		"title": "sensor(\"cliente_na_tela\")",
		"category": "Funções da loja",
		"requirement": "sensor",
		"text": """[b]Olhar a loja[/b]
[code]sensor("cliente_na_tela")[/code] informa se existe um cliente aguardando atendimento.

[b]Como usar[/b]
Use o sensor como uma condição. Quando ele retornar verdadeiro, há cliente na tela.

[b]Cuidado de balcão[/b]
O nome do sensor é texto, então precisa de aspas. Um nome que não existe retorna falso.""",
		"hint": "Use [code]sensor(\"cliente_na_tela\")[/code] dentro de uma condição e deixe o atendimento acontecer só quando houver cliente."
	},
	{
		"id": "while",
		"title": "while",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir enquanto precisa[/b]
[code]while[/code] repete um bloco enquanto a condição continuar verdadeira.

[b]Bom para sentinela[/b]
Ele combina bem com pedidos que acabam em [code]-1[/code], porque você não sabe de antemão quantos valores vão chegar.

[b]Cuidado de balcão[/b]
Alguma coisa dentro do bloco precisa mudar a condição. Se nada mudar, o script fica em repetição infinita.""",
		"hint": "Escolha uma variável de controle, leia um valor antes do [code]while[/code] e atualize essa variável dentro do bloco."
	},
	{
		"id": "for",
		"title": "for",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir com contador[/b]
[code]for[/code] é bom quando você já sabe quantas voltas precisa dar.

[b]Cabeçalho[/b]
Ele junta três partes: onde o contador começa, até quando continua e como muda depois de cada volta.

[b]Cuidado de balcão[/b]
Confira a condição e o incremento. Um sinal errado pode repetir uma vez a mais ou nunca parar.""",
		"hint": "Use um contador inteiro. Defina o início, a condição de parada e o incremento no cabeçalho do [code]for[/code]."
	}
]
