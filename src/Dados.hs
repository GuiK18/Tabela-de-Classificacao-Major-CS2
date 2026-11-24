module Dados (dadosCampeonato, campeonatoTeste) where

import Tipos (Partida)
import Leitura (lerCampeonato)


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

campeonatoTeste :: [Partida]
campeonatoTeste = case lerCampeonato dadosCampeonato of
  Right partidas -> partidas
  Left _ -> []
