# Tabela de classificação de um Major de CS2

Este é um trabalho de Programação Funcional feito em Haskell. O programa usa os resultados de um campeonato fictício de CS2 para mostrar a tabela final, a classificação após a terceira rodada e algumas estatísticas, como a maior diferença de placar. Também mostra o que acontece quando uma partida tem dados inválidos.

O ambiente escolhido para a entrega é o **GHC local**, usando a versão em módulos da pasta `src/`. Também dá para executar o projeto pelo OnlineGDB.

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

## Rodar com GHC no Windows ou no Linux

Com o GHC instalado, abra o terminal **na mesma pasta deste README**, onde ficam `src/` e `tests/`. Rode `ghc --version` para conferir se o terminal reconhece o compilador.

### Windows (PowerShell)

```powershell
ghc -Wall -isrc src/Main.hs -o cs2-major.exe
.\cs2-major.exe
```

### Linux

```bash
ghc -Wall -isrc src/Main.hs -o cs2-major
./cs2-major
```

A opção `-isrc` indica onde o GHC encontra os módulos. A opção `-Wall` mostra avisos de compilação.

## Rodar no OnlineGDB

1. Acesse o [OnlineGDB para Haskell](https://www.onlinegdb.com/online_haskell_compiler).
2. Abra um projeto Haskell vazio.
3. Cole todo o conteúdo de `playground/Main.hs` no arquivo principal do editor.
4. Clique em **Run**. Os resultados aparecem na área de saída.

## Rodar os testes

Abra o terminal na raiz do projeto e execute os comandos do seu sistema.

**Windows (PowerShell)**

```powershell
ghc -Wall -isrc tests/Testes.hs -o testes.exe
.\testes.exe
```

**Linux**

```bash
ghc -Wall -isrc tests/Testes.hs -o testes
./testes
```

Cada teste mostra `OK` ou `FALHOU`. Os testes conferem a classificação, os desempates e casos de entrada inválida.

## Como o campeonato funciona

O exemplo tem seis equipes e cinco rodadas. Vitória vale 3 pontos, empate vale 1 e derrota vale 0. A tabela segue a ordem de pontos, vitórias, saldo e placar a favor. Se o empate continuar, vale a ordem alfabética.

As partidas ficam em `src/Dados.hs`. Por exemplo, a linha `1;FURIA;13;7;NAVI` representa uma vitória da FURIA por 13 a 7 na primeira rodada. Se estiver usando a versão de arquivo único, procure `dadosCampeonato` em `playground/Main.hs` para alterar os resultados.

As decisões do grupo e as limitações da simulação estão em [docs/decisoes.md](docs/decisoes.md).
