       COPY DSLANG.CPY.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LBP102.
       AUTHOR. MARELI AMANCIO VOLPATO.
       DATE-WRITTEN. 29/05/2000.
      *FUNÇÃO: Movimento de AVALIAÇÃO DE NEGATIVOS

       ENVIRONMENT DIVISION.
       class-control.
           Window             is class "wclass".
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY COPX040.
           COPY CGPX001.
           COPY LBPX021.
           COPY LBPX024.
           COPY LBPX025.
           COPY LBPX102.
           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.

       DATA DIVISION.
       FILE SECTION.
       COPY COPW040.
       COPY CGPW001.
       COPY LBPW021.
       COPY LBPW024.
       COPY LBPW025.
       COPY LBPW102.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(130).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "LBP102.CPB".
           COPY "LBP102.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBDATA.CPY".
           COPY "CBPRINT.CPY".
           COPY "CPADAY1.CPY".
           COPY "CPTIME.CPY".
           COPY "CPDCIC.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  PASSAR-PARAMETROS.
           05  PASSAR-STRING-1       PIC X(60).
       01  VARIAVEIS.
           05  ST-COD040             PIC XX       VALUE SPACES.
           05  ST-CGD001             PIC XX       VALUE SPACES.
           05  ST-LBD021             PIC XX       VALUE SPACES.
           05  ST-LBD024             PIC XX       VALUE SPACES.
           05  ST-LBD025             PIC XX       VALUE SPACES.
           05  ST-LBD102             PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
      *    ERRO-W - flag que controla se houve erro de abertura arquivo
           05  ULT-SEQ               PIC 9(3)     VALUE ZEROS.
           05  HORA-W                PIC 9(8)     VALUE ZEROS.
           05  LIN                   PIC 9(2)     VALUE ZEROS.
           05  PAGE-COUNT                 PIC 9(2)     VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-MOVTO-I          PIC 9(8)     VALUE ZEROS.

           05  DATA-DIA-I            PIC 9(8)     VALUE ZEROS.
           COPY "PARAMETR".

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.

       01  CAB01.
           05  EMPRESA-REL         PIC X(60)   VALUE SPACES.
           05  FILLER              PIC X(13)   VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE "PAG: ".
           05  PAG-REL             PIC Z9      VALUE ZEROS.
       01  CAB02.
           05  FILLER              PIC X(39)   VALUE
           "CONFERENCIA-MOVTO AVALIACAO NEGAT".
           05  FILLER              PIC X(07)   VALUE "MOVTO: ".
           05  DATA-MOVTO-REL      PIC 99/99/9999 VALUE ZEROS.
           05  FILLER              PIC X(07)   VALUE SPACES.
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC XX      VALUE SPACES.
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
       01  CAB03.
           05  FILLER              PIC X(80)   VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(80)   VALUE
           "SEQ CONT FOTOGR-NOME       TP-DESCRICAO  FIL-PRO FOT-PRO TIP
      -    "-MOMENTO    TIP-PROB".

       01  LINDET.
           05  LINDET-REL          PIC X(80)   VALUE SPACES.
       LINKAGE SECTION.
       PROCEDURE DIVISION.
       MAIN-PROCESS SECTION.
           PERFORM INICIALIZA-PROGRAMA.
           PERFORM CORPO-PROGRAMA UNTIL GS-EXIT-FLG-TRUE.
           GO FINALIZAR-PROGRAMA.
       INICIALIZA-PROGRAMA SECTION.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           COPY "CBDATA1.CPY".
           MOVE DATA-INV TO DATA-MOVTO-W DATA-MOVTO-REL.
           CALL "GRIDAT2"  USING DATA-INV.
           MOVE DATA-INV       TO DATA-DIA-I.
           MOVE ZEROS TO PAGE-COUNT ERRO-W.
           INITIALIZE GS-DATA-BLOCK
           INITIALIZE DS-CONTROL-BLOCK
           MOVE GS-DATA-BLOCK-VERSION-NO TO DS-DATA-BLOCK-VERSION-NO.
           MOVE GS-VERSION-NO  TO DS-VERSION-NO
           MOVE EMPRESA-W          TO EMP-REC
           MOVE NOME-EMPRESA-W     TO EMPRESA-REL
           MOVE "COD040" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-COD040.
           MOVE "CGD001" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CGD001.
           MOVE "LBD021" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LBD021.
           MOVE "LBD024" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LBD024.
           MOVE "LBD025" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LBD025.
           MOVE "LBD102" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LBD102.
           OPEN I-O LBD102.
           OPEN INPUT CGD001 LBD021 LBD024 LBD025 COD040.
           IF ST-LBD102 = "35"
              CLOSE LBD102      OPEN OUTPUT LBD102
              CLOSE LBD102      OPEN I-O LBD102
           END-IF.
           IF ST-COD040 <> "00"
              MOVE "ERRO ABERTURA COD040: "  TO GS-MENSAGEM-ERRO
              MOVE ST-COD040 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CGD001 <> "00"
              MOVE "ERRO ABERTURA CGD001: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CGD001 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD021 <> "00"
              MOVE "ERRO ABERTURA LBD021: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD021 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD024 <> "00"
              MOVE "ERRO ABERTURA LBD024: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD024 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD025 <> "00"
              MOVE "ERRO ABERTURA LBD025: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD025 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD102 <> "00"
              MOVE "ERRO ABERTURA LBD102: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD102 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO GS-MENSAGEM-ERRO
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ERRO-W = 0 PERFORM LOAD-SCREENSET.

       CORPO-PROGRAMA SECTION.
           EVALUATE TRUE
               WHEN GS-CENTRALIZA-TRUE
                   PERFORM CENTRALIZAR
               WHEN GS-SAVE-FLG-TRUE
                   PERFORM SALVAR-DADOS
                   IF GS-TIPO-GRAVACAO = 1 PERFORM REGRAVA-DADOS
                   ELSE PERFORM GRAVA-DADOS
                   END-IF
                   PERFORM LIMPAR-DADOS
               WHEN GS-EXCLUI-FLG-TRUE
                   PERFORM EXCLUI
                   PERFORM LIMPAR-DADOS
               WHEN GS-CLR-FLG-TRUE
                   PERFORM LIMPAR-DADOS
               WHEN GS-PRINTER-FLG-TRUE
                    COPY IMPRESSORA.CHAMA.
                    IF LNK-MAPEAMENTO <> SPACES
                       PERFORM IMPRIME-RELATORIO
                    END-IF
               WHEN GS-CARREGA-ULT-TRUE
                   PERFORM CARREGA-ULTIMOS
               WHEN GS-CARREGA-LIST-BOX-TRUE
                   MOVE DATA-MOVTO-I     TO DATA-MOVTO-L102
                   MOVE GS-LINDET(1: 3)  TO SEQ-L102
                   PERFORM CARREGAR-DADOS
               WHEN GS-LE-CONTRATO-TRUE
                   PERFORM LE-CONTRATO
               WHEN GS-LE-MOMENTO-TRUE
                   PERFORM LE-MOMENTO
               WHEN GS-LE-PROBLEMA-TRUE
                   PERFORM LE-PROBLEMA
               WHEN GS-LE-TIPO-FILME-TRUE
                   PERFORM LE-TIPO-FILME
               WHEN GS-LE-FOTOGRAFO-TRUE
                   PERFORM LE-FOTOGRAFO
               WHEN GS-CHAMAR-POP-UP-TRUE
                   PERFORM CHAMAR-POP-UP
           END-EVALUATE.
           PERFORM CLEAR-FLAGS.
           PERFORM CALL-DIALOG-SYSTEM.

       CENTRALIZAR SECTION.
          move-object-handle principal handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".

       CHAMAR-POP-UP SECTION.
           EVALUATE GS-OPCAO-POP-UP
             WHEN 1 CALL   "COP040T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "COP040T"
                    MOVE PASSAR-STRING-1(22: 10) TO GS-DESC-CONTRATO
                    MOVE "-"         TO GS-DESC-CONTRATO(11: 1)
                    MOVE PASSAR-STRING-1(33: 10)
                         TO GS-DESC-CONTRATO(12: 10)
                    MOVE PASSAR-STRING-1(52: 4) TO GS-CONTRATO
             WHEN 2 CALL   "CGP001T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "CGP001T"
                    MOVE PASSAR-STRING-1(1: 30) TO GS-NOME-FOTOGRAFO
                    MOVE PASSAR-STRING-1(33: 6) TO GS-FOTOGRAFO
             WHEN 3 CALL   "LBP021T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "LBP021T"
                    MOVE PASSAR-STRING-1(1: 20) TO GS-DESC-TP-FILME
                    MOVE PASSAR-STRING-1(33: 2) TO GS-TIPO-FILME
             WHEN 4 CALL   "LBP024T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "LBP024T"
                    MOVE PASSAR-STRING-1(1: 20) TO GS-NOME-MOMENTO
                    MOVE PASSAR-STRING-1(33: 3) TO GS-TIPO-MOMENTO
             WHEN 5 CALL   "LBP025T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "LBP025T"
                    MOVE PASSAR-STRING-1(1: 20) TO GS-NOME-PROBLEMA
                    MOVE PASSAR-STRING-1(33: 3) TO GS-TIPO-PROBLEMA
           END-EVALUATE.
      *----------------------------------------------------------------
       LE-FOTOGRAFO SECTION.
           MOVE GS-FOTOGRAFO       TO CODIGO-CG01.
           READ CGD001 INVALID KEY MOVE "********" TO NOME-CG01.
           MOVE NOME-CG01          TO GS-NOME-FOTOGRAFO.
       LE-MOMENTO SECTION.
           MOVE GS-TIPO-MOMENTO    TO CODIGO-LB24.
           READ LBD024 INVALID KEY MOVE SPACES TO DESCRICAO-LB24.
           MOVE DESCRICAO-LB24     TO GS-NOME-MOMENTO.
       LE-PROBLEMA SECTION.
           MOVE GS-TIPO-PROBLEMA   TO CODIGO-LB25.
           READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25.
           MOVE DESCRICAO-LB25     TO GS-NOME-PROBLEMA.
       LE-CONTRATO SECTION.
           MOVE GS-CONTRATO        TO NR-CONTRATO-CO40.
           READ COD040 INVALID KEY MOVE "******" TO IDENTIFICACAO-CO40.
           MOVE IDENTIFICACAO-CO40 TO GS-DESC-CONTRATO.
       LE-TIPO-FILME SECTION.
           MOVE GS-TIPO-FILME      TO CODIGO-LB21.
           READ LBD021 INVALID KEY MOVE SPACES TO DESCRICAO-LB21.
           MOVE DESCRICAO-LB21     TO GS-DESC-TP-FILME.
      *--------------------------------------------------------------
       CARREGAR-DADOS SECTION.
           START LBD102 KEY IS = CHAVE-L102 INVALID KEY CONTINUE.
           READ LBD102 INVALID KEY INITIALIZE REG-LBD102.
           MOVE DATA-MOVTO-W         TO  GS-DATA-MOVTO
           MOVE CONTRATO-L102        TO  GS-CONTRATO NR-CONTRATO-CO40.
           READ COD040 INVALID KEY MOVE SPACES TO IDENTIFICACAO-CO40.
           MOVE IDENTIFICACAO-CO40   TO GS-DESC-CONTRATO.
           MOVE SEQ-L102             TO  GS-SEQ
           MOVE MOMENTO-L102         TO  GS-TIPO-MOMENTO CODIGO-LB24.
           READ LBD024 INVALID KEY MOVE SPACES TO DESCRICAO-LB24.
           MOVE DESCRICAO-LB24       TO  GS-NOME-MOMENTO.
           MOVE PROBLEMA-L102        TO  GS-TIPO-PROBLEMA CODIGO-LB25.
           READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25.
           MOVE DESCRICAO-LB25       TO  GS-NOME-PROBLEMA.
           MOVE FOTOGRAFO-L102       TO  GS-FOTOGRAFO CODIGO-CG01.
           READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01.
           MOVE NOME-CG01            TO  GS-NOME-FOTOGRAFO.
           MOVE QT-FILME-PROB-L102   TO  GS-QT-FILME-PROB
           MOVE QT-FOTOG-PROB-L102   TO  GS-QT-FOTOG-PROB
           MOVE TIPO-FILME-L102      TO  GS-TIPO-FILME CODIGO-LB21
           READ LBD021 INVALID KEY MOVE SPACES TO DESCRICAO-LB21.
           MOVE DESCRICAO-LB21       TO  GS-DESC-TP-FILME.
       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE 1 TO ERRO-W.
       LIMPAR-DADOS SECTION.
           INITIALIZE REG-LBD102
           INITIALIZE GS-DATA-BLOCK
           MOVE ULT-SEQ TO GS-SEQ
           MOVE DATA-MOVTO-W TO GS-DATA-MOVTO.
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
           PERFORM CALL-DIALOG-SYSTEM.

       EXCLUI SECTION.
           DELETE LBD102.
           PERFORM LIMPAR-DADOS.
      *    PERFORM CARREGA-ULTIMOS.

       SALVAR-DADOS SECTION.
           MOVE DATA-MOVTO-I          TO DATA-MOVTO-L102
           MOVE GS-SEQ                TO SEQ-L102
           MOVE GS-CONTRATO           TO CONTRATO-L102
           MOVE GS-TIPO-MOMENTO       TO MOMENTO-L102
           MOVE GS-TIPO-PROBLEMA      TO PROBLEMA-L102.
           MOVE GS-FOTOGRAFO          TO FOTOGRAFO-L102
           MOVE GS-QT-FILME-PROB      TO QT-FILME-PROB-L102
           MOVE GS-QT-FOTOG-PROB      TO QT-FOTOG-PROB-L102
           MOVE GS-TIPO-FILME          TO TIPO-FILME-L102.
           MOVE USUARIO-W              TO DIGITADOR-L102.
       GRAVA-DADOS SECTION.
           MOVE ZEROS TO ST-LBD102.
           PERFORM UNTIL ST-LBD102 = "10"
             WRITE REG-LBD102 INVALID KEY
                 ADD 1 TO SEQ-L102
               NOT INVALID KEY
                 MOVE "10" TO ST-LBD102.
           PERFORM MOVER-DADOS-LISTA.
           ADD 1 TO ULT-SEQ.
           MOVE "INSERE-LIST" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       REGRAVA-DADOS SECTION.
           REWRITE REG-LBD102 INVALID KEY
                 MOVE "Erro Regravacao LBD102" TO GS-MENSAGEM-ERRO
                 MOVE ST-LBD102 TO GS-MENSAGEM-ERRO(24: 5)
                 MOVE "ERRO-GRAVACAO" TO DS-PROCEDURE
                 PERFORM CALL-DIALOG-SYSTEM.
           PERFORM MOVER-DADOS-LISTA.
           MOVE "ATUALIZA-LISTA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       ERRO-GRAVACAO SECTION.
           MOVE "ERRO GRAVAÇÃO" TO GS-MENSAGEM-ERRO
           PERFORM LOAD-SCREENSET
           PERFORM CARREGA-MENSAGEM-ERRO.
       CARREGA-ULTIMOS SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           MOVE GS-DATA-MOVTO   TO DATA-MOVTO-W DATA-INV
           CALL "GRIDAT2" USING DATA-INV
           MOVE DATA-INV        TO DATA-MOVTO-I DATA-MOVTO-L102.
           MOVE ZEROS           TO SEQ-L102 GS-SEQ.
           START LBD102 KEY IS NOT < CHAVE-L102
                    INVALID KEY MOVE "10" TO ST-LBD102.
           MOVE SPACES TO GS-LINDET.
           PERFORM UNTIL ST-LBD102 = "10"
              READ LBD102 NEXT RECORD AT END MOVE "10" TO ST-LBD102
              NOT AT END
                IF DATA-MOVTO-L102 <> DATA-MOVTO-I
                   MOVE "10" TO ST-LBD102
                ELSE
                   PERFORM MOVER-DADOS-LISTA
                   MOVE SEQ-L102      TO GS-SEQ
                   MOVE "INSERE-LIST" TO DS-PROCEDURE
                   PERFORM CALL-DIALOG-SYSTEM
                END-IF
              END-READ
           END-PERFORM.
           ADD 1 TO GS-SEQ.
           MOVE GS-SEQ TO ULT-SEQ.
       MOVER-DADOS-LISTA SECTION.
           MOVE SPACES             TO GS-LINDET
           MOVE SEQ-L102           TO GS-LINDET(1: 4)
           MOVE CONTRATO-L102      TO GS-LINDET(5: 5)
           MOVE FOTOGRAFO-L102     TO GS-LINDET(10: 07) CODIGO-CG01
           READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01.
           MOVE NOME-CG01          TO GS-LINDET(17: 10)
           MOVE TIPO-FILME-L102    TO GS-LINDET(28: 3) CODIGO-LB21
           READ LBD021 INVALID KEY MOVE SPACES TO DESCRICAO-LB21.
           MOVE DESCRICAO-LB21     TO GS-LINDET(31: 10).
           MOVE QT-FILME-PROB-L102 TO GS-LINDET(42: 8)
           MOVE QT-FOTOG-PROB-L102 TO GS-LINDET(50: 8)
           MOVE MOMENTO-L102       TO GS-LINDET(58: 4) CODIGO-LB24
           READ LBD024 INVALID KEY MOVE SPACES TO DESCRICAO-LB24.
           MOVE DESCRICAO-LB24     TO GS-LINDET(62: 10)
           MOVE PROBLEMA-L102      TO GS-LINDET(73: 4) CODIGO-LB25
           READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25.
           MOVE DESCRICAO-LB25     TO GS-LINDET(77: 10).
       CLEAR-FLAGS SECTION.
           INITIALIZE GS-FLAG-GROUP.

       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "LBP102" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           MOVE ZEROS TO PAGE-COUNT.
           OPEN OUTPUT RELAT.
           MOVE DATA-MOVTO-I   TO DATA-MOVTO-L102.
           MOVE ZEROS          TO SEQ-L102.
           START LBD102 KEY IS NOT < CHAVE-L102 INVALID KEY
                 MOVE "10" TO ST-LBD102.
           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           PERFORM UNTIL ST-LBD102 = "10"
             READ LBD102 NEXT RECORD AT END MOVE "10" TO ST-LBD102
              NOT AT END
                IF DATA-MOVTO-L102 <> DATA-MOVTO-I
                         MOVE "10" TO ST-LBD102
                ELSE
                  PERFORM MOVER-DADOS-REL
                  WRITE REG-RELAT FROM LINDET
                  ADD 1 TO LIN
                  IF LIN > 56 PERFORM CABECALHO
                  END-IF
                END-IF
             END-READ
           END-PERFORM.
           MOVE SPACES TO REG-RELAT.
           WRITE REG-RELAT AFTER PAGE.
           CLOSE RELAT.

       MOVER-DADOS-REL SECTION.
           MOVE SPACES             TO LINDET-REL
           MOVE SEQ-L102           TO LINDET-REL(1: 4)
           MOVE CONTRATO-L102      TO LINDET-REL(5: 5)
           MOVE FOTOGRAFO-L102     TO LINDET-REL(10: 07) CODIGO-CG01
           READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01.
           MOVE NOME-CG01          TO LINDET-REL(17: 10)
           MOVE TIPO-FILME-L102    TO LINDET-REL(28: 3) CODIGO-LB21
           READ LBD021 INVALID KEY MOVE SPACES TO DESCRICAO-LB21.
           MOVE DESCRICAO-LB21     TO LINDET-REL(31: 10).
           MOVE QT-FILME-PROB-L102 TO LINDET-REL(42: 8)
           MOVE QT-FOTOG-PROB-L102 TO LINDET-REL(50: 8)
           MOVE MOMENTO-L102       TO LINDET-REL(58: 4) CODIGO-LB24
           READ LBD024 INVALID KEY MOVE SPACES TO DESCRICAO-LB24.
           MOVE DESCRICAO-LB24     TO LINDET-REL(62: 10)
           MOVE PROBLEMA-L102      TO LINDET-REL(73: 4) CODIGO-LB25
           READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25.
           MOVE DESCRICAO-LB25     TO LINDET-REL(77: 10).

       CABECALHO SECTION.
           MOVE DATA-MOVTO-W    TO DATA-MOVTO-REL.
           ADD 1 TO PAGE-COUNT.  MOVE PAGE-COUNT TO PAG-REL.
           IF PAGE-COUNT = 1
              WRITE REG-RELAT FROM CAB01
           ELSE WRITE REG-RELAT FROM CAB01 AFTER PAGE.
           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB03.
           MOVE 4 TO LIN.

       CALL-DIALOG-SYSTEM SECTION.
           CALL "DSRUN" USING DS-CONTROL-BLOCK, GS-DATA-BLOCK.
           IF NOT DS-NO-ERROR
              MOVE DS-ERROR-CODE TO DISPLAY-ERROR-NO
              DISPLAY "DS ERROR NO:  " DISPLAY-ERROR-NO
              GO FINALIZAR-PROGRAMA
           END-IF.
       FINALIZAR-PROGRAMA SECTION.
           CLOSE LBD102 LBD021 LBD024 LBD025 CGD001 COD040.
           MOVE DS-QUIT-SET TO DS-CONTROL.
           PERFORM CALL-DIALOG-SYSTEM.
           EXIT PROGRAM.
