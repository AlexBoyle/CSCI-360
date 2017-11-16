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
DATE    DS    7C
NAME    DS    13C
SYMB    DS    3C
NUMB    DS    PL2 Length of 25
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
         BALR  14,10        Branch to Build
         LA    1,HEAD
         ST    1,PARMS+8
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(PRINT) 
         BALR  14,10        Branch to Print
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(SORT)
         BALR  14,10        Branch to Sort
         LA    1,HEADA
         ST    1,PARMS+8
         LA    1,PARMS      End Loading Params into PARMS
         L     10,=V(PRINT) 
         BALR  14,10        Branch to Print
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG              Literals are put here
TABLE    DC    3000C' '
EOT      DS    F
PARMS    DC    4F'0'
HEAD     DC    CL50'1                   Chronological List of Elements'
         DC    CL19'           Page    '
HEADA    DC    CL50'1                        Elements Sorted by Name  '
         DC    CL19'           Page    '
SAVEM    DS    18F'0'
EXIT     DS    F
***********************************
*NAME: BUILD
*
*FUNCTION: This subroutine Takes in two params(table location,EOT)
*          and fills the givin table from the input.
*
*INPUT: Element data in the form of "DATE NAME SYMBOL ATOMIC_NUMBER"
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
*    3    Location of end of item in buff
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
SCAN     TRT   0(80,1),SCANTAB Search for the location of the next
         BZ    READ If the search fails, goto the top of the loop
         LR    3,1 Set location of element
         TRT   0(80,1),SPACES Search for the next space
         LR    4,1 Set end location of element to R4
         SR    4,3 Get length of element
         BCTR  4,0 Subtract one from length
         EX    4,EDATE Set date
         TR    DATE(7),LOWTAB Set to lower
         TRT   0(80,1),SCANTAB Search for the location of the next
         BZ    READ If the search fails, goto the top of the loop
         LR    3,1 Set location of element
         TRT   0(80,1),SPACES Search for the next space
         LR    4,1 Set end location of element to R4
         SR    4,3 Get length of element
         BCTR  4,0 Subtract one from length
         EX    4,ENAME Set name
         TR    NAME(13),LOWTAB Set to lower
         TR    NAME(1),HIGHTAB Set to upper
         TRT   0(80,1),SCANTAB Search for the location of the next
         BZ    READ If the search fails, goto the top of the loop
         LR    3,1 Set location of element
         TRT   0(80,1),SPACES Search for the next space
         LR    4,1 Set end location of element to R4
         SR    4,3 Get length of element
         BCTR  4,0 Subtract one from length
         EX    4,ESYMB Set symbol
         TR    SYMB(3),LOWTAB Set to lower
         TR    SYMB(1),HIGHTAB Set to upper
         TRT   0(80,1),SCANTAB Search for the location of the next
         BZ    READ If the search fails, goto the top of the loop
         LR    3,1 Set location of element
         TRT   0(80,1),SPACES Search for the next space
         LR    4,1 Set end location of element to R4
         SR    4,3 Get length of element
         BCTR  4,0 Subtract one from length
         EX    4,ENUMB Set number
         LA    7,25(0,7) advance table pointer
         B     READ    Back to top of loop
REND     DS    0H
         ST    7,0(0,8) Store EOT
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End subroutine
         LTORG              Literals are put here
*
EDATE    MVC   DATE(0),0(3)
ENAME    MVC   NAME(0),0(3)
ESYMB    MVC   SYMB(0),0(3)
ENUMB    PACK  NUMB(2),0(0,3)
*
BUFF     DC    80C' '
         DC    C'*'
SCANTAB  DC    256X'00'
         ORG   SCANTAB+C'A'
         DC    9X'01'
         ORG
         ORG   SCANTAB+C'J'
         DC    9X'01'
         ORG
         ORG   SCANTAB+C'S'
         DC    8X'01'
         ORG
         ORG   SCANTAB+C'a'
         DC    9X'01'
         ORG
         ORG   SCANTAB+C'j'
         DC    9X'01'
         ORG
         ORG   SCANTAB+C's'
         DC    9X'01'
         ORG
         ORG   SCANTAB+C'0'
         DC    10X'01'
         ORG
SPACES   DC    256X'00'
         ORG   SPACES+X'40'
         DC    X'01'
         ORG
LOWTAB   DC    256C' '
         ORG   LOWTAB+C'a'
         DC    CL9'abcdefghi'
         ORG
         ORG   LOWTAB+C'j'
         DC    CL9'jklmnopqr'
         ORG
         ORG   LOWTAB+C's'
         DC    CL8'stuvwxyz'
         ORG
         ORG   LOWTAB+C'A'
         DC    CL9'abcdefghi'
         ORG
         ORG   LOWTAB+C'J'
         DC    CL9'jklmnopqr'
         ORG
         ORG   LOWTAB+C'S'
         DC    CL8'stuvwxyz'
         ORG
         ORG   LOWTAB+C'0'
         DC    CL10'0123456789'
         ORG
HIGHTAB  DC    256C' '
         ORG   HIGHTAB+C'a'
         DC    CL9'ABCDEFGHI'
         ORG
         ORG   HIGHTAB+C'j'
         DC    CL9'JKLMNOPQR'
         ORG
         ORG   HIGHTAB+C's'
         DC    CL9'STUVWXYZ'
         ORG
         ORG   HIGHTAB+C'A'
         DC    CL9'ABCDEFGHI'
         ORG
         ORG   HIGHTAB+C'J'
         DC    CL9'JKLMNOPQR'
         ORG
         ORG   HIGHTAB+C'S'
         DC    CL9'STUVWXYZ'
         ORG
         ORG   HIGHTAB+C'0'
         DC    CL10'0123456789'
         ORG
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
         L     6,=F'0'
PLOOP    C     7,0(0,8)
         BE    PEND
         C     6,=F'0' Check element counter
         BE    PHEADDER Print headder if true
CONT     MVC   PNAME(13),NAME Set Name
         MVC   PSYMB(2),SYMB Set Symbol
         MVC   PDATE(7),DATE Set date
         MVC   PNUMB(4),=X'40202020' Format for atomic number
         ED    PNUMB(4),NUMB Set atomic number
         XPRNT PLINE,65 Print element
         LA    7,25(0,7)  Advance pointer
         S     6,=F'1' Subtract one from element counter
         B     PLOOP Branch to top of loop
PHEADDER L     6,=F'50' Set counter to 50
         MVC   65(4,9),=X'40202020' fromat pge number
         ED    65(4,9),PCOUNT set page number
         XPRNT 0(,9),69 print page headder
         XPRNT PHEAD,69 Print table headder
         AP    PCOUNT,=PL1'1' add one to page count
         B     CONT Continue printing
*
PEND     L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
PHEAD    DC    CL37'-Name of Element   Chemical Symbol   '
         DC    CL32'Atomic Number    Date Discovered'
PCOUNT   DC    PL2'1'
PLINE    DC    C' '
PNAME    DC    13C' '
         DC    11C' '
PSYMB    DC    2C' '
         DC    14C' '
PNUMB    DC    4C' '
         DC    13C' '
PDATE    DC    7C' '
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
*    3    upper table element
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
         LR    2,7
         L     8,0(,8)
         A     8,=F'-50'
FOR      DS    0H For the number of elements in the table
         CR    2,8
         BE    SEND
         BH    SEND
         LA    3,50(0,2)
         LA    4,75(0,2)
WHILE    DS    0H While the lower element is greater than the upper
         A     3,=F'-25' decriment pointer
         A     4,=F'-25' decriment pointer
         CLC   7(13,3),7(4) Comparison
         BH    SWAP Branch to swap on high
         LA    2,25(0,2) advance pointer
         B     FOR branch to top of for
SWAP     DS    0H Swap the two elements
         MVC   TEMP(25),0(3) Store R3 in temp
         MVC   0(25,3),0(4)  Store R4 in R3
         MVC   0(25,4),TEMP  Store temp in R4
         CR    3,7 check if at the begining of table
         BE    FOR if true branch to for
         B     WHILE top of while
*
SEND     L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
TEMP     DS    25C
SAVED    DS    18F'0'
***********************************
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HW7DATA,DISP=SHR
//