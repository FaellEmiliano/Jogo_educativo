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
Alguns pedidos aceitam uma resposta simples. Outros esperam mais de um valor, como quando aparece pagamento ou troco.

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
Preste atenção na fala do cliente: ela indica quais números fazem parte da compra e qual tipo de resposta ele espera receber.

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
Esse cliente informa os itens da compra e também quanto pagou. A loja precisa responder considerando a compra e o dinheiro entregue.

[b]Fim dos produtos[/b]
Alguns pedidos usam [code]-1[/code] para avisar que a lista de produtos acabou. Depois disso, ainda pode existir outra informação importante.

[b]Cuidado[/b]
O [code]-1[/code] não é produto. Ele só marca uma mudança de parte no pedido.""",
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
Algumas compras recebem desconto quando passam de um valor mínimo. O cliente não precisa pedir: é uma regra da loja.

[b]Quando observar[/b]
Confira o total da compra antes de pensar no desconto. O limite só faz sentido depois que a compra inteira foi considerada.

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
Clientes de estoque mandam as informações em pares: primeiro vem o preço, depois a quantidade daquele produto. Nesses casos, o preço sozinho não conta a compra inteira.

[b]Bônus de prateleira cheia[/b]
Com tudo cheio, cada cliente paga 1.5x. Se vender algum item, o bônus cai até você repor de novo.

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
Se o pedido de compra tiver formato estranho, passar do limite do item ou faltar dinheiro, o terminal avisa que algo não completou.

[b]Cuidado[/b]
A ordem do array é a ordem da prateleira. Se uma posição estiver errada, você compra o produto errado.""",
		"hint": "Compare o que já tem com o limite da prateleira antes de escolher quanto comprar."
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
	}
]
