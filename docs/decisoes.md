# Decisões de modelagem e limitações conhecidas

## Aderência ao enunciado

Esta versão foi ajustada para cumprir os requisitos do PjBL2. As restrições da proposta anterior que proibiam `data`, `type`, records, módulos e bibliotecas não podem ser mantidas: o PDF exige tipos algébricos e records, permite a organização em módulos e pede funções de bibliotecas padrão, como `sortBy`, `comparing`, `Down` e `readMaybe`.

Também não adotamos a proposta de modelar somente os playoffs de eliminação. Ela não cobre o formato de tabela, o empate 0–0 e os casos de classificação empatada exigidos pelo trabalho. O escopo escolhido é uma fase classificatória fictícia de CS2, adequada às três camadas e aos testes obrigatórios.

| Proposta anterior | Ajuste para atender ao PDF |
|---|---|
| Proibir `type`, `data`, records e módulos | Usar `Time`, `Resultado`, `Partida`, `Linha` e `Erro` com os tipos pedidos; separar em módulos ou seções. |
| Representar resultado por `Bool` e estruturas por tuplas | Usar o tipo soma `Resultado` e records nomeados, evitando estados ambíguos e trocas de campos. |
| Usar apenas o Prelude e implementar ordenação própria | Usar apenas a biblioteca padrão `base` e ordenar com `sortBy`, `comparing`, `Down` e `(<>)`. |
| Criar um conversor numérico próprio | Usar `readMaybe`; entradas malformadas retornam um erro em vez de lançar exceção. |
| Fazer somente playoffs sem empate | Modelar uma tabela classificatória com empate, incluindo o caso 0–0 exigido. |

## Formato do campeonato

O programa representa um campeonato didático de seis equipes e cinco rodadas, com uma partida por equipe em cada rodada. Alguns confrontos se repetem em rodadas diferentes. São três partidas por rodada e quinze no total. O programa demonstra a classificação final e a classificação até a terceira rodada.

A temática é CS2, mas os placares são inteiros genéricos usados para exercitar pontos, saldo, maior diferença e média. Os campos `golsMandante` e `golsVisitante` preservam a interface do enunciado. O empate 0–0 é uma simplificação acadêmica obrigatória; não representa uma regra oficial de uma série de CS2 nem um playoff real.

Os dados de teste incluem o empate 0–0 entre G2 e MOUZ, a vitória de FURIA por 13–3 contra G2 e o empate em pontos entre NAVI e Vitality na classificação final. NAVI fica à frente pelo saldo: ambos têm seis pontos e duas vitórias, mas NAVI tem saldo +3 e Vitality, +2.

## Tipos e funções

- `type Time = String` representa o nome de uma equipe.
- `Resultado` é o tipo soma `Vitoria | Empate | Derrota`.
- `Partida` é um record com rodada, mandante, placar do mandante, placar do visitante e visitante.
- `Linha` é um record com equipe, jogos, vitórias, empates, derrotas, placar a favor e contra.
- `Erro` é um tipo soma com os construtores mínimos exigidos: `CamposInvalidos`, `NumeroInvalido`, `PlacarNegativo`, `MesmoTime` e `TimeRepetidoNaRodada`. `RodadaInvalida` é um caso adicional.

A camada de classificação usa as funções requeridas pelo PDF. Vitória vale 3 pontos, empate 1 e derrota 0. A ordem é: pontos, vitórias, saldo, placar a favor e nome da equipe em ordem alfabética, comparado sem diferenciar maiúsculas e minúsculas. A implementação usa `map`, `filter`, `foldl'`, composição, `sortBy`, `comparing`, `Down` e `(<>)`; não implementa uma ordenação própria.

A camada de leitura usa `readMaybe`, `Either`, notação `do` e `traverse`. `lerCampeonato` interrompe no primeiro erro e `todosOsErros` reúne os problemas encontrados. Linhas em branco e comentários iniciados por `#` são ignorados. `Maybe` representa resultados que podem não existir, como a maior goleada ou a média em uma lista vazia.

## Organização e testes

A entrega modular contém `src/Tipos.hs`, `src/Classificacao.hs`, `src/Leitura.hs`, `src/Dados.hs`, `src/Main.hs`, `tests/Testes.hs`, este documento e um README. A versão de arquivo único organiza o mesmo código em seções comentadas para uso em playground; a escolha do ambiente de execução deve ser informada na entrega.

Os testes cobrem as três camadas, a classificação completa conferida manualmente, o desempate por saldo, a classificação até a terceira rodada, listas vazias, entrada válida, cada construtor de erro e um relatório com várias linhas inválidas.

## Limitações conhecidas

- O programa modela somente a fase classificatória; não implementa Swiss, playoffs, séries MD3/MD5, overtime ou regras oficiais de Major.
- O placar é um inteiro genérico e não é validado como placar possível de um mapa ou série real.
- Só são listadas equipes que aparecem em alguma partida; não há cadastro separado de equipes sem jogos.
- O desempate alfabético final é uma convenção didática, não uma regra oficial de competição.
- Os dados ficam embutidos no código para que o programa funcione em ambientes sem entrada pelo teclado.
