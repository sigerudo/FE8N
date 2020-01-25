.thumb
@ 0801a09c

    push {r4, r5, lr}
    mov r4, r0
    lsl r5, r1, #24
    asr r5, r5, #24
    bl main
    ldr r3, =0x0801a0a4
    mov pc, r3

DEFEAT   = (0b10000000) @撃破フラグ
DEFEATED = (0b01000000) @迅雷済みフラグ
STORM    = (0b00100000) @狂嵐フラグ

main:
        push {lr}
        mov r1, r4
        add r1, #69
        ldrb r0, [r1]

        mov r1, #DEFEATED
        and r0, r1
        bne end
        asr r5, r5, #1
    end:
        pop {pc}

.align
.ltorg
addr:

