TITLE Program #2 - RPN Calculator

; Group #9
; Zac Tarpley (TAR5746), Jacob Pitzer (PIT7706), Zech Shoup (SHO3426)
; CSC - 323 Assembly Programming Language
; Created: 2/23/2017
; Edited: 2/26/2017

INCLUDE Irvine32.inc

.data
;______________________________________________________________________________
msg0		BYTE	"Welcome to CSC-323 Program #2", 0
msg01		BYTE	"Input 8 values into the stack", 0
msg1		BYTE	"Enter a value or command", 0
msg2		BYTE	"You must enter an integer.", 0
msg3		BYTE	"AT END SWITCH", 0
msg4		BYTE	"INSIDE AddThem Proc   "
msg5		BYTE	"INSIDE SubThem Proc   ", 0
msg6		BYTE	"INSIDE MulThem Proc   ", 0
msg7		BYTE	"INSIDE DivThem Proc   ", 0
msg8		BYTE	"INSIDE ExcThem Proc   ", 0
msg9		BYTE	"INSIDE Negate Proc   ", 0
msg10		BYTE	"INSIDE FruitRollUp Proc   ", 0
msg11		BYTE	"INSIDE RollDown Proc   ", 0
msg12		BYTE	"INSIDE ViewArray Proc   ", 0
msg13		BYTE	"INSIDE ClearArray Proc   ", 0

bfr0		DWORD	0
StackSize	EQU		8
numStack	SDWORD	StackSize	dup(0)
StackIndex	DWORD	-4
bfrArray	DWORD	21 dup(0)
bfrCnt		DWORD	0

TRUE		EQU		1
FALSE		EQU		0
NULL		EQU		0

moredata	BYTE	1
;_______________________________________________________________________________ Beginning of CODE
.code
main PROC

MOV EDX, OFFSET msg0
CALL WriteString
CALL CRLF

MOV EDX, OFFSET msg01
Call WriteString
Call CRLF
Call CRLF

MOV EDX, OFFSET bfrArray
MOV ECX, SIZEOF bfrArray
Call ReadString

MOV ESI, NULL
CMP bfrArray[ESI], ' '
JE Success
JNE NoSuccess
Success: 
MOV EDX, OFFSET msg0
CALL WriteString
CALL CRLF






			
NoSuccess:

exit				
main ENDP		



END main
