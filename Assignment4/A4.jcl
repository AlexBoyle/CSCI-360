//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN4
*  Programmer:  Alex Boyle
*
*  Register usage:
*    1        Used by XDECI
*   10        location in program when branched
*   13        location of params
*   14        DONT USE
*   15        Base register
************************************************************
MAIN     CSECT
         USING MAIN,15
         LA    13,TABLE     Load the address of Table
         ST    13,PARMS     Store Table address in params
         LA    13,EOT       Load address of end of table
         ST    13,PARMS+4   Store end of table in params
         LA    13,TABLELEN  Load the address of table lenght
         ST    13,PARMS+8   Store the table lenght in params
         LA    13,PARMS     address of params in R13
         BAL   10,BUILD     Build table
         BAL   10,PRINT     Print all numbers
         BAL   10,PRINTO    Print all odd numbers
         BR    14           End Program
***********************************
*
*  Register usage:
*    1        Used by XDECI
*    2        Number in base10
*    3        Table address
*    4        EOT address
*    5        Length of table address
*    6        Counter
*   10        Return address
*   13        params
*   14        DONT USE
*   15        Base register
*
***********************************
BUILD    DS    0H           Start build subroutine
         SR    6,6          clear R6 to use as a counter
         LM    3,5,0(13)    Load params into R3,R4, and R5
BLOOP    XREAD BUFFER,80    Read a line from the input file
         BL    BEND         Check if read failed
         LA    1,BUFFER     Load the address of buffer into R1
BLOOP1   XDECI 2,0(0,1)     Read number from read line
         BO    BLOOP        Check if read failes
         A     6,=F'1'      Add one to counter
         ST    2,0(0,3)     Store number in table
         LA    3,4(0,3)     Advance the table pointer
         CR    3,4          Compare the table pointer to the EOT
         BE    BEND         If at EOT end build
         B     BLOOP1       Goto top of loop
BEND     ST    6,0(0,5)     Store the number of elements
         BR    10           End subroutine
***********************************
*
*  Register usage:
*    1        Used by XDECI
*    2        Line string location
*    3        Table address
*    4        EOT address
*    5        Length of table address
*    6        Width counter 
*    7        Value from table
*   10        Return address
*   13        params
*   14        DONT USE
*   15        Base register
*
***********************************
PRINT    DS    0H           Start of subroutine
         XPRNT PHEAD,44     Print the table head
         LM    3,5,0(13)    Load params into R3,R4, and R5
         L     5,0(0,5)     Load the lenght of the table
PLOOP    L     6,=F'6'      Counter for width of table
         LA    2,PLINE+1    Set R2 to the address of the print line
         MVI   PLINE+1,C' ' Clear the print line
         MVC   PLINE+2(71),PLINE+1
         C     5,=F'0'      Check if all values have been printed
         BE    PEND         End if true
PLOOP1   C     5,=F'0'      Check if all values have been printed
         BE    PEND1        End if true
         L     7,0(0,3)     Get current value from table
         XDECO 7,TEMP       Hex to base 10
         MVC   0(12,2),TEMP Store base 10 num in print line
         LA    2,12(0,2)    Advance print line pointer
         LA    3,4(0,3)     Advance table pointer
         S     5,=F'1'      Decrement table length counter
         S     6,=F'1'      Decrement line width counter
         C     6,=F'0'      Check if we have filled a line
         BNE   PLOOP1       Goto top of loop1
         XPRNT PLINE,73     Print print line
         B     PLOOP        Goto top of loop
PEND1    XPRNT PLINE,73     Print printline
PEND     BR    10           End of subroutine
***********************************
*
*  Register usage:
*    1        Used by XDECI
*    2        Line string location
*    3        Table address
*    4        EOT address
*    5        Length of table address
*    6        Table Var
*    7        used in division
*    8        Width counter
*   10        Return address
*   13        params
*   14        DONT USE
*   15        Base register
*
***********************************
PRINTO    DS    0H          Start of subroutine
         XPRNT OHEAD,48     Print table head
         LM    3,5,0(13)    Load params into R3,R4, and R5
         L     5,0(0,5)     Load lenght of table
OLOOP    L     8,=F'5'      Table width counter
         LA    2,PLINE+1    Load pointer to print line
         MVI   PLINE+1,C' ' Clear print line
         MVC   PLINE+2(71),PLINE+1
         C     5,=F'0'      Check if we have printed the table
         BE    OEND         Goto end of subroutine if true
OLOOP1   C     5,=F'0'      Check if we have printed the table
         BE    OEND1        Goto end if true
         L     7,0(0,3)     Load the current number
         S     5,=F'1'      Decrement table length
         M     6,=F'1'      Check if odd
         D     6,=F'2'      Check if odd
         C     6,=F'0'      Check if odd
         BE    SKIP         Skip printing if odd
         L     6,0(0,3)     Load the current number
         XDECO 6,TEMP       Hex to Dec
         MVC   0(12,2),TEMP Store Dec in print line
         LA    2,12(0,2)    Advance print line pointer
         S     8,=F'1'      Decrement line counter
SKIP     LA    3,4(0,3)     Advance table pointer
         C     8,=F'0'      check if Pline is full
         BNE   OLOOP1       Goto top of loop1
         XPRNT PLINE,73     Print print line
         B     OLOOP        Goto top of loop
OEND1    XPRNT PLINE,73     Print print line
OEND     BR    10           End of subroutine
***********************************
         LTORG                Literals are put here
TABLE    DS    49F'-16'
EOT      DS    0H
TABLELEN DS    F'0'
PHEAD    DC    CL44'1                            List of Numbers'
OHEAD    DC    CL48'1                            List of Odd Numbers'
TEMP     DS    CL12' '
PARMS    DS    F'0'
         DS    F'0'
         DS    F'0'
PLINE    DC    CL1'0'
         DS    CL72' '
BUFFER   DS    80C
         DC    C'*'
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HW4DATA,DISP=SHR
//