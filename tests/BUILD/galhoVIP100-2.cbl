       IDENTIFICATION DIVISION.
       PROGRAM-ID. GALHOVIP100-2.
       AUTHOR. ALFREDO SAVIOLLI NETO.
       DATE-WRITTEN. 03/11/2009.
      *FUNÇÃO: MUDAR O CAMPO NR-FITA

       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CAPX001.

           COPY VIPX100.

       DATA DIVISION.
       FILE SECTION.

           COPY CAPW001.

           COPY VIPW100.

       WORKING-STORAGE SECTION.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-VID100             PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
      *    ERRO-W - flag que controla se houve erro de abertura arquivo
           05  HORA-W                PIC 9(8)     VALUE ZEROS.
           05  PAGE-COUNT                 PIC 9(2)     VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(7).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(12).
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-MOVTO-I          PIC 9(8)     VALUE ZEROS.
           05  CLIENTE-E             PIC ZZZZ.ZZZZ VALUE ZEROS.
           05  SEQ-E                 PIC ZZZZZ    VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999.

           05  CUSTO-PREVISTO-W      PIC 9(8)V99  VALUE ZEROS.
           05  INICIAL-PROCURADA     PIC X(6)     VALUE SPACES.
           05  INICIAL-A-COMPARAR    PIC X(6)     VALUE SPACES.
           05  LETRA                 PIC X        VALUE SPACES.
           05  LETRA1                PIC X        VALUE SPACES.
           05  SAIR-W                PIC 9        VALUE ZEROS.
      *    variáveis p/ listar os nomes com iniciais solicitadas

           05  VALOR-E               PIC ZZZ.ZZZ,ZZ.
           05  VALOR-E1              PIC ZZ.ZZZ.ZZZ,ZZ.
           05  I                     PIC 99       VALUE ZEROS.
           05  L                     PIC 99       VALUE ZEROS.
           05  K                     PIC 99       VALUE ZEROS.
           05  J                     PIC 99       VALUE ZEROS.
           05  VLR-PARCELA           PIC 9(8)V99  VALUE ZEROS.
           05  DATA-DIA-I            PIC 9(8)     VALUE ZEROS.
           05  CLASSIF-W             PIC 9        VALUE ZEROS.
           05  COL1                  PIC 9(3)     VALUE ZEROS.
           05  ANOTACAO-W            PIC X(80)    VALUE SPACES.
           05  ULT-SEQ               PIC 9(3)     VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.

           COPY "PARAMETR".

       01  LINDET.
           05  LINDET-REL          PIC X(130)  VALUE SPACES.

       01  CAB04.
           05  FILLER              PIC X(130)  VALUE
           "CONTRATO    ITEM    CURSO    TURMA".


       PROCEDURE DIVISION.
       MAIN-PROCESS SECTION.
           MOVE ZEROS TO PAGE-COUNT ERRO-W.
           OPEN INPUT CONTROLE
           READ CONTROLE
           MOVE EMPRESA            TO EMP-REC
           MOVE "VID100"  TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-VID100

           OPEN I-O VID100
           CLOSE    VID100
           OPEN I-O VID100

           CLOSE    CONTROLE
           IF ST-VID100 = "35"
              CLOSE VID100      OPEN OUTPUT  VID100
              CLOSE VID100      OPEN I-O     VID100
           END-IF.

           display "vou comecar" stop " "

           INITIALIZE REG-VID100
           START VID100 KEY IS NOT LESS CHAVE-V100 INVALID KEY
                 MOVE "10" TO ST-VID100.

           PERFORM UNTIL ST-VID100 = "10"
                 READ VID100 NEXT RECORD AT END
                      MOVE "10" TO ST-VID100
                 NOT AT END
                      IF DATA-MOVTO-V100 > 20100314
                         IF NR-FITA-V100 > 9999
                            MOVE NR-FITA-V100  TO IDENTIFICADOR-V100
                         ELSE
                            MOVE NR-FITAS-V100 TO IDENTIFICADOR-V100
                         END-IF
                      ELSE
                         MOVE NR-FITA-V100     TO IDENTIFICADOR-V100
                      END-IF
                      display reg-vid100
                      REWRITE REG-VID100
                 END-READ
           END-PERFORM.

           DISPLAY "ACABOU"
           DISPLAY "ACABOU" STOP "  ".

           CLOSE VID100

           EXIT PROGRAM
           STOP RUN.
