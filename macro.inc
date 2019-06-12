printstr macro string
	mov dx, offset string
	mov ah,9
	int 21h
endm

clrscr macro
	mov ah, 0
	mov al, 3
	int 10h
endm

readstr macro limit
    mov ah, 0ah 
    mov dx, offset limit
    int 21h
endm