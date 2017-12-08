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
*  12   Used for line location
*  11   Used for arithmatic
*  10   (A) Used for comparison
*  8-9  (R) Used for arithmatic
*  6-7  (C) Used for arithmatic
*  4-5  (A then D) Used for arithmatic
*  3    (B) Used for arithmatic
*  2    Used by EDMK
*  1    Used by EDMK
***********************************
MAIN     CSECT
         USING MAIN,15
         ST    14,EXIT      Save Exit Location
         LA    13,SAVEM     Set the save area
*
         USING LINE,12
         XPRNT HEAD,45 print headder
LOOP     DS    0H
         XREAD BUFF,80 Read in Line
         BL    ELOOP end if there is no line
         MVC   PA(6),=X'402020202120' format for A
         MVC   PB(6),=X'402020202120' format for B
         MVC   PR(6),=X'402020202120' format for Result
         LA    12,BUFF load location of in line
         PACK  T1(8),N1(6) Pack A
         PACK  T2(8),N2(6) Pack B
         CVB   5,T1 A = R5 convert A to binary
         CVB   3,T2 B = R3 convert B to binary
         LA    1,PA+5 Inital sign location
         EDMK  PA(6),T1+5 format A for display
         C     5,=F'0' if A is negitive
         BNL   SKIP1 Skip if not
         BCTR  1,0 decriemnt R1
         MVI   0(1),C'-' place sign
SKIP1    DS    0H
         LA    1,PB+5 Inital sign location
         EDMK  PB(6),T2+5 format B for display
         C     3,=F'0' is B negitive
         BNL   SKIP2 Skip of positive
         BCTR  1,0 decriemnt R1
         MVI   0(1),C'-' place sign
SKIP2    DS    0H
         M     4,=F'1' Prepare R5 for a divide
         DR    4,3 divide A by B
         LR    7,5 C is set to R7
         LR    9,7 Load result into R9
         MR    8,3 Multiply R9 by B
         C     3,=F'0' check if B is negitive
         BH    SKIP  skip if positive
         LR    11,3 load R3 into R11
         M     10,=F'-1' flip sign
         LR    3,11 move R11 into R3
SKIP     DS    0H 
         LR    5,4 Load R4 into R5
         M     4,=F'2' multiply R5 by 2
         SR    6,6 clear R6
         C     5,=F'0' check if R5 is positive
         BNL   SKIP4 Skip if positive
         M     4,=F'-1' flip sign
SKIP4    DS    0H
         CR    5,3 compare D and E
         BL    PRNT if D >=E
         CVB   10,T1 Load A in
         C     10,=F'0' Check if A is positive
         BNH   ELSE
         AR    9,3 Add E
         B     PRNT
ELSE     DS    0H
         SR    9,3 Subtract E
PRNT     DS    0H
         CVD   9,T1 Convert Result to packed
         LA    1,PR+5 Set pointer location 
         EDMK  PR(6),T1+5 format the result to print line
         C     9,=F'0' check if result is negitive
         BNL   SKIP3  skip if positive
         BCTR  1,0 decriemnt R1
         MVI   0(1),C'-'
SKIP3    DS    0H
         XPRNT PLINE,41 Print line
         B     LOOP Top of loop
ELOOP    DS    0H End of loop
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG              Literals are put here
SAVEM    DS    18F'0'
EXIT     DS    F
BUFF     DS    80C
T1       DS    D
T2       DS    D
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