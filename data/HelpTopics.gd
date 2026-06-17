extends RefCounted
class_name HelpTopics

const TOPICS = [
	{
		"id": "terminal",
		"title": "Como usar o terminal",
		"category": "Primeiros passos",
		"requirement": "start",
		"text": """[b]O que é[/b]
O painel de script é onde você escreve a automação da loja. Todo programa começa pela função [code]main()[/code].

[b]Quando aparece[/b]
O terminal está disponível desde o início pelo botão Scripts.

[b]Como pensar[/b]
Leia os dados com [code]input()[/code], faça os cálculos em variáveis e termine enviando a resposta com [code]send()[/code]. Use o botão INICIAR para executar e observe o retorno do sistema abaixo do editor.

[b]Erros comuns[/b]
Não esqueça o ponto e vírgula no fim dos comandos, os parênteses das funções e as chaves que abrem e fecham a [code]main()[/code].""",
		"hint": "Comece criando a função [code]main()[/code]. Dentro das chaves, coloque um [code]print()[/code] simples e confira o retorno do sistema."
	},
	{
		"id": "input",
		"title": "input()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]O que é[/b]
[code]input()[/code] lê o próximo valor enviado pelo cliente.

[b]Quando aparece[/b]
É usado em qualquer atendimento. Cada chamada consome exatamente uma entrada.

[b]Como pensar[/b]
Guarde o resultado em uma variável antes de calcular. Se o cliente enviar vários valores, chame [code]input()[/code] novamente para cada um.

[b]Erros comuns[/b]
Chamar [code]input()[/code] mais vezes do que o necessário retorna valores que não pertencem ao pedido. Chamar menos vezes deixa parte do pedido sem ser processada.""",
		"hint": "Crie uma variável do tipo [code]float[/code] e atribua a ela o resultado de uma chamada a [code]input()[/code]. Depois, use [code]print()[/code] para conferir o valor."
	},
	{
		"id": "send",
		"title": "send()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]O que é[/b]
[code]send()[/code] entrega a resposta final ao cliente.

[b]Quando aparece[/b]
Todo atendimento precisa terminar com o envio dos valores esperados.

[b]Como pensar[/b]
Faça todos os cálculos primeiro e envie apenas o resultado. Alguns desafios esperam mais de um valor, como total e troco.

[b]Erros comuns[/b]
[code]send()[/code] não substitui [code]print()[/code]: ele valida o atendimento. Enviar valores extras, na ordem errada ou antes do cálculo faz o pedido falhar.""",
		"hint": "Guarde cada entrada em uma variável, faça o cálculo em outra variável e passe somente o resultado final para [code]send()[/code]."
	},
	{
		"id": "print",
		"title": "print()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]O que é[/b]
[code]print()[/code] mostra uma informação no retorno do sistema.

[b]Quando aparece[/b]
Pode ser usado a qualquer momento para entender o que o programa está calculando.

[b]Como pensar[/b]
Imprima valores intermediários para conferir a lógica antes de enviá-los ao cliente.

[b]Erros comuns[/b]
Imprimir um valor não responde ao cliente. O atendimento ainda precisa de [code]send()[/code].""",
		"hint": "Antes de enviar a resposta, imprima a variável que guarda o resultado. Assim você consegue comparar o valor calculado com o pedido do cliente."
	},
	{
		"id": "simple_client",
		"title": "Cliente simples",
		"category": "Clientes",
		"requirement": "start",
		"text": """[b]O que é[/b]
O cliente simples envia dois preços e espera receber a soma.

[b]Quando aparece[/b]
É o atendimento inicial da loja e continua podendo aparecer durante o jogo.

[b]Como pensar[/b]
Leia os dois valores, some-os e envie um único total.

[b]Erros comuns[/b]
Enviar os dois preços separadamente ou ler apenas um deles não corresponde à resposta esperada.""",
		"hint": "Você precisa de duas chamadas a [code]input()[/code]. Some os valores recebidos e envie apenas essa soma."
	},
	{
		"id": "change_client",
		"title": "Cliente com troco",
		"category": "Clientes",
		"requirement": "troco",
		"text": """[b]O que é[/b]
Esse cliente envia os preços da compra até a sentinela [code]-1[/code] e, depois, o valor usado para pagar. Ele espera o total da compra e o troco.

[b]Quando aparece[/b]
Passa a aparecer depois que a mecânica de troco é comprada.

[b]Como pensar[/b]
Some os produtos até receber [code]-1[/code]. Depois, faça mais uma chamada a [code]input()[/code] para ler o pagamento. Calcule [code]pagamento - total[/code] e envie primeiro o total e depois o troco.

[b]Erros comuns[/b]
Troco é [code]pagamento - total[/code], não o contrário. A ordem em [code]send(total, troco)[/code] também importa.""",
		"hint": "O pagamento vem somente depois de [code]-1[/code]. Saia do laço, leia mais um valor, calcule o troco e use [code]send(total, troco)[/code]."
	},
	{
		"id": "sentinel_client",
		"title": "Cliente com sentinela",
		"category": "Clientes",
		"requirement": "sentinela",
		"text": """[b]O que é[/b]
Alguns clientes enviam uma quantidade variável de preços. O valor [code]-1[/code] é uma sentinela: ele avisa que a compra acabou.

[b]Quando aparece[/b]
Passa a aparecer com o upgrade de compras variáveis.

[b]Como pensar[/b]
Leia um valor antes do laço. Enquanto ele for diferente de [code]-1[/code], some ao total e leia o próximo. A sentinela nunca entra na soma.

[b]Erros comuns[/b]
Somar antes de testar inclui [code]-1[/code] no total. Esquecer o novo [code]input()[/code] dentro do laço cria uma repetição infinita.""",
		"hint": "Leia o primeiro valor antes do [code]while[/code]. Dentro do laço, some o valor atual e leia o próximo. A condição deve impedir que [code]-1[/code] seja somado."
	},
	{
		"id": "discount",
		"title": "Desconto acima de R$50",
		"category": "Mecânicas da loja",
		"requirement": "desconto",
		"text": """[b]O que é[/b]
Compras acima de R$50 recebem 10% de desconto.

[b]Quando aparece[/b]
Clientes de desconto passam a aparecer depois que decisões com [code]if[/code] são desbloqueadas.

[b]Como pensar[/b]
Calcule o total completo primeiro. Se ele for maior que 50, mantenha 90% do valor multiplicando por [code]0.9[/code].

[b]Erros comuns[/b]
O desconto vale para valores [b]acima[/b] de 50, não exatamente 50. Aplicar o desconto dentro do laço pode descontar várias vezes.""",
		"hint": "Calcule o total primeiro. Depois use um [code]if[/code] para testar se ele passou de 50. Somente nesse caso, mantenha 90% do valor."
	},
	{
		"id": "stock",
		"title": "Estoque",
		"category": "Mecânicas da loja",
		"requirement": "estoque",
		"text": """[b]O que é[/b]
O estoque guarda os produtos disponíveis para atender pedidos específicos. Comprar unidades tem custo, e clientes de estoque consomem os produtos solicitados.

[b]Quando aparece[/b]
O botão de estoque e esses clientes são liberados pelo upgrade de estoque.

[b]Como pensar[/b]
Abra o menu Estoque, escolha quantas unidades deseja repor e confirme a compra. No atendimento, cada produto envia seu preço e sua quantidade. Calcule cada subtotal com [code]preço * quantidade[/code], some os subtotais e envie o total.

Cada produto tem um limite máximo e aparece como quantidade atual/máximo, por exemplo [code]4/10[/code]. Não é possível comprar acima desse limite.

Os produtos só são consumidos quando a resposta está correta. Se não houver produtos disponíveis, novos clientes de estoque ficam limitados até que você faça a reposição.

Quando todos os produtos estão cheios, o bônus de prateleira cheia fica ativo: as recompensas dos clientes são multiplicadas por 1.5x. Ao atender clientes, produtos podem ser consumidos e o bônus pode deixar de valer até você reabastecer tudo novamente.

[b]Erros comuns[/b]
Somar apenas os preços ignora as quantidades. Também é importante conferir o saldo antes de atender: comprar estoque custa dinheiro, cada produto tem limite máximo, e um pedido só pode usar produtos disponíveis.""",
		"hint": "Leia os valores em pares: primeiro o preço, depois a quantidade. Multiplique cada par, acumule os subtotais e envie apenas o total final."
	},
	{
		"id": "if",
		"title": "if",
		"category": "Controle de fluxo",
		"requirement": "if",
		"text": """[b]O que é[/b]
[code]if[/code] executa um bloco somente quando uma condição é verdadeira.

[b]Quando aparece[/b]
É liberado pelo upgrade Conceito: if() e permite tratar regras como o desconto.

[b]Como pensar[/b]
Escreva a condição entre parênteses e o código condicionado entre chaves. Comparações comuns usam [code]>[/code], [code]<[/code], [code]==[/code] e [code]!=[/code].

[b]Erros comuns[/b]
Use [code]==[/code] para comparar. Um único [code]=[/code] serve para atribuir um valor a uma variável.""",
		"hint": "Pense em uma pergunta que só pode ser verdadeira ou falsa. Coloque essa comparação entre os parênteses do [code]if[/code] e a ação entre as chaves."
	},
	{
		"id": "sensor",
		"title": "sensor(\"cliente_na_tela\")",
		"category": "Funções da loja",
		"requirement": "sensor",
		"text": """[b]O que é[/b]
[code]sensor("cliente_na_tela")[/code] informa se existe um cliente visível aguardando atendimento.

[b]Quando aparece[/b]
A função fica disponível depois da compra do upgrade Conceito: sensor().

[b]Como pensar[/b]
Use o sensor como uma condição. Quando ele retornar verdadeiro, há um cliente na tela.

[b]Erros comuns[/b]
O nome do sensor é um texto e precisa estar entre aspas. Consultar um nome inexistente retorna falso.""",
		"hint": "Use o retorno de [code]sensor(\"cliente_na_tela\")[/code] diretamente como condição de um [code]if[/code]. Dentro dele, faça apenas o que deve acontecer quando houver cliente."
	},
	{
		"id": "while",
		"title": "while",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]O que é[/b]
[code]while[/code] repete um bloco enquanto uma condição for verdadeira.

[b]Quando aparece[/b]
É especialmente útil após liberar compras variáveis com sentinela.

[b]Como pensar[/b]
Prepare a variável usada na condição antes do laço e atualize essa variável dentro dele.

[b]Erros comuns[/b]
Se nada dentro do bloco puder tornar a condição falsa, o programa entra em repetição infinita.""",
		"hint": "Escolha uma variável que controla a repetição. Dê um valor inicial antes do laço e atualize essa mesma variável dentro dele para que a condição possa se tornar falsa."
	},
	{
		"id": "for",
		"title": "for",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]O que é[/b]
[code]for[/code] repete um bloco com início, condição e incremento definidos no cabeçalho.

[b]Quando aparece[/b]
É útil quando você sabe antecipadamente quantas repetições precisa fazer.

[b]Como pensar[/b]
O cabeçalho cria um contador, testa se ele deve continuar e atualiza seu valor depois de cada repetição.

[b]Erros comuns[/b]
Confira a condição e o incremento para não repetir uma vez a mais ou criar um laço que nunca termina.""",
		"hint": "Use um contador inteiro. No cabeçalho do [code]for[/code], defina onde ele começa, até quando continua e como aumenta após cada repetição."
	}
]
