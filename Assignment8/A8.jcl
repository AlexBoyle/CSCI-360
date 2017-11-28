//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN7
*  Programmer:  Alex Boyle
************************************************************
ENTRY   DSECT     Format for Table
ID      DS     CL4
PAS     DS     CL12
REN     DS     CL2
MAJ     DS     CL4
GPA     DS     CL2
TCH     DS     CL2
HCE     DS     CL1   27 bytes
***********************************
*Name: Main
*
* This drives the program by branching to the needed locations
*
*  Register usage:
*  15   MAIN
*  14   Exit
*  13   Save location
*  10   Location to branch to
*  1    Params
***********************************
MAIN     CSECT
         USING MAIN,15
         ST    14,EXIT      Save Exit Location
         LA    13,SAVEM     Set the save area
         LA    1,TABLE      Start Loading params into PARMS
         ST    1,PARMS
         LA    1,EOT
         ST    1,PARMS+4
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(BUILD)
         BALR  14,10 Branch to Build
         XDUMP TABLE,162
         LA    1,HEADA
         ST    1,PARMS+8
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(PRINT)
         BALR  14,10 Branch to Print
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(SORT)
         BALR  14,10 Branch to sort
         LA    1,HEADB
         ST    1,PARMS+8
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(PRINT)
         BALR  14,10 Branch to Print
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG              Literals are put here
         ORG   MAIN+((*-MAIN+31)/32)*32
TABLE    DC    110CL27'                           '
EOT      DS    F
HEADA    DC    CL46'1                          Student Information'
         DC    CL32'                        Page   1'
HEADB    DC    CL48'1                          Student Information'
         DC    CL32' by GPA                 Page   4'
PARMS    DC    4F'0'
SAVEM    DS    18F'0'
EXIT     DS    F
***********************************
*NAME: BUILD
*
*FUNCTION: This subroutine Takes in two params(table location,EOT)
*          and fills the givin table from the input.
*
*INPUT: Data to pe put into a table
*
*OUTPUT: A fulled table and a set EOT pointer
*
*ENTRY CONDS: 0(1) Table pointer
*             4(1) location or EOT pointer
*
*EXIT CONDS: 0(1) Table that was filled
*            4(1) location or EOT pointer
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*    8    Location of EOT
*    7    Start of table
*    4    Length of item in the buff
*    2,3  buffer for binary formating
*    1    Location of params
***********************************
BUILD    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING BUILD,10  External register is R10
         LA    14,SAVEB
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         LM    7,8,0(1) Load params R2=table R3=last entry, R4=buff
         USING ENTRY,7
READ     XREAD BUFF,80 read in lines
         BL    REND
         LA    1,BUFF
*ID
         PACK  TEMP(8),1(8,1) Pack ID
         CVB   2,TEMP Convert id to binary
         STCM  2,B'1111',ID Store
*Password
         MVC   PAS(12),10(1)
         XC    PAS(4),ID  Hash password
         XC    PAS+4(4),ID Hash password
         XC    PAS+8(4),ID Hash password
*Password Reset
         PACK  TEMP(8),27(4,1) Pack year
         SP    TEMP(8),NUM(3) subtract 1980
         CVB   2,TEMP convert to binary
         SLL   2,9 move year over 9
         PACK  TEMP(8),23(2,1) pack day
         CVB   3,TEMP convert to binary
         SLL   3,4 move over 4
         XR    2,3 add to R2
         PACK  TEMP(8),25(2,1) Pack month
         CVB   3,TEMP convert to binary 
         XR    2,3 add to R2
         STCM  2,B'0011',REN Store in REN
*Major
         MVC   MAJ(4),32(1) store Major
*GPA
         PACK  GPA(2),37(3,1) Store GPA as packed
*Hours Currently Enrolled
         PACK  TEMP(8),45(2,1) Pack HCE
         CVB   2,TEMP Convert to binary
         STCM  2,B'0001',HCE Store in HCE
*Total Credit Hours
         PACK  TEMP(8),41(3,1) Pack TCH
         CVB   2,TEMP convert
         STCM  2,B'0011',TCH Store
*
         LA    7,27(,7) Advance pointer
         B     READ    Back to top of loop
REND     DS    0H
         ST    7,0(0,8) Store EOT
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End subroutine
         LTORG              Literals are put here
*
BUFF     DC    80C' '
         DC    C'*'
TEMP     DS    D
NUM      DC    PL3'1980'
SAVEB    DS    18F'0'
***********************************
*NAME: PRINT
*
*FUNCTION: This subroutine prints a table givin to it
*
*OUTPUT: A formated table printed in pages
*
*ENTRY CONDS: 0(1) Table pointer
*             4(1) location or EOT pointer
*             8(1) Location of page headder
*
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*   9     Location of page headder
*   8     Location of EOT
*   7     Table pointer
*   6     counter
*   2   Registers for binary  changing
***********************************
PRINT    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING PRINT,10     Use R10 as base register
         LM    7,9,0(1)     Load params into R3,R4, and R5
         LA    14,SAVEC
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         USING ENTRY,7
         L     6,=F'0' Counter ofr elements per page
PLOOP    C     7,0(0,8)
         BE    PEND
         C     6,=F'0' Check element counter
         BE    PHEADDER Print headder if true
CONT     DS    0H
*
         MVC   DTEMP(8),ID move id to a fullword bounday
         L     2,DTEMP Load ID
         CVD   2,DTEMP convert to packed
         MVC   PID(10),=X'40212020202020202020' format ID
         ED    PID(10),DTEMP+3 Format
         MVI   PLINE+1,C' '
         MVI   PLINE+2,C'Q'
*
         MVC   PTEMP(12),PAS Set passowrd
         XC    PTEMP(4),ID unhash
         XC    PTEMP+4(4),ID unhash
         XC    PTEMP+8(4),ID unhash
         MVC   PPAS(12),PTEMP store pass
*
         MVC   FTEMP(4),=X'00000000'
         MVC   FTEMP+2(2),REN Set REN
         L     2,FTEMP load Ren
         SRL   2,9  Clear all but year
         CVD   2,DTEMP
         ZAP   DTEMP(3),DTEMP(8) fomat packed
         AP    DTEMP(3),=PL3'1980'
         MVC   PDAT+6(6),=X'402120202020' Format
         ED    PDAT+6(6),DTEMP
         L     2,FTEMP
         SLL   2,27 Clear all but day
         SRL   2,27
         CVD   2,DTEMP
         ZAP   DTEMP(2),DTEMP(8) fomat packed
         MVC   PDAT+3(5),=X'4021202061' Format
         ED    PDAT+3(4),DTEMP
         L     2,FTEMP
         SLL   2,23 Clear all but month
         SRL   2,28
         CVD   2,DTEMP
         ZAP   DTEMP(2),DTEMP(8) fomat packed
         MVC   PDAT(5),=X'4021202061' Format
         ED    PDAT(4),DTEMP
*
         MVC   PMAJ(4),MAJ set major
*
         MVC   PGPA(5),=X'F0214B202040' format
         ED    PGPA(5),GPA set GPA
         MVI   PGPA,C' '
*
         MVC   FTEMP(4),=X'00000000'
         MVC   FTEMP+2(2),TCH set TCH
         L     2,FTEMP load
         CVD   2,DTEMP convert to packed
         ZAP   DTEMP(2),DTEMP(8) format packed
         MVC   PTCH(4),=X'40202120' format
         ED    PTCH(4),DTEMP format
*
         MVC   FTEMP(4),=X'00000000' 
         MVC   FTEMP+3(1),HCE set HCE
         L     2,FTEMP load
         CVD   2,DTEMP convert to packed
         ZAP   DTEMP(2),DTEMP(8) format packed
         MVC   PHCE(4),=X'40202120' fomat
         ED    PHCE(4),DTEMP fill format
         XPRNT PLINE,75 print line
         LA    7,27(,7) advance pointer
         S     6,=F'1'
         B     PLOOP
*
PHEADDER L     6,=F'40' Set counter to 50
         MVC   65(4,9),=X'40202020' fromat pge number
         ED    65(4,9),PCOUNT set page number
         XPRNT 0(,9),69 print page headder
         XPRNT HEAD1,69 Print table headder
         XPRNT HEAD2,69 Print table headder
         AP    PCOUNT,=PL1'1' add one to page count
         B     CONT Continue printing
*
PEND     L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
PCOUNT   DC    PL2'1'
PLINE    DC    1C' '
PID      DC    10C' '
         DC    2C' '
PPAS     DC    12C' '
         DC    4C' '
PDAT     DC    12C' '
         DC    5C' '
PMAJ     DC    4C' '
         DC    4C' '
PGPA     DC    5C' '
         DC    4C' '
PTCH     DC    4C' '
         DC    4C' '
PHCE     DC    4C' '  75L
PTEMP    DC    12C' '
FTEMP    DS    F
DTEMP    DS    D
HEAD1    DC    CL46'-  Student                                    '
         DC    CL32'                  Total  Current'
HEAD2    DC    CL46'    ID        Password         Renewal Date   '
         DC    CL32'Major     GPA     Hours    Hours'
SAVEC    DS    18F'0'
***********************************
*NAME: SORT
*
*FUNCTION: This subroutine sorts a table alphabeticly based on name
*
*
*OUTPUT: a sorted table
*
*ENTRY CONDS: 0(1) Table pointer
*             4(1) location or EOT pointer
*
*EXIT CONDS: 0(1) An alphabeticly sorted table
*            4(1) location or EOT pointer
*
*  Register usage:
*   15    DONT USE
*   14    Exit
*   13    Save Area
*    8    Location of EOT
*    7    Location of table
*    4    lower table element
*    2    sort start location
***********************************
SORT   CSECT
         STM   14,12,12(13)
         LR    12,15
         USING SORT,10
         LA    14,SAVED
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
         LM    7,8,0(1)     Load params into R3,R4, and R5
*
         L     2,0(,7)
         L     8,0(,8)
         S     8,=F'27'
         USING ENTRY,2
FOR      DS    0H For the number of elements in the table
         S     8,=F'27'
         LR    2,7
         S     2,=F'27'
         CR    2,8
         BE    SEND
         BH    SEND
WHILE    DS    0H While the lower element is greater than the upper
         A     2,=F'27'
         CLC   22(2,2),49(2) Comparison
         BL    SWAP Branch to swap on Low
BSWAP    DS    0H
         CR    2,8
         BH    FOR
         BL   WHILE
         B     FOR branch to top of for
*
SWAP     DS    0H Swap the two elements
         MVC   STEMP(27),0(2) Store R3 in temp
         MVC   0(27,2),27(2)  Store R4 in R3
         MVC   27(27,2),STEMP  Store temp in R4
         B     BSWAP
*
SEND     L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
SAVED    DS    18F'0'
STEMP    DS    27C
***********************************
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HW8DATA,DISP=SHR
//