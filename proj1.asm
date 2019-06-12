;author: Igor Veres
.model small
.stack 100h
.data
;-----------------
MENU	DB 0ah, 'Input number of option', 0ah
		DB '1: Set file name ', 0ah
		DB '2: Open file ', 0ah
		DB '3: Replace strings', 0ah
		DB '4: Quit',0ah,'$'
;-----------------
OPTERRMSG  DB 0ah, 'Invalid option',0ah,'$'
FINPUTMSG DB 'Input file name: ', 0ah, '$'
CURRFMSG DB 0ah, 'Current selected file is: $'
FOPENERR DB 0ah, 'ERROR: Could not open file$', 0ah
INVOPMSG DB 0ah, 'No file specified or file cannot be opened, please run option 1$', 0ah
FNAMEMAXLENGHT DB 63
FLENGTH   DB ?
FNAME     DB 63 dup('$');initialze to empty string so it doesnt print rubbish at first menu display
FHANDLE DW 65535 ; set to max word(16b) value so that we can test if the handle was set by opening a file
RBUFFER DB 64 dup(?)
CHARSNUM DB 0
LINESNUM DB 0
PUBLIC FHANDLE
.code
include macro.inc
EXTRN replacestrings:near
start:
		mov AX, @data
        mov DS, AX   
home:
		printstr CURRFMSG
		printstr FNAME
		printstr MENU
		mov ah, 1
		int 21h
		cmp al, '1'
		je opt1
		cmp al, '2'
		je opt2
		cmp al, '3'
		je opt3
		cmp al, '4'
		je opt4j
		jmp opterr ; if read character isnt 1-4 go to error
opt4j:
		jmp opt4
opt1:
		clrscr
		printstr FINPUTMSG
		readstr FNAMEMAXLENGHT
		mov si, offset fname
		mov ah, 0
		mov al, FLENGTH
		add si, ax
		mov byte ptr[si], 0
		inc si
		mov byte ptr[si], '$'; add 0 and $ characters at the end of read string
		
		mov ah, 3dh
		mov al, 0
		mov dx, offset fname
		int 21h
		jc ferr
		mov fhandle, ax ;attempt to open file if succesfull, save handle else print error msg
		clrscr
		jmp home
	
opt2:
		cmp fhandle, 65535
		jz invopt
		
		mov ah, 42h
		mov bx, fhandle
		mov cx, 0
		mov dx, 0
		mov al, 0
		int 21h ;reset file pointer to the start of file
		
		mov charsnum, 0
		mov linesnum, 0
		
		clrscr
fillbuff:		
		mov ah, 3fh
		mov bx, fhandle
		mov cx, 64
		mov dx, offset RBUFFER
		int 21h
		cmp ax, 0
		jz done ;if at the end of file - no data was laoded
		
		mov si, offset RBUFFER ; save starting postion of buffer into si
		mov di, si ; copy the starting position to di
		add di, ax ; add ax to di - ax still contains the number of characters laoded by 3fh function, therefore di now contains ending position of buffer
printbuff:
		cmp si, di ; if si(current postion in buffer) equals to di(ending buffer pos) we are at the end of buffer, need to fillbuff
		jz fillbuff
		
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
opt3:
		cmp fhandle, 65535
		jz invopt
		mov ah, 42h
		mov bx, fhandle
		mov cx, 0
		mov dx, 0
		mov al, 0
		int 21h ;reset file pointer to the start of file
		call replacestrings
		jmp done
opt4:
		mov ax, 4c00h
		int 21h		
opterr:
		clrscr
		printstr OPTERRMSG
		jmp home
ferr:
		printstr FOPENERR
		mov ah, 1
		int 21h
		jmp home
done:
		mov ah, 7
		int 21h
		clrscr
		jmp home
invopt:
		printstr INVOPMSG
		mov ah, 7
		int 21h
		jmp home
end start