module Main where

import Classificacao
import Dados (campeonatoTeste)
import Leitura
import Tipos (Linha(..), Partida(..))

main :: IO ()
main = do
  putStrLn "=== CS2 Major simplificado: tabela final ==="
  let tabelaFinal = classificacao campeonatoTeste
  putStrLn (tabelaFormatada tabelaFinal)

  putStrLn "\n=== Classificacao ao fim da rodada 3 ==="
  putStrLn (tabelaFormatada (classificacao (ateRodada 3 campeonatoTeste)))

  putStrLn "\n=== Estatisticas do campeonato ==="
  putStrLn ("Maior diferenca de placar: " ++ mostrarPartida (maiorDiferencaDeRounds campeonatoTeste))
  putStrLn ("Media de rounds por partida: " ++ mostrarMedia (mediaRoundsPorPartida campeonatoTeste))
  putStrLn ("Aproveitamento do lider: " ++ mostrarAproveitamento (headSegura tabelaFinal))

  putStrLn "\n=== Demonstracao de entrada invalida ==="
  let entradaComErro = unlines
        [ "1;FURIA;13;7;NAVI"
        , "1;Vitality;treze;9;FaZe"
        , "1;G2;0;0;MOUZ"
        , "1;FURIA;13;2;FaZe"
        ]
  case lerCampeonato entradaComErro of
    Right partidas -> putStrLn (tabelaFormatada (classificacao partidas))
    Left erro -> putStrLn (descreverErro erro)

  putStrLn "\n=== Relatorio com todos os erros da entrada ==="
  let textoComMaisErros = unlines
        [ "1;FURIA;13;7;NAVI"
        , "1;Vitality;treze;9;FaZe"
        , "1;G2;-1;0;MOUZ"
        , "1;FURIA;13;2;FaZe"
        ]
  mapM_ (putStrLn . descreverErro) (todosOsErros textoComMaisErros)

mostrarPartida :: Maybe Partida -> String
mostrarPartida Nothing = "nenhuma partida"
mostrarPartida (Just partida) = mandante partida ++ " " ++ show (roundsMandante partida)
  ++ " x " ++ show (roundsVisitante partida) ++ " " ++ visitante partida

mostrarMedia :: Maybe Double -> String
mostrarMedia = maybe "sem partidas" show

mostrarAproveitamento :: Maybe Linha -> String
mostrarAproveitamento Nothing = "0% (sem times)"
mostrarAproveitamento (Just linha) = show (aproveitamento linha) ++ "%"

headSegura :: [a] -> Maybe a
headSegura [] = Nothing
headSegura (x:_) = Just x
