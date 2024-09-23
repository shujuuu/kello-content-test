       COPY DSLANG.CPY.
       identification division.
       program-id.     mtp062b.
       author.         Alfredo Saviolli.
       date-written.   03-02-2016.

       security.       Impressão das Etiquetas dos Produtos (PIMACO).

       environment division.
       class-control.
           Window             is class "wclass".

       special-names.
           decimal-point is comma
           console is crt.
       file-control.

           copy capx010.

           copy mtpx019.

           copy mtpx020.

           copy iepx011.

           select   ordserv assign       to arquivo-ordserv
                            organization is line sequential
                            access mode  is      sequential
                            file  status is      fs-ordserv.

           select   work    assign       to    arquivo-work
                            organization is         indexed
                            access mode  is         dynamic
                            record key   is        chave-wk
                            file status  is         st-work.

       data division.
       file section.

           copy capw010.

           copy mtpw019.

           copy mtpw020.

           copy iepw011.

       fd ordserv.
       01 reg-ordserv                          pic x(450).

       fd work.
       01 reg-work.
          05 chave-wk.
             10 folha-wk                       pic 9(05).
             10 numero-etiqueta-wk             pic 9(02).
             10 desc-etiqueta-wk               pic x(09).

       working-storage section.
       78 dialog-system       value "DSGRUN".
       01 display-error-no    pic 9(04).
       01 display-details-1   pic 9(04).
       01 display-details-2   pic 9(04).
       01 arq-help            pic x(11).
       01 abriu-gs            pic x(01) value "S".
       01 mensagem            pic x(200).
       01 tipo-msg            pic x(01).
       01 ws-ultimo           pic 9(06).
       01 resp-msg            pic x(01).
       01 st-cad001           pic x(02) value "00".
       01 st-cad010           pic x(02) value "00".
       01 st-mtd019           pic x(02) value "00".
       01 st-mtd020           pic x(02) value "00".
       01 st-ied011           pic x(02) value "00".
       01 st-work             pic x(02) value "00".
       01 fs-ordserv          pic x(02) value "00".
       01 multiplicador       pic 9(04)v99999.
       01 total-empresa       pic 9(03)v99.
       01 total-etiquetas     pic 9(05) value zeros.
       01 etiquetas-movidas   pic 9(05) value zeros.
       01 pagina1             pic 9(02) value zeros.
       01 numero-pagina       pic 9(05) value zeros.
       01 aux-numero-pagina   pic 9(05) value zeros.
       01 limpar-etiquetas    pic x(01) value spaces.
       01 ok                  pic x(01).
       01 pode                pic x(01).
       01 controle            pic 9(02) value zeros.
       01 masc-qtde           pic Z.ZZ9.
       01 ws-status           pic x(02) value "00".
       01 masc-vlr            pic Z.ZZ9,99 BLANK WHEN ZEROS.
       01 LNK-DETALHE         PIC X(200).
       01 always              pic x(01).
       01  VARIAVEIS.
           05  ERRO-W                PIC 9        VALUE ZEROS.
           05  PAG-W                 PIC 99       VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).

       01 LNK-DADOS.
          05 LNK-OPERACAO       PIC X(01).
          05 LNK-PROGRAMA       PIC X(10).
          05 LNK-ARQUIVO        pic x(10).
          05 LNK-CHAVE          PIC X(70).
          05 LNK-REGISTRO       PIC X(1500).
          05 LNK-TIPO           PIC 9(01).
          05 LNK-ERRO           PIC X(01).

       01 ws-data-sys.
          05 ws-data-cpu.
             10 ws-ano-cpu                 pic 9(04).
             10 ws-mes-cpu                 pic 9(02).
             10 ws-dia-cpu                 pic 9(02).
          05 filler                        pic x(13).

       01 lnk-cadpro.
          05 lnk-fornecedor                pic 9(06).
          05 lnk-grupo                     pic 9(06).
          05 lnk-subgrupo                  pic 9(06).
          05 lnk-codigo                    pic 9(06).

           COPY "PARAMETR".

           COPY IMPRESSORA.

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.



       copy "html.rel".

       copy "mtp062b.cpb".
       copy "mtp062b.cpy".

       copy "ds-cntrl.mf".


       procedure division.
       010-inicio section.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           perform 020-rotina-inicial.
           perform 030-rotina-principal until exit-flag-true.
           perform 040-rotina-final.
       010-inicio-fim.
           exit.

       020-rotina-inicial section.
           initialize  ds-control-block
           initialize  data-block

           move        data-block-version-no to ds-data-block-version-no
           move        version-no            to ds-version-no
           move        ds-push-set           to ds-control
           move        "MTP062B"             to ds-set-name
           move        spaces                to fun-cobol.

           MOVE EMPRESA-W          TO EMP-REC
           MOVE "CAD010"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CAD010.
           MOVE "MTD019"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-MTD019.
           MOVE "MTD020"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-MTD020.
           MOVE "IED011"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-IED011.
           OPEN INPUT MTD019 MTD020 IED011 CAD010
           IF ST-CAD010 <> "00"
              STRING "ERRO ABERTURA CAD010: " ST-CAD010 INTO MENSAGEM
              MOVE "C" TO TIPO-MSG
              PERFORM 140-EXIBIR-MENSAGEM
              MOVE 1 TO EXIT-FLAG.
           IF ST-MTD019 <> "00"
              STRING "ERRO ABERTURA MTD019: " ST-MTD019 INTO MENSAGEM
              MOVE "C" TO TIPO-MSG
              PERFORM 140-EXIBIR-MENSAGEM
              MOVE 1 TO EXIT-FLAG.
           IF ST-MTD020 <> "00"
              STRING "ERRO ABERTURA MTD020: " ST-MTD020 INTO MENSAGEM
              MOVE "C" TO TIPO-MSG
              PERFORM 140-EXIBIR-MENSAGEM
              MOVE 1 TO EXIT-FLAG.
           IF ST-IED011 <> "00"
              STRING "ERRO ABERTURA IED011: " ST-IED011 INTO MENSAGEM
              MOVE "C" TO TIPO-MSG
              PERFORM 140-EXIBIR-MENSAGEM
              MOVE 1 TO EXIT-FLAG.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO MENSAGEM
              MOVE "C" TO TIPO-MSG
              PERFORM 140-EXIBIR-MENSAGEM
              MOVE 1 TO EXIT-FLAG.

           move "c:\tempsis\etiqueta" to arquivo-work.

           move zeros to etiquetas-movidas
           initialize pagina1
           move 1 to numero-pagina
           move 1 to aux-numero-pagina

           open output work
           close       work.

       020-rotina-inicial-fim.
           exit.

       030-rotina-principal section.
           perform 050-call-dialog-system.
           perform 060-processar-cobol.
       030-rotina-principal-fim.
           exit.

       040-rotina-final section.
           if  abriu-gs = "S"
               move    ds-quit-set to ds-control
               perform 050-call-dialog-system.
           close mtd019 mtd020 ied011 cad010
           perform 045-fim-prog.
       040-rotina-final-fim.
           exit.

       045-fim-prog section.
           exit program.
           stop run.
       045-fim-prog-fim.
           exit.

       050-call-dialog-system section.
           call dialog-system using ds-control-block, data-block
           if  not ds-no-error
               move    ds-error-code   to  display-error-no
               display "ds error no:     " display-error-no
               display "error details(1):" display-details-1
               display "error details(2):" display-details-2
               perform 040-rotina-final.
       050-call-dialog-system-fim.
           exit.

       060-processar-cobol section.
           evaluate fun-cobol
               when "a" perform centralizar
               when "C" perform 110-criticar
               when "S" perform 200-sugestao
               when "N" perform 210-navegacao
               when "I" perform 500-incluir
               when "P"
      *                 if tipo-etiqueta = 1
      *                    perform 800-etiqueta-numerica
      *                 else
                           perform 700-imprimir-etiqueta
      *                 end-if

                        move spaces to arq-explorer
                           STRING
                        '"C:\Program Files (x86)\Google\Chrome\Applicati
      -                 'on\"' 'chrome file:///c:/tempsis/'
                                  usuario-w ".HTM" into arq-explorer

      *                 '"c:\program files\internet explorer\"'
      *                 'iexplore.exe file:///c:/tempsis/'
      *                           usuario-w ".HTM" into arq-explorer
                        move "CHAMAR-EXPLORER" to ds-procedure
                        perform 050-call-dialog-system

               when "A" perform 061-anterior
               when "F" perform 062-proximo
               when "L" open output work
                        close       work
                        move 0 to etiquetas-movidas
                        move 1 to numero-pagina
                        move 1 to aux-numero-pagina
                        initialize pagina1
                        perform 063-carregar-pagina
           end-evaluate.
           move spaces to fun-cobol.
       060-processar-cobol-fim.
           exit.

       CENTRALIZAR SECTION.
          move-object-handle win1 handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".



       061-anterior section.
           open input work
           initialize reg-work
           if aux-numero-pagina = 1
              move "Página Inicial" to mensagem
              move "C" to tipo-msg
              perform 140-exibir-mensagem
           else
              move spaces to desc-etiqueta1
                             desc-etiqueta2
                             desc-etiqueta3
                             desc-etiqueta4
                             desc-etiqueta5
                             desc-etiqueta6
                             desc-etiqueta7
                             desc-etiqueta8
                             desc-etiqueta9
                             desc-etiqueta10
                             desc-etiqueta11
                             desc-etiqueta12
                             desc-etiqueta13
                             desc-etiqueta14
                             desc-etiqueta15
                             desc-etiqueta16
                             desc-etiqueta17
                             desc-etiqueta18
                             desc-etiqueta19
                             desc-etiqueta20

              compute aux-numero-pagina = aux-numero-pagina - 1
              initialize reg-work
              move aux-numero-pagina to folha-wk
              start work key is not less chave-wk invalid key
                   move "10" to st-work
              end-start
              perform until st-work = "10"
                   read work next at end
                        move "10" to st-work
                   not at end
                        if aux-numero-pagina <> folha-wk
                           move "10" to st-work
                        else
                      evaluate numero-etiqueta-wk
                        when 1  move desc-etiqueta-wk to desc-etiqueta1
                        when 2  move desc-etiqueta-wk to desc-etiqueta2
                        when 3  move desc-etiqueta-wk to desc-etiqueta3
                        when 4  move desc-etiqueta-wk to desc-etiqueta4
                        when 5  move desc-etiqueta-wk to desc-etiqueta5
                        when 6  move desc-etiqueta-wk to desc-etiqueta6
                        when 7  move desc-etiqueta-wk to desc-etiqueta7
                        when 8  move desc-etiqueta-wk to desc-etiqueta8
                        when 9  move desc-etiqueta-wk to desc-etiqueta9
                        when 10 move desc-etiqueta-wk to desc-etiqueta10
                        when 11 move desc-etiqueta-wk to desc-etiqueta11
                        when 12 move desc-etiqueta-wk to desc-etiqueta12
                        when 13 move desc-etiqueta-wk to desc-etiqueta13
                        when 14 move desc-etiqueta-wk to desc-etiqueta14
                        when 15 move desc-etiqueta-wk to desc-etiqueta15
                        when 16 move desc-etiqueta-wk to desc-etiqueta16
                        when 17 move desc-etiqueta-wk to desc-etiqueta17
                        when 18 move desc-etiqueta-wk to desc-etiqueta18
                        when 19 move desc-etiqueta-wk to desc-etiqueta19
                        when 20 move desc-etiqueta-wk to desc-etiqueta20
                      end-evaluate
                        end-if
                   end-read
              end-perform
           end-if
           close work.
       061-anterior-fim.
           exit.

       062-proximo section.
           open input work
           initialize reg-work
           compute aux-numero-pagina = aux-numero-pagina + 1
           move spaces to desc-etiqueta1
                          desc-etiqueta2
                          desc-etiqueta3
                          desc-etiqueta4
                          desc-etiqueta5
                          desc-etiqueta6
                          desc-etiqueta7
                          desc-etiqueta8
                          desc-etiqueta9
                          desc-etiqueta10
                          desc-etiqueta11
                          desc-etiqueta12
                          desc-etiqueta13
                          desc-etiqueta14
                          desc-etiqueta15
                          desc-etiqueta16
                          desc-etiqueta17
                          desc-etiqueta18
                          desc-etiqueta19
                          desc-etiqueta20

           initialize reg-work
           move aux-numero-pagina to folha-wk
           start work key is not less chave-wk invalid key
                move "10" to st-work
                move "Página Final" to mensagem
                move "C" to tipo-msg
                perform 140-exibir-mensagem
                compute aux-numero-pagina = aux-numero-pagina - 1
           end-start
           perform until st-work = "10"
                read work next at end
                     move "10" to st-work
                not at end
                     if aux-numero-pagina <> folha-wk
                        move "10" to st-work
                     else
                   evaluate numero-etiqueta-wk
                     when 1  move desc-etiqueta-wk to desc-etiqueta1
                     when 2  move desc-etiqueta-wk to desc-etiqueta2
                     when 3  move desc-etiqueta-wk to desc-etiqueta3
                     when 4  move desc-etiqueta-wk to desc-etiqueta4
                     when 5  move desc-etiqueta-wk to desc-etiqueta5
                     when 6  move desc-etiqueta-wk to desc-etiqueta6
                     when 7  move desc-etiqueta-wk to desc-etiqueta7
                     when 8  move desc-etiqueta-wk to desc-etiqueta8
                     when 9  move desc-etiqueta-wk to desc-etiqueta9
                     when 10 move desc-etiqueta-wk to desc-etiqueta10
                     when 11 move desc-etiqueta-wk to desc-etiqueta11
                     when 12 move desc-etiqueta-wk to desc-etiqueta12
                     when 13 move desc-etiqueta-wk to desc-etiqueta13
                     when 14 move desc-etiqueta-wk to desc-etiqueta14
                     when 15 move desc-etiqueta-wk to desc-etiqueta15
                     when 16 move desc-etiqueta-wk to desc-etiqueta16
                     when 17 move desc-etiqueta-wk to desc-etiqueta17
                     when 18 move desc-etiqueta-wk to desc-etiqueta18
                     when 19 move desc-etiqueta-wk to desc-etiqueta19
                     when 20 move desc-etiqueta-wk to desc-etiqueta20
                   end-evaluate
                     end-if
                end-read
           end-perform
           close work.
       062-proximo-fim.
           exit.

       063-carregar-pagina section.
           open input work
           move spaces to desc-etiqueta1
                          desc-etiqueta2
                          desc-etiqueta3
                          desc-etiqueta4
                          desc-etiqueta5
                          desc-etiqueta6
                          desc-etiqueta7
                          desc-etiqueta8
                          desc-etiqueta9
                          desc-etiqueta10
                          desc-etiqueta11
                          desc-etiqueta12
                          desc-etiqueta13
                          desc-etiqueta14
                          desc-etiqueta15
                          desc-etiqueta16
                          desc-etiqueta17
                          desc-etiqueta18
                          desc-etiqueta19
                          desc-etiqueta20

           initialize reg-work
           move aux-numero-pagina to folha-wk
           start work key is not less chave-wk invalid key
                move "10" to st-work
           end-start
           perform until st-work = "10"
                read work next at end
                     move "10" to st-work
                not at end
                     if aux-numero-pagina <> folha-wk
                        move "10" to st-work
                     else
                   evaluate numero-etiqueta-wk
                     when 1  move desc-etiqueta-wk to desc-etiqueta1
                     when 2  move desc-etiqueta-wk to desc-etiqueta2
                     when 3  move desc-etiqueta-wk to desc-etiqueta3
                     when 4  move desc-etiqueta-wk to desc-etiqueta4
                     when 5  move desc-etiqueta-wk to desc-etiqueta5
                     when 6  move desc-etiqueta-wk to desc-etiqueta6
                     when 7  move desc-etiqueta-wk to desc-etiqueta7
                     when 8  move desc-etiqueta-wk to desc-etiqueta8
                     when 9  move desc-etiqueta-wk to desc-etiqueta9
                     when 10 move desc-etiqueta-wk to desc-etiqueta10
                     when 11 move desc-etiqueta-wk to desc-etiqueta11
                     when 12 move desc-etiqueta-wk to desc-etiqueta12
                     when 13 move desc-etiqueta-wk to desc-etiqueta13
                     when 14 move desc-etiqueta-wk to desc-etiqueta14
                     when 15 move desc-etiqueta-wk to desc-etiqueta15
                     when 16 move desc-etiqueta-wk to desc-etiqueta16
                     when 17 move desc-etiqueta-wk to desc-etiqueta17
                     when 18 move desc-etiqueta-wk to desc-etiqueta18
                     when 19 move desc-etiqueta-wk to desc-etiqueta19
                     when 20 move desc-etiqueta-wk to desc-etiqueta20
                   end-evaluate
                     end-if
                end-read
           end-perform
           close work.
       063-carregar-pagina-fim.
           exit.

       110-criticar section.
           move    spaces to mensagem.
           evaluate    campo-critica
               when "EF-CONTRATO"      perform 111-criticar-contrato
               when "EF-ALBUM-INI"     perform 112-criticar-album-ini
               when "EF-ALBUM-FIM"     perform 113-criticar-album-fim
               when "EF-QTDE-COPIAS"   perform 114-criticar-qtde-cop
               when "REGISTRO"         perform 111-criticar-contrato
                                          thru 114-criticar-qtde-cop
           end-evaluate.
       110-criticar-fim.
           exit.

       111-criticar-contrato section.
           if mensagem equal spaces
               if acp-contrato equal zeros
                   move "Contrato Não Informado" to mensagem
                   move "C" to tipo-msg
                   perform 140-exibir-mensagem
               else
                   initialize reg-mtd020
                   move acp-contrato to contrato-mtg
                   start mtd020 key is not less album-mtg invalid key
                        move "Contrato Não Encontrado no MTD020" to
                        mensagem
                        move "C" to tipo-msg
                        perform 140-exibir-mensagem
                   not invalid key
                        read mtd020 next at end
                             move "Contrato Não Encontrado no MTD020" to
                                   mensagem
                             move "C" to tipo-msg
                             perform 140-exibir-mensagem
                        not at end
                             if acp-contrato <> contrato-mtg
                                move "Contrato Não Encontrado no MTD020"
                                  to mensagem
                                move "C" to tipo-msg
                                perform 140-exibir-mensagem.
       111-criticar-contrato-fim.
           exit.

       112-criticar-album-ini section.
       112-criticar-album-ini-fim.
           exit.

       113-criticar-album-fim section.
       113-criticar-album-fim-fim.
           exit.

       114-criticar-qtde-cop section.
           if mensagem equal spaces
              if qtde-copias = 0
                 move 1 to qtde-copias
                 refresh-object win1.
       114-criticar-qtde-cop-fim.
           exit.

       140-exibir-mensagem section.
           move    spaces to resp-msg.
           call    "MENSAGEM" using tipo-msg resp-msg mensagem
           cancel  "MENSAGEM".
           move    1 to flag-critica.
       140-exibir-mensagem-fim.
           exit.

       200-sugestao section.
           move "Sugestão Inexistente!" to mensagem
           move "C" to tipo-msg
           perform 140-exibir-mensagem.
       200-sugestao-fim.
           exit.

       210-navegacao section.
           move "Navegacão Inexistente!" to mensagem
           move "C" TO TIPO-MSG
           perform 140-exibir-mensagem.
       210-navegacao-fim.
           exit.

       300-exibir-tudo section.
           move    "EXIBIR-TUDO" to ds-procedure.
           perform 050-call-dialog-system.
       300-exibir-tudo-fim.
           exit.

       500-incluir section.
      *    open output work
      *    close       work
           open i-o    work.
      *    contagem de contratos
           initialize reg-mtd019 total-etiquetas
           move acp-contrato  to contrato-mt19
           move acp-album-ini to seq-mt19
           start mtd019 key is not less album-mt19 invalid key
               move "10" to st-mtd019.
           perform until st-mtd019 = "10"
               read mtd019 next at end
                   move "10" to st-mtd019
               not at end
                   if acp-contrato <> contrato-mt19
                      move "10" to st-mtd019
                   else
                      if acp-album-fim > 0 and seq-mt19 >
                         acp-album-fim
                         move "10" to st-mtd019
                      else
                         move album-mt19 to album-mtg
                         read mtd020 not invalid key
                              if acp-opcao = 1 or (acp-opcao = 2 and
                                 nao-gerou-album-mtg <> 1)
                                 if fogo-mtg <> 1 and 8
                                    perform verificar-produtos
                                    if pode = "S"
                                       add 1    to total-etiquetas
                                    end-if
                                 end-if
                              end-if
                         end-read
                      end-if
                   end-if
               end-read
           end-perform

           if total-etiquetas = 0
              move "Não Possui nenhum Contrato/Álbum" to mensagem
              move "C" to tipo-msg
              perform 140-exibir-mensagem
           else
      * conta numero de etiquetas 1ª Folha
              initialize pagina1

              if selecao1 = "N"
                 add 1 to pagina1
              end-if

              if selecao2 = "N"
                 add 1 to pagina1
              end-if

              if selecao3 = "N"
                 add 1 to pagina1
              end-if

              if selecao4 = "N"
                 add 1 to pagina1
              end-if

              if selecao5 = "N"
                 add 1 to pagina1
              end-if

              if selecao6 = "N"
                 add 1 to pagina1
              end-if

              if selecao7 = "N"
                 add 1 to pagina1
              end-if

              if selecao8 = "N"
                 add 1 to pagina1
              end-if

              if selecao9 = "N"
                 add 1 to pagina1
              end-if

              if selecao10 = "N"
                 add 1 to pagina1
              end-if

              if selecao11 = "N"
                 add 1 to pagina1
              end-if

              if selecao12 = "N"
                 add 1 to pagina1
              end-if

              if selecao13 = "N"
                 add 1 to pagina1
              end-if

              if selecao14 = "N"
                 add 1 to pagina1
              end-if

              if selecao15 = "N"
                 add 1 to pagina1
              end-if

              if selecao16 = "N"
                 add 1 to pagina1
              end-if

              if selecao17 = "N"
                 add 1 to pagina1
              end-if

              if selecao18 = "N"
                 add 1 to pagina1
              end-if

              if selecao19 = "N"
                 add 1 to pagina1
              end-if

              if selecao20 = "N"
                 add 1 to pagina1
              end-if

      *---------------- joga folha a folha

              initialize reg-mtd019
              move 1 to aux-numero-pagina
              move acp-contrato  to contrato-mt19
              move acp-album-ini to seq-mt19
              start mtd019 key is not less album-mt19 invalid key
                  move "10" to st-mtd019
              end-start
              perform until st-mtd019 = "10"
                  read mtd019 next at end
                      move "10" to st-mtd019
                  not at end
                      if acp-contrato <> contrato-mt19
                         move "10" to st-mtd019
                      else
                         if acp-album-fim > 0 and seq-mt19 >
                            acp-album-fim
                            move "10" to st-mtd019
                         else
                            move album-mt19 to album-mtg
                            read mtd020 not invalid key
                                 if acp-opcao = 1 or (acp-opcao = 2 and
                                    nao-gerou-album-mtg <> 1)
                                    if fogo-mtg <> 1 and 8
                                       perform verificar-produtos
                                       if pode = "S"
                                          add 1 to etiquetas-movidas
                                          perform mover-dados
                                       end-if
                                    end-if
                                 end-if
                            end-read
                         end-if
                      end-if
                  end-read
              end-perform
           end-if


           move spaces to desc-etiqueta1
                          desc-etiqueta2
                          desc-etiqueta3
                          desc-etiqueta4
                          desc-etiqueta5
                          desc-etiqueta6
                          desc-etiqueta7
                          desc-etiqueta8
                          desc-etiqueta9
                          desc-etiqueta10
                          desc-etiqueta11
                          desc-etiqueta12
                          desc-etiqueta13
                          desc-etiqueta14
                          desc-etiqueta15
                          desc-etiqueta16
                          desc-etiqueta17
                          desc-etiqueta18
                          desc-etiqueta19
                          desc-etiqueta20
           close      work
           open input work
           initialize reg-work
           start work key is not less chave-wk invalid key
               move "N" to st-work
           end-start
           perform until st-work = "10"
               read work next at end
                   move "10" to st-work
               not at end
                   if folha-wk <> 1
                      move "10" to st-work
                   else
                      evaluate numero-etiqueta-wk
                        when 1  move desc-etiqueta-wk
                                  to desc-etiqueta1
                        when 2  move desc-etiqueta-wk
                                  to desc-etiqueta2
                        when 3  move desc-etiqueta-wk
                                  to desc-etiqueta3
                        when 4  move desc-etiqueta-wk
                                  to desc-etiqueta4
                        when 5  move desc-etiqueta-wk
                                  to desc-etiqueta5
                        when 6  move desc-etiqueta-wk
                                  to desc-etiqueta6
                        when 7  move desc-etiqueta-wk
                                  to desc-etiqueta7
                        when 8  move desc-etiqueta-wk
                                  to desc-etiqueta8
                        when 9  move desc-etiqueta-wk
                                  to desc-etiqueta9
                        when 10 move desc-etiqueta-wk
                                  to desc-etiqueta10
                        when 11 move desc-etiqueta-wk
                                  to desc-etiqueta11
                        when 12 move desc-etiqueta-wk
                                  to desc-etiqueta12
                        when 13 move desc-etiqueta-wk
                                  to desc-etiqueta13
                        when 14 move desc-etiqueta-wk
                                  to desc-etiqueta14
                        when 15 move desc-etiqueta-wk
                                  to desc-etiqueta15
                        when 16 move desc-etiqueta-wk
                                  to desc-etiqueta16
                        when 17 move desc-etiqueta-wk
                                  to desc-etiqueta17
                        when 18 move desc-etiqueta-wk
                                  to desc-etiqueta18
                        when 19 move desc-etiqueta-wk
                                  to desc-etiqueta19
                        when 20 move desc-etiqueta-wk
                                  to desc-etiqueta20
                      end-evaluate
                   end-if
               end-read
           end-perform
      *    move 1 to numero-pagina
           move 1 to aux-numero-pagina
           close work.
       500-incluir-fim.
           exit.

       verificar-produtos section.
           move "N" to pode

           if dvd = 0 and foto-cd = 0 and book = 0 and poster = 0 and
              estojo = 0
              move "S" to pode
           end-if

           if dvd = 1 and qt-dvd-mtg > 0
              move "S" to pode
           end-if

           if foto-cd = 1 and qt-foto-cd-mtg > 0
              move "S" to pode
           end-if

           if book    = 1 and qt-book-mtg > 0
              move "S" to pode
           end-if

           if poster  = 1 and qt-poster-mtg > 0
              move "S" to pode
           end-if

           if estojo = 1 and qt-estojo-mtg > 0
              move "S" to pode
           end-if.

       verificar-produtos-fim.
           exit.

       mover-dados section.
           perform qtde-copias times
                                 move "N" to ok
            if numero-pagina > 0 and limpar-etiquetas = "S"
      *     if etiquetas-movidas > pagina1
               move "N" to    selecao1
                              selecao2
                              selecao3
                              selecao4
                              selecao5
                              selecao6
                              selecao7
                              selecao8
                              selecao9
                              selecao10
                              selecao11
                              selecao12
                              selecao13
                              selecao14
                              selecao15
                              selecao16
                              selecao17
                              selecao18
                              selecao19
                              selecao20
               move spaces to desc-etiqueta1
                              desc-etiqueta2
                              desc-etiqueta3
                              desc-etiqueta4
                              desc-etiqueta5
                              desc-etiqueta6
                              desc-etiqueta7
                              desc-etiqueta8
                              desc-etiqueta9
                              desc-etiqueta10
                              desc-etiqueta11
                              desc-etiqueta12
                              desc-etiqueta13
                              desc-etiqueta14
                              desc-etiqueta15
                              desc-etiqueta16
                              desc-etiqueta17
                              desc-etiqueta18
                              desc-etiqueta19
                              desc-etiqueta20

            end-if

            if ok = "N" and desc-etiqueta1 = spaces and selecao1 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta1
               move numero-pagina  to folha-wk
               move 1              to numero-etiqueta-wk
               move desc-etiqueta1 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao1
            end-if
            if ok = "N" and desc-etiqueta2 = spaces and selecao2 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta2
               move numero-pagina  to folha-wk
               move 2              to numero-etiqueta-wk
               move desc-etiqueta2 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao2
            end-if
            if ok = "N" and desc-etiqueta3 = spaces and selecao3 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta3
               move numero-pagina  to folha-wk
               move 3              to numero-etiqueta-wk
               move desc-etiqueta3 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao3
            end-if
            if ok = "N" and desc-etiqueta4 = spaces and selecao4 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta4
               move numero-pagina  to folha-wk
               move 4              to numero-etiqueta-wk
               move desc-etiqueta4 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao4
            end-if
            if ok = "N" and desc-etiqueta5 = spaces and selecao5 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta5
               move numero-pagina  to folha-wk
               move 5              to numero-etiqueta-wk
               move desc-etiqueta5 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao5
            end-if
            if ok = "N" and desc-etiqueta6 = spaces and selecao6 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta6
               move numero-pagina  to folha-wk
               move 6              to numero-etiqueta-wk
               move desc-etiqueta6 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao6
            end-if
            if ok = "N" and desc-etiqueta7 = spaces and selecao7 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta7
               move numero-pagina  to folha-wk
               move 7              to numero-etiqueta-wk
               move desc-etiqueta7 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao7
            end-if
            if ok = "N" and desc-etiqueta8 = spaces and selecao8 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta8
               move numero-pagina  to folha-wk
               move 8              to numero-etiqueta-wk
               move desc-etiqueta8 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao8
            end-if
            if ok = "N" and desc-etiqueta9 = spaces and selecao9 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta9
               move numero-pagina  to folha-wk
               move 9              to numero-etiqueta-wk
               move desc-etiqueta9 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao9
            end-if
            if ok = "N" and desc-etiqueta10 = spaces and selecao10 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta10
               move numero-pagina   to folha-wk
               move 10              to numero-etiqueta-wk
               move desc-etiqueta10 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao10
            end-if
            if ok = "N" and desc-etiqueta11 = spaces and selecao11 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta11
               move numero-pagina   to folha-wk
               move 11              to numero-etiqueta-wk
               move desc-etiqueta11 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao11
            end-if
            if ok = "N" and desc-etiqueta12 = spaces and selecao12 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta12
               move numero-pagina   to folha-wk
               move 12              to numero-etiqueta-wk
               move desc-etiqueta12 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao12
            end-if
            if ok = "N" and desc-etiqueta13 = spaces and selecao13 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta13
               move numero-pagina   to folha-wk
               move 13              to numero-etiqueta-wk
               move desc-etiqueta13 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao13
            end-if
            if ok = "N" and desc-etiqueta14 = spaces and selecao14 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta14
               move numero-pagina   to folha-wk
               move 14              to numero-etiqueta-wk
               move desc-etiqueta14 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao14
            end-if
            if ok = "N" and desc-etiqueta15 = spaces and selecao15 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta15
               move numero-pagina   to folha-wk
               move 15              to numero-etiqueta-wk
               move desc-etiqueta15 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao15
            end-if
            if ok = "N" and desc-etiqueta16 = spaces and selecao16 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta16
               move numero-pagina   to folha-wk
               move 16              to numero-etiqueta-wk
               move desc-etiqueta16 to desc-etiqueta-wk
               move "S" to ok
               write reg-work
               move "N" to limpar-etiquetas
                           selecao16
            end-if
            if ok = "N" and desc-etiqueta17 = spaces and selecao17 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta17
               move numero-pagina   to folha-wk
               move 17              to numero-etiqueta-wk
               move desc-etiqueta17 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao17
            end-if
            if ok = "N" and desc-etiqueta18 = spaces and selecao18 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta18
               move numero-pagina   to folha-wk
               move 18              to numero-etiqueta-wk
               move desc-etiqueta18 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao18
            end-if
            if ok = "N" and desc-etiqueta19 = spaces and selecao19 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta19
               move numero-pagina   to folha-wk
               move 19              to numero-etiqueta-wk
               move desc-etiqueta19 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               move "N" to limpar-etiquetas
                           selecao19
            end-if
            if ok = "N" and desc-etiqueta20 = spaces and selecao20 = "N"
               string contrato-mt19 "/" seq-mt19 into desc-etiqueta20
               move numero-pagina   to folha-wk
               move 20              to numero-etiqueta-wk
               move desc-etiqueta20 to desc-etiqueta-wk
               write reg-work
               move "S" to ok
               add  1               to numero-pagina
               move "S" to limpar-etiquetas
                           selecao20
            end-if.
       500-incluir-fim.
           exit.

       700-imprimir-etiqueta section.
           perform 720-abrir-impressora
           if fs-ordserv <> "00"
               move "Erro ao Acessar...ETIQUETA.HTM" to mensagem
               move "C" to tipo-msg
               perform 140-exibir-mensagem
               go to 700-imprimir-etiqueta-fim.

           perform limpar-etiqueta

           move det-001                to lnk-detalhe
           perform 790-imprimir-linha
           move det-002                to lnk-detalhe
           perform 790-imprimir-linha
           move det-003                to lnk-detalhe
           perform 790-imprimir-linha
           move det-004                to lnk-detalhe
           perform 790-imprimir-linha
           move det-005                to lnk-detalhe
           perform 790-imprimir-linha
           move det-006                to lnk-detalhe
           perform 790-imprimir-linha
           move det-009                to lnk-detalhe
           perform 790-imprimir-linha
           move det-010                to lnk-detalhe
           perform 790-imprimir-linha
           move det-011                to lnk-detalhe
           perform 790-imprimir-linha
           move det-012                to lnk-detalhe
           perform 790-imprimir-linha
           move det-013                to lnk-detalhe
           perform 790-imprimir-linha
           move det-014                to lnk-detalhe
           perform 790-imprimir-linha
           move det-015                to lnk-detalhe
           perform 790-imprimir-linha
           move det-016                to lnk-detalhe
           perform 790-imprimir-linha
           move det-017                to lnk-detalhe
           perform 790-imprimir-linha
           move det-018                to lnk-detalhe
           perform 790-imprimir-linha
           move det-019                to lnk-detalhe
           perform 790-imprimir-linha
           move det-020                to lnk-detalhe
           perform 790-imprimir-linha
           move det-021                to lnk-detalhe
           perform 790-imprimir-linha
           move det-022                to lnk-detalhe
           perform 790-imprimir-linha
           move det-025                to lnk-detalhe
           perform 790-imprimir-linha

           open input work

           initialize reg-work
           move "S" to always
           move zeros to numero-pagina
           start work key is not less chave-wk invalid key
               move "10" to st-work.
           perform until st-work = "10"
               read work next at end
                   move "10" to st-work
               not at end
                   if numero-pagina <> folha-wk
                      if numero-pagina <> 0
                         perform imprimir
                         perform limpar-etiqueta
                      end-if
                      move folha-wk to numero-pagina
                   end-if
                   evaluate numero-etiqueta-wk
                      when 1  move desc-etiqueta-wk to desc-etiqueta1
                              perform mover-etiqueta1
                      when 2  move desc-etiqueta-wk to desc-etiqueta2
                              perform mover-etiqueta2
                      when 3  move desc-etiqueta-wk to desc-etiqueta3
                              perform mover-etiqueta3
                      when 4  move desc-etiqueta-wk to desc-etiqueta4
                              perform mover-etiqueta4
                      when 5  move desc-etiqueta-wk to desc-etiqueta5
                              perform mover-etiqueta5
                      when 6  move desc-etiqueta-wk to desc-etiqueta6
                              perform mover-etiqueta6
                      when 7  move desc-etiqueta-wk to desc-etiqueta7
                              perform mover-etiqueta7
                      when 8  move desc-etiqueta-wk to desc-etiqueta8
                              perform mover-etiqueta8
                      when 9  move desc-etiqueta-wk to desc-etiqueta9
                              perform mover-etiqueta9
                      when 10 move desc-etiqueta-wk to desc-etiqueta10
                              perform mover-etiqueta10
                      when 11 move desc-etiqueta-wk to desc-etiqueta11
                              perform mover-etiqueta11
                      when 12 move desc-etiqueta-wk to desc-etiqueta12
                              perform mover-etiqueta12
                      when 13 move desc-etiqueta-wk to desc-etiqueta13
                              perform mover-etiqueta13
                      when 14 move desc-etiqueta-wk to desc-etiqueta14
                              perform mover-etiqueta14
                      when 15 move desc-etiqueta-wk to desc-etiqueta15
                              perform mover-etiqueta15
                      when 16 move desc-etiqueta-wk to desc-etiqueta16
                              perform mover-etiqueta16
                      when 17 move desc-etiqueta-wk to desc-etiqueta17
                              perform mover-etiqueta17
                      when 18 move desc-etiqueta-wk to desc-etiqueta18
                              perform mover-etiqueta18
                      when 19 move desc-etiqueta-wk to desc-etiqueta19
                              perform mover-etiqueta19
                      when 20 move desc-etiqueta-wk to desc-etiqueta20
                              perform mover-etiqueta20
                   end-evaluate
               end-read
           end-perform

           close work

           move "N" to always
           perform imprimir


           move det-422 to lnk-detalhe
           perform 790-imprimir-linha

           perform 730-fechar-impressora.

       700-imprimir-etiqueta-fim.
           exit.

       limpar-etiqueta section.
           initialize campo-017   campo-018  campo-019
                      campo-020   campo-021  campo-022
                      campo-023   campo-024  campo-025
                      campo-026   campo-027  campo-028
                      campo-029   campo-030  campo-031
                      campo-032   campo-033  campo-034
                      campo-034   campo-035  campo-036
                      campo-037   campo-038  campo-039
                      campo-040   campo-041  campo-042
                      campo-043   campo-044  campo-045
                      campo-046   campo-047  campo-048
                      campo-049   campo-050  campo-051
                      campo-052   campo-053  campo-054
                      campo-055   campo-056  campo-057
                      campo-058   campo-059  campo-060
                      campo-061   campo-062  campo-063
                      campo-064   campo-065  campo-066
                      campo-067   campo-068  campo-069
                      campo-070   campo-071  campo-072
                      campo-073   campo-074  campo-075
                      campo-076   campo-077  campo-078
                      campo-079   campo-080  campo-081
                      campo-082   campo-083  campo-084
                      campo-085   campo-086  campo-087
                      campo-088   campo-089  campo-090
                      campo-091   campo-092  campo-093
                      campo-094   campo-095  campo-096
                      campo-097   campo-098  campo-099
                      campo-100   campo-101  campo-102
                      campo-103   campo-104  campo-105
                      campo-106   campo-107  campo-108
                      campo-109   campo-110  campo-111
                      campo-112   campo-113  campo-114
                      campo-115   campo-116  campo-117
                      campo-118   campo-119  campo-120
                      campo-121   campo-122  campo-123
                      campo-124   campo-125  campo-126
                      campo-127   campo-128  campo-129
                      campo-130   campo-131  campo-132
                      campo-133   campo-134  campo-135
                      campo-136   campo-137  campo-138
                      campo-139.
       limpar-etiqueta-fim.
           exit.

       mover-etiqueta1 section.
      *-----------------------------------------------------------------
      *                           1ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta1      to campo-017
           move desc-etiqueta1(1:4) to contrato-mt19
           move desc-etiqueta1(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta1 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)to campo-019
                move nome-form-mt19 to campo-023
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-025
                     move "--"       to campo-026
                not invalid key
                     move nome-cid   to campo-025
                     move uf-cid     to campo-026
                end-read
           end-read
           MOVE DESC-ETIQUETA1(6:4) to campo-020.
       mover-etiqueta1-fim.
           exit.

       mover-etiqueta2 section.
      *-----------------------------------------------------------------
      *                           2ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta2      to campo-018
           move desc-etiqueta2(1:4) to contrato-mt19
           move desc-etiqueta2(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta2 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-021
                move nome-form-mt19 to campo-024
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-027
                     move "--"       to campo-028
                not invalid key
                     move nome-cid   to campo-027
                     move uf-cid     to campo-028
                end-read
           end-read
           MOVE DESC-ETIQUETA2(6:4) TO campo-022.
       mover-etiqueta2-fim.
           exit.

       mover-etiqueta3 section.
      *-----------------------------------------------------------------
      *                           3ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta3      to campo-030
           move desc-etiqueta3(1:4) to contrato-mt19
           move desc-etiqueta3(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta3 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-032
                move nome-form-mt19 to campo-036
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-038
                     move "--"       to campo-039
                not invalid key
                     move nome-cid   to campo-038
                     move uf-cid     to campo-039
                end-read
           end-read
           MOVE DESC-ETIQUETA3(6:4) TO campo-033.
       mover-etiqueta3-fim.
           exit.

       mover-etiqueta4 section.
      *-----------------------------------------------------------------
      *                           4ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta4      to campo-031
           move desc-etiqueta4(1:4) to contrato-mt19
           move desc-etiqueta4(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta4 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-034
                move nome-form-mt19 to campo-037
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-040
                     move "--"       to campo-041
                not invalid key
                     move nome-cid   to campo-040
                     move uf-cid     to campo-041
                end-read
           end-read
           MOVE DESC-ETIQUETA4(6:4) TO campo-035.
       mover-etiqueta4-fim.
           exit.

       mover-etiqueta5 section.
      *-----------------------------------------------------------------
      *                           5ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta5      to campo-043
           move desc-etiqueta5(1:4) to contrato-mt19
           move desc-etiqueta5(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta5 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-045
                move nome-form-mt19 to campo-049
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-051
                     move "--"       to campo-052
                not invalid key
                     move nome-cid   to campo-051
                     move uf-cid     to campo-052
                end-read
           end-read
           MOVE DESC-ETIQUETA5(6:4) TO campo-046.
       mover-etiqueta5-fim.
           exit.

       mover-etiqueta6 section.
      *-----------------------------------------------------------------
      *                           6ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta6      to campo-044
           move desc-etiqueta6(1:4) to contrato-mt19
           move desc-etiqueta6(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta6 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-047
                move nome-form-mt19 to campo-050
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-053
                     move "--"       to campo-054
                not invalid key
                     move nome-cid   to campo-053
                     move uf-cid     to campo-054
                end-read
           end-read
           MOVE DESC-ETIQUETA6(6:4) TO campo-048.
       mover-etiqueta6-fim.
           exit.

       mover-etiqueta7 section.
      *-----------------------------------------------------------------
      *                           7ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta7      to campo-056
           move desc-etiqueta7(1:4) to contrato-mt19
           move desc-etiqueta7(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta7 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-058
                move nome-form-mt19 to campo-062
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-064
                     move "--"       to campo-065
                not invalid key
                     move nome-cid   to campo-064
                     move uf-cid     to campo-065
                end-read
           end-read
           MOVE DESC-ETIQUETA7(6:4) TO campo-059.
       mover-etiqueta7-fim.
           exit.

       mover-etiqueta8 section.
      *-----------------------------------------------------------------
      *                           8ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta8      to campo-057
           move desc-etiqueta8(1:4) to contrato-mt19
           move desc-etiqueta8(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta8 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-060
                move nome-form-mt19 to campo-063
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-066
                     move "--"       to campo-067
                not invalid key
                     move nome-cid   to campo-066
                     move uf-cid     to campo-067
                end-read
           end-read
           MOVE DESC-ETIQUETA8(6:4) TO campo-061.
       mover-etiqueta8-fim.
           exit.

       mover-etiqueta9 section.
      *-----------------------------------------------------------------
      *                           9ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta9      to campo-068
           move desc-etiqueta9(1:4) to contrato-mt19
           move desc-etiqueta9(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta9 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-070
                move nome-form-mt19 to campo-074
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-076
                     move "--"       to campo-077
                not invalid key
                     move nome-cid   to campo-076
                     move uf-cid     to campo-077
                end-read
           end-read
           MOVE DESC-ETIQUETA9(6:4) TO campo-071.
       mover-etiqueta9-fim.
           exit.

       mover-etiqueta10 section.
      *-----------------------------------------------------------------
      *                          10ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta10      to campo-069
           move desc-etiqueta10(1:4) to contrato-mt19
           move desc-etiqueta10(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta10 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-072
                move nome-form-mt19 to campo-075
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-078
                     move "--"       to campo-079
                not invalid key
                     move nome-cid   to campo-078
                     move uf-cid     to campo-079
                end-read
           end-read
           MOVE DESC-ETIQUETA10(6:4) TO campo-073.
       mover-etiqueta10-fim.
           exit.

       mover-etiqueta11 section.
      *-----------------------------------------------------------------
      *                          11ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta11      to campo-080
           move desc-etiqueta11(1:4) to contrato-mt19
           move desc-etiqueta11(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta11 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-082
                move nome-form-mt19 to campo-086
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-088
                     move "--"       to campo-089
                not invalid key
                     move nome-cid   to campo-088
                     move uf-cid     to campo-089
                end-read
           end-read
           MOVE DESC-ETIQUETA11(6:4) TO campo-083.
       mover-etiqueta11-fim.
           exit.

       mover-etiqueta12 section.
      *-----------------------------------------------------------------
      *                          12ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta12      to campo-081
           move desc-etiqueta12(1:4) to contrato-mt19
           move desc-etiqueta12(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta12 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-084
                move nome-form-mt19 to campo-087
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-090
                     move "--"       to campo-091
                not invalid key
                     move nome-cid   to campo-090
                     move uf-cid     to campo-091
                end-read
           end-read
           MOVE DESC-ETIQUETA12(6:4) TO campo-085.
       mover-etiqueta12-fim.
           exit.

       mover-etiqueta13 section.
      *-----------------------------------------------------------------
      *                          13ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta13      to campo-092
           move desc-etiqueta13(1:4) to contrato-mt19
           move desc-etiqueta13(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta13 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-094
                move nome-form-mt19 to campo-098
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-100
                     move "--"       to campo-101
                not invalid key
                     move nome-cid   to campo-100
                     move uf-cid     to campo-101
                end-read
           end-read
           MOVE DESC-ETIQUETA13(6:4) TO campo-095.
       mover-etiqueta13-fim.
           exit.

       mover-etiqueta14 section.
      *-----------------------------------------------------------------
      *                          14ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta14      to campo-093
           move desc-etiqueta14(1:4) to contrato-mt19
           move desc-etiqueta14(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta14 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-096
                move nome-form-mt19 to campo-099
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-102
                     move "--"       to campo-103
                not invalid key
                     move nome-cid   to campo-102
                     move uf-cid     to campo-103
                end-read
           end-read
           MOVE DESC-ETIQUETA14(6:4) TO campo-097.
       mover-etiqueta14-fim.
           exit.

       mover-etiqueta15 section.
      *-----------------------------------------------------------------
      *                          15ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta15      to campo-104
           move desc-etiqueta15(1:4) to contrato-mt19
           move desc-etiqueta15(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta15 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-106
                move nome-form-mt19 to campo-110
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-112
                     move "--"       to campo-113
                not invalid key
                     move nome-cid   to campo-112
                     move uf-cid     to campo-113
                end-read
           end-read
           MOVE DESC-ETIQUETA15(6:4) TO campo-107.
       mover-etiqueta15-fim.
           exit.

       mover-etiqueta16 section.
      *-----------------------------------------------------------------
      *                          16ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta16      to campo-105
           move desc-etiqueta16(1:4) to contrato-mt19
           move desc-etiqueta16(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta16 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-108
                move nome-form-mt19 to campo-111
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-114
                     move "--"       to campo-115
                not invalid key
                     move nome-cid   to campo-114
                     move uf-cid     to campo-115
                end-read
           end-read
           MOVE DESC-ETIQUETA16(6:4) TO campo-109.
       mover-etiqueta16-fim.
           exit.

       mover-etiqueta17 section.
      *-----------------------------------------------------------------
      *                          17ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta17      to campo-116
           move desc-etiqueta17(1:4) to contrato-mt19
           move desc-etiqueta17(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta17 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-118
                move nome-form-mt19 to campo-122
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-124
                     move "--"       to campo-125
                not invalid key
                     move nome-cid   to campo-124
                     move uf-cid     to campo-125
                end-read
           end-read
           MOVE DESC-ETIQUETA17(6:4) TO campo-119.
       mover-etiqueta17-fim.
           exit.

       mover-etiqueta18 section.
      *-----------------------------------------------------------------
      *                          18ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta18      to campo-117
           move desc-etiqueta18(1:4) to contrato-mt19
           move desc-etiqueta18(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta18 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-120
                move nome-form-mt19 to campo-123
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-126
                     move "--"       to campo-127
                not invalid key
                     move nome-cid   to campo-126
                     move uf-cid     to campo-127
                end-read
           end-read
           MOVE DESC-ETIQUETA18(6:4) TO campo-121.
       mover-etiqueta18-fim.
           exit.

       mover-etiqueta19 section.
      *-----------------------------------------------------------------
      *                          19ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta19      to campo-128
           move desc-etiqueta19(1:4) to contrato-mt19
           move desc-etiqueta19(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta19 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-130
                move nome-form-mt19 to campo-134
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-136
                     move "--"       to campo-137
                not invalid key
                     move nome-cid   to campo-136
                     move uf-cid     to campo-137
                end-read
           end-read
           MOVE DESC-ETIQUETA19(6:4) TO campo-131.
       mover-etiqueta19-fim.
           exit.

       mover-etiqueta20 section.
      *-----------------------------------------------------------------
      *                          20ª ETIQUETA
      *-----------------------------------------------------------------
           move desc-etiqueta20      to campo-129
           move desc-etiqueta20(1:4) to contrato-mt19
           move desc-etiqueta20(6:4) to seq-mt19
           read mtd019 invalid key
                string "Contrato Não Encontrado" X"0DA0"
                       desc-etiqueta20 into mensagem
                move   "C" to tipo-msg
                perform 140-exibir-mensagem
           not invalid key
                move curso-mt19     to codigo-ie11
                read ied011 invalid key
                     move "-------" to nome-ie11
                end-read
                move nome-ie11(1:25)      to campo-132
                move nome-form-mt19 to campo-135
                move cidade-mt19    to cidade
                read cad010 invalid key
                     move "--------" to campo-138
                     move "--"       to campo-139
                not invalid key
                     move nome-cid   to campo-138
                     move uf-cid     to campo-139
                end-read
           end-read
           MOVE DESC-ETIQUETA20(6:4) TO campo-133.
       mover-etiqueta20-fim.
           exit.

       imprimir section.
           if always = "S"
              move det-026         to lnk-detalhe
              perform 790-imprimir-linha
           else
              move det-026b        to lnk-detalhe
              perform 790-imprimir-linha
           end-if
           move det-028         to lnk-detalhe
           perform 790-imprimir-linha
           move det-029         to lnk-detalhe
           perform 790-imprimir-linha
           move det-030         to lnk-detalhe
           perform 790-imprimir-linha
           move det-031         to lnk-detalhe
           perform 790-imprimir-linha
           move det-032         to lnk-detalhe
           perform 790-imprimir-linha
           move det-033         to lnk-detalhe
           perform 790-imprimir-linha
           move det-034         to lnk-detalhe
           perform 790-imprimir-linha
           move det-035         to lnk-detalhe
           perform 790-imprimir-linha
           move det-036         to lnk-detalhe
           perform 790-imprimir-linha
           move det-037         to lnk-detalhe
           perform 790-imprimir-linha
           move det-038         to lnk-detalhe
           perform 790-imprimir-linha
           move det-039         to lnk-detalhe
           perform 790-imprimir-linha
           move det-040         to lnk-detalhe
           perform 790-imprimir-linha
           move det-041         to lnk-detalhe
           perform 790-imprimir-linha
           move det-042         to lnk-detalhe
           perform 790-imprimir-linha
           move det-043         to lnk-detalhe
           perform 790-imprimir-linha
           move det-044         to lnk-detalhe
           perform 790-imprimir-linha
           move det-045         to lnk-detalhe
           perform 790-imprimir-linha
           move det-046         to lnk-detalhe
           perform 790-imprimir-linha
           move det-047         to lnk-detalhe
           perform 790-imprimir-linha
           move det-048         to lnk-detalhe
           perform 790-imprimir-linha
           move det-049         to lnk-detalhe
           perform 790-imprimir-linha
           move det-050         to lnk-detalhe
           perform 790-imprimir-linha
           move det-051         to lnk-detalhe
           perform 790-imprimir-linha
           move det-052         to lnk-detalhe
           perform 790-imprimir-linha
           move det-053         to lnk-detalhe
           perform 790-imprimir-linha
           move det-054         to lnk-detalhe
           perform 790-imprimir-linha
           move det-055         to lnk-detalhe
           perform 790-imprimir-linha
           move det-056         to lnk-detalhe
           perform 790-imprimir-linha
           move det-057         to lnk-detalhe
           perform 790-imprimir-linha
           move det-058         to lnk-detalhe
           perform 790-imprimir-linha
           move det-059         to lnk-detalhe
           perform 790-imprimir-linha
           move det-060         to lnk-detalhe
           perform 790-imprimir-linha
           move det-061         to lnk-detalhe
           perform 790-imprimir-linha
           move det-062         to lnk-detalhe
           perform 790-imprimir-linha
           move det-063         to lnk-detalhe
           perform 790-imprimir-linha
           move det-064         to lnk-detalhe
           perform 790-imprimir-linha
           move det-065         to lnk-detalhe
           perform 790-imprimir-linha
           move det-066         to lnk-detalhe
           perform 790-imprimir-linha
           move det-067         to lnk-detalhe
           perform 790-imprimir-linha
           move det-068         to lnk-detalhe
           perform 790-imprimir-linha
           move det-069         to lnk-detalhe
           perform 790-imprimir-linha
           move det-070         to lnk-detalhe
           perform 790-imprimir-linha
           move det-071         to lnk-detalhe
           perform 790-imprimir-linha
           move det-072         to lnk-detalhe
           perform 790-imprimir-linha
           move det-073         to lnk-detalhe
           perform 790-imprimir-linha
           move det-074         to lnk-detalhe
           perform 790-imprimir-linha
           move det-075         to lnk-detalhe
           perform 790-imprimir-linha
           move det-076         to lnk-detalhe
           perform 790-imprimir-linha
           move det-077         to lnk-detalhe
           perform 790-imprimir-linha
           move det-078         to lnk-detalhe
           perform 790-imprimir-linha
           move det-079         to lnk-detalhe
           perform 790-imprimir-linha
           move det-080         to lnk-detalhe
           perform 790-imprimir-linha
           move det-081         to lnk-detalhe
           perform 790-imprimir-linha
           move det-082         to lnk-detalhe
           perform 790-imprimir-linha
           move det-083         to lnk-detalhe
           perform 790-imprimir-linha
           move det-084         to lnk-detalhe
           perform 790-imprimir-linha
           move det-085         to lnk-detalhe
           perform 790-imprimir-linha
           move det-086         to lnk-detalhe
           perform 790-imprimir-linha
           move det-087         to lnk-detalhe
           perform 790-imprimir-linha
           move det-088         to lnk-detalhe
           perform 790-imprimir-linha
           move det-089         to lnk-detalhe
           perform 790-imprimir-linha
           move det-090         to lnk-detalhe
           perform 790-imprimir-linha
           move det-091         to lnk-detalhe
           perform 790-imprimir-linha
           move det-092         to lnk-detalhe
           perform 790-imprimir-linha
           move det-093         to lnk-detalhe
           perform 790-imprimir-linha
           move det-094         to lnk-detalhe
           perform 790-imprimir-linha
           move det-095         to lnk-detalhe
           perform 790-imprimir-linha
           move det-096         to lnk-detalhe
           perform 790-imprimir-linha
           move det-097         to lnk-detalhe
           perform 790-imprimir-linha
           move det-098         to lnk-detalhe
           perform 790-imprimir-linha
           move det-099         to lnk-detalhe
           perform 790-imprimir-linha
           move det-100         to lnk-detalhe
           perform 790-imprimir-linha
           move det-101         to lnk-detalhe
           perform 790-imprimir-linha
           move det-102         to lnk-detalhe
           perform 790-imprimir-linha
           move det-103         to lnk-detalhe
           perform 790-imprimir-linha
           move det-104         to lnk-detalhe
           perform 790-imprimir-linha
           move det-105         to lnk-detalhe
           perform 790-imprimir-linha
           move det-106         to lnk-detalhe
           perform 790-imprimir-linha
           move det-107         to lnk-detalhe
           perform 790-imprimir-linha
           move det-108         to lnk-detalhe
           perform 790-imprimir-linha
           move det-109         to lnk-detalhe
           perform 790-imprimir-linha
           move det-110         to lnk-detalhe
           perform 790-imprimir-linha
           move det-111         to lnk-detalhe
           perform 790-imprimir-linha
           move det-112         to lnk-detalhe
           perform 790-imprimir-linha
           move det-113         to lnk-detalhe
           perform 790-imprimir-linha
           move det-114         to lnk-detalhe
           perform 790-imprimir-linha
           move det-115         to lnk-detalhe
           perform 790-imprimir-linha
           move det-116         to lnk-detalhe
           perform 790-imprimir-linha
           move det-117         to lnk-detalhe
           perform 790-imprimir-linha
           move det-118         to lnk-detalhe
           perform 790-imprimir-linha
           move det-119         to lnk-detalhe
           perform 790-imprimir-linha
           move det-120         to lnk-detalhe
           perform 790-imprimir-linha
           move det-121         to lnk-detalhe
           perform 790-imprimir-linha
           move det-122         to lnk-detalhe
           perform 790-imprimir-linha
           move det-123         to lnk-detalhe
           perform 790-imprimir-linha
           move det-124         to lnk-detalhe
           perform 790-imprimir-linha
           move det-125         to lnk-detalhe
           perform 790-imprimir-linha
           move det-126         to lnk-detalhe
           perform 790-imprimir-linha
           move det-127         to lnk-detalhe
           perform 790-imprimir-linha
           move det-128         to lnk-detalhe
           perform 790-imprimir-linha
           move det-129         to lnk-detalhe
           perform 790-imprimir-linha
           move det-130         to lnk-detalhe
           perform 790-imprimir-linha
           move det-131         to lnk-detalhe
           perform 790-imprimir-linha
           move det-132         to lnk-detalhe
           perform 790-imprimir-linha
           move det-133         to lnk-detalhe
           perform 790-imprimir-linha
           move det-134         to lnk-detalhe
           perform 790-imprimir-linha
           move det-135         to lnk-detalhe
           perform 790-imprimir-linha
           move det-136         to lnk-detalhe
           perform 790-imprimir-linha
           move det-137         to lnk-detalhe
           perform 790-imprimir-linha
           move det-138         to lnk-detalhe
           perform 790-imprimir-linha
           move det-139         to lnk-detalhe
           perform 790-imprimir-linha
           move det-140         to lnk-detalhe
           perform 790-imprimir-linha
           move det-141         to lnk-detalhe
           perform 790-imprimir-linha
           move det-142         to lnk-detalhe
           perform 790-imprimir-linha
           move det-143         to lnk-detalhe
           perform 790-imprimir-linha
           move det-144         to lnk-detalhe
           perform 790-imprimir-linha
           move det-145         to lnk-detalhe
           perform 790-imprimir-linha
           move det-146         to lnk-detalhe
           perform 790-imprimir-linha
           move det-147         to lnk-detalhe
           perform 790-imprimir-linha
           move det-148         to lnk-detalhe
           perform 790-imprimir-linha
           move det-149         to lnk-detalhe
           perform 790-imprimir-linha
           move det-150         to lnk-detalhe
           perform 790-imprimir-linha
           move det-151         to lnk-detalhe
           perform 790-imprimir-linha
           move det-152         to lnk-detalhe
           perform 790-imprimir-linha
           move det-153         to lnk-detalhe
           perform 790-imprimir-linha
           move det-154         to lnk-detalhe
           perform 790-imprimir-linha
           move det-155         to lnk-detalhe
           perform 790-imprimir-linha
           move det-156         to lnk-detalhe
           perform 790-imprimir-linha
           move det-157         to lnk-detalhe
           perform 790-imprimir-linha
           move det-158         to lnk-detalhe
           perform 790-imprimir-linha
           move det-159         to lnk-detalhe
           perform 790-imprimir-linha
           move det-160         to lnk-detalhe
           perform 790-imprimir-linha
           move det-161         to lnk-detalhe
           perform 790-imprimir-linha
           move det-162         to lnk-detalhe
           perform 790-imprimir-linha
           move det-163         to lnk-detalhe
           perform 790-imprimir-linha
           move det-164         to lnk-detalhe
           perform 790-imprimir-linha
           move det-165         to lnk-detalhe
           perform 790-imprimir-linha
           move det-166         to lnk-detalhe
           perform 790-imprimir-linha
           move det-167         to lnk-detalhe
           perform 790-imprimir-linha
           move det-168         to lnk-detalhe
           perform 790-imprimir-linha
           move det-169         to lnk-detalhe
           perform 790-imprimir-linha
           move det-170         to lnk-detalhe
           perform 790-imprimir-linha
           move det-171         to lnk-detalhe
           perform 790-imprimir-linha
           move det-172         to lnk-detalhe
           perform 790-imprimir-linha
           move det-173         to lnk-detalhe
           perform 790-imprimir-linha
           move det-174         to lnk-detalhe
           perform 790-imprimir-linha
           move det-175         to lnk-detalhe
           perform 790-imprimir-linha
           move det-176         to lnk-detalhe
           perform 790-imprimir-linha
           move det-177         to lnk-detalhe
           perform 790-imprimir-linha
           move det-178         to lnk-detalhe
           perform 790-imprimir-linha
           move det-179         to lnk-detalhe
           perform 790-imprimir-linha
           move det-180         to lnk-detalhe
           perform 790-imprimir-linha
           move det-181         to lnk-detalhe
           perform 790-imprimir-linha
           move det-182         to lnk-detalhe
           perform 790-imprimir-linha
           move det-183         to lnk-detalhe
           perform 790-imprimir-linha
           move det-184         to lnk-detalhe
           perform 790-imprimir-linha
           move det-185         to lnk-detalhe
           perform 790-imprimir-linha
           move det-186         to lnk-detalhe
           perform 790-imprimir-linha
           move det-187         to lnk-detalhe
           perform 790-imprimir-linha
           move det-188         to lnk-detalhe
           perform 790-imprimir-linha
           move det-189         to lnk-detalhe
           perform 790-imprimir-linha
           move det-190         to lnk-detalhe
           perform 790-imprimir-linha
           move det-191         to lnk-detalhe
           perform 790-imprimir-linha
           move det-192         to lnk-detalhe
           perform 790-imprimir-linha
           move det-193         to lnk-detalhe
           perform 790-imprimir-linha
           move det-194         to lnk-detalhe
           perform 790-imprimir-linha
           move det-195         to lnk-detalhe
           perform 790-imprimir-linha
           move det-196         to lnk-detalhe
           perform 790-imprimir-linha
           move det-197         to lnk-detalhe
           perform 790-imprimir-linha
           move det-198         to lnk-detalhe
           perform 790-imprimir-linha
           move det-199         to lnk-detalhe
           perform 790-imprimir-linha
           move det-200         to lnk-detalhe
           perform 790-imprimir-linha
           move det-201         to lnk-detalhe
           perform 790-imprimir-linha
           move det-202         to lnk-detalhe
           perform 790-imprimir-linha
           move det-203         to lnk-detalhe
           perform 790-imprimir-linha
           move det-204         to lnk-detalhe
           perform 790-imprimir-linha
           move det-205         to lnk-detalhe
           perform 790-imprimir-linha
           move det-206         to lnk-detalhe
           perform 790-imprimir-linha
           move det-207         to lnk-detalhe
           perform 790-imprimir-linha
           move det-208         to lnk-detalhe
           perform 790-imprimir-linha
           move det-209         to lnk-detalhe
           perform 790-imprimir-linha
           move det-210         to lnk-detalhe
           perform 790-imprimir-linha
           move det-211         to lnk-detalhe
           perform 790-imprimir-linha
           move det-212         to lnk-detalhe
           perform 790-imprimir-linha
           move det-213         to lnk-detalhe
           perform 790-imprimir-linha
           move det-214         to lnk-detalhe
           perform 790-imprimir-linha
           move det-215         to lnk-detalhe
           perform 790-imprimir-linha
           move det-216         to lnk-detalhe
           perform 790-imprimir-linha
           move det-217         to lnk-detalhe
           perform 790-imprimir-linha
           move det-218         to lnk-detalhe
           perform 790-imprimir-linha
           move det-219         to lnk-detalhe
           perform 790-imprimir-linha
           move det-220         to lnk-detalhe
           perform 790-imprimir-linha
           move det-221         to lnk-detalhe
           perform 790-imprimir-linha
           move det-222         to lnk-detalhe
           perform 790-imprimir-linha
           move det-223         to lnk-detalhe
           perform 790-imprimir-linha
           move det-224         to lnk-detalhe
           perform 790-imprimir-linha
           move det-225         to lnk-detalhe
           perform 790-imprimir-linha
           move det-226         to lnk-detalhe
           perform 790-imprimir-linha
           move det-227         to lnk-detalhe
           perform 790-imprimir-linha
           move det-228         to lnk-detalhe
           perform 790-imprimir-linha
           move det-229         to lnk-detalhe
           perform 790-imprimir-linha
           move det-230         to lnk-detalhe
           perform 790-imprimir-linha
           move det-231         to lnk-detalhe
           perform 790-imprimir-linha
           move det-232         to lnk-detalhe
           perform 790-imprimir-linha
           move det-233         to lnk-detalhe
           perform 790-imprimir-linha
           move det-234         to lnk-detalhe
           perform 790-imprimir-linha
           move det-235         to lnk-detalhe
           perform 790-imprimir-linha
           move det-236         to lnk-detalhe
           perform 790-imprimir-linha
           move det-237         to lnk-detalhe
           perform 790-imprimir-linha
           move det-238         to lnk-detalhe
           perform 790-imprimir-linha
           move det-239         to lnk-detalhe
           perform 790-imprimir-linha
           move det-240         to lnk-detalhe
           perform 790-imprimir-linha
           move det-241         to lnk-detalhe
           perform 790-imprimir-linha
           move det-242         to lnk-detalhe
           perform 790-imprimir-linha
           move det-243         to lnk-detalhe
           perform 790-imprimir-linha
           move det-244         to lnk-detalhe
           perform 790-imprimir-linha
           move det-245         to lnk-detalhe
           perform 790-imprimir-linha
           move det-246         to lnk-detalhe
           perform 790-imprimir-linha
           move det-247         to lnk-detalhe
           perform 790-imprimir-linha
           move det-248         to lnk-detalhe
           perform 790-imprimir-linha
           move det-249         to lnk-detalhe
           perform 790-imprimir-linha
           move det-250         to lnk-detalhe
           perform 790-imprimir-linha
           move det-251         to lnk-detalhe
           perform 790-imprimir-linha
           move det-252         to lnk-detalhe
           perform 790-imprimir-linha
           move det-253         to lnk-detalhe
           perform 790-imprimir-linha
           move det-254         to lnk-detalhe
           perform 790-imprimir-linha
           move det-255         to lnk-detalhe
           perform 790-imprimir-linha
           move det-256         to lnk-detalhe
           perform 790-imprimir-linha
           move det-257         to lnk-detalhe
           perform 790-imprimir-linha
           move det-258         to lnk-detalhe
           perform 790-imprimir-linha
           move det-259         to lnk-detalhe
           perform 790-imprimir-linha
           move det-260         to lnk-detalhe
           perform 790-imprimir-linha
           move det-261         to lnk-detalhe
           perform 790-imprimir-linha
           move det-262         to lnk-detalhe
           perform 790-imprimir-linha
           move det-263         to lnk-detalhe
           perform 790-imprimir-linha
           move det-264         to lnk-detalhe
           perform 790-imprimir-linha
           move det-265         to lnk-detalhe
           perform 790-imprimir-linha
           move det-266         to lnk-detalhe
           perform 790-imprimir-linha
           move det-267         to lnk-detalhe
           perform 790-imprimir-linha
           move det-268         to lnk-detalhe
           perform 790-imprimir-linha
           move det-269         to lnk-detalhe
           perform 790-imprimir-linha
           move det-270         to lnk-detalhe
           perform 790-imprimir-linha
           move det-271         to lnk-detalhe
           perform 790-imprimir-linha
           move det-272         to lnk-detalhe
           perform 790-imprimir-linha
           move det-273         to lnk-detalhe
           perform 790-imprimir-linha
           move det-274         to lnk-detalhe
           perform 790-imprimir-linha
           move det-275         to lnk-detalhe
           perform 790-imprimir-linha
           move det-276         to lnk-detalhe
           perform 790-imprimir-linha
           move det-277         to lnk-detalhe
           perform 790-imprimir-linha
           move det-278         to lnk-detalhe
           perform 790-imprimir-linha
           move det-279         to lnk-detalhe
           perform 790-imprimir-linha
           move det-280         to lnk-detalhe
           perform 790-imprimir-linha
           move det-281         to lnk-detalhe
           perform 790-imprimir-linha
           move det-282         to lnk-detalhe
           perform 790-imprimir-linha
           move det-283         to lnk-detalhe
           perform 790-imprimir-linha
           move det-284         to lnk-detalhe
           perform 790-imprimir-linha
           move det-285         to lnk-detalhe
           perform 790-imprimir-linha
           move det-286         to lnk-detalhe
           perform 790-imprimir-linha
           move det-287         to lnk-detalhe
           perform 790-imprimir-linha
           move det-288         to lnk-detalhe
           perform 790-imprimir-linha
           move det-289         to lnk-detalhe
           perform 790-imprimir-linha
           move det-290         to lnk-detalhe
           perform 790-imprimir-linha
           move det-291         to lnk-detalhe
           perform 790-imprimir-linha
           move det-292         to lnk-detalhe
           perform 790-imprimir-linha
           move det-293         to lnk-detalhe
           perform 790-imprimir-linha
           move det-294         to lnk-detalhe
           perform 790-imprimir-linha
           move det-295         to lnk-detalhe
           perform 790-imprimir-linha
           move det-296         to lnk-detalhe
           perform 790-imprimir-linha
           move det-297         to lnk-detalhe
           perform 790-imprimir-linha
           move det-298         to lnk-detalhe
           perform 790-imprimir-linha
           move det-299         to lnk-detalhe
           perform 790-imprimir-linha
           move det-300         to lnk-detalhe
           perform 790-imprimir-linha
           move det-301         to lnk-detalhe
           perform 790-imprimir-linha
           move det-302         to lnk-detalhe
           perform 790-imprimir-linha
           move det-303         to lnk-detalhe
           perform 790-imprimir-linha
           move det-304         to lnk-detalhe
           perform 790-imprimir-linha
           move det-305         to lnk-detalhe
           perform 790-imprimir-linha
           move det-306         to lnk-detalhe
           perform 790-imprimir-linha
           move det-307         to lnk-detalhe
           perform 790-imprimir-linha
           move det-308         to lnk-detalhe
           perform 790-imprimir-linha
           move det-309         to lnk-detalhe
           perform 790-imprimir-linha
           move det-310         to lnk-detalhe
           perform 790-imprimir-linha
           move det-311         to lnk-detalhe
           perform 790-imprimir-linha
           move det-312         to lnk-detalhe
           perform 790-imprimir-linha
           move det-313         to lnk-detalhe
           perform 790-imprimir-linha
           move det-314         to lnk-detalhe
           perform 790-imprimir-linha
           move det-315         to lnk-detalhe
           perform 790-imprimir-linha
           move det-316         to lnk-detalhe
           perform 790-imprimir-linha
           move det-317         to lnk-detalhe
           perform 790-imprimir-linha
           move det-318         to lnk-detalhe
           perform 790-imprimir-linha
           move det-319         to lnk-detalhe
           perform 790-imprimir-linha
           move det-320         to lnk-detalhe
           perform 790-imprimir-linha
           move det-321         to lnk-detalhe
           perform 790-imprimir-linha
           move det-322         to lnk-detalhe
           perform 790-imprimir-linha
           move det-323         to lnk-detalhe
           perform 790-imprimir-linha
           move det-324         to lnk-detalhe
           perform 790-imprimir-linha
           move det-325         to lnk-detalhe
           perform 790-imprimir-linha
           move det-326         to lnk-detalhe
           perform 790-imprimir-linha
           move det-327         to lnk-detalhe
           perform 790-imprimir-linha
           move det-328         to lnk-detalhe
           perform 790-imprimir-linha
           move det-329         to lnk-detalhe
           perform 790-imprimir-linha
           move det-330         to lnk-detalhe
           perform 790-imprimir-linha
           move det-331         to lnk-detalhe
           perform 790-imprimir-linha
           move det-332         to lnk-detalhe
           perform 790-imprimir-linha
           move det-333         to lnk-detalhe
           perform 790-imprimir-linha
           move det-334         to lnk-detalhe
           perform 790-imprimir-linha
           move det-335         to lnk-detalhe
           perform 790-imprimir-linha
           move det-336         to lnk-detalhe
           perform 790-imprimir-linha
           move det-337         to lnk-detalhe
           perform 790-imprimir-linha
           move det-338         to lnk-detalhe
           perform 790-imprimir-linha
           move det-339         to lnk-detalhe
           perform 790-imprimir-linha
           move det-340         to lnk-detalhe
           perform 790-imprimir-linha
           move det-341         to lnk-detalhe
           perform 790-imprimir-linha
           move det-342         to lnk-detalhe
           perform 790-imprimir-linha
           move det-343         to lnk-detalhe
           perform 790-imprimir-linha
           move det-344         to lnk-detalhe
           perform 790-imprimir-linha
           move det-345         to lnk-detalhe
           perform 790-imprimir-linha
           move det-346         to lnk-detalhe
           perform 790-imprimir-linha
           move det-347         to lnk-detalhe
           perform 790-imprimir-linha
           move det-348         to lnk-detalhe
           perform 790-imprimir-linha
           move det-349         to lnk-detalhe
           perform 790-imprimir-linha
           move det-350         to lnk-detalhe
           perform 790-imprimir-linha
           move det-351         to lnk-detalhe
           perform 790-imprimir-linha
           move det-352         to lnk-detalhe
           perform 790-imprimir-linha
           move det-353         to lnk-detalhe
           perform 790-imprimir-linha
           move det-354         to lnk-detalhe
           perform 790-imprimir-linha
           move det-355         to lnk-detalhe
           perform 790-imprimir-linha
           move det-356         to lnk-detalhe
           perform 790-imprimir-linha
           move det-357         to lnk-detalhe
           perform 790-imprimir-linha
           move det-358         to lnk-detalhe
           perform 790-imprimir-linha
           move det-359         to lnk-detalhe
           perform 790-imprimir-linha
           move det-360         to lnk-detalhe
           perform 790-imprimir-linha
           move det-361         to lnk-detalhe
           perform 790-imprimir-linha
           move det-362         to lnk-detalhe
           perform 790-imprimir-linha
           move det-363         to lnk-detalhe
           perform 790-imprimir-linha
           move det-364         to lnk-detalhe
           perform 790-imprimir-linha
           move det-365         to lnk-detalhe
           perform 790-imprimir-linha
           move det-366         to lnk-detalhe
           perform 790-imprimir-linha
           move det-367         to lnk-detalhe
           perform 790-imprimir-linha
           move det-368         to lnk-detalhe
           perform 790-imprimir-linha
           move det-369         to lnk-detalhe
           perform 790-imprimir-linha
           move det-370         to lnk-detalhe
           perform 790-imprimir-linha
           move det-371         to lnk-detalhe
           perform 790-imprimir-linha
           move det-372         to lnk-detalhe
           perform 790-imprimir-linha
           move det-373         to lnk-detalhe
           perform 790-imprimir-linha
           move det-374         to lnk-detalhe
           perform 790-imprimir-linha
           move det-375         to lnk-detalhe
           perform 790-imprimir-linha
           move det-376         to lnk-detalhe
           perform 790-imprimir-linha
           move det-377         to lnk-detalhe
           perform 790-imprimir-linha
           move det-378         to lnk-detalhe
           perform 790-imprimir-linha
           move det-379         to lnk-detalhe
           perform 790-imprimir-linha
           move det-380         to lnk-detalhe
           perform 790-imprimir-linha
           move det-381         to lnk-detalhe
           perform 790-imprimir-linha
           move det-382         to lnk-detalhe
           perform 790-imprimir-linha
           move det-383         to lnk-detalhe
           perform 790-imprimir-linha
           move det-384         to lnk-detalhe
           perform 790-imprimir-linha
           move det-385         to lnk-detalhe
           perform 790-imprimir-linha
           move det-386         to lnk-detalhe
           perform 790-imprimir-linha
           move det-387         to lnk-detalhe
           perform 790-imprimir-linha
           move det-388         to lnk-detalhe
           perform 790-imprimir-linha
           move det-389         to lnk-detalhe
           perform 790-imprimir-linha
           move det-390         to lnk-detalhe
           perform 790-imprimir-linha
           move det-391         to lnk-detalhe
           perform 790-imprimir-linha
           move det-392         to lnk-detalhe
           perform 790-imprimir-linha
           move det-393         to lnk-detalhe
           perform 790-imprimir-linha
           move det-394         to lnk-detalhe
           perform 790-imprimir-linha
           move det-395         to lnk-detalhe
           perform 790-imprimir-linha
           move det-396         to lnk-detalhe
           perform 790-imprimir-linha
           move det-397         to lnk-detalhe
           perform 790-imprimir-linha
           move det-398         to lnk-detalhe
           perform 790-imprimir-linha
           move det-399         to lnk-detalhe
           perform 790-imprimir-linha
           move det-400         to lnk-detalhe
           perform 790-imprimir-linha
           move det-401         to lnk-detalhe
           perform 790-imprimir-linha
           move det-402         to lnk-detalhe
           perform 790-imprimir-linha
           move det-403         to lnk-detalhe
           perform 790-imprimir-linha
           move det-404         to lnk-detalhe
           perform 790-imprimir-linha
           move det-405         to lnk-detalhe
           perform 790-imprimir-linha
           move det-406         to lnk-detalhe
           perform 790-imprimir-linha
           move det-407         to lnk-detalhe
           perform 790-imprimir-linha
           move det-408         to lnk-detalhe
           perform 790-imprimir-linha
           move det-409         to lnk-detalhe
           perform 790-imprimir-linha
           move det-410         to lnk-detalhe
           perform 790-imprimir-linha
           move det-411         to lnk-detalhe
           perform 790-imprimir-linha
           move det-412         to lnk-detalhe
           perform 790-imprimir-linha
           move det-413         to lnk-detalhe
           perform 790-imprimir-linha
           move det-414         to lnk-detalhe
           perform 790-imprimir-linha
           move det-415         to lnk-detalhe
           perform 790-imprimir-linha
           move det-416         to lnk-detalhe
           perform 790-imprimir-linha
           move det-417         to lnk-detalhe
           perform 790-imprimir-linha
           move det-418         to lnk-detalhe
           perform 790-imprimir-linha
           move det-419         to lnk-detalhe
           perform 790-imprimir-linha
           move det-420         to lnk-detalhe
           perform 790-imprimir-linha
           move det-421         to lnk-detalhe
           perform 790-imprimir-linha.
       imprimir-fim.
           exit.


       720-abrir-impressora section.
          STRING "c:\tempsis\" USUARIO-W ".HTM" INTO ARQUIVO-ORDSERV
          OPEN OUTPUT ORDSERV.

      *    open output relat
      *
      *    move lh01    to regrel
      *    write regrel
      *    move lh02    to regrel
      *    write regrel
      *    move lh03    to regrel
      *    write regrel
      *    move lh04    to regrel
      *    write regrel
      *    move lh05    to regrel
      *    write regrel
      *    move lh06    to regrel
      *    write regrel
      *    move lh07    to regrel
      *    write regrel
      *    move lh08    to regrel
      *    write regrel
      *    move lh09    to regrel
      *    write regrel
      *    move lh10    to regrel
      *    write regrel
      *    move lh11    to regrel
      *    write regrel.
       720-abrir-impressora-fim.
           exit.

       730-fechar-impressora section.
      *    close relat.
           close ordserv.
       730-fechar-impressora-fim.
           exit.

       790-imprimir-linha section.
           move lnk-detalhe        to reg-ordserv
           write reg-ordserv.
       790-imprimir-linha-fim.
           exit.

       800-etiqueta-numerica section.
           move "Não foi desenvolvido" to mensagem
           move "C" to tipo-msg
           perform 140-exibir-mensagem.
      *    open output relat

      *    move lh01-N    to regrel
      *    write regrel
      *    move lh02-N    to regrel
      *    write regrel
      *    move lh03-N    to regrel
      *    write regrel
      *    move lh04-N    to regrel
      *    write regrel
      *    move lh05-N    to regrel
      *    write regrel
      *    move lh06-N    to regrel
      *    write regrel
      *    move lh07-N    to regrel
      *    write regrel
      *    move lh08-N    to regrel
      *    write regrel
      *    move lh09-N    to regrel
      *    write regrel
      *    move lh10-N    to regrel
      *    write regrel
      *    move lh11-N    to regrel
      *    write regrel.
      *
      *    open input work
      *
      *    initialize reg-work
      *               controle
      *    start work key is not less chave-wk invalid key
      *        move "10" to st-work.
      *    perform until st-work = "10"
      *        read work next at end
      *            move "10" to st-work
      *        not at end
      *            add 1 to controle
      *
      *            evaluate controle
      *                when 1 move lh10-N           to regrel
      *                       write regrel
      *                       move desc-etiqueta-wk to lh12-n1-p8-texto
      *                       move "."         to lh12-n1-p8-texto(5:1)
      *                       move lh12-N1          to regrel
      *                       write regrel
      *                when 2 move desc-etiqueta-wk to lh12-n2-p8-texto
      *                       move "."         to lh12-n2-p8-texto(5:1)
      *                       move lh12-N2          to regrel
      *                       write regrel
      *                when 3 move desc-etiqueta-wk to lh12-n3-p8-texto
      *                       move "."         to lh12-n3-p8-texto(5:1)
      *                       move lh12-N3          to regrel
      *                       write regrel
      *                when 4 move desc-etiqueta-wk to lh12-n4-p8-texto
      *                       move "."         to lh12-n4-p8-texto(5:1)
      *                       move lh12-N4          to regrel
      *                       write regrel
      *                       move lh16-N           to regrel
      *                       write regrel
      *                       move 0                to controle
      *            end-evaluate
      *        end-read
      *    end-perform
      *
      *    if controle <> 0
      *       move lh16-N                to regrel
      *       write regrel.
      *
      *    close work
      *
      *    close relat.
       800-etiqueta-numerica-fim.
           exit.
