;-----------------------------------------
; void usart_pchar(
;           ch, cmd_addr, data_addr)
usart_pchar proc 
    push bp
    mov bp, sp
      
    usart_pchar_ch equ 4
    usart_pchar_cmd equ 6
    usart_pchar_data equ 8 
    
usart_pchar_wait_ready:  
    mov dx, usart_pchar_cmd[bp]
    in al, dx
    and al, 00000001b
    jz usart_pchar_wait_ready 
    
    mov ax, usart_pchar_ch[bp]
    mov dx, usart_pchar_data[bp]
    out dx, al
    
    mov sp, bp
    pop bp
    ret
usart_pchar endp
;-----------------------------------------

;-----------------------------------------
; void usart_pnumber(
;           n, cmd_addr, data_addr)  
usart_pnumber proc
    push bp
    mov bp, sp
    sub sp, 2
      
    usart_pnumber_n equ 4
    usart_pnumber_cmd equ 6
    usart_pnumber_data equ 8
    usart_pnumber_i equ -2
    
    xor ax, ax
    mov usart_pnumber_i[bp], ax
 
usart_pnumber_loop:
    cmp usart_pnumber_i[bp], 4
    jge usart_pnumber_loop_end
    
    mov bx, usart_pnumber_n[bp]
    rol bx, 4
    mov usart_pnumber_n[bp], bx
    
    mov dl, bl
    and dl, 0fh
    cmp dl, 9
    jg usart_pnumber_is_character
    
    add dl, '0'
    jmp usart_pnumber_end_if
    
usart_pnumber_is_character:
    sub dl, 10
    add dl, 'a'
    
usart_pnumber_end_if:
    push usart_pnumber_data[bp]
    push usart_pnumber_cmd[bp]
    push dx
    call usart_pchar
    add sp, 6    
    
    inc usart_pnumber_i[bp]
    jmp usart_pnumber_loop
usart_pnumber_loop_end:  
    
    mov sp, bp
    pop bp
    ret
usart_pnumber endp 
;-----------------------------------------  

;-----------------------------------------
; void usart_pstring(
;           ptr, n, cmd_addr, data_addr)
usart_pstring proc
    push bp
    mov bp, sp
    sub sp, 2
    
    usart_pstring_ptr equ 4
    usart_pstring_n equ 6
    usart_pstring_cmd equ 8
    usart_pstring_data equ 10
    usart_pstring_i equ -2  
                         
    xor ax, ax
    mov usart_pstring_i[bp], ax
    
usart_pstring_loop_begin:
    mov cx, usart_pstring_n[bp]
    cmp usart_pstring_i[bp], cx
    jge usart_pstring_loop_end
    
    mov dx, usart_pstring_ptr[bp]
    mov cx, usart_pstring_i[bp]
    add dx, cx
    mov di, dx  
         
usart_pstring_wait_ready:  
    mov dx, usart_pstring_cmd[bp]
    in al, dx
    and al, 00000001b
    jz usart_pstring_wait_ready 
    
    xor ax, ax
    mov al, [di]
    mov dx, usart_pstring_data[bp]
    out dx, al   
                       
    inc usart_pstring_i[bp]
    jmp usart_pstring_loop_begin                   
usart_pstring_loop_end:
              
    mov sp, bp
    pop bp
    ret
usart_pstring endp  
;-----------------------------------------

;-----------------------------------------
; char usart_read(cmd, data)
usart_read proc          
    push bp
    mov bp, sp   
    
    usart_read_cmd equ 4
    usart_read_data equ 6 
    
usart_read_loop:
    mov dx, usart_read_cmd[bp]
    in al, dx
    and al, 00000010b
    jz usart_read_loop
    
    xor ax, ax
    mov dx, usart_read_data[bp]
    in al, dx
    shr al, 1  
    
    mov sp, bp
    pop bp
    ret
usart_read endp
;-----------------------------------------