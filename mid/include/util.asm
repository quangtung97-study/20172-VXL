;-------------------------------
delay proc
    mov cx, 10000
delay_loop:      
    nop                 ; 3 cycles
    loop delay_loop     ; 17 cycles 
    ret
delay endp
;------------------------------- 

;-------------------------------
infinite_loop proc 
infinite_loop_begin:
    call delay
    jmp infinite_loop_begin     
    ret
infinite_loop endp
;-------------------------------