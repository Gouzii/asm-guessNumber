org 0x0100

setRandomNb:
    xor eax,eax
    rdtsc
    shr ax,1
    and ax, 0b11111111
    mov [mysteryNb],ax
    mov bx,1
    mov di,output
    call intToStr
    mov si,output
    call displayStr
    mov si,return
    call displayStr

startGame:
    mov si,start
    call displayStr
gameloop:
    mov di, userInput
    call readStr
    ;call strToInt
e:
    ret

;** Functions
    ;** Random
    ; Generate random number between 0 255
    ; Outpout in DI's address
    random:
        push ax
        push bx
        push cx
        push dx
        mov ah, 0x00
        int 0x1A
        mov word[di],dx
        randEnd:
            pop dx
            pop cx
            pop bx
            pop ax
            ret
    ;** intToStr
    ;  write in string adressed by DI the number in AX
    ; if BL = 1, write a final char
    ; BH contains the minimal number of chars to use
    intToStr:
        push cx
        push dx
        push bx
        mov bx, 10
        mov cx, 1
        xor dx,dx
        saveDigit:
            div bx
            push dx
            inc cx
            xor dx,dx
            or ax,ax
            jne saveDigit

            inc bh
        addZero:
            cmp bh,cl
            jbe digitLoop
            push 0
            inc cx
            jmp addZero
        digitLoop:
            dec bh
            loop displayDigit
            pop bx
            test bl, 0b1
            jz depile
            mov byte[di],0
        depile:
            pop dx
            pop cx
            ret
        displayDigit:
            pop ax
            add ax,'0'
            stosb
            jmp digitLoop
    ;** End IntToStr

    ;** strToInt
    ; strToInt:
    ;     push cx
    ;     push dx
    ;     push bx
    ;     mov bx, 10
    ;     mov cx, 1
    ;     xor dx,dx
    ;     saveDigit:
    ;         div bx
    ;         push dx
    ;         inc cx
    ;         xor dx,dx
    ;         or ax,ax
    ;         jne saveDigit
    ;
    ;         inc bh
    ;     addZero:
    ;         cmp bh,cl
    ;         jbe digitLoop
    ;         push 0
    ;         inc cx
    ;         jmp addZero
    ;     digitLoop:
    ;         dec bh
    ;         loop displayDigit
    ;         pop bx
    ;         test bl, 0b1
    ;         jz depile
    ;         mov byte[di],0
    ;     depile:
    ;         pop dx
    ;         pop cx
    ;         ret
    ;     displayDigit:
    ;         pop ax
    ;         add ax,'0'
    ;         stosb
    ;         jmp digitLoop


    ;** Print DX
    printStr:
        mov ah, 0x09
        int 0x21
        ret
    ;** End printStr

    ;** displayStr
    ; display char by char SI
    ; New line every 80chars
    ; End char : 0
    displayStr:
        push ax
        push bx
        push cx
        push dx
        xor bh,bh
        mov ah,0x03
        int 0x10
        mov cx,1
        newChar:
            lodsb
            or al,al
            jz eNewChar
            cmp al, 13
            je newLine
            mov ah,0x0A
            int 0x10
            inc dl
            cmp dl, 80 ; new line every 80chars
            je newLine
        placeCursor:
            mov ah,0x02
            int 0x10
            jmp newChar
        eNewChar:
            pop dx
            pop cx
            pop bx
            pop ax
            ret
        newLine:
            inc dh
            xor dl,dl
            jmp placeCursor
    ;** End displayStr

    ;** readStr
    ; Return user input in SI's adress
    readStr:
            push ax
            push cx
            push dx
            mov ah,0x03
            int 0x10
            mov cx,1
        waitKb:
            mov ah,0x01
            int 0x16
            jz waitKb
            xor ah,ah
            int 0x16
            stosb
            cmp al, 13
            je eWaitKb

            mov ah,0x0A
            int 0x10
            inc dl
            mov ah,0x02
            int 0x10
            jmp waitKb

        eWaitKb:
            inc dh
            xor dl,dl
            mov ah,0x02
            int 0x10
            mov byte [di],0
            pop dx
            pop cx
            pop ax
            ret
    ;** End readStr

    ;------------------NAV DISPLAYS FUNCTIONS--------------------

    ;Display Menu

mysteryNb : dw 0x00
countMoves : dw 0x00

start : db "The mystery number has been defined between 0 and 255",13,"What is your first proposition ?",13,0
more : db "The number is higher",13,0
less : db "The number is lower",13,0

output : db "",13,0
userInput : db "",13,0
return : db 13,0
