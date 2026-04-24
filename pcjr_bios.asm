; -------------------------------------------------------------------------------------------------
; IBM PCjr BIOS LST File (C)IBM Corporation 1983
; Originally published in the IBM PCjr Technical Reference, Appendix A
; OCR'd by GloriousCow in 2026
;
;                               | <- ASM source begins on this column
; A-3
; -------------------------------------------------------------------------------------------------
                                ;
                                ;------------------------------------------------------------------
                                ; <CAVEAT EMPTOR>:
                                ;
                                ;       THE  BIOS  ROUTINES ARE MEANT TO BE ACCESSED THROUGH
                                ;       SOFTWARE INTERRUPTS ONLY.   ANY ADDRESSES PRESENT IN
                                ;       THE LISTINGS  ARE INCLUDED   ONLY FOR  COMPLETENESS,
                                ;       NOT FOR REFERENCE.   APPLICATIONS  WHICH   REFERENCE
                                ;       ABSOLUTE ADDRESSES   WITHIN THIS  CODE  VIOLATE  THE
                                ;       STRUCTURE AND DESIGN OF BIOS.
                                ;------------------------------------------------------------------
                                ;---------------------------------------
                                ;                EQUATES
                                ;---------------------------------------
= 0060                          PORT_A          EQU     60H     ; 8255 PORT A ADDR
= 0038                          CPUREG          EQU     38H     ; MASK FOR CPU REG BITS
= 0007                          CRTREG          EQU     7       ; MASK FOR CRT REG BITS
= 0061                          PORT_B          EQU     61H     ; 8255 PORT B ADDR
= 0062                          PORT_C          EQU     62H     ; 8255 PORT C ADDR
= 0063                          CMD_PORT        EQU     63H
= 0089                          MODE_8255       EQU     10001001B
= 0020                          INTA00          EQU     20H     ; 8259 PORT
= 0021                          INTA01          EQU     21H     ; 8259 PORT
= 0020                          EOI             EQU     20H
= 0040                          TIMER           EQU     40H
= 0043                          TIM_CTL         EQU     43H     ; 8253 TIMER CONTROL PORT ADDR
= 0040                          TIMER0          EQU     40H     ; 8253 TIMER/CNTER 0 PORT ADDR
= 0061                          KB_CTL          EQU     61H     ; CONTROL BITS FOR KEYBOARD
= 03DA                          VGA_CTL         EQU     03DAH   ; VIDEO GATE ARRAY CONTROL PORT
= 00A0                          NMI_PORT        EQU     0A0H    ; NMI CONTROL PORT
= 00B0                          PORT_B0         EQU     0B0H
= 03DF                          PAGREG          EQU     03DFH   ; CRT/CPU PAGE REGISTER
= 0060                          KBPORT          EQU     060H    ; KEYBOARD PORT
= 4000                          DIAG_TABLE_PTR  EQU     4000H
= 2000                          MINI            EQU     2000H
                                ;---------------------------------------
                                ;           DISKETTE EQUATES
                                ;---------------------------------------
= 00F2                          NEC_CTL         EQU     0F2H    ; CONTROL PORT FOR THE DISKETTE
= 0080                          FDC_RESET       EQU     80H     ; RESETS THE NEC (FLOPPY DISK
                                                                ; CONTROLLER).  0 RESETS,
                                                                ; 1 RELEASES THE RESET
= 0020                          WD_ENABLE       EQU     20H     ; ENABLES WATCH DOG TIMER IN NEC
= 0040                          WD_STROBE       EQU     40H     ; STROBES WATCHDOG TIMER
= 0001                          DRIVE_ENABLE    EQU     01H     ; SELECTS AND ENABLES DRIVE

= 00F4                          NEC_STAT        EQU     0F4H    ; STATUS REGISTER FOR THE NEC
= 0020                          BUSY_BIT        EQU     20H     ; BIT = 0 AT END OF EXECUTION PHASE
= 0040                          DIO             EQU     40H     ; INDICATES DIRECTION OF TRANSFER
= 0080                          RQM             EQU     80H     ; REQUEST FOR MASTER
= 00F5                          NEC_DATA        EQU     0F5H    ; DATA PORT FOR THE NEC
                                ;---------------------------------------
                                ;        8088 INTERRUPT LOCATIONS
                                ;---------------------------------------
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
0074                            PARM_PTR        LABEL   DWORD   ; POINTER TO VIDEO PARMS
0074                                    ORG     18H*4
0060                            BASIC_PTR       LABEL   WORD    ; ENTRY POINT FOR CASSETTE BASIC
0060                                    ORG     01EH*4          ; INTERRUPT 1EH
0078                            DISK_POINTER    LABEL   DWORD
0078                                    ORG     01FH*4          ; LOCATION OF POINTER
007C                            EXT_PTR         LABEL   DWORD   ; POINTER TO EXTENSION
007C                                    ORG     044H*4
0110                            CSET_PTR        LABEL   DWORD   ; POINTER TO DOT PATTERNS
0110                                    ORG     048H*4
0120                            KEY62_PTR       LABEL   WORD    ; POINTER TO 62 KEY KEYBOARD CODE
0120                                    ORG     049H*4
0124                            EXST            LABEL   WORD    ; POINTER TO EXT. SCAN TABLE
0124                                    ORG     081H*4
0204                            INT81           LABEL   WORD
0204                                    ORG     082H*4
0208                            INT82           LABEL   WORD
0208                                    ORG     089H*4
0224                            INT89           LABEL   WORD
0224                                    ORG     400H
0400                            DATA_AREA       LABEL   BYTE    ; ABSOLUTE LOCATION OF DATA SEGMENT
0400                            DATA_WORD       LABEL   WORD
0400                                    ORG     7C00H
7C00                            BOOT_LOCN       LABEL   FAR
7C00                            ABS0            ENDS
; -------------------------------------------------------------------------------------------------
; A-4
; -------------------------------------------------------------------------------------------------
                                ;------------------------------------------------
                                ; STACK -- USED DURING INITIALIZATION ONLY
                                ;------------------------------------------------
0000                            STACK           SEGMENT AT 30H
0000      80 [                                  DW      128 DUP (?)
                ????  
                      ]
0100  
0100                            TOS             LABEL   WORD
                                STACK           ENDS
                                ;------------------------------------------------
                                ;              ROM BIOS DATA AREAS
                                ;------------------------------------------------
0000                            DATA            SEGMENT AT 40H
0000      04 [                  RS232_BASE      DW      4 DUP(?) ; ADDRESSES OF RS232 ADAPTERS
                ????
                      ]
0008      04 [                  PRINTER_BASE    DW      4 DUP(?) ; ADDRESSES OF PRINTERS
                ????  
                      ]
0010  ????                      EQUIP_FLAG      DW      ?       ; INSTALLED HARDWARE
0012  ??                        KBD_ERR         DB      ?       ; COUNT OF KEYBOARD TRANSMIT ERRORS
0013  ????                      MEMORY_SIZE     DW      ?       ; USABLE MEMORY SIZE IN K BYTES
0015  ????                      TRUE_MEM        DW      ?       ; REAL MEMORY SIZE IN K BYTES
                                ;------------------------------------------------
                                ;             KEYBOARD DATA AREAS
                                ;------------------------------------------------
0017  ??                        KB_FLAG         DB      ?
                                ;----- SHIFT FLAG EQUATES WITHIN KB_FLAG
= 0040                          CAPS_STATE      EQU     40H     ; CAPS LOCK STATE HAS BEEN TOGGLED
= 0020                          NUM_STATE       EQU     20H     ; NUM LOCK STATE HAS BEEN TOGGLED
= 0008                          ALT_SHIFT       EQU     08H     ; ALTERNATE SHIFT KEY DEPRESSED
= 0004                          CTL_SHIFT       EQU     04H     ; CONTROL SHIFT KEY DEPRESSED
= 0002                          LEFT_SHIFT      EQU     02H     ; LEFT SHIFT KEY DEPRESSED
= 0001                          RIGHT_SHIFT     EQU     01H     ; RIGHT SHIFT KEY DEPRESSED
001B  ??                        KB_FLAG_1       DB      ?       ; SECOND BYTE OF KEYBOARD STATUS
= 0080                          INS_SHIFT       EQU     80H     ; INSERT KEY IS DEPRESSED
= 0040                          CAPS_SHIFT      EQU     40H     ; CAPS LOCK KEY IS DEPRESSED
= 0020                          NUM_SHIFT       EQU     20H     ; NUM LOCK KEY IS DEPRESSED
= 0010                          SCROLL_SHIFT    EQU     10H     ; SCROLL LOCK KEY IS DEPRESSED
= 0008                          HOLD_STATE      EQU     08H     ; SUSPEND KEY HAS BEEN TOGGLED
= 0004                          CLICK_ON        EQU     04H     ; INDICATES THAT AUDIO FEEDBACK IS
                                                                ; ENABLED
= 0002                          CLICK_SEQUENCE  EQU     02H     ; OCCURRENCE OF ALT-CTRL-CAPSLOCK HAS
                                                                ; OCCURED
0019  ??                        ALT_INPUT       DB      ?       ; STORAGE FOR ALTERNATE KEYPAD
                                                                ; ENTRY
001A  ????                      BUFFER_HEAD     DW      ?       ; POINTER TO HEAD OF KEYBOARD BUFF
001C  ????                      BUFFER_TAIL     DW      ?       ; POINTER TO TAIL OF KEYBOARD BUFF
001E      10 [                  KB_BUFFER       DW      16 DUP(?) ; ROOM FOR 15 ENTRIES
                ????  
                      ]
                                ; ------ HEAD = TAIL INDICATES THAT THE BUFFER IS EMPTY
= 0045                          NUM_KEY         EQU     69      ; SCAN CODE FOR NUMBER LOCK
= 0046                          SCROLL_KEY      EQU     70      ; SCROLL LOCK KEY
= 0038                          ALT_KEY         EQU     56      ; ALTERNATE SHIFT KEY SCAN CODE
= 001D                          CTL_KEY         EQU     29      ; SCAN CODE FOR CONTROL KEY
= 003A                          CAPS_KEY        EQU     58      ; SCAN CODE FOR SHIFT LOCK
= 002A                          LEFT_KEY        EQU     42      ; SCAN CODE FOR LEFT SHIFT
= 0036                          RIGHT_KEY       EQU     54      ; SCAN CODE FOR RIGHT SHIFT
= 0052                          INS_KEY         EQU     82      ; SCAN CODE FOR INSERT KEY
= 0053                          DEL_KEY         EQU     83      ; SCAN CODE FOR DELETE KEY
                                ; ------------------------------------------------
                                ;            DISKETTE DATA AREAS
                                ; ------------------------------------------------
003E  ??                        SEEK_STATUS     DB      ?       ; DRIVE RECALIBRATION STATUS
                                                                ; BIT 0 = DRIVE NEEDS RECAL BEFORE
                                                                ; NEXT SEEK IF BIT IS = 0.
003F  ??                        MOTOR_STATUS    DB      ?       ; MOTOR STATUS
                                                                ; BIT 0 = DRIVE 0 IS CURRENTLY
                                                                ; RUNNING
0040  ??                        MOTOR_COUNT     DB      ?       ; TIME OUT COUNTER FOR DRIVE
                                                                ; TURN OFF
= 0025                          MOTOR_WAIT      EQU     37      ; 2 SECS OF COUNTS FOR MOTOR
                                                                ; TURN OFF
0041  ??                        DISKETTE_STATUS DB      ?       ; RETURN CODE STATUS BYTE
= 0080                          TIME_OUT        EQU     80H     ; ATTACHMENT FAILED TO RESPOND
= 0040                          BAD_SEEK        EQU     40H     ; SEEK OPERATION FAILED
= 0020                          BAD_NEC         EQU     20H     ; NEC CONTROLLER HAS FAILED
= 0010                          BAD_CRC         EQU     10H     ; BAD CRC ON DISKETTE READ
= 0009                          DMA_BOUNDARY    EQU     09H     ; ATTEMPT TO DMA ACROSS 64K
                                                                ; BOUNDARY
= 0008                          BAD_DMA         EQU     08H     ; DMA OVERRUN ON OPERATION
= 0004                          RECORD_NOT_FND  EQU     04H     ; REQUESTED SECTOR NOT FOUND
= 0003                          WRITE_PROTECT   EQU     03H     ; WRITE ATTEMPTED ON WRITE
                                                                ; PROTECTED DISK
= 0002                          BAD_ADDR_MARK   EQU     02H     ; ADDRESS MARK NOT FOUND
= 0001                          BAD_CMD         EQU     01H     ; BAD COMMAND GIVEN TO DISKETTE I/O
0042      07 [                  NEC_STATUS      DB      7 DUP(?) ; STATUS BYTES FROM NEC
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
;                               A-5
; --------------------------------------------------------------------------------------------------
                                ; ---------------------------------------------
                                ;              VIDEO DISPLAY DATA AREA
                                ; ---------------------------------------------
0049  ??                        CRT_MODE        DB      ?       ; CURRENT CRT MODE
004A  ????                      CRT_COLS        DW      ?       ; NUMBER OF COLUMNS ON SCREEN
004C  ????                      CRT_LEN         DW      ?       ; LENGTH OF REGEN IN BYTES
004E  ????                      CRT_START       DW      ?       ; STARTING ADDRESS IN REGEN BUFFER
                                CURSOR_POSN     DW      8 DUP(?) ; CURSOR FOR UP TO 8 PAGES


0060  ????                      CURSOR_MODE     DW      ?       ; CURRENT CURSOR MODE SETTING
0062  ??                        ACTIVE_PAGE     DB      ?       ; CURRENT PAGE BEING DISPLAYED
0063  ????                      ADDR_6845       DW      ?       ; BASE ADDRESS FOR ACTIVE DISPLAY
                                                                ; CARD
0065  ??                        CRT_MODE_SET    DB      ?       ; CURRENT SETTING OF THE
                                                                ; CRT MODE REGISTER
0066  ??                        CRT_PALLETTE    DB      ?       ; CURRENT PALETTE MASK SETTING
                                ; ---------------------------------------------
                                ;              CASSETTE DATA AREA
                                ; ---------------------------------------------
0067  ????                      EDGE_CNT        DW      ?       ; TIME COUNT AT DATA EDGE
0069  ????                      CRC_REG         DW      ?       ; CRC REGISTER
006B  ??                        LAST_VAL        DB      ?       ; LAST INPUT VALUE

                                ; ---------------------------------------------
                                ;              TIMER DATA AREA
                                ; ---------------------------------------------
006C  ????                      TIMER_LOW       DW      ?       ; LOW WORD OF TIMER COUNT
006E  ????                      TIMER_HIGH      DW      ?       ; HIGH WORD OF TIMER COUNT
0070  ??                        TIMER_OFL       DB      ?       ; TIMER HAS ROLLED OVER SINCE LAST
                                                                ; READ

                                ; ---------------------------------------------
                                ;              SYSTEM DATA AREA
                                ; ---------------------------------------------
0071  ??                        BIOS_BREAK      DB      ?       ; BIT 7=1 IF BREAK KEY HAS BEEN HIT
0072  ????                      RESET_FLAG      DW      ?       ; WORD=1234H IF KEYBOARD RESET
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
0084  ??                        INTR_FLAG       DB      ?       ; FLAG TO INDICATE AN INTERRUPT
                                                                ; HAPPENED
                                ; ---------------------------------------------
                                ;           62 KEY KEYBOARD DATA AREA
                                ; ---------------------------------------------
0085  ??                        CUR_CHAR        DB      ?       ; CURRENT CHARACTER FOR TYPAMATIC
0086  ??                        VAR_DELAY       DB      ?       ; DETERMINES WHEN INITIAL DELAY IS
                                                                ; OVER
= 000F                          DELAY_RATE      EQU     0FH     ; INCREASES INITIAL DELAY
0087  ??                        CUR_FUNC        DB      ?       ; CURRENT FUNCTION
0088  ??                        KB_FLAG_2       DB      ?       ; 3RD BYTE OF KEYBOARD FLAGS
= 0004                          RANGE           EQU     4       ; NUMBER OF POSITIONS TO SHIFT
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
0089  ??                        HORZ_POS        DB      ?       ; CURRENT VALUE OF HORIZONTAL
                                                                ; START PARM
008A  ??                        PAGDAT          DB      ?       ; IMAGE OF DATA WRITTEN TO PAGREG
008B                            DATA            ENDS

                                ; ---------------------------------------------
                                ;                EXTRA DATA AREA
                                ; ---------------------------------------------
0000                            XXDATA          SEGMENT AT 50H
0000  ??                        STATUS_BYTE     DB      ?
                                ; THE FOLLOWING AREA IS USED ONLY DURING DIAGNOSTICS
                                ; (POST AND ROM RESIDENT)
0001  ??                        DCP_MENU_PAGE   DB      ?       ; TO CURRENT PAGE FOR DIAG. MENU
0002  ????                      DCP_ROW_COL     DW      ?       ; CURRENT ROW/COLUMN COORDINATES
                                                                ; FOR DIAG MENU   
0004  ??                        WRAP_FLAG       DB      ?       ; INTERNAL/EXTERNAL 8250 WRAP
                                                                ; INDICATOR
; --------------------------------------------------------------------------------------------------
; A-6
; --------------------------------------------------------------------------------------------------
0005  ??                        MFG_TST         DB      ?       ; INITIALIZATION FLAG
0006  ????                      MEM_TOT         DW      ?       ; WORD EQUIV. TO HIGHEST SEGMENT IN
                                                                ; MEMORY
0008  ????                      MEM_DONES       DW      ?       ; CURRENT SEGMENT VALUE FOR
                                                                ; BACKGROUND MEM TEST
000A  ????                      MEM_DONEO       DW      ?       ; CURRENT OFFSET VALUE FOR
                                                                ; BACKGROUND MEM TEST
000C  ????                      INITC0          DW      ?       ; SAVE AREA FOR INTERRUPT 1C
000E  ????                      INT1CS          DW      ?       ; ROUTINE
0010  ??                        MENU_UP         DB      ?       ; FLAG TO INDICATE WHETHER MENU IS
                                                                ; ON SCREEN (FF=YES, 0=NO)
0011  ??                        DONE128         DB      ?       ; COUNTER TO KEEP TRACK OF 128 BYTE
                                                                ; BLOCKS TESTED BY BGMEM
0012  ????                      KBDONE          DW      ?       ; TOTAL K OF MEMORY THAT HAS BEEN
                                                                ; TESTED BY BACKGROUND MEM TEST
                                ; ---------------------------------------------
                                ;       POST DATA AREA
                                ; ---------------------------------------------
0014  ????                      IO_ROM_INIT     DW      ?       ; POINTER TO OPTIONAL I/O ROM INIT
                                                                ; ROUTINE
0016  ????                      IO_ROM_SEG      DW      ?       ; POINTER TO IO ROM SEGMENT
0018  ??                        POST_ERR        DB      ?       ; FLAG TO INDICATE ERROR OCCURRED
                                                                ; DURING POST
0019  09 [                      MODEM_BUFFER    DB      9 DUP(?) ; MODEM RESPONSE BUFFER
          ??
        ]

0022  ????                      MFG_RTN         DW      ?       ; (MAX 9 CHARS)
0024  ????                                      DW      ?       ; POINTER TO MFG. OUTPUT ROUTINE

                                ; ---------------------------------------------
                                ;            ERIAL PRINTER DATA
                                ; ---------------------------------------------
0026  ????                      SP_FLAG         DW      ?
0028  ??                        SP_CHAR         DB      ?
                                                                ; THE FOLLOWING SIX ENTRIES ARE
                                                                ; DATA PERTAINING TO NEW STICK                                                                
0029  ????                      NEW_STICK_DATA  DW      ?       ; RIGHT STICK DELAY
002B  ????                                      DW      ?       ; RIGHT BUTTON A DELAY
002D  ????                                      DW      ?       ; RIGHT BUTTON B DELAY
002F  ????                                      DW      ?       ; LEFT STICK DELAY
0031  ????                                      DW      ?       ; LEFT BUTTON A DELAY
0033  ????                                      DW      ?       ; LEFT BUTTON B DELAY
0035  ????                                      DW      ?       ; RIGHT STICK LOCATION
0037  ????                                      DW      ?       ; UNUSED
0039  ????                                      DW      ?       ; UNUSED
003B  ????                                      DW      ?       ; LEFT STICK POSITION
003D                            XXDATA          ENDS                                               
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
                                                                ; SECTOR
                                ;    BUFFER FOR READ AND WRITE OPERATION
= 0200                          DK_BUF_LEN      EQU     512     ; 512 BYTES/SECTOR
0029  0200 [                    READ_BUF        DB      DK_BUF_LEN DUP(0)
              00                
                  ] 

0229  0100 [                    WRITE_BUF       DB      (DK_BUF_LEN/2) DUP(6DH,0BH)
              6D             
              0B
                  ]

0429  ??                        ;   INFO FLAGS
042A  ??                        REQUEST_IN      DB      ?       ; SELECTION CHARACTER
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
; -------------------------------------------------------------------------------------------------
;                               A-7
; -------------------------------------------------------------------------------------------------
0444  ??                        ;   ERROR PARAMETERS
                                DK_ER_OCCURED   DB      ?       ; ERROR HAS OCCURRED
0445  ??                        DK_ER_L1        DB      ?       ; CUSTOMER ERROR LEVEL
0446  ??                        DK_ER_L2        DB      ?       ; SERVICE ERROR LEVEL
0447  ??                        ER_STATUS_BYTE  DB      ?       ; STATUS BYTE RETURN FROM INT 13H
                                                                ; LANGUAGE TABLE
0448  ??                        LANG_BYTE       DB      ?       ; PORT B0 TO DETERMINE WHICH
0449                            DKDATA          ENDS            ; LANGUAGE TO USE
                                ;-----------------------------------------------
                                ;               VIDEO DISPLAY BUFFER
                                ;-----------------------------------------------
0000                            VIDEO_RAM       SEGMENT AT 0B800H
0000  4000 [                    DB              16384 DUP(?)
              ??
                  ]  

4000                            VIDEO_RAM       ENDS
                                ;-----------------------------------------------
                                ;               ROM RESIDENT CODE
                                ;-----------------------------------------------
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
                                ;-----------------------------------------------
                                ;             MESSAGE AREA FOR POST
                                ;-----------------------------------------------
0030  45 52 52 4F 52            ERROR_ERR       DB      'ERROR' ; GENERAL ERROR PROMPT
0035  41                        MEM_ERR         DB      'A'     ; MEMORY ERROR
0036  42                        KEY_ERR         DB      'B'     ; KEYBOARD ERROR MSG
0037  43                        CASS_ERR        DB      'C'     ; CASSETTE ERROR MESSAGE
0038  44                        COM1_ERR        DB      'D'     ; ON-BOARD SERIAL PORT ERR. MSG
0039  45                        COM2_ERR        DB      'E'     ; SERIAL PORTION OF MODEM ERROR
003A  46                        ROM_ERR         DB      'F'     ; OPTIONAL GENERIC BIOS ROM ERROR
003B  47                        CART_ERR        DB      'G'     ; CARTRIDGE ERROR
003C  48                        DISK_ERR        DB      'H'     ; DISKETTE ERR
                                ;
003D                            F4              LABEL   WORD    ; PRINTER SOURCE TABLE
003D  0378                                      DW      378H
003F  0278                                      DW      278H
0041                            F4E             LABEL   WORD
0041  EF                        IMASKS          LABEL   BYTE    ; INTERRUPT MASKS FOR 8259
                                                                ; INTERRUPT CONTROLLER
0042  F7                                        DB      0EFH    ; MODEM INTR MASK
                                                DB      0F7H    ; SERIAL PRINTER INTR MASK                                
                                ;-----------------------------------------
                                ; SETUP                                  :
                                ;       DISABLE NMI, MASKABLE INTS.      :
                                ;       SOUND CHIP, AND VIDEO.           :
                                ;       TURN DRIVE 0 MOTOR OFF           :
                                ;-----------------------------------------
                                        ASSUME  CS:CODE,DS:ABSO,ES:NOTHING,SS:STACK
0043                                    RESET   LABEL   FAR
0043  B0 00                     START:  MOV     AL,0
0045  E6 A0                             OUT     0A0H,AL         ; DISABLES NMI
0047  FE C8                             DEC     AL              ; SEND FF TO MFG_TESTER
0049  E6 10                             OUT     10H,AL    
004B  E4 A0                             IN      AL,0A0H         ; RESET NMI F/F
004D  FA                                CLI                     ; DISABLES MASKABLE INTERRUPTS
                                                                ; DISABLE ATTENUATION IN SOUND CHIP
                                                                ; REG ADDRESS IN AH, ATTENUATOR OFF
004E  B8 108F                           MOV     AX,108FH        ; IN AL
0051  BA 00C0                           MOV     DX,00C0H        ; ADDRESS OF SOUND CHIP
0054  B9 0004                           MOV     CX,4            ; 4 ATTENUATORS TO DISABLE
0057  0A C4                     L1:     OR      AL,AH           ; COMBINE REG ADDRESS AND DATA
0059  EE                                OUT     DX,AL   
005A  80 C4 20                          ADD     AH,20H          ; POINT TO NEXT REG
005D  E2 F8                             LOOP    L1
005F  B0 A0                             MOV     AL,WD_ENABLE+FDC_RESET ; TURN DRIVE 0 MOTOR OFF,
                                                                ; ENABLE TIMER
0061  E6 F2                             OUT     0F2H,AL
0063  BA 03DA                           MOV     DX,VGA_CTL      ; VIDEO GATE ARRAY CONTROL
0066  EC                                IN      AL,DX           ; SYNC VGA TO ACCEPT REG
0067  B0 04                             MOV     AL,4            ; SET VGA RESET REG
0069  EE                                OUT     DX,AL           ; SELECT IT
006A  B0 01                             MOV     AL,1            ; SET ASYNC RESET
006C  EE                                OUT     DX,AL           ; RESET VIDEO GATE ARRAY
                                ;----------------------------------------
                                ; TEST 1                                :
                                ;       8088 PROCESSOR TEST             :
                                ; DESCRIPTION                           :
                                ;       VERIFY 8088 FLAGS, REGISTERS    :
                                ;       AND CONDITIONAL JUMPS           :
                                ;                                       :
                                ; MFG. ERROR CODE 0001H                 :
                                ;----------------------------------------
; ----------------------------------------------------------------------------------------------
; A-8
; ----------------------------------------------------------------------------------------------                          
006D B4 D5                              MOV     AH,0D5H         ; SET SF, CF, ZF, AND AF FLAGS ON
006F 9E                                 SAHF    
0070 73 4C                              JNC     L4              ; GO TO ERR ROUTINE IF CF NOT SET
0072 75 4A                              JNZ     L4              ; GO TO ERR ROUTINE IF ZF NOT SET
0074 7B 48                              JNP     L4              ; GO TO ERR ROUTINE IF PF NOT SET
0076 79 46                              JNS     L4              ; GO TO ERR ROUTINE IF SF NOT SET
0078 9F                                 LAHF                    ; LOAD FLAG IMAGE TO AH
0079 B1 05                              MOV     CL,5            ; LOAD CNT REG WITH SHIFT CNT
007B D2 EC                              SHR     AH,CL           ; SHIFT AF INTO CARRY BIT POS
007D 73 3F                              JNC     L4              ; GO TO ERR ROUTINE IF AF NOT SET
007F B0 40                              MOV     AL,40H          ; SET THE OF FLAG ON
0081 D0 E0                              SHL     AL,1            ; SETUP FOR TESTING
0083 71 39                              JNO     L4              ; GO TO ERR ROUTINE IF OF NOT SET
0085 32 E4                              XOR     AH,AH           ; SET AH = 0
0087 9E                                 SAHF                    ; CLEAR SF, CF, ZF, AND PF
0088 76 34                              JBE     L4              ; GO TO ERR ROUTINE IF CF ON
                                ; GO TO ERR ROUTINE IF ZF ON
008A 78 32                              JS      L4              ; GO TO ERR ROUTINE IF SF ON
008C 7A 30                              JP      L4              ; GO TO ERR ROUTINE IF PF ON
008E 9F                                 LAHF                    ; LOAD FLAG IMAGE TO AH
008F B1 05                              MOV     CL,5            ; LOAD CNT REG WITH SHIFT CNT
0091 D2 EC                              SHR     AH,CL           ; SHIFT 'AF' INTO CARRY BIT POS
0093 72 29                              JC      L4              ; GO TO ERR ROUTINE IF ON
0095 D0 E4                              SHL     AH,1            ; CHECK THAT 'OF' IS CLEAR
0097 70 25                              JO      L4              ; GO TO ERR ROUTINE IF ON
                                ; ----- READ/WRITE THE 8088 GENERAL AND SEGMENTATION REGISTERS
                                ;       WITH ALL ONE'S AND ZEROE'S.
0099 B8 FFFF                            MOV     AX,0FFFFH       ; SETUP ONE'S PATTERN IN AX
009C F9                                 STC
009D 8E D8                      L2:     MOV     DS,AX           ; WRITE PATTERN TO ALL REGS
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
00B3 33 C7                              XOR     AX,DI           ; PATTERN MAKE IT THRU ALL REGS
00B5 75 07                              JNZ     L4              ; NO - GO TO ERR ROUTINE
00B7 F8                                 CLC
00B8 EB E3                              JMP     L2
00BA 0B C7                      L3:     OR      AX,DI           ; ZERO PATTERN MAKE IT THRU?
00BC 74 0C                              JZ      L5              ; YES - GO TO NEXT TEST
00BE BA 0010                    L4:     MOV     DX,0010H        ; HANDLE ERROR
00C1 B0 00                              MOV     AL,0            ;
00C3 EE                                 OUT     DX,AL           ; ERROR 0001
00C4 42                                 INC     DX    
00C5 EE                                 OUT     DX,AL   
00C6 FE C0                              INC     AL    
00C8 EE                                 OUT     DX,AL   
00C9 F4                                 HLT                     ; HALT
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
00CA B0 FE                              MOV     AL,0FEH         ; SEND FE TO MFG
00CC E6 10                              OUT     10H,AL    
00CE B0 89                              MOV     AL,MODE_8255   
00D0 E6 63                              OUT     CMD_PORT,AL     ; CONFIGURES I/O PORTS
00D2 2B C0                              SUB     AX,AX           ; TEST PATTERN SEED = 0000
00D4 8A C4                      L6:     MOV     AL,AH   
00D6 E6 60                              OUT     PORT_A,AL       ; WRITE PATTERN TO PORT A
00D8 E4 60                              IN      AL,PORT_A       ; READ PATTERN FROM PORT A
00DA E6 61                              OUT     PORT_B,AL       ; WRITE PATTERN TO PORT B
00DC E4 61                              IN      AL,PORT_B       ; READ OUTPUT PORT
00DE 3A C4                              CMP     AL,AH           ; DATA AS EXPECTED?
00E0 75 06                              JNE     L7              ; IF NOT, SOMETHING IS WRONG
00E2 FE C4                              INC     AH              ; MAKE NEW DATA PATTERN
00E4 75 EE                              JNZ     L6              ; LOOP TILL 255 PATTERNS DONE
00E6 EB 05                              JMP     SHORT L8        ; CONTINUE IF DONE
00E8 B3 02                      L7:     MOV     BL,02H          ; SET ERROR FLAG (BH=00 NOW)
00EA E9 09BC R                          JMP     E_MSG           ; GO ERROR ROUTINE
00ED 32 C0                      L8:     XOR     AL,AL   
00EF E6 60                              OUT     KBPORT,AL       ; CLEAR KB PORT
00F1 E4 62                              IN      AL,PORT_C       ;
00F3 24 08                              AND     AL,00001000B    ; 64K CARD PRESENT?
00F5 B0 1B                              MOV     AL,1BH          ; PORT SETTING FOR 64K SYS
00F7 75 02                              JNZ     L9              ;
00F9 B0 3F                              MOV     AL,3FH          ; PORT SETTING FOR 128K SYS
00FB BA 03DF                    L9:     MOV     DX,PAGREG       ;
00FE EE                                 OUT     DX,AL           ;
00FF B0 0D                              MOV     AL,00001101B    ; INITIALIZE OUTPUT PORTS
0101 E6 61                              OUT     PORT_B,AL       ;
; -------------------------------------------------------------------------------------------------
; A-9
; -------------------------------------------------------------------------------------------------
                                ;------------------------------------------------------------------
                                ; PART 3
                                ;       SET UP VIDEO GATE ARRAY AND 6845 TO GET MEMORY WORKING
                                ;------------------------------------------------------------------
0103 B0 FD                              MOV     AL,0FDH
0105 E6 10                              OUT     10H,AL          ;
0107 BA 03D4                            MOV     DX,03D4H        ; SET ADDRESS OF 6845
010A BB F0A4 R                          MOV     BX,OFFSET VIDEO_PARMS ; POINT TO 6845 PARMS
010D B9 0040 90                         MOV     CX,M0040        ; SET PARM LEN
0111 32 E4                              XOR     AH,AH           ; AH IS REG #
0113 8A C4                      L10:    MOV     AL,AH           ; GET 6845 REG #
0115 EE                                 OUT     DX,AL
0116 42                                 INC     DX              ; POINT TO DATA PORT
0117 FE C4                              INC     AH              ; NEXT REG VALUE
0119 2E: 8A 07                          MOV     AL,CS:[BX]      ; GET TABLE VALUE
011C EE                                 OUT     DX,AL           ; OUT TO CHIP
011D 43                                 INC     BX              ; NEXT IN TABLE
011E 4A                                 DEC     DX              ; BACK TO POINTER REG
011F E2 F2                              LOOP    L10
0121 BA 03DA                    ;   START VGA WITHOUT VIDEO ENABLED
                                        MOV     DX,VGA_CTL      ; SET ADDRESS OF VGA
0124 EC                                 IN      AL,DX           ; BE SURE ADDR/DATA FLAG IS   
                                                                ; IN THE PROPER STATE                                
0125 B9 0005                            MOV     CX,5            ; # OF REGISTERS
0128 32 E4                              XOR     AH,AH           ; AH IS REG COUNTER
012A 8A C4                      L11:    MOV     AL,AH           ; GET REG #
012C EE                                 OUT     DX,AL           ; SELECT IT
012D 32 C0                              XOR     AL,AL           ; SET ZERO FOR DATA
012F EE                                 OUT     DX,AL
0130 FE C4                              INC     AH              ; NEXT REG
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
                                ;---------------------------------------------------------------
0134 B0 FC                              MOV     AL,0FCH
0136 E6 10                              OUT     10H,AL          ; MFG OUT=FC
                                ; CHECK MODULE AT F000:0 (LENGTH 32K)
0138 33 F6                              XOR     SI,SI           ; INDEX OFFSET WITHIN SEGMENT OF
                                                                ; FIRST BYTE
013A 8C C8                              MOV     AX,CS           ; SET UP STACK SEGMENT
013C 8E D0                              MOV     SS,AX
013E 8E D8                              MOV     DS,AX           ; LOAD DS WITH SEGMENT OF ADDRESS
                                                                ; SPACE OF BIOS/BASIC
0140 B9 8000                            MOV     CX,8000H        ; NUMBER OF BYTES TO BE TESTED, 32K
0143 BC 001B R                          MOV     SP,OFFSET Z1    ; SET UP STACK POINTER SO THAT
                                                                ; RETURN WILL COME HERE
0146 E9 FEEB R                          JMP     ROS_CHECKSUM    ; JUMP TO ROUTINE WHICH PERFORMS
                                                                ; CRC CHECK
0149 74 06                      L12:    JZ      L13             ; MODULE AT F000:0 OK, GO CHECK
                                                                ; OTHER MODULE AT F000:8000
014B BB 0003                            MOV     BX,0003H        ; SET ERROR CODE
014E E9 09BC R                          JMP     E_MSG           ; INDICATE ERROR
0151 B9 8000                    L13:    MOV     CX,8000H        ; LOAD COUNT (SI POINTING TO START
0154 E9 FEEB R                          JMP     ROS_CHECKSUM    ; OF NEXT MODULE AT THIS POINT)
0157 74 06                      L14:    JZ      L15             ; PROCEED IF NO ERROR
0159 BB 0004                            MOV     BX,0004H        ; INDICATE ERROR
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
                                ;  MFG. ERROR CODE 04XX FOR SYSTEM BOARD MEM.
                                ;                  05XX FOR 64K ATTRIB. CD. MEM
                                ;                  06XX FOR ERRORS IN BOTH
                                ;                  (XX= ERROR BITS)
                                ;---------------------------------------------------------------;
015F B0 FB                              MOV     AL,0FBH
0161 E6 10                              OUT     10H,AL          ; SET MFG FLAG=FB
0163 B9 0400                            MOV     CX,0400H        ; SET FOR 1K WORDS, 2K BYTES
0166 33 C0                              XOR     AX,AX   
0168 8E C0                              MOV     ES,AX           ; LOAD ES WITH 0000 SEGMENT
016A E9 0B59 R                          JMP     PODSTG    
016D 75 19                      L16:    JNZ     L20             ; BAD STORAGE FOUND
016F B0 FA                              MOV     AL,0FAH         ; MFG OUT=FA
0171 E6 10                              OUT     10H,AL    
0173 B9 0400                            MOV     CX,400H         ; 1024 WORDS TO BE TESTED IN THE
                                                                ; REGEN BUFFER
0176 E4 60                              IN      AL,PORT_A       ; WHERE IS THE REGEN BUFFER?
0178 3C 1B                              CMP     AL,1BH          ; TOP OF 64K?
017A B8 0F80                            MOV     AX,0F80H        ; SET POINTER TO THERE IF IT IS
017D 74 02                              JE      L18   
017F B4 1F                              MOV     AH,1FH          ; OR SET POINTER TO TOP OF 128K
0181 8E C0                      L18:    MOV     ES,AX   
0183 E9 0B59 R                          JMP     PODSTG          ;
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
01AB B0 F9                      L23:    MOV     AL,0F9H         ; MFG OUT =F9
01AD E6 10                              OUT     10H,AL    
01AF B9 0400                            MOV     CX,0400H        ; 1K WORDS
01B2 B8 BB80                            MOV     AX,0BB80H       ; POINT TO AREA JUST TESTED WITH
                                                                ; DIRECT ADDRESSING

01B5 8E C0                              MOV     ES,AX
01B7 E9 0B59 R                          JMP     PODSTG
01BA 74 06                      L24:    JZ      L25
01BC BB 0005                            MOV     BX,0005H        ; ERROR 0005
01BF E9 09BC R                          JMP     E_MSG
                                ;------ SETUP STACK SEG AND SP
01C2 B8 0030                    L25:    MOV     AX,0030H        ; GET STACK VALUE
01C5 8E D0                              MOV     SS,AX           ; SET THE STACK UP
01C7 BC 0100 R                          MOV     SP,OFFSET TOS   ; STACK IS READY TO GO
01CA 33 C0                              XOR     AX,AX           ; SET UP DATA SEG
01CC 8E D8                              MOV     DS,AX
                                ;------ SETUP CRT PAGE
01CE C7 06 0462 R 0007                  MOV     DATA_WORD(ACTIVE_PAGE-DATA),07
                                ;------ SET PRELIMINARY MEMORY SIZE WORD
01D4 BB 0040                            MOV     BX,64
01D7 E4 62                              IN      AL,PORT_C       ;
01D9 24 08                              AND     AL,08H          ; 64K CARD PRESENT?
01DB B0 1B                              MOV     AL,1BH          ; PORT SETTING FOR 64K SYSTEM
01DD 75 05                              JNZ     L26             ; SET TO 64K IF NOT
01DF 83 C3 40                           ADD     BX,64           ; ELSE SET FOR 128K
01E2 B0 3F                              MOV     AL,3FH          ; PORT SETTING FOR 128K SYSTEM
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
                                ;                       00 - UNUSED
                                ;                       01 - 40X25 BW USING COLOR CARD
                                ;                       10 - 80X25 BW USING COLOR CARD
                                ;                       11 - 80X25 BW USING BW CARD
                                ;       BIT 3,2 = PLANAR RAM SIZE (10=48K,11=64K)
                                ;       BIT 1 NOT USED
                                ;       BIT 0 = 1 (IPL DISKETTE INSTALLED)
                                ;---------------------------------------------------
0250  BB 1118                           ASSUME  CS:CODE,DS:ABSO
                                        MOV     BX,1118H        ; DEFAULT GAMEI0,40X25,NO DMA,48K ON
                                                                ; PLANAR
0253  E4 62                             IN      AL,PORT_C
0255  24 08                             AND     AL,08H          ; 64K CARD PRESENT
0257  75 03                             JNZ     D55             ; NO, JUMP
0259  80 CB 04                          OR      BL,4            ; SET 64K ON PLANAR
025C  89 1E 0410 R              D55:    MOV     DATA_WORD[EQUIP_FLAG-DATA],BX
                                ;-------------------------------------------------------------
                                ; TEST 7
                                ;       INITIALIZE AND TEST THE 8259 INTERRUPT CONTROLLER CHIP
                                ; MFG ERR. CODE 07XX (XX=00, DATA PATH OR INTERNAL FAILURE,
                                ;       XX=ANY OTHER BITS ON=UNEPECTED INTERRUPTS
                                ;-------------------------------------------------------------
0260  E8 E6D8 R                         CALL    MFG_UP          ; MFG CODE=F7
                                        ASSUME  DS:ABSO,CS:CODE
0263  B0 13                             MOV     AL,13H          ; ICW1 - RESET EDGE SENSE CIRCUIT,
                                                                ;SET SINGLE 8259 CHIP AND ICW4 READ
0265  E6 20                             OUT     INTA00,AL
0267  B0 08                             MOV     AL,8            ; ICW2 - SET INTERRUPT TYPE 8 (8-F)
0269  E6 21                             OUT     INTA01,AL
026B  B0 09                             MOV     AL,9            ; ICW4 - SET BUFFERED MODE/SLAVE
                                                                ;   AND 8086 MODE
026D  E6 21                             OUT     INTA01,AL
                                ;-------------------------------------------------------------
                                ;       TEST ABILITY TO WRITE/READ THE MASK REGISTER
                                ;-------------------------------------------------------------
026F  B0 00                             MOV     AL,0             ; WRITE ZEROES TO IMR
0271  8A D8                             MOV     BL,AL            ; PRESET ERROR INDICATOR
0273  E6 21                             OUT     INTA01,AL        ; DEVICE INTERRUPTS ENABLED
0275  E4 21                             IN      AL,INTA01        ; READ IMR
0277  0A C0                             OR      AL,AL            ; IMR = 0?
0279  75 18                             JNZ     GERROR           ; NO - GO TO ERROR ROUTINE
027B  B0 FF                             MOV     AL,0FFH          ; DISABLE DEVICE INTERRUPTS
027D  E6 21                             OUT     INTA01,AL        ; WRITE ONES TO IMR
027F  E4 21                             IN      AL,INTA01        ; READ IMR
0281  04 01                             ADD     AL,1             ; ALL IMR BITS ON?
                                                                 ; (ADD SHOULD PRODUCE 0)
0283  75 0E                             JNZ     GERROR           ; NO - GO TO ERROR ROUTINE
                                ;-------------------------------------------------------------
                                ;       CHECK FOR HOT INTERRUPTS
                                ;-------------------------------------------------------------
                                ;       INTERRUPTS ARE MASKED OFF.  NO INTERRUPTS SHOULD OCCUR.
0285  FB                                STI                     ; ENABLE EXTERNAL INTERRUPTS
0286  B9 0050                           MOV     CX,50H
0289  E2 FE                     HOT1:   LOOP    HOT1            ; WAIT FOR ANY INTERRUPTS
028B  8A 1E 0484 R                      MOV     BL,DATA_AREA[INTR_FLAG-DATA] ; DID ANY INTERRUPTS
                                                                ;       OCCUR?
028F  0A DB                             OR      BL,BL
0291  74 05                             JZ      END_TESTG       ; NO - GO TO NEXT TEST
0293  B7 07                     GERROR: MOV     BH,07H          ; SET 07 SECTION OF ERROR MSG
0295  E9 09BC R                         JMP     E_MSG
0298                            END_TESTG:
                                ; FIRE THE DISKETTE WATCHDOG TIMER
0298  B0 E0                             MOV     AL,WD_ENABLE+WD_STROBE+FDC_RESET
029A  E6 F2                             OUT     0F2H,AL
029C  B0 A0                             MOV     AL,WD_ENABLE+FDC_RESET
029E  E6 F2                             OUT     0F2H,AL
                                        ASSUME  CS:CODE,DS:ABSO
                                ;------------------------------------------------------------------
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
; -------------------------------------------------------------------------------------------------
; A-12    
; -------------------------------------------------------------------------------------------------
                                ;------------------------------------------------------------------
                                ;       INITIALIZE TIMER 1 AND TIMER 0 FOR TEST
                                ;------------------------------------------------------------------

02A0  E8 E6D8 R                         CALL    MFG_UP          ; MFG CKPOINT=F6
02A3  B8 0176                           MOV     AX,0176H        ; SET TIMER 1 TO MODE 3 BINARY
02A6  BB FFFF                           MOV     BX,0FFFFH       ; INITIAL COUNT OF FFFF
02A9  E8 FFE0 R                         CALL    INIT_TIMER      ; INITIALIZE TIMER 1
02AC  B8 0036                           MOV     AX,0036H        ; SET TIMER 0 TO MODE 3 BINARY
                                                                ; INITIAL COUNT OF FFFF
02AF  E8 FFE0 R                         CALL    INIT_TIMER      ; INITIALIZE TIMER 0
                                ;------------------------------------------------------------------
                                ;       SET BIT 5 OF PORT A0 SO TIMER 1 CLOCK WILL BE PULSED BY THE
                                ;       TIMER 0 OUTPUT RATHER THAN THE SYSTEM CLOCK.
                                ;------------------------------------------------------------------
02B2  B0 20                             MOV     AL,00100000B
02B4  E6 A0                             OUT     0A0H,AL
                                ;---------------------------------------------------------------
                                ;       CHECK IF ALL BITS GO ON AND OFF IN TIMER 0 (CHECK FOR STUCK
                                ;          BITS)
                                ;---------------------------------------------------------------
02B6  B4 00                             MOV     AH,0            ; TIMER 0
02B8  E8 036C R                         CALL    BITS_ON_OFF     ; LET SUBROUTINE CHECK IT
02BB  73 05                             JNB     TIMER1_NZ       ; NO STUCK BITS (CARRY FLAG NOT SET)
02BD  B3 00                             MOV     BL,0            ; STUCK BITS IN TIMER 0
02BF  E9 0362 R                         JMP     TIMER_ERROR

                                ;---------------------------------------------------------------
                                ;       SINCE TIMER 0 HAS COMPLETED AT LEAST ONE COMPLETE CYCLE,
                                ;       TIMER 1 SHOULD BE NON-ZERO.  CHECK THAT THIS IS THE CASE.
                                ;---------------------------------------------------------------

02C2                            TIMER1_NZ:
02C2  E4 41                             IN      AL,TIMER+1      ; READ LSB OF TIMER 1
02C4  8A E0                             MOV     AH,AL           ; SAVE LSB
02C6  E4 41                             IN      AL,TIMER+1      ; READ MSB OF TIMER 1
02C8  3D FFFF                           CMP     AX,0FFFFH       ; STILL FFFF?
02CB  75 05                             JNE     TIMER0_INTR     ; NO - TIMER 1 HAS BEEN BUMPED
02CD  B3 01                             MOV     BL,1            ; TIMER 1 WAS NOT BUMPED BY TIMER 0
02CF  E9 0362 R                         JMP     TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       CHECK FOR TIMER 0 INTERRUPT
                                ;---------------------------------------------------------------
02D2                            TIMER0_INTR:
02D2  FB                                STI                     ; ENABLE MASKABLE EXT INTERRUPTS
02D3  E4 21                             IN      AL,INTA01
02D5  24 FE                             AND     AL,0FEH         ; MASK ALL INTRS EXCEPT LVL 0
02D7  20 06 0484 R                      AND     DATA_AREA[INTR_FLAG-DATA],AL ; CLEAR INTR RECEIVED
02DB  E6 21                             OUT     INTA01,AL       ; WRITE THE 8259 IMR
02DD  B9 FFFF                           MOV     CX,0FFFFH       ; SET LOOP COUNT
02E0                            WAIT_INTR_LOOP:
02E0  F6 06 0484 R 01                   TEST    DATA_AREA[INTR_FLAG-DATA],1 ; TIMER 0 INT OCCUR?
02E5  75 06                             JNE     RESET_INTRS     ; YES - CONTINUE
02E7  E2 F7                             LOOP    WAIT_INTR_LOOP  ; WAIT FOR INTR FOR SPECIFIED TIME
02E9  B3 02                             MOV     BL,2            ; TIMER 0 INTR DIDN'T OCCUR
02EB  EB 75                             JMP     SHORT TIMER_ERROR
                                ;---------------------------------------------------------------
                                ;       HOUSEKEEPING FOR TIMER 0 INTERRUPTS
                                ;---------------------------------------------------------------
02ED                            RESET_INTRS:
02ED  FA                                CLI
                                ; SET TIMER INT. TO POINT TO MFG. HEARTBEAT ROUTINE IF IN MFG MODE
02EE  BA 0201                           MOV     DX,201H
02F1  EC                                IN      AL,DX           ; GET MFG. BITS
02F2  24 F0                             AND     AL,0F0H
02F4  3C 10                             CMP     AL,10H          ; SYS TEST MODE?
02F6  74 04                             JE      D6
02F8  0A C0                             OR      AL,AL           ; OR BURN-IN MODE
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
030D  B0 00                     TIME_1: MOV     AL,0            ; MAKE AL = 00
030F  E6 A0                             OUT     0A0H,AL
                                ;------------------------------------------------------------------
                                ;       CHECK FOR STUCK BITS IN TIMER 1
                                ;------------------------------------------------------------------
0311  B4 01                             MOV     AH,1            ; TIMER 1
0313  E8 036C R                         CALL    BITS_ON_OFF
0316  73 04                             JNB     TIMER2_INIT     ; NO STUCK BITS
0318  B3 03                             MOV     BL,3            ; STUCK BITS IN TIMER 1
031A  EB 46                             JMP     SHORT TIMER_ERROR
                                ;------------------------------------------------------------------
                                ;       INITIALIZE TIMER 2
                                ;------------------------------------------------------------------
031C                            TIMER2_INIT:
031C  B8 02B6                           MOV     AX,02B6H        ; SET TIMER 2 TO MODE 3 BINARY
031F  BB FFFF                           MOV     BX,0FFFFH       ; INITIAL COUNT
0322  E8 FFE0 R                         CALL    INIT_TIMER
                                ;------------------------------------------------------------------
                                ;       SET PB0 OF PORT_B OF 8255 (TIMER 2 GATE)
                                ;------------------------------------------------------------------
0325  E4 61                             IN      AL,PORT_B       ; CURRENT STATUS
0327  0C 01                             OR      AL,00000001B    ; SET BIT 0 - LEAVE OTHERS ALONE
0329  E6 61                             OUT     PORT_B,AL
; -------------------------------------------------------------------------------------------------
; A-13    
; -------------------------------------------------------------------------------------------------
032B  B4 02                             MOV     AH,2            ; TIMER 2
032D  E8 036C R                         CALL    BITS_ON_OFF
0330  73 04                             JNB     REINIT_T2       ; NO STUCK BITS
0332  B3 05                             MOV     BL,5            ; STUCK BITS IN TIMER 2
0334  EB 2C                             JMP     SHORT TIMER_ERROR
                                ;------------------------------------------------------------------
                                ;       CHECK FOR STUCK BITS IN TIMER 2
                                ;------------------------------------------------------------------
0336                            REINIT_T2:
                                ; DROP GATE TO TIMER 2
0336  E4 61                             IN      AL,PORT_B       ; CURRENT STATUS
0338  24 FE                             AND     AL,11111110B    ; RESET BIT 0 - LEAVE OTHERS ALONE
033A  E6 61                             OUT     PORT_B,AL
033C  B8 02B0                           MOV     AX,02B0H        ; SET TIMER 2 TO MODE 0 BINARY
033F  BB 000A                           MOV     BX,000AH        ; INITIAL COUNT OF 10
0342  E8 FFE0 R                         CALL    INIT_TIMER
                                ;---------------------------------------------------------------
                                ;       RE-INITIALIZE TIMER 2 WITH MODE 0 AND A SHORT COUNT
                                ;---------------------------------------------------------------
0345  E4 62                             IN      AL,PORT_C       ; CURRENT STATUS
0347  24 20                             AND     AL,00100000B    ; MASK OFF OTHER BITS
0349  74 04                             JZ      CK2_ON          ; IT'S LOW
034B  B3 04                             MOV     BL,4            ; PC5 OF PORT_C WAS HIGH WHEN IT
034D  EB 13                             JMP     SHORT TIMER_ERROR ; SHOULD HAVE BEEN LOW

034F  E4 61                     CK2_ON: IN      AL,PORT_B       ; CURRENT STATUS
0351  0C 01                             OR      AL,00000001B    ; SET BIT 0 - LEAVE OTHERS ALONE
0353  E6 61                             OUT     PORT_B,AL
                                ;------------------------------------------------------------------
                                ;       CHECK PC5 OF PORT_C OF 8255 TO SEE IF THE OUTPUT OF TIMER 2
                                ;       IS LOW
                                ;------------------------------------------------------------------
0355  B9 000A                           MOV     CX,000AH        ; WAIT FOR OUTPUT GO HIGH, SHOULD
0358  E2 FE                     CK2_LO: LOOP    CK2_LO          ; BE LONGER THAN INITIAL COUNT
035A  E4 62                             IN      AL,PORT_C       ; CURRENT STATUS
035C  24 20                             AND     AL,00100000B    ; MASK OFF ALL OTHER BITS
035E  75 57                             JNZ     POD13_END       ; IT'S HIGH - WE'RE DONE!
0360  B3 06                             MOV     BL,6            ; TIMER 2 OUTPUT DID NOT GO HIGH

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
0369  00                                DB      00H             ; LATCH MASK FOR TIMER 0
036A  40                                DB      40H             ; LATCH MASK FOR TIMER 1
036B  80                                DB      80H             ; LATCH MASK FOR TIMER 2

036C                            BITS_ON_OFF PROC    NEAR
036C  33 DB                             XOR     BX,BX           ; INITIALIZE BX REGISTER
036E  33 F6                             XOR     SI,SI           ; 1ST PASS - SI = 0
0370  BA 0040                           MOV     DX,TIMER        ; BASE PORT ADDRESS FOR TIMERS
0373  02 D4                             ADD     DL,AH
0375  BF 0369 R                         MOV     DI,OFFSET LATCHES ; SELECT LATCH MASK
0378  32 C0                             XOR     AL,AL           ; CLEAR AL
037A  86 C4                             XCHG    AL,AH           ; AH -> AL
037C  03 F8                             ADD     DI,AX           ; TIMER LATCH MASK INDEX
                                ; 1ST PASS - CHECKS FOR ALL BITS TO COME ON
                                ; 2ND PASS - CHECKS FOR ALL BITS TO GO OFF
037E                            OUTER_LOOP:
037E  B9 0008                           MOV     CX,8            ; OUTER LOOP COUNTER
0381                            INNER_LOOP:
0381  51                                PUSH    CX              ; SAVE OUTER LOOP COUNTER
0382  B9 FFFF                           MOV     CX,0FFFFH       ; INNER LOOP COUNTER
0385                            TST_BITS:
0385  2E: 8A 05                         MOV     AL,CS:[DI]      ; TIMER LATCH MASK
0388  E6 43                             OUT     TIM_CTL,AL      ; LATCH TIMER
038A  50                                PUSH    AX              ; PAUSE
038B  58                                POP     AX
038C  EC                                IN      AL,DX           ; READ TIMER LSB
038D  0B F6                             OR      SI,SI
038F  75 0D                             JNE     SECOND          ; SECOND PASS
0391  0C 01                             OR      AL,01H          ; TURN LS BIT ON
0393  0A D8                             OR      BL,AL           ; TURN 'ON' BITS ON
0395  EC                                IN      AL,DX           ; READ TIMER MSB
0396  0A F8                             OR      BH,AL           ; TURN 'ON' BITS ON
0398  81 FB FFFF                        CMP     BX,0FFFFH       ; ARE ALL TIMER BITS ON?
039C  EB 07                             JMP     SHORT TST_CMP   ; DON'T CHANGE FLAGS
; --------------------------------------------------------------------------------------------------
; A-14  
; --------------------------------------------------------------------------------------------------
039E                            SECOND: 
039E  22 D8                             AND     BL,AL           ; CHECK FOR ALL BITS OFF
03A0  EC                                IN      AL,DX           ; READ MSB
03A1  22 F8                             AND     BH,AL           ; TURN OFF BITS
03A3  0B DB                             OR      BX,BX           ; ALL OFF?
03A5                            TST_CMP: 
03A5  74 07                             JE      CHK_END         ; YES - SEE IF DONE
03A7  E2 DC                             LOOP    TST_BITS        ; KEEP TRYING
03A9  59                                POP     CX              ; RESTORE OUTER LOOP COUNTER
03AA  E2 D5                             LOOP    INNER_LOOP      ; TRY AGAIN
03AC  F9                                STC                     ; ALL TRIES EXHAUSTED - FAILED TEST
03AD  C3                                RET
03AE                            CHK_END: 
03AE  59                                POP     CX              ; POP FORMER OUTER LOOP COUNTER
03AF  46                                INC     SI
03B0  83 FE 02                          CMP     SI,2
03B3  75 C9                             JNE     OUTER_LOOP      ; CHECK FOR ALL BITS TO GO OFF
03B5  F8                                CLC                     ; TIMER BITS ARE WORKING PROPERLY
03B6  C3                                RET
03B7                            BITS_ON_OFF     ENDP
                                POD13_END:
                                ;------------------------------------------------------------
                                ;                       CRT ATTACHMENT TEST
                                ;
                                ; 1. INIT CRT TO 40X25 - BW
                                ; 2. CHECK FOR VERTICAL AND VIDEO ENABLES, AND CHECK
                                ;    TIMING OF SAME
                                ; 3. CHECK VERTICAL INTERRUPT
                                ; 4. CHECK RED, BLUE, GREEN, AND INTENSIFY DOTS
                                ; 5. INIT TO 40X25 - COLOR
                                ;   MFG. ERROR CODE 09XX (XX-SEE COMMENTS IN CODE)
                                ;------------------------------------------------------------
= A0AC                          MAVT            EQU     0A0ACH  ; MAXIMUM TIME FOR VERT/VERT
                                                                ; (NOMINAL + 10%)
= C460                          MIVT            EQU     0C460H  ; MINIMUM TIME FOR VERT/VERT
                                                                ; (NOMINAL - 10%)
                                ; NOMINAL TIME IS B286H FOR 60 hz.
= 00C8                          EPF             EQU     200     ; NUMBER OF ENABLES PER FRAME
03B7  E8 E6D8 R                         CALL    MFG_UP          ; MFG. CHECKPOINT= F5
03BA  FA                                CLI
03BB  B0 70                             MOV     AL,01110000B    ; SET TIMER 1 TO MODE 0
03BD  E6 43                             OUT     TIM_CTL,AL
03BF  B9 8000                           MOV     CX,8000H
03C2  E2 FE                     Q1:     LOOP    Q1              ; WAIT FOR MODE SET TO "TAKE"
03C4  B0 00                             MOV     AL,00H
03C6  E6 41                             OUT     TIMER+1,AL      ; SEND FIRST BYTE TO TIMER
03C8  2B C0                             SUB     AX,AX           ; SET MODE 40X25 - BW
03CA  CD 10                             INT     10H
03CC  B8 0507                           MOV     AX,0507H        ; SET TO VIDEO PAGE 7
03CF  CD 10                             INT     10H
03D1  BA 03DA                           MOV     DX,03DAH        ; SET ADDRESSING TO VIDEO ARRAY
03D4  2B C9                             SUB     CX,CX           ;
                                ; LOOK FOR VERTICAL
03D6  EC                        Q2:     IN      AL,DX           ; GET STATUS
03D7  A8 08                             TEST    AL,00001000B    ; VERTICAL THERE YET?
03D9  75 06                             JNE     Q3              ; CONTINUE IF IT IS
03DB  E2 F9                             LOOP    Q2              ; KEEP LOOKING TILL COUNT EXHAUSTED
03DD  B3 00                             MOV     BL,00           ;
03DF  EB 4C                             JMP     SHORT Q115      ; NO VERTICAL = ERROR 0900
                                ; GOT VERTICAL - START TIMER
03E1  32 C0                     Q3:     XOR     AL,AL           ;
03E3  E6 41                             OUT     TIMER+1,AL      ; SEND 2ND BYTE TO TIMER TO START
03E5  2B DB                             SUB     BX,BX           ; INIT. ENABLE COUNTER
                                ; WAIT FOR VERTICAL TO GO AWAY
03E7  33 C9                     Q4:     XOR     CX,CX
03E9  EC                                IN      AL,DX           ; GET STATUS
03EA  A8 08                             TEST    AL,00001000B    ; VERTICAL STILL THERE?
03EC  74 06                             JZ      Q5              ; CONTINUE IF IT'S GONE
03EE  E2 F9                             LOOP    Q4              ; KEEP LOOKING TILL COUNT EXHAUSTED
03F0  B3 01                             MOV     BL,01H
03F2  EB 39                             JMP     SHORT Q115      ; VERTICAL STUCK ON = ERROR 0901
                                ; NOW START LOOKING FOR ENABLE TITIONS
03F4  2B C9                     Q5:     SUB     CX,CX
03F6  EC                        Q6:     IN      AL,DX           ; GET STATUS
03F7  A8 01                             TEST    AL,00000001B    ; ENABLE ON YET?
03F9  75 0A                             JNE     Q7              ; GO ON IF IT IS
03FB  A8 08                             TEST    AL,00001000B    ; VERTICAL ON AGAIN?
03FD  75 22                             JNE     Q11             ; CONTINUE IF IT IS
03FF  E2 F5                             LOOP    Q6              ; KEEP LOOKING IF NOT
0401  B3 02                             MOV     BL,02H
0403  EB 28                             JMP     SHORT Q115      ; ENABLE STUCK OFF = ERROR 0902
                                ; MAKE SURE VERTICAL WENT OFF WINABLE GOING ON
0405  A8 08                     Q7:     TEST    AL,00001000B    ; VERTICAL OFF?
0407  74 04                             JZ      Q8              ; GO ON IF IT IS
0409  B3 03                             MOV     BL,03H
040B  EB 20                             JMP     SHORT Q115      ; VERTICAL STUCK ON = ERROR 0903
                                ; NOW WAIT FOR ENABLE TO GO OFF
040D  2B C9                     Q8:     SUB     CX,CX
040F  EC                        Q9:     IN      AL,DX           ; GET STATUS
0410  A8 01                             TEST    AL,00000001B    ; ENABLE OFF YET?
0412  74 06                             JZ      Q10             ; PROCEED IF IT IS
0414  E2 F9                             LOOP    Q9              ; KEEP LOOKING IF NOT YET LOW
0416  B3 04                             MOV     BL,04H
0418  EB 13                             JMP     SHORT Q115      ; ENABLE STUCK ON = ERROR 0904
                                ; ENABLE HAS TOGGLED, BUMP COUNTER AND TEST FOR NEXT VERTICAL
041A  43                        Q10:    INC     BX              ; BUMP ENABLE COUNTER
041B  74 04                             JZ      Q11             ; IF COUNTER WRAPS, ERROR
                                ; DID ENABLE GO LOW BECAUSE OF
041D  A8 08                             TEST    AL,00001000B    ; VERTICAL?
041F  74 03                             JZ      Q5              ; IF NOT, LOOK FOR ANOTHER ENABLE
                                                                ;   TOGGLE
; --------------------------------------------------------------------------------------------------
; A-15
; --------------------------------------------------------------------------------------------------
                                ; HAVE HAD COMPLETE VERTICAL-VERTICAL CYCLE, NOW TEST RESULTS
0421  B0 40                     Q11:    MOV     AL,40H          ; LATCH TIMER1
0423  E6 43                             OUT     TIM_CTL,AL      ;
0425  81 FB 00C8                        CMP     BX,EPF          ; NUMBER OF ENABLES BETWEEN
                                                                ; VERTICALS O.K.?

0429  74 04                             JE      Q12             ;
042B  B3 05                             MOV     BL,05H          ;
042D  EB 74                     Q115:   JMP     SHORT Q22       ; WRONG # ENABLES = ERROR 0905
042F  E4 41                     Q12:    IN      AL,TIMER+1      ; GET TIMER VALUE LOW
0431  8A E0                             MOV     AH,AL           ; SAVE IT
0433  90                                                        ;
0434  E4 41                             IN      AL,TIMER+1      ; GET TIMER HIGH
0436  86 E0                             XCHG    AH,AL           ;
0438  FB                                STI                     ; INTERRUPTS BACK ON
0439  90                                NOP                     
043A  3D A0AC                           CMP     AX,MAVT         ;
043D  7D 04                             JGE     Q13             ;
043F  B3 06                             MOV     BL,06H          ;
0441  EB 60                             JMP     SHORT Q22       ; VERTICALS TOO FAR APART
                                                                ; = ERROR 0906
0443  3D C460                   Q13:    CMP     AX,MIVT         ;
0446  7E 04                             JLE     Q14             ;
0448  B3 07                             MOV     BL,07H          ;
044A  EB 57                             JMP     SHORT Q22       ; VERTICALS TOO CLOSE TOGETHER
                                                                ; = ERROR 0907
                                ; TIMINGS SEEM O.K., NOW CHECK VERTICAL INTERRUPT (LEVEL 5)
044C  2B C9                     Q14:    SUB     CX,CX               ; SET TIMEOUT REG
044E  E4 21                             IN      AL,INTA01           ;
0450  24 DF                             AND     AL,11011111B        ; UNMASK INT. LEVEL 5
0452  E6 21                             OUT     INTA01,AL           ;
0454  20 06 0484 R                      AND     DATA_AREA[INTR_FLAG-DATA],AL
0458  FB                                STI                         ; ENABLE INTS.
0459  F6 06 0484 R 20           Q15:    TEST    DATA_AREA[INTR_FLAG-DATA],00100000B ; SEE IF INTR.
                                                                    ; 5 HAPPENED YET
045E  75 06                             JNZ     Q16                 ; GO ON IF IT DID
0460  E2 F7                             LOOP    Q15                 ; KEEP LOOKING IF IT DIDN'T
0462  B3 08                             MOV     BL,08H              ;
0464  EB 3D                             JMP     SHORT Q22           ; NO VERTICAL INTERRUPT
                                                                    ; = ERROR 0908

0466  E4 21                     Q16:    IN      AL,INTA01           ; DISABLE INTERRUPTS FOR LEVEL 5
0468  0C 20                             OR      AL,00100000B        ;
046A  E6 21                             OUT     INTA01,AL           ;
                                ; SEE IF RED, GREEN, BLUE AND INTENSIFY DOTS WORK
                                ; FIRST, SET A LINE OF REVERSE VIDEO, INTENSIFIED BLANKS INTO VIDEO
                                ; BUFFER
046C  B8 09DB                           MOV     AX,09DBH            ; WRITE CHARS, BLOCKS
046F  BB 077F                           MOV     BX,077FH            ; PAGE 7, REVERSE VIDEO,
                                                                    ;     HIGH INTENSITY
0472  B9 0028                           MOV     CX,40               ; 40 CHARACTERS
0475  CD 10                             INT     10H                 ;
0477  33 C0                             XOR     AX,AX               ; START WITH BLUE DOTS
0479  2B C9                     Q17:    SUB     CX,CX               ;
047B  EE                                OUT     DX,AL               ; SET VIDEO ARRAY ADDRESS FOR DOTS

047C  EC                        Q18:    IN      AL,DX               ; GET STATUS
047D  A8 10                             TEST    AL,00010000B        ; DOT THERE?
047F  75 08                             JNZ     Q19                 ; GO LOOK FOR DOT TO TURN OFF
0481  E2 F9                             LOOP    Q18                 ; CONTINUE TESTING FOR DOT ON
0483  B3 10                             MOV     BL,10H              ;
0485  0A DC                             OR      BL,AH               ; OR IN DOT BEING TESTED
0487  EB 1A                             JMP     SHORT Q22           ; DOT NOT COMING ON = ERROR 091X
                                                                    ; ( X=0, BLUE; X=1, GREEN;
                                                                    ;   X=2, RED; X=3, INTENSITY)
                                ; SEE IF DOT GOES OFF
0489  2B C9                     Q19:    SUB     CX,CX               ;
048B  EC                        Q20:    IN      AL,DX               ; GET STATUS
048C  A8 10                             TEST    AL,00010000B        ; IS DOT STILL ON?
048E  74 08                             JE      Q21                 ; GO ON IF DOT OFF
0490  E2 F9                             LOOP    Q20                 ; ELSE, KEEP WAITING FOR DOT
                                                                    ;     TO GO OFF
0492  B3 20                             MOV     BL,20H              ;
0494  0A DC                             OR      BL,AH               ; OR IN DOT BEING TESTED
0496  EB 0B                             JMP     SHORT Q22           ; DOT STUCK ON = ERROR 092X
                                                                    ; (X=0, BLUE; X=1, GREEN;
                                                                    ;  X=2, RED; X=3, INTENSITY)
                                ; ADJUST TO POINT TO NEXT DOT
0498  FE C4                     Q21:    INC     AH                  ;
049A  80 FC 04                          CMP     AH,4                ; ALL 4 DOTS DONE?
049D  74 09                             JE      Q23                 ; GO END
049F  8A C4                             MOV     AL,AH               ;
04A1  EB D6                             JMP     Q17                 ; GO LOOK FOR ANOTHER DOT
04A3  B7 09                     Q22:    MOV     BH,09H              ; SET MSB OF ERROR CODE
04A5  E9 09BC R                         JMP     E_MSG               ;
                                ; DONE WITH TEST RESET TO 40X25 - COLOR
                                        ASSUME  DS:DATA
04A8  E8 138B R                 Q23:    CALL    DDS                 ;
04AB  B8 0001                           MOV     AX,0001H            ; INIT TO 40X25 - COLOR
04AE  CD 10                             INT     10H                 ;
04B0  B8 0507                           MOV     AX,0507H            ; SET TO VIDEO PAGE 7
04B3  CD 10                             INT     10H                 ;
04B5  81 3E 0072 R 1234                 CMP     RESET_FLAG,1234H    ; WARM START?
04BB  74 03                             JE      Q24                 ; BYPASS PUTTING UP POWER-ON SCREEN
04BD  E8 0C21 R                         CALL    PUT_LOGO            ; PUT LOGO ON SCREEN
; -------------------------------------------------------------------------------------------------
; A-16
; -------------------------------------------------------------------------------------------------
04C0  B0 76                     Q24:    MOV     AL,01110110B        ; RE-INIT TIMER 1
04C2  E6 43                             OUT     TIM_CTL,AL          ;
04C4  B0 00                             MOV     AL,00H
04C6  E6 41                             OUT     TIMER+1,AL
04C8  90                                NOP
04C9  90                                NOP
04CA  E6 41                             OUT     TIMER+1,AL

                                        ASSUME  DS:ABSO
04CC  E8 E6D8 R                         CALL    MFG_UP              ; MFG CHECKPOINT=F4
04CF  33 C0                             XOR     AX,AX
04D1  8E D8                             MOV     DS,AX
04D3  C7 06 0008 R 0F78 R               MOV     NMI_PTR,OFFSET KBDNMI ; SET INTERRUPT VECTOR
04D9  C7 06 0120 R F068 R               MOV     KEY62_PTR,OFFSET KEY_SCAN_SAVE ; SET VECTOR FOR
                                                                    ; POD INT HANDLER
04DF  0E                                PUSH    CS
04E0  58                                POP     AX
04E1  A3 0122 R                         MOV     KEY62_PTR+2,AX
                                        ASSUME  DS:DATA
04E4  E8 138B R                         CALL    DDS                 ; SET DATA SEGMENT
04E7  BE 001E R                         MOV     SI,OFFSET KB_BUFFER ; SET KEYBOARD PARMS
04EA  89 36 001A R                      MOV     BUFFER_HEAD,SI
04EE  89 36 001C R                      MOV     BUFFER_TAIL,SI
04F2  89 36 0080 R                      MOV     BUFFER_START,SI
04F6  83 C6 20                          ADD     SI,32               ; SET DEFAULT BUFFER OF 32 BYTES
04F9  89 36 0082 R                      MOV     BUFFER_END,SI
04FD  E4 A0                             IN      AL,0A0H             ; CLEAR NMI F/F
04FF  B0 80                             MOV     AL,80H              ; ENABLE NMI
0501  E6 A0                             OUT     0A0H,AL             ;

                                ; IF A KEY IS STUCK, THE BUFFER SHOULD FILL WITH THAT KEY'S CODE
                                ; THIS WILL BE CHECKED LATER
                                ;---------------------------------------------------------
                                ;              MEMORY SIZE DETERMINE AND TEST
                                ; THIS ROUTINE WILL DETERMINE HOW MUCH MEM
                                ; IS ATTACHED TO THE SYSTEM (UP TO 640KB)
                                ; AND SET "MEMORY_SIZE" AND "REAL_MEMORY"
                                ; WORDS IN THE DATA AREA.
                                ;
                                ; AFTER THIS, MEMORY WILL BE EITHER TESTED
                                ; OR CLEARED, DEPENDING ON THE CONTENTS OF
                                ; "RESET_FLAG".
                                ;  MFG. ERROR CODES   -0AXX PLANAR BD ERROR
                                ;                     -0BXX 64K CD ERROR
                                ;                     -0CXX ERRORS IN BOTH
                                ;                      ODD AND EVEN BYTES
                                ;                      IN A 128K SYS
                                ;                     -1YXX MEMORY ABOVE 128K
                                ;                      Y=SEGMENT HAVING TROUBLE
                                ;                      XX= ERROR BITS
                                ;---------------------------------------------------------
                                        ASSUME  DS:DATA
0503  E8 E6D8 R                         CALL    MFG_UP          ; MFG CHECKPOINT=F3
0506  BB 0040                           MOV     BX,64           ; START WITH BASE 64K
0509  E4 62                             IN      AL,PORT_C       ; GET CONFIG BYTE
050B  A8 08                             TEST    AL,00001000B    ; SEE IF 64K CARD INSTALLED
050D  75 03                             JNE     Q25             ; (BIT 4 WILL BE 0 IF CARD PLUGGED)
050F  83 C3 40                          ADD     BX,64           ; ADD 64K
0512  53                        Q25:    PUSH    BX              ; SAVE K COUNT
0513  83 EB 10                          SUB     BX,16           ; SUBTRACT 16K CRT REFRESH SPACE
0516  89 1E 0013 R                      MOV     [MEMORY_SIZE],BX ; LOAD "CONTIGUOUS MEMORY" WORD
051A  5B                                POP     BX
051B  BA 2000                           MOV     DX,2000H        ; SET POINTER TO JUST ABOVE 128K
051E  2B FF                             SUB     DI,DI           ; SET DI TO POINT TO BEGINNING
0520  B9 AA55                   Q26:    MOV     CX,0AA55H       ; LOAD DATA PATTERN
0523  8E C2                             MOV     ES,DX           ; SET SEGMENT TO POINT TO MEMORY
0525  26: 89 0D                         MOV     ES:[DI],CX      ; SPACE
0528  B0 0F                             MOV     AL,0FH          ; SET DATA PATTERN TO MEMORY
052A  26: 8B 05                         MOV     AX,ES:[DI]      ; SET AL TO ODD VALUE
052D  33 C1                             XOR     AX,CX           ; GET DATA PATTERN BACK FROM MEM
052F  75 0C                             JNZ     Q27             ; SEE IF DATA MADE IT BACK
                                ; NO? THEN END OF MEM HAS BEEN
                                ; REACHED
0531  81 C2 1000                        ADD     DX,1000H        ; POINT TO BEGINNING OF NEXT 64K
0535  83 C3 40                          ADD     BX,64           ; ADJUST TOTAL MEM. COUNTER
0538  80 FE A0                          CMP     DH,0A0H         ; PAST 640K YET?
053B  75 E6                             JNE     Q26             ; CHECK FOR ANOTHER BLOCK IF NOT
053D  89 1E 0015 R              Q27:    MOV     [TRUE_MEM],BX   ; LOAD "TOTAL MEMORY" WORD
                                ; SIZE HAS BEEN DETERMINED, NOW TEST OR CLEAR ALL OF MEMORY
0541  B8 0004                           MOV     AX,4            ; 4 KB KNOWN OK AT THIS POINT
0544  E8 05BC R                         CALL    Q35
0547  BA 0080                           MOV     DX,0080H        ; SET POINTER TO JUST ABOVE
                                                                ; LOWER 2K
054A  B9 7800                           MOV     CX,7800H        ; TEST 30K WORDS (60KB)
054D  8E C2                     Q28:    MOV     ES,DX
054F  51                                PUSH    CX
0550  53                                PUSH    BX
0551  50                                PUSH    AX
0552  E8 0B59 R                         CALL    PODSTG          ; TEST OR FILL MEM
0555  74 03                             JZ      Q29             
0557  E9 0603 R                         JMP     Q39             ; JUMP IF ERROR
055A  58                        Q29:    POP     AX
055B  5B                                POP     BX
055C  59                                POP     CX
055D  80 FD 78                          CMP     CH,78H          ; WAS THIS A 60 K PASS
0560  9C                                PUSHF
0561  05 003C                           ADD     AX,60           ; BUMP GOOD STORAGE BY 60 KB
0564  9D                                POPF
0565  74 03                             JE      Q30
0567  05 0002                           ADD     AX,2            ; ADD 2 FOR A 62K PASS
056A  E8 05BC R                 Q30:    CALL    Q35
056D  3B C3                             CMP     AX,BX           ; ARE WE DONE YET?
056F  75 03                             JNE     Q31
0571  E9 0640 R                         JMP     Q43             ; ALL DONE, IF SO
; --------------------------------------------------------------------------------------------------
; A-17
; --------------------------------------------------------------------------------------------------
0574  3D 0080                   Q31:    CMP     AX,128          ; DONE WITH 1ST 128K?
0577  74 1E                             JE      Q32             ; GO FINISH REST OF MEM.
0579  BA 0F80                           MOV     DX,0F80H        ; SET POINTER TO FINISH 1ST 64 KB
057C  B9 0400                           MOV     CX,0400H
057F  8E C2                             MOV     ES,DX
0581  50                                PUSH    AX
0582  53                                PUSH    BX
0583  52                                PUSH    DX
0584  E8 0B59 R                         CALL    PODSTG          ; GO TEST/FILL
0587  75 7A                             JNZ     Q39             ;
0589  5A                                POP     DX
058A  5B                                POP     BX
058B  58                                POP     AX
058C  05 0002                           ADD     AX,2            ; UPDATE GOOD COUNT
058F  BA 1000                           MOV     DX,1000H        ; SET POINTER TO 2ND 64K BLOCK
0592  B9 7C00                           MOV     CX,7C00H        ; 62K WORTH
0595  EB B6                             JMP     Q28             ; GO TEST IT
0597  BA 2000                   Q32:    MOV     DX,2000H        ; POINT TO BLOCK ABOVE 128K
059A  3B D8                     Q33:    CMP     BX,AX           ; COMPARE GOOD MEM TO TOTAL MEM
059C  75 03                             JNE     Q34
059E  E9 0640 R                         JMP     Q43             ; EXIT IF ALL DONE
05A1  B9 4000                   Q34:    MOV     CX,4000H        ; SET FOR 32KB BLOCK
05A4  8E C2                             MOV     ES,DX
05A6  50                                PUSH    AX
05A7  53                                PUSH    BX
05A8  52                                PUSH    DX
05A9  E8 0B59 R                         CALL    PODSTG          ; GO TEST/FILL
05AC  75 55                             JNZ     Q39             ;
05AE  5A                                POP     DX
05AF  5B                                POP     BX
05B0  58                                POP     AX
05B1  05 0020                           ADD     AX,32           ; BUMP GOOD MEMORY COUNT
05B4  E8 05BC R                         CALL    Q35             ; DISPLAY CURRENT GOOD MEM
05B7  80 C6 08                          ADD     DH,08H          ; SET POINTER TO NEXT 32K
05BA  EB DE                             JMP     Q33             ; AND MAKE ANOTHER PASS
                                ;---------------------------------------------
                                ;    SUBROUTINE FOR PRINTING TESTED
                                ;    MEMORY OK MSG ON THE CRT
                                ; CALL PARMS: AX = K OF GOOD MEMORY
                                ;             (IN HEX)
                                ;---------------------------------------------
05BC                            Q35     PROC    NEAR
05BC  E8 138B R                         CALL    DDS             ; ESTABLISH ADDRESSING
05BF  81 3E 0072 R 1234                 CMP     RESET_FLAG,1234H ; WARM START?
05C5  74 3B                             JE      Q35E            ; NO PRINT ON WARM START
05C7  53                                PUSH    BX
05C8  51                                PUSH    CX
05C9  52                                PUSH    DX
05CA  50                                PUSH    AX              ; SAVE WORK REGS
05CB  B4 02                             MOV     AH,2            ; SET CURSOR TOWARD THE END OF
05CD  BA 1421                           MOV     DX,1421H        ; ROW 20 (ROW 20, COL. 33)
05D0  B7 07                             MOV     BH,7            ; PAGE 7
05D2  CD 10                             INT     10H
05D4  58                                POP     AX              ;
05D5  50                                PUSH    AX
05D6  BB 000A                           MOV     BX,10           ; SET UP FOR DECIMAL CONVERT
05D9  B9 0003                           MOV     CX,3            ; OF 3 NIBBLES
05DC  33 D2                     Q36:    XOR     DX,DX           ;
05DE  F7 F3                             DIV     BX              ; DEVIDE BY 10
05E0  80 CA 30                          OR      DL,30H          ; MAKE INTO ASCII
05E3  52                                PUSH    DX              ; SAVE
05E4  E2 F6                             LOOP    Q36             ;
05E6  B9 0003                           MOV     CX,3            ;
05E9  58                        Q37:    POP     AX              ; RECOVER A NUMBER
05EA  E8 18BA R                         CALL    PRT_HEX
05ED  E2 FA                             LOOP    Q37
05EF  B9 0003                           MOV     CX,3
05F2  BE 0025 R                 Q38:    MOV     SI,OFFSET F3B   ; PRINT " KB"
05F5  2E: 8A 04                         MOV     AL,CS:[SI]
05F8  46                                INC     SI
05F9  E8 18BA R                         CALL    PRT_HEX
05FC  E2 F7                             LOOP    Q38
05FE  58                                POP     AX
05FF  5A                                POP     DX
0600  59                                POP     CX
0601  5B                                POP     BX
0602  C3                        Q35E:   RET
0603                            Q35     ENDP

                                ; ON ENTRY TO MEMORY ERROR ROUTINE, CX HAS ERROR BITS
                                ; AH HAS ODD/EVEN INFO, OTHER USEFUL INFO ON THE STACK
0603  5A                        Q39:    POP     DX                  ; POP SEGMENT POINTER TO DX
                                ;                         ; (HEADING DOWNHILL, DON'T CARE
                                ;                         ; ABOUT STACK)
0604  81 FA 2000                        CMP     DX,2000H            ; ABOVE 128K (THE SIMPLE CASE)
0608  7C 0E                             JL      Q40                 ; GO DO ODD/EVEN-LESS THAN 128K
060A  8A D9                             MOV     BL,CL               ; FORM ERROR BITS ("XX")
060C  0A DD                             OR      BL,DH
060E  B1 04                             MOV     CL,4                ;
0610  D2 EE                             SHR     DH,CL               ; ROTATE MOST SIGNIFICANT
                                                                    ; NIBBLE OF SEGMENT
0612  B7 10                             MOV     BH,10H              ; TO LOW NIBBLE OF DH
0614  0A FE                             OR      BH,DH               ; FORM "1Y" VALUE
0616  EB 20                             JMP     SHORT Q42
0618  B7 0A                     Q40:    MOV     BH,0AH              ; ERROR 0A....
061A  E4 62                             IN      AL,PORT_C           ; GET CONFIG BITS
061C  24 08                             AND     AL,00001000B        ; TEST FOR ATTRIB CARD PRESENT
061E  74 06                             JZ      Q41                 ; WORRY ABOUT ODD/EVEN IF IT IS
0620  8A D9                             MOV     BL,CL
0622  0A DD                             OR      BL,CH               ; COMBINE ERROR BITS IF IT ISN'T
0624  EB 12                             JMP     SHORT Q42           ;
; --------------------------------------------------------------------------------------------------
; A-18
; --------------------------------------------------------------------------------------------------
0626  80 FC 02                          CMP     AH,02               ; EVEN BYTE ERROR? ERR 0AXX
0629  8A D9                             MOV     BL,CL
062B  74 0B                             JE      Q42
062D  FE C7                             INC     BH                  ; MAKE INTO 0BXX ERR
062F  0A DD                             OR      BL,DH               ; MOVE AND COMBINE ERROR BITS
0631  80 FC 01                          CMP     AH,1                ; ODD BYTE ERROR
0634  74 02                             JE      Q42
0636  FE C7                             INC     BH                  ; MUST HAVE BEEN BOTH
                                ; - MAKE INTO 0CXX

0638  BE 0035 R                 Q42:    MOV     SI,OFFSET MEM_ERR
063B  E8 09BC R                         CALL    E_MSG               ; LET ERROR ROUTINE FIGURE OUT
                                ; WHAT TO DO

063E  FA                                CLI
063F  F4                                HLT
0640                            Q43:
                                ;-------------------------------------------------------
                                ;               KEYBOARD TEST
                                ; DESCRIPTION
                                ;       NMI HAS BEEN ENABLED FOR QUITE A FEW
                                ;       SECONDS NOW. CHECK THAT NO SCAN CODES
                                ;       HAVE SHOWN UP IN THE BUFFER. (STUCK
                                ;       KEY) IF THEY HAVE, DISPLAY THEM AND
                                ;       POST ERROR.
                                ;       MFG ERR CODE
                                ;       2000 STRAY NMI INTERRUPTS OR KEYBOARD
                                ;               RECEIVE ERRORS
                                ;       21XX   CARD FAILURE
                                ;               XX=01, KB DATA STUCK HIGH
                                ;               XX=02, KB DATA STUCK LOW
                                ;               XX=03, NO NMI INTERRUPT
                                ;       22XX STUCK KEY (XX=SCAN CODE)
                                ;-------------------------------------------------------
                                        ASSUME  DS:DATA
                                ;----- CHECK FOR STUCK KEYS
0640  E8 E6D8 R                         CALL    MFG_UP              ; MFG CODE=F2
0643  E8 138B R                         CALL    DDS                 ; ESTABLISH ADDRESSING
0646  BB 001E R                         MOV     BX,OFFSET KB_BUFFER
0649  8A 07                             MOV     AL,[BX]             ; CHECK FOR STUCK KEYS
064B  0A C0                             OR      AL,AL               ; SCAN CODE = 0?
064D  74 06                             JE      F6_Y                ; YES - CONTINUE TESTING
064F  B7 22                             MOV     BH,22H              ; 22XX ERROR CODE
0651  8A D8                             MOV     BL,AL               ;
0653  EB 0A                             JMP     SHORT F6
0655  80 3E 0012 R 00           F6_Y:   CMP     KBD_ERR,00H         ; DID NMI'S HAPPEN WITH NO SCAN
                                                                    ; CODE PASSED?
065A  74 1C                             JE      F7                  ; (STRAYS) - CONTINUE IF NONE
065C  BB 2000                           MOV     BX,2000H            ; SET ERROR CODE 2000
065F  BE 0036 R                 F6:     MOV     SI,OFFSET KEY_ERR   ; GET MSG ADDR
0662  81 3E 0072 R 4321                 CMP     RESET_FLAG,4321H    ; WARM START TO DIAGS
0668  74 0B                             JE      F6_Z                ; DO NOT PUT UP MESSAGE
066A  81 3E 0072 R 1234                 CMP     RESET_FLAG,1234H    ; WARM SYSTEM START
0670  74 03                             JE      F6_Z                ; DO NOT PUT UP MESSAGE
0672  E8 09BC R                         CALL    E_MSG               ; PRINT MSG ON SCREEN
0675  E9 06FF R                 F6_Z:   JMP     F6_X
                                ; CHECK LINK CARD, IF PRESENT
0678  BA 0201                   F7:     MOV     DX,0201H            ; CHECK FOR BURN-IN MODE
067B  EC                                IN      AL,DX               ; GET CONFIG. PORT DATA
067C  24 F0                             AND     AL,0F0H             ; BYPASS CHECK IN BURN-IN MODE
067E  74 7F                             JZ      F6_X                ; KEYBOARD CABLE ATTACHED?
0680  E4 62                             IN      AL,PORT_C           ; BYPASS TEST IF IT IS
0682  24 80                             AND     AL,10000000B        ;
0684  74 79                             JZ      F6_X                ;
0686  E4 61                             IN      AL,PORT_B           ;
0688  24 FC                             AND     AL,11111100B        ; DROP SPEAKER DATA
068A  E6 61                             OUT     PORT_B,AL           ;
068C  B0 B6                             MOV     AL,0B6H             ; MODE SET TIMER 2
068E  E6 43                             OUT     TIM_CTL,AL          ;
0690  B0 40                             MOV     AL,040H             ; DISABLE NMI
0692  E6 A0                             OUT     0A0H,AL             ;
0694  B0 20                             MOV     AL,32               ; LSB TO TIMER 2
                                                                    ; (APPROX. 40Khz VALUE)
0696  BA 0042                           MOV     DX,TIMER+2
0699  EE                                OUT     DX,AL
069A  2B C0                             SUB     AX,AX
069C  8B C8                             MOV     CX,AX
069E  EE                                OUT     DX,AL               ; MSB TO TIMER 2 (START TIMER)
069F  E4 61                             IN      AL,PORT_B
06A1  0C 01                             OR      AL,1
06A3  E6 61                             OUT     PORT_B,AL           ; ENABLE TIMER 2
06A5  E4 62                     F7_0:   IN      AL,PORT_C           ; SEE IF KEYBOARD DATA ACTIVE
06A7  24 40                             AND     AL,01000000B        ;
06A9  75 06                             JNZ     F7_1                ; EXIT LOOP IF DATA SHOWED UP
06AB  E2 F8                             LOOP    F7_0
06AD  B3 02                             MOV     BL,02H              ; SET NO KEYBOARD DATA ERROR
06AF  EB 49                             JMP     SHORT F6_1
06B1  06                        F7_1:   PUSH    ES                  ; SAVE ES
06B2  2B C0                             SUB     AX,AX               ; SET UP SEGMENT REG
06B4  8E C0                             MOV     ES,AX               ; *
06B6  26: C7 06 0008 R F815 R           MOV     ES:[NMI_PTR],OFFSET D11 ; SET UP NEW NMI VECTOR
06BD  A2 0084 R                         MOV     INTR_FLAG,AL        ; RESET INTR FLAG
06C0  E4 61                             IN      AL,PORT_B           ; DISABLE INTERNAL BEEPER TO
06C2  0C 30                             OR      AL,00110000B        ; PREVENT ERROR BEEP
06C4  E6 61                             OUT     PORT_B,AL
06C6  B0 C0                             MOV     AL,0C0H
06C8  E6 A0                             OUT     0A0H,AL             ; ENABLE NMI
06CA  B9 0100                           MOV     CX,0100H            ;
; --------------------------------------------------------------------------------------------------
; A-19
; --------------------------------------------------------------------------------------------------
06CD  E2 FE                     F6_0:   LOOP    F6_0                ; WAIT A BIT
06CF  E4 61                             IN      AL,PORT_B           ; RE-ENABLE BEEPER
06D1  24 CF                             AND     AL,11001111B
06D3  E6 61                             OUT     PORT_B,AL
06D5  A0 0084 R                         MOV     AL,INTR_FLAG        ; GET INTR FLAG
06D8  0A C0                             OR      AL,AL               ; WILL BE NON-ZERO IF NMI HAPPENED
06DA  B3 03                             MOV     BL,03H              ; SET POSSIBLE ERROR CODE
06DC  26: C7 06 0008 R 0F78 R           MOV     ES:[NMI_PTR],OFFSET KBDNMI ; RESET NMI VECTOR
06E3  07                                POP     ES                  ; RESTORE ES
06E4  74 14                             JZ      F6_1                ; JUMP IF NO NMI
06E6  B0 00                             MOV     AL,00H              ; DISABLE FEEDBACK CKT
06E8  E6 A0                             OUT     0A0H,AL             ;
06EA  E4 61                             IN      AL,PORT_B           ;
06EC  24 FE                             AND     AL,11111110B        ; DROP GATE TO TIMER 2
06EE  E6 61                             OUT     PORT_B,AL           ;
06F0  E4 62                     F6_2:   IN      AL,PORT_C           ; SEE IF KEYBOARD DATA ACTIVE
06F2  24 40                             AND     AL,01000000B
06F4  74 09                             JZ      F6_X                ; EXIT LOOP IF DATA WENT LOW
06F6  E2 F8                             LOOP    F6_2                ;
06F8  B3 01                     F6_1:   MOV     BL,01H              ; SET KEYBOARD DATA STUCK HIGH ERR
06FA  B7 21                             MOV     BH,21H              ; POST ERROR "21XX"
06FC  E9 065F R                         JMP     F6                  ;
06FF  B0 00                     F6_X:   MOV     AL,00H              ; DISABLE FEEDBACK CKT
0701  E6 A0                             OUT     0A0H,AL             ;

                                ;--------------------------------------------
                                ;       CASSETTE INTERFACE TEST
                                ; DESCRIPTION
                                ;       TURN CASSETTE MOTOR OFF. WRITE A BIT OUT TO THE
                                ;       CASSETTE DATA BUS. VERIFY THAT CASSETTE DATA
                                ;       READ IS WITHIN A VALID RANGE.
                                ;       MFG. ERROR CODE=2300H (DATA PATH ERROR)
                                ;                       23FF (RELAY FAILED TO PICK)
                                ;--------------------------------------------
= 0A9A                          MAX_PERIOD     EQU     0A9AH        ; NOM.+10%
= 08AD                          MIN_PERIOD     EQU     08ADH        ; NOM -10%
                                ;------ TURN THE CASSETTE MOTOR OFF
0703  E8 E6D8 R                         CALL    MFG_UP              ; MFG CODE=F1
0706  E4 61                             IN      AL,PORT_B
0708  0C 09                             OR      AL,00001001B        ; SET TIMER 2 SPK OUT, AND CASSETTE
070A  E6 61                             OUT     PORT_B,AL           ; OUT BITS ON, CASSETTE MOT OFF

                                ;------ WRITE A BIT
070C  E4 21                             IN      AL,INTA01           ; DISABLE TIMER INTERRUPTS
070E  0C 01                             OR      AL,01H
0710  E6 21                             OUT     INTA01,AL
0712  B0 B6                             MOV     AL,0B6H             ; SEL TIM 2, LSB, MSB, MD 3
0714  E6 43                             OUT     TIMER+3,AL          ; WRITE 8253 CMD/MODE REG
0716  B8 04D2                           MOV     AX,1234             ; SET TIMER 2 CNT FOR 1000 USEC
0719  E6 42                             OUT     TIMER+2,AL          ; WRITE TIMER 2 COUNTER REG
071B  8A C4                             MOV     AL,AH               ; WRITE MSB
071D  E6 42                             OUT     TIMER+2,AL
071F  2B C9                             SUB     CX,CX               ; CLEAR COUNTER FOR LONG DELAY
0721  E2 FE                             LOOP    $                   ; WAIT FOR COUNTER TO INIT

                                ;------ READ CASSETTE INPUT
0723  E4 62                             IN      AL,PORT_C           ; READ VALUE OF CASS IN BIT
0725  24 10                             AND     AL,10H              ; ISOLATE FROM OTHER BITS
0727  A2 006B R                         MOV     LAST_VAL,AL
072A  E8 F96F R                         CALL    READ_HALF_BIT       ; TO SET UP CONDITIONS FOR CHECK
072D  E8 F96F R                         CALL    READ_HALF_BIT
0730  E3 3E                             JCXZ    F8                  ; CAS_ERR
0732  53                                PUSH    BX                  ; SAVE HALF BIT TIME VALUE
0733  E8 F96F R                         CALL    READ_HALF_BIT
0736  58                                POP     AX                  ; GET TOTAL TIME
0737  E3 37                             JCXZ    F8                  ; CAS_ERR
0739  03 C3                             ADD     AX,BX
073B  3D 0A9A                           CMP     AX,MAX_PERIOD
073E  73 30                             JNC     F8                  ; CAS_ERR
0740  3D 08AD                           CMP     AX,MIN_PERIOD
0743  72 2B                             JC      F8
0745  BA 0201                           MOV     DX,201H
0748  EC                                IN      AL,DX
0749  24 F0                             AND     AL,0F0H             ; DETERMINE MODE
074B  3C 10                             CMP     AL,00010000B        ; MFG?
074D  74 04                             JE      F9
074F  3C 40                             CMP     AL,01000000B        ; SERVICE?
0751  75 26                             JNE     T13_END             ; GO TO NEXT TEST IF NOT
                                ; CHECK THAT CASSETTE RELAY IS PICKING (CAN'T DO TEST IN NORMAL
                                ; MODE BECAUSE OF POSSIBILITY OF WRITING ON CASSETTE IF "RECORD"
                                ; BUTTON IS DEPRESSED.)
0753  E4 61                     F9:     IN      AL,PORT_B           ; SAVE PORT B CONTENTS
0755  8A D0                             MOV     DL,AL
0757  24 E5                             AND     AL,11100101B        ; SET CASSETTE MOTOR ON
0759  E6 61                             OUT     PORT_B,AL           ;
075B  33 C9                             XOR     CX,CX               ;
075D  E2 FE                             LOOP    F91                 ; WAIT FOR RELAY TO SETTLE
075F  E8 F96F R                 F91:    CALL    READ_HALF_BIT
0762  E8 F96F R                         CALL    READ_HALF_BIT
0765  8A C2                             MOV     AL,DL               ; DROP RELAY
0767  E6 61                             OUT     PORT_B,AL
0769  E3 0E                             JCXZ    T13_END             ; READ_HALF_BIT SHOULD TIME OUT IN
                                                                    ; THIS SITUATION
076B  BB 23FF                           MOV     BX,23FFH            ; ERROR 23FF
076E  EB 03                             JMP     SHORT F81
0770                            F8:     ; CAS_ERR
0770  BB 2300                           MOV     BX,2300H            ; ERR. CODE 2300H
0773  BE 0037 R                 F81:    MOV     SI,OFFSET CASS_ERR  ; CASSETTE WRAP FAILED
0776  E8 09BC R                         CALL    E_MSG               ; GO PRINT ERROR MSG
0779                            T13_END:
0779  E4 21                             IN      AL,INTA01           ; ENABLE TIMER INTS
077B  24 FE                             AND     AL,0FEH
077D  E6 21                             OUT     INTA01,AL
077F  E4 A0                             IN      AL,NMI_PORT         ; CLEAR NMI FLIP/FLOP
0781  B0 80                             MOV     AL,80H              ; ENABLE NMI INTERRUPTS
0783  E6 A0                             OUT     NMI_PORT,AL
; --------------------------------------------------------------------------------------------------
; A-20
; --------------------------------------------------------------------------------------------------
                                ;
                                ;       SERIAL PRINTER AND MODEM POWER ON DIAGNOSTIC
                                ; DESCRIPTION:
                                ;       VERIFIES THAT THE SERIAL PRINTER UART FUNCTIONS PROPERLY.
                                ;       CHECKS IF THE MODEM CARD IS ATTACHED.  IF IT'S NOT, EXITS.
                                ;       VERIFIES THAT THE MODEM UART FUNCTIONS PROPERLY.
                                ;       ERROR CODES RETURNED BY 'UART' RANGE FROM 1 TO 1FH AND ARE
                                ;       REPORTED VIA REGISTER BL.  SEE LISTING OF 'UART' (POD27)
                                ;       FOR POSSIBLE ERRORS.
                                ;       MFG. ERR. CODES  23XX FOR SERIAL PRINTER
                                ;                       24XX FOR MODEM
                                ;

                                        ASSUME  CS:CODE,DS:DATA

                                ;-------------------------------------------------------
                                ;       TEST SERIAL PRINTER INS8250 UART
                                ;-------------------------------------------------------

0785  E8 E6D8 R                         CALL    MFG_UP              ; MFG ROUTINE INDICATOR=F0
0788  BA 02F8                           MOV     DX,02F8H            ; ADDRESS OF SERIAL PRINTER CARD
078B  E8 E831 R                         CALL    UART                ; ASYNCH. COMM. ADAPTER POD
078E  73 06                             JNC     TM                  ; PASSED
0790  BE 0038 R                         MOV     SI,OFFSET COM1_ERR  ; CODE FOR DISPLAY
0793  E8 09BC R                         CALL    E_MSG               ; REPORT ERROR

                                ;-------------------------------------------------------
                                ;       TEST MODEM INS8250 UART
                                ;-------------------------------------------------------
0796  E8 E6D8 R                 TM:     CALL    MFG_UP              ; MFG ROUTINE INDICATOR = EF
0799  E4 62                             IN      AL,PORT_C           ; TEST FOR MODEM CARD PRESENT
079B  24 02                             AND     AL,00000010B        ; ONLY CONCERNED WITH BIT 1
079D  75 0E                             JNE     TM1                 ; IT'S NOT THERE - DONE WITH TEST
079F  BA 03F8                           MOV     DX,03F8H            ; ADDRESS OF MODEM CARD
07A2  E8 E831 R                         CALL    UART                ; ASYNCH. COMM. ADAPTER POD
07A5  73 06                             JNC     TM1                 ; PASSED
07A7  BE 0039 R                         MOV     SI,OFFSET COM2_ERR  ; MODEM ERROR
07AA  E8 09BC R                         CALL    E_MSG               ; REPORT ERROR
07AD                            TM1:
                                ;-------------------------------------------------------
                                ;       SETUP HARDWARE INT. VECTOR TABLE
                                ;-------------------------------------------------------
07AD                                    ASSUME  CS:CODE,DS:ABSO
07AD  2B C0                             SUB     AX,AX
07AF  8E C0                             MOV     ES,AX
07B1  B9 0008                           MOV     CX,08               ; GET VECTOR CNT
07B4  0E                                PUSH    CS                  ; SETUP DS SEG REG
07B5  1F                                POP     DS
07B6  BE FEF3 R                         MOV     SI,OFFSET VECTOR_TABLE
07B9  BF 0020 R                         MOV     DI,OFFSET INT_PTR
07BC  A5                        F7A:    MOVSW
07BD  47                                INC     DI                  ; SKIP OVER SEGMENT
07BE  47                                INC     DI
07BF  E2 FB                             LOOP    F7A

                                ;----- SET UP OTHER INTERRUPTS AS NECESSARY
                                        ASSUME  DS:ABSO
07C1  8E D9                             MOV     DS,CX
07C3  C7 06 0014 R FF54 R               MOV     INT5_PTR,OFFSET PRINT_SCREEN ; PRINT SCREEN
07C9  C7 06 0120 R 10C6 R               MOV     KEY62_PTR,OFFSET KEY62_INT ; 62 KEY CONVERSION
07CF  C7 06 0110 R FA6E R               MOV     CSET_PTR,OFFSET CRT_CHAR_GEN ; DOT TABLE
07D5  C7 06 0060 R FFCB R               MOV     BASIC_PTR,OFFSET BAS_ENT ; CASSETTE BASIC ENTRY
07DB  0E                                PUSH    CS
07DC  58                                POP     AX
07DD  A3 0062 R                         MOV     WORD PTR BASIC_PTR+2,AX ; CODE SEGMENT FOR CASSETTE

                                ;-------------------------------------------------------
                                ; CHECK FOR OPTIONAL ROM FROM C0000 TO F0000 IN 2K BLOCKS
                                ; (A VALID MODULE HAS '55AA' IN THE FIRST 2 LOCATIONS,
                                ;  LENGTH INDICATOR (LENGTH/512) IN THE 3D LOCATION AND
                                ;  TEST/INIT. CODE STARTING IN THE 4TH LOCATION.)
                                ; MFG ERR CODE 25XX (XX=MSB OF SEGMENT THAT HAS CRC CHECK)
                                ;-------------------------------------------------------
07E0  B0 01                             MOV     AL,01H
07E2  E6 13                             OUT     13H,AL
07E4  E8 E6D8 R                         CALL    MFG_UP              ; MFG ROUTINE = EE
07E7  BA C000                           MOV     DX,0C000H           ; SET BEGINNING ADDRESS
07EA                            ROM_SCAN_1:
07EA  8E DA                             MOV     DS,DX
07EC  2B DB                             SUB     BX,BX               ; SET BX=0000
07EE  8B 07                             MOV     AX,[BX]             ; GET 1ST WORD FROM MODULE
07F0  53                                PUSH    BX
07F1  5B                                POP     BX                  ; BUS SETTLING
07F2  3D AA55                           CMP     AX,0AA55H           ; = TO ID WORD?
07F5  75 05                             JNZ     NEXT_ROM            ; PROCEED TO NEXT ROM IF NOT
07F7  E8 EB51 R                         CALL    ROM_CHECK           ; GO CHECK OUT MODULE
07FA  EB 04                             JMP     SHORT ARE_WE_DONE   ; CHECK FOR END OF ROM SPACE
07FC                            NEXT_ROM:
07FC  81 C2 0080                        ADD     DX,0080H            ; POINT TO NEXT 2K ADDRESS
0800                            ARE_WE_DONE:
0800  81 FA F000                        CMP     DX,0F000H           ; AT F0000 YET?
0804  7C E4                             JL      ROM_SCAN_1          ; GO CHECK ANOTHER ADD. IF NOT
; --------------------------------------------------------------------------------------------------
; A-021
; --------------------------------------------------------------------------------------------------
                                ;
                                ;       DISKETTE ATTACHMENT TEST
                                ; DESCRIPTION
                                ;       CHECK IF IPL DISKETTE DRIVE IS ATTACHED TO SYSTEM.  IF
                                ;       ATTACHED, VERIFY STATUS OF NEC FDC AFTER A RESET. ISSUE
                                ;       A RECAL AND SEEK CMD TO FDC AND CHECK STATUS. COMPLETE
                                ;       SYSTEM INITIALIZATION THEN PASS CONTROL TO THE BOOT
                                ;       LOADER PROGRAM.
                                ;       MFG ERR CODES: 2601 RESET TO DISKETTE CONTROLLER CD. FAILED
                                ;                      2602 RECALIBRATE TO DISKETTE DRIVE FAILED
                                ;                      2603 WATCHDOG TIMER FAILED
                                ;

                                        ASSUME  CS:CODE,DS:DATA
0806  E8 E6D8 R                         CALL    MFG_UP              ; MFG ROUTINE = ED
0809  E8 138B R                         CALL    DDS                 ; POINT TO DATA AREA
080C  B0 FF                             MOV     AL,0FFH
080E  A2 0074 R                         MOV     TRACK0,AL           ; INIT DISKETTE SCRATCHPADS
0811  A2 0075 R                         MOV     TRACK1,AL
0814  A2 0076 R                         MOV     TRACK2,AL
0817  E4 62                             IN      AL,PORT_C           ; DISKETTE PRESENT?
0819  24 04                             AND     AL,00000100B
081B  74 03                             JZ      F10_0
081D  E9 08A3 R                         JMP     F15
0820  80 0E 0010 R 01           F10_0:  OR      BYTE PTR EQUIP_FLAG,01H ; SET IPL DISKETTE
                                                                    ; INDICATOR IN EQUIP. FLAG
0825  83 3E 0072 R 00                   CMP     RESET_FLAG,0        ; RUNNING FROM POWER-ON STATE?
082A  75 0E                             JNE     F10                 ; BYPASS WATCHDOG TEST
082C  B0 0A                             MOV     AL,00001010B        ; READ INT. REQUEST REGISTER CMD
082E  E6 20                             OUT     INTA00,AL
0830  E4 20                             IN      AL,INTA00
0832  24 40                             AND     AL,01000000B        ; HAS WATCHDOG GONE OFF?
0834  75 04                             JNZ     F10                 ; PROCEED IF IT HAS
0836  B3 03                             MOV     BL,03H              ; SET ERROR CODE
0838  EB 33                             JMP     SHORT F13
083A  B0 80                     F10:    MOV     AL,FDC_RESET
083C  E6 F2                             OUT     0F2H,AL             ; DISABLE WATCHDOG TIMER
083E  B4 00                             MOV     AH,0                ; RESET NEC FDC
0840  8A D4                             MOV     DL,AH               ; SET FOR DRIVE 0
0842  CD 13                             INT     13H                 ; VERIFY STATUS AFTER RESET
0844  F6 C4 FF                          TEST    AH,0FFH             ; STATUS OK?
0847  B3 01                             MOV     BL,01H              ; SET UP POSSIBLE ERROR CODE
0849  75 22                             JNZ     F13                 ; NO - FDC FAILED

084B  B0 81                             MOV     AL,DRIVE_ENABLE+FDC_RESET ; TURN MOTOR ON,DRIVE 0
084D  E6 F2                             OUT     0F2H,AL             ; WRITE FDC CONTROL REG
084F  2B C9                             SUB     CX,CX
0851  E2 FE                     F11:    LOOP    F11                 ; WAIT FOR 1 SECOND
0853  E2 FE                     F12:    LOOP    F12
0855  33 D2                             XOR     DX,DX               ; SELECT DRIVE 0
0857  B5 01                             MOV     CH,1                ; SELECT TRACK 1
0859  88 16 003E R                      MOV     SEEK_STATUS,DL      ; RECALIBRATE DISKETTE
085D  E8 E9FB R                         CALL    SEEK
0860  B3 02                             MOV     BL,02H              ; ERROR CODE
0862  72 09                             JC      F13                 ; GO TO ERR SUBROUTINE IF ERR
0864  B5 22                             MOV     CH,34               ; SELECT TRACK 34
0866  E8 E9FB R                         CALL    SEEK                ; SEEK TO TRACK 34
0869  73 0A                             JNC     F14                 ; OK, TURN MOTOR OFF
086B  B3 02                             MOV     BL,02H              ; ERROR CODE
086D  B7 26                     F13:    MOV     BH,26H              ; DSK_ERR:(26XX)
086F  BE 003C R                         MOV     SI,OFFSET DISK_ERR  ; GET ADDR. OF MSG
0872  E8 09BC R                         CALL    E_MSG               ; GO PRINT ERROR MSG
0875  B0 82                     F14:    MOV     AL,FDC_RESET+02H
0877  E6 F2                             OUT     0F2H,AL
0879  E4 E2                             IN      AL,0E2H
087B  24 06                             AND     AL,00000110B
087D  3C 02                             CMP     AL,00000010B
087F  75 1E                             JNE     F14_1
0881  B0 84                             MOV     AL,FDC_RESET+04H
0883  E6 F2                             OUT     0F2H,AL
0885  E4 E2                             IN      AL,0E2H
0887  24 06                             AND     AL,00000110B
0889  3C 04                             CMP     AL,00000100B
088B  75 12                             JNE     F14_1
088D  E4 E2                             IN      AL,0E2H
088F  24 30                             AND     AL,00110000B
0891  74 0C                             JZ      F14_1
0893  3C 10                             CMP     AL,00010000B
0895  B4 40                             MOV     AH,01000000B
0897  74 02                             JE      F14_2
0899  B4 80                             MOV     AH,10000000B
089B  08 26 0010 R              F14_2:  OR      BYTE PTR EQUIP_FLAG,AH
                                ;----- TURN DRIVE 0 MOTOR OFF
089F  B0 80                     F14_1:  MOV     AL,FDC_RESET        ; TURN DRIVE 0 MOTOR OFF
08A1  E6 F2                             OUT     0F2H,AL
08A3  C6 06 0084 R 00           F15:    MOV     INTR_FLAG,00H       ; SET STRAY INTERRUPT FLAG = 00
08A8  BF 0078 R                         MOV     DI,OFFSET PRINT_TIM_OUT ;SET DEFAULT PRT TIMEOUT
08AB  1E                                PUSH    DS
08AC  07                                POP     ES
08AD  B8 1414                           MOV     AX,1414H            ; DEFAULT=20
08B0  AB                                STOSW
08B1  AB                                STOSW
08B2  B8 0101                           MOV     AX,0101H            ; RS232 DEFAULT=01
08B5  AB                                STOSW
08B6  AB                                STOSW
08B7  E4 21                             IN      AL,INTA01
08B9  24 FE                             AND     AL,0FEH             ; ENABLE TIMER INT. (LVL 0)
08BB  E6 21                             OUT     INTA01,AL
                                        ASSUME  DS:XXDATA
08BD  1E                                PUSH    DS
08BE  B8 ---- R                         MOV     AX,XXDATA
08C1  8E D8                             MOV     DS,AX
; --------------------------------------------------------------------------------------------------
; A-022
; --------------------------------------------------------------------------------------------------
08C3  80 3E 0018 R 00                   CMP     POST_ERR,00H        ; CHECK FOR "POST_ERR" NON-ZERO
                                        ASSUME  DS:DATA
08C8  1F                                POP     DS
08C9  74 10                             JE      F15A_0              ; CONTINUE IF NO ERROR
08CB  B2 02                             MOV     DL,2                ; 2 SHORT BEEPS (ERROR).
08CD  E8 1A0C R                         CALL    ERR_BEEP
08D0                            ERR_WAIT:
08D0  B4 00                             MOV     AH,00
08D2  CD 16                             INT     16H                 ; WAIT FOR "ENTER" KEY
08D4  80 FC 1C                          CMP     AH,1CH
08D7  75 F7                             JNE     ERR_WAIT
08D9  EB 05                             JMP     SHORT F15C
08DB                            F15A_0:
08DB  B2 01                             MOV     DL,1                ; 1 SHORT BEEP (NO ERRORS)
08DD  E8 1A0C R                         CALL    ERR_BEEP
                                ;------ SETUP PRINTER AND RS232 BASE ADDRESSES IF DEVICE ATTACHED
08E0  BD 003D R                 F15C:   MOV     BP,OFFSET F4        ; PRT_SRC_TBL
08E3  33 F6                             XOR     SI,SI
08E5  2E: 8B 56 00              F16:    MOV     DX,CS:[BP]          ; PRT_BASE:
08E9  B0 0AAH                           MOV     AL,0AAH             ; GET PRINTER BASE ADDR
08EB  EE                                OUT     DX,AL               ; WRITE DATA TO PORT A
08EC  1E                                PUSH    DS                  ; BUS SETTLING
08ED  EC                                IN      AL,DX               ; READ PORT A
08EE  1F                                POP     DS
08EF  3C 0AA                            CMP     AL,0AAH             ; DATA PATTERN SAME
08F1  75 06                             JNE     F17                 ; NO - CHECK NEXT PRT CD
08F3  89 94 0008 R                      MOV     PRINTER_BASE[SI],DX ; YES - STORE PRT BASE ADDR
08F7  46                                INC     SI                  ; INCREMENT TO NEXT WORD
08F8  46                                INC     SI
08F9  45                        F17:    INC     BP                  ; POINT TO NEXT BASE ADDR
08FA  45                                INC     BP
08FB  83 FD 41                          CMP     BP,OFFSET F4E       ; ALL POSSIBLE ADDRS CHECKED?
08FE  75 E5                             JNE     F16                 ; PRT_BASE
0900  33 DB                             XOR     BX,BX               ; SET ADDRESS BASE
0902  BA 03FA                           MOV     DX,03FAH            ; POINT TO INT ID REGISTER
0905  EC                                IN      AL,DX               ; READ PORT
0906  A8 F8                             TEST    AL,0F8H             ; SEEM TO BE AN 8250
0908  75 08                             JNZ     F18
090A  C7 87 0000 R 03F8                 MOV     RS232_BASE[BX],3F8H ; SETUP RS232 CD #1 ADDR
0910  43                                INC     BX
0911  43                                INC     BX
0912  C7 87 0000 R 02F8         F18:    MOV     RS232_BASE[BX],2F8H ; SETUP RS232 #2
0918  43                                INC     BX                  ; (ALWAYS PRESENT)
0919  43                                INC     BX
                                ;------ SET UP EQUIP FLAG TO INDICATE NUMBER OF PRINTERS AND RS232
                                ;       CARDS
091A  8B C6                             MOV     AX,SI               ; SI HAS 2* NUMBER OF PRINTERS
091C  B1 03                             MOV     CL,3                ; SHIFT COUNT
091E  D2 C8                             ROR     AL,CL               ; ROTATE RIGHT 3 POSITIONS
0920  0A C3                             OR      AL,BL               ; OR IN THE RS232 COUNT
0922  08 06 0011 R                      OR      BYTE PTR EQUIP_FLAG+1,AL ; STORE AS SECOND BYTE
                                ;------ SET EQUIP. FLAG TO INDICATE PRESENCE OF SERIAL PRINTER
                                ;       ATTACHED TO ON BOARD RS232 PORT. ---ASSUMPTION---"RTS" IS TIED TO
                                ;       "CARRIER DETECT" IN THE CABLE PLUG FOR THIS SPECIFIC PRINTER.
0926  8B C8                             MOV     CX,AX               ; SAVE PRINTER COUNT IN CX
0928  BB 02FE                           MOV     BX,2FEH             ; SET POINTER TO MODEM STATUS REG
092B  BA 02FC                           MOV     DX,2FCH             ; POINT TO MODEM CONTROL REG
092E  2A C0                             SUB     AL,AL               ;
0930  EE                                OUT     DX,AL               ; CLEAR IT
0931  EB 00                             JMP     $+2                 ; DELAY
0933  87 D3                             XCHG    DX,BX               ; POINT TO MODEM STATUS REG
0935  EC                                IN      AL,DX               ; CLEAR IT
0936  EB 00                             JMP     $+2                 ; DELAY
0938  B0 02                             MOV     AL,02H              ; BRING UP RTS
093A  87 D3                             XCHG    DX,BX               ; POINT TO MODEM CONTROL REG
093C  EE                                OUT     DX,AL               ;
093D  EB 00                             JMP     $+2                 ; DELAY
093F  87 D3                             XCHG    DX,BX               ; POINT TO MODEM STATUS REG
0941  EC                                IN      AL,DX               ; GET CONTENTS
0942  A8 08                             TEST    AL,00001000B        ; HAS CARRIER DETECT CHANGED?
0944  74 23                             JZ      F19_A               ; NO, THEN NO PRINTER
0946  A8 01                             TEST    AL,00000001B        ; DID CTS CHANGE? (AS WITH WRAP
                                                                    ; CONNECTOR INSTALLED}
0948  75 1F                             JNZ     F19_A               ; WRAP CONNECTOR ON IF IT DID
094A  2A C0                             SUB     AL,AL               ; SET RTS OFF
094C  87 D3                             XCHG    DX,BX               ; POINT TO MODEM CONTROL REG
094E  EE                                OUT     DX,AL               ; DROP RTS
094F  EB 00                             JMP     $+2                 ; DELAY
0951  87 D3                             XCHG    DX,BX               ; MODEM STATUS REG
0953  EC                                IN      AL,DX               ; GET STATUS
0954  24 08                             AND     AL,00001000B        ; HAS CARRIER DETECT CHANGED?
0956  74 11                             JZ      F19_A               ; NO, THEN NO PRINTER
0958  80 C9 20                          OR      CL,00100000B        ; CARRIER DETECT IS FOLLOWING RTS-INDICATE SERIAL PRINTER ATTACHED
095B  F6 C1 C0                          TEST    CL,11000000B        ; CHECK FOR NO PARALLEL PRINTERS
095E  75 09                             JNZ     F19_A               ; DO NOTHING IF PARALLEL PRINTER
                                                                    ; ATTACHED
0960  80 C9 40                          OR      CL,01000000B        ; INDICATE 1 PRINTER ATTACHED
0963  C7 06 0008 R 02F8                 MOV     PRINTER_BASE,2F8H   ; STORE ON-BOARD RS232 BASE IN
                                                                    ; PRINTER BASE
0969  08 0E 0011 R              F19_A:  OR      BYTE PTR EQUIP_FLAG+1,CL ; STORE AS SECOND BYTE
096D  33 D2                             XOR     DX,DX               ; POINT TO FIRST SERIAL PORT
096F  F6 C1 40                          TEST    CL,040H             ; SERIAL PRINTER ATTACHED?
0972  74 18                             JZ      F19_C               ; NO, SKIP INIT
0974  81 3E 0000 R 02F8                 CMP     RS232_BASE,02F8H    ; PRINTER IN FIRST SERIAL PORT
097A  74 01                             JE      F19_B               ; YES, JUMP
097C  42                                INC     DX                  ; NO POINT TO SECOND SERIAL PORT
097D                            F19_B:
097D  B8 0087                           MOV     AX,87H              ; INIT SERIAL PRINTER
0980  CD 14                             INT     14H
0982  F6 C4 1E                          TEST    AH,1EH              ; ERROR?
0985  75 05                             JNZ     F19_C               ; YES, JUMP
0987  B8 0118                           MOV     AX,0118H            ; SEND CANCEL COMMAND TO
098A  CD 14                             INT     14H                 ; ..SERIAL PRINTER
; --------------------------------------------------------------------------------------------------
; A-023
; --------------------------------------------------------------------------------------------------
098C  BA 0201                   F19_C:  MOV     DX,0201H            ; GET MFG./ SERVICE  MODE INFO
098F  EC                                IN      AL,DX               ; IS HIGH ORDER NIBBLE = 0?
0990  24 F0                             AND     AL,0F0H             ; (BURN-IN MODE)
0992  75 03                             JNZ     F19_1               ; ELSE GO TO BEGINNING OF POST
0994  E9 0043 R                 F19_0:  JMP     START               ; SERVICE MODE LOOP?
0997  3C 20                     F19_1:  CMP     AL,00100000B        ; BRANCH TO START
0999  74 F9                             JE      F19_0
099B  81 3E 0072 R 4321                 CMP     RESET_FLAG,4321H    ; DIAG. CONTROL PROGRAM RESTART?
09A1  74 0C                             JE      F19_3               ; NO, GO BOOT
09A3  3C 10                             CMP     AL,00010000B        ; MFG DCP RUN REQUEST
09A5  74 08                             JE      F19_3
09A7  C7 06 0072 R 1234                 MOV     RESET_FLAG,1234H    ; SET WARM START INDICATOR IN CASE
                                                                    ; OF CARTRIDGE RESET
09AD  CD 19                             INT     19H                 ; GO TO THE BOOT LOADER

09AF  FA                        F19_3:  CLI
09B0  2B C0                             SUB     AX,AX
09B2  8E D8                             MOV     DS,AX               ; RESET TIMER INT.
09B4  C7 06 0020 R FEA5 R               MOV     INT_PTR,OFFSET TIMER_INT
09BA  CD 80                             INT     80H                 ; ENTER DCP THROUGH INT. 80H

                                ;-------------------------------------------------------------
                                ; THIS SUBROUTINE IS THE GENERAL ERROR HANDLER FOR THE POST
                                ;
                                ; ENTRY REQUIREMENTS:
                                ;     SI = OFFSET(ADDRESS) OF MESSAGE BUFFER
                                ;     BX= ERROR CODE FOR MANUFACTURING OR SERVICE MODE
                                ;     REGISTERS ARE NOT PRESERVED
                                ;     LOCATION "POST_ERR" IS SET NON-ZERO IF AN ERROR OCCURS IN
                                ;     CUSTOMER MODE
                                ;     SERVICE/MANUFACTURING FLAGS AS FOLLOWS: (HIGH NIBBLE OF
                                ;     PORT 201)
                                ;         0000 = MANUFACTURING (BURN-IN) MODE
                                ;         0001 = MANUFACTURING (SYSTEM TEST) MODE
                                ;         0010 = SERVICE MODE (LOOP POST)
                                ;         0100 = SERVICE MODE (SYSTEM TEST)
                                ;-------------------------------------------------------------

09BC                            E_MSG   PROC    NEAR
09BC  BA 0201                           MOV     DX,201H
09BF  EC                                IN      AL,DX               ; GET MODE BITS
09C0  24 F0                             AND     AL,0F0H             ; ISOLATE BITS OF INTEREST
09C2  75 03                             JNZ     EM0
09C4  E9 0A61 R                         JMP     MFG_OUT             ; MANUFACTURING MODE (BURN-IN)
09C7  3C 10                     EM0:    CMP     AL,00010000B        ;
09C9  75 03                             JNE     EM1
09CB  E9 0A61 R                         JMP     MFG_OUT             ; MFG. MODE (SYSTEM TEST)
09CE  8A F0                     EM1:    MOV     DH,AL               ; SAVE MODE
09D0  80 FF 0A                          CMP     BH,0AH              ; ERROR CODE ABOVE 0AH (CRT STARTED
                                                                    ; DISPLAY POSSIBLE)?
09D3  7C 63                             JL      BEEPS               ; DO BEEP OUTPUT IF BELOW 10H
09D5  53                                PUSH    BX                  ; SAVE ERROR AND MODE FLAGS
09D6  56                                PUSH    SI
09D7  52                                PUSH    DX
09D8  B4 02                             MOV     AH,2                ; SET CURSOR
09DA  BA 1521                           MOV     DX,1521H            ; ROW 21, COL.33
09DD  B7 07                             MOV     BH,7                ; PAGE 7
09DF  CD 10                             INT     10H
09E1  BE 0030 R                         MOV     SI,OFFSET ERROR_ERR
09E4  B9 0005                           MOV     CX,5                ; PRINT WORD "ERROR"
09E7  2E: 8A 04                 EM_O:   MOV     AL,CS:[SI]
09EA  46                                INC     SI
09EB  E8 18BA R                         CALL    PRT_HEX
09EE  E2 F7                             LOOP    EM_O                ; LOOK FOR A BLANK SPACE TO POSSIBLY PUT CUSTOMER LEVEL ERRORS (IN
                                                                    ; CASE OF MULTI ERROR)
09F0  B6 16                             MOV     DH,16H
09F2  B4 02                     EM_1:   MOV     AH,2                ; SET CURSOR
09F4  CD 10                             INT     10H                 ; ROW 22, COL33 (OR ABOVE, IF
                                                                    ; MULTIPLE ERRS)
09F6  B4 08                             MOV     AH,8                ; READ CHARACTER THIS POSITION
09F8  CD 10                             INT     10H
09FA  FE C2                             INC     DL                  ; POINT TO NEXT POSTION
09FC  3C 20                             CMP     AL,' '              ; BLANK?
09FE  75 F2                             JNE     EM_1                ; GO CHECK NEXT POSITION, IF NOT
0A00  5A                                POP     DX                  ; RECOVER ERROR POINTERS
0A01  5E                                POP     SI
0A02  5B                                POP     BX
0A03  80 FE 20                          CMP     DH,00100000B        ; SERVICE MODE?
0A06  74 21                             JE      SERV_OUT            ;
0A08  80 FE 40                          CMP     DH,01000000B        ;
0A0B  74 1C                             JE      SERV_OUT
0A0D  2E: 8A 04                         MOV     AL,CS:[SI]          ; GET ERROR CHARACTER
0A10  E8 18BA R                         CALL    PRT_HEX             ; DISPLAY IT
0A13  80 FF 20                          CMP     BH,20H              ; ERROR BELOW 20? (MEM TROUBLE?)
0A16  7D 03                             JNL     EM_2
0A18  E9 0ABB R                         JMP     TOTLTPO             ; HALT SYSTEM IF SO.
0A1B  1E                        EM_2:   PUSH    DS
0A1C  50                                PUSH    AX
0A1D  B8 ---- R                         MOV     AX,XXDATA
0A20  8E D8                             MOV     DS,AX
0A22  88 3E 0018 R                      MOV     POST_ERR,BH         ; SET ERROR FLAG NON-ZERO
0A26  58                                POP     AX
0A27  1F                                POP     DS
                                        ASSUME  DS:NOTHING
0A28  C3                                RET                         ; RETURN TO CALLER
; --------------------------------------------------------------------------------------------------
; A-024
; --------------------------------------------------------------------------------------------------
0A29                            SERV_OUT:
0A29  8A C7                             MOV     AL,BH               ; PRINT MSB
0A2B  53                                PUSH    BX
0A2C  E8 18A9 R                         CALL    XPC_BYTE            ; DISPLAY IT
0A2F  5B                                POP     BX
0A30  8A C3                             MOV     AL,BL               ; PRINT LSB
0A32  E8 18A9 R                         CALL    XPC_BYTE
0A35  E9 0ABB R                         JMP     TOTLTPO
0A38  FA                        BEEPS:  CLI                         ; SET CODE SEG= STACK SEG
0A39  8C C8                             MOV     AX,CS               ; (STACK IS LOST, BUT THINGS ARE
0A3B  8E D0                             MOV     SS,AX               ;  OVER, ANYWAY)
0A3D  B2 02                             MOV     DL,2                ; 2 BEEPS
0A3F  BC 0028 R                         MOV     SP,OFFSET EX_0      ; SET DUMMY RETURN
0A42  B3 01                     EB:     MOV     BL,1                ; SHORT BEEP
0A44  E9 FF31 R                         JMP     BEEP                ;
0A47  E2 FE                     EB0:    LOOP    EB0                 ; WAIT (BEEPER OFF)
0A49  FE CA                             DEC     DL                  ; DONE YET?
0A4B  75 F5                             JNZ     EB                  ; LOOP IF NOT
0A4D  80 FF 05                          CMP     BH,05H              ; 64K CARD ERROR?
0A50  75 69                             JNE     TOTLTPO             ; END IF NOT
0A52  80 FE 20                          CMP     DH,00100000B        ; SERVICE MODE?
0A55  74 05                             JE      EB1                 ;
0A57  80 FE 40                          CMP     DH,01000000B        ;
0A5A  75 5F                             JNE     TOTLTPO             ; END IF NOT
0A5C  B3 01                     EB1:    MOV     BL,1                ; ONE MORE BEEP FOR 64K ERROR IF IN
                                                                    ; SERVICE MODE
0A5E  E9 FF31 R                         JMP     BEEP
0A61                            MFG_OUT:
0A61  FA                                CLI
0A62  E4 61                             IN      AL,PORT_B
0A64  24 FC                             AND     AL,0FCH
0A66  E6 61                             OUT     PORT_B,AL
0A68  BA 0011                           MOV     DX,11H              ; SEND DATA TO  ADDRESSES 11,12
0A6B  8A C7                             MOV     AL,BH               ;
0A6D  EE                                OUT     DX,AL               ; SEND HIGH BYTE
0A6E  42                                INC     DX                  ;
0A6F  8A C3                             MOV     AL,BL               ;
0A71  EE                                OUT     DX,AL               ; SEND LOW BYTE
                                ; INIT. ON-BOARD RS232 PORT FOR COMMUNICATIONS W/MFG MONITOR
                                        ASSUME  DS:XXDATA
0A72  B8 ---- R                         MOV     AX,XXDATA
0A75  8E D8                             MOV     DS,AX           ; POINT TO DATA SEGMENT CONTAINING
                                                                ; CHECKPOINT #
0A77  8C C8                             MOV     AX,CS
0A79  8E D0                             MOV     SS,AX
0A7B  BC 002E R                         MOV     SP,OFFSET EX1   ; SET STACK FOR RTN
0A7E  BA 02FB                           MOV     DX,02FBH        ; LINE CONTROL REG. ADDRESS
0A81  E9 F085 R                         JMP     S8250           ; GO SET UP FOR 9600, ODD, 2 STOP
                                                                ; BITS, 8 BITS
0A84  8B CA                     M01:    MOV     CX,DX           ; DX CAME BACK WITH XMIT REG
                                                                ; ADDRESS IN IT
0A86  BA 02FC                           MOV     DX,02FCH        ; MODEM CONTROL REG
0A89  2A C0                             SUB     AL,AL           ; SET DTR AND RTS LOW SO POSSIBLE
                                                                ; WRAP PLUG WON'T CONFUSE THINGS
0A8B  EE                                OUT     DX,AL
0A8C  BA 02FE                           MOV     DX,02FEH        ; MODEM STATUS REG
0A8F  EC                        M02:    IN      AL,DX           ; CTS UP YET?
0A90  24 10                             AND     AL,00010000B    ; LOOP TILL IT IS
0A92  74 FB                             JZ      M02             ; SET DX=2FD (LINE STATUS REG)
0A94  4A                                DEC     DX              ; POINT TO XMIT. DATA REG
0A95  87 D1                             XCHG    DX,CX           ; GET MFG ROUTINE ERROR INDICATOR
0A97  A0 0005 R                         MOV     AL,MFG_TST      ; (MAY BE WRONG FOR EARLY ERRORS)
0A9A  EE                                OUT     DX,AL           ; DELAY
0A9B  EB 00                             JMP     $+2
0A9D  87 D1                             XCHG    DX,CX           ; POINT DX=2FD
0A9F  EC                        M03:    IN      AL,DX           ; TRANSMIT EMPTY?
0AA0  24 20                             AND     AL,00100000B    ; DELAY
0AA2  EB 00                             JMP     $+2             ; LOOP TILL IT IS
0AA4  74 F9                             JZ      M03
0AA6  87 D1                             XCHG    DX,CX
0AA8  8A C7                             MOV     AL,BH           ; GET MSB OF ERROR WORD
0AAA  EE                                OUT     DX,AL
0AAB  EB 00                             JMP     $+2             ; DELAY
0AAD  87 D1                             XCHG    DX,CX
0AAF  EC                        M04:    IN      AL,DX           ; WAIT FOR XMIT EMPTY
0AB0  24 20                             AND     AL,00100000B    ; DELAY
0AB2  EB 00                             JMP     $+2             ; LOOP TILL IT IS
0AB4  74 F9                             JZ      M04
0AB6  8A C3                             MOV     AL,BL           ; GET LSB OF ERROR WORD
0AB8  87 D1                             XCHG    DX,CX
0ABA  EE                                OUT     DX,AL
0ABB  FA                        TOTLTPO:CLI                     ; DISABLE INTS.
0ABC  2A C0                             SUB     AL,AL
0ABE  E6 F2                             OUT     0F2H,AL         ; STOP DISKETTE MOTOR
0AC0  E6 A0                             OUT     0A0H,AL         ; DISABLE NMI
0AC2  F4                                HLT                     ; HALT
0AC3  C3                                RET
0AC4                            E_MSG   ENDP
; --------------------------------------------------------------------------------------------------
; A-025
; --------------------------------------------------------------------------------------------------
                                ;---------------------------------------------------------------------
                                ; SUBROUTINE TO INITIALIZE INS8250 PORTS TO THE MASTER RESET
                                ; STATUS. THIS ROUTINE ALSO TESTS THE PORTS' PERMANENT
                                ; ZERO BITS.
                                ; EXPECTS TO BE PASSED:
                                ;       (DX) = ADDRESS OF THE 8250 TRANSMIT/RECEIVE BUFFER
                                ; UPON RETURN:
                                ;       (CF) = 1      IF ONE OF THE PORTS' PERMANENT ZERO BITS WAS NOT
                                ;                     ZERO (ERR)
                                ;       (DX) = PORT ADDRESS THAT FAILED TEST
                                ;       (AL) = MEANINGLESS
                                ;       (BL) = 2      INTR ENBL REG  BITS NOT 0
                                ;                3    INTR ID REG BITS NOT 0
                                ;                4    MODEM CTRL REG  BITS NOT 0
                                ;                5    LINE STAT REG BITS NOT 0
                                ;              0      IF ALL PORTS' PERMANENT ZERO BITS WERE ZERO
                                ;       (DX) = TRANSMIT/RECEIVE BUFFER ADDRESS
                                ;       (AL) = LAST VALUE READ FROM RECEIVER BUFFER
                                ;       (BL) = 5 (MEANINGLESS)
                                ; PORTS SET UP AS FOLLOWS ON ERROR-FREE RETURN:
                                ;       XF9 - INTR ENBL REG = 0              ALL INTERRUPTS DISABLED
                                ;       XFA - INTR ID REG = 00000001B        NO INTERRUPTS PENDING
                                ;       XFB - LINE CTRL REG = 0              ALL BITS LOW
                                ;       XFC - MODEM CTRL REG = 0             ALL BITS LOW
                                ;       XFD - LINE STAT REG = 01100000B      TRANSMITTER HOLDING
                                ;                                           REGISTER AND TRANSMITTER EMPTY ON
                                ;                                           INPUT SIGNALS
                                ;       XFE - MODEM STAT REG = XXX00000B WHERE X 'S REPRESENT
                                ; REGISTERS DX, AL, AND BL ARE ALTERED. NO OTHER REGISTERS USED.
                                ;---------------------------------------------------------------------
0AC4                            I8250   PROC    NEAR
0AC4  EC                                IN      AL,DX           ; READ RECVR BUFFER BUT IGNORE
                                                                ; CONTENTS
0AC5  B3 02                             MOV     BL,2            ; ERROR INDICATOR
0AC7  E8 FE9F R                         CALL    RR2             ; READ INTR ENBL REG
0ACA  24 F0                             AND     AL,11110000B    ; BITS 4-7 OFF?
0ACC  75 28                             JNE     AT20            ; NO - ERROR
0ACE  E8 FE9A R                         CALL    RR1             ; READ INTR ID REG
0AD1  24 F8                             AND     AL,11111000B    ; BITS 3-7 OFF?
0AD3  75 21                             JNE     AT20            ; NO
0AD5  42                                INC     DX              ; LINE CTRL REG
0AD6  E8 FE9A R                         CALL    RR1             ; READ MODEM CTRL REG
0AD9  24 E0                             AND     AL,11100000B    ; BITS 5-7 OFF?
0ADB  75 19                             JNE     AT20            ; NO
0ADD  E8 FE9A R                         CALL    RR1             ; READ LINE STAT REG
0AE0  24 80                             AND     AL,10000000B    ; BIT 7 OFF?
0AE2  75 12                             JNE     AT20            ; NO
0AE4  B0 60                             MOV     AL,60H
0AE6  EE                                OUT     DX,AL
0AE7  EB 00                             JMP     $+2             ; I/O DELAY
0AE9  42                                INC     DX              ; MODEM STAT REG
0AEA  32 C0                             XOR     AL,AL           ; WIRED BITS WILL BE HIGH
0AEC  EE                                OUT     DX,AL           ; CLEAR BITS 0-3 IN CASE THEY'RE ON
0AED  E8 FEA0 R                         CALL    RR3             ; AFTER WRITING TO STATUS REG
                                                                ; RECEIVER BUFFER
0AF0  83 EA 06                          SUB     DX,6            ; IN CASE WRITING TO PORTS CAUSED
0AF3  EC                                IN      AL,DX           ; DATA READY TO GO HIGH!
0AF4  F8                                CLC
0AF5  C3                                RET
0AF6  F9                        AT20:   STC                     ; ERROR RETURN
0AF7  C3                                RET
0AF8                            I8250   ENDP
                                ;---------------------------------------------------------------------
                                ; SUBROUTINE TO TEST A PARTICULAR 8250 INTERRUPT. PASS IT THE
                                ;       (BIT # + 1) OF THE STATUS REGISTER THAT IS TO BE TESTED.
                                ;       THIS ROUTINE SETS THAT BIT AND CHECKS TO SEE IF THE CORRECT
                                ;       8250 INTERRUPT IS GENERATED.
                                ; IT EXPECTS TO BE PASSED:
                                ;       (AH) = BIT # TO BE TESTED
                                ;       (BL) = INTERRUPT IDENTIFIER
                                ;               (0) = RECEIVED DATA AVAILABLE OR TRANSMITTER HOLDING
                                ;                       REGISTER EMPTY INTERRUPT TEST
                                ;               (1) = RECEIVER LINE STATUS OR MODEM STATUS INTERRUPT
                                ;                       TEST
                                ;       (BH) = BITS WHICH DETERMINE WHICH INTERRUPT IS TO BE
                                ;               CHECKED
                                ;               (0) = MODEM STATUS
                                ;               (2) = TRANSMITTER HOLDING REGISTER EMPTY
                                ;               (4) = RECEIVED DATA AVAILABLE
                                ;               (6) = RECEIVER LINE STATUS
                                ;       (CX) = VALUE TO SUBTRACT AND ADD IN ORDER TO REFERENCE THE
                                ;               INTERRUPT IDENTIFICATION REGISTER
                                ;               (3) = RECEIVED DATA AVAILABLE, TRANSMITTER HOLDING
                                ;                       REGISTER AND RECEIVER LINE STATUS INTERRUPTS
                                ;               (4) = MODEM STATUS INTERRUPT
                                ;       (DX) = ADDRESS OF THE LINE STATUS OR MODEM STATUS REGISTER
                                ; IT RETURNS:
                                ;       (AL) = 0FFH IF TEST FAILS - EITHER NO INTERRUPT OCCURRED OR
                                ;               THE WRONG INTERRUPT OCCURRED
                                ;       OR
                                ;       (AL) = CONTENTS OF THE INTERRUPT ID REGISTER FOR RECEIVED
                                ;               DATA AVAILABLE AND TRANSMITTER HOLDING REGISTER
                                ;               EMPTY INTERRUPTS
                                ;                               -OR-
                                ;               CONTENTS OF THE LINE STATUS OR MODEM STATUS REGISTER
                                ;               DEPENDING ON WHICH ONE WAS TESTED.
                                ;       (DX) = ADDRESS OF INTERRUPT ID REGISTER FOR RECEIVED DATA
                                ;               AVAILABLE OR TRANSMITTER HOLDING REGISTER EMPTY
                                ;               INTERRUPTS
                                ;       OR
                                ;       (DX) = ADDRESS OF THE LINE STATUS OR DATA SET STATUS
                                ;               REGISTER (DEPENDING ON WHICH INTERRUPT WAS TESTED)
                                ; NO OTHER REGISTERS ARE ALTERED.
                                ;---------------------------------------------------------------------
; --------------------------------------------------------------------------------------------------
; A-026
; --------------------------------------------------------------------------------------------------
0AF8                            ICT     PROC    NEAR
0AF8  EC                                IN      AL,DX           ; READ STATUS REGISTER
0AF9  EB 00                             JMP     $+2             ; I/O DELAY
0AFB  0A C4                             OR      AL,AH           ; SET TEST BIT
0AFD  EE                                OUT     DX,AL           ; WRITE IT TO THE STATUS REGISTER
0AFE  2B D1                             SUB     DX,CX           ; POINT TO INTERRUPT ID REGISTER
0B00  51                                PUSH    CX
0B01  2B C9                             SUB     CX,CX           ; WAIT FOR 8250 INTERRUPT TO OCCUR
0B03  EC                        AT21:   IN      AL,DX           ; READ INTR ID REG
0B04  A8 01                             TEST    AL,1            ; INTERRUPT PENDING?
0B06  74 02                             JE      AT22            ; YES - RETURN W/ INTERRUPT ID IN AL
0B08  E2 F9                             LOOP    AT21            ; NO - TRY AGAIN
0B0A  59                        AT22:   POP     CX              ; AL = 1 IF NO INTERRUPT OCCURRED
0B0B  3A C7                             CMP     AL,BH           ; INTERRUPT WE'RE LOOKING FOR?
0B0D  75 09                             JNE     AT23            ; NO
0B0F  0A DB                             OR      BL,BL           ; DONE WITH TEST FOR THIS INTERRUPT
0B11  74 07                             JE      AT24            ; RETURN W/ CONTENTS OF INTR ID REG
0B13  03 D1                             ADD     DX,CX           ; READ STATUS REGISTER TO CLEAR THE
0B15  EC                                IN      AL,DX           ; INTERRUPT (WHEN BL=1)
0B16  EB 02                             JMP     SHORT AT24      ; RETURN CONTENTS OF STATUS REG
0B18  B0 FF                     AT23:   MOV     AL,0FFH         ; SET ERROR INDICATOR
0B1A  C3                        AT24:   RET
0B1B                            ICT     ENDP
                                ; --- INT 19 ------------------------------
                                ; BOOT STRAP LOADER
                                ;       TRACK 0, SECTOR 1 IS READ INTO THE
                                ;       BOOT LOCATION (SEGMENT 0, OFFSET 7C00)
                                ;       AND CONTROL IS TRANSFERRED THERE.
                                ;
                                ;       IF THE DISKETTE IS NOT PRESENT OR HAS A
                                ;       PROBLEM LOADING (E.G., NOT READY), AN INT.
                                ;       18H IS EXECUTED.  IF A CARTRIDGE HAS VECTORED
                                ;       INT. 18H TO ITSELF, CONTROL WILL BE PASSED TO
                                ;       THE CARTRIDGE.
                                ;-------------------------------------------------------
                                        ASSUME  CS:CODE,DS:ABSO
0B1B                            BOOT_STRAP      PROC    NEAR
0B1B  FB                                STI                     ; ENABLE INTERRUPTS
0B1C  2B C0                             SUB     AX,AX           ; SET 40X25 B&W MODE ON CRT
0B1E  CD 10                             INT     10H
0B20  2B C0                             SUB     AX,AX           ; ESTABLISH ADDRESSING
0B22  8E D8                             MOV     DS,AX
                                ;------ SEE IF DISKETTE PRESENT
0B24  E4 62                             IN      AL,PORT_C       ; GET CONFIG BITS
0B26  24 04                             AND     AL,00000100B    ; IS DISKETTE PRESENT?
0B28  75 28                             JNZ     H3              ; NO, THEN ATTEMPT TO GO TO CART.
                                ;------ RESET THE DISK PARAMETER TABLE VECTOR
0B2A  C7 06 0078 R EFC7 R               MOV     WORD PTR DISK_POINTER,OFFSET DISK_BASE
0B30  8C 0E 007A R                      MOV     WORD PTR DISK_POINTER+2,CS
                                ;------ LOAD SYSTEM FROM DISKETTE -- CX HAS RETRY COUNT
0B34  B9 0004                           MOV     CX,4            ; SET RETRY COUNT
0B37  51                        H1:     PUSH    CX              ; SAVE RETRY COUNT
0B38  B4 00                             MOV     AH,0            ; RESET THE DISKETTE SYSTEM
0B3A  CD 13                             INT     13H             ; DISKETTE_IO
0B3C  72 0F                             JC      H2              ; IF ERROR, TRY AGAIN
0B3E  B8 0201                           MOV     AX,201H         ; READ IN THE SINGLE SECTOR
0B41  2B D2                             SUB     DX,DX           ; TO THE BOOT LOCATION
0B43  8E C2                             MOV     ES,DX
0B45  BB 7C00 R                         MOV     BX,OFFSET BOOT_LOCN
0B48  B9 0001                           MOV     CX,1            ; DRIVE 0, HEAD 0
0B4B  CD 13                             INT     13H             ; SECTOR 1, TRACK 0
0B4D  59                        H2:     POP     CX              ; DISKETTE_IO
0B4E  73 04                             JNC     H3A             ; RECOVER RETRY COUNT
0B50  E2 E5                             LOOP    H1              ; CF SET BY UNSUCCESSFUL READ
                                ; DO IT FOR RETRY TIMES
                                ;------ UNABLE TO IPL FROM THE DISKETTE
0B52  CD 18                     H3:     INT     18H             ; GO TO BASIC OR CARTRIDGE
                                ;------ IPL WAS SUCCESSFUL
0B54  EA 7C00 ---- R            H3A:    JMP     BOOT_LOCN
0B59                            BOOT_STRAP      ENDP
                                ;-------------------------------------------------------
                                ; THIS ROUTINE PERFORMS A READ/WRITE TEST ON A BLOCK OF
                                ; STORAGE (MAX. SIZE = 32KB).  IF "WARM START", FILL
                                ; BLOCK WITH 0000 AND RETURN.
                                ; DATA PATTERNS USED:
                                ;       0->FF ON ONE BYTE TO TEST DATA BUS
                                ;       AAAA,5555,0OFF,FF00 FOR ALL WORDS
                                ;       FILL WITH 0000 BEFORE EXIT
                                ; ON ENTRY:
                                ;   ES = ADDRESS OF STORAGE TO BE TESTED
                                ;   DS = ADDRESS OF STORAGE TO BE TESTED
                                ;   CX = WORD COUNT OF STORAGE BLOCK TO BE TESTED
                                ;           (MAX. = 8000H (32K WORDS))
                                ; ON EXIT:
                                ;   ZERO FLAG = OFF IF STORAGE ERROR
                                ;   IF ZERO FLAG = OFF, THEN CX = XOR'ED BIT PATTERN
                                ;           OF THE EXPECTED DATA PATTERN VS. THE ACTUAL DATA
                                ;           READ. (I.E., A BIT "ON" IN AL IS THE BIT IN ERROR)
                                ;   AH=03 IF BOTH BYTES OF WORD HAVE ERRORS
                                ;   AH=02 IF LOW (EVEN) BYTE HAS ERROR
                                ;   AH=01 IF HI (ODD) BYTE HAS ERROR
                                ; AX,BX,CX,DX,DI,SI ARE ALL DESTROYED.
                                ;-------------------------------------------------------
; --------------------------------------------------------------------------------------------------
; A-027
; --------------------------------------------------------------------------------------------------
0B59                            PODSTG  PROC    NEAR
                                        ASSUME  DS:ABSO
0B59  FC                                CLD                     ; SET DIRECTION TO INCREMENT
0B5A  2B FF                             SUB     DI,DI           ; SET DI=0000 REL. TO START OF SEG
0B5C  2B C0                             SUB     AX,AX           ; INITIAL DATA PATTERN FOR 00-FF
                                                                ; TEST
0B5E  8E D8                             MOV     DS,AX           ; SET DS TO ABS0
0B60  8B 1E 0472 R                      MOV     BX,DATA_WORD[RESET_FLAG-DATA] ; WARM START?
0B64  81 FB 1234                        CMP     BX,1234H
0B68  8C C2                             MOV     DX,ES
0B6A  8E DA                             MOV     DS,DX           ; RESTORE DS
0B6C  75 0B                             JNE     P1
0B6E  F3/ AB                    P12:    REP     STOSW           ; SIMPLE FILL WITH 0 ON WARM-START
0B70  8E D8                             MOV     DS,AX
0B72  89 1E 0472 R                      MOV     DATA_WORD[RESET_FLAG-DATA],BX
0B76  8E DA                             MOV     DS,DX           ; RESTORE DS
0B78  C3                                RET                     ; AND EXIT
0B79  81 FB 4321                P1:     CMP     BX,4321H        ; DIAG. RESTART?
0B7D  74 EF                             JE      P12             ; DO FILL WITH ZEROS
0B7F  88 05                     P2:     MOV     [DI],AL         ; WRITE TEST DATA
0B81  8A 05                             MOV     AL,[DI]         ; GET IT BACK
0B83  32 C4                             XOR     AL,AH           ; COMPARE TO EXPECTED
0B85  74 03                             JZ      PY
0B87  E9 0C0C R                         JMP     P8              ; ERROR EXIT IF MISCOMPARE
0B8A  FE C4                     PY:     INC     AH              ; FORM NEW DATA PATTERN
0B8C  8A C4                             MOV     AL,AH
0B8E  75 EF                             JNZ     P2              ; LOOP TILL ALL 256 DATA PATTERNS
                                                                ; DONE
0B90  8B E9                             MOV     BP,CX           ; SAVE WORD COUNT
0B92  B8 AAAA                           MOV     AX,0AAAAH       ; LOAD DATA PATTERN
0B95  8B D8                             MOV     BX,AX
0B97  BA 5555                           MOV     DX,05555H       ; LOAD OTHER DATA PATTERN
0B9A  F3/ AB                            REP     STOSW           ; FILL WORDS FROM LOW TO HIGH
                                                                ; WITH AAAA
                                
0B9C  4F                                DEC     DI              ; POINT TO LAST WORD WRITTEN
0B9D  4F                                DEC     DI              ;
0B9E  FD                                STD                     ; SET DIRECTION FLAG TO GO DOWN
0B9F  8B F7                             MOV     SI,DI           ; SET INDEX REGS. EQUAL
0BA1  8B CD                             MOV     CX,BP           ; RECOVER WORD COUNT
0BA3                            P3:                             ; GO FROM HIGH TO LOW
0BA3  AD                                LODSW                   ; GET WORD FROM MEMORY
0BA4  33 C3                             XOR     AX,BX           ; EQUAL WHAT S/B THERE?
0BA6  75 64                             JNZ     P8              ; GO ERROR EXIT IF NOT
0BA8  8B C2                             MOV     AX,DX           ; GET 55 DATA PATTERN
0BAA  AB                                STOSW                   ;  STORE IT IN LOCATION JUST READ
0BAB  E2 F6                             LOOP    P3              ; LOOP TILL ALL BYTES DONE
0BAD  8B CD                             MOV     CX,BP           ; RECOVER WORD COUNT
0BAF  FC                                CLD                     ; DECREMENT
0BB0  46                                INC     SI              ; ADJUST PTRS
0BB1  46                                INC     SI
0BB2  8B FE                             MOV     DI,SI
0BB4  8B DA                             MOV     BX,DX           ; S/B DATA PATTERN TO BX
0BB6  BA 00FF                           MOV     DX,00FFH        ; DATA FOR CHECKERBOARD PATTERN
0BB9  AD                        PX:     LODSW                   ; GET WORD FROM MEMORY
0BBA  33 C3                             XOR     AX,BX           ; EQUAL WHAT S/B THERE?
0BBC  75 4E                             JNZ     P8              ; GO ERROR EXIT IF NOT
0BBE  8B C2                             MOV     AX,DX           ; GET OTHER PATTERN
0BC0  AB                                STOSW                   ; STORE IT IN LOCATION JUST READ
0BC1  E2 F6                             LOOP    PX              ; LOOP TILL ALL BYTES DONE
0BC3  8B CD                             MOV     CX,BP           ; RECOVER WORD COUNT
0BC5  FD                                STD                     ; DECREMENT
0BC6  4E                                DEC     SI              ; ADJUST PTRS
0BC7  4E                                DEC     SI
0BC8  8B FE                             MOV     DI,SI
0BCA  8B DA                             MOV     BX,DX           ; S/B DATA PATTERN TO BX
0BCC  F7 D2                             NOT     DX              ; MAKE PATTERN FF00
0BCE  0A D2                             OR      DL,DL           ; FIRST PASS?
0BD0  74 E7                             JZ      PX
0BD2  FC                                CLD                     ; INCREMENT
0BD3  83 C6 04                          ADD     SI,4
0BD6  F7 D2                             NOT     DX
0BD8  8B FE                             MOV     DI,SI
0BDA  8B CD                             MOV     CX,BP
0BDC  AD                        P4:                             ; LOW TO HIGH
0BDC  AD                                LODSW                   ; GET A WORD
0BDD  33 C2                             XOR     AX,DX           ; SHOULD COMPARE TO DX
0BDF  75 2B                             JNZ     P8              ; GO ERROR IF NOT
0BE1  AB                                STOSW                   ; WRITE 0000 BACK TO LOCATION
                                                                ; JUST READ
0BE2  E2 F8                             LOOP    P4              ; LOOP TILL DONE
0BE4  FD                                STD                     ; BACK TO DECREMENT
0BE5  4E                                DEC     SI              ; ADJUST POINTER DOWN TO LAST WORD
0BE6  4E                                DEC     SI              ; WRITTEN
                                ; CHECK IF IN SERVICE/MFG MODES, IF SO, PERFORM REFRESH CHECK
0BE7  BA 0201                           MOV     DX,201H         ;
0BEA  EC                                IN      AL,DX           ; GET OPTION BITS
0BEB  24 F0                             AND     AL,0F0H         ;
0BED  3C F0                             CMP     AL,0F0H         ; ALL BITS HIGH=NORMAL MODE
0BEF  74 10                             JE      P6
0BF1  8C C9                             MOV     CX,CS
0BF3  8C D3                             MOV     BX,SS
0BF5  3B CB                             CMP     CX,BX           ; SEE IF IN PRE-STACK MODE
0BF7  74 08                             JE      P6              ; BYPASS RETENTION TEST IF SO
0BF9  B0 18                             MOV     AL,24           ; SET OUTER LOOP COUNT
                                ; WAIT ABOUT 6-8 SECONDS WITHOUT ACCESSING MEMORY
                                ; IF REFRESH IS NOT WORKING PROPERLY, THIS SHOULD
                                ; BE ENOUGH TIME FOR SOME DATA TO GO SOUR.
; --------------------------------------------------------------------------------------------------
; A-028
; --------------------------------------------------------------------------------------------------
0BFB  E2 FE                     P5:     LOOP    P5                  ; RECOVER WORD COUNT
0BFD  FE C8                             DEC     AL                  ; GET WORD
0BFF  75 FA                             JNZ     P5                  ; = TO 0000
0C01  8B CD                     P6:     MOV     CX,BP               ; ERROR IF NOT
0C03  AD                        P7:     LODSW                       ; LOOP TILL DONE
0C04  0B C0                             OR      AX,AX               ; THEN EXIT
0C06  75 04                             JNZ     P8                  ; SAVE BITS IN ERROR
0C08  E2 F9                             LOOP    P7
0C0A  EB 13                             JMP     SHORT P11
0C0C  8B C8                     P8:     MOV     CX,AX               ; HIGH BYTE ERROR?
0C0E  32 E4                             XOR     AH,AH
0C10  0A ED                             OR      CH,CH               ; SET HIGH BYTE ERROR
0C12  74 02                             JZ      P9                  ; LOW BYTE ERROR?
0C14  FE C4                             INC     AH
0C16  0A C9                     P9:     OR      CL,CL
0C18  74 03                             JZ      P10
0C1A  80 C4 02                          ADD     AH,2
0C1D  0A E4                     P10:    OR      AH,AH               ; SET ZERO FLAG=0 (ERROR INDICATION
0C1F  FC                        P11:    CLD                         ; SET DIR FLAG BACK TO INCREMENT
0C20  C3                                RET                         ; RETURN TO CALLER
0C21                            PODSTG  ENDP

                                ;*******************************************************
                                ; PUT_LOGO PROCEDURE
                                ;      THIS PROC SETS UP POINTERS AND CALLS THE SCREEN
                                ;   OUTPUT ROUTINE SO THAT THE IBM LOGO, A MESSAGE,
                                ;   AND A COLOR BAR ARE PUT UP ON THE SCREEN.
                                ;   AX,BX, AND DX ARE DESTROYED. ALL OTHERS ARE SAVED
                                ;*******************************************************

0C21                            PUT_LOGO PROC    NEAR
0C21  1E                                PUSH    DS
0C22  55                                PUSH    BP
0C23  50                                PUSH    AX
0C24  53                                PUSH    BX
0C25  51                                PUSH    CX
0C26  52                                PUSH    DX
0C27  BD 0C4A R                         MOV     BP,OFFSET LOGO      ; POINT DH DL AT ROW,COLUMN 0,0
0C2A  BA 8000                           MOV     DX,8000H            ; ATTRIBUTE OF CHARACTERS TO BE
0C2D  B3 1F                             MOV     BL,00011111B        ; WRITTEN

0C2F  CD 82                             INT     82H                 ; CALL OUTPUT ROUTINE
0C31  B3 00                             MOV     BL,00000000B        ; INITIALIZE ATTRIBUTE
0C33  B2 00                             MOV     DL,0                ; INITIALIZE COLUMN
0C35  B6 94                     AGAIN:  MOV     DH,94H              ; SET LINE
0C37  BD 0CDD R                         MOV     BP,OFFSET COLOR     ; OUTPUT GIVEN COLOR BAR
0C3A  CD 82                             INT     82H                 ; CALL OUTPUT ROUTINE
0C3C  FE C3                             INC     BL                  ; INCREMENT ATTRIBUTE
0C3E  80 FA 20                          CMP     DL,32               ; IS THE COLUMN COUNTER POINTING
                                                                    ; PAST 40?
0C41  7C F2                             JL      AGAIN               ; IF NOT, DO IT AGAIN
0C43  5A                                POP     DX
0C44  59                                POP     CX
0C45  5B                                POP     BX
0C46  58                                POP     AX
0C47  5D                                POP     BP                  ; RESTORE BP
0C48  1F                                POP     DS                  ; RESTORE DS
0C49  C3                                RET
0C4A                            PUT_LOGO ENDP
0C4A  03                        LOGO    DB      LOGO_E - LOGO
0C4B  20 DC                             DB      ' ',220
= 0C4D                          LOGO_E  =       $
0C4D  28 FB                             DB      40,-5
0C4F  28 FB                             DB      40,-5
0C51  02 07 01 09 03 04                 DB      2,7,1,9,3,4,9,4,1,-5
      09 04 01 FB
0C5B  02 07 01 0A 02 05                 DB      2,7,1,10,2,5,7,5,1,-5
      07 05 01 FB
0C65  02 07 01 0B 01 06                 DB      2,7,1,11,1,6,5,6,1,-5
      05 06 01 FB
0C6F  04 03 05 03 03 03                 DB      4,3,5,3,3,3,5,3,5,3,-5
      03 05 03 05 03 FB
0C7B  04 03 05 03 03 03                 DB      4,3,5,3,3,3,3,6,1,6,3,-5
      03 03 05 03 03 03
0C87  04 03 05 08 04 0D                 DB      4,3,5,8,4,13,3,-5
      03 FB
0C8F  04 03 05 07 05 0D                 DB      4,3,5,7,5,13,3,-5
      03 FB
0C97  04 03 05 08 04 0D                 DB      4,3,5,8,4,13,3,-5
      03 FB
0C9F  04 03 05 03 03 03                 DB      4,3,5,3,3,3,3,13,3,-5
      03 00 03 FB
0CA9  04 03 05 03 03 03                 DB      4,3,5,3,3,3,3,1,5,1,3,3,-5
      03 03 01 05 01 03
      03 FB
0CB7  02 07 01 0B 01 05                 DB      2,7,1,11,1,5,2,3,2,5,1,-5
      02 03 02 05 01 FB
0CC3  02 07 01 0A 02 05                 DB      2,7,1,10,2,5,3,1,3,5,1,-5
      03 01 03 05 01 FB
0CCF  02 07 01 09 03 05                 DB      2,7,1,9,3,5,7,5,1,-5
      07 05 01 FB
0CD9  28 FB                             DB      40,-5
0CDB  28 FC                             DB      40,-4
0CDD  02                        COLOR   DB      COLOR_E - COLOR
0CDE  DB                                DB      219
= 0CDF                          COLOR_E =       $
0CDF  02 77 02 77 02 77                 DB      2,121-2,2,121-2,2,121-2,2,121-2,2,-4
      02 77 02 FC

                                        ASSUME  DS:DATA
; --------------------------------------------------------------------------------------------------
; A-029
; --------------------------------------------------------------------------------------------------
                                ;--- INT 10 -------------------------------------------------------------
                                ; VIDEO_IO
                                ;       THESE ROUTINES PROVIDE THE CRT INTERFACE
                                ;       THE FOLLOWING FUNCTIONS ARE PROVIDED:
                                ;       (AH)=0  SET MODE (AL) CONTAINS MODE VALUE
                                ;               (AL)=0  40X25 BW (POWER ON DEFAULT)
                                ;               (AL)=1  40X25 COLOR
                                ;               (AL)=2  80X25 BW
                                ;               (AL)=3  80X25 COLOR
                                ;       GRAPHICS MODES
                                ;               (AL)=4  320X200 4 COLOR
                                ;               (AL)=5  320X200 BW 4 SHADES
                                ;               (AL)=6  640X200 BW 2 SHADES
                                ;               (AL)=7  NOT VALID
                                ;       **** EXTENDED MODES ***
                                ;               (AL)=8   160X200 16 COLOR
                                ;               (AL)=9   320X200 16 COLOR
                                ;               (AL)=A   640X200 4 COLOR
                                ;       *** NOTE BW MODES OPERATE SAME AS COLOR MODES, BUT
                                ;               COLOR BURST IS NOT ENABLED
                                ;       *** NOTE IF HIGH ORDER BIT IN AL IS SET, THE REGEN
                                ;               BUFFER IS NOT CLEARED.
                                ;
                                ;       (AH)=1  SET CURSOR TYPE
                                ;               (CH) = BITS 4-0 = START LINE FOR CURSOR
                                ;                     ** HARDWARE WILL ALWAYS CAUSE BLINK
                                ;                     ** SETTING BIT 5 OR 6 WILL CAUSE ERRATIC
                                ;                        BLINKING OR NO CURSOR AT ALL
                                ;                     ** IN GRAPHICS MODES, BIT 5 IS FORCED ON TO
                                ;                        DISABLE THE CURSOR
                                ;               (CL) = BITS 4-0 = END LINE FOR CURSOR
                                ;       (AH)=2  SET CURSOR POSITION
                                ;               (DH,DL) = ROW,COLUMN (0,0) IS UPPER LEFT
                                ;               (BH) = PAGE NUMBER (MUST BE 0 FOR GRAPHICS MODES)
                                ;       (AH)=3  READ CURSOR POSITION
                                ;               (BH) = PAGE NUMBER (MUST BE 0 FOR GRAPHICS MODES).
                                ;               ON EXIT, (DH,DL) = ROW,COLUMN OF CURRENT CURSOR
                                ;                         (CH,CL) = CURSOR MODE CURRENTLY SET
                                ;
                                ;       (AH)=4  READ LIGHT PEN POSITION
                                ;               ON EXIT:
                                ;               (AH) = 0 -- LIGHT PEN SWITCH NOT DOWN/NOT TRIGGERED
                                ;               (AH) = 1 -- VALID LIGHT PEN VALUE IN REGISTERS
                                ;               (DH,DL) = ROW,COLUMN OF CHARACTER LP POSN
                                ;               (CH) = RASTER LINE (0-199)
                                ;               (BX) = PIXEL COLUMN (0-319,639)
                                ;
                                ;       (AH)=5  SELECT ACTIVE DISPLAY PAGE (VALID ONLY FOR
                                ;               ALPHA MODES)
                                ;               (AL)=NEW PAGE VALUE (0-7 FOR MODES 0&1, 0-3 FOR
                                ;               MODES 2&3)
                                ;               IF BIT 7 (80H) OF AL=1
                                ;                       READ/WRITE CRT/CPU PAGE REGISTERS
                                ;                       (AL) = 80H READ CRT/CPU PAGE REGISTERS
                                ;                       (AL) = 81H SET CPU PAGE REGISTER
                                ;                               (BL) = VALUE TO SET
                                ;                       (AL) = 82H SET CRT PAGE REGISTER
                                ;                               (BH) = VALUE TO SET
                                ;                       (AL) = 83H SET BOTH CRT AND CPU PAGE REGISTERS
                                ;                               (BL) = VALUE TO SET IN CPU PAGE REGISTER
                                ;                               (BH) = VALUE TO SET IN CRT PAGE REGISTER
                                ;               IF BIT 7 (80H) OF AL=1
                                ;                       ALWAYS RETURNS  (BH) = CONTENTS OF CRT PAGE REG
                                ;                                       (BL) = CONTENTS OF CPU PAGE REG
                                ;
                                ;       (AH)=6  SCROLL ACTIVE PAGE UP
                                ;               (AL) = NUMBER OF LINES, INPUT LINES BLANKED AT
                                ;                       BOTTOM OF WINDOW, AL = 0 MEANS BLANK
                                ;                       ENTIRE WINDOW
                                ;               (CH,CL) = ROW,COLUMN OF UPPER LEFT CORNER OF
                                ;                       SCROLL
                                ;               (DH,DL) = ROW,COLUMN OF LOWER RIGHT CORNER OF
                                ;                       SCROLL
                                ;               (BH) = ATTRIBUTE TO BE USED ON BLANK LINE
                                ;       (AH)=7  SCROLL ACTIVE PAGE DOWN
                                ;               (AL) = NUMBER OF LINES, INPUT LINES BLANKED AT TOP
                                ;                       OF WINDOW, AL=0 MEANS BLANK ENTIRE WINDOW
                                ;               (CH,CL) = ROW,COLUMN OF UPPER LEFT CORNER OF
                                ;                       SCROLL
                                ;               (DH,DL) = ROW,COLUMN OF LOWER RIGHT CORNER OF
                                ;                       SCROLL
                                ;               (BH) = ATTRIBUTE TO BE USED ON BLANK LINE
                                ;
                                ;       CHARACTER HANDLING ROUTINES
                                ;       (AH) = 8 READ ATTRIBUTE/CHARACTER AT CURRENT CURSOR POSITION
                                ;               (BH) = DISPLAY PAGE (VALID FOR ALPHA MODES ONLY)
                                ;               ON EXIT:
                                ;               (AL) = CHAR READ
                                ;               (AH) = ATTRIBUTE OF CHARACTER READ (ALPHA MODES
                                ;                       ONLY)
                                ;
                                ;       (AH) = 9 WRITE ATTRIBUTE/CHARACTER AT CURRENT CURSOR
                                ;               POSITION
                                ;               (BH) = DISPLAY PAGE (VALID FOR ALPHA MODES ONLY)
                                ;               (CX) = COUNT OF CHARACTERS TO WRITE
                                ;               (AL) = CHAR TO WRITE
                                ;               (BL) = ATTRIBUTE OF CHARACTER (ALPHA)/COLOR OF
                                ;                       CHARACTER (GRAPHICS). SEE NOTE ON WRITE
                                ;                       DOT FOR BIT 7 OF BL = 1.
                                ;
                                ;       (AH) = 10 (0AH) WRITE CHARACTER ONLY AT CURRENT CURSOR
                                ;               POSITION
                                ;               (BH) = DISPLAY PAGE (VALID FOR ALPHA MODES ONLY)
                                ;               (CX) = COUNT OF CHARACTERS TO WRITE
                                ;               (AL) = CHAR TO WRITE
                                ;               (BL) = COLOR OF CHAR (GRAPHICS)
                                ;                       SEE NOTE ON WRITE DOT FOR BIT 7 OF BL = 1.
; --------------------------------------------------------------------------------------------------
; A-030
; --------------------------------------------------------------------------------------------------
                                ;       FOR READ/WRITE CHARACTER INTERFACE WHILE IN GRAPHICS MODE,
                                ;               THE CHARACTERS ARE FORMED FROM A CHARACTER
                                ;               GENERATOR IMAGE MAINTAINED IN THE SYSTEM ROM.
                                ;               INTERRUPT 44H (LOCATION 00101H) IS USED TO
                                ;               POINT TO THE 1K BYTE TABLE CONTAINING THE
                                ;               FIRST 128 CHARS (0-127).
                                ;               INTERRUPT 1FH (LOCATION 0007CH) IS USED TO
                                ;               POINT TO THE 1K BYTE TABLE CONTAINING THE SECOND
                                ;               128 CHARS (128-255).
                                ;       FOR WRITE CHARACTER INTERFACE IN GRAPHICS MODE, THE
                                ;               REPLICATION FACTOR CONTAINED IN (CX) ON ENTRY WILL
                                ;               PRODUCE VALID RESULTS ONLY FOR CHARACTERS
                                ;               CONTAINED ON THE SAME ROW. CONTINUATION TO
                                ;               SUCCEEDING LINES WILL NOT PRODUCE CORRECTLY.
                                ;
                                ;       GRAPHICS INTERFACE
                                ;       (AH) = 11 (0BH) SET COLOR PALETTE
                                ;               (BH) = PALETTE COLOR ID BEING SET (0-127)
                                ;               (BL) = COLOR VALUE TO BE USED WITH THAT COLOR ID
                                ;                       COLOR 1D = 0 SELECTS THE BACKGROUND
                                ;                       COLOR (0-15)
                                ;                       COLOR ID = 1 SELECTS THE PALETTE TO BE
                                ;                          USED:
                                ;                          2 COLOR MODE:
                                ;                               0 = WHITE FOR COLOR 1
                                ;                               1 = BLACK FOR COLOR 1
                                ;                          4 COLOR MODES:
                                ;                               0 = GREEN, RED, BROWN FOR
                                ;                                   COLORS 1,2,3
                                ;                               1 = CYAN, MAGENTA, WHITE FOR
                                ;                                    COLORS 1,2,3
                                ;                          16 COLOR MODES:
                                ;                               ALWAYS SETS UP PALETTE AS:
                                ;                               BLUE FOR COLOR 1
                                ;                               GREEN FOR COLOR 2
                                ;                               CYAN FOR COLOR 3
                                ;                               RED FOR COLOR 4
                                ;                               MAGENTA FOR COLOR 5
                                ;                               BROWN FOR COLOR 6
                                ;                               LIGHT GRAY FOR COLOR 7
                                ;                               DARK GRAY FOR COLOR 8
                                ;                               LIGHT BLUE FOR COLOR 9
                                ;                               LIGHT GREEN FOR COLOR 10
                                ;                               LIGHT CYAN FOR COLOR 11
                                ;                               LIGHT RED FOR COLOR 12
                                ;                               LIGHT MAGENTA FOR COLOR 13
                                ;                               YELLOW FOR COLOR 14
                                ;                               WHITE FOR COLOR 15
                                ;               IN 40X25 OR 80X25 ALPHA MODES, THE VALUE SET
                                ;                      FOR PALETTE COLOR 0 INDICATES THE BORDER
                                ;                      COLOR TO BE USED. IN GRAPHIC MODES, IT
                                ;                      INDICATES THE BORDER COLOR AND THE
                                ;                      BACKGROUND COLOR.
                                ;
                                ;       (AH) = 12 (0CH) WRITE DOT
                                ;               (DX) = ROW NUMBER
                                ;               (CX) = COLUMN NUMBER
                                ;               (AL) = COLOR VALUE
                                ;                  IF BIT 7 OF AL = 1, THEN THE COLOR VALUE IS
                                ;                  EXCLUSIVE OR'D WITH THE CURRENT CONTENTS OF
                                ;                  THE DOT
                                ;       (AH) = 13 (0DH) READ DOT
                                ;               (DX) = ROW NUMBER
                                ;               (CX) = COLUMN NUMBER
                                ;               (AL) RETURNS THE DOT READ
                                ;
                                ;       ASCII TELETYPE ROUTINE FOR OUTPUT
                                ;       (AH) = 14 (0EH) WRITE TELETYPE TO ACTIVE PAGE
                                ;               (AL) = CHAR TO WRITE
                                ;               (BL) = FOREGROUND COLOR IN GRAPHICS MODE
                                ;               NOTE -- SCREEN WIDTH IS CONTROLLED BY PREVIOUS
                                ;               MODE SET
                                ;       (AH) = 15 (0FH) CURRENT VIDEO STATE
                                ;               RETURNS THE CURRENT VIDEO STATE
                                ;               (AL) = MODE CURRENTLY SET (SEE AH=0 FOR
                                ;                      EXPLANATION)
                                ;               (AH) = NUMBER OF CHARACTER COLUMNS ON SCREEN
                                ;               (BH) = CURRENT ACTIVE DISPLAY PAGE
                                ;       (AH) = 16 (10H) SET PALETTE REGISTERS
                                ;               (AL) = 0 SET PALETTE REGISTER
                                ;                       (BL) = PALETTE REGISTER TO SET (00H - 0FH)
                                ;                       (BH) = VALUE TO SET
                                ;               (AL) = 1 SET BORDER COLOR REGISTER
                                ;                       (BH) = VALUE TO SET
                                ;               (AL) = 2 SET ALL PALETTE REGISTERS AND BORDER
                                ;                       REGISTER
                                ;                       ES:DX POINTS TO A 17 BYTE LIST
                                ;                       BYTES 0 THRU 15 ARE VALUES FOR PALETTE
                                ;                               REGISTERS 0 THRU 15
                                ;                       BYTE 16 IS THE VALUE FOR THE BORDER
                                ;                               REGISTER
                                ;
                                ;       NOTE:
                                ;       IN MODES USING A 32K REGEN (9 AND A), ACCESS THROUGH THE CPU
                                ;       REGISTER BY USE OF B800H SEGMENT VALUE ONLY REACHES THE
                                ;       FIRST 16K. BIOS USES THE CONTENTS OF THE CPU PAGE REG
                                ;       (BITS 3,4, & 5 OF PAGDAT IN BIOS DATA AREA) TO DERIVE THE
                                ;       PROPER SEGMENT VALUE.
                                ;
                                ;       CS,SS,DS,ES,BX,CX,DX PRESERVED DURING CALL
                                ;       ALL OTHERS DESTROYED
; --------------------------------------------------------------------------------------------------
; A-31
; --------------------------------------------------------------------------------------------------
                                ; --------------------------------------------
                                ; VIDEO GATE ARRAY REGISTERS
                                ; --------------------------------------------
                                ; PORT 3DA OUTPUT
                                ;       REG 0   MODE CONTROL 1 REGISTER
                                ;       01H     +HI BANDWIDTH/-LOW BANDWIDTH
                                ;       02H     +GRAPHICS/-ALPHA
                                ;       04H     +B&W
                                ;       08H     +VIDEO ENABLE
                                ;       10H     +16 COLOR GRAPHICS
                                ;
                                ;       REG 1   PALETTE MASK REISTER
                                ;       01H     PALETTE MASK 0
                                ;       02H     PALETTE MASK 1
                                ;       04H     PALETTE MASK 2
                                ;       08H     PALETTE MASK 3
                                ;
                                ;       REG 2   BORDER COLOR REGISTER
                                ;       01H     BLUE
                                ;       02H     GREEN
                                ;       04H     RED
                                ;       08H     INTENSITY
                                ;
                                ;       REG 3   MODE CONTROL 2 REGISTER
                                ;       01H     RESERVED -- MUST BE ZERO
                                ;       02H     +ENABLE BLINK
                                ;       04H     RESERVED -- MUST BE ZERO
                                ;       08H     +2 COLOR GRAPHICS (640X200 2 COLOR ONLY)
                                ;
                                ;       REG 4   RESET REGISTER
                                ;       01H     +ASYNCHRONOUS RESET
                                ;       02H     +SYNCHRONOUS RESET
                                ;
                                ;       REGS 10 TO 1F     PALETTE REGISTERS
                                ;       01H     BLUE
                                ;       02H     GREEN
                                ;       04H     RED
                                ;       08H     INTENSITY
                                ;
                                ; VIDEO GATE ARRAY STATUS
                                ;       PORT 3DA INPUT
                                ;       01H     +DISPLAY ENABLE
                                ;       02H     +LIGHT PEN TRIGGER SET
                                ;       04H     -LIGHT PEN SWITCH MADE
                                ;       08H     +VERTICAL RETRACE
                                ;       10H     +VIDEO DOTS
                                        ASSUME  CS:CODE,DS:DATA,ES:VIDEO_RAM
0CE9                            M0010   LABEL   WORD    ;  TABLE OF ROUTINES WITHIN VIDEO I/O
0CE9  0DA5 R                            DW      OFFSET  SET_MODE
0CEB  E45E R                            DW      OFFSET  SET_CTYPE
0CED  E488 R                            DW      OFFSET  SET_CPOS
0CEF  E52D R                            DW      OFFSET  READ_CURSOR
0CF1  F751 R                            DW      OFFSET  READ_LPEN
0CF3  E4B3 R                            DW      OFFSET  ACT_DISP_PAGE
0CF5  E5D3 R                            DW      OFFSET  SCROLL_UP
0CF7  E63F R                            DW      OFFSET  SCROLL_DOWN
0CF9  F0E4 R                            DW      OFFSET  READ_AC_CURRENT
0CFB  F113 R                            DW      OFFSET  WRITE_AC_CURRENT
0CFD  F12C R                            DW      OFFSET  WRITE_C_CURRENT
0CFF  E543 R                            DW      OFFSET  SET_COLOR
0D01  F187 R                            DW      OFFSET  WRITE_DOT
0D03  F146 R                            DW      OFFSET  READ_DOT
0D05  1992 R                            DW      OFFSET  WRITE_TTY
0D07  E5B1 R                            DW      OFFSET  VIDEO_STATE
0D09  E685 R                            DW      OFFSET  SET_PALLETTE
= 0022
                                M0010L  EQU     $-M0010

0D0B                            VIDEO_IO        PROC    NEAR
0D0B  FB                                STI                     ; INTERRUPTS BACK ON
0D0C  FC                                CLD                     ; SET DIRECTION FORWARD
0D0D  06                                PUSH    ES              ; SAVE SEGMENT REGISTERS
0D0E  1E                                PUSH    DS
0D0F  52                                PUSH    DX
0D10  51                                PUSH    CX
0D11  53                                PUSH    BX
0D12  56                                PUSH    SI
0D13  57                                PUSH    DI
0D14  50                                PUSH    AX              ; SAVE AX VALUE
0D15  8A C4                             MOV     AL,AH           ; GET INTO LOW BYTE
0D17  32 E4                             XOR     AH,AH           ; ZERO TO HIGH BYTE
0D19  D1 E0                             SAL     AX,1            ; *2 FOR TABLE LOOKUP
0D1B  8B F0                             MOV     SI,AX           ; PUT INTO SI FOR BRANCH
0D1D  3D 0022                           CMP     AX,M0010L       ; TEST FOR WITHIN RANGE
0D20  72 04                             JB      C1              ; BRANCH AROUND BRANCH
0D22  58                                POP     AX              ; THROW AWAY THE PARAMETER
0D23  E9 0F70 R                         JMP     VIDEO_RETURN    ; DO NOTHING IF NOT IN RANGE
0D26  E8 138B R C1:                     CALL    DDS
0D29  B8 B800                           MOV     AX,0B800H       ; SEGMENT FOR COLOR CARD
0D2C  80 3E 0049 R 09                   CMP     CRT_MODE,9      ; IN MODE USING 32K REGEN
0D31  72 09                             JC      C2              ; NO,JUMP
0D33  8A 26 008A R                      MOV     AH,PAGDAT       ; GET COPY OF PAGE REGS
0D37  80 E4 38                          AND     AH,CPUREG       ; ISOLATE CPU REG
0D3A  D0 EC                             SHR     AH,1            ; SHIFT TO MAKE INTO SEGMENT VALUE
0D3C  8E C0 C2:                         MOV     ES,AX           ; SET UP TO POINT AT VIDEO RAM AREA
0D3E  58                                POP     AX              ; RECOVER VALUE
0D3F  8A 26 0049 R                      MOV     AH,CRT_MODE     ; GET CURRENT MODE INTO AH
0D43  2E: FF A4 0CE9 R                  JMP     WORD PTR CS:[SI+OFFSET M0010]
0D48                            VIDEO_IO ENDP
; --------------------------------------------------------------------------------------------------
; A-32
; --------------------------------------------------------------------------------------------------
                                ;-------------------------------------------------
                                ; SET_MODE
                                ;
                                ;       THIS ROUTINE INITIALIZES THE ATTACHMENT TO
                                ;       THE SELECTED MODE.  THE SCREEN IS BLANKED.
                                ;
                                ; INPUT      (AL) = MODE SELECTED (RANGE 0-8)
                                ;
                                ; OUTPUT
                                ;       NONE
                                ;-------------------------------------------------
0D48                            M0050   LABEL   WORD            ; TABLE OF REGEN LENGTHS
0D48  0800                              DW      2048            ; MODE 0 40X25 BW
0D4A  0800                              DW      2048            ; MODE 1 40X25 COLOR
0D4C  1000                              DW      4096            ; MODE 2 80X25 BW
0D4E  1000                              DW      4096            ; MODE 3 80X25 COLOR
0D50  4000                              DW      16384           ; MODE 4 320X200 4 COLOR
0D52  4000                              DW      16384           ; MODE 5 320X200 4 COLOR
0D54  4000                              DW      16384           ; MODE 6 640X200 BW
0D56  4000                              DW      0               ; MODE 7 INVALID
0D58  4000                              DW      16384           ; MODE 8 160X200 16 COLOR
0D5A  8000                              DW      32768           ; MODE 9 320X200 16 COLOR
0D5C  8000                              DW      32768           ; MODE A 640X200 4 COLOR
                                ;------- COLUMNS
                                M0060   LABEL   BYTE
0D5E  28 28 50 50 28 28                 DB      40,40,80,80,40,40,80,0,20,40,80
      50 00 14 28 50
                                ;------- TABLE OF GATE ARRAY PARAMETERS FOR MODE SETTING
0D69                            M0070   LABEL   BYTE
                                ;------- SET UP FOR 40X25 BW            MODE 0
0D69  0C 0F 00 02                       DB      0CH,0FH,0,2     ; GATE ARRAY PARMS
= 0004                          M0070L  EQU     $-M0070
                                ;------- SET UP FOR 40X25 COLOR         MODE 1
0D6D  08 0F 00 02                       DB      08H,0FH,0,2     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 80X25 BW            MODE 2
0D71  0D 0F 00 02                       DB      0DH,0FH,0,2     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 80X25 COLOR         MODE 3
0D75  09 0F 00 02                       DB      09H,0FH,0,2     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 320X200 4 COLOR     MODE 4
0D79  0A 03 00 00                       DB      0AH,03H,0,0     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 320X200 BW          MODE 5
0D7D  0E 03 00 00                       DB      0EH,03H,0,0     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 640X200 BW          MODE 6
0D81  0E 01 00 08                       DB      0EH,01H,0,8     ; GATE ARRAY PARMS
                                ;------- SET UP FOR INVALID             MODE 7
0D85  00 00 00 00                       DB      00H,00H,0,0     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 160X200 16 COLOR    MODE 8
0D89  1A 0F 00 00                       DB      1AH,0FH,0,0     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 320X200 16 COLOR    MODE 9
0D8D  1B 0F 00 00                       DB      1BH,0FH,0,0     ; GATE ARRAY PARMS
                                ;------- SET UP FOR 640X200 4 COLOR     MODE A
0D91  0B 03 00 00                       DB      0BH,03H,0,0     ; GATE ARRAY PARMS
                                ;----------------- TABLES OF PALETTE COLORS FOR 2 AND 4 COLOR MODES
                                ;------- 2 COLOR, SET 0
                                M0072   LABEL   BYTE
0D95  00 0F 00 00                       DB      0,0FH,0,0
= 0004                          M0072L  EQU     $-M0072         ;ENTRY LENGTH
                                ;------- 2 COLOR, SET 1
0D99  0F 00 00 00                       DB      0FH,0,0,0
                                ;------- 4 COLOR, SET 0
                                M0074   LABEL   BYTE
0D9D  00 02 04 06                       DB      0,2,4,6
                                ;------- 4 COLOR, SET 1
                                M0075   LABEL   BYTE
0DA1  00 03 05 0F                       DB      0,3,5,0FH
0DA5                            SET_MODE PROC    NEAR           ;SAVE INPUT MODE ON STACK
0DA5  50                                PUSH    AX
0DA6  24 7F                             AND     AL,7FH          ;REMOVE CLEAR REGEN SWITCH
0DA8  3C 07                             CMP     AL,7            ;CHECK FOR VALID MODES
0DAA  74 04                             JE      C3              ;MODE 7 IS INVALID
0DAC  3C 0B                             CMP     AL,0BH
0DAE  72 02                             JC      C4              ;GREATER THAN A IS INVALID
0DB0  B0 00                     C3:     MOV     AL,0            ;DEFAULT TO MODE 0
0DB2  3C 02                     C4:     CMP     AL,2            ;CHECK FOR MODES NEEDING 128K
0DB4  74 08                             JE      C5
0DB6  3C 03                             CMP     AL,3
0DB8  74 04                             JE      C5
0DBA  3C 09                             CMP     AL,09H
0DBC  72 0A                             JC      C6
0DBE  81 3E 0015 R 0080         C5:     CMP     TRUE_MEM,128    ;DO WE HAVE 128K?
0DC4  73 02                             JNC     C6              ;YES, JUMP
0DC6  B0 00                             MOV     AL,0            ;NO, DEFAULT TO MODE 0
0DC8  BA 03D4                   C6:     MOV     DX,03D4H        ; ADDRESS OF COLOR CARD
0DCB  8A E0                             MOV     AH,AL           ; SAVE MODE IN AH
0DCD  A2 0049 R                         MOV     CRT_MODE,AL     ; SAVE IN GLOBAL VARIABLE
0DD0  89 16 0063 R                      MOV     ADDR_6845,DX    ; SAVE ADDRESS OF BASE
0DD4  8B F8                             MOV     DI,AX           ; SAVE MODE IN DI
0DD6  BA 03DA                           MOV     DX,VGA_CTL      ; POINT TO CONTROL REGISTER
0DD9  EC                                IN      AL,DX           ; SYNC CONTROL REG TO ADDRESS
0DDA  32 C0                             XOR     AL,AL           ; SET VGA REG 0
0DDC  EE                                OUT     DX,AL           ; SELECT IT
0DDD  A0 0065 R                         MOV     AL,CRT_MODE_SET ; GET LAST MODE SET
0DE0  24 F7                             AND     AL,0F7H         ; TURN OFF VIDEO
0DE2  EE                                OUT     DX,AL           ; SET IN GATE ARRAY
; --------------------------------------------------------------------------------------------------
; A-33
; --------------------------------------------------------------------------------------------------
                                ; SET DEFAULT PALETTES
0DE3  8B C7                             MOV     AX,DI           ; GET MODE
0DE5  B4 10                             MOV     AH,10H          ; SET PALETTE REG 0
0DE7  BB 0D95 R                         MOV     BX,OFFSET M0072 ; POINT TO TABLE ENTRY
0DEA  3C 06                             CMP     AL,6            ; 2 COLOR MODE?
0DEC  74 0F                             JE      C7              ; YES, JUMP
0DEE  BB 0DA1 R                         MOV     BX,OFFSET M0075 ; POINT TO TABLE ENTRY
0DF1  3C 05                             CMP     AL,5            ; CHECK FOR 4 COLOR MODE
0DF3  74 08                             JE      C7              ; YES, JUMP
0DF5  3C 04                             CMP     AL,4            ; CHECK FOR 4 COLOR MODE
0DF7  74 04                             JE      C7              ; YES JUMP
0DF9  3C 0A                             CMP     AL,0AH          ; CHECK FOR 4 COLOR MODE
0DFB  75 11                             JNE     C9              ; NO, JUMP
0DFD  B9 0004                   C7:     MOV     CX,4            ; NUMBER OF REGS TO SET
0E00  8A C4                     C8:     MOV     AL,AH           ; GET REG NUMBER
0E02  EE                                OUT     DX,AL           ; SELECT IT
0E03  2E: 8A 07                         MOV     AL,CS:[BX]      ; GET DATA
0E06  EE                                OUT     DX,AL           ; SET IT
0E07  FE C4                             INC     AH              ; NEXT REG
0E09  43                                INC     BX              ; NEXT TABLE VALUE
0E0A  E2 F4                             LOOP    C8
0E0C  EB 0B                             JMP     SHORT C11
                                ;----- SET PALETTES FOR DEFAULT 16 COLOR 
0E0E  B9 0010                   C9:     MOV     CX,16           ; NUMBER OF PALETTES, AH IS REG
                                                                ; COUNTER
0E11  8A C4                     C10:    MOV     AL,AH           ; GET REG NUMBER
0E13  EE                                OUT     DX,AL           ; SELECT IT
0E14  EE                                OUT     DX,AL           ; SET PALETTE VALUE
0E15  FE C4                             INC     AH              ; NEXT REG
0E17  E2 F8                             LOOP    C10
                                ;----- SET UP M0 & M1 in PAGREG
0E19  8B C7                     C11:    MOV     AX,DI           ; GET CURRENT MODE
0E1B  32 DB                             XOR     BL,BL           ; SET UP FOR ALPHA MODE
0E1D  3C 04                             CMP     AL,4            ; IN ALPHA MODE
0E1F  72 08                             JC      C12             ; YES, JUMP
0E21  B3 40                             MOV     BL,40H          ; SET UP FOR 16K REGEN
0E23  3C 09                             CMP     AL,09H          ; MODE USE 16K
0E25  72 02                             JC      C12             ; YES, JUMP
0E27  B3 C0                             MOV     BL,0C0H         ; SET UP FOR 32K REGEN
0E29  BA 03DF                   C12:    MOV     DX,PAGREG       ; SET PORT ADDRESS OF PAGREG
0E2C  A0 008A R                         MOV     AL,PAGDAT       ; GET LAST DATA OUTPUT
0E2F  24 3F                             AND     AL,3FH          ; CLEAR M0 & M1 BITS
0E31  0A C3                             OR      AL,BL           ; SET NEW BITS
0E33  EE                                OUT     DX,AL           ; STUFF BACK IN PORT
0E34  A2 008A R                         MOV     PAGDAT,AL       ; SAVE COPY IN RAM
                                ;----- ENABLE VIDEO AND CORRECT PORT SETTING
0E37  8B C7                             MOV     AX,DI           ; GET CURRENT MODE
0E39  32 E4                             XOR     AH,AH           ; INTO AX REG
0E3B  B9 0004                           MOV     CX,M0070L       ; SET TABLE ENTRY LENGTH
0E3E  F7 E1                             MUL     CX              ; TIMES MODE FOR OFFSET INTO TABLE
0E40  8B D8                             MOV     BX,AX           ; TABLE OFFSET IN BX
0E42  81 C3 0D69 R                      ADD     BX,OFFSETM0070  ; ADD TABLE START TO OFFSET
0E46  2E: 8A 27                         MOV     AH,CS:[BX]      ; SAVE MODE SET AND PALETTE
0E49  2E: 8A 47 02                      MOV     AL,CS:[BX + 2]  ; TILL WE CAN PUT THEM IN RAM
0E4D  8B F0                             MOV     SI,AX
0E4F  FA                                CLI                     ; DISABLE INTERRUPTS
0E50  E8 E675 R                         CALL    MODE_ALIVE      ; KEEP MEMORY DATA VALID
0E53  B0 10                             MOV     AL,10H          ; DISABLE NMI AND HOLD REQUEST
0E55  E6 A0                             OUT     NMI_PORT,AL     ;
0E57  BA 03DA                           MOV     DX,VGA_CTL      ;
0E5A  B0 04                             MOV     AL,4            ; POINT TO RESET REG
0E5C  EE                                OUT     DX,AL           ; SEND TO GATE ARRAY
0E5D  B0 02                             MOV     AL,2            ; SET SYNCHRONOUS RESET
0E5F  EE                                OUT     DX,AL           ; DO IT
                                ; WHILE GATE ARRAY IS IN RESET STATE, WE CANNOT ACCESS RAM
0E60  8B C6                             MOV     AX,SI           ; RESTORE NEW MODE SET
0E62  80 E4 F7                          AND     AH,0F7H         ; TURN OFF VIDEO ENABLE
0E65  32 C0                             XOR     AL,AL           ; SET UP TO SELECT VGA REG 0
0E67  EE                                OUT     DX,AL           ; SELECT IT
0E68  86 E0                             XCHG    AH,AL           ; AH IS VGA REG COUNTER
0E6A  EE                                OUT     DX,AL           ; SET MODE
0E6B  B0 04                             MOV     AL,4            ; SET UP TO SELECT VGA REG 4
0E6D  EE                                OUT     DX,AL           ; SELECT IT
0E6E  32 C0                             XOR     AL,AL           ;
0E70  EE                                OUT     DX,AL           ; REMOVE RESET FROM VGA
                                ; NOW OKAY TO ACCESS RAM AGAIN
0E71  B0 80                             MOV     AL,80H          ; ENABLE NMI AGAIN
0E73  E6 A0                             OUT     NMI_PORT,AL     ;
0E75  E8 E675 R                         CALL    MODE_ALIVE      ; KEEP MEMORY DATA VALID
0E78  FB                                STI                     ; ENABLE INTERRUPTS
0E79  EB 07                             JMP     SHORT C14
0E7B  8A C4                     C13:    MOV     AL,AH           ; GET VGA REG NUMBER
0E7D  EE                                OUT     DX,AL           ; SELECT REG
0E7E  2E: 8A 07                         MOV     AL,CS:[BX]      ; GET TABLE VALUE
0E81  EE                                OUT     DX,AL           ; PUT IN VGA REG
0E82  43                                INC     BX              ; NEXT IN TABLE
0E83  FE C4                     C14:    INC     AH              ; NEXT REG
0E85  E2 F4                             LOOP    C13             ; DO ENTIRE ENTRY
                                ;---- SET UP CRT AND CPU PAGE REGS ACCORDING TO MODE & MEMORY SIZE
0E87  BA 03DF                           MOV     DX,PAGREG       ; SET IO ADDRESS OF PAGREG
0E8A  A0 008A R                         MOV     AL,PAGDAT       ; GET LAST DATA OUTPUT
0E8D  24 C0                             AND     AL,0C0H         ; CLEAR REG BITS
0E8F  B3 36                             MOV     BL,36H          ; SET UP FOR GRAPHICS MODE WITH 32K
                                                                ; REGEN
0E91  A8 80                             TEST    AL,80H          ; IN THIS MODE?
0E93  75 0C                             JNZ     C15             ; YES, JUMP
0E95  B3 3F                             MOV     BL,3FH          ; SET UP FOR 16K REGEN AND 128K
                                                                ; MEMORY
0E97  81 3E 0015 R 0080                 CMP     TRUE_MEM,128    ; DO WE HAVE 128K?
0E9D  73 02                             JNC     C15             ; YES, JUMP
0E9F  B3 1B                             MOV     BL,1BH          ; SET UP FOR 16K REGEN AND 64K
                                                                ; MEMORY
; --------------------------------------------------------------------------------------------------
; A-34
; --------------------------------------------------------------------------------------------------
0EA1  0A C3                     C15:    OR      AL,BL           ; COMBINE MODE BITS AND REG VALUES
0EA3  EE                                OUT     DX,AL           ; SET PORT
0EA4  A2 008A R                         MOV     PAGDAT,AL       ; SAVE COPY IN RAM
0EA7  8B C6                             MOV     AX,SI           ; PUT MODE SET & PALETTE IN RAM
0EA9  88 26 0065 R                      MOV     CRT_MODE_SET,AH
0EAD  A2 0066 R                         MOV     CRT_PALETTE,AL
0EB0  E4 61                             IN      AL,PORT_B       ; GET CURRENT VALUE OF 8255 PORT B
0EB2  24 FB                             AND     AL,0FBH         ; SET UP GRAPHICS MODE
0EB4  F6 C4 02                          TEST    AH,2            ; JUST SET ALPHA MODE IN VGA?
0EB7  75 02                             JNZ     C16             ; YES, JUMP
0EB9  0C 04                             OR      AL,4            ; SET UP ALPHA MODE
0EBB  E6 61                     C16:    OUT     PORT_B,AL       ; STUFF BACK IN 8255

0EBD  1E                                PUSH    DS              ; SAVE DATA SEGMENT VALUE
0EBE  33 C0                             XOR     AX,AX           ; SET UP FOR ABSO SEGMENT
0EC0  8E D8                             MOV     DS,AX           ; ESTABLISH VECTOR TABLE ADDRESSING
                                        ASSUME  DS:ABSO
0EC2  C5 1E 0074 R                      LDS     BX,PARM_PTR     ; GET POINTER TO VIDEO PARMS
                                        ASSUME  DS:CODE
0EC6  8B C7                             MOV     AX,DI           ; GET CURRENT MODE IN AX
0EC8  B9 0010 90                        MOV     CX,MO040        ; LENGTH OF EACH ROW OF TABLE
0ECC  80 FC 02                          CMP     AH,2            ; DETERMINE WHICH TO USE
0ECF  72 10                             JC      C17             ; MODE IS 0 OR 1
0ED1  03 D9                             ADD     BX,CX           ; MOVE TO NEXT ROW OF INIT TABLE
0ED3  80 FC 04                          CMP     AH,4            ; MODE IS 2 OR 3
0ED6  72 09                             JC      C17             ; MOVE TO GRAPHICS ROW OF
0ED8  03 D9                             ADD     BX,CX           ; INIT_TABLE

0EDA  80 FC 09                          CMP     AH,9            ; MODE IS 4, 5, 6, 8, OR 9
0EDD  72 02                             JC      C17             ; MOVE TO NEXT GRAPHICS ROW OF
0EDF  03 D9                             ADD     BX,CX           ; INIT_TABLE

0EE1  50                        C17:    PUSH    AX              ; SAVE MODE IN AH
0EE2  8A 47 02                          MOV     AL,DS:[BX+2]    ; GET HORZ. SYNC POSITION
0EE5  8B 7F 0A                          MOV     DI,WORD PTR DS:[BX+10] ; GET CURSOR TYPE
0EE8  1E                                PUSH    DS
0EE9  E8 138B R                         CALL    DDS
                                        ASSUME  DS:DATA
0EEC  A2 0089 R                         MOV     HORZ_POS,AL     ; SAVE HORZ. SYNC POSITION VARIABLE
0EEF  89 3E 0060 R                      MOV     CURSOR_MODE,DI  ; SAVE CURSOR MODE
0EF3  50                                PUSH    AX
0EF4  A0 0086 R                         MOV     AL,VAR_DELAY    ; SET DEFAULT OFFSET
0EF7  24 0F                             AND     AL,0FH
0EF9  A2 0086 R                         MOV     VAR_DELAY,AL
0EFC  58                                POP     AX
                                        ASSUME  DS:CODE
0EFD  1F                                POP     DS
0EFE  32 E4                             XOR     AH,AH           ; AH WILL SERVE AS REGISTER NUMBER
0F00  BA 03D4                           MOV     DX,03D4H        ; POINT TO 6845
                                ;LOOP THROUGH TABLE, OUTPUTTING REG ADDRESS, THEN VALUE FROM TABLE
0F03  8A C4                     C18:    MOV     AL,AH           ; GET 6845 REGISTER NUMBER
0F05  EE                                OUT     DX,AL
0F06  42                                INC     DX              ; POINT TO DATA PORT
0F07  FE C4                             INC     AH              ; NEXT REGISTER VALUE
0F09  8A 07                             MOV     AL,[BX]         ; GET TABLE VALUE
0F0B  EE                                OUT     DX,AL           ; OUT TO CHIP
0F0C  43                                INC     BX              ; NEXT IN TABLE
0F0D  4A                                DEC     DX              ; BACK TO POINTER REGISTER
0F0E  E2 F3                             LOOP    C18             ; DO THE WHOLE TABLE
0F10  58                                POP     AX              ; GET MODE BACK
0F11  1F                                POP     DS              ; RECOVER SEGMENT VALUE
                                        ASSUME  DS:DATA
                                ;------- FILL REGEN AREA WITH BLANK
0F12  33 FF                             XOR     DI,DI           ; SET UP POINTER FOR REGEN
0F14  89 3E 004E R                      MOV     CRT_START,DI    ; START ADDRESS SAVED IN GLOBAL
0F18  C6 06 0062 R 00                   MOV     ACTIVE_PAGE,0   ; SET PAGE VALUE
0F1D  5A                                POP     DX              ; GET ORIGINAL INPUT BACK
0F1E  80 E2 80                          AND     DL,80H          ; NO CLEAR OF REGEN ?
0F21  75 1C                             JNZ     C21             ; SKIP CLEARING REGEN
0F23  BA B800                           MOV     DX,0B800H       ; SET UP SEGMENT FOR 16K REGEN AREA
0F26  B9 2000                           MOV     CX,8192         ; NUMBER OF WORDS TO CLEAR
0F29  3C 09                             CMP     AL,09H          ; REQUIRE 32K BYTE REGEN ?
0F2B  72 05                             JC      C19             ; NO, JUMP
0F2D  D1 E1                             SHL     CX,1            ; SET 16K WORDS TO CLEAR
0F2F  BA 1800                           MOV     DX,1800H        ; SET UP SEGMENT FOR 32K REGEN AREA
0F32  8E C2                     C19:    MOV     ES,DX           ; SET REGEN SEGMENT
0F34  3C 04                             CMP     AL,4            ; TEST FOR GRAPHICS
0F36  B8 0F20                           MOV     AX,' '+15*256   ; FILL CHAR FOR ALPHA
0F39  72 02                             JC      C20             ; NO_GRAPHICS_INIT
0F3B  33 C0                             XOR     AX,AX           ; FILL FOR GRAPHICS MODE
0F3D  F3/ AB                    C20:    REP     STOSW           ; FILL THE REGEN BUFFER WITH BLANKS
                                ;----- ENABLE VIDEO
0F3F  BA 03DA                   C21:    MOV     DX,VGA_CTL      ; SET PORT ADDRESS OF VGA
0F42  32 C0                             XOR     AL,AL
0F44  EE                                OUT     DX,AL           ; SELECT VGA REG 0
0F45  A0 0065 R                         MOV     AL,CRT_MODE_SET ; GET MODE SET VALUE
0F48  EE                                OUT     DX,AL           ; SET MODE
                                ;------- DETERMINE NUMBER OF COLUMNS, BOTH FOR ENTIRE DISPLAY
                                ;------- AND THE NUMBER TO BE USED FOR TTY INTERFACE
0F49  32 FF                             XOR     BH,BH
0F4B  8A 1E 0049 R                      MOV     BL,CRT_MODE
0F4F  2E: 8A 87 005E R                  MOV     AL,CS:[BX + OFFSET M0060]
0F54  32 E4                             XOR     AH,AH
0F56  A3 004A R                         MOV     CRT_COLS,AX     ; NUMBER OF COLUMNS IN THIS SCREEN
; --------------------------------------------------------------------------------------------------
; A-35
; --------------------------------------------------------------------------------------------------
                                ;------ SET CURSOR POSITIONS
0F59  D1 E3                             SHL     BX,1            ; WORD OFFSET INTO CLEAR LENGTH
                                ; TABLE
0F5B  2E: 8B 8F 0048 R                  MOV     CX,CS:[BX + OFFSET M0050] ; LENGTH TO CLEAR
0F60  89 0E 004C R                      MOV     CRT_LEN,CX      ; SAVE LENGTH OF CRT
0F64  B9 0008                           MOV     CX,8            ; CLEAR ALL CURSOR POSITIONS
0F67  BF 0050 R                         MOV     DI,OFFSET CURSOR_POSN
0F6A  1E                                PUSH    DS              ; ESTABLISH SEGMENT
0F6B  07                                POP     ES              ; ADDRESSING
0F6C  33 C0                             XOR     AX,AX
0F6E  F3/ AB                            REP     STOSW           ; FILL WITH ZEROES
                                ;------ NORMAL RETURN FROM ALL VIDEO RETURNS
0F70                            VIDEO_RETURN:
0F70  5F                                POP     DI
0F71  5E                                POP     SI
0F72  5B                                POP     BX
0F73  59 C22:                           POP     CX
0F74  5A                                POP     DX
0F75  1F                                POP     DS
0F76  07                                POP     ES              ; RECOVER SEGMENTS
0F77  CF                                IRET                    ; ALL DONE
0F78                            SET_MODE ENDP
                                ;--------------------------------------------------------------
                                ;
                                ; KBDNMI - KEYBOARD NMI INTERRUPT ROUTINE
                                ;
                                ;     THIS ROUTINE OBTAINS CONTROL UPON AN NMI INTERRUPT, WHICH
                                ;     OCCURS UPON A KEYSTROKE FROM THE KEYBOARD.
                                ;  
                                ;     THIS ROUTINE WILL DE-SERIALIZE THE BIT STREAM IN ORDER TO
                                ;     GET THE KEYBOARD SCAN CODE ENTERED.  IT THEN ISSUES INT 41
                                ;     PASSING THE SCAN CODE IN AL TO THE KEY PROCESSOR.  UPON RETURN
                                ;     IT RE-ENABLES NMI AND RETURNS TO SYSTEM (IRET).
                                ;
                                ;--------------------------------------------------------------
                                        ASSUME  CS:CODE,DS:DATA
0F78                            KBDNMI  PROC    FAR
                                ;---------DISABLE INTERRUPTS
0F78  FA                                CLI
                                ;---------SAVE REGS & DISABLE NMI
0F79  56                                PUSH    SI
0F7A  57                                PUSH    DI
0F7B  50                                PUSH    AX              ; SAVE REGS
0F7C  53                                PUSH    BX
0F7D  51                                PUSH    CX
0F7E  52                                PUSH    DX
0F7F  1E                                PUSH    DS
0F80  06                                PUSH    ES
                                ;---------INIT COUNTERS
0F81  BE 0008                           MOV     SI,8            ; SET UP # OF DATA BITS
0F84  32 DB                             XOR     BL,BL           ; INIT. PARITY COUNTER
                                ;---------SAMPLE 5 TIMES TO VALIDATE START BIT
0F86  32 E4                             XOR     AH,AH
0F88  B9 0005                           MOV     CX,5            ; SET COUNTER
0F8B  E4 62                     I1:     IN      AL,PORT_C       ; GET SAMPLE
0F8D  A8 40                             TEST    AL,40H          ; TEST IF 1
0F8F  74 02                             JZ      I2              ; JMP IF 0
0F91  FE C4                             INC     AH              ; KEEP COUNT OF 1'S
0F93  E2 F6                     I2:     LOOP    I1              ; KEEP SAMPLING
0F95  80 FC 03                          CMP     AH,3            ; VALID START BIT ?
0F98  73 03                             JNB     I25             ; JUMP IF OK
0F9A  EB 5D 90                          JMP     I8              ; INVALID (SYNC ERROR) NO AUDIO
                                                                ; OUTPUT
                                ;---------VALID START BIT, LOOK FOR TRAILING EDGE
0F9D  B9 0032                   I25:    MOV     CX,50           ; SET UP WATCHDOG TIMEOUT
0FA0  E4 62                     I3:     IN      AL,PORT_C       ; GET SAMPLE
0FA2  A8 40                             TEST    AL,40H          ; TEST IF 0
0FA4  74 05                             JZ      I5              ; JMP IF TRAILING EDGE FOUND
0FA6  E2 F8                             LOOP    I3              ; KEEP LOOKING FOR TRAILING EDGE
0FA8  EB 4F 90                          JMP     I8              ; SYNC ERROR (STUCK ON 1'S)
                                ;---------READ CLOCK TO SET START OF BIT TIME
0FAB  B0 40                     I5:     MOV     AL,40H          ; READ CLOCK
0FAD  E6 43                             OUT     TIM_CTL,AL      ; *
0FAF  90                                NOP                     ; *
0FB0  90                                NOP                     ; *
0FB1  E4 41                             IN      AL,TIMER+1      ; *
0FB3  8A E0                             MOV     AH,AL           ; *
0FB5  E4 41                             IN      AL,TIMER+1      ; *
0FB7  86 E0                             XCHG    AH,AL           ; *
0FB9  8B F8                             MOV     DI,AX           ; SAVE CLOCK TIME IN DI
                                ;---------VERIFY VALID TRANSITION
0FBB  B9 0004                           MOV     CX,4            ; SET COUNTER
0FBE  E4 62                     I6:     IN      AL,PORT_C       ; GET SAMPLE
0FC0  A8 40                             TEST    AL,40H          ; TEST IF 0
0FC2  75 35                             JNZ     I8              ; JMP IF INVALID TRANSITION (SYNC)
0FC4  E2 F8                             LOOP    I6              ; KEEP LOOKING FOR VALID TRANSITION
                                ;---------SET UP DISTANCE TO MIDDLE OF 1ST DATA BIT
0FC6  BA 0220                           MOV     DX,544          ; 310.USEC AWAY (.838 US / CT)
                                ;---------START LOOKING FOR TIME TO READ DATA BITS AND ASSEMBLE BYTE
0FC9  E8 1031 R                 I7:     CALL    I30
0FCC  BA 020E                           MOV     DX,526          ; SET NEW DISTANCE TO NEXT HALF BIT
0FCF  50                                PUSH    AX              ; SAVE 1ST HALF BIT
0FD0  E8 1031 R                         CALL    I30
0FD3  8A C8                             MOV     CL,AL           ; PUT 2ND HALF BIT IN CL
0FD5  58                                POP     AX              ; RESTORE 1ST HALF BIT
0FD6  3A C8                             CMP     CL,AL           ; ARE THEY OPPOSITES ?
0FD8  74 2A                             JE      I9              ; NO, PHASE ERROR
; --------------------------------------------------------------------------------------------------
; A-36
; --------------------------------------------------------------------------------------------------
                                ; ----------VALID DATA BIT, PLACE IN SCAN BYTE
0FDA  D0 EF                             SHR     BH,1            ; SHIFT PREVIOUS BITS
0FDC  0A F8                             OR      BH,AL           ; OR IN NEW DATA BIT
0FDE  4E                                DEC     SI              ; DECREMENT DATA BIT COUNTER
0FDF  75 E8                             JNZ     I7              ; CONTINUE FOR MORE DATA BITS
                                ;-----------WAIT FOR TIME TO SAMPLE PARITY BIT
0FE1  E8 1031 R                         CALL    I30             
0FE4  50                                PUSH    AX              ; SAVE 1ST HALF BIT
0FE5  E8 1031 R                         CALL    I30             ; PUT 2ND HALF BIT IN CL
0FE8  8A C8                             MOV     CL,AL           ; RESTORE 1ST HALF BIT
0FEA  58                                POP     AX              ; ARE THEY OPPOSITES ?
0FEB  3A C8                             CMP     CL,AL           ; NO, PHASE ERROR
0FED  74 15                             JE      I9
                                ;-----------VALID PARITY BIT, CHECK PARITY
0FEF  80 E3 01                          AND     BL,1            ; CHECK IF ODD PARITY
0FF2  74 10                             JZ      I9              ; JMP IF PARITY ERROR
                                ;-----------VALID CHARACTER, SEND TO CHARACTER PROCESSING
0FF4  FB                                STI                     ; ENABLE INTERRUPTS
0FF5  8A C7                             MOV     AL,BH           ; PLACE SCAN CODE IN AL
0FF7  CD 48                             INT     48H              ; CHARACTER PROCESSING                               
                                ;-----------RESTORE REGS AND RE-ENABEL NMI
0FF9  07                        I8:     POP     ES              
0FFA  1F                                POP     DS              ; RESTORE REGS
0FFB  5A                                POP     DX
0FFC  59                                POP     CX
0FFD  5B                                POP     BX
0FFE  E4 A0                             IN      AL,0A0H         ; ENABLE NMI
1000  58                                POP     AX
1001  5F                                POP     DI
1002  5E                                POP     SI
1003  CF                                IRET                    ; RETURN TO SYSTEM
                                ;-----------PARITY, SYNCH OR PHASE ERROR. OUTPUT MISSED KEY BEEP
1004  E8 138B R                 I9:     CALL    DDS             ; SETUP ADDRESSING
1007  83 FE 08                          CMP     SI,8            ; ARE WE ON THE FIRST DATA BIT?
100A  74 ED                             JE      I8              ; NO AUDIO FEEDBACK (MIGHT BE A
                                                                ; ..GLITCH)
100C  F6 06 0018 R 01                   TEST    KB_FLAG_1,01H   ; CHECK IF TRANSMISSION ERRORS
                                                                ; ..ARE TO BE REPORTED
1011  75 18                             JNZ     I10             ; 1=DO NOT BEEP, 0=BEEP
1013  BB 0080                           MOV     BX,080H         ; DURATION OF ERROR BEEP
1016  B9 0048                           MOV     CX,048H         ; FREQUENCY OF ERROR BEEP
1019  E8 E035 R                         CALL    KB_NOISE        ; AUDIO FEEDBACK
101C  80 26 0017 R F0                   AND     KB_FLAG,0F0H    ; CLEAR ALT,CLRL,LEFT AND RIGHT
                                                                ; SHIFTS
1021  80 26 0018 R 0F                   AND     KB_FLAG_1,0FH   ; CLEAR POTENTIAL BREAK OF INS,CAPS
                                                                ; NUM AND SCROLL SHIFT
1026  80 26 0088 R 1F                   AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
102B  FE 06 0012 R              I10:    INC     KBD_ERR         ; KEEP TRACK OF KEYBOARD ERRORS
102F  EB C8                             JMP     SHORT I8        ; RETURN FROM INTERRUPT
                                KBDNMI  ENDP
                                I30     PROC    NEAR
1031  B0 40                     I31:    MOV     AL,40H          ; READ CLOCK
1033  E6 43                             OUT     TIM_CTL,AL      ; *
1035  90                                NOP                     ; *
1036  90                                NOP                     ; *
1037  E4 41                             IN      AL,TIMER+1      ; *
1039  8A E0                             MOV     AH,AL           ; *
103B  E4 41                             IN      AL,TIMER+1      ; *
103D  86 E0                             XCHG    AH,AL           ; *
103F  8B CF                             MOV     CX,DI           ; GET LAST CLOCK TIME
1041  2B C8                             SUB     CX,AX           ; SUB CURRENT TIME
1043  3B CA                             CMP     CX,DX           ; IS IT TIME TO SAMPLE ?
1045  72 EA                             JC      I31             ; NO, KEEP LOOKING AT TIME
1047  2B CA                             SUB     CX,DX           ; UPDATE # OF COUNTS OFF
1049  8B F8                             MOV     DI,AX           ; SAVE CURRENT TIME AS LAST TIME
104B  03 F9                             ADD     DI,CX           ; ADD DIFFERENCE FOR NEXT TIME
                                ;-----------START SAMPLING DATA BIT (5 SAMPLES)
104D  B9 0005                           MOV     CX,5            ; SET COUNTER
                                ;-------------------------------------------------------------
                                ;
                                ; SAMPLE LINE
                                ;
                                ;       PORT_C IS SAMPLED CX TIMES AND IF THER ARE 3 OR MORE 1"S
                                ;       THEN 80H IS RETURNED IN AL, ELSE 00H IS RETURNED IN AL.
                                ;       PARITY COUNTER IS MAINTAINED IN ES.
                                ;
                                ;-------------------------------------------------------------                                
1050  32 E4                             XOR     AH,AH           ; CLEAR COUNTER
1052  E4 62                     I32:    IN      AL,PORT_C       ; GET SAMPLE
1054  A8 40                             TEST    AL,40H          ; TEST IF 1
1056  74 02                             JZ      I33             ; JMP IF 0
1058  FE C4                             INC     AH              ; KEEP COUNT OF 1'S
105A  E2 F6                     I33:    LOOP    I32             ; KEEP SAMPLING
105C  80 FC 03                          CMP     AH,3            ; VALID 1 ?
105F  72 05                             JB      I34             ; JMP IF NOT VALID 1
1061  B0 80                             MOV     AL,080H         ; RETURN 80H IN AL (1)
1063  FE C3                             INC     BL              ; INCREMENT PARITY COUNTER
1065  C3                                RET                     ; RETURN TO CALLER
1066  32 C0                     I34:    XOR     AL,AL           ; RETURN 0 IN AL (0)
1068  C3                                RET                     ; RETURN TO CALLER
1069                            I30     ENDP
; --------------------------------------------------------------------------------------------------
; A-37
; --------------------------------------------------------------------------------------------------
                                ;------------------------------------------------------------------
                                ;KEY62_INT
                                ;
                                ;       THE PURPOSE OF THIS ROUTINE IS TO TRANSLATE SCAN CODES AND
                                ;       SCAN CODE COMBINATIONS FROM THE 62 KEY KEYBOARD TO THEIR
                                ;       EQUIVILENTS ON THE 83 KEY KEYBOARD.  THE SCAN CODE IS
                                ;       PASSED IN AL.  EACH SCAN CODE PASSED EITHER TRIGGERS ONE OR
                                ;       MORE CALLS TO INTERRUPT 9 OR SETS FLAGS TO RETAIN KEYBOARD
                                ;       STATUS.  WHEN INTERRUPT 9 IS CALLED THE TRANSLATED SCAN
                                ;       CODES ARE PASSED TO IT IN AL.  THE INTENT OF THIS CODE WAS
                                ;       TO KEEP INTERRUPT 9 INTACT FROM ITS ORIGIN IN THE PC FAMILY
                                ;       THIS ROUTINE IS IN THE FRONT END OF INTERRUPT 9 AND
                                ;       TRANSFORMS A 62 KEY KEYBOARD TO LOOK AS IF IT WERE AN 83
                                ;       KEY VERSION.
                                ;  
                                ;       IT IS ASSUMED THAT THIS ROUTINE IS CALLED FROM THE NMI
                                ;       DESERIALIZATION ROUTINE AND THAT ALL REGISTERS WERE SAVED
                                ;       IN THE CALLING ROUTINE.  AS A CONSEQUENCE ALL REGISTERS ARE
                                ;       DESTROYED.
                                ;------------------------------------------------------------------
                                ;EQUATES
= 0080                          BREAK_BIT       EQU     80H
= 0054                          FN_KEY          EQU     54H
= 0055                          PHK             EQU     FN_KEY+1
= 0056                          EXT_SCAN        EQU     PHK+1   ; BASE CODE FOR SCAN CODES
                                                                ; EXTENDING BEYOND 83
= 00FF                          AND_MASK        EQU     0FFH    ; USED TO SELECTIVELY REMOVE BITS
= 001F                          CLEAR_FLAGS     EQU     AND_MASK - (FN_FLAG+FN_BREAK+FN_PENDING)
                                ; SCAN CODES
= 0030                          B_KEY           EQU     48
= 0010                          Q_KEY           EQU     16
= 0019                          P_KEY           EQU     25
= 0012                          E_KEY           EQU     18
= 001F                          S_KEY           EQU     31
= 0031                          N_KEY           EQU     49
= 0048                          UP_ARROW        EQU     72
= 0050                          DOWN_ARROW      EQU     80
= 004B                          LEFT_ARROW      EQU     75
= 004D                          RIGHT_ARROW     EQU     77
= 000C                          MINUS           EQU     12
= 000D                          EQUALS          EQU     13
= 000B                          NUM_0           EQU     11
                                ; NEW TRANSLATED SCAN CODES
                                ;---------------------------------------------------------------
                                ;NOTE:
                                ;          BREAK, PAUSE, ECHO, AND PRT_SCREEN ARE USED AS OFFSETS
                                ;          INTO THE TABLE 'SCAN'.  OFFSET = TABLE POSITION + 1.
                                ;---------------------------------------------------------------
= 0001                          ECHO            EQU     01
= 0002                          BREAK           EQU     02
= 0003                          PAUSE           EQU     03
= 0004                          PRT_SCREEN      EQU     04
= 0046                          SCROLL_LOCK     EQU     70
= 0047                          NUM_LOCK        EQU     69
= 004F                          HOME            EQU     71
= 0049                          END_KEY         EQU     79
= 0051                          PAGE_UP         EQU     73
= 004A                          PAGE_DOWN       EQU     81
= 004A                          KEYPAD_MINUS    EQU     74
= 004E                          KEYPAD_PLUS     EQU     78
                                        ASSUME  CS:CODE,DS:DATA
                                ;-----TABLE OF VALID SCAN CODES
1069                            KB0             LABEL   BYTE
1069  30 10 12 19 1F 31                 DB      B_KEY, Q_KEY, E_KEY, P_KEY, S_KEY, N_KEY
106F  48 50 4B 4D 0C                    DB      UP_ARROW, DOWN_ARROW, LEFT_ARROW, RIGHT_ARROW, MINUS
1074  0D                                DB      EQUALS
= 000C                          KB0LEN          EQU     $ - KB0
                                ;-----TABLE OF NEW SCAN CODES
1075                            KB1             LABEL   BYTE
1075  02 03 01 04 46 45                 DB      BREAK, PAUSE, ECHO, PRT_SCREEN, SCROLL_LOCK, NUM_LOCK
107B  47 4F 49 51 4A 4E                 DB      HOME,END_KEY,PAGE_UP,PAGE_DOWN,KEYPAD_MINUS,KEYPAD_PLUS
                                ;---------------------------------------------------------------
                                ;NOTE:  THERE IS A ONE TO ONE CORRESPONDENCE BETWEEN
                                ;       THE SIZE OF KB0 AND KB1.
                                ;---------------------------------------------------------------
                                ;TABLE OF NUMERIC KEYPAD SCAN CODES
                                ;       THESE SCAN CODES WERE NUMERIC KEYPAD CODES ON
                                ;       THE 83 KEY KEYBOARD.
                                ;---------------------------------------------------------------
1081                            NUM_CODES       LABEL   BYTE
1081  4F 50 51 4B 4C 4D                 DB      79,80,81,75,76,77,71,72,73,82
      47 48 49 52
                                ;---------------------------------------------------------------
                                ;TABLE OF SIMULATED KEYSTROKES
                                ;       THIS TABLE REPRESENTS A 4*2 ARRAY.  EACH ROW
                                ;       CONSISTS OF A SEQUENCE OF SCAN CODES WHICH
                                ;       WOULD HAVE BEEN GENERATED ON AN 83 KEY KEYBOARD
                                ;       TO CAUSE THE FOLLOWING FUNCTIONS:
                                ;            ROW 1=ECHO CRT OUTPUT TO THE PRINTER
                                ;            ROW 2=BREAK
                                ;       THE TABLE HAS BOTH MAKE AND BREAK SCAN CODES.
                                ;---------------------------------------------------------------
108B                            SCAN            LABEL   BYTE
108B  1D 37 B7 9D                       DB      29,55,183,157   ; CTRL + PRTSC
108F  1D 46 C6 9D                       DB      29,70,198,157   ; CTRL + SCROLL-LOCK
; --------------------------------------------------------------------------------------------------
; A-38
; --------------------------------------------------------------------------------------------------
                                ;------------------------------------------------------------
                                ;TABLE OF VALID ALT SHIFT SCAN CODES
                                ;       THIS TABLE CONTAINS SCAN CODES FOR KEYS ON THE
                                ;       62 KEY KEYBOARD.  THESE CODES ARE USED IN
                                ;       COMBINATION WITH THE ALT KEY TO PRODUCE SCAN CODES
                                ;       FOR KEYS NOT FOUND ON THE 62 KEY KEYBOARD.
                                ;------------------------------------------------------------
1093                            ALT_TABLE       LABEL   BYTE
1093  35 28 34 1A 1B                    DB      53,40,52,26,27
= 0005                          ALT_LEN         EQU     $ - ALT_TABLE
                                ;------------------------------------------------------------
                                ;TABLE OF TRANSLATED SCAN CODES WITH ALT SHIFT
                                ;       THIS TABLE CONTAINS THE SCAN CODES FOR THE
                                ;       KEYS WHICH ARE NOT ON THE 62 KEY KEYBOARD AND
                                ;       WILL BE TRANSLATED WITH ALT SHIFT.  THERE IS A
                                ;       ONE TO ONE CORRESPONDENCE BETWEEN THE SIZES
                                ;       OF ALT_TABLE AND NEW_ALT.
                                ;       THE FOLLOWING TRANSLATIONS ARE MADE:
                                ;               ALT+ / = \
                                ;               ALT+ ' = `
                                ;               ALT+ [ = ;
                                ;               ALT+ ] = ~
                                ;               ALT+ . = *
                                ;------------------------------------------------------------

1098                            NEW_ALT         LABEL   BYTE
1098  2B 29 37 2B 29                    DB      43,41,55,43,41

                                ;------------------------------------------------------------
                                ;EXTAB
                                ;       TABLE OF SCAN CODES FOR MAPPING EXTENDED SET
                                ;       OF SCAN CODES (SCAN CODES > 85).  THIS TABLE
                                ;       ALLOWS OTHER DEVICES TO USE THE KEYBOARD INTERFACE.
                                ;       IF THE DEVICE GENERATES A SCAN CODE > 85 THIS TABLE
                                ;       CAN BE USED TO MAP THE DEVICE TO THE KEYBOARD.  THE
                                ;       DEVICE ALSO HAS THE OPTION OF HAVING A UNIQUE SCAN
                                ;       CODE PUT IN THE KEYBOARD BUFFER (INSTEAD OF MAPPING
                                ;       TO THE KEYBOARD).  THE EXTENDED SCAN CODE PUT IN THE
                                ;       BUFFER WILL BE CONTINUOUS BEGINNING AT 150.  A ZERO
                                ;       WILL BE USED IN PLACE OF AN ASCII CODE.  (E.G. A
                                ;       DEVICE GENERATING SCAN CODE 86 AND NOT MAPPING 86
                                ;       TO THE KEYBOARD WILL HAVE A [150,0] PUT IN THE
                                ;       KEYBOARD BUFFER)
                                ;       TABLE FORMAT:
                                ;       THE FIRST BYTE IS A LENGTH INDICATING THE NUMBER
                                ;       OF SCAN CODES MAPPED TO THE KEYBOARD.  THE REMAINING
                                ;       ENTRIES ARE WORDS.  THE FIRST BYTE (LOW BYTE) IS A
                                ;       SCAN CODE AND THE SECOND BYTE (HIGH BYTE) IS ZERO.
                                ;       A DEVICE GENERATING N SCAN CODES IS ASSUMED TO GENERATE THE
                                ;       FOLLOWING STREAM 86,87,88,...,86+(N-1).  THE SCAN CODE BYTES
                                ;       IN THE TABLE CORRESPOND TO THIS SET WITH THE FIRST DATA
                                ;       BYTE MATCHING 86, THE SECOND MATCHING 87 ETC.
                                ;   NOTES:
                                ;       (1) IF A DEVICE GENERATES A BREAK CODE, NOTHING IS
                                ;           PUT IN THE BUFFER.
                                ;       (2) A LENGTH OF 0 INDICATES THAT ZERO SCAN CODES HAVE BEEN
                                ;           MAPPED TO THE KEYBOARD AND ALL EXTENDED SCAN CODES WILL
                                ;           BE USED.
                                ;       (3) A DEVICE CAN MAP SOME OF ITS SCAN CODES TO THE KEYBOARD
                                ;           AND HAVE SOME ITS SCAN CODES IN THE EXTENDED SET.
                                ;------------------------------------------------------------
109D                            EXTAB   LABEL   BYTE
109D  14                                DB      20              ; LENGTH OF TABLE
109E  0048 0049 004D 0051
      0050 004F 004B 0047
      0039 001C                         DW      72,73,77,81,80,79,75,71,57,28
10B2  0011 0012 001F 002D
      002C 002B 001E 0010
      000F 0001                         DW      17,18,31,45,44,43,30,16,15,1

10C6                            KEY62_INT PROC  FAR
10C6  FB                                STI                     
10C7  FC                                CLD                     ; FORWARD DIRECTION
10C8  E8 138B R                         CALL    DDS             ; SET UP ADDRESSING
10CB  8A E0                             MOV     AH,AL           ; SAVE SCAN CODE
10CD  E8 131E R                         CALL    TPM             ; ADJUST OUTPUT FOR USER
                                                                ; MODIFICATION
10D0  73 01                             JNC     KBX0            ; JUMP IF OK TO CONTINUE
10D2  CF                                IRET                    ; RETURN FROM INTERRUPT.
                                ;----EXTENDED SCAN CODE CHECK
10D3  3C FF                     KBX0:   CMP     AL,0FFH         ; IS THIS AN OVERRUN CHAR?
10D5  74 6C                             JE      KBO_1           ; PASS IT TO INTERRUPT 9
10D7  24 7F                             AND     AL,AND_MASK-BREAK_BIT ; TURN OFF BREAK BIT
10D9  3C 56                             CMP     AL,EXT_SCAN     ; IS THIS A SCAN CODE > 83
10DB  7C 5F                             JL      KBX4            ; REPLACE BREAK BIT
                                ;----SCAN CODE IS IN EXTENDED SET
10DD  1E                                PUSH    DS
10DE  33 F6                             XOR     SI,SI
10E0  8E DE                             MOV     DS,SI
                                        ASSUME  DS:ABSO
10E2  C4 3E 0124 R                      LES     DI,DWORD PTR EXST ; GET THE POINTER TO THE EXTENDED
                                                                ; SET
10E6  26: 8A 0D                         MOV     CL,BYTE PTR ES:[DI] ; GET LENGTH BYTE
10E9  1F                                POP     DS
                                        ASSUME  DS:DATA
                                ;----DOES SCAN CODE GET MAPPED TO KEYBOARD OR TO NEW EXTENDED SCAN
                                ;    CODES?
10EA  2C 56                             SUB     AL,EXT_SCAN     ; CONVERT TO BASE OF NEW SET
10EC  FE C9                             DEC     CL              ; LENGTH - 1
10EE  3A C1                             CMP     AL,CL           ; IS CODE IN TABLE?
10F0  7F 10                             JG      KBX1            ; JUMP IF SCAN CODE IS NOT IN TABLE
; --------------------------------------------------------------------------------------------------
; A-39
; --------------------------------------------------------------------------------------------------
                                ;----GET SCAN CODE FROM TABLE
10F2  47                                INC     DI              ; POINT DI PAST LENGTH BYTE
10F3  8B D8                             MOV     BX,AX           ; PREPARE FOR ADDING TO 16 BIT
10F5  32 FF                             XOR     BH,BH           ; REGISTER

10F7  D1 E3                             SHL     BX,1            ; OFFSET TO CORRECT TABLE ENTRY
10F9  03 FB                             ADD     DI,BX
10FB  26: 8A 05                         MOV     AL,BYTE PTR ES:[DI] ; TRANSLATED SCAN CODE IN AL
10FE  3C 56                             CMP     AL,EXT_SCAN     ; IS CODE IN KEYBOARD SET?
1100  7C 3A                             JL      KBX4            ; IN KEYBOARD SET, CHECK FOR BREAK
                                ;----SCAN CODE GETS MAPPED TO EXTENDED SCAN CODES
1102  F6 C4 80                  KBX1:   TEST    AH,BREAK_BIT    ; IS THIS A BREAK CODE?
1105  74 01                             JZ      KBX2            ; MAKE CODE, PUT IN BUFFER
1107  CF                                IRET                    ; BREAK CODE, RETURN FROM INTERRUPT
1108  80 C4 40                  KBX2:   ADD     AH,64           ; EXTENDED SET CODES BEGIN AT 150
110B  32 C0                             XOR     AL,AL           ; ZERO OUT ASCII VALUE (NUL)
110D  8B 1E 001C R                      MOV     BX,BUFFER_TAIL  ; GET TAIL POINTER
1111  8B F3                             MOV     SI,BX           ; SAVE POINTER TO TAIL
1113  E8 144F R                         CALL    K4              ; INCREMENT TAIL VALUE
1116  3B 1E 001A R                      CMP     BX,BUFFER_HEAD  ; IS BUFFER FULL?
111A  75 19                             JNE     KBX3            ; PUT CONTENTS OF AX IN BUFFER
                                ;----BUFFER IS FULL, BEEP AND CLEAR FLAGS
111C  BB 0080                           MOV     BX,80H          ; FREQUENCY OF BEEP
111F  B9 0048                           MOV     CX,48H          ; DURATION OF BEEP
1122  E8 E035 R                         CALL    KB_NOISE        ; BUFFER FULL BEEP
1125  80 26 0017 R F0                   AND     KB_FLAG,0F0H    ; CLEAR ALT, CTRL, LEFT AND RIGHT
112A  80 26 0018 R 0F                   AND     KB_FLAG_1,0FH   ; CLEAR MAKE OF INS,CAPS_LOCK,NUM
                                                                ; AND SCROLL
112F  80 26 0088 R 1F                   AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
1134  CF                                IRET                    ; DONE WITH INTERRUPT
1135  89 04                     KBX3:   MOV     [SI],AX         ; PUT CONTENTS OF AX IN BUFFER
1137  89 1E 001C R                      MOV     BUFFER_TAIL,BX  ; ADVANCE BUFFER TAIL
113B  CF                                IRET                    ; RETURN FROM INTERRUPT
113C  80 E4 80                  KBX4:   AND     AH,BREAK_BIT    ; MASK BREAK BIT ON ORIGINAL SCAN
113F  0A C4                             OR      AL,AH           ; UPDATE NEW SCAN CODE
1141  8A E0                             MOV     AH,AL           ; SAVE AL IN AH AGAIN
                                ;----83 KEY KEYBOARD FUNCTIONS SHIFT+PRTSC AND CTRL+NUMLOCK
1143  3C 45                     KBO_1:  CMP     AL,NUM_KEY      ; IS THIS A NUMLOCK?
1145  75 14                             JNE     KBO_3           ; CHECK FOR PRTSC
1147  F6 06 0017 R 04                   TEST    KB_FLAG,CTL_SHIFT ; IS CTRL KEY BEING HELD DOWN?
114C  74 0A                             JZ      KBO_2           ; NUMLOCK WITHOUT CTRL, CONTINUE
114E  F6 06 0017 R 08                   TEST    KB_FLAG,ALT_SHIFT ; IS ALT KEY HELD CONCURRENTLY?
1153  75 03                             JNZ     KBO_2           ; PASS IT ON
1155  E9 12EB R                         JMP     KB16_1          ; PUT KEYBOARD IN HOLD STATE
1158  E9 125C R                 KBO_2:  JMP     CONT_INT        ; CONTINUE WITH INTERRUPT 48H
                                ;----CHECK FOR PRTSC
115B  3C 37                     KBO_3:  CMP     AL,55           ; IS THIS A PRTSC KEY?
115D  75 11                             JNZ     KB1_1           ; NOT A PRTSC KEY
115F  F6 06 0017 R 03                   TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; EITHER SHIFT
                                                                ; ACTIVE?
1164  74 F2                             JZ      KBO_2           ; PROCESS SCAN IN INT9
1166  F6 06 0017 R 04                   TEST    KB_FLAG,CTL_SHIFT ; IS THE CTRL KEY PRESSED?
116B  75 EB                             JNZ     KBO_2           ; NOT A VALID PRTSC (PC COMPATIBLE)
116D  E9 1301 R                         JMP     PRTSC           ; HANDLE THE PRINT SCREEN FUNCTION
                                ;----ALTERNATE SHIFT TRANSLATIONS
1170  8A E0                     KB1_1:  MOV     AH,AL           ; SAVE CHARACTER
1172  24 7F                             AND     AL, AND_MASK - BREAK_BIT ; MASK BREAK BIT
1174  F6 06 0017 R 08                   TEST    KB_FLAG,ALT_SHIFT ; IS THIS A POTENTIAL TRANSLATION
1179  74 39                             JZ      KB2
                                ;----TABLE LOOK UP
117B  0E                                PUSH    CS              ; INITIALIZE SEGMENT FOR TABLE LOOK
117C  07                                POP     ES              ; UP

117D  BF 1093 R                         MOV     DI,OFFSET ALT_TABLE
1180  B9 0005                           MOV     CX,ALT_LEN      ; GET READY FOR TABLE LOOK UP
1183  F2/ AE                            REPNE   SCASB           ; SEARCH TABLE
1185  75 2D                             JNE     KB2             ; JUMP IF MATCH IS NOT FOUND
1187  B9 1094 R                         MOV     CX,OFFSET ALT_TABLE + 1
118A  2B F9                             SUB     DI,CX           ; UPDATE DI TO INDEX SCAN CODE
118C  2E: 8A 85 1098 R                  MOV     AL,CS:NEW_ALT[DI] ; TRANSLATE SCAN CODE
                                ;----CHECK FOR BREAK CODE
1191  8A 1E 0017 R                      MOV     BL,KB_FLAG      ; SAVE KB_FLAG STATUS
1195  80 36 0017 R 08                   XOR     KB_FLAG,ALT_SHIFT ; MASK OFF ALT SHIFT
119A  F6 C4 80                          TEST    AH,BREAK_BIT    ; IS THIS A BREAK CHARACTER?
119D  74 02                             JZ      KB1_2           ; JUMP IF SCAN IS A MAKE
119F  0C 80                             OR      AL,BREAK_BIT    ; SET BREAK BIT
                                ;----MAKE CODE, CHECK FOR SHIFT SEQUENCE
11A1  83 FF 03                  KB1_2:  CMP     DI,3            ; IS THIS A SHIFT SEQUENCE
11A4  7C 05                             JL      KB1_3           ; JUMP IF NOT SHIFT SEQUENCE
11A6  80 0E 0017 R 02                   OR      KB_FLAG,LEFT_SHIFT ; TURN ON SHIFT FLAG
11AB  E6 60                     KB1_3:  OUT     KBPORT,AL
11AD  CD 09                             INT     9H              ; ISSUE INT TO PROCESS SCAN CODE
11AF  88 1E 0017 R                      MOV     KB_FLAG,BL      ; RESTORE ORIGINAL FLAG STATES
11B3  CF                                IRET
                                ;----FUNCTION KEY HANDLER
11B4  3C 54                     KB2:    CMP     AL, FN_KEY      ; CHECK FOR FUNCTION KEY
11B6  75 23                             JNZ     KB4             ; JUMP IF NOT FUNCTION KEY
11B8  F6 C4 80                          TEST    AH, BREAK_BIT   ; IS THIS A FUNCTION BREAK
11BB  75 0B                             JNZ     KB3             ; JUMP IF FUNCTION BREAK
11BD  80 26 0088 R 1F                   AND     KB_FLAG_2,CLEAR_FLAGS ; CLEAR ALL PREVIOUS
                                                                ; FUNCTIONS
11C2  80 0E 0088 R A0                   OR      KB_FLAG_2, FN_FLAG + FN_PENDING
11C7  CF                                IRET                    ; RETURN FROM INTERRUPT
                                ;----FUNCTION BREAK
11C8  F6 06 0088 R 20           KB3:    TEST    KB_FLAG_2,FN_PENDING
11CD  75 06                             JNZ     KB3_1           ; JUMP IF FUNCTION IS PENDING
11CF  80 26 0088 R 1F                   AND     KB_FLAG_2,CLEAR_FLAGS ; CLEAR ALL FLAGS
11D4  CF                                IRET
11D5  80 0E 0088 R 40           KB3_1:  OR      KB_FLAG_2,FN_BREAK ; SET BREAK FLAG
11DA  CF                        KB3_2:  IRET                    ; RETURN FROM INTERRUPT
; --------------------------------------------------------------------------------------------------
; A-40
; --------------------------------------------------------------------------------------------------
                                ;----CHECK IF FUNCTION FLAG ALREADY SET
11DB  3C 55                     KB4:    CMP     AL,PHK          ; IS THIS A PHANTOM KEY?
11DD  74 FB                             JZ      KB3_2           ; JUMP IF PHANTOM SEQUENCE
11DF  F6 06 008B R 90           KB4_0:  TEST    KB_FLAG_2,FN_FLAG+FN_LOCK ; ARE WE IN FUNCTION
                                                                ; STATE?
11E4  75 21                             JNZ     KB5             
                                ;----CHECK IF NUM_STATE IS ACTIVE
11E6  F6 06 0017 R 20                   TEST    KB_FLAG,NUM_STATE
11EB  74 16                             JZ      KB4_1           ; JUMP IF NOT IN NUM_STATE
11ED  3C 0B                             CMP     AL,NUM_0        ; ARE WE IN NUMERIC KEYPAD REGION?
11EF  77 12                             JA      KB4_1           ; JUMP IF NOT IN KEYPAD
11F1  FE C8                             DEC     AL              ; CHECK LOWER BOUND OF RANGE
11F3  74 0E                             JZ      KB4_1           ; JUMP IF NOT IN RANGE (ESC KEY)
                                ;----TRANSLATE SCAN CODE TO NUMERIC KEYPAD
11F5  FE C8                             DEC     AL              ; AL IS OFFSET INTO TABLE
11F7  BB 1081 R                         MOV     BX,OFFSET NUM_CODES
11FA  2E: D7                            XLAT    CS:NUM_CODES    ; NEW SCAN CODE IS IN AL
11FC  80 E4 80                          AND     AH,BREAK_BIT    ; ISOLATE BREAK BIT ON ORIGINAL
11FF  0A C4                             OR      AL,AH           ; SCAN CODE
1201  EB 59                             JMP     SHORT CONT_INT  ; UPDATE KEYPAD SCAN CODE
1203  8A C4                     KB4_1:  MOV     AL,AH           ; GET BACK BREAK BIT IF SET
1205  EB 55                             JMP     SHORT CONT_INT
                                ;----CHECK FOR VALID FUNCTION KEY
1207  3C 0B                     KB5:    CMP     AL, NUM_0       ; CHECK FOR RANGE OF INTEGERS
1209  77 2D                             JA      KB7             ; JUMP IF NOT IN RANGE
120B  FE C8                             DEC     AL
120D  75 25                             JNZ     KB6             ; CHECK FOR ESC KEY (=1)
                                ;----ESCAPE KEY, LOCK KEYBOARD IN FUNCTION LOCK
120F  F6 C4 80                          TEST    AH,BREAK_BIT    ; IS THIS A BREAK CODE?
1212  75 30                             JNZ     KB8             ; NO PROCESSING FOR ESCAPE BREAK
1214  F6 06 008B R 80                   TEST    KB_FLAG_2,FN_FLAG ; TOGGLES ONLY WHEN FN HELD
1219  74 29                             JZ      KB8             ; CONCURRENTLY
121B  F6 06 008B R 40                   TEST    KB_FLAG_2,FN_BREAK ; HAS THE FUNCTION KEY BEEN
1220  75 22                             JNZ     KB8             ; RELEASED?
                                ; CONTINUE IF RELEASED. PROCESS AS
1222  F6 06 0017 R 03                   TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; EITHER SHIFT?
1227  74 1B                             JZ      KB8             ; NOT HELD DOWN
1229  80 36 008B R 10                   XOR     KB_FLAG_2,FN_LOCK ; TOGGLE STATE
122E  80 26 008B R 1F                   AND     KB_FLAG_2,CLEAR_FLAGS ; TURN OFF OTHER STATES
1233  CF                                IRET                    ; RETURN FROM INTERUPT
                                ;----SCAN CODE IN RANGE 1 -> 0
1234  04 3A                     KB6:    ADD     AL, 58          ; GENERATE CORRECT SCAN CODE
1236  EB 3E                             JMP     SHORT KB12      ; CLEAN-UP BEFORE RETURN TO KB_INT
                                ;----CHECK TABLE FOR OTHER VALID SCAN CODES
1238  0E                        KB7:    PUSH    CS              ; ESTABLISH ADDRESS OF TABLE
1239  07                                POP     ES
123A  BF 1069 R                         MOV     DI, OFFSET KB0  ; BASE OF TABLE
123D  B9 000C                           MOV     CX, KB0LEN      ; LENGTH OF TABLE
1240  F2/ AE                            REPNE   SCASB           ; SEARCH TABLE FOR A MATCH
1242  74 1D                             JE      KB10            ; JUMP IF MATCH
                                ;----ILLEGAL CHARACTER
1244  F6 06 008B R 40           KB8:    TEST    KB_FLAG_2,FN_BREAK ; HAS BREAK OCCURED?
1249  74 0F                             JZ      KB9             ; FUNCTION KEY HAS NOT BEEN
124B  F6 C4 80                          TEST    AH,BREAK_BIT    ; RELEASED
124E  75 0A                             JNZ     KB9             ; DON'T RESET FLAGS ON ILLEGAL
                                                                ; BREAK
1250  80 26 008B R 1F           KB8S:   AND     KB_FLAG_2,CLEAR_FLAGS ; NORMAL STATE
1255  C6 06 0087 R 00                   MOV     CUR_FUNC,0      ; RETRIEVE ORIGINAL SCAN CODE
                                ;----FUNCTION BREAK IS NOT SET
125A  8A C4                     KB9:    MOV     AL,AH           ; RETRIEVE ORIGINAL SCAN CODE
125C                            CONT_INT:
125C  E6 60                             OUT     KBPORT,AL
125E  CD 09                             INT     9H              ; ISSUE KEYBOARD INTERRUPT
1260                            RET_INT:
1260  CF                                IRET
                                ;----BEFORE TRANSLATION CHECK FOR ALT+FN+N_KEY AS NUM LOCK
1261  3C 31                     KB10:   CMP     AL,N_KEY        ; IS THIS A POTENTIAL NUMLOCK?
1263  75 07                             JNE     KB10_1          ; NOT A NUMKEY, TRANSLATE IT
1265  F6 06 0017 R 08                   TEST    KB_FLAG,ALT_SHIFT ; ALT HELD DOWN ALSO?
126A  74 D8                             JZ      KB8             ; TREAT AS ILLEGAL COMBINATION
126C  B9 106A R                         MOV     CX, OFFSET KB0 + 1 ; GET OFFSET TO TABLE
126F  2B F9                     KB10_1: SUB     DI, CX          ; UPDATE INDEX TO NEW SCAN CODE
1271  2E: 8A 85 1075 R                  MOV     AL, CS:KB1[DI]  ; MOV NEW SCAN CODE INTO REGISTER
                                ;----TRANSLATED CODE IN AL OR AN OFFSET TO THE TABLE "SCAN"
1276  F6 C4 80                  KB12:   TEST    AH,BREAK_BIT    ; IS THIS A BREAK CHAR?
1279  74 35                             JZ      KB13            ; JUMP IF MAKE CODE
                                ;----CHECK FOR TOGGLE KEY
127B  3C 45                             CMP     AL,NUM_LOCK     ; IS THIS A NUM LOCK?
127D  74 04                             JZ      KB12_1          ; JUMP IF TOGGLE KEY
127F  3C 46                             CMP     AL, SCROLL_LOCK ; IS THIS A SCROLL LOCK?
1281  75 08                             JNZ     KB12_2          ; JUMP IF NOT A TOGGLE KEY
1283  0C 80                     KB12_1: OR      AL,80H          ; TURN ON BREAK BIT
1285  E6 60                             OUT     KBPORT,AL
1287  CD 09                             INT     9H
1289  24 7F                             AND     AL,AND_MASK-BREAK_BIT ; TURN OFF BREAK BIT
128B  F6 06 008B R 40           KB12_2: TEST    KB_FLAG_2,FN_BREAK ; HAS FUNCTION BREAK OCCURED?
1290  74 11                             JZ      KB12_3          ; JUMP IF BREAK HAS NOT OCCURED
1292  3A 06 0087 R                      CMP     AL,CUR_FUNC     ; IS THIS A BREAK OF OLD VALID
                                ; FUNCTION
1296  75 C8                             JNE     RET_INT         ; ALLOW FURTHER CURRENT FUNCTIONS
1298  80 26 008B R 1F                   AND     KB_FLAG_2,CLEAR_FLAGS
129D                            KB12_20:
129D  C6 06 0087 R 00                   MOV     CUR_FUNC,0      ; CLEAR CURRENT FUNCTION
12A2  CF                                IRET                    ; RETURN FROM INTERRUPT
