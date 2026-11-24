module Leitura
  ( Erro(..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  , tabelaFormatada
  , descreverErro
  ) where

import Data.Char (isSpace)
import Data.List (dropWhileEnd, intercalate)
import Text.Read (readMaybe)
import Tipos
import Classificacao (pontosLinha, saldo)

data Erro
  = CamposInvalidos Int Int
  | NumeroInvalido Int String
  | PlacarNegativo Int
  | MesmoTime Int Time
  | TimeRepetidoNaRodada Int Int Time
  | RodadaInvalida Int Int
  deriving (Eq, Show)

separar :: Char -> String -> [String]
separar separador texto =
  case break (== separador) texto of
    (campo, []) -> [campo]
    (campo, _:restante) -> campo : separar separador restante

lerPartida :: Int -> String -> Either Erro Partida
lerPartida numeroLinha texto =
  case map trim (separar ';' texto) of
    [campoRodada, timeCasa, campoCasa, campoVisitante, timeFora]
      | null timeCasa || null timeFora -> Left (CamposInvalidos numeroLinha 5)
      | otherwise -> do
          numeroRodada <- converterNumero numeroLinha campoRodada
          golsCasa <- converterNumero numeroLinha campoCasa
          golsFora <- converterNumero numeroLinha campoVisitante
          if numeroRodada <= 0
            then Left (RodadaInvalida numeroLinha numeroRodada)
            else if golsCasa < 0 || golsFora < 0
              then Left (PlacarNegativo numeroLinha)
              else if timeCasa == timeFora
                then Left (MesmoTime numeroLinha timeCasa)
                else Right (Partida numeroRodada timeCasa golsCasa golsFora timeFora)
    campos -> Left (CamposInvalidos numeroLinha (length campos))

converterNumero :: Int -> String -> Either Erro Int
converterNumero numeroLinha texto =
  case readMaybe texto of
    Just numero -> Right numero
    Nothing -> Left (NumeroInvalido numeroLinha texto)

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = traverse primeiroResultado (validarLinhas texto)
  where
    primeiroResultado (Right partida) = Right partida
    primeiroResultado (Left (erro, _)) = Left erro

todosOsErros :: String -> [Erro]
todosOsErros texto = concat [erro : outros | Left (erro, outros) <- validarLinhas texto]

validarLinhas :: String -> [Either (Erro, [Erro]) Partida]
validarLinhas texto = conferir [] (zip [1..] (lines texto))
  where
    conferir _ [] = []
    conferir anteriores ((numero, linha) : restantes)
      | linhaIgnoravel linha = conferir anteriores restantes
      | otherwise = case lerPartida numero linha of
          Left erro -> Left (erro, []) : conferir anteriores restantes
          Right partida ->
            let mesmaRodada = filter (\jogo -> rodada jogo == rodada partida) anteriores
                conflitos = [TimeRepetidoNaRodada numero (rodada partida) time
                            | time <- [mandante partida, visitante partida]
                            , any (participou time) mesmaRodada]
                resultado = case conflitos of
                  [] -> Right partida
                  erro : outros -> Left (erro, outros)
            in resultado : conferir (partida : anteriores) restantes

linhaIgnoravel :: String -> Bool
linhaIgnoravel texto = null semEspacos || take 1 semEspacos == "#"
  where
    semEspacos = dropWhile isSpace texto

trim :: String -> String
trim texto = dropWhileEnd isSpace (dropWhile isSpace texto)

descreverErro :: Erro -> String
descreverErro erro = case erro of
  CamposInvalidos linha quantidade ->
    "Linha " ++ show linha ++ ": esperava 5 campos separados por ';', encontrei " ++ show quantidade ++ "."
  NumeroInvalido linha valor ->
    "Linha " ++ show linha ++ ": '" ++ valor ++ "' nao e um numero valido."
  PlacarNegativo linha ->
    "Linha " ++ show linha ++ ": o placar nao pode conter valores negativos."
  MesmoTime linha time ->
    "Linha " ++ show linha ++ ": " ++ time ++ " nao pode jogar contra si mesmo."
  TimeRepetidoNaRodada linha numeroRodada time ->
    "Linha " ++ show linha ++ ": " ++ time ++ " ja aparece em outra partida da rodada " ++ show numeroRodada ++ "."
  RodadaInvalida linha numeroRodada ->
    "Linha " ++ show linha ++ ": a rodada deve ser positiva; recebido " ++ show numeroRodada ++ "."

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = intercalate "\n" (cabecalho : map formatarLinha numeradas)
  where
    cabecalho = intercalate " | "
      [alinharDireita 3 "Pos", alinharEsquerda 12 "Time", alinharDireita 3 "Pts"
      ,alinharDireita 3 "J", alinharDireita 3 "V", alinharDireita 3 "E"
      ,alinharDireita 3 "D", alinharDireita 4 "SG"]
    numeradas = zip ([1..] :: [Int]) linhas
    formatarLinha (posicao, linha) = intercalate " | "
      [alinharDireita 3 (show posicao), alinharEsquerda 12 (linhaTime linha)
      ,alinharDireita 3 (show (pontosLinha linha)), alinharDireita 3 (show (jogos linha))
      ,alinharDireita 3 (show (vitorias linha)), alinharDireita 3 (show (empates linha))
      ,alinharDireita 3 (show (derrotas linha)), alinharDireita 4 (show (saldo linha))]

alinharEsquerda :: Int -> String -> String
alinharEsquerda largura texto = take largura (texto ++ replicate largura ' ')

alinharDireita :: Int -> String -> String
alinharDireita largura texto = replicate (max 0 (largura - length texto)) ' ' ++ texto
