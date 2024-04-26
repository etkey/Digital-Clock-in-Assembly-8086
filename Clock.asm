include 'emu8086.inc'
ORG 100h

.DATA
 HOUR        DW 0
 MINUTE      DW 0
 SECOND      DW 0
 ALARM_HOUR  DW ?
 ALARM_MIN   DW ?
 ALARM_SEC   DW ?

 msg         DB  'Enter the alarm hour (0-23): ', 0
 msg2        DB  'Enter the alarm minute (0-59): ', 0
 msg3        DB  'Enter the alarm seconds (0-59): ', 0
 alarm_msg   DB  'Alarm!', 0

.CODE

    MOV AX, @DATA
    MOV DS, AX

    ; Initialize time variables to 00:00:00
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0

    ; Prompt user to set alarm
    LEA SI, msg
    CALL PRINT_STRING 
    CALL SCAN_NUM
    MOV ALARM_HOUR, CX

    LEA SI, msg2
    CALL PRINT_STRING
    CALL SCAN_NUM
    MOV ALARM_MIN, CX

    LEA SI, msg3
    CALL PRINT_STRING
    CALL SCAN_NUM
    MOV ALARM_SEC, CX
    
    
usec:
    ; print hour
    GOTOXY 2, 21
    MOV AX, HOUR
    CALL PRINT_NUM

    ; symbol
    GOTOXY 5, 21
    mov dl,':'
    mov ah,2
    int 21h

    ; print minute
    GOTOXY 8, 21
    MOV AX, MINUTE
    CALL PRINT_NUM

    ; symbol
    GOTOXY 11, 21
    mov dl,':'
    mov ah,2
    int 21h

    ; print seconds
    GOTOXY 14, 21
    MOV AX, SECOND
    CALL PRINT_NUM

    ; Check if alarm is set and if current time matches alarm time 
    CALL check_alarm
 
mainc:
 
    ; Delay for 1 second
    MOV     CX, 0FH
    MOV     DX, 4240H
    MOV     AH, 86H
    INT     15H
    
    ; Check for inputs    
    MOV AH, 01h
    INT 16h
    JZ increment_time  ; Jump if no key pressed 
    mov ah, 00
    int 16h
    CMP AL, 61h
    JE increment_hour
    CMP AL, 73h
    JE decrement_hour
    CMP AL, 64h
    JE increment_minute
    CMP AL, 66h
    JE decrement_minute 

;increment the hour if input is 'a'
increment_hour:
    INC HOUR
    CMP HOUR, 24
    JNE increment_time
    MOV HOUR, 0 

; decrement the hour if input is 's'    
decrement_hour:
    DEC HOUR
    CMP HOUR, 0
    JNS increment_time   ; Jump if the sign flag is not set (i.e., HOUR is not negative)
    MOV HOUR, 23         ; Wrap around to 23 if HOUR is negative

; increment the minute if input is 'd'    
increment_minute:
    INC MINUTE
    CMP MINUTE, 60
    JNE increment_time
    MOV MINUTE, 0 

; decrement the minute if input is 'f'    
decrement_MINUTE:
    DEC MINUTE
    CMP MINUTE, 0
    JNS increment_time
    MOV MINUTE, 59

increment_time:
    
    ;; Increment seconds and handle overflow
    ADD SECOND, 1
    CMP SECOND, 60
    JL  usec   ; Jump back if seconds < 60
    MOV SECOND, 0
    ;; Increment minutes and handle overflow
    ADD MINUTE, 1
    CMP MINUTE, 60
    JL  usec   ; Jump back if minutes < 60
    MOV MINUTE, 0
    ;; Increment hours and handle overflow
    ADD HOUR, 1
    CMP HOUR, 24
    JL  usec   ; Jump back if hours < 24
    MOV HOUR, 0

    JMP usec

check_alarm:

    ; Check if the hour matches with the alarm hour
    MOV AX, ALARM_HOUR
    CMP AX, HOUR
    JNE not_alarm_time
    
    ; Check if the minute matches with the alarm minute
    MOV AX,ALARM_MIN
    CMP AX, MINUTE
    JNE not_alarm_time
    
    ; Check if the second matches with the alarm second 
    MOV AX, ALARM_SEC
    CMP AX, SECOND
    JNE not_alarm_time



    ; Print alarm message in a new window to visually warn the user 
    mov al, 0h
	mov ah, 0
	int 10h
    LEA SI, alarm_msg
    CALL PRINT_STRING


not_alarm_time:
    ; Continue by jumping to the increment if the time doesn't match with the alarm
    JMP mainc

DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_PTHIS

END