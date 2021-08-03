TITLE Program #3 - Multitasking Operating System Simulator

; Group #9
; Zac Tarpley (TAR5746), Jacob Pitzer (PIT7706), Zech Shoup (SHO3426)
; CSC - 323 Assembly Programming Language
; Created: 3/16/2017
; Edited: 3/28/2017

INCLUDE Irvine32.inc
;_____________________________________________________________________________________________________ DATA Division
.data

		msg0	BYTE	"Enter command or HELP (all caps): ", 0
		msg1	BYTE	"Enter a valid command (enter HELP for assistance).", 0
		msg2	BYTE	"Job name must be less than 9 characters in length.", 0
		msg3	BYTE	"Enter a JOBNAME between 1 and 8 characters: ", 0
		msg4	BYTE	"Enter the level of priority (0-7 ONLY): ", 0
		msg5	BYTE	"Enter the RUNTIME(1-50 ONLY): ",0
		msg6	BYTE	"Enter the job name: ", 0
		msg7	BYTE	"Job does not exist.", 0
		msg8	BYTE	"JOB QUEUE IS FULL"
		msg9	BYTE	"          ", 0
		msg10	BYTE	"_____________________________________________________", 0
		msg11	BYTE	"Job must be in the HOLD state.", 0
		msg12	BYTE	"Job - - Priority - - Runtime - - LoadTime - - Status", 0
		msg13	BYTE	" - - ", 0
		msgS	BYTE	"   ", 0
		help1	BYTE	"- The program will prompt for inputs.", 0
		help2	BYTE	"- All commmand entries must be CAPITALIZED.", 0
		help2a	BYTE	"- Job Queue cannot exceed 10 jobs.", 0
		help2b	BYTE	"- Job must be in RUN (1) state to be processed.", 0
		help2c	BYTE	"- Job must be in HOLD (0) state to be killed", 0
		help3	BYTE	"- Command options include:", 0
		help4	BYTE	"   1. QUIT: Terminates the program.", 0
		help5a	BYTE	"   2. LOAD: Loads job into the Queue.",0 
		help5b	byte    " Job is defaulted to hold state.", 0
		help6	BYTE	"   3. RUN: Changes job from HOLD state to RUN state.",0
		help7	BYTE	"   4. HOLD: Changes job from RUN state to HOLD state.", 0
		help8	BYTE	"   5. KILL: Removes job from Queue. MUST BE IN HOLD STATE.", 0
		help9	BYTE	"   6. SHOW: Displays all the job Queue slots.", 0
		help10	BYTE	"   7. STEP: Processes the highest priority job in the Queue.", 0
		help11	BYTE	"   8. CHANGE: Enables user to change job priority.", 0
	 

JobQueueSize	EQU		10d
  MaxJobSize	EQU		8d
  MaxRuntime	EQU		50d	
		NULL	EQU		0d
		HOLD	EQU		0d
		 RUN	EQU		1d
	JobQueue	BYTE	10d	
		Jobs	BYTE	160		dup(0)	
  JobsBuffer	BYTE	160		dup(0)
      JobCnt	BYTE	1d
	 StepCnt	BYTE	1d	
	 LoopCnt	BYTE	1d
	   Steps	DWORD	2d		dup(0)
	  PriCnt	BYTE	1d	
	  buffer	BYTE	8d		dup(0)
   JobBuffer	BYTE	9d		dup(0)
   PriBuffer	BYTE	2d		dup(0)
   RunBuffer	BYTE	3d		dup(0)
  LoadBuffer	BYTE	3d		dup(0)
   ChaBuffer	BYTE	2d		dup(0)
  KillBuffer	DWORD	2d		dup(0)
  ShiftIndex	BYTE	2d		dup(0)
   TempArray	BYTE	8d		dup(0)
     RunTemp	BYTE	8d		dup(0)
	 RunSize	DWORD	1d		dup(0)
	 ChaSize	DWORD	1d		dup(0)
	  RunCnt	DWORD	1d		dup(0)
	PrintCnt	DWORD	1d
  QueueIndex 	DWORD	3d		dup(0)
      JobLoc	DWORD	1d		dup(0)
	  PriLoc	DWORD	1d		dup(0)
	  RunLoc	DWORD	1d		dup(0)
	 LoadLoc	DWORD	1d		dup(0)
	  StaLoc	DWORD	1d		dup(0)
	NullFlag	BYTE	1d		dup(0)
	QuitFlag	BYTE	1d		dup(1)
	StepFlag	BYTE	1d		dup(0)
	 QuitVar    BYTE	"QUIT", 0
	 HelpVar	BYTE	"HELP", 0
	 LoadVar	BYTE	"LOAD", 0
	  RunVar	BYTE	"RUN", 0
	 HoldVar	BYTE	"HOLD", 0
	 KillVar	BYTE	"KILL", 0
	 ShowVar	BYTE	"SHOW", 0
	 StepVar	BYTE	"STEP 0", 0
   ChangeVar	BYTE	"CHANGE", 0
	
;_____________________________________________________________________________________________________ CODE Division
.code
	main PROC

	MOV JobQueue, 0d								; - inits important counting variables
	MOV LoadBuffer, 0d


	L0:		MOV EDX, OFFSET msg0
			Call WriteString

			MOV NullFlag, 0d								; - reads user input
			MOV EDX, OFFSET buffer
			MOV ECX, SIZEOF buffer
			CALL ReadString			

			CMP EAX, 0										; - Checks if entry is <9 && >0
			JZ ERROR0
			
			CALL SkipWhiteSpaces							; - tosses any white spaces
			CMP NullFlag, 1									; - if no input, JMP to error0
			JE ERROR0
			JMP SwitchCase

ERROR0:		MOV EDX, OFFSET msg1							; - Prompts for user command
			CALL WriteString
			CALL CRLF
			JMP L0

SwitchCase: 
			
Case1:		CLD
			MOV ESI, OFFSET TempArray						; - Compares TempArray to "QUIT"
			MOV EDI, OFFSET QuitVar                    
			MOV ECX, LENGTHOF QuitVar
			REPE CMPSB
			JNE Case2
			CALL QuitJobs
			CMP QuitFlag, 0d
			JE QuitP
			JMP EndSwitch
Case2:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "HELP"
			MOV EDI, OFFSET HelpVar
			MOV ECX, LENGTHOF HelpVar
			CMPSW
			JNE Case3
			CALL HelpPrompt
			JMP EndSwitch
Case3:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "LOAD"
			MOV EDI, OFFSET LoadVar
			MOV ECX, LENGTHOF LoadVar
			CMPSW
			JNE Case4
			CALL LoadJob
			JMP EndSwitch
Case4:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "RUN"
			MOV EDI, OFFSET RunVar
			MOV ECX, LENGTHOF RunVar
			CMPSW
			JNE Case5
			CALL RunJob
			JMP EndSwitch
Case5:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "HOLD"
			MOV EDI, OFFSET HoldVar
			MOV ECX, LENGTHOF HoldVar
			CMPSW
			JNE Case6
			CALL HoldJob
			JMP EndSwitch
Case6:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "KILL"
			MOV EDI, OFFSET KillVar
			MOV ECX, LENGTHOF KillVar
			CMPSW
			JNE Case7
			CALL KillJob
			JMP EndSwitch
Case7:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "SHOW"
			MOV EDI, OFFSET ShowVar
			MOV ECX, LENGTHOF ShowVar
			CMPSW
			JNE Case8
			CALL ShowJob
			JMP EndSwitch
Case8:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "STEP 0"
			MOV EDI, OFFSET StepVar							; - Moves 'n' into array named Step
			MOV ECX, LENGTHOF StepVar
			CMPSW
			JNE Case9
			MOV ESI, OFFSET TempArray
			MOV EBX, [ESI+5]
			MOV Steps, EBX
			CALL StepJob
			JMP EndSwitch
Case9:		CLD
			MOV ESI, OFFSET TempArray                       ; - Compares TempArray to "Change"
			MOV EDI, OFFSET ChangeVar
			MOV ECX, LENGTHOF ChangeVar
			CMPSW
			JNE Case10
			CALL ChangeJob
			JMP EndSwitch
Case10:		
			
EndSwitch: JMP L0
QuitP:
EXIT
main ENDP
;_____________________________________________________________________________________________________ End of main Proc

;_____________________________________________________________________________________________________ SkipWhiteSpaces PROC (COMPLETE)
; - This subroutine skips all the white spaces and checks for '0'. 
; - If characters are entered, they're moved into TempArray for later processing
SkipWhiteSpaces PROC
			
			MOV EAX, NULL									; - inits arrays
			MOV EBX, NULL
			MOV ECX, NULL
			MOV EDX, NULL
			MOV ESI, NULL
	
			MOV ESI, OFFSET buffer
L0:			MOV BL, [ESI]									; - checks input for spaces (20h = [SPACE]) & loops
			CMP BL, 20h
			JNE L1											; - JMP to loop when character found
			ADD ESI, 1
			LOOP L0
L1:			CMP BL, 00h										; - checks if user enters '0' then jumps to L2A
			JNE L2A
			MOV NullFlag, 1
			JMP EndLoop
			
			
L2A:		MOV EDX, OFFSET TempArray						; - Begins moving contents into temporary array
L2B:		MOV BL, [ESI]
			MOV [EDX], BL
			ADD ESI, 1
			ADD EDX, 1
			CMP BL, 0000h
			JNE L2B


EndLoop: 
RET
SkipWhiteSpaces ENDP

;_____________________________________________________________________________________________________ QuitJobs PROC (COMPLETE)
; - Simply moves '0' into QuitFlag. The QuitFlag is checked during the primary switch case/command reading
QuitJobs PROC
			MOV QuitFlag, 0d
			RET
QuitJobs ENDP

;_____________________________________________________________________________________________________ HelpPrompt PROC (INCOMPLETE)
; - Displays helpful information to the user
HelpPrompt PROC

MOV EDX, OFFSET msg10
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help1
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help2
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help2a
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help2b
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help2c
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help3
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help4
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help5a
CALL WriteString
MOV EDX, OFFSET help5b
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help6
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help7
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help8
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help9
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help10
CALL WriteString
CALL CRLF
MOV EDX, OFFSET help11
CALL WriteString
CALL CRLF
MOV EDX, OFFSET msg10
CALL WriteString
CALL CRLF


RET
HelpPrompt ENDP

;_____________________________________________________________________________________________________ LoadJob PROC (NEEDS FINE TUNING)
; - This subroutine is responsible for ALL the job queue LOADING. Deletion is handled by "ShiftJobs PROC" 
LoadJob PROC
		

		CMP JobQueue, 10							; - If Queue is full, send prompt to user
		JE FULL
		
			
	L0: MOV EDX, OFFSET msg3						;- This loop gets the job name & stores in JobBuffer
		CALL WriteString
		MOV EDX, OFFSET JobBuffer
		MOV ECX, SIZEOF JobBuffer
		CALL ReadString
		CMP EAX, 0d
		JE L0
		CMP EAX, 9d
		JE L0
		CMP byte ptr [EDX], ' '
		JE L0
		
	L1:	MOV EDX, OFFSET msg4						; - This loop gets priority and stores in PriBuffer		
		CALL WriteString
		MOV EDX, OFFSET PriBuffer
		MOV ECX, SIZEOF PriBuffer
		CALL ReadString
		CMP EAX, 0
		JE L1
		CMP EAX, 2
		JE L1
		CALL ParseInteger32
		CMP EAX, 0
		JL L1
		CMP EAX, 8
		JGE L1
		MOV PriBuffer, 0
		MOV PriBuffer, AL
		
		
	L2: MOV EDX, OFFSET msg5						; - This loops gets the runtime and stores in RunBuffer
		CALL WriteString
		MOV EDX, OFFSET RunBuffer
		MOV ECX, SIZEOF RunBuffer
		CALL ReadString
		CMP EAX, 0
		JE L2
		CMP EAX, 3
		JGE L2
		CALL ParseInteger32
		CMP EAX, 1
		JL L2
		CMP EAX, 50
		JG L2
		MOV RunBuffer, AL
		

		CMP JobQueue, 0								; - Inits Queue offsets
		JG L8
		MOV JobLoc, 0
		MOV PriLoc, 9
		MOV RunLoc, 10
		MOV LoadLoc, 12
		MOV StaLoc, 15

   L2A: MOV JobCnt, 0
		MOV ESI, OFFSET Jobs						; - Loads JobBuffer into the queue
		ADD ESI, JobLoc
		MOV EAX, OFFSET JobBuffer
	L3:	MOV ECX, [EAX]
		MOV [ESI], ECX
		ADD JobCnt, 1d
		CMP JobCnt, MaxJobSize
		JG L4
		ADD ESI, 1
		ADD EAX, 1
		JMP L3
		
	L4:	MOV ECX, 0									; - Loads PriBuffer into queue
		MOV ESI, OFFSET Jobs
		ADD ESI, PriLoc
		MOV [ESI], ECX
		MOV EBX, OFFSET PriBuffer
		MOV ECX, [EBX]
		MOV [ESI], ECX

    L5: MOV ECX, 0									; - Loads RunBuffer into queue
		MOV ESI, OFFSET Jobs
		ADD ESI, RunLoc
		MOV [ESI], ECX
		MOV EBX, OFFSET RunBuffer
		MOV ECX, [EBX]
		MOV [ESI], ECX
		ADD EBX, 1
		ADD ESI, 1
		MOV ECX, [EBX]
		MOV [ESI], ECX

		MOV ECX, 0									; - Loads LoadBuffer into queue
		MOV ESI, OFFSET Jobs
		ADD ESI, LoadLoc
		MOV [ESI], ECX
		MOV EBX, OFFSET LoadBuffer
	L6:	MOV ECX, [EBX]
		MOV [ESI], ECX
		ADD EBX, 1
		ADD ESI, 1
		MOV ECX, [EBX]
		MOV [ESI], ECX
		ADD EBX, 1
		ADD ESI, 1
		MOV ECX, [EBX]
		MOV [ESI], ECX
		ADD EBX, 1
		ADD ESI, 1

		MOV ECX, HOLD
		MOV ESI, OFFSET Jobs
		ADD ESI, StaLoc
		MOV [ESI], ECX
		JMP EndLoad

	L8: ADD JobLoc, 16
		ADD PriLoc, 16
		ADD RunLoc, 16
		ADD LoadLoc, 16
		ADD StaLoc, 16
		JMP L2A

FULL: MOV EDX, OFFSET msg8
	  CALL WriteString
	  CALL CRLF
	  JMP EndLoad1

EndLoad: ADD JobQueue, 1
EndLoad1:
		
RET
LoadJob ENDP

;_____________________________________________________________________________________________________ RunJob PROC (COMPLETE)
; - This procedue changes a job from HOLD state to RUN state
RunJob PROC
	
	L0:	    MOV EDX, OFFSET msg6						; - Gets user input	
			CALL WriteString
			MOV EDX, OFFSET buffer
			MOV ECX, SIZEOF buffer
			CALL ReadString
			CMP EAX, 0		
			MOV RunSize, EAX		
			JZ ERROR0
			MOV RunSize,EAX
			CALL SkipWhiteSpaces

Case1:		CLD											; - Checks first location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case2
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+15], CL
			JMP EndSwitch

Case2:      CLD											; - Checks second location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+16
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case3
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+31], CL
			JMP EndSwitch

Case3:      CLD											; - Checks third location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+32
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case4
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+47], CL
			JMP EndSwitch

Case4:      CLD											; - Checks fourth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+48
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case5
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+63], CL
			JMP EndSwitch

Case5:      CLD											; - Checks fifth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+64
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case6
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+79], CL
			JMP EndSwitch

Case6:      CLD											; - Checks sixth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+80
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case7
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+95], CL
			JMP EndSwitch

Case7:      CLD											; - Checks seventh location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+96
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case8
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+111], CL
			JMP EndSwitch

Case8:      CLD											; - Checks eighth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+112
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case9
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+127], CL
			JMP EndSwitch

Case9:      CLD											; - Checks ninth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+128
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case10
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+143], CL
			JMP EndSwitch

Case10:     CLD											; - Checks tenth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+144
			MOV ECX, RunSize
			REPE CMPSB
			JNE NoJob
			MOV ESI, OFFSET Jobs
			MOV CL, RUN
			MOV [ESI+159], CL
			JMP EndSwitch


ERROR0:		MOV EDX, OFFSET msg1						; - Error prompt for nothing entered
			CALL WriteString
			CALL CRLF
			JMP L0
NoJob:		MOV EDX, OFFSET msg7						; - Error prompt for invalid entry/no search results returned
			CALL WriteString
			CALL CRLF

EndSwitch:


			

RET
RunJob ENDP

;_____________________________________________________________________________________________________ HoldJob PROC (COMPLETE)
; - This procedure changes a jobs RUN status to HOLD status
HoldJob PROC

L0:			MOV EDX, OFFSET msg6						; - Gets user input	
			CALL WriteString
			MOV EDX, OFFSET buffer
			MOV ECX, SIZEOF buffer
			CALL ReadString
			CMP EAX, 0		
			MOV RunSize, EAX		
			JZ ERROR0
			MOV RunSize,EAX
			CALL SkipWhiteSpaces

Case1:		CLD											; - Checks first location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case2
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+15], CL
			JMP EndSwitch

Case2:      CLD											; - Checks second location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+16
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case3
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+31], CL
			JMP EndSwitch

Case3:      CLD											; - Checks third location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+32
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case4
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+47], CL
			JMP EndSwitch

Case4:      CLD											; - Checks fourth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+48
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case5
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+63], CL
			JMP EndSwitch

Case5:      CLD											; - Checks fifth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+64
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case6
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+79], CL
			JMP EndSwitch

Case6:      CLD											; - Checks sixth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+80
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case7
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+95], CL
			JMP EndSwitch

Case7:      CLD											; - Checks seventh location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+96
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case8
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+111], CL
			JMP EndSwitch

Case8:      CLD											; - Checks eighth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+112
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case9
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+127], CL
			JMP EndSwitch

Case9:      CLD											; - Checks ninth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+128
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case10
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+143], CL
			JMP EndSwitch

Case10:     CLD											; - Checks tenth location of the JobQueue
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+144
			MOV ECX, RunSize
			REPE CMPSB
			JNE NoJob
			MOV ESI, OFFSET Jobs
			MOV CL, HOLD
			MOV [ESI+159], CL
			JMP EndSwitch


ERROR0:		MOV EDX, OFFSET msg1
			CALL WriteString
			CALL CRLF
			JMP L0

NoJob:		MOV EDX, OFFSET msg7						; - Error prompt for invalid entry/no search results returned
			CALL WriteString
			CALL CRLF

EndSwitch:

RET
HoldJob ENDP

;_____________________________________________________________________________________________________ KillJob PROC (COMPLETE)
; - This procedure identifies the job that the user wants to delete. Passes a identifier into a variable "KillBuffer"
; - See ShiftJobs PROC
KillJob PROC

L0:			MOV EDX, OFFSET msg6						; - Gets user input	
			CALL WriteString
			MOV EDX, OFFSET buffer
			MOV ECX, SIZEOF buffer
			CALL ReadString
			CMP EAX, 0		
			MOV RunSize, EAX		
			JZ ERROR0
			MOV RunSize,EAX
			CALL SkipWhiteSpaces

Case1:		CLD											; - Checks first location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case2
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+15], AL
			JNE NoGo
			MOV KillBuffer, 0
			Call ShiftJobs
			JMP EndSwitch

Case2:		CLD											; - Checks second location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+16
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case3
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+31], AL
			JNE NoGo
			MOV KillBuffer, 1
			Call ShiftJobs
			JMP EndSwitch

Case3:		CLD											; - Checks third location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+32
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case4
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+47], AL
			JNE NoGo
			MOV KillBuffer, 2
			Call ShiftJobs
			JMP EndSwitch

Case4:		CLD											; - Checks fourth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+48
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case5
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+63], AL
			JNE NoGo
			MOV KillBuffer, 3
			Call ShiftJobs
			JMP EndSwitch

Case5:		CLD											; - Checks fifth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+64
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case6
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+79], AL
			JNE NoGo
			MOV KillBuffer, 4
			Call ShiftJobs
			JMP EndSwitch

Case6:		CLD											; - Checks sixth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+80
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case7
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+95], AL
			JNE NoGo
			MOV KillBuffer, 5
			Call ShiftJobs
			JMP EndSwitch

Case7:		CLD											; - Checks seventh location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+96
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case8
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+111], AL
			JNE NoGo
			MOV KillBuffer, 6
			Call ShiftJobs
			JMP EndSwitch

Case8:		CLD											; - Checks eighth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+112
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case9
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+127], AL
			JNE NoGo
			MOV KillBuffer, 7
			Call ShiftJobs
			JMP EndSwitch

Case9:		CLD											; - Checks ninth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+128
			MOV ECX, RunSize
			REPE CMPSB
			JNE Case10
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+143], AL
			JNE NoGo
			MOV KillBuffer, 8
			Call ShiftJobs
			JMP EndSwitch

Case10:		CLD											; - Checks tenth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+144
			MOV ECX, RunSize
			REPE CMPSB
			JNE NoJob
			MOV EDI, OFFSET Jobs
			MOV EAX, 0d
			CMP [EDI+159], AL
			JNE NoGo
			MOV KillBuffer, 9
			Call ShiftJobs
			JMP EndSwitch

ERROR0:		MOV EDX, OFFSET msg6
			CALL WriteString
			CALL CRLF
			JMP L0

NoGo:		MOV EDX, OFFSET msg11
			CALL WriteString
			CALL CRLF
			JMP EndSwitch

NoJob:		MOV EDX, OFFSET msg7
			CALL WriteString
			CALL CRLF
			JMP EndSwitch

EndSwitch:

RET
KillJob ENDP

;_____________________________________________________________________________________________________ ShowJob PROC (NEEDS IMPROVEMENTS)
; - This procedure displays the entire JobQueue 
ShowJob PROC

		MOV EDX, OFFSET msg10
		CALL WriteString
		CALL CRLF
		CALL CRLF
		MOV EDX, OFFSET msg12
		CALL WriteString
		CALL CRLF
		MOV EDX, OFFSET msg10
		CALL WriteString
		CALL CRLF
		MOV QueueIndex, 0d	
		
								
	L1: MOV ESI, OFFSET Jobs
		ADD ESI, QueueIndex
		MOV EDX, ESI
		CALL WriteString
		MOV EDX, OFFSET msg13
		CALL WriteString
		MOV EAX, 0
		MOV AL, [ESI+9]
		CALL WriteDec
		MOV EDX, OFFSET msg13
		CALL WriteString
		MOV AL, [ESI+10]
		CALL WriteDec
		MOV EDX, OFFSET msg13
		CALL WriteString
		MOV AL, [ESI+12]
		CALL WriteDec
		MOV EDX, OFFSET msg13
		CALL WriteString
		MOV AL, [ESI+15]
		CALL WriteDec
		CALL CRLF
		ADD QueueIndex, 16d
		CMP QueueIndex, 160
		JL L1
		MOV EDX, OFFSET msg10
		CALL WriteString
		CALL CRLF

RET
ShowJob ENDP

;_____________________________________________________________________________________________________ StepJob PROC (NEEDS WORK)
; - This procedure Steps thru the jobs
; - First: Check if the variable 'n' was entered. If 'n' was entered, program will store variable and loop accordingly
; - Second: Increment JobQueue variable
; - Third: Check for RUN status starting at first job. If run, proceed to next loop. If hold, step to next job.
; - Fourth: Checks priority starting at zero. Will decrement the first lowest priority encountered
; - Fifth: Checks of LoadTime is '0'. If '0' then call ShiftJobs to delete from Queue
StepJob PROC
		
		MOV ESI, OFFSET Steps
		MOV ECX, 0
		CMP [ESI], ECX
		JE L0
		MOV EDX, OFFSET Steps
		MOV ECX, SIZEOF Steps
		CALL ParseInteger32
		CMP EAX, 0d
		JL L0
		MOV Steps, EAX



L0:		ADD LoadBuffer, 1d
		CMP JobQueue, 0
		JZ EndSwitch

		MOV StepCnt, 0d
		MOV LoopCnt, 0d

		MOV ESI, 0
		MOV EAX, 0
		MOV EBX, 0
		MOV EDX, 0

		MOV ESI, OFFSET Jobs
		MOV AL, 1d	
		MOV PriCnt, 0d
L1:		CMP [ESI+15], AL
		JNE Case1
		MOV BL, PriCnt
		CMP [ESI+9], BL
		JNE Case2
		MOV ECX, [ESI+10]
		SUB ECX, 1d
		MOV [ESI+10], ECX
		CMP CL, 00h
		JNE EndSwitch	
		MOV DL, StepCnt
		MOV KillBuffer, EDX
		CALL ShiftJobs
		JMP EndSwitch

Case1:	Add StepCnt, 1d
		CMP StepCnt, 10
		JE Case3
		ADD ESI, 16
		JMP L1

Case2:  Add StepCnt, 1d
		CMP StepCnt, 10
		JE Case3
		ADD ESI, 16
		JMP L1

Case3:  ADD LoopCnt, 1
		CMP LoopCnt, 7
		JG EndSwitch
		MOV StepCnt, 0
		MOV ESI, OFFSET Jobs
		ADD PriCnt, 1
		JMP L1

EndSwitch: 
			DEC Steps	
			CMP Steps, 0
			JG L0

RET
StepJob ENDP

;_____________________________________________________________________________________________________ ChangeJob PROC (COMPLETE)
; - This procedure changes the Run Time of a job in the queue. 
ChangeJob PROC

L0:			MOV EDX, OFFSET msg6						; - Gets user input	
			CALL WriteString
			MOV EDX, OFFSET buffer
			MOV ECX, SIZEOF buffer
			CALL ReadString
			CMP EAX, 0		
			MOV ChaSize, EAX		
			JZ ERROR0
			MOV RunSize,EAX
			CALL SkipWhiteSpaces
L1:			MOV EDX, OFFSET msg4						; - This loop gets priority and stores in ChaBuffer		
			CALL WriteString
			MOV EDX, OFFSET ChaBuffer
			MOV ECX, SIZEOF ChaBuffer
			CALL ReadString
			CMP EAX, 0
			JE L1
			CMP EAX, 2
			JE L1
			CALL ParseInteger32
			CMP EAX, 0
			JL L1
			CMP EAX, 8
			JGE L1
			MOV ChaBuffer, 0
			MOV ChaBuffer, AL
Case1:		CLD											; - Checks first location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case2
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+9], CL
			JMP EndSwitch

Case2:		CLD											; - Checks second location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+16
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case3
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+25], CL
			JMP EndSwitch

Case3:		CLD											; - Checks third location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+32
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case4
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+41], CL
			JMP EndSwitch

Case4:		CLD											; - Checks fourth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+48
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case5
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+57], CL
			JMP EndSwitch

Case5:		CLD											; - Checks fifth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+64
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case6
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+73], CL
			JMP EndSwitch

Case6:		CLD											; - Checks sixth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+80
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case7
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+89], CL
			JMP EndSwitch

Case7:		CLD											; - Checks seventh location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+96
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case8
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+105], CL
			JMP EndSwitch

Case8:		CLD											; - Checks eighth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+112
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case9
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+121], CL
			JMP EndSwitch

Case9:		CLD											; - Checks ninth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+128
			MOV ECX, ChaSize
			REPE CMPSB
			JNE Case10
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+137], CL
			JMP EndSwitch

Case10:		CLD											; - Checks tenth location of the JobQueue	
			MOV ESI, OFFSET TempArray	 
			MOV EDI, OFFSET Jobs+144
			MOV ECX, ChaSize
			REPE CMPSB
			JNE NoJob
			MOV ESI, OFFSET Jobs
			MOV CL, ChaBuffer
			MOV [ESI+153], CL
			JMP EndSwitch

ERROR0:		MOV EDX, OFFSET msg1
			CALL WriteString
			CALL CRLF
			JMP L0

NoJob:		MOV EDX, OFFSET msg7
			CALL WriteString
			CALL CRLF

EndSwitch:
RET
ChangeJob ENDP

;_____________________________________________________________________________________________________ ShiftJobs PROC (COMPLETE)
; - This job "REMOVES" a desired job from the Jobs queue by overwritting the current location with the next job in the queue.
; - If the last job in the queue is encountered, it will insert zeros into that location
ShiftJobs PROC
			
			DEC JobQueue
			SUB JobLoc, 16
			SUB PriLoc, 16
			SUB RunLoc, 16
			SUB LoadLoc, 16
			SUB StaLoc, 16
			CMP KillBuffer, 10
			JGE L3
L0:			MOV ShiftIndex, 0
			MOV EDX, KillBuffer
			IMUL ECX, EDX, 16
			MOV EAX, OFFSET Jobs
			ADD EAX, ECX
L1:			MOV BL,[EAX+16]
			MOV [EAX], BL
			ADD EAX, 1
			ADD ShiftIndex, 1
			CMP ShiftIndex, 16
			JL L1
			JGE L2

L2:			CMP KillBuffer, 10
			JGE EndSwitch
			Add KillBuffer, 1
			JMP L0

L3:			MOV ShiftIndex, 0
			MOV EAX, OFFSET Jobs
			MOV EBX, 0
L3A:		MOV [EAX+144], BL
			ADD ShiftIndex, 1
			CMP ShiftIndex, 16
			JGE EndSwitch
			ADD EAX, 1d
			JMP L3A
			 
EndSwitch: 

RET
ShiftJobs ENDP
END main


; -------------------------------------------------------------------- END OF PROGRAM