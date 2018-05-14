;-------------------------------
; void print_hex(short a);
print_hex proc  
    print_hex_a EQU 4 
    push bp
    mov bp, sp      
                
    mov bx, print_hex_a[bp]
    mov cx, 4     
print_hex_loop:   
    rol bx, 4
    mov dl, bl
    and dl, 0fh
    cmp dl, 9
    jg when_is_character ; dl <= 9
    add dl, '0'   
    jmp print_hex_endif
    
when_is_character: 
    sub dl, 10
    add dl, 'a'  
                
print_hex_endif: 
    mov ah, 0x2h
    int 21h
      
    loop print_hex_loop
    
    mov sp, bp
    pop bp
    ret
print_hex endp 
;--------------------------------

;--------------------------------
; void exit()
exit proc
    mov ah, 4Ch
    int 21h
    ret
exit endp
;--------------------------------