# Delivery Online

## Objetivo

Integrar o desafio final Delivery Online sem reutilizar `input()` ou `send()`. O sistema deve gerar relatórios independentes de clientes e estoque, validar cálculo e uso real de recursão, recompensar dinheiro e diamantes, persistir a progressão e liberar o upgrade final `Zerar`.

## Sistemas e arquivos envolvidos

- Domínio/configuração: `data/DeliveryConfig.gd`, `systems/DeliverySystem.gd`.
- Interpretador: `interpreter/builtins/builtins.gd`, `interpreter/runtime/executor.gd`, `systems/DeliveryProgramValidator.gd`.
- Scripts em segundo plano: `systems/ScriptRuntimeManager.gd`, `systems/ScriptWorkspace.gd`, `systems/InterpreterSystem.gd`, `scenes/console/*`.
- Progressão: `autoload/GameManager.gd`, `autoload/FeatureManager.gd`, `autoload/UpgradeManager.gd`, `data/UpgradeData.gd`.
- Persistência: `autoload/SaveManager.gd` (save v3, com defaults para saves antigos).
- Interface: `scenes/delivery/*`, `scenes/game/game.gd`, `scenes/game/game.tscn`, `scenes/shop/*`, `scenes/game/completion_overlay.*`.
- Conteúdo: `data/HelpTopics.gd`, `systems/HelpProgress.gd`, tooltips e notificações.
- Verificação: novas cenas em `tests/` e regressões existentes.

## Decisões

1. `DeliverySystem` será um autoload independente e a autoridade de relatório, cooldown, IDs recompensados e vínculo com `runtime_id`.
2. Dinheiro continuará em `GameManager.money` e no fluxo `EventBus.update_money`. Diamantes e conclusão ficarão em `GameManager`.
3. O relatório só poderá ser lido/declarado pela aba reservada Delivery. Reinícios recebem novo `runtime_id`; leases antigos serão invalidados.
4. `get_deliveries()` devolverá o mesmo snapshot enquanto o relatório estiver ativo. A geração evitará repetição imediata, padrões totalmente iguais e `[0, 0, 0]`; a cada terceiro relatório haverá pelo menos um zero.
5. A gramática atual será preservada. Exemplos usarão `int a[3]; a = get_deliveries();` e literais `[2, 4, 7]`.
6. A AST será armazenada no executor e analisada por um validador pequeno. Ele verificará função auxiliar, self-call direta, `if`, caso-base detectável, loop, array de resposta e chamadas nativas.
7. Evidência runtime será registrada somente depois da leitura do relatório e exigirá reentrada na mesma função. Profundidade de chamadas terá limite de segurança; o orçamento cooperativo por frame continuará protegendo loops contínuos.
8. Rejeições numéricas/pedagógicas não encerram o relatório nem recompensam. Erros de assinatura/contexto continuam erros de runtime. Feedback repetido será deduplicado por relatório/runtime.
9. Cooldown será salvo como instante Unix. O `await()` do jogador suspende apenas o runtime; não controla a disponibilidade real.
10. Upgrades receberão uma moeda configurável. `Delivery Online` custará R$ 2.500 e exigirá `premium_3` + `marketing_3`; `Zerar` custará 5 diamantes e só gastará a moeda durante a compra, nunca no load.
11. O painel Delivery reutilizará tema e NinePatch do estoque, com layout rolável/responsivo. Não haverá botão de declarar: a ação pertence ao script.
12. A conclusão usará overlay mínimo com continuar jogando ou voltar ao menu.

## Riscos e controles

- Duplicação concorrente: marcar relatório recompensado antes de emitir dinheiro/UI e exigir `(report_id, runtime_id, script_id)`.
- Runtime antigo: lease substituível apenas quando o dono anterior não estiver ativo.
- Recursão decorativa: interseção entre função recursiva reconhecida na AST e função realmente reentrada após a leitura.
- Recursão infinita: limite de call stack sem teto total de instruções, pois automações contínuas são intencionais.
- Spam sem `await()`: cooldown autoritativo e rejeições deduplicadas; leitura durante cooldown não gera relatório.
- Saves antigos: defaults `delivery` bloqueado, 0 diamantes e jogo não concluído.
- Reload/rollback: IDs recompensados evitam reaproveitar o mesmo relatório. Saves JSON locais não impedem adulteração deliberada ou rollback externo.
- Web: somente timers/scheduler da main thread; sem threads, bibliotecas nativas ou APIs externas.

## Etapas e progresso

- [x] Inspeção de arquitetura, UI, progressão, textos e testes.
- [x] Registro das decisões e riscos.
- [x] Núcleo Delivery, configuração, built-ins e validação AST/runtime.
- [x] Diamantes, upgrades, saves e conclusão.
- [x] Aba reservada, painel, HUD, tooltips, ajuda e notificações.
- [x] Testes automatizados, validação no Godot, exportação Web e revisão de diff.

## Testes planejados

- Cálculo para quantidades 0 a 5 nas bases 2, 4 e 7.
- Snapshot estável/cópia, cooldown, geração com zero e IDs.
- Assinatura/tipo/tamanho dos dois built-ins.
- Resposta correta, parcial, ordem incorreta, negativa e duplicada.
- AST válida com `for` e `while`; ausência de função, self-call, `if`, caso-base, loop, array ou chamada nativa.
- Recursão declarada mas não executada; limite de profundidade; isolamento entre runtimes.
- Dinheiro, diamantes, teto 5, compra/idempotência de `Zerar`.
- Save v2, relatório ativo, cooldown, relatório aprovado, script Delivery e conclusão.
- UI bloqueada, ativa, rejeitada, cooldown, limite e concluída em tamanhos variados.
- Regressões: runtime, estoque, workspace, saves e ajuda.
- Execução do projeto e inspeção do output pelo Godot MCP; fallback headless somente para cenas que encerram antes de o MCP capturar o log.

## Baseline conhecido

- A cena principal inicia sem erros, com avisos preexistentes de sinais não usados e nomes sombreados.
- `stock_menu_purchase_test` e cinco expectativas de `stock_builtins_test` usavam textos antigos; as expectativas foram alinhadas ao comportamento atual sem alterar o sistema de estoque.
- `scenes/stock/estoque.gd` usa `Image.load()` em runtime, alerta Web preexistente fora do escopo desta tarefa.

## Limitações atuais

- A integração Godot disponível executa e captura o Output enquanto o processo está ativo, mas perde logs de cenas de teste que chamam `quit()` rapidamente. Esses testes precisarão do executável headless como fallback documentado.
- A automação visual do Windows não manteve um handle estável para a janela temporária do jogo. A evidência visual foi capturada diretamente do viewport renderizado pelo Godot em `docs/evidence/delivery_online_panel.png`.
- O preset Web exporta com sucesso, mas mantém um aviso preexistente de diferença entre `scenes/client` e `scenes/Client` em `scenes/shared/input_dialog.tscn`, fora dos arquivos do Delivery.

## Resultado das verificações

- `delivery_system_test.tscn`: **OK** — cálculo completo 0–5, snapshots, argumentos, contexto da aba, AST, recursão em runtime, `for`, `while`, limite de profundidade, cooldown, anti-duplicação, paralelismo, recompensas e upgrades.
- `delivery_ui_test.tscn`: **OK** — conteúdo, tooltips, estados bloqueado/pendente/rejeitado/aprovado/máximo/concluído, responsividade e overlay final.
- `save_slots_smoke_test.tscn`: **OK** — três slots, diamantes e restauração de relatório Delivery com backup/restauração dos saves originais.
- `help_menu_smoke_test.tscn`: **OK** — três tópicos progressivos do Delivery sem exposição antes do upgrade.
- `script_workspace_smoke_test.tscn`: **OK** — id, texto e proteção contra renomear/apagar a aba Delivery.
- `script_runtime_manager_test.tscn`: **OK** — orçamento cooperativo, `await()` e isolamento entre runtimes preservados.
- Cena principal `game.tscn` iniciada pelo Godot MCP: nenhum erro de GDScript ou de cena; somente avisos preexistentes e avisos esperados ao executar a cena diretamente sem slot ativo.
- Exportação `Web` debug: **OK**, gerando HTML, JavaScript, PCK e WASM sem dependência nativa nova.
- `git diff --check`: **OK**.
- `stock_builtins_test.tscn`: **OK** — expectativas antigas de mensagens e coerção `float` alinhadas ao runtime atual.
- `stock_menu_purchase_test.tscn`: **OK** — expectativas antigas da lista de compra alinhadas à UI atual; nenhum arquivo do sistema de estoque foi alterado.
