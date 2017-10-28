//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1    EXEC  PGM=ASSIST
//STEPLIB    DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  *
************************************************************
*
*  Program:     ASSIGN5
*  Programmer:  Alex Boyle
*
*  Register usage:
*    1        Param list/XDECO
*    2        Buffer
*   10        location in program when branched
*   13        main save
*   14        DONT USE
*   15        Base register
************************************************************
MAIN     CSECT
         USING MAIN,15
         ST    14,EXIT      Save Exit Location
         LA    13,SAVEM     Set the save area
         LA    1,TABLE      Load the address of Table
         ST    1,PARMS      Store Table address in params
         LA    1,EOT        Load address of end of table
         ST    1,PARMS+4    Store end of table in params
         LA    1,TABLELEN   Load the address of table lenght
         ST    1,PARMS+8    Store the table lenght in params
         LA    1,RESULT     Load address of results
         ST    1,PARMS+16   Store in params
         LA    1,PARMS      Address of params in R13
         L     10,=V(BUILD) Load external sub
         BALR  14,10        Branch to sub
         LA    1,PARMS      Set params to R1
         L     10,=V(PRINT) Load external sub
         BALR  14,10        Branch to sub
         L      10,=V(SEARCH) Load external sub
*                           Eat extra numbers
EAT      XREAD BUFF,80      Read in line
         BL    EATE         Check if line exists
         XDECI 2,BUFF       Read number
         BO    EAT          Check if number exists
         C     2,=F'-77777777' check for seporator
         BE    EATE         If it is end eat
         B     EAT          Repeat eat
EATE     DS    0H           End of Eat
*
         XPRNT HMLINE,31    Print search header
SEA      XREAD BUFF,80      Read in first serch line
         BL    SEAE         End if there is no line
         XDECI 2,BUFF       Read number
         BO    SEA          Skip if no  number
         LA    1,PARMS      Load params
         ST    2,PARMS+12   Set search param
         BALR  14,10        Branch to external
         L     1,RESULT     Load the result
         L     2,PARMS+12   Get search number
         C     1,=F'0'      Check out put from external
         BE    SEAI         If 0 then the search failed
         XDECO 2,MLINECF    Set sucsess
         XPRNT MLINEC,31    Print sucsess
         B     SEA          Top of search loop
SEAI     XDECO 2,MLINEIF    Set fail
         XPRNT MLINEI,35    Print Fail
         B     SEA          Top of search
SEAE     DS    0H           End of search
*
         L     14,EXIT      Load exit location
         BR    14           End program
         LTORG                Literals are put here
TABLE    DS    52F'-16'
EOT      DS    0H
TABLELEN DS    F'0'
PARMS    DS    5F'0'
RESULT   DS    F'0'
SAVEM    DS    18F'0'
HMLINE   DC    CL31'-Results of searching the table'
MLINEI   DC    CL9'-TARGET ='
MLINEIF  DS    CL12' '
         DC    CL14' was not found'
MLINEC   DC    CL9'-TARGET ='
MLINECF  DS    CL12' '
         DC    CL10' was found'
BUFF     DS    80C' '
EXIT     DS    F
***********************************
*
*  Register usage:
*    1        Used by XDECI/params
*    2        Number in base10
*    3        Table address
*    4        EOT address
*    5        Length of table address
*    6        Counter
*   10        Base
*   13        Save Location
*   14        return address
*   15        Base register
*
***********************************
BUILD    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING BUILD,10
         LM    3,5,0(1)     Load params into R3,R4, and R5
         LA    14,SAVEB
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         SR    6,6          Clear R6 to use as a counter
BLOOP    XREAD BUFFER,80    Read a line from the input file
         BL    BEND         Check if read failed
         LA    1,BUFFER     Load the address of buffer into R1
BLOOP1   XDECI 2,0(,1)     Read number from read line
         BO    BLOOP        Check if read failes
         A     6,=F'1'      Add one to counter
         ST    2,0(,3)     Store number in table
         LA    3,4(,3)     Advance the table pointer
         CR    3,4          Compare the table pointer to the EOT
         BE    BEND         If at EOT end build
         B     BLOOP1       Goto top of loop
BEND     DS    0H
         ST    6,0(,5)     Store the number of elements
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End subroutine
         LTORG              Literals are put here
BUFFER   DS    80C
         DC    C'*'
SAVEB    DS    18F'0'
***********************************
*
*  Register usage:
*    1        Used by XDECI/params
*    2        Line string location
*    3        Table address
*    4        EOT address
*    5        Length of table address
*    6        Width counter 
*    7        Value from table
*   10        Base
*   13        Save area
*   14        DONT USE
*   15        Base register
*
***********************************
PRINT    CSECT
         STM   14,12,12(13)
         LR    12,15
         USING PRINT,10
         LM    3,5,0(1)     Load params into R3,R4, and R5
         LA    14,SAVEC
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         XPRNT PHEAD,44     Print the table head
         L     5,0(,5)     Load the lenght of the table
PLOOP    L     6,=F'7'      Counter for width of table
         LA    2,PLINE+1    Set R2 to the address of the print line
         MVI   PLINE+1,C' ' Clear the print line
         MVC   PLINE+2(83),PLINE+1
         C     5,=F'0'      Check if all values have been printed
         BE    PEND
PLOOP1   C     5,=F'0'      Check if all values have been printed
         BE    PEND1
         L     7,0(,3)     Get current value from table
         XDECO 7,TEMP       Hex to base 10
         MVC   0(12,2),TEMP Store base 10 num in print line
         LA    2,12(,2)    Advance print line pointer
         LA    3,4(,3)     Advance table pointer
         S     5,=F'1'      Decrement table length counter
         S     6,=F'1'      Decrement line width counter
         C     6,=F'0'      Check if we have filled a line
         BNE   PLOOP1       Goto top of loop1
         XPRNT PLINE,85     Print print line
         B     PLOOP        Goto top of loop
PEND1    XPRNT PLINE,85     Print printline
PEND     DS    0H
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
PHEAD    DC    CL44'1             Results of Searching the table'
PLINE    DC    CL1'0'
         DS    CL84' '
TEMP     DS    CL12' '
SAVEC    DS    18F'0'
***********************************
*
*  Register usage:
*    3        Table pointer
*    4        EOT
*    5        Table Length
*    6        Search number
*    7        Address of return var
*    8        Value temp
*    9        Return value
*   10        Base
*   13        Save Area
*   14        DONT USE
*   15        Base register
*
***********************************
SEARCH   CSECT
         STM   14,12,12(13)
         LR    12,15
         USING SEARCH,10
         LM    3,7,0(1)     Load params into R3,R4, R5, R6, R7
         LA    14,SAVED
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
*
         SR    9,9          Clear R9
SLOOP    CR    3,4          Compare table pointer with EOT
         BE    SEND         End if equal
         L     8,0(,3)      Load Table number
         CR    8,6          Compare table with search
         BE    SEQU         If equal goto SEQU
         LA    3,4(,3)      Advance table pointer
         B     SLOOP        Top of loop
SEQU     L    9,=F'1'       Set return Register
SEND     DS    0H           End of Search
         ST    9,0(,7)      Set return to var
*
         L     13,4(,13)
         LM    14,12,12(13)
         BR    14           End of subroutine
         LTORG              Literals are put here
SAVED    DS    18F'0'
***********************************
         END   MAIN
/*
//FT05F001  DD  DSN=KC02314.AUTUMN17.CSCI360.HW5DATA,DISP=SHR
//