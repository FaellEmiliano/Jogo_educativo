extends RefCounted
class_name HelpTopics

const TOPICS = [
	{
		"id": "terminal",
		"title": "Como usar o terminal",
		"category": "Primeiros passos",
		"requirement": "start",
		"text": """[b]Onde o jogo começa de verdade[/b]
O painel de script é o lugar onde você prepara o atendimento automático da loja. Quando o cliente chega, o jogo entrega os dados no terminal e espera a resposta do seu script.

[b]Rodar e observar[/b]
O botão RODAR testa o que você escreveu. O retorno aparece embaixo do editor, junto com mensagens que ajudam a entender se o script conseguiu atender o pedido.

[b]Quando der ruim[/b]
Antes de desconfiar da ideia, confira detalhes pequenos: ponto e vírgula, parênteses, chaves e nomes escritos igualzinho.""",
		"hint": "Comece pequeno e rode cedo. Se o retorno aparecer, o painel já está conversando com o seu script."
	},
	{
		"id": "input",
		"title": "input()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Pegar o próximo número[/b]
[code]input()[/code] lê uma informação que o cliente enviou para a loja. Cada cliente pode mandar preços, quantidades, pagamentos ou sinais especiais, dependendo do desafio.

[b]Fila de dados[/b]
Os valores chegam em ordem. Depois que um valor é lido, o próximo [code]input()[/code] olha para o próximo item da fila.

[b]Cuidado[/b]
Ler dados demais pode misturar partes do pedido. Ler de menos deixa informação importante parada.""",
		"hint": "Quando estiver perdido, mostre no retorno o valor que acabou de chegar e compare com a fala do cliente."
	},
	{
		"id": "send",
		"title": "send()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Responder o cliente[/b]
[code]send()[/code] entrega a resposta que vale para o atendimento. É isso que o cliente usa para decidir se o pedido foi resolvido.

[b]O que ele espera[/b]
Alguns pedidos aceitam uma resposta simples, como [code]send(total);[/code]. Quando houver troco, envie dois valores e mantenha esta ordem: [code]send(total, troco);[/code].

[b]Cuidado[/b]
[code]print()[/code] só mostra algo para você. Quem fecha a venda é [code]send()[/code].""",
		"hint": "Antes de enviar, pense no que o cliente realmente pediu como resposta final."
	},
	{
		"id": "print",
		"title": "print()",
		"category": "Funções básicas",
		"requirement": "start",
		"text": """[b]Ver o que está acontecendo[/b]
[code]print()[/code] escreve no retorno do sistema.

[b]Quando usar[/b]
Use quando o script roda, mas o resultado não combina com o pedido. Ele serve para enxergar valores intermediários sem mudar a resposta enviada ao cliente.

[b]Cuidado[/b]
Imprimir não responde o cliente. Depois de olhar, ainda precisa usar [code]send()[/code].""",
		"hint": "Mostre uma coisa por vez. Assim fica mais fácil descobrir em que momento o número deixou de fazer sentido."
	},
	{
		"id": "simple_client",
		"title": "Cliente simples",
		"category": "Clientes",
		"requirement": "start",
		"text": """[b]O primeiro tipo de cliente[/b]
Esse cliente traz uma compra pequena, com poucos valores, e espera uma resposta objetiva da loja.

[b]O que observar[/b]
Cada [code]input()[/code] lê o preço de um item. Some os preços e use [code]send(total);[/code] para responder quanto ficou a compra.

[b]Cuidado[/b]
Responder partes soltas da compra pode parecer útil, mas o atendimento só conta quando a resposta combina com o pedido.""",
		"hint": "Procure transformar os valores do pedido em uma única informação final."
	},
	{
		"id": "change_client",
		"title": "Cliente com troco",
		"category": "Clientes",
		"requirement": "troco",
		"text": """[b]Compra com pagamento[/b]
Esse cliente informa os itens da compra e também quanto entregou para pagar. Esse pagamento não é dinheiro extra para a loja: ele serve para calcular o troco.

[b]Fim dos produtos[/b]
Leia os preços até encontrar [code]-1[/code]. O próximo [code]input()[/code] depois desse marcador contém o pagamento do cliente.

[b]Como responder[/b]
Calcule [code]troco = pagamento - total[/code] e envie exatamente dois valores, nesta ordem: [code]send(total, troco);[/code].

[b]Cuidado[/b]
O [code]-1[/code] não entra na soma, e inverter total e troco faz a resposta ser recusada.""",
		"hint": "Depois do marcador de fim, veja se ainda existe um valor que muda o significado da resposta."
	},
	{
		"id": "sentinel_client",
		"title": "Cliente com sentinela",
		"category": "Clientes",
		"requirement": "sentinela",
		"text": """[b]Pedido sem tamanho fixo[/b]
Alguns clientes não dizem antes quantos produtos vão comprar. Eles continuam mandando valores até aparecer um marcador de fim.

[b]O marcador[/b]
O [code]-1[/code] serve como aviso de parada. Ele separa os produtos do que vem depois, ou simplesmente indica que o pedido acabou.

[b]Cuidado[/b]
Se o script fica preso, provavelmente ele está olhando sempre para a mesma informação.""",
		"hint": "Quando o tamanho do pedido varia, o [code]while[/code] ajuda a repetir enquanto o marcador de fim ainda não apareceu."
	},
	{
		"id": "discount",
		"title": "Desconto acima de R$50",
		"category": "Mecânicas da loja",
		"requirement": "desconto",
		"text": """[b]Regra fixa da loja[/b]
Toda compra cujo total bruto seja maior que R$50 recebe 10% de desconto. O cliente não precisa pedir: é uma regra da loja.

[b]Quando observar[/b]
Primeiro some todos os produtos. Se o total passar de R$50, aplique o desconto uma única vez sobre o total.

[b]Cuidado[/b]
O desconto pertence à compra inteira, não a cada produto separado.""",
		"hint": "Compare o total final com o limite da regra antes de alterar o valor."
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
Clientes de estoque mandam as informações em pares: primeiro o preço de uma unidade, depois a quantidade. Calcule [code]preco * quantidade[/code] para cada par e some os resultados. O [code]-1[/code] marca o fim dos pares.

[b]Bônus de prateleira cheia[/b]
Com tudo cheio, a recompensa de cada atendimento vale 1,5x. O total da compra que seu script deve enviar não muda. Depois de vender algum item, o bônus fica inativo até você encher o estoque novamente.

[b]Cuidado[/b]
Também olhe o dinheiro antes de comprar, porque reposição custa.""",
		"hint": "Quando aparecer quantidade, pense no valor de uma unidade e no tamanho do pedido como duas informações separadas."
	},
	{
		"id": "stock_commands",
		"title": "Comandos do estoque",
		"category": "Funções da loja",
		"requirement": "estoque",
		"text": """[b]Ver o estoque pelo código[/b]
[code]get_stock()[/code] devolve um array com as quantidades atuais, na ordem: arroz, feijão, farinha, morango, uva e chocolate.

[b]Comprar pelo código[/b]
[code]buy_stock(compra)[/code] recebe um array com 6 posições e compra essas quantidades para o estoque.
Cada posição representa um produto da prateleira.

[b]Quando buy_stock() não completa[/b]
Formato inválido, quantidade negativa ou compra acima do limite cancelam toda a operação. Se faltar dinheiro, a compra pode ser parcial: o jogo compra o que puder começando pela posição [code][0][/code] e para quando o dinheiro acaba. O terminal avisa quando isso acontece.

[b]Cuidado[/b]
A ordem do array é a ordem da prateleira. Confira o estoque depois de uma compra parcial, porque os últimos produtos da lista podem não ter sido comprados.""",
		"hint": "Compare o que já tem com o limite da prateleira antes de escolher quanto comprar."
	},
	{
		"id": "await",
		"title": "await()",
		"category": "Funções da loja",
		"requirement": "estoque",
		"text": """[b]Liberado com o estoque[/b]
O upgrade [b]Abrir estoque[/b] também libera [code]await()[/code] para seus scripts automáticos.

[b]Dar uma pausa no script[/b]
[code]await(segundos)[/code] suspende o script pelo tempo indicado. Enquanto ele espera, a loja, os clientes e os outros scripts continuam funcionando normalmente.

[b]Por que isso é útil[/b]
Um script automático costuma usar [code]while[/code] para observar a loja o tempo todo. Sem uma pausa, ele verifica a mesma coisa muitas vezes seguidas. [code]await()[/code] controla esse ritmo sem travar o jogo.

[b]Como usar[/b]
[code]await(1);[/code] espera um segundo antes de continuar. Tempos menores, como [code]await(0.1);[/code], servem para verificações mais frequentes.

[b]Cuidado[/b]
A espera acontece somente no script que chamou a função. Um tempo muito alto pode fazer esse script demorar para perceber o próximo cliente.""",
		"hint": "Dentro de um [code]while[/code] automático, coloque [code]await()[/code] depois de verificar ou atender o cliente."
	},
	{
		"id": "if",
		"title": "if",
		"category": "Controle de fluxo",
		"requirement": "if",
		"text": """[b]Tomar decisão no código[/b]
[code]if[/code] serve para o script escolher entre agir ou não agir em uma situação.

[b]Pergunta de sim ou não[/b]
Ele combina com regras do tipo: tem desconto? tem cliente? o valor passou do limite? Quando a resposta é sim, o bloco acontece.

[b]Cuidado[/b]
[code]==[/code] compara. [code]=[/code] guarda valor. Confundir os dois quebra muita coisa.""",
		"hint": "Transforme a regra em uma pergunta curta antes de escrever a condição."
	},
	{
		"id": "sensor",
		"title": "sensor(\"cliente_na_tela\")",
		"category": "Funções da loja",
		"requirement": "sensor",
		"text": """[b]Olhar a loja pelo código[/b]
[code]sensor("cliente_na_tela")[/code] diz se tem cliente esperando.

[b]Quando ajuda[/b]
Ele é útil para automatizar o script e não precisar ficar apertando RODAR manualmente a cada cliente.

[b]Cuidado[/b]
O nome do sensor é texto, então vai entre aspas. Se escrever o nome errado, ele retorna falso.""",
		"hint": "Pense no sensor como uma pergunta sobre a cena antes de decidir atender."
	},
	{
		"id": "while",
		"title": "while",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir até parar[/b]
[code]while[/code] repete um trecho enquanto uma situação continuar valendo.

[b]Bom para sentinela[/b]
Ele combina com pedidos que não têm tamanho fixo, especialmente quando existe um marcador avisando que chegou ao fim.

[b]Cuidado[/b]
Alguma coisa dentro da repetição precisa mudar. Se nada muda, o script fica rodando para sempre.""",
		"hint": "Observe qual informação faz a repetição continuar e qual informação faz ela parar."
	},
	{
		"id": "for",
		"title": "for",
		"category": "Controle de fluxo",
		"requirement": "loops",
		"text": """[b]Repetir com contador[/b]
[code]for[/code] é uma repetição com contador. Ele é útil quando o número de voltas já está claro.

[b]Cabeçalho[/b]
O cabeçalho concentra as informações do contador: começo, limite e mudança a cada volta.

[b]Cuidado[/b]
Olhe bem a condição e o incremento. Um sinal errado pode fazer uma volta a mais ou não parar.""",
		"hint": "Antes de escrever, conte mentalmente a primeira e a última volta esperadas."
	},
	{
		"id": "delivery_overview",
		"title": "Visão geral",
		"category": "Delivery Online",
		"requirement": "delivery",
		"text": """[b]Relatórios fora do balcão[/b]
O Delivery Online gera relatórios separados dos clientes presenciais e do estoque. Cada relatório continua aberto até seu script declarar os lucros corretos.

[b]Três categorias[/b]
O relatório sempre traz três quantidades, nesta ordem: entregas normais, expressas e VIP.

[b]Seu objetivo[/b]
Leia as quantidades, calcule cada categoria e envie os três resultados na ordem certa. Quando a declaração for aprovada, o lucro total entra no caixa. Você também recebe 1 diamante enquanto ainda não tiver atingido o limite de 5.

[b]O que uma solução precisa usar[/b]
O Delivery exige uma função criada por você e usada de verdade no cálculo. Essa função deve ser recursiva, usar [code]if[/code] para o caso-base e se aproximar desse caso a cada chamada. Use também [code]for[/code] ou [code]while[/code] para processar as três categorias e envie um array de 3 posições para [code]declare_profit()[/code].

[b]Diamantes[/b]
Junte 5 diamantes para comprar o upgrade final Zerar.

[b]Cuidado[/b]
Ler o relatório de novo não troca as quantidades. Um novo só aparece depois que o atual for aprovado e o tempo de espera terminar.""",
		"hint": "Resolva uma categoria por vez. Quando a mesma regra servir para as três, pense em como reaproveitar uma função."
	},
	{
		"id": "delivery_commands",
		"title": "Comandos do Delivery",
		"category": "Delivery Online",
		"requirement": "delivery",
		"text": """[b]Ler o relatório[/b]
[code]int entregas[3];[/code]
[code]entregas = get_deliveries();[/code]
A função devolve um array com três posições: [code][0][/code] normal, [code][1][/code] expressa e [code][2][/code] VIP.

[b]Declarar os lucros[/b]
[code]declare_profit(lucros);[/code]
A função recebe um array com três lucros, na mesma ordem das categorias.

[b]Regra do lucro[/b]
Se [code]L(n)[/code] é o lucro de [code]n[/code] entregas e [code]b[/code] é o valor-base da categoria, a regra é:
[code]L(0) = 0[/code]
[code]L(n) = 2 * L(n - 1) + b[/code]

Normal usa [code]b = 2[/code], expressa usa [code]b = 4[/code] e VIP usa [code]b = 7[/code]. A forma direta equivalente é [code]L(n) = b * (2^n - 1)[/code], mas ela serve apenas para conferir o resultado: a solução aprovada precisa usar a relação recursiva acima.

[b]Esperar sem travar[/b]
Use [code]await(segundos)[/code] entre uma declaração e a próxima leitura. O jogo controla o intervalo real: diminuir a espera não cria relatórios nem recompensas mais rápido.

[b]Cuidado[/b]
Trocar a ordem do array muda a categoria declarada. Uma resposta rejeitada não encerra o relatório: revise o cálculo e tente novamente.""",
		"hint": "Confira primeiro o caso de zero entregas. Depois observe como o resultado anterior participa do próximo passo."
	},
	{
		"id": "recursion_delivery",
		"title": "Recursão",
		"category": "Delivery Online",
		"requirement": "delivery",
		"text": """[b]Resolver uma versão menor[/b]
Uma função recursiva chama a si mesma para resolver uma parte menor do mesmo problema. No Delivery, [code]L(n)[/code] usa [code]L(n - 1)[/code]: cada chamada trabalha com uma entrega a menos.

[b]Saber quando parar[/b]
Toda recursão precisa de um caso-base. Aqui, zero entregas produz lucro zero e encerra as chamadas.

[b]O que o Delivery observa[/b]
Não basta deixar uma função recursiva escrita no editor. Ela precisa participar do cálculo do relatório, usar [code]if[/code] para reconhecer o caso-base e encerrar as chamadas. O programa também precisa usar [code]for[/code] ou [code]while[/code] para processar as três categorias.

[b]Cuidado[/b]
Se a entrada não se aproxima do caso-base, as chamadas continuam até o limite de segurança.""",
		"hint": "Antes da chamada recursiva, responda: qual entrada encerra o cálculo e qual entrada vem logo antes da atual?"
	}
]
