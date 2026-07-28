extends RefCounted
class_name HelpTopics

const TOPICS = [
	{
		"id": "terminal",
		"title": "Como usar o terminal",
		"category": "Primeiros passos",
		"requirement": "start",
		"text": """[b]Onde o jogo começa de verdade[/b]
O painel de script é onde você escreve o código que atende os clientes. Quase tudo vai ficar dentro da função [code]main()[/code].

[b]O ciclo básico[/b]
Use [code]input()[/code] para pegar valores do cliente, faça a conta e responda com [code]send()[/code]. O botão RODAR liga o script. A saída aparece embaixo do editor.

[b]Quando der ruim[/b]
Antes de desconfiar da lógica, confere ponto e vírgula, parênteses e chaves. No começo, o erro quase sempre está nisso.""",
		"hint": "Faça uma [code]main()[/code] pequena com um [code]print()[/code] e rode. Se aparecer no retorno, o painel está ok."
	},
	{
		"id": "input",
		"title": "input()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Pegar o próximo número[/b]
[code]input()[/code] pega o próximo valor da fila do cliente.

[b]Como usar[/b]
Cada chamada pega um valor e passa para o próximo. Dois preços? Chame duas vezes. Teve pagamento depois? Mais um [code]input()[/code].

[b]Cuidado[/b]
Se chamar demais, você puxa coisa que ainda não era para usar. Se chamar de menos, parte do pedido fica de fora.""",
		"hint": "Guarde o [code]input()[/code] numa variável e dê um [code]print()[/code]. É o jeito mais rápido de ver o que chegou."
	},
	{
		"id": "send",
		"title": "send()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Responder o cliente[/b]
[code]send()[/code] manda sua resposta final.

[b]Antes de mandar[/b]
Calcule tudo antes. Alguns clientes esperam só o total. Outros querem total e troco, nessa ordem.

[b]Cuidado[/b]
[code]print()[/code] é só para você enxergar. Quem fecha a venda é [code]send()[/code]. Valor extra ou fora de ordem conta como erro.""",
		"hint": "Calcule em uma variável e passe essa variável no [code]send()[/code]. Fica mais fácil de conferir."
	},
	{
		"id": "print",
		"title": "print()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Ver o que está acontecendo[/b]
[code]print()[/code] escreve no retorno do sistema.

[b]Quando usar[/b]
Use quando uma conta parece certa, mas o cliente discorda. Imprima total parcial, pagamento, troco ou qualquer variável suspeita.

[b]Cuidado[/b]
Imprimir não responde o cliente. Depois de olhar, ainda precisa usar [code]send()[/code].""",
		"hint": "Dê [code]print()[/code] no resultado antes do [code]send()[/code]. Se o número já sai errado ali, o problema está antes."
	},
	{
		"id": "simple_client",
		"title": "Cliente simples",
		"category": "Clientes",
		"requirement": "start",
		"text": """[b]O primeiro tipo de cliente[/b]
Ele manda dois preços e quer saber o total.

[b]Caminho simples[/b]
Leia o primeiro preço, leia o segundo, some os dois e mande só a soma.

[b]Cuidado[/b]
Não envie os preços separados. O cliente pediu o total.""",
		"hint": "Dois [code]input()[/code], uma soma, um [code]send()[/code]."
	},
	{
		"id": "change_client",
		"title": "Cliente com troco",
		"category": "Clientes",
		"requirement": "troco",
		"text": """[b]Compra com pagamento[/b]
Esse cliente manda uma lista de preços, termina com [code]-1[/code] e depois informa quanto pagou.

[b]Ordem certa[/b]
Some os produtos até chegar no [code]-1[/code]. Depois leia o pagamento, faça [code]pagamento - total[/code] e envie [code]send(total, troco)[/code].

[b]Cuidado[/b]
Troco é pagamento menos total. E a ordem no [code]send()[/code] importa.""",
		"hint": "Quando sair do laço do [code]-1[/code], leia mais um valor. Esse valor é o pagamento."
	},
	{
		"id": "sentinel_client",
		"title": "Cliente com sentinela",
		"category": "Clientes",
		"requirement": "sentinela",
		"text": """[b]Pedido sem tamanho fixo[/b]
Alguns clientes mandam vários preços e só avisam que acabou com [code]-1[/code].

[b]Como ler[/b]
Leia o primeiro valor antes do laço. Enquanto ele não for [code]-1[/code], some e leia o próximo.

[b]Cuidado[/b]
O [code]-1[/code] não entra na soma. E se você esquecer o [code]input()[/code] dentro do laço, o código fica preso no mesmo número.""",
		"hint": "Leia antes do [code]while[/code], some dentro dele e leia de novo no final do bloco."
	},
	{
		"id": "discount",
		"title": "Desconto acima de R$50",
		"category": "Mecânicas da loja",
		"requirement": "desconto",
		"text": """[b]Regra fixa da loja[/b]
Passou de R$50, tem 10% de desconto. Não é sorteio.

[b]Como aplicar[/b]
Primeiro some tudo. Se o total for maior que 50, multiplique por [code]0.9[/code].

[b]Cuidado[/b]
R$50 exatos não desconta. E deixe para aplicar depois da soma, senão você pode descontar mais de uma vez.""",
		"hint": "Some tudo primeiro. Depois use [code]if (total > 50)[/code] e aplique [code]total *= 0.9[/code]."
	},
	{
		"id": "stock",
		"title": "Estoque",
		"category": "Mecânicas da loja",
		"requirement": "estoque",
		"text": """[b]Prateleira da loja[/b]
O estoque guarda produtos para pedidos mais específicos. Repor custa dinheiro. Quando você acerta o atendimento, os itens saem da prateleira.

[b]Repor produtos[/b]
Abra o Estoque, escolha quantas unidades comprar e confirme. Cada item mostra atual e limite, tipo [code]4/10[/code].

[b]Atender pedido[/b]
O cliente manda pares: preço e quantidade. Multiplique cada par e some tudo.

[b]Bônus de prateleira cheia[/b]
Com tudo cheio, cada cliente paga 1.5x. Se vender algum item, o bônus cai até você repor de novo.

[b]Cuidado[/b]
Somar só os preços ignora as quantidades. Também olha o dinheiro antes de comprar, porque reposição custa.""",
		"hint": "Leia em pares: preço, quantidade. Cada subtotal é [code]preço * quantidade[/code]."
	},
	{
		"id": "if",
		"title": "if",
		"category": "Controle de fluxo",
		"requirement": "if",
		"text": """[b]Tomar decisão no código[/b]
[code]if[/code] roda um bloco só quando a condição é verdadeira.

[b]Formato[/b]
A pergunta fica entre parênteses. O que deve acontecer fica entre chaves. Para comparar, use [code]>[/code], [code]<[/code], [code]==[/code] ou [code]!=[/code].

[b]Cuidado[/b]
[code]==[/code] compara. [code]=[/code] guarda valor. Confundir os dois quebra muita coisa.""",
		"hint": "Pense no [code]if[/code] como uma pergunta de sim ou não. Se der sim, ele entra nas chaves."
	},
	{
		"id": "sensor",
		"title": "sensor(\"cliente_na_tela\")",
		"category": "Funções da loja",
		"requirement": "sensor",
		"text": """[b]Olhar a loja pelo código[/b]
[code]sensor("cliente_na_tela")[/code] diz se tem cliente esperando.

[b]Como usar[/b]
Use como condição no [code]if[/code] ou no [code]while[/code]. Se retornar verdadeiro, tem cliente na tela.

[b]Cuidado[/b]
O nome do sensor é texto, então vai entre aspas. Se escrever o nome errado, ele retorna falso.""",
		"hint": "Use [code]sensor(\"cliente_na_tela\")[/code] na condição e só atenda quando ele der verdadeiro."
	},
	{
		"id": "while",
		"title": "while",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir até parar[/b]
[code]while[/code] repete um bloco enquanto a condição continuar verdadeira.

[b]Bom para sentinela[/b]
Ele serve muito bem para pedidos que acabam em [code]-1[/code], porque você não sabe quantos valores vão chegar.

[b]Cuidado[/b]
Alguma coisa dentro do bloco precisa mudar. Se nada muda, o script fica rodando para sempre.""",
		"hint": "Tenha uma variável de controle. Leia antes do [code]while[/code] e atualize dentro dele."
	},
	{
		"id": "for",
		"title": "for",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir com contador[/b]
[code]for[/code] é para quando você já sabe quantas voltas quer dar.

[b]Cabeçalho[/b]
Ele junta três partes: onde começa, quando para e como muda depois de cada volta.

[b]Cuidado[/b]
Olhe bem a condição e o incremento. Um sinal errado pode fazer uma volta a mais ou não parar.""",
		"hint": "Use um contador inteiro e confira início, parada e incremento no cabeçalho do [code]for[/code]."
	}
]
