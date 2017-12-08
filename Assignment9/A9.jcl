//KC03I2CA JOB ,'Alex Boyle',MSGCLASS=H
//STEP1   EXEC  PGM=ASSIST,PARM='MACRO=H'
//STEPLIB   DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT  DD  SYSOUT=*
//SYSIN     DD  *
************************************************************
*
*  Program:     ASSIGN9
*  Programmer:  Alex Boyle
************************************************************
*
*
***********************************
*Name: STRCMP
*
* This macro compares two c style strings and sets the condition 
* code to:
* 0 if equal
* 1 if less than
* 2 if greater than
*
*  Params: &FIRST  - the first c-string in the comparason
*          &SECOND - The second c-scring in the comparason
*
*  Return: The Condition Code is set to :
*     0 if equal
*     1 if less than
*     2 if greater than
*
*  Register usage:
*  2 Pointer to &FIRST
*  3 Pointer to &SECOND
***********************************
         MACRO Start Macro code
         STRCMP &FIRST,&SECOND The macro's name is STRCMP and has 2 pa
         AIF   ('&FIRST' EQ '').ERROR if the first argument is missing
         AIF   ('&SECOND' EQ '').ERROR if the second argument is missi
         STM   2,3,A&SYSNDX Back up the params we wil be using
         B     B&SYSNDX branch over save area
A&SYSNDX DS    2F Save area
B&SYSNDX LA    2,&FIRST Store pointer to first param in R2
         LA    3,&SECOND Store pointer to second param in R3
C&SYSNDX DS    0H top of comparason loop
         CLC   0(1,2),0(3) check if the current letters are equal
         BNE   D&SYSNDX If not equal, branch to end of macro
         CLI   0(2),X'00' check if at end of c-string
         BE    D&SYSNDX if true branch to end of macro
         LA    2,1(,2) advance pointer
         LA    3,1(,3) advance pointer
         B     C&SYSNDX branch to top of loop
D&SYSNDX DS    0H end of macro lable
         LM    2,3,A&SYSNDX restore the registers used
         MEXIT exit macro
.ERROR   MNOTE 'Missing Argument'
         MEND end macro code
*
*
***********************************
*Name: MAX
*
* This macro compares a list of fullwords and stores the largest one
* in a specified area
*
*  Params: &RESULT - Location to store the largest fullword at
*          &LIST   - The list of fullwords to compare
*
*  Return: Largest number stored at &RESULT
*
*  Register usage:
*  2 Largest element of &LIST
*  3 Comparison element of &LIST
*  4 Location in code to branch to
***********************************
         MACRO Start of macro code
         MAX &RESULT,&LIST MAX has the params RESULT and LIST
         LCLA  &CNT,&NUM declare the arithmatic var CNT and NUM
&CNT     SETA  2 set CNT to 2
&NUM     SETA  N'&LIST set NUM to the lenght of the list
         AIF   ('&RESULT' EQ '').ERROR if RESULT is blank error
         AIF   ('&LIST' EQ '').ERROR if LIST is blank error
         AIF   ('&LIST' EQ '()').ERROR if list is empty error
         STM   2,4,Z&SYSNDX store registers 2-4
         B     Y&SYSNDX branch over save area
Z&SYSNDX DS    3F Save area
Y&SYSNDX DS    0H Start of macro logic
         L     2,&LIST(1) load fullword into R2
.BLOOP   AIF   (&CNT  GT  &NUM).DONE condition for including the
*                                    following code when compiling
*                                    goto .DONE when done
         L     3,&LIST(&CNT) load the next full word
         BAL   4,W&SYSNDX branch to compare
         BH    W&SYSNDX 
&CNT     SETA  &CNT+1 increment CNT by 1
         AGO   .BLOOP go to top of generating loop
.DONE    ANOP end of generated loop
         B     X&SYSNDX branch to end of code
W&SYSNDX DS    0H compare block
         CR    2,3 compare R2 and R3
         BH    V&SYSNDX  if R2 is bigger goto register load
         BR    4 branch back to 4
V&SYSNDX DS    0H register load
         LR    2,3 load 3 into 2
X&SYSNDX DS    0H end of logic
         ST    2,&RESULT store the largest number
         LM    2,4,Z&SYSNDX restore registers
         MEXIT exit macro
.ERROR   MNOTE 'Missing Argument'
         MEND end macro code
*
*
//          DD DSN=KC02314.AUTUMN17.CSCI360.HW9DRVR,DISP=SHR
//FT05F001  DD DUMMY
//FT06F001  DD SYSOUT=*
//