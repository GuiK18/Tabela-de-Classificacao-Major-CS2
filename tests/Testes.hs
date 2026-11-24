module Main where

import Classificacao
import Dados (campeonatoTeste, dadosCampeonato)
import Leitura
import Tipos

main :: IO ()
main = do
  putStrLn "--- Camada 1 ---"
  testar "mandante vence" (resultadoPara "FURIA" partidaExemplo) (Just Vitoria)
  testar "visitante perde" (resultadoPara "NAVI" partidaExemplo) (Just Derrota)
  testar "empate 0 a 0" (resultadoPara "G2" (Partida 1 "G2" 0 0 "MOUZ")) (Just Empate)
  testar "time que nao jogou retorna Nothing" (resultadoPara "MOUZ" partidaExemplo) Nothing
  testar "participacao" (participou "NAVI" partidaExemplo) True
  testar "times sem repeticao e em ordem alfabetica"
    (times campeonatoTeste) ["FaZe", "FURIA", "G2", "MOUZ", "NAVI", "Vitality"]

  putStrLn "\n--- Camada 2 ---"
  let tabelaFinal = classificacao campeonatoTeste
      tabelaRodada3 = classificacao (ateRodada 3 campeonatoTeste)

  testar "classificacao final conferida" (map linhaTime tabelaFinal)
    ["MOUZ", "FURIA", "NAVI", "Vitality", "G2", "FaZe"]
  testar "estatisticas completas da classificacao final" tabelaFinal
    [ Linha "MOUZ" 5 4 1 0 52 37
    , Linha "FURIA" 5 4 0 1 63 41
    , Linha "NAVI" 5 2 0 3 52 49
    , Linha "Vitality" 5 2 0 3 57 55
    , Linha "G2" 5 1 1 3 27 50
    , Linha "FaZe" 5 1 0 4 44 63
    ]
  testar "empate em pontos decidido pelo saldo"
    (map saldo (take 2 (drop 2 tabelaFinal))) [3, 2]
  testar "classificacao apos rodada 3 e diferente da final"
    (map linhaTime tabelaRodada3 /= map linhaTime tabelaFinal) True
  testar "maior diferenca de rounds em lista vazia"
    (maiorDiferencaDeRounds []) Nothing
  testar "maior diferenca de rounds do campeonato"
    (maiorDiferencaDeRounds campeonatoTeste) (Just (Partida 3 "FURIA" 13 3 "G2"))
  testar "media de rounds em lista vazia"
    (mediaRoundsPorPartida []) Nothing
  testar "media de rounds por partida"
    (mediaRoundsPorPartida campeonatoTeste) (Just (295 / 15))
  testar "pontuacao de vitoria, empate e derrota"
    (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "aproveitamento sem jogos" (aproveitamento (linhaDoTime [] "Time novo")) 0.0

  putStrLn "\n--- Camada 3 ---"
  testar "entrada valida" (lerCampeonato dadosCampeonato == Right campeonatoTeste) True
  testar "CamposInvalidos" (ehErro isCampos (lerPartida 1 "1;FURIA;13;NAVI")) True
  testar "NumeroInvalido" (ehErro isNumero (lerPartida 1 "1;FURIA;dois;7;NAVI")) True
  testar "PlacarNegativo" (ehErro isNegativo (lerPartida 1 "1;FURIA;-1;7;NAVI")) True
  testar "MesmoTime" (ehErro isMesmoTime (lerPartida 1 "1;FURIA;13;7;FURIA")) True
  testar "TimeRepetidoNaRodada"
    (ehErro isRepetido (lerCampeonato "1;FURIA;13;7;NAVI\n1;FURIA;13;3;G2\n")) True
  testar "RodadaInvalida" (ehErro isRodada (lerPartida 1 "0;FURIA;13;7;NAVI")) True
  testar "todosOsErros encontra tres linhas invalidas"
    (todosOsErros "1;FURIA;xx;7;NAVI\n1;G2;-1;0;MOUZ\n1;NAVI;1;1;NAVI\n")
    [NumeroInvalido 1 "xx", PlacarNegativo 2, MesmoTime 3 "NAVI"]
  testar "duplicidade antes de um erro de leitura"
    (lerCampeonato "1;A;1;0;B\n1;A;2;0;C\n2;A;x;0;B")
    (Left (TimeRepetidoNaRodada 2 1 "A"))
  testar "comentarios e linhas em branco sao ignorados"
    (lerCampeonato "\n# comentario\n1;FURIA;13;7;NAVI\n" == Right [partidaExemplo]) True
  testar "entrada vazia produz campeonato vazio"
    (lerCampeonato "  \n# nada\n") (Right [])

partidaExemplo :: Partida
partidaExemplo = Partida 1 "FURIA" 13 7 "NAVI"

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK: " ++ nome)
  | otherwise = putStrLn ("FALHOU: " ++ nome ++ " | obtido: " ++ show obtido
      ++ " | esperado: " ++ show esperado)

ehErro :: (Erro -> Bool) -> Either Erro a -> Bool
ehErro predicado resultado = case resultado of
  Left erro -> predicado erro
  Right _ -> False

isCampos, isNumero, isNegativo, isMesmoTime, isRepetido, isRodada :: Erro -> Bool
isCampos (CamposInvalidos _ _) = True
isCampos _ = False
isNumero (NumeroInvalido _ _) = True
isNumero _ = False
isNegativo (PlacarNegativo _) = True
isNegativo _ = False
isMesmoTime (MesmoTime _ _) = True
isMesmoTime _ = False
isRepetido (TimeRepetidoNaRodada _ _ _) = True
isRepetido _ = False
isRodada (RodadaInvalida _ _) = True
isRodada _ = False
