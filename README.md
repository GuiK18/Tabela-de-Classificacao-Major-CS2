# CS2 Major Simplificado em Haskell

Projeto academico para calcular a classificacao de um campeonato ficticio de CS2, organizado nas tres camadas exigidas no enunciado.

## Ambiente

Ambiente de desenvolvimento escolhido: GHC no Haskell Playground (play.haskell.org). O projeto usa apenas a biblioteca padrao `base`, sem dependencias externas. Os dados de demonstracao ficam no proprio programa, entao `main` nao depende de teclado nem de arquivo externo.

## Estrutura

```text
projeto/
├── src/
│   ├── Tipos.hs
│   ├── Classificacao.hs
│   ├── Leitura.hs
│   ├── Dados.hs
│   └── Main.hs
├── tests/
│   └── Testes.hs
├── docs/
│   └── decisoes.md
└── README.md
```

## Compilar e executar

No OnlineGDB, use um projeto Haskell vazio e copie apenas o conteúdo de playground/Main.hs para o editor.

Como alternativa, na pasta `cs2-major-simplificado/`, com GHC local instalado:

```bash
ghc -Wall -isrc src/Main.hs -o cs2-major
./cs2-major
```

No Windows, execute `cs2-major.exe` depois de compilar.

## Usar no Haskell Playground

O Playground recebe um unico arquivo por vez. Para executar sem instalar o GHC:

1. Abra `playground/Main.hs` neste projeto e copie todo o conteudo.
2. Acesse [play.haskell.org](https://play.haskell.org), substitua o conteudo do editor pelo codigo copiado e pressione **Run**.
3. O arquivo unico mostra a demonstracao do campeonato; os testes ficam em tests/Testes.hs para execução separada.

Essa versao junta os modulos em um arquivo e preserva as mesmas funcoes. O ZIP continua contendo tambem a versao modular usada para compilar localmente.

## Executar os testes

```bash
ghc -Wall -isrc tests/Testes.hs -o testes
./testes
```

Cada teste imprime `OK` ou `FALHOU`, incluindo os erros de leitura e a classificacao conferida manualmente.

## Regras simplificadas

- Seis equipes jogam cinco rodadas, uma partida por equipe em cada rodada.
- Vitoria vale 3 pontos; empate vale 1; derrota vale 0.
- Desempate: pontos, vitorias, saldo, placar a favor e nome alfabetico.
- O empate 0 a 0 existe para cumprir o caso pedido no trabalho. E uma simplificacao academica, nao uma regra real do CS2.

Veja `docs/decisoes.md` para as escolhas de modelagem e limitacoes.
