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
*  2     Total 
*  5     Counter
* 15     Base register
*
********************************************
MAIN     CSECT
         USING MAIN,15
         SR    2,2     ZERO FOR TOTAL
         SR    5,5     ZERO FOR COUNTER
         XDUMP
         BR    14
         END   MAIN
/*
//