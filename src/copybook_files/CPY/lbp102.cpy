      $IF SYS-CONSTANTS NOT DEFINED
       01  SYS-CONSTANTS.
           03  SYS-NULL       PIC 9(8) COMP-X VALUE H"01000000".
           03  SYS-CONTROL    PIC 9(8) COMP-X VALUE H"02000000".
           03  SYS-WINDOW     PIC 9(8) COMP-X VALUE H"03000000".
      $END

       01  filler.

       03  PRINCIPAL                       PIC 9(8) COMP-X VALUE 1.
       03  GBOX1                           PIC 9(8) COMP-X VALUE 2.
       03  D-MOVTO                         PIC 9(8) COMP-X VALUE 3.
       03  EF9                             PIC 9(8) COMP-X VALUE 4.
       03  D-CONTRATO                      PIC 9(8) COMP-X VALUE 5.
       03  EF20                            PIC 9(8) COMP-X VALUE 6.
       03  EF48                            PIC 9(8) COMP-X VALUE 7.
       03  EF52                            PIC 9(8) COMP-X VALUE 8.
       03  EF1                             PIC 9(8) COMP-X VALUE 9.
       03  EF2                             PIC 9(8) COMP-X VALUE 10.
       03  EF15                            PIC 9(8) COMP-X VALUE 11.
       03  EF6                             PIC 9(8) COMP-X VALUE 12.
       03  EF4                             PIC 9(8) COMP-X VALUE 13.
       03  EF16                            PIC 9(8) COMP-X VALUE 14.
       03  EF3                             PIC 9(8) COMP-X VALUE 15.
       03  EF5                             PIC 9(8) COMP-X VALUE 16.
       03  PB1                             PIC 9(8) COMP-X VALUE 17.
       03  PB2                             PIC 9(8) COMP-X VALUE 18.
       03  PB3                             PIC 9(8) COMP-X VALUE 19.
       03  PB11                            PIC 9(8) COMP-X VALUE 20.
       03  LB1                             PIC 9(8) COMP-X VALUE 21.
       03  PB6                             PIC 9(8) COMP-X VALUE 22.
       03  PB7                             PIC 9(8) COMP-X VALUE 23.
       03  GBOX2                           PIC 9(8) COMP-X VALUE 24.
       03  MBOX1                           PIC 9(8) COMP-X VALUE 25.
       03  MBOX-ERROS                      PIC 9(8) COMP-X VALUE 26.
       03  MBOX6                           PIC 9(8) COMP-X VALUE 27.
       03  AJUDA                           PIC 9(8) COMP-X VALUE 28.
       03  PB8                             PIC 9(8) COMP-X VALUE 29.
       03  MBOX5                           PIC 9(8) COMP-X VALUE 30.
