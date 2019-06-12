;author: Igor Veres
.model small
.stack 100h
.data
EXTRN FHANDLE:word
RBUFFER DB 255 dup(?)
SREPLACEMAXLEN DB 63
SREPLACELEN DB ?
SREPLACE DB 63 dup('$')
SWITHREPLACEMAXLEN DB 63
SWITHREPLACELEN DB ?
SWITHREPLACE DB 63 dup('$')
REPLACEMSG DB 0ah, 'Enter string to be replaced: $', 0ah
REPLACEWITHMSG DB 0ah, 'Enter string to be replaced with: $', 0ah
CHARSNUM DB 0
LINESNUM DB 0
.code
INCLUDE macro.inc
PUBLIC replacestrings
replacestrings proc
start:
		mov AX, @data
        mov DS, AX   
		mov es, ax
		printstr REPLACEMSG
		readstr SREPLACEMAXLEN
		printstr REPLACEWITHMSG
		readstr SWITHREPLACEMAXLEN
	
		mov charsnum, 0
		mov linesnum, 0
		
		mov si, offset SWITHREPLACELEN
		mov ah,0
		mov al,[si]
		add si,ax
		inc si
		mov byte ptr[si],'$';buffered input reads carriage return so we need to delete it 
		
		clrscr
fillbuff:		
		mov ah, 3fh
		mov bx, fhandle
		mov cx, 64
		mov dx, offset RBUFFER
		int 21h
		cmp ax, 0
		jz finish ;if at the end of file - no data was laoded
		
		mov si, offset RBUFFER ; save starting postion of buffer into si
		mov di, si ; copy the starting position to di
		add di, ax ; add ax to di - ax still contains the number of characters laoded by 3fh function, therefore di now contains ending position of buffer
printbuff:
		cmp si, di ; if si(current postion in buffer) equals to di(ending buffer pos) we are at the end of buffer, need to fillbuff
		jz fillbuff
		push di
		push si
		;cld                     ;Scan in the forward direction
        mov cl, SREPLACELEN ;Scanning sreplacelen bytes (CX is used by REPE)
		mov ch, 0
        ;mov     si, buffer1     ;Starting address of first buffer
        mov di, offset SREPLACE ;Starting address of second buffer
        repe cmpsb ;...and compare it.
        jne mismatch ;The Zero Flag will be cleared if there is a mismatch
match:  ;If we get here, buffers match
        pop si
		pop di
		printstr SWITHREPLACE
		mov al, SREPLACELEN
		mov ah, 0
		add si, ax ; need to jump ahead by the lenght of string we replaced
		jmp printbuff
mismatch:
		pop si
		pop di
		mov ah,2
		mov dl,[si]
		int 21h
		inc si ; print whatever is currently in si and then set si to next character
		inc charsnum
		cmp charsnum, 80
		jz linefull
		cmp byte ptr[si],10
		jz linefull
		cmp LINESNUM, 22
		jz waitoprint
		
		jmp printbuff
waitoprint: 
		mov LINESNUM, 0
		mov ah, 7
		int 21h
		jmp printbuff
linefull:
		inc LINESNUM
		mov charsnum, 0
		jmp printbuff
finish:
		ret
endp
end