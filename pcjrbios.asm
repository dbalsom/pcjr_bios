; ----------------------------------------------------------------------
; IBM PCjr BIOS (C)IBM Corporation 1983
; Originally published in the IBM PCjr Technical Reference, Appendix A
; Transcribed by GloriousCow in 2026
; ----------------------------------------------------------------------
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
PORT_A          EQU     60H     ; 8255 PORT A ADDR
CPUREG          EQU     38H     ; MASK FOR CPU REG BITS
CRTREG          EQU     7       ; MASK FOR CRT REG BITS
PORT_B          EQU     61H     ; 8255 PORT B ADDR
PORT_C          EQU     62H     ; 8255 PORT C ADDR
CMD_PORT        EQU     63H
MODE_8255       EQU     10001001B
INTA00          EQU     20H     ; 8259 PORT
INTA01          EQU     21H     ; 8259 PORT
EOI             EQU     20H
TIMER           EQU     40H
TIM_CTL         EQU     43H     ; 8253 TIMER CONTROL PORT ADDR
TIMER0          EQU     40H     ; 8253 TIMER/CNTER 0 PORT ADDR
KB_CTL          EQU     61H     ; CONTROL BITS FOR KEYBOARD
VGA_CTL         EQU     03DAH   ; VIDEO GATE ARRAY CONTROL PORT
NMI_PORT        EQU     0A0H    ; NMI CONTROL PORT
PORT_B0         EQU     0B0H
PAGREG          EQU     03DFH   ; CRT/CPU PAGE REGISTER
KBPORT          EQU     060H    ; KEYBOARD PORT
DIAG_TABLE_PTR  EQU     4000H
MINI            EQU     2000H
;---------------------------------------
;           DISKETTE EQUATES
;---------------------------------------
NEC_CTL         EQU     0F2H    ; CONTROL PORT FOR THE DISKETTE
FDC_RESET       EQU     80H     ; RESETS THE NEC (FLOPPY DISK
                                ; CONTROLLER).  0 RESETS,
                                ; 1 RELEASES THE RESET
WD_ENABLE       EQU     20H     ; ENABLES WATCH DOG TIMER IN NEC
WD_STROBE       EQU     40H     ; STROBES WATCHDOG TIMER
DRIVE_ENABLE    EQU     01H     ; SELECTS AND ENABLES DRIVE

NEC_STAT        EQU     0F4H    ; STATUS REGISTER FOR THE NEC
BUSY_BIT        EQU     20H     ; BIT = 0 AT END OF EXECUTION PHASE
DIO             EQU     40H     ; INDICATES DIRECTION OF TRANSFER
RQM             EQU     80H     ; REQUEST FOR MASTER
NEC_DATA        EQU     0F5H    ; DATA PORT FOR THE NEC
;---------------------------------------
;        8088 INTERRUPT LOCATIONS
;---------------------------------------
ABS0            SEGMENT AT 0
        ORG     2*4
NMI_PTR         LABEL   WORD
        ORG     3*4
INT3_PTR        LABEL   WORD
        ORG     5*4
INT5_PTR        LABEL   WORD
        ORG     8*4
INT_PTR         LABEL   WORD
        ORG     10H*4
VIDEO_INT       LABEL   WORD
        ORG     1CH*4
INT1C_PTR       LABEL   WORD
        ORG     1DH*4
PARM_PTR        LABEL   DWORD   ; POINTER TO VIDEO PARMS
        ORG     18H*4
BASIC_PTR       LABEL   WORD    ; ENTRY POINT FOR CASSETTE BASIC
        ORG     01EH*4          ; INTERRUPT 1EH
DISK_POINTER    LABEL   DWORD
        ORG     01FH*4          ; LOCATION OF POINTER
EXT_PTR         LABEL   DWORD   ; POINTER TO EXTENSION
        ORG     044H*4
CSET_PTR        LABEL   DWORD   ; POINTER TO DOT PATTERNS
        ORG     048H*4
KEY62_PTR       LABEL   WORD    ; POINTER TO 62 KEY KEYBOARD CODE
        ORG     049H*4
EXST            LABEL   WORD    ; POINTER TO EXT. SCAN TABLE
        ORG     081H*4
INT81           LABEL   WORD
        ORG     082H*4
INT82           LABEL   WORD
        ORG     089H*4
INT89           LABEL   WORD
        ORG     400H
DATA_AREA       LABEL   BYTE    ; ABSOLUTE LOCATION OF DATA SEGMENT
DATA_WORD       LABEL   WORD
        ORG     7C00H
BOOT_LOCN       LABEL   FAR
ABS0            ENDS
;------------------------------------------------
; STACK -- USED DURING INITIALIZATION ONLY
;------------------------------------------------
STACK           SEGMENT AT 30H
                DW      128 DUP (?)



TOS             LABEL   WORD
STACK           ENDS
;------------------------------------------------
;              ROM BIOS DATA AREAS
;------------------------------------------------
DATA            SEGMENT AT 40H
RS232_BASE      DW      4 DUP(?) ; ADDRESSES OF RS232 ADAPTERS


PRINTER_BASE    DW      4 DUP(?) ; ADDRESSES OF PRINTERS


EQUIP_FLAG      DW      ?       ; INSTALLED HARDWARE
KBD_ERR         DB      ?       ; COUNT OF KEYBOARD TRANSMIT ERRORS
MEMORY_SIZE     DW      ?       ; USABLE MEMORY SIZE IN K BYTES
TRUE_MEM        DW      ?       ; REAL MEMORY SIZE IN K BYTES
;------------------------------------------------
;             KEYBOARD DATA AREAS
;------------------------------------------------
KB_FLAG         DB      ?
;----- SHIFT FLAG EQUATES WITHIN KB_FLAG
CAPS_STATE      EQU     40H     ; CAPS LOCK STATE HAS BEEN TOGGLED
NUM_STATE       EQU     20H     ; NUM LOCK STATE HAS BEEN TOGGLED
ALT_SHIFT       EQU     08H     ; ALTERNATE SHIFT KEY DEPRESSED
CTL_SHIFT       EQU     04H     ; CONTROL SHIFT KEY DEPRESSED
LEFT_SHIFT      EQU     02H     ; LEFT SHIFT KEY DEPRESSED
RIGHT_SHIFT     EQU     01H     ; RIGHT SHIFT KEY DEPRESSED
KB_FLAG_1       DB      ?       ; SECOND BYTE OF KEYBOARD STATUS
INS_SHIFT       EQU     80H     ; INSERT KEY IS DEPRESSED
CAPS_SHIFT      EQU     40H     ; CAPS LOCK KEY IS DEPRESSED
NUM_SHIFT       EQU     20H     ; NUM LOCK KEY IS DEPRESSED
SCROLL_SHIFT    EQU     10H     ; SCROLL LOCK KEY IS DEPRESSED
HOLD_STATE      EQU     08H     ; SUSPEND KEY HAS BEEN TOGGLED
CLICK_ON        EQU     04H     ; INDICATES THAT AUDIO FEEDBACK IS
                                ; ENABLED
CLICK_SEQUENCE  EQU     02H     ; OCCURRENCE OF ALT-CTRL-CAPSLOCK HAS
                                ; OCCURED
ALT_INPUT       DB      ?       ; STORAGE FOR ALTERNATE KEYPAD
                                ; ENTRY
BUFFER_HEAD     DW      ?       ; POINTER TO HEAD OF KEYBOARD BUFF
BUFFER_TAIL     DW      ?       ; POINTER TO TAIL OF KEYBOARD BUFF
KB_BUFFER       DW      16 DUP(?) ; ROOM FOR 15 ENTRIES


; ------ HEAD = TAIL INDICATES THAT THE BUFFER IS EMPTY
NUM_KEY         EQU     69      ; SCAN CODE FOR NUMBER LOCK
SCROLL_KEY      EQU     70      ; SCROLL LOCK KEY
ALT_KEY         EQU     56      ; ALTERNATE SHIFT KEY SCAN CODE
CTL_KEY         EQU     29      ; SCAN CODE FOR CONTROL KEY
CAPS_KEY        EQU     58      ; SCAN CODE FOR SHIFT LOCK
LEFT_KEY        EQU     42      ; SCAN CODE FOR LEFT SHIFT
RIGHT_KEY       EQU     54      ; SCAN CODE FOR RIGHT SHIFT
INS_KEY         EQU     82      ; SCAN CODE FOR INSERT KEY
DEL_KEY         EQU     83      ; SCAN CODE FOR DELETE KEY
; ------------------------------------------------
;            DISKETTE DATA AREAS
; ------------------------------------------------
SEEK_STATUS     DB      ?       ; DRIVE RECALIBRATION STATUS
                                ; BIT 0 = DRIVE NEEDS RECAL BEFORE
                                ; NEXT SEEK IF BIT IS = 0.
MOTOR_STATUS    DB      ?       ; MOTOR STATUS
                                ; BIT 0 = DRIVE 0 IS CURRENTLY
                                ; RUNNING
MOTOR_COUNT     DB      ?       ; TIME OUT COUNTER FOR DRIVE
                                ; TURN OFF
MOTOR_WAIT      EQU     37      ; 2 SECS OF COUNTS FOR MOTOR
                                ; TURN OFF
DISKETTE_STATUS DB      ?       ; RETURN CODE STATUS BYTE
TIME_OUT        EQU     80H     ; ATTACHMENT FAILED TO RESPOND
BAD_SEEK        EQU     40H     ; SEEK OPERATION FAILED
BAD_NEC         EQU     20H     ; NEC CONTROLLER HAS FAILED
BAD_CRC         EQU     10H     ; BAD CRC ON DISKETTE READ
DMA_BOUNDARY    EQU     09H     ; ATTEMPT TO DMA ACROSS 64K
                                ; BOUNDARY
BAD_DMA         EQU     08H     ; DMA OVERRUN ON OPERATION
RECORD_NOT_FND  EQU     04H     ; REQUESTED SECTOR NOT FOUND
WRITE_PROTECT   EQU     03H     ; WRITE ATTEMPTED ON WRITE
                                ; PROTECTED DISK
BAD_ADDR_MARK   EQU     02H     ; ADDRESS MARK NOT FOUND
BAD_CMD         EQU     01H     ; BAD COMMAND GIVEN TO DISKETTE I/O
NEC_STATUS      DB      7 DUP(?) ; STATUS BYTES FROM NEC


SEEK_END        EQU     20H         ; NUMBER OF TIMER-0 TICKS TILL
THRESHOLD       EQU     300         ; ENABLE
PARM0           EQU     0AFH        ; PARAMETER 0 IN THE DISK_PARM
PARM1           EQU     3           ; PARAMETER 1
PARM9           EQU     25          ; PARAMETER 9
PARM10          EQU     4           ; PARAMETER 10
; ---------------------------------------------
;              VIDEO DISPLAY DATA AREA
; ---------------------------------------------
CRT_MODE        DB      ?       ; CURRENT CRT MODE
CRT_COLS        DW      ?       ; NUMBER OF COLUMNS ON SCREEN
CRT_LEN         DW      ?       ; LENGTH OF REGEN IN BYTES
CRT_START       DW      ?       ; STARTING ADDRESS IN REGEN BUFFER
CURSOR_POSN     DW      8 DUP(?) ; CURSOR FOR UP TO 8 PAGES


CURSOR_MODE     DW      ?       ; CURRENT CURSOR MODE SETTING
ACTIVE_PAGE     DB      ?       ; CURRENT PAGE BEING DISPLAYED
ADDR_6845       DW      ?       ; BASE ADDRESS FOR ACTIVE DISPLAY
                                ; CARD
CRT_MODE_SET    DB      ?       ; CURRENT SETTING OF THE
                                ; CRT MODE REGISTER
CRT_PALETTE     DB      ?       ; CURRENT PALETTE MASK SETTING
; ---------------------------------------------
;              CASSETTE DATA AREA
; ---------------------------------------------
EDGE_CNT        DW      ?       ; TIME COUNT AT DATA EDGE
CRC_REG         DW      ?       ; CRC REGISTER
LAST_VAL        DB      ?       ; LAST INPUT VALUE

; ---------------------------------------------
;              TIMER DATA AREA
; ---------------------------------------------
TIMER_LOW       DW      ?       ; LOW WORD OF TIMER COUNT
TIMER_HIGH      DW      ?       ; HIGH WORD OF TIMER COUNT
TIMER_OFL       DB      ?       ; TIMER HAS ROLLED OVER SINCE LAST
                                ; READ

; ---------------------------------------------
;              SYSTEM DATA AREA
; ---------------------------------------------
BIOS_BREAK      DB      ?       ; BIT 7=1 IF BREAK KEY HAS BEEN HIT
RESET_FLAG      DW      ?       ; WORD=1234H IF KEYBOARD RESET
; UNDERWAY

; ---------------------------------------------
;           EXTRA DISKETTE DATA AREAS
; ---------------------------------------------
TRACK0          DB      ?
TRACK1          DB      ?
TRACK2          DB      ?
                DB      ?

; ---------------------------------------------
;        PRINTER AND RS232 TIME-OUT VARIABLES
; ---------------------------------------------
PRINT_TIM_OUT   DB      4 DUP(?)



RS232_TIM_OUT   DB      4 DUP(?)



BUFFER_START    DW      ?
BUFFER_END      DW      ?
INTR_FLAG       DB      ?       ; FLAG TO INDICATE AN INTERRUPT
                                ; HAPPENED
; ---------------------------------------------
;           62 KEY KEYBOARD DATA AREA
; ---------------------------------------------
CUR_CHAR        DB      ?       ; CURRENT CHARACTER FOR TYPAMATIC
VAR_DELAY       DB      ?       ; DETERMINES WHEN INITIAL DELAY IS
                                ; OVER
DELAY_RATE      EQU     0FH     ; INCREASES INITIAL DELAY
CUR_FUNC        DB      ?       ; CURRENT FUNCTION
KB_FLAG_2       DB      ?       ; 3RD BYTE OF KEYBOARD FLAGS
RANGE           EQU     4       ; NUMBER OF POSITIONS TO SHIFT
                                ; DISPLAY
; ---------------------------------------------
;          BIT ASSIGNMETS FOR KB_FLAG_2
; ---------------------------------------------
FN_FLAG         EQU     80H
FN_BREAK        EQU     40H
FN_PENDING      EQU     20H
FN_LOCK         EQU     10H
TYPE_OFF        EQU     08H
HALF_RATE       EQU     04H
INIT_DELAY      EQU     02H
PUTCHAR         EQU     01H
HORZ_POS        DB      ?       ; CURRENT VALUE OF HORIZONTAL
                                ; START PARM
PAGDAT          DB      ?       ; IMAGE OF DATA WRITTEN TO PAGREG
DATA            ENDS

; ---------------------------------------------
;                EXTRA DATA AREA
; ---------------------------------------------
XXDATA          SEGMENT AT 50H
STATUS_BYTE     DB      ?
; THE FOLLOWING AREA IS USED ONLY DURING DIAGNOSTICS
; (POST AND ROM RESIDENT)
DCP_MENU_PAGE   DB      ?       ; TO CURRENT PAGE FOR DIAG. MENU
DCP_ROW_COL     DW      ?       ; CURRENT ROW/COLUMN COORDINATES
                                ; FOR DIAG MENU   
WRAP_FLAG       DB      ?       ; INTERNAL/EXTERNAL 8250 WRAP
                                ; INDICATOR
MFG_TST         DB      ?       ; INITIALIZATION FLAG
MEM_TOT         DW      ?       ; WORD EQUIV. TO HIGHEST SEGMENT IN
                                ; MEMORY
MEM_DONES       DW      ?       ; CURRENT SEGMENT VALUE FOR
                                ; BACKGROUND MEM TEST
MEM_DONEO       DW      ?       ; CURRENT OFFSET VALUE FOR
                                ; BACKGROUND MEM TEST
INITC0          DW      ?       ; SAVE AREA FOR INTERRUPT 1C
INT1CS          DW      ?       ; ROUTINE
MENU_UP         DB      ?       ; FLAG TO INDICATE WHETHER MENU IS
                                ; ON SCREEN (FF=YES, 0=NO)
DONE128         DB      ?       ; COUNTER TO KEEP TRACK OF 128 BYTE
                                ; BLOCKS TESTED BY BGMEM
KBDONE          DW      ?       ; TOTAL K OF MEMORY THAT HAS BEEN
                                ; TESTED BY BACKGROUND MEM TEST
; ---------------------------------------------
;       POST DATA AREA
; ---------------------------------------------
IO_ROM_INIT     DW      ?       ; POINTER TO OPTIONAL I/O ROM INIT
                                ; ROUTINE
IO_ROM_SEG      DW      ?       ; POINTER TO IO ROM SEGMENT
POST_ERR        DB      ?       ; FLAG TO INDICATE ERROR OCCURRED
                                ; DURING POST
MODEM_BUFFER    DB      9 DUP(?) ; MODEM RESPONSE BUFFER



MFG_RTN         DW      ?       ; (MAX 9 CHARS)
                DW      ?       ; POINTER TO MFG. OUTPUT ROUTINE

; ---------------------------------------------
;            ERIAL PRINTER DATA
; ---------------------------------------------
SP_FLAG         DW      ?
SP_CHAR         DB      ?
                                ; THE FOLLOWING SIX ENTRIES ARE
                                ; DATA PERTAINING TO NEW STICK                                                                
NEW_STICK_DATA  DW      ?       ; RIGHT STICK DELAY
                DW      ?       ; RIGHT BUTTON A DELAY
                DW      ?       ; RIGHT BUTTON B DELAY
                DW      ?       ; LEFT STICK DELAY
                DW      ?       ; LEFT BUTTON A DELAY
                DW      ?       ; LEFT BUTTON B DELAY
                DW      ?       ; RIGHT STICK LOCATION
                DW      ?       ; UNUSED
                DW      ?       ; UNUSED
                DW      ?       ; LEFT STICK POSITION
XXDATA          ENDS                                               
; ---------------------------------------------
;       DISKETTE DATA AREA
; ---------------------------------------------
DKDATA  SEGMENT AT 60H
NUM_DRIVE       DB      ?
DUAL            DB      ?
OPERATION       DB      ?
DRIVE           DB      ?
TRACK           DB      ?
HEAD            DB      ?
SECTOR          DB      ?
NUM_SECTOR      DB      ?
SEC             DB      ?
;   FORMAT ID
TK_HD_SC        DB      8 DUP(0,0,0,0) ; TRACK,HEAD,SECTOR,NUM OF





                                ; SECTOR
;    BUFFER FOR READ AND WRITE OPERATION
DK_BUF_LEN      EQU     512     ; 512 BYTES/SECTOR
READ_BUF        DB      DK_BUF_LEN DUP(0)



WRITE_BUF       DB      (DK_BUF_LEN/2) DUP(6DH,0BH)




;   INFO FLAGS
REQUEST_IN      DB      ?       ; SELECTION CHARACTER
DK_EXISTED      DB      ?
DK_FLAG         DB      ?
RAN_NUM         DW      ?
SEED            DW      ?           
;   SPEED TEST VARIABLES
DK_SPEED        DW      ?
TIM_1           DW      ?
TIM_L_1         DW      ?
TIM_2           DW      ?
TIM_L_2         DW      ?
FRACT_H         DW      ?
FRACT_L         DW      ?
PART_CYCLE      DW      ?
WHOLE_CYCLE     DW      ?
HALF_CYCLE      DW      ?
;   ERROR PARAMETERS
DK_ER_OCCURED   DB      ?       ; ERROR HAS OCCURRED
DK_ER_L1        DB      ?       ; CUSTOMER ERROR LEVEL
DK_ER_L2        DB      ?       ; SERVICE ERROR LEVEL
ER_STATUS_BYTE  DB      ?       ; STATUS BYTE RETURN FROM INT 13H
                                ; LANGUAGE TABLE
LANG_BYTE       DB      ?       ; PORT B0 TO DETERMINE WHICH
DKDATA          ENDS            ; LANGUAGE TO USE
;-----------------------------------------------
;               VIDEO DISPLAY BUFFER
;-----------------------------------------------
VIDEO_RAM       SEGMENT AT 0B800H
DB              16384 DUP(?)



VIDEO_RAM       ENDS
;-----------------------------------------------
;               ROM RESIDENT CODE
;-----------------------------------------------
CODE            SEGMENT PAGE
                ASSUME  CS:CODE,DS:ABS0,ES:NOTHING,SS:STACK
                DB      '1504036 COPR. IBM 1981,1983' ; COPYRIGHT NOTICE





Z1              DW      L12         ; RETURN POINTERS FOR RTNS CALLED
                DW      L14         ; BEFORE STACK INITIALIZED
                DW      L16
                DW      L19
                DW      L24
F3B             DB      ' KB'
EX_0            DW      OFFSET  EB0
                DW      OFFSET  EB0
                DW      OFFSET  TOTLTPO
EX1             DW      OFFSET  M01
;-----------------------------------------------
;             MESSAGE AREA FOR POST
;-----------------------------------------------
ERROR_ERR       DB      'ERROR' ; GENERAL ERROR PROMPT
MEM_ERR         DB      'A'     ; MEMORY ERROR
KEY_ERR         DB      'B'     ; KEYBOARD ERROR MSG
CASS_ERR        DB      'C'     ; CASSETTE ERROR MESSAGE
COM1_ERR        DB      'D'     ; ON-BOARD SERIAL PORT ERR. MSG
COM2_ERR        DB      'E'     ; SERIAL PORTION OF MODEM ERROR
ROM_ERR         DB      'F'     ; OPTIONAL GENERIC BIOS ROM ERROR
CART_ERR        DB      'G'     ; CARTRIDGE ERROR
DISK_ERR        DB      'H'     ; DISKETTE ERR
;
F4              LABEL   WORD    ; PRINTER SOURCE TABLE
                DW      378H
                DW      278H
F4E             LABEL   WORD
IMASKS          LABEL   BYTE    ; INTERRUPT MASKS FOR 8259
                                ; INTERRUPT CONTROLLER
                DB      0EFH    ; MODEM INTR MASK
                DB      0F7H    ; SERIAL PRINTER INTR MASK                                
;-----------------------------------------
; SETUP                                  :
;       DISABLE NMI, MASKABLE INTS.      :
;       SOUND CHIP, AND VIDEO.           :
;       TURN DRIVE 0 MOTOR OFF           :
;-----------------------------------------
        ASSUME  CS:CODE,DS:ABS0,ES:NOTHING,SS:STACK
        RESET   LABEL   FAR
START:  MOV     AL,0
        OUT     0A0H,AL         ; DISABLES NMI
        DEC     AL              ; SEND FF TO MFG_TESTER
        OUT     10H,AL    
        IN      AL,0A0H         ; RESET NMI F/F
        CLI                     ; DISABLES MASKABLE INTERRUPTS
                                ; DISABLE ATTENUATION IN SOUND CHIP
                                ; REG ADDRESS IN AH, ATTENUATOR OFF
        MOV     AX,108FH        ; IN AL
        MOV     DX,00C0H        ; ADDRESS OF SOUND CHIP
        MOV     CX,4            ; 4 ATTENUATORS TO DISABLE
L1:     OR      AL,AH           ; COMBINE REG ADDRESS AND DATA
        OUT     DX,AL   
        ADD     AH,20H          ; POINT TO NEXT REG
        LOOP    L1
        MOV     AL,WD_ENABLE+FDC_RESET ; TURN DRIVE 0 MOTOR OFF,
                                ; ENABLE TIMER
        OUT     0F2H,AL
        MOV     DX,VGA_CTL      ; VIDEO GATE ARRAY CONTROL
        IN      AL,DX           ; SYNC VGA TO ACCEPT REG
        MOV     AL,4            ; SET VGA RESET REG
        OUT     DX,AL           ; SELECT IT
        MOV     AL,1            ; SET ASYNC RESET
        OUT     DX,AL           ; RESET VIDEO GATE ARRAY
;----------------------------------------
; TEST 1                                :
;       8088 PROCESSOR TEST             :
; DESCRIPTION                           :
;       VERIFY 8088 FLAGS, REGISTERS    :
;       AND CONDITIONAL JUMPS           :
;                                       :
; MFG. ERROR CODE 0001H                 :
;----------------------------------------
        MOV     AH,0D5H         ; SET SF, CF, ZF, AND AF FLAGS ON
        SAHF    
        JNC     L4              ; GO TO ERR ROUTINE IF CF NOT SET
        JNZ     L4              ; GO TO ERR ROUTINE IF ZF NOT SET
        JNP     L4              ; GO TO ERR ROUTINE IF PF NOT SET
        JNS     L4              ; GO TO ERR ROUTINE IF SF NOT SET
        LAHF                    ; LOAD FLAG IMAGE TO AH
        MOV     CL,5            ; LOAD CNT REG WITH SHIFT CNT
        SHR     AH,CL           ; SHIFT AF INTO CARRY BIT POS
        JNC     L4              ; GO TO ERR ROUTINE IF AF NOT SET
        MOV     AL,40H          ; SET THE OF FLAG ON
        SHL     AL,1            ; SETUP FOR TESTING
        JNO     L4              ; GO TO ERR ROUTINE IF OF NOT SET
        XOR     AH,AH           ; SET AH = 0
        SAHF                    ; CLEAR SF, CF, ZF, AND PF
        JBE     L4              ; GO TO ERR ROUTINE IF CF ON
; GO TO ERR ROUTINE IF ZF ON
        JS      L4              ; GO TO ERR ROUTINE IF SF ON
        JP      L4              ; GO TO ERR ROUTINE IF PF ON
        LAHF                    ; LOAD FLAG IMAGE TO AH
        MOV     CL,5            ; LOAD CNT REG WITH SHIFT CNT
        SHR     AH,CL           ; SHIFT 'AF' INTO CARRY BIT POS
        JC      L4              ; GO TO ERR ROUTINE IF ON
        SHL     AH,1            ; CHECK THAT 'OF' IS CLEAR
        JO      L4              ; GO TO ERR ROUTINE IF ON
; ----- READ/WRITE THE 8088 GENERAL AND SEGMENTATION REGISTERS
;       WITH ALL ONE'S AND ZEROE'S.
        MOV     AX,0FFFFH       ; SETUP ONE'S PATTERN IN AX
        STC
L2:     MOV     DS,AX           ; WRITE PATTERN TO ALL REGS
        MOV     BX,DS
        MOV     ES,BX
        MOV     CX,ES
        MOV     SS,CX
        MOV     DX,SS
        MOV     SP,DX
        MOV     BP,SP
        MOV     SI,BP
        MOV     DI,SI
        JNC     L3
        XOR     AX,DI           ; PATTERN MAKE IT THRU ALL REGS
        JNZ     L4              ; NO - GO TO ERR ROUTINE
        CLC
        JMP     L2
L3:     OR      AX,DI           ; ZERO PATTERN MAKE IT THRU?
        JZ      L5              ; YES - GO TO NEXT TEST
L4:     MOV     DX,0010H        ; HANDLE ERROR
        MOV     AL,0            ;
        OUT     DX,AL           ; ERROR 0001
        INC     DX    
        OUT     DX,AL   
        INC     AL    
        OUT     DX,AL   
        HLT                     ; HALT
L5:
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
        MOV     AL,0FEH         ; SEND FE TO MFG
        OUT     10H,AL    
        MOV     AL,MODE_8255   
        OUT     CMD_PORT,AL     ; CONFIGURES I/O PORTS
        SUB     AX,AX           ; TEST PATTERN SEED = 0000
L6:     MOV     AL,AH   
        OUT     PORT_A,AL       ; WRITE PATTERN TO PORT A
        IN      AL,PORT_A       ; READ PATTERN FROM PORT A
        OUT     PORT_B,AL       ; WRITE PATTERN TO PORT B
        IN      AL,PORT_B       ; READ OUTPUT PORT
        CMP     AL,AH           ; DATA AS EXPECTED?
        JNE     L7              ; IF NOT, SOMETHING IS WRONG
        INC     AH              ; MAKE NEW DATA PATTERN
        JNZ     L6              ; LOOP TILL 255 PATTERNS DONE
        JMP     SHORT L8        ; CONTINUE IF DONE
L7:     MOV     BL,02H          ; SET ERROR FLAG (BH=00 NOW)
        JMP     E_MSG           ; GO ERROR ROUTINE
L8:     XOR     AL,AL   
        OUT     KBPORT,AL       ; CLEAR KB PORT
        IN      AL,PORT_C       ;
        AND     AL,00001000B    ; 64K CARD PRESENT?
        MOV     AL,1BH          ; PORT SETTING FOR 64K SYS
        JNZ     L9              ;
        MOV     AL,3FH          ; PORT SETTING FOR 128K SYS
L9:     MOV     DX,PAGREG       ;
        OUT     DX,AL           ;
        MOV     AL,00001101B    ; INITIALIZE OUTPUT PORTS
        OUT     PORT_B,AL       ;
;------------------------------------------------------------------
; PART 3
;       SET UP VIDEO GATE ARRAY AND 6845 TO GET MEMORY WORKING
;------------------------------------------------------------------
        MOV     AL,0FDH
        OUT     10H,AL          ;
        MOV     DX,03D4H        ; SET ADDRESS OF 6845
        MOV     BX,OFFSET VIDEO_PARMS ; POINT TO 6845 PARMS
        MOV     CX,M0040        ; SET PARM LEN
        XOR     AH,AH           ; AH IS REG #
L10:    MOV     AL,AH           ; GET 6845 REG #
        OUT     DX,AL
        INC     DX              ; POINT TO DATA PORT
        INC     AH              ; NEXT REG VALUE
        MOV     AL,CS:[BX]      ; GET TABLE VALUE
        OUT     DX,AL           ; OUT TO CHIP
        INC     BX              ; NEXT IN TABLE
        DEC     DX              ; BACK TO POINTER REG
        LOOP    L10
;   START VGA WITHOUT VIDEO ENABLED
        MOV     DX,VGA_CTL      ; SET ADDRESS OF VGA
        IN      AL,DX           ; BE SURE ADDR/DATA FLAG IS   
                                ; IN THE PROPER STATE                                
        MOV     CX,5            ; # OF REGISTERS
        XOR     AH,AH           ; AH IS REG COUNTER
L11:    MOV     AL,AH           ; GET REG #
        OUT     DX,AL           ; SELECT IT
        XOR     AL,AL           ; SET ZERO FOR DATA
        OUT     DX,AL
        INC     AH              ; NEXT REG
        LOOP    L11
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
        MOV     AL,0FCH
        OUT     10H,AL          ; MFG OUT=FC
; CHECK MODULE AT F000:0 (LENGTH 32K)
        XOR     SI,SI           ; INDEX OFFSET WITHIN SEGMENT OF
                                ; FIRST BYTE
        MOV     AX,CS           ; SET UP STACK SEGMENT
        MOV     SS,AX
        MOV     DS,AX           ; LOAD DS WITH SEGMENT OF ADDRESS
                                ; SPACE OF BIOS/BASIC
        MOV     CX,8000H        ; NUMBER OF BYTES TO BE TESTED, 32K
        MOV     SP,OFFSET Z1    ; SET UP STACK POINTER SO THAT
                                ; RETURN WILL COME HERE
        JMP     ROS_CHECKSUM    ; JUMP TO ROUTINE WHICH PERFORMS
                                ; CRC CHECK
L12:    JZ      L13             ; MODULE AT F000:0 OK, GO CHECK
                                ; OTHER MODULE AT F000:8000
        MOV     BX,0003H        ; SET ERROR CODE
        JMP     E_MSG           ; INDICATE ERROR
L13:    MOV     CX,8000H        ; LOAD COUNT (SI POINTING TO START
        JMP     ROS_CHECKSUM    ; OF NEXT MODULE AT THIS POINT)
L14:    JZ      L15             ; PROCEED IF NO ERROR
        MOV     BX,0004H        ; INDICATE ERROR
        JMP     E_MSG
L15:
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
        MOV     AL,0FBH
        OUT     10H,AL          ; SET MFG FLAG=FB
        MOV     CX,0400H        ; SET FOR 1K WORDS, 2K BYTES
        XOR     AX,AX   
        MOV     ES,AX           ; LOAD ES WITH 0000 SEGMENT
        JMP     PODSTG    
L16:    JNZ     L20             ; BAD STORAGE FOUND
        MOV     AL,0FAH         ; MFG OUT=FA
        OUT     10H,AL    
        MOV     CX,400H         ; 1024 WORDS TO BE TESTED IN THE
                                ; REGEN BUFFER
        IN      AL,PORT_A       ; WHERE IS THE REGEN BUFFER?
        CMP     AL,1BH          ; TOP OF 64K?
        MOV     AX,0F80H        ; SET POINTER TO THERE IF IT IS
        JE      L18   
        MOV     AH,1FH          ; OR SET POINTER TO TOP OF 128K
L18:    MOV     ES,AX   
        JMP     PODSTG          ;
L19:    JZ      L23
L20:    MOV     BH,04H          ; ERROR 04....
        IN      AL,PORT_C       ; GET CONFIG BITS
        AND     AL,00001000B    ; TEST FOR ATTRIB CARD PRESENT
        JZ      L21             ; WORRY ABOUT ODD/EVEN IF IT IS
        MOV     BL,CL   
        OR      BL,CH           ; COMBINE ERROR BITS IF IT ISN'T
        JMP     SHORT L22       ;
L21:    CMP     AH,02           ; EVEN BYTE ERROR? ERR 04XX
        MOV     BL,CL   
        JE      L22             ; MAKE INTO 05XX ERR
        INC     BH              ; MOVE AND POSSIBLY COMBINE
        OR      BL,CH           ; ERROR BITS

        CMP     AH,1            ; ODD BYTE ERROR
        JE      L22   
        INC     BH              ; MUST HAVE BEEN BOTH

L22:    JMP     E_MSG           ; - MAKE INTO 06XX
; RETEST HIGH 2K USING B8000 ADDRESS PATH
L23:    MOV     AL,0F9H         ; MFG OUT =F9
        OUT     10H,AL    
        MOV     CX,0400H        ; 1K WORDS
        MOV     AX,0BB80H       ; POINT TO AREA JUST TESTED WITH
                                ; DIRECT ADDRESSING

        MOV     ES,AX
        JMP     PODSTG
L24:    JZ      L25
        MOV     BX,0005H        ; ERROR 0005
        JMP     E_MSG
;------ SETUP STACK SEG AND SP
L25:    MOV     AX,0030H        ; GET STACK VALUE
        MOV     SS,AX           ; SET THE STACK UP
        MOV     SP,OFFSET TOS   ; STACK IS READY TO GO
        XOR     AX,AX           ; SET UP DATA SEG
        MOV     DS,AX
;------ SETUP CRT PAGE
        MOV     DATA_WORD[ACTIVE_PAGE-DATA],07
;------ SET PRELIMINARY MEMORY SIZE WORD
        MOV     BX,64
        IN      AL,PORT_C       ;
        AND     AL,08H          ; 64K CARD PRESENT?
        MOV     AL,1BH          ; PORT SETTING FOR 64K SYSTEM
        JNZ     L26             ; SET TO 64K IF NOT
        ADD     BX,64           ; ELSE SET FOR 128K
        MOV     AL,3FH          ; PORT SETTING FOR 128K SYSTEM
L26:    MOV     DATA_WORD[TRUE_MEM-DATA],BX
        MOV     DATA_AREA[PAGDAT-DATA],AL
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
        ASSUME  DS:XXDATA
        MOV     AX,XXDATA
        MOV     DS,AX
        MOV     MFG_TST,0F8H    ; SET UP MFG CHECKPOINT FROM THIS
                                ; POINT 
        CALL    MFG_UP          ; UPDATE MFG CHECKPOINT
        MOV     MFG_RTN,OFFSET MFG_OUT
        MOV     AX,CS
        MOV     MFG_RTN+2,AX    ; SET DOUBLEWORD POINTER TO MFG.
                                ; ERROR OUTPUT ROUTINE SO DIAGS.
                                ; DON'T HAVE TO DUPLICATE CODE

        ASSUME  CS:CODE,DS:ABS0
        MOV     AX,0
        MOV     DS,AX
;------ SET UP THE INTERRUPT VECTORS TO TEMP INTERRUPT
        MOV     CX,255          ; FILL ALL INTERRUPTS
        SUB     DI,DI           ; FIRST INTERRUPT LOCATION IS 0000
        MOV     ES,DI           ; SET ES=0000 ALSO
D3:     MOV     AX,OFFSET D11   ; MOVE ADDR OF INTR PROC TO TBL
        STOSW
        MOV     AX,CS           ; GET ADDR OF INTR PROC SEG
        STOSW
        LOOP    D3              ; VECTBL0
        MOV     EXST,OFFSET EXTAB ; SET UP EXT. SCAN TABLE
; SET UP BIOS INTERRUPTS
        MOV     DI,OFFSET VIDEO_INT ; SET UP VIDEO INT
        PUSH    CS
        POP     DS              ; PLACE CS IN DS
        MOV     SI,OFFSET VECTOR_TABLE+16
        MOV     CX,16
D4:     MOVSW                   ; MOVE INTERRUPT VECTOR TO LOW
                                ; MEMORY

        INC     DI              
        INC     DI              ; POINT TO NEXT VECTOR ENTRY
        LOOP    D4              ; REPEAT FOR ALL 16 BIOS INTERRUPTS
; SET UP DIAGNOSTIC INTERRUPTS
        MOV     DI,0200H        ; START WITH INT. 80H
        MOV     SI,DIAG_TABLE_PTR ; POINT TO ENTRY POINT TABLE
        MOV     CX,16           ; 16 ENTRIES
D5:     MOVSW                   ; MOVE INTERRUPT VECTOR TO LOW
                                ; MEMORY
        INC     DI
        INC     DI              ; POINT TO NEXT VECTOR ENTRY
        LOOP    D5              ; REPEAT FOR ALL 16 BIOS INTERRUPTS
        MOV     DS,CX           ; SET DS TO ZERO
        MOV     INT81,OFFSET LOCATEI
        MOV     INT82,OFFSET PRNT3
        MOV     INT89,OFFSET JOYSTICK

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
        ASSUME  CS:CODE,DS:ABS0
        MOV     BX,1118H        ; DEFAULT GAMEI0,40X25,NO DMA,48K ON
                                ; PLANAR
        IN      AL,PORT_C
        AND     AL,08H          ; 64K CARD PRESENT
        JNZ     D55             ; NO, JUMP
        OR      BL,4            ; SET 64K ON PLANAR
D55:    MOV     DATA_WORD[EQUIP_FLAG-DATA],BX
;-------------------------------------------------------------
; TEST 7
;       INITIALIZE AND TEST THE 8259 INTERRUPT CONTROLLER CHIP
; MFG ERR. CODE 07XX (XX=00, DATA PATH OR INTERNAL FAILURE,
;       XX=ANY OTHER BITS ON=UNEPECTED INTERRUPTS
;-------------------------------------------------------------
        CALL    MFG_UP          ; MFG CODE=F7
        ASSUME  DS:ABS0,CS:CODE
        MOV     AL,13H          ; ICW1 - RESET EDGE SENSE CIRCUIT,
                                ;SET SINGLE 8259 CHIP AND ICW4 READ
        OUT     INTA00,AL
        MOV     AL,8            ; ICW2 - SET INTERRUPT TYPE 8 (8-F)
        OUT     INTA01,AL
        MOV     AL,9            ; ICW4 - SET BUFFERED MODE/SLAVE
                                ;   AND 8086 MODE
        OUT     INTA01,AL
;-------------------------------------------------------------
;       TEST ABILITY TO WRITE/READ THE MASK REGISTER
;-------------------------------------------------------------
        MOV     AL,0             ; WRITE ZEROES TO IMR
        MOV     BL,AL            ; PRESET ERROR INDICATOR
        OUT     INTA01,AL        ; DEVICE INTERRUPTS ENABLED
        IN      AL,INTA01        ; READ IMR
        OR      AL,AL            ; IMR = 0?
        JNZ     GERROR           ; NO - GO TO ERROR ROUTINE
        MOV     AL,0FFH          ; DISABLE DEVICE INTERRUPTS
        OUT     INTA01,AL        ; WRITE ONES TO IMR
        IN      AL,INTA01        ; READ IMR
        ADD     AL,1             ; ALL IMR BITS ON?
                                 ; (ADD SHOULD PRODUCE 0)
        JNZ     GERROR           ; NO - GO TO ERROR ROUTINE
;-------------------------------------------------------------
;       CHECK FOR HOT INTERRUPTS
;-------------------------------------------------------------
;       INTERRUPTS ARE MASKED OFF.  NO INTERRUPTS SHOULD OCCUR.
        STI                     ; ENABLE EXTERNAL INTERRUPTS
        MOV     CX,50H
HOT1:   LOOP    HOT1            ; WAIT FOR ANY INTERRUPTS
        MOV     BL,DATA_AREA[INTR_FLAG-DATA] ; DID ANY INTERRUPTS
                                ;       OCCUR?
        OR      BL,BL
        JZ      END_TESTG       ; NO - GO TO NEXT TEST
GERROR: MOV     BH,07H          ; SET 07 SECTION OF ERROR MSG
        JMP     E_MSG
END_TESTG:
; FIRE THE DISKETTE WATCHDOG TIMER
        MOV     AL,WD_ENABLE+WD_STROBE+FDC_RESET
        OUT     0F2H,AL
        MOV     AL,WD_ENABLE+FDC_RESET
        OUT     0F2H,AL
        ASSUME  CS:CODE,DS:ABS0
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
;------------------------------------------------------------------
;       INITIALIZE TIMER 1 AND TIMER 0 FOR TEST
;------------------------------------------------------------------

        CALL    MFG_UP          ; MFG CKPOINT=F6
        MOV     AX,0176H        ; SET TIMER 1 TO MODE 3 BINARY
        MOV     BX,0FFFFH       ; INITIAL COUNT OF FFFF
        CALL    INIT_TIMER      ; INITIALIZE TIMER 1
        MOV     AX,0036H        ; SET TIMER 0 TO MODE 3 BINARY
                                ; INITIAL COUNT OF FFFF
        CALL    INIT_TIMER      ; INITIALIZE TIMER 0
;------------------------------------------------------------------
;       SET BIT 5 OF PORT A0 SO TIMER 1 CLOCK WILL BE PULSED BY THE
;       TIMER 0 OUTPUT RATHER THAN THE SYSTEM CLOCK.
;------------------------------------------------------------------
        MOV     AL,00100000B
        OUT     0A0H,AL
;---------------------------------------------------------------
;       CHECK IF ALL BITS GO ON AND OFF IN TIMER 0 (CHECK FOR STUCK
;          BITS)
;---------------------------------------------------------------
        MOV     AH,0            ; TIMER 0
        CALL    BITS_ON_OFF     ; LET SUBROUTINE CHECK IT
        JNB     TIMER1_NZ       ; NO STUCK BITS (CARRY FLAG NOT SET)
        MOV     BL,0            ; STUCK BITS IN TIMER 0
        JMP     TIMER_ERROR

;---------------------------------------------------------------
;       SINCE TIMER 0 HAS COMPLETED AT LEAST ONE COMPLETE CYCLE,
;       TIMER 1 SHOULD BE NON-ZERO.  CHECK THAT THIS IS THE CASE.
;---------------------------------------------------------------

TIMER1_NZ:
        IN      AL,TIMER+1      ; READ LSB OF TIMER 1
        MOV     AH,AL           ; SAVE LSB
        IN      AL,TIMER+1      ; READ MSB OF TIMER 1
        CMP     AX,0FFFFH       ; STILL FFFF?
        JNE     TIMER0_INTR     ; NO - TIMER 1 HAS BEEN BUMPED
        MOV     BL,1            ; TIMER 1 WAS NOT BUMPED BY TIMER 0
        JMP     TIMER_ERROR
;---------------------------------------------------------------
;       CHECK FOR TIMER 0 INTERRUPT
;---------------------------------------------------------------
TIMER0_INTR:
        STI                     ; ENABLE MASKABLE EXT INTERRUPTS
        IN      AL,INTA01
        AND     AL,0FEH         ; MASK ALL INTRS EXCEPT LVL 0
        AND     DATA_AREA[INTR_FLAG-DATA],AL ; CLEAR INTR RECEIVED
        OUT     INTA01,AL       ; WRITE THE 8259 IMR
        MOV     CX,0FFFFH       ; SET LOOP COUNT
WAIT_INTR_LOOP:
        TEST    DATA_AREA[INTR_FLAG-DATA],1 ; TIMER 0 INT OCCUR?
        JNE     RESET_INTRS     ; YES - CONTINUE
        LOOP    WAIT_INTR_LOOP  ; WAIT FOR INTR FOR SPECIFIED TIME
        MOV     BL,2            ; TIMER 0 INTR DIDN'T OCCUR
        JMP     SHORT TIMER_ERROR
;---------------------------------------------------------------
;       HOUSEKEEPING FOR TIMER 0 INTERRUPTS
;---------------------------------------------------------------
RESET_INTRS:
        CLI
; SET TIMER INT. TO POINT TO MFG. HEARTBEAT ROUTINE IF IN MFG MODE
        MOV     DX,201H
        IN      AL,DX           ; GET MFG. BITS
        AND     AL,0F0H
        CMP     AL,10H          ; SYS TEST MODE?
        JE      D6
        OR      AL,AL           ; OR BURN-IN MODE
        JNZ     TIME_1
D6:     MOV     INT_PTR,OFFSET MFG_TICK ; SET TO POINT TO MFG.
                                ; ROUTINE
        MOV     INT1C_PTR,OFFSET MFG_TICK ; ALSO SET USER TIMER INT
                                ; FOR DIAGS. USE
        MOV     AL,0FEH
        OUT     INTA01,AL
        STI
;---------------------------------------------------------------
;       RESET D5 OF PORT A0 SO THAT THE TIMER 1 CLOCK WILL BE
;       PULSED BY THE SYSTEM CLOCK.
;---------------------------------------------------------------
TIME_1: MOV     AL,0            ; MAKE AL = 00
        OUT     0A0H,AL
;------------------------------------------------------------------
;       CHECK FOR STUCK BITS IN TIMER 1
;------------------------------------------------------------------
        MOV     AH,1            ; TIMER 1
        CALL    BITS_ON_OFF
        JNB     TIMER2_INIT     ; NO STUCK BITS
        MOV     BL,3            ; STUCK BITS IN TIMER 1
        JMP     SHORT TIMER_ERROR
;------------------------------------------------------------------
;       INITIALIZE TIMER 2
;------------------------------------------------------------------
TIMER2_INIT:
        MOV     AX,02B6H        ; SET TIMER 2 TO MODE 3 BINARY
        MOV     BX,0FFFFH       ; INITIAL COUNT
        CALL    INIT_TIMER
;------------------------------------------------------------------
;       SET PB0 OF PORT_B OF 8255 (TIMER 2 GATE)
;------------------------------------------------------------------
        IN      AL,PORT_B       ; CURRENT STATUS
        OR      AL,00000001B    ; SET BIT 0 - LEAVE OTHERS ALONE
        OUT     PORT_B,AL
        MOV     AH,2            ; TIMER 2
        CALL    BITS_ON_OFF
        JNB     REINIT_T2       ; NO STUCK BITS
        MOV     BL,5            ; STUCK BITS IN TIMER 2
        JMP     SHORT TIMER_ERROR
;------------------------------------------------------------------
;       CHECK FOR STUCK BITS IN TIMER 2
;------------------------------------------------------------------
REINIT_T2:
; DROP GATE TO TIMER 2
        IN      AL,PORT_B       ; CURRENT STATUS
        AND     AL,11111110B    ; RESET BIT 0 - LEAVE OTHERS ALONE
        OUT     PORT_B,AL
        MOV     AX,02B0H        ; SET TIMER 2 TO MODE 0 BINARY
        MOV     BX,000AH        ; INITIAL COUNT OF 10
        CALL    INIT_TIMER
;---------------------------------------------------------------
;       RE-INITIALIZE TIMER 2 WITH MODE 0 AND A SHORT COUNT
;---------------------------------------------------------------
        IN      AL,PORT_C       ; CURRENT STATUS
        AND     AL,00100000B    ; MASK OFF OTHER BITS
        JZ      CK2_ON          ; IT'S LOW
        MOV     BL,4            ; PC5 OF PORT_C WAS HIGH WHEN IT
        JMP     SHORT TIMER_ERROR ; SHOULD HAVE BEEN LOW

CK2_ON: IN      AL,PORT_B       ; CURRENT STATUS
        OR      AL,00000001B    ; SET BIT 0 - LEAVE OTHERS ALONE
        OUT     PORT_B,AL
;------------------------------------------------------------------
;       CHECK PC5 OF PORT_C OF 8255 TO SEE IF THE OUTPUT OF TIMER 2
;       IS LOW
;------------------------------------------------------------------
        MOV     CX,000AH        ; WAIT FOR OUTPUT GO HIGH, SHOULD
CK2_LO: LOOP    CK2_LO          ; BE LONGER THAN INITIAL COUNT
        IN      AL,PORT_C       ; CURRENT STATUS
        AND     AL,00100000B    ; MASK OFF ALL OTHER BITS
        JNZ     POD13_END       ; IT'S HIGH - WE'RE DONE!
        MOV     BL,6            ; TIMER 2 OUTPUT DID NOT GO HIGH

;---------------------------------------------------------------
;       8253 TIMER ERROR OCCURRED.  SET BH WITH MAJOR ERROR
;       INDICATOR AND CALL E_MSG TO INFORM THE SYSTEM OF THE ERROR.
;       (BL ALREADY CONTAINS THE MINOR ERROR INDICATOR TO TELL
;       WHICH PART OF THE TEST FAILED.)
;---------------------------------------------------------------
TIMER_ERROR:
        MOV     BH,8                ; TIMER ERROR INDICATOR
        CALL    E_MSG
        JMP     SHORT POD13_END
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

LATCHES LABEL   BYTE
        DB      00H             ; LATCH MASK FOR TIMER 0
        DB      40H             ; LATCH MASK FOR TIMER 1
        DB      80H             ; LATCH MASK FOR TIMER 2

BITS_ON_OFF PROC    NEAR
        XOR     BX,BX           ; INITIALIZE BX REGISTER
        XOR     SI,SI           ; 1ST PASS - SI = 0
        MOV     DX,TIMER        ; BASE PORT ADDRESS FOR TIMERS
        ADD     DL,AH
        MOV     DI,OFFSET LATCHES ; SELECT LATCH MASK
        XOR     AL,AL           ; CLEAR AL
        XCHG    AL,AH           ; AH -> AL
        ADD     DI,AX           ; TIMER LATCH MASK INDEX
; 1ST PASS - CHECKS FOR ALL BITS TO COME ON
; 2ND PASS - CHECKS FOR ALL BITS TO GO OFF
OUTER_LOOP:
        MOV     CX,8            ; OUTER LOOP COUNTER
INNER_LOOP:
        PUSH    CX              ; SAVE OUTER LOOP COUNTER
        MOV     CX,0FFFFH       ; INNER LOOP COUNTER
TST_BITS:
        MOV     AL,CS:[DI]      ; TIMER LATCH MASK
        OUT     TIM_CTL,AL      ; LATCH TIMER
        PUSH    AX              ; PAUSE
        POP     AX
        IN      AL,DX           ; READ TIMER LSB
        OR      SI,SI
        JNE     SECOND          ; SECOND PASS
        OR      AL,01H          ; TURN LS BIT ON
        OR      BL,AL           ; TURN 'ON' BITS ON
        IN      AL,DX           ; READ TIMER MSB
        OR      BH,AL           ; TURN 'ON' BITS ON
        CMP     BX,0FFFFH       ; ARE ALL TIMER BITS ON?
        JMP     SHORT TST_CMP   ; DON'T CHANGE FLAGS
SECOND: 
        AND     BL,AL           ; CHECK FOR ALL BITS OFF
        IN      AL,DX           ; READ MSB
        AND     BH,AL           ; TURN OFF BITS
        OR      BX,BX           ; ALL OFF?
TST_CMP: 
        JE      CHK_END         ; YES - SEE IF DONE
        LOOP    TST_BITS        ; KEEP TRYING
        POP     CX              ; RESTORE OUTER LOOP COUNTER
        LOOP    INNER_LOOP      ; TRY AGAIN
        STC                     ; ALL TRIES EXHAUSTED - FAILED TEST
        RET
CHK_END: 
        POP     CX              ; POP FORMER OUTER LOOP COUNTER
        INC     SI
        CMP     SI,2
        JNE     OUTER_LOOP      ; CHECK FOR ALL BITS TO GO OFF
        CLC                     ; TIMER BITS ARE WORKING PROPERLY
        RET
BITS_ON_OFF     ENDP
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
MAVT            EQU     0A0ACH  ; MAXIMUM TIME FOR VERT/VERT
                                ; (NOMINAL + 10%)
MIVT            EQU     0C460H  ; MINIMUM TIME FOR VERT/VERT
                                ; (NOMINAL - 10%)
; NOMINAL TIME IS B286H FOR 60 hz.
EPF             EQU     200     ; NUMBER OF ENABLES PER FRAME
        CALL    MFG_UP          ; MFG. CHECKPOINT= F5
        CLI
        MOV     AL,01110000B    ; SET TIMER 1 TO MODE 0
        OUT     TIM_CTL,AL
        MOV     CX,8000H
Q1:     LOOP    Q1              ; WAIT FOR MODE SET TO "TAKE"
        MOV     AL,00H
        OUT     TIMER+1,AL      ; SEND FIRST BYTE TO TIMER
        SUB     AX,AX           ; SET MODE 40X25 - BW
        INT     10H
        MOV     AX,0507H        ; SET TO VIDEO PAGE 7
        INT     10H
        MOV     DX,03DAH        ; SET ADDRESSING TO VIDEO ARRAY
        SUB     CX,CX           ;
; LOOK FOR VERTICAL
Q2:     IN      AL,DX           ; GET STATUS
        TEST    AL,00001000B    ; VERTICAL THERE YET?
        JNE     Q3              ; CONTINUE IF IT IS
        LOOP    Q2              ; KEEP LOOKING TILL COUNT EXHAUSTED
        MOV     BL,00           ;
        JMP     SHORT Q115      ; NO VERTICAL = ERROR 0900
; GOT VERTICAL - START TIMER
Q3:     XOR     AL,AL           ;
        OUT     TIMER+1,AL      ; SEND 2ND BYTE TO TIMER TO START
        SUB     BX,BX           ; INIT. ENABLE COUNTER
; WAIT FOR VERTICAL TO GO AWAY
        XOR     CX,CX
Q4:     IN      AL,DX           ; GET STATUS
        TEST    AL,00001000B    ; VERTICAL STILL THERE?
        JZ      Q5              ; CONTINUE IF IT'S GONE
        LOOP    Q4              ; KEEP LOOKING TILL COUNT EXHAUSTED
        MOV     BL,01H
        JMP     SHORT Q115      ; VERTICAL STUCK ON = ERROR 0901
; NOW START LOOKING FOR ENABLE TITIONS
Q5:     SUB     CX,CX
Q6:     IN      AL,DX           ; GET STATUS
        TEST    AL,00000001B    ; ENABLE ON YET?
        JNE     Q7              ; GO ON IF IT IS
        TEST    AL,00001000B    ; VERTICAL ON AGAIN?
        JNE     Q11             ; CONTINUE IF IT IS
        LOOP    Q6              ; KEEP LOOKING IF NOT
        MOV     BL,02H
        JMP     SHORT Q115      ; ENABLE STUCK OFF = ERROR 0902
; MAKE SURE VERTICAL WENT OFF WINABLE GOING ON
Q7:     TEST    AL,00001000B    ; VERTICAL OFF?
        JZ      Q8              ; GO ON IF IT IS
        MOV     BL,03H
        JMP     SHORT Q115      ; VERTICAL STUCK ON = ERROR 0903
; NOW WAIT FOR ENABLE TO GO OFF
Q8:     SUB     CX,CX
Q9:     IN      AL,DX           ; GET STATUS
        TEST    AL,00000001B    ; ENABLE OFF YET?
        JZ      Q10             ; PROCEED IF IT IS
        LOOP    Q9              ; KEEP LOOKING IF NOT YET LOW
        MOV     BL,04H
        JMP     SHORT Q115      ; ENABLE STUCK ON = ERROR 0904
; ENABLE HAS TOGGLED, BUMP COUNTER AND TEST FOR NEXT VERTICAL
Q10:    INC     BX              ; BUMP ENABLE COUNTER
        JZ      Q11             ; IF COUNTER WRAPS, ERROR
; DID ENABLE GO LOW BECAUSE OF
        TEST    AL,00001000B    ; VERTICAL?
        JZ      Q5              ; IF NOT, LOOK FOR ANOTHER ENABLE
                                ;   TOGGLE
; HAVE HAD COMPLETE VERTICAL-VERTICAL CYCLE, NOW TEST RESULTS
Q11:    MOV     AL,40H          ; LATCH TIMER1
        OUT     TIM_CTL,AL      ;
        CMP     BX,EPF          ; NUMBER OF ENABLES BETWEEN
                                ; VERTICALS O.K.?

        JE      Q12             ;
        MOV     BL,05H          ;
Q115:   JMP     SHORT Q22       ; WRONG # ENABLES = ERROR 0905
Q12:    IN      AL,TIMER+1      ; GET TIMER VALUE LOW
        MOV     AH,AL           ; SAVE IT
; IBM listing has a bare 90 byte here.  Emit it as NOP.
        NOP                     ;
        IN      AL,TIMER+1      ; GET TIMER HIGH
        XCHG    AH,AL           ;
        STI                     ; INTERRUPTS BACK ON
        NOP                     
        CMP     AX,MAVT         ;
        JGE     Q13             ;
        MOV     BL,06H          ;
        JMP     SHORT Q22       ; VERTICALS TOO FAR APART
                                ; = ERROR 0906
Q13:    CMP     AX,MIVT         ;
        JLE     Q14             ;
        MOV     BL,07H          ;
        JMP     SHORT Q22       ; VERTICALS TOO CLOSE TOGETHER
                                ; = ERROR 0907
; TIMINGS SEEM O.K., NOW CHECK VERTICAL INTERRUPT (LEVEL 5)
Q14:    SUB     CX,CX               ; SET TIMEOUT REG
        IN      AL,INTA01           ;
        AND     AL,11011111B        ; UNMASK INT. LEVEL 5
        OUT     INTA01,AL           ;
        AND     DATA_AREA[INTR_FLAG-DATA],AL
        STI                         ; ENABLE INTS.
Q15:    TEST    DATA_AREA[INTR_FLAG-DATA],00100000B ; SEE IF INTR.
                                    ; 5 HAPPENED YET
        JNZ     Q16                 ; GO ON IF IT DID
        LOOP    Q15                 ; KEEP LOOKING IF IT DIDN'T
        MOV     BL,08H              ;
        JMP     SHORT Q22           ; NO VERTICAL INTERRUPT
                                    ; = ERROR 0908

Q16:    IN      AL,INTA01           ; DISABLE INTERRUPTS FOR LEVEL 5
        OR      AL,00100000B        ;
        OUT     INTA01,AL           ;
; SEE IF RED, GREEN, BLUE AND INTENSIFY DOTS WORK
; FIRST, SET A LINE OF REVERSE VIDEO, INTENSIFIED BLANKS INTO VIDEO
; BUFFER
        MOV     AX,09DBH            ; WRITE CHARS, BLOCKS
        MOV     BX,077FH            ; PAGE 7, REVERSE VIDEO,
                                    ;     HIGH INTENSITY
        MOV     CX,40               ; 40 CHARACTERS
        INT     10H                 ;
        XOR     AX,AX               ; START WITH BLUE DOTS
Q17:    SUB     CX,CX               ;
        OUT     DX,AL               ; SET VIDEO ARRAY ADDRESS FOR DOTS

Q18:    IN      AL,DX               ; GET STATUS
        TEST    AL,00010000B        ; DOT THERE?
        JNZ     Q19                 ; GO LOOK FOR DOT TO TURN OFF
        LOOP    Q18                 ; CONTINUE TESTING FOR DOT ON
        MOV     BL,10H              ;
        OR      BL,AH               ; OR IN DOT BEING TESTED
        JMP     SHORT Q22           ; DOT NOT COMING ON = ERROR 091X
                                    ; ( X=0, BLUE; X=1, GREEN;
                                    ;   X=2, RED; X=3, INTENSITY)
; SEE IF DOT GOES OFF
Q19:    SUB     CX,CX               ;
Q20:    IN      AL,DX               ; GET STATUS
        TEST    AL,00010000B        ; IS DOT STILL ON?
        JE      Q21                 ; GO ON IF DOT OFF
        LOOP    Q20                 ; ELSE, KEEP WAITING FOR DOT
                                    ;     TO GO OFF
        MOV     BL,20H              ;
        OR      BL,AH               ; OR IN DOT BEING TESTED
        JMP     SHORT Q22           ; DOT STUCK ON = ERROR 092X
                                    ; (X=0, BLUE; X=1, GREEN;
                                    ;  X=2, RED; X=3, INTENSITY)
; ADJUST TO POINT TO NEXT DOT
Q21:    INC     AH                  ;
        CMP     AH,4                ; ALL 4 DOTS DONE?
        JE      Q23                 ; GO END
        MOV     AL,AH               ;
        JMP     Q17                 ; GO LOOK FOR ANOTHER DOT
Q22:    MOV     BH,09H              ; SET MSB OF ERROR CODE
        JMP     E_MSG               ;
; DONE WITH TEST RESET TO 40X25 - COLOR
        ASSUME  DS:DATA
Q23:    CALL    DDS                 ;
        MOV     AX,0001H            ; INIT TO 40X25 - COLOR
        INT     10H                 ;
        MOV     AX,0507H            ; SET TO VIDEO PAGE 7
        INT     10H                 ;
        CMP     RESET_FLAG,1234H    ; WARM START?
        JE      Q24                 ; BYPASS PUTTING UP POWER-ON SCREEN
        CALL    PUT_LOGO            ; PUT LOGO ON SCREEN
Q24:    MOV     AL,01110110B        ; RE-INIT TIMER 1
        OUT     TIM_CTL,AL          ;
        MOV     AL,00H
        OUT     TIMER+1,AL
        NOP
        NOP
        OUT     TIMER+1,AL

        ASSUME  DS:ABS0
        CALL    MFG_UP              ; MFG CHECKPOINT=F4
        XOR     AX,AX
        MOV     DS,AX
        MOV     NMI_PTR,OFFSET KBDNMI ; SET INTERRUPT VECTOR
        MOV     KEY62_PTR,OFFSET KEY_SCAN_SAVE ; SET VECTOR FOR
                                    ; POD INT HANDLER
        PUSH    CS
        POP     AX
        MOV     KEY62_PTR+2,AX
        ASSUME  DS:DATA
        CALL    DDS                 ; SET DATA SEGMENT
        MOV     SI,OFFSET KB_BUFFER ; SET KEYBOARD PARMS
        MOV     BUFFER_HEAD,SI
        MOV     BUFFER_TAIL,SI
        MOV     BUFFER_START,SI
        ADD     SI,32               ; SET DEFAULT BUFFER OF 32 BYTES
        MOV     BUFFER_END,SI
        IN      AL,0A0H             ; CLEAR NMI F/F
        MOV     AL,80H              ; ENABLE NMI
        OUT     0A0H,AL             ;

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
        CALL    MFG_UP          ; MFG CHECKPOINT=F3
        MOV     BX,64           ; START WITH BASE 64K
        IN      AL,PORT_C       ; GET CONFIG BYTE
        TEST    AL,00001000B    ; SEE IF 64K CARD INSTALLED
        JNE     Q25             ; (BIT 4 WILL BE 0 IF CARD PLUGGED)
        ADD     BX,64           ; ADD 64K
Q25:    PUSH    BX              ; SAVE K COUNT
        SUB     BX,16           ; SUBTRACT 16K CRT REFRESH SPACE
        MOV     [MEMORY_SIZE],BX ; LOAD "CONTIGUOUS MEMORY" WORD
        POP     BX
        MOV     DX,2000H        ; SET POINTER TO JUST ABOVE 128K
        SUB     DI,DI           ; SET DI TO POINT TO BEGINNING
        MOV     CX,0AA55H       ; LOAD DATA PATTERN
Q26:    MOV     ES,DX           ; SET SEGMENT TO POINT TO MEMORY
        MOV     ES:[DI],CX      ; SPACE
        MOV     AL,0FH          ; SET DATA PATTERN TO MEMORY
        MOV     AX,ES:[DI]      ; SET AL TO ODD VALUE
        XOR     AX,CX           ; GET DATA PATTERN BACK FROM MEM
        JNZ     Q27             ; SEE IF DATA MADE IT BACK
; NO? THEN END OF MEM HAS BEEN
; REACHED
        ADD     DX,1000H        ; POINT TO BEGINNING OF NEXT 64K
        ADD     BX,64           ; ADJUST TOTAL MEM. COUNTER
        CMP     DH,0A0H         ; PAST 640K YET?
        JNE     Q26             ; CHECK FOR ANOTHER BLOCK IF NOT
Q27:    MOV     [TRUE_MEM],BX   ; LOAD "TOTAL MEMORY" WORD
; SIZE HAS BEEN DETERMINED, NOW TEST OR CLEAR ALL OF MEMORY
        MOV     AX,4            ; 4 KB KNOWN OK AT THIS POINT
        CALL    Q35
        MOV     DX,0080H        ; SET POINTER TO JUST ABOVE
                                ; LOWER 2K
        MOV     CX,7800H        ; TEST 30K WORDS (60KB)
Q28:    MOV     ES,DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        CALL    PODSTG          ; TEST OR FILL MEM
        JZ      Q29             
        JMP     Q39             ; JUMP IF ERROR
Q29:    POP     AX
        POP     BX
        POP     CX
        CMP     CH,78H          ; WAS THIS A 60 K PASS
        PUSHF
        ADD     AX,60           ; BUMP GOOD STORAGE BY 60 KB
        POPF
        JE      Q30
        ADD     AX,2            ; ADD 2 FOR A 62K PASS
Q30:    CALL    Q35
        CMP     AX,BX           ; ARE WE DONE YET?
        JNE     Q31
        JMP     Q43             ; ALL DONE, IF SO
Q31:    CMP     AX,128          ; DONE WITH 1ST 128K?
        JE      Q32             ; GO FINISH REST OF MEM.
        MOV     DX,0F80H        ; SET POINTER TO FINISH 1ST 64 KB
        MOV     CX,0400H
        MOV     ES,DX
        PUSH    AX
        PUSH    BX
        PUSH    DX
        CALL    PODSTG          ; GO TEST/FILL
        JNZ     Q39             ;
        POP     DX
        POP     BX
        POP     AX
        ADD     AX,2            ; UPDATE GOOD COUNT
        MOV     DX,1000H        ; SET POINTER TO 2ND 64K BLOCK
        MOV     CX,7C00H        ; 62K WORTH
        JMP     Q28             ; GO TEST IT
Q32:    MOV     DX,2000H        ; POINT TO BLOCK ABOVE 128K
Q33:    CMP     BX,AX           ; COMPARE GOOD MEM TO TOTAL MEM
        JNE     Q34
        JMP     Q43             ; EXIT IF ALL DONE
Q34:    MOV     CX,4000H        ; SET FOR 32KB BLOCK
        MOV     ES,DX
        PUSH    AX
        PUSH    BX
        PUSH    DX
        CALL    PODSTG          ; GO TEST/FILL
        JNZ     Q39             ;
        POP     DX
        POP     BX
        POP     AX
        ADD     AX,32           ; BUMP GOOD MEMORY COUNT
        CALL    Q35             ; DISPLAY CURRENT GOOD MEM
        ADD     DH,08H          ; SET POINTER TO NEXT 32K
        JMP     Q33             ; AND MAKE ANOTHER PASS
;---------------------------------------------
;    SUBROUTINE FOR PRINTING TESTED
;    MEMORY OK MSG ON THE CRT
; CALL PARMS: AX = K OF GOOD MEMORY
;             (IN HEX)
;---------------------------------------------
Q35     PROC    NEAR
        CALL    DDS             ; ESTABLISH ADDRESSING
        CMP     RESET_FLAG,1234H ; WARM START?
        JE      Q35E            ; NO PRINT ON WARM START
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    AX              ; SAVE WORK REGS
        MOV     AH,2            ; SET CURSOR TOWARD THE END OF
        MOV     DX,1421H        ; ROW 20 (ROW 20, COL. 33)
        MOV     BH,7            ; PAGE 7
        INT     10H
        POP     AX              ;
        PUSH    AX
        MOV     BX,10           ; SET UP FOR DECIMAL CONVERT
        MOV     CX,3            ; OF 3 NIBBLES
Q36:    XOR     DX,DX           ;
        DIV     BX              ; DEVIDE BY 10
        OR      DL,30H          ; MAKE INTO ASCII
        PUSH    DX              ; SAVE
        LOOP    Q36             ;
        MOV     CX,3            ;
Q37:    POP     AX              ; RECOVER A NUMBER
        CALL    PRT_HEX
        LOOP    Q37
        MOV     CX,3
        MOV     SI,OFFSET F3B   ; PRINT " KB"
Q38:    MOV     AL,CS:[SI]
        INC     SI
        CALL    PRT_HEX
        LOOP    Q38
        POP     AX
        POP     DX
        POP     CX
        POP     BX
Q35E:   RET
Q35     ENDP
; ON ENTRY TO MEMORY ERROR ROUTINE, CX HAS ERROR BITS
; AH HAS ODD/EVEN INFO, OTHER USEFUL INFO ON THE STACK
Q39:    POP     DX              ; POP SEGMENT POINTER TO DX
;                               ; (HEADING DOWNHILL, DON'T CARE
;                               ; ABOUT STACK)
        CMP     DX,2000H        ; ABOVE 128K (THE SIMPLE CASE)
        JL      Q40             ; GO DO ODD/EVEN-LESS THAN 128K
        MOV     BL,CL           ; FORM ERROR BITS ("XX")
        OR      BL,CH
        MOV     CL,4            ;
        SHR     DH,CL           ; ROTATE MOST SIGNIFICANT
                                ; NIBBLE OF SEGMENT
        MOV     BH,10H          ; TO LOW NIBBLE OF DH
        OR      BH,DH           ; FORM "1Y" VALUE
        JMP     SHORT Q42
Q40:    MOV     BH,0AH          ; ERROR 0A....
        IN      AL,PORT_C       ; GET CONFIG BITS
        AND     AL,00001000B    ; TEST FOR ATTRIB CARD PRESENT
        JZ      Q41             ; WORRY ABOUT ODD/EVEN IF IT IS
        MOV     BL,CL
        OR      BL,CH           ; COMBINE ERROR BITS IF IT ISN'T
        JMP     SHORT Q42       ;
Q41:    CMP     AH,02           ; EVEN BYTE ERROR? ERR 0AXX
        MOV     BL,CL
        JE      Q42
        INC     BH              ; MAKE INTO 0BXX ERR
        OR      BL,CH           ; MOVE AND COMBINE ERROR BITS
        CMP     AH,1            ; ODD BYTE ERROR
        JE      Q42
        INC     BH              ; MUST HAVE BEEN BOTH
                                ; - MAKE INTO 0CXX
Q42:    MOV     SI,OFFSET MEM_ERR
        CALL    E_MSG           ; LET ERROR ROUTINE FIGURE OUT
                                ; WHAT TO DO
                                ;
        CLI
        HLT
Q43:
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
        CALL    MFG_UP          ; MFG CODE=F2
        CALL    DDS             ; ESTABLISH ADDRESSING
        MOV     BX,OFFSET KB_BUFFER
        MOV     AL,[BX]         ; CHECK FOR STUCK KEYS
        OR      AL,AL           ; SCAN CODE = 0?
        JE      F6_Y            ; YES - CONTINUE TESTING
        MOV     BH,22H          ; 22XX ERROR CODE
        MOV     BL,AL           ;
        JMP     SHORT F6
F6_Y:   CMP     KBD_ERR,00H     ; DID NMI'S HAPPEN WITH NO SCAN
                                ; CODE PASSED?
        JE      F7              ; (STRAYS) - CONTINUE IF NONE
        MOV     BX,2000H        ; SET ERROR CODE 2000
F6:     MOV     SI,OFFSET KEY_ERR ; GET MSG ADDR
        CMP     RESET_FLAG,4321H ; WARM START TO DIAGS
        JE      F6_Z            ; DO NOT PUT UP MESSAGE
        CMP     RESET_FLAG,1234H ; WARM SYSTEM START
        JE      F6_Z            ; DO NOT PUT UP MESSAGE
        CALL    E_MSG           ; PRINT MSG ON SCREEN
F6_Z:   JMP     F6_X
; CHECK LINK CARD, IF PRESENT
F7:     MOV     DX,0201H        ; CHECK FOR BURN-IN MODE
        IN      AL,DX           ; GET CONFIG. PORT DATA
        AND     AL,0F0H         ; BYPASS CHECK IN BURN-IN MODE
        JZ      F6_X            ; KEYBOARD CABLE ATTACHED?
        IN      AL,PORT_C       ; BYPASS TEST IF IT IS
        AND     AL,10000000B    ;
        JZ      F6_X            ;
        IN      AL,PORT_B       ;
        AND     AL,11111100B    ; DROP SPEAKER DATA
        OUT     PORT_B,AL       ;
        MOV     AL,0B6H         ; MODE SET TIMER 2
        OUT     TIM_CTL,AL      ;
        MOV     AL,040H         ; DISABLE NMI
        OUT     0A0H,AL         ;
        MOV     AL,32           ; LSB TO TIMER 2
                                ; (APPROX. 40Khz VALUE)
        MOV     DX,TIMER+2
        OUT     DX,AL
        SUB     AX,AX
        MOV     CX,AX
        OUT     DX,AL           ; MSB TO TIMER 2 (START TIMER)
        IN      AL,PORT_B
        OR      AL,1
        OUT     PORT_B,AL       ; ENABLE TIMER 2
F7_0:   IN      AL,PORT_C       ; SEE IF KEYBOARD DATA ACTIVE
        AND     AL,01000000B    ;
        JNZ     F7_1            ; EXIT LOOP IF DATA SHOWED UP
        LOOP    F7_0
        MOV     BL,02H          ; SET NO KEYBOARD DATA ERROR
        JMP     SHORT F6_1
F7_1:   PUSH    ES              ; SAVE ES
        SUB     AX,AX           ; SET UP SEGMENT REG
        MOV     ES,AX           ; *
        MOV     ES:[NMI_PTR],OFFSET D11 ; SET UP NEW NMI VECTOR
        MOV     INTR_FLAG,AL    ; RESET INTR FLAG
        IN      AL,PORT_B       ; DISABLE INTERNAL BEEPER TO
        OR      AL,00110000B    ; PREVENT ERROR BEEP
        OUT     PORT_B,AL
        MOV     AL,0C0H
        OUT     0A0H,AL         ; ENABLE NMI
        MOV     CX,0100H        ;
F6_0:   LOOP    F6_0            ; WAIT A BIT
        IN      AL,PORT_B       ; RE-ENABLE BEEPER
        AND     AL,11001111B
        OUT     PORT_B,AL
        MOV     AL,INTR_FLAG    ; GET INTR FLAG
        OR      AL,AL           ; WILL BE NON-ZERO IF NMI HAPPENED
        MOV     BL,03H          ; SET POSSIBLE ERROR CODE
        MOV     ES:[NMI_PTR],OFFSET KBDNMI ; RESET NMI VECTOR
        POP     ES              ; RESTORE ES
        JZ      F6_1            ; JUMP IF NO NMI
        MOV     AL,00H          ; DISABLE FEEDBACK CKT
        OUT     0A0H,AL         ;
        IN      AL,PORT_B       ;
        AND     AL,11111110B    ; DROP GATE TO TIMER 2
        OUT     PORT_B,AL       ;
F6_2:   IN      AL,PORT_C       ; SEE IF KEYBOARD DATA ACTIVE
        AND     AL,01000000B
        JZ      F6_X            ; EXIT LOOP IF DATA WENT LOW
        LOOP    F6_2            ;
        MOV     BL,01H          ; SET KEYBOARD DATA STUCK HIGH ERR
F6_1:   MOV     BH,21H          ; POST ERROR "21XX"
        JMP     F6              ;
F6_X:   MOV     AL,00H          ; DISABLE FEEDBACK CKT
        OUT     0A0H,AL         ;
;--------------------------------------------
;       CASSETTE INTERFACE TEST
; DESCRIPTION
;       TURN CASSETTE MOTOR OFF. WRITE A BIT OUT TO THE
;       CASSETTE DATA BUS. VERIFY THAT CASSETTE DATA
;       READ IS WITHIN A VALID RANGE.
;  MFG. ERROR CODE=2300H (DATA PATH ERROR)
;                  23FF (RELAY FAILED TO PICK)
;--------------------------------------------
MAX_PERIOD     EQU     0A9AH    ; NOM.+10%
MIN_PERIOD     EQU     08ADH    ; NOM -10%
;------ TURN THE CASSETTE MOTOR OFF
        CALL    MFG_UP          ; MFG CODE=F1
        IN      AL,PORT_B
        OR      AL,00001001B    ; SET TIMER 2 SPK OUT, AND CASSETTE
        OUT     PORT_B,AL       ; OUT BITS ON, CASSETTE MOT OFF
;------ WRITE A BIT
        IN      AL,INTA01       ; DISABLE TIMER INTERRUPTS
        OR      AL,01H
        OUT     INTA01,AL
        MOV     AL,0B6H         ; SEL TIM 2, LSB, MSB, MD 3
        OUT     TIMER+3,AL      ; WRITE 8253 CMD/MODE REG
        MOV     AX,1234         ; SET TIMER 2 CNT FOR 1000 USEC
        OUT     TIMER+2,AL      ; WRITE TIMER 2 COUNTER REG
        MOV     AL,AH           ; WRITE MSB
        OUT     TIMER+2,AL
        SUB     CX,CX           ; CLEAR COUNTER FOR LONG DELAY
        LOOP    $               ; WAIT FOR COUNTER TO INIT
;------ READ CASSETTE INPUT
        IN      AL,PORT_C       ; READ VALUE OF CASS IN BIT
        AND     AL,10H          ; ISOLATE FROM OTHER BITS
        MOV     LAST_VAL,AL
        CALL    READ_HALF_BIT   ; TO SET UP CONDITIONS FOR CHECK
        CALL    READ_HALF_BIT
        JCXZ    F8              ; CAS_ERR
        PUSH    BX              ; SAVE HALF BIT TIME VALUE
        CALL    READ_HALF_BIT
        POP     AX              ; GET TOTAL TIME
        JCXZ    F8              ; CAS_ERR
        ADD     AX,BX
        CMP     AX,MAX_PERIOD
        JNC     F8              ; CAS_ERR
        CMP     AX,MIN_PERIOD
        JC      F8
        MOV     DX,201H
        IN      AL,DX
        AND     AL,0F0H         ; DETERMINE MODE
        CMP     AL,00010000B    ; MFG?
        JE      F9
        CMP     AL,01000000B    ; SERVICE?
        JNE     T13_END         ; GO TO NEXT TEST IF NOT
; CHECK THAT CASSETTE RELAY IS PICKING (CAN'T DO TEST IN NORMAL
; MODE BECAUSE OF POSSIBILITY OF WRITING ON CASSETTE IF "RECORD"
; BUTTON IS DEPRESSED.)
F9:     IN      AL,PORT_B       ; SAVE PORT B CONTENTS
        MOV     DL,AL
        AND     AL,11100101B    ; SET CASSETTE MOTOR ON
        OUT     PORT_B,AL       ;
        XOR     CX,CX           ;
F91:    LOOP    F91             ; WAIT FOR RELAY TO SETTLE
        CALL    READ_HALF_BIT
        CALL    READ_HALF_BIT
        MOV     AL,DL           ; DROP RELAY
        OUT     PORT_B,AL
        JCXZ    T13_END         ; READ_HALF_BIT SHOULD TIME OUT IN
                                ; THIS SITUATION
        MOV     BX,23FFH        ; ERROR 23FF
        JMP     SHORT F81
F8:                             ; CAS_ERR
        MOV     BX,2300H        ; ERR. CODE 2300H
F81:    MOV     SI,OFFSET CASS_ERR ; CASSETTE WRAP FAILED
        CALL    E_MSG           ; GO PRINT ERROR MSG
T13_END:
        IN      AL,INTA01       ; ENABLE TIMER INTS
        AND     AL,0FEH
        OUT     INTA01,AL
        IN      AL,NMI_PORT     ; CLEAR NMI FLIP/FLOP
        MOV     AL,80H          ; ENABLE NMI INTERRUPTS
        OUT     NMI_PORT,AL
;-------------------------------------------------------------------
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
;-------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
;---------------------------------------------------------------
;       TEST SERIAL PRINTER INS8250 UART
;---------------------------------------------------------------
        CALL    MFG_UP          ; MFG ROUTINE INDICATOR=F0
        MOV     DX,02F8H        ; ADDRESS OF SERIAL PRINTER CARD
        CALL    UART            ; ASYNCH. COMM. ADAPTER POD
        JNC     TM              ; PASSED
        MOV     SI,OFFSET COM1_ERR ; CODE FOR DISPLAY
        CALL    E_MSG           ; REPORT ERROR
;---------------------------------------------------------------
;       TEST MODEM INS8250 UART
;---------------------------------------------------------------
TM:     CALL    MFG_UP          ; MFG ROUTINE INDICATOR = EF
        IN      AL,PORT_C       ; TEST FOR MODEM CARD PRESENT
        AND     AL,00000010B    ; ONLY CONCERNED WITH BIT 1
        JNE     TM1             ; IT'S NOT THERE - DONE WITH TEST
        MOV     DX,03F8H        ; ADDRESS OF MODEM CARD
        CALL    UART            ; ASYNCH. COMM. ADAPTER POD
        JNC     TM1             ; PASSED
        MOV     SI,OFFSET COM2_ERR ; MODEM ERROR
        CALL    E_MSG           ; REPORT ERROR
TM1:
;---------------------------------------------------------------
;       SETUP HARDWARE INT. VECTOR TABLE
;---------------------------------------------------------------
        ASSUME  CS:CODE,DS:ABS0
        SUB     AX,AX
        MOV     ES,AX
        MOV     CX,08           ; GET VECTOR CNT
        PUSH    CS              ; SETUP DS SEG REG
        POP     DS
        MOV     SI,OFFSET VECTOR_TABLE
        MOV     DI,OFFSET INT_PTR
F7A:    MOVSW
        INC     DI              ; SKIP OVER SEGMENT
        INC     DI
        LOOP    F7A
;----- SET UP OTHER INTERRUPTS AS NECESSARY
        ASSUME  DS:ABS0
        MOV     DS,CX
        MOV     INT5_PTR,OFFSET PRINT_SCREEN ; PRINT SCREEN
        MOV     KEY62_PTR,OFFSET KEY62_INT ; 62 KEY CONVERSION
        MOV     WORD PTR CSET_PTR,OFFSET CRT_CHAR_GEN ; DOT TABLE
        MOV     BASIC_PTR,OFFSET BAS_ENT ; CASSETTE BASIC ENTRY
        PUSH    CS
        POP     AX
        MOV     WORD PTR BASIC_PTR+2,AX ; CODE SEGMENT FOR CASSETTE
;---------------------------------------------------------------
; CHECK FOR OPTIONAL ROM FROM C0000 TO F0000 IN 2K BLOCKS
;       (A VALID MODULE HAS '55AA' IN THE FIRST 2 LOCATIONS,
;       LENGTH INDICATOR (LENGTH/512) IN THE 3D LOCATION AND
;       TEST/INIT. CODE STARTING IN THE 4TH LOCATION.)
;       MFG ERR CODE 25XX (XX=MSB OF SEGMENT THAT HAS CRC CHECK)
;---------------------------------------------------------------
        MOV     AL,01H
        OUT     13H,AL
        CALL    MFG_UP          ; MFG ROUTINE = EE
        MOV     DX,0C000H       ; SET BEGINNING ADDRESS
ROM_SCAN_1:
        MOV     DS,DX
        SUB     BX,BX           ; SET BX=0000
        MOV     AX,[BX]         ; GET 1ST WORD FROM MODULE
        PUSH    BX
        POP     BX              ; BUS SETTLING
        CMP     AX,0AA55H       ; = TO ID WORD?
        JNZ     NEXT_ROM        ; PROCEED TO NEXT ROM IF NOT
        CALL    ROM_CHECK       ; GO CHECK OUT MODULE
        JMP     SHORT ARE_WE_DONE ; CHECK FOR END OF ROM SPACE
NEXT_ROM:
        ADD     DX,0080H        ; POINT TO NEXT 2K ADDRESS
ARE_WE_DONE:
        CMP     DX,0F000H       ; AT F0000 YET?
        JL      ROM_SCAN_1      ; GO CHECK ANOTHER ADD. IF NOT
;------------------------------------------------------------------
;       DISKETTE ATTACHMENT TEST
; DESCRIPTION
;       CHECK IF IPL DISKETTE DRIVE IS ATTACHED TO SYSTEM.  IF
;       ATTACHED, VERIFY STATUS OF NEC FDC AFTER A RESET. ISSUE
;       A RECAL AND SEEK CMD TO FDC AND CHECK STATUS. COMPLETE
;       SYSTEM INITIALIZATION THEN PASS CONTROL TO THE BOOT
;       LOADER PROGRAM.
;  MFG ERR CODES: 2601 RESET TO DISKETTE CONTROLLER CD. FAILED
;                 2602 RECALIBRATE TO DISKETTE DRIVE FAILED
;                 2603 WATCHDOG TIMER FAILED
;------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
        CALL    MFG_UP          ; MFG ROUTINE = ED
        CALL    DDS             ; POINT TO DATA AREA
        MOV     AL,0FFH
        MOV     TRACK0,AL       ; INIT DISKETTE SCRATCHPADS
        MOV     TRACK1,AL
        MOV     TRACK2,AL
        IN      AL,PORT_C       ; DISKETTE PRESENT?
        AND     AL,00000100B
        JZ      F10_0
        JMP     F15
F10_0:  OR      BYTE PTR EQUIP_FLAG,01H ; SET IPL DISKETTE
                                ; INDICATOR IN EQUIP. FLAG
        CMP     RESET_FLAG,0    ; RUNNING FROM POWER-ON STATE?
        JNE     F10             ; BYPASS WATCHDOG TEST
        MOV     AL,00001010B    ; READ INT. REQUEST REGISTER CMD
        OUT     INTA00,AL
        IN      AL,INTA00
        AND     AL,01000000B    ; HAS WATCHDOG GONE OFF?
        JNZ     F10             ; PROCEED IF IT HAS
        MOV     BL,03H          ; SET ERROR CODE
        JMP     SHORT F13
F10:    MOV     AL,FDC_RESET
        OUT     0F2H,AL         ; DISABLE WATCHDOG TIMER
        MOV     AH,0            ; RESET NEC FDC
        MOV     DL,AH           ; SET FOR DRIVE 0
        INT     13H             ; VERIFY STATUS AFTER RESET
        TEST    AH,0FFH         ; STATUS OK?
        MOV     BL,01H          ; SET UP POSSIBLE ERROR CODE
        JNZ     F13             ; NO - FDC FAILED
;----- TURN MOTOR ON,DRIVE 0
        MOV     AL,DRIVE_ENABLE+FDC_RESET 
        OUT     0F2H,AL         ; WRITE FDC CONTROL REG
        SUB     CX,CX
F11:    LOOP    F11             ; WAIT FOR 1 SECOND
F12:    LOOP    F12
        XOR     DX,DX           ; SELECT DRIVE 0
        MOV     CH,1            ; SELECT TRACK 1
        MOV     SEEK_STATUS,DL  ; RECALIBRATE DISKETTE
        CALL    SEEK
        MOV     BL,02H          ; ERROR CODE
        JC      F13             ; GO TO ERR SUBROUTINE IF ERR
        MOV     CH,34           ; SELECT TRACK 34
        CALL    SEEK            ; SEEK TO TRACK 34
        JNC     F14             ; OK, TURN MOTOR OFF
        MOV     BL,02H          ; ERROR CODE
F13:    MOV     BH,26H          ; DSK_ERR:(26XX)
        MOV     SI,OFFSET DISK_ERR ; GET ADDR. OF MSG
        CALL    E_MSG           ; GO PRINT ERROR MSG
F14:    MOV     AL,FDC_RESET+02H
        OUT     0F2H,AL
        IN      AL,0E2H
        AND     AL,00000110B
        CMP     AL,00000010B
        JNE     F14_1
        MOV     AL,FDC_RESET+04H
        OUT     0F2H,AL
        IN      AL,0E2H
        AND     AL,00000110B
        CMP     AL,00000100B
        JNE     F14_1
        IN      AL,0E2H
        AND     AL,00110000B
        JZ      F14_1
        CMP     AL,00010000B
        MOV     AH,01000000B
        JE      F14_2
        MOV     AH,10000000B
F14_2:  OR      BYTE PTR EQUIP_FLAG,AH
;----- TURN DRIVE 0 MOTOR OFF
F14_1:  MOV     AL,FDC_RESET    ; TURN DRIVE 0 MOTOR OFF
        OUT     0F2H,AL
F15:    MOV     INTR_FLAG,00H   ; SET STRAY INTERRUPT FLAG = 00
        MOV     DI,OFFSET PRINT_TIM_OUT ;SET DEFAULT PRT TIMEOUT
        PUSH    DS
        POP     ES
        MOV     AX,1414H        ; DEFAULT=20
        STOSW
        STOSW
        MOV     AX,0101H        ; RS232 DEFAULT=01
        STOSW
        STOSW
        IN      AL,INTA01
        AND     AL,0FEH         ; ENABLE TIMER INT. (LVL 0)
        OUT     INTA01,AL
        ASSUME  DS:XXDATA
        PUSH    DS
        MOV     AX,XXDATA
        MOV     DS,AX
        CMP     POST_ERR,00H    ; CHECK FOR "POST_ERR" NON-ZERO
        ASSUME  DS:DATA
        POP     DS
        JE      F15A_0          ; CONTINUE IF NO ERROR
        MOV     DL,2            ; 2 SHORT BEEPS (ERROR).
        CALL    ERR_BEEP
ERR_WAIT:
        MOV     AH,00
        INT     16H             ; WAIT FOR "ENTER" KEY
        CMP     AH,1CH
        JNE     ERR_WAIT
        JMP     SHORT F15C
F15A_0:
        MOV     DL,1            ; 1 SHORT BEEP (NO ERRORS)
        CALL    ERR_BEEP
;------ SETUP PRINTER AND RS232 BASE ADDRESSES IF DEVICE ATTACHED
F15C:   MOV     BP,OFFSET F4    ; PRT_SRC_TBL
        XOR     SI,SI
F16:    MOV     DX,CS:[BP]      ; PRT_BASE:
        MOV     AL,0AAH         ; GET PRINTER BASE ADDR
        OUT     DX,AL           ; WRITE DATA TO PORT A
        PUSH    DS              ; BUS SETTLING
        IN      AL,DX           ; READ PORT A
        POP     DS
        CMP     AL,0AAH         ; DATA PATTERN SAME
        JNE     F17             ; NO - CHECK NEXT PRT CD
        MOV     PRINTER_BASE[SI],DX ; YES - STORE PRT BASE ADDR
        INC     SI              ; INCREMENT TO NEXT WORD
        INC     SI
F17:    INC     BP              ; POINT TO NEXT BASE ADDR
        INC     BP
        CMP     BP,OFFSET F4E   ; ALL POSSIBLE ADDRS CHECKED?
        JNE     F16             ; PRT_BASE
        XOR     BX,BX           ; SET ADDRESS BASE
        MOV     DX,03FAH        ; POINT TO INT ID REGISTER
        IN      AL,DX           ; READ PORT
        TEST    AL,0F8H         ; SEEM TO BE AN 8250
        JNZ     F18
        MOV     RS232_BASE[BX],3F8H ; SETUP RS232 CD #1 ADDR
        INC     BX
        INC     BX
F18:    MOV     RS232_BASE[BX],2F8H ; SETUP RS232 #2
        INC     BX              ; (ALWAYS PRESENT)
        INC     BX
;------ SET UP EQUIP FLAG TO INDICATE NUMBER OF PRINTERS AND RS232
;       CARDS
        MOV     AX,SI           ; SI HAS 2* NUMBER OF PRINTERS
        MOV     CL,3            ; SHIFT COUNT
        ROR     AL,CL           ; ROTATE RIGHT 3 POSITIONS
        OR      AL,BL           ; OR IN THE RS232 COUNT
        OR      BYTE PTR EQUIP_FLAG+1,AL ; STORE AS SECOND BYTE
;------ SET EQUIP. FLAG TO INDICATE PRESENCE OF SERIAL PRINTER
;       ATTACHED TO ON BOARD RS232 PORT. ---ASSUMPTION---"RTS" IS TIED TO
;       "CARRIER DETECT" IN THE CABLE PLUG FOR THIS SPECIFIC PRINTER.
        MOV     CX,AX           ; SAVE PRINTER COUNT IN CX
        MOV     BX,2FEH         ; SET POINTER TO MODEM STATUS REG
        MOV     DX,2FCH         ; POINT TO MODEM CONTROL REG
        SUB     AL,AL           ;
        OUT     DX,AL           ; CLEAR IT
        JMP     $+2             ; DELAY
        XCHG    DX,BX           ; POINT TO MODEM STATUS REG
        IN      AL,DX           ; CLEAR IT
        JMP     $+2             ; DELAY
        MOV     AL,02H          ; BRING UP RTS
        XCHG    DX,BX           ; POINT TO MODEM CONTROL REG
        OUT     DX,AL           ;
        JMP     $+2             ; DELAY
        XCHG    DX,BX           ; POINT TO MODEM STATUS REG
        IN      AL,DX           ; GET CONTENTS
        TEST    AL,00001000B    ; HAS CARRIER DETECT CHANGED?
        JZ      F19_A           ; NO, THEN NO PRINTER
        TEST    AL,00000001B    ; DID CTS CHANGE? (AS WITH WRAP
                                ; CONNECTOR INSTALLED}
        JNZ     F19_A           ; WRAP CONNECTOR ON IF IT DID
        SUB     AL,AL           ; SET RTS OFF
        XCHG    DX,BX           ; POINT TO MODEM CONTROL REG
        OUT     DX,AL           ; DROP RTS
        JMP     $+2             ; DELAY
        XCHG    DX,BX           ; MODEM STATUS REG
        IN      AL,DX           ; GET STATUS
        AND     AL,00001000B    ; HAS CARRIER DETECT CHANGED?
        JZ      F19_A           ; NO, THEN NO PRINTER
        OR      CL,00100000B    ; CARRIER DETECT IS FOLLOWING RTS-INDICATE SERIAL PRINTER ATTACHED
        TEST    CL,11000000B    ; CHECK FOR NO PARALLEL PRINTERS
        JNZ     F19_A           ; DO NOTHING IF PARALLEL PRINTER
                                ; ATTACHED
        OR      CL,01000000B    ; INDICATE 1 PRINTER ATTACHED
        MOV     PRINTER_BASE,02F8H ; STORE ON-BOARD RS232 BASE IN
                                ; PRINTER BASE
F19_A:  OR      BYTE PTR EQUIP_FLAG+1,CL ; STORE AS SECOND BYTE
        XOR     DX,DX           ; POINT TO FIRST SERIAL PORT
        TEST    CL,040H         ; SERIAL PRINTER ATTACHED?
        JZ      F19_C           ; NO, SKIP INIT
        CMP     RS232_BASE,02F8H ; PRINTER IN FIRST SERIAL PORT
        JE      F19_B           ; YES, JUMP
        INC     DX              ; NO POINT TO SECOND SERIAL PORT
F19_B:
        MOV     AX,87H          ; INIT SERIAL PRINTER
        INT     14H
        TEST    AH,1EH          ; ERROR?
        JNZ     F19_C           ; YES, JUMP
        MOV     AX,0118H        ; SEND CANCEL COMMAND TO
        INT     14H             ; ..SERIAL PRINTER
F19_C:  MOV     DX,0201H        ; GET MFG./ SERVICE  MODE INFO
        IN      AL,DX           ; IS HIGH ORDER NIBBLE = 0?
        AND     AL,0F0H         ; (BURN-IN MODE)
        JNZ     F19_1           ; ELSE GO TO BEGINNING OF POST
F19_0:  JMP     START           ; SERVICE MODE LOOP?
F19_1:  CMP     AL,00100000B    ; BRANCH TO START
        JE      F19_0
        CMP     RESET_FLAG,4321H ; DIAG. CONTROL PROGRAM RESTART?
        JE      F19_3           ; NO, GO BOOT
        CMP     AL,00010000B    ; MFG DCP RUN REQUEST
        JE      F19_3
        MOV     RESET_FLAG,1234H ; SET WARM START INDICATOR IN CASE
                                ; OF CARTRIDGE RESET
        INT     19H             ; GO TO THE BOOT LOADER
        ASSUME  DS:ABS0
F19_3:  CLI
        SUB     AX,AX
        MOV     DS,AX               ; RESET TIMER INT.
        MOV     INT_PTR,OFFSET TIMER_INT
        INT     80H                 ; ENTER DCP THROUGH INT. 80H

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

E_MSG   PROC    NEAR
        MOV     DX,201H
        IN      AL,DX           ; GET MODE BITS
        AND     AL,0F0H         ; ISOLATE BITS OF INTEREST
        JNZ     EM0
        JMP     MFG_OUT         ; MANUFACTURING MODE (BURN-IN)
EM0:    CMP     AL,00010000B    ;
        JNE     EM1
        JMP     MFG_OUT         ; MFG. MODE (SYSTEM TEST)
EM1:    MOV     DH,AL           ; SAVE MODE
        CMP     BH,0AH          ; ERROR CODE ABOVE 0AH (CRT STARTED
                                ; DISPLAY POSSIBLE)?
        JL      BEEPS           ; DO BEEP OUTPUT IF BELOW 10H
        PUSH    BX              ; SAVE ERROR AND MODE FLAGS
        PUSH    SI
        PUSH    DX
        MOV     AH,2            ; SET CURSOR
        MOV     DX,1521H        ; ROW 21, COL.33
        MOV     BH,7            ; PAGE 7
        INT     10H
        MOV     SI,OFFSET ERROR_ERR
        MOV     CX,5            ; PRINT WORD "ERROR"
EM_O:   MOV     AL,CS:[SI]
        INC     SI
        CALL    PRT_HEX
        LOOP    EM_O            ; LOOK FOR A BLANK SPACE TO POSSIBLY PUT CUSTOMER LEVEL ERRORS (IN
                                ; CASE OF MULTI ERROR)
        MOV     DH,16H
EM_1:   MOV     AH,2            ; SET CURSOR
        INT     10H             ; ROW 22, COL33 (OR ABOVE, IF
                                ; MULTIPLE ERRS)
        MOV     AH,8            ; READ CHARACTER THIS POSITION
        INT     10H
        INC     DL              ; POINT TO NEXT POSTION
        CMP     AL,' '          ; BLANK?
        JNE     EM_1            ; GO CHECK NEXT POSITION, IF NOT
        POP     DX              ; RECOVER ERROR POINTERS
        POP     SI
        POP     BX
        CMP     DH,00100000B    ; SERVICE MODE?
        JE      SERV_OUT        ;
        CMP     DH,01000000B    ;
        JE      SERV_OUT
        MOV     AL,CS:[SI]      ; GET ERROR CHARACTER
        CALL    PRT_HEX         ; DISPLAY IT
        CMP     BH,20H          ; ERROR BELOW 20? (MEM TROUBLE?)
        JNL     EM_2
        JMP     TOTLTPO         ; HALT SYSTEM IF SO.
EM_2:   PUSH    DS
        PUSH    AX
        MOV     AX,XXDATA
        MOV     DS,AX
        ASSUME  DS:XXDATA
        MOV     POST_ERR,BH     ; SET ERROR FLAG NON-ZERO
        POP     AX
        POP     DS
        ASSUME  DS:NOTHING
        RET                     ; RETURN TO CALLER
SERV_OUT:
        MOV     AL,BH           ; PRINT MSB
        PUSH    BX
        CALL    XPC_BYTE        ; DISPLAY IT
        POP     BX
        MOV     AL,BL           ; PRINT LSB
        CALL    XPC_BYTE
        JMP     TOTLTPO
BEEPS:  CLI                     ; SET CODE SEG= STACK SEG
        MOV     AX,CS           ; (STACK IS LOST, BUT THINGS ARE
        MOV     SS,AX           ;  OVER, ANYWAY)
        MOV     DL,2            ; 2 BEEPS
        MOV     SP,OFFSET EX_0  ; SET DUMMY RETURN
EB:     MOV     BL,1            ; SHORT BEEP
        JMP     BEEP            ;
EB0:    LOOP    EB0             ; WAIT (BEEPER OFF)
        DEC     DL              ; DONE YET?
        JNZ     EB              ; LOOP IF NOT
        CMP     BH,05H          ; 64K CARD ERROR?
        JNE     TOTLTPO         ; END IF NOT
        CMP     DH,00100000B    ; SERVICE MODE?
        JE      EB1             ;
        CMP     DH,01000000B    ;
        JNE     TOTLTPO         ; END IF NOT
EB1:    MOV     BL,1            ; ONE MORE BEEP FOR 64K ERROR IF IN
                                ; SERVICE MODE
        JMP     BEEP
MFG_OUT:
        CLI
        IN      AL,PORT_B
        AND     AL,0FCH
        OUT     PORT_B,AL
        MOV     DX,11H          ; SEND DATA TO  ADDRESSES 11,12
        MOV     AL,BH           ;
        OUT     DX,AL           ; SEND HIGH BYTE
        INC     DX              ;
        MOV     AL,BL           ;
        OUT     DX,AL           ; SEND LOW BYTE
; INIT. ON-BOARD RS232 PORT FOR COMMUNICATIONS W/MFG MONITOR
        ASSUME  DS:XXDATA
        MOV     AX,XXDATA
        MOV     DS,AX           ; POINT TO DATA SEGMENT CONTAINING
                                ; CHECKPOINT #
        MOV     AX,CS
        MOV     SS,AX
        MOV     SP,OFFSET EX1   ; SET STACK FOR RTN
        MOV     DX,02FBH        ; LINE CONTROL REG. ADDRESS
        JMP     S8250           ; GO SET UP FOR 9600, ODD, 2 STOP
                                ; BITS, 8 BITS
M01:    MOV     CX,DX           ; DX CAME BACK WITH XMIT REG
                                ; ADDRESS IN IT
        MOV     DX,02FCH        ; MODEM CONTROL REG
        SUB     AL,AL           ; SET DTR AND RTS LOW SO POSSIBLE
                                ; WRAP PLUG WON'T CONFUSE THINGS
        OUT     DX,AL
        MOV     DX,02FEH        ; MODEM STATUS REG
M02:    IN      AL,DX           ; CTS UP YET?
        AND     AL,00010000B    ; LOOP TILL IT IS
        JZ      M02             ; SET DX=2FD (LINE STATUS REG)
        DEC     DX              ; POINT TO XMIT. DATA REG
        XCHG    DX,CX           ; GET MFG ROUTINE ERROR INDICATOR
        MOV     AL,MFG_TST      ; (MAY BE WRONG FOR EARLY ERRORS)
        OUT     DX,AL           ; DELAY
        JMP     $+2
        XCHG    DX,CX           ; POINT DX=2FD
M03:    IN      AL,DX           ; TRANSMIT EMPTY?
        AND     AL,00100000B    ; DELAY
        JMP     $+2             ; LOOP TILL IT IS
        JZ      M03
        XCHG    DX,CX
        MOV     AL,BH           ; GET MSB OF ERROR WORD
        OUT     DX,AL
        JMP     $+2             ; DELAY
        XCHG    DX,CX
M04:    IN      AL,DX           ; WAIT FOR XMIT EMPTY
        AND     AL,00100000B    ; DELAY
        JMP     $+2             ; LOOP TILL IT IS
        JZ      M04
        MOV     AL,BL           ; GET LSB OF ERROR WORD
        XCHG    DX,CX
        OUT     DX,AL
TOTLTPO:CLI                     ; DISABLE INTS.
        SUB     AL,AL
        OUT     0F2H,AL         ; STOP DISKETTE MOTOR
        OUT     0A0H,AL         ; DISABLE NMI
        HLT                     ; HALT
        RET
E_MSG   ENDP
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
I8250   PROC    NEAR
        IN      AL,DX           ; READ RECVR BUFFER BUT IGNORE
                                ; CONTENTS
        MOV     BL,2            ; ERROR INDICATOR
        CALL    RR2             ; READ INTR ENBL REG
        AND     AL,11110000B    ; BITS 4-7 OFF?
        JNE     AT20            ; NO - ERROR
        CALL    RR1             ; READ INTR ID REG
        AND     AL,11111000B    ; BITS 3-7 OFF?
        JNE     AT20            ; NO
        INC     DX              ; LINE CTRL REG
        CALL    RR1             ; READ MODEM CTRL REG
        AND     AL,11100000B    ; BITS 5-7 OFF?
        JNE     AT20            ; NO
        CALL    RR1             ; READ LINE STAT REG
        AND     AL,10000000B    ; BIT 7 OFF?
        JNE     AT20            ; NO
        MOV     AL,60H
        OUT     DX,AL
        JMP     $+2             ; I/O DELAY
        INC     DX              ; MODEM STAT REG
        XOR     AL,AL           ; WIRED BITS WILL BE HIGH
        OUT     DX,AL           ; CLEAR BITS 0-3 IN CASE THEY'RE ON
        CALL    RR3             ; AFTER WRITING TO STATUS REG
                                ; RECEIVER BUFFER
        SUB     DX,6            ; IN CASE WRITING TO PORTS CAUSED
        IN      AL,DX           ; DATA READY TO GO HIGH!
        CLC
        RET
AT20:   STC                     ; ERROR RETURN
        RET
I8250   ENDP
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
ICT     PROC    NEAR
        IN      AL,DX           ; READ STATUS REGISTER
        JMP     $+2             ; I/O DELAY
        OR      AL,AH           ; SET TEST BIT
        OUT     DX,AL           ; WRITE IT TO THE STATUS REGISTER
        SUB     DX,CX           ; POINT TO INTERRUPT ID REGISTER
        PUSH    CX
        SUB     CX,CX           ; WAIT FOR 8250 INTERRUPT TO OCCUR
AT21:   IN      AL,DX           ; READ INTR ID REG
        TEST    AL,1            ; INTERRUPT PENDING?
        JE      AT22            ; YES - RETURN W/ INTERRUPT ID IN AL
        LOOP    AT21            ; NO - TRY AGAIN
AT22:   POP     CX              ; AL = 1 IF NO INTERRUPT OCCURRED
        CMP     AL,BH           ; INTERRUPT WE'RE LOOKING FOR?
        JNE     AT23            ; NO
        OR      BL,BL           ; DONE WITH TEST FOR THIS INTERRUPT
        JE      AT24            ; RETURN W/ CONTENTS OF INTR ID REG
        ADD     DX,CX           ; READ STATUS REGISTER TO CLEAR THE
        IN      AL,DX           ; INTERRUPT (WHEN BL=1)
        JMP     SHORT AT24      ; RETURN CONTENTS OF STATUS REG
AT23:   MOV     AL,0FFH         ; SET ERROR INDICATOR
AT24:   RET
ICT     ENDP
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
        ASSUME  CS:CODE,DS:ABS0
BOOT_STRAP      PROC    NEAR
        STI                     ; ENABLE INTERRUPTS
        SUB     AX,AX           ; SET 40X25 B&W MODE ON CRT
        INT     10H
        SUB     AX,AX           ; ESTABLISH ADDRESSING
        MOV     DS,AX
;------ SEE IF DISKETTE PRESENT
        IN      AL,PORT_C       ; GET CONFIG BITS
        AND     AL,00000100B    ; IS DISKETTE PRESENT?
        JNZ     H3              ; NO, THEN ATTEMPT TO GO TO CART.
;------ RESET THE DISK PARAMETER TABLE VECTOR
        MOV     WORD PTR DISK_POINTER,OFFSET DISK_BASE
        MOV     WORD PTR DISK_POINTER+2,CS
;------ LOAD SYSTEM FROM DISKETTE -- CX HAS RETRY COUNT
        MOV     CX,4            ; SET RETRY COUNT
H1:     PUSH    CX              ; SAVE RETRY COUNT
        MOV     AH,0            ; RESET THE DISKETTE SYSTEM
        INT     13H             ; DISKETTE_IO
        JC      H2              ; IF ERROR, TRY AGAIN
        MOV     AX,201H         ; READ IN THE SINGLE SECTOR
        SUB     DX,DX           ; TO THE BOOT LOCATION
        MOV     ES,DX
        MOV     BX,OFFSET BOOT_LOCN
        MOV     CX,1            ; DRIVE 0, HEAD 0
        INT     13H             ; SECTOR 1, TRACK 0
H2:     POP     CX              ; DISKETTE_IO
        JNC     H3A             ; RECOVER RETRY COUNT
        LOOP    H1              ; CF SET BY UNSUCCESSFUL READ
; DO IT FOR RETRY TIMES
;------ UNABLE TO IPL FROM THE DISKETTE
H3:     INT     18H             ; GO TO BASIC OR CARTRIDGE
;------ IPL WAS SUCCESSFUL
H3A:    JMP     BOOT_LOCN
BOOT_STRAP      ENDP
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
PODSTG  PROC    NEAR
        ASSUME  DS:ABS0
        CLD                     ; SET DIRECTION TO INCREMENT
        SUB     DI,DI           ; SET DI=0000 REL. TO START OF SEG
        SUB     AX,AX           ; INITIAL DATA PATTERN FOR 00-FF
                                ; TEST
        MOV     DS,AX           ; SET DS TO ABS0
        MOV     BX,DATA_WORD[RESET_FLAG-DATA] ; WARM START?
        CMP     BX,1234H
        MOV     DX,ES
        MOV     DS,DX           ; RESTORE DS
        JNE     P1
P12:    REP     STOSW           ; SIMPLE FILL WITH 0 ON WARM-START
        MOV     DS,AX
        MOV     DATA_WORD[RESET_FLAG-DATA],BX
        MOV     DS,DX           ; RESTORE DS
        RET                     ; AND EXIT
P1:     CMP     BX,4321H        ; DIAG. RESTART?
        JE      P12             ; DO FILL WITH ZEROS
P2:     MOV     [DI],AL         ; WRITE TEST DATA
        MOV     AL,[DI]         ; GET IT BACK
        XOR     AL,AH           ; COMPARE TO EXPECTED
        JZ      PY
        JMP     P8              ; ERROR EXIT IF MISCOMPARE
PY:     INC     AH              ; FORM NEW DATA PATTERN
        MOV     AL,AH
        JNZ     P2              ; LOOP TILL ALL 256 DATA PATTERNS
                                ; DONE
        MOV     BP,CX           ; SAVE WORD COUNT
        MOV     AX,0AAAAH       ; LOAD DATA PATTERN
        MOV     BX,AX
        MOV     DX,05555H       ; LOAD OTHER DATA PATTERN
        REP     STOSW           ; FILL WORDS FROM LOW TO HIGH
                                ; WITH AAAA

        DEC     DI              ; POINT TO LAST WORD WRITTEN
        DEC     DI              ;
        STD                     ; SET DIRECTION FLAG TO GO DOWN
        MOV     SI,DI           ; SET INDEX REGS. EQUAL
        MOV     CX,BP           ; RECOVER WORD COUNT
P3:                             ; GO FROM HIGH TO LOW
        LODSW                   ; GET WORD FROM MEMORY
        XOR     AX,BX           ; EQUAL WHAT S/B THERE?
        JNZ     P8              ; GO ERROR EXIT IF NOT
        MOV     AX,DX           ; GET 55 DATA PATTERN
        STOSW                   ;  STORE IT IN LOCATION JUST READ
        LOOP    P3              ; LOOP TILL ALL BYTES DONE
        MOV     CX,BP           ; RECOVER WORD COUNT
        CLD                     ; DECREMENT
        INC     SI              ; ADJUST PTRS
        INC     SI
        MOV     DI,SI
        MOV     BX,DX           ; S/B DATA PATTERN TO BX
        MOV     DX,00FFH        ; DATA FOR CHECKERBOARD PATTERN
PX:     LODSW                   ; GET WORD FROM MEMORY
        XOR     AX,BX           ; EQUAL WHAT S/B THERE?
        JNZ     P8              ; GO ERROR EXIT IF NOT
        MOV     AX,DX           ; GET OTHER PATTERN
        STOSW                   ; STORE IT IN LOCATION JUST READ
        LOOP    PX              ; LOOP TILL ALL BYTES DONE
        MOV     CX,BP           ; RECOVER WORD COUNT
        STD                     ; DECREMENT
        DEC     SI              ; ADJUST PTRS
        DEC     SI
        MOV     DI,SI
        MOV     BX,DX           ; S/B DATA PATTERN TO BX
        NOT     DX              ; MAKE PATTERN FF00
        OR      DL,DL           ; FIRST PASS?
        JZ      PX
        CLD                     ; INCREMENT
        ADD     SI,4
        NOT     DX
        MOV     DI,SI
        MOV     CX,BP
P4:                             ; LOW TO HIGH
        LODSW                   ; GET A WORD
        XOR     AX,DX           ; SHOULD COMPARE TO DX
        JNZ     P8              ; GO ERROR IF NOT
        STOSW                   ; WRITE 0000 BACK TO LOCATION
                                ; JUST READ
        LOOP    P4              ; LOOP TILL DONE
        STD                     ; BACK TO DECREMENT
        DEC     SI              ; ADJUST POINTER DOWN TO LAST WORD
        DEC     SI              ; WRITTEN
; CHECK IF IN SERVICE/MFG MODES, IF SO, PERFORM REFRESH CHECK
        MOV     DX,201H         ;
        IN      AL,DX           ; GET OPTION BITS
        AND     AL,0F0H         ;
        CMP     AL,0F0H         ; ALL BITS HIGH=NORMAL MODE
        JE      P6
        MOV     CX,CS
        MOV     BX,SS
        CMP     CX,BX           ; SEE IF IN PRE-STACK MODE
        JE      P6              ; BYPASS RETENTION TEST IF SO
        MOV     AL,24           ; SET OUTER LOOP COUNT
; WAIT ABOUT 6-8 SECONDS WITHOUT ACCESSING MEMORY
; IF REFRESH IS NOT WORKING PROPERLY, THIS SHOULD
; BE ENOUGH TIME FOR SOME DATA TO GO SOUR.
P5:     LOOP    P5              ; RECOVER WORD COUNT
        DEC     AL              ; GET WORD
        JNZ     P5              ; = TO 0000
P6:     MOV     CX,BP           ; ERROR IF NOT
P7:     LODSW                   ; LOOP TILL DONE
        OR      AX,AX           ; THEN EXIT
        JNZ     P8              ; SAVE BITS IN ERROR
        LOOP    P7
        JMP     SHORT P11
P8:     MOV     CX,AX           ; HIGH BYTE ERROR?
        XOR     AH,AH
        OR      CH,CH           ; SET HIGH BYTE ERROR
        JZ      P9              ; LOW BYTE ERROR?
        INC     AH
P9:     OR      CL,CL
        JZ      P10
        ADD     AH,2
P10:    OR      AH,AH           ; SET ZERO FLAG=0 (ERROR INDICATION
P11:    CLD                     ; SET DIR FLAG BACK TO INCREMENT
        RET                     ; RETURN TO CALLER
PODSTG  ENDP

;*******************************************************
; PUT_LOGO PROCEDURE
;      THIS PROC SETS UP POINTERS AND CALLS THE SCREEN
;   OUTPUT ROUTINE SO THAT THE IBM LOGO, A MESSAGE,
;   AND A COLOR BAR ARE PUT UP ON THE SCREEN.
;   AX,BX, AND DX ARE DESTROYED. ALL OTHERS ARE SAVED
;*******************************************************

PUT_LOGO PROC    NEAR
        PUSH    DS
        PUSH    BP
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     BP,OFFSET LOGO  ; POINT DH DL AT ROW,COLUMN 0,0
        MOV     DX,8000H        ; ATTRIBUTE OF CHARACTERS TO BE
        MOV     BL,00011111B    ; WRITTEN

        INT     82H             ; CALL OUTPUT ROUTINE
        MOV     BL,00000000B    ; INITIALIZE ATTRIBUTE
        MOV     DL,0            ; INITIALIZE COLUMN
AGAIN:  MOV     DH,94H          ; SET LINE
        MOV     BP,OFFSET COLOR ; OUTPUT GIVEN COLOR BAR
        INT     82H             ; CALL OUTPUT ROUTINE
        INC     BL              ; INCREMENT ATTRIBUTE
        CMP     DL,32           ; IS THE COLUMN COUNTER POINTING
                                ; PAST 40?
        JL      AGAIN           ; IF NOT, DO IT AGAIN
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POP     BP              ; RESTORE BP
        POP     DS              ; RESTORE DS
        RET
PUT_LOGO ENDP
LOGO    DB      LOGO_E - LOGO
        DB      ' ',220
LOGO_E  =       $
        DB      40,-5
        DB      40,-5
        DB      2,7,1,9,3,4,9,4,1,-5

        DB      2,7,1,10,2,5,7,5,1,-5

        DB      2,7,1,11,1,6,5,6,1,-5

        DB      4,3,5,3,3,3,3,5,3,5,3,-5

        DB      4,3,5,3,3,3,3,6,1,6,3,-5

        DB      4,3,5,8,4,13,3,-5

        DB      4,3,5,7,5,13,3,-5

        DB      4,3,5,8,4,13,3,-5

        DB      4,3,5,3,3,3,3,13,3,-5

        DB      4,3,5,3,3,3,3,3,1,5,1,3,3,-5


        DB      2,7,1,11,1,5,2,3,2,5,1,-5

        DB      2,7,1,10,2,5,3,1,3,5,1,-5

        DB      2,7,1,9,3,5,7,5,1,-5

        DB      40,-5
        DB      40,-4
COLOR   DB      COLOR_E - COLOR
        DB      219
COLOR_E =       $
        DB      2,121-2,2,121-2,2,121-2,2,121-2,2,-4


        ASSUME  DS:DATA
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
M0010   LABEL   WORD    ;  TABLE OF ROUTINES WITHIN VIDEO I/O
        DW      OFFSET  SET_MODE
        DW      OFFSET  SET_CTYPE
        DW      OFFSET  SET_CPOS
        DW      OFFSET  READ_CURSOR
        DW      OFFSET  READ_LPEN
        DW      OFFSET  ACT_DISP_PAGE
        DW      OFFSET  SCROLL_UP
        DW      OFFSET  SCROLL_DOWN
        DW      OFFSET  READ_AC_CURRENT
        DW      OFFSET  WRITE_AC_CURRENT
        DW      OFFSET  WRITE_C_CURRENT
        DW      OFFSET  SET_COLOR
        DW      OFFSET  WRITE_DOT
        DW      OFFSET  READ_DOT
        DW      OFFSET  WRITE_TTY
        DW      OFFSET  VIDEO_STATE
        DW      OFFSET  SET_PALLETTE
M0010L  EQU     $-M0010

VIDEO_IO        PROC    NEAR
        STI                     ; INTERRUPTS BACK ON
        CLD                     ; SET DIRECTION FORWARD
        PUSH    ES              ; SAVE SEGMENT REGISTERS
        PUSH    DS
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    SI
        PUSH    DI
        PUSH    AX              ; SAVE AX VALUE
        MOV     AL,AH           ; GET INTO LOW BYTE
        XOR     AH,AH           ; ZERO TO HIGH BYTE
        SAL     AX,1            ; *2 FOR TABLE LOOKUP
        MOV     SI,AX           ; PUT INTO SI FOR BRANCH
        CMP     AX,M0010L       ; TEST FOR WITHIN RANGE
        JB      C1              ; BRANCH AROUND BRANCH
        POP     AX              ; THROW AWAY THE PARAMETER
        JMP     VIDEO_RETURN    ; DO NOTHING IF NOT IN RANGE
C1:     CALL    DDS
        MOV     AX,0B800H       ; SEGMENT FOR COLOR CARD
        CMP     CRT_MODE,9      ; IN MODE USING 32K REGEN
        JC      C2              ; NO,JUMP
        MOV     AH,PAGDAT       ; GET COPY OF PAGE REGS
        AND     AH,CPUREG       ; ISOLATE CPU REG
        SHR     AH,1            ; SHIFT TO MAKE INTO SEGMENT VALUE
C2:     MOV     ES,AX           ; SET UP TO POINT AT VIDEO RAM AREA
        POP     AX              ; RECOVER VALUE
        MOV     AH,CRT_MODE     ; GET CURRENT MODE INTO AH
        JMP     WORD PTR CS:[SI+OFFSET M0010]
VIDEO_IO ENDP
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
M0050   LABEL   WORD            ; TABLE OF REGEN LENGTHS
        DW      2048            ; MODE 0 40X25 BW
        DW      2048            ; MODE 1 40X25 COLOR
        DW      4096            ; MODE 2 80X25 BW
        DW      4096            ; MODE 3 80X25 COLOR
        DW      16384           ; MODE 4 320X200 4 COLOR
        DW      16384           ; MODE 5 320X200 4 COLOR
        DW      16384           ; MODE 6 640X200 BW
        DW      0               ; MODE 7 INVALID
        DW      16384           ; MODE 8 160X200 16 COLOR
        DW      32768           ; MODE 9 320X200 16 COLOR
        DW      32768           ; MODE A 640X200 4 COLOR
;------- COLUMNS
M0060   LABEL   BYTE
        DB      40,40,80,80,40,40,80,0,20,40,80

;------- TABLE OF GATE ARRAY PARAMETERS FOR MODE SETTING
M0070   LABEL   BYTE
;------- SET UP FOR 40X25 BW            MODE 0
        DB      0CH,0FH,0,2     ; GATE ARRAY PARMS
M0070L  EQU     $-M0070
;------- SET UP FOR 40X25 COLOR         MODE 1
        DB      08H,0FH,0,2     ; GATE ARRAY PARMS
;------- SET UP FOR 80X25 BW            MODE 2
        DB      0DH,0FH,0,2     ; GATE ARRAY PARMS
;------- SET UP FOR 80X25 COLOR         MODE 3
        DB      09H,0FH,0,2     ; GATE ARRAY PARMS
;------- SET UP FOR 320X200 4 COLOR     MODE 4
        DB      0AH,03H,0,0     ; GATE ARRAY PARMS
;------- SET UP FOR 320X200 BW          MODE 5
        DB      0EH,03H,0,0     ; GATE ARRAY PARMS
;------- SET UP FOR 640X200 BW          MODE 6
        DB      0EH,01H,0,8     ; GATE ARRAY PARMS
;------- SET UP FOR INVALID             MODE 7
        DB      00H,00H,0,0     ; GATE ARRAY PARMS
;------- SET UP FOR 160X200 16 COLOR    MODE 8
        DB      1AH,0FH,0,0     ; GATE ARRAY PARMS
;------- SET UP FOR 320X200 16 COLOR    MODE 9
        DB      1BH,0FH,0,0     ; GATE ARRAY PARMS
;------- SET UP FOR 640X200 4 COLOR     MODE A
        DB      0BH,03H,0,0     ; GATE ARRAY PARMS
;----------------- TABLES OF PALETTE COLORS FOR 2 AND 4 COLOR MODES
;------- 2 COLOR, SET 0
M0072   LABEL   BYTE
        DB      0,0FH,0,0
M0072L  EQU     $-M0072         ;ENTRY LENGTH
;------- 2 COLOR, SET 1
        DB      0FH,0,0,0
;------- 4 COLOR, SET 0
M0074   LABEL   BYTE
        DB      0,2,4,6
;------- 4 COLOR, SET 1
M0075   LABEL   BYTE
        DB      0,3,5,0FH
SET_MODE PROC    NEAR           ;SAVE INPUT MODE ON STACK
        PUSH    AX
        AND     AL,7FH          ;REMOVE CLEAR REGEN SWITCH
        CMP     AL,7            ;CHECK FOR VALID MODES
        JE      C3              ;MODE 7 IS INVALID
        CMP     AL,0BH
        JC      C4              ;GREATER THAN A IS INVALID
C3:     MOV     AL,0            ;DEFAULT TO MODE 0
C4:     CMP     AL,2            ;CHECK FOR MODES NEEDING 128K
        JE      C5
        CMP     AL,3
        JE      C5
        CMP     AL,09H
        JC      C6
C5:     CMP     TRUE_MEM,128    ;DO WE HAVE 128K?
        JNC     C6              ;YES, JUMP
        MOV     AL,0            ;NO, DEFAULT TO MODE 0
C6:     MOV     DX,03D4H        ; ADDRESS OF COLOR CARD
        MOV     AH,AL           ; SAVE MODE IN AH
        MOV     CRT_MODE,AL     ; SAVE IN GLOBAL VARIABLE
        MOV     ADDR_6845,DX    ; SAVE ADDRESS OF BASE
        MOV     DI,AX           ; SAVE MODE IN DI
        MOV     DX,VGA_CTL      ; POINT TO CONTROL REGISTER
        IN      AL,DX           ; SYNC CONTROL REG TO ADDRESS
        XOR     AL,AL           ; SET VGA REG 0
        OUT     DX,AL           ; SELECT IT
        MOV     AL,CRT_MODE_SET ; GET LAST MODE SET
        AND     AL,0F7H         ; TURN OFF VIDEO
        OUT     DX,AL           ; SET IN GATE ARRAY
; SET DEFAULT PALETTES
        MOV     AX,DI           ; GET MODE
        MOV     AH,10H          ; SET PALETTE REG 0
        MOV     BX,OFFSET M0072 ; POINT TO TABLE ENTRY
        CMP     AL,6            ; 2 COLOR MODE?
        JE      C7              ; YES, JUMP
        MOV     BX,OFFSET M0075 ; POINT TO TABLE ENTRY
        CMP     AL,5            ; CHECK FOR 4 COLOR MODE
        JE      C7              ; YES, JUMP
        CMP     AL,4            ; CHECK FOR 4 COLOR MODE
        JE      C7              ; YES JUMP
        CMP     AL,0AH          ; CHECK FOR 4 COLOR MODE
        JNE     C9              ; NO, JUMP
C7:     MOV     CX,4            ; NUMBER OF REGS TO SET
C8:     MOV     AL,AH           ; GET REG NUMBER
        OUT     DX,AL           ; SELECT IT
        MOV     AL,CS:[BX]      ; GET DATA
        OUT     DX,AL           ; SET IT
        INC     AH              ; NEXT REG
        INC     BX              ; NEXT TABLE VALUE
        LOOP    C8
        JMP     SHORT C11
;----- SET PALETTES FOR DEFAULT 16 COLOR 
C9:     MOV     CX,16           ; NUMBER OF PALETTES, AH IS REG
                                ; COUNTER
C10:    MOV     AL,AH           ; GET REG NUMBER
        OUT     DX,AL           ; SELECT IT
        OUT     DX,AL           ; SET PALETTE VALUE
        INC     AH              ; NEXT REG
        LOOP    C10
;----- SET UP M0 & M1 in PAGREG
C11:    MOV     AX,DI           ; GET CURRENT MODE
        XOR     BL,BL           ; SET UP FOR ALPHA MODE
        CMP     AL,4            ; IN ALPHA MODE
        JC      C12             ; YES, JUMP
        MOV     BL,40H          ; SET UP FOR 16K REGEN
        CMP     AL,09H          ; MODE USE 16K
        JC      C12             ; YES, JUMP
        MOV     BL,0C0H         ; SET UP FOR 32K REGEN
C12:    MOV     DX,PAGREG       ; SET PORT ADDRESS OF PAGREG
        MOV     AL,PAGDAT       ; GET LAST DATA OUTPUT
        AND     AL,3FH          ; CLEAR M0 & M1 BITS
        OR      AL,BL           ; SET NEW BITS
        OUT     DX,AL           ; STUFF BACK IN PORT
        MOV     PAGDAT,AL       ; SAVE COPY IN RAM
;----- ENABLE VIDEO AND CORRECT PORT SETTING
        MOV     AX,DI           ; GET CURRENT MODE
        XOR     AH,AH           ; INTO AX REG
        MOV     CX,M0070L       ; SET TABLE ENTRY LENGTH
        MUL     CX              ; TIMES MODE FOR OFFSET INTO TABLE
        MOV     BX,AX           ; TABLE OFFSET IN BX
        ADD     BX,OFFSET M0070  ; ADD TABLE START TO OFFSET
        MOV     AH,CS:[BX]      ; SAVE MODE SET AND PALETTE
        MOV     AL,CS:[BX + 2]  ; TILL WE CAN PUT THEM IN RAM
        MOV     SI,AX
        CLI                     ; DISABLE INTERRUPTS
        CALL    MODE_ALIVE      ; KEEP MEMORY DATA VALID
        MOV     AL,10H          ; DISABLE NMI AND HOLD REQUEST
        OUT     NMI_PORT,AL     ;
        MOV     DX,VGA_CTL      ;
        MOV     AL,4            ; POINT TO RESET REG
        OUT     DX,AL           ; SEND TO GATE ARRAY
        MOV     AL,2            ; SET SYNCHRONOUS RESET
        OUT     DX,AL           ; DO IT
; WHILE GATE ARRAY IS IN RESET STATE, WE CANNOT ACCESS RAM
        MOV     AX,SI           ; RESTORE NEW MODE SET
        AND     AH,0F7H         ; TURN OFF VIDEO ENABLE
        XOR     AL,AL           ; SET UP TO SELECT VGA REG 0
        OUT     DX,AL           ; SELECT IT
        XCHG    AH,AL           ; AH IS VGA REG COUNTER
        OUT     DX,AL           ; SET MODE
        MOV     AL,4            ; SET UP TO SELECT VGA REG 4
        OUT     DX,AL           ; SELECT IT
        XOR     AL,AL           ;
        OUT     DX,AL           ; REMOVE RESET FROM VGA
; NOW OKAY TO ACCESS RAM AGAIN
        MOV     AL,80H          ; ENABLE NMI AGAIN
        OUT     NMI_PORT,AL     ;
        CALL    MODE_ALIVE      ; KEEP MEMORY DATA VALID
        STI                     ; ENABLE INTERRUPTS
        JMP     SHORT C14
C13:    MOV     AL,AH           ; GET VGA REG NUMBER
        OUT     DX,AL           ; SELECT REG
        MOV     AL,CS:[BX]      ; GET TABLE VALUE
        OUT     DX,AL           ; PUT IN VGA REG
C14:    INC     BX              ; NEXT IN TABLE
        INC     AH              ; NEXT REG
        LOOP    C13             ; DO ENTIRE ENTRY
;---- SET UP CRT AND CPU PAGE REGS ACCORDING TO MODE & MEMORY SIZE
        MOV     DX,PAGREG       ; SET IO ADDRESS OF PAGREG
        MOV     AL,PAGDAT       ; GET LAST DATA OUTPUT
        AND     AL,0C0H         ; CLEAR REG BITS
        MOV     BL,36H          ; SET UP FOR GRAPHICS MODE WITH 32K
                                ; REGEN
        TEST    AL,80H          ; IN THIS MODE?
        JNZ     C15             ; YES, JUMP
        MOV     BL,3FH          ; SET UP FOR 16K REGEN AND 128K
                                ; MEMORY
        CMP     TRUE_MEM,128    ; DO WE HAVE 128K?
        JNC     C15             ; YES, JUMP
        MOV     BL,1BH          ; SET UP FOR 16K REGEN AND 64K
                                ; MEMORY
C15:    OR      AL,BL           ; COMBINE MODE BITS AND REG VALUES
        OUT     DX,AL           ; SET PORT
        MOV     PAGDAT,AL       ; SAVE COPY IN RAM
        MOV     AX,SI           ; PUT MODE SET & PALETTE IN RAM
        MOV     CRT_MODE_SET,AH
        MOV     CRT_PALETTE,AL
        IN      AL,PORT_B       ; GET CURRENT VALUE OF 8255 PORT B
        AND     AL,0FBH         ; SET UP GRAPHICS MODE
        TEST    AH,2            ; JUST SET ALPHA MODE IN VGA?
        JNZ     C16             ; YES, JUMP
        OR      AL,4            ; SET UP ALPHA MODE
C16:    OUT     PORT_B,AL       ; STUFF BACK IN 8255

        PUSH    DS              ; SAVE DATA SEGMENT VALUE
        XOR     AX,AX           ; SET UP FOR ABS0 SEGMENT
        MOV     DS,AX           ; ESTABLISH VECTOR TABLE ADDRESSING
        ASSUME  DS:ABS0
        LDS     BX,PARM_PTR     ; GET POINTER TO VIDEO PARMS
        ASSUME  DS:CODE
        MOV     AX,DI           ; GET CURRENT MODE IN AX
        MOV     CX,M0040        ; LENGTH OF EACH ROW OF TABLE
        CMP     AH,2            ; DETERMINE WHICH TO USE
        JC      C17             ; MODE IS 0 OR 1
        ADD     BX,CX           ; MOVE TO NEXT ROW OF INIT TABLE
        CMP     AH,4            ; MODE IS 2 OR 3
        JC      C17             ; MOVE TO GRAPHICS ROW OF
        ADD     BX,CX           ; INIT_TABLE

        CMP     AH,9            ; MODE IS 4, 5, 6, 8, OR 9
        JC      C17             ; MOVE TO NEXT GRAPHICS ROW OF
        ADD     BX,CX           ; INIT_TABLE

C17:    PUSH    AX              ; SAVE MODE IN AH
        MOV     AL,DS:[BX+2]    ; GET HORZ. SYNC POSITION
        MOV     DI,WORD PTR DS:[BX+10] ; GET CURSOR TYPE
        PUSH    DS
        CALL    DDS
        ASSUME  DS:DATA
        MOV     HORZ_POS,AL     ; SAVE HORZ. SYNC POSITION VARIABLE
        MOV     CURSOR_MODE,DI  ; SAVE CURSOR MODE
        PUSH    AX
        MOV     AL,VAR_DELAY    ; SET DEFAULT OFFSET
        AND     AL,0FH
        MOV     VAR_DELAY,AL
        POP     AX
        ASSUME  DS:CODE
        POP     DS
        XOR     AH,AH           ; AH WILL SERVE AS REGISTER NUMBER
        MOV     DX,03D4H        ; POINT TO 6845
;LOOP THROUGH TABLE, OUTPUTTING REG ADDRESS, THEN VALUE FROM TABLE
C18:    MOV     AL,AH           ; GET 6845 REGISTER NUMBER
        OUT     DX,AL
        INC     DX              ; POINT TO DATA PORT
        INC     AH              ; NEXT REGISTER VALUE
        MOV     AL,[BX]         ; GET TABLE VALUE
        OUT     DX,AL           ; OUT TO CHIP
        INC     BX              ; NEXT IN TABLE
        DEC     DX              ; BACK TO POINTER REGISTER
        LOOP    C18             ; DO THE WHOLE TABLE
        POP     AX              ; GET MODE BACK
        POP     DS              ; RECOVER SEGMENT VALUE
        ASSUME  DS:DATA
;------- FILL REGEN AREA WITH BLANK
        XOR     DI,DI           ; SET UP POINTER FOR REGEN
        MOV     CRT_START,DI    ; START ADDRESS SAVED IN GLOBAL
        MOV     ACTIVE_PAGE,0   ; SET PAGE VALUE
        POP     DX              ; GET ORIGINAL INPUT BACK
        AND     DL,80H          ; NO CLEAR OF REGEN ?
        JNZ     C21             ; SKIP CLEARING REGEN
        MOV     DX,0B800H       ; SET UP SEGMENT FOR 16K REGEN AREA
        MOV     CX,8192         ; NUMBER OF WORDS TO CLEAR
        CMP     AL,09H          ; REQUIRE 32K BYTE REGEN ?
        JC      C19             ; NO, JUMP
        SHL     CX,1            ; SET 16K WORDS TO CLEAR
        MOV     DX,1800H        ; SET UP SEGMENT FOR 32K REGEN AREA
C19:    MOV     ES,DX           ; SET REGEN SEGMENT
        CMP     AL,4            ; TEST FOR GRAPHICS
        MOV     AX,' '+15*256   ; FILL CHAR FOR ALPHA
        JC      C20             ; NO_GRAPHICS_INIT
        XOR     AX,AX           ; FILL FOR GRAPHICS MODE
C20:    REP     STOSW           ; FILL THE REGEN BUFFER WITH BLANKS
;----- ENABLE VIDEO
C21:    MOV     DX,VGA_CTL      ; SET PORT ADDRESS OF VGA
        XOR     AL,AL
        OUT     DX,AL           ; SELECT VGA REG 0
        MOV     AL,CRT_MODE_SET ; GET MODE SET VALUE
        OUT     DX,AL           ; SET MODE
;------- DETERMINE NUMBER OF COLUMNS, BOTH FOR ENTIRE DISPLAY
;------- AND THE NUMBER TO BE USED FOR TTY INTERFACE
        XOR     BH,BH
        MOV     BL,CRT_MODE
        MOV     AL,CS:[BX + OFFSET M0060]
        XOR     AH,AH
        MOV     CRT_COLS,AX     ; NUMBER OF COLUMNS IN THIS SCREEN
;------ SET CURSOR POSITIONS
        SHL     BX,1            ; WORD OFFSET INTO CLEAR LENGTH
; TABLE
        MOV     CX,CS:[BX + OFFSET M0050] ; LENGTH TO CLEAR
        MOV     CRT_LEN,CX      ; SAVE LENGTH OF CRT
        MOV     CX,8            ; CLEAR ALL CURSOR POSITIONS
        MOV     DI,OFFSET CURSOR_POSN
        PUSH    DS              ; ESTABLISH SEGMENT
        POP     ES              ; ADDRESSING
        XOR     AX,AX
        REP     STOSW           ; FILL WITH ZEROES
;------ NORMAL RETURN FROM ALL VIDEO RETURNS
VIDEO_RETURN:
        POP     DI
        POP     SI
        POP     BX
C22:    POP     CX
        POP     DX
        POP     DS
        POP     ES              ; RECOVER SEGMENTS
        IRET                    ; ALL DONE
SET_MODE ENDP
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
KBDNMI  PROC    FAR
;---------DISABLE INTERRUPTS
        CLI
;---------SAVE REGS & DISABLE NMI
        PUSH    SI
        PUSH    DI
        PUSH    AX              ; SAVE REGS
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        PUSH    ES
;---------INIT COUNTERS
        MOV     SI,8            ; SET UP # OF DATA BITS
        XOR     BL,BL           ; INIT. PARITY COUNTER
;---------SAMPLE 5 TIMES TO VALIDATE START BIT
        XOR     AH,AH
        MOV     CX,5            ; SET COUNTER
I1:     IN      AL,PORT_C       ; GET SAMPLE
        TEST    AL,40H          ; TEST IF 1
        JZ      I2              ; JMP IF 0
        INC     AH              ; KEEP COUNT OF 1'S
I2:     LOOP    I1              ; KEEP SAMPLING
        CMP     AH,3            ; VALID START BIT ?
        JNB     I25             ; JUMP IF OK
        JMP     I8              ; INVALID (SYNC ERROR) NO AUDIO
                                ; OUTPUT
;---------VALID START BIT, LOOK FOR TRAILING EDGE
I25:    MOV     CX,50           ; SET UP WATCHDOG TIMEOUT
I3:     IN      AL,PORT_C       ; GET SAMPLE
        TEST    AL,40H          ; TEST IF 0
        JZ      I5              ; JMP IF TRAILING EDGE FOUND
        LOOP    I3              ; KEEP LOOKING FOR TRAILING EDGE
        JMP     I8              ; SYNC ERROR (STUCK ON 1'S)
;---------READ CLOCK TO SET START OF BIT TIME
I5:     MOV     AL,40H          ; READ CLOCK
        OUT     TIM_CTL,AL      ; *
        NOP                     ; *
        NOP                     ; *
        IN      AL,TIMER+1      ; *
        MOV     AH,AL           ; *
        IN      AL,TIMER+1      ; *
        XCHG    AH,AL           ; *
        MOV     DI,AX           ; SAVE CLOCK TIME IN DI
;---------VERIFY VALID TRANSITION
        MOV     CX,4            ; SET COUNTER
I6:     IN      AL,PORT_C       ; GET SAMPLE
        TEST    AL,40H          ; TEST IF 0
        JNZ     I8              ; JMP IF INVALID TRANSITION (SYNC)
        LOOP    I6              ; KEEP LOOKING FOR VALID TRANSITION
;---------SET UP DISTANCE TO MIDDLE OF 1ST DATA BIT
        MOV     DX,544          ; 310.USEC AWAY (.838 US / CT)
;---------START LOOKING FOR TIME TO READ DATA BITS AND ASSEMBLE BYTE
I7:     CALL    I30
        MOV     DX,526          ; SET NEW DISTANCE TO NEXT HALF BIT
        PUSH    AX              ; SAVE 1ST HALF BIT
        CALL    I30
        MOV     CL,AL           ; PUT 2ND HALF BIT IN CL
        POP     AX              ; RESTORE 1ST HALF BIT
        CMP     CL,AL           ; ARE THEY OPPOSITES ?
        JE      I9              ; NO, PHASE ERROR
; ----------VALID DATA BIT, PLACE IN SCAN BYTE
        SHR     BH,1            ; SHIFT PREVIOUS BITS
        OR      BH,AL           ; OR IN NEW DATA BIT
        DEC     SI              ; DECREMENT DATA BIT COUNTER
        JNZ     I7              ; CONTINUE FOR MORE DATA BITS
;-----------WAIT FOR TIME TO SAMPLE PARITY BIT
        CALL    I30             
        PUSH    AX              ; SAVE 1ST HALF BIT
        CALL    I30             ; PUT 2ND HALF BIT IN CL
        MOV     CL,AL           ; RESTORE 1ST HALF BIT
        POP     AX              ; ARE THEY OPPOSITES ?
        CMP     CL,AL           ; NO, PHASE ERROR
        JE      I9
;-----------VALID PARITY BIT, CHECK PARITY
        AND     BL,1            ; CHECK IF ODD PARITY
        JZ      I9              ; JMP IF PARITY ERROR
;-----------VALID CHARACTER, SEND TO CHARACTER PROCESSING
        STI                     ; ENABLE INTERRUPTS
        MOV     AL,BH           ; PLACE SCAN CODE IN AL
        INT     48H              ; CHARACTER PROCESSING                               
;-----------RESTORE REGS AND RE-ENABEL NMI
I8:     POP     ES              
        POP     DS              ; RESTORE REGS
        POP     DX
        POP     CX
        POP     BX
        IN      AL,0A0H         ; ENABLE NMI
        POP     AX
        POP     DI
        POP     SI
        IRET                    ; RETURN TO SYSTEM
;-----------PARITY, SYNCH OR PHASE ERROR. OUTPUT MISSED KEY BEEP
I9:     CALL    DDS             ; SETUP ADDRESSING
        CMP     SI,8            ; ARE WE ON THE FIRST DATA BIT?
        JE      I8              ; NO AUDIO FEEDBACK (MIGHT BE A
                                ; ..GLITCH)
        TEST    KB_FLAG_1,01H   ; CHECK IF TRANSMISSION ERRORS
                                ; ..ARE TO BE REPORTED
        JNZ     I10             ; 1=DO NOT BEEP, 0=BEEP
        MOV     BX,080H         ; DURATION OF ERROR BEEP
        MOV     CX,048H         ; FREQUENCY OF ERROR BEEP
        CALL    KB_NOISE        ; AUDIO FEEDBACK
        AND     KB_FLAG,0F0H    ; CLEAR ALT,CLRL,LEFT AND RIGHT
                                ; SHIFTS
        AND     KB_FLAG_1,0FH   ; CLEAR POTENTIAL BREAK OF INS,CAPS
                                ; NUM AND SCROLL SHIFT
        AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
I10:    INC     KBD_ERR         ; KEEP TRACK OF KEYBOARD ERRORS
        JMP     SHORT I8        ; RETURN FROM INTERRUPT
KBDNMI  ENDP
I30     PROC    NEAR
I31:    MOV     AL,40H          ; READ CLOCK
        OUT     TIM_CTL,AL      ; *
        NOP                     ; *
        NOP                     ; *
        IN      AL,TIMER+1      ; *
        MOV     AH,AL           ; *
        IN      AL,TIMER+1      ; *
        XCHG    AH,AL           ; *
        MOV     CX,DI           ; GET LAST CLOCK TIME
        SUB     CX,AX           ; SUB CURRENT TIME
        CMP     CX,DX           ; IS IT TIME TO SAMPLE ?
        JC      I31             ; NO, KEEP LOOKING AT TIME
        SUB     CX,DX           ; UPDATE # OF COUNTS OFF
        MOV     DI,AX           ; SAVE CURRENT TIME AS LAST TIME
        ADD     DI,CX           ; ADD DIFFERENCE FOR NEXT TIME
;-----------START SAMPLING DATA BIT (5 SAMPLES)
        MOV     CX,5            ; SET COUNTER
;-------------------------------------------------------------
;
; SAMPLE LINE
;
;       PORT_C IS SAMPLED CX TIMES AND IF THER ARE 3 OR MORE 1"S
;       THEN 80H IS RETURNED IN AL, ELSE 00H IS RETURNED IN AL.
;       PARITY COUNTER IS MAINTAINED IN ES.
;
;-------------------------------------------------------------                                
        XOR     AH,AH           ; CLEAR COUNTER
I32:    IN      AL,PORT_C       ; GET SAMPLE
        TEST    AL,40H          ; TEST IF 1
        JZ      I33             ; JMP IF 0
        INC     AH              ; KEEP COUNT OF 1'S
I33:    LOOP    I32             ; KEEP SAMPLING
        CMP     AH,3            ; VALID 1 ?
        JB      I34             ; JMP IF NOT VALID 1
        MOV     AL,080H         ; RETURN 80H IN AL (1)
        INC     BL              ; INCREMENT PARITY COUNTER
        RET                     ; RETURN TO CALLER
I34:    XOR     AL,AL           ; RETURN 0 IN AL (0)
        RET                     ; RETURN TO CALLER
I30     ENDP
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
BREAK_BIT       EQU     80H
FN_KEY          EQU     54H
PHK             EQU     FN_KEY+1
EXT_SCAN        EQU     PHK+1   ; BASE CODE FOR SCAN CODES
                                ; EXTENDING BEYOND 83
AND_MASK        EQU     0FFH    ; USED TO SELECTIVELY REMOVE BITS
CLEAR_FLAGS     EQU     AND_MASK - (FN_FLAG+FN_BREAK+FN_PENDING)
; SCAN CODES
B_KEY           EQU     48
Q_KEY           EQU     16
P_KEY           EQU     25
E_KEY           EQU     18
S_KEY           EQU     31
N_KEY           EQU     49
UP_ARROW        EQU     72
DOWN_ARROW      EQU     80
LEFT_ARROW      EQU     75
RIGHT_ARROW     EQU     77
MINUS           EQU     12
EQUALS          EQU     13
NUM_0           EQU     11
; NEW TRANSLATED SCAN CODES
;---------------------------------------------------------------
;NOTE:
;          BREAK, PAUSE, ECHO, AND PRT_SCREEN ARE USED AS OFFSETS
;          INTO THE TABLE 'SCAN'.  OFFSET = TABLE POSITION + 1.
;---------------------------------------------------------------
ECHO            EQU     01
BREAK           EQU     02
PAUSE           EQU     03
PRT_SCREEN      EQU     04
SCROLL_LOCK     EQU     70
NUM_LOCK        EQU     69
HOME            EQU     71
END_KEY         EQU     79
PAGE_UP         EQU     73
PAGE_DOWN       EQU     81
KEYPAD_MINUS    EQU     74
KEYPAD_PLUS     EQU     78
        ASSUME  CS:CODE,DS:DATA
;-----TABLE OF VALID SCAN CODES
KB0             LABEL   BYTE
        DB      B_KEY, Q_KEY, E_KEY, P_KEY, S_KEY, N_KEY
        DB      UP_ARROW, DOWN_ARROW, LEFT_ARROW, RIGHT_ARROW, MINUS
        DB      EQUALS
KB0LEN          EQU     $ - KB0
;-----TABLE OF NEW SCAN CODES
KB1             LABEL   BYTE
        DB      BREAK, PAUSE, ECHO, PRT_SCREEN, SCROLL_LOCK, NUM_LOCK
        DB      HOME,END_KEY,PAGE_UP,PAGE_DOWN,KEYPAD_MINUS,KEYPAD_PLUS
;---------------------------------------------------------------
;NOTE:  THERE IS A ONE TO ONE CORRESPONDENCE BETWEEN
;       THE SIZE OF KB0 AND KB1.
;---------------------------------------------------------------
;TABLE OF NUMERIC KEYPAD SCAN CODES
;       THESE SCAN CODES WERE NUMERIC KEYPAD CODES ON
;       THE 83 KEY KEYBOARD.
;---------------------------------------------------------------
NUM_CODES       LABEL   BYTE
        DB      79,80,81,75,76,77,71,72,73,82

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
SCAN            LABEL   BYTE
        DB      29,55,183,157   ; CTRL + PRTSC
        DB      29,70,198,157   ; CTRL + SCROLL-LOCK
;------------------------------------------------------------
;TABLE OF VALID ALT SHIFT SCAN CODES
;       THIS TABLE CONTAINS SCAN CODES FOR KEYS ON THE
;       62 KEY KEYBOARD.  THESE CODES ARE USED IN
;       COMBINATION WITH THE ALT KEY TO PRODUCE SCAN CODES
;       FOR KEYS NOT FOUND ON THE 62 KEY KEYBOARD.
;------------------------------------------------------------
ALT_TABLE       LABEL   BYTE
        DB      53,40,52,26,27
ALT_LEN         EQU     $ - ALT_TABLE
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

NEW_ALT         LABEL   BYTE
        DB      43,41,55,43,41

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
EXTAB   LABEL   BYTE
        DB      20              ; LENGTH OF TABLE


        DW      72,73,77,81,80,79,75,71,57,28


        DW      17,18,31,45,44,43,30,16,15,1

KEY62_INT PROC  FAR
        STI                     
        CLD                     ; FORWARD DIRECTION
        CALL    DDS             ; SET UP ADDRESSING
        MOV     AH,AL           ; SAVE SCAN CODE
        CALL    TPM             ; ADJUST OUTPUT FOR USER
                                ; MODIFICATION
        JNC     KBX0            ; JUMP IF OK TO CONTINUE
        IRET                    ; RETURN FROM INTERRUPT.
;----EXTENDED SCAN CODE CHECK
KBX0:   CMP     AL,0FFH         ; IS THIS AN OVERRUN CHAR?
        JE      KBO_1           ; PASS IT TO INTERRUPT 9
        AND     AL,AND_MASK-BREAK_BIT ; TURN OFF BREAK BIT
        CMP     AL,EXT_SCAN     ; IS THIS A SCAN CODE > 83
        JL      KBX4            ; REPLACE BREAK BIT
;----SCAN CODE IS IN EXTENDED SET
        PUSH    DS
        XOR     SI,SI
        MOV     DS,SI
        ASSUME  DS:ABS0
        LES     DI,DWORD PTR EXST ; GET THE POINTER TO THE EXTENDED
                                ; SET
        MOV     CL,BYTE PTR ES:[DI] ; GET LENGTH BYTE
        POP     DS
        ASSUME  DS:DATA
;----DOES SCAN CODE GET MAPPED TO KEYBOARD OR TO NEW EXTENDED SCAN
;    CODES?
        SUB     AL,EXT_SCAN     ; CONVERT TO BASE OF NEW SET
        DEC     CL              ; LENGTH - 1
        CMP     AL,CL           ; IS CODE IN TABLE?
        JG      KBX1            ; JUMP IF SCAN CODE IS NOT IN TABLE
;----GET SCAN CODE FROM TABLE
        INC     DI              ; POINT DI PAST LENGTH BYTE
        MOV     BX,AX           ; PREPARE FOR ADDING TO 16 BIT
        XOR     BH,BH           ; REGISTER

        SHL     BX,1            ; OFFSET TO CORRECT TABLE ENTRY
        ADD     DI,BX
        MOV     AL,BYTE PTR ES:[DI] ; TRANSLATED SCAN CODE IN AL
        CMP     AL,EXT_SCAN     ; IS CODE IN KEYBOARD SET?
        JL      KBX4            ; IN KEYBOARD SET, CHECK FOR BREAK
;----SCAN CODE GETS MAPPED TO EXTENDED SCAN CODES
KBX1:   TEST    AH,BREAK_BIT    ; IS THIS A BREAK CODE?
        JZ      KBX2            ; MAKE CODE, PUT IN BUFFER
        IRET                    ; BREAK CODE, RETURN FROM INTERRUPT
KBX2:   ADD     AH,64           ; EXTENDED SET CODES BEGIN AT 150
        XOR     AL,AL           ; ZERO OUT ASCII VALUE (NUL)
        MOV     BX,BUFFER_TAIL  ; GET TAIL POINTER
        MOV     SI,BX           ; SAVE POINTER TO TAIL
        CALL    K4              ; INCREMENT TAIL VALUE
        CMP     BX,BUFFER_HEAD  ; IS BUFFER FULL?
        JNE     KBX3            ; PUT CONTENTS OF AX IN BUFFER
;----BUFFER IS FULL, BEEP AND CLEAR FLAGS
        MOV     BX,80H          ; FREQUENCY OF BEEP
        MOV     CX,48H          ; DURATION OF BEEP
        CALL    KB_NOISE        ; BUFFER FULL BEEP
        AND     KB_FLAG,0F0H    ; CLEAR ALT, CTRL, LEFT AND RIGHT
        AND     KB_FLAG_1,0FH   ; CLEAR MAKE OF INS,CAPS_LOCK,NUM
                                ; AND SCROLL
        AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
        IRET                    ; DONE WITH INTERRUPT
KBX3:   MOV     [SI],AX         ; PUT CONTENTS OF AX IN BUFFER
        MOV     BUFFER_TAIL,BX  ; ADVANCE BUFFER TAIL
        IRET                    ; RETURN FROM INTERRUPT
KBX4:   AND     AH,BREAK_BIT    ; MASK BREAK BIT ON ORIGINAL SCAN
        OR      AL,AH           ; UPDATE NEW SCAN CODE
        MOV     AH,AL           ; SAVE AL IN AH AGAIN
;----83 KEY KEYBOARD FUNCTIONS SHIFT+PRTSC AND CTRL+NUMLOCK
KBO_1:  CMP     AL,NUM_KEY      ; IS THIS A NUMLOCK?
        JNE     KBO_3           ; CHECK FOR PRTSC
        TEST    KB_FLAG,CTL_SHIFT ; IS CTRL KEY BEING HELD DOWN?
        JZ      KBO_2           ; NUMLOCK WITHOUT CTRL, CONTINUE
        TEST    KB_FLAG,ALT_SHIFT ; IS ALT KEY HELD CONCURRENTLY?
        JNZ     KBO_2           ; PASS IT ON
        JMP     KB16_1          ; PUT KEYBOARD IN HOLD STATE
KBO_2:  JMP     CONT_INT        ; CONTINUE WITH INTERRUPT 48H
;----CHECK FOR PRTSC
KBO_3:  CMP     AL,55           ; IS THIS A PRTSC KEY?
        JNZ     KB1_1           ; NOT A PRTSC KEY
        TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; EITHER SHIFT
                                ; ACTIVE?
        JZ      KBO_2           ; PROCESS SCAN IN INT9
        TEST    KB_FLAG,CTL_SHIFT ; IS THE CTRL KEY PRESSED?
        JNZ     KBO_2           ; NOT A VALID PRTSC (PC COMPATIBLE)
        JMP     PRTSC           ; HANDLE THE PRINT SCREEN FUNCTION
;----ALTERNATE SHIFT TRANSLATIONS
KB1_1:  MOV     AH,AL           ; SAVE CHARACTER
        AND     AL, AND_MASK - BREAK_BIT ; MASK BREAK BIT
        TEST    KB_FLAG,ALT_SHIFT ; IS THIS A POTENTIAL TRANSLATION
        JZ      KB2
;----TABLE LOOK UP
        PUSH    CS              ; INITIALIZE SEGMENT FOR TABLE LOOK
        POP     ES              ; UP

        MOV     DI,OFFSET ALT_TABLE
        MOV     CX,ALT_LEN      ; GET READY FOR TABLE LOOK UP
        REPNE   SCASB           ; SEARCH TABLE
        JNE     KB2             ; JUMP IF MATCH IS NOT FOUND
        MOV     CX,OFFSET ALT_TABLE + 1
        SUB     DI,CX           ; UPDATE DI TO INDEX SCAN CODE
        MOV     AL,CS:NEW_ALT[DI] ; TRANSLATE SCAN CODE
;----CHECK FOR BREAK CODE
        MOV     BL,KB_FLAG      ; SAVE KB_FLAG STATUS
        XOR     KB_FLAG,ALT_SHIFT ; MASK OFF ALT SHIFT
        TEST    AH,BREAK_BIT    ; IS THIS A BREAK CHARACTER?
        JZ      KB1_2           ; JUMP IF SCAN IS A MAKE
        OR      AL,BREAK_BIT    ; SET BREAK BIT
;----MAKE CODE, CHECK FOR SHIFT SEQUENCE
KB1_2:  CMP     DI,3            ; IS THIS A SHIFT SEQUENCE
        JL      KB1_3           ; JUMP IF NOT SHIFT SEQUENCE
        OR      KB_FLAG,LEFT_SHIFT ; TURN ON SHIFT FLAG
KB1_3:  OUT     KBPORT,AL
        INT     9H              ; ISSUE INT TO PROCESS SCAN CODE
        MOV     KB_FLAG,BL      ; RESTORE ORIGINAL FLAG STATES
        IRET
;----FUNCTION KEY HANDLER
KB2:    CMP     AL, FN_KEY      ; CHECK FOR FUNCTION KEY
        JNZ     KB4             ; JUMP IF NOT FUNCTION KEY
        TEST    AH, BREAK_BIT   ; IS THIS A FUNCTION BREAK
        JNZ     KB3             ; JUMP IF FUNCTION BREAK
        AND     KB_FLAG_2,CLEAR_FLAGS ; CLEAR ALL PREVIOUS
                                ; FUNCTIONS
        OR      KB_FLAG_2, FN_FLAG + FN_PENDING
        IRET                    ; RETURN FROM INTERRUPT
;----FUNCTION BREAK
KB3:    TEST    KB_FLAG_2,FN_PENDING
        JNZ     KB3_1           ; JUMP IF FUNCTION IS PENDING
        AND     KB_FLAG_2,CLEAR_FLAGS ; CLEAR ALL FLAGS
        IRET
KB3_1:  OR      KB_FLAG_2,FN_BREAK ; SET BREAK FLAG
KB3_2:  IRET                    ; RETURN FROM INTERRUPT
;----CHECK IF FUNCTION FLAG ALREADY SET
KB4:    CMP     AL,PHK          ; IS THIS A PHANTOM KEY?
        JZ      KB3_2           ; JUMP IF PHANTOM SEQUENCE
KB4_0:  TEST    KB_FLAG_2,FN_FLAG+FN_LOCK ; ARE WE IN FUNCTION
                                ; STATE?
        JNZ     KB5             
;----CHECK IF NUM_STATE IS ACTIVE
        TEST    KB_FLAG,NUM_STATE
        JZ      KB4_1           ; JUMP IF NOT IN NUM_STATE
        CMP     AL,NUM_0        ; ARE WE IN NUMERIC KEYPAD REGION?
        JA      KB4_1           ; JUMP IF NOT IN KEYPAD
        DEC     AL              ; CHECK LOWER BOUND OF RANGE
        JZ      KB4_1           ; JUMP IF NOT IN RANGE (ESC KEY)
;----TRANSLATE SCAN CODE TO NUMERIC KEYPAD
        DEC     AL              ; AL IS OFFSET INTO TABLE
        MOV     BX,OFFSET NUM_CODES
        XLAT    CS:NUM_CODES    ; NEW SCAN CODE IS IN AL
        AND     AH,BREAK_BIT    ; ISOLATE BREAK BIT ON ORIGINAL
        OR      AL,AH           ; SCAN CODE
        JMP     SHORT CONT_INT  ; UPDATE KEYPAD SCAN CODE
KB4_1:  MOV     AL,AH           ; GET BACK BREAK BIT IF SET
        JMP     SHORT CONT_INT
;----CHECK FOR VALID FUNCTION KEY
KB5:    CMP     AL, NUM_0       ; CHECK FOR RANGE OF INTEGERS
        JA      KB7             ; JUMP IF NOT IN RANGE
        DEC     AL
        JNZ     KB6             ; CHECK FOR ESC KEY (=1)
;----ESCAPE KEY, LOCK KEYBOARD IN FUNCTION LOCK
        TEST    AH,BREAK_BIT    ; IS THIS A BREAK CODE?
        JNZ     KB8             ; NO PROCESSING FOR ESCAPE BREAK
        TEST    KB_FLAG_2,FN_FLAG ; TOGGLES ONLY WHEN FN HELD
        JZ      KB8             ; CONCURRENTLY
        TEST    KB_FLAG_2,FN_BREAK ; HAS THE FUNCTION KEY BEEN
        JNZ     KB8             ; RELEASED?
; CONTINUE IF RELEASED. PROCESS AS
        TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; EITHER SHIFT?
        JZ      KB8             ; NOT HELD DOWN
        XOR     KB_FLAG_2,FN_LOCK ; TOGGLE STATE
        AND     KB_FLAG_2,CLEAR_FLAGS ; TURN OFF OTHER STATES
        IRET                    ; RETURN FROM INTERUPT
;----SCAN CODE IN RANGE 1 -> 0
KB6:    ADD     AL, 58          ; GENERATE CORRECT SCAN CODE
        JMP     SHORT KB12      ; CLEAN-UP BEFORE RETURN TO KB_INT
;----CHECK TABLE FOR OTHER VALID SCAN CODES
KB7:    PUSH    CS              ; ESTABLISH ADDRESS OF TABLE
        POP     ES
        MOV     DI, OFFSET KB0  ; BASE OF TABLE
        MOV     CX, KB0LEN      ; LENGTH OF TABLE
        REPNE   SCASB           ; SEARCH TABLE FOR A MATCH
        JE      KB10            ; JUMP IF MATCH
;----ILLEGAL CHARACTER
KB8:    TEST    KB_FLAG_2,FN_BREAK ; HAS BREAK OCCURED?
        JZ      KB9             ; FUNCTION KEY HAS NOT BEEN
        TEST    AH,BREAK_BIT    ; RELEASED
        JNZ     KB9             ; DON'T RESET FLAGS ON ILLEGAL
                                ; BREAK
KB8S:   AND     KB_FLAG_2,CLEAR_FLAGS ; NORMAL STATE
        MOV     CUR_FUNC,0      ; RETRIEVE ORIGINAL SCAN CODE
;----FUNCTION BREAK IS NOT SET
KB9:    MOV     AL,AH           ; RETRIEVE ORIGINAL SCAN CODE
CONT_INT:
        OUT     KBPORT,AL
        INT     9H              ; ISSUE KEYBOARD INTERRUPT
RET_INT:
        IRET
;----BEFORE TRANSLATION CHECK FOR ALT+FN+N_KEY AS NUM LOCK
KB10:   CMP     AL,N_KEY        ; IS THIS A POTENTIAL NUMLOCK?
        JNE     KB10_1          ; NOT A NUMKEY, TRANSLATE IT
        TEST    KB_FLAG,ALT_SHIFT ; ALT HELD DOWN ALSO?
        JZ      KB8             ; TREAT AS ILLEGAL COMBINATION
KB10_1: MOV     CX, OFFSET KB0 + 1 ; GET OFFSET TO TABLE
        SUB     DI, CX          ; UPDATE INDEX TO NEW SCAN CODE
        MOV     AL, CS:KB1[DI]  ; MOV NEW SCAN CODE INTO REGISTER
;----TRANSLATED CODE IN AL OR AN OFFSET TO THE TABLE "SCAN"
KB12:   TEST    AH,BREAK_BIT    ; IS THIS A BREAK CHAR?
        JZ      KB13            ; JUMP IF MAKE CODE
;----CHECK FOR TOGGLE KEY
        CMP     AL,NUM_LOCK     ; IS THIS A NUM LOCK?
        JZ      KB12_1          ; JUMP IF TOGGLE KEY
        CMP     AL, SCROLL_LOCK ; IS THIS A SCROLL LOCK?
        JNZ     KB12_2          ; JUMP IF NOT A TOGGLE KEY
KB12_1: OR      AL,80H          ; TURN ON BREAK BIT
        OUT     KBPORT,AL
        INT     9H
        AND     AL,AND_MASK-BREAK_BIT ; TURN OFF BREAK BIT
KB12_2: TEST    KB_FLAG_2,FN_BREAK ; HAS FUNCTION BREAK OCCURED?
        JZ      KB12_3          ; JUMP IF BREAK HAS NOT OCCURED
        CMP     AL,CUR_FUNC     ; IS THIS A BREAK OF OLD VALID
; FUNCTION
        JNE     RET_INT         ; ALLOW FURTHER CURRENT FUNCTIONS
        AND     KB_FLAG_2,CLEAR_FLAGS
KB12_20:
        MOV     CUR_FUNC,0      ; CLEAR CURRENT FUNCTION
        IRET                    ; RETURN FROM INTERRUPT
KB12_3: CMP     AL,CUR_FUNC     ; IS THIS BREAK OF FIRST FUNCTION?
        JNE     RET_INT         ; IGNORE
        AND     KB_FLAG_2,AND_MASK-FN_PENDING ; TURN OFF PENDING
                                ; FUNCTION
        JMP     KB12_20         ; CLEAR CURRENT FUNCTION AND RETURN
;-----VALID MAKE KEY HAS BEEN PRESSED
KB13:   TEST    KB_FLAG_2,FN_BREAK ; CHECK IF FUNCTION KEY HAS BEEN
                                ; PRESSED
        JZ      KB14_1          ; JUMP IF NOT SET
;-----FUNCTION BREAK HAS ALREADY OCCURED
        CMP     CUR_FUNC,0      ; IS THIS A NEW FUNCTION?
        JZ      KB14_1          ; INITIALIZE NEW FUNCTION
        CMP     CUR_FUNC,AL     ; IS THIS NON-CURRENT FUNCTION
        JNZ     KB8S            ; JUMP IF NO FUNCTION IS PENDING
                                ; ...TO RETRIEVE ORIGINAL SCAN CODE
;-----CHECK FOR SCAN CODE GENERATION SEQUENCE
KB14_1: MOV     CUR_FUNC,AL     ; INITIALIZE CURRENT FN
KB16:   CMP     AL,PRT_SCREEN   ; IS THIS A SIMULATED SEQUENCE?
        JG      CONT_INT        ; JUMP IF THIS IS A SIMPLE
                                ; TRANSLATION
        JZ      PRTSC           ; DO THE PRINT SCREEN FUNCTION
        CMP     AL,PAUSE        ; IS THIS THE HOLD FUNCTION?
        JZ      KB16_1          ; DO THE PAUSE FUNCTION
;-----BREAK OR ECHO
        DEC     AL              ; POINT AT BASE
        SHL     AL,1
        SHL     AL,1            ; MULTIPLY BY 4
        CBW
        LEA     SI,SCAN         ; ADDRESS SEQUENCE OF SIMULATED
                                ; KEYSTROKES
        ADD     SI,AX           ; UPDATE TO POINT AT CORRECT SET
        MOV     CX,4            ; LOOP COUNTER
GENERATE:
        LODS    SCAN            ; GET SCAN CODE FROM TABLE
        OUT     KBPORT,AL
        INT     9H              ; PROCESS IT
        LOOP    GENERATE        ; GET NEXT
        IRET
;-----PUT KEYBOARD IN HOLD STATE
KB16_1: TEST    KB_FLAG_1,HOLD_STATE ; CANNOT GO IN HOLD STATE IF
                                ; ITS ACTIVE
        JNZ     KB16_2          ; DONE WITH INTERRUPT
        OR      KB_FLAG_1,HOLD_STATE ; TURN ON HOLD FLAG
        IN      AL,NMI_PORT     ; RESET KEYBOARD LATCH
HOLD:   TEST    KB_FLAG_1,HOLD_STATE ; STILL IN HOLD STATE?
        JNZ     HOLD            ; CONTINUE LOOPING UNTIL KEY IS
                                ; PRESSED
KB16_2: IRET                    ; RETURN FROM INTERRUPT 48H
;-----PRINT SCREEN FUNCTION
PRTSC:  TEST    KB_FLAG_1,HOLD_STATE ; IS HOLD STATE IN PROGRESS?
        JZ      KB16_3          ; OK TO CONTINUE WITH PRTSC
        AND     KB_FLAG_1,0FFH-HOLD_STATE ; TURN OFF FLAG
        IRET
KB16_3: ADD     SP,3*2          ; GET RID OF CALL TO INTERRUPT 48H
        POP     ES              ; POP REGISTERS THAT AREN'T
                                ; MODIFIED IN INT5
        POP     DS
        POP     DX
        POP     CX
        POP     BX
        IN      AL,NMI_PORT     ; RESET KEYBOARD LATCH
        INT     5H              ; ISSUE INTERRUPT
        POP     AX
        POP     DI
        POP     SI
        IRET
KEY62_INT ENDP
;----------------------------------------------------------------
; TYPAMATIC
;       THIS ROUTINE WILL CHECK KEYBOARD STATUS BITS IN KB_FLAG_2
;       AND DETERMINE WHAT STATE THE KEYBOARD IS IN.  APPROPRIATE
;       ACTION WILL BE TAKEN.
;
;INPUT  AL= SCAN CODE OF KEY WHICH TRIGGERED NON-MASKABLE INTERRUPT
;
;OUTPUT
;       CARRY BIT = 1 IF NO ACTION IS TO BE TAKEN.
;       CARRY BIT = 0 MEANS SCAN CODE IN AL SHOULD BE PROCESSED
;                     FURTHER.
;       MODIFICATIONS TO THE VARIABLES CUR_CHAR AND VAR_DELAY ARE
;       MADE.  ALSO THE PUTCHAR BIT IN KB_FLAG_2 IS TOGGLED WHEN
;       THE KEYBOARD IS IN HALF RATE MODE.
;----------------------------------------------------------------
TPM     PROC    NEAR
        PUSH    BX
        CMP     CUR_CHAR,AL     ; IS THIS A NEW CHARACTER?
        JZ      TP2             ; JUMP IF SAME CHARACTER
;-----NEW CHARACTER CHECK FOR BREAK SEQUENCES
        TEST    AL,BREAK_BIT    ; IS THE NEW KEY A BREAK KEY?
        JZ      TP0             ; JUMP IF NOT A BREAK
        AND     AL,07FH         ; CLEAR BREAK BIT
        CMP     CUR_CHAR,AL     ; IS NEW CHARACTER THE BREAK OF
                                ; LAST MAKE?
        MOV     AL,AH           ; RETRIEVE ORIGINAL CHARACTER
        JNZ     TP              ; JUMP IF NOT THE SAME CHARACTER
        MOV     CUR_CHAR,00     ; CLEAR CURRENT CHARACTER
TP:     CLC                     ; CLEAR CARRY BIT
        POP     BX
        RET                     ; RETURN
;----INITIALIZE A NEW CHARACTER
TP0:    MOV     CUR_CHAR,AL     ; SAVE NEW CHARACTER
        AND     VAR_DELAY,0F0H  ; CLEAR VARIABLE DELAY
        AND     KB_FLAG_2,0FEH  ; INITIAL PUTCHAR BIT AS ZERO
        TEST    KB_FLAG_2,INIT_DELAY ; ARE WE INCREASING THE
        JZ      TP              ; INITIAL DELAY?
        OR      VAR_DELAY,DELAY_RATE ; INCREASE DELAY BY 2X
        JMP     SHORT TP        ; DEFAULT DELAY
;----CHECK IF WE ARE IN TYPAMATIC MODE AND IF DELAY IS OVER
TP2:    TEST    KB_FLAG_2,TYPE_OFF ; IS TYPAMATIC TURNED OFF?
        JNZ     TP4             ; JUMP IF TYPAMATIC RATE IS OFF
        MOV     BL,VAR_DELAY    ; GET VAR_DEALY
        AND     BL,0FH          ; MASK OFF HIGH ORDER(SCREEN RANGE)
        OR      BL,BL           ; IS INITIAL DELAY OVER?
        JZ      TP3             ; JUMP IF DELAY IS OVER
        DEC     BL              ; DECREASE DELAY WAIT BY ANOTHER
        AND     VAR_DELAY,0F0H  ; CHARACTER
        OR      VAR_DELAY,BL
        JMP     SHORT TP4
;----CHECK IF TIME TO OUTPUT CHAR
TP3:    TEST    KB_FLAG_2,HALF_RATE ; ARE WE IN HALF RATE MODE
        JZ      TP              ; JUMP IF WE ARE IN NORMAL MODE
        XOR     KB_FLAG_2,PUTCHAR ; TOGGLE BIT
        TEST    KB_FLAG_2,PUTCHAR ; IS IT TIME TO PUT OUT A CHAR
        JNZ     TP              ; NOT TIME TO OUTPUT CHARACTER
TP4:                            ; SKIP THIS CHARACTER
        STC                     ; SET CARRY FLAG
        POP     BX
        RET
TPM     ENDP
;----------------------------------------------------------------
; THIS SUBROUTINE SETS DS TO POINT TO THE BIOS DATA AREA
; INPUT: NONE
; OUTPUT: DS IS SET
;----------------------------------------------------------------
DDS     PROC    NEAR
        PUSH    AX
        MOV     AX,40H
        MOV     DS,AX
        POP     AX
        RET
DDS     ENDP
;---- INT 1A -----------------------------------------------------
; TIME_OF_DAY/SOUND SOURCE SELECT
;     THIS ROUTINE ALLOWS THE CLOCK TO BE SET/READ.
;     AN INTERFACE FOR SETTING THE MULTIPLEXER FOR
;     AUDIO SOURCE IS ALSO PROVIDED
;
; INPUT
;     (AH) = 0     READ THE CURRENT CLOCK SETTING
;                 RETURNS CX = HIGH PORTION OF COUNT
;                         DX = LOW PORTION OF COUNT
;                         AL = 0 IF TIMER HAS NOT PASSED 24 HOURS
;                              SINCE LAST READ. <> 0 IF ON ANOTHER DAY
;     (AH) = 1     SET THE CURRENT CLOCK
;                 CX = HIGH PORTION OF COUNT
;                 DX = LOW PORTION OF COUNT
;     (AH) = 80H   SET UP SOUND MULTIPLEXER
;                 AL =(SOURCE OF SOUND) --> "AUDIO OUT" OR RF MODULATOR
;                     00 = 8253 CHANNEL 2
;                     01 = CASSETTE INPUT
;                     02 = "AUDIO IN" LINE ON I/O CHANNEL
;                     03 = COMPLEX SOUND GENERATOR CHIP
;
; NOTE: COUNTS OCCUR AT THE RATE OF 1193180/65536 COUNTS/SEC
;       (OR ABOUT 18.2 PER SECOND -- SEE EQUATES BELOW)
;----------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
TIME_OF_DAY     PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE SEGMENT
        CALL    DDS
        CMP     AH,80H          ; AH=80
        JE      T4A             ; MUX_SET-UP
        OR      AH,AH           ; AH=0
        JZ      T2              ; READ_TIME
        DEC     AH
        JZ      T3              ; SET_TIME
T1:     STI                     ; INTERRUPTS BACK ON
        POP     DS              ; RECOVER SEGMENT
        IRET                    ; RETURN TO CALLER
T2:     CLI                     ; NO TIMER INTERRUPTS WHILE READING
        MOV     AL,TIMER_OFL
        MOV     TIMER_OFL,0     ; GET OVERFLOW, AND RESET THE FLAG
        MOV     CX,TIMER_HIGH
        MOV     DX,TIMER_LOW
        JMP     T1              ; TOD_RETURN
T3:     CLI                     ; NO INTERRUPTS WHILE WRITING
        MOV     TIMER_LOW,DX
        MOV     TIMER_HIGH,CX   ; SET THE TIME
        MOV     TIMER_OFL,0     ; RESET OVERFLOW
        JMP     T1              ; TOD_RETURN
T4A:    PUSH    CX              ;
        MOV     CL,5            ; SHIFT PARM BITS LEFT 5 POSITIONS
        SAL     AL,CL           ; SAVE PARM
        XCHG    AL,AH           ; GET CURRENT PORT SETTINGS
        IN      AL,PORT_B       ; ISOLATE MUX BITS
        AND     AL,10011111B    ; COMBINE PORT BITS/PARM BITS
        OR      AL,AH           ; SET PORT TO NEW VALUE
        OUT     PORT_B,AL
        POP     CX
        JMP     T1              ; TOD_RETURN
TIME_OF_DAY     ENDP
;----- INT 16 ------------------------------------------------
; KEYBOARD I/O
;       THESE ROUTINES PROVIDE KEYBOARD SUPPORT
; INPUT
;       (AH)=0  READ THE NEXT ASCII CHARACTER STRUCK FROM THE
;               KEYBOARD, RETURN THE RESULT IN (AL), SCAN CODE IN
;               (AH)
;       (AH)=1  SET THE Z FLAG TO INDICATE IF AN ASCII CHARACTER IS
;               AVAILABLE TO BE READ.
;                       (ZF)=1 -- NO CODE AVAILABLE
;                       (ZF)=0 -- CODE IS AVAILABLE
;               IF ZF = 0, THE NEXT CHARACTER IN THE BUFFER TO BE
;               READ IS IN AX, AND THE ENTRY REMAINS IN THE BUFFER
;       (AH)=2  RETURN THE CURRENT SHIFT STATUS IN AL REGISTER
;               THE BIT SETTINGS FOR THIS CODE ARE INDICATED IN THE
;               THE EQUATES FOR KB_FLAG
;       (AH)=3  SET TYPAMATIC RATES. THE TYPAMATIC RATE CAN BE
;               CHANGED USING THE FOLLOWING FUNCTIONS:
;                       (AL)=0   RETURN TO DEFAULT.  RESTORES ORIGINAL
;                               STATE. I.E. TYPAMATIC ON, NORMAL INITIAL
;                               DELAY, AND NORMAL TYPAMATIC RATE.
;                       (AL)=1   INCREASE INITIAL DELAY. THIS IS THE
;                               DELAY BETWEEN THE FIRST CHARACTER AND
;                               THE BURST OF TYPAMATIC CHARS.
;                       (AL)=2   HALF_RATE. SLOWS TYPAMATIC CHARACTERS
;                               BY ONE HALF.
;                       (AL)=3   COMBINES AL=1 AND AL=2. INCREASES
;                               INITIAL DELAY AND SLOWS TYPAMATIC
;                               CHARACTERS BY ONE HALF.
;                       (AL)=4   TURN OFF TYPAMATIC CHARACTERS. ONLY THE
;                               FIRST CHARACTER IS HONORED. ALL OTHERS
;                               ARE IGNORED.
;               AL IS RANGE CHECKED. IF AL<0 OR AL>4 THE STATE
;               REMAINS THE SAME.
;               ***NOTE*** EACH TIME THE TYPAMATIC RATES ARE
;               CHANGED ALL PREVIOUS STATES ARE REMOVED. I.E. IF
;               THE KEYBOARD IS IN THE HALF RATE MODE AND YOU WANT
;               TO ADD AN INCREASE IN TYPAMATIC DELAY, YOU MUST
;               CALL THIS ROUTINE WITH AH=3 AND AL=3.
;       (AH)=4   ADJUST KEYBOARD BY THE VALUE IN AL AS FOLLOWS:
;                       (AL)=0   TURN OFF KEYBOARD CLICK.
;                       (AL)=1   TURN ON KEYBOARD CLICK.
;               AL IS RANGE CHECKED. THE STATE IS UNALTERED IF
;               AL <> 1,0.
; OUTPUT
;       AS NOTED ABOVE, ONLY AX AND FLAGS CHANGED
;       ALL REGISTERS RETAINED
;-------------------------------------------------------------------------
KEYBOARD_IO     PROC    FAR
ASSUME  CS:CODE,DS:DATA
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE CURRENT DS
        PUSH    BX              ; SAVE BX TEMPORARILY
        CALL    DDS             ; POINT DS AT BIOS DATA SEGMENT
        OR      AH,AH           ; AH=0
        JZ      K1              ; ASCII_READ
        DEC     AH              ; AH=1
        JZ      K2              ; ASCII_STATUS
        DEC     AH              ; AH=2
        JZ      K3              ; SHIFT_STATUS
        JMP     SHORT K3_1
;------- READ THE KEY TO FIGURE OUT WHAT TO DO
K1:                             ; ASCII READ
        STI                     ; INTERRUPTS BACK ON DURING LOOP
        NOP                     ; ALLOW AN INTERRUPT TO OCCUR
        CLI                     ; INTERRUPTS BACK OFF
        MOV     BX,BUFFER_HEAD  ; GET POINTER TO HEAD OF BUFFER
        CMP     BX,BUFFER_TAIL  ; TEST END OF BUFFER
        JZ      K1              ; LOOP UNTIL SOMETHING IN BUFFER
        MOV     AX,[BX]         ; GET SCAN CODE AND ASCII CODE
        CALL    K4              ; MOVE POINTER TO NEXT POSITION
        MOV     BUFFER_HEAD,BX  ; STORE VALUE IN VARIABLE
        JMP     SHORT RET_INT16
;------- ASCII STATUS
K2:     CLI                     ; INTERRUPTS OFF
        MOV     BX,BUFFER_HEAD  ; GET HEAD POINTER
        CMP     BX,BUFFER_TAIL  ; IF EQUAL (Z=1) THEN NOTHING THERE
        MOV     AX,[BX]
        STI                     ; INTERRUPTS BACK ON
        POP     BX              ; RECOVER REGISTER
        POP     DS              ; RECOVER SEGMENT
        RET     2               ; THROW AWAY FLAGS
;------- SHIFT STATUS
K3:     MOV     AL,KB_FLAG      ; GET THE SHIFT STATUS FLAGS
        JMP     SHORT RET_INT16
K3_1:   DEC     AH              ; AH=3, ADJUST TYPAMATIC
        JZ      K3_3            ; RANGE CHECK FOR AH=4
        DEC     AH              ; ILLEGAL FUNCTION CALL
        JNZ     RET_INT16       ; TURN OFF KEYBOARD CLICK?
        OR      AL,AL
        JNZ     K3_2            ; JUMP FOR RANGE CHECK
        AND     KB_FLAG_1,AND_MASK-CLICK_ON ; TURN OFF CLICK
        JMP     SHORT RET_INT16
K3_2:   CMP     AL,1            ; RANGE CHECK
        JNE     RET_INT16       ; NOT IN RANGE, RETURN
        OR      KB_FLAG_1,CLICK_ON ; TURN ON KEYBOARD CLICK
        JMP     SHORT RET_INT16
;------- SET TYPAMATIC
K3_3:   CMP     AL,4            ; CHECK FOR CORRECT RANGE
        JG      RET_INT16       ; IF ILLEGAL VALUE IN AL IGNORE
        AND     KB_FLAG_2,0F1H  ; MASK OFF ANY OLD TYPAMATIC STATES
        SHL     AL,1            ; SHIFT TO PROPER POSITION
        OR      KB_FLAG_2,AL
RET_INT16:
        POP     BX              ; RECOVER REGISTER
        POP     DS              ; RECOVER REGISTER
        IRET                    ; RETURN TO CALLER
KEYBOARD_IO     ENDP

;------- INCREMENT A BUFFER POINTER
K4      PROC    NEAR
        INC     BX              ; MOVE TO NEXT WORD IN LIST
        INC     BX
        CMP     BX,BUFFER_END   ; AT END OF BUFFER?
        JNE     K5              ; NO, CONTINUE
        MOV     BX,BUFFER_START ; YES, RESET TO BUFFER BEGINNING
K5:     RET
K4      ENDP
;------- TABLE OF SHIFT KEYS AND MASK VALUES
K6      LABEL   BYTE
        DB      INS_KEY         ; INSERT KEY
        DB      CAPS_KEY,NUM_KEY,SCROLL_KEY,ALT_KEY,CTL_KEY
        DB      LEFT_KEY,RIGHT_KEY
K6L     EQU     $-K6
;------- SHIFT_MASK_TABLE
K7      LABEL   BYTE
        DB      INS_SHIFT       ; INSERT MODE SHIFT
        DB      CAPS_SHIFT,NUM_SHIFT,SCROLL_SHIFT,ALT_SHIFT,CTL_SHIFT
        DB      LEFT_SHIFT,RIGHT_SHIFT
;------- SCAN CODE TABLES
K8      DB      27,-1,0,-1,-1,-1,30,-1

        DB      -1,-1,-1,31,-1,127,-1,17

        DB      23,5,18,20,25,21,9,15

        DB      16,27,29,10,-1,1,19

        DB      4,6,7,8,10,11,12,-1,-1

        DB      -1,-1,28,26,24,3,22,2

        DB      14,13,-1,-1,-1,-1,-1,-1

        DB      ' ', -1
;------- CTL TABLE SCAN
K9      LABEL   BYTE
        DB      94,95,96,97,98,99,100,101

        DB      102,103,-1,-1,119,-1,132,-1

        DB      115,-1,116,-1,117,-1,118,-1

        DB      -1

;------- LC TABLE
K10     LABEL   BYTE
        DB      01BH,'1234567890-=',08H,09H


        DB      'qwertyuiop[]',0DH,-1,'asdfghjkl;',027H




        DB      60H,-1,5CH,'zxcvbnm,./',-1,'*',-1,' '


        DB      -1

;------- UC TABLE
K11     LABEL   BYTE
        DB      27,'!@#$%',05EH,'&*()_+',08H,0


        DB      'QWERTYUIOP{}',0DH,-1,'ASDFGHJKL:"'




        DB      07EH,-1,'|ZXCVBNM<>?',-1,0,-1,' ', -1


;-------   UC TABLE SCAN
K12     LABEL   BYTE
        DB      84,85,86,87,88,89,90

        DB      91,92,93

;-------   ALT TABLE SCAN
K13     LABEL   BYTE
       DB      104,105,106,107,108
       DB      109,110,111,112,113

;-------   NUM STATE TABLE
K14     LABEL   BYTE
        DB      '789-456+1230.'



;-------   BASE CASE TABLE
K15     LABEL   BYTE
        DB      71,72,73,-1,75,-1,77

        DB      -1,79,80,81,82,83

;-------   KEYBOARD INTERRUPT ROUTINE
KB_INT  PROC    FAR
        STI                     ; ALLOW FURTHER INTERRUPTS
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES
        CLD                     ; FORWARD DIRECTION
        CALL    DDS
        MOV     AH,AL           ; SAVE SCAN CODE IN AH
;------- TEST FOR OVERRUN SCAN CODE FROM KEYBOARD
        CMP     AL,0FFH         ; IS THIS AN OVERRUN CHAR?
        JNZ     K16             ; NO, TEST FOR SHIFT KEY
        MOV     BX,80H          ; DURATION OF ERROR BEEP
        MOV     CX,48H          ; FREQUENCY OF TONE
        CALL    KB_NOISE        ; BUFFER FULL BEEP
        AND     KB_FLAG,0F0H    ; CLEAR ALT,CLRL,LEFT AND RIGHT
                                ; SHIFTS
        AND     KB_FLAG_1,0FH   ; CLEAR POTENTIAL BREAK OF INS,CAPS
                                ; ,NUM AND SCROLL SHIFT
        AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
        JMP     K26             ; END OF INTERRUPT

;-------   TEST FOR SHIFT KEYS
K16:    AND     AL,07FH         ; TEST_SHIFT
        PUSH    CS              ; TURN OFF THE BREAK BIT
        POP     ES
        MOV     DI,OFFSET K6    ; ESTABLISH ADDRESS OF SHIFT TABLE
        MOV     CX,K6L          ; SHIFT KEY TABLE
        REPNE   SCASB           ; LOOK THROUGH THE TABLE FOR A
                                ; MATCH
        MOV     AL,AH           ; RECOVER SCAN CODE
        JE      K17             ; JUMP IF MATCH FOUND
        JMP     K25             ; IF NO MATCH, THEN SHIFT NOT FOUND

K17:    SUB     DI,OFFSET K6+1  ; ADJUST PTR TO SCAN CODE MATCH
        MOV     AH,CS:K7[DI]    ; GET MASK INTO AH
        TEST    AL,80H          ; TEST FOR BREAK KEY
        JNZ     K23             ; BREAK_SHIFT_FOUND

;------- SHIFT MAKE FOUND, DETERMINE SET OR TOGGLE
        CMP     AH,SCROLL_SHIFT
        JAE     K18             ; IF SCROLL SHIFT OR ABOVE, TOGGLE
                                ; KEY

;------- PLAIN SHIFT KEY, SET SHIFT ON
        OR      KB_FLAG,AH      ; TURN ON SHIFT BIT
        JMP     K26             ; INTERRUPT_RETURN

;-------   TOGGLED SHIFT KEY, TEST FOR 1ST MAKE OR NOT
K18:    TEST    KB_FLAG,CTL_SHIFT ; SHIFT-TOGGLE
        JNZ     K25             ; JUMP IF CTL STATE
        CMP     AL, INS_KEY     ; CHECK FOR INSERT KEY
        JNZ     K22             ; JUMP IF NOT INSERT KEY
        TEST    KB_FLAG,ALT_SHIFT ; CHECK FOR ALTERNATE SHIFT
        JNZ     K25             ; JUMP IF ALTERNATE SHIFT
        TEST    KB_FLAG,NUM_STATE ; CHECK FOR BASE STATE
        JNZ     K21             ; JUMP IF NUM LOCK IS ON
        TEST    KB_FLAG,LEFT_SHIFT+ RIGHT_SHIFT ;
        JZ      K22             ; JUMP IF BASE STATE

K20:                            ; NUMERIC ZERO, NOT INSERT KEY
        MOV     AX,5230H        ; PUT OUT AN ASCII ZERO
        JMP     K57             ; BUFFER_FILL
                                ; MIGHT BE NUMERIC
K21:
        TEST    KB_FLAG, LEFT_SHIFT+ RIGHT_SHIFT
        JZ      K20             ; JUMP NUMERIC, NOT INSERT
K22:                            ; SHIFT TOGGLE KEY HIT; PROCESS IT
        TEST    AH,KB_FLAG_1    ; IS KEY ALREADY DEPRESSED
        JNZ     K26             ; JUMP IF KEY ALREADY DEPRESSED
        OR      KB_FLAG_1,AH    ; INDICATE THAT THE KEY IS
                                ; DEPRESSED

        XOR     KB_FLAG,AH      ; TOGGLE THE SHIFT STATE
        CMP     AL,INS_KEY      ; TEST FOR 1ST MAKE OF INSERT KEY
        JNE     K26             ; JUMP IF NOT INSERT KEY
        MOV     AX,INS_KEY*256  ; SET SCAN CODE INTO AH, 0 INTO AL
        JMP     K57             ; PUT INTO OUTPUT BUFFER
;------- BREAK SHIFT FOUND
K23:    CMP     AH,SCROLL_SHIFT ; IS THIS A TOGGLE KEY
        JAE     K24             ; YES, HANDLE BREAK TOGGLE
        NOT     AH              ; INVERT MASK
        AND     KB_FLAG,AH      ; TURN OFF SHIFT BIT
        CMP     AL,ALT_KEY+80H  ; IS THIS ALTERNATE SHIFT RELEASE
        JNE     K26             ; INTERRUPT_RETURN
;------- ALTERNATE SHIFT KEY RELEASED, GET THE VALUE INTO BUFFER
        MOV     AL,ALT_INPUT    
        XOR     AH,AH           ; SCAN CODE OF 0
        MOV     ALT_INPUT,AH    ; ZERO OUT THE FIELD
        OR      AL,AL           ; WAS THE INPUT=0?
        JE      K26             ; INTERRUPT_RETURN
        JMP     K58             ; BREAK-TOGGLE

K24:    CMP     AL,CAPS_KEY+BREAK_BIT ; SPECIAL CASE OF TOGGLE KEY
        JNE     K24_1           ; JUMP AROUND POTENTIAL UPDATE
        TEST    KB_FLAG_1,CLICK_SEQUENCE ; TEST CLICK
        JZ      K24_1           ; JUMP IF NOT SPECIAL CASE
        AND     KB_FLAG_1,AND_MASK-CLICK_SEQUENCE ; MASK OFF MAKE
                                ; OF CLICK
        JMP     K26             ; INTERRUPT IS OVER

;------- BREAK OF NORMAL TOGGLE
K24_1:  NOT     AH              ; INVERT MASK
        AND     KB_FLAG_1,AH
        JMP     SHORT K26       ; INTERRUPT_RETURN

;------- TEST FOR HOLD STATE
K25:    CMP     AL,80H          ; NO-SHIFT-FOUND
        JAE     K26             ; TEST FOR BREAK KEY
                                ; NOTHING FOR BREAK CHARS FROM HERE
                                ; ON
        TEST    KB_FLAG_1,HOLD_STATE ; ARE WE IN HOLD STATE?
        JZ      K28             ; BRANCH AROUND TEST IF NOT
        AND     KB_FLAG_1,NOT HOLD_STATE ; TURN OFF THE HOLD STATE
                                ; BIT
                                ; INTERRUPT-RETURN

K26:    POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        IRET                    ; RETURN, INTERRUPTS BACK ON WITH
                                ; FLAG CHANGE

;------- NOT IN HOLD STATE, TEST FOR SPECIAL CHARS
K28:    TEST    KB_FLAG,ALT_SHIFT ; ARE WE IN ALTERNATE SHIFT
        JNZ     K29             ; JUMP IF ALTERNATE SHIFT
        JMP     K38             ; JUMP IF NOT ALTERNATE

;------- TEST FOR ALT+CTRL KEY SEQUENCES
K29:    TEST    KB_FLAG,CTL_SHIFT ; ARE WE IN CONTROL SHIFT ALSO
        JZ      K31             ; NO_RESET
        CMP     AL,DEL_KEY      ; SHIFT STATE IS THERE, TEST KEY
        JNE     K29_1           ; NO_RESET

;------- CTL-ALT-DEL HAS BEEN FOUND, DO I/O CLEANUP
        MOV     RESET_FLAG,1234H ; SET FLAG FOR RESET FUNCTION
        JMP     NEAR PTR RESET  ; JUMP TO POWER ON DIAGNOSTICS
K29_1:  CMP     AL,INS_KEY      ; CHECK FOR RESET WITH DIAGNOSTICS
        JNE     K29_2           ; CHECK FOR OTHER
                                ; ALT-CTRL-SEQUENCES

;------- ALT-CTRL-INS HAS BEEN FOUND
        MOV     RESET_FLAG,4321H ; SET FLAG FOR DIAGNOSTICS
        JMP     NEAR PTR RESET  ; LEVEL 1 DIAGNOSTICS
K29_2:  CMP     AL,CAPS_KEY     ; CHECK FOR KEYBOARD CLICK TOGGLE
        JNE     K29_3           ; CHECK FOR SCREEN ADJUSTMENT

;------- ALT+CTRL+CAPSLOCK HAS BEEN FOUND
        TEST    KB_FLAG_1,CLICK_SEQUENCE
        JNZ     K26             ; JUMP IF SEQUENCE HAS ALREADY
                                ; OCCURED
        XOR     KB_FLAG_1,CLICK_ON ; TOGGLE BIT FOR AUDIO KEYSTROKE
                                ; FEEDBACK
        OR      KB_FLAG_1,CLICK_SEQUENCE ; SET CLICK_SEQUENCE STATE
        JMP     SHORT K26       ; INTERRUPT IS OVER
K29_3:  CMP     AL,RIGHT_ARROW  ; ADJUST SCREEN TO THE RIGHT?
        JNE     K29_4           ; LOOK FOR RIGHT ADJUSTMENT
        CALL    GET_POS         ; GET THE # OF POSITIONS SCREEN IS
                                ; SHIFTED
        CMP     AL,0-RANGE      ; IS SCREEN SHIFTED AS FAR AS
                                ; POSSIBLE?
        JL      K26             ; OUT OF RANGE
        DEC     HORZ_POS        ; SHIFT VALUE TO THE RIGHT
        DEC     AL              ; DECREASE RANGE VALUE
        CALL    PUT_POS         ; RESTORE STORAGE LOCATION
        JMP     SHORT K29_5     ; ADJUST
K29_4:  CMP     AL,LEFT_ARROW   ; ADJUST SCREEN TO THE LEFT?
        JNE     K31             ; NOT AN ALT_CTRL SEQUENCE
        CALL    GET_POS         ; GET NUMBER OF POSITIONS SCREEN IS
                                ; SHIFTED

        CMP     AL,RANGE        ; IS SCREEN SHIFTED AS FAR AS
                                ; POSSIBLE?
        JG      K26             ; SHIFT SCREEN TO THE LEFT
        INC     HORZ_POS        ; INCREASE NUMBER OF POSITIONS
        INC     AL              ; SCREEN IS SHIFTED

        CALL    PUT_POS         ; PUT POSTION BACK IN STORAGE
K29_5:  MOV     AL,2            ; ADJUST
        MOV     DX,3D4H         ; ADDRESS TO CRT CONTROLLER
        OUT     DX,AL           ;
        MOV     AL,HORZ_POS     ; COLUMN POSITION
        INC     DX              ; POINT AT DATA REGISTER
        OUT     DX,AL           ; MOV POSITION
        JMP     K26             ;
;------- IN ALTERNATE SHIFT, RESET NOT FOUND

K31:    CMP     AL,57           ; NO-RESET
        JNE     K32             ; TEST FOR SPACE KEY
        MOV     AL,' '          ; NOT THERE
        JMP     K57             ; SET SPACE CHAR
                                ; BUFFER_FILL
;------- ALT-INPUT-TABLE
K30     LABEL   BYTE
        DB      82,79,80,81,75,76,77

        DB      71,72,73        ; 10 NUMBERS ON KEYPAD
;------- SUPER-SHIFT-TABLE
        DB      16,17,18,19,20,21,22,23 ; A-Z TYPEWRITER CHARS

        DB      24,25,30,31,32,33,34,35

        DB      36,37,38,44,45,46,47,48

        DB      49,50
;------- LOOK FOR KEY PAD ENTRY
K32:                            ; ALT-KEY-PAD
        MOV     DI,OFFSET K30   ; ALT-INPUT-TABLE
        MOV     CX,10           ; LOOK FOR ENTRY USING KEYPAD
        REPNE   SCASB           ; LOOK FOR MATCH
        JNE     K33             ; NO_ALT_KEYPAD
        SUB     DI,OFFSET K30+1 ; DI NOW HAS ENTRY VALUE
        MOV     AL,ALT_INPUT    ; GET THE CURRENT BYTE
        MOV     AH,10           ; MULTIPLY BY 10
        MUL     AH              ;
        ADD     AX,DI           ; ADD IN THE LATEST ENTRY
        MOV     ALT_INPUT,AL    ; STORE IT AWAY
        JMP     K26             ; THROW AWAY THAT KEYSTROKE


K33:    MOV     ALT_INPUT,0     ; NO-ALT-KEYPAD
                                ; ZERO ANY PREVIOUS ENTRY INTO
        MOV     CX,26           ; INPUT
        REPNE   SCASB           ; DI,ES ALREADY POINTING
        JNE     K34             ; LOOK FOR MATCH IN ALPHABET
        XOR     AL,AL           ; NOT FOUND, FUNCTION KEY OR OTHER
        JMP     K57             ; ASCII CODE OF ZERO
                                ; PUT IT IN THE BUFFER
;------- LOOK FOR TOP ROW OF ALTERNATE SHIFT
K34:    CMP     AL,2            ; ALT-TOP-ROW
        JB      K35             ; KEY WITH '1' ON IT
        CMP     AL,14           ; NOT ONE OF INTERESTING KEYS
        JAE     K35             ; IS IT IN THE REGION?
        ADD     AH,118          ; ALT-FUNCTION
                                ; CONVERT PSEUDO SCAN CODE TO
        XOR     AL,AL           ; INDICATE AS SUCH
        JMP     K57             ; BUFFER_FILL

;------- TRANSLATE ALTERNATE SHIFT PSEUDO SCAN CODES
K35:    CMP     AL,59           ; ALT-FUNCTION
        JAE     K37             ; TEST FOR IN TABLE
K36:    JMP     K26             ; CLOSE-RETURN
                                ; IGNORE THE KEY
K37:                            ; ALT-CONTINUE
        CMP     AL,71           ; IN KEYPAD REGION
        JAE     K36             ; IF SO, IGNORE
        MOV     BX,OFFSET K13   ; ALT SHIFT PSEUDO SCAN TABLE
        JMP     K63             ; TRANSLATE THAT

;------- NOT IN ALTERNATE SHIFT
K38:    TEST    KB_FLAG,CTL_SHIFT ; NOT-ALT-SHIFT
        JZ      K44             ; ARE WE IN CONTROL SHIFT?
                                ; NOT-CTL-SHIFT
                                ; CONTROL SHIFT, TEST SPECIAL CHARACTERS
;------- TEST FOR BREAK AND PAUSE KEYS
        CMP     AL,SCROLL_KEY   ; TEST FOR BREAK
        JNE     K41             ; NO-BREAK
        MOV     BX,BUFFER_HEAD  ; GET CURRENT BUFFER HEAD
        MOV     BIOS_BREAK,80H  ; TURN ON BIOS_BREAK BIT
        INT     1BH             ; BREAK INTERRUPT VECTOR
        SUB     AX,AX           ; PUT OUT DUMMY CHARACTER
        MOV     [BX],AX         ; PUT DUMMY CHAR AT BUFFER HEAD
        CALL    K4              ; UPDATE BUFFER POINTER
        MOV     BUFFER_TAIL,BX  ; UPDATE TAIL
        JMP     K26             ; DONE WITH INTERRUPT
K41:                            ; NO-PAUSE
;------- TEST SPECIAL CASE KEY 55                                          
        CMP     AL,55           ; NOT-KEY-55
        JNE     K42             ; START/STOP PRINTING SWITCH
        MOV     AX,7200H
        JMP     K57             ; BUFFER_FILL
;-------  SET UP TO TRANSLATE CONTROL SHIFT
K42:    MOV     BX,OFFSET K8    ; SET UP TO TRANSLATE CTL
        CMP     AL,59           ; IS IT IN TABLE?
        JB      K56             ; YES, GO TRANSLATE CHAR
                                ; CTL-TABLE-TRANSLATE
        MOV     BX,OFFSET K9    ; CTL TABLE SCAN
        JMP     K63             ; TRANSLATE_SCAN
;-------  NOT IN CONTROL SHIFT
K44:    CMP     AL,71           ; TEST FOR KEYPAD REGION
        JAE     K48             ; HANDLE KEYPAD REGION
        TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT
        JZ      K54             ; TEST FOR SHIFT STATE
;-------  UPPER CASE, HANDLE SPECIAL CASES
        CMP     AL,15           ; BACK TAB KEY
        JNE     K46             ; NOT-BACK-TAB
        MOV     AX,15*256       ; SET PSEUDO SCAN CODE
        JMP     SHORT K57       ; BUFFER_FILL
                                ; NOT-PRINT-SCREEN
K46:    CMP     AL,59           ; TEST FOR FUNCTION KEYS
        JB      K47             ; NOT-UPPER-FUNCTION
        MOV     BX,OFFSET K12   ; UPPER CASE PSEUDO SCAN CODES
        JMP     K63             ; TRANSLATE_SCAN
                                ; NOT-UPPER-FUNCTION
K47:    MOV     BX,OFFSET K11   ; POINT TO UPPER CASE TABLE
        JMP     SHORT K56       ; OK, TRANSLATE THE CHAR
;-------  KEYPAD KEYS, MUST TEST NUM LOCK FOR DETERMINATION
K48:    TEST    KB_FLAG,NUM_STATE ; ARE WE IN NUM_LOCK?
        JNZ     K52             ; TEST FOR SURE
        TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; ARE WE IN SHIFT
                                ; STATE
        JNZ     K53             ; IF SHIFTED, REALLY NUM STATE
;-------  BASE CASE FOR KEYPAD
K49:    CMP     AL,74           ; BASE-CASE
        JE      K50             ; SPECIAL CASE FOR A COUPLE OF KEYS
        CMP     AL,78           ; MINUS
        JE      K51
        SUB     AL,71           ; CONVERT ORIGIN
        MOV     BX,OFFSET K15   ; BASE CASE TABLE
        JMP     K64             ; CONVERT TO PSEUDO SCAN
K50:    MOV     AX,74*256+'-'   ; MINUS
        JMP     SHORT K57       ; BUFFER_FILL
K51:    MOV     AX,78*256+'+'   ; PLUS
        JMP     SHORT K57       ; BUFFER_FILL
;-------  MIGHT BE NUM LOCK, TEST SHIFT STATUS
K52:    TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; ALMOST-NUM-STATE
        JNZ     K49             ; SHIFTED TEMP OUT OF NUM STATE
                                ; REALLY_NUM_STATE
K53:    SUB     AL,70           ; CONVERT ORIGIN
        MOV     BX,OFFSET K14   ; NUM STATE TABLE
        JMP     SHORT K56       ; TRANSLATE_CHAR
;-------  PLAIN OLD LOWER CASE
K54:    CMP     AL,59           ; NOT-SHIFT
        JB      K55             ; TEST FOR FUNCTION KEYS
        XOR     AL,AL           ; NOT-LOWER-FUNCTION
        JMP     SHORT K57       ; SCAN CODE IN AH ALREADY
                                ; BUFFER_FILL
K55:    MOV     BX,OFFSET K10   ; NOT-LOWER-FUNCTION
;-------  TRANSLATE THE CHARACTER
K56:    DEC     AL              ; TRANSLATE-CHAR
        XLAT    CS:K11          ; CONVERT ORIGIN
                                ; CONVERT THE SCAN CODE TO ASCII
;-------  PUT CHARACTER INTO BUFFER
K57:    CMP     AL,-1           ; BUFFER-FILL
        JE      K59             ; IS THIS AN IGNORE CHAR?
        CMP     AH,-1           ; YES, DO NOTHING WITH IT
        JE      K59             ; LOOK FOR -1 PSEUDO SCAN
                                ; NEAR_INTERRUPT_RETURN
;-------  HANDLE THE CAPS LOCK PROBLEM
K58:    TEST    KB_FLAG,CAPS_STATE ; BUFFER-FILL-NOTEST
        JZ      K61             ; ARE WE IN CAPS LOCK STATE?
                                ; SKIP IF NOT
        TEST    KB_FLAG,LEFT_SHIFT+RIGHT_SHIFT ; IN CAPS LOCK STATE
                                ; TEST FOR SHIFT
        JZ      K60             ; IF NOT SHIFT, CONVERT LOWER TO
                                ; UPPER
;-------  CONVERT ANY UPPER CASE TO LOWER CASE
        CMP     AL,'A'          ; FIND OUT IF ALPHABETIC
        JB      K61             ; NOT_CAPS_STATE
        CMP     AL,'Z'
        JA      K61             ; NOT_CAPS_STATE
        ADD     AL,'a'-'A'      ; CONVERT TO LOWER CASE
        JMP     SHORT K61       ; NOT_CAPS_STATE
                                ; NEAR-INTERRUPT-RETURN
K59:    JMP     K26             ; INTERRUPT_RETURN
;-------  CONVERT ANY LOWER CASE TO UPPER CASE
K60:    CMP     AL,'a'          ; LOWER-TO-UPPER
        JB      K61             ; FIND OUT IF ALPHABETIC
        CMP     AL,'z'
        JA      K61             ; NOT_CAPS_STATE
        SUB     AL,'a'-'A'      ; CONVERT TO UPPER CASE
K61:                            ; NOT-CAPS-STATE
        MOV     BX,BUFFER_TAIL  ; GET THE END POINTER TO THE BUFFER
        MOV     SI,BX           ; SAVE THE VALUE
        CALL    K4              ; ADVANCE THE TAIL
        CMP     BX,BUFFER_HEAD  ; HAS THE BUFFER WRAPPED AROUND?
        JNE     K61_1           ; BUFFER_FULL_BEEP
        PUSH    BX              ; SAVE BUFFER_TAIL
        MOV     BX,080H         ; DURATION OF ERROR BEEP
        MOV     CX,48H          ; FREQUENCY OF ERROR BEEP HALF TONE
        CALL    KB_NOISE        ; OUTPUT NOISE
        AND     KB_FLAG,0F0H    ; CLEAR ALT,CTRL,LEFT AND RIGHT
                                ; SHIFTS
        AND     KB_FLAG_1,0FH   ; CLEAR POTENTIAL BREAK OF INS,CAPS
                                ; ,NUM AND SCROLL SHIFT
        AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
        POP     BX              ; RETRIEVE BUFFER TAIL
        JMP     K26             ; RETURN FROM INTERRUPT
K61_1:  TEST    KB_FLAG_1,CLICK_ON ; IS AUDIO FEEDBACK ENABLED?
        JZ      K61_2           ; NO, JUST PUT IN BUFFER
        PUSH    BX              ; SAVE BUFFER_TAIL VALUE
        MOV     BX,1H           ; DURATION OF CLICK
        MOV     CX,10H          ; FREQUENCY OF CLICK
        CALL    KB_NOISE        ; OUTPUT AUDIO FEEDBACK OF KEY
                                ; STROKE
        POP     BX              ; RETRIEVE BUFFER_TAIL VALUE
K61_2:  MOV     [SI],AX         ; STORE THE VALUE
        MOV     BUFFER_TAIL,BX  ; MOVE THE POINTER UP
        JMP     K26             ; INTERRUPT_RETURN
;------ TRANSLATE SCAN FOR PSEUDO SCAN CODES
K63:                            ; TRANSLATE-SCAN
        SUB     AL,59           ; CONVERT ORIGIN TO FUNCTION KEYS                                                                
K64:                            ; TRANSLATE-SCAN-ORG0
        XLAT    CS:K9           ; CTL TABLE SCAN
        MOV     AH,AL           ; PUT VALUE INTO AH
        XOR     AL,AL           ; ZERO ASCII CODE
        JMP     K57             ; PUT IT INTO THE BUFFER
KB_INT  ENDP
;---------------------------------------------------------------
;GET_POS
;       THIS ROUTINE WILL SHIFT THE VALUE STORED IN THE HIGH NIBBLE
;       OF THE VARIABLE VAR_DELAY TO THE LOW NIBBLE.
;INPUT
;       NONE.   IT IS ASSUMED THAT DS POINTS AT THE BIOS DATA AREA
;OUTPUT
;       AL CONTAINS THE SHIFTED VALUE.
;---------------------------------------------------------------
GET_POS PROC    NEAR
        PUSH    CX              ; SAVE SHIFT REGISTER
        MOV     AL,BYTE PTR VAR_DELAY ; GET STORAGE LOCATION
        AND     AL,0F0H         ; MASK OFF LOW NIBBLE
        MOV     CL,4            ; SHIFT OF FOUR BIT POSITIONS
        SAR     AL,CL           ; SHIFT THE VALUE SIGN EXTENDED
        POP     CX              ; RESTORE THE VALUE
        RET
GET_POS ENDP
;---------------------------------------------------------------
;PUT_POS
;       THIS ROUTINE WILL TAKE THE VALUE IN LOW ORDER NIBBLE IN
;       AL AND STORE IT IN THE HIGH ORDER OF VAR_DELAY
;INPUT
;       AL CONTAINS THE VALUE FOR STORAGE
;OUTPUT
;       NONE.
;---------------------------------------------------------------
PUT_POS PROC    NEAR
        PUSH    CX              ; SAVE REGISTER
        MOV     CL,4            ; SHIFT COUNT
        SHL     AL,CL           ; PUT IN HIGH ORDER NIBBLE
        MOV     CL,BYTE PTR VAR_DELAY ; GET DATA BYTE
        AND     CL,0FH          ; CLEAR OLD VALUE IN HIGH NIBBLE
        OR      AL,CL           ; COMBINE HIGH AND LOW NIBBLES
        MOV     BYTE PTR VAR_DELAY,AL ; PUT IN POSITION
        POP     CX              ; RESTORE REGISTER
        RET
PUT_POS ENDP
;---------------------------------------------------------------
; MANUFACTURING ACTIVITY SIGNAL ROUTINE - INVOKED THROUGH THE TIMER
; TICK ROUTINE DURING MANUFACTURING ACTIVITIES . (ACCESSED THROUGH
; INT 1CH)
;---------------------------------------------------------------
MFG_TICK        PROC    FAR
        PUSH    AX
        SUB     AX,AX           ; SEND A 00 TO PORT 13 AS A
                                ; ACTIVITY SIGNAL
        OUT     13H,AL
        IN      AL,PORT_B       ; FLIP SPEAKER DATA TO OPPOSITE
                                ; SENSE
        MOV     AH,AL           ; SAVE ORIG SETTING
        AND     AH,10011101B    ; MAKE SURE MUX IS -> RIGHT AND
                                ; ISOLATE SPEAKER BIT
        NOT     AL              ; FLIP ALL BITS
        AND     AL,00000010B    ; ISOLATE SPEAKER DATA BIT (NOW IN
                                ; OPPOSITE SENSE)
        OR      AL,AH           ; COMBINE WITH ORIG. DATA FROM
                                ; PORT B
        OR      AL,00010000B    ; AND DISABLE INTERNAL SPEAKER
        OUT     PORT_B,AL
        MOV     AL,20H          ; EOI TO INTR. CHIP
        OUT     20H,AL
        POP     AX
        IRET
MFG_TICK        ENDP
;--------------------------------------------------------------
;            CONVERT AND PRINT ASCII CODE
;
;     AL MUST CONTAIN NUMBER TO BE CONVERTED.
;                  AX AND BX DESTROYED.
;--------------------------------------------------------------

XPC_BYTE        PROC    NEAR
        PUSH    AX              ; SAVE FOR LOW NIBBLE DISPLAY
        MOV     CL,4            ; SHIFT COUNT
        SHR     AL,CL           ; NIBBLE SWAP
        CALL    XLAT_PR         ; DO THE HIGH NIBBLE DISPLAY
        POP     AX              ; RECOVER THE NIBBLE
        AND     AL,0FH          ; ISOLATE TO LOW NIBBLE
; FALL INTO LOW NIBBLE CONVERSION
XLAT_PR PROC    NEAR           ; CONVERT 00-0F TO ASCII CHARACTER
        ADD     AL,090H         ; ADD FIRST CONVERSION FACTOR
        DAA                     ; ADJUST FOR NUMERIC AND ALPHA
                                ; RANGE
        ADC     AL,040H         ; ADD CONVERSION AND ADJUST LOW
                                ; NIBBLE
        DAA                     ; ADJUST HIGH NIBBLE TO ASCII RANGE
PRT_HEX PROC    NEAR
        PUSH    BX
        MOV     AH,14           ; DISPLAY CHARACTER IN AL
        MOV     BH,0
        INT     10H             ; CALL VIDEO_IO
        POP     BX
        RET
PRT_HEX ENDP
XLAT_PR ENDP
XPC_BYTE        ENDP
;CONTROL IS PASSED HERE WHEN THERE ARE NO PARALLEL PRINTERS
;ATTACHED. CX HAS EQUIPMENT FLAG,DS POINTS AT DATA (40H)
;DETERMINE WHICH RS232 CARD (0,1) TO USE
REPRINT PROC    NEAR
B1_A:   SUB     DX,DX           ;ASSUME TO USE CARD 0
        TEST    CH,00000100B    ;UNLESS THERE ARE TWO CARDS
        JE      B10_1           ;IN WHICH CASE,
        INC     DX              ;USE CARD 1
;DETERMINE WHICH FUNCTION IS BEING CALLED
B10_1:  OR      AH,AH           ;TEST FOR AH = 0
        JZ      B12             ;GO PRINT CHAR
        DEC     AH              ;TEST FOR AH = 1
        JZ      B11             ;GO DO INIT
        DEC     AH              ;TEST FOR AH = 2
        JNZ     SHORT B10_3     ;IF NOT VALID, RETURN
;ELSE...
;GET STATUS FROM RS232 PORT
        PUSH    AX              ;SAVE AL
        MOV     AH,03H          ;USE THE GET COMMO PORT
        INT     014H            ;STATUS FUNCTION OF INT14
        CALL    FAKE            ;FAKE WILL MAP ERROR BITS FROM
                                ;RS232 TO CORRESPONDING ONES
                                ;FOR THE PRINTER
        POP     AX              ;RESTORE AL
        OR      DH,DH           ;CHECK IF ANY FLAGS WERE SET
        JZ      B10_2
        MOV     AH,DH           ;MOVE FAKED ERROR CONDITION TO AH
        AND     AH,0FEH
        JMP     SHORT B10_3     ;THEN RETURN
B10_2:  MOV     AH,090H         ;MOVE IN STATUS FOR 'CORRECT'
                                ; RETURN
B10_3:  JMP     B1
;INIT COMMO PORT     --- DX HAS WHICH CARD TO INIT.
;MOVE TIME OUT VALUE FROM PRINTER TO RS232 TIME OUT VALUE
B11:    MOV     SI,DX           ;SI GETS OFFSET INTO THE TABLE
        MOV     AL,PRINT_TIM_OUT
        ADD     AL,0AH          ; INCREASE DELAY
        MOV     RS232_TIM_OUT[SI],AL
        PUSH    AX              ;SAVE AL
        MOV     AL,087H         ;SET INIT FOR: 1200 BAUD
                                ;              8 BIT WRD LNG
                                ;              NO PARITY
                                ;              2 STOP BITS
        SUB     AH,AH           ;AH=0 IS COMMO INIT FUNCTION
        INT     014H            ;DO INIT
        CALL    FAKE            ;FAKE WILL MAP ERROR BITS FROM
                                ;RS232 TO CORRESPONDING ONES
                                ;FOR THE PRINTER
        POP     AX              ;RESTORE AL
        MOV     AH,DH           ;IF DH IS RETURNED ZERO, MEANING
        OR      AH,AH           ;NO ERRORS RETURN IT FOR THAT'S THE
                                ;'CORRECT' RETURN FROM AN ERROR
                                ; FREE INIT
        JE      B10_3
        MOV     AH,0A8H
        JMP     SHORT B10_3     ;THEN RETURN
;PRINT CHAR TO SERIAL PORT
;DX = RS232 CARD TO BE USED: AL HAS CHAR TO BE PRINTED
B12:    PUSH    AX              ;SAVE AL
        MOV     AH,01           ;1 IS SEND A CHAR DOWN COMMO LINE
        INT     014H            ;SEND THE CHAR
        CALL    FAKE            ;FAKE WILL MAP ERROR BITS FROM
                                 ;RS232 TO CORRESPONDING ONES
                                 ;FOR THE PRINTER

        POP     AX              ;RESTORE AL
        OR      DH,DH           ;SEE IF NO ERRORS WERE RETURNED
        JZ      B12_1
        MOV     AH,DH           ;IF THERE WERE ERRORS, RETURN THEM
        JMP     SHORT B10_3     ;AND RETURN
B12_1:  MOV     AH,010H         ;PUT 'CORRECT' RETURN STATUS IN AH
        JMP     SHORT B10_3     ;AND RETURN
        REPRINT ENDP
;THIS PROC MAPS THE ERRORS RETURNED FROM A BIOS INT14 CALL
;TO THOSE 'LIKE THAT' OF AN INT17 CALL
;BREAK,FRAMING,PARITY,OVERRUN ERRORS ARE LOGGED AS I/O
;ERRORS AND A TIME OUT IS MOVED TO THE APPROPRIATE BIT
FAKE    PROC    NEAR
        XOR     DH,DH           ;CLEAR FAKED STATUS FLAGS
        TEST    AH,011110B      ;CHECK FOR BREAK,FRAMING,PARITY
                                 ;OVERRUN
        JZ      B13_1           ;ERRORS. IF NOT THEN CHECK FOR
                                 ;TIME OUT.
        MOV     DH,01000B       ;SET BIT 3 TO INDICATE 'I/O ERROR'
        RET                     ;AND RETURN
B13_1:  TEST    AH,080H         ;TEST FOR TIME OUT ERROR RETURNED
        JZ      B13_2           ;IF NOT TIME OUT, RETURN
        MOV     DH,09H          ;IF TIME OUT
B13_2:  RET
FAKE    ENDP
;---------------------------------------------------------------
;NEW_INT9
;       THIS ROUTINE IS THE INTERRUPT 9 HANDLER WHEN THE MACHINE IS
;       FIRST POWERED ON AND CASSETTE BASIC IS GIVEN CONTROL.  IT
;       HANDLES THE FIRST KEYSTROKES ENTERED FROM THE KEYBOARD AND
;       PERFORMS "SPECIAL" ACTIONS AS FOLLOWS:
;               IF ESC IS THE FIRST KEY ENTERED MINI-WELCOME IS
;                       EXECUTED
;               IF CTRL-ESC IS THE FIRST SEQUENCE "LOAD CAS1:,R" IS
;                       EXECUTED GIVING THE USER THE ABILITY TO BOOT
;                       FROM CASSETTE
;       AFTER THESE KEYSTROKES OR AFTER ANY OTHER KEYSTROKES THE
;       INTERRUPT 9 VECTOR IS CHANGED TO POINT AT THE REAL
;       INTERRUPT 9 ROUTINE.
;---------------------------------------------------------------
NEW_INT_9       PROC    FAR
        CMP     AL,1            ;IS THIS AN ESCAPE KEY?
        JE      ESC_KEY         ;JUMP IF AL=ESCAPE KEY
        CMP     AL,29           ;ELSE, IS THIS A CONTROL KEY?
        JE      CTRL_KEY        ;JUMP IF AL=CONTROL KEY
        CALL    REAL_VECTOR_SETUP ;OTHERWISE, INITIALIZE REAL
                                 ;INT 9 VECTOR
        INT     9H              ;PASS THE SCAN CODE IN AL
        IRET                    ;RETURN TO INTERRUPT 48H
CTRL_KEY:
        OR      KB_FLAG,04H     ;TURN ON CTRL SHIFT IN KB_FLAG
        IRET                    ;RETURN TO INTERRUPT
ESC_KEY:
        TEST    KB_FLAG,04H     ;HAS CONTROL SHIFT OCCURED?
        JE      ESC_ONLY        ;NO.  ESCAPE ONLY
;CONTROL ESCAPE HAS OCCURED, PUT MESSAGE IN BUFFER FOR CASSETTE
;LOAD
        MOV     KB_FLAG,0       ;ZERO OUT CONTROL STATE
        PUSH    DS
        POP     ES              ;INITIALIZE ES FOR BIOS DATA
        PUSH    DS              ;SAVE OLD DS
        PUSH    CS              ;POINT DS AT CODE SEGMENT
        POP     DS
        MOV     SI,OFFSET CAS_LOAD ;GET MESSAGE
        MOV     DI,OFFSET KB_BUFFER ;POINT AT KEYBOARD BUFFER
        MOV     CX,CAS_LENGTH   ;LENGTH OF CASSETTE MESSAGE
T_LOOP: LODSB                   ;GET ASCII CHARACTER FROM MESSAGE
        STOSW                   ;PUT IN KEYBOARD BUFFER
        LOOP    T_LOOP
        POP     DS              ;RETRIEVE BIOS DATA SEGMENT
;------- INITIALIZE QUEUE SO MESSAGE WILL BE REMOVED FROM BUFFER
        MOV     BUFFER_HEAD,OFFSET KB_BUFFER
        MOV     BUFFER_TAIL,OFFSET KB_BUFFER+(CAS_LENGTH*2)
;---------------------------------------------------------------
;***NOTE***
;       IT IS ASSUMED THAT THE LENGTH OF THE CASSETTE MESSAGE IS
;       LESS THAN OR EQUAL TO THE LENGTH OF THE BUFFER.  IF THIS IS
;       NOT THE CASE THE BUFFER WILL EVENTUALLY CONSUME MEMORY.
;---------------------------------------------------------------
        CALL    REAL_VECTOR_SETUP
        IRET
ESC_ONLY:
        CALL    REAL_VECTOR_SETUP
        MOV     CX,MINI
        JMP     CX              ;ENTER THE WORLD OF KEYBOARD CAPER
;MESSAGE FOR OUTPUT WHEN CONTROL-ESCAPE IS ENTERED AS FIRST
;KEY SEQUENCE
CAS_LOAD        LABEL   BYTE
        DB      'LOAD "CAS1:",R'


        DB      13
CAS_LENGTH     EQU     $ - CAS_LOAD
NEW_INT_9       ENDP
;----------------------------------------
; WRITE_TTY
; THIS INTERFACE PROVIDES A TELETYPE LIKE INTERFACE TO THE
; VIDEO CARD.  THE INPUT CHARACTER IS WRITTEN TO THE CURRENT
; CURSOR POSITION, AND THE CURSOR IS MOVED TO THE NEXT POSITION.
; IF THE CURSOR LEAVES THE LAST COLUMN OF THE FIELD, THE COLUMN
; IS SET TO ZERO, AND THE ROW VALUE IS INCREMENTED.  IF THE ROW
; VALUE LEAVES THE FIELD, THE CURSOR IS PLACED ON THE LAST
; ROW, FIRST COLUMN, AND THE ENTIRE SCREEN IS SCROLLED UP ONE
; LINE. WHEN THE SCREEN IS SCROLLED UP, THE ATTRIBUTE FOR FILLING
; THE NEWLY BLANKED LINE IS READ FROM THE CURSOR POSITION ON THE
; PREVIOUS LINE BEFORE THE SCROLL, IN CHARACTER MODE.  IN
; GRAPHICS MODE, THE 0 COLOR IS USED.
;
; ENTRY --
;    (AH) = CURRENT CRT MODE
;    (AL) = CHARACTER TO BE WRITTEN
;           NOTE THAT BACK SPACE, CAR RET, BELL AND LINE FEED ARE
;           HANDLED AS COMMANDS RATHER THAN AS DISPLAYABLE GRAPHICS
;    (BL) = FOREGROUND COLOR FOR CHAR WRITE IF CURRENTLY IN A
;           GRAPHICS MODE
;
; EXIT --
;    ALL REGISTERS SAVED
;----------------------------------------

ASSUME  CS:CODE,DS:DATA
WRITE_TTY       PROC    NEAR
        PUSH    AX              ; SAVE REGISTERS
        PUSH    AX              ; SAVE CHAR TO WRITE
        MOV     BH,ACTIVE_PAGE  ; GET CURRENT PAGE SETTING
        PUSH    BX              ; SAVE IT
        MOV     BL,BH           ; IN BL
        XOR     BH,BH
        SAL     BX,1            ; CONVERT TO WORD OFFSET
        MOV     DX,[BX+OFFSET CURSOR_POSN] ; GET CURSOR POSITION
        POP     BX              ; RECOVER CURRENT PAGE
        POP     AX              ; RECOVER CHAR
;------ DX NOW HAS THE CURRENT CURSOR POSITION
        CMP     AL,8            ; IS IT A BACKSPACE?
        JE      U8              ; BACK_SPACE
        CMP     AL,0DH          ; IS IT A CARRIAGE RETURN?
        JE      U9              ; CAR_RET
        CMP     AL,0AH          ; IS IT A LINE FEED
        JE      U10             ; LINE_FEED
        CMP     AL,07H          ; IS IT A BELL
        JE      U11             ; BELL
;------ WRITE THE CHAR TO THE SCREEN
        MOV     AH,10           ; WRITE CHAR ONLY
        MOV     CX,1            ; ONLY ONE CHAR
        INT     10H             ; WRITE THE CHAR
;------ POSITION THE CURSOR FOR NEXT CHAR
        INC     DL
        CMP     DL,BYTE PTR CRT_COLS ; TEST FOR COLUMN OVERFLOW
        JNZ     U7              ; SET_CURSOR
        XOR     DL,DL           ; COLUMN FOR CURSOR

;------ LINE FEED
U10:
        CMP     DH,24
        JNZ     U6              ; SET_CURSOR_INC

;------ SCROLL REQUIRED
        MOV     AH,2            ; SET THE CURSOR
        INT     10H

;------ DETERMINE VALUE TO FILL WITH DURING SCROLL
        MOV     AL,CRT_MODE     ; GET THE CURRENT MODE
        CMP     AL,4
        JC      U2              ; READ-CURSOR
        XOR     BH,BH           ; FILL WITH BACKGROUND
        JMP     SHORT U3        ; SCROLL-UP
U2:
        MOV     AH,8
        INT     10H             ; READ CHAR/ATTR AT CURRENT CURSOR
        MOV     BH,AH           ; STORE IN BH
U3:
        MOV     AX,601H         ; SCROLL ONE LINE
        SUB     CX,CX           ; UPPER LEFT CORNER
        MOV     DH,24           ; LOWER RIGHT ROW
        MOV     DL,BYTE PTR CRT_COLS ; LOWER RIGHT COLUMN
        DEC     DL
U4:
        INT     10H             ; SCROLL UP THE SCREEN
U5:
        POP     AX              ; RESTORE THE CHARACTER
        JMP     VIDEO_RETURN    ; RETURN TO CALLER
U6:
        INC     DH              ; NEXT ROW
U7:
        MOV     AH,2            ; ESTABLISH THE NEW CURSOR
        JMP     U4

;------ BACK SPACE FOUND
U8:     OR      DL,DL           ; ALREADY AT END OF LINE
        JE      U7              ; SET_CURSOR
        DEC     DL              ; NO -- JUST MOVE IT BACK
        JMP     U7              ; SET_CURSOR

;------ CARRIAGE RETURN FOUND
U9:     XOR     DL,DL           ; MOVE TO FIRST COLUMN
        JMP     U7              ; SET_CURSOR

;------ BELL FOUND
U11:    MOV     BL,2            ; SET UP COUNT FOR BEEP
        CALL    BEEP            ; SOUND THE POD BELL
        JMP     U5              ; TTY_RETURN
WRITE_TTY       ENDP
;-----------------------------------------------------------
; THIS PROCEDURE WILL ISSUE SHORT TONES TO INDICATE FAILURES
; THAT 1: OCCUR BEFORE THE CRT IS STARTED, 2: TO CALL THE
; OPERATORS ATTENTION TO AN ERROR AT THE END OF POST, OR
; 3: TO SIGNAL THE SUCCESSFUL COMPLETION OF POST
; ENTRY PARAMETERS:
;   DL = NUMBER OF APPROX. 1/2 SEC TONES TO SOUND
;-----------------------------------------------------------
ERR_BEEP        PROC    NEAR
        PUSHF                   ; SAVE FLAGS
        PUSH    BX
        CLI                     ; DISABLE SYSTEM INTERRUPTS
 ; SHORT_BEEP:
G3:     MOV     BL,1            ; COUNTER FOR A SHORT BEEP
        CALL    BEEP            ; DO THE SOUND
G4:     LOOP    G4              ; DELAY BETWEEN BEEPS
        DEC     DL              ; DONE WITH SHORTS
        JNZ     G3              ; DO SOME MORE
G5:     LOOP    G5              ; LONG DELAY BEFORE RETURN
G6:     LOOP    G6
        POP     BX              ; RESTORE ORIG CONTENTS OF BX
        POPF                    ; RESTORE FLAGS TO ORIG SETTINGS
        RET                     ; RETURN TO CALLER
ERR_BEEP        ENDP
;-----------------------------------------------------------
; SET_CURSOR
;
; SET THE HARDWARE CURSOR POSITION USING VIDEO_IO.
;
; ENTRY
;       BH = DISPLAY PAGE
;       DH,DL = ROW,COLUMN
; EXIT
;       SI,DI PRESERVED
;-----------------------------------------------------------
SET_CURSOR      PROC    NEAR
        MOV     AH,2
        PUSH    DI
        PUSH    SI
        INT     10H
        POP     SI
        POP     DI
        RET
SET_CURSOR      ENDP
;-----------------------------------------------------------
; PRNT3
;
; DISPLAY A FORMATTED MESSAGE STRING THROUGH VIDEO_IO.
; THE STRING IS ADDRESSED THROUGH THE FAR RETURN FRAME AND
; MAY CONTAIN CONTROL BYTES FOR CURSOR MOVEMENT, ATTRIBUTE
; CHANGES, AND STRING RESTARTS.
;
; ENTRY
;       STACK FRAME CONTAINS FAR STRING POINTER
;       DX = INITIAL ROW,COLUMN AND CONTROL FLAGS
;       BL = DEFAULT ATTRIBUTE WHEN DH BIT 7 IS CLEAR
; EXIT
;       IRET TO CALLER
;-----------------------------------------------------------
        ORG     1A2AH
PRNT3           PROC    FAR
        PUSH    AX
        PUSH    ES
        PUSH    BP
        MOV     BP,SP
        MOV     AX,[BP+8]
        MOV     ES,AX
        ASSUME  ES:NOTHING
        POP     BP
        PUSH    BX
        PUSH    CX
        PUSH    BP
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    DX
        CALL    DDS
        MOV     BH,ACTIVE_PAGE
        XOR     CX,CX
LOC_F1A45:
        MOV     DI,1
        MOV     AL,ES:[BP+0]
        XOR     AH,AH
        MOV     SI,AX
        TEST    DH,80H
        JNZ     SHORT LOC_F1A57
        MOV     BL,7
LOC_F1A57:
        TEST    DH,40H
        JZ      SHORT LOC_F1A9C
        INC     SI
        AND     DX,1F7FH
LOC_F1A61:
        INC     CL
        DEC     DI
        NOT     SI
        ADD     SI,2
LOC_F1A69:
        INC     DI
        INC     SI
        JZ      SHORT LOC_F1ADD
        MOV     AL,ES:[BP+DI]
        CMP     AL,0DH
        JNZ     SHORT LOC_F1A7B
        ADD     DH,1
        MOV     DL,0
        JMP     SHORT LOC_F1A69
LOC_F1A7B:
        CMP     AL,0AH
        JNZ     SHORT LOC_F1A83
        INC     DH
        JMP     SHORT LOC_F1A69
LOC_F1A83:
        CMP     AL,0BH
        JNZ     SHORT LOC_F1A92
        INC     DH
        INC     SI
        INC     DI
        MOV     AL,ES:[BP+DI]
        ADD     DL,AL
        JMP     SHORT LOC_F1A69
LOC_F1A92:
        CMP     AL,0CH
        JNZ     SHORT LOC_F1ADF
        INC     DI
        INC     DI
        ADD     BP,DI
        JMP     SHORT LOC_F1A45
LOC_F1A9C:
        AND     DX,1F7FH
LOC_F1AA0:
        MOV     CL,ES:[BP+SI]
        INC     SI
        CMP     CL,0
        JZ      SHORT LOC_F1AEF
        JL      SHORT LOC_F1AB2
        CMP     CL,51H
        JL      SHORT LOC_F1ADF
        JMP     SHORT LOC_F1ACD
LOC_F1AB2:
        INC     CL
        JZ      SHORT LOC_F1A61
        INC     CL
        JZ      SHORT LOC_F1B08
        INC     CL
        JZ      SHORT LOC_F1B1E
        INC     CL
        JZ      SHORT LOC_F1ADD
        INC     CL
        JZ      SHORT LOC_F1B04
        INC     CL
        JZ      SHORT LOC_F1B2A
        SUB     CX,6
LOC_F1ACD:
        SUB     CL,51H
        CMP     CL,50H
        JL      SHORT LOC_F1B0D
        SUB     CL,50H
        CMP     CL,51H
        JL      SHORT LOC_F1B16
LOC_F1ADD:
        JMP     SHORT LOC_F1B2F
LOC_F1ADF:
        CALL    SET_CURSOR
        PUSH    DI
        PUSH    SI
        MOV     AH,9
        MOV     AL,ES:[BP+DI]
        ADD     DL,CL
        INT     10H
        POP     SI
        POP     DI
LOC_F1AEF:
        CMP     SI,0
        JGE     SHORT LOC_F1AF7
        JMP     LOC_F1A69
LOC_F1AF7:
        MOV     AL,ES:[BP+0]
        XOR     AH,AH
        INC     DI
        CMP     AX,DI
        JG      SHORT LOC_F1AA0
        JMP     SHORT LOC_F1B08
LOC_F1B04:
        MOV     DL,0
        INC     DH
LOC_F1B08:
        MOV     DI,1
        JMP     SHORT LOC_F1AA0
LOC_F1B0D:
        SUB     CL,28H
        ADD     DL,CL
        INC     DH
        JMP     SHORT LOC_F1AA0
LOC_F1B16:
        MOV     BL,ES:[BP+DI]
        INC     DI
        JZ      SHORT LOC_F1AEF
        JMP     SHORT LOC_F1ADF
LOC_F1B1E:
        MOV     AH,ES:[BP+SI]
        INC     SI
        SUB     AH,28H
        ADD     DH,AH
        JMP     LOC_F1AA0
LOC_F1B2A:
        ADD     BP,SI
        JMP     LOC_F1A45
LOC_F1B2F:
        CALL    SET_CURSOR
        POP     BX
        PUSH    BX
        TEST    BH,20H
        JZ      SHORT LOC_F1B4A
        TEST    BH,80H
        JZ      SHORT LOC_F1B45
        MOV     BL,3
        CALL    BEEP
        JMP     SHORT LOC_F1B4A
LOC_F1B45:
        MOV     BL,1
        CALL    BEEP
LOC_F1B4A:
        POP     BX
        TEST    BL,80H
        JZ      SHORT LOC_F1B5A
        MOV     AH,0
        INT     16H
        CMP     AL,59H
        CLC
        JNZ     SHORT LOC_F1B5A
        STC
LOC_F1B5A:
        POP     DS
        POP     DI
        POP     SI
        POP     BP
        POP     CX
        POP     BX
        POP     ES
        POP     AX
        IRET
PRNT3           ENDP

;-----------------------------------------------------------
; LOCATEI
;
; LOCATE A DISPLAY PAGE WITH ROOM FOR THE REQUESTED MESSAGE.
; IF THE CURRENT PAGE CANNOT FIT THE MESSAGE, ADVANCE TO AN
; EARLIER PAGE, DISPLAY A SHORT PROMPT, AND SELECT THAT PAGE.
;
; ENTRY
;       AL = MESSAGE WIDTH NEEDED
; EXIT
;       DX = ROW,COLUMN FOR MESSAGE
;       IRET TO CALLER
;-----------------------------------------------------------
LOCATEI         PROC    FAR
        PUSH    BX
        PUSH    BP
        PUSH    AX
        MOV     BH,7
LOC_F1B68:
        MOV     AH,3
        INT     10H
        POP     AX
        PUSH    AX
        CMP     DH,14H
        JL      SHORT LOC_F1B77
        DEC     BH
        JMP     SHORT LOC_F1B68
LOC_F1B77:
        MOV     AH,26H
        SUB     AH,DL
        CMP     AL,AH
        JL      SHORT LOC_F1B9C
        MOV     DL,2
        ADD     DH,0CH
        CMP     DH,14H
        JL      SHORT LOC_F1B9C
        MOV     DX,1525H
        MOV     BP,OFFSET LOCATE_MSG
        INT     82H
        DEC     BH
        MOV     AL,BH
        MOV     AH,5
        INT     10H
        MOV     DX,0102H
LOC_F1B9C:
        POP     AX
        POP     BP
        POP     BX
        IRET
LOCATEI         ENDP

 LOCATE_MSG      DB      02H,02AH,0FFH,000H,0FCH

;-----------------------------------------------------------
; JOYSTICK
;
; SERVICE THE PCJR JOYSTICK DEMONSTRATION/TEST INTERRUPT.
; THIS ROUTINE READS THE GAME I/O PORT, DISPLAYS STICK AND
; BUTTON STATE THROUGH PRNT3, AND ACCEPTS KEYBOARD CONTROL
; INPUT FOR THE ON-SCREEN TEST DISPLAY.
;
; ENTRY
;       AH = JOYSTICK SERVICE FUNCTION
; EXIT
;       IRET OR FAR RETURN, DEPENDING ON SERVICE PATH
;-----------------------------------------------------------
JOYSTICK        PROC    FAR
        XOR     BX,BX
        OR      AH,AH
        JZ      SHORT LOC_F1BDD
        CMP     AH,1
        JZ      SHORT LOC_F1BE1
        CMP     AH,36H
        JZ      SHORT LOC_F1C0A
        CMP     AH,45H
        JZ      SHORT LOC_F1BEA
        CMP     AH,0FFH
        JZ      SHORT LOC_F1BEA
        MOV     BL,5AH
        CMP     AH,37H
        JZ      SHORT LOC_F1C0A
        JMP     LOCRET_F1CE5

JOY_LIMITS1     DW      036BH,0002H
JOY_LIMITS2     DW      0028H,0012H
                DW      0046H,0025H
                DW      006DH,003CH
                DW      008DH,004FH

LOC_F1BDD:
        CALL    JOY_SHOW_TITLE
        IRET
LOC_F1BE1:
        CALL    JOY_SHOW_TITLE
        MOV     BP,OFFSET JOY_PROMPT
        INT     82H
        IRET
LOC_F1BEA:
        PUSH    CS
        POP     DS
        ASSUME  DS:CODE
        XOR     BX,BX
        MOV     AH,1
        MOV     SI,OFFSET JOY_LIMITS2
LOC_F1BF3:
        CALL    JOY_READ_AXIS
        CALL    JOY_ACCUM_AXIS
        ADD     SI,4
        ROL     AH,1
        TEST    AH,10H
        JZ      SHORT LOC_F1BF3
        MOV     DH,BH
        OR      DH,BL
        JMP     LOC_F1CE1
LOC_F1C0A:
        MOV     AX,1
        INT     10H
        PUSH    CS
        POP     DS
        MOV     AH,1
        MOV     CH,20H
        INT     10H
        MOV     DX,0400H
        MOV     BP,OFFSET JOY_SCREEN
        INT     82H
        MOV     CX,0DH
        MOV     DX,0800H
        MOV     BP,OFFSET JOY_REPEAT
LOC_F1C28:
        INT     82H
        LOOP    LOC_F1C28
        CMP     BL,5AH
        JNZ     SHORT LOC_F1C34
        JMP     LOC_F1E32
LOC_F1C34:
        MOV     BP,OFFSET JOY_STATUS
        MOV     AH,1
LOC_F1C39:
        MOV     DL,AL
        CALL    JOY_READ_AXIS
        MOV     SI,OFFSET JOY_LIMITS1
        CALL    JOY_ACCUM_AXIS
        CALL    JOY_AXIS_BUCKET
        ROL     AH,1
        TEST    AH,0AH
        JNZ     SHORT LOC_F1C39
        MOV     DH,AL
        ADD     DX,8817H
        TEST    AH,10H
        PUSHF
        JZ      SHORT LOC_F1C5D
        SUB     DL,13H
LOC_F1C5D:
        PUSH    BX
        CMP     BH,11H
        MOV     BL,0FH
        JNZ     SHORT LOC_F1C67
        MOV     BL,0
LOC_F1C67:
        CALL    JOY_CLEAR_WINDOW
        INT     82H
        POP     BX
        POPF
        JZ      SHORT LOC_F1C39
        PUSH    BX
        MOV     DX,0201H
        IN      AL,DX
        MOV     DX,821FH
        MOV     BP,OFFSET JOY_MARK
LOC_F1C7B:
        MOV     BL,9
        TEST    AL,AH
        JNZ     SHORT LOC_F1C83
        MOV     BL,0
LOC_F1C83:
        INT     82H
        OR      DH,80H
        ROL     AH,1
        JB      SHORT LOC_F1C94
        TEST    AH,40H
        JZ      SHORT LOC_F1C7B
        DEC     DX
        JMP     SHORT LOC_F1C7B
LOC_F1C94:
        POP     BX
        MOV     DX,2A2AH
        OR      BX,BX
        JZ      SHORT LOC_F1CD9
        TEST    BX,8888H
        JZ      SHORT LOC_F1CA7
        MOV     DX,4320H
        JMP     SHORT LOC_F1CE1
LOC_F1CA7:
        CMP     BX,1111H
        JNZ     SHORT LOC_F1CB2
        MOV     DX,4141H
        JMP     SHORT LOC_F1CE1
LOC_F1CB2:
        CMP     BL,11H
        JNZ     SHORT LOC_F1CBC
        MOV     DL,41H
        AND     BL,0CCH
LOC_F1CBC:
        CMP     BH,11H
        JNZ     SHORT LOC_F1CC6
        MOV     DH,41H
        AND     BH,0CCH
LOC_F1CC6:
        OR      BL,BL
        JZ      SHORT LOC_F1CCC
        MOV     DL,42H
LOC_F1CCC:
        OR      BH,BH
        JZ      SHORT LOC_F1CD4
        MOV     DH,42H
        JMP     SHORT LOC_F1CE1
LOC_F1CD4:
        CMP     DL,42H
        JZ      SHORT LOC_F1CE1
LOC_F1CD9:
        CALL    JOY_TEST_BREAK
        JNZ     SHORT LOC_F1CE1
        JMP     LOC_F1C34
LOC_F1CE1:
        STC
        RET     2
LOCRET_F1CE5:
        IRET
JOYSTICK        ENDP

JOY_SHOW_TITLE  PROC    NEAR
        MOV     BP,OFFSET JOY_TITLE
        MOV     AL,3
        INT     81H
        INT     82H
        RET
JOY_SHOW_TITLE  ENDP

JOY_TEST_BREAK  PROC    NEAR
        PUSH    AX
        PUSH    DS
        CALL    DDS
        ASSUME  DS:DATA
        MOV     AL,BIOS_BREAK
        POP     DS
        ASSUME  DS:NOTHING
        TEST    AL,80H
        POP     AX
        RET
JOY_TEST_BREAK  ENDP

JOY_READ_AXIS   PROC    NEAR
        PUSH    DX
        MOV     DX,0201H
        MOV     CX,36BH
LOC_F1D04:
        IN      AL,DX
        TEST    AL,AH
        LOOPNE  LOC_F1D04
        MOV     CX,36BH
        CLI
        OUT     DX,AL
LOC_F1D0E:
        IN      AL,DX
        TEST    AL,AH
        LOOPNE  LOC_F1D0E
        STI
        JCXZ    SHORT LOC_F1D1E
        NEG     CX
        ADD     CX,36BH
        JMP     SHORT LOC_F1D20
LOC_F1D1E:
        MOV     AL,0FFH
LOC_F1D20:
        POP     DX
        RET
JOY_READ_AXIS   ENDP

JOY_AXIS_BUCKET PROC    NEAR
        PUSH    BX
        MOV     BX,0AH
        MOV     AL,0
LOC_F1D28:
        CMP     CX,BX
        JL      SHORT LOC_F1D36
        CMP     AL,0CH
        JZ      SHORT LOC_F1D36
        ADD     BX,8
        INC     AX
        JMP     SHORT LOC_F1D28
LOC_F1D36:
        POP     BX
        RET
JOY_AXIS_BUCKET ENDP

JOY_CLEAR_WINDOW PROC   NEAR
        PUSH    BP
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        MOV     AX,600H
        MOV     BH,7
        MOV     CX,804H
        CMP     DL,14H
        MOV     DX,1410H
        JL      SHORT LOC_F1D51
        MOV     CL,17H
        MOV     DL,23H
LOC_F1D51:
        INT     10H
        POP     AX
        POP     BX
        POP     CX
        POP     DX
        POP     BP
        RET
JOY_CLEAR_WINDOW ENDP

JOY_ACCUM_AXIS  PROC    NEAR
        PUSH    CX
        CMP     AL,0FFH
        JNZ     SHORT LOC_F1D63
        OR      BL,1
        JMP     SHORT LOC_F1D7F
LOC_F1D63:
        CMP     CX,36BH
        JLE     SHORT LOC_F1D6E
        OR      BL,4
        JMP     SHORT LOC_F1D7F
LOC_F1D6E:
        CMP     CX,[SI]
        JLE     SHORT LOC_F1D77
LOC_F1D72:
        OR      BL,2
        JMP     SHORT LOC_F1D7F
LOC_F1D77:
        CMP     CX,[SI+2]
        JGE     SHORT LOC_F1D7F
        OR      BL,8
LOC_F1D7F:
        MOV     CL,4
        ROR     BX,CL
        POP     CX
        RET
JOY_ACCUM_AXIS  ENDP

JOY_SCREEN      DB      05H,07H,20H,09H,0DBH,0A4H,0A7H,0A4H
                DB      0A7H,0A5H,0A7H,0A4H,0A7H,0FBH,0FBH,0FBH
                DB      0FAH,07H,20H,0C9H,0C8H,0CDH,0BBH,0BCH
                DB      03H,01H,00H,0DH,01H,00H,04H,01H
                DB      00H,0DH,01H,00H,03H,0FDH,35H,0FBH
                DB      03H,00H,01H,0DH,00H,01H,04H,00H
                DB      01H,0DH,00H,01H,03H,0FBH,85H,0FCH
JOY_REPEAT      DB      03H,20H,0BAH,03H,01H,0DH,01H,04H
                DB      01H,0DH,01H,0FBH,0FCH
JOY_STATUS      DB      02H,0FH,0FFH
JOY_MARK        DB      02H,0DBH,06H,73H,06H,6AH,0FDH,26H
                DB      0FCH
JOY_TITLE       DB      15H,0AH,0AH,0AH,0BH,02H,0FEH,0BH
                DB      0FEH,0DAH,0C1H,0BFH,0BH,0FDH,0C0H,0C4H
                DB      0D9H,0AH,0BH,0FDH,0CH,0FFH
JOY_LOCATE_MSG  DB      07H,07H,20H,87H,36H,07H,20H,0A2H
                DB      0A2H,0A2H,0FDH,1FH,7BH,0FCH
JOY_PROMPT      DB      05H,87H,20H,45H,20H,0FDH,2FH,74H
                DB      0A2H,01H,01H,0FDH,1FH,7BH,0FCH
JOY_KEY_SCANS   DB      48H,4BH,47H,4DH,49H,50H,4FH,51H
                DB      1CH,39H,11H,1EH,10H,1FH,12H,2CH
                DB      2BH,2DH,01H,0FH
JOY_KEY_MASKS   DB      01H,02H,03H,04H,05H,08H,0AH,0CH
                DB      10H,20H,41H,42H,43H,44H,45H,48H
                DB      4AH,4CH,50H,60H,00H

LOC_F1E32:
        CALL    DDS
        PUSH    DS
        MOV     BYTE PTR DS:[12H],0
        MOV     AX,50H
        MOV     DS,AX
        ASSUME  DS:NOTHING
        PUSH    DS
        POP     ES
        ASSUME  ES:NOTHING
        MOV     CX,6
        MOV     AL,1
        MOV     DI,29H
        REP     STOSW
        JMP     SHORT LOC_F1E54
LOC_F1E4E:
        MOV     AH,1
        INT     16H
        JNZ     SHORT LOC_F1E57
LOC_F1E54:
        JMP     LOC_F1EF1
LOC_F1E57:
        MOV     AH,0
        INT     16H
        MOV     AL,AH
        MOV     CX,15H
        CLD
        MOV     DI,OFFSET JOY_KEY_SCANS
        PUSH    CS
        POP     ES
        ASSUME  ES:CODE
        REPNE  SCASB
        MOV     AX,DI
        SUB     AX,OFFSET JOY_KEY_SCANS
        DEC     AX
        MOV     BX,OFFSET JOY_KEY_MASKS
        XLAT    CS:JOY_KEY_MASKS
        MOV     BX,29H
        TEST    AL,40H
        PUSHF
        JZ      SHORT LOC_F1E7E
        ADD     BX,6
LOC_F1E7E:
        MOV     DX,8C1BH
        TEST    AL,1
        JZ      SHORT LOC_F1E87
        MOV     DH,88H
LOC_F1E87:
        TEST    AL,8
        JZ      SHORT LOC_F1E8D
        MOV     DH,90H
LOC_F1E8D:
        TEST    AL,4
        JZ      SHORT LOC_F1E93
        MOV     DL,1FH
LOC_F1E93:
        TEST    AL,2
        JZ      SHORT LOC_F1E99
        MOV     DL,17H
LOC_F1E99:
        CMP     DX,8C1BH
        JZ      SHORT LOC_F1EC0
        POPF
        PUSHF
        JZ      SHORT LOC_F1EA6
        SUB     DL,13H
LOC_F1EA6:
        CMP     [BX+0CH],DX
        JZ      SHORT LOC_F1EBC
        CALL    JOY_CLEAR_WINDOW
        MOV     BP,OFFSET JOY_MOVE_MARK
        PUSH    DX
        PUSH    BX
        MOV     BL,0EH
        INT     82H
        POP     BX
        POP     DX
        MOV     [BX+0CH],DX
LOC_F1EBC:
        MOV     WORD PTR [BX],5FFH
LOC_F1EC0:
        MOV     DX,821FH
        MOV     BP,OFFSET JOY_MARK
        POPF
        JZ      SHORT LOC_F1ECB
        MOV     DL,0CH
LOC_F1ECB:
        TEST    AL,10H
        JZ      SHORT LOC_F1EDC
        PUSH    BX
        MOV     BL,0
        INT     82H
        POP     BX
        MOV     WORD PTR [BX+2],5FFH
        JMP     SHORT LOC_F1EDF
LOC_F1EDC:
        SUB     DL,9
LOC_F1EDF:
        TEST    AL,20H
        JZ      SHORT LOC_F1EF1
        PUSH    BX
        MOV     BL,0
        OR      DH,80H
        INT     82H
        POP     BX
        MOV     WORD PTR [BX+4],5FFH
LOC_F1EF1:
        MOV     CX,4
        MOV     BX,2BH
        MOV     DX,821FH
        MOV     BP,OFFSET JOY_MARK
LOC_F1EFD:
        DEC     WORD PTR [BX]
        JNZ     SHORT LOC_F1F0C
        PUSH    BX
        MOV     BL,9
        INT     82H
        POP     BX
        OR      DH,80H
        JMP     SHORT LOC_F1F0F
LOC_F1F0C:
        SUB     DL,9
LOC_F1F0F:
        CMP     DL,0DH
        JNZ     SHORT LOC_F1F17
        DEC     DX
        INC     BX
        INC     BX
LOC_F1F17:
        INC     BX
        INC     BX
        LOOP    LOC_F1EFD
        SUB     BX,0CH
        MOV     CL,2
        MOV     BP,OFFSET JOY_MOVE_MARK
        MOV     DX,0C1BH
LOC_F1F26:
        DEC     WORD PTR [BX]
        JNZ     SHORT LOC_F1F39
        CALL    JOY_CLEAR_WINDOW
        PUSH    BX
        MOV     [BX+0CH],DX
        OR      DH,80H
        MOV     BL,0EH
        INT     82H
        POP     BX
LOC_F1F39:
        MOV     DX,0C08H
        ADD     BX,6
        LOOP    LOC_F1F26
        CALL    JOY_TEST_BREAK
        JNZ     SHORT LOC_F1F49
        JMP     LOC_F1E4E
LOC_F1F49:
        POP     DS
        ASSUME  DS:NOTHING
        SUB     DH,DH
        MOV     BL,DH
        MOV     BH,DS:[12H]
        OR      BH,BH
        JZ      SHORT LOC_F1F59
        MOV     DX,4220H
LOC_F1F59:
        JMP     LOC_F1CE1

JOY_MOVE_MARK   DB      02H,0DBH,05H,74H,05H,74H,05H,74H
               DB      05H,74H,05H,0FCH
JOY_PAD         DB      151 DUP(0)


                DB      0ABH

; LIST
ASSUME  CS:CODE,DS:DATA
;-------------------------------------------------------
; Opaque ROM blobs for Diagnostics and Basic.
; These were omitted from the original source via a
; NOLIST directive.
;-------------------------------------------------------
        ORG     2000H
DIAG_ROM        LABEL   BYTE
        INCLUDE DIAGROM.INC

        ORG     6000H
BASIC_ROM       LABEL   BYTE
        INCLUDE BASICROM.INC

        ORG     0E000H
        DB      '1504037 COPR. IBM 1981,1983' ; COPYRIGHT NOTICE





;-----------------------------------------------------------
;REAL_VECTOR_SETUP
;
; THIS ROUTINE WILL INITIALIZE THE INTERRUPT 9 VECTOR TO
; POINT AT THE REAL INTERRUPT ROUTINE.
;-----------------------------------------------------------
REAL_VECTOR_SETUP PROC  NEAR
        PUSH    AX              ; SAVE THE SCAN CODE
        PUSH    BX
        PUSH    ES
        XOR     AX,AX           ; INITIALIZE TO POINT AT VECTOR
                                 ; SECTOR(0)
        MOV     ES,AX
        MOV     BX,9H*4H        ; POINT AT INTERRUPT 9
        MOV     WORD PTR ES:[BX],OFFSET KB_INT ; MOVE IN OFFSET OF
                                 ; ROUTINE
        INC     BX              ; ADD 2 TO BX
        INC     BX
        PUSH    CS              ; GET CODE SEGMENT OF BIOS (SEGMENT
                                 ; RELOCATEABLE)
        POP     AX
        MOV     WORD PTR ES:[BX],AX ; MOVE IN SEGMENT OF ROUTINE
        POP     ES
        POP     BX
        POP     AX
        RET
REAL_VECTOR_SETUP ENDP
;-----------------------------------------------------------
;KB_NOISE
;
; THIS ROUTINE IS CALLED WHEN GENERAL BEEPS ARE REQUIRED FROM
; THE SYSTEM.
;
;INPUT
;       BX=LENGTH OF THE TONE
;       CX=CONTAINS THE FREQUENCY
;OUTPUT
;       ALL REGISTERS ARE MAINTAINED.
;HINTS
;       AS CX GETS LARGER THE TONE PRODUCED GETS LOWER IN PITCH.
;
;-----------------------------------------------------------
KB_NOISE        PROC    NEAR
        STI
        PUSH    AX
        PUSH    BX
        PUSH    CX
        IN      AL,061H         ; GET CONTROL INFO
        PUSH    AX              ; SAVE
LOOP01:
        AND     AL,0FCH         ; TURN OFF TIMER GATE AND SPEAKER
                                 ; DATA
        OUT     061H,AL         ; OUTPUT TO CONTROL
        PUSH    CX              ; HALF CYCLE TIME FOR TONE
LOOP02: LOOP    LOOP02          ; SPEAKER OFF
        OR      AL,2            ; TURN ON SPEAKER BIT
        OUT     061H,AL         ; OUTPUT TO CONTROL
        POP     CX
        PUSH    CX              ; RETRIEVE FREQUENCY
LOOP03: LOOP    LOOP03          ; ANOTHER HALF CYCLE
        DEC     BX              ; TOTAL TIME COUNT
        POP     CX              ; RETRIEVE FREQ.
        JNZ     LOOP01          ; DO ANOTHER CYCLE
        POP     AX              ; RECOVER CONTROL
        OUT     061H,AL         ; OUTPUT THE CONTROL
        POP     CX
        POP     BX
        POP     AX
        RET
KB_NOISE        ENDP
        ORG     0E05BH
        JMP     NEAR PTR RESET
; ----------------------------------------------------
;     CHARACTER GENERATOR GRAPHICS FOR 320X200 AND 640X200
;     GRAPHICS FOR CHARACTERS 80H THROUGH FFH
; ----------------------------------------------------
CRT_CHARH       LABEL   BYTE
        DB      078H, 0CCH, 0C0H, 0CCH, 078H, 018H, 00CH, 078H ; D_80

        DB      000H, 0CCH, 000H, 0CCH, 0CCH, 0CCH, 07EH, 000H ; D_81

        DB      01CH, 000H, 078H, 0CCH, 0FCH, 0C0H, 078H, 000H ; D_82

        DB      07EH, 0C3H, 03CH, 006H, 03EH, 066H, 03FH, 000H ; D_83

        DB      0CCH, 000H, 078H, 00CH, 07CH, 0CCH, 07EH, 000H ; D_84

        DB      0E0H, 000H, 078H, 00CH, 07CH, 0CCH, 07EH, 000H ; D_85

        DB      030H, 030H, 078H, 00CH, 07CH, 0CCH, 07EH, 000H ; D_86

        DB      000H, 000H, 078H, 0C0H, 0C0H, 078H, 00CH, 038H ; D_87

        DB      07EH, 0C3H, 03CH, 066H, 07EH, 060H, 03CH, 000H ; D_88

        DB      0CCH, 000H, 078H, 0CCH, 0FCH, 0C0H, 078H, 000H ; D_89

        DB      0E0H, 000H, 078H, 0CCH, 0FCH, 0C0H, 078H, 000H ; D_8A

        DB      0CCH, 000H, 070H, 030H, 030H, 030H, 078H, 000H ; D_8B

        DB      07CH, 0C6H, 038H, 018H, 018H, 018H, 03CH, 000H ; D_8C

        DB      0E0H, 000H, 070H, 030H, 030H, 030H, 078H, 000H ; D_8D

        DB      0C6H, 038H, 06CH, 0C6H, 0FEH, 0C6H, 0C6H, 000H ; D_8E

        DB      030H, 030H, 000H, 078H, 0CCH, 0FCH, 0CCH, 000H ; D_8F

        DB      01CH, 000H, 0FCH, 060H, 078H, 060H, 0FCH, 000H ; D_90

        DB      000H, 000H, 07FH, 00CH, 07FH, 0CCH, 07FH, 000H ; D_91

        DB      03EH, 06CH, 0CCH, 0FEH, 0CCH, 0CCH, 0CEH, 000H ; D_92

        DB      078H, 0CCH, 000H, 078H, 0CCH, 0CCH, 078H, 000H ; D_93

        DB      000H, 0CCH, 000H, 078H, 0CCH, 0CCH, 078H, 000H ; D_94

        DB      000H, 0E0H, 000H, 078H, 0CCH, 0CCH, 078H, 000H ; D_95

        DB      078H, 0CCH, 000H, 0CCH, 0CCH, 0CCH, 07EH, 000H ; D_96

        DB      000H, 0E0H, 000H, 0CCH, 0CCH, 0CCH, 07EH, 000H ; D_97

        DB      000H, 0CCH, 000H, 0CCH, 0CCH, 07CH, 00CH, 0F8H ; D_98

        DB      0C3H, 018H, 03CH, 066H, 066H, 03CH, 018H, 000H ; D_99

        DB      0CCH, 000H, 0CCH, 0CCH, 0CCH, 0CCH, 078H, 000H ; D_9A

        DB      018H, 018H, 07EH, 0C0H, 0C0H, 07EH, 018H, 018H ; D_9B

        DB      038H, 06CH, 064H, 0F0H, 060H, 0E6H, 0FCH, 000H ; D_9C

        DB      0CCH, 0CCH, 078H, 0FCH, 030H, 0FCH, 030H, 030H ; D_9D

        DB      0F8H, 0CCH, 0CCH, 0FAH, 0C6H, 0CFH, 0C6H, 0C7H ; D_9E

        DB      00EH, 01BH, 018H, 03CH, 018H, 018H, 0D8H, 070H ; D_9F


        DB      01CH, 000H, 078H, 00CH, 07CH, 0CCH, 07EH, 000H ; D_A0

        DB      038H, 000H, 070H, 030H, 030H, 030H, 078H, 000H ; D_A1

        DB      000H, 01CH, 000H, 078H, 0CCH, 0CCH, 078H, 000H ; D_A2

        DB      000H, 01CH, 000H, 0CCH, 0CCH, 0CCH, 07EH, 000H ; D_A3

        DB      000H, 0F8H, 000H, 0F8H, 0CCH, 0CCH, 0CCH, 000H ; D_A4

        DB      0FCH, 000H, 0CCH, 0ECH, 0FCH, 0DCH, 0CCH, 000H ; D_A5

        DB      03CH, 06CH, 06CH, 03EH, 000H, 07EH, 000H, 000H ; D_A6

        DB      038H, 06CH, 06CH, 038H, 000H, 07CH, 000H, 000H ; D_A7

        DB      030H, 000H, 030H, 060H, 0C0H, 0CCH, 078H, 000H ; D_A8

        DB      000H, 000H, 000H, 0FCH, 0C0H, 0C0H, 000H, 000H ; D_A9

        DB      000H, 000H, 000H, 0FCH, 00CH, 00CH, 000H, 000H ; D_AA

        DB      0C3H, 0C6H, 0CCH, 0DEH, 033H, 066H, 0CCH, 00FH ; D_AB

        DB      0C3H, 0C6H, 0CCH, 0DBH, 037H, 06FH, 0CFH, 003H ; D_AC

        DB      018H, 018H, 000H, 018H, 018H, 018H, 018H, 000H ; D_AD

        DB      000H, 033H, 066H, 0CCH, 066H, 033H, 000H, 000H ; D_AE

        DB      000H, 0CCH, 066H, 033H, 066H, 0CCH, 000H, 000H ; D_AF

        DB      022H, 088H, 022H, 088H, 022H, 088H, 022H, 088H ; D_B0

        DB      055H, 0AAH, 055H, 0AAH, 055H, 0AAH, 055H, 0AAH ; D_B1

        DB      0DBH, 077H, 0DBH, 0EEH, 0DBH, 077H, 0DBH, 0EEH ; D_B2

        DB      018H, 018H, 018H, 018H, 018H, 018H, 018H, 018H ; D_B3

        DB      018H, 018H, 018H, 018H, 0F8H, 018H, 018H, 018H ; D_B4

        DB      018H, 018H, 0F8H, 018H, 0F8H, 018H, 018H, 018H ; D_B5

        DB      036H, 036H, 036H, 036H, 0F6H, 036H, 036H, 036H ; D_B6

        DB      000H, 000H, 000H, 000H, 0FEH, 036H, 036H, 036H ; D_B7

        DB      000H, 000H, 0F8H, 018H, 0F8H, 018H, 018H, 018H ; D_B8

        DB      036H, 036H, 0F6H, 006H, 0F6H, 036H, 036H, 036H ; D_B9

        DB      036H, 036H, 036H, 036H, 036H, 036H, 036H, 036H ; D_BA

        DB      000H, 000H, 0FEH, 006H, 0F6H, 036H, 036H, 036H ; D_BB

        DB      036H, 036H, 0F6H, 006H, 0FEH, 000H, 000H, 000H ; D_BC

        DB      036H, 036H, 036H, 036H, 0FEH, 000H, 000H, 000H ; D_BD

        DB      018H, 018H, 0F8H, 018H, 0F8H, 000H, 000H, 000H ; D_BE

        DB      000H, 000H, 000H, 000H, 0F8H, 018H, 018H, 018H ; D_BF

        DB      018H, 018H, 018H, 018H, 01FH, 000H, 000H, 000H ; D_C0

        DB      018H, 018H, 018H, 018H, 0FFH, 000H, 000H, 000H ; D_C1

        DB      000H, 000H, 000H, 000H, 0FFH, 018H, 018H, 018H ; D_C2

        DB      018H, 018H, 018H, 018H, 01FH, 018H, 018H, 018H ; D_C3

        DB      000H, 000H, 000H, 000H, 0FFH, 000H, 000H, 000H ; D_C4

        DB      018H, 018H, 018H, 018H, 0FFH, 018H, 018H, 018H ; D_C5

        DB      018H, 018H, 01FH, 018H, 01FH, 018H, 018H, 018H ; D_C6

        DB      036H, 036H, 036H, 036H, 037H, 036H, 036H, 036H ; D_C7

        DB      036H, 036H, 037H, 030H, 03FH, 000H, 000H, 000H ; D_C8

        DB      000H, 000H, 03FH, 030H, 037H, 036H, 036H, 036H ; D_C9

        DB      036H, 036H, 0F7H, 000H, 0FFH, 000H, 000H, 000H ; D_CA

        DB      000H, 000H, 0FFH, 000H, 0F7H, 036H, 036H, 036H ; D_CB

        DB      036H, 036H, 037H, 030H, 037H, 036H, 036H, 036H ; D_CC

        DB      000H, 000H, 0FFH, 000H, 0FFH, 000H, 000H, 000H ; D_CD

        DB      036H, 036H, 0F7H, 000H, 0F7H, 036H, 036H, 036H ; D_CE

        DB      018H, 018H, 0FFH, 000H, 0FFH, 000H, 000H, 000H ; D_CF

        DB      036H, 036H, 036H, 036H, 0FFH, 000H, 000H, 000H ; D_D0

        DB      000H, 000H, 0FFH, 000H, 0FFH, 018H, 018H, 018H ; D_D1

        DB      000H, 000H, 000H, 000H, 0FFH, 036H, 036H, 036H ; D_D2

        DB      036H, 036H, 036H, 036H, 03FH, 000H, 000H, 000H ; D_D3

        DB      018H, 018H, 01FH, 018H, 01FH, 000H, 000H, 000H ; D_D4

        DB      000H, 000H, 01FH, 018H, 01FH, 018H, 018H, 018H ; D_D5

        DB      000H, 000H, 000H, 000H, 03FH, 036H, 036H, 036H ; D_D6

        DB      036H, 036H, 036H, 036H, 0FFH, 036H, 036H, 036H ; D_D7

        DB      018H, 018H, 0FFH, 018H, 0FFH, 018H, 018H, 018H ; D_D8

        DB      018H, 018H, 018H, 018H, 0F8H, 000H, 000H, 000H ; D_D9

        DB      000H, 000H, 000H, 000H, 01FH, 018H, 018H, 018H ; D_DA

        DB      0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; D_DB

        DB      000H, 000H, 000H, 000H, 0FFH, 0FFH, 0FFH, 0FFH ; D_DC

        DB      0F0H, 0F0H, 0F0H, 0F0H, 0F0H, 0F0H, 0F0H, 0F0H ; D_DD

        DB      00FH, 00FH, 00FH, 00FH, 00FH, 00FH, 00FH, 00FH ; D_DE

        DB      0FFH, 0FFH, 0FFH, 0FFH, 000H, 000H, 000H, 000H ; D_DF

        DB      000H, 000H, 076H, 0DCH, 0C8H, 0DCH, 076H, 000H ; D_E0

        DB      000H, 078H, 0CCH, 0F8H, 0CCH, 0F8H, 0C0H, 0C0H ; D_E1

        DB      000H, 0FCH, 0CCH, 0C0H, 0C0H, 0C0H, 0C0H, 000H ; D_E2

        DB      000H, 0FEH, 06CH, 06CH, 06CH, 06CH, 06CH, 000H ; D_E3

        DB      0FCH, 0CCH, 060H, 030H, 060H, 0CCH, 0FCH, 000H ; D_E4

        DB      000H, 000H, 07EH, 0D8H, 0D8H, 0D8H, 070H, 000H ; D_E5

        DB      000H, 066H, 066H, 066H, 066H, 07CH, 060H, 0C0H ; D_E6

        DB      000H, 076H, 0DCH, 018H, 018H, 018H, 018H, 000H ; D_E7

        DB      0FCH, 030H, 078H, 0CCH, 0CCH, 078H, 030H, 0FCH ; D_E8

        DB      038H, 06CH, 0C6H, 0FEH, 0C6H, 06CH, 038H, 000H ; D_E9

        DB      038H, 06CH, 0C6H, 0C6H, 06CH, 06CH, 0EEH, 000H ; D_EA

        DB      01CH, 030H, 018H, 07CH, 0CCH, 0CCH, 078H, 000H ; D_EB

        DB      000H, 000H, 07EH, 0DBH, 0DBH, 07EH, 000H, 000H ; D_EC

        DB      006H, 00CH, 07EH, 0DBH, 0DBH, 07EH, 060H, 0C0H ; D_ED

        DB      038H, 060H, 0C0H, 0F8H, 0C0H, 060H, 038H, 000H ; D_EE

        DB      078H, 0CCH, 0CCH, 0CCH, 0CCH, 0CCH, 0CCH, 000H ; D_EF


        DB      000H, 0FCH, 000H, 0FCH, 000H, 0FCH, 000H, 000H ; D_F0

        DB      030H, 030H, 0FCH, 030H, 030H, 000H, 0FCH, 000H ; D_F1

        DB      060H, 030H, 018H, 030H, 060H, 000H, 0FCH, 000H ; D_F2

        DB      018H, 030H, 060H, 030H, 018H, 000H, 0FCH, 000H ; D_F3

        DB      00EH, 01BH, 01BH, 018H, 018H, 018H, 018H, 018H ; D_F4

        DB      018H, 018H, 018H, 018H, 018H, 0D8H, 0D8H, 070H ; D_F5

        DB      030H, 030H, 000H, 0FCH, 000H, 030H, 030H, 000H ; D_F6

        DB      000H, 076H, 0DCH, 000H, 076H, 0DCH, 000H, 000H ; D_F7

        DB      038H, 06CH, 06CH, 038H, 000H, 000H, 000H, 000H ; D_F8

        DB      000H, 000H, 000H, 018H, 018H, 000H, 000H, 000H ; D_F9

        DB      000H, 000H, 000H, 000H, 018H, 000H, 000H, 000H ; D_FA

        DB      00FH, 00CH, 00CH, 00CH, 0ECH, 06CH, 03CH, 01CH ; D_FB

        DB      078H, 06CH, 06CH, 06CH, 06CH, 000H, 000H, 000H ; D_FC

        DB      070H, 018H, 030H, 060H, 078H, 000H, 000H, 000H ; D_FD

        DB      000H, 000H, 03CH, 03CH, 03CH, 03CH, 000H, 000H ; D_FE

        DB      000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H ; D_FF


ASSUME  CS:CODE,DS:DATA
;---------------------------------------------------------------
;       SET_CTYPE
;               THIS ROUTINE SETS THE CURSOR VALUE
;       INPUT   (CX) HAS CURSOR VALUE CH-START LINE, CL-STOP LINE
;       OUTPUT  NONE
;---------------------------------------------------------------
SET_CTYPE       PROC    NEAR
        CMP     AH,4            ; IN GRAPHICS MODE?
        JC      C23X            ; NO, JUMP
        OR      CH,20H          ; YES, DISABLE CURSOR
C23X:   MOV     AH,10           ; 6845 REGISTER FOR CURSOR SET
        MOV     CURSOR_MODE,CX  ; SAVE IN DATA AREA
        CALL    C23             ; OUTPUT CX REG
        JMP     VIDEO_RETURN
;THIS ROUTINE OUTPUTS THE CX REGISTER TO THE 6845 REGS NAMED IN AH
C23:    MOV     DX,ADDR_6845    ; ADDRESS REGISTER
        MOV     AL,AH           ; GET VALUE
        OUT     DX,AL           ; REGISTER SET
        INC     DX              ; DATA REGISTER
        MOV     AL,CH           ; DATA
        OUT     DX,AL
        DEC     DX
        MOV     AL,AH
        INC     AL              ; POINT TO OTHER DATA REGISTER
        OUT     DX,AL           ; SET FOR SECOND REGISTER
        INC     DX
        MOV     AL,CL           ; SECOND DATA VALUE
        OUT     DX,AL
        RET                     ; ALL DONE
SET_CTYPE       ENDP
;----------------------------------------
; SET_CPOS
;      THIS ROUTINE SETS THE CURRENT CURSOR POSITION TO THE
;      NEW X-Y VALUES PASSED
;
; INPUT
;      DX - ROW,COLUMN OF NEW CURSOR
;      BH - DISPLAY PAGE OF CURSOR
;
; OUTPUT
;      CURSOR IS SET AT 6845 IF DISPLAY PAGE IS CURRENT DISPLAY
;----------------------------------------
SET_CPOS        PROC    NEAR
        MOV     CL,BH
        XOR     CH,CH           ; ESTABLISH LOOP COUNT
        SAL     CX,1            ; WORD OFFSET
        MOV     SI,CX           ; USE INDEX REGISTER
        MOV     [SI+OFFSET CURSOR_POSN],DX ; SAVE THE POINTER
        CMP     ACTIVE_PAGE,BH
        JNZ     C24             ; SET_CPOS_RETURN
        MOV     AX,DX           ; GET ROW/COLUMN TO AX
        CALL    C25             ; CURSOR_SET
C24:    JMP     VIDEO_RETURN
SET_CPOS        ENDP
;------ SET CURSOR POSITION, AX HAS ROW/COLUMN FOR CURSOR
C25     PROC    NEAR
        CALL    POSITION        ; DETERMINE LOCATION IN REGEN
                                 ; BUFFER
        MOV     CX,AX
        ADD     CX,CRT_START    ; ADD IN THE START ADDRESS FOR THIS
                                 ; PAGE
        SAR     CX,1            ; DIVIDE BY 2 FOR CHAR ONLY COUNT
        MOV     AH,14           ; REGISTER NUMBER FOR CURSOR
        CALL    C23             ; OUTPUT THE VALUE TO THE 6845
        RET
C25     ENDP
;----------------------------------------
; ACT_DISP_PAGE
;      THIS ROUTINE SETS THE ACTIVE DISPLAY PAGE, ALLOWING
;      THE FULL USE OF THE RAM SET ASIDE FOR THE VIDEO ATTACHMENT
;
; INPUT
;      AL HAS THE NEW ACTIVE DISPLAY PAGE
;
; OUTPUT
;      THE 6845 IS RESET TO DISPLAY THAT PAGE
;----------------------------------------
ACT_DISP_PAGE   PROC    NEAR
        TEST    AL,080H         ; CRT/CPU PAGE REG FUNCTION
        JNZ     SET_CRTCPU      ; YES, GO HANDLE IT
        MOV     ACTIVE_PAGE,AL  ; SAVE ACTIVE PAGE VALUE
        MOV     CX,CRT_LEN      ; GET SAVED LENGTH OF REGEN BUFFER
        CBW                     ; CONVERT AL TO WORD
        PUSH    AX              ; SAVE PAGE VALUE
        MUL     CX              ; DISPLAY PAGE TIMES REGEN LENGTH
        MOV     CRT_START,AX    ; SAVE START ADDRESS FOR LATER USE
        MOV     CX,AX           ; START ADDRESS TO CX
        SAR     CX,1            ; DIVIDE BY 2 FOR 6845 HANDLING
        MOV     AH,12           ; 6845 REGISTER FOR START ADDRESS
        CALL    C23
        POP     BX              ; RECOVER PAGE VALUE
        SAL     BX,1            ; *2 FOR WORD OFFSET
        MOV     AX,[BX + OFFSET CURSOR_POSN] ; GET CURSOR FOR THIS
                                 ; PAGE
        CALL    C25             ; SET THE CURSOR POSITION
        JMP     VIDEO_RETURN
;----------------------------------------
; SET_CRTCPU
;      THIS ROUTINE READS OR WRITES THE CRT/CPU PAGE REGISTERS
;
; INPUT
;      (AL) = 83H       SET BOTH CRT AND CPU PAGE REGS
;             (BH) =    VALUE TO SET IN CRT PAGE REG
;             (BL) =    VALUE TO SET IN CPU PAGE REG
;      (AL) = 82H       SET CRT PAGE REG
;             (BH) =    VALUE TO SET IN CRT PAGE REG
;      (AL) = 81H       SET CPU PAGE REG
;             (BL) =    VALUE TO SET IN CPU PAGE REG
;      (AL) = 80H       READ CURRENT VALUE OF CRT/CPU PAGE REGS
;
; OUTPUT
;      ALL FUNCTIONS RETURN
;             (BH) = CURRENT CONTENTS OF CRT PAGE REG
;             (BL) = CURRENT CONTENTS OF CPU PAGE REG
;----------------------------------------
SET_CRTCPU:
        MOV     AH,AL           ; SAVE REQUEST IN AH
        MOV     DX,VGA_CTL      ; SET ADDRESS OF GATE ARRAY
C26:    IN      AL,DX           ; GET STATUS
        AND     AL,08H          ; VERTICAL RETRACE?
        JZ      C26             ; NO, WAIT FOR IT
        MOV     DX,PAGREG       ; SET IO ADDRESS OF PAGE REG
        MOV     AL,PAGDAT       ; GET DATA LAST OUTPUT TO REG
        CMP     AH,80H          ; READ FUNCTION REQUESTED?
        JZ      C29             ; YES, DON'T SET ANYTHING
        CMP     AH,84H          ; VALID REQUEST?
        JNC     C29             ; NO, PRETEND IT WAS A READ REQUEST
        TEST    AH,1            ; SET CPU REG?
        JZ      C27             ; NO, GO SEE ABOUT CRT REG
        SHL     BL,1            ; SHIFT VALUE TO RIGHT BIT POSITION
        SHL     BL,1
        SHL     BL,1
        AND     AL,NOT CPUREG   ; CLEAR OLD CPU VALUE
        AND     BL,CPUREG       ; BE SURE UNRELATED BITS ARE ZERO
        OR      AL,BL           ; OR IN NEW VALUE
C27:    TEST    AH,2            ; SET CRT REG?
        JZ      C28             ; NO, GO RETURN CURRENT SETTINGS
        AND     AL,NOT CRTREG   ; CLEAR OLD CRT VALUE
        AND     BH,CRTREG       ; BE SURE UNRELATED BITS ARE ZERO
        OR      AL,BH           ; OR IN NEW VALUE
C28:    OUT     DX,AL           ; SET NEW VALUES
        MOV     PAGDAT,AL       ; SAVE COPY IN RAM
C29:    MOV     BL,AL           ; GET CPU REG VALUE
        AND     BL,CPUREG       ; CLEAR EXTRA BITS
        SAR     BL,1            ; RIGHT JUSTIFY IN BL
        SAR     BL,1
        SAR     BL,1
        MOV     BH,AL           ; GET CRT REG VALUE
        AND     BH,CRTREG       ; CLEAR EXTRA BITS
        POP     DI              ; RESTORE SOME REGS
        POP     SI
        POP     AX              ; DISCARD SAVED BX
        JMP     C22             ; RETURN
ACT_DISP_PAGE   ENDP

;-----------------------------------------
; READ_CURSOR
;
; THIS ROUTINE READS THE CURRENT CURSOR VALUE FROM THE
; 6845, FORMATS IT, AND SENDS IT BACK TO THE CALLER
;
; INPUT
;      BH - PAGE OF CURSOR
; OUTPUT
;      DX - ROW, COLUMN OF THE CURRENT CURSOR POSITION
;      CX - CURRENT CURSOR MODE
;-----------------------------------------
READ_CURSOR     PROC    NEAR
        MOV     BL,BH
        XOR     BH,BH
        SAL     BX,1            ; WORD OFFSET
        MOV     DX,[BX+OFFSET CURSOR_POSN]
        MOV     CX,CURSOR_MODE
        POP     DI
        POP     SI
        POP     BX
        POP     AX              ; DISCARD SAVED CX AND DX
        POP     AX
        POP     DS
        POP     ES
        IRET
READ_CURSOR     ENDP
;
;-----------------------------------------
; SET COLOR
;
; THIS ROUTINE WILL ESTABLISH THE BACKGROUND COLOR, THE
; OVERSCAN COLOR, AND THE FOREGROUND COLOR SET FOR GRAPHICS
;
; INPUT
;
;      (BH) HAS COLOR ID
;
;           IF BH=0, THE BACKGROUND COLOR VALUE IS SET
;           FROM THE LOW BITS OF BL (0-31)
;           IN GRAPHIC MODES, BOTH THE BACKGROUND AND
;           BORDER ARE SET.  IN ALPHA MODES, ONLY THE
;           BORDER IS SET.
;           IF BH=1, THE PALETTE SELECTION IS MADE
;           BASED ON THE LOW BIT OF BL:
;                2 COLOR MODE:
;                     0 = WHITE FOR COLOR 1
;                     1 = BLACK FOR COLOR 1
;                4 COLOR MODES:
;                     0 = GREEN, RED, YELLOW FOR
;                         COLORS 1,2,3
;                     1 = BLUE, CYAN, MAGENTA FOR
;                         COLORS 1,2,3
;                16 COLOR MODES:
;                     ALWAYS SETS UP PALETTE AS:
;                          BLUE FOR COLOR 1
;                          GREEN FOR COLOR 2
;                          CYAN FOR COLOR 3
;                          RED FOR COLOR 4
;                          MAGENTA FOR COLOR 5
;                          BROWN FOR COLOR 6
;                          LIGHT GRAY FOR COLOR 7
;                          DARK GRAY FOR COLOR 8
;                          LIGHT BLUE FOR COLOR 9
;                          LIGHT GREEN FOR COLOR 10
;                          LIGHT CYAN FOR COLOR 11
;                          LIGHT RED FOR COLOR 12
;                          LIGHT MAGENTA FOR COLOR 13
;                          YELLOW FOR COLOR 14
;                          WHITE FOR COLOR 15
;
;      (BL) HAS THE COLOR VALUE TO BE USED
;
; OUTPUT
;
;      THE COLOR SELECTION IS UPDATED
;-----------------------------------------
SET_COLOR       PROC    NEAR
        MOV     DX,VGA_CTL      ; I/O PORT FOR PALETTE
C30:    IN      AL,DX           ; SYNC UP VGA FOR REG ADDRESS
        TEST    AL,8            ; IS VERTICAL RETRACE ON?
        JZ      C30             ; NO, WAIT UNTIL IT IS
        OR      BH,BH           ; IS THIS COLOR 0?
        JNZ     C31             ; OUTPUT COLOR 1
;------- HANDLE COLOR 0 BY SETTING THE BACKGROUND COLOR
;        AND BORDER COLOR
       CMP     CRT_MODE,4      ; IN ALPHA MODE?
       JC      C305            ; YES, JUST SET BORDER REG
       MOV     AL,10H          ; SET PALETTE REG 0
       OUT     DX,AL           ; SELECT VGA REG
       MOV     AL,BL           ; GET COLOR
       OUT     DX,AL           ; SET IT
C305:   MOV     AL,2            ; SET BORDER REG
       OUT     DX,AL           ; SELECT VGA BORDER REG
       MOV     AL,BL           ; GET COLOR
       OUT     DX,AL           ; SET IT
       MOV     CRT_PALETTE,AL  ; SAVE THE COLOR VALUE
       JMP     VIDEO_RETURN

;------- HANDLE COLOR 1 BY CHANGING PALETTE REGISTERS
C31:    MOV     AL,CRT_MODE     ; GET CURRENT MODE
        MOV     CX,OFFSET M0072 ; POINT TO 2 COLOR TABLE ENTRY
        CMP     AL,6            ; 2 COLOR MODE?
        JE      C33             ; YES, JUMP
        CMP     AL,4            ; 4 COLOR MODE?
        JE      C32             ; YES, JUMP
        CMP     AL,5            ; 4 COLOR MODE?
        JE      C32             ; YES, JUMP
        CMP     AL,0AH          ; 4 COLOR MODE?
        JNE     C36             ; NO, GO TO 16 COLOR SET UP
C32:    MOV     CX,OFFSET M0074 ; POINT TO 4 COLOR TABLE ENTRY
C33:    ROR     BL,1            ; SELECT ALTERNATE SET?
        JNC     C34             ; NO, JUMP
        ADD     CX,M0072L       ; POINT TO NEXT ENTRY
C34:    MOV     BX,CX           ; TABLE ADDRESS IN BX
        INC     BX              ; SKIP OVER BACKGROUND COLOR
        MOV     CX,M0072L-1     ; SET NUMBER OF REGS TO FILL
        MOV     AH,11H          ; AH IS REGISTER COUNTER
C35:    MOV     AL,AH           ; GET REG NUMBER
        OUT     DX,AL           ; SELECT IT
        MOV     AL,CS:[BX]      ; GET DATA
        OUT     DX,AL           ; SET IT
        INC     AH              ; NEXT REG
        INC     BX              ; NEXT TABLE VALUE
        LOOP    C35
        JMP     SHORT C38
C36:    MOV     AH,11H          ; AH IS REGISTER COUNTER
        MOV     CX,15           ; NUMBER OF PALETTES
C37:    MOV     AL,AH           ; GET REG NUMBER
        OUT     DX,AL           ; SELECT IT
        OUT     DX,AL           ; SET PALETTE VALUE
        INC     AH              ; NEXT REG
        LOOP    C37
C38:    XOR     AL,AL           ; SELECT LOW REG TO ENABLE VIDEO
                                 ; AGAIN
        OUT     DX,AL
        JMP     VIDEO_RETURN
SET_COLOR       ENDP
;-----------------------------------------
; VIDEO STATE
; RETURNS THE CURRENT VIDEO STATE IN AX
; AH = NUMBER OF COLUMNS ON THE SCREEN
; AL = CURRENT VIDEO MODE
; BH = CURRENT ACTIVE PAGE
;-----------------------------------------
VIDEO_STATE     PROC    NEAR
        MOV     AH,BYTE PTR CRT_COLS ; GET NUMBER OF COLUMNS
        MOV     AL,CRT_MODE     ; CURRENT MODE
        MOV     BH,ACTIVE_PAGE  ; GET CURRENT ACTIVE PAGE
        POP     DI              ; RECOVER REGISTERS
        POP     SI
        POP     CX              ; DISCARD SAVED BX
        JMP     C22             ; RETURN TO CALLER
VIDEO_STATE     ENDP
;-----------------------------------------
; POSITION
; THIS SERVICE ROUTINE CALCULATES THE REGEN BUFFER ADDRESS
; OF A CHARACTER IN THE ALPHA MODE
; INPUT
;        AX = ROW, COLUMN POSITION
; OUTPUT
;        AX = OFFSET OF CHAR POSITION IN REGEN BUFFER
;-----------------------------------------
POSITION        PROC    NEAR
        PUSH    BX              ; SAVE REGISTER
        MOV     BX,AX
        MOV     AL,AH           ; ROWS TO AL
        MUL     BYTE PTR CRT_COLS ; DETERMINE BYTES TO ROW
        XOR     BH,BH
        ADD     AX,BX           ; ADD IN COLUMN VALUE
        SAL     AX,1            ; * 2 FOR ATTRIBUTE BYTES
        POP     BX
        RET
POSITION        ENDP
;-----------------------------------------
; SCROLL UP
; THIS ROUTINE MOVES A BLOCK OF CHARACTERS UP
; ON THE SCREEN
; INPUT
;        (AH) = CURRENT CRT MODE
;        (AL) = NUMBER OF ROWS TO SCROLL
;        (CX) = ROW/COLUMN OF UPPER LEFT CORNER
;        (DX) = ROW/COLUMN OF LOWER RIGHT CORNER
;        (BH) = ATTRIBUTE TO BE USED ON BLANKED LINE
;        (DS) = DATA SEGMENT
;        (ES) = REGEN BUFFER SEGMENT
; OUTPUT
;        NONE -- THE REGEN BUFFER IS MODIFIED
;-----------------------------------------
ASSUME  CS:CODE,DS:DATA,ES:DATA
SCROLL_UP       PROC    NEAR
        MOV     BL,AL           ; SAVE LINE COUNT IN BL
        CMP     AH,4            ; TEST FOR GRAPHICS MODE
        JC      C39             ; HANDLE SEPARATELY
        JMP     GRAPHICS_UP

C39:                            ; UP_CONTINUE
        PUSH    BX              ; SAVE FILL ATTRIBUTE IN BH
        MOV     AX,CX           ; UPPER LEFT POSITION
        CALL    SCROLL_POSITION ; DO SETUP FOR SCROLL
        JZ      C44             ; BLANK_FIELD
        ADD     SI,AX           ; FROM ADDRESS
        MOV     AH,DH           ; # ROWS IN BLOCK
        SUB     AH,BL           ; # ROWS TO BE MOVED
C40:    CALL    C45             ; MOVE ONE ROW
        ADD     SI,BP
        ADD     DI,BP           ; POINT TO NEXT LINE IN BLOCK
        DEC     AH              ; COUNT OF LINES TO MOVE
        JNZ     C40             ; ROW_LOOP
C41:    POP     AX              ; RECOVER ATTRIBUTE IN AH
        MOV     AL,' '          ; FILL WITH BLANKS
C42:    CALL    C46             ; CLEAR THE ROW
        ADD     DI,BP           ; POINT TO NEXT LINE
        DEC     BL              ; COUNTER OF LINES TO SCROLL
        JNZ     C42             ; CLEAR_LOOP
C43:    JMP     VIDEO_RETURN
C44:    MOV     BL,DH           ; GET ROW COUNT
        JMP     C41             ; GO CLEAR THAT AREA
SCROLL_UP       ENDP
;----- HANDLE COMMON SCROLL SET UP HERE
SCROLL_POSITION PROC    NEAR
        CALL    POSITION        ; CONVERT TO REGEN POINTER
        ADD     AX,CRT_START    ; OFFSET OF ACTIVE PAGE
        MOV     DI,AX           ; TO ADDRESS FOR SCROLL
        MOV     SI,AX           ; FROM ADDRESS FOR SCROLL
        SUB     DX,CX           ; DX = #ROWS, #COLS IN BLOCK
        INC     DH
        INC     DL              ; INCREMENT FOR 0 ORIGIN
        XOR     CH,CH           ; SET HIGH BYTE OF COUNT TO ZERO
        MOV     BP,CRT_COLS     ; GET NUMBER OF COLUMNS IN DISPLAY
        ADD     BP,BP           ; TIMES 2 FOR ATTRIBUTE BYTE
        MOV     AL,BL           ; GET LINE COUNT
        MUL     BYTE PTR CRT_COLS ; DETERMINE OFFSET TO FROM
        ADD     AX,AX           ; ADDRESS
        PUSH    ES              ; ESTABLISH ADDRESSING TO REGEN
                                 ; BUFFER
                                 ; FOR BOTH POINTERS
        POP     DS
        OR      BL,BL           ; 0 SCROLL MEANS BLANK FIELD
        RET                     ; RETURN WITH FLAGS SET
SCROLL_POSITION ENDP
;------ MOVE_ROW
C45     PROC    NEAR
        MOV     CL,DL           ; GET # OF COLS TO MOVE
        PUSH    SI
        PUSH    DI              ; SAVE START ADDRESS
        REP     MOVSW           ; MOVE THAT LINE ON SCREEN
        POP     DI
        POP     SI              ; RECOVER ADDRESSES
        RET
C45     ENDP
;------ CLEAR_ROW
C46     PROC    NEAR
        MOV     CL,DL           ; GET # COLUMNS TO CLEAR
        PUSH    DI
        REP     STOSW           ; STORE THE FILL CHARACTER
        POP     DI
        RET
C46     ENDP
;----------------------------------------
; SCROLL_DOWN
; THIS ROUTINE MOVES THE CHARACTERS WITHIN A DEFINED
; BLOCK DOWN ON THE SCREEN, FILLING THE TOP LINES
; WITH A DEFINED CHARACTER
;
; INPUT
;
;   (AH) = CURRENT CRT MODE
;   (AL) = NUMBER OF LINES TO SCROLL
;   (CX) = UPPER LEFT CORNER OF REGION
;   (DX) = LOWER RIGHT CORNER OF REGION
;   (BH) = FILL CHARACTER
;   (DS) = DATA SEGMENT
;   (ES) = REGEN SEGMENT
;
; OUTPUT
;
;   NONE -- SCREEN IS SCROLLED
;----------------------------------------
SCROLL_DOWN     PROC    NEAR
        STD                     ; DIRECTION FOR SCROLL DOWN
        MOV     BL,AL           ; LINE COUNT TO BL
        CMP     AH,4            ; TEST FOR GRAPHICS
        JC      C47
        JMP     GRAPHICS_DOWN
C47:    PUSH    BX              ; SAVE ATTRIBUTE IN BH
        MOV     AX,DX           ; LOWER RIGHT CORNER
        CALL    SCROLL_POSITION ; GET REGEN LOCATION
        JZ      C51
        SUB     SI,AX           ; SI IS FROM ADDRESS
        MOV     AH,DH           ; GET TOTAL # ROWS
        SUB     AH,BL           ; COUNT TO MOVE IN SCROLL
C48:    CALL    C45             ; MOVE ONE ROW
        SUB     SI,BP
        SUB     DI,BP
        DEC     AH
        JNZ     C48
C49:    POP     AX              ; RECOVER ATTRIBUTE IN AH
        MOV     AL,' '
C50:    CALL    C46             ; CLEAR ONE ROW
        SUB     DI,BP           ; GO TO NEXT ROW
        DEC     BL
        JNZ     C50
        JMP     C43             ; SCROLL_END
C51:    MOV     BL,DH
        JMP     C49
SCROLL_DOWN     ENDP

;----------------------------------------------------
; MODE_ALIVE
;       THIS ROUTINE READS 256 LOCATIONS IN MEMORY AS EVERY OTHER
;       LOCATION IN 512 LOCATIONS.  THIS IS TO INSURE THE DATA
;       INTEGRITY OF MEMORY DURING MODE CHANGES.
;----------------------------------------------------
MODE_ALIVE      PROC    NEAR
        PUSH    AX              ;SAVE USED REGS
        PUSH    SI
        PUSH    CX
        XOR     SI,SI
        MOV     CX,256
C52:    LODSB
        INC     SI
        LOOP    C52
        POP     CX
        POP     SI
        POP     AX
        RET
MODE_ALIVE      ENDP

;----------------------------------------------------
; SET_PALLETTE
;       THIS ROUTINE WRITES THE PALETTE REGISTERS
;
;       INPUT
;
;               (AL) = 0        SET PALETTE REG
;                       (BH) =  VALUE TO SET
;                       (BL) =  PALETTE REG TO SET
;
;               (AL) = 1        SET BORDER COLOR REG
;                       (BH) =  VALUE TO SET
;
;               (AL) = 2        SET ALL PALETTE REGS AND BORDER REG
;       NOTE: REGISTERS ARE WRITE ONLY.
;----------------------------------------------------
SET_PALLETTE    PROC    NEAR
        PUSH    AX
        MOV     SI,SP
        MOV     AX,SS:[SI+12]  ; GET SEG FROM STACK
        MOV     ES,AX
        MOV     SI,DX           ; OFFSET IN SI
        MOV     DX,VGA_CTL      ; SET VGA CONTROL PORT
C53:    IN      AL,DX           ; GET VGA STATUS
        AND     AL,08H          ; IN VERTICAL RETRACE?
        JNZ     C53             ; YES, WAIT FOR IT TO GO AWAY
C54:    IN      AL,DX           ; GET VGA STATUS
        AND     AL,08H          ; IN VERTICAL RETRACE?
        JZ      C54             ; NO, WAIT FOR IT
        POP     AX
        OR      AL,AL           ; SET PALETTE REG?
        JZ      C55             ; YES, GO DO IT
        CMP     AL,2            ; SET ALL REGS?
        JE      C57
        CMP     AL,1            ; SET BORDER COLOR REG?
        JNE     C59             ; NO, DON'T DO ANYTHING
        MOV     AL,2            ; SET BORDER COLOR REG NUMBER
        JMP     SHORT C56
C55:    MOV     AL,BL           ; GET DESIRED REG NUMBER IN AL
        AND     AL,0FH          ; STRIP UNUSED BITS
        OR      AL,10H          ; MAKE INTO REAL REG NUMBER
C56:    OUT     DX,AL           ; SELECT REG
        MOV     AL,BH           ; GET DATA IN AL
        OUT     DX,AL           ; SET NEW DATA
        XOR     AL,AL           ; SET REG 0 SO DISPLAY WORKS AGAIN
        OUT     DX,AL
        JMP     SHORT C59
C57:    MOV     AH,10H          ; AH IS REG COUNTER
C58:    MOV     AL,AH           ; REG ADDRESS IN AL
        OUT     DX,AL           ; SELECT IT
        MOV     AL,BYTE PTR ES:[SI] ;GET DATA
        OUT     DX,AL           ; PUT IN VGA REG
        INC     SI              ; NEXT DATA BYTE
        INC     AH              ; NEXT REG
        CMP     AH,20H          ; LAST PALETTE REG?
        JB      C58             ; NO, DO NEXT ONE
        MOV     AL,2            ; SET BORDER REG
        OUT     DX,AL           ; SELECT IT
        MOV     AL,BYTE PTR ES:[SI] ; GET DATA
        OUT     DX,AL           ; PUT IN VGA REG
C59:    JMP     VIDEO_RETURN    ; ALL DONE
SET_PALLETTE   ENDP
MFG_UP  PROC    NEAR
        PUSH    AX
        PUSH    DS
ASSUME  DS:XXDATA
        MOV     AX,XXDATA
        MOV     DS,AX
        MOV     AL,MFG_TST      ; GET MFG CHECKPOINT
        OUT     10H,AL          ; OUTPUT IT TO TESTER
        DEC     AL              ; DROP IT BY 1 FOR THE NEXT TEST
        MOV     MFG_TST,AL
ASSUME  DS:ABS0
        POP     DS
        POP     AX
        RET
MFG_UP  ENDP
ASSUME  CS:CODE,DS:DATA
        ORG     0E6F2H
        JMP     NEAR PTR BOOT_STRAP
;--------------------------------------------------------------------
; SUBROUTINE TO SET UP CONDITIONS FOR THE TESTING OF 8250 AND
; 8259 INTERRUPTS.  ENABLES MASKABLE EXTERNAL INTERRUPTS,
; CLEARS THE 8259 INTR RECEIVED FLAG BIT, AND ENABLES THE
; DEVICE'S 8259 INTR (WHICHEVER IS BEING TESTED).
; IT EXPECTS TO BE PASSED:
;       (DS) = ADDRESS OF SEGMENT WHERE INTR_FLAG IS DEFINED
;       (DI) = OFFSET OF THE INTERRUPT BIT MASK
; UPON RETURN:
;       INTR_FLAG BIT FOR THE DEVICE = 0
; NO REGISTERS ARE ALTERED.
;--------------------------------------------------------------------
SUI     PROC    NEAR
        PUSH    AX
        STI                     ; ENABLE MASKABLE EXTERNAL
                                ;       INTERRUPTS
        MOV     AH,CS:[DI]      ; GET INTERRUPT BIT MASK
        AND     INTR_FLAG,AH    ; CLEAR 8259 INTERRUPT REC'D FLAG
                                ;       BIT
        IN      AL,INTA01       ; CURRENT INTERRUPTS
        AND     AL,AH           ; ENABLE THIS INTERRUPT, TOO
        OUT     INTA01,AL       ; WRITE TO 8259 (INTERRUPT
                                ;       CONTROLLER)
        POP     AX
        RET
SUI     ENDP
;--------------------------------------------------------------------
; SUBROUTINE WHICH CHECKS IF A 8259 INTERRUPT IS GENERATED BY THE
; 8250 INTERRUPT.
; IT EXPECTS TO BE PASSED:
;       (DI) = OFFSET OF INTERRUPT BIT MASK
;       (DS) = ADDRESS OF SEGMENT WHERE INTR_FLAG IS DEFINED.
; IT RETURNS:
;       (CF) = 1 IF NO INTERRUPT IS GENERATED
;             0 IF THE INTERRUPT OCCURRED
;       (AL) = COMPLEMENT OF THE INTERRUPT MASK
; NO OTHER REGISTERS ARE ALTERED.
;--------------------------------------------------------------------
C5059   PROC    NEAR
        PUSH    CX
        SUB     CX,CX           ; SET PROGRAM LOOP COUNT
        MOV     AL,CS:[DI]      ; GET INTERRUPT MASK
        XOR     AL,0FFH         ; COMPLEMENT MASK SO ONLY THE INTR
                                ;       TEST BIT IS ON
AT25:   TEST    INTR_FLAG,AL    ; 8259 INTERRUPT OCCUR?
        JNE     AT27            ; YES - CONTINUE
        LOOP    AT25            ; WAIT SOME MORE
        STC                     ; TIME'S UP - FAILED
AT27:   POP     CX
        RET
C5059   ENDP
;--------------------------------------------------------------------
; SUBROUTINE TO WAIT FOR ALL ENABLED 8250 INTERRUPTS TO CLEAR (SO
;       NO INTRS WILL BE PENDING).  EACH INTERRUPT COULD TAKE UP TO
;       1 MILLISECOND TO CLEAR.  THE INTERRUPT IDENTIFICATION
;       REGISTER WILL BE CHECKED UNTIL THE INTERRUPT(S) IS CLEARED
;       OR A TIMEOUT OCCURS.
; EXPECTS TO BE PASSED:
;       (DX) = ADDRESS OF THE INTERRUPT ID REGISTER
;
; RETURNS:
;       (AL) = CONTENTS OF THE INTR ID REGISTER
;       (CF) = 1  IF INTERRUPTS ARE STILL PENDING
;             0  IF NO INTERRUPTS ARE PENDING (ALL CLEAR)
; NO OTHER REGISTERS ARE ALTERED.
;--------------------------------------------------------------------
W8250C  PROC    NEAR
        PUSH    CX
        SUB     CX,CX
AT28:   IN      AL,DX           ; READ INTR ID REG
        CMP     AL,1            ; INTERRUPTS STILL PENDING?
        JE      AT29            ; NO - GOOD FINISH
        LOOP    AT28            ; KEEP TRYING
        STC                     ; TIME'S UP - ERROR
        JMP     SHORT AT30
AT29:   CLC
AT30:   POP     CX
        RET
W8250C  ENDP
;-----INT 14--------------------------------------------------
;RS232_IO
;
;      THIS ROUTINE PROVIDES BYTE STREAM I/O TO THE COMMUNICATIONS
;      PORT ACCORDING TO THE PARAMETERS:
;            (AH)=0   INITIALIZE THE COMMUNICATIONS PORT
;                     (AL) HAS PARMS FOR INITIALIZATION
;
;
;---7-------6-------5-------4-------3-------2-------1-------0----
;-------- BAUD RATE ---:----PARITY----:--STOPBIT-::--WORD LENGTH--
;
; 000 - 110                  X0 - NONE           0 - 1       10 - 7 BITS
; 001 - 150                  01 - ODD            1 - 2       11 - 8 BITS
; 010 - 300                  11 - EVEN
; 011 - 600
; 100 - 1200
; 101 - 2400
; 110 - 4800
; 111 - 4800
;
;
;      ON RETURN, THE RS232 INTERRUPTS ARE DISABLED AND
;      CONDITIONS ARE SET AS IN CALL TO COMMO
;      STATUS (AH=3)
;
; (AH)=1   SEND THE CHARACTER IN (AL) OVER THE COMMO LINE
;          (AL) REGISTER IS PRESERVED
;          ON EXIT, BIT 7 OF AH IS SET IF THE ROUTINE WAS
;          UNABLE TO TRANSMIT THE BYTE OF DATA OVER
;          THE LINE. IF BIT 7 OF AH IS NOT SET, THE
;          REMAINDER OF AH IS SET AS IN A STATUS
;          REQUEST, REFLECTING THE CURRENT STATUS OF
;          THE LINE.
;
; (AH)=2   RECEIVE A CHARACTER IN (AL) FROM COMMO LINE BEFORE
;          RETURNING TO CALLER
;          ON EXIT, AH HAS THE CURRENT LINE STATUS, AS SET BY
;          THE STATUS ROUTINE, EXCEPT THAT THE ONLY
;          BITS LEFT ON, ARE THE ERROR BITS
;          (7,4,3,2,1). IN THIS CASE, THE TIME OUT BIT
;          INDICATES DATA SET READY WAS NOT RECEIVED.
;          THUS, AH IS NON ZERO ONLY WHEN AN ERROR
;          OCCURRED.(NOTE: IF THE TIME-OUT BIT IS SET,
;          OTHER BITS IN AH MAY NOT BE RELIABLE.)
;
; (AH)=3   RETURN THE COMMO PORT STATUS IN (AX)
;          AH CONTAINS THE LINE CONTROL STATUS
;               BIT 7 = TIME OUT
;               BIT 6 = TRANS SHIFT REGISTER EMPTY
;               BIT 5 = TRAN HOLDING REGISTER EMPTY
;               BIT 4 = BREAK DETECT
;               BIT 3 = FRAMING ERROR
;               BIT 2 = PARITY ERROR
;               BIT 1 = OVERRUN ERROR
;               BIT 0 = DATA READY
;          AL CONTAINS THE MODEM STATUS
;               BIT 7 = RECEIVED LINE SIGNAL DETECT
;               BIT 6 = RING INDICATOR
;               BIT 5 = DATA SET READY
;               BIT 4 = CLEAR TO SEND
;               BIT 3 = DELTA RECEIVE LINE SIGNAL DETECT
;               BIT 2 = TRAILING EDGE RING DETECTOR
;               BIT 1 = DELTA DATA SET READY
;               BIT 0 = DELTA CLEAR TO SEND
;          (DX) = PARAMETER INDICATING WHICH RS232 CARD (0,1 ALLOWED)
; DATA AREA RS232_BASE CONTAINS THE BASE ADDRESS OF THE 8250 ON THE
;      CARD. LOCATION 400H CONTAINS UP TO 4 RS232 ADDRESSES POSSIBLE
; DATA AREA RS232_TIM_OUT (BYTE) CONTAINS OUTER LOOP COUNT
;      VALUE FOR TIMEOUT (DEFAULT=1)
;OUTPUT
;      AX          MODIFIED ACCORDING TO PARMS OF CALL
;      ALL OTHERS UNCHANGED
;-------------------------------------------------------
ASSUME  CS:CODE,DS:DATA
        ORG     0E729H
A1              LABEL   WORD
       DW      1017            ; 110 BAUD      ; TABLE OF INIT VALUE
       DW      746             ; 150
       DW      373             ; 300
       DW      186             ; 600
       DW      93              ; 1200
       DW      47              ; 2400
       DW      23              ; 4800
       DW      23              ; 4800
RS232_IO        PROC    FAR
;------ VECTOR TO APPROPRIATE ROUTINE
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE SEGMENT
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    CX
        PUSH    BX
        MOV     SI,DX           ; RS232 VALUE TO SI
        MOV     DI,DX           ; AND TO DI (FOR TIMEOUTS)
        SHL     SI,1            ; WORD OFFSET
        CALL    DDS             ; POINT TO BIOS DATA SEGMENT
        MOV     DX,RS232_BASE[SI] ; GET BASE ADDRESS
        OR      DX,DX           ; TEST FOR 0 BASE ADDRESS
        JZ      A3              ; RETURN
        OR      AH,AH           ; TEST FOR (AH)=0
        JZ      A4              ; COMMUN INIT
        DEC     AH              ; TEST FOR (AH)=1
        JZ      A5              ; SEND AL
        DEC     AH              ; TEST FOR (AH)=2
        JZ      A12             ; RECEIVE INTO AL
        DEC     AH              ; TEST FOR (AH)=3
        JNZ     A3
        JMP     A18             ; COMMUNICATION STATUS
A3:                             ; RETURN FROM RS232
        POP     BX
        POP     CX
        POP     DI
        POP     SI
        POP     DX
        POP     DS
        IRET                    ; RETURN TO CALLER, NO ACTION

A4:     MOV     AH,AL           ; SAVE INIT PARMS IN AH
        ADD     DX,3            ; POINT TO 8250 CONTROL REGISTER
        MOV     AL,80H
        OUT     DX,AL           ; SET DLAB=1
;------ DETERMINE BAUD RATE DIVISOR
        MOV     DL,AH           ; GET PARMS TO DL
        MOV     CL,4
        ROL     DL,CL
        AND     DX,0EH          ; ISOLATE THEM
        MOV     DI,OFFSET A1    ; BASE OF TABLE
        ADD     DI,DX           ; PUT INTO INDEX REGISTER
        MOV     DX,RS232_BASE[SI] ; POINT TO HIGH ORDER OF DIVISOR
        INC     DX
        MOV     AL,CS:[DI]+1    ; GET HIGH ORDER OF DIVISOR
        OUT     DX,AL           ; SET MS OF DIV TO 0
        DEC     DX
        MOV     AL,CS:[DI]      ; GET LOW ORDER OF DIVISOR
        OUT     DX,AL           ; SET LOW OF DIVISOR
        ADD     DX,3
        MOV     AL,AH           ; GET PARMS BACK
        AND     AL,01FH         ; STRIP OFF THE BAUD BITS
        OUT     DX,AL           ; LINE CONTROL TO 8 BITS
        DEC     DX
        DEC     DX
        MOV     AL,0            ; INTERRUPT ENABLES ALL OFF
        OUT     DX,AL
        JMP     SHORT A18       ; COM_STATUS
;------ SEND CHARACTER IN (AL) OVER COMMO LINE
A5:
        PUSH    AX              ; SAVE CHAR TO SEND
        ADD     DX,4            ; MODEM CONTROL REGISTER
        MOV     AL,3            ; DTR AND RTS
        OUT     DX,AL
        INC     DX              ; MODEM STATUS REGISTER
        INC     DX
        MOV     BH,30H          ; DATA SET READY & CLEAR TO SEND
        CALL    WAIT_FOR_STATUS ; ARE BOTH TRUE?
        JE      A9              ; YES, READY TO TRANSMIT CHAR
A7:     POP     CX
        MOV     AL,CL           ; RELOAD DATA BYTE
A8:     OR      AH,80H          ; INDICATE TIME OUT
        JMP     A3              ; RETURN
A9:                             ; CLEAR_TO_SEND
        DEC     DX              ; LINE STATUS REGISTER
        MOV     BH,20H          ; IS TRANSMITTER READY
        CALL    WAIT_FOR_STATUS ; TEST FOR TRANSMITTER READY
        JNZ     A7              ; RETURN WITH TIME OUT SET
        SUB     DX,5            ; DATA PORT
        POP     CX              ; RECOVER IN CX TEMPORARILY
        MOV     AL,CL           ; MOVE CHAR TO AL FOR OUT, STATUS
        OUT     DX,AL           ; OUTPUT CHARACTER
        JMP     A3              ; RETURN
;------ RECEIVE CHARACTER FROM COMMO LINE
A12:    ADD     DX,4            ; MODEM CONTROL REGISTER
        MOV     AL,1            ; DATA TERMINAL READY
        OUT     DX,AL
        INC     DX              ; MODEM STATUS REGISTER
        INC     DX
        MOV     BH,20H          ; DATA SET READY
        CALL    WAIT_FOR_STATUS ; TEST FOR DSR
        JNZ     A8              ; RETURN WITH ERROR
        DEC     DX              ; LINE STATUS REGISTER
A16:    IN      AL,DX
        TEST    AL,1            ; RECEIVE BUFFER FULL
        JNZ     A17             ; TEST FOR REC. BUFF. FULL
        TEST    BIOS_BREAK,80H  ; TEST FOR BREAK KEY
        JZ      A16             ; LOOP IF NO BREAK KEY
        JMP     A8              ; SET TIME OUT ERROR
A17:    AND     AL,00011110B    ; TEST FOR ERROR CONDITIONS ON RECV
                                ; CHAR
        MOV     AH,AL
        MOV     DX,RS232_BASE[SI] ; DATA PORT
        IN      AL,DX           ; GET CHARACTER FROM LINE
        JMP     A3              ; RETURN
;------ COMMO PORT STATUS ROUTINE
A18:    MOV     DX,RS232_BASE[SI]
        ADD     DX,5            ; CONTROL PORT
        IN      AL,DX           ; GET LINE CONTROL STATUS
        MOV     AH,AL           ; PUT IN AH FOR RETURN
        INC     DX              ; POINT TO MODEM STATUS REGISTER
        IN      AL,DX           ; GET MODEM CONTROL STATUS
        JMP     A3              ; RETURN

;------------------------------------
; WAIT FOR STATUS ROUTINE
;ENTRY: BH=STATUS BIT(S) TO LOOK FOR,
;       DX=ADDR. OF STATUS REG
;EXIT:  ZERO FLAG ON = STATUS FOUND
;       ZERO FLAG OFF = TIMEOUT.
;       AH=LAST STATUS READ
;------------------------------------
WAIT_FOR_STATUS PROC    NEAR
        MOV     BL,RS232_TIM_OUT[DI] ;LOAD OUTER LOOP COUNT
WFS0:   SUB     CX,CX
WFS1:   IN      AL,DX           ;GET STATUS
        MOV     AH,AL           ;MOVE TO AH
        AND     AL,BH           ;ISOLATE BITS TO TEST
        CMP     AL,BH           ;EXACTLY = TO MASK
        JE      WFS_END         ;RETURN WITH ZERO FLAG ON
        LOOP    WFS1            ;TRY AGAIN
        DEC     BL
        JNZ     WFS0
        OR      BH,BH           ;SET ZERO FLAG OFF
WFS_END:
        RET
WAIT_FOR_STATUS ENDP
RS232_IO        ENDP
;---------------------------------------------------------------
; THIS ROUTINE WILL READ TIMER1.  THE VALUE READ IS RETURNED IN AX.
;---------------------------------------------------------------
READ_TIME       PROC    NEAR
        MOV     AL,40H          ;LATCH TIMER1
        OUT     TIM_CTL,AL
        PUSH    AX              ;WAIT FOR 8253 TO INIT ITSELF
        POP     AX
        IN      AL,TIMER+1      ;READ LSB
        MOV     AH,AL           ;SAVE IT IN HIGH BYTE
        PUSH    AX              ;WAIT FOR 8253 TO INIT ITSELF
        POP     AX
        IN      AL,TIMER+1      ;READ MSB
        XCHG    AL,AH           ;PUT BYTES IN PROPER ORDER
        RET
READ_TIME       ENDP
        ORG     0E82EH
        JMP     NEAR PTR KEYBOARD_IO
;---------------------------------------------------------------
;ASYNCHRONOUS COMMUNICATIONS ADAPTER POWER ON DIAGNOSTIC TEST
;DESCRIPTION:
; THIS SUBROUTINE PERFORMS A THOROUGH CHECK OUT OF AN INS8250 LSI
; CHIP.
; THE TEST INCLUDES:
; 1) INITIALIZATION OF THE CHIP TO ASSUME ITS MASTER RESET STATE.
; 2) READING REGISTERS FOR KNOWN PERMANENT ZERO BITS.
; 3) TESTING THE INS8250 INTERRUPT SYSTEM AND THAT THE 8250
;    INTERRUPTS TRIGGER AN 8259 (INTERRUPT CONTROLLER) INTERRUPT.
; 4) PERFORMING THE LOOP BACK TEST:
;    A) TESTING WHAT WAS WRITTEN/READ AND THAT THE TRANSMITTER
;       HOLDING REG EMPTY BIT AND THE RECEIVER INTERRUPT WORK
;       PROPERLY.
;    B) TESTING IF CERTAIN BITS OF THE DATA SET CONTROL REGISTER
;       ARE 'LOOPED BACK' TO THOSE IN THE DATA SET STATUS
;       REGISTER.
;    C) TESTING THAT THE TRANSMITTER IS IDLE WHEN TRANSMISSION
;       TEST IS FINISHED.
; THIS SUBROUTINE EXPECTS TO HAVE THE FOLLOWING PARAMETER PASSED:
; (DX)= ADDRESS OF THE INS8250 CARD TO TEST.
; NOTE: THE ASSUMPTION HAS BEEN MADE THAT THE MODEM ADAPTER IS
;       ---- LOCATED AT 03F8H; THE SERIAL PRINTER AT 02F8H.
; IT RETURNS:
; (CF) = 1 IF ANY PORTION OF THE TEST FAILED
;     = 0 IF TEST PASSED
; (BX) = FAILURE KEY FOR ERROR MESSAGE (ONLY VALID IF TEST FAILED)
; (BH) = 23H  SERIAL PRINTER ADAPTER TEST FAILURE
;       = 24H  MODEM ADAPTER TEST FAILURE
; (BL) = 2  PERMANENT ZERO BITS IN INTERRUPT ENABLE REGISTER
;            WERE INCORRECT
;       3  PERMANENT ZERO BITS IN INTERRUPT IDENTIFICATION
;            REGISTER WERE INCORRECT
;       4  PERMANENT ZERO BITS IN DATA SET CONTROL REGISTER
;            WERE INCORRECT
;       5  PERMANENT ZERO BITS IN THE LINE STATUS REGISTER
;            WERE INCORRECT
;       6  RECEIVED DATA AVAILABLE INTERRUPT TEST FAILED
;            (THE INTERRUPT WAS NOT GENERATED)
;      16H RECEIVED DATA AVAILABLE INTERRUPT FAILED TO CLEAR
;       7  RESERVED FOR REPORTING THE TRANSMITTER HOLDING
;            REGISTER EMPTY INTERRUPT TEST FAILED
;            (NOT USED AT THIS TIME BECAUSE OF THE DIFFERENCES
;             BETWEEN THE 8250'S WHICH WILL BE USED.)
;      17H TRANSMITTER HOLDING REG EMPTY INTR FAILED TO CLEAR
;       8-B RECEIVER LINE STATUS INTERRUPT TEST FAILED
;            (THE INTERRUPT WAS NOT GENERATED)
;          8 - OVERRUN ERROR
;          9 - PARITY ERROR
;          A - FRAMING ERROR
;          B - BREAK INTERRUPT ERROR
;     18-1B RECEIVER LINE STATUS INTERRUPT FAILED TO CLEAR
;      C-F MODEM STATUS INTERRUPT TEST FAILED
;            (THE INTERRUPT WAS NOT GENERATED)
;          C - DELTA CLEAR TO SEND ERROR
;          D - DELTA DATA SET READY ERROR
;          E - TRAILING EDGE RING INDICATOR ERROR
;          F - DELTA RECEIVE LINE SIGNAL DETECT ERROR
;       1C-1F  MODEM STATUS INTERRUPT FAILED TO CLEAR
;       10H    AN 8250 INTERRUPT OCCURRED AS EXPECTED, BUT NO
;              8259 (INTR CONTROLLER) INTERRUPT WAS GENERATED
;       11H    DURING THE TRANSMISSION TEST, THE TRANSMITTER
;              HOLDING REGISTER WAS NOT EMPTY WHEN IT SHOULD
;              HAVE BEEN.
;       12H    DURING THE TRANSMISSION TEST, THE RECEIVED DATA
;              AVAILABLE INTERRUPT DIDN'T OCCUR.
;       13H    TRANSMISSION ERROR - THE CHARACTER RECEIVED
;              DURING LOOP MODE WAS NOT THE SAME AS THE ONE
;              TRANSMITTED
;       14H    DURING TRANSMISSION TEST, THE 4 DATA SET CONTROL
;              OUTPUTS WERE NOT THE SAME AS THE 4 DATA SET
;              CONTROL INPUTS.
;       15H    THE TRANSMITTER WAS NOT IDLE AFTER THE TRANS-
;              MISSION TEST COMPLETED.
;
;       ON EXIT:
;              - THE MODEM OR SERIAL PRINTER'S 8259 INTERRUPT (WHICHEVER
;                DEVICE WAS TESTED) IS DISABLED.
;              - THE 8250 IS IN THE MASTER RESET STATE.
;              ONLY THE DS REGISTER IS PRESERVED - ALL OTHERS ARE ALTERED.
;------------------------------------------------------------------
WRAP            EQU     84H         ; LOOP BACK TRANSMISSION TEST
; INTERRUPT VECTOR ADDRESS
; (IN DIAGNOSTICS)

ASSUME  CS:CODE,DS:DATA
UART    PROC    NEAR
        PUSH    DS
        IN      AL,INTA01       ; CURRENT ENABLED INTERRUPTS
        PUSH    AX              ; SAVE FOR EXIT
        OR      AL,00000001B    ; DISABLE TIMER INTR DURING THIS
                                ; TEST
        OUT     INTA01,AL
        PUSHF                   ; SAVE CALLER'S FLAGS (SAVE INTR
                                ; FLAG)
        PUSH    DX              ; SAVE BASE ADDRESS OF ADAPTER CARD
        CALL    DDS             ; SET UP 'DATA' AS DATA SEGMENT
                                ; ADDRESS
;---------------------------------------------------------------
;       INITIALIZE PORTS FOR MASTER RESET STATES AND TEST PERMANENT
;       ZERO DATA BITS FOR CERTAIN PORTS.
;---------------------------------------------------------------
        CALL    I8250
        JNC     AT1             ; ALL OK
        JMP     AT14            ; A PORT'S ZERO BITS WERE NOT ZERO!
;---------------------------------------------------------------
;       INS8250 INTERRUPT SYSTEM TEST
;       ONLY THE INTERRUPT BEING TESTED WILL BE ENABLED.
;---------------------------------------------------------------
;       SET DI AND SI FOR CALLS TO 'SUI'
AT1:    MOV     DI,OFFSET IMASKS ; BASE ADDRESS OF INTERRUPT MASKS
        XOR     SI,SI           ; MODEM INDEX
        CMP     DH,2            ; OR SERIAL?
        JNE     AT2             ; NO - IT'S MODEM
        INC     SI              ; IT'S SERIAL PRINTER
        INC     DI              ; SERIAL PRINTER 8259 MASK ADDRESS
;       RECEIVED DATA AVAILABLE INTERRUPT TEST
AT2:    CALL    SUI             ; SET UP FOR INTERRUPTS
        INC     BL              ; ERROR REPORTER (INIT. IN I8250)
        INC     DX              ; POINT TO INTERRUPT ENABLE
                                ; REGISTER
        MOV     AL,1            ; ENABLE RECEIVED DATA AVAILABLE
                                ; INTR
        OUT     DX,AL
        PUSH    BX              ; SAVE ERROR REPORTER
        ADD     DX,4            ; POINT TO LINE STATUS REGISTER
        MOV     AH,1            ; SET RECEIVER DATA READY BIT
        MOV     BX,0400H        ; INTR TO CHECK, INTR IDENTIFIER
        MOV     CX,3            ; INTERRUPT ID REG 'INDEX'
        CALL    ICT             ; PERFORM TEST FOR INTERRUPT
        POP     BX              ; RESTORE ERROR INDICATOR
        CMP     AL,0FFH         ; INTERRUPT ERROR OCCUR?
        JE      AT4             ; YES
        CALL    C5059           ; GENERATE 8259 INTERRUPT?
        JC      AT5             ; NO
        DEC     DX
        DEC     DX              ; RESET INTR BY READING RECR BUFR
        IN      AL,DX           ; DON'T CARE ABOUT THE CONTENTS!
        INC     DX
        INC     DX              ; INTR ID REG
        CALL    W8250C          ; WAIT FOR INTR TO CLEAR
        JNC     AT3             ; OK
        JMP     AT13            ; DIDN'T CLEAR
;---------------------------------------------------------------
;       TRANSMITTER HOLDING REGISTER EMPTY INTERRUPT TEST
;       THIS TEST HAS BEEN MODIFIED BECAUSE THE DIFFERENT 8250'S
;       THAT MAY BE USED IN PRODUCING THIS PRODUCT DO NOT FUNCTION
;       THE SAME DURING THE STANDARD TEST OF THIS INTERRUPT
;       (STANDARD BEING THE SAME METHOD FOR TESTING THE OTHER
;       POSSIBLE 8250 INTERRUPTS).  IT IS STILL VALID FOR TESTING
;       IF AN 8259 INTERRUPT IS GENERATED IN RESPONSE TO THE 8250
;       INTERRUPT AND THAT THE 8250 INTERRUPT CLEARS AS IT SHOULD.
;
;       IF THE TRANSMITTER HOLDING REGISTER EMPTY INTERRUPT IS NOT
;       GENERATED WHEN THAT INTERRUPT IS ENABLED, IT IS NOT TREATED
;       AS AN ERROR.  HOWEVER, IF THE INTERRUPT IS GENERATED, IT
;       MUST GENERATE AN 8259 INTERRUPT AND CLEAR PROPERLY TO PASS
;       THIS TEST.
;---------------------------------------------------------------
AT3:    CALL    SUI             ; SET UP FOR INTERRUPTS
        INC     BL              ; BUMP ERROR REPORTER
        DEC     DX              ; POINT TO INTERRUPT ENABLE
                                ; REGISTER
        MOV     AL,2            ; ENABLE XMITTER HOLDING REG EMPTY
                                ; INTR

        OUT     DX,AL
        JMP     $+2             ; I/O DELAY
        INC     DX              ; INTR IDENTIFICATION REG
        SUB     CX,CX
AT31:   IN      AL,DX           ; READ IT
        CMP     AL,2            ; XMITTER HOLDING REG EMPTY INTR?
        JE      AT32            ; YES
        LOOP    AT31
        JMP     SHORT AT6       ; THE INTR DIDN'T OCCUR - TRY NEXT
                                ; TEST

AT32:                           ; THE INTR DID OCCUR
        CALL    C5059           ; GENERATE 8259 INTERRUPT?
        JC      AT5             ; NO
        CALL    W8250C          ; WAIT FOR THE INTERRUPT TO CLEAR
                                ; (IT SHOULD ALREADY BE CLEAR
                                ; BECAUSE 'ICT' READ THE INTR ID
                                ; REG)
        JNC     AT6             ; IT CLEARED
        JMP     AT13            ; ERROR
AT4:    JMP     SHORT AT11      ; AVOID OUT OF RANGE JUMPS
AT5:    JMP     SHORT AT10

;-----------------------------------
; RECEIVER LINE STATUS INTERRUPT TEST
; THERE ARE 4 BITS WHICH COULD GENERATE THIS INTERRUPT.
; EACH ONE IS TESTED INDIVIDUALLY.
;   WHEN:  AH      TESTING
;           --      -------
;           2       OVERRUN
;           4       PARITY
;           8       FRAMING
;           10H     BREAK INTR
;-----------------------------------

AT6:    DEC     DX              ; POINT TO INTERRUPT ENABLE
                                ; REGISTER
        MOV     AL,4            ; ENABLE RECEIVER LINE STATUS INTR
        OUT     DX,AL
        ADD     DX,4            ; POINT TO LINE STATUS REGISTER
        MOV     CX,3            ; INTR ID REG 'INDEX'
        MOV     BP,4            ; LOOP COUNTER
        MOV     AH,2            ; INITIAL BIT TO BE TESTED
AT7:    CALL    SUI             ; SET UP FOR INTERRUPTS
        INC     BL              ; BUMP ERROR REPORTER
        PUSH    BX              ; SAVE IT
        MOV     BX,0601H        ; INTR TO CHECK, INTR IDENTIFIER
        CALL    ICT             ; PERFORM TEST FOR INTERRUPT
        POP     BX
        AND     AL,00011110B    ; MASK OUT BITS THAT DON'T MATTER
        CMP     AL,AH           ; TEST BIT ON?
        JNE     AT11            ; NO
        CALL    C5059           ; GENERATE 8259 INTERRUPT?
        JC      AT10            ; NO
        SUB     DX,3            ; INTR ID REG
        CALL    W8250C          ; WAIT FOR THE INTR TO CLEAR
        JC      AT13            ; IT DIDN'T
        DEC     BP              ; ALL FOUR BITS TESTED?
        JE      AT8             ; YES - GO ON TO NEXT TEST
        SHL     AH,1            ; GET READY FOR NEXT BIT
        ADD     DX,3            ; LINE STATUS REGISTER
        JMP     AT7             ; TEST NEXT BIT

;-----------------------------------
; MODEM STATUS INTERRUPT TEST
; THERE ARE 4 BITS WHICH COULD GENERATE THIS INTERRUPT.
; THEY ARE TESTED INDIVIDUALLY.
;   WHEN:  AH      TESTING
;           --      -------
;           1       DELTA CLEAR TO SEND
;           2       DELTA DATA SET READY
;           4       TRAILING EDGE RING INDICATOR
;           8       DELTA RECEIVE LINE SIGNAL DETECT
;-----------------------------------

AT8:    ADD     DX,4            ; MODEM STATUS REGISTER
        IN      AL,DX           ; CLEAR DELTA BITS THAT MAY BE ON
                                ; BECAUSE OF DIFFERENCES AMONG
                                ; 8250'S.
        JMP     $+2             ; I/O DELAY
        SUB     DX,5            ; INTERRUPT ENABLE REGISTER
        MOV     AL,8            ; ENABLE MODEM STATUS INTERRUPT
        OUT     DX,AL
        ADD     DX,5            ; POINT TO MODEM STATUS REGISTER
        MOV     CX,4            ; INTR ID REG 'INDEX'
        MOV     BP,4            ; LOOP COUNTER
        MOV     AH,1            ; INITIAL BIT TO BE TESTED
AT9:    CALL    SUI             ; SET UP FOR INTERRUPTS
        INC     BL              ; BUMP ERROR INDICATOR
        PUSH    BX              ; SAVE IT
        MOV     BX,0001H        ; INTR TO CHECK, INTR IDENTIFIER
        CALL    ICT             ; PERFORM TEST FOR INTERRUPT
        POP     BX
        AND     AL,00001111B    ; MASK OUT BITS THAT DON'T MATTER
        CMP     AL,AH           ; TEST BIT ON?
        JNE     AT11            ; NO
        CALL    C5059           ; GENERATE 8259 INTERRUPT?
        JC      AT10            ; NO
        SUB     DX,4            ; INTR ID REG
        CALL    W8250C          ; WAIT FOR INTERRUPT TO CLEAR
        JC      AT13            ; IT DIDN'T
        DEC     BP
        JE      AT12            ; ALL FOUR BITS TESTED - GO ON
        SHL     AH,1            ; GET READY FOR NEXT BIT
        ADD     DX,4            ; MODEM STATUS REGISTER
        JMP     AT9             ; TEST NEXT BIT
;-----------------------------------------------------------
;       POSSIBLE 8259 INTERRUPT CONTROLLER PROBLEM
;-----------------------------------------------------------
AT10:   MOV     BL,10H          ; SET ERROR REPORTER
AT11:   JMP     SHORT AT14
;------------------------------------------------------------
;       SET 9600 BAUD RATE AND DEFINE DATA WORD AS HAVING 8
;       BITS/WORD, 2 STOP BITS, AND ODD PARITY.
;------------------------------------------------------------
AT12:   INC     DX              ; LINE CONTROL REGISTER
        CALL    S8250
;-----------------------------------------------------------
;       SET DATA SET CONTROL WORD TO BE IN LOOP MODE
;-----------------------------------------------------------
        ADD     DX,4
        IN      AL,DX           ; CURRENT STATE
        JMP     $+2             ; I/O DELAY
        OR      AL,00010000B    ; SET BIT 4 OF DATA SET CONTROL REG
        OUT     DX,AL
        JMP     $+2             ; I/O DELAY
        INC     DX
        INC     DX              ; MODEM STATUS REG
        IN      AL,DX           ; CLEAR POSSIBLE MODEM STATUS
                                ; INTERRUPT WHICH COULD BE CAUSED
                                ; BY THE OUTPUT BITS BEING LOOPED
                                ; TO THE INPUT BITS
        JMP     $+2             ; I/O DELAY
        SUB     DX,6            ; RECEIVER BUFFER
        IN      AL,DX           ; DUMMY READ TO CLEAR DATA READY
                                ; BIT IF IT WENT HIGH ON WRITE TO
                                ; MCR
;-----------------------------------------------------------
;       PERFORM THE LOOP BACK TEST
;-----------------------------------------------------------
        INC     DX              ; INTR ENBL REG
        MOV     AL,0            ; SET FOR INTERNAL WRAP TEST
        INT     WRAP            ; DO LOOP BACK TRANSMISSION TEST
        MOV     CL,0            ; ASSUME NO ERRORS
        JNC     AT15            ; WRAP TEST PASSED
AT13:   ADD     BL,10H          ; ERROR INDICATOR
;-----------------------------------------------------------
;       AN ERROR WAS ENCOUNTERED SOMEWHERE DURING THE TEST
;-----------------------------------------------------------
AT14:   MOV     CL,1            ; SET FAIL INDICATOR
;-----------------------------------------------------------
;       HOUSEKEEPING: RE-INITIALIZE THE 8250 PORTS (THE LOOP BIT
;                     WILL BE RESET), DISABLE THIS DEVICE INTERRUPT, SET UP
;                     REGISTER BH IF AN ERROR OCCURRED, AND SET OR RESET THE
;                     CARRY FLAG.
;-----------------------------------------------------------
AT15:   POP     DX              ; GET BASE ADDRESS OF 8250 ADAPTER
        PUSH    BX              ; SAVE ERROR CODE
        CALL    I8250           ; RE-INITIALIZE 8250 PORTS
        POP     BX
        MOV     AH,CS:[DI]      ; GET DEVICE INTERRUPT MASK
        AND     INTR_FLAG,AH    ; CLEAR DEVICE'S INTERRUPT FLAG BIT
        XOR     AH,0FFH         ; FLIP BITS
        IN      AL,INTA01       ; GET CURRENT INTERRUPT PORT
        OR      AL,AH           ; DISABLE THIS DEVICE INTERRUPT
        OUT     INTA01,AL
        POPF                    ; RE-ESTABLISH CALLER'S INTERRUPT
                                ; FLAG
        OR      CL,CL           ; ANY ERRORS?
        JE      AT17            ; NO
        MOV     BH,24H          ; ASSUME MODEM ERROR
        CMP     DH,2            ; OR IS IT SERIAL?
        JNE     AT16            ; IT'S MODEM
        MOV     BH,23H          ; IT'S SERIAL PRINTER
AT16:   STC                     ; SET CARRY FLAG TO INDICATE ERROR
        JMP     SHORT AT18
AT17:   CLC                     ; RESET CARRY FLAG - NO ERRORS
AT18:   POP     AX              ; RESTORE ENTRY ENABLED INTERRUPTS
        OUT     INTA01,AL       ; DEVICE INTRS RE-ESTABLISHED
        POP     DS              ; RESTORE REGISTER
        RET
UART    ENDP
        ORG     0E987H
        JMP     NEAR PTR KB_INT
;-----------------------------------------------------------
;       NEC_OUTPUT
;
;       THIS ROUTINE SENDS A BYTE TO THE NEC CONTROLLER
;       AFTER TESTING FOR CORRECT DIRECTION AND CONTROLLER READY
;       THIS ROUTINE WILL TIME OUT IF THE BYTE IS NOT ACCEPTED
;       WITHIN A REASONABLE AMOUNT OF TIME, SETTING THE DISKETTE
;       STATUS ON COMPLETION
;
;       INPUT
;               (AH)    BYTE TO BE OUTPUT
;
;       OUTPUT
;               CY = 0  SUCCESS
;               CY = 1  FAILURE -- DISKETTE STATUS UPDATED
;                       IF A FAILURE HAS OCCURRED, THE RETURN IS MADE ONE
;                       LEVEL HIGHER THAN THE CALLER OF NEC_OUTPUT
;                       THIS REMOVES THE REQUIREMENT OF TESTING AFTER EVERY
;                       CALL OF NEC_OUTPUT
;               (AL)    DESTROYED
;-----------------------------------------------------------
NEC_OUTPUT     PROC    NEAR
        PUSH    DX              ; SAVE REGISTERS
        PUSH    CX
       MOV     DX,NEC_STAT     ; STATUS PORT
        XOR     CX,CX           ; COUNT FOR TIME OUT
J23:    IN      AL,DX           ; GET STATUS
        TEST    AL,DIO          ; TEST DIRECTION BIT
        JZ      J25             ; DIRECTION OK
        LOOP    J23
J24:                            ; TIME_ERROR
        OR      DISKETTE_STATUS,TIME_OUT
        POP     CX
        POP     DX              ; SET ERROR CODE AND RESTORE REGS
        POP     AX              ; DISCARD THE RETURN ADDRESS
        STC                     ; INDICATE ERROR TO CALLER
        RET
J25:    XOR     CX,CX           ; RESET THE COUNT
J26:    IN      AL,DX           ; GET THE STATUS
        TEST    AL,RQM          ; IS IT READY?
        JNZ     J27             ; YES, GO OUTPUT
        LOOP    J26             ; COUNT DOWN AND TRY AGAIN
        JMP     J24             ; ERROR CONDITION
J27:                            ; OUTPUT
        MOV     AL,AH           ; GET BYTE TO OUTPUT
        INC     DX              ; DATA PORT IS 1 GREATER THAN
                                ; STATUS PORT
        OUT     DX,AL           ; OUTPUT THE BYTE
        POP     CX              ; RECOVER REGISTERS
        POP     DX
        RET                     ; CY = 0 FROM TEST INSTRUCTION
NEC_OUTPUT     ENDP
;-----------------------------------------
; GET_PARM
; THIS ROUTINE FETCHES THE INDEXED POINTER FROM
; THE DISK_BASE BLOCK POINTED AT BY THE DATA
; VARIABLE DISK_POINTER
; A BYTE FROM THAT TABLE IS THEN MOVED INTO AH,
; THE INDEX OF THAT BYTE BEING THE PARM IN BX
; ENTRY --
;   BL = INDEX OF BYTE TO BE FETCHED * 2
;   IF THE LOW BIT OF BL IS ON, THE BYTE IS IMMEDIATELY
;     OUTPUT TO THE NEC CONTROLLER
; EXIT --
;   AH = THAT BYTE FROM BLOCK
;   BX = DESTROYED
;-----------------------------------------
GET_PARM       PROC    NEAR
        PUSH    DS              ; SAVE SEGMENT
        PUSH    SI              ; SAVE REGISTER
        SUB     AX,AX           ; ZERO TO AX
        XOR     BH,BH           ; ZERO BH
        MOV     DS,AX
ASSUME  DS:ABS0
        LDS     SI,DISK_POINTER ; POINT TO BLOCK
        SHR     BX,1            ; DIVIDE BX BY 2, AND SET FLAG FOR
                                ; EXIT
        PUSHF                   ; SAVE OUTPUT BIT
        MOV     AH,[SI+BX]      ; GET THE BYTE
        CMP     BX,1            ; IS THIS THE PARM WITH DMA
                                ; INDICATOR
        JNZ     J27_1
        OR      AH,1            ; TURN ON NO DMA BIT
        JMP     SHORT J27_2
J27_1:  CMP     BX,10           ; MOTOR STARTUP DELAY?
        JNE     J27_2
        CMP     AH,4            ; GREATER THAN OR EQUAL TO 1/2 SEC?
        JGE     J27_2           ; YES, OKAY
        MOV     AH,4            ; NO, FORCE 1/2 SECOND DELAY
J27_2:  POPF                    ; GET OUTPUT BIT
        POP     SI              ; RESTORE REGISTER
        POP     DS              ; RESTORE SEGMENT
ASSUME  DS:DATA
        JC      NEC_OUTPUT      ; IF FLAG SET, OUTPUT TO CONTROLLER
        RET                     ; RETURN TO CALLER
GET_PARM       ENDP
;-----------------------------------------
; BOUND_SETUP
; THIS ROUTINE SETS UP BUFFER ADDRESSING FOR READ/WRITE/VERIFY
; OPERATIONS.
; INPUT
;   ES HAS ORIGINAL BUFFER SEGMENT VALUE
;   BP POINTS AT BASE OF SAVED PARMETERS ON STACK
; OUTPUT
;   ES HAS SEGMENT WHICH WILL ALLOW 64K ACCESS.  THE
;   COMBINATION ES:DI AND DS:SI POINT TO THE BUFFER. THIS
;   CALCULATED ADDRESS WILL ALWAYS ACCESS 64K OF MEMORY.
;   BX DESTOYED
;-----------------------------------------
BOUND_SETUP     PROC    NEAR
        PUSH    CX              ; SAVE REGISTERS
        MOV     BX,[BP+12]      ; GET OFFSET OF BUFFER FROM STACK
        PUSH    BX              ; SAVE OFFSET TEMPORARILY
        MOV     CL,4            ; SHIFT COUNT
        SHR     BX,CL           ; SHIFT OFFSET FOR NEW SEGMENT
                                ; VALUE
        MOV     CX,ES           ; PUT ES IN REGISTER SUITABLE FOR
                                ; ADDING TO
        ADD     CX,BX           ; GET NEW VALUE FOR ES
        MOV     ES,CX           ; UPDATE THE ES REGISTER
        POP     BX              ; RECOVER ORIGINAL OFFSET
        AND     BX,0000FH       ; NEW OFFSET
        MOV     SI,BX           ; DS:SI POINT AT BUFFER
        MOV     DI,BX           ; ES:DI POINT AT BUFFER
        POP     CX
        RET
BOUND_SETUP     ENDP
;---------------------------------------------------
; SEEK
;
;       THIS ROUTINE WILL MOVE THE HEAD ON THE NAMED DRIVE
;       TO THE NAMED TRACK.  IF THE DRIVE HAS NOT BEEN ACCESSED
;       SINCE THE DRIVE RESET COMMAND WAS ISSUED, THE DRIVE WILL BE
;       RECALIBRATED.
;
; INPUT
;
;       (DL) = DRIVE TO SEEK ON
;       (CH) = TRACK TO SEEK TO
;
; OUTPUT
;
;       CY = 0 SUCCESS
;       CY = 1 FAILURE -- DISKETTE_STATUS SET ACCORDINGLY
;       (AX) DESTROYED
;---------------------------------------------------
SEEK            PROC    NEAR
        PUSH    SI              ; SAVE REGISTER
        PUSH    BX              ; SAVE REGISTER
        PUSH    CX
        MOV     SI,OFFSET TRACK0 ; BASE OF CURRENT HEAD POSITIONS
        MOV     AL,1            ; ESTABLISH MASK FOR RECAL
        MOV     CL,DL           ; USE DRIVE AS A SHIFT COUNT
        AND     CX,0FFH         ; MASK OFF HIGH BYTE
        ADD     SI,CX           ; POINT SI AT CORRECT DRIVE
        ROL     AL,CL           ; GET MASK FOR DRIVE
;------ SI CONTAINS OFFSET FOR CORRECT DRIVE, AL CONTAINS BIT MASK
;       IN POSITION 0,1 OR 2
        POP     CX              ; RESTORE PARAMETER REGISTER
        MOV     BX,OFFSET J32   ; SET UP ERROR RECOVERY ADDRESS
        PUSH    BX              ; NEEDED FOR ROUTINE NEC_OUTPUT
        TEST    SEEK_STATUS,AL  ; TEST DRIVE FOR RECAL
        JNZ     J28             ; NO_RECAL
        OR      SEEK_STATUS,AL  ; TURN ON THE NO RECAL BIT IN FLAG
        CMP     BYTE PTR[SI],0  ; LAST REFERENCED TRACK=0?
        JZ      J28             ; YES IGNORE RECAL
        MOV     AH,07H          ; RECALIBRATE COMMAND
        CALL    NEC_OUTPUT
        MOV     AH,DL           ; RECAL REQUIRED ON DRIVE IN DL
        CALL    NEC_OUTPUT      ; OUTPUT THE DRIVE NUMBER

        CALL    CHK_STAT_2      ; GET THE STATUS OF RECALIBRATE
        JC      J32_2           ; SEEK_ERROR
        MOV     BYTE PTR[SI],0
;------ DRIVE IS IN SYNCH WITH CONTROLLER, SEEK TO TRACK
J28:    MOV     AL,BYTE PTR[SI] ; GET THE PCN
        SUB     AL,CH           ; GET SEEK_WAIT VALUE
        JZ      J31_1           ; ALREADY ON CORRECT TRACK
        MOV     AH,0FH          ; SEEK COMMAND TO NEC
        CALL    NEC_OUTPUT
        MOV     AH,DL           ; DRIVE NUMBER
        CALL    NEC_OUTPUT
        MOV     AH,CH           ; TRACK NUMBER
        CALL    NEC_OUTPUT
        CALL    CHK_STAT_2      ; GET ENDING INTERRUPT AND SENSE
                                ; STATUS

;------ WAIT FOR HEAD SETTLE
        PUSHF                   ; SAVE STATUS FLAGS
        PUSH    CX              ; SAVE REGISTER
        MOV     BL,18           ; HEAD SETTLE PARAMETER
        CALL    GET_PARM
J29:    MOV     CX,550          ; 1 MS LOOP
        OR      AH,AH           ; TEST FOR TIME EXPIRED
        JZ      J31
J30:    LOOP    J30             ; DELAY FOR 1 MS
        DEC     AH              ; DECREMENT THE COUNT
        JMP     J29             ; DO IT SOME MORE
J31:    POP     CX              ; RESTORE REGISTER
        POPF
        JC      J32_2
        MOV     BYTE PTR[SI],CH
J31_1:  POP     BX              ; GET RID OF DUMMY RETURN
J32:                            ; SEEK_ERROR
        POP     BX              ; RESTORE REGISTER
        POP     SI              ; UPDATE CORRECT
        RET                     ; RETURN TO CALLER
J32_2:  MOV     BYTE PTR[SI],0FFH ; UNKNOWN STATUS ABOUT SEEK
                                ; OPERATION
        POP     BX              ; GET RID OF DUMMY RETURN
        JMP     SHORT J32
SEEK            ENDP
;------------------------------------------------------------
; CHK_STAT_2
;      THIS ROUTINE HANDLES THE INTERRUPT RECEIVED AFTER
;      A RECALIBRATE, SEEK, OR RESET TO THE ADAPTER.
;      THE INTERRUPT IS WAITED FOR, THE INTERRUPT STATUS SENSED,
;      AND THE RESULT RETURNED TO THE CALLER.
;
; INPUT
;
;      NONE
;
; OUTPUT
;
;      CY = 0 SUCCESS
;      CY = 1 FAILURE -- ERROR IS IN DISKETTE_STATUS
;      (AX) DESTROYED
;------------------------------------------------------------
CHK_STAT_2      PROC    NEAR
        PUSH    BX              ; SAVE REGISTERS
        PUSH    SI
        XOR     BX,BX           ; NUMBER OF SENSE INTERRUPTS TO
                                ; ISSUE
        MOV     SI,OFFSET J33_3 ; SET UP DUMMY RETURN FROM
                                ; NEC_OUTPUT
        PUSH    SI              ; PUT ON STACK
J33_2:  MOV     AH,08H          ; SENSE INTERUPT STATUS
        CALL    NEC_OUTPUT      ; ISSUE SENSE INTERUPT STATUS
        CALL    RESULTS         ;
        JC      J35             ; NEC TIME OUT, FLAGS SET IN
                                ; RESULTS
        MOV     AL,NEC_STATUS   ; GET STATUS
        TEST    AL,SEEK_END     ; IS SEEK OR RECAL OPERATION DONE?
        JNZ     J35_1           ; JUMP IF EXECUTION OF SEEK OR
                                ; RECAL DONE
J33_3:  DEC     BX              ; DEC LOOP COUNTER
        JNZ     J33_2           ; DO ANOTHER LOOP
        OR      DISKETTE_STATUS,TIME_OUT
J34:    STC                     ; RETURN ERROR INDICATION FOR
                                ; CALLER
J35:    POP     SI              ; RESTORE REGISTERS
        POP     SI
        POP     BX
        RET
;-----SEEK END HAS OCCURED, CHECK FOR NORMAL TERMINATION
J35_1:  AND     AL,0C0H         ; MASK NORMAL TERMINATION BITS
        JZ      J35             ; JUMP IF NORMAL TERMINATION
        OR      DISKETTE_STATUS,BAD_SEEK
        JMP     J34
CHK_STAT_2      ENDP
;------------------------------------------------------------
; RESULTS
;
;      THIS ROUTINE WILL READ ANYTHING THAT THE NEC CONTROLLER
;      HAS TO SAY FOLLOWING AN INTERRUPT.
;      IT IS ASSUMED THAT THE NEC DATA PORT = NEC STATUS PORT + 1.
;
; INPUT
;
;      NONE
;
; OUTPUT
;
;      CY = 0  SUCCESSFUL TRANSFER
;      CY = 1  FAILURE -- TIME OUT IN WAITING FOR STATUS
;      NEC_STATUS AREA HAS STATUS BYTE LOADED INTO IT
;      (AH) DESTROYED
;------------------------------------------------------------
RESULTS         PROC    NEAR
        CLD
        MOV     DI,OFFSET NEC_STATUS ; POINTER TO DATA AREA
        PUSH    CX              ; SAVE COUNTER
        PUSH    DX
        PUSH    BX
        MOV     BL,7            ; MAX STATUS BYTES
;------- WAIT FOR REQUEST FOR MASTER
J38:    XOR     CX,CX           ; INPUT_LOOP
       MOV     DX,NEC_STAT     ; STATUS PORT
J39:    IN      AL,DX           ; WAIT FOR MASTER
        TEST    AL,080H         ; MASTER READY
        JNZ     J40A            ; TEST_DIR
        LOOP    J39             ; WAIT_MASTER
        OR      DISKETTE_STATUS,TIME_OUT
J40:    STC                     ; RESULTS_ERROR
;------- RESULT OPERATION IS DONE
J44:    POP     BX
        POP     DX
        POP     CX
        RET
;------- TEST THE DIRECTION BIT
J40A:   IN      AL,DX           ; GET STATUS REG AGAIN
        TEST    AL,040H         ; TEST DIRECTION BIT
        JNZ     J42             ; OK TO READ STATUS
J41:    OR      DISKETTE_STATUS,BAD_NEC
        JMP     J40             ; RESULTS_ERROR
;------- READ IN THE STATUS
J42:    INC     DX              ; INPUT_STAT
        IN      AL,DX           ; GET THE DATA
        MOV     [DI],AL         ; STORE THE BYTE
        INC     DI              ; INCREMENT THE POINTER
        MOV     CX,10           ; LOOP TO KILL TIME FOR NEC
J43:    LOOP    J43
        DEC     DX              ; POINT AT STATUS PORT
        IN      AL,DX           ; GET STATUS
        TEST    AL,010H         ; TEST FOR NEC STILL BUSY
        JZ      J44             ; RESULTS DONE
        DEC     BL              ; DECREMENT THE STATUS COUNTER
        JNZ     J38             ; GO BACK FOR MORE
        JMP     J41             ; CHIP HAS FAILED
;------------------------------------------------------------
; NUM_TRANS
;       THIS ROUTINE CALCULATES THE NUMBER OF SECTORS THAT
;       WERE ACTUALLY TRANSFERRED TO/FROM THE DISKETTE
; INPUT
;       (CH) = CYLINDER OF OPERATION
;       (CL) = START SECTOR OF OPERATION
; OUTPUT
;       (AL) = NUMBER ACTUALLY TRANSFERRED
;       NO OTHER REGISTERS MODIFIED
;------------------------------------------------------------
NUM_TRANS       PROC    NEAR
        MOV     AL,NEC_STATUS+3 ; GET CYLINDER ENDED UP ON
        CMP     AL,[BP+11]      ; SAME AS WE STARTED
        MOV     AL,NEC_STATUS+5 ; GET ENDING SECTOR
        JZ      J45             ; IF ON SAME CYL, THEN NO ADJUST
        MOV     BL,8
        CALL    GET_PARM        ; GET EOT VALUE
        MOV     AL,AH           ; INTO AL
J45:    INC     AL              ; USE EOT+1 FOR CALCULATION
        SUB     AL,[BP]+10      ; SUBTRACT START FROM END
        MOV     [BP+14],AL
        RET
NUM_TRANS       ENDP
RESULTS         ENDP
;------------------------------------------------------------
; DISABLE
;       THIS ROUTINE WILL DISABLE ALL INTERRUPTS EXCEPT FOR
;       INTERRUPT 6 SO WATCH DOG TIME OUT CAN OCCUR IN ERROR
;       CONDITIONS.
; INPUT
;       NONE
; OUTPUT
;       NONE
;       ALL REGISTERS REMAIN INTACT
;------------------------------------------------------------
DISABLE         PROC    NEAR
        PUSH    AX
;------- DISABLE ALL INTERRUPTS AT THE 8259 LEVEL EXCEPT DISKETTE
        IN      AL,INTA01       ; READ CURRENT MASK
        MOV     [BP+16],AX      ; SAVE MASK ON THE SPACE ALLOCATED
                                ; ON THE STACK
        MOV     AL,0BFH         ; MASK OFF ALL INTERRUPTS EXCEPT
                                ; DISKETTE
        OUT     INTA01,AL       ; OUTPUT MASK TO THE 8259
        CALL    BOUND_SETUP     ; SETUP REGISTERS TO ACCESS BUFFER
        POP     AX
        RET
DISABLE         ENDP
;------------------------------------------------------------
; ENABLE
;       THIS PROC ENABLES ALL INTERRUPTS.  IT ALSO SETS THE 8253 TO
;       THE MODE REQUIRED FOR KEYBOARD DATA DESERIALIZATION.
;       BEFORE THE LATCH FOR KEYBOARD DATA IS RESET, BIT 0 OF THE
;       8255 IS READ TO DETERMINE WHETHER ANY KEYSTROKES OCCURED
;       WHILE THE SYSTEM WAS MASKED OFF.
; INPUT
;       NONE
; OUTPUT
;       AL=1 MEANS A KEY WAS STRUCK DURING DISKETTE I/O. (OR NOISE
;           ON THE LINE)
;       AL=0 MEANS THAT NO KEY WAS PRESSED.
;       AX IS DESTROYED.  ALL OTHER REGISTERS REMAIN INTACT.
;------------------------------------------------------------
ENABLE          PROC    NEAR
        PUSH    DX              ; SAVE DX
;------- RETURN TIMER1 TO STATE NEEDED FOR KEYBOARD I/O
        MOV     AL,01110110B    ;
        OUT     TIM_CTL,AL
        PUSH    AX
        POP     AX              ; WAIT FOR 8253 TO INITIALIZE
                                ; ITSELF
        MOV     AL,0FFH         ; INITIAL VALUE FOR 8253
        OUT     TIMER+1,AL      ; LSB
        PUSH    AX
        POP     AX              ; WAIT
        OUT     TIMER+1,AL      ; MSB
;------- CHECK IF ANY KEYSTROKES OCCURED DURING DISKETTE TRANSFER
        MOV     ES,[BP+16]      ; GET ORIGINAL ES VALUE FROM THE
                                ; STACK
        IN      AL,62H          ; READ PORT C OF 8255
        AND     AL,01H          ; BIT=1 MEANS KEYSTROKE HAS OCCURED
        PUSH    AX              ; SAVE IT ON THE STACK
;------- ENABLE NMI INTERRUPTS
        IN      AL,NMI_PORT     ; RESET LATCH
        MOV     AL,80H          ; MASK TO ENABLE NMI
        OUT     NMI_PORT,AL     ; ENABLE NMI
;------- ENABLE ALL INTERRUPTS WHICH WERE ENABLED BEFORE TRANSFER
        MOV     AX,[BP+16]      ; GET MASK FROM THE STACK
        OUT     INTA01,AL
        POP     AX              ; PASS BACK KEY STROKE FLAG
        POP     DX
        STI
        RET
ENABLE          ENDP
;--------------------------------------------------
;CLOCK_WAIT
;
;       THIS PROCEDURE IS CALLED WHEN THE TIME OF DAY
;       IS BEING UPDATED.  IT WAITS IF TIMER0 IS ALMOST
;       READY TO WRAP UNTIL IT IS SAFE TO READ AN ACCURATE
;       TIMER1.
;
;INPUT
;
;       NONE.
;
;OUTPUT
;
;       NONE.  AX IS DESTROYED.
;--------------------------------------------------
CLOCK_WAIT      PROC    NEAR
        XOR     AL,AL           ; READ MODE TIMER0 FOR 8253
        OUT     TIM_CTL,AL      ; OUTPUT TO THE 8253
        PUSH    AX
        POP     AX              ; WAIT FOR 8253 TO INITIALIZE
                                ; ITSELF
        IN      AL,TIMER0       ; READ LEAST SIGNIFICANT BYTE
        XCHG    AL,AH           ; SAVE IT
        IN      AL,TIMER0       ; READ MOST SIGNIFICANT BYTE
        XCHG    AL,AH           ; REARRANGE FOR PROPER ORDER
        CMP     AX,THRESHOLD    ; IS TIMER0 CLOSE TO WRAPPING?
        JC      CLOCK_WAIT      ; JUMP IF CLOCK IS WITHIN THRESHOLD
        RET                     ; OK TO READ TIMER1
CLOCK_WAIT      ENDP
;--------------------------------------------------
;GET_DRIVE
;
;       THIS ROUTINE WILL CALCULATE A BIT MASK FOR THE DRIVE WHICH
;       IS SELECTED BY THE CURRENT INT 13 CALL.  THE DRIVE SELECTED
;       CORRESPONDS TO THE BIT IN THE MASK, I.E. DRIVE ZERO
;       CORRESPONDS TO BIT ZERO AND A 01H IS RETURNED. THE BIT IS
;       CALCULATED BY ACCESSING THE PARAMETERS PASSED TO INT 13
;       WHICH WERE SAVED ON THE STACK.
;
;INPUT
;
;       BYTE PTR[BP] MUST POINT TO DRIVE FOR SELECTION.
;
;OUTPUT
;
;       AL CONTAINS THE BIT MASK.  ALL OTHER REGISTERS ARE INTACT
;--------------------------------------------------
GET_DRIVE       PROC    NEAR
        PUSH    CX              ; SAVE REGISTER.
        MOV     CL,BYTE PTR[BP] ; GET DRIVE NUMBER
        MOV     AL,1            ; INITIALIZE AL WITH VALUE FOR
                                ; SHIFTING
        SHL     AL,CL           ; SHIFT BIT POSITION BY DRIVE
                                ; NUMBER (DRIVE IN RANGE 0-2)
        AND     AL,07H          ; ONLY THREE DRIVES ARE SUPPORTED.
                                ; RANGE CHECK
        POP     CX              ; RESTORE REGISTERS
        RET
GET_DRIVE       ENDP
;--------------------------------------------------
;       THIS ROUTINE CHECKS OPTIONAL ROM MODULES (CHECKSUM
;       FOR MODULES FROM C0000->D0000, CRC CHECK FOR CARTRIDGES
;       (D0000->F0000)
;       IF CHECK IS OK, CALLS INIT/TEST CODE IN MODULE
;       MFG ERROR CODE= 25XX (XX=MSB OF SEGMENT IN ERROR)
;--------------------------------------------------
ROM_CHECK       PROC    NEAR
        SUB     SI,SI           ; SET SI TO POINT TO BEGINNING
                                ; (REL. TO DS)
        SUB     AL,AL           ; ZERO OUT AL
        MOV     AH,[BX+2]       ; GET LENGTH INDICATOR
        SHL     AX,1            ; FORM COUNT
        PUSH    AX              ; SAVE COUNT
        CMP     DX,0D000H       ; SEE IF POINTER IS BELOW D000
        PUSHF                   ; SAVE RESULTS
        MOV     CL,4            ; ADJUST
        SHR     AX,CL           ;
        ADD     DX,AX           ; SET POINTER TO NEXT MODULE
        POPF                    ; RECOVER FLAGS FROM POINTER RANGE
                                ; CHECK
        POP     CX              ; RECOVER COUNT IN CX REGISTER
        PUSH    DX              ; SAVE POINTER
        JL      ROM_1           ; DO ARITHMETIC CHECKSUM IF BELOW
                                ; D0000
        CALL    CRC_CHECK       ; DO CRC CHECK
        JZ      ROM_CHECK_1     ; PROCEED IF OK
        JMP     SHORT ROM_2     ; ELSE POST ERROR
ROM_1:  CALL    ROS_CHECKSUM    ; DO ARITHMETIC CHECKSUM
        JZ      ROM_CHECK_1     ; PROCEED IF OK
ROM_2:  MOV     DX,1626H        ; POSITION CURSOR, ROW 22, COL 38
        MOV     AH,2
        MOV     BH,7
        INT     10H
        MOV     DX,DS           ; RECOVER DATA SEG
        MOV     AL,DH           ;
        CALL    XPC_BYTE        ; DISPLAY MSB OF DATA SEG
        MOV     BL,DH           ; FORM XX VALUE OF ERROR CODE
        MOV     BH,25H          ; FORM 25 PORTION
        CMP     DH,0D0H         ; IN CARTRIDGE SPACE?
        MOV     SI,OFFSET CART_ERR
        JGE     ROM_CHECK_0     ;
        MOV     SI,OFFSET ROM_ERR
ROM_CHECK_0:
        CALL    E_MSG           ; GO ERROR ROUTINE
        JMP     SHORT ROM_CHECK_END ; AND EXIT
ROM_CHECK_1:
        MOV     AX,XXDATA       ; SET ES TO POINT TO XXDATA AREA
        MOV     ES,AX           ;
        MOV     ES:IO_ROM_INIT,0003H ; LOAD OFFSET
        MOV     ES:IO_ROM_SEG,DS ; LOAD SEGMENT
        CALL    DWORD PTR ES:IO_ROM_INIT ; CALL INIT./TEST ROUTINE
ROM_CHECK_END:
        POP     DX              ; RECOVER POINTER
        RET                     ; RETURN TO CALLER
ROM_CHECK       ENDP
;-- INT 13 -------------------------------------------
; DISKETTE I/O
; THIS INTERFACE PROVIDES ACCESS TO THE 5 1/4" DISKETTE DRIVES
; INPUT
;     (AH)=0   RESET DISKETTE SYSTEM
;             HARD RESET TO NEC, PREPARE COMMAND, RECAL REQD ON
;             ALL DRIVES
;     (AH)=1   READ THE STATUS OF THE SYSTEM INTO (AL)
;             DISKETTE_STATUS FROM LAST OP'N IS USED
;             REGISTERS FOR READ/WRITE/VERIFY/FORMAT
;             (DL) - DRIVE NUMBER (0-3 ALLOWED, VALUE CHECKED)
;             (DH) - HEAD NUMBER (0-1 ALLOWED, NOT VALUE CHECKED)
;             (CH) - TRACK NUMBER (0-39, NOT VALUE CHECKED)
;             (CL) - SECTOR NUMBER (1-8, NOT VALUE CHECKED, NOT USED FOR
;                    FORMAT)
;             (AL) - NUMBER OF SECTORS ( MAX = 8, NOT VALUE CHECKED, NOT
;                    USED FOR FORMAT, HOWEVER, CANNOT BE ZERO!!!)
;             (ES:BX) - ADDRESS OF BUFFER ( NOT REQUIRED FOR VERIFY)
;
;     (AH)=2   READ THE DESIRED SECTORS INTO MEMORY
;     (AH)=3   WRITE THE DESIRED SECTORS FROM MEMORY
;     (AH)=4   VERIFY THE DESIRED SECTORS
;     (AH)=5   FORMAT THE DESIRED TRACK
;             FOR THE FORMAT OPERATION, THE BUFFER POINTER
;             (ES,BX) MUST POINT TO THE COLLECTION OF DESIRED
;             ADDRESS FIELDS FOR THE TRACK. EACH FIELD IS
;             COMPOSED OF 4 BYTES, (C,H,R,N), WHERE
;             C = TRACK NUMBER, H=HEAD NUMBER, R = SECTOR NUMBER,
;             N= NUMBER OF BYTES PER SECTOR (00=128, 01=256,
;                02=512, 03=1024,). THERE MUST BE ONE ENTRY FOR
;                EVERY SECTOR ON THE TRACK. THIS INFORMATION IS USED
;                TO FIND THE REQUESTED SECTOR DURING READ/WRITE
;                ACCESS.
; DATA VARIABLE -- DISK_POINTER
;     DOUBLE WORD POINTER TO THE CURRENT SET OF DISKETTE PARAMETERS
; OUTPUT
;     AH = STATUS OF OPERATION
;          STATUS BITS ARE DEFINED IN THE EQUATES FOR
;          DISKETTE_STATUS VARIABLE IN THE DATA SEGMENT OF
;          THIS MODULE
;     CY = 0  SUCCESSFUL OPERATION (AH=0 ON RETURN)
;     CY = 1  FAILED OPERATION (AH HAS ERROR REASON)
;     FOR READ/WRITE/VERIFY
;          DS,BX,DX,CH,CL PRESERVED
;          AL = NUMBER OF SECTORS ACTUALLY READ
;          **** AL MAY NOT BE CORRECT IF TIME OUT ERROR OCCURS
;     NOTE: IF AN ERROR IS REPORTED BY THE DISKETTE CODE, THE
;           APPROPRIATE ACTION IS TO RESET THE DISKETTE, THEN
;           RETRY THE OPERATION. ON READ ACCESSES, NO MOTOR
;           START DELAY IS TAKEN, SO THAT THREE RETRIES ARE
;           REQUIRED ON READS TO ENSURE THAT THE PROBLEM IS NOT
;           DUE TO MOTOR START-UP.
;---------------------------------------------------
ASSUME  CS:CODE,DS:DATA,ES:DATA
        ORG     0EC59H
DISKETTE_IO    PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    ES              ; SAVE ES
        PUSH    AX              ; ALLOCATE ONE WORD OF STORAGE FOR
                                ; TIMER1 INITIAL VALUE
        PUSH    AX              ; ALLOCATE ONE WORD ON STACK FOR
                                ; USE IN PROCS ENABLE AND DISABLE.
                                ; WILL HOLD 8259 MASK.
        PUSH    AX              ; SAVE COMMAND AND N_SECTORS
        PUSH    BX              ; SAVE ADDRESS
        PUSH    CX
        PUSH    DS              ; SAVE SEGMENT REGISTER VALUE
        PUSH    SI              ; SAVE ALL REGISTERS DURING
                                ; OPERATION
        PUSH    DI
        PUSH    BP
        PUSH    DX
        MOV     BP,SP           ; SET UP POINTER TO HEAD PARM
        CALL    DDS             ; SET DS=DATA
        CALL    J1              ; CALL THE REST TO ENSURE DS
                                ; RESTORED
        MOV     BL,4            ; GET THE MOTOR WAIT PARAMETER
        CALL    GET_PARM
        MOV     MOTOR_COUNT,AH  ; SET THE TIMER COUNT FOR THE MOTOR
        MOV     AH,DISKETTE_STATUS ; GET STATUS OF OPERATION
        MOV     [BP+15],AH      ; RETURN STATUS IN AL
        POP     DX              ; RESTORE ALL REGISTERS
        POP     BP
        POP     DI
        POP     SI
        POP     DS
        POP     CX
        POP     BX              ; RECOVER OFFSET
        POP     AX
        ADD     SP,4            ; DISCARD DUMMY SPACE FOR 8259 MASK
        POP     ES              ; RECOVER SEGMENT
        CMP     AH,1            ; SET THE CARRY FLAG TO INDICATE
                                ; SUCCESS OR FAILURE
        CMC
        RET     2               ; THROW AWAY SAVED FLAGS
DISKETTE_IO    ENDP
J1              PROC    NEAR
        MOV     DH,AL           ; SAVE # SECTORS IN DH
        AND     MOTOR_STATUS,07FH ; INDICATE A READ OPERATION
        OR      AH,AH           ; AH=0
        JZ      DISK_RESET
        DEC     AH              ; AH=1
        JZ      DISK_STATUS
        MOV     DISKETTE_STATUS,0 ; RESET THE STATUS INDICATOR
        CMP     DL,2            ; TEST FOR DRIVE IN 0-2 RANGE
        JA      J3              ; ERROR IF ABOVE
        DEC     AH              ; AH=2
        JZ      DISK_READ
        DEC     AH              ; AH=3
        JNZ     J2              ; TEST_DISK_VERF
        JMP     DISK_WRITE
J2:                             ; TEST_DISK_VERF
        DEC     AH              ; AH=4
        JZ      DISK_VERF
        DEC     AH              ; AH=5
        JZ      DISK_FORMAT
J3:                             ; BAD_COMMAND
        MOV     DISKETTE_STATUS,BAD_CMD ; ERROR CODE, NO SECTORS
                                ; TRANSFERRED
        RET                     ; UNDEFINED OPERATION
J1              ENDP
;------- RESET THE DISKETTE SYSTEM
DISK_RESET      PROC    NEAR
       MOV     DX,NEC_CTL      ; ADAPTER CONTROL PORT
        CLI                     ; NO INTERRUPTS
        MOV     AL,MOTOR_STATUS ; FIND OUT IF MOTOR IS RUNNING
        AND     AL,07H          ; DRIVE BITS
        OUT     DX,AL           ; RESET THE ADAPTER
        MOV     SEEK_STATUS,0   ; SET RECAL REQUIRED ON ALL DRIVES
        MOV     DISKETTE_STATUS,0 ; SET OK STATUS FOR DISKETTE
        OR      AL,FDC_RESET    ; TURN OFF RESET
        OUT     DX,AL           ; TURN OFF THE RESET
        STI                     ; REENABLE THE INTERRUPTS
        MOV     SI,OFFSET J4_2  ; DUMMY RETURN FOR
        PUSH    SI              ; PUSH RETURN IF ERROR
                                ; IN NEC_OUTPUT
       MOV     CX,10H          ; NUMBER OF SENSE INTERRUPTS TO
                                ; ISSUE
J4_0:   MOV     AH,08H          ; COMMAND FOR SENSE INTERRUPT
                                ; STATUS
        CALL    NEC_OUTPUT      ; OUTPUT THE SENSE INTERRUPT
                                ; STATUS
        CALL    RESULTS         ; GET STATUS FOLLOWING COMPLETION
                                ; OF RESET
        MOV     AL,NEC_STATUS   ; IGNORE ERROR RETURN AND DO OWN
                                ; TEST
        CMP     AL,0C0H         ; TEST FOR DRIVE READY TRANSITION
        JZ      J7              ; EVERYTHING OK
        LOOP    J4_0            ; RETRY THE COMMAND
J4_1:   OR      DISKETTE_STATUS,BAD_NEC ; SET ERROR CODE
        POP     SI
        JMP     SHORT J8
J4_2:   MOV     SI,OFFSET J4_2  ; NEC_OUTPUT FAILED, RETRY THE
                                ; SENSE INTERRUPT
        PUSH    SI              ; OFFSET OF BAD RETURN IN
                                ; NEC_OUTPUT
        LOOP    J4_0            ; RETRY
        JMP     SHORT J4_1
;------- SEND SPECIFY COMMAND TO NEC
J7:     POP     SI              ; GET RID OF DUMMY ARGUMENT
        MOV     AH,03H          ; SPECIFY COMMAND
        CALL    NEC_OUTPUT      ; OUTPUT THE COMMAND
        MOV     BL,1            ; STEP RATE TIME AND HEAD UNLOAD
        CALL    GET_PARM        ; OUTPUT TO THE NEC CONTROLLER
        MOV     BL,3            ; PARM1 HEAD LOAD AND NO DMA
        CALL    GET_PARM        ; TO THE NEC CONTROLLER
J8:     RET                     ; RESET_RET
DISK_RESET      ENDP
;------- DISKETTE STATUS ROUTINE
DISK_STATUS     PROC    NEAR
        MOV     AL,DISKETTE_STATUS
        MOV     BYTE PTR[BP+14],AL ; PUT STATUS ON STACK, IT WILL
                                ; POP IN AL
        RET
DISK_STATUS     ENDP
;------- DISKETTE VERIFY
DISK_VERF       LABEL   NEAR
;------- DISKETTE READ
DISK_READ       PROC    NEAR
J9:     MOV     AH,046H         ; DISK_READ_CONT
                                ; SET UP READ COMMAND FOR NEC
                                ; CONTROLLER
        JMP     SHORT RW_OPN    ; GO DO THE OPERATION
DISK_READ       ENDP
;------- DISKETTE FORMAT
DISK_FORMAT     PROC    NEAR
        OR      MOTOR_STATUS,80H ; INDICATE A WRITE OPERATION
        MOV     AH,04DH         ; ESTABLISH THE FORMAT COMMAND
        JMP     SHORT RW_OPN    ; DO THE OPERATION
J10:    MOV     BL,7            ; CONTINUATION OF RW_OPN FOR FMT
        CALL    GET_PARM        ; GET THE BYTES/SECTOR VALUE TO NEC
        MOV     BL,9            ; GET THE SECTORS/TRACK VALUE TO NEC
        CALL    GET_PARM
        MOV     BL,15           ; GET THE GAP LENGTH VALUE TO NEC
        CALL    GET_PARM
        MOV     BX,17           ; GET THE FILLER BYTE
        PUSH    BX              ; SAVE PARAMETER INDEX ON STACK
        JMP     J16             ; TO THE CONTROLLER
DISK_FORMAT    ENDP

;------- DISKETTE WRITE ROUTINE
DISK_WRITE      PROC    NEAR
        OR      MOTOR_STATUS,80H ; INDICATE A WRITE OPERATION
        MOV     AH,045H         ; NEC COMMAND TO WRITE TO DISKETTE
DISK_WRITE      ENDP
;----- ALLOW WRITE ROUTINE TO FALL INTO RW_OPN
;---------------------------------------
; RW_OPN
;       THIS ROUTINE PERFORMS THE READ/WRITE/VERIFY OPERATION
;---------------------------------------
RW_OPN          PROC    NEAR
        PUSH    AX              ; SAVE THE COMMAND
;------- TURN ON THE MOTOR AND SELECT THE DRIVE
        PUSH    CX              ; SAVE THE T/S PARMS
        CLI                     ; NO INTERRUPTS WHILE DETERMINING
                                ; MOTOR STATUS
        MOV     MOTOR_COUNT,0FFH ; SET LARGE COUNT DURING OPERATION
        CALL    GET_DRIVE       ; GET THE DRIVE PARAMETER FROM THE
                                ; STACK
        TEST    MOTOR_STATUS,AL ; TEST MOTOR FOR OPERATING
        JNZ     J14             ; IF RUNNING, SKIP THE WAIT
        AND     MOTOR_STATUS,0F0H ; TURN OFF RUNNING DRIVE
        OR      MOTOR_STATUS,AL ; TURN ON THE CURRENT MOTOR
        STI                     ; INTERRUPTS BACK ON
        OR      AL,FDC_RESET    ; NO RESET.  TURN ON MOTOR
        OUT     NEC_CTL,AL
;------- WAIT FOR MOTOR BOTH READ AND WRITE
        MOV     BL,20           ; GET MOTOR START TIME
        CALL    GET_PARM
        OR      AH,AH           ; TEST FOR NO WAIT
J12:    JZ      J14             ; TEST_WAIT_TIME
        SUB     CX,CX           ; SET UP 1/8 SECOND LOOP TIME
J13:    LOOP    J13             ; WAIT FOR THE REQUIRED TIME
        DEC     AH              ; DECREMENT TIME VALUE
        JMP     J12             ; ARE WE DONE YET
J14:    STI                     ; MOTOR_RUNNING
                                ; INTERRUPTS BACK ON FOR BYPASS WAIT
        POP     CX
;------- DO THE SEEK OPERATION
        CALL    SEEK            ; MOVE TO CORRECT TRACK
        POP     AX              ; RECOVER COMMAND
        MOV     BH,AH           ; SAVE COMMAND IN BH
        MOV     DH,0            ; SET NO SECTORS READ IN CASE OF ERROR
        JNC     J14_1           ; IF NO ERROR CONTINUE, JUMP AROUND
        JMP     J17             ; CARRY SET JUMP TO MOTOR WAIT
J14_1:  MOV     SI,OFFSET J17   ; DUMMY RETURN ON STACK FOR NEC_OUTPUT
        PUSH    SI              ; SO THAT IT WILL RETURN TO MOTOR OFF LOCATION
;------- SEND OUT THE PARAMETERS TO THE CONTROLLER
        CALL    NEC_OUTPUT      ; OUTPUT THE OPERATION COMMAND
        MOV     AH,[BP+1]       ; GET THE CURRENT HEAD NUMBER
        SAL     AH,1            ; MOVE IT TO BIT 2
        SAL     AH,1
        AND     AH,4            ; ISOLATE THAT BIT
        OR      AH,DL           ; OR IN THE DRIVE NUMBER
        CALL    NEC_OUTPUT
;------- TEST FOR FORMAT COMMAND
        CMP     BH,04DH         ; IS THIS A FORMAT OPERATION?
        JNE     J15             ; NO.  CONTINUE WITH R/W/V
        JMP     J10             ; IF SO, HANDLE SPECIAL
J15:    MOV     AH,CH           ; CYLINDER NUMBER
        CALL    NEC_OUTPUT
        MOV     AH,[BP+1]       ; HEAD NUMBER FROM STACK
        CALL    NEC_OUTPUT
        MOV     AH,CL           ; SECTOR NUMBER
        CALL    NEC_OUTPUT
        MOV     BL,7            ; BYTES/SECTOR PARM FROM BLOCK
        CALL    GET_PARM        ; TO THE NEC
        MOV     BL,8            ; EOT PARM FROM BLOCK
        CALL    GET_PARM        ; RETURNED IN AH
        ADD     CL,[BP+14]      ; ADD CURRENT SECTOR TO NUMBER IN
                                ; TRANSFER
        DEC     CL              ; CURRENT SECTOR + N_SECTORS - 1
        MOV     AH,CL           ; EOT PARAMETER IS THE CALCULATED ONE
        CALL    NEC_OUTPUT
        MOV     BL,11           ; GAP LENGTH PARM FROM BLOCK
        CALL    GET_PARM        ; TO THE NEC
        MOV     BX,13           ; DTL PARM FROM BLOCK
        PUSH    BX              ; SAVE INDEX TO DISK PARAMETER ON STACK
J16:    CLD                     ; FORWARD DIRECTION
;------- START TIMER1 WITH INITIAL VALUE OF FFFF
        MOV     AL,01110000B    ; SELECT TIMER1,LSB-MSB, MODE 0,
        OUT     TIM_CTL,AL      ; BINARY COUNTER
        PUSH    AX              ; INITIALIZE THE COUNTER
        POP     AX              ; ALLOW ENOUGH TIME FOR THE 8253 TO
                                ; INITIALIZE ITSELF
        MOV     AL,0FFH         ; INITIAL COUNT VALUE FOR THE 8253
        OUT     TIMER+1,AL      ; OUTPUT LEAST SIGNIFICANT BYTE
        PUSH    AX
        POP     AX              ; WAIT
        OUT     TIMER+1,AL      ; OUTPUT MOST SIGNIFICANT BYTE
;-------INITIALIZE CX FOR JUMP AFTER LAST PARAMETER IS PASSED TO NEC
        MOV     AL,[BP+15]      ; RETRIEVE COMMAND PARAMETER
        TEST    AL,01H          ; IS THIS AN ODD NUMBERED FUNCTION?
        JZ      J16_1           ; JUMP IF NOT ODD NUMBERED
        MOV     CX,OFFSET WRITE_LOOP
        JMP     SHORT J16_3
J16_1:  CMP     AL,2            ; IS THIS A READ?
        JNZ     J16_2           ; JUMP IF VERIFY
        MOV     CX,OFFSET READ_LOOP
        JMP     SHORT J16_3
J16_2:  MOV     CX,OFFSET VERIFY_LOOP
;-------FINISH INITIALIZATION
J16_3:
;----------------------------------------------------------------
;***NOTE***
;       ALL INTERRUPTS ARE ABOUT TO BE DISABLED.  THERE IS A POTENTIAL
;       THAT THIS TIME PERIOD WILL BE LONG ENOUGH TO MISS TIME OF
;       DAY INTERRUPTS.  FOR THIS REASON, TIMER1 WILL BE USED TO
;       KEEP TRACK OF THE NUMBER OF TIME OF DAY INTERRUPTS WHICH
;       WILL BE MISSED. THIS INFORMATION IS USED AFTER THE DISKETTE
;       OPERATION TO UPDATE THE TIME OF DAY.
;----------------------------------------------------------------
        MOV     AL,10H          ; DISABLE NMI
        OUT     NMI_PORT,AL     ; NO KEYBOARD INTERRUPT
        CALL    CLOCK_WAIT      ; WAIT IF TIMER0 IS ABOUT TO
                                ; INTERRUPT
;------- ENABLE WATCHDOG TIMER
;----------------------------------------------------------------
;***NOTE***
;       GIVEN THE CURRENT SYSTEM CONFIGURATION A METHOD IS NEEDED
;       TO PULL THE NEC OUT OF "FATAL ERROR" SITUATIONS.  A TIMER
;       ON THE ADAPTER CARD IS PROVIDED WHICH WILL PERFORM THIS
;       FUNCTION. THE WATCHDOG TIMER ON THE ADAPTER CARD IS ENABLED
;       AND STROBED BEFORE THE 8259 INTERRUPT 6 LINE IS ENABLED.
;       THIS IS BECAUSE OF A GLITCH ON THE LINE LARGE ENOUGH TO
;       TRIGGER AN INTERRUPT.
;----------------------------------------------------------------
        CALL    GET_DRIVE       ; GET BIT MASK FOR DRIVE
        MOV     DX,NEC_CTL      ; CONTROL PORT TO NEC
        OR      AL,FDC_RESET+WD_ENABLE+WD_STROBE
        OUT     DX,AL           ; OUTPUT CONTROL INFO FOR
                                ; WATCHDOG(WD) ENABLE
        AND     AL,FDC_RESET+WD_ENABLE+7H
        OUT     DX,AL           ; OUTPUT CONTROL INFO TO STROBE
                                ; WATCHDOG
        MOV     DX,NEC_STAT     ; PORT TO NEC STATUS
        MOV     AL,20H          ; SELECT TIMER1 INPUT FROM TIMER0
                                ; OUTPUT
        OUT     NMI_PORT,AL
;------- READ TIMER1 NOW AND SAVE THE INITIAL VALUE
        CALL    READ_TIME       ; GET TIMER1 VALUE
        MOV     [BP+18],AX      ; SAVE INITIAL VALUE FOR CLOCK
                                ; UPDATE IN TEMPORARY STORAGE
        CALL    DISABLE         ; DISABLE ALL INTERRUPTS
;------- NEC BEGINS OPERATION WHEN NEC RECEIVES LAST PARAMETER
        POP     BX              ; GET PARAMTER FROM STACK
        CALL    GET_PARM        ; OUTPUT LAST PARAMETER TO THE NEC
        POP     AX              ; CAN NOW DISCARD THAT DUMMY RETURN
                                ; ADDRESS
        PUSH    ES
        POP     DS              ; INITIALIZE DS FOR WRITE
        JMP     CX              ; JUMP TO APPROPRIATE R/W/V LOOP
;----------------------------------------------------------------
;***NOTE***
;       DATA IS TRANSFERRED USING POLLING ALGORITHMS.  THESE LOOPS
;       TRANSFER A DATA BYTE AT A TIME WHILE POLLING THE NEC FOR
;       NEXT DATA BYTE AND COMPLETION STATUS.
;----------------------------------------------------------------
;-------VERIFY OPERATION
VERIFY_LOOP:
        IN      AL,DX           ; READ STATUS
        TEST    AL,BUSY_BIT     ; HAS NEC ENTERED EXECUTION PHASE
                                ; YET?
        JZ      VERIFY_LOOP     ; NO, CONTINUE SAMPLING
J22_2:  TEST    AL,RQM          ; IS DATA READY?
        JNZ     J22_4           ; JUMP IF DATA TRANSFER IS READY
        IN      AL,DX           ; READ STATUS PORT
        TEST    AL,BUSY_BIT     ; ARE WE DONE?
        JNZ     J22_2           ; JUMP IF MORE TRANSFERS
        JMP     SHORT OP_END    ; TRANSFER DONE
J22_4:  INC     DX              ; POINT AT NEC DATA REGISTER
        IN      AL,DX           ; READ DATA
        DEC     DX              ; POINT AT NEC STATUS REGISTER
        IN      AL,DX           ; READ STATUS PORT
        TEST    AL,BUSY_BIT     ; ARE WE DONE?
        JNZ     J22_2           ; CONTINUE
        JMP     SHORT OP_END    ; WE ARE DONE
;------READ OPERATION
READ_LOOP:
        IN      AL,DX           ; READ STATUS REGISTER
        TEST    AL,BUSY_BIT     ; HAS NEC STARTED THE EXECUTION
                                ; PHASE?
        JZ      READ_LOOP       ; HAS NOT STARTED YET
J22_5:  IN      AL,DX           ; READ STATUS PORT
        TEST    AL,BUSY_BIT     ; HAS NEC COMPLETED EXECUTION
                                ; PHASE?
        JZ      OP_END          ; JUMP IF EXECUTION PHASE IS OVER
        TEST    AL,RQM          ; IS DATA READY?
        JZ      J22_5           ; READ THE DATA
        INC     DX              ; POINT AT NEC_DATA
        IN      AL,DX           ; READ DATA
        STOSB                   ; TRANSFER DATA
        DEC     DX              ; POINT AT NEC_STATUS
        JMP     J22_5           ; CONTINUE WITH READ OPERATION

;------WRITE AND FORMAT OPERATION
WRITE_LOOP:
        IN      AL,DX           ; READ NEC STATUS PORT
        TEST    AL,BUSY_BIT     ; HAS THE NEC ENTERED EXECUTION
                                ; PHASE YET?
        JZ      WRITE_LOOP      ; NO, CONTINUE LOOPING
        MOV     CX,BUSY_BIT*256+RQM
J22_7:
        IN      AL,DX           ; READ STATUS PORT
        TEST    AL,CH           ; IS THE FEC STILL IN THE EXECUTION
                                ; PHASE?
        JZ      OP_END          ; JUMP IF EXECUTION PHASE IS DONE.
        TEST    AL,CL           ; IS THE DATA PORT READY FOR THE
                                ; TRANSFER?
        JZ      J22_7           ; JUMP TO WRITE DATA
        INC     DX              ; POINT AT DATA REGISTER
        LODSB                   ; TRANSFER BYTE
        OUT     DX,AL           ; WRITE THE BYTE ON THE DISKETTE
        DEC     DX              ; POINT AT THE STATUS REGISTER
        JMP     J22_7           ; CONTINUE WITH WRITE OR FORMAT

;------TRANSFER PROCESS IS OVER
OP_END: PUSHF                   ; SAVE THE CARRY BIT SET IN
                                ; DISK_INT
        CALL    GET_DRIVE       ; GET BIT MASK FOR DRIVE SELECTION
        OR      AL,FDC_RESET    ; NO RESET, KEEP DRIVE SPINNING
        MOV     DX,NEC_CTL      ;
        OUT     DX,AL           ; DISABLE WATCHDOG

;------UPDATE TIME OF DAY
        CALL    DDS             ; POINT DS AT BIOS DATA SEGMENT
        CALL    CLOCK_WAIT      ; WAIT IF TIMER0 IS CLOSE TO
                                ; WRAPPING
        CALL    READ_TIME
        MOV     BX,[BP+18]      ; GET THE INITIAL VALUE OF TIMER1
        SUB     AX,BX           ; UPDATE NUMBER OF INTERRUPTS
                                ; MISSED
        NEG     AX              ; PUT IT IN AX
        PUSH    AX              ; SAVE IT FOR REUSE IN ISSUING USER
                                ; TIMER INTERRUPTS
        ADD     TIMER_LOW,AX    ; ADD NUMBER OF TIMER INTERRUPTS TO
                                ; TIME
        JNC     J16_4           ; JUMP IF TIMER_LOW DID NOT SPILL
                                ; OVER TO TIMER_HI
        INC     TIMER_HIGH
J16_4:  CMP     TIMER_HIGH,018H ; TEST FOR COUNT TOTALING 24 HOURS
        JNZ     J16_5           ; JUMP IF NOT 24 HOURS
        CMP     TIMER_LOW,0B0H  ; LOW VALUE = 24 HOUR VALUE?
        JL      J16_5           ; NOT 24 HOUR VALUE?

;------TIMER HAS GONE 24 HOURS
        MOV     TIMER_HIGH,0    ; ZERO OUT TIMER_HIGH VALUE
        SUB     TIMER_LOW,0B0H  ; VALUE REFLECTS CORRECT TICKS PAST
                                ; 00B0H
        MOV     TIMER_OFL,1     ; INDICATES 24 HOUR THRESHOLD
J16_5:  CALL    ENABLE          ; ENABLE ALL INTERRUPTS
        POP     CX              ; CX:=AX, COUNT FOR NUMBER OF USER
                                ; TIME INTERRUPTS
        JCXZ    J16_7           ; IF ZERO DO NOT ISSUE ANY
                                ; INTERRUPTS
        PUSH    DS              ; SAVE ALL REGISTERS SAVED PRIOR TO
                                ; INT 1C CALL FROM TIMERINT
        PUSH    AX              ; THIS PROVIDES A COMPATIBLE
                                ; INTERFACE TO 1C
        PUSH    DX              ;
J16_6:  INT     1CH             ; TRANSFER CONTROL TO USER
                                ; INTERRUPT
        LOOP    J16_6           ; DO ALL USER TIMER INTERRUPTS
        POP     DX
        POP     AX
        POP     DS              ; RESTORE REGISTERS

;------CLOCK IS UPDATED AND USER INTERRUPTS 1C HAVE BEEN ISSUED.
;       CHECK IF KEYSTROKE OCCURED
        OR      AL,AL           ; AL WAS SET DURING CALL TO ENABLE
        JZ      J16_7           ; NO KEY WAS PRESSED WHILE SYSTEM
                                ; WAS MASKED

        MOV     BX,080H         ; DURATION OF TONE
        MOV     CX,048H         ; FREQUNCY OF TONE
        CALL    KB_NOISE        ; NOTIFY USER OF MISSED KEYBORAD
                                ; INPUT
        AND     KB_FLAG,0F0H    ; CLEAR ALT,CTRL,LEFT AND RIGHT
                                ;       SHIFTS
        AND     KB_FLAG_1,0FH   ; CLEAR POTENTIAL BREAK OF INS,CAPS
                                ;       NUM AND SCROLL SHIFT
        AND     KB_FLAG_2,1FH   ; CLEAR FUNCTION STATES
J16_7:  POPF                    ; GET THE FLAGS
J17:
        JC      J20
        CALL    RESULTS         ; GET THE NEC STATUS
        JC      J20             ; LOOK FOR ERROR

;-------CHECK THE RESULTS RETURNED BY THE CONTROLLER
        CLD                     ; SET THE CORRECT DIRECTION
        MOV     SI,OFFSET NEC_STATUS ; POINT TO STATUS FIELD
        LODS    NEC_STATUS      ; GET ST0
        AND     AL,0C0H         ; TEST FOR NORMAL TERMINATION
        JZ      J22             ; OPN_OK
        CMP     AL,040H         ; TEST FOR ABNORMAL TERMINATION
        JNZ     J18             ; NOT ABNORMAL, BAD NEC
;--------------------------------------------------------
;***NOTE***
;       THE CURRENT SYSTEM CONFIGURATION HAS NO DMA.  IN ORDER TO
;       STOP THE NEC AN EOT MUST BE PASSED TO FORCE THE NEC TO HALT
;       THEREFORE, THE STATUS RETURNED BY THE NEC WILL ALWAYS SHOW
;       AN EOT ERROR.  IF THIS IS THE ONLY ERROR RETURNED AND THE
;       NUMBER OF SECTORS TRANSFERRED EQUALS THE NUMBER SECTORS
;       REQUESTED IN THIS INTERRUPT CALL THEN THE OPERATION HAS
;       COMPLETED SUCCESSFULLY.  IF AN EOT ERROR IS RETURNED AND THE
;       REQUESTED NUMBER OF SECTORS IS NOT THE NUMBER OF SECTORS
;       TRANSFERRED THEN THE ERROR IS LEGITIMATE.  WHEN THE EOT
;       ERROR IS INVALID THE STATUS BYTES RETURNED ARE UPDATED TO
;       REFLECT THE STATUS OF THE OPERATION IF DMA HAD BEEN PRESENT
;--------------------------------------------------------
        LODS    NEC_STATUS      ; GET ST1
        CMP     AL,80H          ; IS THIS THE ONLY ERROR?
        JE      J21_1           ; NORMAL TERMINATION, NO ERROR
        SAL     AL,1            ; NOT EOT ERROR, BYPASS ERROR BITS
        SAL     AL,1
        SAL     AL,1            ; TEST FOR CRC ERROR
        MOV     AH,BAD_CRC
        JC      J19             ; RW_FAIL
        SAL     AL,1            ; TEST FOR DMA OVERRUN
        MOV     AH,BAD_DMA
        JC      J19             ; RW_FAIL
        SAL     AL,1            ; TEST FOR RECORD NOT FOUND
        SAL     AL,1
        MOV     AH,RECORD_NOT_FND
        JC      J19             ; RW_FAIL
        SAL     AL,1            ; TEST MISSING ADDRESS MARK
        SAL     AL,1
        MOV     AH,BAD_ADDR_MARK
        JC      J19             ; RW_FAIL

;-------NEC MUST HAVE FAILED
J18:
        MOV     AH,BAD_NEC      ; RW-NEC-FAIL
J19:    OR      DISKETTE_STATUS,AH
        CALL    NUM_TRANS       ; HOW MANY WERE REALLY TRANSFERRED
J20:                            ; RW_ERR
        RET                     ; RETURN TO CALLER

;-------OPERATION WAS SUCCESSFUL
J21_1:
        MOV     BL,[BP+14]      ; GET NUMBER OF SECTORS PASSED
                                ;       FROM STACK
        CALL    NUM_TRANS       ; HOW MANY GOT MOVED, AL CONTAINS
                                ;       NUM OF SECTORS
        CMP     BL,AL           ; NUMBER REQUESTED=NUMBER ACTUALLY
                                ;       TRANSFERRED?
        JE      J21_2           ; TRANSFER SUCCESSFUL
;-------OPERATION ATTEMPTED TO ACCESS DATA PAST REAL EOT.  THIS IS
;       A REAL ERROR
        OR      DISKETTE_STATUS,RECORD_NOT_FND
        MOV     NEC_STATUS+1,80H ; ST1 GETS CORRECT VALUE
        STC
        RET
J21_2:  XOR     AX,AX           ; CLEAR AX FOR NEC_STATUS UPDATE
        XOR     SI,SI           ; INDEX TO NEC_STATUS ARRAY
        MOV     NEC_STATUS[SI],AL ; ZERO OUT BYTE, ST0
        INC     SI              ; POINT INDEX AT SECOND BYTE
        MOV     NEC_STATUS[SI],AL ; ZERO OUT BYTE, ST1
        JMP     SHORT J21_3     ; OPN_OK
J22:    CALL    NUM_TRANS
J21_3:  XOR     AH,AH           ; NO ERRORS
        RET
RW_OPN  ENDP
;--------------------------------------------------------
; DISK_INT
;       THIS ROUTINE HANDLES THE DISKETTE INTERRUPT.  AN INTERRUPT
;       WILL OCCUR ONLY WHEN THE ONE-SHOT TIMER IS FIRED.  THIS
;       OCCURS IN AN ERROR SITUATION.  THIS ROUTINE SETS ERRORS IN
;       THE DISKETTE STATUS BYTE AND DISABLES THE ONE-SHOT TIMER.
;       THEN THE RETURN ADDRESS ON THE STACK IS CHANGED TO RETURN
;       TO THE OP_END LABEL.
;
; INPUT
;       NONE.
;
; OUTPUT
;       NONE.  DS POINTS AT BIOS DATA AREA.  CARRY FLAG IS SET SO
;       THAT ERROR WILL BE CAUGHT IN THE ENVIRONMENT RETURNED TO.
;--------------------------------------------------------
        ORG     0EF57H
DISK_INT        PROC    FAR
        PUSH    DS
        PUSH    AX
        PUSH    DX              ; SAVE REGISTER
        PUSH    BP              ; SAVE THE BP REGISTER
        CALL    DDS             ; SETUP DS TO POINT AT BIOS DATA
;------- CHECK IF INTERRUPT OCCURED IN INT13 OR WHETHER IT IS A
;       SPURIOUS INTERRUPT
        MOV     BP,SP           ; POINT BP AT STACK
        PUSH    CS              ; WAS IT IN THE BIOS AREA
        POP     AX
        CMP     AX,WORD PTR[BP+10] ; GET INTERRUPTED SEGMENT
        JNE     DI3             ; NOT IN BIOS, ERROR CONDITION
        MOV     AX,WORD PTR[BP+8] ; GET IP ON THE STACK
        CMP     AX,OFFSET VERIFY_LOOP ; RANGE CHECK IP FOR DISK
                                ;       TRANSFER
        JL      DI3             ; BELOW TRANSFER CODE
        CMP     AX,OFFSET OP_END+1 ; UPPER RANGE OF TRANSFER CODE
        JGE     DI3             ; ABOVE RANGE OF WATCHDOG TERRAIN
;-------VALID DISKETTE INTERRUPT CHANGE RETURN ADDRESS ON STACK TO
;       PULL OUT OF LOOP
        MOV     WORD PTR[BP+8],OFFSET OP_END
        OR      WORD PTR[BP+12],1 ; TURN ON CARRY FLAG IN FLAGS ON
                                ;       STACK
;------------------------------------------------------------
;***NOTE***
; A WRITE PROTECTED DISKETTE WILL ALWAYS GET STUCK IN WRITE LOOP
; WAITING FOR BEGINNING OF EXECUTION PHASE.  WHEN THE WATCHDOG
; FIRES AND THE STATUS IN PORT NEC_STAT = DXH (X MEANS DON'T CARE)
; STATUS FROM THE RESULT PHASE IS AVAILABLE.  THE STATUS IS READ
; AND WRITE PROTECT IS CHECKED FOR.
;------------------------------------------------------------
        MOV     DX,NEC_STAT
        IN      AL,DX           ; GET NEC STATUS BYTE
        AND     AL,0F0H         ; MASK HIGH NIBBLE
        CMP     AL,0D0H         ; IS EXECUTION PHASE DONE
        JNE     DI1             ; STUCK IN LOOP
        CALL    RESULTS         ; GET STATUS OF OPERATION
        MOV     SI,OFFSET NEC_STATUS ; ADDRESS OF BYTES RETURNED BY
                                ;       NEC
        MOV     AL,[SI+1]       ; GET ST1
        TEST    AL,02H          ; WRITE PROTECT SIGNAL ACTIVE?
        JZ      DI1             ; TIME OUT ERROR
        OR      DISKETTE_STATUS,WRITE_PROTECT
        JMP     SHORT DI3
;-------TIME OUT ERROR
DI1:    OR      DISKETTE_STATUS,TIME_OUT
        MOV     SEEK_STATUS,0   ; SET RECAL ON DRIVES
;------- RESET THE NEC AND DISABLE WATCHDOG
DI2:    MOV     DX,NEC_CTL      ; ADDRESS TO NEC CONTROL PORT
        POP     BP              ; POINT BP AT BASE OF STACKED
                                ;       PARAMETERS
        CALL    GET_DRIVE       ; RESET ADAPTER AND DISABLE WD
        PUSH    BP              ; RESTORE FOR RETURNED CALL
        OUT     DX,AL
DI3:    MOV     AL,EOI           ; GIVE EOI TO 8259
        OUT     INTA00,AL
        POP     BP
        POP     DX
        POP     AX
        POP     DS
        IRET                    ; RETURN FROM INTERRUPT
DISK_INT        ENDP
;------------------------------------------------------------
; DISK_BASE
; THIS IS THE SET OF PARAMETERS REQUIRED FOR
; DISKETTE OPERATION.  THEY ARE POINTED AT BY THE
; DATA VARIABLE DISK_POINTER.  TO MODIFY THE PARAMETERS,
; BUILD ANOTHER PARAMETER BLOCK AND POINT AT IT
;------------------------------------------------------------
        ORG     0EFC7H
DISK_BASE       LABEL   BYTE
        DB      11001111B       ; SRT=C, HD UNLOAD=0F - 1ST SPECIFY
                                ; BYTE
        DB      3               ; HD LOAD=1, MODE=NO DMA - 2ND
                                ; SPECIFY BYTE
        DB      MOTOR_WAIT      ; WAIT AFTER OPN TIL MOTOR OFF
        DB      2               ; 512 BYTES/SECTOR
        DB      8               ; EOT ( LAST SECTOR ON TRACK)
        DB      02AH            ; GAP LENGTH
        DB      0FFH            ; DTL
        DB      050H            ; GAP LENGTH FOR FORMAT
        DB      0F6H            ; FILL BYTE FOR FORMAT
        DB      25              ; HEAD SETTLE TIME (MILLISECONDS)
        DB      4               ; MOTOR START TIME (1/8 SECONDS)
;--- INT 17 --------------------------------------------------------------
; PRINTER_IO
;       THIS ROUTINE PROVIDES COMMUNICATION WITH THE PRINTER
;       (AH)=0   PRINT THE CHARACTER IN (AL)
;               ON RETURN, AH=1 IF CHARACTER COULD NOT BE PRINTED
;               (TIME OUT), OTHER BITS SET AS ON NORMAL STATUS CALL
;       (AH)=1   INITIALIZE THE PRINTER PORT
;               RETURNS WITH (AH) SET WITH PRINTER STATUS
;       (AH)=2   READ THE PRINTER STATUS INTO (AH)
;               7       6       5       4       3       2-1     0
;               .       .       .       .       .       .       ._ TIME OUT
;               .       .       .       .       .       ._ UNUSED
;               .       .       .       .       ._ 1 = I/O ERROR
;               .       .       .       ._ 1 = SELECTED
;               .       .       ._ 1 = OUT OF PAPER
;               .       ._ 1 = ACKNOWLEDGE
;               ._ 1 = NOT BUSY
;
;       (DX) = PRINTER TO BE USED (0,1,2) CORRESPONDING TO ACTUAL
;               VALUES IN PRINTER_BASE AREA
;       DATA AREA PRINTER_BASE CONTAINS THE BASE ADDRESS OF THE PRINTER
;       CARD(S) AVAILABLE (LOCATED AT BEGINNING OF DATA SEGMENT, 408H
;       ABSOLUTE, 3 WORDS), UNLESS THERE IS ONLY A SERIAL PRINTER
;       ATTACHED, IN WHICH CASE THE WORD AT 40:8 WILL CONTAIN A 02F8H.
;       REGISTERS       AH IS MODIFIED
;                       ALL OTHERS UNCHANGED
;-----------------------------------------------------------------------
ASSUME  CS:CODE,DS:DATA
        ORG     0EFD2H
PRINTER_IO      PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE SEGMENT
        PUSH    DX
        PUSH    SI
        PUSH    CX
        PUSH    BX
        CALL    DDS
;REDIRECT TO SERIAL ONLY IF:
;   1) SERIAL PRINTER IS ATTACHED, AND...
;   2) WORD AT PRINTER BASE = 02F8H.
; POWER ONS WILL ONLY PUT A 02F8H IN THE PRINTER BASE IF THERE'S
; NO PARALLEL PRINTER ATTACHED.
        MOV     CX,EQUIP_FLAG   ; GET FLAG IN CX
        TEST    CH,00100000B    ; SERIAL ATTACHED?
        JZ      B0              ; NO -HANDLE NORMALLY
        MOV     BX,PRINTER_BASE ; SEE IF THERE'S AN RS232
        CMP     BX,02F8H        ; BASE IN THE PRINTER BASE.
        JNE     B0
B00:    JMP     B1_A            ; IF THERE IS REDIRECT
; ELSE... HANDLE AS PARALLEL
;CONTROL IS PASSED TO THIS POINT IF THERE IS A PARALLEL OR
;THERE'S NO SERIAL PRINTER ATTACHED.
B0:     MOV     SI,DX           ; GET PRINTER PARM
        MOV     BL,PRINT_TIM_OUT[SI] ; LOAD TIMEOUT VALUE
        SHL     SI,1            ; WORD OFFSET INTO TABLE
        MOV     DX,PRINTER_BASE[SI] ; GET BASE ADDRESS FOR PRINTER
                                ; CARD
        OR      DX,DX           ; TEST DX FOR ZERO, INDICATING NO
                                ; PRINTER
        JZ      B1              ; IF NO PARALLEL, RETURN
        OR      AH,AH           ; TEST FOR (AH)=0
        JZ      B2              ; PRINT_AL
        DEC     AH              ; TEST FOR (AH)=1
        JZ      B8              ; INIT_PRT
        DEC     AH              ; TEST FOR (AH)=2
        JZ      B5              ; PRINTER STATUS
B1:                             ; RETURN
        POP     BX
        POP     CX
        POP     SI              ; RECOVER REGISTERS
        POP     DX              ; RECOVER REGISTERS
        POP     DS
        IRET
;------- PRINT THE CHARACTER IN (AL)
B2:     PUSH    AX              ; SAVE VALUE TO PRINT
        OUT     DX,AL           ; OUTPUT CHAR TO PORT
        INC     DX              ; POINT TO STATUS PORT
;
;-------WAIT BUSY
B3:     SUB     CX,CX           ; INNER LOOP (64K)
B3_1:   IN      AL,DX           ; GET STATUS
        MOV     AH,AL           ; STATUS TO AH ALSO
        TEST    AL,80H          ; IS THE PRINTER CURRENTLY BUSY
        JNZ     B4              ; OUT_STROBE
        LOOP    B3_1            ; LOOP IF NOT
        DEC     BL              ; DROP OUTER LOOP COUNT
        JNZ     B3              ; MAKE ANOTHER PASS IF NOT ZERO
        OR      AH,1            ; SET ERROR FLAG
        AND     AH,0F9H         ; TURN OFF THE UNUSED BITS
        JMP     SHORT B7        ; RETURN WITH ERROR FLAG SET
; OUT_STROBE
B4:     MOV     AL,0DH          ; SET THE STROBE HIGH
        INC     DX
        OUT     DX,AL
        MOV     AL,0CH          ; SET THE STROBE LOW
        OUT     DX,AL
        POP     AX              ; RECOVER THE OUTPUT CHAR
;------- PRINTER STATUS
B5:     PUSH    AX              ; SAVE AL REG
B6:     MOV     DX,PRINTER_BASE[SI]
        INC     DX
        IN      AL,DX           ; GET PRINTER STATUS
        MOV     AH,AL
        AND     AH,0F8H         ; TURN OFF UNUSED BITS
B7:     POP     DX              ; RECOVER AL REG
        MOV     AL,DL           ; GET CHARACTER INTO AL
        XOR     AH,48H          ; FLIP A COUPLE OF BITS
        JMP     B1              ; RETURN FROM ROUTINE
;------- INITIALIZE THE PRINTER PORT
B8:     PUSH    AX              ; SAVE AL
        INC     DX              ; POINT TO OUTPUT PORT
        INC     DX
        MOV     AL,8            ; SET INIT LINE LOW
        OUT     DX,AL
        MOV     AX,1000
B9:     DEC     AX              ; LOOP FOR RESET TO TAKE
        JNZ     B9              ; INIT_LOOP
        MOV     AL,0CH          ; NO INTERRUPTS, NON AUTO LF, INIT
        OUT     DX,AL           ; HIGH
        JMP     B6              ; PRT_STATUS_1
PRINTER_IO      ENDP
        ORG     0F065H
        JMP     NEAR PTR VIDEO_IO
;---------------------------------------------------------
; SUBROUTINE TO SAVE ANY SCAN CODE RECEIVED
; BY THE NMI ROUTINE (PASSED IN AL)
; DURING POST IN THE KEYBOARD BUFFER
; CALLED THROUGH INT. 48H
;---------------------------------------------------------
KEY_SCAN_SAVE   PROC    FAR
ASSUME  DS:DATA
        CALL    DDS             ; POINT DS TO DATA AREA
        MOV     SI,OFFSET KB_BUFFER ; POINT TO FIRST LOC. IN BUFFER
        MOV     [SI],AL         ; SAVE SCAN CODE
        MOV     AX,SP           ; CHECK FOR STACK UNDERFLOW
        AND     AH,11100000B    ; (THESE BITS WILL BE 111 IF
        JZ      KS_1            ;  UNDERFLOW HAPPEND)
        XOR     AL,AL
        OUT     0A0H,AL         ; SHUT OFF NMI
        MOV     BX,2000H        ; ERROR CODE 2000H
        MOV     SI,OFFSET KEY_ERR ; POST MESSAGE
        CALL    E_MSG           ; AND HALT SYSTEM
KS_1:   IRET                    ; RETURN TO CALLER
KEY_SCAN_SAVE   ENDP
;---------------------------------------------------------
; SUBROUTINE TO SET AN INS8250 CHIP'S BAUD RATE TO 9600 BPS AND
; DEFINE IT'S DATA WORD AS HAVING 8 BITS/WORD, 2 STOP BITS, AND
; ODD PARITY.
;
; EXPECTS TO BE PASSED:
;   (DX) = LINE CONTROL REGISTER
;
; UPON RETURN:
;   (DX) = TRANSMIT/RECEIVE BUFFER ADDRESS
;
; ALSO, ALTERS REGISTER AL.  ALL OTHERS REMAIN INTACT.
;---------------------------------------------------------
S8250           PROC    NEAR
        MOV     AL,80H          ; SET DLAB = 1
        OUT     DX,AL
        JMP     $+2             ; I/O DELAY
        SUB     DX,3            ; LSB OF DIVISOR LATCH
        MOV     AL,12           ; DIVISOR = 12 PRODUCES 9600 BPS
        OUT     DX,AL           ; SET LSB
        JMP     $+2             ; I/O DELAY
        INC     DX              ; MSB OF DIVISOR LATCH
        MOV     AL,0            ; HIGH ORDER OF DIVISORS
        OUT     DX,AL           ; SET MSB
        JMP     $+2             ; I/O DELAY
        INC     DX
        INC     DX              ; LINE CONTROL REGISTER
        MOV     AL,00001111B    ; 8 BITS/WORD, 2 STOP BITS, ODD
                                ; PARITY
        OUT     DX,AL
        JMP     $+2             ; I/O DELAY
        SUB     DX,3            ; RECEIVER BUFFER
        IN      AL,DX           ; IN CASE WRITING TO PORT LCR
                                ; CAUSED DATA READY TO GO HIGH!
        RET
S8250           ENDP
;------- TABLES FOR USE IN SETTING OF CRT MODE
        ORG     0F0A4H
VIDEO_PARMS     LABEL   BYTE
;------- INIT_TABLE
        DB      38H,28H,2CH,06H,1FH,6,19H ; SETUP FOR 40X25

        DB      1CH,2,7,6,7
        DB      0,0,0,0
M0040   EQU     $-VIDEO_PARMS
        DB      71H,50H,5AH,0CH,1FH,6,19H ; SETUP FOR 80X25

        DB      1CH,2,7,6,7
        DB      0,0,0,0

        DB      38H,28H,2BH,06H,7FH,6,64H ; SET UP FOR GRAPHICS

        DB      70H,2,1,26H,7
        DB      0,0,0,0

        DB      71H,50H,56H,0CH,3FH,6,32H ; SET UP FOR GRAPHICS

        DB      38H,2,3,26H,7    ; USING 32K OF MEMORY
        DB      0,0,0,0          ; (MODES 9 & A)

;------------------------------------------------
; READ_AC_CURRENT
; THIS ROUTINE READS THE ATTRIBUTE AND CHARACTER AT THE
; CURRENT CURSOR POSITION AND RETURNS THEM TO THE CALLER
;
; INPUT
;       (AH) = CURRENT CRT MODE
;       (BH) = DISPLAY PAGE ( ALPHA MODES ONLY )
;       (DS) = DATA SEGMENT
;       (ES) = REGEN SEGMENT
;
; OUTPUT
;       (AL) = CHAR READ
;       (AH) = ATTRIBUTE READ
;------------------------------------------------
ASSUME  CS:CODE,DS:DATA,ES:DATA
READ_AC_CURRENT PROC    NEAR
        CMP     AH,4            ; IS THIS GRAPHICS?
        JC      C60
        JMP     GRAPHICS_READ
C60:                            ; READ_AC_CONTINUE
        CALL    FIND_POSITION
        MOV     SI,BX           ; ESTABLISH ADDRESSING IN SI
        PUSH    ES
        POP     DS              ; GET SEGMENT FOR QUICK ACCESS
        LODSW                   ; GET THE CHAR/ATTR
        JMP     VIDEO_RETURN
READ_AC_CURRENT ENDP
FIND_POSITION   PROC    NEAR
        MOV     CL,BH           ; DISPLAY PAGE TO CX
        XOR     CH,CH
        MOV     SI,CX           ; MOVE TO SI FOR INDEX
        SAL     SI,1            ; * 2 FOR WORD OFFSET
        MOV     AX,[SI+ OFFSET CURSOR_POSN] ; GET ROW/COLUMN OF
                                ; THAT PAGE
        XOR     BX,BX           ; SET START ADDRESS TO ZERO
        JCXZ    C62             ; NO_PAGE
C61:                            ; PAGE_LOOP
        ADD     BX,CRT_LEN      ; LENGTH OF BUFFER
        LOOP    C61
C62:                            ; NO_PAGE
        CALL    POSITION        ; DETERMINE LOCATION IN REGEN
        ADD     BX,AX           ; ADD TO START OF REGEN
        RET
FIND_POSITION   ENDP
;------------------------------------------------
; WRITE_AC_CURRENT
; THIS ROUTINE WRITES THE ATTRIBUTE AND CHARACTER AT
; THE CURRENT CURSOR POSITION
;
; INPUT
;       (AH) = CURRENT CRT MODE
;       (BH) = DISPLAY PAGE
;       (CX) = COUNT OF CHARACTERS TO WRITE
;       (AL) = CHAR TO WRITE
;       (BL) = ATTRIBUTE OF CHAR TO WRITE
;       (DS) = DATA SEGMENT
;       (ES) = REGEN SEGMENT
;
; OUTPUT
;       NONE
;------------------------------------------------
WRITE_AC_CURRENT PROC   NEAR
        CMP     AH,4            ; IS THIS GRAPHICS?
        JC      C63
        JMP     GRAPHICS_WRITE
C63:                            ; WRITE_AC_CONTINUE
        MOV     AH,BL           ; GET ATTRIBUTE TO AH
        PUSH    AX              ; SAVE ON STACK
        PUSH    CX              ; SAVE WRITE COUNT
        CALL    FIND_POSITION
        MOV     DI,BX           ; ADDRESS TO DI REGISTER
        POP     CX              ; WRITE COUNT
        POP     AX              ; CHARACTER IN AX REG
C64:                            ; WRITE_LOOP
        STOSW                   ; PUT THE CHAR/ATTR
        LOOP    C64             ; AS MANY TIMES AS REQUESTED
        JMP     VIDEO_RETURN
WRITE_AC_CURRENT ENDP
;------------------------------------------------
; WRITE_C_CURRENT
;
; THIS ROUTINE WRITES THE CHARACTER AT
; THE CURRENT CURSOR POSITION, ATTRIBUTE UNCHANGED
;
; INPUT --
;     (AH) = CURRENT CRT MODE
;     (BH) = DISPLAY PAGE
;     (CX) = COUNT OF CHARACTERS TO WRITE
;     (AL) = CHAR TO WRITE
;     (DS) = DATA SEGMENT
;     (ES) = REGEN SEGMENT
;
; OUTPUT
;
;     NONE
;------------------------------------------------
WRITE_C_CURRENT PROC   NEAR
        CMP     AH,4            ; IS THIS GRAPHICS?
        JC      C65
        JMP     GRAPHICS_WRITE
C65:    PUSH    AX              ; SAVE ON STACK
        PUSH    CX              ; SAVE WRITE COUNT
        CALL    FIND_POSITION
        MOV     DI,BX           ; ADDRESS TO DI
        POP     CX              ; WRITE COUNT
        POP     BX              ; BL HAS CHAR TO WRITE
C66:
        MOV     AL,BL           ; RECOVER CHAR
        STOSB                   ; PUT THE CHAR/ATTR
        INC     DI              ; BUMP POINTER PAST ATTRIBUTE
        LOOP    C66             ; AS MANY TIMES AS REQUESTED
        JMP     VIDEO_RETURN
WRITE_C_CURRENT ENDP
;------------------------------------------------
; READ DOT -- WRITE DOT
;
; THESE ROUTINES WILL WRITE A DOT, OR READ THE
; DOT AT THE INDICATED LOCATION
;
; ENTRY --
;     DX = ROW (0-199)     (THE ACTUAL VALUE DEPENDS ON THE MODE)
;     CX = COLUMN ( 0-639) ( THE VALUES ARE NOT RANGE CHECKED )
;     AL = DOT VALUE TO WRITE (1,2 OR 4 BITS DEPENDING ON MODE,
;          REQ'D FOR WRITE DOT ONLY, RIGHT JUSTIFIED)
;          BIT 7 OF AL = 1 INDICATES XOR THE VALUE INTO THE LOCATION
;     DS = DATA SEGMENT
;     ES = REGEN SEGMENT
;
; EXIT
;
;     AL = DOT VALUE READ, RIGHT JUSTIFIED, READ ONLY
;------------------------------------------------
ASSUME  CS:CODE,DS:DATA,ES:DATA
READ_DOT        PROC    NEAR
        CMP     CRT_MODE,0AH    ; 640X200 4 COLOR?
        JE      READ_ODD        ; YES, HANDLE SEPARATELY
        CALL    C72             ; DETERMINE BYTE POSITION OF DOT
        MOV     AL,ES:[SI]      ; GET THE BYTE
        AND     AL,AH           ; MASK OFF THE OTHER BITS IN THE
                                ; BYTE
        SHL     AL,CL           ; LEFT JUSTIFY THE VALUE
        MOV     CL,DH           ; GET NUMBER OF BITS IN RESULT
        ROL     AL,CL           ; RIGHT JUSTIFY THE RESULT
        JMP     VIDEO_RETURN    ; RETURN FROM VIDEO IO
; IN 640X200 4 COLOR MODE, THE 2 COLOR BITS (C1,C0) ARE DIFFERENT
; THAN OTHER MODES. C0 IS IN THE EVEN BYTE, C1 IS IN THE FOLLOWING
; ODD BYTE - BOTH AT THE SAME BIT POSITION WITHIN THEIR RESPECTIVE
; BYTES.
READ_ODD:
        CALL    C72             ; DETERMINE POSITION OF DOT
        PUSH    DX              ; SAVE INFO
        PUSH    CX
        PUSH    AX
        MOV     AL,ES:[SI+1]    ; GET C1 COLOR BIT FROM ODD BYTE
        AND     AL,AH           ; MASK OFF OTHER BITS
        SHL     AL,CL           ; LEFT JUSTIFY THE VALUE
        MOV     CL,DH           ; GET NUMBER OF BITS IN RESULT
        INC     CL
        ROL     AL,CL           ; RIGHT JUSTIFY THE RESULT
        MOV     BX,AX           ; SAVE IN BX REG
        POP     AX              ; RESTORE POSITION INFO
        POP     CX
        POP     DX
        MOV     AL,ES:[SI]      ; GET C0 COLOR BIT FROM EVEN BYTE
        AND     AL,AH           ; MASK OFF OTHER BITS
        SHL     AL,CL           ; LEFT JUSTIFY THE VALUE
        MOV     CL,DH           ; GET NUMBER OF BITS IN RESULT
        ROL     AL,CL           ; RIGHT JUSTIFY THE RESULT
        OR      AL,BL           ; COMBINE C1 & C0
        JMP     VIDEO_RETURN
READ_DOT        ENDP
WRITE_DOT       PROC    NEAR
        PUSH    CX              ; SAVE COL
        PUSH    DX              ; SAVE ROW
        PUSH    AX              ; SAVE DOT VALUE
        PUSH    AX              ; TWICE
        CALL    C72             ; DETERMINE BYTE POSITION OF THE
                                ; DOT
        SHR     AL,CL           ; SHIFT TO SET UP THE BITS FOR
                                ; OUTPUT
        AND     AL,AH           ; STRIP OFF THE OTHER BITS
        MOV     CL,ES:[SI]      ; GET THE CURRENT BYTE
        POP     BX              ; RECOVER XOR FLAG
        TEST    BL,80H          ; IS IT ON
        JNZ     C70             ; YES, XOR THE DOT
        NOT     AH              ; SET THE MASK TO REMOVE THE
                                ; INDICATED BITS
        AND     CL,AH
        OR      AL,CL           ; OR IN THE NEW VALUE OF THOSE BITS
C67:                            ; FINISH_DOT
        MOV     ES:[SI],AL      ; RESTORE THE BYTE IN MEMORY
        POP     AX
        POP     DX              ; RECOVER ROW
        POP     CX              ; RECOVER COL
        CMP     CRT_MODE,0AH    ; 640X200 4 COLOR?
        JNE     C69             ; NO,JUMP
        PUSH    AX              ; SAVE DOT VALUE
        PUSH    AX              ; TWICE
        SHR     AL,1            ; SHIFT C1 BIT INTO C0 POSITION
        CALL    C72             ; DETERMINE BYTE POSITION OF THE
                                ; DOT
        SHR     AL,CL           ; SHIFT TO SET UP THE BITS FOR
                                ; OUTPUT
        AND     AL,AH           ; STRIP OFF THE OTHER BITS
        MOV     CL,ES:[SI+1]    ; GET THE CURRENT BYTE
        POP     BX              ; RECOVER XOR FLAG
        TEST    BL,80H          ; IS IT ON
        JNZ     C71             ; YES, XOR THE DOT
        NOT     AH              ; SET THE MASK TO REMOVE THE
                                ; INDICATED BITS
        AND     CL,AH
        OR      AL,CL           ; OR IN THE NEW VALUE OF THOSE BITS
C68:                            ; FINISH_DOT
        MOV     ES:[SI+1],AL    ; RESTORE THE BYTE IN MEMORY
        POP     AX
C69:    JMP     VIDEO_RETURN    ; RETURN FROM VIDEO IO
C70:    XOR     AL,CL           ; XOR DOT
        JMP     C67             ; FINISH UP THE WRITING
C71:    XOR     AL,CL           ; EXCLUSIVE OR THE DOTS
        JMP     C68             ; FINISH UP THE WRITING
WRITE_DOT       ENDP
;----------------------------------------------------------
; THIS SUBROUTINE DETERMINES THE REGEN BYTE LOCATION OF THE
; INDICATED ROW COLUMN VALUE IN GRAPHICS MODE.
; ENTRY --
;        DX = ROW VALUE (0-199)
;        CX = COLUMN VALUE (0-639)
; EXIT --
;        SI = OFFSET INTO REGEN BUFFER FOR BYTE OF INTEREST
;        AH = MASK TO STRIP OFF THE BITS OF INTEREST
;        CL = BITS TO SHIFT TO RIGHT JUSTIFY THE MASK IN AH
;        DH = # BITS IN RESULT
;----------------------------------------------------------
C72             PROC    NEAR
        PUSH    BX              ; SAVE BX DURING OPERATION
        PUSH    AX              ; WILL SAVE AL DURING OPERATION
;------- DETERMINE 1ST BYTE IN INDICATED ROW BY MULTIPLYING ROW VALUE
;       BY 40( LOW BIT OF ROW DETERMINES EVEN/ODD, 80 BYTES/ROW
        MOV     AL,40
        PUSH    DX              ; SAVE ROW VALUE
        AND     DL,0FEH         ; STRIP OFF ODD/EVEN BIT
        CMP     CRT_MODE,09H    ; MODE USING 32K REGEN?
        JC      C73             ; NO, JUMP
        AND     DL,0FCH         ; STRIP OFF LOW 2 BITS
C73:    MUL     DL              ; AX HAS ADDRESS OF 1ST BYTE OF
                                ; INDICATED ROW
        POP     DX              ; RECOVER IT
        TEST    DL,1            ; TEST FOR EVEN/ODD
        JZ      C74             ; JUMP IF EVEN ROW
        ADD     AX,2000H        ; OFFSET TO LOCATION OF ODD ROWS
C74:                            ; EVEN_ROW
        CMP     CRT_MODE,09H    ; MODE USING 32K REGEN?
        JC      C75             ; NO, JUMP
        TEST    DL,2            ; TEST FOR ROW 2 OR ROW 3
        JZ      C75             ; JUMP IF ROW 0 OR 1
        ADD     AX,4000H        ; OFFSET TO LOCATION OF ROW 2 OR 3
C75:    MOV     SI,AX           ; MOVE POINTER TO SI
        POP     AX              ; RECOVER AL VALUE
        MOV     DX,CX           ; COLUMN VALUE TO DX
;------- DETERMINE GRAPHICS MODE CURRENTLY IN EFFECT
; SET UP THE REGISTERS ACCORDING TO THE MODE
; CH = MASK FOR LOW OF COLUMN ADDRESS ( 7/3/1 FOR HIGH/MED/LOW RES)
; CL = # OF ADDRESS BITS IN COLUMN VALUE ( 3/2/1 FOR H/M/L)
; BL = MASK TO SELECT BITS FROM POINTED BYTE (80H/C0H/F0H FOR H/M/L)
; BH = NUMBER OF VALID BITS IN POINTED BYTE ( 1/2/4 FOR H/M/L)
        MOV     BX,2C0H
        MOV     CX,302H         ; SET PARMS FOR MED RES
        CMP     CRT_MODE,4
        JE      C77             ; HANDLE IF MED RES
        CMP     CRT_MODE,5
        JE      C77             ; HANDLE IF MED RES
        MOV     BX,4F0H         ; SET PARMS FOR LOW RES
        MOV     CX,101H
        CMP     CRT_MODE,0AH    ; HANDLE MODE A AS HIGH RES
        JE      C76
        CMP     CRT_MODE,6
        JNE     C77             ; HANDLE IF LOW RES
C76:    MOV     BX,180H
        MOV     CX,703H         ; SET PARMS FOR HIGH RES
;------- DETERMINE BIT OFFSET IN BYTE FROM COLUMN MASK
C77:    AND     CH,DL           ; ADDRESS OF PEL WITHIN BYTE TO CH
;------- DETERMINE BYTE OFFSET FOR THIS LOCATION IN COLUMN
        SHR     DX,CL           ; SHIFT BY CORRECT AMOUNT
        ADD     SI,DX
        CMP     CRT_MODE,0AH    ; 640X200 4 COLOR?
        JNE     C78             ; NO, JUMP
        ADD     SI,DX           ; INCREMENT THE POINTER
C78:    MOV     DH,BH           ; GET THE # OF BITS IN RESULT TO DH
;------- MULTIPLY BH (VALID BITS IN BYTE) BY CH (BIT OFFSET)
        SUB     CL,CL           ; ZERO INTO STORAGE LOCATION
C79:    ROR     AL,1            ; LEFT JUSTIFY THE VALUE IN AL
                                ; (FOR WRITE)
        ADD     CL,CH           ; ADD IN THE BIT OFFSET VALUE
        DEC     BH              ; LOOP CONTROL
        JNZ     C79             ; ON EXIT, CL HAS SHIFT COUNT TO
                                ; RESTORE BITS
        MOV     AH,BL           ; GET MASK TO AH
        SHR     AH,CL           ; MOVE THE MASK TO CORRECT
                                ; LOCATION
        POP     BX              ; RECOVER REG
        RET                     ; RETURN WITH EVERYTHING SET UP
C72             ENDP

;------------------------------------------------------------
;               SCROLL UP
; THIS ROUTINE SCROLLS UP THE INFORMATION ON THE CRT
; ENTRY --
; CH,CL = UPPER LEFT CORNER OF REGION TO SCROLL
; DH,DL = LOWER RIGHT CORNER OF REGION TO SCROLL
; BOTH OF THE ABOVE ARE IN CHARACTER POSITIONS
; BH = FILL VALUE FOR BLANKED LINES
; AL = # LINES TO SCROLL (AL=0 MEANS BLANK THE ENTIRE FIELD)
; DS = DATA SEGMENT
; ES = REGEN SEGMENT
; EXIT --
; NOTHING, THE SCREEN IS SCROLLED
;------------------------------------------------------------
GRAPHICS_UP     PROC    NEAR
        MOV     BL,AL           ; SAVE LINE COUNT IN BL
        MOV     AX,CX           ; GET UPPER LEFT POSITION INTO AX REG
; USE CHARACTER SUBROUTINE FOR POSITIONING
; ADDRESS RETURNED IS MULTIPLIED BY 2 FROM CORRECT VALUE
        CALL    GRAPH_POSN
        MOV     DI,AX           ; SAVE RESULT AS DESTINATION
                                ; ADDRESS
;------- DETERMINE SIZE OF WINDOW
        SUB     DX,CX
        ADD     DX,101H         ; ADJUST VALUES
        SAL     DH,1            ; MULTIPLY # ROWS BY 4 SINCE 8 VERT
                                ; DOTS/CHAR
        SAL     DH,1            ; AND EVEN/ODD ROWS
;------- DETERMINE CRT MODE
        CMP     CRT_MODE,6      ; TEST FOR HIGH RES
        JE      C80             ; FIND_SOURCE
;------- MEDIUM RES UP
        SAL     DL,1            ; # COLUMNS * 2, SINCE 2 BYTES/CHAR
        SAL     DI,1            ; OFFSET *2 SINCE 2 BYTES/CHAR
        CMP     CRT_MODE,4      ; TEST FOR MEDIUM RES
        JE      C80
        CMP     CRT_MODE,5      ; TEST FOR MEDIUM RES
        JE      C80
        CMP     CRT_MODE,0AH    ; TEST FOR MEDIUM RES
        JE      C80
;------- LOW RES UP
        SAL     DL,1            ; # COLUMNS * 2 AGAIN, SINCE 4
                                ; BYTES/CHAR
        SAL     DI,1            ; OFFSET *2 AGAIN, SINCE 4
                                ; BYTES/CHAR
;------- DETERMINE THE SOURCE ADDRESS IN THE BUFFER
C80:    PUSH    ES              ; FIND_SOURCE
                                ; GET SEGMENTS BOTH POINTING TO
                                ; REGEN
        POP     DS
        SUB     CH,CH           ; ZERO TO HIGH OF COUNT REG
        SAL     BL,1            ; MULTIPLY NUMBER OF LINES BY 4
        SAL     BL,1
        JZ      C86             ; IF ZERO, THEN BLANK ENTIRE FIELD
        MOV     AL,BL           ; GET NUMBER OF LINES IN AL
        MOV     AH,80           ; 80 BYTES/ROW
        MUL     AH              ; DETERMINE OFFSET TO SOURCE
        MOV     SI,DI           ; SET UP SOURCE
        ADD     SI,AX           ; ADD IN OFFSET TO IT
        MOV     AH,DH           ; NUMBER OF ROWS IN FIELD
        SUB     AH,BL           ; DETERMINE NUMBER TO MOVE
;------- LOOP THROUGH, MOVING ONE ROW AT A TIME, BOTH EVEN AND ODD
;       FIELDS
C81:    CALL    C95             ; ROW_LOOP
        PUSH    DS              ; MOVE ONE ROW
        CALL    DDS             ; SAVE DATA SEG
        CMP     CRT_MODE,9      ; MODE USES 32K REGEN?
        POP     DS              ; RESTORE DATA SEG
        JC      C82             ; NO, JUMP
        ADD     SI,2000H        ; ADJUST POINTERS
        ADD     DI,2000H
        CALL    C95             ; MOVE 2 MORE ROWS
        SUB     SI,4000H-80     ; BACK UP POINTERS
        SUB     DI,4000H-80
        DEC     AH              ; ADJUST COUNT
C82:    SUB     SI,2000H-80     ; MOVE TO NEXT ROW
        SUB     DI,2000H-80
        DEC     AH              ; NUMBER OF ROWS TO MOVE
        JNZ     C81             ; CONTINUE TILL ALL MOVED
;------- FILL IN THE VACATED LINE(S)
C83:                            ; CLEAR_ENTRY
        MOV     AL,BH           ; ATTRIBUTE TO FILL WITH
C84:    CALL    C96             ; CLEAR THAT ROW
        PUSH    DS              ; SAVE DATA SEG
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,9      ; MODE USES 32K REGEN?
        POP     DS              ; RESTORE DATA SEG
        JC      C85             ; NO, JUMP
        ADD     DI,2000H
        CALL    C96             ; CLEAR 2 MORE ROWS
        SUB     DI,4000H-80     ; BACK UP POINTERS
        DEC     BL              ; ADJUST COUNT
C85:    SUB     DI,2000H-80     ; POINT TO NEXT LINE
        DEC     BL              ; NUMBER OF LINES TO FILL
        JNZ     C84             ; CLEAR_LOOP
        JMP     VIDEO_RETURN    ; EVERYTHING DONE
C86:    MOV     BL,DH           ; BLANK_FIELD
                                ; SET BLANK COUNT TO EVERYTHING IN
                                ; FIELD
        JMP     C83             ; CLEAR THE FIELD
GRAPHICS_UP     ENDP
;--------------------------------------------------------------
; SCROLL DOWN
; THIS ROUTINE SCROLLS DOWN THE INFORMATION ON THE CRT
; ENTRY --
;   CH,CL = UPPER LEFT CORNER OF REGION TO SCROLL
;   DH,DL = LOWER RIGHT CORNER OF REGION TO SCROLL
;   BOTH OF THE ABOVE ARE IN CHARACTER POSITIONS
;   BH = FILL VALUE FOR BLANKED LINES
;   AL = # LINES TO SCROLL (AL=0 MEANS BLANK THE ENTIRE FIELD)
;   DS = DATA SEGMENT
;   ES = REGEN SEGMENT
; EXIT --
;   NOTHING, THE SCREEN IS SCROLLED
;--------------------------------------------------------------
GRAPHICS_DOWN   PROC    NEAR
        STD                     ; SET DIRECTION
        MOV     BL,AL           ; SAVE LINE COUNT IN BL
        MOV     AX,DX           ; GET LOWER RIGHT POSITION INTO AX REG
;------- USE CHARACTER SUBROUTINE FOR POSITIONING
;------- ADDRESS RETURNED IS MULTIPLIED BY 2 FROM CORRECT VALUE
        CALL    GRAPH_POSN
        MOV     DI,AX           ; SAVE RESULT AS DESTINATION
                                ; ADDRESS
;------- DETERMINE SIZE OF WINDOW
        SUB     DX,CX
        ADD     DX,101H         ; ADJUST VALUES
        SAL     DH,1            ; MULTIPLY # ROWS BY 4 SINCE 8 VERT
                                ; DOTS/CHAR
        SAL     DH,1            ; AND EVEN/ODD ROWS
;------- DETERMINE CRT MODE
        CMP     CRT_MODE,6      ; TEST FOR HIGH RES
        JZ      C87             ; FIND_SOURCE_DOWN
;------- MEDIUM RES DOWN
        SAL     DL,1            ; # COLUMNS * 2, SINCE 2 BYTES/CHAR
        SAL     DI,1            ; (OFFSET OK)
        INC     DI              ; OFFSET *2 SINCE 2 BYTES/CHAR
        CMP     CRT_MODE,4      ; POINT TO LAST BYTE
        JZ      C87             ; TEST FOR MEDIUM RES
        CMP     CRT_MODE,5      ; TEST FOR MEDIUM RES
        JZ      C87             ; FIND_SOURCE_DOWN
        CMP     CRT_MODE,0AH    ; TEST FOR MEDIUM RES
        JZ      C87             ; FIND_SOURCE_DOWN
        DEC     DI
        SAL     DL,1            ; # COLUMNS * 2 AGAIN, SINCE 4
                                ; BYTES/CHAR (OFFSET OK)
        SAL     DI,1            ; OFFSET *2 AGAIN, SINCE 4
                                ; BYTES/CHAR
        ADD     DI,3            ; POINT TO LAST BYTE
;------- DETERMINE THE SOURCE ADDRESS IN THE BUFFER
C87:                            ; FIND_SOURCE_DOWN
        SUB     CH,CH           ; ZERO TO HIGH OF COUNT REG
        MOV     AX,240          ; OFFSET TO LAST ROW OF PIXELS IF
                                ; 16K REGEN
        CMP     CRT_MODE,9      ; USING 32K REGEN?
        JC      C88             ; NO, JUMP
        MOV     AX,160          ; OFFSET TO LAST ROW OF PIXELS IF
                                ; 32K REGEN
C88:    ADD     DI,AX           ; POINT TO LAST ROW OF PIXELS
        SAL     BL,1            ; MULTIPLY NUMBER OF LINES BY 4
        SAL     BL,1
        JZ      C94             ; IF ZERO, THEN BLANK ENTIRE FIELD
        MOV     AL,BL           ; GET NUMBER OF LINES IN AL
        MOV     AH,80           ; 80 BYTES/ROW
        MUL     AH              ; DETERMINE OFFSET TO SOURCE
        MOV     SI,DI           ; SET UP SOURCE
        SUB     SI,AX           ; SUBTRACT THE OFFSET
        MOV     AH,DH           ; NUMBER OF ROWS IN FIELD
        SUB     AH,BL           ; DETERMINE NUMBER TO MOVE
        PUSH    ES              ; BOTH SEGMENTS TO REGEN
        POP     DS
;------- LOOP THROUGH, MOVING ONE ROW AT A TIME, BOTH EVEN AND ODD
;       FIELDS
C89:    CALL    C95             ; ROW_LOOP_DOWN
        PUSH    DS              ; MOVE ONE ROW
        CALL    DDS             ; SAVE DATA SEG
        CMP     CRT_MODE,9      ; MODE USES 32K REGEN?
        POP     DS              ; RESTORE DATA SEG
        JC      C90             ; NO, JUMP
        ADD     SI,2000H        ; ADJUST POINTERS
        ADD     DI,2000H
        CALL    C95             ; MOVE 2 MORE ROWS
        SUB     SI,4000H+80     ; BACK UP POINTERS
        SUB     DI,4000H+80
        DEC     AH              ; ADJUST COUNT
C90:    SUB     SI,2000H+80     ; MOVE TO NEXT ROW
        SUB     DI,2000H+80
        DEC     AH              ; NUMBER OF ROWS TO MOVE
        JNZ     C89             ; CONTINUE TILL ALL MOVED
;------- FILL IN THE VACATED LINE(S)
C91:                            ; CLEAR_ENTRY_DOWN
        MOV     AL,BH           ; ATTRIBUTE TO FILL WITH
C92:                            ; CLEAR_LOOP_DOWN
        CALL    C96             ; CLEAR A ROW
        PUSH    DS              ; SAVE DATA SEG
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,9      ; MODE USES 32K REGEN?
        POP     DS              ; RESTORE DATA SEG
        JC      C93             ; NO, JUMP
        ADD     DI,2000H        ; ADJUST POINTERS
        CALL    C96             ; CLEAR 2 MORE ROWS
        SUB     DI,4000H+80     ; BACK UP POINTERS
        DEC     BL              ; ADJUST COUNT
C93:    SUB     DI,2000H+80     ; POINT TO NEXT LINE
        DEC     BL              ; NUMBER OF LINES TO FILL
        JNZ     C92             ; CLEAR_LOOP_DOWN
        CLD                     ; RESET THE DIRECTION FLAG
        JMP     VIDEO_RETURN    ; EVERYTHING DONE
C94:    MOV     BL,DH           ; BLANK_FIELD_DOWN
        JMP     C91             ; CLEAR THE FIELD
GRAPHICS_DOWN  ENDP
;------- ROUTINE TO MOVE ONE ROW OF INFORMATION
C95             PROC    NEAR
        MOV     CL,DL           ; NUMBER OF BYTES IN THE ROW
        PUSH    SI              ; SAVE POINTERS
        PUSH    DI
        REP     MOVSB           ; MOVE THE EVEN FIELD
        POP     DI
        POP     SI
        ADD     SI,2000H
        ADD     DI,2000H        ; POINT TO THE ODD FIELD
        PUSH    SI              ; SAVE THE POINTERS
        PUSH    DI
        MOV     CL,DL           ; COUNT BACK
        REP     MOVSB           ; MOVE THE ODD FIELD
        POP     DI
        POP     SI              ; POINTERS BACK
        RET                     ; RETURN TO CALLER
C95             ENDP
;------- CLEAR A SINGLE ROW
C96             PROC    NEAR
        MOV     CL,DL           ; NUMBER OF BYTES IN FIELD
        PUSH    DI              ; SAVE POINTER
        REP     STOSB           ; STORE THE NEW VALUE
        POP     DI              ; POINTER BACK
        ADD     DI,2000H        ; POINT TO ODD FIELD
        PUSH    DI
        MOV     CL,DL
        REP     STOSB           ; FILL THE ODD FIELD
        POP     DI
        RET                     ; RETURN TO CALLER
C96             ENDP

;-------------------------------------------------
; GRAPHICS WRITE
; THIS ROUTINE WRITES THE ASCII CHARACTER TO THE CURRENT
; POSITION ON THE SCREEN.
;
; ENTRY --
;     AL = CHARACTER TO WRITE
;     BL = COLOR ATTRIBUTE TO BE USED FOR FOREGROUND COLOR
;          IF BIT 7 IS SET, THE CHAR IS XOR'D INTO THE REGEN BUFFER
;             (0 IS USED FOR THE BACKGROUND COLOR)
;     CX = NUMBER OF CHARS TO WRITE
;     DS = DATA SEGMENT
;     ES = REGEN SEGMENT
; EXIT --
;     NOTHING IS RETURNED
;
; GRAPHICS READ
;     THIS ROUTINE READS THE ASCII CHARACTER AT THE CURRENT CURSOR
;     POSITION ON THE SCREEN BY MATCHING THE DOTS ON THE SCREEN TO
;     THE CHARACTER GENERATOR CODE POINTS
; ENTRY --
;     NONE  (0 IS ASSUMED AS THE BACKGROUND COLOR)
; EXIT --
;     AL = CHARACTER READ AT THAT POSITION (0 RETURNED IF NONE FOUND)
;
; FOR BOTH ROUTINES, THE IMAGES USED TO FORM CHARS ARE CONTAINED IN
; ROM.  INTERRUPT 44H IS USED TO POINT TO THE TABLE FOR THE FIRST
; 128 CHARS.  INTERRUPT 17H IS USED TO POINT TO THE TABLE FOR THE
; SECOND 128 CHARS.
;-------------------------------------------------
ASSUME  CS:CODE,DS:DATA,ES:DATA
GRAPHICS_WRITE PROC    NEAR
        XOR     AH,AH           ; ZERO TO HIGH OF CODE POINT
        PUSH    AX              ; SAVE CODE POINT VALUE
;------- DETERMINE POSITION IN REGEN BUFFER TO PUT CODE POINTS
        CALL    R59             ; FIND LOCATION IN REGEN BUFFER
        MOV     DI,AX           ; REGEN POINTER IN DI
;------- DETERMINE REGION TO GET CODE POINTS FROM
        POP     AX              ; RECOVER CODE POINT
        MOV     SI,OFFSET CSET_PTR ; ASSUME FIRST HALF
        CMP     AL,80H          ; IS IT IN FIRST HALF?
        JB      R1              ; JUMP IF IT IS
        MOV     SI,OFFSET EXT_PTR ; SET POINTER FOR SECOND HALF
        SUB     AL,80H          ; ZERO ORIGIN FOR SECOND HALF
R1:     PUSH    DS              ; SAVE DATA POINTER
        XOR     DX,DX
        MOV     DS,DX           ; ESTABLISH VECTOR ADDRESSING
ASSUME  DS:ABS0
        LDS     SI,DWORD PTR [SI] ; GET THE OFFSET OF THE TABLE
        MOV     DX,DS           ; GET THE SEGMENT OF THE TABLE
ASSUME  DS:DATA
        POP     DS              ; RECOVER DATA SEGMENT
        PUSH    DX              ; SAVE TABLE SEGMENT ON STACK
;------- DETERMINE GRAPHICS MODE IN OPERATION
        SAL     AX,1            ; MULTIPLY CODE POINT
        SAL     AX,1            ; VALUE BY 8
        SAL     AX,1
        ADD     SI,AX           ; SI HAS OFFSET OF DESIRED CODES
        CMP     CRT_MODE,4
        JE      R9              ; TEST FOR MEDIUM RESOLUTION MODE
        CMP     CRT_MODE,5
        JE      R9              ; TEST FOR MEDIUM RESOLUTION MODE
        CMP     CRT_MODE,0AH
        JNE     R3              ; TEST FOR MEDIUM RESOLUTION MODE
        JMP     R16
R3:     CMP     CRT_MODE,6      ; TEST FOR HIGH RESOLUTION MODE
        JNE     R12             ; GOTO LOW RESOLUTION IF NOT
;------- HIGH RESOLUTION MODE
        POP     DS              ; RECOVER TABLE POINTER SEGMENT
R5:     PUSH    DI              ; SAVE REGEN POINTER
        PUSH    SI              ; SAVE CODE POINTER
        MOV     DH,4            ; NUMBER OF TIMES THROUGH LOOP
R6:     LODSB                   ; GET BYTE FROM CODE POINTS
        TEST    BL,80H          ; SHOULD WE USE THE FUNCTION
        JNZ     R8              ; TO PUT CHAR IN?
        STOSB                   ; STORE IN REGEN BUFFER
        LODSB
R7:     MOV     ES:[DI+2000H-1],AL ; STORE IN SECOND HALF
        ADD     DI,79           ; MOVE TO NEXT ROW IN REGEN
        DEC     DH              ; DONE WITH LOOP
        JNZ     R6
        POP     SI
        POP     DI              ; RECOVER REGEN POINTER
        INC     DI              ; POINT TO NEXT CHAR POSITION
        LOOP    R5              ; MORE CHARS TO WRITE
R705:   JMP     VIDEO_RETURN
R8:     XOR     AL,ES:[DI]      ; EXCLUSIVE OR WITH CURRENT DATA
        STOSB                   ; STORE THE CODE POINT
        LODSB                   ; AGAIN FOR ODD FIELD
        XOR     AL,ES:[DI+2000H-1]
        JMP     R7              ; BACK TO MAINSTREAM

;------- MEDIUM RESOLUTION WRITE
R9:     POP     DS              ; MED_RES_WRITE
        MOV     DL,BL           ; RECOVER TABLE POINTER SEGMENT
        SAL     DI,1            ; SAVE HIGH COLOR BIT
        CALL    R40             ; OFFSET*2 SINCE 2 BYTES/CHAR
                                ; EXPAND BL TO FULL WORD OF COLOR
R10:    PUSH    DI              ; MED_CHAR
        PUSH    SI              ; SAVE REGEN POINTER
        MOV     DH,4            ; SAVE THE CODE POINTER
R11:    CALL    R35             ; NUMBER OF LOOPS
        ADD     DI,2000H        ; DO FIRST 2 BYTES
        CALL    R35             ; NEXT SPOT IN REGEN
        SUB     DI,2000H-80     ; DO NEXT 2 BYTES
        DEC     DH
        JNZ     R11             ; KEEP GOING
        POP     SI              ; RECOVER CODE POINTER
        POP     DI              ; RECOVER REGEN POINTER
        INC     DI              ; POINT TO NEXT CHAR POSITION
        INC     DI
        LOOP    R10             ; MORE TO WRITE
        JMP     R705

;------- LOW RESOLUTION WRITE
R12:    POP     DS              ; LOW_RES_WRITE
        MOV     DL,BL           ; RECOVER TABLE POINTER SEGMENT
        SAL     DI,1            ; SAVE HIGH COLOR BIT
        SAL     DI,1            ; OFFSET*4 SINCE 4 BYTES/CHAR
        CALL    R42             ; EXPAND BL TO FULL WORD OF COLOR
R13:    PUSH    DI              ; MED_CHAR
        PUSH    SI              ; SAVE REGEN POINTER
        MOV     DH,4            ; SAVE THE CODE POINTER
R14:    CALL    R39             ; EXPAND DOT ROW IN REGEN
        ADD     DI,2000H        ; POINT TO NEXT REGEN ROW
        CALL    R39             ; EXPAND DOT ROW IN REGEN
        PUSH    DS              ; SAVE DS
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,09H    ; USING 32K REGEN AREA?
        POP     DS              ; RECOVER DS
        JNE     R15             ; JUMP IF 16K REGEN
        ADD     DI,2000H        ; POINT TO NEXT REGEN ROW
        CALL    R39             ; EXPAND DOT ROW IN REGEN
        ADD     DI,2000H        ; POINT TO NEXT REGEN ROW
        CALL    R39             ; EXPAND DOT ROW IN REGEN
        SUB     DI,4000H-80     ; ADJUST REGEN POINTER
        DEC     DH
R15:    SUB     DI,2000H-80     ; ADJUST REGEN POINTER TO NEXT ROW
        DEC     DH
        JNZ     R14             ; KEEP GOING
        POP     SI              ; RECOVER CODE POINTER
        POP     DI              ; RECOVER REGEN POINTER
        ADD     DI,4            ; POINT TO NEXT CHAR POSITION
        LOOP    R13             ; MORE TO WRITE
        JMP     R705

R16:    POP     DS              ; 640X200 4 COLOR GRAPHICS WRITE
        MOV     DL,BL           ; RECOVER TABLE SEGMENT POINTER
        SAL     DI,1            ; SAVE HIGH COLOR BIT
; EXPAND LOW 2 COLOR BITS IN BL (c1c0)
; INTO BX (c0c0c0c0c0c0c0c1c1c1c1c1c1c1c1)
        XOR     AX,AX
        TEST    BL,1            ; c0 COLOR BIT ON?
        JZ      R17             ; NO, JUMP
        MOV     AH,0FFH         ; YES, SET ALL c0 BITS ON
R17:    TEST    BL,2            ; c1 COLOR BIT ON?
        JZ      R18             ; NO, JUMP
        MOV     AL,0FFH         ; YES, SET ALL c1 BITS ON
R18:    MOV     BX,AX           ; COLOR MASK IN BX
R19:    PUSH    DI              ; SAVE REGEN POINTER
        PUSH    SI              ; SAVE CODE POINT POINTER
        MOV     DH,2            ; SET LOOP COUNTER
R20:    CALL    R21             ; DO FIRST DOT ROW
        ADD     DI,2000H        ; ADJUST REGEN POINTER
        CALL    R21             ; DO NEXT DOT ROW
        ADD     DI,2000H        ; ADJUST REGEN POINTER
        CALL    R21             ; DO NEXT DOT ROW
        ADD     DI,2000H        ; ADJUST REGEN POINTER
        CALL    R21             ; DO NEXT DOT ROW
        SUB     DI,6000H-160    ; ADJUST REGEN POINTER TO NEXT ROW
        DEC     DH
        JNZ     R20             ; KEEP GOING
        POP     SI              ; RECOVER CODE POINT POINTER
        POP     DI              ; RECOVER REGEN POINTER
        INC     DI              ; POINT TO NEXT CHARACTER
        INC     DI
        LOOP    R19             ; MORE TO WRITE
        JMP     VIDEO_RETURN
R21             PROC    NEAR
        LODSB                   ; GET CODE POINT
        MOV     AH,AL           ; COPY INTO AH
        AND     AX,BX           ; SET COLOR
        TEST    DL,80H          ; XOR FUNCTION?
        JZ      R22             ; NO, JUMP
        XOR     AH,ES:[DI]
        XOR     AL,ES:[DI+1]
R22:    MOV     ES:[DI],AH      ; STORE IN REGEN BUFFER
        MOV     ES:[DI+1],AL
        RET
R21             ENDP
GRAPHICS_WRITE ENDP
;-----------------------------------
; GRAPHICS READ
;-----------------------------------
GRAPHICS_READ  PROC    NEAR
        CALL    R59             ; CONVERTED TO OFFSET IN REGEN
        MOV     SI,AX           ; SAVE IN SI
        SUB     SP,8            ; ALLOCATE SPACE TO SAVE THE READ
                                ; CODE POINT
        MOV     BP,SP           ; POINTER TO SAVE AREA
        PUSH    ES
        MOV     DH,4            ; NUMBER OF PASSES
        CMP     CRT_MODE,6
        JZ      R23             ; HIGH RESOLUTION
        CMP     CRT_MODE,4
        JZ      R28             ; MEDIUM RESOLUTION
        CMP     CRT_MODE,5
        JZ      R28             ; MEDIUM RESOLUTION
        CMP     CRT_MODE,0AH
        JZ      R28             ; MEDIUM RESOLUTION
        JMP     SHORT R25       ; LOW RESOLUTION

;------- HIGH RESOLUTION READ
;------- GET VALUES FROM REGEN BUFFER AND CONVERT TO CODE POINT
R23:    POP     DS              ; POINT TO REGEN SEGMENT
R24:    MOV     AL,[SI]         ; GET FIRST BYTE
        MOV     [BP],AL         ; SAVE IN STORAGE AREA
        INC     BP              ; NEXT LOCATION
        MOV     AL,[SI+2000H]   ; GET LOWER REGION BYTE
        MOV     [BP],AL         ; ADJUST AND STORE
        INC     BP
        ADD     SI,80           ; POINTER INTO REGEN
        DEC     DH              ; LOOP CONTROL
        JNZ     R24             ; DO IT SOME MORE
        JMP     SHORT R31       ; GO MATCH THE SAVED CODE POINTS

;------- LOW RESOLUTION READ
R25:    POP     DS              ; POINT TO REGEN SEGMENT
        SAL     SI,1            ; OFFSET*4 SINCE 4 BYTES/CHAR
        SAL     SI,1
R26:    CALL    R55             ; GET 4 BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R55             ; GET 4 BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        PUSH    DS              ; SAVE DS
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,9      ; DO WE HAVE A 32K REGEN AREA?
        POP     DS
        JNE     R27             ; NO, JUMP
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R55             ; GET 4 BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R55             ; GET 4 BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        SUB     SI,4000H-80     ; ADJUST POINTER
        DEC     DH
R27:    SUB     SI,2000H-80     ; ADJUST POINTER BACK TO UPPER
        DEC     DH
        JNZ     R26             ; DO IT SOME MORE
        JMP     SHORT R31       ; GO MATCH THE SAVED CODE POINTS

R28:                            ; MEDIUM RESOLUTION READ
        POP     DS              ; POINT TO REGEN SEGMENT
        SAL     SI,1            ; OFFSET*2 SINCE 2 BYTES/CHAR
R29:    CALL    R50             ; GET PAIR BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R50             ; GET THIS PAIR INTO SAVE
        PUSH    DS              ; SAVE DS
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,0AH    ; DO WE HAVE A 32K REGEN AREA?
        POP     DS
        JNE     R30             ; NO, JUMP
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R50             ; GET PAIR BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        ADD     SI,2000H        ; GOTO LOWER REGION
        CALL    R50             ; GET PAIR BYTES FROM REGEN INTO
                                ; SINGLE SAVE
        SUB     SI,4000H-80     ; ADJUST POINTER
        DEC     DH
R30:
        SUB     SI,2000H-80     ; ADJUST POINTER BACK INTO UPPER
        DEC     DH
        JNZ     R29             ; KEEP GOING UNTIL ALL 8 DONE
;-------- SAVE AREA HAS CHARACTER IN IT, MATCH IT
R31:    XOR     AX,AX
        MOV     DS,AX           ; ESTABLISH ADDRESSING TO VECTOR
ASSUME  DS:ABS0
        LES     DI,CSET_PTR     ; GET POINTER TO FIRST HALF
        SUB     BP,8            ; ADJUST POINTER TO BEGINNING OF
                                ; SAVE AREA

        MOV     SI,BP
        CLD                     ; ENSURE DIRECTION
        XOR     AL,AL           ; CURRENT CODE POINT BEING MATCHED
R32:    PUSH    SS              ; ESTABLISH ADDRESSING TO STACK
        POP     DS              ; FOR THE STRING COMPARE
        MOV     DX,128          ; NUMBER TO TEST AGAINST
R33:    PUSH    SI              ; SAVE AREA POINTER
        PUSH    DI              ; SAVE CODE POINTER
        MOV     CX,8            ; NUMBER OF BYTES TO MATCH
        REPE    CMPSB           ; COMPARE THE 8 BYTES
        POP     DI              ; RECOVER THE POINTERS
        POP     SI
        JZ      R34             ; IF ZERO FLAG SET, THEN MATCH
                                ; OCCURRED
        INC     AL              ; NO MATCH, MOVE ON TO NEXT
        ADD     DI,8            ; NEXT CODE POINT
        DEC     DX              ; LOOP CONTROL
        JNZ     R33             ; DO ALL OF THEM
;-------- CHAR NOT MATCHED, MIGHT BE IN SECOND HALF
        OR      AL,AL           ; AL<> 0 IF ONLY 1ST HALF SCANNED
        JE      R34             ; IF = 0, THEN ALL HAS BEEN SCANNED
        SUB     AX,AX
        MOV     DS,AX           ; ESTABLISH ADDRESSING TO VECTOR
ASSUME  DS:ABS0
        LES     DI,EXT_PTR      ; GET POINTER
        MOV     AX,ES           ; SEE IF THE POINTER REALLY EXISTS
        OR      AX,DI           ; IF ALL 0, THEN DOESN'T EXIST
        JZ      R34             ; NO SENSE LOOKING
        MOV     AL,128          ; ORIGIN FOR SECOND HALF
        JMP     R32             ; GO BACK AND TRY FOR IT
ASSUME  DS:DATA
;-------- CHARACTER IS FOUND ( AL=0 IF NOT FOUND )
R34:    ADD     SP,8            ; READJUST THE STACK, THROW AWAY
                                ; WORK AREA
        JMP     VIDEO_RETURN    ; ALL DONE
GRAPHICS_READ  ENDP
;--------
R35             PROC    NEAR
        LODSB                   ; GET CODE POINT
        CALL    R43             ; DOUBLE UP ALL THE BITS
R36:    AND     AX,BX           ; CONVERT THEM TO FOREGROUND COLOR
                                ; ( 0 BACK )
        TEST    DL,80H          ; IS THIS XOR FUNCTION?
        JZ      R37             ; NO, STORE IT IN AS IT IS
        XOR     AH,ES:[DI]      ; DO FUNCTION WITH HALF
        XOR     AL,ES:[DI+1]    ; AND WITH OTHER HALF
R37:    MOV     ES:[DI],AH      ; STORE FIRST BYTE
        MOV     ES:[DI+1],AL    ; STORE SECOND BYTE
        RET
R35             ENDP
;--------
R38             PROC    NEAR
        CALL    R45             ; QUAD UP THE LOW NIBBLE
        JMP     R36
R38             ENDP
;-------------
; EXPAND 1 DOT ROW OF A CHAR INTO 4 BYTES IN THE REGEN BUFFER
;-------------
R39             PROC    NEAR
        LODSB                   ; GET CODE POINT
        PUSH    AX              ; SAVE
        PUSH    CX
        MOV     CL,4            ; MOV HIGH NIBBLE TO LOW
        SHR     AL,CL
        POP     CX
        CALL    R38             ; EXPAND TO 2 BYTES & PUT IN REGEN
        POP     AX              ; RECOVER CODE POINT
        INC     DI              ; ADJUST REGEN POINTER
        INC     DI
        CALL    R38             ; EXPAND LOW NIBBLE & PUT IN REGEN
        DEC     DI              ; RESTORE REGEN POINTER
        DEC     DI
        RET
R39             ENDP
;----------------------------------------------------
; EXPAND_MED_COLOR
; THIS ROUTINE EXPANDS THE LOW 2 BITS IN BL TO
; FILL THE ENTIRE BX REGISTER
; ENTRY --
;   BL = COLOR TO BE USED ( LOW 2 BITS )
; EXIT --
;   BX = COLOR TO BE USED ( 8 REPLICATIONS OF THE 2 COLOR BITS )
;----------------------------------------------------
R40             PROC    NEAR
        AND     BL,3            ; ISOLATE THE COLOR BITS
        MOV     AL,BL           ; COPY TO AL
        PUSH    CX              ; SAVE REGISTER
        MOV     CX,3            ; NUMBER OF TIMES TO DO THIS
R41:    SAL     AL,1
        SAL     AL,1            ; LEFT SHIFT BY 2
        OR      BL,AL           ; ANOTHER COLOR VERSION INTO BL
        LOOP    R41             ; FILL ALL OF BL
        MOV     BH,BL           ; FILL UPPER PORTION
        POP     CX              ; REGISTER BACK
        RET                     ; ALL DONE
R40             ENDP
;-------------------------------
; EXPAND_LOW_COLOR
; THIS ROUTINE EXPANDS THE LOW 4 BITS IN BL TO
; FILL THE ENTIRE BX REGISTER
; ENTRY --
;   BL = COLOR TO BE USED ( LOW 4 BITS )
; EXIT --
;   BX = COLOR TO BE USED ( 4 REPLICATIONS OF THE 4 COLOR BITS )
;-------------------------------
R42             PROC    NEAR
        PUSH    CX
        AND     BL,0FH          ; ISOLATE THE COLOR BITS
        MOV     BH,BL           ; COPY TO BH
        MOV     CL,4            ; MOVE TO HIGH NIBBLE
        SHL     BH,CL
        OR      BH,BL           ; MAKE BYTE FROM HIGH AND LOW
                                ; NIBBLES
        MOV     BL,BH
        POP     CX
        RET                     ; ALL DONE
R42             ENDP
;-------------------------------
; EXPAND_BYTE
; THIS ROUTINE TAKES THE BYTE IN AL AND DOUBLES ALL
; OF THE BITS, TURNING THE 8 BITS INTO 16 BITS.
; THE RESULT IS LEFT IN AX
;-------------------------------
R43             PROC    NEAR
        PUSH    DX              ; SAVE REGISTERS
        PUSH    CX
        PUSH    BX
        SUB     DX,DX           ; RESULT REGISTER
        MOV     CX,1            ; MASK REGISTER
R44:    MOV     BX,AX           ; BASE INTO TEMP
        AND     BX,CX           ; USE MASK TO EXTRACT A BIT
        OR      DX,BX           ; PUT INTO RESULT REGISTER
        SHL     AX,1
        SHL     CX,1            ; SHIFT BASE AND MASK BY 1
        MOV     BX,AX           ; BASE TO TEMP
        AND     BX,CX           ; EXTRACT THE SAME BIT
        OR      DX,BX           ; PUT INTO RESULT
        SHL     CX,1            ; SHIFT ONLY MASK NOW, MOVING TO
                                ; NEXT BASE
        JNC     R44             ; USE MASK BIT COMING OUT TO
                                ; TERMINATE
        MOV     AX,DX           ; RESULT TO PARM REGISTER
        POP     BX
        POP     CX              ; RECOVER REGISTERS
        POP     DX
        RET                     ; ALL DONE
R43             ENDP
;-------------------------------
; EXPAND_NIBBLE
; THIS ROUTINE TAKES THE LOW NIBBLE IN AL AND QUADS ALL
; OF THE BITS, TURNING THE 4 BITS INTO 16 BITS.
; THE RESULT IS LEFT IN AX
;-------------------------------
R45             PROC    NEAR
        PUSH    DX              ; SAVE REGISTERS
        XOR     DX,DX           ; RESULT REGISTER
        TEST    AL,8
        JZ      R46
        OR      DH,0F0H
R46:    TEST    AL,4
        JZ      R47
        OR      DH,0FH
R47:    TEST    AL,2
        JZ      R48
        OR      DL,0F0H
R48:    TEST    AL,1
        JZ      R49
        OR      DL,0FH
R49:    MOV     AX,DX           ; RESULT TO PARM REGISTER
        POP     DX              ; RECOVER REGISTERS
        RET                     ; ALL DONE
R45             ENDP
;-----------------------------------------------------------
; MED_READ_BYTE
; THIS ROUTINE WILL TAKE 2 BYTES FROM THE REGEN BUFFER,
; COMPARE AGAINST THE CURRENT FOREGROUND COLOR, AND PLACE
; THE CORRESPONDING ON/OFF BIT PATTERN INTO THE CURRENT
; POSITION IN THE SAVE AREA
; ENTRY --
; SI,DS = POINTER TO REGEN AREA OF INTEREST
; BX = EXPANDED FOREGROUND COLOR
; BP = POINTER TO SAVE AREA
; EXIT --
; BP IS INCREMENT AFTER SAVE
;-----------------------------------------------------------
R50             PROC    NEAR
        MOV     AH,[SI]         ; GET FIRST BYTE
        MOV     AL,[SI+1]       ; GET SECOND BYTE
        PUSH    DS              ; SAVE DS
        CALL    DDS             ; POINT TO BIOS DATA AREA
        CMP     CRT_MODE,0AH    ; IN 640X200 4 COLOR MODE?
        POP     DS              ; RESTORE REGEN SEG
        JNE     R52             ; NO, JUMP
; IN 640X200 4 COLOR MODE, ALL THE c0 BITS ARE IN ONE BYTE, AND ALL
; THE c1 BITS ARE IN THE NEXT BYTE. HERE WE CHANGE THEM BACK TO
; NORMAL c1c0 ADJACENT PAIRS.
        PUSH    BX              ; SAVE REG
        MOV     CX,8            ; SET LOOP COUNTER
R51:    SAR     AH,1            ; c0 BIT INTO CARRY
        RCR     BX,1            ; AND INTO BX
        SAR     AL,1            ; c1 BIT INTO CARRY
        RCR     BX,1            ; AND INTO BX
        LOOP    R51             ; REPEAT
        MOV     AX,BX           ; RESULT INTO AX
        POP     BX              ; RESTORE BX
R52:    MOV     CX,0C000H       ; 2 BIT MASK TO TEST THE ENTRIES
        XOR     DL,DL           ; RESULT REGISTER
R53:    TEST    AX,CX           ; IS THIS SECTION BACKGROUND?
        JZ      R54             ; IF ZERO, IT IS BACKGROUND
        STC                     ; WASN'T, SO SET CARRY
R54:    RCL     DL,1            ; MOVE THAT BIT INTO THE RESULT
        SHR     CX,1            ; MOVE THE MASK TO THE RIGHT BY 2
        SHR     CX,1            ; BITS
        JNC     R53             ; DO IT AGAIN IF MASK DIDN'T FALL
                                ; OUT
        MOV     [BP],DL         ; STORE RESULT IN SAVE AREA
        INC     BP              ; ADJUST POINTER
        RET                     ; ALL DONE
R50             ENDP
;
;-----------------------------------------------------------
; LOW_READ_BYTE
; THIS ROUTINE WILL TAKE 4 BYTES FROM THE REGEN BUFFER,
; COMPARE FOR BACKGROUND COLOR, AND PLACE
; THE CORRESPONDING ON/OFF BIT PATTERN INTO THE CURRENT
; POSITION IN THE SAVE AREA
; ENTRY --
; SI,DS = POINTER TO REGEN AREA OF INTEREST
; BP = POINTER TO SAVE AREA
; EXIT --
; BP IS INCREMENT AFTER SAVE
;-----------------------------------------------------------
R55             PROC    NEAR
        MOV     AH,[SI]         ; GET FIRST 2 BYTES
        MOV     AL,[SI+1]
        XOR     DL,DL
        CALL    R56             ; BUILD HIGH NIBBLE
        MOV     AH,[SI+2]       ; GET SECOND 2 BYTES
        MOV     AL,[SI+3]
        CALL    R56             ; BUILD LOW NIBBLE
        MOV     [BP],DL         ; STORE RESULT IN SAVE AREA
        INC     BP              ; ADJUST POINTER
        RET
R55             ENDP
R56             PROC    NEAR
        MOV     CX,0F000H       ; 4 BIT MASK TO TEST THE ENTRIES
R57:    TEST    AX,CX           ; IS THIS SECTION BACKGROUND?
        JZ      R58             ; IF ZERO, IT IS BACKGROUND
        STC                     ; WASN'T, SO SET CARRY
R58:    RCL     DL,1            ; MOVE THAT BIT INTO RESULT
        SHR     CX,1            ; MOVE MASK RIGH 4 BITS
        SHR     CX,1
        SHR     CX,1
        SHR     CX,1
        JNC     R57             ; DO IT AGAIN IF MASK DID'T FALL OUT
        RET
R56             ENDP
;---------------------------------------
; V4_POSITION
; THIS ROUTINE TAKES THE CURSOR POSITION CONTAINED IN
; THE MEMORY LOCATION, AND CONVERTS IT INTO AN OFFSET
; INTO THE REGEN BUFFER, ASSUMING ONE BYTE/CHAR.
; FOR MEDIUM RESOLUTION GRAPHICS, THE NUMBER MUST
; BE DOUBLED.
; ENTRY -- NO REGISTERS,MEMORY LOCATION CURSOR_POSN IS USED
; EXIT--
; AX CONTAINS OFFSET INTO REGEN BUFFER
;---------------------------------------
R59             PROC    NEAR
        MOV     AX,CURSOR_POSN  ; GET CURRENT CURSOR
GRAPH_POSN      LABEL   NEAR
        PUSH    BX              ; SAVE REGISTER
        MOV     BX,AX           ; SAVE A COPY OF CURRENT CURSOR
        MOV     AL,AH           ; GET ROWS TO AL
        MUL     BYTE PTR CRT_COLS ; MULTIPLY BY BYTES/COLUMN
        CMP     CRT_MODE,9      ; MODE USING 32K REGEN?
        JNC     R60             ; YES, JUMP
        SHL     AX,1            ; MULTIPLY * 4 SINCE 4 ROWS/BYTE
R60:
        SHL     AX,1
        SUB     BH,BH           ; ISOLATE COLUMN VALUE
        ADD     AX,BX           ; DETERMINE OFFSET
        POP     BX              ; RECOVER POINTER
        RET                     ; ALL DONE
R59             ENDP

;---------------------------------------
; LIGHT PEN
; THIS ROUTINE TESTS THE LIGHT PEN SWITCH AND THE LIGHT
; PEN TRIGGER. IF BOTH ARE SET, THE LOCATION OF THE LIGHT
; PEN IS DETERMINED. OTHERWISE, A RETURN WITH NO INFORMATION
; IS MADE.
; ON EXIT:
;       (AH) = 0 IF NO LIGHT PEN INFORMATION IS AVAILABLE
;               BX,CX,DX ARE DESTROYED
;       (AH) = 1 IF LIGHT PEN IS AVAILABLE
;               (DH,DL) = ROW,COLUMN OF CURRENT LIGHT PEN POSITION
;               (CH) = RASTER POSITION
;               (BX) = BEST GUESS AT PIXEL HORIZONTAL POSITION
;---------------------------------------
ASSUME  CS:CODE,DS:DATA
;------ SUBTRACT_TABLE
V1              LABEL   BYTE
       DB      3,3,5,5,3,3,3,0,2,3,4


READ_LPEN       PROC    NEAR
;----- WAIT FOR LIGHT PEN TO BE DEPRESSED
        XOR     AH,AH           ; SET NO LIGHT PEN RETURN CODE
        MOV     DX,VGA_CTL      ; GET ADDRESS OF VGA CONTROL REG
        IN      AL,DX           ; GET STATUS REGISTER
        TEST    AL,4            ; TEST LIGHT PEN SWITCH
        JZ      V7B
        JMP     V6              ; NOT SET, RETURN
;----- NOW TEST FOR LIGHT PEN TRIGGER
V7B:    TEST    AL,2            ; TEST LIGHT PEN TRIGGER
        JNZ     V7A             ; RETURN WITHOUT RESETTING TRIGGER
        JMP     V7
;----- TRIGGER HAS BEEN SET, READ THE VALUE IN
V7A:    MOV     AH,16           ; LIGHT PEN REGISTERS ON 6845
;----- INPUT REGS POINTED TO BY AH, AND CONVERT TO ROW COLUMN IN DX
        MOV     DX,ADDR_6845    ; ADDRESS REGISTER FOR 6845
        MOV     AL,AH           ; REGISTER TO READ
        OUT     DX,AL           ; SET IT UP
        INC     DX              ; DATA REGISTER
        IN      AL,DX           ; GET THE VALUE
        MOV     CH,AL           ; SAVE IN CX
        DEC     DX              ; ADDRESS REGISTER
        INC     AH
        MOV     AL,AH           ; SECOND DATA REGISTER
        OUT     DX,AL
        INC     DX              ; POINT TO DATA REGISTER
        IN      AL,DX           ; GET SECOND DATA VALUE
        MOV     AH,CH           ; AX HAS INPUT VALUE
;----- AX HAS THE VALUE READ IN FROM THE 6845
        MOV     BL,CRT_MODE
        SUB     BH,BH           ; MODE VALUE TO BX
        MOV     BL,CS:V1[BX]    ; DETERMINE AMOUNT TO SUBTRACT
        SUB     AX,BX           ; TAKE IT AWAY
        CMP     AX,4000         ; IN TOP OR BOTTOM BORDER?
        JB      V15             ; NO, OKAY
        XOR     AX,AX           ; YES, SET TO ZERO
V15:    MOV     BX,CRT_START
        SHR     BX,1
        SUB     AX,BX           ; CONVERT TO CORRECT PAGE ORIGIN
        JNS     V2              ; IF POSITIVE, DETERMINE MODE
        SUB     AX,AX           ; <0 PLAYS AS 0
;----- DETERMINE MODE OF OPERATION
V2:                             ; DETERMINE_MODE
        MOV     CL,3            ; SET *8 SHIFT COUNT
        CMP     CRT_MODE,4      ; DETERMINE IF GRAPHICS OR ALPHA
        JB      V4              ; ALPHA_PEN
;----- GRAPHICS MODE
        MOV     DL,40           ; DIVISOR FOR GRAPHICS
        CMP     CRT_MODE,9      ; USING 32K REGEN?
        JB      V20             ; NO, JUMP
        MOV     DL,80           ; YES, SET RIGHT DIVSOR
V20:    DIV     DL              ; DETERMINE ROW(AL) AND COLUMN(AH)
                                ; AL RANGE 0-99, AH RANGE 0-39
        MOV     CH,AL           ; SAVE ROW VALUE IN CH
        ADD     CH,CH           ; *2 FOR EVEN/ODD FIELD
        CMP     CRT_MODE,9      ; USING 32K REGEN?
        JB      V21             ; NO, JUMP
        SHR     AH,1            ; ADJUST ROW & COLUMN
        SHL     AL,1
        ADD     CH,CH           ; *4 FOR 4 SCAN LINES
V21:    MOV     BL,AH           ; COLUMN VALUE TO BX
        SUB     BH,BH           ; MULTIPLY BY 8 FOR MEDIUM RES
        CMP     CRT_MODE,6      ; DETERMINE MEDIUM OR HIGH RES
        JB      V3              ; MODE 4 OR 5
        JA      V23             ; MODE 8, 9, OR A
V22:    MOV     CL,4            ; SHIFT VALUE FOR HIGH RES
        SAL     AH,1            ; COLUMN VALUE TIMES 2 FOR HIGH RES
        JMP     SHORT V3
V23:    CMP     CRT_MODE,9      ; CHECK MODE
        JA      V22             ; MODE A
        JE      V3              ; MODE 9
        MOV     CL,2            ; MODE 8 SHIFT VALUE
        SHR     AH,1
V3:     SHL     BX,CL           ; NOT_HIGH_RES
                                ; MULTIPLY *16 FOR HIGH RES
        MOV     DL,AH           ; COLUMN VALUE FOR RETURN
        MOV     DH,AL           ; ROW VALUE
        SHR     DH,1            ; DIVIDE BY 4
        SHR     DH,1            ; FOR VALUE IN 0-24 RANGE
        JMP     SHORT V5        ; LIGHT_PEN_RETURN_SET
;------ ALPHA MODE ON LIGHT PEN
V4:     DIV     BYTE PTR CRT_COLS ; DETERMINE ROW,COLUMN VALUE
        MOV     DH,AL           ; ROWS TO DH
        MOV     DL,AH           ; COLS TO DL
        SAL     AL,CL           ; MULTIPLY ROWS * 8
        MOV     CH,AL           ; GET RASTER VALUE TO RETURN REG
        MOV     BL,AH           ; COLUMN VALUE
        XOR     BH,BH           ; TO BX
        SAL     BX,CL
V5:                             ; LIGHT_PEN_RETURN_SET
        MOV     AH,1            ; INDICATE EVERYTHING SET
V6:                             ; LIGHT_PEN_RETURN
        PUSH    DX              ; SAVE RETURN VALUE (IN CASE)
        MOV     DX,ADDR_6845    ; GET BASE ADDRESS
        ADD     DX,7            ; POINT TO RESET PARM
        OUT     DX,AL           ; ADDRESS, NOT DATA, IS IMPORTANT
        POP     DX              ; RECOVER VALUE
V7:                             ; RETURN_NO_RESET
        POP     DI
        POP     SI
        POP     DS
        POP     DS
        POP     DS
        POP     DS
        POP     ES
        IRET
READ_LPEN       ENDP
;----------------------------------------------------------------
; TEMPORARY INTERRUPT SERVICE ROUTINE
; 1. THIS ROUTINE IS ALSO LEFT IN PLACE AFTER THE
;    POWER ON DIAGNOSTICS TO SERVICE UNUSED
;    INTERRUPT VECTORS. LOCATION 'INTR_FLAG' WILL
;    CONTAIN EITHER: 1. LEVEL OF HARDWARE INT. THAT
;                      CAUSED CODE TO BE EXEC.
;                    2. 'FF' FOR NON-HARDWARE INTERRUPTS THAT WERE
;                       EXECUTED ACCIDENTLY.
;----------------------------------------------------------------
D11             PROC    NEAR
ASSUME  DS:DATA
        PUSH    DS
        PUSH    AX              ; SAVE REG AX CONTENTS
        CALL    DDS
        MOV     AL,0BH          ; READ IN-SERVICE REG
        OUT     INTA00,AL       ; (FIND OUT WHAT LEVEL BEING
        NOP                     ; SERVICED)
        IN      AL,INTA00       ; GET LEVEL
        MOV     AH,AL           ; SAVE IT
        OR      AL,AH           ; 00? (NO HARDWARE ISR ACTIVE)
        JNZ     HW_INT
        MOV     AH,0FFH
        JMP     SHORT SET_INTR_FLAG ; SET FLAG TO FF IF NON-HDWARE
HW_INT: IN      AL,INTA01       ; GET MASK VALUE
        OR      AL,AH           ; MASK OFF LVL BEING SERVICED
        OUT     INTA01,AL
        MOV     AL,EOI
        OUT     INTA00,AL
SET_INTR_FLAG:
        MOV     INTR_FLAG,AH    ; SET FLAG
        POP     AX              ; RESTORE REG AX CONTENTS
        POP     DS
        STI                     ; INTERRUPTS BACK ON
DUMMY_RETURN:                   ; NEED IRET FOR VECTOR TABLE
        IRET
D11             ENDP
; --- INT 12 ----------------------------------------
; MEMORY_SIZE_DETERMINE
; INPUT
;       NO REGISTERS
;       THE MEMORY_SIZE VARIABLE IS SET DURING POWER ON DIAGNOSTICS
; OUTPUT
;       (AX) = NUMBER OF CONTIGUOUS 1K BLOCKS OF MEMORY
;---------------------------------------------------
ASSUME  CS:CODE,DS:DATA
        ORG     0F841H
MEMORY_SIZE_DETERMINE PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE SEGMENT
        MOV     AX,DATA         ; ESTABLISH ADDRESSING
        MOV     DS,AX
        MOV     AX,MEMORY_SIZE  ; GET VALUE
        POP     DS              ; RECOVER SEGMENT
        IRET                    ; RETURN TO CALLER
MEMORY_SIZE_DETERMINE ENDP
; --- INT 11 ---------------------------------------
; EQUIPMENT DETERMINATION
;       THIS ROUTINE ATTEMPTS TO DETERMINE WHAT OPTIONAL
;       DEVICES ARE ATTACHED TO THE SYSTEM.
; INPUT
;       NO REGISTERS
;       THE EQUIP_FLAG VARIABLE IS SET DURING THE POWER ON
;       DIAGNOSTICS USING THE FOLLOWING HARDWARE ASSUMPTIONS:
;               PORT 62 (0->3) = LOW ORDER BYTE OF EQUIPMENT
;               PORT 3FA = INTERRUPT ID REGISTER OF 8250
;                       BITS 7-3 ARE ALWAYS 0
;               PORT 378 = OUTPUT PORT OF PRINTER -- 8255 PORT THAT
;                               CAN BE READ AS WELL AS WRITTEN
; OUTPUT
;       (AX) IS SET, BIT SIGNIFICANT, TO INDICATE ATTACHED I/O
;               BIT 15,14 = NUMBER OF PRINTERS ATTACHED
;               BIT 13 = 1 = SERIAL PRINTER ATTACHED
;               BIT 12 = GAME I/O ATTACHED
;               BIT 11,10,9 = NUMBER OF RS232 CARDS ATTACHED
;               BIT 8 = 0 = DMA CHIP PRESENT ON SYSTEM, 1 = NO DMA ON SYSTEM
;               BIT 7,6 = NUMBER OF DISKETTE DRIVES
;                       00=1, 01=2, 10=3, 11=4 ONLY IF BIT 0 = 1
;               BIT 5,4 = INITIAL VIDEO MODE
;                       00 - UNUSED
;                       01 - 40X25 BW USING COLOR CARD
;                       10 - 80X25 BW USING COLOR CARD
;                       11 - 80X25 BW USING BW CARD
;               BIT 3,2 = PLANAR RAM SIZE (10=48K,11=64K)
;               BIT 1 NOT USED
;               BIT 0 = 1 (IPL DISKETTE INSTALLED)
;       NO OTHER REGISTERS AFFECTED
;------------------------------------------------------
ASSUME  CS:CODE,DS:DATA
        ORG     0F84DH
EQUIPMENT       PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; SAVE SEGMENT REGISTER
        MOV     AX,DATA         ; ESTABLISH ADDRESSING
        MOV     DS,AX
        MOV     AX,EQUIP_FLAG   ; GET THE CURRENT SETTINGS
        POP     DS              ; RECOVER SEGMENT
        IRET                    ; RETURN TO CALLER
EQUIPMENT       ENDP
; --- INT 15 ---------------------------------------
; CASSETTE I/O
;       (AH) = 0      TURN CASSETTE MOTOR ON
;       (AH) = 1      TURN CASSETTE MOTOR OFF
;       (AH) = 2      READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;                       (ES,BX) = POINTER TO DATA BUFFER
;                       (CX) = COUNT OF BYTES TO READ
;       ON EXIT
;               (ES,BX) = POINTER TO LAST BYTE READ + 1
;               (DX) = COUNT OF BYTES ACTUALLY READ
;               (CY) = 0 IF NO ERROR OCCURRED
;                       = 1 IF ERROR OCCURRED
;               (AH) = ERROR RETURN IF (CY)= 1
;                       = 01 IF CRC ERROR WAS DETECTED
;                       = 02 IF DATA TRANSITIONS ARE LOST
;                       = 04 IF NO DATA WAS FOUND
;       (AH) = 3      WRITE 1 OR MORE 256 BYTE BLOCKS TO CASSETTE
;                       (ES,BX) = POINTER TO DATA BUFFER
;                       (CX) = COUNT OF BYTES TO WRITE
;       ON EXIT
;               (EX,BX) = POINTER TO LAST BYTE WRITTEN + 1
;               (CX) = 0
;               (AH) = ANY OTHER THAN ABOVE VALUES CAUSES (CY)= 1
;                               AND (AH)= 80 TO BE RETURNED (INVALID COMMAND).
;------------------------------------------------------
ASSUME  DS:DATA,ES:NOTHING,SS:NOTHING,CS:CODE
        ORG     0F859H
CASSETTE_IO     PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS              ; ESTABLISH ADDRESSING TO DATA
        CALL    DDS
        AND     BIOS_BREAK,7FH  ; MAKE SURE BREAK FLAG IS OFF
        CALL    W1              ; CASSETTE_IO_CONT
        POP     DS
        RET     2               ; INTERRUPT RETURN
CASSETTE_IO     ENDP
W1              PROC    NEAR
; PURPOSE:
; TO CALL APPROPRIATE ROUTINE DEPENDING ON REG AH
;   AH          ROUTINE
;   --          -------
;    0          MOTOR ON
;    1          MOTOR OFF
;    2          READ CASSETTE BLOCK
;    3          WRITE CASSETTE BLOCK
;
        OR      AH,AH           ; TURN ON MOTOR?
        JZ      MOTOR_ON        ; YES, DO IT
        DEC     AH              ; TURN OFF MOTOR?
        JZ      MOTOR_OFF       ; YES, DO IT
        DEC     AH              ; READ CASSETTE BLOCK?
        JZ      READ_BLOCK      ; YES, DO IT
        DEC     AH              ; WRITE CASSETTE BLOCK?
        JNZ     W2              ; NOT DEFINED
        JMP     WRITE_BLOCK     ; YES, DO IT
W2:
        MOV     AH,080H         ; COMMAND NOT DEFINED
        STC                     ; ERROR, UNDEFINED OPERATION
        RET                     ; ERROR FLAG
W1              ENDP
MOTOR_ON        PROC    NEAR
;
; PURPOSE:
;     TO TURN ON CASSETTE MOTOR
; ------------------------------------------
        IN      AL,PORT_B       ; READ CASSETTE OUTPUT
        AND     AL,NOT 08H      ; CLEAR BIT TO TURN ON MOTOR
W3:     OUT     PORT_B,AL       ; WRITE IT OUT
        SUB     AH,AH           ; CLEAR AH
        RET
MOTOR_ON        ENDP
MOTOR_OFF       PROC    NEAR
;
; PURPOSE:
;     TO TURN CASSETTE MOTOR OFF
; ------------------------------------------
        IN      AL,PORT_B       ; READ CASSETTE OUTPUT
        OR      AL,08H          ; SET BIT TO TURN OFF
        JMP     W3              ; WRITE IT, CLEAR ERROR, RETURN
MOTOR_OFF       ENDP
READ_BLOCK      PROC    NEAR
;
; PURPOSE:
;     TO READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;
; ON ENTRY:
;     ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;     BX POINTS TO START OF MEMORY BUFFER
;     CX CONTAINS NUMBER OF BYTES TO READ
;
; ON EXIT:
;     BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;     CX CONTAINS DECREMENTED BYTE COUNT
;     DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;
;     CARRY FLAG IS CLEAR IF NO ERROR DETECTED
;     CARRY FLAG IS SET IF CRC ERROR DETECTED
; ------------------------------------------
        PUSH    BX              ; SAVE BX
        PUSH    CX              ; SAVE CX
        PUSH    SI              ; SAVE SI
        MOV     SI,7            ; SET UP RETRY COUNT FOR LEADER
        CALL    BEGIN_OP        ; BEGIN BY STARTING MOTOR
W4:
        IN      AL,PORT_C       ; SEARCH FOR LEADER
        AND     AL,010H         ; GET INITIAL VALUE
        MOV     LAST_VAL,AL     ; MASK OFF EXTRANEOUS BITS
        MOV     DX,16250        ; SAVE IN LOC LAST_VAL
W5:                             ; # OF TRANSITIONS TO LOOK FOR
        TEST    BIOS_BREAK,80H  ; WAIT_FOR_EDGE
        JNZ     W6A             ; CHECK FOR BREAK KEY
        DEC     DX              ; JUMP IF BEGINNING OF LEADER
        JNZ     W7              ; JUMP IF NO LEADER FOUND
W6A:    JMP     W17             ; IGNORE FIRST EDGE
W7:     CALL    READ_HALF_BIT   ; JUMP IF NO EDGE DETECTED
        JCXZ    W5              ; CHECK FOR HALF BITS
        MOV     DX,0378H        ; MUST HAVE AT LEAST THIS MANY ONE
        MOV     CX,200H         ; SIZE PULSES BEFORE CHCKNG FOR
                                ; SYNC BIT (0)
        CLI                     ; DISABLE INTERRUPTS
W8:
        TEST    BIOS_BREAK,80H  ; SEARCH-LDR
        JNZ     W17             ; CHECK FOR BREAK KEY
        PUSH    CX              ; JUMP IF BREAK KEY HIT
        CALL    READ_HALF_BIT   ; SAVE REG CX
        OR      CX,CX           ; GET PULSE WIDTH
        POP     CX              ; CHECK FOR TRANSITION
        JZ      W4              ; RESTORE ONE BIT COUNTER
        CMP     DX,BX           ; JUMP IF NO TRANSITION
        JCXZ    W9              ; CHECK PULSE WIDTH
                                ; IF CX=0 THEN WE CAN LOOK
                                ; FOR SYNC BIT (0)
        JNC     W4              ; JUMP IF ZERO BIT (NOT GOOD
                                ; LEADER)
        LOOP    W8              ; DEC CX AND READ ANOTHER HALF ONE
                                ; BIT
W9:
        JC      W8              ; FIND-SYNC
                                ; JUMP IF ONE BIT (STILL LEADER)
        CALL    READ_HALF_BIT   ; SKIP OTHER HALF OF SYNC BIT (0)
        CALL    READ_BYTE       ; READ SYNC BYTE
        CMP     AL,16H          ; SYNCHRONIZATION CHARACTER
        JNE     W16             ; JUMP IF BAD LEADER FOUND.

        POP     SI              ; RESTORE REGS
        POP     CX
        POP     BX
;---------------------------------------------------------------
; READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
; ON ENTRY:
;    ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;    BX POINTS TO START OF MEMORY BUFFER
;    CX CONTAINS NUMBER OF BYTES TO READ
;
; ON EXIT:
;    BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;    CX CONTAINS DECREMENTED BYTE COUNT
;    DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;---------------------------------------------------------------
        PUSH    CX              ; SAVE BYTE COUNT
W10:
        MOV     CRC_REG,0FFFFH  ; COME HERE BEFORE EACH
        MOV     DX,256          ; 256 BYTE BLOCK
W11:                            ; RD_BLK
        TEST    BIOS_BREAK,80H  ; CHECK FOR BREAK KEY
        JNZ     W13             ; JUMP IF BREAK KEY HIT
        CALL    READ_BYTE       ; READ BYTE FROM CASSETTE
        JC      W13             ; CY SET INDICATES NO DATA
                                ; TRANSITIONS
        JCXZ    W12             ; IF WE'VE ALREADY REACHED
                                ; END OF MEMORY BUFFER
                                ; SKIP REST OF BLOCK
        MOV     ES:[BX],AL      ; STORE DATA BYTE AT BYTE PTR
        INC     BX              ; INC BUFFER PTR
        DEC     CX              ; DEC BYTE COUNTER
W12:                            ; LOOP UNTIL DATA BLOCK HAS BEEN READ FROM CASSETTE
        DEC     DX              ; DEC BLOCK CNT
        JG      W11             ; RD_BLK
        CALL    READ_BYTE       ; NOW READ TWO CRC BYTES
        CALL    READ_BYTE
        SUB     AH,AH           ; CLEAR AH
        CMP     CRC_REG,1D0FH   ; IS THE CRC CORRECT?
        JNE     W14             ; IF NOT EQUAL CRC IS BAD
        JCXZ    W15             ; IF BYTE COUNT IS ZERO
                                ; THEN WE HAVE READ ENOUGH
                                ; SO WE WILL EXIT
        JMP     W10             ; STILL MORE, SO READ ANOTHER BLOCK
W13:                            ; MISSING-DATA
        MOV     AH,01H          ; SET AH=02 TO INDICATE
                                ; DATA TIMEOUT
W14:                            ; BAD-CRC
        INC     AH              ; EXIT EARLY ON ERROR
W15:                            ; SET AH=01 TO INDICATE CRC ERROR
        POP     DX              ; RD-BLK-EX
        SUB     DX,CX           ; CALCULATE COUNT OF
                                ; DATA BYTES ACTUALLY READ
                                ; RETURN COUNT IN REG DX
        PUSH    AX              ; SAVE AX (RET CODE)
        TEST    AH,90H          ; CHECK FOR ERRORS
        JNZ     W18             ; JUMP IF ERROR DETECTED
        CALL    READ_BYTE       ; READ TRAILER
        JMP     SHORT W18       ; SKIP TO TURN OFF MOTOR
; BAD-LEADER
W16:                            ; CHECK RETRIES
        DEC     SI
        JZ      W17             ; JUMP IF TOO MANY RETRIES
        JMP     W4              ; JUMP IF NOT TOO MANY RETRIES
W17:                            ; NO VALID DATA FOUND
        POP     SI              ; NO DATA FROM CASSETTE ERROR, I.E. TIMEOUT
        POP     CX              ; RESTORE REGS
        POP     BX              ; RESTORE REGS
        SUB     DX,DX           ; ZERO NUMBER OF BYTES READ
        MOV     AH,04H          ; TIME OUT ERROR (NO LEADER)
        PUSH    AX
W18:
        STI                     ; MOT-OFF
        CALL    MOTOR_OFF       ; REENABLE INTERRUPTS
                                ; TURN OFF MOTOR
        POP     AX              ; RESTORE RETURN CODE
        CMP     AH,01H          ; SET CARRY IF ERROR (AH>0)
        CMC
        RET                     ; FINISHED
READ_BLOCK      ENDP
; --------------------------------------------------------
; PURPOSE:
;              TO READ A BYTE FROM CASSETTE
; ON EXIT
;              REG AL CONTAINS READ DATA BYTE
; --------------------------------------------------------
READ_BYTE       PROC    NEAR
        PUSH    BX              ; SAVE REGS BX,CX
        PUSH    CX
        MOV     CL,8H           ; SET BIT COUNTER FOR 8 BITS
; BYTE-ASM
W19:    PUSH    CX              ; SAVE CX

; -----------------------------------------------------
; READ DATA BIT FROM CASSETTE
; -----------------------------------------------------
        CALL    READ_HALF_BIT   ; READ ONE PULSE
        JCXZ    W21             ; IF CX=0 THEN TIMEOUT
                                ; BECAUSE OF NO DATA TRANSITIONS
        PUSH    BX              ; SAVE 1ST HALF BIT'S
                                ; PULSE WIDTH (IN BX)
        CALL    READ_HALF_BIT   ; READ COMPLEMENTARY PULSE
        POP     AX              ; COMPUTE DATA BIT
        JCXZ    W21             ; IF CX=0 THEN TIMEOUT DUE TO
                                ; NO DATA TRANSITIONS
        ADD     BX,AX           ; PERIOD
        CMP     BX,06F0H        ; CHECK FOR ZERO BIT
        CMC                     ; CARRY IS SET IF ONE BIT
        LAHF                    ; SAVE CARRY IN AH
        POP     CX              ; RESTORE CX
; NOTE:
; MS BIT OF BYTE IS READ FIRST.
; REG CH IS SHIFTED LEFT WITH
; CARRY BEING INSERTED INTO LS
; BIT OF CH.
; AFTER ALL 8 BITS HAVE BEEN
; READ, THE MS BIT OF THE DATA
; BYTE WILL BE IN THE MS BIT OF
; REG CH
        RCL     CH,1            ; ROTATE REG CH LEFT WITH CARRY TO
                                ; LS BIT OF REG CH
        SAHF                    ; RESTORE CARRY FOR CRC ROUTINE
        CALL    CRC_GEN         ; GENERATE CRC FOR BIT
        DEC     CL              ; LOOP TILL ALL 8 BITS OF DATA
                                ; ASSEMBLED IN REG CH
        JNZ     W19             ; BYTE-ASM
        MOV     AL,CH           ; RETURN DATA BYTE IN REG AL
        CLC
W20:    POP     CX              ; RESTORE REGS CX,BX
        POP     BX
        RET                     ; FINISHED
W21:    POP     CX              ; NO-DATA
        STC                     ; RESTORE CX
        JMP     W20             ; INDICATE ERROR
READ_BYTE       ENDP

; -------------------------------------------------------
; PURPOSE:
;              TO COMPUTE TIME TILL NEXT DATA
;              TRANSITION (EDGE)
; ON ENTRY:
;              EDGE_CNT CONTAINS LAST EDGE COUNT
; ON EXIT:
;              AX CONTAINS OLD LAST EDGE COUNT
;              BX CONTAINS PULSE WIDTH (HALF BIT)
; -------------------------------------------------------
READ_HALF_BIT   PROC    NEAR
        MOV     CX,100          ; SET TIME TO WAIT FOR BIT
        MOV     AH,LAST_VAL     ; GET PRESENT INPUT VALUE
; RD-H-BIT
W22:
        IN      AL,PORT_C       ; INPUT DATA BIT
        AND     AL,010H         ; MASK OFF EXTRANEOUS BITS
        CMP     AL,AH           ; SAME AS BEFORE?
        LOOPE   W22             ; LOOP TILL IT CHANGES
        MOV     LAST_VAL,AL     ; UPDATE LAST_VAL WITH NEW VALUE
        MOV     AL,40H          ; READ TIMER'S COUNTER COMMAND
        OUT     TIM_CTL,AL      ; LATCH COUNTER
        MOV     BX,EDGE_CNT     ; BX GETS LAST EDGE COUNT
        IN      AL,TIMER+1      ; GET LS BYTE
        MOV     AH,AL           ; SAVE IN AH
        IN      AL,TIMER+1      ; GET MS BYTE
        XCHG    AL,AH           ; XCHG AL,AH
        SUB     BX,AX           ; SET BX EQUAL TO HALF BIT PERIOD
        MOV     EDGE_CNT,AX     ; UPDATE EDGE COUNT;
        RET
READ_HALF_BIT   ENDP
;---------------------------------------------------------
; PURPOSE
;       WRITE 1 OR MORE 256 BYTE BLOCKS TO CASSETTE.
;       THE DATA IS PADDED TO FILL OUT THE LAST 256 BYTE BLOCK.
; ON ENTRY:
;       BX POINTS TO MEMORY BUFFER ADDRESS
;       CX CONTAINS NUMBER OF BYTES TO WRITE
; ON EXIT:
;       BX POINTS 1 BYTE PAST LAST BYTE WRITTEN TO CASSETTE
;       CX IS ZERO
;---------------------------------------------------------
WRITE_BLOCK     PROC    NEAR
        PUSH    BX
        PUSH    CX
        IN      AL,PORT_B       ; DISABLE SPEAKER
        AND     AL,NOT 02H
        OR      AL,01H          ; ENABLE TIMER
        OUT     PORT_B,AL
        MOV     AL,0B6H         ; SET UP TIMER - MODE 3 SQUARE WAVE
        OUT     TIM_CTL,AL
        CALL    BEGIN_OP        ; START MOTOR AND DELAY
        MOV     AX,1184         ; SET NORMAL BIT SIZE
        CALL    W31             ; SET TIMER
        MOV     CX,0800H        ; SET CX FOR LEADER BYTE COUNT
; WRITE LEADER
; WRITE ONE BITS
W23:    STC
        CALL    WRITE_BIT       ; WRITE SYNC BIT (0)
        LOOP    W23             ; LOOP 'TIL LEADER IS WRITTEN
        CLI                     ; DISABLE INTS.
        CLC
        CALL    WRITE_BIT       ; WRITE SYNC BIT (0)
        POP     CX              ; RESTORE REGS CX,BX
        POP     BX
        MOV     AL,16H          ; WRITE SYNC CHARACTER
        CALL    WRITE_BYTE
;---------------------------------------------------------
; PURPOSE
;       WRITE 1 OR MORE 256 BYTE BLOCKS TO CASSETTE
; ON ENTRY:
;       BX POINTS TO MEMORY BUFFER ADDRESS
;       CONTAINS NUMBER OF BYTES TO WRITE
; ON EXIT:
;       BX POINTS 1 BYTE PAST LAST BYTE WRITTEN TO CASSETTE
;       CX IS ZERO
;---------------------------------------------------------
WR_BLOCK:
        MOV     CRC_REG,0FFFFH  ; INIT CRC
        MOV     DX,256          ; FOR 256 BYTES
; WR-BLK
W24:    MOV     AL,ES:[BX]      ; READ BYTE FROM MEM
        CALL    WRITE_BYTE      ; WRITE IT TO CASSETTE
        JCXZ    W25             ; UNLESS CX=0, ADVANCE PTRS & DEC
                                ; COUNT
        INC     BX              ; INC BUFFER POINTER
        DEC     CX              ; DEC BYTE COUNTER
; SKIP-ADV
W25:    DEC     DX              ; DEC BLOCK CNT
        JG      W24             ; LOOP TILL 256 BYTE BLOCK
                                ; IS WRITTEN TO TAPE
;---------------------------------------------------------
; WRITE CRC
;       WRITE 1'S COMPLEMENT OF CRC REG TO CASSETTE
;       WHICH IS CHECKED FOR CORRECTNESS WHEN THE BLOCK IS READ
; REG AX IS MODIFIED
;---------------------------------------------------------
        MOV     AX,CRC_REG      ; WRITE THE ONE'S COMPLEMENT OF THE
                                ; TWO BYTE CRC TO TAPE
        NOT     AX              ; FOR 1'S COMPLEMENT
        PUSH    AX              ; SAVE IT
        XCHG    AH,AL           ; WRITE MS BYTE FIRST
        CALL    WRITE_BYTE      ; WRITE IT
        POP     AX              ; GET IT BACK
        CALL    WRITE_BYTE      ; NOW WRITE LS BYTE
        OR      CX,CX           ; IS BYTE COUNT EXHAUSTED?
        JNZ     WR_BLOCK        ; JUMP IF NOT DONE YET
        PUSH    CX              ; SAVE REG CX
        STI                     ; RE-ENABLE INTERUPTS
        MOV     CX,32           ; WRITE OUT TRAILER BITS
; TRAIL-LOOP
W26:    STC
        CALL    WRITE_BIT       ; WRITE UNTIL TRAILER WRITTEN
        LOOP    W26             ; RESTORE REG CX
        POP     CX              ; TURN TIMER2 OFF
        MOV     AL,0B0H
        OUT     TIM_CTL,AL
        MOV     AX,1            ; SET TIMER
        CALL    W31             ; TURN MOTOR OFF
        CALL    MOTOR_OFF       ; NO ERRORS REPORTED ON WRITE OP
        SUB     AX,AX           ; FINISHED
        RET
WRITE_BLOCK     ENDP
; ------------------------------
; WRITE A BYTE TO CASSETTE.
; BYTE TO WRITE IS IN REG AL.
; ------------------------------
WRITE_BYTE      PROC    NEAR
        PUSH    CX              ; SAVE REGS CX,AX
        PUSH    AX
        MOV     CH,AL           ; AL=BYTE TO WRITE.
;   (MS BIT WRITTEN FIRST)
        MOV     CL,8            ; FOR 8 DATA BITS IN BYTE.
;   NOTE: TWO EDGES PER BIT
;   DISASSEMBLE THE DATA BIT
W27:    RCL     CH,1            ; ROTATE MS BIT INTO CARRY
        PUSHF                   ; SAVE FLAGS.
                                ;   NOTE: DATA BIT IS IN CARRY
        CALL    WRITE_BIT       ; WRITE DATA BIT
        POPF                    ; RESTORE CARRY FOR CRC CALC
        CALL    CRC_GEN         ; COMPUTE CRC ON DATA BIT
        DEC     CL              ; LOOP TILL ALL 8 BITS DONE
        JNZ     W27             ; JUMP IF NOT DONE YET
        POP     AX              ; RESTORE REGS AX,CX
        POP     CX
        RET                     ; WE ARE FINISHED
WRITE_BYTE      ENDP
; ------------------------------
WRITE_BIT       PROC    NEAR
; PURPOSE:
;
; TO WRITE A DATA BIT TO CASSETTE
; CARRY FLAG CONTAINS DATA BIT
; I.E. IF SET  DATA BIT IS A ONE
;      IF CLEAR DATA BIT IS A ZERO
;
; NOTE: TWO EDGES ARE WRITTEN PER BIT
;       ONE BIT HAS 500 USEC BETWEEN EDGES
;       FOR A 1000 USEC PERIOD (1 MILLISEC)
;
; ZERO BIT HAS 250 USEC BETWEEN EDGES
;       FOR A  500 USEC PERIOD (.5 MILLISEC)
; CARRY FLAG IS DATA BIT
; ------------------------------
       MOV     AX,1184          ; ASSUME IT'S A '1'
       JC      W28              ; SET AX TO NOMINAL ONE SIZE
; JUMP IF ONE BIT
       MOV     AX,592           ; NO, SET TO NOMINAL ZERO SIZE
W28:                            ; WRITE-BIT-AX
        PUSH    AX              ; WRITE BIT WITH PERIOD EQ TO VALUE
                                ;   AX
W29:    IN      AL,PORT_C       ; INPUT TIMER-0 OUTPUT
        AND     AL,020H
        JZ      W29             ; LOOP TILL HIGH
W30:    IN      AL,PORT_C       ; NOW WAIT TILL TIMER'S OUTPUT IS
                                ;   LOW
        AND     AL,020H
        JNZ     W30             ; RELOAD TIMER WITH PERIOD
                                ;   FOR NEXT DATA BIT
        POP     AX              ; RESTORE PERIOD COUNT
W31:    OUT     042H,AL         ; SET TIMER
        MOV     AL,AH
        OUT     042H,AL         ; SET HIGH BYTE OF TIMER 2
        RET
WRITE_BIT       ENDP
; ------------------------------
CRC_GEN         PROC    NEAR
; UPDATE CRC REGISTER WITH NEXT DATA BIT
; CRC IS USED TO DETECT READ ERRORS
; ASSUMES DATA BIT IS IN CARRY
; REG AX IS MODIFIED
; FLAGS ARE MODIFIED
; ------------------------------
        MOV     AX,CRC_REG      ; THE FOLLOWING INSTRUCTIONS
; WILL SET THE OVERFLOW FLAG
; IF CARRY AND MS BIT OF CRC
; ARE UNEQUAL
        RCR     AX,1
        RCL     AX,1
        CLC                     ; CLEAR CARRY
        JNO     W32             ; SKIP IF NO OVERFLOW
; IF DATA BIT XORED WITH
        XOR     AX,0810H        ; CRC REG BIT 15 IS ONE
; THEN XOR CRC REG WITH
; 0810H
        STC                     ; SET CARRY
W32:    RCL     AX,1            ; ROTATE CARRY (DATA BIT)
; INTO CRC REG
        MOV     CRC_REG,AX      ; UPDATE CRC_REG
        RET                     ; FINISHED
CRC_GEN         ENDP
;----------------------------------------------------------------
BEGIN_OP        PROC    NEAR        ; START TAPE AND DELAY
        CALL    MOTOR_ON            ; TURN ON MOTOR
        MOV     BL,42H              ; DELAY FOR TAPE DRIVE
; TO GET UP TO SPEED  (1/2 SEC)
W33:    MOV     CX,700H             ; INNER LOOP= APPROX. 10 MILLISEC
W34:    LOOP    W34
        DEC     BL
        JNZ     W33
        RET
BEGIN_OP       ENDP
;------ CARRIAGE RETURN, LINE FEED SUBROUTINE
CRLF            PROC    NEAR
        XOR     DX,DX               ; PRINTER 0
        XOR     AH,AH               ; WILL NOW SEND INITIAL LF,CR TO
                                    ; PRINTER
        MOV     AL,0DH              ; CR
        INT     17H                 ; SEND THE LINE FEED
        XOR     AH,AH               ; NOW FOR THE CR
        MOV     AL,0AH              ; LF
        INT     17H                 ; SEND THE CARRIAGE RETURN
        RET
CRLF            ENDP
;----------------------------------------------------------------
; CHARACTER GENERATOR GRAPHICS FOR 320X200 AND 640X200
; GRAPHICS FOR CHARACTERS 00H THRU 7FH
;----------------------------------------------------------------
        ORG     0FA6EH
CRT_CHAR_GEN    LABEL   BYTE
        DB      000H,000H,000H,000H,000H,000H,000H,000H ; D_00

        DB      07EH,081H,0A5H,081H,0BDH,099H,081H,07EH ; D_01

        DB      07EH,0FFH,0DBH,0FFH,0C3H,0E7H,0FFH,07EH ; D_02

        DB      06CH,0FEH,0FEH,0FEH,07CH,038H,010H,000H ; D_03

        DB      010H,038H,07CH,0FEH,07CH,038H,010H,000H ; D_04

        DB      038H,07CH,038H,0FEH,0FEH,07CH,038H,07CH ; D_05

        DB      010H,010H,038H,07CH,0FEH,07CH,038H,07CH ; D_06

        DB      000H,000H,018H,03CH,03CH,018H,000H,000H ; D_07

        DB      0FFH,0FFH,0E7H,0C3H,0C3H,0E7H,0FFH,0FFH ; D_08

        DB      000H,03CH,066H,042H,042H,066H,03CH,000H ; D_09

        DB      0FFH,0C3H,099H,0BDH,0BDH,099H,0C3H,0FFH ; D_0A

        DB      00FH,007H,00FH,07DH,0CCH,0CCH,0CCH,078H ; D_0B

        DB      03CH,066H,066H,066H,03CH,018H,07EH,018H ; D_0C

        DB      03FH,033H,03FH,030H,030H,070H,0F0H,0E0H ; D_0D

        DB      07FH,063H,07FH,063H,063H,067H,0E6H,0C0H ; D_0E

        DB      099H,05AH,03CH,0E7H,0E7H,03CH,05AH,099H ; D_0F

        DB      080H,0E0H,0F8H,0FEH,0F8H,0E0H,080H,000H ; D_10

        DB      002H,00EH,03EH,0FEH,03EH,00EH,002H,000H ; D_11

        DB      018H,03CH,07EH,018H,018H,07EH,03CH,018H ; D_12

        DB      066H,066H,066H,066H,066H,000H,066H,000H ; D_13

        DB      07FH,0DBH,0DBH,07BH,01BH,01BH,01BH,000H ; D_14

        DB      03EH,063H,038H,06CH,06CH,038H,0CCH,078H ; D_15

        DB      000H,000H,000H,000H,07EH,07EH,07EH,000H ; D_16

        DB      018H,03CH,07EH,018H,07EH,03CH,018H,0FFH ; D_17

        DB      018H,03CH,07EH,018H,018H,018H,018H,000H ; D_18

        DB      018H,018H,018H,018H,07EH,03CH,018H,000H ; D_19

        DB      000H,018H,00CH,0FEH,00CH,018H,000H,000H ; D_1A

        DB      000H,030H,060H,0FEH,060H,030H,000H,000H ; D_1B

        DB      000H,000H,0C0H,0C0H,0C0H,0FEH,000H,000H ; D_1C

        DB      000H,024H,066H,0FFH,066H,024H,000H,000H ; D_1D

        DB      000H,018H,03CH,07EH,0FFH,0FFH,000H,000H ; D_1E

        DB      000H,0FFH,0FFH,07EH,03CH,018H,000H,000H ; D_1F

        DB      000H,000H,000H,000H,000H,000H,000H,000H ; SP D_20

        DB      030H,078H,078H,030H,030H,000H,030H,000H ; ! D_21

        DB      06CH,06CH,06CH,000H,000H,000H,000H,000H ; " D_22

        DB      06CH,06CH,0FEH,06CH,0FEH,06CH,06CH,000H ; # D_23

        DB      030H,07CH,0C0H,078H,00CH,0F8H,030H,000H ; $ D_24

        DB      000H,0C6H,0CCH,018H,030H,066H,0C6H,000H ; PER CENT D_25

        DB      038H,06CH,038H,076H,0DCH,0CCH,076H,000H ; & D_26

        DB      060H,060H,0C0H,000H,000H,000H,000H,000H ; ' D_27

        DB      018H,030H,060H,060H,060H,030H,018H,000H ; ( D_28

        DB      060H,030H,018H,018H,018H,030H,060H,000H ; ) D_29

        DB      000H,066H,03CH,0FFH,03CH,066H,000H,000H ; * D_2A

        DB      000H,030H,030H,0FCH,030H,030H,000H,000H ; + D_2B

        DB      000H,000H,000H,000H,000H,030H,030H,060H ; , D_2C

        DB      000H,000H,000H,0FCH,000H,000H,000H,000H ; - D_2D

        DB      000H,000H,000H,000H,000H,030H,030H,000H ; . D_2E

        DB      006H,00CH,018H,030H,060H,0C0H,080H,000H ; / D_2F


        DB      07CH,0C6H,0CEH,0DEH,0F6H,0E6H,07CH,000H ; 0 D_30

        DB      030H,070H,030H,030H,030H,030H,0FCH,000H ; 1 D_31

        DB      078H,0CCH,00CH,038H,060H,0CCH,0FCH,000H ; 2 D_32

        DB      078H,0CCH,00CH,038H,00CH,0CCH,078H,000H ; 3 D_33

        DB      01CH,03CH,06CH,0CCH,0FEH,00CH,01EH,000H ; 4 D_34

        DB      0FCH,0C0H,0F8H,00CH,00CH,0CCH,078H,000H ; 5 D_35

        DB      038H,060H,0C0H,0F8H,0CCH,0CCH,078H,000H ; 6 D_36

        DB      0FCH,0CCH,00CH,018H,030H,030H,030H,000H ; 7 D_37

        DB      078H,0CCH,0CCH,078H,0CCH,0CCH,078H,000H ; 8 D_38

        DB      078H,0CCH,0CCH,07CH,00CH,018H,070H,000H ; 9 D_39

        DB      000H,030H,030H,000H,000H,030H,030H,000H ; : D_3A

        DB      000H,030H,030H,000H,000H,030H,030H,060H ; ; D_3B

        DB      018H,030H,060H,0C0H,060H,030H,018H,000H ; < D_3C

        DB      000H,000H,0FCH,000H,000H,0FCH,000H,000H ; = D_3D

        DB      060H,030H,018H,00CH,018H,030H,060H,000H ; > D_3E

        DB      078H,0CCH,00CH,018H,030H,000H,030H,000H ; ? D_3F


        DB      07CH,0C6H,0DEH,0DEH,0DEH,0C0H,078H,000H ; @ D_40

        DB      030H,078H,0CCH,0CCH,0FCH,0CCH,0CCH,000H ; A D_41

        DB      0FCH,066H,066H,07CH,066H,066H,0FCH,000H ; B D_42

        DB      03CH,066H,0C0H,0C0H,0C0H,066H,03CH,000H ; C D_43

        DB      0F8H,06CH,066H,066H,066H,06CH,0F8H,000H ; D D_44

        DB      0FEH,062H,068H,078H,068H,062H,0FEH,000H ; E D_45

        DB      0FEH,062H,068H,078H,068H,060H,0F0H,000H ; F D_46

        DB      03CH,066H,0C0H,0C0H,0CEH,066H,03EH,000H ; G D_47

        DB      0CCH,0CCH,0CCH,0FCH,0CCH,0CCH,0CCH,000H ; H D_48

        DB      078H,030H,030H,030H,030H,030H,078H,000H ; I D_49

        DB      01EH,00CH,00CH,00CH,0CCH,0CCH,078H,000H ; J D_4A

        DB      0E6H,066H,06CH,078H,06CH,066H,0E6H,000H ; K D_4B

        DB      0F0H,060H,060H,060H,062H,066H,0FEH,000H ; L D_4C

        DB      0C6H,0EEH,0FEH,0FEH,0D6H,0C6H,0C6H,000H ; M D_4D

        DB      0C6H,0E6H,0F6H,0DEH,0CEH,0C6H,0C6H,000H ; N D_4E

        DB      038H,06CH,0C6H,0C6H,0C6H,06CH,038H,000H ; O D_4F

        DB      0FCH,066H,066H,07CH,060H,060H,0F0H,000H ; P D_50

        DB      078H,0CCH,0CCH,0CCH,0DCH,078H,01CH,000H ; Q D_51

        DB      0FCH,066H,066H,07CH,06CH,066H,0E6H,000H ; R D_52

        DB      078H,0CCH,0E0H,070H,01CH,0CCH,078H,000H ; S D_53

        DB      0FCH,0B4H,030H,030H,030H,030H,078H,000H ; T D_54

        DB      0CCH,0CCH,0CCH,0CCH,0CCH,0CCH,0FCH,000H ; U D_55

        DB      0CCH,0CCH,0CCH,0CCH,0CCH,078H,030H,000H ; V D_56

        DB      0C6H,0C6H,0C6H,0D6H,0FEH,0EEH,0C6H,000H ; W D_57

        DB      0C6H,0C6H,06CH,038H,038H,06CH,0C6H,000H ; X D_58

        DB      0CCH,0CCH,0CCH,078H,030H,030H,078H,000H ; Y D_59

        DB      0FEH,0C6H,08CH,018H,032H,066H,0FEH,000H ; Z D_5A

        DB      078H,060H,060H,060H,060H,060H,078H,000H ; [ D_5B

        DB      0C0H,060H,030H,018H,00CH,006H,002H,000H ; BACKSLASH D_5C

        DB      078H,018H,018H,018H,018H,018H,078H,000H ; ] D_5D

        DB      010H,038H,06CH,0C6H,000H,000H,000H,000H ; CIRCUMFLEX D_5E

        DB      000H,000H,000H,000H,000H,000H,000H,0FFH ; _ D_5F

        DB      030H,030H,018H,000H,000H,000H,000H,000H ; ' D_60

        DB      000H,000H,078H,00CH,07CH,0CCH,076H,000H ; LOWER CASE A D_61

        DB      0E0H,060H,060H,07CH,066H,066H,0DCH,000H ; LC B D_62

        DB      000H,000H,078H,0CCH,0C0H,0CCH,078H,000H ; LC C D_63

        DB      01CH,00CH,00CH,07CH,0CCH,0CCH,076H,000H ; LC D D_64

        DB      000H,000H,078H,0CCH,0FCH,0C0H,078H,000H ; LC E D_65

        DB      038H,06CH,060H,0F0H,060H,060H,0F0H,000H ; LC F D_66

        DB      000H,000H,076H,0CCH,0CCH,07CH,00CH,0F8H ; LC G D_67

        DB      0E0H,060H,06CH,076H,066H,066H,0E6H,000H ; LC H D_68

        DB      030H,000H,070H,030H,030H,030H,078H,000H ; LC I D_69

        DB      00CH,000H,00CH,00CH,00CH,0CCH,0CCH,078H ; LC J D_6A

        DB      0E0H,060H,066H,06CH,078H,06CH,0E6H,000H ; LC K D_6B

        DB      070H,030H,030H,030H,030H,030H,078H,000H ; LC L D_6C

        DB      000H,000H,0CCH,0FEH,0FEH,0D6H,0C6H,000H ; LC M D_6D

        DB      000H,000H,0F8H,0CCH,0CCH,0CCH,0CCH,000H ; LC N D_6E

        DB      000H,000H,078H,0CCH,0CCH,0CCH,078H,000H ; LC O D_6F


        DB      000H,000H,0DCH,066H,066H,07CH,060H,0F0H ; LC P D_70

        DB      000H,000H,076H,0CCH,0CCH,07CH,00CH,01EH ; LC Q D_71

        DB      000H,000H,0DCH,076H,066H,060H,0F0H,000H ; LC R D_72

        DB      000H,000H,07CH,0C0H,078H,00CH,0F8H,000H ; LC S D_73

        DB      010H,030H,07CH,030H,030H,034H,018H,000H ; LC T D_74

        DB      000H,000H,0CCH,0CCH,0CCH,0CCH,076H,000H ; LC U D_75

        DB      000H,000H,0CCH,0CCH,0CCH,078H,030H,000H ; LC V D_76

        DB      000H,000H,0C6H,0D6H,0FEH,0FEH,06CH,000H ; LC W D_77

        DB      000H,000H,0C6H,06CH,038H,06CH,0C6H,000H ; LC X D_78

        DB      000H,000H,0CCH,0CCH,0CCH,07CH,00CH,0F8H ; LC Y D_79

        DB      000H,000H,0FCH,098H,030H,064H,0FCH,000H ; LC Z D_7A

        DB      01CH,030H,030H,0E0H,030H,030H,01CH,000H ; { D_7B

        DB      018H,018H,018H,000H,018H,018H,018H,000H ; | D_7C

        DB      0E0H,030H,030H,01CH,030H,030H,0E0H,000H ; } D_7D

        DB      076H,0DCH,000H,000H,000H,000H,000H,000H ; ~ D_7E

        DB      000H,010H,038H,06CH,0C6H,0C6H,0FEH,000H ; DELTA D_7F

        ORG     0FE6EH
        JMP     NEAR PTR TIME_OF_DAY
;----------------------------------------------------------
;               CRC CHECK/GENERATION ROUTINE
; ROUTINE TO CHECK A ROM MODULE USING THE POLYNOMINAL:
;               X16 + X12 + X5 + 1
; CALLING PARAMETERS:
;       DS = DATA SEGMENT OF ROM SPACE TO BE CHECKED
;       SI = INDEX OFFSET INTO DS POINTING TO 1ST BYTE
;       CX = LENGTH OF SPACE TO BE CHECKED (INCLUDING CRC BYTES)
; ON EXIT:
;       ZERO FLAG = SET = CRC CHECKED OK
;       AH = 00
;       AL = ??
;       BX = 0000
;       CL = 04
;       DX = 0000 IF CRC CHECKED OK, ELSE, ACCUMULATED CRC
;       SI = (SI(ENTRY)+BX(ENTRY)
;       NOTE: ROUTINE WILL RETURN IMMEDIATLY IF "RESET_FLAG
;               IS EQUAL TO "1234H" (WARM START)
;----------------------------------------------------------
CRC_CHECK       PROC    NEAR
ASSUME  DS:NOTHING
        MOV     BX,CX           ; SAVE COUNT
        MOV     DX,0FFFFH       ; INIT. ENCODE REGISTER
        CLD                     ; SET DIR FLAG TO INCREMENT
        XOR     AH,AH           ; INIT. WORK REG HIGH
        MOV     CL,4            ; SET ROTATE COUNT
CRC_1:  LODSB                   ; GET A BYTE
        XOR     DH,AL           ; FORM AJ + CJ + 1
        MOV     AL,DH
        ROL     AX,CL           ; SHIFT WORK REG BACK 4
        XOR     DX,AX           ; ADD INTO RESULT REG
        ROL     AX,1            ; SHIFT WORK REG BACK 1
        XCHG    DH,DL           ; SWAP PARTIAL SUM INTO RESULT REG
        XOR     DX,AX           ; ADD WORK REG INTO RESULTS
        ROR     AX,CL           ; SHIFT WORK REG OVER 4
        AND     AL,11100000B    ; CLEAR OFF (EFGH)
        XOR     DX,AX           ; ADD (ABCD) INTO RESULTS
        ROR     AX,1            ; SHIFT WORK REG ON OVER (AH=0 FOR
                                ;       NEXT PASS)
        XOR     DH,AL           ; ADD (ABCD INTO RESULTS LOW)
        DEC     BX              ; DECREMENT COUNT
        JNZ     CRC_1           ; LOOP TILL COUNT = 0000
        OR      DX,DX           ; DX S/B = 0000 IF O.K.
        RET                     ; RETURN TO CALLER
CRC_CHECK       ENDP
;----------------------------------------------------------
; SUBROUTINE TO READ AN 8250 REGISTER.  MAY ALSO BUMP ERROR
; REPORTER (BL) AND/OR REG DX (PORT ADDRESS) DEPENDING ON
; WHICH ENTRY POINT IS CHOSEN.
; THIS SUBROUTINE WAS WRITTEN TO AVOID MULTIPLE USE OF I/O TIME
; DELAYS FOR THE 8250.  IT WAS THE MOST EFFICIENT WAY TO
; INCLUDE THE DELAYS.
; IN EVERY CASE, UPON RETURN, REG AL WILL CONTAIN THE CONTENTS OF
;       PORT(DX)
;----------------------------------------------------------
RR1             PROC    NEAR
        XOR     AL,AL
        OUT     DX,AL           ; DISABLE ALL INTERRUPTS
        INC     BL              ; BUMP ERROR REPORTER
RR2:    INC     DX              ; INCR PORT ADDR
RR3:    IN      AL,DX           ; READ REGISTER
        RET
RR1             ENDP
;----------------------------------------------------------
; THIS ROUTINE HANDLES THE TIMER INTERRUPT FROM
; CHANNEL 0 OF THE 8253 TIMER.  INPUT FREQUENCY IS 1.19318 MHZ
; AND THE DIVISOR IS 65536, RESULTING IN APPROX. 18.2 INTERRUPTS
; EVERY SECOND.
;
; THE INTERRUPT HANDLER MAINTAINS A COUNT OF INTERRUPTS SINCE POWER
; ON TIME, WHICH MAY BE USED TO ESTABLISH TIME OF DAY.
; INTERRUPTS MISSED WHILE INTS. WERE DISABLED ARE TAKEN CARE OF
; BY THE USE OF TIMER 1 AS A OVERFLOW COUNTER
; THE INTERRUPT HANDLER ALSO DECREMENTS THE MOTOR CONTROL COUNT
; OF THE DISKETTE, AND WHEN IT EXPIRES, WILL TURN OFF THE DISKETTE
; MOTOR, AND RESET THE MOTOR RUNNING FLAGS
; THE INTERRUPT HANDLER WILL ALSO INVOKE A USER ROUTINE THROUGH
; INTERRUPT 1CH AT EVERY TIME TICK.  THE USER MUST CODE A ROUTINE
; AND PLACE THE CORRECT ADDRESS IN THE VECTOR TABLE.
;----------------------------------------------------------
        ORG     0FEA5H
ASSUME  DS:DATA
TIMER_INT       PROC    FAR
        STI                     ; INTERRUPTS BACK ON
        PUSH    DS
        PUSH    AX
        PUSH    DX              ; SAVE MACHINE STATE
        CALL    DDS
        INC     TIMER_LOW       ; INCREMENT TIME
        JNZ     T4              ; TEST_DAY
        INC     TIMER_HIGH      ; INCREMENT HIGH WORD OF TIME
T4:     CMP     TIMER_HIGH,018H ; TEST FOR COUNT EQUALLING 24 HOURS
        JNZ     T5              ; DISKETTE_CTL
        CMP     TIMER_LOW,0B0H
        JNZ     T5              ; DISKETTE_CTL
        SUB     AX,AX
        MOV     TIMER_HIGH,AX
        MOV     TIMER_LOW,AX
        MOV     TIMER_OFL,1

T5:                             ; LOOP TILL ALL OVERFLOWS TAKEN
                                ; CARE OF
        DEC     MOTOR_COUNT
        JNZ     T6              ; RETURN IF COUNT NOT OUT
        AND     MOTOR_STATUS,0F0H ; TURN OFF MOTOR RUNNING BITS
        MOV     AL,FDC_RESET    ; TURN OFF MOTOR, DO NOT RESET FDC
        OUT     NEC_CTL,AL      ; TURN OFF THE MOTOR
T6:     INT     1CH             ; TRANSFER CONTROL TO A USER
                                ; ROUTINE
        MOV     AL,EOI
        OUT     020H,AL         ; END OF INTERRUPT TO 8259
        POP     DX
        POP     AX
        POP     DS              ; RESET MACHINE STATE
        IRET                    ; RETURN FROM INTERRUPT
TIMER_INT       ENDP
;-------------------------------------------------------------------
; ARITHMETIC CHECKSUM ROUTINE
;
;       ENTRY:
;               DS = DATA SEGMENT OF ROM SPACE TO BE CHECKED
;               SI = INDEX OFFSET INTO DS POINTING TO 1ST BYTE
;               CX = LENGTH OF SPACE TO BE CHECKED
;       EXIT:   ZERO FLAG OFF=ERROR, ON= SPACE CHECKED OK
;-------------------------------------------------------------------
ROS_CHECKSUM    PROC    NEAR
RC_0:   ADD     AL,DS:[SI]
        INC     SI
        LOOP    RC_0
        OR      AL,AL
        RET
ROS_CHECKSUM    ENDP
;-------------------------------------------------------------------
; THESE ARE THE VECTORS WHICH ARE MOVED INTO
; THE 8086 INTERRUPT AREA DURING POWER ON.
; ONLY THE OFFSETS ARE DISPLAYED HERE, CODE
; SEGMENT WILL BE ADDED FOR ALL OF THEM, EXCEPT
; WHERE NOTED.
;-------------------------------------------------------------------

        ASSUME  CS:CODE
        ORG     0FEF3H
VECTOR_TABLE    LABEL   WORD    ; VECTOR TABLE FOR MOVE TO INTERRUPTS
        DW      OFFSET TIMER_INT ; INTERRUPT 8
        DW      OFFSET KB_INT    ; INTERRUPT 9
        DW      OFFSET D11       ; INTERRUPT A
        DW      OFFSET D11       ; INTERRUPT B
        DW      OFFSET D11       ; INTERRUPT C
        DW      OFFSET D11       ; INTERRUPT D
        DW      OFFSET DISK_INT  ; INTERRUPT E
        DW      OFFSET D11       ; INTERRUPT F
        DW      OFFSET VIDEO_IO  ; INTERRUPT 10H
        DW      OFFSET EQUIPMENT ; INTERRUPT 11H
        DW      OFFSET MEMORY_SIZE_DETERMINE ; INTERRUPT 12H
        DW      OFFSET DISKETTE_IO ; INTERRUPT 13H
        DW      OFFSET RS232_IO  ; INTERRUPT 14H
        DW      OFFSET CASSETTE_IO ; INTERRUPT 15H
        DW      OFFSET KEYBOARD_IO ; INTERRUPT 16H
        DW      OFFSET PRINTER_IO ; INTERRUPT 17H
        DW      00000H           ; INTERRUPT 18H
        ;       DW      0F600H           ; MUST BE INSERTED INTO TABLE LATER
        DW      OFFSET BOOT_STRAP ; INTERRUPT 19H
        DW      TIME_OF_DAY      ; INTERRUPT 1AH -- TIME OF DAY
        DW      DUMMY_RETURN     ; INTERRUPT 1BH -- KEYBD BREAK ADDR
        DW      DUMMY_RETURN     ; INTERRUPT 1C -- TIMER BREAK ADDR
        DW      VIDEO_PARMS      ; INTERRUPT 1D -- VIDEO PARAMETERS
        DW      OFFSET DISK_BASE ; INTERRUPT 1E -- DISK PARMS
        DW      CRT_CHARH        ; INTERRUPT 1F -- VIDEO EXT
P_MSG          PROC    NEAR
G12A:   MOV     AL,CS:[SI]      ; PUT CHAR IN AL
        INC     SI              ; POINT TO NEXT CHAR
        PUSH    AX              ; SAVE PRINT CHAR
        CALL    PRT_HEX         ; CALL VIDEO_IO
        POP     AX              ; RECOVER PRINT CHAR
        CMP     AL,13           ; WAS IT CARRAGE RETURN?
        JNE     G12A            ; NO,KEEP PRINTING STRING
        RET
P_MSG          ENDP
        ; ROUTINE TO SOUND BEEPER
BEEP            PROC    NEAR
        MOV     AL,10110110B    ; SEL TIM 2,LSB,MSB,BINARY
        OUT     TIMER+3,AL      ; WRITE THE TIMER MODE REG
        MOV     AX,533H         ; DIVISOR FOR 1000 HZ
        OUT     TIMER+2,AL      ; WRITE TIMER 2 CNT - LSB
        MOV     AL,AH
        OUT     TIMER+2,AL      ; WRITE TIMER 2 CNT - MSB
        IN      AL,PORT_B       ; GET CURRENT SETTING OF PORT
        MOV     AH,AL           ; SAVE THAT SETTING
        OR      AL,03           ; TURN SPEAKER ON
        OUT     PORT_B,AL
        SUB     CX,CX           ; SET CNT TO WAIT 500 MS
G7:     LOOP    G7              ; DELAY BEFORE TURNING OFF
        DEC     BL              ; DELAY CNT EXPIRED?
        JNZ     G7              ; NO - CONTINUE BEEPING SPK
        MOV     AL,AH           ; RECOVER VALUE OF PORT
        OUT     PORT_B,AL
        RET                     ; RETURN TO CALLER
BEEP            ENDP
; -------------------------------
; DUMMY RETURN FOR ADDRESS COMPATIBILITY
; -------------------------------

        ORG     0FF53H
        IRET
; -- INT 5 -----------------------------------------
; THIS LOGIC WILL BE INVOKED BY INTERRUPT 05H TO PRINT
; THE SCREEN.  THE CURSOR POSITION AT THE TIME THIS ROUTINE
; IS INVOKED WILL BE SAVED AND RESTORED UPON COMPLETION.  THE
; ROUTINE IS INTENDED TO RUN WITH INTERRUPTS ENABLED.
; IF A SUBSEQUENT 'PRINT SCREEN KEY IS DEPRESSED DURING THE
; TIME THIS ROUTINE IS PRINTING IT WILL BE IGNORED.
; ADDRESS 50:0 CONTAINS THE STATUS OF THE PRINT SCREEN:
;
;       50:0    =0      EITHER PRINT SCREEN HAS NOT BEEN CALLED
;                       OR UPON RETURN FROM A CALL THIS INDICATES
;                       A SUCCESSFUL OPERATION.
;
;               =1      PRINT SCREEN IS IN PROGRESS
;
;               =0FFH  ERROR ENCOUNTERED DURING PRINTING
; -------------------------------------------------------
ASSUME  CS:CODE,DS:XXDATA
        ORG     0FF54H
PRINT_SCREEN    PROC    FAR
        STI                     ; MUST RUN WITH INTERRUPTS ENABLED
        PUSH    DS              ; MUST USE 50:0 FOR DATA AREA
                                ; STORAGE
        PUSH    AX
        PUSH    BX              ; WILL USE THIS LATER FOR CURSOR
        PUSH    CX              ; LIMITS
        PUSH    DX              ; WILL HOLD CURRENT CURSOR POSITION
        MOV     AX,XXDATA       ; HEX 50
        MOV     DS,AX
        CMP     STATUS_BYTE,1   ; SEE IF PRINT ALREADY IN PROGRESS
        JZ      EXIT            ; JUMP IF PRINT ALREADY IN PROGRESS
        MOV     STATUS_BYTE,1   ; INDICATE PRINT NOW IN PROGRESS
        MOV     AH,15           ; WILL REQUEST THE CURRENT SCREEN
                                ; MODE
        INT     10H             ;       [AL]=MODE
                                ;       [AH]=NUMBER COLUMNS/LINE
                                ;       [BH]=VISUAL PAGE
; *****************************************************
; AT THIS POINT WE KNOW THE COLUMNS/LINE ARE IN
; [AX] AND THE PAGE IF APPLICABLE IS IN [BH].  THE STACK
; HAS DS,AX,BX,CX,DX PUSHED.  [AL] HAS VIDEO MODE
; *****************************************************
        MOV     CL,AH           ; WILL MAKE USE OF [CX] REGISTER TO
        MOV     CH,25           ; CONTROL ROW & COLUMNS
        CALL    CRLF            ; CARRIAGE RETURN LINE FEED ROUTINE
        PUSH    CX              ; SAVE SCREEN BOUNDS
        MOV     AH,3            ; WILL NOW READ THE CURSOR.
        INT     10H             ; AND PRESERVE THE POSITION
        POP     CX              ; RECALL SCREEN BOUNDS
        PUSH    DX              ; RECALL [BH]=VISUAL PAGE
        XOR     DX,DX           ; WILL SET CURSOR POSITION TO [0,0]
; *******************************************************
; THE LOOP FROM PRI10 TO THE INSTRUCTION PRIOR TO PRI20
; IS THE LOOP TO READ EACH CURSOR POSITION FROM THE SCREEN
; AND PRINT.
; *******************************************************
PRI10:  MOV     AH,2            ; TO INDICATE CURSOR SET REQUEST
        INT     10H             ; NEW CURSOR POSITION ESTABLISHED
        MOV     AH,8            ; TO INDICATE READ CHARACTER
        INT     10H             ; CHARACTER NOW IN [AL]
        OR      AL,AL           ; SEE IF VALID CHAR
        JNZ     PRI15           ; JUMP IF VALID CHAR
        MOV     AL,' '          ; MAKE A BLANK
PRI15:  PUSH    DX              ; SAVE CURSOR POSITION
        XOR     DX,DX           ; INDICATE PRINTER 1
        XOR     AH,AH           ; TO INDICATE PRINT CHAR IN [AL]
        INT     17H             ; PRINT THE CHARACTER
        POP     DX              ; RECALL CURSOR POSITION
        TEST    AH,029H         ; TEST FOR PRINTER ERROR
        JNZ     ERR10           ; JUMP IF ERROR DETECTED
        INC     DL              ; ADVANCE TO NEXT COLUMN
        CMP     CL,DL           ; SEE IF AT END OF LINE
        JNZ     PRI10           ; IF NOT PROCEED
        XOR     DL,DL           ; BACK TO COLUMN 0
        MOV     AH,DL           ; [AH]=0
        PUSH    DX              ; SAVE NEW CURSOR POSITION
        CALL    CRLF            ; LINE FEED CARRIAGE RETURN
        POP     DX              ; RECALL CURSOR POSITION
        INC     DH              ; ADVANCE TO NEXT LINE
        CMP     CH,DH           ; FINISHED?
        JNZ     PRI10           ; IF NOT CONTINUE
        POP     DX              ; RECALL CURSOR POSITION
        MOV     AH,2            ; TO INDICATE CURSOR SET REQUEST
        INT     10H             ; CURSOR POSITION RESTORED
        MOV     STATUS_BYTE,0   ; INDICATE FINISHED
        JMP     SHORT EXIT      ; EXIT THE ROUTINE
ERR10:  POP     DX              ; GET CURSOR POSITION
        MOV     AH,2            ; TO REQUEST CURSOR SET
        INT     10H             ; CURSOR POSITION RESTORED
        MOV     STATUS_BYTE,0FFH ; INDICATE ERROR
EXIT:   POP     DX              ; RESTORE ALL THE REGISTERS USED
        POP     CX
        POP     BX
        POP     AX
        POP     DS
        IRET
PRINT_SCREEN    ENDP
;-------------------------------------------------------;
; EASE OF USE REVECTOR ROUTINE - CALLED THROUGH          ;
; INT 18H WHEN CASSETTE BASIC IS INVOKED (NO DISKETTE    ;
; NO CARTRIDGES)                                         ;
; KEYBOARD VECTOR IS RESET TO POINT TO "NEW_INT_9"       ;
; BASIC VECTOR IS SET TO POINT TO F600:0                 ;
;-------------------------------------------------------;
BAS_ENT         PROC    FAR
ASSUME  DS:ABS0
        SUB     AX,AX
        MOV     DS,AX           ; SET ADDRESSING
        MOV     WORD PTR INT_PTR+4,OFFSET NEW_INT_9
        MOV     BASIC_PTR,AX    ; SET INT 18=F600:0
        MOV     BASIC_PTR+2,0F600H
        INT     18H             ; GO TO BASIC
BAS_ENT         ENDP
;-------------------------------------------------------;
; INITIALIZE TIMER SUBROUTINE - ASSUMES BOTH THE LSB AND MSB
; OF THE TIMER WILL BE USED.                             ;
;                                                       ;
; CALLING PARAMETERS:                                   ;
;   (AH) = TIMER #                                      ;
;   (AL) = BIT PATTERN OF INITIALIZATION WORD           ;
;   (BX) = INITIAL COUNT                                ;
;         (BH) = MSB COUNT                              ;
;         (BL) = LSB COUNT                              ;
;                                                       ;
; ALTERS REGISTERS DX AND AL.                          ;
;-------------------------------------------------------;

INIT_TIMER      PROC    NEAR
        OUT     TIM_CTL,AL      ; OUTPUT INITIAL CONTROL WORD
        MOV     DX,TIMER        ; BASE PORT ADDR FOR TIMERS
        ADD     DL,AH           ; ADD IN THE TIMER #
        MOV     AL,BL           ; LOAD LSB
        OUT     DX,AL
        PUSH    DX              ; PAUSE
        POP     DX
        MOV     AL,BH           ; LOAD MSB
        OUT     DX,AL
        RET
INIT_TIMER      ENDP

;------------------------------;
; POWER ON RESET VECTOR :      ;
;------------------------------;

        ORG     0FFF0H

;----- POWER ON RESET
        DB      0EAH            ; JUMP FAR
        DW      OFFSET RESET
        DW      0F000H

        DB      '06/01/83'      ; RELEASE MARKER

        DB      0FFH            ; FILLER

        DB      0FDH            ; SYSTEM IDENTIFIER

        ;       DB      0FFH    ; CHECKSUM
CODE    ENDS
        END
