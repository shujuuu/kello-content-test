      $IF SYS-CONSTANTS NOT DEFINED
       01  SYS-CONSTANTS.
           03  SYS-NULL       PIC 9(8) COMP-X VALUE H"01000000".
           03  SYS-CONTROL    PIC 9(8) COMP-X VALUE H"02000000".
           03  SYS-WINDOW     PIC 9(8) COMP-X VALUE H"03000000".
      $END

       01  filler.

       03  PRINCIPAL                       PIC 9(8) COMP-X VALUE 1.
       03  GBOX1                           PIC 9(8) COMP-X VALUE 2.
       03  D-DATA-MOVTO                    PIC 9(8) COMP-X VALUE 3.
       03  SB3                             PIC 9(8) COMP-X VALUE 4.
       03  EF7                             PIC 9(8) COMP-X VALUE 5.
       03  D-COD-CLIENTE                   PIC 9(8) COMP-X VALUE 6.
       03  EF2                             PIC 9(8) COMP-X VALUE 7.
       03  EF10                            PIC 9(8) COMP-X VALUE 8.
       03  EF3                             PIC 9(8) COMP-X VALUE 9.
       03  SB1                             PIC 9(8) COMP-X VALUE 10.
       03  EF-CARTAO                       PIC 9(8) COMP-X VALUE 11.
       03  EF4                             PIC 9(8) COMP-X VALUE 12.
       03  SB2                             PIC 9(8) COMP-X VALUE 13.
       03  EF6                             PIC 9(8) COMP-X VALUE 14.
       03  EF5                             PIC 9(8) COMP-X VALUE 15.
       03  EF8                             PIC 9(8) COMP-X VALUE 16.
       03  EF9                             PIC 9(8) COMP-X VALUE 17.
       03  EF48                            PIC 9(8) COMP-X VALUE 18.
       03  SB6                             PIC 9(8) COMP-X VALUE 19.
       03  EF11                            PIC 9(8) COMP-X VALUE 20.
       03  EF12                            PIC 9(8) COMP-X VALUE 21.
       03  EF14                            PIC 9(8) COMP-X VALUE 22.
       03  EF13                            PIC 9(8) COMP-X VALUE 23.
       03  PB1                             PIC 9(8) COMP-X VALUE 24.
       03  PB2                             PIC 9(8) COMP-X VALUE 25.
       03  PB3                             PIC 9(8) COMP-X VALUE 26.
       03  PB4                             PIC 9(8) COMP-X VALUE 27.
       03  PB11                            PIC 9(8) COMP-X VALUE 28.
       03  LB1                             PIC 9(8) COMP-X VALUE 29.
       03  PB6                             PIC 9(8) COMP-X VALUE 30.
       03  PB7                             PIC 9(8) COMP-X VALUE 31.
       03  EF20                            PIC 9(8) COMP-X VALUE 32.
       03  EF16                            PIC 9(8) COMP-X VALUE 33.
       03  EF17                            PIC 9(8) COMP-X VALUE 34.
       03  EF18                            PIC 9(8) COMP-X VALUE 35.
       03  GBOX2                           PIC 9(8) COMP-X VALUE 36.
       03  EF52                            PIC 9(8) COMP-X VALUE 37.
       03  CB1                             PIC 9(8) COMP-X VALUE 38.
       03  GBOX3                           PIC 9(8) COMP-X VALUE 39.
       03  D-DIGITADOR                     PIC 9(8) COMP-X VALUE 40.
       03  PB12                            PIC 9(8) COMP-X VALUE 41.
       03  EF15                            PIC 9(8) COMP-X VALUE 42.
       03  MBOX1                           PIC 9(8) COMP-X VALUE 43.
       03  MBOX-ERROS                      PIC 9(8) COMP-X VALUE 44.
       03  MBOX6                           PIC 9(8) COMP-X VALUE 45.
       03  MBOX2                           PIC 9(8) COMP-X VALUE 46.
       03  AJUDA                           PIC 9(8) COMP-X VALUE 47.
       03  PB8                             PIC 9(8) COMP-X VALUE 48.
       03  WIN1                            PIC 9(8) COMP-X VALUE 49.
       03  EF1                             PIC 9(8) COMP-X VALUE 50.
       03  EF61                            PIC 9(8) COMP-X VALUE 51.
       03  EF62                            PIC 9(8) COMP-X VALUE 52.
       03  EF63                            PIC 9(8) COMP-X VALUE 53.
       03  EF64                            PIC 9(8) COMP-X VALUE 54.
       03  EF65                            PIC 9(8) COMP-X VALUE 55.
       03  EF66                            PIC 9(8) COMP-X VALUE 56.
       03  EF67                            PIC 9(8) COMP-X VALUE 57.
       03  EF68                            PIC 9(8) COMP-X VALUE 58.
       03  EF69                            PIC 9(8) COMP-X VALUE 59.
       03  EF70                            PIC 9(8) COMP-X VALUE 60.
       03  EF71                            PIC 9(8) COMP-X VALUE 61.
       03  EF72                            PIC 9(8) COMP-X VALUE 62.
       03  EF73                            PIC 9(8) COMP-X VALUE 63.
       03  EF74                            PIC 9(8) COMP-X VALUE 64.
       03  EF75                            PIC 9(8) COMP-X VALUE 65.
       03  EF76                            PIC 9(8) COMP-X VALUE 66.
       03  EF77                            PIC 9(8) COMP-X VALUE 67.
       03  EF78                            PIC 9(8) COMP-X VALUE 68.
       03  EF79                            PIC 9(8) COMP-X VALUE 69.
       03  EF80                            PIC 9(8) COMP-X VALUE 70.
       03  EF81                            PIC 9(8) COMP-X VALUE 71.
       03  EF82                            PIC 9(8) COMP-X VALUE 72.
       03  EF83                            PIC 9(8) COMP-X VALUE 73.
       03  EF84                            PIC 9(8) COMP-X VALUE 74.
       03  EF85                            PIC 9(8) COMP-X VALUE 75.
       03  EF86                            PIC 9(8) COMP-X VALUE 76.
       03  EF87                            PIC 9(8) COMP-X VALUE 77.
       03  EF88                            PIC 9(8) COMP-X VALUE 78.
       03  EF89                            PIC 9(8) COMP-X VALUE 79.
       03  EF90                            PIC 9(8) COMP-X VALUE 80.
       03  EF91                            PIC 9(8) COMP-X VALUE 81.
       03  EF92                            PIC 9(8) COMP-X VALUE 82.
       03  EF93                            PIC 9(8) COMP-X VALUE 83.
       03  EF94                            PIC 9(8) COMP-X VALUE 84.
       03  EF95                            PIC 9(8) COMP-X VALUE 85.
       03  EF96                            PIC 9(8) COMP-X VALUE 86.
       03  GBOX4                           PIC 9(8) COMP-X VALUE 87.
       03  EF97                            PIC 9(8) COMP-X VALUE 88.
       03  EF98                            PIC 9(8) COMP-X VALUE 89.
       03  EF99                            PIC 9(8) COMP-X VALUE 90.
       03  EF100                           PIC 9(8) COMP-X VALUE 91.
       03  EF101                           PIC 9(8) COMP-X VALUE 92.
       03  EF102                           PIC 9(8) COMP-X VALUE 93.
       03  EF103                           PIC 9(8) COMP-X VALUE 94.
       03  EF104                           PIC 9(8) COMP-X VALUE 95.
       03  EF105                           PIC 9(8) COMP-X VALUE 96.
       03  EF106                           PIC 9(8) COMP-X VALUE 97.
       03  EF107                           PIC 9(8) COMP-X VALUE 98.
       03  EF108                           PIC 9(8) COMP-X VALUE 99.
       03  EF109                           PIC 9(8) COMP-X VALUE 100.
       03  EF110                           PIC 9(8) COMP-X VALUE 101.
       03  EF111                           PIC 9(8) COMP-X VALUE 102.
       03  EF112                           PIC 9(8) COMP-X VALUE 103.
       03  EF113                           PIC 9(8) COMP-X VALUE 104.
       03  EF114                           PIC 9(8) COMP-X VALUE 105.
       03  EF115                           PIC 9(8) COMP-X VALUE 106.
       03  EF116                           PIC 9(8) COMP-X VALUE 107.
       03  EF117                           PIC 9(8) COMP-X VALUE 108.
       03  EF118                           PIC 9(8) COMP-X VALUE 109.
       03  EF119                           PIC 9(8) COMP-X VALUE 110.
       03  EF120                           PIC 9(8) COMP-X VALUE 111.
       03  EF121                           PIC 9(8) COMP-X VALUE 112.
       03  EF122                           PIC 9(8) COMP-X VALUE 113.
       03  EF123                           PIC 9(8) COMP-X VALUE 114.
       03  EF124                           PIC 9(8) COMP-X VALUE 115.
       03  EF125                           PIC 9(8) COMP-X VALUE 116.
       03  EF126                           PIC 9(8) COMP-X VALUE 117.
       03  EF127                           PIC 9(8) COMP-X VALUE 118.
       03  EF128                           PIC 9(8) COMP-X VALUE 119.
       03  EF129                           PIC 9(8) COMP-X VALUE 120.
       03  EF130                           PIC 9(8) COMP-X VALUE 121.
       03  EF131                           PIC 9(8) COMP-X VALUE 122.
       03  EF132                           PIC 9(8) COMP-X VALUE 123.
       03  GBOX5                           PIC 9(8) COMP-X VALUE 124.
       03  PB10                            PIC 9(8) COMP-X VALUE 125.
       03  PB9                             PIC 9(8) COMP-X VALUE 126.
       03  MBOX4                           PIC 9(8) COMP-X VALUE 127.
       03  WIN4                            PIC 9(8) COMP-X VALUE 128.
       03  SB4                             PIC 9(8) COMP-X VALUE 129.
       03  WIN5                            PIC 9(8) COMP-X VALUE 130.
       03  SB5                             PIC 9(8) COMP-X VALUE 131.
       03  MBOX9                           PIC 9(8) COMP-X VALUE 132.
       03  MBOX10                          PIC 9(8) COMP-X VALUE 133.
       03  WIN3                            PIC 9(8) COMP-X VALUE 134.
       03  SB7                             PIC 9(8) COMP-X VALUE 135.
       03  WIN6                            PIC 9(8) COMP-X VALUE 136.
       03  MLE1                            PIC 9(8) COMP-X VALUE 137.
       03  PB5                             PIC 9(8) COMP-X VALUE 138.
       03  PB14                            PIC 9(8) COMP-X VALUE 139.
