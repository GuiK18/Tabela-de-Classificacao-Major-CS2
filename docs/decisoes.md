# Decisões do projeto

## Como montamos o campeonato

Escolhemos o tema de Major de CS2 e criamos uma fase classificatória fictícia com seis equipes, cinco rodadas e 15 partidas. Cada equipe joga uma vez por rodada. Alguns confrontos se repetem em rodadas diferentes.

A pontuação é simples: vitória vale 3 pontos, empate vale 1 e derrota vale 0. Mantivemos um empate em 0 × 0 entre G2 e MOUZ para cobrir o caso pedido no trabalho.

## Como representamos os dados

Usamos `Time` como um nome para `String` e criamos o tipo `Resultado` com três opções: `Vitoria`, `Empate` e `Derrota`. A função `resultadoPara` devolve `Nothing` se a equipe não participou da partida.

`Partida` e `Linha` são registros com campos nomeados. Isso ajuda a distinguir valores do mesmo tipo, como o placar do mandante e o do visitante. `Partida` guarda os dados de um jogo, enquanto `Linha` guarda os totais de uma equipe na tabela.

## Como calculamos a tabela

Usamos `foldl'` para percorrer as partidas e atualizar os totais de cada equipe. A cada jogo, somamos o resultado e os placares a favor e contra. Para ver a tabela até a terceira rodada, filtramos as partidas primeiro e aplicamos o mesmo cálculo.

A tabela é ordenada por pontos, vitórias, saldo e placar a favor. Se o empate continuar, usamos a ordem alfabética. No exemplo, NAVI e Vitality terminam com 6 pontos e 2 vitórias cada. A NAVI fica na frente porque tem saldo de +3, enquanto a Vitality tem +2.

Usamos `Maybe` nas funções de média e maior diferença de placar. Se a lista estiver vazia, as duas retornam `Nothing`, porque não há partidas para comparar nem placares para calcular a média.

## Como tratamos a entrada

As partidas de exemplo ficam como texto em `src/Dados.hs`. Cada linha tem os dados de uma partida separados por ponto e vírgula. Linhas em branco e comentários que começam com `#` são ignorados.

Usamos `readMaybe` para converter os números. Assim, um placar escrito como `treze` vira um erro de leitura. `lerCampeonato` usa `Either` para retornar as partidas ou o primeiro erro na ordem das linhas. Já `todosOsErros` percorre a entrada inteira e reúne os problemas encontrados.

Deixamos o cálculo e a validação em funções puras. O `main` usa essas funções para mostrar a tabela, as estatísticas e exemplos de erros. Isso também permite testar o cálculo separado da saída no terminal.

## Limitações

- O projeto cobre a fase classificatória. Fases suíças, playoffs, séries MD3 e MD5 e prorrogação ficam fora da simulação.
- Os placares são simplificados. A validação verifica o formato e rejeita valores negativos, mas aceita placares que podem não ocorrer em um mapa real de CS2.
- A tabela inclui as equipes que aparecem nas partidas. Uma equipe sem jogos registrados não aparece na classificação.
- O relatório pode apontar erros em várias linhas. Se uma única linha tiver mais de um campo inválido, a leitura dessa linha aponta o primeiro problema encontrado.
