//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN3
*  Programmer:  Alex Boyle
*
*  Register usage:
*    1        Used by XDECI
*    4        ElementOne
*    5        ElementOne
*    6        ElementTwo
*    7        Total types
*    8        Type
*    9        Total calculations
*   10        total adds
*   11        Total subtracts
*   12        Total Multiplys
*   13        Total Divides
*   15        Base register
************************************************************
MAIN     CSECT
         USING MAIN,15
         TITLE 'Arithmetic'
         EJECT
         SPACE
         SR    9,9            Set register 9 to 0
         SR    10,10          Set register 10 to 0
         SR    11,11          Set register 11 to 0
         SR    12,12          Set register 12 to 0
         SR    13,13          Set register 13 to 0
         XPRNT TOP,68         Print table name
         XPRNT HEAD,56        Print column headdings
         XPRNT DASH,121       Print dashed line
LOOP     XREAD BUFFER,80      Start loop and read in the first 80
         BC    B'0100',ENDLOOP  check if read failed
         A    6,=F'1'         Add one to counter
         XDECI 8,BUFFER       Store the first number in 8
         XDECI 5,0(1)         Store the second number in 4
         XDECI 6,0(1)         Store the third number in 6
         A     9,=F'1'
         C     8,=F'1'        Is the operator 1
         BC    B'1000',ADD    Goto add if equ
         C     8,=F'2'        Is the operator 2
         BC    B'1000',SUB    Goto sub if equ
         C     8,=F'3'        Is the operator 3
         BC    B'1000',MUL    Goto mul if equ
         C     8,=F'4'        Is the operator 4
         BC    B'1000',DIV    Goto div if equ
         BC    B'1111',ENDLOOP
ADD      XDECO 5,ADDA         Store num1 in column 1
         XDECO 6,ADDB         Store num2 in column 2
         AR    5,6            Add R5 and R6
         XDECO 5,ADDC         Store the ans in column 3
         XPRNT ADDS,71        Print the stored result
         A     10,=F'1'       Add one to the add counter
         BC    B'1111',LOOP   Goto top of loop
SUB      XDECO 5,SUBA         Store num1 in column 1
         XDECO 6,SUBB         Store num2 in column 2
         SR    5,6            Subtract R5 and R6
         XDECO 5,SUBC         Store the result in column 3
         XPRNT SUBS,71        Print the stored result
         A     11,=F'1'       Add one to adding counter
         BC    B'1111',LOOP   Goto top of loop
MUL      XDECO 5,MULA         store num1 in column 1
         XDECO 6,MULB         store num2 in column 2
         MR    4,6            Multiply R5 and R6
         D     4,=F'1'        Divide R4 and R5 to get result
         XDECO 5,MULC         Store Result in column 3
         XPRNT MULS,71        Printthe stored result
         A     12,=F'1'       Add one to mul counter
         BC    B'1111',LOOP   Goto top of loop
DIV      XDECO 5,DIVA         Store num1 in column 1
         XDECO 6,DIVB         Store num2 in column 2
         M     4,=F'1'        Make R4 and R5 a 64 bit number
         DR    4,6            Divide R4,R5 by R6
         XDECO 5,DIVC         Store result in column 3
         XDECO 4,DIVD         Store remainder in column 4
         XPRNT DIVS,101       Print the stored result
         A     13,=F'1'       Add one to sub counter
         BC    B'1111',LOOP   Goto top of loop
ENDLOOP  XDECO 9,TOT          Store total calculations
         XPRNT SUM,32         Print calculations
         XDECO 10,TOTA        Store total Adds
         XDECO 11,TOTB        Store total Subs
         XDECO 12,TOTC        Store total Muls
         XDECO 13,TOTD        Store total Divs
         XPRNT TOTS,113       Print totals
         BR    14             End of code
         LTORG                Literals are put here
ADDS     DC    CL16'0Addition:      '
ADDA     DS    CL12
ADDB     DS    CL12
         DC    CL8' '
         DC    CL11'Sum:       '
ADDC     DS    CL12
SUBS     DC    CL16'0Subtraction:   '
SUBA     DS    CL12
SUBB     DS    CL12
         DC    CL8' '
         DC    CL11'Difference:'
SUBC     DS    CL12
MULS     DC    CL16'0Multiplication:'
MULA     DS    CL12
MULB     DS    CL12
         DC    CL8' '
         DC    CL11'Product    '
MULC     DS    CL12
DIVS     DC    CL16'0Division:      '
DIVA     DS    CL12
DIVB     DS    CL12
         DC    CL8' '
         DC    CL11'Quotient:  '
DIVC     DS    CL12
         DC    CL8' '
         DC    CL10'Remainder:'
DIVD     DS    CL12
SUM      DC    CL20'-Total Calculations:'
TOT      DS    CL12
TOTS     DC    CL6' '
         DC    CL14'Addition:     '
TOTA     DS    CL12
         DC    CL3' '
         DC    CL12'Subtraction:'
TOTB     DS    CL12
         DC    CL3' '
         DC    CL15'Multiplication:'
TOTC     DS    CL12
         DC    CL3' '
         DC    CL9'Division:'
TOTD     DS    CL12
TOP      DC    CL48'1'
         DC    CL20'Result of Arithmetic'
HEAD     DC    CL10'0Operation'
         DC    CL13' '
         DC    CL5'Num 1'
         DC    CL7' '
         DC    CL5'Num 3'
         DC    CL8' '
         DC    CL8'Result'
DASH     DC    CL1' '
         DC    CL20'--------------------'
         DC    CL20'--------------------'
         DC    CL20'--------------------'
         DC    CL20'--------------------'
         DC    CL20'--------------------'
         DC    CL20'--------------------'
BUFFER   DS    0C
         END   MAIN
/*
//FT05F001 DD DSN=KC02314.AUTUMN17.CSCI360.HW3DATA,DISP=SHR
//