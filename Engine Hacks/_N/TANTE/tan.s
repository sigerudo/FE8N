INVARID_ITEM = (0xFF)
BREAK_NUM = (0xFF)
DEAD_EYE_FLAG = (0x4C)

.thumb
@.org 0802b3b0

	ldr	r0, =0x0203a4d0
	ldrh	r1, [r0, #0]
	mov	r0, #2
	and	r0, r1
	cmp	r0, #0
	bne	RETURN	@予測ならノーマル

	mov	r0, #0x50
	ldrb	r0, [r7, r0]
	cmp	r0, #4
	ble	physics
	cmp	r0, #8
	bge	physics
	mov	r0, #1
	b	magic
physics:
	mov	r0, #0
magic:
	mov	r1, r8
	bl	SHIELD
	cmp	r0, #0
	beq	RETURN
	cmp	r1, #255
	beq	RETURN	@壊れないならジャンプ
	mov	r2, r9
	cmp	r2, #DEAD_EYE_FLAG
	beq	force_break		@必的フラグオンならジャンプ
	
	add	r1, r8
	ldrb r2, [r1, #1]
	cmp	r2,	#BREAK_NUM	@この回数なら破損状態
	beq	breaked

	ldrh r0, [r1]
	push {r1}
	bl $08016894	@破損処理
	pop {r1}
	cmp r0, #0
	bne not_zero
	mov r0, r8
	ldrh r0, [r1]
	mov r2, #BREAK_NUM	@消滅フラグ
	lsl r2, r2, #8
	orr r0, r2
not_zero:
	strh r0, [r1]
	b	RETURN

force_break:
	add	r1, r8
	ldrb r2, [r1, #1]
	mov	r2, #BREAK_NUM	@消滅フラグ
	strb r2, [r1, #1]
breaked:
	sub	r4, r4, r0	@壊れてるので、ボーナス分を減算
RETURN:
	ldr	r0, =0x0802b3b8
	mov	pc, r0
	
	
	
	
@;盾装備判定
@r0 防御ボーナス
@r1 盾位置(255=壊れない)
SHIELD:
	push	{r4, r5, r6, r7, lr}
	mov	r5, r0 @;魔法判定
	mov	r4, r1 @;相手ステータス
	
	mov r0, #72
	ldrh r0, [r4, r0]
		ldr r1, =0x080172f0	@武器種類
		mov lr, r1
		.short 0xF800
	mov r7, r0

	mov	r6, #28
loopShield:
	add	r6, #2
	cmp	r6, #40
	beq	loopEnd
	
	ldrh	r0, [r4, r6]
	cmp	r0, #0
	beq	loopShield
		ldr	r1, =0x08017314
		mov	lr, r1
		.short 0xF800
	mov	r2, r1
	mov	r1, r0
	lsl	r0, r1, #6	@;盾パッチの下のビット
	bmi	isShield
	b	loopShield
loopEnd:
	mov	r0, #0
	mov	r1, #0
	b	endShield
	
isShield:
	ldrb	r0, [r2, #28]
	cmp r0, #0
	bne needEquipment	@;武器レベル0以外なら剣装備盾
	ldr	r3, [r2, #16]
	cmp	r3, #0
	bne	needClass		@;それ以外なら兵種制限盾
	b	canShield		@;制限なし盾

needClass:	@装備可能クラスかチェック
	ldr	r0, [r4, #4]
	ldrb	r0, [r0, #4]
loopCanShield:
	ldrb	r1, [r3]
	cmp	r1, #0
	beq	loopShield		@不可。戻ってほかの盾を探す
	cmp	r0, r1
	beq	canShield
	add	r3, #1
	b	loopCanShield

needEquipment:	@装備可能装備かチェック
	cmp r7, #INVARID_ITEM
	beq canShield	@装備なしならtrue
	cmp r7, #0	@剣
	beq canShield	@剣装備ならtrue
	b loopShield		@不可。戻ってほかの盾を探す
	
canShield:
	ldr	r0, [r2, #12]
	add	r0, #4
	ldrb	r0, [r0, r5]
	ldr	r2, [r2, #8]
	lsl	r2, r2, #28
	bpl	kowareru	@;壊れないフラグがオフならジャンプ
	mov	r6, #255
kowareru:
	mov	r1, r6
endShield:
	pop	{r4, r5, r6, r7, pc}

$08016894:
ldr	r1, =0x08016894
mov	pc, r1
	
.align
.ltorg
adr:
