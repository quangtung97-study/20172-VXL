;-------------------------------
; (ax, bx) rotate_left(ax, bx, cx) 
rotate_left proc
    push bp
    mov bp, sp 
    sub sp, 10
    
    rl_ax equ -2
    rl_bx equ -4
    rl_cx equ -6
    rl_tmp equ -10
    
    mov rl_ax[bp], ax
    mov rl_bx[bp], bx
    mov rl_cx[bp], cx
    
    cmp cx, 16
    jg  rotate_left_inverse
    mov ax, bx 
    shl bx, cl
    neg cx
    add cx, 16
    shr ax, cl 
    mov rl_tmp[bp], ax
    mov rl_tmp+2[bp], bx
    
    mov ax, rl_ax[bp]
    mov bx, ax
    shr bx, cl
    neg cx
    add cx, 16
    shl ax, cl
    
    mov cx, rl_tmp[bp]
    mov dx, rl_tmp+2[bp]
    or ax, cx
    or bx, dx
    jmp rotate_left_end_if 
    
rotate_left_inverse:
    sub cx, 16
    mov ax, bx
    shl ax, cl
    neg cx
    add cx, 16
    shr bx, cl
    mov rl_tmp[bp], ax
    mov rl_tmp+2[bp], bx
    
    mov ax, rl_ax[bp]
    mov bx, ax
    shr ax, cl
    neg cx
    add cx, 16
    shl bx, cl
    
    mov cx, rl_tmp[bp]
    mov dx, rl_tmp+2[bp]
    or ax, cx
    or bx, dx
    
rotate_left_end_if:
    mov sp, bp
    pop bp
    ret
rotate_left endp
;-------------------------------