//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN6
*  Programmer:  Alex Boyle
************************************************************
ENTRY   DSECT     Format for Table
FNAME   DS    10C
LNAME   DS    10C
ID      DS    8C
BAL     DS    PL4 32 chars
***********************************
CHANGE   DSECT    Format for transactions
CID      DS    8C
         DS    2C
CTYPE    DS    1C
         DS    2C
CAMOUNT  DS    7C
         DS    2C
CDAY     DS    2C
CMONTH   DS    2C
CYEAR    DS    4C
***********************************
*
*  Register usage:
*  15   MAIN
*  14   Exit
*  1    Params
***********************************
MAIN     CSECT
         USING MAIN,15
         ST    14,EXIT      Save Exit Location
         LA    13,SAVEM     Set the save area
         ZAP   PCOUNT(2),=PL1'0'
         LA    1,TABLE      Start Loading params into PARMS
         ST    1,PARMS
         LA    1,EOT
         ST    1,PARMS+4
         LA    1,BUFF
         ST    1,PARMS+8
         LA    1,PCOUNT
         ST    1,PARMS+12
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(BUILD)
         BALR  14,10        Branch to Build
         LA     1,PARMS
         L     10,=V(PRINT)
         BALR  14,10        Branch to print
         LA     1,PARMS
         L     10,=V(TRANS)
         BALR  14,10        Branch to Trans
         LA     1,PARMS
         L     10,=V(PRINT)
         BALR  14,10        Branch to print
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG              Literals are put here
         ORG   MAIN+((*-MAIN+31)/32)*32
TABLE    DS    40CL38
EOT      DS    F
BUFF     DS    84C
PCOUNT   DS    PL2'0'
PARMS    DS    4F'0'
SAVEM    DS    18F'0'
EXIT     DS    F
***********************************
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*   1     Buffer
*   2     TABLE
*   3     Last ENTRY
*   4     Buffer
***********************************
BUILD    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING BUILD,10  External register is R10
         USING ENTRY,2   Table will use format ENTRY
         LA    14,SAVEB
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         LM    2,4,0(1) Load params R2=table R3=last entry, R4=buff
READ     XREAD 0(,4),84 read in an account
         BL    REND
         LA    1,0(,4)
         MVC   FNAME(10),0(1)    First Name
         CLC   FNAME(8),=CL8'DONOTPUT' check if end of entries
         BE    REND   branch to end of entries
         LA    1,12(,1)
         MVC   LNAME(10),0(1)   Last Name
         LA    1,12(,1)
         MVC   ID(8),0(1)    ID number
         LA    1,10(,1)
         MVC   TEMP(7),0(1)  Save the balance in a temp var
         PACK  BAL(4),TEMP(7) Pack the balance
         CLC   7(1,1),=CL1'+' check if positive or negitive
         BE    SKIP
         MP    BAL(4),=PL1'-1'  if negitive make BAL negitive
SKIP     DS    0H
         LA    2,32(,2)
         B     READ    Back to top of loop
REND     DS    0H
         ST    2,0(,3)
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End subroutine
         LTORG              Literals are put here
         DC    C'*'
TEMP     DS    CL7' '
SAVEB    DS    18F'0'
***********************************
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*   1     location of $
*   2     TABLE
*   3     Last ENTRY
*   4     Buffer
*   5     Page Number
*   6     counter
***********************************
PRINT    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING PRINT,10     Use R10 as base register
         LM    2,5,0(1)     Load params into R3,R4, and R5
         LA    14,SAVEC
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         USING ENTRY,2      Use ENTRY format for table
         SR    6,6          Clear R6
PLOOP    DS    0H
         C     2,0(,3)      Check if we are at the end of Table
         BE    PEND         Branch to end
         C     6,=F'0'      Check if R6 = 0
         BNE   PSKIP        Skip if R6 != 0
         AP    0(2,5),=PL1'1' Add 1 to page number
         MVC   PPNUM(4),=X'40202120' Format Page number
         ED    PPNUM(4),0(5) Format page number
         XPRNT PHEAD,81     Print page headder
         XPRNT PHEADA,76    Print table headder
         L     6,=F'5'      Load 5 into R6
PSKIP    DS    0H
         MVC   PFNAME(10),FNAME Set first name
         MVC   PLNAME(10),LNAME Set last name
         MVC   PID(8),ID    Set ID
         MVC   PBAL(10),=X'4020206B2021204B2020'
         LA    1,PBAL+6
         EDMK  PBAL(10),BAL Format Balance
         BCTR  1,0          Get location for $
         MVC   0(1,1),=CL1'$' Set $
         MVC   PT(2),=CL2'  '
         AP    BAL,=PL1'0'    Get sign of balance
         BH    PPRINT
         MVC   PT(2),=CL2'CR' If negitive set CR
PPRINT   XPRNT PLINE,78   Print Entry
         AP    PNUM(2),=PL1'1'  Add one to entry number
         AP    PSUM(4),BAL Add balance to the total sum
         LA    2,32(0,2) advance table pointer
         S     6,=F'1' subtract one from R6
         B     PLOOP   To top of loop
PEND     DS    0H
         MVC   PPENDC(4),=X'40202020'
         ED    PPENDC(4),PNUM Format number of accounts
         XPRNT PPEND,33   Print number of accounts
         LA    1,PSENDS+6 Load address of $
         MVC   PSENDS(10),=X'4020206B2021204B2020' 
         EDMK  PSENDS(10),PSUM Format the Sum
         BCTR  1,0
         MVC   0(1,1),=CL1'$' Add in $
         XPRNT PSEND,35 Print the Sum
         ZAP   PNTEMP(5),PSUM(4) Psum is to small so we use PNTEMP
         DP    PNTEMP(5),PNUM(2) Divide the sum by the accounts
         LA    1,PFENDT+6        load address of $
         MVC   PFENDT(7),=X'402021204B2020'
         EDMK  PFENDT(7),PNTEMP Fromat average
         BCTR  1,0
         MVC   0(1,1),=CL1'$' Add $
         XPRNT PFEND,35 Print average
         ZAP   PNUM(2),=PL1'0' Zero out num
         ZAP   PSUM(4),=PL1'0' Zero out sum
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
PHEAD    DC    CL50'1                      Odds and Ends Customer Data'
         DC    CL27'                      Page'
PPNUM    DS    CL4' '
PHEADA   DC    CL44'-First Name           Last Name             '
         DC    CL32'ID Number                Balance'
PLINE    DC    CL1'0'
PFNAME   DS    10C' '
         DC    11C' '
PLNAME   DS    10C' '
         DC    11C' '
PID      DS    8C' '
         DC    14C' '
PBAL     DS    10C' '
         DC    1C' '
PT       DS    2C' '
PPEND    DC    CL29'-Number of customers =      '
PPENDC   DS    4C' '
PSEND    DC    CL25'0Sum of all balances =   '
PSENDS   DS    10C' '
PFEND    DC    CL28'0Average balance =          '
PFENDT   DS    7C' '
PNUM     DC    PL2'0'
PNTEMP   DC    PL5'0'
PSUM     DC    PL4'0'
SAVEC    DS    18F'0'
***********************************
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*   1     location of $
*   2     TABLE
*   3     Last ENTRY
*   4     Buffer
*   5     page number
*   6     Start of Table
***********************************
TRANS   CSECT
         STM   14,12,12(13)
         LR    12,15
         USING TRANS,10
         USING ENTRY,2
         LA    14,SAVED
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         LM    2,5,0(1) Load Params
         LR    6,2      Save the start of table in R6
         AP    0(2,5),=PL1'1' Add one to the page num
         MVC   TPAGE(4),=X'40202120'
         ED    TPAGE(4),0(5) Format Page number
         XPRNT THEAD,80 Print pae header
         XPRNT THEADA,77  print table header
         ZAP   TSC,=PL1'0' Zero out suc
         ZAP   TEC,=PL1'0' Zero out Err
TLOOP    XREAD 0(,4),80    Read in transaction
         BL    TEND        End if nothing
         USING CHANGE,4    R4 formats transaction
         LR    2,6         reset R2 pointer
         PACK  TNUM(4),CAMOUNT(7) Pack the transaction amount
         MVC   EAMOUNT(10),=X'4020206B2021204B2020'
         LA    1,EAMOUNT+6
         EDMK  EAMOUNT(10),TNUM format transaction
         BCTR  1,0
         MVC   0(1,1),=CL1'$' Add $
         MVC   TAMOUNT(10),EAMOUNT Copy Transaction amount
         CLC   CTYPE(1),=CL1'B' Balance
         BE    EBAL
         CLC   CTYPE(1),=CL1'D' Deposit
         BE    EDEP
         CLC   CTYPE(1),=CL1'W' Withdrawl
         BE    EWIT
*
EWIT     MVC   ETYPE(17),=CL17'Withdrawal       '
         MVC   TTYPE(17),ETYPE  Add type to output lines
         B     TSKIP
*
EDEP     MVC   ETYPE(17),=CL17'Deposit          '
         MVC   TTYPE(17),ETYPE  Add type to output lines
         B     TSKIP
*
EBAL     MVC   ETYPE(17),=CL17'Balance Query    '
         MVC   TTYPE(17),ETYPE  Add type to output lines
*
TSKIP    DS    0H
         MVC   EID(8),CID         Start mass var Adding
         MVC   TID(8),CID
         MVC   EDATE(4),CYEAR
         MVC   EDATE+4(1),=C'/'
         MVC   EDATE+5(2),CMONTH
         MVC   EDATE+7(1),=C'/'
         MVC   EDATE+8(2),CDAY
         MVC   TDATE(2),CMONTH
         MVC   TDATE+2(1),=C'/'
         MVC   TDATE+3(2),CDAY
         MVC   TDATE+5(1),=C'/'
         MVC   TDATE+6(4),CYEAR   End mass var adding
FLOOP    DS    0H        Find the account being transacted on
         C     2,0(,3)   Check if we are at the end of table
         BE    TERR      Branch to error if true
         CLC   ID(8),CID  Compare IDs
         BE    TYPE       If match goto Type
         LA    2,32(,2)   Advance table pointer
         B     FLOOP      Top of loop
TYPE     DS    0H
         MVC   TT(2),=CL2'  '
         CLC   CTYPE(1),=CL1'B' Balance
         BE    TBBAL
         CLC   CTYPE(1),=CL1'D' Deposit
         BE    TBDEP
         CLC   CTYPE(1),=CL1'W' Withdrawl
         BE    TBWIT
         B     TEND
TBBAL    DS    0H
         AP    BAL,=PL1'0'
         BH    TBEND
         MVC   TT(2),=CL2'CR'  check if credit
         MVC   TAMOUNT(10),=CL10'             ' Clear Transaction
         B     TBEND
TBDEP    DS    0H
         SP    BAL,TNUM Subtract Transaction
         BH    TBEND
         MVC   TT(2),=CL2'CR'  check if credit
         B     TBEND
TBWIT    DS    0H
         AP    BAL,TNUM Add transaction
         BH    TBEND
         MVC   TT(2),=CL2'CR'  check if credit
TBEND    DS    0H
         MVC   TBAL(10),=X'4020206B2021204B2020'
         LA    1,TBAL+6
         EDMK  TBAL(10),BAL Format new balance
         BCTR  1,0
         MVC   0(1,1),=CL1'$' Add $
         XPRNT TPRINT,80 Print transaction
         AP    TSC,=PL1'1' One more Suc
         B     TLOOP
TERR     DS    0H
         XPRNT ERROR,82 Print Error
         AP    TEC,=PL1'1' One more Err
         MVI   ETYPE,C' ' Clear type
         MVI   EAMOUNT,C' ' Clear amount
         B     TLOOP Branch top of loop
TEND     DS    0H
         MVC   TSCN(4),=X'40202020'
         MVC   TECN(4),=X'40202020'
         ED    TSCN(4),TSC format Suc
         ED    TECN(4),TEC Format Err
         XPRNT TSCP,30 Print Suc
         XPRNT TECP,30 Print Err
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
TEDIT    DS    PL4'0'
TNUM     DS    PL4'0'
*
ERROR    DC    CL12'0Error!  ID '
EID      DS    8C' '
         DC    CL21' was not found for a '
ETYPE    DS    CL17'                 '
EAMOUNT  DS    CL10'          '
         DC    CL4' on '
EDATE    DS    10C' '
*
TPRINT   DC    CL5'0    '
TID      DS    CL8
         DC    5C' '
TTYPE    DS    17C' '
TAMOUNT  DS    10C' '
         DC    5C' '
TDATE    DS    10C' '
         DC    7C' '
TBAL     DS    10C' '
         DC    1C' '
TT       DS    2C' '
THEAD    DC    CL43'1                              Transaction '
         DC    CL33'Report                       Page'
TPAGE    DS    4C' '
THEADA   DC    CL38'-   Customer ID     Transaction       '
         DC    CL39'Amount          Date            Balance'
TEC      DS    PL2'0'
TSC      DS    PL2'0'
TSCP     DC    CL26'1Successful transactions: '
TSCN     DS    4C' '
TECP     DC    CL26'-Failed transactions:     '
TECN     DS    4C' '
*
SAVED    DS    18F'0'
***********************************
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HW6DATA,DISP=SHR
//