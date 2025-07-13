INCLUDE irvine32.inc

.data
ground BYTE "------------------------------------------------------------", 0

strScore BYTE "Your score: ", 0
score BYTE 0

strLives BYTE "Lives: ", 0
lives BYTE 3

strTimer BYTE "Steps left: ", 0
timer DWORD 99 ; Timer in ticks

xPos BYTE 20 ; Player starting position
yPos BYTE 20

xCoinPos BYTE ? ; Coin position
yCoinPos BYTE ?

xObsPos BYTE ? ; Obstacle position
yObsPos BYTE ?

inputChar BYTE ? ; User input
playerSymbol BYTE "X" ; Default player symbol

msg BYTE "GAME OVER", 0
msg2 BYTE "Choose your symbol: ", 0

.code
main PROC
    ; Let user choose the player symbol:
    call ChoosePlayerSymbol

    ; Draw ground:
    mov dl, 0
    mov dh, 29
    call Gotoxy
    mov edx, OFFSET ground
    call WriteString

    ; Initialize game state:
    call Randomize
    call CreateRandomCoin
    call DrawCoin
    call CreateRandomObstacle
    call DrawObstacle

gameLoop:
    ; Display score, lives, and timer:
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET strScore
    call WriteString
    mov eax, 0
    mov al, score
    call WriteInt
    call crlf

    mov edx, OFFSET strLives
    call WriteString
    mov al, lives
    call WriteInt
    call crlf

    mov edx, OFFSET strTimer
    call WriteString
    mov eax, timer
    call WriteInt
    call crlf

    ; Check for game over:
    cmp lives, 0
    je gameOver
    cmp timer, 0
    je gameOver

    ; Timer countdown:
    call Delay ; Simulate a second
    dec timer

    ; Check coin collection:
    call CheckCoinCollection

    ; Check obstacle collision:
    call CheckObstacleCollision

    ; Get user input:
    call ReadChar
    mov inputChar, al

    ; Exit if user types 'x':
    cmp inputChar, "x"
    je gameOver

    ; Handle player movement:
    cmp inputChar, "w"
    je moveUp
    cmp inputChar, "s"
    je moveDown
    cmp inputChar, "a"
    je moveLeft
    cmp inputChar, "d"
    je moveRight

    jmp gameLoop

moveUp:
    cmp yPos, 1 ; Prevent moving out of bounds
    jle moveUpEnd
    call UpdatePlayer
    dec yPos
    call DrawPlayer
moveUpEnd:
    jmp gameLoop

moveDown:
    cmp yPos, 28 ; Prevent moving out of bounds
    jge moveDownEnd
    call UpdatePlayer
    inc yPos
    call DrawPlayer
moveDownEnd:
    jmp gameLoop

moveLeft:
    cmp xPos, 1 ; Prevent moving out of bounds
    jle moveLeftEnd
    call UpdatePlayer
    dec xPos
    call DrawPlayer
moveLeftEnd:
    jmp gameLoop

moveRight:
    cmp xPos, 55 ; Prevent moving out of bounds
    jge moveRightEnd
    call UpdatePlayer
    inc xPos
    call DrawPlayer
moveRightEnd:
    jmp gameLoop

gameOver:
    ; Clear part of the screen for the "GAME OVER" message
    mov dl, 0
    mov dh, 10
    call Gotoxy
    mov ecx, 50 ; Clear 50 spaces
clearScreen:
    mov al, " "
    call WriteChar
    loop clearScreen
    call clrscr
    ; Display "GAME OVER" message
    mov dl, 10
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET msg
    call WriteString

    ; Pause for a few seconds before exiting
    mov ecx, 3
pauseLoop:
    call Delay ; Delay for 1 second
    loop pauseLoop

    ; Exit the program
    exit
main ENDP

; Function to choose player symbol:
ChoosePlayerSymbol PROC
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET msg2
    call WriteString
    call ReadChar
    ; Set playerSymbol to the user input character:
    mov playerSymbol, al
    ; Clear the line after symbol selection:
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov ecx, 50
clearLine:
    mov al, " "
    call WriteChar
    loop clearLine
    ret
ChoosePlayerSymbol ENDP

; Check if the player collects the coin:
CheckCoinCollection PROC
    mov al, xPos
    cmp al, xCoinPos
    jne notCollecting
    mov al, yPos
    cmp al, yCoinPos
    jne notCollecting

    ; Player collects coin:
    inc score
    call CreateRandomCoin
    call DrawCoin
notCollecting:
    ret
CheckCoinCollection ENDP

; Check if the player hits the obstacle:
CheckObstacleCollision PROC
    mov al, xPos
    cmp al, xObsPos
    jne noCollision
    mov al, yPos
    cmp al, yObsPos
    jne noCollision

    ; Player hits obstacle:
    dec lives
    call CreateRandomObstacle
    call DrawObstacle
noCollision:
    ret
CheckObstacleCollision ENDP

; Draw player at (xPos, yPos):
DrawPlayer PROC
    mov dl, xPos
    mov dh, yPos
    call Gotoxy
    mov al, playerSymbol
    call WriteChar
    ret
DrawPlayer ENDP

; Update player position:
UpdatePlayer PROC
    mov dl, xPos
    mov dh, yPos
    call Gotoxy
    mov al, " "
    call WriteChar
    ret
UpdatePlayer ENDP

; Draw coin at (xCoinPos, yCoinPos):
DrawCoin PROC
    mov eax, lightGreen
    call SetTextColor
    mov dl, xCoinPos
    mov dh, yCoinPos
    call Gotoxy
    mov al, "O"
    call WriteChar
    ret
DrawCoin ENDP

; Draw obstacle at (xObsPos, yObsPos):
DrawObstacle PROC
    mov eax, lightRed
    call SetTextColor
    mov dl, xObsPos
    mov dh, yObsPos
    call Gotoxy
    mov al, "#"
    call WriteChar
    ret
DrawObstacle ENDP

; Create random coin position:
CreateRandomCoin PROC
randomCoin:
    mov eax, 55
    call RandomRange
    mov xCoinPos, al
    mov eax, 27
    call RandomRange
    mov yCoinPos, al
    ; Ensure coin does not spawn on player:
    mov dl, xCoinPos
    cmp dl, xPos
    jne checkY
    mov dl, yCoinPos
    cmp dl, yPos
    jne checkY
    jmp randomCoin
checkY:
    ret
CreateRandomCoin ENDP

; Create random obstacle position:
CreateRandomObstacle PROC
randomObstacle:
    mov eax, 55
    call RandomRange
    mov xObsPos, al
    mov eax, 27
    call RandomRange
    mov yObsPos, al
    ; Ensure obstacle does not spawn on player or coin:
    mov dl, xObsPos
    cmp dl, xPos
    jne checkObsY
    mov dl, yObsPos
    cmp dl, yPos
    jne checkObsY
    mov dl, xObsPos
    cmp dl, xCoinPos
    jne checkObsY
    mov dl, yObsPos
    cmp dl, yCoinPos
    jne checkObsY
    jmp randomObstacle
checkObsY:
    ret
CreateRandomObstacle ENDP

END main