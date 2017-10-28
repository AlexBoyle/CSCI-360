//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1 EXEC PGM=ASSIST
//STEPLIB DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
********************************************
* EXAMPLE PROGRAM
*
* NAME:  Alex Boyle
*
* Register Usage
*
* 15     
*  1     NUM1 Add
*  2     NUM2 Add
*  3     NUM1 Sub
*  4     NUM2 Sub
*
********************************************
MAIN     CSECT
         USING MAIN,15
         L     1,NUM1       Load NUM1 into R1
         L     2,NUM2       Load NUM2 into R2
         SR    2,1          Subtract R2 from R1, store in R2
         ST    2,DIFF       Store R2 in DIFF
         L     3,NUM1       Load NUM1 into R3
         L     4,NUM2       Load NUM2 into R4
         AR    4,3          Add R4 and R3, store in R4
         ST    4,SUM        Store R4 in SUM
         XDUMP DIFF,8       Dump DIFF
         XDUMP SUM,8        Dump SUM
         BR    14           End program
NUM1     DC    F'249'       NUM1 = 249
NUM2     DC    F'117'       NUM2 = 117
DIFF     DS    F            DIFF = null
SUM      DS    F            SUM = null
         END   MAIN
/*
//