; A-3

                                ;-------------------------------------------------------------------
                                ; <CAVEAT EMPTOR>:
                                ;
                                ;     THE  BIOS  ROUTINES ARE MEANT TO BE ACCESSED THROUGH
                                ;     SOFTWARE INTERRUPTS ONLY.   ANY ADDRESSES PRESENT IN
                                ;     THE LISTINGS  ARE  INCLUDED   ONLY FOR  COMPLETENESS,
                                ;     NOT FOR REFERENCE.   APPLICATIONS  WHICH   REFERENCE
                                ;     ABSOLUTE ADDRESSES   WITHIN THIS  CODE  VIOLATE  THE
                                ;     STRUCTURE AND DESIGN OF BIOS.
                                ;-------------------------------------------------------------------
                                ;-------------------------------------------
                                ;                EQUATES
                                ;-------------------------------------------
= 0060                          PORT_A          EQU     60H         ; 8255 PORT A ADDR
= 0038                          CPUREG          EQU     38H         ; MASK FOR CPU REG BITS
= 0007                          CRTREG          EQU     7           ; MASK FOR CRT REG BITS
= 0061                          PORT_B          EQU     61H         ; 8255 PORT B ADDR
= 0062                          PORT_C          EQU     62H         ; 8255 PORT C ADDR
= 0063                          CMD_PORT        EQU     63H
= 0089                          MODE_8255       EQU     10001001B
= 0020                          INTA00          EQU     20H         ; 8259 PORT
= 0021                          INTA01          EQU     21H         ; 8259 PORT
= 0020                          EOI             EQU     20H
= 0040                          TIMER           EQU     40H
= 0043                          TIM_CTL         EQU     43H         ; 8253 TIMER CONTROL PORT ADDR
= 0040                          TIMER0          EQU     40H         ; 8253 TIMER/CNTER 0 PORT ADDR
= 0061                          KB_CTL          EQU     61H         ; CONTROL BITS FOR KEYBOARD
= 03DA                          VGA_CTL         EQU     03DAH       ; VIDEO GATE ARRAY CONTROL PORT
= 00A0                          NMI_PORT        EQU     0A0H        ; NMI CONTROL PORT
= 00B0                          PORT_B0         EQU     0B0H
= 03DF                          PAGREG          EQU     03DFH       ; CRT/CPU PAGE REGISTER
= 0060                          KBPORT          EQU     060H        ; KEYBOARD PORT
= 4000                          DIAG_TABLE_PTR  EQU     4000H
= 2000                          MINI            EQU     2000H
                                ;-------------------------------------------
                                ;            DISKETTE EQUATES
                                ;-------------------------------------------
= 00F2                          NEC_CTL         EQU     0F2H        ; CONTROL PORT FOR THE DISKETTE
= 0080                          FDC_RESET       EQU     80H         ; RESETS THE NEC (FLOPPY DISK
                                                                    ; CONTROLLER).  0 RESETS,
                                                                    ; 1 RELEASES THE RESET
= 0020                          WD_ENABLE       EQU     20H         ; ENABLES WATCH DOG TIMER IN NEC
= 0040                          WD_STROBE       EQU     40H         ; STROBES WATCHDOG TIMER
= 0001                          DRIVE_ENABLE    EQU     01H         ; SELECTS AND ENABLES DRIVE

= 00F4                          NEC_STAT        EQU     0F4H        ; STATUS REGISTER FOR THE NEC
= 0020                          BUSY_BIT        EQU     20H         ; BIT = 0 AT END OF EXECUTION PHASE
= 0040                          DIO             EQU     40H         ; INDICATES DIRECTION OF TRANSFER
= 0080                          RQM             EQU     80H         ; REQUEST FOR MASTER
= 00F5                          NEC_DATA        EQU     0F5H        ; DATA PORT FOR THE NEC
                                ;-------------------------------------------
                                ;         8088 INTERRUPT LOCATIONS
                                ;-------------------------------------------
0000                            ABS0            SEGMENT AT 0
0000                                    ORG     2*4
0008                            NMI_PTR         LABEL   WORD
0008                                    ORG     3*4
000C                            INT3_PTR        LABEL   WORD
000C                                    ORG     5*4
0014                            INT5_PTR        LABEL   WORD
0014                                    ORG     8*4
0020                            INT_PTR         LABEL   DWORD
0020                                    ORG     10H*4
0040                            VIDEO_INT       LABEL   WORD
0040                                    ORG     1CH*4
0070                            INT1C_PTR       LABEL   WORD
0070                                    ORG     1DH*4
0074                            PARM_PTR        LABEL   DWORD       ; POINTER TO VIDEO PARMS
0074                                    ORG     18H*4
0060                            BASIC_PTR       LABEL   WORD        ; ENTRY POINT FOR CASSETTE BASIC
0060                                    ORG     01EH*4              ; INTERRUPT 1EH
0078                            DISK_POINTER    LABEL   DWORD
0078                                    ORG     01FH*4              ; LOCATION OF POINTER
007C                            EXT_PTR         LABEL   DWORD       ; POINTER TO EXTENSION
007C                                    ORG     044H*4
0110                            CSET_PTR        LABEL   DWORD       ; POINTER TO DOT PATTERNS
0110                                    ORG     048H*4
0120                            KEY62_PTR       LABEL   WORD        ; POINTER TO 62 KEY KEYBOARD CODE
0120                                    ORG     049H*4
0124                            EXST            LABEL   WORD        ; POINTER TO EXT. SCAN TABLE
0124                                    ORG     081H*4
0204                            INT81           LABEL   WORD
0204                                    ORG     082H*4
0208                            INT82           LABEL   WORD
0208                                    ORG     089H*4
0224                            INT89           LABEL   WORD
0224                                    ORG     400H
0400                            DATA_AREA       LABEL   BYTE        ; ABSOLUTE LOCATION OF DATA SEGMENT
0400                            DATA_WORD       LABEL   WORD
0400                                    ORG     7C00H
7C00                            BOOT_LOCN       LABEL   FAR
7C00                            ABS0            ENDS
; --------------------------------------------------------------------------------------------------
; A-4
; --------------------------------------------------------------------------------------------------
                                ; ------------------------------------------------
                                ; STACK -- USED DURING INITIALIZATION ONLY
                                ; ------------------------------------------------
0000                            STACK           SEGMENT AT 30H
0000      80 [                                  DW      128 DUP (?)
                ????  
                      ]
0100  
0100                            TOS             LABEL   WORD
                                STACK           ENDS
                                ; ------------------------------------------------
                                ;               ROM BIOS DATA AREAS
                                ; ------------------------------------------------
0000                            DATA            SEGMENT AT 40H
0000      04 [                  RS232_BASE      DW      4 DUP(?)    ; ADDRESSES OF RS232 ADAPTERS
                ????
                      ]
0008      04 [                  PRINTER_BASE    DW      4 DUP(?)    ; ADDRESSES OF PRINTERS
                ????  
                      ]
0010  ????                      EQUIP_FLAG      DW      ?           ; INSTALLED HARDWARE
0012  ??                        KBD_ERR         DB      ?           ; COUNT OF KEYBOARD TRANSMIT ERRORS
0013  ????                      MEMORY_SIZE     DW      ?           ; USABLE MEMORY SIZE IN K BYTES
0015  ????                      TRUE_MEM        DW      ?           ; REAL MEMORY SIZE IN K BYTES
                                ; ------------------------------------------------
                                ; KEYBOARD DATA AREAS
                                ; ------------------------------------------------
0017  ??                        KB_FLAG         DB      ?
                                ; ----- SHIFT FLAG EQUATES WITHIN KB_FLAG
                                CAPS_STATE      EQU     40H         ; CAPS LOCK STATE HAS BEEN TOGGLED
                                NUM_STATE       EQU     20H         ; NUM LOCK STATE HAS BEEN TOGGLED
                                ALT_SHIFT       EQU     08H         ; ALTERNATE SHIFT KEY DEPRESSED
                                CTL_SHIFT       EQU     04H         ; CONTROL SHIFT KEY DEPRESSED
                                LEFT_SHIFT      EQU     02H         ; LEFT SHIFT KEY DEPRESSED
                                RIGHT_SHIFT     EQU     01H         ; RIGHT SHIFT KEY DEPRESSED
                                KB_FLAG_1       DB      ?           ; SECOND BYTE OF KEYBOARD STATUS
                                INS_SHIFT       EQU     80H         ; INSERT KEY IS DEPRESSED
                                CAPS_SHIFT      EQU     40H         ; CAPS LOCK KEY IS DEPRESSED
                                NUM_SHIFT       EQU     20H         ; NUM LOCK KEY IS DEPRESSED
                                SCROLL_SHIFT    EQU     10H         ; SCROLL LOCK KEY IS DEPRESSED
                                HOLD_STATE      EQU     08H         ; SUSPEND KEY HAS BEEN TOGGLED
                                CLICK_ON        EQU     04H         ; INDICATES THAT AUDIO FEEDBACK IS
                                                                    ; ENABLED
                                CLICK_SEQUENCE  EQU     02H         ; OCCURRENCE OF ALT-CTRL-CAPSLOCK HAS
                                                                    ; OCCURED
0019  ??                        ALT_INPUT       DB      ?           ; STORAGE FOR ALTERNATE KEYPAD
                                                                    ; ENTRY
001A  ????                      BUFFER_HEAD     DW      ?           ; POINTER TO HEAD OF KEYBOARD BUFF
001C  ????                      BUFFER_TAIL     DW      ?           ; POINTER TO TAIL OF KEYBOARD BUFF
001E      10 [                  KB_BUFFER       DW      16 DUP(?)   ; ROOM FOR 15 ENTRIES
                ????  
                      ]
                                ; ------ HEAD = TAIL INDICATES THAT THE BUFFER IS EMPTY
                                NUM_KEY         EQU     69          ; SCAN CODE FOR NUMBER LOCK
                                SCROLL_KEY      EQU     70          ; SCROLL LOCK KEY
                                ALT_KEY         EQU     56          ; ALTERNATE SHIFT KEY SCAN CODE
                                CTL_KEY         EQU     29          ; SCAN CODE FOR CONTROL KEY
                                CAPS_KEY        EQU     58          ; SCAN CODE FOR SHIFT LOCK
                                LEFT_KEY        EQU     42          ; SCAN CODE FOR LEFT SHIFT
                                RIGHT_KEY       EQU     54          ; SCAN CODE FOR RIGHT SHIFT
                                INS_KEY         EQU     82          ; SCAN CODE FOR INSERT KEY
                                DEL_KEY         EQU     83          ; SCAN CODE FOR DELETE KEY
                                ; ------------------------------------------------
                                ; DISKETTE DATA AREAS
                                ; ------------------------------------------------
003E  ??                        SEEK_STATUS     DB      ?           ; DRIVE RECALIBRATION STATUS
                                                                    ; BIT 0 = DRIVE NEEDS RECAL BEFORE
                                                                    ; NEXT SEEK IF BIT IS = 0.
003F  ??                        MOTOR_STATUS    DB      ?           ; MOTOR STATUS
                                                                    ; BIT 0 = DRIVE 0 IS CURRENTLY
                                                                    ; RUNNING
0040  ??                        MOTOR_COUNT     DB      ?           ; TIME OUT COUNTER FOR DRIVE
                                                                    ; TURN OFF
= 0025                          MOTOR_WAIT      EQU     37          ; 2 SECS OF COUNTS FOR MOTOR
                                                                    ; TURN OFF
0041  ??                        DISKETTE_STATUS DB      ?           ; RETURN CODE STATUS BYTE
= 0080                          TIME_OUT        EQU     80H         ; ATTACHMENT FAILED TO RESPOND
= 0040                          BAD_SEEK        EQU     40H         ; SEEK OPERATION FAILED
= 0020                          BAD_NEC         EQU     20H         ; NEC CONTROLLER HAS FAILED
= 0010                          BAD_CRC         EQU     10H         ; BAD CRC ON DISKETTE READ
= 0009                          DMA_BOUNDARY    EQU     09H         ; ATTEMPT TO DMA ACROSS 64K
                                                                    ; BOUNDARY
= 0008                          BAD_DMA         EQU     08H         ; DMA OVERRUN ON OPERATION
= 0004                          RECORD_NOT_FND  EQU     04H         ; REQUESTED SECTOR NOT FOUND
= 0003                          WRITE_PROTECT   EQU     03H         ; WRITE ATTEMPTED ON WRITE
                                                                    ; PROTECTED DISK
= 0002                          BAD_ADDR_MARK   EQU     02H         ; ADDRESS MARK NOT FOUND
= 0001                          BAD_CMD         EQU     01H         ; BAD COMMAND GIVEN TO DISKETTE I/O
0042      07 [                  NEC_STATUS      DB      7 DUP(?)    ; STATUS BYTES FROM NEC
                ??
                    ]
= 0020                          SEEK_END        EQU     20H         ; NUMBER OF TIMER-0 TICKS TILL
= 012C                          THRESHOLD       EQU     300         ; ENABLE
= 00AF                          PARM0           EQU     0AFH        ; PARAMETER 0 IN THE DISK_PARM
; TABLE
= 0003                          PARM1           EQU     3           ; PARAMETER 1
= 0019                          PARM9           EQU     25          ; PARAMETER 9
= 0004                          PARM10          EQU     4           ; PARAMETER 10
; --------------------------------------------------------------------------------------------------
; A-5
; --------------------------------------------------------------------------------------------------
                                ; ---------------------------------------------
                                ;              VIDEO DISPLAY DATA AREA
                                ; ---------------------------------------------
                                CRT_MODE        DB      ?           ; CURRENT CRT MODE
                                CRT_COLS        DW      ?           ; NUMBER OF COLUMNS ON SCREEN
                                CRT_LEN         DW      ?           ; LENGTH OF REGEN IN BYTES
                                CRT_START       DW      ?           ; STARTING ADDRESS IN REGEN BUFFER

0060  ????                      CURSOR_MODE     DW      ?           ; CURRENT CURSOR MODE SETTING
0062  ??                        ACTIVE_PAGE     DB      ?           ; CURRENT PAGE BEING DISPLAYED
0063  ????                      ADDR_6845       DW      ?           ; BASE ADDRESS FOR ACTIVE DISPLAY
                                                                    ; CARD
0065  ??                        CRT_MODE_SET    DB      ?           ; CURRENT SETTING OF THE
                                                                    ; CRT MODE REGISTER
0066  ??                        CRT_PALLETTE    DB      ?           ; CURRENT PALETTE MASK SETTING
                                ; ---------------------------------------------
                                ;              CASSETTE DATA AREA
                                ; ---------------------------------------------
0067  ????                      EDGE_CNT        DW      ?           ; TIME COUNT AT DATA EDGE
0069  ????                      CRC_REG         DW      ?           ; CRC REGISTER
006B  ??                        LAST_VAL        DB      ?           ; LAST INPUT VALUE

                                ; ---------------------------------------------
                                ;              TIMER DATA AREA
                                ; ---------------------------------------------
006C  ????                      TIMER_LOW       DW      ?           ; LOW WORD OF TIMER COUNT
006E  ????                      TIMER_HIGH      DW      ?           ; HIGH WORD OF TIMER COUNT
0070  ??                        TIMER_OFL       DB      ?           ; TIMER HAS ROLLED OVER SINCE LAST
                                                                    ; READ

                                ; ---------------------------------------------
                                ;              SYSTEM DATA AREA
                                ; ---------------------------------------------
0071  ??                        BIOS_BREAK      DB      ?           ; BIT 7=1 IF BREAK KEY HAS BEEN HIT
0072  ????                      RESET_FLAG      DW      ?           ; WORD=1234H IF KEYBOARD RESET
                                ; UNDERWAY

                                ; ---------------------------------------------
                                ;           EXTRA DISKETTE DATA AREAS
                                ; ---------------------------------------------
0074  ??                        TRACK0          DB      ?
0075  ??                        TRACK1          DB      ?
0076  ??                        TRACK2          DB      ?
0077  ??                                        DB      ?

                                ; ---------------------------------------------
                                ;        PRINTER AND RS232 TIME-OUT VARIABLES
                                ; ---------------------------------------------
0078  04 [                      PRINT_TIM_OUT   DB      4 DUP(?)
            ?? 
                ]

007C  04 [                      RS232_TIM_OUT   DB      4 DUP(?)
            ?? 
                ]

0080  ????                      BUFFER_START    DW      ?
0082  ????                      BUFFER_END      DW      ?
0084  ??                        INTR_FLAG       DB      ?           ; FLAG TO INDICATE AN INTERRUPT
                                                                    ; HAPPENED
                                ; ---------------------------------------------
                                ;           62 KEY KEYBOARD DATA AREA
                                ; ---------------------------------------------
0085  ??                        CUR_CHAR        DB      ?           ; CURRENT CHARACTER FOR TYPAMATIC
0086  ??                        VAR_DELAY       DB      ?           ; DETERMINES WHEN INITIAL DELAY IS
                                                                    ; OVER
= 000F                          DELAY_RATE      EQU     0FH         ; INCREASES INITIAL DELAY
0087  ??                        CUR_FUNC        DB      ?           ; CURRENT FUNCTION
0088  ??                        KB_FLAG_2       DB      ?           ; 3RD BYTE OF KEYBOARD FLAGS
= 0004                          RANGE           EQU     4           ; NUMBER OF POSITIONS TO SHIFT
                                                                    ; DISPLAY
                                ; ---------------------------------------------
                                ;          BIT ASSIGNMETS FOR KB_FLAG_2
                                ; ---------------------------------------------
= 0080                          FN_FLAG         EQU     80H
= 0040                          FN_BREAK        EQU     40H
= 0020                          FN_PENDING      EQU     20H
= 0010                          FN_LOCK         EQU     10H
= 0008                          TYPE_OFF        EQU     08H
= 0004                          HALF_RATE       EQU     04H
= 0002                          INIT_DELAY      EQU     02H
= 0001                          PUTCHAR         EQU     01H
0089  ??                        HORZ_POS        DB      ?           ; CURRENT VALUE OF HORIZONTAL
                                                                    ; START PARM
008A  ??                        PAGDAT          DB      ?           ; IMAGE OF DATA WRITTEN TO PAGREG
008B                            DATA            ENDS

                                ; ---------------------------------------------
                                ;                EXTRA DATA AREA
                                ; ---------------------------------------------
0000                            XXDATA          SEGMENT AT 50H
0000  ??                        STATUS_BYTE     DB      ?
                                ; THE FOLLOWING AREA IS USED ONLY DURING DIAGNOSTICS
                                ; (POST AND ROM RESIDENT)
0001  ??                        DCP_MENU_PAGE   DB      ?           ; TO CURRENT PAGE FOR DIAG. MENU
0002  ????                      DCP_ROW_COL     DW      ?           ; CURRENT ROW/COLUMN COORDINATES
                                                                    ; FOR DIAG MENU   
0004  ??                        WRAP_FLAG       DB      ?           ; INTERNAL/EXTERNAL 8250 WRAP
                                                                    ; INDICATOR
; --------------------------------------------------------------------------------------------------
; A-6
; --------------------------------------------------------------------------------------------------
0005  ??                        MFG_TST         DB      ?           ; INITIALIZATION FLAG
0006  ????                      MEM_TOT         DW      ?           ; WORD EQUIV. TO HIGHEST SEGMENT IN
                                                                    ; MEMORY
0008  ????                      MEM_DONES       DW      ?           ; CURRENT SEGMENT VALUE FOR
                                                                    ; BACKGROUND MEM TEST
000A  ????                      MEM_DONEO       DW      ?           ; CURRENT OFFSET VALUE FOR
                                                                    ; BACKGROUND MEM TEST
000C  ????                      INITC0          DW      ?           ; SAVE AREA FOR INTERRUPT 1C
000E  ????                      INT1CS          DW      ?           ; ROUTINE
0010  ??                        MENU_UP         DB      ?           ; FLAG TO INDICATE WHETHER MENU IS
                                                                    ; ON SCREEN (FF=YES, 0=NO)
0011  ??                        DONE128         DB      ?           ; COUNTER TO KEEP TRACK OF 128 BYTE
                                                                    ; BLOCKS TESTED BY BGMEM
0012  ????                      KBDONE          DW      ?           ; TOTAL K OF MEMORY THAT HAS BEEN
                                                                    ; TESTED BY BACKGROUND MEM TEST
                                ; ---------------------------------------------
                                ;       POST DATA AREA
                                ; ---------------------------------------------
0014  ????                      IO_ROM_INIT     DW      ?           ; POINTER TO OPTIONAL I/O ROM INIT
                                                                    ; ROUTINE
0016  ????                      IO_ROM_SEG      DW      ?           ; POINTER TO IO ROM SEGMENT
0018  ??                        POST_ERR        DB      ?           ; FLAG TO INDICATE ERROR OCCURRED
                                                                    ; DURING POST
0019  09 [                      MODEM_BUFFER    DB      9 DUP(?)    ; MODEM RESPONSE BUFFER
          ??
        ]

0022  ????                      MFG_RTN         DW      ?           ; (MAX 9 CHARS)
0024  ????                                      DW      ?           ; POINTER TO MFG. OUTPUT ROUTINE

                                ; ---------------------------------------------
                                ;       SERIAL PRINTER DATA
                                ; ---------------------------------------------
0026  ????                      SP_FLAG         DW      ?
0028  ??                        SP_CHAR         DB      ?

0029  ????                      NEW_STICK_DATA  DW      ?           ; THE FOLLOWING SIX ENTRIES ARE
002B  ????                                      DW      ?           ; DATA PERTAINING TO NEW STICK
002D  ????                                      DW      ?           ; RIGHT STICK DELAY
002F  ????                                      DW      ?           ; RIGHT BUTTON A DELAY
0031  ????                                      DW      ?           ; RIGHT BUTTON B DELAY
0033  ????                                      DW      ?           ; LEFT STICK DELAY
0035  ????                                      DW      ?           ; LEFT BUTTON A DELAY
0037  ????                                      DW      ?           ; LEFT BUTTON B DELAY
0039  ????                                      DW      ?           ; RIGHT STICK LOCATION
003B  ????                                      DW      ?           ; UNUSED
003D                                            DW      ?           ; UNUSED
                                XXDATA          ENDS                 ; LEFT STICK POSITION

                                ; ---------------------------------------------
                                ;       DISKETTE DATA AREA
                                ; ---------------------------------------------
0000                            DKDATA  SEGMENT AT 60H
0000  ??                        NUM_DRIVE       DB      ?
0001  ??                        DUAL            DB      ?
0002  ??                        OPERATION       DB      ?
0003  ??                        DRIVE           DB      ?
0004  ??                        TRACK           DB      ?
0005  ??                        HEAD            DB      ?
0006  ??                        SECTOR          DB      ?
0007  ??                        NUM_SECTOR      DB      ?
0008  ??                        SEC             DB      ?
                                ;   FORMAT ID
0009  08   [                    TK_HD_SC        DB      8 DUP(0,0,0,0) ; TRACK,HEAD,SECTOR,NUM OF
              00
              00
              00
              00
                  ]

                                ;   SECTOR BUFFER FOR READ AND WRITE OPERATION
= 0200                          DK_BUF_LEN      EQU     512         ; 512 BYTES/SECTOR
0029  0200 [                    READ_BUF        DB      DK_BUF_LEN DUP(0)
              00                
                  ] 

0229  0100 [                    WRITE_BUF       DB      (DK_BUF_LEN/2) DUP(6DH,0BH)
              6D             
              0B
                  ]

0429  ??                        ;   INFO FLAGS
042A  ??                        REQUEST_IN      DB      ?           ; SELECTION CHARACTER
042B  ??                        DK_EXISTED      DB      ?
042C  ??                        DK_FLAG         DB      ?
042E  ????                      RAN_NUM         DW      ?
                                SEED            DW      ?           
                                ;   SPEED TEST VARIABLES
0430  ????                      DK_SPEED        DW      ?
0432  ????                      TIM_1           DW      ?
0434  ????                      TIM_L_1         DW      ?
0436  ????                      TIM_2           DW      ?
0438  ????                      TIM_L_2         DW      ?
043A  ????                      FRACT_H         DW      ?
043C  ????                      FRACT_L         DW      ?
043E  ????                      PART_CYCLE      DW      ?
0440  ????                      WHOLE_CYCLE     DW      ?
0442  ????                      HALF_CYCLE      DW      ?
; --------------------------------------------------------------------------------------------------
; A-7
; --------------------------------------------------------------------------------------------------

0444  ??                        ;   ERROR PARAMETERS
                                DK_ER_OCCURED   DB      ?           ; ERROR HAS OCCURRED
0445  ??                        DK_ER_L1        DB      ?           ; CUSTOMER ERROR LEVEL
0446  ??                        DK_ER_L2        DB      ?           ; SERVICE ERROR LEVEL
0447  ??                        ER_STATUS_BYTE  DB      ?           ; STATUS BYTE RETURN FROM INT 13H
                                                                    ; LANGUAGE TABLE
0448  ??                        LANG_BYTE       DB      ?           ; PORT B0 TO DETERMINE WHICH
0449                            DKDATA          ENDS                ; LANGUAGE TO USE
                                ;------------------------------------------------
                                ;               VIDEO DISPLAY BUFFER
                                ;------------------------------------------------
0000                            VIDEO_RAM       SEGMENT AT 0B800H
0000  4000 [                    DB              16384 DUP(?)
              ??
                  ]  

4000                            VIDEO_RAM       ENDS
                                ;------------------------------------------------
                                ;               ROM RESIDENT CODE
                                ;------------------------------------------------
0000                            CODE            SEGMENT PAGE
                                                ASSUME  CS:CODE,DS:ABSO,ES:NOTHING,SS:STACK
0000  31 35 30 34 30 33                         DB      '1504036 COPR. IBM 1981,1983' ; COPYRIGHT NOTICE
      36 20 43 4F 50 52
      2E 20 49 42 4D 20
      31 39 38 31 2C 31
      39 38 33

001B  0149 R                    Z1              DW      L12         ; RETURN POINTERS FOR RTNS CALLED
001D  0157 R                                    DW      L14         ; BEFORE STACK INITIALIZED
001F  0160 R                                    DW      L16
0021  0186 R                                    DW      L19
0023  01BA R                                    DW      L24
0025  20 4B 42                  F3B             DB      ' KB'
0028  0A47 R                    EX_0            DW      OFFSET  EBO
002A  0A47 R                                    DW      OFFSET  EBO
002C  0ABB R                                    DW      OFFSET  TOTLPO
002E  0A84 R                    EX1             DW      OFFSET  MO1
                                ;
                                ;---------------------- MESSAGE AREA FOR POST -------------------
0030  45 52 52 4F 52            ERROR_ERR       DB      'ERROR'     ; GENERAL ERROR PROMPT
0035  41                        MEM_ERR         DB      'A'         ; MEMORY ERROR
0036  42                        KEY_ERR         DB      'B'         ; KEYBOARD ERROR MSG
0037  43                        CASS_ERR        DB      'C'         ; CASSETTE ERROR MESSAGE
0038  44                        COM1_ERR        DB      'D'         ; ON-BOARD SERIAL PORT ERR. MSG
0039  45                        COM2_ERR        DB      'E'         ; SERIAL PORTION OF MODEM ERROR
003A  46                        ROM_ERR         DB      'F'         ; OPTIONAL GENERIC BIOS ROM ERROR
003B  47                        CART_ERR        DB      'G'         ; CARTRIDGE ERROR
003C  48                        DISK_ERR        DB      'H'         ; DISKETTE ERR
                                ;
003D                            F4              LABEL   WORD        ; PRINTER SOURCE TABLE
003D  0378                                      DW      378H
003F  0278                                      DW      278H
0041                            F4E             LABEL   WORD
0041  EF                        IMASKS          LABEL   BYTE        ; INTERRUPT MASKS FOR 8259
                                                                    ; INTERRUPT CONTROLLER
0042  F7                                        DB      0EFH        ; MODEM INTR MASK
                                                DB      0F7H        ; SERIAL PRINTER INTR MASK
                                
                                ;---------------------------------------------------
                                ; SETUP                                            :
                                ;       DISABLE NMI, MASKABLE INTS.                :
                                ;       SOUND CHIP, AND VIDEO.                     :
                                ;       TURN DRIVE 0 MOTOR OFF                     :
                                ;---------------------------------------------------
                                        ASSUME  CS:CODE,DS:ABSO,ES:NOTHING,SS:STACK
0043                                    RESET           LABEL   FAR
0043  B0 00                     START:  MOV     AL,0
0045  E6 A0                             OUT     0A0H,AL             ; DISABLES NMI
0047  FE C8                             DEC     AL                  ; SEND FF TO MFG_TESTER
0049  E6 10                             OUT     10H,AL    
004B  E4 A0                             IN      AL,0A0H             ; RESET NMI F/F
004D  FA                                CLI                         ; DISABLES MASKABLE INTERRUPTS
                                                                    ; DISABLE ATTENUATION IN SOUND CHIP
                                                                    ; REG ADDRESS IN AH, ATTENUATOR OFF
004E  B8 108F                           MOV     AX,108FH            ; IN AL
0051  BA 00C0                           MOV     DX,00C0H            ; ADDRESS OF SOUND CHIP
0054  B9 0004                           MOV     CX,4                ; 4 ATTENUATORS TO DISABLE
0057  0A C4                     L1:     OR      AL,AH               ; COMBINE REG ADDRESS AND DATA
0059  EE                                OUT     DX,AL   
005A  80 C4 20                          ADD     AH,20H              ; POINT TO NEXT REG
005D  E2 F8                             LOOP    L1
005F  B0 A0                             MOV     AL,WD_ENABLE+FDC_RESET ; TURN DRIVE 0 MOTOR OFF,
                                                                    ; ENABLE TIMER
0061  E6 F2                             OUT     0F2H,AL
0063  BA 03DA                           MOV     DX,VGA_CTL          ; VIDEO GATE ARRAY CONTROL
0066  EC                                IN      AL,DX               ; SYNC VGA TO ACCEPT REG
0067  B0 04                             MOV     AL,4                ; SET VGA RESET REG
0069  EE                                OUT     DX,AL               ; SELECT IT
006A  B0 01                             MOV     AL,1                ; SET ASYNC RESET
006C  EE                                OUT     DX,AL               ; RESET VIDEO GATE ARRAY

                                ;------------------------------------------------
                                ; TEST 1                                        :
                                ;       8088 PROCESSOR TEST                     :
                                ; DESCRIPTION                                   :
                                ;       VERIFY 8088 FLAGS, REGISTERS            :
                                ;       AND CONDITIONAL JUMPS                   :
                                ;                                               :
                                ; MFG. ERROR CODE 0001H                         :
                                ;------------------------------------------------
; --------------------------------------------------------------------------------------------------
; A-8
; --------------------------------------------------------------------------------------------------                           
006D B4 D5                              MOV     AH,0D5H             ; SET SF, CF, ZF, AND AF FLAGS ON
006F 9E                                 SAHF    
0070 73 4C                              JNC     L4                  ; GO TO ERR ROUTINE IF CF NOT SET
0072 75 4A                              JNZ     L4                  ; GO TO ERR ROUTINE IF ZF NOT SET
0074 7B 48                              JNP     L4                  ; GO TO ERR ROUTINE IF PF NOT SET
0076 79 46                              JNS     L4                  ; GO TO ERR ROUTINE IF SF NOT SET
0078 9F                                 LAHF                        ; LOAD FLAG IMAGE TO AH
0079 B1 05                              MOV     CL,5                ; LOAD CNT REG WITH SHIFT CNT
007B D2 EC                              SHR     AH,CL               ; SHIFT AF INTO CARRY BIT POS
007D 73 3F                              JNC     L4                  ; GO TO ERR ROUTINE IF AF NOT SET
007F B0 40                              MOV     AL,40H              ; SET THE OF FLAG ON
0081 D0 E0                              SHL     AL,1                ; SETUP FOR TESTING
0083 71 39                              JNO     L4                  ; GO TO ERR ROUTINE IF OF NOT SET
0085 32 E4                              XOR     AH,AH               ; SET AH = 0
0087 9E                                 SAHF                        ; CLEAR SF, CF, ZF, AND PF
0088 76 34                              JBE     L4                  ; GO TO ERR ROUTINE IF CF ON
                                ; GO TO ERR ROUTINE IF ZF ON
008A 78 32                              JS      L4                  ; GO TO ERR ROUTINE IF SF ON
008C 7A 30                              JP      L4                  ; GO TO ERR ROUTINE IF PF ON
008E 9F                                 LAHF                        ; LOAD FLAG IMAGE TO AH
008F B1 05                              MOV     CL,5                ; LOAD CNT REG WITH SHIFT CNT
0091 D2 EC                              SHR     AH,CL               ; SHIFT 'AF' INTO CARRY BIT POS
0093 72 29                              JC      L4                  ; GO TO ERR ROUTINE IF ON
0095 D0 E4                              SHL     AH,1                ; CHECK THAT 'OF' IS CLEAR
0097 70 25                              JO      L4                  ; GO TO ERR ROUTINE IF ON
                                ; ----- READ/WRITE THE 8088 GENERAL AND SEGMENTATION REGISTERS
                                ;       WITH ALL ONE'S AND ZEROE'S.
0099 B8 FFFF                            MOV     AX,0FFFFH           ; SETUP ONE'S PATTERN IN AX
009C F9                                 STC
009D 8E D8                      L2:     MOV     DS,AX               ; WRITE PATTERN TO ALL REGS
009F 8C D8                              MOV     BX,DS
00A1 8E C3                              MOV     ES,BX
00A3 8C C1                              MOV     CX,ES
00A5 8E D1                              MOV     SS,CX
00A7 8C D2                              MOV     DX,SS
00A9 8B E2                              MOV     SP,DX
00AB 8B EC                              MOV     BP,SP
00AD 8B F5                              MOV     SI,BP
00AF 8B FE                              MOV     DI,SI
00B1 73 07                              JNC     L3
00B3 33 C7                              XOR     AX,DI               ; PATTERN MAKE IT THRU ALL REGS
00B5 75 07                              JNZ     L4                  ; NO - GO TO ERR ROUTINE
00B7 F8                                 CLC
00B8 EB E3                              JMP     L2
00BA 0B C7                      L3:     OR      AX,DI               ; ZERO PATTERN MAKE IT THRU?
00BC 74 0C                              JZ      L5                  ; YES - GO TO NEXT TEST
00BE BA 0010                    L4:     MOV     DX,0010H            ; HANDLE ERROR
00C1 B0 00                              MOV     AL,0                ;
00C3 EE                                 OUT     DX,AL               ; ERROR 0001
00C4 42                                 INC     DX    
00C5 EE                                 OUT     DX,AL   
00C6 FE C0                              INC     AL    
00C8 EE                                 OUT     DX,AL   
00C9 F4                                 HLT                         ; HALT
00CA                            L5:
                                ;-------------------------------------------------------------
                                ; TEST 2                                                     :
                                ;       8255 INITIALIZATION AND TEST                         :
                                ; DESCRIPTION                                                :
                                ;       FIRST INITIALIZE 8255 PROG.                          :
                                ;       PERIPHERAL INTERFACE. PORTS A&B                      :
                                ;       ARE LATCHED OUTPUT                                   :
                                ;       BUFFERS. C IS INPUT.                                 :
                                ; MFG. ERR. CODE =0002H                                      :
                                ;-------------------------------------------------------------
00CA B0 FE                              MOV     AL,0FEH             ; SEND FE TO MFG
00CC E6 10                              OUT     10H,AL    
00CE B0 89                              MOV     AL,MODE_8255    
00D0 E6 63                              OUT     CMD_PORT,AL         ; CONFIGURES I/O PORTS
00D2 2B C0                              SUB     AX,AX               ; TEST PATTERN SEED = 0000
00D4 8A C4                      L6:     MOV     AL,AH   
00D6 E6 60                              OUT     PORT_A,AL           ; WRITE PATTERN TO PORT A
00D8 E4 60                              IN      AL,PORT_A           ; READ PATTERN FROM PORT A
00DA E6 61                              OUT     PORT_B,AL           ; WRITE PATTERN TO PORT B
00DC E4 61                              IN      AL,PORT_B           ; READ OUTPUT PORT
00DE 3A C4                              CMP     AL,AH               ; DATA AS EXPECTED?
00E0 75 06                              JNE     L7                  ; IF NOT, SOMETHING IS WRONG
00E2 FE C4                              INC     AH                  ; MAKE NEW DATA PATTERN
00E4 75 EE                              JNZ     L6                  ; LOOP TILL 255 PATTERNS DONE
00E6 EB 05                              JMP     SHORT L8            ; CONTINUE IF DONE
00E8 B3 02                      L7:     MOV     BL,02H              ; SET ERROR FLAG (BH=00 NOW)
00EA E9 09BC R                          JMP     E_MSG               ; GO ERROR ROUTINE
00ED 32 C0                      L8:     XOR     AL,AL   
00EF E6 60                              OUT     KBPORT,AL           ; CLEAR KB PORT
00F1 E4 62                              IN      AL,PORT_C           ;
00F3 24 08                              AND     AL,00001000B        ; 64K CARD PRESENT?
00F5 B0 1B                              MOV     AL,1BH              ; PORT SETTING FOR 64K SYS
00F7 75 02                              JNZ     L9                  ;
00F9 B0 3F                              MOV     AL,3FH              ; PORT SETTING FOR 128K SYS
00FB BA 03DF                    L9:     MOV     DX,PAGREG           ;
00FE EE                                 OUT     DX,AL               ;
00FF B0 0D                              MOV     AL,00001101B        ; INITIALIZE OUTPUT PORTS
0101 E6 61                              OUT     PORT_B,AL           ;
; --------------------------------------------------------------------------------------------------
; A-9
; --------------------------------------------------------------------------------------------------     
                                ;-------------------------------------------------------------------
                                ; PART 3
                                ;           SET UP VIDEO GATE ARRAY AND 6845 TO GET MEMORY WORKING
                                ;-------------------------------------------------------------------

0103 B0 FD                              MOV     AL,0FDH
0105 E6 10                              OUT     10H,AL                 ;
0107 BA 03D4                            MOV     DX,03D4H               ; SET ADDRESS OF 6845
010A BB F0A4 R                          MOV     BX,OFFSET VIDEO_PARMS  ; POINT TO 6845 PARMS
010D B9 0040 90                         MOV     CX,MO040               ; SET PARM LEN
0111 32 E4                              XOR     AH,AH                  ; AH IS REG #
0113 8A C4                      L10:    MOV     AL,AH                  ; GET 6845 REG #
0115 EE                                 OUT     DX,AL
0116 42                                 INC     DX                     ; POINT TO DATA PORT
0117 FE C4                              INC     AH                     ; NEXT REG VALUE
0119 2E: 8A 07                          MOV     AL,CS:[BX]             ; GET TABLE VALUE
011C EE                                 OUT     DX,AL                  ; OUT TO CHIP
011D 43                                 INC     BX                     ; NEXT IN TABLE
011E 4A                                 DEC     DX                     ; BACK TO POINTER REG
011F E2 F2                              LOOP    L10

0121 BA 03DA            ;       START VGA WITHOUT VIDEO ENABLED
0124 EC                                 IN      AL,DX                  ; SET ADDRESS OF VGA
                                ; BE SURE ADDR/DATA FLAG IS
                                ; IN THE PROPER STATE
0125 B9 0005                            MOV     CX,5                   ; # OF REGISTERS
0128 32 E4                              XOR     AH,AH                  ; AH IS REG COUNTER
012A 8A C4                      L11:    MOV     AL,AH                  ; GET REG #
012C EE                                 OUT     DX,AL                  ; SELECT IT
012D 32 C0                              XOR     AL,AL                  ; SET ZERO FOR DATA
012F EE                                 OUT     DX,AL
0130 FE C4                              INC     AH                     ; NEXT REG
0132 E2 F6                              LOOP    L11

                                ;---------------------------------------------------------------
                                ; TEST 4
                                ;       PLANAR BOARD ROS CHECKSUM TEST
                                ; DESCRIPTION
                                ;       A CHECKSUM TEST IS DONE FOR EACH ROS
                                ;       MODULE ON THE PLANAR BOARD TO.
                                ;       MFG ERROR CODE =0003H MODULE AT ADDRESS
                                ;                       F000:0000 ERROR
                                ;                       0004H MODULE AT ADDRESS
                                ;                       F800:0000 ERROR
                                ;
                                ;---------------------------------------------------------------

0134 B0 FC                              MOV     AL,0FCH
0136 E6 10                              OUT     10H,AL                 ; MFG OUT=FC
                                        ; CHECK MODULE AT F000:0 (LENGTH 32K)
0138 33 F6                              XOR     SI,SI                  ; INDEX OFFSET WITHIN SEGMENT OF
                                        ; FIRST BYTE
013A 8C C8                              MOV     AX,CS                  ; SET UP STACK SEGMENT
013C 8E D0                              MOV     SS,AX
013E 8E D8                              MOV     DS,AX                  ; LOAD DS WITH SEGMENT OF ADDRESS
                                        ; SPACE OF BIOS/BASIC
0140 B9 8000                            MOV     CX,8000H               ; NUMBER OF BYTES TO BE TESTED, 32K
0143 BC 001B R                          MOV     SP,OFFSET Z1           ; SET UP STACK POINTER SO THAT
                                        ; RETURN WILL COME HERE
0146 E9 FEEB R                          JMP     ROS_CHECKSUM           ; JUMP TO ROUTINE WHICH PERFORMS
                                        ; CRC CHECK
0149 74 06                      L12:    JZ      L13                    ; MODULE AT F000:0 OK, GO CHECK
                                        ; OTHER MODULE AT F000:8000
014B BB 0003                            MOV     BX,0003H               ; SET ERROR CODE
014E E9 09BC R                          JMP     E_MSG                  ; INDICATE ERROR
0151 B9 8000                    L13:    MOV     CX,8000H               ; LOAD COUNT (SI POINTING TO START
0154 E9 FEEB R                          JMP     ROS_CHECKSUM           ; OF NEXT MODULE AT THIS POINT)
0157 74 06                      L14:    JZ      L15                    ; PROCEED IF NO ERROR
0159 BB 0004                            MOV     BX,0004H               ; INDICATE ERROR
015C E9 09BC R                          JMP     E_MSG
015F                            L15:

                                ;---------------------------------------------------------------
                                ; TEST 5
                                ;       BASE  2K READ/WRITE STORAGE TEST
                                ; DESCRIPTION
                                ;       WRITE/READ/VERIFY DATA PATTERNS
                                ;       AA,55, AND 00 TO 1ST 2K OF STORAGE
                                ;       AND THE 2K JUST BELOW 64K (CRT BUFFER)
                                ;       VERIFY STORAGE ADDRESSABILITY.
                                ;       ON EXIT SET CRT PAGE TO 3. SET
                                ;       TEMPORARY STACK ALSO.
                                ;       MFG. ERROR CODE 04XX FOR SYSTEM BOARD MEM.
                                ;                       05XX FOR 64K ATTRIB. CD. MEM
                                ;                       06XX FOR ERRORS IN BOTH
                                ;                           (XX= ERROR BITS)
                                ;---------------------------------------------------------------;

015F B0 FB                              MOV     AL,0FBH
0161 E6 10                              OUT     10H,AL                    ; SET MFG FLAG=FB
0163 B9 0400                            MOV     CX,0400H                  ; SET FOR 1K WORDS, 2K BYTES
0166 33 C0                              XOR     AX,AX
0168 8E C0                              MOV     ES,AX                     ; LOAD ES WITH 0000 SEGMENT
016A E9 0B59 R                          JMP     PODSTG
016D 75 19                      L16:    JNZ     L20                       ; BAD STORAGE FOUND
016F B0 FA                              MOV     AL,0FAH                   ; MFG OUT=FA
0171 E6 10                              OUT     10H,AL
0173 B9 0400                            MOV     CX,400H                   ; 1024 WORDS TO BE TESTED IN THE
                                        ; REGEN BUFFER
0176 E4 60                              IN      AL,PORT_A                 ; WHERE IS THE REGEN BUFFER?
0178 3C 1B                              CMP     AL,1BH                    ; TOP OF 64K?
017A B8 0F80                            MOV     AX,0F80H                  ; SET POINTER TO THERE IF IT IS
017D 74 02                              JE      L18
017F B4 1F                              MOV     AH,1FH                    ; OR SET POINTER TO TOP OF 128K
0181 8E C0                      L18:    MOV     ES,AX
0183 E9 0B59 R                          JMP     PODSTG                    ;
0186 74 23                      L19:    JZ      L23
; --------------------------------------------------------------------------------------------------
; A-10
; --------------------------------------------------------------------------------------------------
0188 B7 04                      L20:    MOV     BH,04H          ; ERROR 04....
018A E4 62                              IN      AL,PORT_C       ; GET CONFIG BITS
018C 24 08                              AND     AL,00001000B    ; TEST FOR ATTRIB CARD PRESENT
018E 74 06                              JZ      L21             ; WORRY ABOUT ODD/EVEN IF IT IS
0190 8A D9                              MOV     BL,CL
0192 0A DD                              OR      BL,CH           ; COMBINE ERROR BITS IF IT ISN'T
0194 EB 12                              JMP     SHORT L22       ;
0196 80 FC 02                   L21:    CMP     AH,02           ; EVEN BYTE ERROR? ERR 04XX
0199 8A D9                              MOV     BL,CL
019B 74 0B                              JE      L22             ; MAKE INTO 05XX ERR
019D FE C7                              INC     BH              ; MOVE AND POSSIBLY COMBINE
019F 0A D0                              OR      BL,CH           ; ERROR BITS

01A1 80 FC 01                           CMP     AH,1            ; ODD BYTE ERROR
01A4 74 02                              JE      L22
01A6 FE C7                              INC     BH              ; MUST HAVE BEEN BOTH

01A8 E9 09BC R                  L22:    JMP     E_MSG           ; - MAKE INTO 06XX
                                        ; RETEST HIGH 2K USING B8000 ADDRESS PATH
01AB B0 F9                      L23:    MOV     AL,0F9H             ; MFG OUT =F9
01AD E6 10                              OUT     10H,AL    
01AF B9 0400                            MOV     CX,0400H            ; 1K WORDS
01B2 B8 BB80                            MOV     AX,0BB80H           ; POINT TO AREA JUST TESTED WITH
                                        ; DIRECT ADDRESSING

01B5 8E C0                              MOV     ES,AX
01B7 E9 0B59 R                          JMP     PODSTG
01BA 74 06                      L24:    JZ      L25
01BC BB 0005                            MOV     BX,0005H            ; ERROR 0005
01BF E9 09BC R                          JMP     E_MSG
                                        ;------ SETUP STACK SEG AND SP
01C2 B8 0030                    L25:    MOV     AX,0030H            ; GET STACK VALUE
01C5 8E D0                              MOV     SS,AX               ; SET THE STACK UP
01C7 BC 0100 R                          MOV     SP,OFFSET TOS       ; STACK IS READY TO GO
01CA 33 C0                              XOR     AX,AX               ; SET UP DATA SEG
01CC 8E D8                              MOV     DS,AX
                                        ;------ SETUP CRT PAGE
01CE C7 06 0462 R 0007                  MOV     DATA_WORD(ACTIVE_PAGE-DATA),07
                                        ;------ SET PRELIMINARY MEMORY SIZE WORD
01D4 BB 0040                            MOV     BX,64
01D7 E4 62                              IN      AL,PORT_C           ;
01D9 24 08                              AND     AL,08H              ; 64K CARD PRESENT?
01DB B0 1B                              MOV     AL,1BH              ; PORT SETTING FOR 64K SYSTEM
01DD 75 05                              JNZ     L26                 ; SET TO 64K IF NOT
01DF 83 C3 40                           ADD     BX,64               ; ELSE SET FOR 128K
01E2 B0 3F                              MOV     AL,3FH              ; PORT SETTING FOR 128K SYSTEM
01E4 89 1E 0415 R               L26:    MOV     DATA_WORD(TRUE_MEM-DATA),BX
01E8 A2 048A R                          MOV     DATA_AREA(PAGDAT-DATA),AL

                                ;-----------------------------------------
                                ;       PART 6
                                ;               INTERRUPTS
                                ; DESCRIPTION
                                ;       32 INTERRUPTS ARE INITIALIZED TO POINT TO A
                                ;       DUMMY HANDLER. THE BIOS INTERRUPTS ARE LOADED.
                                ;       DIAGNOSTIC INTERRUPTS ARE LOADED
                                ;       SYSTEM CONFIGURATION WORD IS PUT IN MEMORY.
                                ;       THE DUMMY INTERRUPT HANDLER RESIDES HERE.
                                ;-----------------------------------------

01EB B8 ---- R                          ASSUME  DS:XXDATA
01EE 8E D8                              MOV     AX,XXDATA
01F0 C6 06 0005 R F8                    MOV     DS,AX
                                        MOV     MFG_TST,0F8H    ; SET UP MFG CHECKPOINT FROM THIS
                                                                ; POINT 
01F5 E8 E6D8 R                          CALL    MFG_UP          ; UPDATE MFG CHECKPOINT
01F8 C7 06 0022 R 0A61 R                MOV     MFG_RTN,OFFSET MFG_OUT
01FE 8C C8                              MOV     AX,CS
0200 A3 0024 R                          MOV     MFG_RTN+2,AX    ; SET DOUBLEWORD POINTER TO MFG.
                                                                ; ERROR OUTPUT ROUTINE SO DIAGS.
                                                                ; DON'T HAVE TO DUPLICATE CODE

                                        ASSUME  CS:CODE,DS:ABSO
0203 BB 0000                            MOV     AX,0
0206 8E D8                              MOV     DS,AX
                                        ;------ SET UP THE INTERRUPT VECTORS TO TEMP INTERRUPT
0208 B9 00FF                            MOV     CX,255          ; FILL ALL INTERRUPTS
020B 2B FF                              SUB     DI,DI           ; FIRST INTERRUPT LOCATION IS 0000
020D 8E C7                              MOV     ES,DI           ; SET ES=0000 ALSO
020F B8 F815 R                  D3:     MOV     AX,OFFSET D11   ; MOVE ADDR OF INTR PROC TO TBL
0212 AB                                 STOSW
0213 8C C8                              MOV     AX,CS           ; GET ADDR OF INTR PROC SEG
0215 AB                                 STOSW
0216 E2 F7                              LOOP    D3              ; VECTBL0
0218 C7 06 0124 R 109D R                MOV     EXST,OFFSET EXTAB ; SET UP EXT. SCAN TABLE
                                        ; SET UP BIOS INTERRUPTS
021E BF 0040 R                          MOV     DI,OFFSET VIDEO_INT ; SET UP VIDEO INT
0221 0E                                 PUSH    CS
0222 1F                                 POP     DS              ; PLACE CS IN DS
0223 BE FF03 R                          MOV     SI,OFFSET VECTOR_TABLE+16
0226 B9 0010                            MOV     CX,16
0229 A5                         D4:     MOVSW                   ; MOVE INTERRUPT VECTOR TO LOW
                                                                ; MEMORY

022A 47                                 INC     DI              
022B 47                                 INC     DI              ; POINT TO NEXT VECTOR ENTRY
022C E2 FB                              LOOP    D4              ; REPEAT FOR ALL 16 BIOS INTERRUPTS
                                        ; SET UP DIAGNOSTIC INTERRUPTS
022E BF 0200                            MOV     DI,0200H        ; START WITH INT. 80H
0231 BE 4000                            MOV     SI,DIAG_TABLE_PTR ; POINT TO ENTRY POINT TABLE
0234 B9 0010                            MOV     CX,16           ; 16 ENTRIES
0237 A5                         D5:     MOVSW                   ; MOVE INTERRUPT VECTOR TO LOW
                                                                ; MEMORY
; --------------------------------------------------------------------------------------------------
; A-11        
; --------------------------------------------------------------------------------------------------
0238  47                                INC     DI
0239  47                                INC     DI              ; POINT TO NEXT VECTOR ENTRY
023A  E2 FB                             LOOP    D5              ; REPEAT FOR ALL 16 BIOS INTERRUPTS
023C  8E D9                             MOV     DS,CX           ; SET DS TO ZERO
023E  C7 06 0204 R 1B63 R               MOV     INTB1,OFFSET LOCATE1
0244  C7 06 0208 R 1A2A R               MOV     INT82,OFFSET PRNT3
024A  C7 06 0224 R 1BA5 R               MOV     INT89,OFFSET JOYSTICK

                                ;----- SET UP DEFAULT EQUIPMENT DETERMINATION WORD
                                ;       BIT 15,14 = NUMBER OF PRINTERS ATTACHED
                                ;       BIT 13 = 1 = SERIAL PRINTER PRESENT
                                ;       BIT 12 = GAME I/O ATTACHED
                                ;       BIT 11,10,9 = NUMBER OF RS232 CARDS ATTACHED
                                ;       BIT 8 = DMA (0=DMA PRESENT, 1=NO DMA ON SYSTEM
                                ;       BIT 7,6 = NUMBER OF DISKETTE DRIVES
                                ;               00=1, 01=2, 10=3, 11=4 ONLY IF BIT 0 = 1
                                ;       BIT 5,4 = INITIAL VIDEO MODE
                                ;               00 - UNUSED
                                ;               01 - 40X25 BW USING COLOR CARD
                                ;               10 - 80X25 BW USING COLOR CARD
                                ;               11 - 80X25 BW USING BW CARD
                                ;       BIT 3,2 = PLANAR RAM SIZE (10=48K,11=64K)
                                ;       BIT 1 NOT USED
                                ;       BIT 0 = 1 (IPL DISKETTE INSTALLED)
                                ;-------------------------------------------------------------
0250  BB 1118                           ASSUME  CS:CODE,DS:ABSO
                                        MOV     BX,1118H            ; DEFAULT GAMEI0,40X25,NO DMA,48K ON
                                                                    ; PLANAR
0253  E4 62                             IN      AL,PORT_C
0255  24 08                             AND     AL,08H          ; 64K CARD PRESENT
0257  75 03                             JNZ     D55             ; NO, JUMP
0259  80 CB 04                          OR      BL,4            ; SET 64K ON PLANAR
025C  89 1E 0410 R              D55:    MOV     DATA_WORD[EQUIP_FLAG-DATA],BX
                                ;-------------------------------------------------------------
                                ; TEST 7
                                ;       INITIALIZE AND TEST THE 8259 INTERRUPT CONTROLLER CHIP
                                ;       MFG ERR. CODE 07XX (XX=00, DATA PATH OR INTERNAL FAILURE,
                                ;               XX=ANY OTHER BITS ON=UNEPECTED INTERRUPTS
                                ;-------------------------------------------------------------
0260  E8 E6D8 R                         CALL    MFG_UP              ; MFG CODE=F7
                                        ASSUME  DS:ABSO,CS:CODE
0263  B0 13                             MOV     AL,13H              ; ICW1 - RESET EDGE SENSE CIRCUIT,
                                                                    ;SET SINGLE 8259 CHIP AND ICW4 READ
0265  E6 20                             OUT     INTA00,AL
0267  B0 08                             MOV     AL,8                ; ICW2 - SET INTERRUPT TYPE 8 (8-F)
0269  E6 21                             OUT     INTA01,AL
026B  B0 09                             MOV     AL,9                ; ICW4 - SET BUFFERED MODE/SLAVE
                                                                    ;   AND 8086 MODE
026D  E6 21                             OUT     INTA01,AL
                                ;-------------------------------------------------------------
                                ; TEST ABILITY TO WRITE/READ THE MASK REGISTER
                                ;-------------------------------------------------------------
026F  B0 00                             MOV     AL,0                ; WRITE ZEROES TO IMR
0271  8A D8                             MOV     BL,AL               ; PRESET ERROR INDICATOR
0273  E6 21                             OUT     INTA01,AL           ; DEVICE INTERRUPTS ENABLED
0275  E4 21                             IN      AL,INTA01           ; READ IMR
0277  0A C0                             OR      AL,AL               ; IMR = 0?
0279  75 18                             JNZ     GERROR              ; NO - GO TO ERROR ROUTINE
027B  B0 FF                             MOV     AL,0FFH             ; DISABLE DEVICE INTERRUPTS
027D  E6 21                             OUT     INTA01,AL           ; WRITE ONES TO IMR
027F  E4 21                             IN      AL,INTA01           ; READ IMR
0281  04 01                             ADD     AL,1                ; ALL IMR BITS ON?
                                                                    ; (ADD SHOULD PRODUCE 0)
0283  75 0E                             JNZ     GERROR              ; NO - GO TO ERROR ROUTINE
                                        ;-------------------------------------------------------------
                                        ; CHECK FOR HOT INTERRUPTS
                                        ;-------------------------------------------------------------
                                        ;       INTERRUPTS ARE MASKED OFF.  NO INTERRUPTS SHOULD OCCUR.
0285  FB                                STI                         ; ENABLE EXTERNAL INTERRUPTS
0286  B9 0050                           MOV     CX,50H
0289  E2 FE                     HOT1:   LOOP    HOT1                ; WAIT FOR ANY INTERRUPTS
028B  8A 1E 0484 R                      MOV     BL,DATA_AREA[INTR_FLAG-DATA] ; DID ANY INTERRUPTS
                                                                    ;       OCCUR?
028F  0A DB                             OR      BL,BL
0291  74 05                             JZ      END_TESTG           ; NO - GO TO NEXT TEST
0293  B7 07                     GERROR: MOV     BH,07H              ; SET 07 SECTION OF ERROR MSG
0295  E9 09BC R                         JMP     E_MSG
0298                            END_TESTG:
                                ; FIRE THE DISKETTE WATCHDOG TIMER
0298  B0 E0                             MOV     AL,WD_ENABLE+WD_STROBE+FDC_RESET
029A  E6 F2                             OUT     0F2H,AL
029C  B0 A0                             MOV     AL,WD_ENABLE+FDC_RESET
029E  E6 F2                             OUT     0F2H,AL
                                        ASSUME  CS:CODE,DS:ABSO
                                ;-------------------------------------------------------------
                                ;       8253 TIMER CHECKOUT
                                ; DESCRIPTION
                                ;       VERIFY THAT THE TIMERS (0, 1, AND 2) FUNCTION PROPERLY.
                                ;       THIS INCLUDES CHECKING FOR STUCK BITS IN ALL THE TIMERS,
                                ;       THAT TIMER 1 RESPONDS TO TIMER 0 OUTPUTS, THAT TIMER 0
                                ;       INTERRUPTS WHEN IT SHOULD, AND THAT TIMER 2'S OUTPUT WORKS
                                ;       AS IT SHOULD.
                                ;       THERE ARE 7 POSSIBLE ERRORS DURING THIS CHECKOUT.
                                ;       BL VALUES FOR THE CALL TO E_MSG INCLUDE:
                                ;       0)      STUCK BITS IN TIMER 0
                                ;       1)      TIMER 1 DOES NOT RESPOND TO TIMER 0 OUTPUT
                                ;       2)      TIMER 0 INTERRUPT DOES NOT OCCUR
                                ;       3)      STUCK BITS IN TIMER 1
                                ;       4)      TIMER 2 OUTPUT INITIAL VALUE IS NOT LOW
                                ;       5)      STUCK BITS IN TIMER 2
                                ;       6)      TIMER 2 OUTPUT DOES NOT GO HIGH ON TERMINAL COUNT
; --------------------------------------------------------------------------------------------------
; A-12    
; --------------------------------------------------------------------------------------------------
                                ;---------------------------------------------------------------
                                ;       INITIALIZE TIMER 1 AND TIMER 0 FOR TEST
                                ;---------------------------------------------------------------

02A0  E8 E6D8 R                         CALL    MFG_UP              ; MFG CKPOINT=F6
02A3  B8 0176                           MOV     AX,0176H            ; SET TIMER 1 TO MODE 3 BINARY
02A6  BB FFFF                           MOV     BX,0FFFFH           ; INITIAL COUNT OF FFFF
02A9  E8 FFE0 R                         CALL    INIT_TIMER          ; INITIALIZE TIMER 1
02AC  B8 0036                           MOV     AX,0036H            ; SET TIMER 0 TO MODE 3 BINARY
                                                                    ; INITIAL COUNT OF FFFF
02AF  E8 FFE0 R                         CALL    INIT_TIMER          ; INITIALIZE TIMER 0

                                ;---------------------------------------------------------------
                                ;       SET BIT 5 OF PORT A0 SO TIMER 1 CLOCK WILL BE
                                ;       TIMER 0 OUTPUT RATHER THAN THE SYSTEM CLOCK.
                                ;---------------------------------------------------------------
02B2  B0 20                             MOV     AL,00100000B
02B4  E6 A0                             OUT     0A0H,AL

                                ;---------------------------------------------------------------
                                ;       CHECK IF ALL BITS GO ON AND OFF IN TIMER 0 (CHECK FOR STUCK
                                ;       BITS)
                                ;---------------------------------------------------------------
02B6  B4 00                             MOV     AH,0                ; TIMER 0
02B8  E8 036C R                         CALL    BITS_ON_OFF         ; LET SUBROUTINE CHECK IT
02BB  73 05                             JNB     TIMER1_NZ           ; NO STUCK BITS (CARRY FLAG NOT SET)
02BD  B3 00                             MOV     BL,0                ; STUCK BITS IN TIMER 0
02BF  E9 0362 R                         JMP     TIMER_ERROR

                                ;---------------------------------------------------------------
                                ;       SINCE TIMER 0 HAS COMPLETED AT LEAST ONE COMPLETE CYCLE,
                                ;       TIMER 1 SHOULD BE NON-ZERO.  CHECK THAT THIS IS THE CASE.
                                ;---------------------------------------------------------------

02C2                            TIMER1_NZ:
02C2  E4 41                             IN      AL,TIMER+1          ; READ LSB OF TIMER 1
02C4  8A E0                             MOV     AH,AL               ; SAVE LSB
02C6  E4 41                             IN      AL,TIMER+1          ; READ MSB OF TIMER 1
02C8  3D FFFF                           CMP     AX,0FFFFH           ; STILL FFFF?
02CB  75 05                             JNE     TIMER0_INTR         ; NO - TIMER 1 HAS BEEN BUMPED
02CD  B3 01                             MOV     BL,1                ; TIMER 1 WAS NOT BUMPED BY TIMER 0
02CF  E9 0362 R                         JMP     TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       CHECK FOR TIMER 0 INTERRUPT
                                ;---------------------------------------------------------------
02D2                            TIMER0_INTR:
02D2  FB                                STI                         ; ENABLE MASKABLE EXT INTERRUPTS
02D3  E4 21                             IN      AL,INTA01
02D5  24 FE                             AND     AL,0FEH             ; MASK ALL INTRS EXCEPT LVL 0
02D7  20 06 0484 R                      AND     DATA_AREA[INTR_FLAG-DATA],AL ; CLEAR INTR RECEIVED
02DB  E6 21                             OUT     INTA01,AL           ; WRITE THE 8259 IMR
02DD  B9 FFFF                           MOV     CX,0FFFFH           ; SET LOOP COUNT
02E0                            WAIT_INTR_LOOP:
02E0  F6 06 0484 R 01                   TEST    DATA_AREA[INTR_FLAG-DATA],1 ; TIMER 0 INT OCCUR?
02E5  75 06                             JNE     RESET_INTRS         ; YES - CONTINUE
02E7  E2 F7                             LOOP    WAIT_INTR_LOOP      ; WAIT FOR INTR FOR SPECIFIED TIME
02E9  B3 02                             MOV     BL,2                ; TIMER 0 INTR DIDN'T OCCUR
02EB  EB 75                             JMP     SHORT TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       HOUSEKEEPING FOR TIMER 0 INTERRUPTS
                                ;---------------------------------------------------------------
02ED                            RESET_INTRS:
02ED  FA                                CLI
                                ; SET TIMER INT. TO POINT TO MFG. HEARTBEAT ROUTINE IF IN MFG MODE
02EE  BA 0201                           MOV     DX,201H
02F1  EC                                IN      AL,DX               ; GET MFG. BITS
02F2  24 F0                             AND     AL,0F0H
02F4  3C 10                             CMP     AL,10H              ; SYS TEST MODE?
02F6  74 04                             JE      D6
02F8  0A C0                             OR      AL,AL               ; OR BURN-IN MODE
02FA  75 11                             JNZ     TIME_1
02FC  C7 06 0020 R 188D R       D6:     MOV     INT_PTR,OFFSET MFG_TICK ; SET TO POINT TO MFG.
                                                                    ; ROUTINE
0302  C7 06 0070 R 188D R               MOV     INTIC_PTR,OFFSET MFG_TICK ; ALSO SET USER TIMER INT
                                                                    ; FOR DIAGS. USE
0308  B0 FE                             MOV     AL,0FEH
030A  E6 21                             OUT     INTA01,AL
030C  FB                                STI
                                ;---------------------------------------------------------------
                                ;       RESET D5 OF PORT A0 SO THAT THE TIMER 1 CLOCK WILL BE
                                ;       PULSED BY THE SYSTEM CLOCK.
                                ;---------------------------------------------------------------
030D  B0 00                     TIME_1: MOV     AL,0                ; MAKE AL = 00
030F  E6 A0                             OUT     0A0H,AL
                                ;---------------------------------------------------------------
                                ;       CHECK FOR STUCK BITS IN TIMER 1
                                ;---------------------------------------------------------------
0311  B4 01                             MOV     AH,1                ; TIMER 1
0313  E8 036C R                         CALL    BITS_ON_OFF
0316  73 04                             JNB     TIMER2_INIT         ; NO STUCK BITS
0318  B3 03                             MOV     BL,3                ; STUCK BITS IN TIMER 1
031A  EB 46                             JMP     SHORT TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       INITIALIZE TIMER 2
                                ;---------------------------------------------------------------
031C                            TIMER2_INIT:
031C  B8 02B6                           MOV     AX,02B6H            ; SET TIMER 2 TO MODE 3 BINARY
031F  BB FFFF                           MOV     BX,0FFFFH           ; INITIAL COUNT
0322  E8 FFE0 R                         CALL    INIT_TIMER
                                ;---------------------------------------------------------------
                                ;       SET PB0 OF PORT_B OF 8255 (TIMER 2 GATE)
                                ;---------------------------------------------------------------
0325  E4 61                             IN      AL,PORT_B           ; CURRENT STATUS
0327  0C 01                             OR      AL,00000001B        ; SET BIT 0 - LEAVE OTHERS ALONE
0329  E6 61                             OUT     PORT_B,AL
; --------------------------------------------------------------------------------------------------
; A-13    
; --------------------------------------------------------------------------------------------------
032B  B4 02                             MOV     AH,2                ; TIMER 2
032D  E8 036C R                         CALL    BITS_ON_OFF
0330  73 04                             JNB     REINIT_T2           ; NO STUCK BITS
0332  B3 05                             MOV     BL,5                ; STUCK BITS IN TIMER 2
0334  EB 2C                             JMP     SHORT TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       CHECK FOR STUCK BITS IN TIMER 2
                                ;---------------------------------------------------------------
0336                            REINIT_T2:
                                ; DROP GATE TO TIMER 2
0336  E4 61                             IN      AL,PORT_B           ; CURRENT STATUS
0338  24 FE                             AND     AL,11111110B        ; RESET BIT 0 - LEAVE OTHERS ALONE
033A  E6 61                             OUT     PORT_B,AL
033C  B8 02B0                           MOV     AX,02B0H            ; SET TIMER 2 TO MODE 0 BINARY
033F  BB 000A                           MOV     BX,000AH            ; INITIAL COUNT OF 10
0342  E8 FFE0 R                         CALL    INIT_TIMER

                                ;---------------------------------------------------------------
                                ;       RE-INITIALIZE TIMER 2 WITH MODE 0 AND A SHORT COUNT
                                ;---------------------------------------------------------------

0345  E4 62                             IN      AL,PORT_C           ; CURRENT STATUS
0347  24 20                             AND     AL,00100000B        ; MASK OFF OTHER BITS
0349  74 04                             JZ      CK2_ON              ; IT'S LOW
034B  B3 04                             MOV     BL,4                ; PC5 OF PORT_C WAS HIGH WHEN IT
034D  EB 13                             JMP     SHORT TIMER_ERROR   ; SHOULD HAVE BEEN LOW

034F  E4 61                     CK2_ON: IN      AL,PORT_B           ; CURRENT STATUS
0351  0C 01                             OR      AL,00000001B        ; SET BIT 0 - LEAVE OTHERS ALONE
0353  E6 61                             OUT     PORT_B,AL

                                ;---------------------------------------------------------------
                                ;       CHECK PC5 OF PORT_C OF 8255 TO SEE IF THE OUTPUT OF TIMER 2
                                ;       IS LOW
                                ;---------------------------------------------------------------

0355  B9 000A                           MOV     CX,000AH            ; WAIT FOR OUTPUT GO HIGH, SHOULD
0358  E2 FE                     CK2_LO: LOOP    CK2_LO              ; BE LONGER THAN INITIAL COUNT
035A  E4 62                             IN      AL,PORT_C           ; CURRENT STATUS
035C  24 20                             AND     AL,00100000B        ; MASK OFF ALL OTHER BITS
035E  75 57                             JNZ     POD13_END           ; IT'S HIGH - WE'RE DONE!
0360  B3 06                             MOV     BL,6                ; TIMER 2 OUTPUT DID NOT GO HIGH

                                ;---------------------------------------------------------------
                                ;       8253 TIMER ERROR OCCURRED.  SET BH WITH MAJOR ERROR
                                ;       INDICATOR AND CALL E_MSG TO INFORM THE SYSTEM OF THE ERROR.
                                ;       (BL ALREADY CONTAINS THE MINOR ERROR INDICATOR TO TELL
                                ;       WHICH PART OF THE TEST FAILED.)
                                ;---------------------------------------------------------------
0362                            TIMER_ERROR:
0362  B7 08                             MOV     BH,8                ; TIMER ERROR INDICATOR
0364  E8 09BC R                         CALL    E_MSG
0367  EB 4E                             JMP     SHORT POD13_END
                                ;---------------------------------------------------------------
                                ;       BITS ON/OFF SUBROUTINE - USED FOR DETERMINING IF A
                                ;       PARTICULAR TIMER'S BITS GO ON AND OFF AS THEY SHOULD.
                                ;       THIS ROUTINE ASSUMES THAT THE TIMER IS USING BOTH THE LSB
                                ;       AND THE MSB.
                                ;     CALLING PARAMETER:
                                ;         (AH) = TIMER NUMBER (0, 1, OR 2)
                                ;     RETURNS:
                                ;         (CF) = 1 IF FAILED
                                ;         (CF) = 0 IF PASSED
                                ;     REGISTERS AX, BX, CX, DX, DI, AND SI ARE ALTERED.
                                ;---------------------------------------------------------------

0369                            LATCHES LABEL   BYTE
0369  00                                DB      00H                 ; LATCH MASK FOR TIMER 0
036A  40                                DB      40H                 ; LATCH MASK FOR TIMER 1
036B  80                                DB      80H                 ; LATCH MASK FOR TIMER 2

036C                            BITS_ON_OFF PROC    NEAR
036C  33 DB                             XOR     BX,BX               ; INITIALIZE BX REGISTER
036E  33 F6                             XOR     SI,SI               ; 1ST PASS - SI = 0
0370  BA 0040                           MOV     DX,TIMER            ; BASE PORT ADDRESS FOR TIMERS
0373  02 D4                             ADD     DL,AH
0375  BF 0369 R                         MOV     DI,OFFSET LATCHES   ; SELECT LATCH MASK
0378  32 C0                             XOR     AL,AL               ; CLEAR AL
037A  86 C4                             XCHG    AL,AH               ; AH -> AL
037C  03 F8                             ADD     DI,AX               ; TIMER LATCH MASK INDEX
                                ; 1ST PASS - CHECKS FOR ALL BITS TO COME ON
                                ; 2ND PASS - CHECKS FOR ALL BITS TO GO OFF
037E                            OUTER_LOOP:
037E  B9 0008                           MOV     CX,8                ; OUTER LOOP COUNTER
0381                            INNER_LOOP:
0381  51                                PUSH    CX                  ; SAVE OUTER LOOP COUNTER
0382  B9 FFFF                           MOV     CX,0FFFFH           ; INNER LOOP COUNTER
0385                            TST_BITS:
0385  2E: 8A 05                         MOV     AL,CS:[DI]          ; TIMER LATCH MASK
0388  E6 43                             OUT     TIM_CTL,AL          ; LATCH TIMER
038A  50                                PUSH    AX                  ; PAUSE
038B  58                                POP     AX
038C  EC                                IN      AL,DX               ; READ TIMER LSB
038D  0B F6                             OR      SI,SI
038F  75 0D                             JNE     SECOND              ; SECOND PASS
0391  0C 01                             OR      AL,01H              ; TURN LS BIT ON
0393  0A D8                             OR      BL,AL               ; TURN 'ON' BITS ON
0395  EC                                IN      AL,DX               ; READ TIMER MSB
0396  0A F8                             OR      BH,AL               ; TURN 'ON' BITS ON
0398  81 FB FFFF                        CMP     BX,0FFFFH           ; ARE ALL TIMER BITS ON?
039C  EB 07                             JMP     SHORT TST_CMP       ; DON'T CHANGE FLAGS
; --------------------------------------------------------------------------------------------------
; A-14  
; --------------------------------------------------------------------------------------------------
