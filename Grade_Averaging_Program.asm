TITLE Program #1 - The Grade Averaging Program

; Group #9
; Zac Tarpley (TAR5746), Jacob Pitzer (PIT7706), Zech Shoup (SHO3426)
; CSC - 323 Assembly Programming Language
; Created: 2/1/2017
; Last Edited: 2/5/2017

INCLUDE Irvine32.inc

.data 
; Innitial prompts and directions
message0	BYTE	"-Welcome to the Grade Averaging program.", 0
message1	BYTE	"--Please enter an inclusive value between 0-100.", 0
message2	BYTE	"-Entering 323 will end the program.", 0
message3    BYTE	"Please enter a value.", 0
message4    BYTE	"Please enter a value greater than zero.", 0
message5    BYTE	"Please enter a value less than 100.", 0
message6    BYTE	"Grades entered: ", 0
message7	BYTE	"Total of grades entered: ", 0
message8    BYTE	"Average: ", 0
message9	BYTE	"Remainder: ", 0


buffer		DWORD	50d  dup(0)
sum1		DWORD	1d  dup(0)
counter		DWORD	1d  dup(0)
temp1		DWORD	1d  dup(0)
converter	DWORD	16  dup(0)

.code
	main PROC
		MOV EDX, OFFSET message0				;Program startup prompts
		CALL WriteString
		CALL CRLF
		MOV EDX, OFFSET message1
		CALL WriteString
		CALL CRLF
		MOV EDX, OFFSET message2
		CALL WriteString
		CALL CRLF


    START1:		MOV EDX, OFFSET buffer
				MOV ECX, SIZEOF buffer

				call ReadString

				CMP EAX, 0						;Checks if user enters a value
				JZ SAFETY1
				MOV ECX, EAX					;Converts entry to decimal
		        CALL ParseInteger32

				CMP EAX, 323					;Checks keyboard for termination string
				JE Result1
				CMP EAX, 0						;Checks innitial value if = = 0
				JE SAFETY2
	START2:		CMP EAX, 0						;Checks if value is <0
				JL SAFETY4
				CMP EAX, 100					;Checks if value is >100
				JG SAFETY3
				JMP PROCESSING					;If all is okay then jump to PROCESSING

	SAFETY1:	MOV EDX, OFFSET message3		;Prompts user to reenter a value
				CALL WriteString
				CALL CRLF
				JMP START1

	SAFETY2:	CMP counter, 0d					;Checks if innitial value is >0, Proceeding values can be >=0
				JG START2
				MOV EDX, OFFSET message4		
				CALL WriteString
				CALL CRLF
				JMP START1

	SAFETY3:	MOV EDX, OFFSET message5		;Prompts the user to enter a value <101
				CALL WriteString
				CALL CRLF
				JMP START1

	SAFETY4:	MOV EDX, OFFSET message4		;Prompts the user to enter a value >0
				CALL WriteString
				CALL CRLF
				JMP START1

	PROCESSING: ADD sum1, EAX					;Accumulates the sum and counter
				INC counter
				JMP START1

	Result1:	CMP counter, 0d					
				JZ SAFETY1
				MOV EDX, OFFSET message6		;Prints the qty of grades entered
				CALL WriteString
				MOV EAX, counter
				CALL WriteDec
				CALL CRLF

				MOV EDX, OFFSET message7		;Prints the grade total
				CALL WriteString
				MOV EAX, sum1
				CALL WriteDec
				CALL CRLF

				MOV EAX, sum1					;Prints the average
				CDQ
				MOV EBX, counter
				idiv EBX
				MOV EDX, OFFSET message8
				CALL WriteString
				CALL WriteDec
				CALL CRLF

				MOV EDX, OFFSET message9		;Prints the remainder
				CALL WriteString
				MOV EAX, sum1
				CDQ
				MOV EBX, counter
				idiv EBX
				MOV EAX, EDX
				CALL WriteDec
				CALL CRLF




	EXIT
	main ENDP
	END main