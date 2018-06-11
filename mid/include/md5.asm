;-----------------------------------------
; void md5(input[64], length, 
;  binary_output[16], output[32], T0, S0)
md5 proc 
    push bp
    mov bp, sp
    sub sp, 48 
    
    md5_input equ 4    
    md5_length equ 6
    md5_binary_output equ 8 
    md5_output equ 10
    md5_T0 equ 12
    md5_S0 equ 14
    
    md5_a equ -4
    md5_b equ -8
    md5_c equ -12
    md5_d equ -16
    
    md5_aa equ -20
    md5_bb equ -24
    md5_cc equ -28
    md5_dd equ -32
        
    md5_F equ -36
    md5_g equ -40  
    md5_i equ -42
    md5_tmp equ -46
    md5_s equ -48     
    
    ; clear remain bytes                   
    mov ax, md5_length[bp]
    mov md5_i[bp], ax
md5_clear_loop:    
    cmp md5_i[bp], 64
    jge md5_clear_loop_end
    
    mov ax, md5_i[bp]
    mov di, md5_input[bp]
    add di, ax
    mov [di], 0  
        
    inc md5_i[bp], 1
    jmp md5_clear_loop     
md5_clear_loop_end:
    
    ; append 10000000...
    mov di, md5_input[bp] 
    add di, md5_length[bp]
    mov [di], 0x80  
                         
    ; length in bits
    mov di, md5_input[bp]
    mov ax, md5_length[bp]
    shl ax, 3
    mov 56[di], ax  
    
    
    mov md5_a[bp], 2301h
    mov md5_a+2[bp], 6745h
    mov md5_b[bp], 0ab89h
    mov md5_b+2[bp], 0efcdh
    mov md5_c[bp], 0dcfeh
    mov md5_c+2[bp], 98bah
    mov md5_d[bp], 5476h
    mov md5_d+2[bp], 1032h
    
    mov md5_aa[bp], 2301h
    mov md5_aa+2[bp], 6745h
    mov md5_bb[bp], 0ab89h
    mov md5_bb+2[bp], 0efcdh
    mov md5_cc[bp], 0dcfeh
    mov md5_cc+2[bp], 98bah
    mov md5_dd[bp], 5476h
    mov md5_dd+2[bp], 1032h
    
    xor ax, ax
    mov md5_i[bp], ax              ; i = 0
md5_begin_for:   
    cmp md5_i[bp], 64              ; i < 64
    jge md5_end_for

    cmp md5_i[bp], 16              ; i < 16
    jge md5_else1
              
    ; F = b & c
    mov ax, md5_b[bp]
    mov bx, md5_b+2[bp]
    mov cx, md5_c[bp]
    mov dx, md5_c+2[bp]
    and ax, cx
    and bx, dx
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx 
                        
    ; (ax, bx) = ~b & d
    mov ax, md5_b[bp]
    mov bx, md5_b+2[bp]
    mov cx, md5_d[bp]
    mov dx, md5_d+2[bp]
    
    not ax
    not bx
    and ax, cx
    and bx, dx 
    
    ; F = (b & c) | (~b & d)
    mov cx, md5_F[bp]
    mov dx, md5_F+2[bp]
    or ax, cx
    or bx, dx
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx 
                      
    ; g = i      
    mov ax, md5_i[bp]
    mov md5_g[bp], ax 
           
    jmp md5_end_if
md5_else1:          
    cmp md5_i[bp], 32
    jge md5_else2                  ; i < 32
                
    ; F = d & b
    mov ax, md5_d[bp]
    mov bx, md5_d+2[bp]
    mov cx, md5_b[bp]
    mov dx, md5_b+2[bp]
    and ax, cx
    and bx, dx
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx 
    
    ; (ax, bx) = ~d & c
    mov ax, md5_d[bp]
    mov bx, md5_d+2[bp]
    mov cx, md5_c[bp]
    mov dx, md5_c+2[bp]
    
    not ax
    not bx
    and ax, cx
    and bx, dx  
    
    ; F = (d & b) | (~d & c)
    mov cx, md5_F[bp]
    mov dx, md5_F+2[bp]
    or ax, cx
    or bx, dx
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx
    
    ; g = (5 * i + 1) % 16
    mov ax, md5_i[bp]
    mov bl, 5
    mul bl
    add ax, 1 
    mov dx, 0
    mov bx, 16
    div bx         
    mov md5_g[bp], dx 
            
    jmp md5_end_if
md5_else2:
    cmp md5_i[bp], 48
    jge md5_else_final             ; i < 48
    
    ; (ax, bx) = B ^ C
    mov ax, md5_b[bp]
    mov bx, md5_b+2[bp]
    mov cx, md5_c[bp]
    mov dx, md5_c+2[bp]
    xor ax, cx
    xor bx, dx
    
    ; (ax, bx) = (ax, bx) ^ D
    mov cx, md5_d[bp]
    mov dx, md5_d+2[bp]
    xor ax, cx
    xor bx, dx
    
    ; F = (ax, bx)
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx
    
    ; g = (3 * i + 5) % 16
    mov ax, md5_i[bp]
    mov bl, 3
    mul bl
    add ax, 5 
    mov dx, 0
    mov bx, 16
    div bx         
    mov md5_g[bp], dx
           
    jmp md5_end_if
md5_else_final:
    ; (ax, bx) = b | ~d
    mov ax, md5_b[bp]
    mov bx, md5_b+2[bp]
    mov cx, md5_d[bp]
    mov dx, md5_d+2[bp]
    not cx
    not dx
    or ax, cx
    or bx, dx
    
    ; (ax, bx) = (ax, bx) ^ C
    mov cx, md5_c[bp]
    mov dx, md5_c+2[bp] 
    xor ax, cx
    xor bx, dx
    
    ; F = (ax, bx)  
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx
               
    ; g = (7*i) % 16
    mov ax, md5_i[bp]
    mov bl, 7
    mul bl 
    mov dx, 0
    mov bx, 16
    div bx         
    mov md5_g[bp], dx
            
md5_end_if: 
    ; (ax, bx) = F + A
    mov ax, md5_F[bp]
    mov bx, md5_F+2[bp]
    mov cx, md5_a[bp]
    mov dx, md5_a+2[bp]
    add ax, cx
    adc bx, dx 
    
    ; (ax, bx) = (ax, bx) + input[g]
    mov cx, md5_input[bp]
    mov dx, md5_g[bp]
    shl dx, 2
    add cx, dx
    mov di, cx
    mov cx, [di]
    mov dx, 2[di]
    
    add ax, cx
    adc bx, dx
    
    ; (ax, bx) = (ax, bx) + T1[i]
    mov cx, md5_T0[bp]
    mov dx, md5_i[bp]
    shl dx, 2
    add cx, dx
    mov di, cx
    mov cx, [di]
    mov dx, 2[di]
    
    add ax, cx
    adc bx, dx
    
    ; F = (ax, bx)
    mov md5_F[bp], ax
    mov md5_F+2[bp], bx 
    
    ; A = D
    mov ax, md5_d[bp]
    mov bx, md5_d+2[bp]
    mov md5_a[bp], ax
    mov md5_a+2[bp], bx 
    
    ; D = C
    mov ax, md5_c[bp]
    mov bx, md5_c+2[bp]
    mov md5_d[bp], ax
    mov md5_d+2[bp], bx 
    
    ; C = B
    mov ax, md5_b[bp]
    mov bx, md5_b+2[bp]
    mov md5_c[bp], ax
    mov md5_c+2[bp], bx
    
    ; s = s0[(i / 16) * 4 + i % 4] 
    mov cx, md5_s0[bp]
    mov ax, md5_i[bp]
    mov dx, 0
    mov bx, 16
    div bx         ; ax = i / 16
    mov bl, 4
    mul bl         ; ax = al * 4 
    mov md5_tmp[bp], ax    ; tmp = ax
    mov ax, md5_i[bp]
    mov dx, 0
    mov bx, 4
    div bx          ; dx = i % 4
    
    mov ax, md5_tmp[bp]
    add ax, dx      ; ax = (i/16) * 4 + i%4
    add cx, ax
    mov di, cx 
    
    xor ax, ax       
    mov al, [di]
    mov md5_s[bp], ax      ; store s
    
    mov ax, md5_F[bp]
    mov bx, md5_F+2[bp]
    mov cx, md5_s[bp]
    
    call rotate_left
    
    ; B += (ax, bx)
    add md5_b[bp], ax
    adc md5_b+2[bp], bx 
    
    inc md5_i[bp]      ; i++   
    jmp md5_begin_for
md5_end_for: 

    ; A += AA         
    mov ax, md5_aa[bp]
    mov bx, md5_aa+2[bp
    add md5_a[bp], ax
    adc md5_a+2[bp], bx
    
    ; B += BB         
    mov ax, md5_bb[bp]
    mov bx, md5_bb+2[bp
    add md5_b[bp], ax
    adc md5_b+2[bp], bx
    
    ; C += CC         
    mov ax, md5_cc[bp]
    mov bx, md5_cc+2[bp
    add md5_c[bp], ax
    adc md5_c+2[bp], bx
    
    ; D += DD         
    mov ax, md5_dd[bp]
    mov bx, md5_dd+2[bp
    add md5_d[bp], ax
    adc md5_d+2[bp], bx
    
    ;-----------------------
    
    mov di, md5_binary_output[bp]
       
    mov ax, md5_a[bp]
    mov 0[di], ax  
    
    mov ax, md5_a+2[bp]
    mov 2[di], ax
    
    mov ax, md5_b[bp]
    mov 4[di], ax
    
    mov ax, md5_b+2[bp]
    mov 6[di], ax
    
    mov ax, md5_c[bp]
    mov 8[di], ax
    
    mov ax, md5_c+2[bp]
    mov 10[di], ax
    
    mov ax, md5_d[bp]
    mov 12[di], ax
    
    mov ax, md5_d+2[bp]
    mov 14[di], ax 
    
    ;-----------------------
           
    mov ax, md5_output[bp]
    push ax       
    mov ax, md5_binary_output[bp]
    push ax
    call compute_output
    add sp, 4
    
    mov sp, bp
    pop bp
    ret
md5 endp    
;---------------------------------------

;-------------------------------
; void compute_output(binary_output, output)
compute_output proc 
    push bp
    mov bp, sp
    sub sp, -4
                
    co_binary_output equ 4
    co_output equ 6
    co_i equ -2
    co_j equ -4
        
    xor ax, ax 
    mov co_i[bp], ax
     
co_loop:  
    mov cx, co_i[bp]
    cmp cx, 16
    jge co_end_loop
                        
    mov dx, co_binary_output[bp]
    add dx, cx
    mov di, dx
     
    mov al, [di]
    shl dl, 1
    
    ror al, 4
    mov bl, al
    and bl, 0fh
    cmp bl, 9
    jg co_case_character1 
    add bl, '0'
    
    mov dx, co_output[bp]
    add dx, cx
    add dx, cx
    mov di, dx
    mov [di], bl
    jmp co_endif1
co_case_character1:
    sub bl, 10      
    add bl, 'a' 
    
    mov dx, co_output[bp]
    add dx, cx
    add dx, cx
    mov di, dx
    mov [di], bl
co_endif1:

    ror al, 4
    mov bl, al
    and bl, 0fh
    cmp bl, 9
    jg co_case_character2 
    add bl, '0'
    
    mov dx, co_output[bp]
    add dx, cx
    add dx, cx 
    add dx, 1
    mov di, dx
    mov [di], bl
    jmp co_endif2
    
co_case_character2:
    sub bl, 10      
    add bl, 'a'
    
    mov dx, co_output[bp]
    add dx, cx
    add dx, cx 
    add dx, 1
    mov di, dx
    mov [di], bl
co_endif2:
    
    inc co_i[bp]
    jmp co_loop
co_end_loop:   
    mov sp, bp 
    pop bp
    ret
compute_output endp            
;-------------------------------