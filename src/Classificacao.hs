module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , classificacao
  , ateRodada
  , maiorDiferencaDeRounds
  , mediaRoundsPorPartida
  ) where

import Data.Char (toLower)
import Data.List (sortBy) 
import Data.Ord (Down(..), comparing)
import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas time = foldl' (acumular time) linhaVazia partidas
  where
    linhaVazia = Linha time 0 0 0 0 0 0

acumular :: Time -> Linha -> Partida -> Linha
acumular time linha partida =
  case resultadoPara time partida of
    Nothing -> linha
    Just resultado ->
      let (pro, contra) = placarDoTime time partida
          (v, e, d) = contabilizarResultado resultado
      in linha
           { jogos = jogos linha + 1
           , vitorias = vitorias linha + v
           , empates = empates linha + e
           , derrotas = derrotas linha + d
           , roundsPro = roundsPro linha + pro
           , roundsContra = roundsContra linha + contra
           }

placarDoTime :: Time -> Partida -> (Int, Int)
placarDoTime time partida
  | time == mandante partida = (roundsMandante partida, roundsVisitante partida)
  | otherwise = (roundsVisitante partida, roundsMandante partida)

contabilizarResultado :: Resultado -> (Int, Int, Int)
contabilizarResultado Vitoria = (1, 0, 0)
contabilizarResultado Empate = (0, 1, 0)
contabilizarResultado Derrota = (0, 0, 1)

pontosLinha :: Linha -> Int
pontosLinha linha = 3 * vitorias linha + empates linha

saldo :: Linha -> Int
saldo linha = roundsPro linha - roundsContra linha

aproveitamento :: Linha -> Double
aproveitamento linha
  | jogos linha == 0 = 0
  | otherwise = fromIntegral (pontosLinha linha) / fromIntegral (3 * jogos linha) * 100

classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy comparar linhas
  where
    linhas = map (linhaDoTime partidas) (times partidas)
    
    comparar = comparing (Down . pontosLinha)
      <> comparing (Down . vitorias)
      <> comparing (Down . saldo)
      <> comparing (Down . roundsPro)
      <> comparing (map toLower . linhaTime)

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada limite partidas = filter dentroDoLimite partidas
  where
    dentroDoLimite partida = rodada partida <= limite

maiorDiferencaDeRounds :: [Partida] -> Maybe Partida
maiorDiferencaDeRounds = foldl' escolher Nothing
  where
    escolher :: Maybe Partida -> Partida -> Maybe Partida
    escolher Nothing partida = Just partida
    escolher (Just atual) candidata
      | diferenca candidata > diferenca atual = Just candidata
      | otherwise = Just atual
    diferenca :: Partida -> Int
    diferenca partida = abs (roundsMandante partida - roundsVisitante partida)

mediaRoundsPorPartida :: [Partida] -> Maybe Double
mediaRoundsPorPartida [] = Nothing
mediaRoundsPorPartida partidas = Just (fromIntegral total / fromIntegral quantidade)
  where
    total = sum [roundsMandante jogo + roundsVisitante jogo | jogo <- partidas]
    quantidade = length partidas
