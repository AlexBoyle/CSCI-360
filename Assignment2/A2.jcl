//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN2
*  Programmer:  Alex Boyle
*
*  Register usage:
*    1        Used by XDECI
*    2        X component
*    3        Y component
*    4        Z component
*    5        calculation
*    6        Number of lines
*    7        Total sum
*   15        Base register
************************************************************
MAIN     CSECT
         USING MAIN,15
         SR    6,6            Set register 6 to 0
         SR    7,7            Set register 7 to 0
LOOP     XREAD BUFFER,80      Start loop and read in the first 80
         BC    B'0100',ENDLOOP  check if read failed
         A    6,=F'1'        Add one to line counter
         XDECI 2,BUFFER      Store the first number in 2
         XDECI 3,0(1)        Store the second number in 3
         XDECI 4,0(1)        Store the third number in 4
         LR    5,3           Load register 3 into 5
         AR    5,4           Add register 4 to 5
         SR    5,2           Subtract register 2 from 5
         AR    7,5           Add register 5 to 7
         XDECO 2,XCOM        Format register 2 and store in XCOM
         XDECO 3,YCOM        Format register 3 and store in YCOM
         XDECO 4,ZCOM        Format register 4 and store in ZCOM
         XDECO 5,RCOM        Format register 5 and store in RCOM
         XPRNT LINE,90       Print formated string at LINE
         BC    B'1111',LOOP  Goto top of loop
ENDLOOP  XDECO 6,NLINE       Format register 6 and store in NLINE
         XDECO 7,SUM         Format register 7 and store in SUM
         XPRNT STAT,66       Print the formated string at STAT
         BR    14            End of code
         LTORG               Literals are put here
LINE     DC    C' '          Start of formated string LINE
         DC    CL3'X ='
XCOM     DS    CL12          Variable XCOM
         DC    CL8' '
         DC    CL3'Y ='
YCOM     DS    CL12          Variable YCOM
         DC    CL8' '
         DC    CL3'Z ='
ZCOM     DS    CL12          Variable ZCOM
         DC    CL8' '
         DC    CL8'Result ='
RCOM     DS    CL12          Variable RCOM
STAT     DC    C' '          Start of formated string STAT
         DC    CL17'Number of Lines ='    
NLINE    DS    CL12          Variable NLINE
         DC    CL8' '
         DC    CL16'Sum of Results ='
SUM      DS    CL12          Variable SUM
BUFFER   DS    0C            Variable BUFFER
         END   MAIN          End of program
/*
//FT05F001   DD  *
8163   2529   2805
4536   1839   5741
0591   7843   9487
4190   3057   2775
2399   0667   4129
8118   3961   6535
4765   0498   1111
9056   2345   1110
0001   0002   0003
9999   9998   9997
8001   7999   3512
/*
//FT06F001   DD SYSOUT=*
//