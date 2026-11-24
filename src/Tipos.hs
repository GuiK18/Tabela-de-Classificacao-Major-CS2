module Tipos
  ( Time
  , Resultado(..)
  , Partida(..)
  , Linha(..)
  , participou
  , resultadoPara
  , times
  ) where

import Data.Char (toLower)
import Data.List (nub, sortOn)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Eq, Show)

data Partida = Partida
  { rodada         :: Int
  , mandante       :: Time
  , golsMandante   :: Int
  , golsVisitante  :: Int
  , visitante      :: Time
  } deriving (Eq, Show)

data Linha = Linha
  { linhaTime  :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Eq, Show)

participou :: Time -> Partida -> Bool
participou time partida = time == mandante partida || time == visitante partida

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara time partida
  | time == mandante partida = Just (compararPlacar (golsMandante partida) (golsVisitante partida))
  | time == visitante partida = Just (compararPlacar (golsVisitante partida) (golsMandante partida))
  | otherwise = Nothing

compararPlacar :: Int -> Int -> Resultado
compararPlacar golsTime golsAdversario
  | golsTime > golsAdversario = Vitoria
  | golsTime == golsAdversario = Empate
  | otherwise = Derrota

times :: [Partida] -> [Time]
times partidas = sortOn (map toLower) (nub participantes)
  where
    participantes = concatMap equipesDaPartida partidas
    equipesDaPartida partida = [mandante partida, visitante partida]
