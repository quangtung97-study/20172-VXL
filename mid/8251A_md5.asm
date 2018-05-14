; multi-segment executable file template.
name "md5"

data segment
    ; add your data here!
    usart_cmd  equ 002h
    usart_data equ 000h
    
    T1  DW 0a478h, 0d76ah
    T2  DW 0b756h, 0e8c7h
    T3  DW 070dbh, 02420h
    T4  DW 0ceeeh, 0c1bdh
    T5  DW 00fafh, 0f57ch
    T6  DW 0c62ah, 04787h
    T7  DW 04613h, 0a830h
    T8  DW 09501h, 0fd46h
    T9  DW 098d8h, 06980h
    T10 DW 0f7afh, 08b44h
    T11 DW 05bb1h, 0ffffh
    T12 DW 0d7beh, 0895ch
    T13 DW 01122h, 06b90h
    T14 DW 07193h, 0fd98h
    T15 DW 0438eh, 0a679h
    T16 DW 00821h, 049b4h
    T17 DW 02562h, 0f61eh
    T18 DW 0b340h, 0c040h
    T19 DW 05a51h, 0265eh
    T20 DW 0c7aah, 0e9b6h
    T21 DW 0105dh, 0d62fh
    T22 DW 01453h, 0244h
    T23 DW 0e681h, 0d8a1h
    T24 DW 0fbc8h, 0e7d3h
    T25 DW 0cde6h, 021e1h
    T26 DW 007d6h, 0c337h
    T27 DW 00d87h, 0f4d5h
    T28 DW 014edh, 0455ah
    T29 DW 0e905h, 0a9e3h
    T30 DW 0a3f8h, 0fcefh
    T31 DW 002d9h, 0676fh
    T32 DW 04c8ah, 08d2ah
    T33 DW 03942h, 0fffah
    T34 DW 0f681h, 08771h
    T35 DW 06122h, 06d9dh
    T36 DW 0380ch, 0fde5h
    T37 DW 0ea44h, 0a4beh
    T38 DW 0cfa9h, 04bdeh
    T39 DW 04b60h, 0f6bbh
    T40 DW 0bc70h, 0bebfh
    T41 DW 07ec6h, 0289bh
    T42 DW 027fah, 0eaa1h
    T43 DW 03085h, 0d4efh
    T44 DW 01d05h, 00488h
    T45 DW 0d039h, 0d9d4h
    T46 DW 099e5h, 0e6dbh
    T47 DW 07cf8h, 01fa2h
    T48 DW 05665h, 0c4ach
    T49 DW 02244h, 0f429h
    T50 DW 0ff97h, 0432ah
    T51 DW 023a7h, 0ab94h
    T52 DW 0a039h, 0fc93h
    T53 DW 059c3h, 0655bh
    T54 DW 0cc92h, 08f0ch
    T55 DW 0f47dh, 0ffefh
    T56 DW 05dd1h, 08584h
    T57 DW 07e4fh, 06fa8h
    T58 DW 0e6e0h, 0fe2ch
    T59 DW 04314h, 0a301h
    T60 DW 011a1h, 04e08h
    T61 DW 07e82h, 0f753h
    T62 DW 0f235h, 0bd3ah
    T63 DW 0d2bbh, 02ad7h
    T64 DW 0d391h, 0eb86h 
    
    input DB "abcd7890dcba6789", 56 dup(0)  
    binary_output DB 16 dup(?)
    output DB 33 dup(?)   
    
    s0 DB 7, 12, 17, 22
    s1 DB 5, 9, 14, 20,
    s2 DB 4, 11, 16, 23
    s3 DB 6, 10, 15, 21  
    
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
    
    start_i equ -2  
   
    call init_uart 
   
main_repeat: 
    xor ax, ax
    mov start_i[bp], ax
main_loop_read: 
    cmp start_i[bp], 16
    jge main_loop_read_end
    
    ; read character   
    push usart_data
    push usart_cmd    
    call usart_read
    add sp, 4
               
    ; copy value to input array
    lea dx, input
    mov cx, start_i[bp]
    add dx, cx
    mov di, dx
    mov [di], al
    
    push usart_data
    push usart_cmd
    push ax
    call usart_pchar
    add sp, 6
                 
    inc start_i[bp]
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
          
    ; md5(input, binary_output, output, s0) 
    lea ax, s0       
    push ax   
    lea ax, T1
    push ax
    lea ax, output
    push ax      
    lea ax, binary_output
    push ax
    lea ax, input
    push ax
    call md5
    add sp, 10
    
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
         
include "include/util.asm"
include "include/usart.asm"
include "include/rotate.asm"
include "include/md5.asm"

init_uart proc
    mov al, 01001101b; 
    out usart_cmd, al;
    mov al, 00000111b;
    out usart_cmd, al; 
    ret    
init_uart endp

end start 
