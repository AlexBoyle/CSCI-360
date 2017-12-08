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
LINE    DSECT     Format for Table
N1      DS     CL6
        DS     CL2
N2      DS     CL6
***********************************
*Name: Main
*
* This drives the program by branching to the needed locations
*
*  Register usage:
*  15   MAIN
*  14   Exit
*  13   Save location
*  12   location of line buffer
*  1-2  
***********************************
MAIN     CSECT
         USING MAIN,15
         ST    14,EXIT      Save Exit Location
         LA    13,SAVEM     Set the save area
*
         USING LINE,12 set dsect LINE to R12
         XPRNT HEAD,45 Print the haedder
LOOP     DS    0H
         XREAD BUFF,80 Read Buffer
         BL    ELOOP End loop if nothing to read
         MVC   PA(6),=X'402020202120'
         MVC   PB(6),=X'402020202120'
         MVC   PR(6),=X'402020202120'
         LA    12,BUFF set R12 to location of buff
         PACK  A(6),N1(6) Pack A
         PACK  B(6),N2(6) Pack B
         LA    1,PA+5 Set sign location
         EDMK  PA(6),A+3 Format A for print line
         CP    A(6),=PL1'0' is negitive
         BNL   SKIP1
         BCTR  1,0 dec R1
         MVI   0(1),C'-' place negitive sign
SKIP1    DS    0H
         LA    1,PB+5  Set sign location
         EDMK  PB(6),B+3 format B
         CP    B(6),=PL1'0' is negitive
         BNL   SKIP2
         BCTR  1,0 dec R1
         MVI   0(1),C'-' place sign
SKIP2    DS    0H
         ZAP   C(6),A(6) set C to A 
         DP    C(6),B+3(3) divide C by B
         ZAP   D(7),C+3(3) Save remainder in D
         ZAP   C(6),C(3) Format C
         ZAP   R(8),C(6) Set R to C
         MP    R(8),B(6) Multiply R by B
         ZAP   E(7),B(6) Set E to B
         CP    E(7),=PL1'0' check if negitive
         BNL    SKIP
         MP    E(7),=PL1'-1' set to positive
SKIP     DS    0H
         MP    D(7),=PL1'2' multiply D by 2
         CP    D(7),=PL1'0' check if D is negitive
         BNL   SKIP4
         MP    D(7),=PL1'-1' set to positive
SKIP4    DS    0H
         CP    D(7),E(7) check if D >= E
         BL    PRNT if D >=E
         CP    A(6),=PL1'0' Is A positive
         BNH   ELSE
         AP    R(8),E(7) Add E to R
         B     PRNT
ELSE     DS    0H
         SP    R(8),E(7) Subtract E from R
PRNT     DS    0H
         LA    1,PR+5 set location of sign
         EDMK  PR(6),R+5 format R
         CP    R(8),=PL1'0'  is R negitive
         BNL   SKIP3
         BCTR  1,0 dec R1
         MVI   0(1),C'-' set sign
SKIP3    DS    0H
         XPRNT PLINE,41 Print line
         B     LOOP
ELOOP    DS    0H
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG              Literals are put here
SAVEM    DS    18F'0'
EXIT     DS    F
BUFF     DS    80C
A        DS    PL6
B        DS    PL6
C        DS    PL6
D        DS    PL7
E        DS    PL7
R        DS    PL8
PLINE    DC    CL3'0  '
PA       DS    6C
         DC    CL10'          '
PB       DS    6C
         DC    CL10'          '
PR       DS    6C
HEAD     DC    CL45'1First Number   Second Number   Rounded Value'
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HWEXDATA,DISP=SHR
//