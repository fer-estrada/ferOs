[BITS 32]
[EXTERN kernel_main]

global start

start:
    call kernel_main
    jmp $
