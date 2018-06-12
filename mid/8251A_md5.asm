; multi-segment executable file template.
name "md5"

data segment   
    T0  DW 0a478h, 0d76ah
    T1  DW 0b756h, 0e8c7h
    T2  DW 070dbh, 02420h
    T3  DW 0ceeeh, 0c1bdh
    T4  DW 00fafh, 0f57ch
    T5  DW 0c62ah, 04787h
    T6  DW 04613h, 0a830h
    T7  DW 09501h, 0fd46h
    T8  DW 098d8h, 06980h
    T9  DW 0f7afh, 08b44h
    T10 DW 05bb1h, 0ffffh
    T11 DW 0d7beh, 0895ch
    T12 DW 01122h, 06b90h
    T13 DW 07193h, 0fd98h
    T14 DW 0438eh, 0a679h
    T15 DW 00821h, 049b4h
    T16 DW 02562h, 0f61eh
    T17 DW 0b340h, 0c040h
    T18 DW 05a51h, 0265eh
    T19 DW 0c7aah, 0e9b6h
    T20 DW 0105dh, 0d62fh
    T21 DW 01453h, 0244h
    T22 DW 0e681h, 0d8a1h
    T23 DW 0fbc8h, 0e7d3h
    T24 DW 0cde6h, 021e1h
    T25 DW 007d6h, 0c337h
    T26 DW 00d87h, 0f4d5h
    T27 DW 014edh, 0455ah
    T28 DW 0e905h, 0a9e3h
    T29 DW 0a3f8h, 0fcefh
    T30 DW 002d9h, 0676fh
    T31 DW 04c8ah, 08d2ah
    T32 DW 03942h, 0fffah
    T33 DW 0f681h, 08771h
    T34 DW 06122h, 06d9dh
    T35 DW 0380ch, 0fde5h
    T36 DW 0ea44h, 0a4beh
    T37 DW 0cfa9h, 04bdeh
    T38 DW 04b60h, 0f6bbh
    T39 DW 0bc70h, 0bebfh
    T40 DW 07ec6h, 0289bh
    T41 DW 027fah, 0eaa1h
    T42 DW 03085h, 0d4efh
    T43 DW 01d05h, 00488h
    T44 DW 0d039h, 0d9d4h
    T45 DW 099e5h, 0e6dbh
    T46 DW 07cf8h, 01fa2h
    T47 DW 05665h, 0c4ach
    T48 DW 02244h, 0f429h
    T49 DW 0ff97h, 0432ah
    T50 DW 023a7h, 0ab94h
    T51 DW 0a039h, 0fc93h
    T52 DW 059c3h, 0655bh
    T53 DW 0cc92h, 08f0ch
    T54 DW 0f47dh, 0ffefh
    T55 DW 05dd1h, 08584h
    T56 DW 07e4fh, 06fa8h
    T57 DW 0e6e0h, 0fe2ch
    T58 DW 04314h, 0a301h
    T59 DW 011a1h, 04e08h
    T60 DW 07e82h, 0f753h
    T61 DW 0f235h, 0bd3ah
    T62 DW 0d2bbh, 02ad7h
    T63 DW 0d391h, 0eb86h 
    
    S0 DB 7, 12, 17, 22
    S1 DB 5, 9, 14, 20,
    S2 DB 4, 11, 16, 23
    S3 DB 6, 10, 15, 21
    
    
    usart_cmd  equ 002h
    usart_data equ 000h
        
    input DB 64 dup(0)  
    binary_output DB 16 dup(?)
    output DB 33 dup(?)    
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    ; set segment registers: 
    mov ax, data
    mov ds, ax
    mov es, ax    
    
    push bp
    mov bp, sp 
    sub sp, 2
    
    start_length equ -2  
   
    call init_uart 
   
main_repeat: 
    xor ax, ax
    mov start_length[bp], ax    ; length = 0
    
main_loop_read: 
    ; read character   
    push usart_data
    push usart_cmd    
    call usart_read
    add sp, 4      
    
    cmp al, 13
    je main_loop_read_end   
    
    cmp al, 7fh      ;  delete
    jne main_loop_read_end_if
    dec start_length[bp]
    
    jmp main_loop_read_print
    
main_loop_read_end_if:
               
    ; copy value to input array
    lea dx, input
    mov cx, start_length[bp]
    add dx, cx
    mov di, dx
    mov [di], al   
    
    ; length++
    inc start_length[bp]   
    
main_loop_read_print:
                    
    ; print that character
    push usart_data
    push usart_cmd
    push ax
    call usart_pchar
    add sp, 6
    
    jmp main_loop_read
main_loop_read_end:        
     
    ; print carriage return
    push usart_data
    push usart_cmd
    push 13
    call usart_pchar
    add sp, 6 
      
    ; print newline
    push usart_data
    push usart_cmd
    push 10
    call usart_pchar
    add sp, 6  
          
    ; md5(input, length, binary_output, output) 
    lea ax, output
    push ax      
    lea ax, binary_output
    push ax
    mov ax, start_length[bp]
    push ax
    lea ax, input
    push ax
    call md5
    add sp, 8
    
    push usart_data
    push usart_cmd                      
    push 32    
    lea ax, output
    push ax
    call usart_pstring
    add sp, 8   
    
    ; print carriage return
    push usart_data
    push usart_cmd
    push 13
    call usart_pchar
    add sp, 6 
    
    ; print newline
    push usart_data
    push usart_cmd
    push 10
    call usart_pchar
    add sp, 6
    
    jmp main_repeat
       
    mov sp, bp
    pop bp
    ret             
ends 

init_uart proc
    mov al, 01001101b; 
    out usart_cmd, al;
    mov al, 00000111b;
    out usart_cmd, al; 
    ret    
init_uart endp
         
include "include/util.asm"
include "include/usart.asm"
include "include/rotate.asm"
include "include/md5.asm" 

end start 