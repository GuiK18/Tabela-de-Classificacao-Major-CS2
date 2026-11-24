-- Cole este arquivo inteiro no editor e pressione Run.

import Data.Char (isSpace, toLower)
import Data.List (dropWhileEnd, foldl', intercalate, nub, sortOn, sortBy)
import Data.Ord (Down(..), comparing)
import Text.Read (readMaybe)

-- ===== Tipos =====
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

-- ===== Classificacao =====
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
           , golsPro = golsPro linha + pro
           , golsContra = golsContra linha + contra
           }

placarDoTime :: Time -> Partida -> (Int, Int)
placarDoTime time partida
  | time == mandante partida = (golsMandante partida, golsVisitante partida)
  | otherwise = (golsVisitante partida, golsMandante partida)

contabilizarResultado :: Resultado -> (Int, Int, Int)
contabilizarResultado Vitoria = (1, 0, 0)
contabilizarResultado Empate = (0, 1, 0)
contabilizarResultado Derrota = (0, 0, 1)

pontosLinha :: Linha -> Int
pontosLinha linha = 3 * vitorias linha + empates linha

saldo :: Linha -> Int
saldo linha = golsPro linha - golsContra linha

aproveitamento :: Linha -> Double
aproveitamento linha
  | jogos linha == 0 = 0
  | otherwise = fromIntegral (pontosLinha linha) / fromIntegral (3 * jogos linha) * 100

classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy comparar linhas
  where
    linhas = map (linhaDoTime partidas) (times partidas)
    -- Só consultamos o critério seguinte quando o anterior dá empate.
    comparar = comparing (Down . pontosLinha)
      <> comparing (Down . vitorias)
      <> comparing (Down . saldo)
      <> comparing (Down . golsPro)
      <> comparing (map toLower . linhaTime)

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada limite partidas = filter dentroDoLimite partidas
  where
    dentroDoLimite partida = rodada partida <= limite

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldl' escolher Nothing
  where
    escolher :: Maybe Partida -> Partida -> Maybe Partida
    escolher Nothing partida = Just partida
    escolher (Just atual) candidata
      | diferenca candidata > diferenca atual = Just candidata
      | otherwise = Just atual
    diferenca :: Partida -> Int
    diferenca partida = abs (golsMandante partida - golsVisitante partida)

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols partidas = Just (fromIntegral total / fromIntegral quantidade)
  where
    total = sum [golsMandante jogo + golsVisitante jogo | jogo <- partidas]
    quantidade = length partidas

-- ===== Leitura =====
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

-- Cada linha produz uma partida ou pelo menos um erro.
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

-- ===== Dados =====
-- Campeonato ficticio para fins didaticos. Os placares sao pontos de uma serie
-- simplificada; o empate foi mantido para atender ao exercicio da disciplina.
dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;mandante;placar mandante;placar visitante;visitante"
  , "1;FURIA;13;7;NAVI"
  , "1;Vitality;13;9;FaZe"
  , "1;G2;0;0;MOUZ"
  , "2;FURIA;13;10;Vitality"
  , "2;NAVI;13;4;G2"
  , "2;MOUZ;13;8;FaZe"
  , "3;FURIA;13;3;G2"
  , "3;MOUZ;13;8;NAVI"
  , "3;FaZe;13;11;Vitality"
  , "4;MOUZ;13;11;FURIA"
  , "4;NAVI;13;6;FaZe"
  , "4;Vitality;13;7;G2"
  , "5;FURIA;13;8;FaZe"
  , "5;MOUZ;13;10;Vitality"
  , "5;G2;13;11;NAVI"
  ]

-- Lemos a tabela de exemplo pelo mesmo caminho usado para qualquer entrada.
campeonatoTeste :: [Partida]
campeonatoTeste = case lerCampeonato dadosCampeonato of
  Right partidas -> partidas
  Left _ -> []

-- ===== Main =====
main :: IO ()
main = do
  putStrLn "=== CS2 Major simplificado: tabela final ==="
  let tabelaFinal = classificacao campeonatoTeste
  putStrLn (tabelaFormatada tabelaFinal)

  putStrLn "\n=== Classificacao ao fim da rodada 3 ==="
  putStrLn (tabelaFormatada (classificacao (ateRodada 3 campeonatoTeste)))

  putStrLn "\n=== Estatisticas do campeonato ==="
  putStrLn ("Maior diferenca de placar: " ++ mostrarGoleada (maiorGoleada campeonatoTeste))
  putStrLn ("Media da soma dos placares por serie: " ++ mostrarMedia (mediaGols campeonatoTeste))
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

mostrarGoleada :: Maybe Partida -> String
mostrarGoleada Nothing = "nenhuma partida"
mostrarGoleada (Just partida) = mandante partida ++ " " ++ show (golsMandante partida)
  ++ " x " ++ show (golsVisitante partida) ++ " " ++ visitante partida

mostrarMedia :: Maybe Double -> String
mostrarMedia = maybe "sem partidas" show

mostrarAproveitamento :: Maybe Linha -> String
mostrarAproveitamento Nothing = "0% (sem times)"
mostrarAproveitamento (Just linha) = show (aproveitamento linha) ++ "%"

headSegura :: [a] -> Maybe a
headSegura [] = Nothing
headSegura (x:_) = Just x
