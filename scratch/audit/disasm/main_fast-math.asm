
scratch/audit/builds/main_fast-math.elf:     file format elf32-avr


Disassembly of section .text:

00000000 <__vectors>:
       0:	0c 94 68 01 	jmp	0x2d0	; 0x2d0 <__ctors_end>
       4:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
       8:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
       c:	0c 94 65 2c 	jmp	0x58ca	; 0x58ca <__vector_3>
      10:	0c 94 2b 2c 	jmp	0x5856	; 0x5856 <__vector_4>
      14:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      18:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      1c:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      20:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      24:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      28:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      2c:	0c 94 aa 2c 	jmp	0x5954	; 0x5954 <__vector_11>
      30:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      34:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      38:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      3c:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      40:	0c 94 94 2c 	jmp	0x5928	; 0x5928 <__vector_16>
      44:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      48:	0c 94 e1 2e 	jmp	0x5dc2	; 0x5dc2 <__vector_18>
      4c:	0c 94 81 2f 	jmp	0x5f02	; 0x5f02 <__vector_19>
      50:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      54:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      58:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      5c:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      60:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      64:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      68:	08 4a       	sbci	r16, 0xA8	; 168
      6a:	d7 3b       	cpi	r29, 0xB7	; 183
      6c:	3b ce       	rjmp	.-906    	; 0xfffffce4 <__eeprom_end+0xff7efce4>
      6e:	01 6e       	ori	r16, 0xE1	; 225
      70:	84 bc       	out	0x24, r8	; 36
      72:	bf fd       	.word	0xfdbf	; ????
      74:	c1 2f       	mov	r28, r17
      76:	3d 6c       	ori	r19, 0xCD	; 205
      78:	74 31       	cpi	r23, 0x14	; 20
      7a:	9a bd       	out	0x2a, r25	; 42
      7c:	56 83       	std	Z+6, r21	; 0x06
      7e:	3d da       	rcall	.-2950   	; 0xfffff4fa <__eeprom_end+0xff7ef4fa>
      80:	3d 00       	.word	0x003d	; ????
      82:	c7 7f       	andi	r28, 0xF7	; 247
      84:	11 be       	out	0x31, r1	; 49
      86:	d9 e4       	ldi	r29, 0x49	; 73
      88:	bb 4c       	sbci	r27, 0xCB	; 203
      8a:	3e 91       	ld	r19, -X
      8c:	6b aa       	std	Y+51, r6	; 0x33
      8e:	aa be       	out	0x3a, r10	; 58
      90:	00 00       	nop
      92:	00 80       	ld	r0, Z
      94:	3f 05       	cpc	r19, r15
      96:	a8 4c       	sbci	r26, 0xC8	; 200
      98:	cd b2       	in	r12, 0x1d	; 29
      9a:	d4 4e       	sbci	r29, 0xE4	; 228
      9c:	b9 38       	cpi	r27, 0x89	; 137
      9e:	36 a9       	ldd	r19, Z+54	; 0x36
      a0:	02 0c       	add	r0, r2
      a2:	50 b9       	out	0x00, r21	; 0
      a4:	91 86       	std	Z+9, r9	; 0x09
      a6:	88 08       	sbc	r8, r8
      a8:	3c a6       	std	Y+44, r3	; 0x2c
      aa:	aa aa       	std	Y+50, r10	; 0x32
      ac:	2a be       	out	0x3a, r2	; 58
      ae:	00 00       	nop
      b0:	00 80       	ld	r0, Z
      b2:	3f 00       	.word	0x003f	; ????

000000b4 <__trampolines_end>:
      b4:	0d 0a       	sbc	r0, r29
      b6:	47 72       	andi	r20, 0x27	; 39
      b8:	62 6c       	ori	r22, 0xC2	; 194
      ba:	20 31       	cpi	r18, 0x10	; 16
      bc:	2e 31       	cpi	r18, 0x1E	; 30
      be:	68 20       	and	r6, r8
      c0:	5b 27       	eor	r21, r27
      c2:	24 27       	eor	r18, r20
      c4:	20 66       	ori	r18, 0x60	; 96
      c6:	6f 72       	andi	r22, 0x2F	; 47
      c8:	20 68       	ori	r18, 0x80	; 128
      ca:	65 6c       	ori	r22, 0xC5	; 197
      cc:	70 5d       	subi	r23, 0xD0	; 208
      ce:	0d 0a       	sbc	r0, r29
	...

000000d1 <__c.2591>:
      d1:	24 4e 00                                            $N.

000000d4 <__c.2602>:
      d4:	5b 4f 50 54 3a 00                                   [OPT:.

000000da <__c.2600>:
      da:	5b 56 45 52 3a 31 2e 31 68 2e 32 30 31 39 30 38     [VER:1.1h.201908
      ea:	33 30 3a 00                                         30:.

000000ee <__c.2565>:
      ee:	5b 54 4c 4f 3a 00                                   [TLO:.

000000f4 <__c.2563>:
      f4:	5b 47 39 32 3a 00                                   [G92:.

000000fa <__c.2557>:
      fa:	33 30 00                                            30.

000000fd <__c.2553>:
      fd:	32 38 00                                            28.

00000100 <__c.2550>:
     100:	5b 47 00                                            [G.

00000103 <__c.2441>:
     103:	20 47 00                                             G.

00000106 <__c.2445>:
     106:	20 4d 00                                             M.

00000109 <__c.2585>:
     109:	20 53 00                                             S.

0000010c <__c.2583>:
     10c:	20 46 00                                             F.

0000010f <__c.2581>:
     10f:	20 54 00                                             T.

00000112 <__c.2571>:
     112:	33 38 2e 00                                         38..

00000116 <__c.2569>:
     116:	5b 47 43 3a 47 00                                   [GC:G.

0000011c <__c.2523>:
     11c:	5b 48 4c 50 3a 24 24 20 24 23 20 24 47 20 24 49     [HLP:$$ $# $G $I
     12c:	20 24 4e 20 24 78 3d 76 61 6c 20 24 4e 78 3d 6c      $N $x=val $Nx=l
     13c:	69 6e 65 20 24 4a 3d 6c 69 6e 65 20 24 53 4c 50     ine $J=line $SLP
     14c:	20 24 43 20 24 58 20 24 48 20 7e 20 21 20 3f 20      $C $X $H ~ ! ? 
     15c:	63 74 72 6c 2d 78 5d 0d 0a 00                       ctrl-x]...

00000166 <__c.2476>:
     166:	41 4c 41 52 4d 3a 00                                ALARM:.

0000016d <__c.2665>:
     16d:	7c 41 3a 00                                         |A:.

00000171 <__c.2661>:
     171:	7c 4f 76 3a 00                                      |Ov:.

00000176 <__c.2659>:
     176:	7c 57 43 4f 3a 00                                   |WCO:.

0000017c <__c.2657>:
     17c:	7c 50 6e 3a 00                                      |Pn:.

00000181 <__c.2652>:
     181:	7c 46 53 3a 00                                      |FS:.

00000186 <__c.2650>:
     186:	7c 42 66 3a 00                                      |Bf:.

0000018b <__c.2648>:
     18b:	7c 57 50 6f 73 3a 00                                |WPos:.

00000192 <__c.2646>:
     192:	7c 4d 50 6f 73 3a 00                                |MPos:.

00000199 <__c.2640>:
     199:	53 6c 65 65 70 00                                   Sleep.

0000019f <__c.2637>:
     19f:	44 6f 6f 72 3a 00                                   Door:.

000001a5 <__c.2634>:
     1a5:	43 68 65 63 6b 00                                   Check.

000001ab <__c.2631>:
     1ab:	41 6c 61 72 6d 00                                   Alarm.

000001b1 <__c.2628>:
     1b1:	48 6f 6d 65 00                                      Home.

000001b6 <__c.2625>:
     1b6:	4a 6f 67 00                                         Jog.

000001ba <__c.2622>:
     1ba:	48 6f 6c 64 3a 00                                   Hold:.

000001c0 <__c.2619>:
     1c0:	52 75 6e 00                                         Run.

000001c4 <__c.2615>:
     1c4:	49 64 6c 65 00                                      Idle.

000001c9 <defaults>:
     1c9:	00 00 7a 43 00 00 7a 43 00 00 7a 43 00 00 fa 43     ..zC..zC..zC...C
     1d9:	00 00 fa 43 00 00 fa 43 00 a0 0c 47 00 a0 0c 47     ...C...C...G...G
     1e9:	00 a0 0c 47 00 00 48 c3 00 00 48 c3 00 00 48 c3     ...G..H...H...H.
     1f9:	0a 00 00 19 01 0a d7 23 3c 6f 12 03 3b 00 00 7a     .......#<o..;..z
     209:	44 00 00 00 00 00 00 00 00 c8 41 00 00 fa 43 fa     D.........A...C.
     219:	00 00 00 80 3f                                      ....?

0000021e <__c.2435>:
     21e:	0d 0a 00                                            ...

00000221 <__c.2543>:
     221:	5b 50 52 42 3a 00                                   [PRB:.

00000227 <__c.2471>:
     227:	65 72 72 6f 72 3a 00                                error:.

0000022e <__c.2467>:
     22e:	6f 6b 0d 0a 00                                      ok...

00000233 <__c.2515>:
     233:	53 6c 65 65 70 69 6e 67 00                          Sleeping.

0000023c <__c.2512>:
     23c:	52 65 73 74 6f 72 69 6e 67 20 73 70 69 6e 64 6c     Restoring spindl
     24c:	65 00                                               e.

0000024e <__c.2509>:
     24e:	52 65 73 74 6f 72 69 6e 67 20 64 65 66 61 75 6c     Restoring defaul
     25e:	74 73 00                                            ts.

00000261 <__c.2506>:
     261:	50 67 6d 20 45 6e 64 00                             Pgm End.

00000269 <__c.2503>:
     269:	43 68 65 63 6b 20 4c 69 6d 69 74 73 00              Check Limits.

00000276 <__c.2500>:
     276:	43 68 65 63 6b 20 44 6f 6f 72 00                    Check Door.

00000281 <__c.2497>:
     281:	44 69 73 61 62 6c 65 64 00                          Disabled.

0000028a <__c.2494>:
     28a:	45 6e 61 62 6c 65 64 00                             Enabled.

00000292 <__c.2491>:
     292:	43 61 75 74 69 6f 6e 3a 20 55 6e 6c 6f 63 6b 65     Caution: Unlocke
     2a2:	64 00                                               d.

000002a4 <__c.2488>:
     2a4:	27 24 48 27 7c 27 24 58 27 20 74 6f 20 75 6e 6c     '$H'|'$X' to unl
     2b4:	6f 63 6b 00                                         ock.

000002b8 <__c.2484>:
     2b8:	52 65 73 65 74 20 74 6f 20 63 6f 6e 74 69 6e 75     Reset to continu
     2c8:	65 00                                               e.

000002ca <__c.2481>:
     2ca:	5b 4d 53 47 3a 00                                   [MSG:.

000002d0 <__ctors_end>:
     2d0:	11 24       	eor	r1, r1
     2d2:	1f be       	out	0x3f, r1	; 63
     2d4:	cf ef       	ldi	r28, 0xFF	; 255
     2d6:	d8 e0       	ldi	r29, 0x08	; 8
     2d8:	de bf       	out	0x3e, r29	; 62
     2da:	cd bf       	out	0x3d, r28	; 61

000002dc <__do_clear_bss>:
     2dc:	27 e0       	ldi	r18, 0x07	; 7
     2de:	a0 e0       	ldi	r26, 0x00	; 0
     2e0:	b1 e0       	ldi	r27, 0x01	; 1
     2e2:	01 c0       	rjmp	.+2      	; 0x2e6 <.do_clear_bss_start>

000002e4 <.do_clear_bss_loop>:
     2e4:	1d 92       	st	X+, r1

000002e6 <.do_clear_bss_start>:
     2e6:	a1 36       	cpi	r26, 0x61	; 97
     2e8:	b2 07       	cpc	r27, r18
     2ea:	e1 f7       	brne	.-8      	; 0x2e4 <.do_clear_bss_loop>
     2ec:	0e 94 ab 2f 	call	0x5f56	; 0x5f56 <main>
     2f0:	0c 94 d5 39 	jmp	0x73aa	; 0x73aa <_exit>

000002f4 <__bad_interrupt>:
     2f4:	0c 94 00 00 	jmp	0	; 0x0 <__vectors>

000002f8 <read_float.constprop.12>:
     2f8:	8f 92       	push	r8
     2fa:	9f 92       	push	r9
     2fc:	af 92       	push	r10
     2fe:	bf 92       	push	r11
     300:	cf 92       	push	r12
     302:	df 92       	push	r13
     304:	ef 92       	push	r14
     306:	ff 92       	push	r15
     308:	0f 93       	push	r16
     30a:	1f 93       	push	r17
     30c:	cf 93       	push	r28
     30e:	df 93       	push	r29
     310:	7c 01       	movw	r14, r24
     312:	6b 01       	movw	r12, r22
     314:	dc 01       	movw	r26, r24
     316:	ec 91       	ld	r30, X
     318:	f0 e0       	ldi	r31, 0x00	; 0
     31a:	ef 5e       	subi	r30, 0xEF	; 239
     31c:	f8 4f       	sbci	r31, 0xF8	; 248
     31e:	80 81       	ld	r24, Z
     320:	ef 01       	movw	r28, r30
     322:	8d 32       	cpi	r24, 0x2D	; 45
     324:	29 f5       	brne	.+74     	; 0x370 <read_float.constprop.12+0x78>
     326:	22 96       	adiw	r28, 0x02	; 2
     328:	81 81       	ldd	r24, Z+1	; 0x01
     32a:	01 e0       	ldi	r16, 0x01	; 1
     32c:	91 2c       	mov	r9, r1
     32e:	f0 e0       	ldi	r31, 0x00	; 0
     330:	10 e0       	ldi	r17, 0x00	; 0
     332:	20 e0       	ldi	r18, 0x00	; 0
     334:	30 e0       	ldi	r19, 0x00	; 0
     336:	a9 01       	movw	r20, r18
     338:	5e 01       	movw	r10, r28
     33a:	e0 ed       	ldi	r30, 0xD0	; 208
     33c:	e8 0f       	add	r30, r24
     33e:	ea 30       	cpi	r30, 0x0A	; 10
     340:	18 f5       	brcc	.+70     	; 0x388 <read_float.constprop.12+0x90>
     342:	ff 5f       	subi	r31, 0xFF	; 255
     344:	f9 30       	cpi	r31, 0x09	; 9
     346:	e0 f4       	brcc	.+56     	; 0x380 <read_float.constprop.12+0x88>
     348:	91 10       	cpse	r9, r1
     34a:	11 50       	subi	r17, 0x01	; 1
     34c:	a5 e0       	ldi	r26, 0x05	; 5
     34e:	b0 e0       	ldi	r27, 0x00	; 0
     350:	0e 94 ae 39 	call	0x735c	; 0x735c <__muluhisi3>
     354:	9b 01       	movw	r18, r22
     356:	ac 01       	movw	r20, r24
     358:	22 0f       	add	r18, r18
     35a:	33 1f       	adc	r19, r19
     35c:	44 1f       	adc	r20, r20
     35e:	55 1f       	adc	r21, r21
     360:	2e 0f       	add	r18, r30
     362:	31 1d       	adc	r19, r1
     364:	41 1d       	adc	r20, r1
     366:	51 1d       	adc	r21, r1
     368:	21 96       	adiw	r28, 0x01	; 1
     36a:	d5 01       	movw	r26, r10
     36c:	8c 91       	ld	r24, X
     36e:	e4 cf       	rjmp	.-56     	; 0x338 <read_float.constprop.12+0x40>
     370:	8b 32       	cpi	r24, 0x2B	; 43
     372:	19 f0       	breq	.+6      	; 0x37a <read_float.constprop.12+0x82>
     374:	21 96       	adiw	r28, 0x01	; 1
     376:	00 e0       	ldi	r16, 0x00	; 0
     378:	d9 cf       	rjmp	.-78     	; 0x32c <read_float.constprop.12+0x34>
     37a:	22 96       	adiw	r28, 0x02	; 2
     37c:	81 81       	ldd	r24, Z+1	; 0x01
     37e:	fb cf       	rjmp	.-10     	; 0x376 <read_float.constprop.12+0x7e>
     380:	91 10       	cpse	r9, r1
     382:	f2 cf       	rjmp	.-28     	; 0x368 <read_float.constprop.12+0x70>
     384:	1f 5f       	subi	r17, 0xFF	; 255
     386:	f0 cf       	rjmp	.-32     	; 0x368 <read_float.constprop.12+0x70>
     388:	ee 3f       	cpi	r30, 0xFE	; 254
     38a:	29 f4       	brne	.+10     	; 0x396 <read_float.constprop.12+0x9e>
     38c:	91 10       	cpse	r9, r1
     38e:	03 c0       	rjmp	.+6      	; 0x396 <read_float.constprop.12+0x9e>
     390:	99 24       	eor	r9, r9
     392:	93 94       	inc	r9
     394:	e9 cf       	rjmp	.-46     	; 0x368 <read_float.constprop.12+0x70>
     396:	ff 23       	and	r31, r31
     398:	f9 f0       	breq	.+62     	; 0x3d8 <read_float.constprop.12+0xe0>
     39a:	ca 01       	movw	r24, r20
     39c:	b9 01       	movw	r22, r18
     39e:	0e 94 b8 36 	call	0x6d70	; 0x6d70 <__floatunsisf>
     3a2:	4b 01       	movw	r8, r22
     3a4:	5c 01       	movw	r10, r24
     3a6:	20 e0       	ldi	r18, 0x00	; 0
     3a8:	30 e0       	ldi	r19, 0x00	; 0
     3aa:	a9 01       	movw	r20, r18
     3ac:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     3b0:	81 11       	cpse	r24, r1
     3b2:	2b c0       	rjmp	.+86     	; 0x40a <__LOCK_REGION_LENGTH__+0xa>
     3b4:	00 23       	and	r16, r16
     3b6:	09 f4       	brne	.+2      	; 0x3ba <read_float.constprop.12+0xc2>
     3b8:	45 c0       	rjmp	.+138    	; 0x444 <__LOCK_REGION_LENGTH__+0x44>
     3ba:	b7 fa       	bst	r11, 7
     3bc:	b0 94       	com	r11
     3be:	b7 f8       	bld	r11, 7
     3c0:	b0 94       	com	r11
     3c2:	f6 01       	movw	r30, r12
     3c4:	80 82       	st	Z, r8
     3c6:	91 82       	std	Z+1, r9	; 0x01
     3c8:	a2 82       	std	Z+2, r10	; 0x02
     3ca:	b3 82       	std	Z+3, r11	; 0x03
     3cc:	c1 51       	subi	r28, 0x11	; 17
     3ce:	d7 40       	sbci	r29, 0x07	; 7
     3d0:	c1 50       	subi	r28, 0x01	; 1
     3d2:	f7 01       	movw	r30, r14
     3d4:	c0 83       	st	Z, r28
     3d6:	f1 e0       	ldi	r31, 0x01	; 1
     3d8:	8f 2f       	mov	r24, r31
     3da:	df 91       	pop	r29
     3dc:	cf 91       	pop	r28
     3de:	1f 91       	pop	r17
     3e0:	0f 91       	pop	r16
     3e2:	ff 90       	pop	r15
     3e4:	ef 90       	pop	r14
     3e6:	df 90       	pop	r13
     3e8:	cf 90       	pop	r12
     3ea:	bf 90       	pop	r11
     3ec:	af 90       	pop	r10
     3ee:	9f 90       	pop	r9
     3f0:	8f 90       	pop	r8
     3f2:	08 95       	ret
     3f4:	2a e0       	ldi	r18, 0x0A	; 10
     3f6:	37 ed       	ldi	r19, 0xD7	; 215
     3f8:	43 e2       	ldi	r20, 0x23	; 35
     3fa:	5c e3       	ldi	r21, 0x3C	; 60
     3fc:	c5 01       	movw	r24, r10
     3fe:	b4 01       	movw	r22, r8
     400:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     404:	4b 01       	movw	r8, r22
     406:	5c 01       	movw	r10, r24
     408:	1e 5f       	subi	r17, 0xFE	; 254
     40a:	1f 3f       	cpi	r17, 0xFF	; 255
     40c:	9c f3       	brlt	.-26     	; 0x3f4 <read_float.constprop.12+0xfc>
     40e:	1f 3f       	cpi	r17, 0xFF	; 255
     410:	59 f4       	brne	.+22     	; 0x428 <__LOCK_REGION_LENGTH__+0x28>
     412:	2d ec       	ldi	r18, 0xCD	; 205
     414:	3c ec       	ldi	r19, 0xCC	; 204
     416:	4c ec       	ldi	r20, 0xCC	; 204
     418:	5d e3       	ldi	r21, 0x3D	; 61
     41a:	c5 01       	movw	r24, r10
     41c:	b4 01       	movw	r22, r8
     41e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     422:	4b 01       	movw	r8, r22
     424:	5c 01       	movw	r10, r24
     426:	c6 cf       	rjmp	.-116    	; 0x3b4 <read_float.constprop.12+0xbc>
     428:	11 23       	and	r17, r17
     42a:	21 f2       	breq	.-120    	; 0x3b4 <read_float.constprop.12+0xbc>
     42c:	20 e0       	ldi	r18, 0x00	; 0
     42e:	30 e0       	ldi	r19, 0x00	; 0
     430:	40 e2       	ldi	r20, 0x20	; 32
     432:	51 e4       	ldi	r21, 0x41	; 65
     434:	c5 01       	movw	r24, r10
     436:	b4 01       	movw	r22, r8
     438:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     43c:	4b 01       	movw	r8, r22
     43e:	5c 01       	movw	r10, r24
     440:	11 50       	subi	r17, 0x01	; 1
     442:	f2 cf       	rjmp	.-28     	; 0x428 <__LOCK_REGION_LENGTH__+0x28>
     444:	d6 01       	movw	r26, r12
     446:	8d 92       	st	X+, r8
     448:	9d 92       	st	X+, r9
     44a:	ad 92       	st	X+, r10
     44c:	bc 92       	st	X, r11
     44e:	13 97       	sbiw	r26, 0x03	; 3
     450:	bd cf       	rjmp	.-134    	; 0x3cc <read_float.constprop.12+0xd4>

00000452 <system_set_exec_accessory_override_flag>:
     452:	2f b7       	in	r18, 0x3f	; 63
     454:	f8 94       	cli
     456:	90 91 16 06 	lds	r25, 0x0616	; 0x800616 <sys_rt_exec_accessory_override>
     45a:	89 2b       	or	r24, r25
     45c:	80 93 16 06 	sts	0x0616, r24	; 0x800616 <sys_rt_exec_accessory_override>
     460:	2f bf       	out	0x3f, r18	; 63
     462:	08 95       	ret

00000464 <system_set_exec_motion_override_flag>:
     464:	2f b7       	in	r18, 0x3f	; 63
     466:	f8 94       	cli
     468:	90 91 15 06 	lds	r25, 0x0615	; 0x800615 <sys_rt_exec_motion_override>
     46c:	89 2b       	or	r24, r25
     46e:	80 93 15 06 	sts	0x0615, r24	; 0x800615 <sys_rt_exec_motion_override>
     472:	2f bf       	out	0x3f, r18	; 63
     474:	08 95       	ret

00000476 <system_set_exec_alarm>:
     476:	9f b7       	in	r25, 0x3f	; 63
     478:	f8 94       	cli
     47a:	80 93 14 06 	sts	0x0614, r24	; 0x800614 <sys_rt_exec_alarm>
     47e:	9f bf       	out	0x3f, r25	; 63
     480:	08 95       	ret

00000482 <system_clear_exec_state_flag>:
     482:	9f b7       	in	r25, 0x3f	; 63
     484:	f8 94       	cli
     486:	20 91 13 06 	lds	r18, 0x0613	; 0x800613 <sys_rt_exec_state>
     48a:	80 95       	com	r24
     48c:	82 23       	and	r24, r18
     48e:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
     492:	9f bf       	out	0x3f, r25	; 63
     494:	08 95       	ret

00000496 <system_set_exec_state_flag>:
     496:	2f b7       	in	r18, 0x3f	; 63
     498:	f8 94       	cli
     49a:	90 91 13 06 	lds	r25, 0x0613	; 0x800613 <sys_rt_exec_state>
     49e:	89 2b       	or	r24, r25
     4a0:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
     4a4:	2f bf       	out	0x3f, r18	; 63
     4a6:	08 95       	ret

000004a8 <system_check_travel_limits>:
     4a8:	af 92       	push	r10
     4aa:	bf 92       	push	r11
     4ac:	cf 92       	push	r12
     4ae:	df 92       	push	r13
     4b0:	ef 92       	push	r14
     4b2:	ff 92       	push	r15
     4b4:	0f 93       	push	r16
     4b6:	1f 93       	push	r17
     4b8:	cf 93       	push	r28
     4ba:	df 93       	push	r29
     4bc:	ec 01       	movw	r28, r24
     4be:	06 e6       	ldi	r16, 0x66	; 102
     4c0:	16 e0       	ldi	r17, 0x06	; 6
     4c2:	5c 01       	movw	r10, r24
     4c4:	8c e0       	ldi	r24, 0x0C	; 12
     4c6:	a8 0e       	add	r10, r24
     4c8:	b1 1c       	adc	r11, r1
     4ca:	c9 90       	ld	r12, Y+
     4cc:	d9 90       	ld	r13, Y+
     4ce:	e9 90       	ld	r14, Y+
     4d0:	f9 90       	ld	r15, Y+
     4d2:	20 e0       	ldi	r18, 0x00	; 0
     4d4:	30 e0       	ldi	r19, 0x00	; 0
     4d6:	a9 01       	movw	r20, r18
     4d8:	c7 01       	movw	r24, r14
     4da:	b6 01       	movw	r22, r12
     4dc:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
     4e0:	18 16       	cp	r1, r24
     4e2:	dc f0       	brlt	.+54     	; 0x51a <system_check_travel_limits+0x72>
     4e4:	f8 01       	movw	r30, r16
     4e6:	21 91       	ld	r18, Z+
     4e8:	31 91       	ld	r19, Z+
     4ea:	41 91       	ld	r20, Z+
     4ec:	51 91       	ld	r21, Z+
     4ee:	8f 01       	movw	r16, r30
     4f0:	c7 01       	movw	r24, r14
     4f2:	b6 01       	movw	r22, r12
     4f4:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     4f8:	87 fd       	sbrc	r24, 7
     4fa:	0f c0       	rjmp	.+30     	; 0x51a <system_check_travel_limits+0x72>
     4fc:	ca 15       	cp	r28, r10
     4fe:	db 05       	cpc	r29, r11
     500:	21 f7       	brne	.-56     	; 0x4ca <system_check_travel_limits+0x22>
     502:	80 e0       	ldi	r24, 0x00	; 0
     504:	df 91       	pop	r29
     506:	cf 91       	pop	r28
     508:	1f 91       	pop	r17
     50a:	0f 91       	pop	r16
     50c:	ff 90       	pop	r15
     50e:	ef 90       	pop	r14
     510:	df 90       	pop	r13
     512:	cf 90       	pop	r12
     514:	bf 90       	pop	r11
     516:	af 90       	pop	r10
     518:	08 95       	ret
     51a:	81 e0       	ldi	r24, 0x01	; 1
     51c:	f3 cf       	rjmp	.-26     	; 0x504 <system_check_travel_limits+0x5c>

0000051e <system_convert_array_steps_to_mpos>:
     51e:	8f 92       	push	r8
     520:	9f 92       	push	r9
     522:	af 92       	push	r10
     524:	bf 92       	push	r11
     526:	cf 92       	push	r12
     528:	df 92       	push	r13
     52a:	ef 92       	push	r14
     52c:	ff 92       	push	r15
     52e:	0f 93       	push	r16
     530:	1f 93       	push	r17
     532:	cf 93       	push	r28
     534:	df 93       	push	r29
     536:	eb 01       	movw	r28, r22
     538:	22 e4       	ldi	r18, 0x42	; 66
     53a:	e2 2e       	mov	r14, r18
     53c:	26 e0       	ldi	r18, 0x06	; 6
     53e:	f2 2e       	mov	r15, r18
     540:	8c 01       	movw	r16, r24
     542:	6b 01       	movw	r12, r22
     544:	8c e0       	ldi	r24, 0x0C	; 12
     546:	c8 0e       	add	r12, r24
     548:	d1 1c       	adc	r13, r1
     54a:	69 91       	ld	r22, Y+
     54c:	79 91       	ld	r23, Y+
     54e:	89 91       	ld	r24, Y+
     550:	99 91       	ld	r25, Y+
     552:	f7 01       	movw	r30, r14
     554:	81 90       	ld	r8, Z+
     556:	91 90       	ld	r9, Z+
     558:	a1 90       	ld	r10, Z+
     55a:	b1 90       	ld	r11, Z+
     55c:	7f 01       	movw	r14, r30
     55e:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
     562:	a5 01       	movw	r20, r10
     564:	94 01       	movw	r18, r8
     566:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
     56a:	f8 01       	movw	r30, r16
     56c:	61 93       	st	Z+, r22
     56e:	71 93       	st	Z+, r23
     570:	81 93       	st	Z+, r24
     572:	91 93       	st	Z+, r25
     574:	8f 01       	movw	r16, r30
     576:	cc 15       	cp	r28, r12
     578:	dd 05       	cpc	r29, r13
     57a:	39 f7       	brne	.-50     	; 0x54a <system_convert_array_steps_to_mpos+0x2c>
     57c:	df 91       	pop	r29
     57e:	cf 91       	pop	r28
     580:	1f 91       	pop	r17
     582:	0f 91       	pop	r16
     584:	ff 90       	pop	r15
     586:	ef 90       	pop	r14
     588:	df 90       	pop	r13
     58a:	cf 90       	pop	r12
     58c:	bf 90       	pop	r11
     58e:	af 90       	pop	r10
     590:	9f 90       	pop	r9
     592:	8f 90       	pop	r8
     594:	08 95       	ret

00000596 <system_control_get_state>:
     596:	96 b1       	in	r25, 0x06	; 6
     598:	90 95       	com	r25
     59a:	89 2f       	mov	r24, r25
     59c:	87 70       	andi	r24, 0x07	; 7
     59e:	39 f0       	breq	.+14     	; 0x5ae <system_control_get_state+0x18>
     5a0:	82 e0       	ldi	r24, 0x02	; 2
     5a2:	91 ff       	sbrs	r25, 1
     5a4:	80 e0       	ldi	r24, 0x00	; 0
     5a6:	90 fd       	sbrc	r25, 0
     5a8:	81 60       	ori	r24, 0x01	; 1
     5aa:	92 fd       	sbrc	r25, 2
     5ac:	84 60       	ori	r24, 0x04	; 4
     5ae:	08 95       	ret

000005b0 <probe_configure_invert_mask>:
     5b0:	10 92 17 06 	sts	0x0617, r1	; 0x800617 <probe_invert_mask>
     5b4:	90 91 87 06 	lds	r25, 0x0687	; 0x800687 <settings+0x45>
     5b8:	97 fd       	sbrc	r25, 7
     5ba:	03 c0       	rjmp	.+6      	; 0x5c2 <probe_configure_invert_mask+0x12>
     5bc:	90 e2       	ldi	r25, 0x20	; 32
     5be:	90 93 17 06 	sts	0x0617, r25	; 0x800617 <probe_invert_mask>
     5c2:	88 23       	and	r24, r24
     5c4:	31 f0       	breq	.+12     	; 0x5d2 <probe_configure_invert_mask+0x22>
     5c6:	80 91 17 06 	lds	r24, 0x0617	; 0x800617 <probe_invert_mask>
     5ca:	90 e2       	ldi	r25, 0x20	; 32
     5cc:	89 27       	eor	r24, r25
     5ce:	80 93 17 06 	sts	0x0617, r24	; 0x800617 <probe_invert_mask>
     5d2:	08 95       	ret

000005d4 <limits_get_state>:
     5d4:	93 b1       	in	r25, 0x03	; 3
     5d6:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
     5da:	86 ff       	sbrs	r24, 6
     5dc:	0b c0       	rjmp	.+22     	; 0x5f4 <limits_get_state+0x20>
     5de:	96 71       	andi	r25, 0x16	; 22
     5e0:	59 f0       	breq	.+22     	; 0x5f8 <limits_get_state+0x24>
     5e2:	91 fb       	bst	r25, 1
     5e4:	88 27       	eor	r24, r24
     5e6:	80 f9       	bld	r24, 0
     5e8:	92 fd       	sbrc	r25, 2
     5ea:	82 60       	ori	r24, 0x02	; 2
     5ec:	90 71       	andi	r25, 0x10	; 16
     5ee:	29 f0       	breq	.+10     	; 0x5fa <limits_get_state+0x26>
     5f0:	84 60       	ori	r24, 0x04	; 4
     5f2:	08 95       	ret
     5f4:	90 95       	com	r25
     5f6:	f3 cf       	rjmp	.-26     	; 0x5de <limits_get_state+0xa>
     5f8:	80 e0       	ldi	r24, 0x00	; 0
     5fa:	08 95       	ret

000005fc <limits_disable>:
     5fc:	eb e6       	ldi	r30, 0x6B	; 107
     5fe:	f0 e0       	ldi	r31, 0x00	; 0
     600:	80 81       	ld	r24, Z
     602:	89 7e       	andi	r24, 0xE9	; 233
     604:	80 83       	st	Z, r24
     606:	e8 e6       	ldi	r30, 0x68	; 104
     608:	f0 e0       	ldi	r31, 0x00	; 0
     60a:	80 81       	ld	r24, Z
     60c:	8e 7f       	andi	r24, 0xFE	; 254
     60e:	80 83       	st	Z, r24
     610:	08 95       	ret

00000612 <limits_init>:
     612:	84 b1       	in	r24, 0x04	; 4
     614:	89 7e       	andi	r24, 0xE9	; 233
     616:	84 b9       	out	0x04, r24	; 4
     618:	85 b1       	in	r24, 0x05	; 5
     61a:	86 61       	ori	r24, 0x16	; 22
     61c:	85 b9       	out	0x05, r24	; 5
     61e:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
     622:	83 ff       	sbrs	r24, 3
     624:	0b c0       	rjmp	.+22     	; 0x63c <limits_init+0x2a>
     626:	80 91 6b 00 	lds	r24, 0x006B	; 0x80006b <__DATA_REGION_ORIGIN__+0xb>
     62a:	86 61       	ori	r24, 0x16	; 22
     62c:	80 93 6b 00 	sts	0x006B, r24	; 0x80006b <__DATA_REGION_ORIGIN__+0xb>
     630:	80 91 68 00 	lds	r24, 0x0068	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
     634:	81 60       	ori	r24, 0x01	; 1
     636:	80 93 68 00 	sts	0x0068, r24	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
     63a:	08 95       	ret
     63c:	0c 94 fe 02 	jmp	0x5fc	; 0x5fc <limits_disable>

00000640 <limit_value_by_axis_maximum>:
     640:	6f 92       	push	r6
     642:	7f 92       	push	r7
     644:	8f 92       	push	r8
     646:	9f 92       	push	r9
     648:	af 92       	push	r10
     64a:	bf 92       	push	r11
     64c:	cf 92       	push	r12
     64e:	df 92       	push	r13
     650:	ef 92       	push	r14
     652:	ff 92       	push	r15
     654:	0f 93       	push	r16
     656:	1f 93       	push	r17
     658:	cf 93       	push	r28
     65a:	df 93       	push	r29
     65c:	eb 01       	movw	r28, r22
     65e:	8c 01       	movw	r16, r24
     660:	5b 01       	movw	r10, r22
     662:	8c e0       	ldi	r24, 0x0C	; 12
     664:	a8 0e       	add	r10, r24
     666:	b1 1c       	adc	r11, r1
     668:	89 e9       	ldi	r24, 0x99	; 153
     66a:	68 2e       	mov	r6, r24
     66c:	96 e7       	ldi	r25, 0x76	; 118
     66e:	79 2e       	mov	r7, r25
     670:	26 e9       	ldi	r18, 0x96	; 150
     672:	82 2e       	mov	r8, r18
     674:	3e e7       	ldi	r19, 0x7E	; 126
     676:	93 2e       	mov	r9, r19
     678:	c9 90       	ld	r12, Y+
     67a:	d9 90       	ld	r13, Y+
     67c:	e9 90       	ld	r14, Y+
     67e:	f9 90       	ld	r15, Y+
     680:	20 e0       	ldi	r18, 0x00	; 0
     682:	30 e0       	ldi	r19, 0x00	; 0
     684:	a9 01       	movw	r20, r18
     686:	c7 01       	movw	r24, r14
     688:	b6 01       	movw	r22, r12
     68a:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     68e:	88 23       	and	r24, r24
     690:	b9 f0       	breq	.+46     	; 0x6c0 <limit_value_by_axis_maximum+0x80>
     692:	a7 01       	movw	r20, r14
     694:	96 01       	movw	r18, r12
     696:	f8 01       	movw	r30, r16
     698:	60 81       	ld	r22, Z
     69a:	71 81       	ldd	r23, Z+1	; 0x01
     69c:	82 81       	ldd	r24, Z+2	; 0x02
     69e:	93 81       	ldd	r25, Z+3	; 0x03
     6a0:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
     6a4:	6b 01       	movw	r12, r22
     6a6:	7c 01       	movw	r14, r24
     6a8:	e8 94       	clt
     6aa:	f7 f8       	bld	r15, 7
     6ac:	a7 01       	movw	r20, r14
     6ae:	96 01       	movw	r18, r12
     6b0:	b3 01       	movw	r22, r6
     6b2:	c4 01       	movw	r24, r8
     6b4:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     6b8:	18 16       	cp	r1, r24
     6ba:	14 f4       	brge	.+4      	; 0x6c0 <limit_value_by_axis_maximum+0x80>
     6bc:	36 01       	movw	r6, r12
     6be:	47 01       	movw	r8, r14
     6c0:	0c 5f       	subi	r16, 0xFC	; 252
     6c2:	1f 4f       	sbci	r17, 0xFF	; 255
     6c4:	ca 15       	cp	r28, r10
     6c6:	db 05       	cpc	r29, r11
     6c8:	b9 f6       	brne	.-82     	; 0x678 <limit_value_by_axis_maximum+0x38>
     6ca:	b3 01       	movw	r22, r6
     6cc:	c4 01       	movw	r24, r8
     6ce:	df 91       	pop	r29
     6d0:	cf 91       	pop	r28
     6d2:	1f 91       	pop	r17
     6d4:	0f 91       	pop	r16
     6d6:	ff 90       	pop	r15
     6d8:	ef 90       	pop	r14
     6da:	df 90       	pop	r13
     6dc:	cf 90       	pop	r12
     6de:	bf 90       	pop	r11
     6e0:	af 90       	pop	r10
     6e2:	9f 90       	pop	r9
     6e4:	8f 90       	pop	r8
     6e6:	7f 90       	pop	r7
     6e8:	6f 90       	pop	r6
     6ea:	08 95       	ret

000006ec <plan_sync_position>:
     6ec:	e7 ef       	ldi	r30, 0xF7	; 247
     6ee:	f5 e0       	ldi	r31, 0x05	; 5
     6f0:	a8 e1       	ldi	r26, 0x18	; 24
     6f2:	b6 e0       	ldi	r27, 0x06	; 6
     6f4:	4d 91       	ld	r20, X+
     6f6:	5d 91       	ld	r21, X+
     6f8:	6d 91       	ld	r22, X+
     6fa:	7c 91       	ld	r23, X
     6fc:	13 97       	sbiw	r26, 0x03	; 3
     6fe:	40 83       	st	Z, r20
     700:	51 83       	std	Z+1, r21	; 0x01
     702:	62 83       	std	Z+2, r22	; 0x02
     704:	73 83       	std	Z+3, r23	; 0x03
     706:	14 96       	adiw	r26, 0x04	; 4
     708:	4d 91       	ld	r20, X+
     70a:	5d 91       	ld	r21, X+
     70c:	6d 91       	ld	r22, X+
     70e:	7c 91       	ld	r23, X
     710:	17 97       	sbiw	r26, 0x07	; 7
     712:	44 83       	std	Z+4, r20	; 0x04
     714:	55 83       	std	Z+5, r21	; 0x05
     716:	66 83       	std	Z+6, r22	; 0x06
     718:	77 83       	std	Z+7, r23	; 0x07
     71a:	18 96       	adiw	r26, 0x08	; 8
     71c:	8d 91       	ld	r24, X+
     71e:	9d 91       	ld	r25, X+
     720:	0d 90       	ld	r0, X+
     722:	bc 91       	ld	r27, X
     724:	a0 2d       	mov	r26, r0
     726:	80 87       	std	Z+8, r24	; 0x08
     728:	91 87       	std	Z+9, r25	; 0x09
     72a:	a2 87       	std	Z+10, r26	; 0x0a
     72c:	b3 87       	std	Z+11, r27	; 0x0b
     72e:	08 95       	ret

00000730 <plan_compute_profile_nominal_speed>:
     730:	bf 92       	push	r11
     732:	cf 92       	push	r12
     734:	df 92       	push	r13
     736:	ef 92       	push	r14
     738:	ff 92       	push	r15
     73a:	0f 93       	push	r16
     73c:	1f 93       	push	r17
     73e:	cf 93       	push	r28
     740:	df 93       	push	r29
     742:	ec 01       	movw	r28, r24
     744:	ba a4       	ldd	r11, Y+42	; 0x2a
     746:	cb a4       	ldd	r12, Y+43	; 0x2b
     748:	dc a4       	ldd	r13, Y+44	; 0x2c
     74a:	ed a4       	ldd	r14, Y+45	; 0x2d
     74c:	89 89       	ldd	r24, Y+17	; 0x11
     74e:	80 ff       	sbrs	r24, 0
     750:	35 c0       	rjmp	.+106    	; 0x7bc <plan_compute_profile_nominal_speed+0x8c>
     752:	60 91 39 06 	lds	r22, 0x0639	; 0x800639 <sys+0x8>
     756:	70 e0       	ldi	r23, 0x00	; 0
     758:	90 e0       	ldi	r25, 0x00	; 0
     75a:	80 e0       	ldi	r24, 0x00	; 0
     75c:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
     760:	2a e0       	ldi	r18, 0x0A	; 10
     762:	37 ed       	ldi	r19, 0xD7	; 215
     764:	43 e2       	ldi	r20, 0x23	; 35
     766:	5c e3       	ldi	r21, 0x3C	; 60
     768:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     76c:	2b 2d       	mov	r18, r11
     76e:	3c 2d       	mov	r19, r12
     770:	4d 2d       	mov	r20, r13
     772:	5e 2d       	mov	r21, r14
     774:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     778:	f6 2e       	mov	r15, r22
     77a:	07 2f       	mov	r16, r23
     77c:	18 2f       	mov	r17, r24
     77e:	c9 2f       	mov	r28, r25
     780:	20 e0       	ldi	r18, 0x00	; 0
     782:	30 e0       	ldi	r19, 0x00	; 0
     784:	40 e8       	ldi	r20, 0x80	; 128
     786:	5f e3       	ldi	r21, 0x3F	; 63
     788:	6f 2d       	mov	r22, r15
     78a:	70 2f       	mov	r23, r16
     78c:	81 2f       	mov	r24, r17
     78e:	9c 2f       	mov	r25, r28
     790:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
     794:	87 ff       	sbrs	r24, 7
     796:	04 c0       	rjmp	.+8      	; 0x7a0 <plan_compute_profile_nominal_speed+0x70>
     798:	f1 2c       	mov	r15, r1
     79a:	00 e0       	ldi	r16, 0x00	; 0
     79c:	10 e8       	ldi	r17, 0x80	; 128
     79e:	cf e3       	ldi	r28, 0x3F	; 63
     7a0:	6f 2d       	mov	r22, r15
     7a2:	70 2f       	mov	r23, r16
     7a4:	81 2f       	mov	r24, r17
     7a6:	9c 2f       	mov	r25, r28
     7a8:	df 91       	pop	r29
     7aa:	cf 91       	pop	r28
     7ac:	1f 91       	pop	r17
     7ae:	0f 91       	pop	r16
     7b0:	ff 90       	pop	r15
     7b2:	ef 90       	pop	r14
     7b4:	df 90       	pop	r13
     7b6:	cf 90       	pop	r12
     7b8:	bf 90       	pop	r11
     7ba:	08 95       	ret
     7bc:	82 fd       	sbrc	r24, 2
     7be:	19 c0       	rjmp	.+50     	; 0x7f2 <plan_compute_profile_nominal_speed+0xc2>
     7c0:	60 91 38 06 	lds	r22, 0x0638	; 0x800638 <sys+0x7>
     7c4:	70 e0       	ldi	r23, 0x00	; 0
     7c6:	90 e0       	ldi	r25, 0x00	; 0
     7c8:	80 e0       	ldi	r24, 0x00	; 0
     7ca:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
     7ce:	2a e0       	ldi	r18, 0x0A	; 10
     7d0:	37 ed       	ldi	r19, 0xD7	; 215
     7d2:	43 e2       	ldi	r20, 0x23	; 35
     7d4:	5c e3       	ldi	r21, 0x3C	; 60
     7d6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     7da:	9b 01       	movw	r18, r22
     7dc:	ac 01       	movw	r20, r24
     7de:	6b 2d       	mov	r22, r11
     7e0:	7c 2d       	mov	r23, r12
     7e2:	8d 2d       	mov	r24, r13
     7e4:	9e 2d       	mov	r25, r14
     7e6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     7ea:	b6 2e       	mov	r11, r22
     7ec:	c7 2e       	mov	r12, r23
     7ee:	d8 2e       	mov	r13, r24
     7f0:	e9 2e       	mov	r14, r25
     7f2:	fe a0       	ldd	r15, Y+38	; 0x26
     7f4:	0f a1       	ldd	r16, Y+39	; 0x27
     7f6:	18 a5       	ldd	r17, Y+40	; 0x28
     7f8:	c9 a5       	ldd	r28, Y+41	; 0x29
     7fa:	2b 2d       	mov	r18, r11
     7fc:	3c 2d       	mov	r19, r12
     7fe:	4d 2d       	mov	r20, r13
     800:	5e 2d       	mov	r21, r14
     802:	6f 2d       	mov	r22, r15
     804:	70 2f       	mov	r23, r16
     806:	81 2f       	mov	r24, r17
     808:	9c 2f       	mov	r25, r28
     80a:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     80e:	18 16       	cp	r1, r24
     810:	0c f0       	brlt	.+2      	; 0x814 <plan_compute_profile_nominal_speed+0xe4>
     812:	b6 cf       	rjmp	.-148    	; 0x780 <plan_compute_profile_nominal_speed+0x50>
     814:	fb 2c       	mov	r15, r11
     816:	86 01       	movw	r16, r12
     818:	ce 2d       	mov	r28, r14
     81a:	b2 cf       	rjmp	.-156    	; 0x780 <plan_compute_profile_nominal_speed+0x50>

0000081c <plan_get_current_block>:
     81c:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
     820:	90 91 f6 05 	lds	r25, 0x05F6	; 0x8005f6 <block_buffer_head>
     824:	98 17       	cp	r25, r24
     826:	39 f0       	breq	.+14     	; 0x836 <plan_get_current_block+0x1a>
     828:	22 e3       	ldi	r18, 0x32	; 50
     82a:	82 9f       	mul	r24, r18
     82c:	c0 01       	movw	r24, r0
     82e:	11 24       	eor	r1, r1
     830:	8a 52       	subi	r24, 0x2A	; 42
     832:	9d 4f       	sbci	r25, 0xFD	; 253
     834:	08 95       	ret
     836:	90 e0       	ldi	r25, 0x00	; 0
     838:	80 e0       	ldi	r24, 0x00	; 0
     83a:	08 95       	ret

0000083c <eeprom_put_char>:
     83c:	f8 94       	cli
     83e:	f9 99       	sbic	0x1f, 1	; 31
     840:	fe cf       	rjmp	.-4      	; 0x83e <eeprom_put_char+0x2>
     842:	92 bd       	out	0x22, r25	; 34
     844:	81 bd       	out	0x21, r24	; 33
     846:	81 e0       	ldi	r24, 0x01	; 1
     848:	8f bb       	out	0x1f, r24	; 31
     84a:	20 b5       	in	r18, 0x20	; 32
     84c:	86 2f       	mov	r24, r22
     84e:	82 27       	eor	r24, r18
     850:	08 2e       	mov	r0, r24
     852:	00 0c       	add	r0, r0
     854:	99 0b       	sbc	r25, r25
     856:	50 e0       	ldi	r21, 0x00	; 0
     858:	86 23       	and	r24, r22
     85a:	95 23       	and	r25, r21
     85c:	89 2b       	or	r24, r25
     85e:	49 f0       	breq	.+18     	; 0x872 <eeprom_put_char+0x36>
     860:	84 e1       	ldi	r24, 0x14	; 20
     862:	6f 3f       	cpi	r22, 0xFF	; 255
     864:	11 f0       	breq	.+4      	; 0x86a <eeprom_put_char+0x2e>
     866:	60 bd       	out	0x20, r22	; 32
     868:	84 e0       	ldi	r24, 0x04	; 4
     86a:	8f bb       	out	0x1f, r24	; 31
     86c:	f9 9a       	sbi	0x1f, 1	; 31
     86e:	78 94       	sei
     870:	08 95       	ret
     872:	26 17       	cp	r18, r22
     874:	e1 f3       	breq	.-8      	; 0x86e <eeprom_put_char+0x32>
     876:	60 bd       	out	0x20, r22	; 32
     878:	84 e2       	ldi	r24, 0x24	; 36
     87a:	f7 cf       	rjmp	.-18     	; 0x86a <eeprom_put_char+0x2e>

0000087c <memcpy_to_eeprom_with_checksum>:
     87c:	9f 92       	push	r9
     87e:	af 92       	push	r10
     880:	bf 92       	push	r11
     882:	cf 92       	push	r12
     884:	df 92       	push	r13
     886:	ef 92       	push	r14
     888:	ff 92       	push	r15
     88a:	0f 93       	push	r16
     88c:	1f 93       	push	r17
     88e:	cf 93       	push	r28
     890:	df 93       	push	r29
     892:	5c 01       	movw	r10, r24
     894:	8a 01       	movw	r16, r20
     896:	7b 01       	movw	r14, r22
     898:	e4 0e       	add	r14, r20
     89a:	f5 1e       	adc	r15, r21
     89c:	eb 01       	movw	r28, r22
     89e:	91 2c       	mov	r9, r1
     8a0:	6c 01       	movw	r12, r24
     8a2:	c6 1a       	sub	r12, r22
     8a4:	d7 0a       	sbc	r13, r23
     8a6:	ce 01       	movw	r24, r28
     8a8:	8c 0d       	add	r24, r12
     8aa:	9d 1d       	adc	r25, r13
     8ac:	21 e0       	ldi	r18, 0x01	; 1
     8ae:	91 10       	cpse	r9, r1
     8b0:	07 c0       	rjmp	.+14     	; 0x8c0 <memcpy_to_eeprom_with_checksum+0x44>
     8b2:	29 2d       	mov	r18, r9
     8b4:	99 0c       	add	r9, r9
     8b6:	33 0b       	sbc	r19, r19
     8b8:	23 2f       	mov	r18, r19
     8ba:	22 1f       	adc	r18, r18
     8bc:	22 27       	eor	r18, r18
     8be:	22 1f       	adc	r18, r18
     8c0:	69 91       	ld	r22, Y+
     8c2:	96 2e       	mov	r9, r22
     8c4:	92 0e       	add	r9, r18
     8c6:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
     8ca:	ce 15       	cp	r28, r14
     8cc:	df 05       	cpc	r29, r15
     8ce:	59 f7       	brne	.-42     	; 0x8a6 <memcpy_to_eeprom_with_checksum+0x2a>
     8d0:	69 2d       	mov	r22, r9
     8d2:	c5 01       	movw	r24, r10
     8d4:	80 0f       	add	r24, r16
     8d6:	91 1f       	adc	r25, r17
     8d8:	df 91       	pop	r29
     8da:	cf 91       	pop	r28
     8dc:	1f 91       	pop	r17
     8de:	0f 91       	pop	r16
     8e0:	ff 90       	pop	r15
     8e2:	ef 90       	pop	r14
     8e4:	df 90       	pop	r13
     8e6:	cf 90       	pop	r12
     8e8:	bf 90       	pop	r11
     8ea:	af 90       	pop	r10
     8ec:	9f 90       	pop	r9
     8ee:	0c 94 1e 04 	jmp	0x83c	; 0x83c <eeprom_put_char>

000008f2 <write_global_settings>:
     8f2:	6a e0       	ldi	r22, 0x0A	; 10
     8f4:	90 e0       	ldi	r25, 0x00	; 0
     8f6:	80 e0       	ldi	r24, 0x00	; 0
     8f8:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
     8fc:	45 e5       	ldi	r20, 0x55	; 85
     8fe:	50 e0       	ldi	r21, 0x00	; 0
     900:	62 e4       	ldi	r22, 0x42	; 66
     902:	76 e0       	ldi	r23, 0x06	; 6
     904:	81 e0       	ldi	r24, 0x01	; 1
     906:	90 e0       	ldi	r25, 0x00	; 0
     908:	0c 94 3e 04 	jmp	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>

0000090c <eeprom_get_char>:
     90c:	f9 99       	sbic	0x1f, 1	; 31
     90e:	fe cf       	rjmp	.-4      	; 0x90c <eeprom_get_char>
     910:	92 bd       	out	0x22, r25	; 34
     912:	81 bd       	out	0x21, r24	; 33
     914:	81 e0       	ldi	r24, 0x01	; 1
     916:	8f bb       	out	0x1f, r24	; 31
     918:	80 b5       	in	r24, 0x20	; 32
     91a:	08 95       	ret

0000091c <memcpy_from_eeprom_with_checksum>:
     91c:	9f 92       	push	r9
     91e:	af 92       	push	r10
     920:	bf 92       	push	r11
     922:	cf 92       	push	r12
     924:	df 92       	push	r13
     926:	ef 92       	push	r14
     928:	ff 92       	push	r15
     92a:	0f 93       	push	r16
     92c:	1f 93       	push	r17
     92e:	cf 93       	push	r28
     930:	df 93       	push	r29
     932:	5b 01       	movw	r10, r22
     934:	8a 01       	movw	r16, r20
     936:	7c 01       	movw	r14, r24
     938:	e4 0e       	add	r14, r20
     93a:	f5 1e       	adc	r15, r21
     93c:	ec 01       	movw	r28, r24
     93e:	91 2c       	mov	r9, r1
     940:	6b 01       	movw	r12, r22
     942:	c8 1a       	sub	r12, r24
     944:	d9 0a       	sbc	r13, r25
     946:	c6 01       	movw	r24, r12
     948:	8c 0f       	add	r24, r28
     94a:	9d 1f       	adc	r25, r29
     94c:	0e 94 86 04 	call	0x90c	; 0x90c <eeprom_get_char>
     950:	21 e0       	ldi	r18, 0x01	; 1
     952:	91 10       	cpse	r9, r1
     954:	07 c0       	rjmp	.+14     	; 0x964 <memcpy_from_eeprom_with_checksum+0x48>
     956:	29 2d       	mov	r18, r9
     958:	99 0c       	add	r9, r9
     95a:	33 0b       	sbc	r19, r19
     95c:	23 2f       	mov	r18, r19
     95e:	22 1f       	adc	r18, r18
     960:	22 27       	eor	r18, r18
     962:	22 1f       	adc	r18, r18
     964:	98 2e       	mov	r9, r24
     966:	92 0e       	add	r9, r18
     968:	89 93       	st	Y+, r24
     96a:	ce 15       	cp	r28, r14
     96c:	df 05       	cpc	r29, r15
     96e:	59 f7       	brne	.-42     	; 0x946 <memcpy_from_eeprom_with_checksum+0x2a>
     970:	c5 01       	movw	r24, r10
     972:	80 0f       	add	r24, r16
     974:	91 1f       	adc	r25, r17
     976:	0e 94 86 04 	call	0x90c	; 0x90c <eeprom_get_char>
     97a:	21 e0       	ldi	r18, 0x01	; 1
     97c:	30 e0       	ldi	r19, 0x00	; 0
     97e:	89 15       	cp	r24, r9
     980:	11 f0       	breq	.+4      	; 0x986 <memcpy_from_eeprom_with_checksum+0x6a>
     982:	30 e0       	ldi	r19, 0x00	; 0
     984:	20 e0       	ldi	r18, 0x00	; 0
     986:	c9 01       	movw	r24, r18
     988:	df 91       	pop	r29
     98a:	cf 91       	pop	r28
     98c:	1f 91       	pop	r17
     98e:	0f 91       	pop	r16
     990:	ff 90       	pop	r15
     992:	ef 90       	pop	r14
     994:	df 90       	pop	r13
     996:	cf 90       	pop	r12
     998:	bf 90       	pop	r11
     99a:	af 90       	pop	r10
     99c:	9f 90       	pop	r9
     99e:	08 95       	ret

000009a0 <st_update_plan_block_parameters>:
     9a0:	cf 93       	push	r28
     9a2:	df 93       	push	r29
     9a4:	c0 91 d1 02 	lds	r28, 0x02D1	; 0x8002d1 <pl_block>
     9a8:	d0 91 d2 02 	lds	r29, 0x02D2	; 0x8002d2 <pl_block+0x1>
     9ac:	20 97       	sbiw	r28, 0x00	; 0
     9ae:	c9 f0       	breq	.+50     	; 0x9e2 <st_update_plan_block_parameters+0x42>
     9b0:	80 91 a2 02 	lds	r24, 0x02A2	; 0x8002a2 <prep+0x1>
     9b4:	81 60       	ori	r24, 0x01	; 1
     9b6:	80 93 a2 02 	sts	0x02A2, r24	; 0x8002a2 <prep+0x1>
     9ba:	60 91 b8 02 	lds	r22, 0x02B8	; 0x8002b8 <prep+0x17>
     9be:	70 91 b9 02 	lds	r23, 0x02B9	; 0x8002b9 <prep+0x18>
     9c2:	80 91 ba 02 	lds	r24, 0x02BA	; 0x8002ba <prep+0x19>
     9c6:	90 91 bb 02 	lds	r25, 0x02BB	; 0x8002bb <prep+0x1a>
     9ca:	9b 01       	movw	r18, r22
     9cc:	ac 01       	movw	r20, r24
     9ce:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     9d2:	6a 8b       	std	Y+18, r22	; 0x12
     9d4:	7b 8b       	std	Y+19, r23	; 0x13
     9d6:	8c 8b       	std	Y+20, r24	; 0x14
     9d8:	9d 8b       	std	Y+21, r25	; 0x15
     9da:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
     9de:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
     9e2:	df 91       	pop	r29
     9e4:	cf 91       	pop	r28
     9e6:	08 95       	ret

000009e8 <planner_recalculate>:
     9e8:	2f 92       	push	r2
     9ea:	3f 92       	push	r3
     9ec:	4f 92       	push	r4
     9ee:	5f 92       	push	r5
     9f0:	6f 92       	push	r6
     9f2:	7f 92       	push	r7
     9f4:	8f 92       	push	r8
     9f6:	9f 92       	push	r9
     9f8:	af 92       	push	r10
     9fa:	bf 92       	push	r11
     9fc:	cf 92       	push	r12
     9fe:	df 92       	push	r13
     a00:	ef 92       	push	r14
     a02:	ff 92       	push	r15
     a04:	0f 93       	push	r16
     a06:	1f 93       	push	r17
     a08:	cf 93       	push	r28
     a0a:	df 93       	push	r29
     a0c:	00 d0       	rcall	.+0      	; 0xa0e <planner_recalculate+0x26>
     a0e:	00 d0       	rcall	.+0      	; 0xa10 <planner_recalculate+0x28>
     a10:	cd b7       	in	r28, 0x3d	; 61
     a12:	de b7       	in	r29, 0x3e	; 62
     a14:	00 91 f6 05 	lds	r16, 0x05F6	; 0x8005f6 <block_buffer_head>
     a18:	00 23       	and	r16, r16
     a1a:	09 f4       	brne	.+2      	; 0xa1e <planner_recalculate+0x36>
     a1c:	79 c0       	rjmp	.+242    	; 0xb10 <planner_recalculate+0x128>
     a1e:	09 83       	std	Y+1, r16	; 0x01
     a20:	39 81       	ldd	r19, Y+1	; 0x01
     a22:	31 50       	subi	r19, 0x01	; 1
     a24:	39 83       	std	Y+1, r19	; 0x01
     a26:	10 91 d3 02 	lds	r17, 0x02D3	; 0x8002d3 <block_buffer_planned>
     a2a:	13 17       	cp	r17, r19
     a2c:	09 f4       	brne	.+2      	; 0xa30 <planner_recalculate+0x48>
     a2e:	59 c0       	rjmp	.+178    	; 0xae2 <planner_recalculate+0xfa>
     a30:	e2 e3       	ldi	r30, 0x32	; 50
     a32:	3e 9f       	mul	r19, r30
     a34:	c0 01       	movw	r24, r0
     a36:	11 24       	eor	r1, r1
     a38:	9c 01       	movw	r18, r24
     a3a:	2a 52       	subi	r18, 0x2A	; 42
     a3c:	3d 4f       	sbci	r19, 0xFD	; 253
     a3e:	79 01       	movw	r14, r18
     a40:	f9 01       	movw	r30, r18
     a42:	26 8d       	ldd	r18, Z+30	; 0x1e
     a44:	37 8d       	ldd	r19, Z+31	; 0x1f
     a46:	40 a1       	ldd	r20, Z+32	; 0x20
     a48:	51 a1       	ldd	r21, Z+33	; 0x21
     a4a:	62 8d       	ldd	r22, Z+26	; 0x1a
     a4c:	73 8d       	ldd	r23, Z+27	; 0x1b
     a4e:	84 8d       	ldd	r24, Z+28	; 0x1c
     a50:	95 8d       	ldd	r25, Z+29	; 0x1d
     a52:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     a56:	9b 01       	movw	r18, r22
     a58:	ac 01       	movw	r20, r24
     a5a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     a5e:	f7 01       	movw	r30, r14
     a60:	76 88       	ldd	r7, Z+22	; 0x16
     a62:	87 88       	ldd	r8, Z+23	; 0x17
     a64:	90 8c       	ldd	r9, Z+24	; 0x18
     a66:	a1 8c       	ldd	r10, Z+25	; 0x19
     a68:	b6 2e       	mov	r11, r22
     a6a:	c7 2e       	mov	r12, r23
     a6c:	d8 2e       	mov	r13, r24
     a6e:	9b 83       	std	Y+3, r25	; 0x03
     a70:	27 2d       	mov	r18, r7
     a72:	38 2d       	mov	r19, r8
     a74:	49 2d       	mov	r20, r9
     a76:	5a 2d       	mov	r21, r10
     a78:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     a7c:	18 16       	cp	r1, r24
     a7e:	1c f4       	brge	.+6      	; 0xa86 <planner_recalculate+0x9e>
     a80:	b7 2c       	mov	r11, r7
     a82:	64 01       	movw	r12, r8
     a84:	ab 82       	std	Y+3, r10	; 0x03
     a86:	4b 2d       	mov	r20, r11
     a88:	5c 2d       	mov	r21, r12
     a8a:	6d 2d       	mov	r22, r13
     a8c:	7b 81       	ldd	r23, Y+3	; 0x03
     a8e:	f7 01       	movw	r30, r14
     a90:	42 8b       	std	Z+18, r20	; 0x12
     a92:	53 8b       	std	Z+19, r21	; 0x13
     a94:	64 8b       	std	Z+20, r22	; 0x14
     a96:	75 8b       	std	Z+21, r23	; 0x15
     a98:	f9 81       	ldd	r31, Y+1	; 0x01
     a9a:	8f 2f       	mov	r24, r31
     a9c:	f1 11       	cpse	r31, r1
     a9e:	01 c0       	rjmp	.+2      	; 0xaa2 <planner_recalculate+0xba>
     aa0:	80 e1       	ldi	r24, 0x10	; 16
     aa2:	ff 24       	eor	r15, r15
     aa4:	fa 94       	dec	r15
     aa6:	f8 0e       	add	r15, r24
     aa8:	30 90 d5 02 	lds	r3, 0x02D5	; 0x8002d5 <block_buffer_tail>
     aac:	1f 11       	cpse	r17, r15
     aae:	33 c0       	rjmp	.+102    	; 0xb16 <planner_recalculate+0x12e>
     ab0:	13 11       	cpse	r17, r3
     ab2:	02 c0       	rjmp	.+4      	; 0xab8 <planner_recalculate+0xd0>
     ab4:	0e 94 d0 04 	call	0x9a0	; 0x9a0 <st_update_plan_block_parameters>
     ab8:	e2 e3       	ldi	r30, 0x32	; 50
     aba:	1e 9f       	mul	r17, r30
     abc:	c0 01       	movw	r24, r0
     abe:	11 24       	eor	r1, r1
     ac0:	8a 52       	subi	r24, 0x2A	; 42
     ac2:	9d 4f       	sbci	r25, 0xFD	; 253
     ac4:	9a 83       	std	Y+2, r25	; 0x02
     ac6:	89 83       	std	Y+1, r24	; 0x01
     ac8:	33 24       	eor	r3, r3
     aca:	33 94       	inc	r3
     acc:	31 0e       	add	r3, r17
     ace:	f0 e1       	ldi	r31, 0x10	; 16
     ad0:	3f 12       	cpse	r3, r31
     ad2:	01 c0       	rjmp	.+2      	; 0xad6 <planner_recalculate+0xee>
     ad4:	31 2c       	mov	r3, r1
     ad6:	82 e3       	ldi	r24, 0x32	; 50
     ad8:	28 2e       	mov	r2, r24
     ada:	03 11       	cpse	r16, r3
     adc:	84 c0       	rjmp	.+264    	; 0xbe6 <planner_recalculate+0x1fe>
     ade:	10 93 d3 02 	sts	0x02D3, r17	; 0x8002d3 <block_buffer_planned>
     ae2:	0f 90       	pop	r0
     ae4:	0f 90       	pop	r0
     ae6:	0f 90       	pop	r0
     ae8:	0f 90       	pop	r0
     aea:	df 91       	pop	r29
     aec:	cf 91       	pop	r28
     aee:	1f 91       	pop	r17
     af0:	0f 91       	pop	r16
     af2:	ff 90       	pop	r15
     af4:	ef 90       	pop	r14
     af6:	df 90       	pop	r13
     af8:	cf 90       	pop	r12
     afa:	bf 90       	pop	r11
     afc:	af 90       	pop	r10
     afe:	9f 90       	pop	r9
     b00:	8f 90       	pop	r8
     b02:	7f 90       	pop	r7
     b04:	6f 90       	pop	r6
     b06:	5f 90       	pop	r5
     b08:	4f 90       	pop	r4
     b0a:	3f 90       	pop	r3
     b0c:	2f 90       	pop	r2
     b0e:	08 95       	ret
     b10:	20 e1       	ldi	r18, 0x10	; 16
     b12:	29 83       	std	Y+1, r18	; 0x01
     b14:	85 cf       	rjmp	.-246    	; 0xa20 <planner_recalculate+0x38>
     b16:	29 81       	ldd	r18, Y+1	; 0x01
     b18:	82 e3       	ldi	r24, 0x32	; 50
     b1a:	28 9f       	mul	r18, r24
     b1c:	90 01       	movw	r18, r0
     b1e:	11 24       	eor	r1, r1
     b20:	2a 52       	subi	r18, 0x2A	; 42
     b22:	3d 4f       	sbci	r19, 0xFD	; 253
     b24:	3c 83       	std	Y+4, r19	; 0x04
     b26:	2b 83       	std	Y+3, r18	; 0x03
     b28:	22 e3       	ldi	r18, 0x32	; 50
     b2a:	e2 2e       	mov	r14, r18
     b2c:	8f 2c       	mov	r8, r15
     b2e:	91 2c       	mov	r9, r1
     b30:	fe 9c       	mul	r15, r14
     b32:	c0 01       	movw	r24, r0
     b34:	11 24       	eor	r1, r1
     b36:	fc 01       	movw	r30, r24
     b38:	ea 52       	subi	r30, 0x2A	; 42
     b3a:	fd 4f       	sbci	r31, 0xFD	; 253
     b3c:	fa 83       	std	Y+2, r31	; 0x02
     b3e:	e9 83       	std	Y+1, r30	; 0x01
     b40:	f1 10       	cpse	r15, r1
     b42:	02 c0       	rjmp	.+4      	; 0xb48 <planner_recalculate+0x160>
     b44:	90 e1       	ldi	r25, 0x10	; 16
     b46:	f9 2e       	mov	r15, r25
     b48:	fa 94       	dec	r15
     b4a:	f3 10       	cpse	r15, r3
     b4c:	02 c0       	rjmp	.+4      	; 0xb52 <planner_recalculate+0x16a>
     b4e:	0e 94 d0 04 	call	0x9a0	; 0x9a0 <st_update_plan_block_parameters>
     b52:	e8 9c       	mul	r14, r8
     b54:	c0 01       	movw	r24, r0
     b56:	e9 9c       	mul	r14, r9
     b58:	90 0d       	add	r25, r0
     b5a:	11 24       	eor	r1, r1
     b5c:	9c 01       	movw	r18, r24
     b5e:	2a 52       	subi	r18, 0x2A	; 42
     b60:	3d 4f       	sbci	r19, 0xFD	; 253
     b62:	69 01       	movw	r12, r18
     b64:	f9 01       	movw	r30, r18
     b66:	46 88       	ldd	r4, Z+22	; 0x16
     b68:	57 88       	ldd	r5, Z+23	; 0x17
     b6a:	60 8c       	ldd	r6, Z+24	; 0x18
     b6c:	71 8c       	ldd	r7, Z+25	; 0x19
     b6e:	a3 01       	movw	r20, r6
     b70:	92 01       	movw	r18, r4
     b72:	62 89       	ldd	r22, Z+18	; 0x12
     b74:	73 89       	ldd	r23, Z+19	; 0x13
     b76:	84 89       	ldd	r24, Z+20	; 0x14
     b78:	95 89       	ldd	r25, Z+21	; 0x15
     b7a:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     b7e:	88 23       	and	r24, r24
     b80:	31 f1       	breq	.+76     	; 0xbce <planner_recalculate+0x1e6>
     b82:	f6 01       	movw	r30, r12
     b84:	26 8d       	ldd	r18, Z+30	; 0x1e
     b86:	37 8d       	ldd	r19, Z+31	; 0x1f
     b88:	40 a1       	ldd	r20, Z+32	; 0x20
     b8a:	51 a1       	ldd	r21, Z+33	; 0x21
     b8c:	62 8d       	ldd	r22, Z+26	; 0x1a
     b8e:	73 8d       	ldd	r23, Z+27	; 0x1b
     b90:	84 8d       	ldd	r24, Z+28	; 0x1c
     b92:	95 8d       	ldd	r25, Z+29	; 0x1d
     b94:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     b98:	9b 01       	movw	r18, r22
     b9a:	ac 01       	movw	r20, r24
     b9c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     ba0:	eb 81       	ldd	r30, Y+3	; 0x03
     ba2:	fc 81       	ldd	r31, Y+4	; 0x04
     ba4:	22 89       	ldd	r18, Z+18	; 0x12
     ba6:	33 89       	ldd	r19, Z+19	; 0x13
     ba8:	44 89       	ldd	r20, Z+20	; 0x14
     baa:	55 89       	ldd	r21, Z+21	; 0x15
     bac:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     bb0:	4b 01       	movw	r8, r22
     bb2:	5c 01       	movw	r10, r24
     bb4:	ac 01       	movw	r20, r24
     bb6:	9b 01       	movw	r18, r22
     bb8:	c3 01       	movw	r24, r6
     bba:	b2 01       	movw	r22, r4
     bbc:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
     bc0:	f6 01       	movw	r30, r12
     bc2:	18 16       	cp	r1, r24
     bc4:	5c f4       	brge	.+22     	; 0xbdc <planner_recalculate+0x1f4>
     bc6:	82 8a       	std	Z+18, r8	; 0x12
     bc8:	93 8a       	std	Z+19, r9	; 0x13
     bca:	a4 8a       	std	Z+20, r10	; 0x14
     bcc:	b5 8a       	std	Z+21, r11	; 0x15
     bce:	29 81       	ldd	r18, Y+1	; 0x01
     bd0:	3a 81       	ldd	r19, Y+2	; 0x02
     bd2:	3c 83       	std	Y+4, r19	; 0x04
     bd4:	2b 83       	std	Y+3, r18	; 0x03
     bd6:	1f 11       	cpse	r17, r15
     bd8:	a9 cf       	rjmp	.-174    	; 0xb2c <planner_recalculate+0x144>
     bda:	6e cf       	rjmp	.-292    	; 0xab8 <planner_recalculate+0xd0>
     bdc:	42 8a       	std	Z+18, r4	; 0x12
     bde:	53 8a       	std	Z+19, r5	; 0x13
     be0:	64 8a       	std	Z+20, r6	; 0x14
     be2:	75 8a       	std	Z+21, r7	; 0x15
     be4:	f4 cf       	rjmp	.-24     	; 0xbce <planner_recalculate+0x1e6>
     be6:	c3 2c       	mov	r12, r3
     be8:	d1 2c       	mov	r13, r1
     bea:	32 9c       	mul	r3, r2
     bec:	c0 01       	movw	r24, r0
     bee:	11 24       	eor	r1, r1
     bf0:	9c 01       	movw	r18, r24
     bf2:	2a 52       	subi	r18, 0x2A	; 42
     bf4:	3d 4f       	sbci	r19, 0xFD	; 253
     bf6:	79 01       	movw	r14, r18
     bf8:	e9 81       	ldd	r30, Y+1	; 0x01
     bfa:	fa 81       	ldd	r31, Y+2	; 0x02
     bfc:	42 88       	ldd	r4, Z+18	; 0x12
     bfe:	53 88       	ldd	r5, Z+19	; 0x13
     c00:	64 88       	ldd	r6, Z+20	; 0x14
     c02:	75 88       	ldd	r7, Z+21	; 0x15
     c04:	f9 01       	movw	r30, r18
     c06:	82 88       	ldd	r8, Z+18	; 0x12
     c08:	93 88       	ldd	r9, Z+19	; 0x13
     c0a:	a4 88       	ldd	r10, Z+20	; 0x14
     c0c:	b5 88       	ldd	r11, Z+21	; 0x15
     c0e:	a5 01       	movw	r20, r10
     c10:	94 01       	movw	r18, r8
     c12:	c3 01       	movw	r24, r6
     c14:	b2 01       	movw	r22, r4
     c16:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     c1a:	87 ff       	sbrs	r24, 7
     c1c:	24 c0       	rjmp	.+72     	; 0xc66 <planner_recalculate+0x27e>
     c1e:	e9 81       	ldd	r30, Y+1	; 0x01
     c20:	fa 81       	ldd	r31, Y+2	; 0x02
     c22:	26 8d       	ldd	r18, Z+30	; 0x1e
     c24:	37 8d       	ldd	r19, Z+31	; 0x1f
     c26:	40 a1       	ldd	r20, Z+32	; 0x20
     c28:	51 a1       	ldd	r21, Z+33	; 0x21
     c2a:	62 8d       	ldd	r22, Z+26	; 0x1a
     c2c:	73 8d       	ldd	r23, Z+27	; 0x1b
     c2e:	84 8d       	ldd	r24, Z+28	; 0x1c
     c30:	95 8d       	ldd	r25, Z+29	; 0x1d
     c32:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     c36:	9b 01       	movw	r18, r22
     c38:	ac 01       	movw	r20, r24
     c3a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     c3e:	a3 01       	movw	r20, r6
     c40:	92 01       	movw	r18, r4
     c42:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     c46:	2b 01       	movw	r4, r22
     c48:	3c 01       	movw	r6, r24
     c4a:	ac 01       	movw	r20, r24
     c4c:	9b 01       	movw	r18, r22
     c4e:	c5 01       	movw	r24, r10
     c50:	b4 01       	movw	r22, r8
     c52:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
     c56:	18 16       	cp	r1, r24
     c58:	34 f4       	brge	.+12     	; 0xc66 <planner_recalculate+0x27e>
     c5a:	f7 01       	movw	r30, r14
     c5c:	42 8a       	std	Z+18, r4	; 0x12
     c5e:	53 8a       	std	Z+19, r5	; 0x13
     c60:	64 8a       	std	Z+20, r6	; 0x14
     c62:	75 8a       	std	Z+21, r7	; 0x15
     c64:	13 2d       	mov	r17, r3
     c66:	2c 9c       	mul	r2, r12
     c68:	f0 01       	movw	r30, r0
     c6a:	2d 9c       	mul	r2, r13
     c6c:	f0 0d       	add	r31, r0
     c6e:	11 24       	eor	r1, r1
     c70:	ea 52       	subi	r30, 0x2A	; 42
     c72:	fd 4f       	sbci	r31, 0xFD	; 253
     c74:	26 89       	ldd	r18, Z+22	; 0x16
     c76:	37 89       	ldd	r19, Z+23	; 0x17
     c78:	40 8d       	ldd	r20, Z+24	; 0x18
     c7a:	51 8d       	ldd	r21, Z+25	; 0x19
     c7c:	62 89       	ldd	r22, Z+18	; 0x12
     c7e:	73 89       	ldd	r23, Z+19	; 0x13
     c80:	84 89       	ldd	r24, Z+20	; 0x14
     c82:	95 89       	ldd	r25, Z+21	; 0x15
     c84:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     c88:	81 11       	cpse	r24, r1
     c8a:	01 c0       	rjmp	.+2      	; 0xc8e <planner_recalculate+0x2a6>
     c8c:	13 2d       	mov	r17, r3
     c8e:	33 94       	inc	r3
     c90:	f0 e1       	ldi	r31, 0x10	; 16
     c92:	3f 12       	cpse	r3, r31
     c94:	01 c0       	rjmp	.+2      	; 0xc98 <planner_recalculate+0x2b0>
     c96:	31 2c       	mov	r3, r1
     c98:	fa 82       	std	Y+2, r15	; 0x02
     c9a:	e9 82       	std	Y+1, r14	; 0x01
     c9c:	1e cf       	rjmp	.-452    	; 0xada <planner_recalculate+0xf2>

00000c9e <st_generate_step_dir_invert_masks>:
     c9e:	90 91 73 06 	lds	r25, 0x0673	; 0x800673 <settings+0x31>
     ca2:	49 2f       	mov	r20, r25
     ca4:	80 91 74 06 	lds	r24, 0x0674	; 0x800674 <settings+0x32>
     ca8:	28 2f       	mov	r18, r24
     caa:	90 ff       	sbrs	r25, 0
     cac:	11 c0       	rjmp	.+34     	; 0xcd0 <st_generate_step_dir_invert_masks+0x32>
     cae:	94 e0       	ldi	r25, 0x04	; 4
     cb0:	80 ff       	sbrs	r24, 0
     cb2:	10 c0       	rjmp	.+32     	; 0xcd4 <st_generate_step_dir_invert_masks+0x36>
     cb4:	80 e2       	ldi	r24, 0x20	; 32
     cb6:	41 fd       	sbrc	r20, 1
     cb8:	98 60       	ori	r25, 0x08	; 8
     cba:	21 fd       	sbrc	r18, 1
     cbc:	80 64       	ori	r24, 0x40	; 64
     cbe:	42 fd       	sbrc	r20, 2
     cc0:	90 61       	ori	r25, 0x10	; 16
     cc2:	22 fd       	sbrc	r18, 2
     cc4:	80 68       	ori	r24, 0x80	; 128
     cc6:	90 93 f2 01 	sts	0x01F2, r25	; 0x8001f2 <step_port_invert_mask>
     cca:	80 93 f3 01 	sts	0x01F3, r24	; 0x8001f3 <dir_port_invert_mask>
     cce:	08 95       	ret
     cd0:	90 e0       	ldi	r25, 0x00	; 0
     cd2:	ee cf       	rjmp	.-36     	; 0xcb0 <st_generate_step_dir_invert_masks+0x12>
     cd4:	80 e0       	ldi	r24, 0x00	; 0
     cd6:	ef cf       	rjmp	.-34     	; 0xcb6 <st_generate_step_dir_invert_masks+0x18>

00000cd8 <st_wake_up>:
     cd8:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
     cdc:	82 ff       	sbrs	r24, 2
     cde:	13 c0       	rjmp	.+38     	; 0xd06 <st_wake_up+0x2e>
     ce0:	28 9a       	sbi	0x05, 0	; 5
     ce2:	80 91 f2 01 	lds	r24, 0x01F2	; 0x8001f2 <step_port_invert_mask>
     ce6:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
     cea:	80 91 72 06 	lds	r24, 0x0672	; 0x800672 <settings+0x30>
     cee:	82 50       	subi	r24, 0x02	; 2
     cf0:	99 0b       	sbc	r25, r25
     cf2:	88 0f       	add	r24, r24
     cf4:	81 95       	neg	r24
     cf6:	80 93 02 02 	sts	0x0202, r24	; 0x800202 <st+0xd>
     cfa:	80 91 6f 00 	lds	r24, 0x006F	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
     cfe:	82 60       	ori	r24, 0x02	; 2
     d00:	80 93 6f 00 	sts	0x006F, r24	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
     d04:	08 95       	ret
     d06:	28 98       	cbi	0x05, 0	; 5
     d08:	ec cf       	rjmp	.-40     	; 0xce2 <st_wake_up+0xa>

00000d0a <protocol_auto_cycle_start>:
     d0a:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
     d0e:	89 2b       	or	r24, r25
     d10:	19 f0       	breq	.+6      	; 0xd18 <protocol_auto_cycle_start+0xe>
     d12:	82 e0       	ldi	r24, 0x02	; 2
     d14:	0c 94 4b 02 	jmp	0x496	; 0x496 <system_set_exec_state_flag>
     d18:	08 95       	ret

00000d1a <serial_write>:
     d1a:	e0 91 04 01 	lds	r30, 0x0104	; 0x800104 <serial_tx_buffer_head>
     d1e:	91 e0       	ldi	r25, 0x01	; 1
     d20:	9e 0f       	add	r25, r30
     d22:	99 36       	cpi	r25, 0x69	; 105
     d24:	09 f4       	brne	.+2      	; 0xd28 <serial_write+0xe>
     d26:	90 e0       	ldi	r25, 0x00	; 0
     d28:	20 91 6e 01 	lds	r18, 0x016E	; 0x80016e <serial_tx_buffer_tail>
     d2c:	29 17       	cp	r18, r25
     d2e:	61 f0       	breq	.+24     	; 0xd48 <serial_write+0x2e>
     d30:	f0 e0       	ldi	r31, 0x00	; 0
     d32:	eb 5f       	subi	r30, 0xFB	; 251
     d34:	fe 4f       	sbci	r31, 0xFE	; 254
     d36:	80 83       	st	Z, r24
     d38:	90 93 04 01 	sts	0x0104, r25	; 0x800104 <serial_tx_buffer_head>
     d3c:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
     d40:	80 62       	ori	r24, 0x20	; 32
     d42:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
     d46:	04 c0       	rjmp	.+8      	; 0xd50 <serial_write+0x36>
     d48:	20 91 13 06 	lds	r18, 0x0613	; 0x800613 <sys_rt_exec_state>
     d4c:	24 ff       	sbrs	r18, 4
     d4e:	ec cf       	rjmp	.-40     	; 0xd28 <serial_write+0xe>
     d50:	08 95       	ret

00000d52 <printString.constprop.9>:
     d52:	cf 93       	push	r28
     d54:	df 93       	push	r29
     d56:	c1 e1       	ldi	r28, 0x11	; 17
     d58:	d7 e0       	ldi	r29, 0x07	; 7
     d5a:	89 91       	ld	r24, Y+
     d5c:	81 11       	cpse	r24, r1
     d5e:	03 c0       	rjmp	.+6      	; 0xd66 <printString.constprop.9+0x14>
     d60:	df 91       	pop	r29
     d62:	cf 91       	pop	r28
     d64:	08 95       	ret
     d66:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     d6a:	f7 cf       	rjmp	.-18     	; 0xd5a <printString.constprop.9+0x8>

00000d6c <printFloat>:
     d6c:	8f 92       	push	r8
     d6e:	9f 92       	push	r9
     d70:	af 92       	push	r10
     d72:	bf 92       	push	r11
     d74:	cf 92       	push	r12
     d76:	df 92       	push	r13
     d78:	ef 92       	push	r14
     d7a:	ff 92       	push	r15
     d7c:	0f 93       	push	r16
     d7e:	1f 93       	push	r17
     d80:	cf 93       	push	r28
     d82:	df 93       	push	r29
     d84:	cd b7       	in	r28, 0x3d	; 61
     d86:	de b7       	in	r29, 0x3e	; 62
     d88:	2d 97       	sbiw	r28, 0x0d	; 13
     d8a:	0f b6       	in	r0, 0x3f	; 63
     d8c:	f8 94       	cli
     d8e:	de bf       	out	0x3e, r29	; 62
     d90:	0f be       	out	0x3f, r0	; 63
     d92:	cd bf       	out	0x3d, r28	; 61
     d94:	6b 01       	movw	r12, r22
     d96:	7c 01       	movw	r14, r24
     d98:	04 2f       	mov	r16, r20
     d9a:	20 e0       	ldi	r18, 0x00	; 0
     d9c:	30 e0       	ldi	r19, 0x00	; 0
     d9e:	a9 01       	movw	r20, r18
     da0:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
     da4:	87 ff       	sbrs	r24, 7
     da6:	07 c0       	rjmp	.+14     	; 0xdb6 <printFloat+0x4a>
     da8:	8d e2       	ldi	r24, 0x2D	; 45
     daa:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     dae:	f7 fa       	bst	r15, 7
     db0:	f0 94       	com	r15
     db2:	f7 f8       	bld	r15, 7
     db4:	f0 94       	com	r15
     db6:	10 2f       	mov	r17, r16
     db8:	12 30       	cpi	r17, 0x02	; 2
     dba:	08 f0       	brcs	.+2      	; 0xdbe <printFloat+0x52>
     dbc:	54 c0       	rjmp	.+168    	; 0xe66 <printFloat+0xfa>
     dbe:	00 ff       	sbrs	r16, 0
     dc0:	0a c0       	rjmp	.+20     	; 0xdd6 <printFloat+0x6a>
     dc2:	20 e0       	ldi	r18, 0x00	; 0
     dc4:	30 e0       	ldi	r19, 0x00	; 0
     dc6:	40 e2       	ldi	r20, 0x20	; 32
     dc8:	51 e4       	ldi	r21, 0x41	; 65
     dca:	c7 01       	movw	r24, r14
     dcc:	b6 01       	movw	r22, r12
     dce:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     dd2:	6b 01       	movw	r12, r22
     dd4:	7c 01       	movw	r14, r24
     dd6:	20 e0       	ldi	r18, 0x00	; 0
     dd8:	30 e0       	ldi	r19, 0x00	; 0
     dda:	40 e0       	ldi	r20, 0x00	; 0
     ddc:	5f e3       	ldi	r21, 0x3F	; 63
     dde:	c7 01       	movw	r24, r14
     de0:	b6 01       	movw	r22, r12
     de2:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
     de6:	0e 94 82 36 	call	0x6d04	; 0x6d04 <__fixsfsi>
     dea:	10 e0       	ldi	r17, 0x00	; 0
     dec:	3a e0       	ldi	r19, 0x0A	; 10
     dee:	83 2e       	mov	r8, r19
     df0:	91 2c       	mov	r9, r1
     df2:	a1 2c       	mov	r10, r1
     df4:	b1 2c       	mov	r11, r1
     df6:	e1 2f       	mov	r30, r17
     df8:	f0 e0       	ldi	r31, 0x00	; 0
     dfa:	61 15       	cp	r22, r1
     dfc:	71 05       	cpc	r23, r1
     dfe:	81 05       	cpc	r24, r1
     e00:	91 05       	cpc	r25, r1
     e02:	e9 f5       	brne	.+122    	; 0xe7e <printFloat+0x112>
     e04:	81 e0       	ldi	r24, 0x01	; 1
     e06:	90 e0       	ldi	r25, 0x00	; 0
     e08:	8c 0f       	add	r24, r28
     e0a:	9d 1f       	adc	r25, r29
     e0c:	e8 0f       	add	r30, r24
     e0e:	f9 1f       	adc	r31, r25
     e10:	80 e3       	ldi	r24, 0x30	; 48
     e12:	10 17       	cp	r17, r16
     e14:	08 f4       	brcc	.+2      	; 0xe18 <printFloat+0xac>
     e16:	45 c0       	rjmp	.+138    	; 0xea2 <printFloat+0x136>
     e18:	10 13       	cpse	r17, r16
     e1a:	09 c0       	rjmp	.+18     	; 0xe2e <printFloat+0xc2>
     e1c:	e1 e0       	ldi	r30, 0x01	; 1
     e1e:	f0 e0       	ldi	r31, 0x00	; 0
     e20:	ec 0f       	add	r30, r28
     e22:	fd 1f       	adc	r31, r29
     e24:	e1 0f       	add	r30, r17
     e26:	f1 1d       	adc	r31, r1
     e28:	80 e3       	ldi	r24, 0x30	; 48
     e2a:	80 83       	st	Z, r24
     e2c:	1f 5f       	subi	r17, 0xFF	; 255
     e2e:	ee 24       	eor	r14, r14
     e30:	e3 94       	inc	r14
     e32:	f1 2c       	mov	r15, r1
     e34:	ec 0e       	add	r14, r28
     e36:	fd 1e       	adc	r15, r29
     e38:	e1 0e       	add	r14, r17
     e3a:	f1 1c       	adc	r15, r1
     e3c:	11 11       	cpse	r17, r1
     e3e:	34 c0       	rjmp	.+104    	; 0xea8 <printFloat+0x13c>
     e40:	2d 96       	adiw	r28, 0x0d	; 13
     e42:	0f b6       	in	r0, 0x3f	; 63
     e44:	f8 94       	cli
     e46:	de bf       	out	0x3e, r29	; 62
     e48:	0f be       	out	0x3f, r0	; 63
     e4a:	cd bf       	out	0x3d, r28	; 61
     e4c:	df 91       	pop	r29
     e4e:	cf 91       	pop	r28
     e50:	1f 91       	pop	r17
     e52:	0f 91       	pop	r16
     e54:	ff 90       	pop	r15
     e56:	ef 90       	pop	r14
     e58:	df 90       	pop	r13
     e5a:	cf 90       	pop	r12
     e5c:	bf 90       	pop	r11
     e5e:	af 90       	pop	r10
     e60:	9f 90       	pop	r9
     e62:	8f 90       	pop	r8
     e64:	08 95       	ret
     e66:	20 e0       	ldi	r18, 0x00	; 0
     e68:	30 e0       	ldi	r19, 0x00	; 0
     e6a:	48 ec       	ldi	r20, 0xC8	; 200
     e6c:	52 e4       	ldi	r21, 0x42	; 66
     e6e:	c7 01       	movw	r24, r14
     e70:	b6 01       	movw	r22, r12
     e72:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     e76:	6b 01       	movw	r12, r22
     e78:	7c 01       	movw	r14, r24
     e7a:	12 50       	subi	r17, 0x02	; 2
     e7c:	9d cf       	rjmp	.-198    	; 0xdb8 <printFloat+0x4c>
     e7e:	ee 24       	eor	r14, r14
     e80:	e3 94       	inc	r14
     e82:	f1 2c       	mov	r15, r1
     e84:	ec 0e       	add	r14, r28
     e86:	fd 1e       	adc	r15, r29
     e88:	ee 0e       	add	r14, r30
     e8a:	ff 1e       	adc	r15, r31
     e8c:	a5 01       	movw	r20, r10
     e8e:	94 01       	movw	r18, r8
     e90:	0e 94 86 39 	call	0x730c	; 0x730c <__udivmodsi4>
     e94:	60 5d       	subi	r22, 0xD0	; 208
     e96:	f7 01       	movw	r30, r14
     e98:	60 83       	st	Z, r22
     e9a:	b9 01       	movw	r22, r18
     e9c:	ca 01       	movw	r24, r20
     e9e:	1f 5f       	subi	r17, 0xFF	; 255
     ea0:	aa cf       	rjmp	.-172    	; 0xdf6 <printFloat+0x8a>
     ea2:	1f 5f       	subi	r17, 0xFF	; 255
     ea4:	81 93       	st	Z+, r24
     ea6:	b5 cf       	rjmp	.-150    	; 0xe12 <printFloat+0xa6>
     ea8:	10 13       	cpse	r17, r16
     eaa:	03 c0       	rjmp	.+6      	; 0xeb2 <printFloat+0x146>
     eac:	8e e2       	ldi	r24, 0x2E	; 46
     eae:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     eb2:	f7 01       	movw	r30, r14
     eb4:	82 91       	ld	r24, -Z
     eb6:	7f 01       	movw	r14, r30
     eb8:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     ebc:	11 50       	subi	r17, 0x01	; 1
     ebe:	be cf       	rjmp	.-132    	; 0xe3c <printFloat+0xd0>

00000ec0 <printFloat_RateValue>:
     ec0:	20 91 87 06 	lds	r18, 0x0687	; 0x800687 <settings+0x45>
     ec4:	40 e0       	ldi	r20, 0x00	; 0
     ec6:	20 ff       	sbrs	r18, 0
     ec8:	07 c0       	rjmp	.+14     	; 0xed8 <printFloat_RateValue+0x18>
     eca:	2b e8       	ldi	r18, 0x8B	; 139
     ecc:	32 e4       	ldi	r19, 0x42	; 66
     ece:	41 e2       	ldi	r20, 0x21	; 33
     ed0:	5d e3       	ldi	r21, 0x3D	; 61
     ed2:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     ed6:	41 e0       	ldi	r20, 0x01	; 1
     ed8:	0c 94 b6 06 	jmp	0xd6c	; 0xd6c <printFloat>

00000edc <printFloat_CoordValue>:
     edc:	20 91 87 06 	lds	r18, 0x0687	; 0x800687 <settings+0x45>
     ee0:	43 e0       	ldi	r20, 0x03	; 3
     ee2:	20 ff       	sbrs	r18, 0
     ee4:	07 c0       	rjmp	.+14     	; 0xef4 <printFloat_CoordValue+0x18>
     ee6:	2b e8       	ldi	r18, 0x8B	; 139
     ee8:	32 e4       	ldi	r19, 0x42	; 66
     eea:	41 e2       	ldi	r20, 0x21	; 33
     eec:	5d e3       	ldi	r21, 0x3D	; 61
     eee:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
     ef2:	44 e0       	ldi	r20, 0x04	; 4
     ef4:	0c 94 b6 06 	jmp	0xd6c	; 0xd6c <printFloat>

00000ef8 <report_util_axis_values>:
     ef8:	0f 93       	push	r16
     efa:	1f 93       	push	r17
     efc:	cf 93       	push	r28
     efe:	8c 01       	movw	r16, r24
     f00:	c0 e0       	ldi	r28, 0x00	; 0
     f02:	f8 01       	movw	r30, r16
     f04:	61 91       	ld	r22, Z+
     f06:	71 91       	ld	r23, Z+
     f08:	81 91       	ld	r24, Z+
     f0a:	91 91       	ld	r25, Z+
     f0c:	8f 01       	movw	r16, r30
     f0e:	0e 94 6e 07 	call	0xedc	; 0xedc <printFloat_CoordValue>
     f12:	c2 30       	cpi	r28, 0x02	; 2
     f14:	19 f0       	breq	.+6      	; 0xf1c <report_util_axis_values+0x24>
     f16:	8c e2       	ldi	r24, 0x2C	; 44
     f18:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     f1c:	cf 5f       	subi	r28, 0xFF	; 255
     f1e:	c3 30       	cpi	r28, 0x03	; 3
     f20:	81 f7       	brne	.-32     	; 0xf02 <report_util_axis_values+0xa>
     f22:	cf 91       	pop	r28
     f24:	1f 91       	pop	r17
     f26:	0f 91       	pop	r16
     f28:	08 95       	ret

00000f2a <print_uint8_base10>:
     f2a:	cf 93       	push	r28
     f2c:	df 93       	push	r29
     f2e:	84 36       	cpi	r24, 0x64	; 100
     f30:	58 f0       	brcs	.+22     	; 0xf48 <print_uint8_base10+0x1e>
     f32:	6a e0       	ldi	r22, 0x0A	; 10
     f34:	0e 94 66 39 	call	0x72cc	; 0x72cc <__udivmodqi4>
     f38:	c0 e3       	ldi	r28, 0x30	; 48
     f3a:	c9 0f       	add	r28, r25
     f3c:	6a e0       	ldi	r22, 0x0A	; 10
     f3e:	0e 94 66 39 	call	0x72cc	; 0x72cc <__udivmodqi4>
     f42:	d0 e3       	ldi	r29, 0x30	; 48
     f44:	d9 0f       	add	r29, r25
     f46:	04 c0       	rjmp	.+8      	; 0xf50 <print_uint8_base10+0x26>
     f48:	c0 e0       	ldi	r28, 0x00	; 0
     f4a:	d0 e0       	ldi	r29, 0x00	; 0
     f4c:	8a 30       	cpi	r24, 0x0A	; 10
     f4e:	b0 f7       	brcc	.-20     	; 0xf3c <print_uint8_base10+0x12>
     f50:	80 5d       	subi	r24, 0xD0	; 208
     f52:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     f56:	dd 23       	and	r29, r29
     f58:	19 f0       	breq	.+6      	; 0xf60 <print_uint8_base10+0x36>
     f5a:	8d 2f       	mov	r24, r29
     f5c:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     f60:	cc 23       	and	r28, r28
     f62:	29 f0       	breq	.+10     	; 0xf6e <print_uint8_base10+0x44>
     f64:	8c 2f       	mov	r24, r28
     f66:	df 91       	pop	r29
     f68:	cf 91       	pop	r28
     f6a:	0c 94 8d 06 	jmp	0xd1a	; 0xd1a <serial_write>
     f6e:	df 91       	pop	r29
     f70:	cf 91       	pop	r28
     f72:	08 95       	ret

00000f74 <printPgmString>:
     f74:	cf 93       	push	r28
     f76:	df 93       	push	r29
     f78:	ec 01       	movw	r28, r24
     f7a:	fe 01       	movw	r30, r28
     f7c:	84 91       	lpm	r24, Z
     f7e:	21 96       	adiw	r28, 0x01	; 1
     f80:	81 11       	cpse	r24, r1
     f82:	03 c0       	rjmp	.+6      	; 0xf8a <printPgmString+0x16>
     f84:	df 91       	pop	r29
     f86:	cf 91       	pop	r28
     f88:	08 95       	ret
     f8a:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     f8e:	f5 cf       	rjmp	.-22     	; 0xf7a <printPgmString+0x6>

00000f90 <report_util_line_feed>:
     f90:	8e e1       	ldi	r24, 0x1E	; 30
     f92:	92 e0       	ldi	r25, 0x02	; 2
     f94:	0c 94 ba 07 	jmp	0xf74	; 0xf74 <printPgmString>

00000f98 <report_status_message.part.0>:
     f98:	cf 93       	push	r28
     f9a:	c8 2f       	mov	r28, r24
     f9c:	87 e2       	ldi	r24, 0x27	; 39
     f9e:	92 e0       	ldi	r25, 0x02	; 2
     fa0:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
     fa4:	8c 2f       	mov	r24, r28
     fa6:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
     faa:	cf 91       	pop	r28
     fac:	0c 94 c8 07 	jmp	0xf90	; 0xf90 <report_util_line_feed>

00000fb0 <report_status_message>:
     fb0:	81 11       	cpse	r24, r1
     fb2:	04 c0       	rjmp	.+8      	; 0xfbc <report_status_message+0xc>
     fb4:	8e e2       	ldi	r24, 0x2E	; 46
     fb6:	92 e0       	ldi	r25, 0x02	; 2
     fb8:	0c 94 ba 07 	jmp	0xf74	; 0xf74 <printPgmString>
     fbc:	0c 94 cc 07 	jmp	0xf98	; 0xf98 <report_status_message.part.0>

00000fc0 <report_util_float_setting>:
     fc0:	cf 92       	push	r12
     fc2:	df 92       	push	r13
     fc4:	ef 92       	push	r14
     fc6:	ff 92       	push	r15
     fc8:	cf 93       	push	r28
     fca:	df 93       	push	r29
     fcc:	d8 2f       	mov	r29, r24
     fce:	6a 01       	movw	r12, r20
     fd0:	7b 01       	movw	r14, r22
     fd2:	c2 2f       	mov	r28, r18
     fd4:	84 e2       	ldi	r24, 0x24	; 36
     fd6:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     fda:	8d 2f       	mov	r24, r29
     fdc:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
     fe0:	8d e3       	ldi	r24, 0x3D	; 61
     fe2:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
     fe6:	4c 2f       	mov	r20, r28
     fe8:	c7 01       	movw	r24, r14
     fea:	b6 01       	movw	r22, r12
     fec:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printFloat>
     ff0:	df 91       	pop	r29
     ff2:	cf 91       	pop	r28
     ff4:	ff 90       	pop	r15
     ff6:	ef 90       	pop	r14
     ff8:	df 90       	pop	r13
     ffa:	cf 90       	pop	r12
     ffc:	0c 94 c8 07 	jmp	0xf90	; 0xf90 <report_util_line_feed>

00001000 <report_util_uint8_setting>:
    1000:	cf 93       	push	r28
    1002:	df 93       	push	r29
    1004:	d8 2f       	mov	r29, r24
    1006:	c6 2f       	mov	r28, r22
    1008:	84 e2       	ldi	r24, 0x24	; 36
    100a:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    100e:	8d 2f       	mov	r24, r29
    1010:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    1014:	8d e3       	ldi	r24, 0x3D	; 61
    1016:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    101a:	8c 2f       	mov	r24, r28
    101c:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    1020:	df 91       	pop	r29
    1022:	cf 91       	pop	r28
    1024:	0c 94 c8 07 	jmp	0xf90	; 0xf90 <report_util_line_feed>

00001028 <report_grbl_settings>:
    1028:	ef 92       	push	r14
    102a:	ff 92       	push	r15
    102c:	0f 93       	push	r16
    102e:	1f 93       	push	r17
    1030:	cf 93       	push	r28
    1032:	df 93       	push	r29
    1034:	60 91 72 06 	lds	r22, 0x0672	; 0x800672 <settings+0x30>
    1038:	70 e0       	ldi	r23, 0x00	; 0
    103a:	80 e0       	ldi	r24, 0x00	; 0
    103c:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1040:	60 91 75 06 	lds	r22, 0x0675	; 0x800675 <settings+0x33>
    1044:	70 e0       	ldi	r23, 0x00	; 0
    1046:	81 e0       	ldi	r24, 0x01	; 1
    1048:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    104c:	60 91 73 06 	lds	r22, 0x0673	; 0x800673 <settings+0x31>
    1050:	70 e0       	ldi	r23, 0x00	; 0
    1052:	82 e0       	ldi	r24, 0x02	; 2
    1054:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1058:	60 91 74 06 	lds	r22, 0x0674	; 0x800674 <settings+0x32>
    105c:	70 e0       	ldi	r23, 0x00	; 0
    105e:	83 e0       	ldi	r24, 0x03	; 3
    1060:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1064:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    1068:	62 fb       	bst	r22, 2
    106a:	66 27       	eor	r22, r22
    106c:	60 f9       	bld	r22, 0
    106e:	70 e0       	ldi	r23, 0x00	; 0
    1070:	84 e0       	ldi	r24, 0x04	; 4
    1072:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1076:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    107a:	66 fb       	bst	r22, 6
    107c:	66 27       	eor	r22, r22
    107e:	60 f9       	bld	r22, 0
    1080:	70 e0       	ldi	r23, 0x00	; 0
    1082:	85 e0       	ldi	r24, 0x05	; 5
    1084:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1088:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    108c:	08 2e       	mov	r0, r24
    108e:	00 0c       	add	r0, r0
    1090:	99 0b       	sbc	r25, r25
    1092:	69 2f       	mov	r22, r25
    1094:	66 1f       	adc	r22, r22
    1096:	66 27       	eor	r22, r22
    1098:	66 1f       	adc	r22, r22
    109a:	70 e0       	ldi	r23, 0x00	; 0
    109c:	86 e0       	ldi	r24, 0x06	; 6
    109e:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    10a2:	60 91 76 06 	lds	r22, 0x0676	; 0x800676 <settings+0x34>
    10a6:	70 e0       	ldi	r23, 0x00	; 0
    10a8:	8a e0       	ldi	r24, 0x0A	; 10
    10aa:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    10ae:	40 91 77 06 	lds	r20, 0x0677	; 0x800677 <settings+0x35>
    10b2:	50 91 78 06 	lds	r21, 0x0678	; 0x800678 <settings+0x36>
    10b6:	60 91 79 06 	lds	r22, 0x0679	; 0x800679 <settings+0x37>
    10ba:	70 91 7a 06 	lds	r23, 0x067A	; 0x80067a <settings+0x38>
    10be:	23 e0       	ldi	r18, 0x03	; 3
    10c0:	8b e0       	ldi	r24, 0x0B	; 11
    10c2:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    10c6:	40 91 7b 06 	lds	r20, 0x067B	; 0x80067b <settings+0x39>
    10ca:	50 91 7c 06 	lds	r21, 0x067C	; 0x80067c <settings+0x3a>
    10ce:	60 91 7d 06 	lds	r22, 0x067D	; 0x80067d <settings+0x3b>
    10d2:	70 91 7e 06 	lds	r23, 0x067E	; 0x80067e <settings+0x3c>
    10d6:	23 e0       	ldi	r18, 0x03	; 3
    10d8:	8c e0       	ldi	r24, 0x0C	; 12
    10da:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    10de:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    10e2:	61 70       	andi	r22, 0x01	; 1
    10e4:	70 e0       	ldi	r23, 0x00	; 0
    10e6:	8d e0       	ldi	r24, 0x0D	; 13
    10e8:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    10ec:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    10f0:	65 fb       	bst	r22, 5
    10f2:	66 27       	eor	r22, r22
    10f4:	60 f9       	bld	r22, 0
    10f6:	70 e0       	ldi	r23, 0x00	; 0
    10f8:	84 e1       	ldi	r24, 0x14	; 20
    10fa:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    10fe:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    1102:	63 fb       	bst	r22, 3
    1104:	66 27       	eor	r22, r22
    1106:	60 f9       	bld	r22, 0
    1108:	70 e0       	ldi	r23, 0x00	; 0
    110a:	85 e1       	ldi	r24, 0x15	; 21
    110c:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1110:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    1114:	62 95       	swap	r22
    1116:	61 70       	andi	r22, 0x01	; 1
    1118:	70 e0       	ldi	r23, 0x00	; 0
    111a:	86 e1       	ldi	r24, 0x16	; 22
    111c:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    1120:	60 91 88 06 	lds	r22, 0x0688	; 0x800688 <settings+0x46>
    1124:	70 e0       	ldi	r23, 0x00	; 0
    1126:	87 e1       	ldi	r24, 0x17	; 23
    1128:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    112c:	40 91 89 06 	lds	r20, 0x0689	; 0x800689 <settings+0x47>
    1130:	50 91 8a 06 	lds	r21, 0x068A	; 0x80068a <settings+0x48>
    1134:	60 91 8b 06 	lds	r22, 0x068B	; 0x80068b <settings+0x49>
    1138:	70 91 8c 06 	lds	r23, 0x068C	; 0x80068c <settings+0x4a>
    113c:	23 e0       	ldi	r18, 0x03	; 3
    113e:	88 e1       	ldi	r24, 0x18	; 24
    1140:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    1144:	40 91 8d 06 	lds	r20, 0x068D	; 0x80068d <settings+0x4b>
    1148:	50 91 8e 06 	lds	r21, 0x068E	; 0x80068e <settings+0x4c>
    114c:	60 91 8f 06 	lds	r22, 0x068F	; 0x80068f <settings+0x4d>
    1150:	70 91 90 06 	lds	r23, 0x0690	; 0x800690 <settings+0x4e>
    1154:	23 e0       	ldi	r18, 0x03	; 3
    1156:	89 e1       	ldi	r24, 0x19	; 25
    1158:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    115c:	60 91 91 06 	lds	r22, 0x0691	; 0x800691 <settings+0x4f>
    1160:	70 91 92 06 	lds	r23, 0x0692	; 0x800692 <settings+0x50>
    1164:	8a e1       	ldi	r24, 0x1A	; 26
    1166:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    116a:	40 91 93 06 	lds	r20, 0x0693	; 0x800693 <settings+0x51>
    116e:	50 91 94 06 	lds	r21, 0x0694	; 0x800694 <settings+0x52>
    1172:	60 91 95 06 	lds	r22, 0x0695	; 0x800695 <settings+0x53>
    1176:	70 91 96 06 	lds	r23, 0x0696	; 0x800696 <settings+0x54>
    117a:	23 e0       	ldi	r18, 0x03	; 3
    117c:	8b e1       	ldi	r24, 0x1B	; 27
    117e:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    1182:	40 91 7f 06 	lds	r20, 0x067F	; 0x80067f <settings+0x3d>
    1186:	50 91 80 06 	lds	r21, 0x0680	; 0x800680 <settings+0x3e>
    118a:	60 91 81 06 	lds	r22, 0x0681	; 0x800681 <settings+0x3f>
    118e:	70 91 82 06 	lds	r23, 0x0682	; 0x800682 <settings+0x40>
    1192:	20 e0       	ldi	r18, 0x00	; 0
    1194:	8e e1       	ldi	r24, 0x1E	; 30
    1196:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    119a:	40 91 83 06 	lds	r20, 0x0683	; 0x800683 <settings+0x41>
    119e:	50 91 84 06 	lds	r21, 0x0684	; 0x800684 <settings+0x42>
    11a2:	60 91 85 06 	lds	r22, 0x0685	; 0x800685 <settings+0x43>
    11a6:	70 91 86 06 	lds	r23, 0x0686	; 0x800686 <settings+0x44>
    11aa:	20 e0       	ldi	r18, 0x00	; 0
    11ac:	8f e1       	ldi	r24, 0x1F	; 31
    11ae:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    11b2:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    11b6:	66 95       	lsr	r22
    11b8:	61 70       	andi	r22, 0x01	; 1
    11ba:	70 e0       	ldi	r23, 0x00	; 0
    11bc:	80 e2       	ldi	r24, 0x20	; 32
    11be:	0e 94 00 08 	call	0x1000	; 0x1000 <report_util_uint8_setting>
    11c2:	84 e6       	ldi	r24, 0x64	; 100
    11c4:	f8 2e       	mov	r15, r24
    11c6:	10 e0       	ldi	r17, 0x00	; 0
    11c8:	c2 e4       	ldi	r28, 0x42	; 66
    11ca:	d6 e0       	ldi	r29, 0x06	; 6
    11cc:	00 e0       	ldi	r16, 0x00	; 0
    11ce:	e0 2e       	mov	r14, r16
    11d0:	ef 0c       	add	r14, r15
    11d2:	12 30       	cpi	r17, 0x02	; 2
    11d4:	11 f1       	breq	.+68     	; 0x121a <report_grbl_settings+0x1f2>
    11d6:	13 30       	cpi	r17, 0x03	; 3
    11d8:	69 f1       	breq	.+90     	; 0x1234 <report_grbl_settings+0x20c>
    11da:	11 30       	cpi	r17, 0x01	; 1
    11dc:	c9 f0       	breq	.+50     	; 0x1210 <report_grbl_settings+0x1e8>
    11de:	48 81       	ld	r20, Y
    11e0:	59 81       	ldd	r21, Y+1	; 0x01
    11e2:	6a 81       	ldd	r22, Y+2	; 0x02
    11e4:	7b 81       	ldd	r23, Y+3	; 0x03
    11e6:	23 e0       	ldi	r18, 0x03	; 3
    11e8:	8e 2d       	mov	r24, r14
    11ea:	0e 94 e0 07 	call	0xfc0	; 0xfc0 <report_util_float_setting>
    11ee:	0f 5f       	subi	r16, 0xFF	; 255
    11f0:	24 96       	adiw	r28, 0x04	; 4
    11f2:	03 30       	cpi	r16, 0x03	; 3
    11f4:	61 f7       	brne	.-40     	; 0x11ce <report_grbl_settings+0x1a6>
    11f6:	8a e0       	ldi	r24, 0x0A	; 10
    11f8:	f8 0e       	add	r15, r24
    11fa:	1f 5f       	subi	r17, 0xFF	; 255
    11fc:	8c e8       	ldi	r24, 0x8C	; 140
    11fe:	f8 12       	cpse	r15, r24
    1200:	e3 cf       	rjmp	.-58     	; 0x11c8 <report_grbl_settings+0x1a0>
    1202:	df 91       	pop	r29
    1204:	cf 91       	pop	r28
    1206:	1f 91       	pop	r17
    1208:	0f 91       	pop	r16
    120a:	ff 90       	pop	r15
    120c:	ef 90       	pop	r14
    120e:	08 95       	ret
    1210:	4c 85       	ldd	r20, Y+12	; 0x0c
    1212:	5d 85       	ldd	r21, Y+13	; 0x0d
    1214:	6e 85       	ldd	r22, Y+14	; 0x0e
    1216:	7f 85       	ldd	r23, Y+15	; 0x0f
    1218:	e6 cf       	rjmp	.-52     	; 0x11e6 <report_grbl_settings+0x1be>
    121a:	24 eb       	ldi	r18, 0xB4	; 180
    121c:	32 ea       	ldi	r19, 0xA2	; 162
    121e:	41 e9       	ldi	r20, 0x91	; 145
    1220:	59 e3       	ldi	r21, 0x39	; 57
    1222:	68 8d       	ldd	r22, Y+24	; 0x18
    1224:	79 8d       	ldd	r23, Y+25	; 0x19
    1226:	8a 8d       	ldd	r24, Y+26	; 0x1a
    1228:	9b 8d       	ldd	r25, Y+27	; 0x1b
    122a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    122e:	ab 01       	movw	r20, r22
    1230:	bc 01       	movw	r22, r24
    1232:	d9 cf       	rjmp	.-78     	; 0x11e6 <report_grbl_settings+0x1be>
    1234:	4c a1       	ldd	r20, Y+36	; 0x24
    1236:	5d a1       	ldd	r21, Y+37	; 0x25
    1238:	6e a1       	ldd	r22, Y+38	; 0x26
    123a:	7f a1       	ldd	r23, Y+39	; 0x27
    123c:	70 58       	subi	r23, 0x80	; 128
    123e:	d3 cf       	rjmp	.-90     	; 0x11e6 <report_grbl_settings+0x1be>

00001240 <report_util_feedback_line_feed>:
    1240:	8d e5       	ldi	r24, 0x5D	; 93
    1242:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    1246:	0c 94 c8 07 	jmp	0xf90	; 0xf90 <report_util_line_feed>

0000124a <report_probe_parameters>:
    124a:	cf 93       	push	r28
    124c:	df 93       	push	r29
    124e:	cd b7       	in	r28, 0x3d	; 61
    1250:	de b7       	in	r29, 0x3e	; 62
    1252:	2c 97       	sbiw	r28, 0x0c	; 12
    1254:	0f b6       	in	r0, 0x3f	; 63
    1256:	f8 94       	cli
    1258:	de bf       	out	0x3e, r29	; 62
    125a:	0f be       	out	0x3f, r0	; 63
    125c:	cd bf       	out	0x3d, r28	; 61
    125e:	81 e2       	ldi	r24, 0x21	; 33
    1260:	92 e0       	ldi	r25, 0x02	; 2
    1262:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    1266:	64 e2       	ldi	r22, 0x24	; 36
    1268:	76 e0       	ldi	r23, 0x06	; 6
    126a:	ce 01       	movw	r24, r28
    126c:	01 96       	adiw	r24, 0x01	; 1
    126e:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    1272:	ce 01       	movw	r24, r28
    1274:	01 96       	adiw	r24, 0x01	; 1
    1276:	0e 94 7c 07 	call	0xef8	; 0xef8 <report_util_axis_values>
    127a:	8a e3       	ldi	r24, 0x3A	; 58
    127c:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    1280:	80 91 36 06 	lds	r24, 0x0636	; 0x800636 <sys+0x5>
    1284:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    1288:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    128c:	2c 96       	adiw	r28, 0x0c	; 12
    128e:	0f b6       	in	r0, 0x3f	; 63
    1290:	f8 94       	cli
    1292:	de bf       	out	0x3e, r29	; 62
    1294:	0f be       	out	0x3f, r0	; 63
    1296:	cd bf       	out	0x3d, r28	; 61
    1298:	df 91       	pop	r29
    129a:	cf 91       	pop	r28
    129c:	08 95       	ret

0000129e <coolant_set_state>:
    129e:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    12a2:	91 11       	cpse	r25, r1
    12a4:	05 c0       	rjmp	.+10     	; 0x12b0 <coolant_set_state+0x12>
    12a6:	86 ff       	sbrs	r24, 6
    12a8:	04 c0       	rjmp	.+8      	; 0x12b2 <coolant_set_state+0x14>
    12aa:	43 9a       	sbi	0x08, 3	; 8
    12ac:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    12b0:	08 95       	ret
    12b2:	43 98       	cbi	0x08, 3	; 8
    12b4:	fb cf       	rjmp	.-10     	; 0x12ac <coolant_set_state+0xe>

000012b6 <spindle_set_speed>:
    12b6:	80 93 b3 00 	sts	0x00B3, r24	; 0x8000b3 <__DATA_REGION_ORIGIN__+0x53>
    12ba:	81 11       	cpse	r24, r1
    12bc:	06 c0       	rjmp	.+12     	; 0x12ca <spindle_set_speed+0x14>
    12be:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12c2:	8f 77       	andi	r24, 0x7F	; 127
    12c4:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12c8:	08 95       	ret
    12ca:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12ce:	80 68       	ori	r24, 0x80	; 128
    12d0:	f9 cf       	rjmp	.-14     	; 0x12c4 <spindle_set_speed+0xe>

000012d2 <spindle_init>:
    12d2:	cf 93       	push	r28
    12d4:	df 93       	push	r29
    12d6:	23 9a       	sbi	0x04, 3	; 4
    12d8:	c0 eb       	ldi	r28, 0xB0	; 176
    12da:	d0 e0       	ldi	r29, 0x00	; 0
    12dc:	83 e0       	ldi	r24, 0x03	; 3
    12de:	88 83       	st	Y, r24
    12e0:	84 e0       	ldi	r24, 0x04	; 4
    12e2:	80 93 b1 00 	sts	0x00B1, r24	; 0x8000b1 <__DATA_REGION_ORIGIN__+0x51>
    12e6:	25 9a       	sbi	0x04, 5	; 4
    12e8:	20 91 83 06 	lds	r18, 0x0683	; 0x800683 <settings+0x41>
    12ec:	30 91 84 06 	lds	r19, 0x0684	; 0x800684 <settings+0x42>
    12f0:	40 91 85 06 	lds	r20, 0x0685	; 0x800685 <settings+0x43>
    12f4:	50 91 86 06 	lds	r21, 0x0686	; 0x800686 <settings+0x44>
    12f8:	60 91 7f 06 	lds	r22, 0x067F	; 0x80067f <settings+0x3d>
    12fc:	70 91 80 06 	lds	r23, 0x0680	; 0x800680 <settings+0x3e>
    1300:	80 91 81 06 	lds	r24, 0x0681	; 0x800681 <settings+0x3f>
    1304:	90 91 82 06 	lds	r25, 0x0682	; 0x800682 <settings+0x40>
    1308:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    130c:	9b 01       	movw	r18, r22
    130e:	ac 01       	movw	r20, r24
    1310:	60 e0       	ldi	r22, 0x00	; 0
    1312:	70 e0       	ldi	r23, 0x00	; 0
    1314:	8e e7       	ldi	r24, 0x7E	; 126
    1316:	93 e4       	ldi	r25, 0x43	; 67
    1318:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    131c:	60 93 00 01 	sts	0x0100, r22	; 0x800100 <_edata>
    1320:	70 93 01 01 	sts	0x0101, r23	; 0x800101 <_edata+0x1>
    1324:	80 93 02 01 	sts	0x0102, r24	; 0x800102 <_edata+0x2>
    1328:	90 93 03 01 	sts	0x0103, r25	; 0x800103 <_edata+0x3>
    132c:	88 81       	ld	r24, Y
    132e:	8f 77       	andi	r24, 0x7F	; 127
    1330:	88 83       	st	Y, r24
    1332:	df 91       	pop	r29
    1334:	cf 91       	pop	r28
    1336:	08 95       	ret

00001338 <gc_sync_position>:
    1338:	68 e1       	ldi	r22, 0x18	; 24
    133a:	76 e0       	ldi	r23, 0x06	; 6
    133c:	8f ea       	ldi	r24, 0xAF	; 175
    133e:	96 e0       	ldi	r25, 0x06	; 6
    1340:	0c 94 8f 02 	jmp	0x51e	; 0x51e <system_convert_array_steps_to_mpos>

00001344 <plan_reset>:
    1344:	e7 ef       	ldi	r30, 0xF7	; 247
    1346:	f5 e0       	ldi	r31, 0x05	; 5
    1348:	8c e1       	ldi	r24, 0x1C	; 28
    134a:	df 01       	movw	r26, r30
    134c:	1d 92       	st	X+, r1
    134e:	8a 95       	dec	r24
    1350:	e9 f7       	brne	.-6      	; 0x134c <plan_reset+0x8>
    1352:	10 92 d5 02 	sts	0x02D5, r1	; 0x8002d5 <block_buffer_tail>
    1356:	10 92 f6 05 	sts	0x05F6, r1	; 0x8005f6 <block_buffer_head>
    135a:	81 e0       	ldi	r24, 0x01	; 1
    135c:	80 93 d4 02 	sts	0x02D4, r24	; 0x8002d4 <next_buffer_head>
    1360:	10 92 d3 02 	sts	0x02D3, r1	; 0x8002d3 <block_buffer_planned>
    1364:	08 95       	ret

00001366 <convert_delta_vector_to_unit_vector>:
    1366:	4f 92       	push	r4
    1368:	5f 92       	push	r5
    136a:	6f 92       	push	r6
    136c:	7f 92       	push	r7
    136e:	af 92       	push	r10
    1370:	bf 92       	push	r11
    1372:	cf 92       	push	r12
    1374:	df 92       	push	r13
    1376:	ef 92       	push	r14
    1378:	ff 92       	push	r15
    137a:	0f 93       	push	r16
    137c:	1f 93       	push	r17
    137e:	cf 93       	push	r28
    1380:	df 93       	push	r29
    1382:	ec 01       	movw	r28, r24
    1384:	5c 01       	movw	r10, r24
    1386:	2c e0       	ldi	r18, 0x0C	; 12
    1388:	a2 0e       	add	r10, r18
    138a:	b1 1c       	adc	r11, r1
    138c:	8c 01       	movw	r16, r24
    138e:	c1 2c       	mov	r12, r1
    1390:	d1 2c       	mov	r13, r1
    1392:	76 01       	movw	r14, r12
    1394:	f8 01       	movw	r30, r16
    1396:	41 90       	ld	r4, Z+
    1398:	51 90       	ld	r5, Z+
    139a:	61 90       	ld	r6, Z+
    139c:	71 90       	ld	r7, Z+
    139e:	8f 01       	movw	r16, r30
    13a0:	20 e0       	ldi	r18, 0x00	; 0
    13a2:	30 e0       	ldi	r19, 0x00	; 0
    13a4:	a9 01       	movw	r20, r18
    13a6:	c3 01       	movw	r24, r6
    13a8:	b2 01       	movw	r22, r4
    13aa:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    13ae:	88 23       	and	r24, r24
    13b0:	71 f0       	breq	.+28     	; 0x13ce <convert_delta_vector_to_unit_vector+0x68>
    13b2:	a3 01       	movw	r20, r6
    13b4:	92 01       	movw	r18, r4
    13b6:	c3 01       	movw	r24, r6
    13b8:	b2 01       	movw	r22, r4
    13ba:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    13be:	9b 01       	movw	r18, r22
    13c0:	ac 01       	movw	r20, r24
    13c2:	c7 01       	movw	r24, r14
    13c4:	b6 01       	movw	r22, r12
    13c6:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    13ca:	6b 01       	movw	r12, r22
    13cc:	7c 01       	movw	r14, r24
    13ce:	0a 15       	cp	r16, r10
    13d0:	1b 05       	cpc	r17, r11
    13d2:	01 f7       	brne	.-64     	; 0x1394 <convert_delta_vector_to_unit_vector+0x2e>
    13d4:	c7 01       	movw	r24, r14
    13d6:	b6 01       	movw	r22, r12
    13d8:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    13dc:	6b 01       	movw	r12, r22
    13de:	7c 01       	movw	r14, r24
    13e0:	ac 01       	movw	r20, r24
    13e2:	9b 01       	movw	r18, r22
    13e4:	60 e0       	ldi	r22, 0x00	; 0
    13e6:	70 e0       	ldi	r23, 0x00	; 0
    13e8:	80 e8       	ldi	r24, 0x80	; 128
    13ea:	9f e3       	ldi	r25, 0x3F	; 63
    13ec:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    13f0:	2b 01       	movw	r4, r22
    13f2:	3c 01       	movw	r6, r24
    13f4:	69 91       	ld	r22, Y+
    13f6:	79 91       	ld	r23, Y+
    13f8:	89 91       	ld	r24, Y+
    13fa:	99 91       	ld	r25, Y+
    13fc:	5e 01       	movw	r10, r28
    13fe:	f4 e0       	ldi	r31, 0x04	; 4
    1400:	af 1a       	sub	r10, r31
    1402:	b1 08       	sbc	r11, r1
    1404:	a3 01       	movw	r20, r6
    1406:	92 01       	movw	r18, r4
    1408:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    140c:	f5 01       	movw	r30, r10
    140e:	60 83       	st	Z, r22
    1410:	71 83       	std	Z+1, r23	; 0x01
    1412:	82 83       	std	Z+2, r24	; 0x02
    1414:	93 83       	std	Z+3, r25	; 0x03
    1416:	c0 17       	cp	r28, r16
    1418:	d1 07       	cpc	r29, r17
    141a:	61 f7       	brne	.-40     	; 0x13f4 <convert_delta_vector_to_unit_vector+0x8e>
    141c:	c7 01       	movw	r24, r14
    141e:	b6 01       	movw	r22, r12
    1420:	df 91       	pop	r29
    1422:	cf 91       	pop	r28
    1424:	1f 91       	pop	r17
    1426:	0f 91       	pop	r16
    1428:	ff 90       	pop	r15
    142a:	ef 90       	pop	r14
    142c:	df 90       	pop	r13
    142e:	cf 90       	pop	r12
    1430:	bf 90       	pop	r11
    1432:	af 90       	pop	r10
    1434:	7f 90       	pop	r7
    1436:	6f 90       	pop	r6
    1438:	5f 90       	pop	r5
    143a:	4f 90       	pop	r4
    143c:	08 95       	ret

0000143e <spindle_compute_pwm_value>:
    143e:	4f 92       	push	r4
    1440:	5f 92       	push	r5
    1442:	6f 92       	push	r6
    1444:	7f 92       	push	r7
    1446:	8f 92       	push	r8
    1448:	9f 92       	push	r9
    144a:	af 92       	push	r10
    144c:	bf 92       	push	r11
    144e:	cf 92       	push	r12
    1450:	df 92       	push	r13
    1452:	ef 92       	push	r14
    1454:	ff 92       	push	r15
    1456:	6b 01       	movw	r12, r22
    1458:	7c 01       	movw	r14, r24
    145a:	80 90 83 06 	lds	r8, 0x0683	; 0x800683 <settings+0x41>
    145e:	90 90 84 06 	lds	r9, 0x0684	; 0x800684 <settings+0x42>
    1462:	a0 90 85 06 	lds	r10, 0x0685	; 0x800685 <settings+0x43>
    1466:	b0 90 86 06 	lds	r11, 0x0686	; 0x800686 <settings+0x44>
    146a:	40 90 7f 06 	lds	r4, 0x067F	; 0x80067f <settings+0x3d>
    146e:	50 90 80 06 	lds	r5, 0x0680	; 0x800680 <settings+0x3e>
    1472:	60 90 81 06 	lds	r6, 0x0681	; 0x800681 <settings+0x3f>
    1476:	70 90 82 06 	lds	r7, 0x0682	; 0x800682 <settings+0x40>
    147a:	a3 01       	movw	r20, r6
    147c:	92 01       	movw	r18, r4
    147e:	c5 01       	movw	r24, r10
    1480:	b4 01       	movw	r22, r8
    1482:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    1486:	87 ff       	sbrs	r24, 7
    1488:	1b c0       	rjmp	.+54     	; 0x14c0 <spindle_compute_pwm_value+0x82>
    148a:	60 91 3a 06 	lds	r22, 0x063A	; 0x80063a <sys+0x9>
    148e:	70 e0       	ldi	r23, 0x00	; 0
    1490:	90 e0       	ldi	r25, 0x00	; 0
    1492:	80 e0       	ldi	r24, 0x00	; 0
    1494:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
    1498:	2a e0       	ldi	r18, 0x0A	; 10
    149a:	37 ed       	ldi	r19, 0xD7	; 215
    149c:	43 e2       	ldi	r20, 0x23	; 35
    149e:	5c e3       	ldi	r21, 0x3C	; 60
    14a0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    14a4:	a7 01       	movw	r20, r14
    14a6:	96 01       	movw	r18, r12
    14a8:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    14ac:	6b 01       	movw	r12, r22
    14ae:	7c 01       	movw	r14, r24
    14b0:	ac 01       	movw	r20, r24
    14b2:	9b 01       	movw	r18, r22
    14b4:	c3 01       	movw	r24, r6
    14b6:	b2 01       	movw	r22, r4
    14b8:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    14bc:	18 16       	cp	r1, r24
    14be:	b4 f0       	brlt	.+44     	; 0x14ec <spindle_compute_pwm_value+0xae>
    14c0:	40 92 3e 06 	sts	0x063E, r4	; 0x80063e <sys+0xd>
    14c4:	50 92 3f 06 	sts	0x063F, r5	; 0x80063f <sys+0xe>
    14c8:	60 92 40 06 	sts	0x0640, r6	; 0x800640 <sys+0xf>
    14cc:	70 92 41 06 	sts	0x0641, r7	; 0x800641 <sys+0x10>
    14d0:	8f ef       	ldi	r24, 0xFF	; 255
    14d2:	ff 90       	pop	r15
    14d4:	ef 90       	pop	r14
    14d6:	df 90       	pop	r13
    14d8:	cf 90       	pop	r12
    14da:	bf 90       	pop	r11
    14dc:	af 90       	pop	r10
    14de:	9f 90       	pop	r9
    14e0:	8f 90       	pop	r8
    14e2:	7f 90       	pop	r7
    14e4:	6f 90       	pop	r6
    14e6:	5f 90       	pop	r5
    14e8:	4f 90       	pop	r4
    14ea:	08 95       	ret
    14ec:	a7 01       	movw	r20, r14
    14ee:	96 01       	movw	r18, r12
    14f0:	c5 01       	movw	r24, r10
    14f2:	b4 01       	movw	r22, r8
    14f4:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    14f8:	87 fd       	sbrc	r24, 7
    14fa:	1c c0       	rjmp	.+56     	; 0x1534 <spindle_compute_pwm_value+0xf6>
    14fc:	20 e0       	ldi	r18, 0x00	; 0
    14fe:	30 e0       	ldi	r19, 0x00	; 0
    1500:	a9 01       	movw	r20, r18
    1502:	c7 01       	movw	r24, r14
    1504:	b6 01       	movw	r22, r12
    1506:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    150a:	81 11       	cpse	r24, r1
    150c:	09 c0       	rjmp	.+18     	; 0x1520 <spindle_compute_pwm_value+0xe2>
    150e:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    1512:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    1516:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    151a:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    151e:	d9 cf       	rjmp	.-78     	; 0x14d2 <spindle_compute_pwm_value+0x94>
    1520:	80 92 3e 06 	sts	0x063E, r8	; 0x80063e <sys+0xd>
    1524:	90 92 3f 06 	sts	0x063F, r9	; 0x80063f <sys+0xe>
    1528:	a0 92 40 06 	sts	0x0640, r10	; 0x800640 <sys+0xf>
    152c:	b0 92 41 06 	sts	0x0641, r11	; 0x800641 <sys+0x10>
    1530:	81 e0       	ldi	r24, 0x01	; 1
    1532:	cf cf       	rjmp	.-98     	; 0x14d2 <spindle_compute_pwm_value+0x94>
    1534:	c0 92 3e 06 	sts	0x063E, r12	; 0x80063e <sys+0xd>
    1538:	d0 92 3f 06 	sts	0x063F, r13	; 0x80063f <sys+0xe>
    153c:	e0 92 40 06 	sts	0x0640, r14	; 0x800640 <sys+0xf>
    1540:	f0 92 41 06 	sts	0x0641, r15	; 0x800641 <sys+0x10>
    1544:	a5 01       	movw	r20, r10
    1546:	94 01       	movw	r18, r8
    1548:	c7 01       	movw	r24, r14
    154a:	b6 01       	movw	r22, r12
    154c:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1550:	20 91 00 01 	lds	r18, 0x0100	; 0x800100 <_edata>
    1554:	30 91 01 01 	lds	r19, 0x0101	; 0x800101 <_edata+0x1>
    1558:	40 91 02 01 	lds	r20, 0x0102	; 0x800102 <_edata+0x2>
    155c:	50 91 03 01 	lds	r21, 0x0103	; 0x800103 <_edata+0x3>
    1560:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1564:	0e 94 f5 36 	call	0x6dea	; 0x6dea <floor>
    1568:	20 e0       	ldi	r18, 0x00	; 0
    156a:	30 e0       	ldi	r19, 0x00	; 0
    156c:	40 e8       	ldi	r20, 0x80	; 128
    156e:	5f e3       	ldi	r21, 0x3F	; 63
    1570:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    1574:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    1578:	86 2f       	mov	r24, r22
    157a:	ab cf       	rjmp	.-170    	; 0x14d2 <spindle_compute_pwm_value+0x94>

0000157c <spindle_set_state>:
    157c:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    1580:	91 11       	cpse	r25, r1
    1582:	11 c0       	rjmp	.+34     	; 0x15a6 <spindle_set_state+0x2a>
    1584:	81 11       	cpse	r24, r1
    1586:	10 c0       	rjmp	.+32     	; 0x15a8 <spindle_set_state+0x2c>
    1588:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    158c:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    1590:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    1594:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    1598:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    159c:	8f 77       	andi	r24, 0x7F	; 127
    159e:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    15a2:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    15a6:	08 95       	ret
    15a8:	80 31       	cpi	r24, 0x10	; 16
    15aa:	89 f4       	brne	.+34     	; 0x15ce <spindle_set_state+0x52>
    15ac:	2d 98       	cbi	0x05, 5	; 5
    15ae:	90 91 87 06 	lds	r25, 0x0687	; 0x800687 <settings+0x45>
    15b2:	91 ff       	sbrs	r25, 1
    15b4:	05 c0       	rjmp	.+10     	; 0x15c0 <spindle_set_state+0x44>
    15b6:	80 32       	cpi	r24, 0x20	; 32
    15b8:	19 f4       	brne	.+6      	; 0x15c0 <spindle_set_state+0x44>
    15ba:	40 e0       	ldi	r20, 0x00	; 0
    15bc:	50 e0       	ldi	r21, 0x00	; 0
    15be:	ba 01       	movw	r22, r20
    15c0:	cb 01       	movw	r24, r22
    15c2:	ba 01       	movw	r22, r20
    15c4:	0e 94 1f 0a 	call	0x143e	; 0x143e <spindle_compute_pwm_value>
    15c8:	0e 94 5b 09 	call	0x12b6	; 0x12b6 <spindle_set_speed>
    15cc:	ea cf       	rjmp	.-44     	; 0x15a2 <spindle_set_state+0x26>
    15ce:	2d 9a       	sbi	0x05, 5	; 5
    15d0:	ee cf       	rjmp	.-36     	; 0x15ae <spindle_set_state+0x32>

000015d2 <plan_buffer_line>:
    15d2:	2f 92       	push	r2
    15d4:	3f 92       	push	r3
    15d6:	4f 92       	push	r4
    15d8:	5f 92       	push	r5
    15da:	6f 92       	push	r6
    15dc:	7f 92       	push	r7
    15de:	8f 92       	push	r8
    15e0:	9f 92       	push	r9
    15e2:	af 92       	push	r10
    15e4:	bf 92       	push	r11
    15e6:	cf 92       	push	r12
    15e8:	df 92       	push	r13
    15ea:	ef 92       	push	r14
    15ec:	ff 92       	push	r15
    15ee:	0f 93       	push	r16
    15f0:	1f 93       	push	r17
    15f2:	cf 93       	push	r28
    15f4:	df 93       	push	r29
    15f6:	cd b7       	in	r28, 0x3d	; 61
    15f8:	de b7       	in	r29, 0x3e	; 62
    15fa:	c2 54       	subi	r28, 0x42	; 66
    15fc:	d1 09       	sbc	r29, r1
    15fe:	0f b6       	in	r0, 0x3f	; 63
    1600:	f8 94       	cli
    1602:	de bf       	out	0x3e, r29	; 62
    1604:	0f be       	out	0x3f, r0	; 63
    1606:	cd bf       	out	0x3d, r28	; 61
    1608:	3b 01       	movw	r6, r22
    160a:	00 91 f6 05 	lds	r16, 0x05F6	; 0x8005f6 <block_buffer_head>
    160e:	20 2e       	mov	r2, r16
    1610:	31 2c       	mov	r3, r1
    1612:	22 e3       	ldi	r18, 0x32	; 50
    1614:	02 9f       	mul	r16, r18
    1616:	a0 01       	movw	r20, r0
    1618:	11 24       	eor	r1, r1
    161a:	ba 01       	movw	r22, r20
    161c:	6a 52       	subi	r22, 0x2A	; 42
    161e:	7d 4f       	sbci	r23, 0xFD	; 253
    1620:	7c ab       	std	Y+52, r23	; 0x34
    1622:	6b ab       	std	Y+51, r22	; 0x33
    1624:	fb 01       	movw	r30, r22
    1626:	11 92       	st	Z+, r1
    1628:	2a 95       	dec	r18
    162a:	e9 f7       	brne	.-6      	; 0x1626 <plan_buffer_line+0x54>
    162c:	f3 01       	movw	r30, r6
    162e:	20 85       	ldd	r18, Z+8	; 0x08
    1630:	fb 01       	movw	r30, r22
    1632:	21 8b       	std	Z+17, r18	; 0x11
    1634:	f3 01       	movw	r30, r6
    1636:	44 81       	ldd	r20, Z+4	; 0x04
    1638:	55 81       	ldd	r21, Z+5	; 0x05
    163a:	66 81       	ldd	r22, Z+6	; 0x06
    163c:	77 81       	ldd	r23, Z+7	; 0x07
    163e:	eb a9       	ldd	r30, Y+51	; 0x33
    1640:	fc a9       	ldd	r31, Y+52	; 0x34
    1642:	46 a7       	std	Z+46, r20	; 0x2e
    1644:	57 a7       	std	Z+47, r21	; 0x2f
    1646:	60 ab       	std	Z+48, r22	; 0x30
    1648:	71 ab       	std	Z+49, r23	; 0x31
    164a:	21 ff       	sbrs	r18, 1
    164c:	f0 c0       	rjmp	.+480    	; 0x182e <plan_buffer_line+0x25c>
    164e:	2c e0       	ldi	r18, 0x0C	; 12
    1650:	e8 e1       	ldi	r30, 0x18	; 24
    1652:	f6 e0       	ldi	r31, 0x06	; 6
    1654:	de 01       	movw	r26, r28
    1656:	59 96       	adiw	r26, 0x19	; 25
    1658:	01 90       	ld	r0, Z+
    165a:	0d 92       	st	X+, r0
    165c:	2a 95       	dec	r18
    165e:	e1 f7       	brne	.-8      	; 0x1658 <plan_buffer_line+0x86>
    1660:	89 ab       	std	Y+49, r24	; 0x31
    1662:	9a ab       	std	Y+50, r25	; 0x32
    1664:	22 e4       	ldi	r18, 0x42	; 66
    1666:	36 e0       	ldi	r19, 0x06	; 6
    1668:	21 96       	adiw	r28, 0x01	; 1
    166a:	3f af       	std	Y+63, r19	; 0x3f
    166c:	2e af       	std	Y+62, r18	; 0x3e
    166e:	21 97       	sbiw	r28, 0x01	; 1
    1670:	be 01       	movw	r22, r28
    1672:	63 5f       	subi	r22, 0xF3	; 243
    1674:	7f 4f       	sbci	r23, 0xFF	; 255
    1676:	7e af       	std	Y+62, r23	; 0x3e
    1678:	6d af       	std	Y+61, r22	; 0x3d
    167a:	ce 01       	movw	r24, r28
    167c:	49 96       	adiw	r24, 0x19	; 25
    167e:	9c af       	std	Y+60, r25	; 0x3c
    1680:	8b af       	std	Y+59, r24	; 0x3b
    1682:	eb a9       	ldd	r30, Y+51	; 0x33
    1684:	fc a9       	ldd	r31, Y+52	; 0x34
    1686:	fa af       	std	Y+58, r31	; 0x3a
    1688:	e9 af       	std	Y+57, r30	; 0x39
    168a:	9e 01       	movw	r18, r28
    168c:	2b 5d       	subi	r18, 0xDB	; 219
    168e:	3f 4f       	sbci	r19, 0xFF	; 255
    1690:	3e ab       	std	Y+54, r19	; 0x36
    1692:	2d ab       	std	Y+53, r18	; 0x35
    1694:	38 af       	std	Y+56, r19	; 0x38
    1696:	2f ab       	std	Y+55, r18	; 0x37
    1698:	10 e0       	ldi	r17, 0x00	; 0
    169a:	82 e3       	ldi	r24, 0x32	; 50
    169c:	82 9d       	mul	r24, r2
    169e:	20 01       	movw	r4, r0
    16a0:	83 9d       	mul	r24, r3
    16a2:	50 0c       	add	r5, r0
    16a4:	11 24       	eor	r1, r1
    16a6:	b2 01       	movw	r22, r4
    16a8:	6a 52       	subi	r22, 0x2A	; 42
    16aa:	7d 4f       	sbci	r23, 0xFD	; 253
    16ac:	2b 01       	movw	r4, r22
    16ae:	cb 01       	movw	r24, r22
    16b0:	0c 96       	adiw	r24, 0x0c	; 12
    16b2:	23 96       	adiw	r28, 0x03	; 3
    16b4:	9f af       	std	Y+63, r25	; 0x3f
    16b6:	8e af       	std	Y+62, r24	; 0x3e
    16b8:	23 97       	sbiw	r28, 0x03	; 3
    16ba:	90 e1       	ldi	r25, 0x10	; 16
    16bc:	49 0e       	add	r4, r25
    16be:	51 1c       	adc	r5, r1
    16c0:	e9 a9       	ldd	r30, Y+49	; 0x31
    16c2:	fa a9       	ldd	r31, Y+50	; 0x32
    16c4:	61 91       	ld	r22, Z+
    16c6:	71 91       	ld	r23, Z+
    16c8:	81 91       	ld	r24, Z+
    16ca:	91 91       	ld	r25, Z+
    16cc:	fa ab       	std	Y+50, r31	; 0x32
    16ce:	e9 ab       	std	Y+49, r30	; 0x31
    16d0:	21 96       	adiw	r28, 0x01	; 1
    16d2:	ee ad       	ldd	r30, Y+62	; 0x3e
    16d4:	ff ad       	ldd	r31, Y+63	; 0x3f
    16d6:	21 97       	sbiw	r28, 0x01	; 1
    16d8:	81 90       	ld	r8, Z+
    16da:	91 90       	ld	r9, Z+
    16dc:	a1 90       	ld	r10, Z+
    16de:	b1 90       	ld	r11, Z+
    16e0:	21 96       	adiw	r28, 0x01	; 1
    16e2:	ff af       	std	Y+63, r31	; 0x3f
    16e4:	ee af       	std	Y+62, r30	; 0x3e
    16e6:	21 97       	sbiw	r28, 0x01	; 1
    16e8:	a5 01       	movw	r20, r10
    16ea:	94 01       	movw	r18, r8
    16ec:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    16f0:	0e 94 35 38 	call	0x706a	; 0x706a <lround>
    16f4:	ed ad       	ldd	r30, Y+61	; 0x3d
    16f6:	fe ad       	ldd	r31, Y+62	; 0x3e
    16f8:	61 93       	st	Z+, r22
    16fa:	71 93       	st	Z+, r23
    16fc:	81 93       	st	Z+, r24
    16fe:	91 93       	st	Z+, r25
    1700:	fe af       	std	Y+62, r31	; 0x3e
    1702:	ed af       	std	Y+61, r30	; 0x3d
    1704:	eb ad       	ldd	r30, Y+59	; 0x3b
    1706:	fc ad       	ldd	r31, Y+60	; 0x3c
    1708:	c1 90       	ld	r12, Z+
    170a:	d1 90       	ld	r13, Z+
    170c:	e1 90       	ld	r14, Z+
    170e:	f1 90       	ld	r15, Z+
    1710:	fc af       	std	Y+60, r31	; 0x3c
    1712:	eb af       	std	Y+59, r30	; 0x3b
    1714:	6c 19       	sub	r22, r12
    1716:	7d 09       	sbc	r23, r13
    1718:	8e 09       	sbc	r24, r14
    171a:	9f 09       	sbc	r25, r15
    171c:	9b 01       	movw	r18, r22
    171e:	ac 01       	movw	r20, r24
    1720:	97 ff       	sbrs	r25, 7
    1722:	07 c0       	rjmp	.+14     	; 0x1732 <plan_buffer_line+0x160>
    1724:	22 27       	eor	r18, r18
    1726:	33 27       	eor	r19, r19
    1728:	a9 01       	movw	r20, r18
    172a:	26 1b       	sub	r18, r22
    172c:	37 0b       	sbc	r19, r23
    172e:	48 0b       	sbc	r20, r24
    1730:	59 0b       	sbc	r21, r25
    1732:	e9 ad       	ldd	r30, Y+57	; 0x39
    1734:	fa ad       	ldd	r31, Y+58	; 0x3a
    1736:	21 93       	st	Z+, r18
    1738:	31 93       	st	Z+, r19
    173a:	41 93       	st	Z+, r20
    173c:	51 93       	st	Z+, r21
    173e:	fa af       	std	Y+58, r31	; 0x3a
    1740:	e9 af       	std	Y+57, r30	; 0x39
    1742:	23 96       	adiw	r28, 0x03	; 3
    1744:	ee ad       	ldd	r30, Y+62	; 0x3e
    1746:	ff ad       	ldd	r31, Y+63	; 0x3f
    1748:	23 97       	sbiw	r28, 0x03	; 3
    174a:	c0 80       	ld	r12, Z
    174c:	d1 80       	ldd	r13, Z+1	; 0x01
    174e:	e2 80       	ldd	r14, Z+2	; 0x02
    1750:	f3 80       	ldd	r15, Z+3	; 0x03
    1752:	c2 16       	cp	r12, r18
    1754:	d3 06       	cpc	r13, r19
    1756:	e4 06       	cpc	r14, r20
    1758:	f5 06       	cpc	r15, r21
    175a:	10 f4       	brcc	.+4      	; 0x1760 <plan_buffer_line+0x18e>
    175c:	69 01       	movw	r12, r18
    175e:	7a 01       	movw	r14, r20
    1760:	23 96       	adiw	r28, 0x03	; 3
    1762:	ee ad       	ldd	r30, Y+62	; 0x3e
    1764:	ff ad       	ldd	r31, Y+63	; 0x3f
    1766:	23 97       	sbiw	r28, 0x03	; 3
    1768:	c0 82       	st	Z, r12
    176a:	d1 82       	std	Z+1, r13	; 0x01
    176c:	e2 82       	std	Z+2, r14	; 0x02
    176e:	f3 82       	std	Z+3, r15	; 0x03
    1770:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
    1774:	a5 01       	movw	r20, r10
    1776:	94 01       	movw	r18, r8
    1778:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    177c:	ef a9       	ldd	r30, Y+55	; 0x37
    177e:	f8 ad       	ldd	r31, Y+56	; 0x38
    1780:	61 93       	st	Z+, r22
    1782:	71 93       	st	Z+, r23
    1784:	81 93       	st	Z+, r24
    1786:	91 93       	st	Z+, r25
    1788:	f8 af       	std	Y+56, r31	; 0x38
    178a:	ef ab       	std	Y+55, r30	; 0x37
    178c:	20 e0       	ldi	r18, 0x00	; 0
    178e:	30 e0       	ldi	r19, 0x00	; 0
    1790:	a9 01       	movw	r20, r18
    1792:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    1796:	87 ff       	sbrs	r24, 7
    1798:	0b c0       	rjmp	.+22     	; 0x17b0 <plan_buffer_line+0x1de>
    179a:	90 e2       	ldi	r25, 0x20	; 32
    179c:	11 23       	and	r17, r17
    179e:	21 f0       	breq	.+8      	; 0x17a8 <plan_buffer_line+0x1d6>
    17a0:	90 e4       	ldi	r25, 0x40	; 64
    17a2:	11 30       	cpi	r17, 0x01	; 1
    17a4:	09 f0       	breq	.+2      	; 0x17a8 <plan_buffer_line+0x1d6>
    17a6:	90 e8       	ldi	r25, 0x80	; 128
    17a8:	f2 01       	movw	r30, r4
    17aa:	80 81       	ld	r24, Z
    17ac:	89 2b       	or	r24, r25
    17ae:	80 83       	st	Z, r24
    17b0:	1f 5f       	subi	r17, 0xFF	; 255
    17b2:	13 30       	cpi	r17, 0x03	; 3
    17b4:	09 f0       	breq	.+2      	; 0x17b8 <plan_buffer_line+0x1e6>
    17b6:	84 cf       	rjmp	.-248    	; 0x16c0 <plan_buffer_line+0xee>
    17b8:	80 e0       	ldi	r24, 0x00	; 0
    17ba:	cd 28       	or	r12, r13
    17bc:	ce 28       	or	r12, r14
    17be:	cf 28       	or	r12, r15
    17c0:	09 f4       	brne	.+2      	; 0x17c4 <plan_buffer_line+0x1f2>
    17c2:	cb c0       	rjmp	.+406    	; 0x195a <plan_buffer_line+0x388>
    17c4:	ce 01       	movw	r24, r28
    17c6:	85 96       	adiw	r24, 0x25	; 37
    17c8:	0e 94 b3 09 	call	0x1366	; 0x1366 <convert_delta_vector_to_unit_vector>
    17cc:	4b 01       	movw	r8, r22
    17ce:	5c 01       	movw	r10, r24
    17d0:	22 e3       	ldi	r18, 0x32	; 50
    17d2:	22 9d       	mul	r18, r2
    17d4:	c0 01       	movw	r24, r0
    17d6:	23 9d       	mul	r18, r3
    17d8:	90 0d       	add	r25, r0
    17da:	11 24       	eor	r1, r1
    17dc:	9c 01       	movw	r18, r24
    17de:	2a 52       	subi	r18, 0x2A	; 42
    17e0:	3d 4f       	sbci	r19, 0xFD	; 253
    17e2:	79 01       	movw	r14, r18
    17e4:	f9 01       	movw	r30, r18
    17e6:	86 8e       	std	Z+30, r8	; 0x1e
    17e8:	97 8e       	std	Z+31, r9	; 0x1f
    17ea:	a0 a2       	std	Z+32, r10	; 0x20
    17ec:	b1 a2       	std	Z+33, r11	; 0x21
    17ee:	be 01       	movw	r22, r28
    17f0:	6b 5d       	subi	r22, 0xDB	; 219
    17f2:	7f 4f       	sbci	r23, 0xFF	; 255
    17f4:	8a e5       	ldi	r24, 0x5A	; 90
    17f6:	96 e0       	ldi	r25, 0x06	; 6
    17f8:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    17fc:	f7 01       	movw	r30, r14
    17fe:	62 8f       	std	Z+26, r22	; 0x1a
    1800:	73 8f       	std	Z+27, r23	; 0x1b
    1802:	84 8f       	std	Z+28, r24	; 0x1c
    1804:	95 8f       	std	Z+29, r25	; 0x1d
    1806:	be 01       	movw	r22, r28
    1808:	6b 5d       	subi	r22, 0xDB	; 219
    180a:	7f 4f       	sbci	r23, 0xFF	; 255
    180c:	8e e4       	ldi	r24, 0x4E	; 78
    180e:	96 e0       	ldi	r25, 0x06	; 6
    1810:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    1814:	f7 01       	movw	r30, r14
    1816:	66 a3       	std	Z+38, r22	; 0x26
    1818:	77 a3       	std	Z+39, r23	; 0x27
    181a:	80 a7       	std	Z+40, r24	; 0x28
    181c:	91 a7       	std	Z+41, r25	; 0x29
    181e:	11 89       	ldd	r17, Z+17	; 0x11
    1820:	10 ff       	sbrs	r17, 0
    1822:	09 c0       	rjmp	.+18     	; 0x1836 <plan_buffer_line+0x264>
    1824:	62 a7       	std	Z+42, r22	; 0x2a
    1826:	73 a7       	std	Z+43, r23	; 0x2b
    1828:	84 a7       	std	Z+44, r24	; 0x2c
    182a:	95 a7       	std	Z+45, r25	; 0x2d
    182c:	10 c0       	rjmp	.+32     	; 0x184e <plan_buffer_line+0x27c>
    182e:	2c e0       	ldi	r18, 0x0C	; 12
    1830:	e7 ef       	ldi	r30, 0xF7	; 247
    1832:	f5 e0       	ldi	r31, 0x05	; 5
    1834:	0f cf       	rjmp	.-482    	; 0x1654 <plan_buffer_line+0x82>
    1836:	f3 01       	movw	r30, r6
    1838:	20 81       	ld	r18, Z
    183a:	31 81       	ldd	r19, Z+1	; 0x01
    183c:	42 81       	ldd	r20, Z+2	; 0x02
    183e:	53 81       	ldd	r21, Z+3	; 0x03
    1840:	13 fd       	sbrc	r17, 3
    1842:	a5 c0       	rjmp	.+330    	; 0x198e <plan_buffer_line+0x3bc>
    1844:	f7 01       	movw	r30, r14
    1846:	22 a7       	std	Z+42, r18	; 0x2a
    1848:	33 a7       	std	Z+43, r19	; 0x2b
    184a:	44 a7       	std	Z+44, r20	; 0x2c
    184c:	55 a7       	std	Z+45, r21	; 0x2d
    184e:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    1852:	08 17       	cp	r16, r24
    1854:	11 f0       	breq	.+4      	; 0x185a <plan_buffer_line+0x288>
    1856:	11 ff       	sbrs	r17, 1
    1858:	a0 c0       	rjmp	.+320    	; 0x199a <plan_buffer_line+0x3c8>
    185a:	82 e3       	ldi	r24, 0x32	; 50
    185c:	82 9d       	mul	r24, r2
    185e:	f0 01       	movw	r30, r0
    1860:	83 9d       	mul	r24, r3
    1862:	f0 0d       	add	r31, r0
    1864:	11 24       	eor	r1, r1
    1866:	ea 52       	subi	r30, 0x2A	; 42
    1868:	fd 4f       	sbci	r31, 0xFD	; 253
    186a:	12 8a       	std	Z+18, r1	; 0x12
    186c:	13 8a       	std	Z+19, r1	; 0x13
    186e:	14 8a       	std	Z+20, r1	; 0x14
    1870:	15 8a       	std	Z+21, r1	; 0x15
    1872:	12 a2       	std	Z+34, r1	; 0x22
    1874:	13 a2       	std	Z+35, r1	; 0x23
    1876:	14 a2       	std	Z+36, r1	; 0x24
    1878:	15 a2       	std	Z+37, r1	; 0x25
    187a:	82 e3       	ldi	r24, 0x32	; 50
    187c:	82 9d       	mul	r24, r2
    187e:	80 01       	movw	r16, r0
    1880:	83 9d       	mul	r24, r3
    1882:	10 0d       	add	r17, r0
    1884:	11 24       	eor	r1, r1
    1886:	0a 52       	subi	r16, 0x2A	; 42
    1888:	1d 4f       	sbci	r17, 0xFD	; 253
    188a:	f8 01       	movw	r30, r16
    188c:	81 89       	ldd	r24, Z+17	; 0x11
    188e:	81 fd       	sbrc	r24, 1
    1890:	63 c0       	rjmp	.+198    	; 0x1958 <plan_buffer_line+0x386>
    1892:	8b a9       	ldd	r24, Y+51	; 0x33
    1894:	9c a9       	ldd	r25, Y+52	; 0x34
    1896:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    189a:	6b 01       	movw	r12, r22
    189c:	7c 01       	movw	r14, r24
    189e:	80 90 0f 06 	lds	r8, 0x060F	; 0x80060f <pl+0x18>
    18a2:	90 90 10 06 	lds	r9, 0x0610	; 0x800610 <pl+0x19>
    18a6:	a0 90 11 06 	lds	r10, 0x0611	; 0x800611 <pl+0x1a>
    18aa:	b0 90 12 06 	lds	r11, 0x0612	; 0x800612 <pl+0x1b>
    18ae:	ac 01       	movw	r20, r24
    18b0:	9b 01       	movw	r18, r22
    18b2:	c5 01       	movw	r24, r10
    18b4:	b4 01       	movw	r22, r8
    18b6:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    18ba:	87 ff       	sbrs	r24, 7
    18bc:	37 c1       	rjmp	.+622    	; 0x1b2c <plan_buffer_line+0x55a>
    18be:	a5 01       	movw	r20, r10
    18c0:	94 01       	movw	r18, r8
    18c2:	c5 01       	movw	r24, r10
    18c4:	b4 01       	movw	r22, r8
    18c6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    18ca:	f8 01       	movw	r30, r16
    18cc:	66 8b       	std	Z+22, r22	; 0x16
    18ce:	77 8b       	std	Z+23, r23	; 0x17
    18d0:	80 8f       	std	Z+24, r24	; 0x18
    18d2:	91 8f       	std	Z+25, r25	; 0x19
    18d4:	82 e3       	ldi	r24, 0x32	; 50
    18d6:	82 9d       	mul	r24, r2
    18d8:	80 01       	movw	r16, r0
    18da:	83 9d       	mul	r24, r3
    18dc:	10 0d       	add	r17, r0
    18de:	11 24       	eor	r1, r1
    18e0:	0a 52       	subi	r16, 0x2A	; 42
    18e2:	1d 4f       	sbci	r17, 0xFD	; 253
    18e4:	f8 01       	movw	r30, r16
    18e6:	82 a0       	ldd	r8, Z+34	; 0x22
    18e8:	93 a0       	ldd	r9, Z+35	; 0x23
    18ea:	a4 a0       	ldd	r10, Z+36	; 0x24
    18ec:	b5 a0       	ldd	r11, Z+37	; 0x25
    18ee:	a5 01       	movw	r20, r10
    18f0:	94 01       	movw	r18, r8
    18f2:	66 89       	ldd	r22, Z+22	; 0x16
    18f4:	77 89       	ldd	r23, Z+23	; 0x17
    18f6:	80 8d       	ldd	r24, Z+24	; 0x18
    18f8:	91 8d       	ldd	r25, Z+25	; 0x19
    18fa:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    18fe:	18 16       	cp	r1, r24
    1900:	2c f4       	brge	.+10     	; 0x190c <plan_buffer_line+0x33a>
    1902:	f8 01       	movw	r30, r16
    1904:	86 8a       	std	Z+22, r8	; 0x16
    1906:	97 8a       	std	Z+23, r9	; 0x17
    1908:	a0 8e       	std	Z+24, r10	; 0x18
    190a:	b1 8e       	std	Z+25, r11	; 0x19
    190c:	c0 92 0f 06 	sts	0x060F, r12	; 0x80060f <pl+0x18>
    1910:	d0 92 10 06 	sts	0x0610, r13	; 0x800610 <pl+0x19>
    1914:	e0 92 11 06 	sts	0x0611, r14	; 0x800611 <pl+0x1a>
    1918:	f0 92 12 06 	sts	0x0612, r15	; 0x800612 <pl+0x1b>
    191c:	8c e0       	ldi	r24, 0x0C	; 12
    191e:	fe 01       	movw	r30, r28
    1920:	b5 96       	adiw	r30, 0x25	; 37
    1922:	a3 e0       	ldi	r26, 0x03	; 3
    1924:	b6 e0       	ldi	r27, 0x06	; 6
    1926:	01 90       	ld	r0, Z+
    1928:	0d 92       	st	X+, r0
    192a:	8a 95       	dec	r24
    192c:	e1 f7       	brne	.-8      	; 0x1926 <plan_buffer_line+0x354>
    192e:	8c e0       	ldi	r24, 0x0C	; 12
    1930:	fe 01       	movw	r30, r28
    1932:	3d 96       	adiw	r30, 0x0d	; 13
    1934:	a7 ef       	ldi	r26, 0xF7	; 247
    1936:	b5 e0       	ldi	r27, 0x05	; 5
    1938:	01 90       	ld	r0, Z+
    193a:	0d 92       	st	X+, r0
    193c:	8a 95       	dec	r24
    193e:	e1 f7       	brne	.-8      	; 0x1938 <plan_buffer_line+0x366>
    1940:	80 91 d4 02 	lds	r24, 0x02D4	; 0x8002d4 <next_buffer_head>
    1944:	80 93 f6 05 	sts	0x05F6, r24	; 0x8005f6 <block_buffer_head>
    1948:	8f 5f       	subi	r24, 0xFF	; 255
    194a:	80 31       	cpi	r24, 0x10	; 16
    194c:	09 f4       	brne	.+2      	; 0x1950 <plan_buffer_line+0x37e>
    194e:	80 e0       	ldi	r24, 0x00	; 0
    1950:	80 93 d4 02 	sts	0x02D4, r24	; 0x8002d4 <next_buffer_head>
    1954:	0e 94 f4 04 	call	0x9e8	; 0x9e8 <planner_recalculate>
    1958:	81 e0       	ldi	r24, 0x01	; 1
    195a:	ce 5b       	subi	r28, 0xBE	; 190
    195c:	df 4f       	sbci	r29, 0xFF	; 255
    195e:	0f b6       	in	r0, 0x3f	; 63
    1960:	f8 94       	cli
    1962:	de bf       	out	0x3e, r29	; 62
    1964:	0f be       	out	0x3f, r0	; 63
    1966:	cd bf       	out	0x3d, r28	; 61
    1968:	df 91       	pop	r29
    196a:	cf 91       	pop	r28
    196c:	1f 91       	pop	r17
    196e:	0f 91       	pop	r16
    1970:	ff 90       	pop	r15
    1972:	ef 90       	pop	r14
    1974:	df 90       	pop	r13
    1976:	cf 90       	pop	r12
    1978:	bf 90       	pop	r11
    197a:	af 90       	pop	r10
    197c:	9f 90       	pop	r9
    197e:	8f 90       	pop	r8
    1980:	7f 90       	pop	r7
    1982:	6f 90       	pop	r6
    1984:	5f 90       	pop	r5
    1986:	4f 90       	pop	r4
    1988:	3f 90       	pop	r3
    198a:	2f 90       	pop	r2
    198c:	08 95       	ret
    198e:	c5 01       	movw	r24, r10
    1990:	b4 01       	movw	r22, r8
    1992:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1996:	f7 01       	movw	r30, r14
    1998:	45 cf       	rjmp	.-374    	; 0x1824 <plan_buffer_line+0x252>
    199a:	23 e0       	ldi	r18, 0x03	; 3
    199c:	36 e0       	ldi	r19, 0x06	; 6
    199e:	3a ab       	std	Y+50, r19	; 0x32
    19a0:	29 ab       	std	Y+49, r18	; 0x31
    19a2:	8e 01       	movw	r16, r28
    19a4:	0f 5f       	subi	r16, 0xFF	; 255
    19a6:	1f 4f       	sbci	r17, 0xFF	; 255
    19a8:	6d a9       	ldd	r22, Y+53	; 0x35
    19aa:	7e a9       	ldd	r23, Y+54	; 0x36
    19ac:	64 5f       	subi	r22, 0xF4	; 244
    19ae:	7f 4f       	sbci	r23, 0xFF	; 255
    19b0:	7c af       	std	Y+60, r23	; 0x3c
    19b2:	6b af       	std	Y+59, r22	; 0x3b
    19b4:	c1 2c       	mov	r12, r1
    19b6:	d1 2c       	mov	r13, r1
    19b8:	76 01       	movw	r14, r12
    19ba:	0f ab       	std	Y+55, r16	; 0x37
    19bc:	19 af       	std	Y+57, r17	; 0x39
    19be:	e9 a9       	ldd	r30, Y+49	; 0x31
    19c0:	fa a9       	ldd	r31, Y+50	; 0x32
    19c2:	81 90       	ld	r8, Z+
    19c4:	91 90       	ld	r9, Z+
    19c6:	a1 90       	ld	r10, Z+
    19c8:	b1 90       	ld	r11, Z+
    19ca:	fa ab       	std	Y+50, r31	; 0x32
    19cc:	e9 ab       	std	Y+49, r30	; 0x31
    19ce:	ed a9       	ldd	r30, Y+53	; 0x35
    19d0:	fe a9       	ldd	r31, Y+54	; 0x36
    19d2:	41 90       	ld	r4, Z+
    19d4:	51 90       	ld	r5, Z+
    19d6:	61 90       	ld	r6, Z+
    19d8:	71 90       	ld	r7, Z+
    19da:	fe ab       	std	Y+54, r31	; 0x36
    19dc:	ed ab       	std	Y+53, r30	; 0x35
    19de:	a3 01       	movw	r20, r6
    19e0:	92 01       	movw	r18, r4
    19e2:	c5 01       	movw	r24, r10
    19e4:	b4 01       	movw	r22, r8
    19e6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    19ea:	9b 01       	movw	r18, r22
    19ec:	ac 01       	movw	r20, r24
    19ee:	c7 01       	movw	r24, r14
    19f0:	b6 01       	movw	r22, r12
    19f2:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    19f6:	6b 01       	movw	r12, r22
    19f8:	7c 01       	movw	r14, r24
    19fa:	a5 01       	movw	r20, r10
    19fc:	94 01       	movw	r18, r8
    19fe:	c3 01       	movw	r24, r6
    1a00:	b2 01       	movw	r22, r4
    1a02:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1a06:	f8 01       	movw	r30, r16
    1a08:	61 93       	st	Z+, r22
    1a0a:	71 93       	st	Z+, r23
    1a0c:	81 93       	st	Z+, r24
    1a0e:	91 93       	st	Z+, r25
    1a10:	8f 01       	movw	r16, r30
    1a12:	2b ad       	ldd	r18, Y+59	; 0x3b
    1a14:	3c ad       	ldd	r19, Y+60	; 0x3c
    1a16:	6d a9       	ldd	r22, Y+53	; 0x35
    1a18:	7e a9       	ldd	r23, Y+54	; 0x36
    1a1a:	26 17       	cp	r18, r22
    1a1c:	37 07       	cpc	r19, r23
    1a1e:	79 f6       	brne	.-98     	; 0x19be <plan_buffer_line+0x3ec>
    1a20:	2f ee       	ldi	r18, 0xEF	; 239
    1a22:	3f ef       	ldi	r19, 0xFF	; 255
    1a24:	4f e7       	ldi	r20, 0x7F	; 127
    1a26:	5f e3       	ldi	r21, 0x3F	; 63
    1a28:	c7 01       	movw	r24, r14
    1a2a:	b6 01       	movw	r22, r12
    1a2c:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    1a30:	18 16       	cp	r1, r24
    1a32:	4c f4       	brge	.+18     	; 0x1a46 <plan_buffer_line+0x474>
    1a34:	82 e3       	ldi	r24, 0x32	; 50
    1a36:	82 9d       	mul	r24, r2
    1a38:	f0 01       	movw	r30, r0
    1a3a:	83 9d       	mul	r24, r3
    1a3c:	f0 0d       	add	r31, r0
    1a3e:	11 24       	eor	r1, r1
    1a40:	ea 52       	subi	r30, 0x2A	; 42
    1a42:	fd 4f       	sbci	r31, 0xFD	; 253
    1a44:	16 cf       	rjmp	.-468    	; 0x1872 <plan_buffer_line+0x2a0>
    1a46:	2f ee       	ldi	r18, 0xEF	; 239
    1a48:	3f ef       	ldi	r19, 0xFF	; 255
    1a4a:	4f e7       	ldi	r20, 0x7F	; 127
    1a4c:	5f eb       	ldi	r21, 0xBF	; 191
    1a4e:	c7 01       	movw	r24, r14
    1a50:	b6 01       	movw	r22, r12
    1a52:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    1a56:	87 ff       	sbrs	r24, 7
    1a58:	11 c0       	rjmp	.+34     	; 0x1a7c <plan_buffer_line+0x4aa>
    1a5a:	82 e3       	ldi	r24, 0x32	; 50
    1a5c:	82 9d       	mul	r24, r2
    1a5e:	f0 01       	movw	r30, r0
    1a60:	83 9d       	mul	r24, r3
    1a62:	f0 0d       	add	r31, r0
    1a64:	11 24       	eor	r1, r1
    1a66:	ea 52       	subi	r30, 0x2A	; 42
    1a68:	fd 4f       	sbci	r31, 0xFD	; 253
    1a6a:	89 e9       	ldi	r24, 0x99	; 153
    1a6c:	96 e7       	ldi	r25, 0x76	; 118
    1a6e:	a6 e9       	ldi	r26, 0x96	; 150
    1a70:	be e7       	ldi	r27, 0x7E	; 126
    1a72:	82 a3       	std	Z+34, r24	; 0x22
    1a74:	93 a3       	std	Z+35, r25	; 0x23
    1a76:	a4 a3       	std	Z+36, r26	; 0x24
    1a78:	b5 a3       	std	Z+37, r27	; 0x25
    1a7a:	ff ce       	rjmp	.-514    	; 0x187a <plan_buffer_line+0x2a8>
    1a7c:	8f a9       	ldd	r24, Y+55	; 0x37
    1a7e:	99 ad       	ldd	r25, Y+57	; 0x39
    1a80:	0e 94 b3 09 	call	0x1366	; 0x1366 <convert_delta_vector_to_unit_vector>
    1a84:	6f a9       	ldd	r22, Y+55	; 0x37
    1a86:	79 ad       	ldd	r23, Y+57	; 0x39
    1a88:	8a e5       	ldi	r24, 0x5A	; 90
    1a8a:	96 e0       	ldi	r25, 0x06	; 6
    1a8c:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    1a90:	4b 01       	movw	r8, r22
    1a92:	5c 01       	movw	r10, r24
    1a94:	a7 01       	movw	r20, r14
    1a96:	96 01       	movw	r18, r12
    1a98:	60 e0       	ldi	r22, 0x00	; 0
    1a9a:	70 e0       	ldi	r23, 0x00	; 0
    1a9c:	80 e8       	ldi	r24, 0x80	; 128
    1a9e:	9f e3       	ldi	r25, 0x3F	; 63
    1aa0:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1aa4:	20 e0       	ldi	r18, 0x00	; 0
    1aa6:	30 e0       	ldi	r19, 0x00	; 0
    1aa8:	40 e0       	ldi	r20, 0x00	; 0
    1aaa:	5f e3       	ldi	r21, 0x3F	; 63
    1aac:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1ab0:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    1ab4:	6b 01       	movw	r12, r22
    1ab6:	7c 01       	movw	r14, r24
    1ab8:	82 e3       	ldi	r24, 0x32	; 50
    1aba:	82 9d       	mul	r24, r2
    1abc:	80 01       	movw	r16, r0
    1abe:	83 9d       	mul	r24, r3
    1ac0:	10 0d       	add	r17, r0
    1ac2:	11 24       	eor	r1, r1
    1ac4:	0a 52       	subi	r16, 0x2A	; 42
    1ac6:	1d 4f       	sbci	r17, 0xFD	; 253
    1ac8:	a7 01       	movw	r20, r14
    1aca:	96 01       	movw	r18, r12
    1acc:	c5 01       	movw	r24, r10
    1ace:	b4 01       	movw	r22, r8
    1ad0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1ad4:	20 91 77 06 	lds	r18, 0x0677	; 0x800677 <settings+0x35>
    1ad8:	30 91 78 06 	lds	r19, 0x0678	; 0x800678 <settings+0x36>
    1adc:	40 91 79 06 	lds	r20, 0x0679	; 0x800679 <settings+0x37>
    1ae0:	50 91 7a 06 	lds	r21, 0x067A	; 0x80067a <settings+0x38>
    1ae4:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1ae8:	4b 01       	movw	r8, r22
    1aea:	5c 01       	movw	r10, r24
    1aec:	a7 01       	movw	r20, r14
    1aee:	96 01       	movw	r18, r12
    1af0:	60 e0       	ldi	r22, 0x00	; 0
    1af2:	70 e0       	ldi	r23, 0x00	; 0
    1af4:	80 e8       	ldi	r24, 0x80	; 128
    1af6:	9f e3       	ldi	r25, 0x3F	; 63
    1af8:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1afc:	9b 01       	movw	r18, r22
    1afe:	ac 01       	movw	r20, r24
    1b00:	c5 01       	movw	r24, r10
    1b02:	b4 01       	movw	r22, r8
    1b04:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    1b08:	6b 01       	movw	r12, r22
    1b0a:	7c 01       	movw	r14, r24
    1b0c:	20 e0       	ldi	r18, 0x00	; 0
    1b0e:	30 e0       	ldi	r19, 0x00	; 0
    1b10:	a9 01       	movw	r20, r18
    1b12:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    1b16:	87 ff       	sbrs	r24, 7
    1b18:	03 c0       	rjmp	.+6      	; 0x1b20 <plan_buffer_line+0x54e>
    1b1a:	c1 2c       	mov	r12, r1
    1b1c:	d1 2c       	mov	r13, r1
    1b1e:	76 01       	movw	r14, r12
    1b20:	f8 01       	movw	r30, r16
    1b22:	c2 a2       	std	Z+34, r12	; 0x22
    1b24:	d3 a2       	std	Z+35, r13	; 0x23
    1b26:	e4 a2       	std	Z+36, r14	; 0x24
    1b28:	f5 a2       	std	Z+37, r15	; 0x25
    1b2a:	a7 ce       	rjmp	.-690    	; 0x187a <plan_buffer_line+0x2a8>
    1b2c:	a7 01       	movw	r20, r14
    1b2e:	96 01       	movw	r18, r12
    1b30:	c7 01       	movw	r24, r14
    1b32:	b6 01       	movw	r22, r12
    1b34:	c8 ce       	rjmp	.-624    	; 0x18c6 <plan_buffer_line+0x2f4>

00001b36 <st_go_idle>:
    1b36:	80 91 6f 00 	lds	r24, 0x006F	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
    1b3a:	8d 7f       	andi	r24, 0xFD	; 253
    1b3c:	80 93 6f 00 	sts	0x006F, r24	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
    1b40:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    1b44:	88 7f       	andi	r24, 0xF8	; 248
    1b46:	81 60       	ori	r24, 0x01	; 1
    1b48:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    1b4c:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    1b50:	80 91 75 06 	lds	r24, 0x0675	; 0x800675 <settings+0x33>
    1b54:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    1b58:	8f 3f       	cpi	r24, 0xFF	; 255
    1b5a:	a1 f4       	brne	.+40     	; 0x1b84 <st_go_idle+0x4e>
    1b5c:	20 91 14 06 	lds	r18, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    1b60:	21 11       	cpse	r18, r1
    1b62:	10 c0       	rjmp	.+32     	; 0x1b84 <st_go_idle+0x4e>
    1b64:	90 38       	cpi	r25, 0x80	; 128
    1b66:	81 f4       	brne	.+32     	; 0x1b88 <st_go_idle+0x52>
    1b68:	90 e0       	ldi	r25, 0x00	; 0
    1b6a:	01 97       	sbiw	r24, 0x01	; 1
    1b6c:	78 f4       	brcc	.+30     	; 0x1b8c <st_go_idle+0x56>
    1b6e:	81 e0       	ldi	r24, 0x01	; 1
    1b70:	90 91 87 06 	lds	r25, 0x0687	; 0x800687 <settings+0x45>
    1b74:	92 ff       	sbrs	r25, 2
    1b76:	02 c0       	rjmp	.+4      	; 0x1b7c <st_go_idle+0x46>
    1b78:	91 e0       	ldi	r25, 0x01	; 1
    1b7a:	89 27       	eor	r24, r25
    1b7c:	88 23       	and	r24, r24
    1b7e:	69 f0       	breq	.+26     	; 0x1b9a <st_go_idle+0x64>
    1b80:	28 9a       	sbi	0x05, 0	; 5
    1b82:	08 95       	ret
    1b84:	94 30       	cpi	r25, 0x04	; 4
    1b86:	81 f7       	brne	.-32     	; 0x1b68 <st_go_idle+0x32>
    1b88:	80 e0       	ldi	r24, 0x00	; 0
    1b8a:	f2 cf       	rjmp	.-28     	; 0x1b70 <st_go_idle+0x3a>
    1b8c:	ef e9       	ldi	r30, 0x9F	; 159
    1b8e:	ff e0       	ldi	r31, 0x0F	; 15
    1b90:	31 97       	sbiw	r30, 0x01	; 1
    1b92:	f1 f7       	brne	.-4      	; 0x1b90 <st_go_idle+0x5a>
    1b94:	00 c0       	rjmp	.+0      	; 0x1b96 <st_go_idle+0x60>
    1b96:	00 00       	nop
    1b98:	e8 cf       	rjmp	.-48     	; 0x1b6a <st_go_idle+0x34>
    1b9a:	28 98       	cbi	0x05, 0	; 5
    1b9c:	08 95       	ret

00001b9e <st_reset>:
    1b9e:	cf 93       	push	r28
    1ba0:	df 93       	push	r29
    1ba2:	0e 94 9b 0d 	call	0x1b36	; 0x1b36 <st_go_idle>
    1ba6:	e1 ea       	ldi	r30, 0xA1	; 161
    1ba8:	f2 e0       	ldi	r31, 0x02	; 2
    1baa:	80 e3       	ldi	r24, 0x30	; 48
    1bac:	df 01       	movw	r26, r30
    1bae:	1d 92       	st	X+, r1
    1bb0:	8a 95       	dec	r24
    1bb2:	e9 f7       	brne	.-6      	; 0x1bae <st_reset+0x10>
    1bb4:	c5 ef       	ldi	r28, 0xF5	; 245
    1bb6:	d1 e0       	ldi	r29, 0x01	; 1
    1bb8:	83 e2       	ldi	r24, 0x23	; 35
    1bba:	fe 01       	movw	r30, r28
    1bbc:	11 92       	st	Z+, r1
    1bbe:	8a 95       	dec	r24
    1bc0:	e9 f7       	brne	.-6      	; 0x1bbc <st_reset+0x1e>
    1bc2:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
    1bc6:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
    1bca:	10 92 18 02 	sts	0x0218, r1	; 0x800218 <segment_buffer_tail>
    1bce:	10 92 44 02 	sts	0x0244, r1	; 0x800244 <segment_buffer_head>
    1bd2:	81 e0       	ldi	r24, 0x01	; 1
    1bd4:	80 93 19 02 	sts	0x0219, r24	; 0x800219 <segment_next_head>
    1bd8:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    1bdc:	0e 94 4f 06 	call	0xc9e	; 0xc9e <st_generate_step_dir_invert_masks>
    1be0:	80 91 f3 01 	lds	r24, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    1be4:	8f 87       	std	Y+15, r24	; 0x0f
    1be6:	8b b1       	in	r24, 0x0b	; 11
    1be8:	83 7e       	andi	r24, 0xE3	; 227
    1bea:	90 91 f2 01 	lds	r25, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    1bee:	89 2b       	or	r24, r25
    1bf0:	8b b9       	out	0x0b, r24	; 11
    1bf2:	8b b1       	in	r24, 0x0b	; 11
    1bf4:	8f 71       	andi	r24, 0x1F	; 31
    1bf6:	90 91 f3 01 	lds	r25, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    1bfa:	89 2b       	or	r24, r25
    1bfc:	8b b9       	out	0x0b, r24	; 11
    1bfe:	df 91       	pop	r29
    1c00:	cf 91       	pop	r28
    1c02:	08 95       	ret

00001c04 <mc_reset>:
    1c04:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    1c08:	84 fd       	sbrc	r24, 4
    1c0a:	1f c0       	rjmp	.+62     	; 0x1c4a <mc_reset+0x46>
    1c0c:	80 e1       	ldi	r24, 0x10	; 16
    1c0e:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    1c12:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    1c16:	8f 77       	andi	r24, 0x7F	; 127
    1c18:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    1c1c:	43 98       	cbi	0x08, 3	; 8
    1c1e:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    1c22:	89 2f       	mov	r24, r25
    1c24:	8c 72       	andi	r24, 0x2C	; 44
    1c26:	21 f4       	brne	.+8      	; 0x1c30 <mc_reset+0x2c>
    1c28:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    1c2c:	86 70       	andi	r24, 0x06	; 6
    1c2e:	69 f0       	breq	.+26     	; 0x1c4a <mc_reset+0x46>
    1c30:	94 30       	cpi	r25, 0x04	; 4
    1c32:	49 f4       	brne	.+18     	; 0x1c46 <mc_reset+0x42>
    1c34:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    1c38:	81 11       	cpse	r24, r1
    1c3a:	03 c0       	rjmp	.+6      	; 0x1c42 <mc_reset+0x3e>
    1c3c:	86 e0       	ldi	r24, 0x06	; 6
    1c3e:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    1c42:	0c 94 9b 0d 	jmp	0x1b36	; 0x1b36 <st_go_idle>
    1c46:	83 e0       	ldi	r24, 0x03	; 3
    1c48:	fa cf       	rjmp	.-12     	; 0x1c3e <mc_reset+0x3a>
    1c4a:	08 95       	ret

00001c4c <st_prep_buffer>:
    1c4c:	2f 92       	push	r2
    1c4e:	3f 92       	push	r3
    1c50:	4f 92       	push	r4
    1c52:	5f 92       	push	r5
    1c54:	6f 92       	push	r6
    1c56:	7f 92       	push	r7
    1c58:	8f 92       	push	r8
    1c5a:	9f 92       	push	r9
    1c5c:	af 92       	push	r10
    1c5e:	bf 92       	push	r11
    1c60:	cf 92       	push	r12
    1c62:	df 92       	push	r13
    1c64:	ef 92       	push	r14
    1c66:	ff 92       	push	r15
    1c68:	0f 93       	push	r16
    1c6a:	1f 93       	push	r17
    1c6c:	cf 93       	push	r28
    1c6e:	df 93       	push	r29
    1c70:	cd b7       	in	r28, 0x3d	; 61
    1c72:	de b7       	in	r29, 0x3e	; 62
    1c74:	c0 54       	subi	r28, 0x40	; 64
    1c76:	d1 09       	sbc	r29, r1
    1c78:	0f b6       	in	r0, 0x3f	; 63
    1c7a:	f8 94       	cli
    1c7c:	de bf       	out	0x3e, r29	; 62
    1c7e:	0f be       	out	0x3f, r0	; 63
    1c80:	cd bf       	out	0x3d, r28	; 61
    1c82:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    1c86:	80 fd       	sbrc	r24, 0
    1c88:	61 c2       	rjmp	.+1218   	; 0x214c <st_prep_buffer+0x500>
    1c8a:	90 91 18 02 	lds	r25, 0x0218	; 0x800218 <segment_buffer_tail>
    1c8e:	80 91 19 02 	lds	r24, 0x0219	; 0x800219 <segment_next_head>
    1c92:	98 17       	cp	r25, r24
    1c94:	09 f4       	brne	.+2      	; 0x1c98 <st_prep_buffer+0x4c>
    1c96:	5a c2       	rjmp	.+1204   	; 0x214c <st_prep_buffer+0x500>
    1c98:	80 91 d1 02 	lds	r24, 0x02D1	; 0x8002d1 <pl_block>
    1c9c:	90 91 d2 02 	lds	r25, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1ca0:	89 2b       	or	r24, r25
    1ca2:	09 f0       	breq	.+2      	; 0x1ca6 <st_prep_buffer+0x5a>
    1ca4:	7e c0       	rjmp	.+252    	; 0x1da2 <st_prep_buffer+0x156>
    1ca6:	10 91 35 06 	lds	r17, 0x0635	; 0x800635 <sys+0x4>
    1caa:	12 ff       	sbrs	r17, 2
    1cac:	69 c2       	rjmp	.+1234   	; 0x2180 <st_prep_buffer+0x534>
    1cae:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    1cb2:	22 e3       	ldi	r18, 0x32	; 50
    1cb4:	82 9f       	mul	r24, r18
    1cb6:	c0 01       	movw	r24, r0
    1cb8:	11 24       	eor	r1, r1
    1cba:	8a 52       	subi	r24, 0x2A	; 42
    1cbc:	9d 4f       	sbci	r25, 0xFD	; 253
    1cbe:	90 93 d2 02 	sts	0x02D2, r25	; 0x8002d2 <pl_block+0x1>
    1cc2:	80 93 d1 02 	sts	0x02D1, r24	; 0x8002d1 <pl_block>
    1cc6:	40 91 d1 02 	lds	r20, 0x02D1	; 0x8002d1 <pl_block>
    1cca:	50 91 d2 02 	lds	r21, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1cce:	5e 83       	std	Y+6, r21	; 0x06
    1cd0:	4d 83       	std	Y+5, r20	; 0x05
    1cd2:	45 2b       	or	r20, r21
    1cd4:	09 f4       	brne	.+2      	; 0x1cd8 <st_prep_buffer+0x8c>
    1cd6:	3a c2       	rjmp	.+1140   	; 0x214c <st_prep_buffer+0x500>
    1cd8:	00 91 a2 02 	lds	r16, 0x02A2	; 0x8002a2 <prep+0x1>
    1cdc:	00 ff       	sbrs	r16, 0
    1cde:	53 c2       	rjmp	.+1190   	; 0x2186 <st_prep_buffer+0x53a>
    1ce0:	10 92 a2 02 	sts	0x02A2, r1	; 0x8002a2 <prep+0x1>
    1ce4:	10 92 b4 02 	sts	0x02B4, r1	; 0x8002b4 <prep+0x13>
    1ce8:	10 92 b5 02 	sts	0x02B5, r1	; 0x8002b5 <prep+0x14>
    1cec:	10 92 b6 02 	sts	0x02B6, r1	; 0x8002b6 <prep+0x15>
    1cf0:	10 92 b7 02 	sts	0x02B7, r1	; 0x8002b7 <prep+0x16>
    1cf4:	ad 81       	ldd	r26, Y+5	; 0x05
    1cf6:	be 81       	ldd	r27, Y+6	; 0x06
    1cf8:	5a 96       	adiw	r26, 0x1a	; 26
    1cfa:	2d 91       	ld	r18, X+
    1cfc:	3d 91       	ld	r19, X+
    1cfe:	4d 91       	ld	r20, X+
    1d00:	5c 91       	ld	r21, X
    1d02:	5d 97       	sbiw	r26, 0x1d	; 29
    1d04:	2d 87       	std	Y+13, r18	; 0x0d
    1d06:	3e 87       	std	Y+14, r19	; 0x0e
    1d08:	4f 87       	std	Y+15, r20	; 0x0f
    1d0a:	58 8b       	std	Y+16, r21	; 0x10
    1d0c:	60 e0       	ldi	r22, 0x00	; 0
    1d0e:	70 e0       	ldi	r23, 0x00	; 0
    1d10:	80 e0       	ldi	r24, 0x00	; 0
    1d12:	9f e3       	ldi	r25, 0x3F	; 63
    1d14:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    1d18:	69 83       	std	Y+1, r22	; 0x01
    1d1a:	7a 83       	std	Y+2, r23	; 0x02
    1d1c:	8b 83       	std	Y+3, r24	; 0x03
    1d1e:	9c 83       	std	Y+4, r25	; 0x04
    1d20:	ed 81       	ldd	r30, Y+5	; 0x05
    1d22:	fe 81       	ldd	r31, Y+6	; 0x06
    1d24:	c6 8c       	ldd	r12, Z+30	; 0x1e
    1d26:	d7 8c       	ldd	r13, Z+31	; 0x1f
    1d28:	e0 a0       	ldd	r14, Z+32	; 0x20
    1d2a:	f1 a0       	ldd	r15, Z+33	; 0x21
    1d2c:	42 88       	ldd	r4, Z+18	; 0x12
    1d2e:	53 88       	ldd	r5, Z+19	; 0x13
    1d30:	64 88       	ldd	r6, Z+20	; 0x14
    1d32:	75 88       	ldd	r7, Z+21	; 0x15
    1d34:	11 ff       	sbrs	r17, 1
    1d36:	14 c3       	rjmp	.+1576   	; 0x2360 <st_prep_buffer+0x714>
    1d38:	f2 e0       	ldi	r31, 0x02	; 2
    1d3a:	f0 93 b3 02 	sts	0x02B3, r31	; 0x8002b3 <prep+0x12>
    1d3e:	a3 01       	movw	r20, r6
    1d40:	92 01       	movw	r18, r4
    1d42:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1d46:	9b 01       	movw	r18, r22
    1d48:	ac 01       	movw	r20, r24
    1d4a:	c7 01       	movw	r24, r14
    1d4c:	b6 01       	movw	r22, r12
    1d4e:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1d52:	4b 01       	movw	r8, r22
    1d54:	5c 01       	movw	r10, r24
    1d56:	20 e0       	ldi	r18, 0x00	; 0
    1d58:	30 e0       	ldi	r19, 0x00	; 0
    1d5a:	a9 01       	movw	r20, r18
    1d5c:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    1d60:	87 ff       	sbrs	r24, 7
    1d62:	ed c2       	rjmp	.+1498   	; 0x233e <st_prep_buffer+0x6f2>
    1d64:	a7 01       	movw	r20, r14
    1d66:	96 01       	movw	r18, r12
    1d68:	6d 85       	ldd	r22, Y+13	; 0x0d
    1d6a:	7e 85       	ldd	r23, Y+14	; 0x0e
    1d6c:	8f 85       	ldd	r24, Y+15	; 0x0f
    1d6e:	98 89       	ldd	r25, Y+16	; 0x10
    1d70:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1d74:	9b 01       	movw	r18, r22
    1d76:	ac 01       	movw	r20, r24
    1d78:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    1d7c:	9b 01       	movw	r18, r22
    1d7e:	ac 01       	movw	r20, r24
    1d80:	c3 01       	movw	r24, r6
    1d82:	b2 01       	movw	r22, r4
    1d84:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1d88:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    1d8c:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    1d90:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    1d94:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    1d98:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    1d9c:	18 60       	ori	r17, 0x08	; 8
    1d9e:	10 93 35 06 	sts	0x0635, r17	; 0x800635 <sys+0x4>
    1da2:	80 91 44 02 	lds	r24, 0x0244	; 0x800244 <segment_buffer_head>
    1da6:	a8 2f       	mov	r26, r24
    1da8:	b0 e0       	ldi	r27, 0x00	; 0
    1daa:	b8 8f       	std	Y+24, r27	; 0x18
    1dac:	af 8b       	std	Y+23, r26	; 0x17
    1dae:	27 e0       	ldi	r18, 0x07	; 7
    1db0:	2a 9f       	mul	r18, r26
    1db2:	f0 01       	movw	r30, r0
    1db4:	2b 9f       	mul	r18, r27
    1db6:	f0 0d       	add	r31, r0
    1db8:	11 24       	eor	r1, r1
    1dba:	e6 5e       	subi	r30, 0xE6	; 230
    1dbc:	fd 4f       	sbci	r31, 0xFD	; 253
    1dbe:	80 91 a1 02 	lds	r24, 0x02A1	; 0x8002a1 <prep>
    1dc2:	84 83       	std	Z+4, r24	; 0x04
    1dc4:	40 91 d1 02 	lds	r20, 0x02D1	; 0x8002d1 <pl_block>
    1dc8:	50 91 d2 02 	lds	r21, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1dcc:	5a 87       	std	Y+10, r21	; 0x0a
    1dce:	49 87       	std	Y+9, r20	; 0x09
    1dd0:	da 01       	movw	r26, r20
    1dd2:	5e 96       	adiw	r26, 0x1e	; 30
    1dd4:	bc 91       	ld	r27, X
    1dd6:	bd 87       	std	Y+13, r27	; 0x0d
    1dd8:	fa 01       	movw	r30, r20
    1dda:	f7 8d       	ldd	r31, Z+31	; 0x1f
    1ddc:	f9 8b       	std	Y+17, r31	; 0x11
    1dde:	da 01       	movw	r26, r20
    1de0:	90 96       	adiw	r26, 0x20	; 32
    1de2:	bc 91       	ld	r27, X
    1de4:	bd 8b       	std	Y+21, r27	; 0x15
    1de6:	fa 01       	movw	r30, r20
    1de8:	f1 a1       	ldd	r31, Z+33	; 0x21
    1dea:	fe 8b       	std	Y+22, r31	; 0x16
    1dec:	20 91 af 02 	lds	r18, 0x02AF	; 0x8002af <prep+0xe>
    1df0:	30 91 b0 02 	lds	r19, 0x02B0	; 0x8002b0 <prep+0xf>
    1df4:	40 91 b1 02 	lds	r20, 0x02B1	; 0x8002b1 <prep+0x10>
    1df8:	50 91 b2 02 	lds	r21, 0x02B2	; 0x8002b2 <prep+0x11>
    1dfc:	6d 85       	ldd	r22, Y+13	; 0x0d
    1dfe:	79 89       	ldd	r23, Y+17	; 0x11
    1e00:	8b 2f       	mov	r24, r27
    1e02:	9f 2f       	mov	r25, r31
    1e04:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1e08:	6e a7       	std	Y+46, r22	; 0x2e
    1e0a:	7f a7       	std	Y+47, r23	; 0x2f
    1e0c:	88 ab       	std	Y+48, r24	; 0x30
    1e0e:	99 ab       	std	Y+49, r25	; 0x31
    1e10:	20 e0       	ldi	r18, 0x00	; 0
    1e12:	30 e0       	ldi	r19, 0x00	; 0
    1e14:	a9 01       	movw	r20, r18
    1e16:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    1e1a:	87 ff       	sbrs	r24, 7
    1e1c:	04 c0       	rjmp	.+8      	; 0x1e26 <st_prep_buffer+0x1da>
    1e1e:	1e a6       	std	Y+46, r1	; 0x2e
    1e20:	1f a6       	std	Y+47, r1	; 0x2f
    1e22:	18 aa       	std	Y+48, r1	; 0x30
    1e24:	19 aa       	std	Y+49, r1	; 0x31
    1e26:	20 91 bc 02 	lds	r18, 0x02BC	; 0x8002bc <prep+0x1b>
    1e2a:	2a 8f       	std	Y+26, r18	; 0x1a
    1e2c:	30 91 bd 02 	lds	r19, 0x02BD	; 0x8002bd <prep+0x1c>
    1e30:	3b 8f       	std	Y+27, r19	; 0x1b
    1e32:	40 91 be 02 	lds	r20, 0x02BE	; 0x8002be <prep+0x1d>
    1e36:	4c 8f       	std	Y+28, r20	; 0x1c
    1e38:	50 91 bf 02 	lds	r21, 0x02BF	; 0x8002bf <prep+0x1e>
    1e3c:	5d 8f       	std	Y+29, r21	; 0x1d
    1e3e:	80 91 c4 02 	lds	r24, 0x02C4	; 0x8002c4 <prep+0x23>
    1e42:	8a a3       	std	Y+34, r24	; 0x22
    1e44:	90 91 c5 02 	lds	r25, 0x02C5	; 0x8002c5 <prep+0x24>
    1e48:	9b a3       	std	Y+35, r25	; 0x23
    1e4a:	a0 91 c6 02 	lds	r26, 0x02C6	; 0x8002c6 <prep+0x25>
    1e4e:	ac a3       	std	Y+36, r26	; 0x24
    1e50:	b0 91 c7 02 	lds	r27, 0x02C7	; 0x8002c7 <prep+0x26>
    1e54:	bd a3       	std	Y+37, r27	; 0x25
    1e56:	9c 01       	movw	r18, r24
    1e58:	ad 01       	movw	r20, r26
    1e5a:	6d 85       	ldd	r22, Y+13	; 0x0d
    1e5c:	79 89       	ldd	r23, Y+17	; 0x11
    1e5e:	8d 89       	ldd	r24, Y+21	; 0x15
    1e60:	9e 89       	ldd	r25, Y+22	; 0x16
    1e62:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1e66:	9b 01       	movw	r18, r22
    1e68:	ac 01       	movw	r20, r24
    1e6a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    1e6e:	6a ab       	std	Y+50, r22	; 0x32
    1e70:	7b ab       	std	Y+51, r23	; 0x33
    1e72:	8c ab       	std	Y+52, r24	; 0x34
    1e74:	9d ab       	std	Y+53, r25	; 0x35
    1e76:	e0 91 b3 02 	lds	r30, 0x02B3	; 0x8002b3 <prep+0x12>
    1e7a:	e9 8f       	std	Y+25, r30	; 0x19
    1e7c:	f0 91 c8 02 	lds	r31, 0x02C8	; 0x8002c8 <prep+0x27>
    1e80:	fe a3       	std	Y+38, r31	; 0x26
    1e82:	20 91 c9 02 	lds	r18, 0x02C9	; 0x8002c9 <prep+0x28>
    1e86:	2f a3       	std	Y+39, r18	; 0x27
    1e88:	30 91 ca 02 	lds	r19, 0x02CA	; 0x8002ca <prep+0x29>
    1e8c:	38 a7       	std	Y+40, r19	; 0x28
    1e8e:	40 91 cb 02 	lds	r20, 0x02CB	; 0x8002cb <prep+0x2a>
    1e92:	49 a7       	std	Y+41, r20	; 0x29
    1e94:	2a 8d       	ldd	r18, Y+26	; 0x1a
    1e96:	3b 8d       	ldd	r19, Y+27	; 0x1b
    1e98:	4c 8d       	ldd	r20, Y+28	; 0x1c
    1e9a:	5d 8d       	ldd	r21, Y+29	; 0x1d
    1e9c:	60 e0       	ldi	r22, 0x00	; 0
    1e9e:	70 e0       	ldi	r23, 0x00	; 0
    1ea0:	80 e8       	ldi	r24, 0x80	; 128
    1ea2:	9f e3       	ldi	r25, 0x3F	; 63
    1ea4:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    1ea8:	6b af       	std	Y+59, r22	; 0x3b
    1eaa:	7c af       	std	Y+60, r23	; 0x3c
    1eac:	8d af       	std	Y+61, r24	; 0x3d
    1eae:	9e af       	std	Y+62, r25	; 0x3e
    1eb0:	70 90 b8 02 	lds	r7, 0x02B8	; 0x8002b8 <prep+0x17>
    1eb4:	60 90 b9 02 	lds	r6, 0x02B9	; 0x8002b9 <prep+0x18>
    1eb8:	50 91 ba 02 	lds	r21, 0x02BA	; 0x8002ba <prep+0x19>
    1ebc:	21 96       	adiw	r28, 0x01	; 1
    1ebe:	5f af       	std	Y+63, r21	; 0x3f
    1ec0:	21 97       	sbiw	r28, 0x01	; 1
    1ec2:	80 91 bb 02 	lds	r24, 0x02BB	; 0x8002bb <prep+0x1a>
    1ec6:	8f af       	std	Y+63, r24	; 0x3f
    1ec8:	90 91 b4 02 	lds	r25, 0x02B4	; 0x8002b4 <prep+0x13>
    1ecc:	9a a7       	std	Y+42, r25	; 0x2a
    1ece:	a0 91 b5 02 	lds	r26, 0x02B5	; 0x8002b5 <prep+0x14>
    1ed2:	ab a7       	std	Y+43, r26	; 0x2b
    1ed4:	b0 91 b6 02 	lds	r27, 0x02B6	; 0x8002b6 <prep+0x15>
    1ed8:	bc a7       	std	Y+44, r27	; 0x2c
    1eda:	e0 91 b7 02 	lds	r30, 0x02B7	; 0x8002b7 <prep+0x16>
    1ede:	ed a7       	std	Y+45, r30	; 0x2d
    1ee0:	f0 91 c0 02 	lds	r31, 0x02C0	; 0x8002c0 <prep+0x1f>
    1ee4:	ff ab       	std	Y+55, r31	; 0x37
    1ee6:	20 91 c1 02 	lds	r18, 0x02C1	; 0x8002c1 <prep+0x20>
    1eea:	28 af       	std	Y+56, r18	; 0x38
    1eec:	30 91 c2 02 	lds	r19, 0x02C2	; 0x8002c2 <prep+0x21>
    1ef0:	39 af       	std	Y+57, r19	; 0x39
    1ef2:	40 91 c3 02 	lds	r20, 0x02C3	; 0x8002c3 <prep+0x22>
    1ef6:	4a af       	std	Y+58, r20	; 0x3a
    1ef8:	2e a1       	ldd	r18, Y+38	; 0x26
    1efa:	3f a1       	ldd	r19, Y+39	; 0x27
    1efc:	48 a5       	ldd	r20, Y+40	; 0x28
    1efe:	59 a5       	ldd	r21, Y+41	; 0x29
    1f00:	6a a1       	ldd	r22, Y+34	; 0x22
    1f02:	7b a1       	ldd	r23, Y+35	; 0x23
    1f04:	8c a1       	ldd	r24, Y+36	; 0x24
    1f06:	9d a1       	ldd	r25, Y+37	; 0x25
    1f08:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    1f0c:	81 11       	cpse	r24, r1
    1f0e:	b3 c3       	rjmp	.+1894   	; 0x2676 <st_prep_buffer+0xa2a>
    1f10:	52 e0       	ldi	r21, 0x02	; 2
    1f12:	5e ab       	std	Y+54, r21	; 0x36
    1f14:	8e e3       	ldi	r24, 0x3E	; 62
    1f16:	c8 2e       	mov	r12, r24
    1f18:	83 ec       	ldi	r24, 0xC3	; 195
    1f1a:	d8 2e       	mov	r13, r24
    1f1c:	8e e2       	ldi	r24, 0x2E	; 46
    1f1e:	e8 2e       	mov	r14, r24
    1f20:	89 e3       	ldi	r24, 0x39	; 57
    1f22:	f8 2e       	mov	r15, r24
    1f24:	21 2c       	mov	r2, r1
    1f26:	31 2c       	mov	r3, r1
    1f28:	21 01       	movw	r4, r2
    1f2a:	a7 01       	movw	r20, r14
    1f2c:	96 01       	movw	r18, r12
    1f2e:	2e 8f       	std	Y+30, r18	; 0x1e
    1f30:	3f 8f       	std	Y+31, r19	; 0x1f
    1f32:	48 a3       	std	Y+32, r20	; 0x20
    1f34:	59 a3       	std	Y+33, r21	; 0x21
    1f36:	59 8d       	ldd	r21, Y+25	; 0x19
    1f38:	51 30       	cpi	r21, 0x01	; 1
    1f3a:	09 f4       	brne	.+2      	; 0x1f3e <st_prep_buffer+0x2f2>
    1f3c:	39 c4       	rjmp	.+2162   	; 0x27b0 <st_prep_buffer+0xb64>
    1f3e:	a9 85       	ldd	r26, Y+9	; 0x09
    1f40:	ba 85       	ldd	r27, Y+10	; 0x0a
    1f42:	51 30       	cpi	r21, 0x01	; 1
    1f44:	08 f4       	brcc	.+2      	; 0x1f48 <st_prep_buffer+0x2fc>
    1f46:	c9 c3       	rjmp	.+1938   	; 0x26da <st_prep_buffer+0xa8e>
    1f48:	53 30       	cpi	r21, 0x03	; 3
    1f4a:	09 f0       	breq	.+2      	; 0x1f4e <st_prep_buffer+0x302>
    1f4c:	67 c4       	rjmp	.+2254   	; 0x281c <st_prep_buffer+0xbd0>
    1f4e:	5a 96       	adiw	r26, 0x1a	; 26
    1f50:	2d 91       	ld	r18, X+
    1f52:	3d 91       	ld	r19, X+
    1f54:	4d 91       	ld	r20, X+
    1f56:	5c 91       	ld	r21, X
    1f58:	5d 97       	sbiw	r26, 0x1d	; 29
    1f5a:	c7 01       	movw	r24, r14
    1f5c:	b6 01       	movw	r22, r12
    1f5e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    1f62:	4b 01       	movw	r8, r22
    1f64:	5c 01       	movw	r10, r24
    1f66:	2a 8d       	ldd	r18, Y+26	; 0x1a
    1f68:	3b 8d       	ldd	r19, Y+27	; 0x1b
    1f6a:	4c 8d       	ldd	r20, Y+28	; 0x1c
    1f6c:	5d 8d       	ldd	r21, Y+29	; 0x1d
    1f6e:	67 2d       	mov	r22, r7
    1f70:	76 2d       	mov	r23, r6
    1f72:	21 96       	adiw	r28, 0x01	; 1
    1f74:	8f ad       	ldd	r24, Y+63	; 0x3f
    1f76:	21 97       	sbiw	r28, 0x01	; 1
    1f78:	9f ad       	ldd	r25, Y+63	; 0x3f
    1f7a:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    1f7e:	9b 01       	movw	r18, r22
    1f80:	ac 01       	movw	r20, r24
    1f82:	c5 01       	movw	r24, r10
    1f84:	b4 01       	movw	r22, r8
    1f86:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    1f8a:	87 fd       	sbrc	r24, 7
    1f8c:	7e c3       	rjmp	.+1788   	; 0x268a <st_prep_buffer+0xa3e>
    1f8e:	27 2d       	mov	r18, r7
    1f90:	36 2d       	mov	r19, r6
    1f92:	21 96       	adiw	r28, 0x01	; 1
    1f94:	4f ad       	ldd	r20, Y+63	; 0x3f
    1f96:	21 97       	sbiw	r28, 0x01	; 1
    1f98:	5f ad       	ldd	r21, Y+63	; 0x3f
    1f9a:	6a 8d       	ldd	r22, Y+26	; 0x1a
    1f9c:	7b 8d       	ldd	r23, Y+27	; 0x1b
    1f9e:	8c 8d       	ldd	r24, Y+28	; 0x1c
    1fa0:	9d 8d       	ldd	r25, Y+29	; 0x1d
    1fa2:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    1fa6:	9b 01       	movw	r18, r22
    1fa8:	ac 01       	movw	r20, r24
    1faa:	6a a9       	ldd	r22, Y+50	; 0x32
    1fac:	7b a9       	ldd	r23, Y+51	; 0x33
    1fae:	8c a9       	ldd	r24, Y+52	; 0x34
    1fb0:	9d a9       	ldd	r25, Y+53	; 0x35
    1fb2:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    1fb6:	6b 01       	movw	r12, r22
    1fb8:	7c 01       	movw	r14, r24
    1fba:	7a 8c       	ldd	r7, Y+26	; 0x1a
    1fbc:	6b 8c       	ldd	r6, Y+27	; 0x1b
    1fbe:	bc 8d       	ldd	r27, Y+28	; 0x1c
    1fc0:	21 96       	adiw	r28, 0x01	; 1
    1fc2:	bf af       	std	Y+63, r27	; 0x3f
    1fc4:	21 97       	sbiw	r28, 0x01	; 1
    1fc6:	ed 8d       	ldd	r30, Y+29	; 0x1d
    1fc8:	ef af       	std	Y+63, r30	; 0x3f
    1fca:	0a a1       	ldd	r16, Y+34	; 0x22
    1fcc:	1b a1       	ldd	r17, Y+35	; 0x23
    1fce:	fc a1       	ldd	r31, Y+36	; 0x24
    1fd0:	f9 83       	std	Y+1, r31	; 0x01
    1fd2:	2d a1       	ldd	r18, Y+37	; 0x25
    1fd4:	2d 83       	std	Y+5, r18	; 0x05
    1fd6:	31 e0       	ldi	r19, 0x01	; 1
    1fd8:	39 8f       	std	Y+25, r19	; 0x19
    1fda:	a7 01       	movw	r20, r14
    1fdc:	96 01       	movw	r18, r12
    1fde:	c2 01       	movw	r24, r4
    1fe0:	b1 01       	movw	r22, r2
    1fe2:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    1fe6:	1b 01       	movw	r2, r22
    1fe8:	2c 01       	movw	r4, r24
    1fea:	2e 8d       	ldd	r18, Y+30	; 0x1e
    1fec:	3f 8d       	ldd	r19, Y+31	; 0x1f
    1fee:	48 a1       	ldd	r20, Y+32	; 0x20
    1ff0:	59 a1       	ldd	r21, Y+33	; 0x21
    1ff2:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    1ff6:	87 ff       	sbrs	r24, 7
    1ff8:	80 c4       	rjmp	.+2304   	; 0x28fa <st_prep_buffer+0xcae>
    1ffa:	a2 01       	movw	r20, r4
    1ffc:	91 01       	movw	r18, r2
    1ffe:	6e 8d       	ldd	r22, Y+30	; 0x1e
    2000:	7f 8d       	ldd	r23, Y+31	; 0x1f
    2002:	88 a1       	ldd	r24, Y+32	; 0x20
    2004:	99 a1       	ldd	r25, Y+33	; 0x21
    2006:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    200a:	6b 01       	movw	r12, r22
    200c:	7c 01       	movw	r14, r24
    200e:	98 01       	movw	r18, r16
    2010:	49 81       	ldd	r20, Y+1	; 0x01
    2012:	5d 81       	ldd	r21, Y+5	; 0x05
    2014:	6a a5       	ldd	r22, Y+42	; 0x2a
    2016:	7b a5       	ldd	r23, Y+43	; 0x2b
    2018:	8c a5       	ldd	r24, Y+44	; 0x2c
    201a:	9d a5       	ldd	r25, Y+45	; 0x2d
    201c:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    2020:	87 fd       	sbrc	r24, 7
    2022:	2c c3       	rjmp	.+1624   	; 0x267c <st_prep_buffer+0xa30>
    2024:	39 8d       	ldd	r19, Y+25	; 0x19
    2026:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    202a:	87 2d       	mov	r24, r7
    202c:	96 2d       	mov	r25, r6
    202e:	21 96       	adiw	r28, 0x01	; 1
    2030:	af ad       	ldd	r26, Y+63	; 0x3f
    2032:	21 97       	sbiw	r28, 0x01	; 1
    2034:	bf ad       	ldd	r27, Y+63	; 0x3f
    2036:	80 93 b8 02 	sts	0x02B8, r24	; 0x8002b8 <prep+0x17>
    203a:	90 93 b9 02 	sts	0x02B9, r25	; 0x8002b9 <prep+0x18>
    203e:	a0 93 ba 02 	sts	0x02BA, r26	; 0x8002ba <prep+0x19>
    2042:	b0 93 bb 02 	sts	0x02BB, r27	; 0x8002bb <prep+0x1a>
    2046:	e0 91 45 02 	lds	r30, 0x0245	; 0x800245 <st_prep_block>
    204a:	f0 91 46 02 	lds	r31, 0x0246	; 0x800246 <st_prep_block+0x1>
    204e:	21 89       	ldd	r18, Z+17	; 0x11
    2050:	21 11       	cpse	r18, r1
    2052:	04 c0       	rjmp	.+8      	; 0x205c <st_prep_buffer+0x410>
    2054:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    2058:	83 ff       	sbrs	r24, 3
    205a:	2d c0       	rjmp	.+90     	; 0x20b6 <st_prep_buffer+0x46a>
    205c:	a9 85       	ldd	r26, Y+9	; 0x09
    205e:	ba 85       	ldd	r27, Y+10	; 0x0a
    2060:	51 96       	adiw	r26, 0x11	; 17
    2062:	8c 91       	ld	r24, X
    2064:	51 97       	sbiw	r26, 0x11	; 17
    2066:	80 73       	andi	r24, 0x30	; 48
    2068:	09 f4       	brne	.+2      	; 0x206c <st_prep_buffer+0x420>
    206a:	67 c4       	rjmp	.+2254   	; 0x293a <st_prep_buffer+0xcee>
    206c:	9e 96       	adiw	r26, 0x2e	; 46
    206e:	6d 91       	ld	r22, X+
    2070:	7d 91       	ld	r23, X+
    2072:	8d 91       	ld	r24, X+
    2074:	9c 91       	ld	r25, X
    2076:	d1 97       	sbiw	r26, 0x31	; 49
    2078:	22 23       	and	r18, r18
    207a:	a1 f0       	breq	.+40     	; 0x20a4 <st_prep_buffer+0x458>
    207c:	20 91 cc 02 	lds	r18, 0x02CC	; 0x8002cc <prep+0x2b>
    2080:	30 91 cd 02 	lds	r19, 0x02CD	; 0x8002cd <prep+0x2c>
    2084:	40 91 ce 02 	lds	r20, 0x02CE	; 0x8002ce <prep+0x2d>
    2088:	50 91 cf 02 	lds	r21, 0x02CF	; 0x8002cf <prep+0x2e>
    208c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2090:	9b 01       	movw	r18, r22
    2092:	ac 01       	movw	r20, r24
    2094:	67 2d       	mov	r22, r7
    2096:	76 2d       	mov	r23, r6
    2098:	21 96       	adiw	r28, 0x01	; 1
    209a:	8f ad       	ldd	r24, Y+63	; 0x3f
    209c:	21 97       	sbiw	r28, 0x01	; 1
    209e:	9f ad       	ldd	r25, Y+63	; 0x3f
    20a0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    20a4:	0e 94 1f 0a 	call	0x143e	; 0x143e <spindle_compute_pwm_value>
    20a8:	80 93 d0 02 	sts	0x02D0, r24	; 0x8002d0 <prep+0x2f>
    20ac:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    20b0:	87 7f       	andi	r24, 0xF7	; 247
    20b2:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    20b6:	27 e0       	ldi	r18, 0x07	; 7
    20b8:	ef 89       	ldd	r30, Y+23	; 0x17
    20ba:	f8 8d       	ldd	r31, Y+24	; 0x18
    20bc:	2e 9f       	mul	r18, r30
    20be:	c0 01       	movw	r24, r0
    20c0:	2f 9f       	mul	r18, r31
    20c2:	90 0d       	add	r25, r0
    20c4:	11 24       	eor	r1, r1
    20c6:	ac 01       	movw	r20, r24
    20c8:	46 5e       	subi	r20, 0xE6	; 230
    20ca:	5d 4f       	sbci	r21, 0xFD	; 253
    20cc:	3a 01       	movw	r6, r20
    20ce:	80 91 d0 02 	lds	r24, 0x02D0	; 0x8002d0 <prep+0x2f>
    20d2:	da 01       	movw	r26, r20
    20d4:	16 96       	adiw	r26, 0x06	; 6
    20d6:	8c 93       	st	X, r24
    20d8:	20 91 ab 02 	lds	r18, 0x02AB	; 0x8002ab <prep+0xa>
    20dc:	30 91 ac 02 	lds	r19, 0x02AC	; 0x8002ac <prep+0xb>
    20e0:	40 91 ad 02 	lds	r20, 0x02AD	; 0x8002ad <prep+0xc>
    20e4:	50 91 ae 02 	lds	r21, 0x02AE	; 0x8002ae <prep+0xd>
    20e8:	b8 01       	movw	r22, r16
    20ea:	89 81       	ldd	r24, Y+1	; 0x01
    20ec:	9d 81       	ldd	r25, Y+5	; 0x05
    20ee:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    20f2:	69 87       	std	Y+9, r22	; 0x09
    20f4:	7a 87       	std	Y+10, r23	; 0x0a
    20f6:	8b 87       	std	Y+11, r24	; 0x0b
    20f8:	9c 87       	std	Y+12, r25	; 0x0c
    20fa:	0e 94 ef 35 	call	0x6bde	; 0x6bde <ceil>
    20fe:	6b 01       	movw	r12, r22
    2100:	7c 01       	movw	r14, r24
    2102:	60 91 a7 02 	lds	r22, 0x02A7	; 0x8002a7 <prep+0x6>
    2106:	70 91 a8 02 	lds	r23, 0x02A8	; 0x8002a8 <prep+0x7>
    210a:	80 91 a9 02 	lds	r24, 0x02A9	; 0x8002a9 <prep+0x8>
    210e:	90 91 aa 02 	lds	r25, 0x02AA	; 0x8002aa <prep+0x9>
    2112:	0e 94 ef 35 	call	0x6bde	; 0x6bde <ceil>
    2116:	4b 01       	movw	r8, r22
    2118:	5c 01       	movw	r10, r24
    211a:	a7 01       	movw	r20, r14
    211c:	96 01       	movw	r18, r12
    211e:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2122:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    2126:	6d 87       	std	Y+13, r22	; 0x0d
    2128:	7e 87       	std	Y+14, r23	; 0x0e
    212a:	8f 87       	std	Y+15, r24	; 0x0f
    212c:	98 8b       	std	Y+16, r25	; 0x10
    212e:	2d 85       	ldd	r18, Y+13	; 0x0d
    2130:	3e 85       	ldd	r19, Y+14	; 0x0e
    2132:	f3 01       	movw	r30, r6
    2134:	31 83       	std	Z+1, r19	; 0x01
    2136:	20 83       	st	Z, r18
    2138:	23 2b       	or	r18, r19
    213a:	09 f0       	breq	.+2      	; 0x213e <st_prep_buffer+0x4f2>
    213c:	09 c4       	rjmp	.+2066   	; 0x2950 <st_prep_buffer+0xd04>
    213e:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    2142:	81 ff       	sbrs	r24, 1
    2144:	05 c4       	rjmp	.+2058   	; 0x2950 <st_prep_buffer+0xd04>
    2146:	81 60       	ori	r24, 0x01	; 1
    2148:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    214c:	c0 5c       	subi	r28, 0xC0	; 192
    214e:	df 4f       	sbci	r29, 0xFF	; 255
    2150:	0f b6       	in	r0, 0x3f	; 63
    2152:	f8 94       	cli
    2154:	de bf       	out	0x3e, r29	; 62
    2156:	0f be       	out	0x3f, r0	; 63
    2158:	cd bf       	out	0x3d, r28	; 61
    215a:	df 91       	pop	r29
    215c:	cf 91       	pop	r28
    215e:	1f 91       	pop	r17
    2160:	0f 91       	pop	r16
    2162:	ff 90       	pop	r15
    2164:	ef 90       	pop	r14
    2166:	df 90       	pop	r13
    2168:	cf 90       	pop	r12
    216a:	bf 90       	pop	r11
    216c:	af 90       	pop	r10
    216e:	9f 90       	pop	r9
    2170:	8f 90       	pop	r8
    2172:	7f 90       	pop	r7
    2174:	6f 90       	pop	r6
    2176:	5f 90       	pop	r5
    2178:	4f 90       	pop	r4
    217a:	3f 90       	pop	r3
    217c:	2f 90       	pop	r2
    217e:	08 95       	ret
    2180:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
    2184:	9c cd       	rjmp	.-1224   	; 0x1cbe <st_prep_buffer+0x72>
    2186:	80 91 a1 02 	lds	r24, 0x02A1	; 0x8002a1 <prep>
    218a:	8f 5f       	subi	r24, 0xFF	; 255
    218c:	85 30       	cpi	r24, 0x05	; 5
    218e:	09 f4       	brne	.+2      	; 0x2192 <st_prep_buffer+0x546>
    2190:	80 e0       	ldi	r24, 0x00	; 0
    2192:	80 93 a1 02 	sts	0x02A1, r24	; 0x8002a1 <prep>
    2196:	28 2f       	mov	r18, r24
    2198:	30 e0       	ldi	r19, 0x00	; 0
    219a:	52 e1       	ldi	r21, 0x12	; 18
    219c:	85 9f       	mul	r24, r21
    219e:	c0 01       	movw	r24, r0
    21a0:	11 24       	eor	r1, r1
    21a2:	dc 01       	movw	r26, r24
    21a4:	a9 5b       	subi	r26, 0xB9	; 185
    21a6:	bd 4f       	sbci	r27, 0xFD	; 253
    21a8:	7d 01       	movw	r14, r26
    21aa:	b0 93 46 02 	sts	0x0246, r27	; 0x800246 <st_prep_block+0x1>
    21ae:	a0 93 45 02 	sts	0x0245, r26	; 0x800245 <st_prep_block>
    21b2:	ed 81       	ldd	r30, Y+5	; 0x05
    21b4:	fe 81       	ldd	r31, Y+6	; 0x06
    21b6:	80 89       	ldd	r24, Z+16	; 0x10
    21b8:	50 96       	adiw	r26, 0x10	; 16
    21ba:	8c 93       	st	X, r24
    21bc:	90 e0       	ldi	r25, 0x00	; 0
    21be:	80 e0       	ldi	r24, 0x00	; 0
    21c0:	41 91       	ld	r20, Z+
    21c2:	51 91       	ld	r21, Z+
    21c4:	61 91       	ld	r22, Z+
    21c6:	71 91       	ld	r23, Z+
    21c8:	d7 01       	movw	r26, r14
    21ca:	a8 0f       	add	r26, r24
    21cc:	b9 1f       	adc	r27, r25
    21ce:	68 94       	set
    21d0:	12 f8       	bld	r1, 2
    21d2:	44 0f       	add	r20, r20
    21d4:	55 1f       	adc	r21, r21
    21d6:	66 1f       	adc	r22, r22
    21d8:	77 1f       	adc	r23, r23
    21da:	16 94       	lsr	r1
    21dc:	d1 f7       	brne	.-12     	; 0x21d2 <st_prep_buffer+0x586>
    21de:	4d 93       	st	X+, r20
    21e0:	5d 93       	st	X+, r21
    21e2:	6d 93       	st	X+, r22
    21e4:	7c 93       	st	X, r23
    21e6:	13 97       	sbiw	r26, 0x03	; 3
    21e8:	04 96       	adiw	r24, 0x04	; 4
    21ea:	8c 30       	cpi	r24, 0x0C	; 12
    21ec:	91 05       	cpc	r25, r1
    21ee:	41 f7       	brne	.-48     	; 0x21c0 <st_prep_buffer+0x574>
    21f0:	ad 81       	ldd	r26, Y+5	; 0x05
    21f2:	be 81       	ldd	r27, Y+6	; 0x06
    21f4:	1c 96       	adiw	r26, 0x0c	; 12
    21f6:	6d 91       	ld	r22, X+
    21f8:	7d 91       	ld	r23, X+
    21fa:	8d 91       	ld	r24, X+
    21fc:	9c 91       	ld	r25, X
    21fe:	1f 97       	sbiw	r26, 0x0f	; 15
    2200:	b2 e1       	ldi	r27, 0x12	; 18
    2202:	b2 9f       	mul	r27, r18
    2204:	a0 01       	movw	r20, r0
    2206:	b3 9f       	mul	r27, r19
    2208:	50 0d       	add	r21, r0
    220a:	11 24       	eor	r1, r1
    220c:	fa 01       	movw	r30, r20
    220e:	e9 5b       	subi	r30, 0xB9	; 185
    2210:	fd 4f       	sbci	r31, 0xFD	; 253
    2212:	4b 01       	movw	r8, r22
    2214:	5c 01       	movw	r10, r24
    2216:	23 e0       	ldi	r18, 0x03	; 3
    2218:	88 0c       	add	r8, r8
    221a:	99 1c       	adc	r9, r9
    221c:	aa 1c       	adc	r10, r10
    221e:	bb 1c       	adc	r11, r11
    2220:	2a 95       	dec	r18
    2222:	d1 f7       	brne	.-12     	; 0x2218 <st_prep_buffer+0x5cc>
    2224:	84 86       	std	Z+12, r8	; 0x0c
    2226:	95 86       	std	Z+13, r9	; 0x0d
    2228:	a6 86       	std	Z+14, r10	; 0x0e
    222a:	b7 86       	std	Z+15, r11	; 0x0f
    222c:	0e 94 b8 36 	call	0x6d70	; 0x6d70 <__floatunsisf>
    2230:	60 93 a7 02 	sts	0x02A7, r22	; 0x8002a7 <prep+0x6>
    2234:	70 93 a8 02 	sts	0x02A8, r23	; 0x8002a8 <prep+0x7>
    2238:	80 93 a9 02 	sts	0x02A9, r24	; 0x8002a9 <prep+0x8>
    223c:	90 93 aa 02 	sts	0x02AA, r25	; 0x8002aa <prep+0x9>
    2240:	ed 81       	ldd	r30, Y+5	; 0x05
    2242:	fe 81       	ldd	r31, Y+6	; 0x06
    2244:	26 8d       	ldd	r18, Z+30	; 0x1e
    2246:	37 8d       	ldd	r19, Z+31	; 0x1f
    2248:	40 a1       	ldd	r20, Z+32	; 0x20
    224a:	51 a1       	ldd	r21, Z+33	; 0x21
    224c:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    2250:	9b 01       	movw	r18, r22
    2252:	ac 01       	movw	r20, r24
    2254:	20 93 ab 02 	sts	0x02AB, r18	; 0x8002ab <prep+0xa>
    2258:	30 93 ac 02 	sts	0x02AC, r19	; 0x8002ac <prep+0xb>
    225c:	40 93 ad 02 	sts	0x02AD, r20	; 0x8002ad <prep+0xc>
    2260:	50 93 ae 02 	sts	0x02AE, r21	; 0x8002ae <prep+0xd>
    2264:	60 e0       	ldi	r22, 0x00	; 0
    2266:	70 e0       	ldi	r23, 0x00	; 0
    2268:	80 ea       	ldi	r24, 0xA0	; 160
    226a:	9f e3       	ldi	r25, 0x3F	; 63
    226c:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    2270:	60 93 af 02 	sts	0x02AF, r22	; 0x8002af <prep+0xe>
    2274:	70 93 b0 02 	sts	0x02B0, r23	; 0x8002b0 <prep+0xf>
    2278:	80 93 b1 02 	sts	0x02B1, r24	; 0x8002b1 <prep+0x10>
    227c:	90 93 b2 02 	sts	0x02B2, r25	; 0x8002b2 <prep+0x11>
    2280:	10 92 a3 02 	sts	0x02A3, r1	; 0x8002a3 <prep+0x2>
    2284:	10 92 a4 02 	sts	0x02A4, r1	; 0x8002a4 <prep+0x3>
    2288:	10 92 a5 02 	sts	0x02A5, r1	; 0x8002a5 <prep+0x4>
    228c:	10 92 a6 02 	sts	0x02A6, r1	; 0x8002a6 <prep+0x5>
    2290:	11 fd       	sbrc	r17, 1
    2292:	02 c0       	rjmp	.+4      	; 0x2298 <st_prep_buffer+0x64c>
    2294:	03 ff       	sbrs	r16, 3
    2296:	42 c0       	rjmp	.+132    	; 0x231c <st_prep_buffer+0x6d0>
    2298:	60 91 c0 02 	lds	r22, 0x02C0	; 0x8002c0 <prep+0x1f>
    229c:	70 91 c1 02 	lds	r23, 0x02C1	; 0x8002c1 <prep+0x20>
    22a0:	80 91 c2 02 	lds	r24, 0x02C2	; 0x8002c2 <prep+0x21>
    22a4:	90 91 c3 02 	lds	r25, 0x02C3	; 0x8002c3 <prep+0x22>
    22a8:	60 93 b8 02 	sts	0x02B8, r22	; 0x8002b8 <prep+0x17>
    22ac:	70 93 b9 02 	sts	0x02B9, r23	; 0x8002b9 <prep+0x18>
    22b0:	80 93 ba 02 	sts	0x02BA, r24	; 0x8002ba <prep+0x19>
    22b4:	90 93 bb 02 	sts	0x02BB, r25	; 0x8002bb <prep+0x1a>
    22b8:	9b 01       	movw	r18, r22
    22ba:	ac 01       	movw	r20, r24
    22bc:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    22c0:	ad 81       	ldd	r26, Y+5	; 0x05
    22c2:	be 81       	ldd	r27, Y+6	; 0x06
    22c4:	52 96       	adiw	r26, 0x12	; 18
    22c6:	6d 93       	st	X+, r22
    22c8:	7d 93       	st	X+, r23
    22ca:	8d 93       	st	X+, r24
    22cc:	9c 93       	st	X, r25
    22ce:	55 97       	sbiw	r26, 0x15	; 21
    22d0:	07 7f       	andi	r16, 0xF7	; 247
    22d2:	00 93 a2 02 	sts	0x02A2, r16	; 0x8002a2 <prep+0x1>
    22d6:	d7 01       	movw	r26, r14
    22d8:	51 96       	adiw	r26, 0x11	; 17
    22da:	1c 92       	st	X, r1
    22dc:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    22e0:	81 ff       	sbrs	r24, 1
    22e2:	00 cd       	rjmp	.-1536   	; 0x1ce4 <st_prep_buffer+0x98>
    22e4:	ed 81       	ldd	r30, Y+5	; 0x05
    22e6:	fe 81       	ldd	r31, Y+6	; 0x06
    22e8:	81 89       	ldd	r24, Z+17	; 0x11
    22ea:	85 ff       	sbrs	r24, 5
    22ec:	fb cc       	rjmp	.-1546   	; 0x1ce4 <st_prep_buffer+0x98>
    22ee:	22 a5       	ldd	r18, Z+42	; 0x2a
    22f0:	33 a5       	ldd	r19, Z+43	; 0x2b
    22f2:	44 a5       	ldd	r20, Z+44	; 0x2c
    22f4:	55 a5       	ldd	r21, Z+45	; 0x2d
    22f6:	60 e0       	ldi	r22, 0x00	; 0
    22f8:	70 e0       	ldi	r23, 0x00	; 0
    22fa:	80 e8       	ldi	r24, 0x80	; 128
    22fc:	9f e3       	ldi	r25, 0x3F	; 63
    22fe:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    2302:	60 93 cc 02 	sts	0x02CC, r22	; 0x8002cc <prep+0x2b>
    2306:	70 93 cd 02 	sts	0x02CD, r23	; 0x8002cd <prep+0x2c>
    230a:	80 93 ce 02 	sts	0x02CE, r24	; 0x8002ce <prep+0x2d>
    230e:	90 93 cf 02 	sts	0x02CF, r25	; 0x8002cf <prep+0x2e>
    2312:	e1 e0       	ldi	r30, 0x01	; 1
    2314:	d7 01       	movw	r26, r14
    2316:	51 96       	adiw	r26, 0x11	; 17
    2318:	ec 93       	st	X, r30
    231a:	e4 cc       	rjmp	.-1592   	; 0x1ce4 <st_prep_buffer+0x98>
    231c:	ed 81       	ldd	r30, Y+5	; 0x05
    231e:	fe 81       	ldd	r31, Y+6	; 0x06
    2320:	62 89       	ldd	r22, Z+18	; 0x12
    2322:	73 89       	ldd	r23, Z+19	; 0x13
    2324:	84 89       	ldd	r24, Z+20	; 0x14
    2326:	95 89       	ldd	r25, Z+21	; 0x15
    2328:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    232c:	60 93 b8 02 	sts	0x02B8, r22	; 0x8002b8 <prep+0x17>
    2330:	70 93 b9 02 	sts	0x02B9, r23	; 0x8002b9 <prep+0x18>
    2334:	80 93 ba 02 	sts	0x02BA, r24	; 0x8002ba <prep+0x19>
    2338:	90 93 bb 02 	sts	0x02BB, r25	; 0x8002bb <prep+0x1a>
    233c:	cc cf       	rjmp	.-104    	; 0x22d6 <st_prep_buffer+0x68a>
    233e:	80 92 b4 02 	sts	0x02B4, r8	; 0x8002b4 <prep+0x13>
    2342:	90 92 b5 02 	sts	0x02B5, r9	; 0x8002b5 <prep+0x14>
    2346:	a0 92 b6 02 	sts	0x02B6, r10	; 0x8002b6 <prep+0x15>
    234a:	b0 92 b7 02 	sts	0x02B7, r11	; 0x8002b7 <prep+0x16>
    234e:	10 92 c0 02 	sts	0x02C0, r1	; 0x8002c0 <prep+0x1f>
    2352:	10 92 c1 02 	sts	0x02C1, r1	; 0x8002c1 <prep+0x20>
    2356:	10 92 c2 02 	sts	0x02C2, r1	; 0x8002c2 <prep+0x21>
    235a:	10 92 c3 02 	sts	0x02C3, r1	; 0x8002c3 <prep+0x22>
    235e:	1e cd       	rjmp	.-1476   	; 0x1d9c <st_prep_buffer+0x150>
    2360:	10 92 b3 02 	sts	0x02B3, r1	; 0x8002b3 <prep+0x12>
    2364:	c0 92 c4 02 	sts	0x02C4, r12	; 0x8002c4 <prep+0x23>
    2368:	d0 92 c5 02 	sts	0x02C5, r13	; 0x8002c5 <prep+0x24>
    236c:	e0 92 c6 02 	sts	0x02C6, r14	; 0x8002c6 <prep+0x25>
    2370:	f0 92 c7 02 	sts	0x02C7, r15	; 0x8002c7 <prep+0x26>
    2374:	12 ff       	sbrs	r17, 2
    2376:	68 c0       	rjmp	.+208    	; 0x2448 <st_prep_buffer+0x7fc>
    2378:	10 92 c0 02 	sts	0x02C0, r1	; 0x8002c0 <prep+0x1f>
    237c:	10 92 c1 02 	sts	0x02C1, r1	; 0x8002c1 <prep+0x20>
    2380:	10 92 c2 02 	sts	0x02C2, r1	; 0x8002c2 <prep+0x21>
    2384:	10 92 c3 02 	sts	0x02C3, r1	; 0x8002c3 <prep+0x22>
    2388:	81 2c       	mov	r8, r1
    238a:	91 2c       	mov	r9, r1
    238c:	54 01       	movw	r10, r8
    238e:	8d 81       	ldd	r24, Y+5	; 0x05
    2390:	9e 81       	ldd	r25, Y+6	; 0x06
    2392:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    2396:	69 8b       	std	Y+17, r22	; 0x11
    2398:	7a 8b       	std	Y+18, r23	; 0x12
    239a:	8b 8b       	std	Y+19, r24	; 0x13
    239c:	9c 8b       	std	Y+20, r25	; 0x14
    239e:	9b 01       	movw	r18, r22
    23a0:	ac 01       	movw	r20, r24
    23a2:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    23a6:	6d 83       	std	Y+5, r22	; 0x05
    23a8:	7e 83       	std	Y+6, r23	; 0x06
    23aa:	8f 83       	std	Y+7, r24	; 0x07
    23ac:	98 87       	std	Y+8, r25	; 0x08
    23ae:	a3 01       	movw	r20, r6
    23b0:	92 01       	movw	r18, r4
    23b2:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    23b6:	87 ff       	sbrs	r24, 7
    23b8:	91 c0       	rjmp	.+290    	; 0x24dc <st_prep_buffer+0x890>
    23ba:	a3 01       	movw	r20, r6
    23bc:	92 01       	movw	r18, r4
    23be:	6d 81       	ldd	r22, Y+5	; 0x05
    23c0:	7e 81       	ldd	r23, Y+6	; 0x06
    23c2:	8f 81       	ldd	r24, Y+7	; 0x07
    23c4:	98 85       	ldd	r25, Y+8	; 0x08
    23c6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    23ca:	29 81       	ldd	r18, Y+1	; 0x01
    23cc:	3a 81       	ldd	r19, Y+2	; 0x02
    23ce:	4b 81       	ldd	r20, Y+3	; 0x03
    23d0:	5c 81       	ldd	r21, Y+4	; 0x04
    23d2:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    23d6:	a7 01       	movw	r20, r14
    23d8:	96 01       	movw	r18, r12
    23da:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    23de:	60 93 c4 02 	sts	0x02C4, r22	; 0x8002c4 <prep+0x23>
    23e2:	70 93 c5 02 	sts	0x02C5, r23	; 0x8002c5 <prep+0x24>
    23e6:	80 93 c6 02 	sts	0x02C6, r24	; 0x8002c6 <prep+0x25>
    23ea:	90 93 c7 02 	sts	0x02C7, r25	; 0x8002c7 <prep+0x26>
    23ee:	20 e0       	ldi	r18, 0x00	; 0
    23f0:	30 e0       	ldi	r19, 0x00	; 0
    23f2:	a9 01       	movw	r20, r18
    23f4:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    23f8:	18 16       	cp	r1, r24
    23fa:	0c f4       	brge	.+2      	; 0x23fe <st_prep_buffer+0x7b2>
    23fc:	49 c0       	rjmp	.+146    	; 0x2490 <st_prep_buffer+0x844>
    23fe:	32 e0       	ldi	r19, 0x02	; 2
    2400:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    2404:	a7 01       	movw	r20, r14
    2406:	96 01       	movw	r18, r12
    2408:	6d 85       	ldd	r22, Y+13	; 0x0d
    240a:	7e 85       	ldd	r23, Y+14	; 0x0e
    240c:	8f 85       	ldd	r24, Y+15	; 0x0f
    240e:	98 89       	ldd	r25, Y+16	; 0x10
    2410:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2414:	9b 01       	movw	r18, r22
    2416:	ac 01       	movw	r20, r24
    2418:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    241c:	9b 01       	movw	r18, r22
    241e:	ac 01       	movw	r20, r24
    2420:	c3 01       	movw	r24, r6
    2422:	b2 01       	movw	r22, r4
    2424:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2428:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    242c:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    2430:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    2434:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    2438:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    243c:	80 91 a2 02 	lds	r24, 0x02A2	; 0x8002a2 <prep+0x1>
    2440:	88 60       	ori	r24, 0x08	; 8
    2442:	80 93 a2 02 	sts	0x02A2, r24	; 0x8002a2 <prep+0x1>
    2446:	aa cc       	rjmp	.-1708   	; 0x1d9c <st_prep_buffer+0x150>
    2448:	e0 91 d5 02 	lds	r30, 0x02D5	; 0x8002d5 <block_buffer_tail>
    244c:	ef 5f       	subi	r30, 0xFF	; 255
    244e:	e0 31       	cpi	r30, 0x10	; 16
    2450:	09 f4       	brne	.+2      	; 0x2454 <st_prep_buffer+0x808>
    2452:	e0 e0       	ldi	r30, 0x00	; 0
    2454:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    2458:	81 2c       	mov	r8, r1
    245a:	91 2c       	mov	r9, r1
    245c:	54 01       	movw	r10, r8
    245e:	8e 17       	cp	r24, r30
    2460:	51 f0       	breq	.+20     	; 0x2476 <st_prep_buffer+0x82a>
    2462:	22 e3       	ldi	r18, 0x32	; 50
    2464:	2e 9f       	mul	r18, r30
    2466:	f0 01       	movw	r30, r0
    2468:	11 24       	eor	r1, r1
    246a:	ea 52       	subi	r30, 0x2A	; 42
    246c:	fd 4f       	sbci	r31, 0xFD	; 253
    246e:	82 88       	ldd	r8, Z+18	; 0x12
    2470:	93 88       	ldd	r9, Z+19	; 0x13
    2472:	a4 88       	ldd	r10, Z+20	; 0x14
    2474:	b5 88       	ldd	r11, Z+21	; 0x15
    2476:	c5 01       	movw	r24, r10
    2478:	b4 01       	movw	r22, r8
    247a:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    247e:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    2482:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    2486:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    248a:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    248e:	7f cf       	rjmp	.-258    	; 0x238e <st_prep_buffer+0x742>
    2490:	a5 01       	movw	r20, r10
    2492:	94 01       	movw	r18, r8
    2494:	6d 81       	ldd	r22, Y+5	; 0x05
    2496:	7e 81       	ldd	r23, Y+6	; 0x06
    2498:	8f 81       	ldd	r24, Y+7	; 0x07
    249a:	98 85       	ldd	r25, Y+8	; 0x08
    249c:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    24a0:	29 81       	ldd	r18, Y+1	; 0x01
    24a2:	3a 81       	ldd	r19, Y+2	; 0x02
    24a4:	4b 81       	ldd	r20, Y+3	; 0x03
    24a6:	5c 81       	ldd	r21, Y+4	; 0x04
    24a8:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    24ac:	60 93 c8 02 	sts	0x02C8, r22	; 0x8002c8 <prep+0x27>
    24b0:	70 93 c9 02 	sts	0x02C9, r23	; 0x8002c9 <prep+0x28>
    24b4:	80 93 ca 02 	sts	0x02CA, r24	; 0x8002ca <prep+0x29>
    24b8:	90 93 cb 02 	sts	0x02CB, r25	; 0x8002cb <prep+0x2a>
    24bc:	89 89       	ldd	r24, Y+17	; 0x11
    24be:	9a 89       	ldd	r25, Y+18	; 0x12
    24c0:	ab 89       	ldd	r26, Y+19	; 0x13
    24c2:	bc 89       	ldd	r27, Y+20	; 0x14
    24c4:	80 93 bc 02 	sts	0x02BC, r24	; 0x8002bc <prep+0x1b>
    24c8:	90 93 bd 02 	sts	0x02BD, r25	; 0x8002bd <prep+0x1c>
    24cc:	a0 93 be 02 	sts	0x02BE, r26	; 0x8002be <prep+0x1d>
    24d0:	b0 93 bf 02 	sts	0x02BF, r27	; 0x8002bf <prep+0x1e>
    24d4:	93 e0       	ldi	r25, 0x03	; 3
    24d6:	90 93 b3 02 	sts	0x02B3, r25	; 0x8002b3 <prep+0x12>
    24da:	60 cc       	rjmp	.-1856   	; 0x1d9c <st_prep_buffer+0x150>
    24dc:	a5 01       	movw	r20, r10
    24de:	94 01       	movw	r18, r8
    24e0:	c3 01       	movw	r24, r6
    24e2:	b2 01       	movw	r22, r4
    24e4:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    24e8:	29 81       	ldd	r18, Y+1	; 0x01
    24ea:	3a 81       	ldd	r19, Y+2	; 0x02
    24ec:	4b 81       	ldd	r20, Y+3	; 0x03
    24ee:	5c 81       	ldd	r21, Y+4	; 0x04
    24f0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    24f4:	a7 01       	movw	r20, r14
    24f6:	96 01       	movw	r18, r12
    24f8:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    24fc:	20 e0       	ldi	r18, 0x00	; 0
    24fe:	30 e0       	ldi	r19, 0x00	; 0
    2500:	40 e0       	ldi	r20, 0x00	; 0
    2502:	5f e3       	ldi	r21, 0x3F	; 63
    2504:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2508:	69 87       	std	Y+9, r22	; 0x09
    250a:	7a 87       	std	Y+10, r23	; 0x0a
    250c:	8b 87       	std	Y+11, r24	; 0x0b
    250e:	9c 87       	std	Y+12, r25	; 0x0c
    2510:	20 e0       	ldi	r18, 0x00	; 0
    2512:	30 e0       	ldi	r19, 0x00	; 0
    2514:	a9 01       	movw	r20, r18
    2516:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    251a:	18 16       	cp	r1, r24
    251c:	0c f0       	brlt	.+2      	; 0x2520 <st_prep_buffer+0x8d4>
    251e:	92 c0       	rjmp	.+292    	; 0x2644 <st_prep_buffer+0x9f8>
    2520:	a7 01       	movw	r20, r14
    2522:	96 01       	movw	r18, r12
    2524:	69 85       	ldd	r22, Y+9	; 0x09
    2526:	7a 85       	ldd	r23, Y+10	; 0x0a
    2528:	8b 85       	ldd	r24, Y+11	; 0x0b
    252a:	9c 85       	ldd	r25, Y+12	; 0x0c
    252c:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    2530:	87 ff       	sbrs	r24, 7
    2532:	86 c0       	rjmp	.+268    	; 0x2640 <st_prep_buffer+0x9f4>
    2534:	a5 01       	movw	r20, r10
    2536:	94 01       	movw	r18, r8
    2538:	6d 81       	ldd	r22, Y+5	; 0x05
    253a:	7e 81       	ldd	r23, Y+6	; 0x06
    253c:	8f 81       	ldd	r24, Y+7	; 0x07
    253e:	98 85       	ldd	r25, Y+8	; 0x08
    2540:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2544:	29 81       	ldd	r18, Y+1	; 0x01
    2546:	3a 81       	ldd	r19, Y+2	; 0x02
    2548:	4b 81       	ldd	r20, Y+3	; 0x03
    254a:	5c 81       	ldd	r21, Y+4	; 0x04
    254c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2550:	9b 01       	movw	r18, r22
    2552:	ac 01       	movw	r20, r24
    2554:	20 93 c8 02 	sts	0x02C8, r18	; 0x8002c8 <prep+0x27>
    2558:	30 93 c9 02 	sts	0x02C9, r19	; 0x8002c9 <prep+0x28>
    255c:	40 93 ca 02 	sts	0x02CA, r20	; 0x8002ca <prep+0x29>
    2560:	50 93 cb 02 	sts	0x02CB, r21	; 0x8002cb <prep+0x2a>
    2564:	69 85       	ldd	r22, Y+9	; 0x09
    2566:	7a 85       	ldd	r23, Y+10	; 0x0a
    2568:	8b 85       	ldd	r24, Y+11	; 0x0b
    256a:	9c 85       	ldd	r25, Y+12	; 0x0c
    256c:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    2570:	18 16       	cp	r1, r24
    2572:	ac f5       	brge	.+106    	; 0x25de <st_prep_buffer+0x992>
    2574:	29 89       	ldd	r18, Y+17	; 0x11
    2576:	3a 89       	ldd	r19, Y+18	; 0x12
    2578:	4b 89       	ldd	r20, Y+19	; 0x13
    257a:	5c 89       	ldd	r21, Y+20	; 0x14
    257c:	20 93 bc 02 	sts	0x02BC, r18	; 0x8002bc <prep+0x1b>
    2580:	30 93 bd 02 	sts	0x02BD, r19	; 0x8002bd <prep+0x1c>
    2584:	40 93 be 02 	sts	0x02BE, r20	; 0x8002be <prep+0x1d>
    2588:	50 93 bf 02 	sts	0x02BF, r21	; 0x8002bf <prep+0x1e>
    258c:	a3 01       	movw	r20, r6
    258e:	92 01       	movw	r18, r4
    2590:	6d 81       	ldd	r22, Y+5	; 0x05
    2592:	7e 81       	ldd	r23, Y+6	; 0x06
    2594:	8f 81       	ldd	r24, Y+7	; 0x07
    2596:	98 85       	ldd	r25, Y+8	; 0x08
    2598:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    259c:	81 11       	cpse	r24, r1
    259e:	04 c0       	rjmp	.+8      	; 0x25a8 <st_prep_buffer+0x95c>
    25a0:	31 e0       	ldi	r19, 0x01	; 1
    25a2:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    25a6:	fa cb       	rjmp	.-2060   	; 0x1d9c <st_prep_buffer+0x150>
    25a8:	2d 81       	ldd	r18, Y+5	; 0x05
    25aa:	3e 81       	ldd	r19, Y+6	; 0x06
    25ac:	4f 81       	ldd	r20, Y+7	; 0x07
    25ae:	58 85       	ldd	r21, Y+8	; 0x08
    25b0:	c3 01       	movw	r24, r6
    25b2:	b2 01       	movw	r22, r4
    25b4:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    25b8:	29 81       	ldd	r18, Y+1	; 0x01
    25ba:	3a 81       	ldd	r19, Y+2	; 0x02
    25bc:	4b 81       	ldd	r20, Y+3	; 0x03
    25be:	5c 81       	ldd	r21, Y+4	; 0x04
    25c0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    25c4:	a7 01       	movw	r20, r14
    25c6:	96 01       	movw	r18, r12
    25c8:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    25cc:	60 93 c4 02 	sts	0x02C4, r22	; 0x8002c4 <prep+0x23>
    25d0:	70 93 c5 02 	sts	0x02C5, r23	; 0x8002c5 <prep+0x24>
    25d4:	80 93 c6 02 	sts	0x02C6, r24	; 0x8002c6 <prep+0x25>
    25d8:	90 93 c7 02 	sts	0x02C7, r25	; 0x8002c7 <prep+0x26>
    25dc:	df cb       	rjmp	.-2114   	; 0x1d9c <st_prep_buffer+0x150>
    25de:	89 85       	ldd	r24, Y+9	; 0x09
    25e0:	9a 85       	ldd	r25, Y+10	; 0x0a
    25e2:	ab 85       	ldd	r26, Y+11	; 0x0b
    25e4:	bc 85       	ldd	r27, Y+12	; 0x0c
    25e6:	80 93 c4 02 	sts	0x02C4, r24	; 0x8002c4 <prep+0x23>
    25ea:	90 93 c5 02 	sts	0x02C5, r25	; 0x8002c5 <prep+0x24>
    25ee:	a0 93 c6 02 	sts	0x02C6, r26	; 0x8002c6 <prep+0x25>
    25f2:	b0 93 c7 02 	sts	0x02C7, r27	; 0x8002c7 <prep+0x26>
    25f6:	80 93 c8 02 	sts	0x02C8, r24	; 0x8002c8 <prep+0x27>
    25fa:	90 93 c9 02 	sts	0x02C9, r25	; 0x8002c9 <prep+0x28>
    25fe:	a0 93 ca 02 	sts	0x02CA, r26	; 0x8002ca <prep+0x29>
    2602:	b0 93 cb 02 	sts	0x02CB, r27	; 0x8002cb <prep+0x2a>
    2606:	2d 85       	ldd	r18, Y+13	; 0x0d
    2608:	3e 85       	ldd	r19, Y+14	; 0x0e
    260a:	4f 85       	ldd	r20, Y+15	; 0x0f
    260c:	58 89       	ldd	r21, Y+16	; 0x10
    260e:	ca 01       	movw	r24, r20
    2610:	b9 01       	movw	r22, r18
    2612:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2616:	29 85       	ldd	r18, Y+9	; 0x09
    2618:	3a 85       	ldd	r19, Y+10	; 0x0a
    261a:	4b 85       	ldd	r20, Y+11	; 0x0b
    261c:	5c 85       	ldd	r21, Y+12	; 0x0c
    261e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2622:	a5 01       	movw	r20, r10
    2624:	94 01       	movw	r18, r8
    2626:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    262a:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    262e:	60 93 bc 02 	sts	0x02BC, r22	; 0x8002bc <prep+0x1b>
    2632:	70 93 bd 02 	sts	0x02BD, r23	; 0x8002bd <prep+0x1c>
    2636:	80 93 be 02 	sts	0x02BE, r24	; 0x8002be <prep+0x1d>
    263a:	90 93 bf 02 	sts	0x02BF, r25	; 0x8002bf <prep+0x1e>
    263e:	ae cb       	rjmp	.-2212   	; 0x1d9c <st_prep_buffer+0x150>
    2640:	92 e0       	ldi	r25, 0x02	; 2
    2642:	49 cf       	rjmp	.-366    	; 0x24d6 <st_prep_buffer+0x88a>
    2644:	80 91 c0 02 	lds	r24, 0x02C0	; 0x8002c0 <prep+0x1f>
    2648:	90 91 c1 02 	lds	r25, 0x02C1	; 0x8002c1 <prep+0x20>
    264c:	a0 91 c2 02 	lds	r26, 0x02C2	; 0x8002c2 <prep+0x21>
    2650:	b0 91 c3 02 	lds	r27, 0x02C3	; 0x8002c3 <prep+0x22>
    2654:	10 92 c4 02 	sts	0x02C4, r1	; 0x8002c4 <prep+0x23>
    2658:	10 92 c5 02 	sts	0x02C5, r1	; 0x8002c5 <prep+0x24>
    265c:	10 92 c6 02 	sts	0x02C6, r1	; 0x8002c6 <prep+0x25>
    2660:	10 92 c7 02 	sts	0x02C7, r1	; 0x8002c7 <prep+0x26>
    2664:	80 93 bc 02 	sts	0x02BC, r24	; 0x8002bc <prep+0x1b>
    2668:	90 93 bd 02 	sts	0x02BD, r25	; 0x8002bd <prep+0x1c>
    266c:	a0 93 be 02 	sts	0x02BE, r26	; 0x8002be <prep+0x1d>
    2670:	b0 93 bf 02 	sts	0x02BF, r27	; 0x8002bf <prep+0x1e>
    2674:	93 cb       	rjmp	.-2266   	; 0x1d9c <st_prep_buffer+0x150>
    2676:	81 e0       	ldi	r24, 0x01	; 1
    2678:	8e ab       	std	Y+54, r24	; 0x36
    267a:	4c cc       	rjmp	.-1896   	; 0x1f14 <st_prep_buffer+0x2c8>
    267c:	0d 87       	std	Y+13, r16	; 0x0d
    267e:	19 8b       	std	Y+17, r17	; 0x11
    2680:	39 81       	ldd	r19, Y+1	; 0x01
    2682:	3d 8b       	std	Y+21, r19	; 0x15
    2684:	4d 81       	ldd	r20, Y+5	; 0x05
    2686:	4e 8b       	std	Y+22, r20	; 0x16
    2688:	56 cc       	rjmp	.-1876   	; 0x1f36 <st_prep_buffer+0x2ea>
    268a:	20 e0       	ldi	r18, 0x00	; 0
    268c:	30 e0       	ldi	r19, 0x00	; 0
    268e:	40 e0       	ldi	r20, 0x00	; 0
    2690:	5f e3       	ldi	r21, 0x3F	; 63
    2692:	c5 01       	movw	r24, r10
    2694:	b4 01       	movw	r22, r8
    2696:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    269a:	27 2d       	mov	r18, r7
    269c:	36 2d       	mov	r19, r6
    269e:	21 96       	adiw	r28, 0x01	; 1
    26a0:	4f ad       	ldd	r20, Y+63	; 0x3f
    26a2:	21 97       	sbiw	r28, 0x01	; 1
    26a4:	5f ad       	ldd	r21, Y+63	; 0x3f
    26a6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    26aa:	a7 01       	movw	r20, r14
    26ac:	96 01       	movw	r18, r12
    26ae:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    26b2:	2d 85       	ldd	r18, Y+13	; 0x0d
    26b4:	39 89       	ldd	r19, Y+17	; 0x11
    26b6:	4d 89       	ldd	r20, Y+21	; 0x15
    26b8:	5e 89       	ldd	r21, Y+22	; 0x16
    26ba:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    26be:	8b 01       	movw	r16, r22
    26c0:	89 83       	std	Y+1, r24	; 0x01
    26c2:	9d 83       	std	Y+5, r25	; 0x05
    26c4:	a5 01       	movw	r20, r10
    26c6:	94 01       	movw	r18, r8
    26c8:	67 2d       	mov	r22, r7
    26ca:	76 2d       	mov	r23, r6
    26cc:	21 96       	adiw	r28, 0x01	; 1
    26ce:	8f ad       	ldd	r24, Y+63	; 0x3f
    26d0:	21 97       	sbiw	r28, 0x01	; 1
    26d2:	9f ad       	ldd	r25, Y+63	; 0x3f
    26d4:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    26d8:	64 c0       	rjmp	.+200    	; 0x27a2 <st_prep_buffer+0xb56>
    26da:	5a 96       	adiw	r26, 0x1a	; 26
    26dc:	2d 91       	ld	r18, X+
    26de:	3d 91       	ld	r19, X+
    26e0:	4d 91       	ld	r20, X+
    26e2:	5c 91       	ld	r21, X
    26e4:	5d 97       	sbiw	r26, 0x1d	; 29
    26e6:	c7 01       	movw	r24, r14
    26e8:	b6 01       	movw	r22, r12
    26ea:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    26ee:	4b 01       	movw	r8, r22
    26f0:	5c 01       	movw	r10, r24
    26f2:	20 e0       	ldi	r18, 0x00	; 0
    26f4:	30 e0       	ldi	r19, 0x00	; 0
    26f6:	40 e0       	ldi	r20, 0x00	; 0
    26f8:	5f e3       	ldi	r21, 0x3F	; 63
    26fa:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    26fe:	27 2d       	mov	r18, r7
    2700:	36 2d       	mov	r19, r6
    2702:	21 96       	adiw	r28, 0x01	; 1
    2704:	4f ad       	ldd	r20, Y+63	; 0x3f
    2706:	21 97       	sbiw	r28, 0x01	; 1
    2708:	5f ad       	ldd	r21, Y+63	; 0x3f
    270a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    270e:	a7 01       	movw	r20, r14
    2710:	96 01       	movw	r18, r12
    2712:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2716:	9b 01       	movw	r18, r22
    2718:	ac 01       	movw	r20, r24
    271a:	6d 85       	ldd	r22, Y+13	; 0x0d
    271c:	79 89       	ldd	r23, Y+17	; 0x11
    271e:	8d 89       	ldd	r24, Y+21	; 0x15
    2720:	9e 89       	ldd	r25, Y+22	; 0x16
    2722:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2726:	8b 01       	movw	r16, r22
    2728:	89 83       	std	Y+1, r24	; 0x01
    272a:	9d 83       	std	Y+5, r25	; 0x05
    272c:	9b 01       	movw	r18, r22
    272e:	ac 01       	movw	r20, r24
    2730:	6a a1       	ldd	r22, Y+34	; 0x22
    2732:	7b a1       	ldd	r23, Y+35	; 0x23
    2734:	8c a1       	ldd	r24, Y+36	; 0x24
    2736:	9d a1       	ldd	r25, Y+37	; 0x25
    2738:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    273c:	18 16       	cp	r1, r24
    273e:	3c f5       	brge	.+78     	; 0x278e <st_prep_buffer+0xb42>
    2740:	27 2d       	mov	r18, r7
    2742:	36 2d       	mov	r19, r6
    2744:	21 96       	adiw	r28, 0x01	; 1
    2746:	4f ad       	ldd	r20, Y+63	; 0x3f
    2748:	21 97       	sbiw	r28, 0x01	; 1
    274a:	5f ad       	ldd	r21, Y+63	; 0x3f
    274c:	6a 8d       	ldd	r22, Y+26	; 0x1a
    274e:	7b 8d       	ldd	r23, Y+27	; 0x1b
    2750:	8c 8d       	ldd	r24, Y+28	; 0x1c
    2752:	9d 8d       	ldd	r25, Y+29	; 0x1d
    2754:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2758:	9b 01       	movw	r18, r22
    275a:	ac 01       	movw	r20, r24
    275c:	6a a9       	ldd	r22, Y+50	; 0x32
    275e:	7b a9       	ldd	r23, Y+51	; 0x33
    2760:	8c a9       	ldd	r24, Y+52	; 0x34
    2762:	9d a9       	ldd	r25, Y+53	; 0x35
    2764:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    2768:	6b 01       	movw	r12, r22
    276a:	7c 01       	movw	r14, r24
    276c:	7a 8c       	ldd	r7, Y+26	; 0x1a
    276e:	6b 8c       	ldd	r6, Y+27	; 0x1b
    2770:	bc 8d       	ldd	r27, Y+28	; 0x1c
    2772:	21 96       	adiw	r28, 0x01	; 1
    2774:	bf af       	std	Y+63, r27	; 0x3f
    2776:	21 97       	sbiw	r28, 0x01	; 1
    2778:	ed 8d       	ldd	r30, Y+29	; 0x1d
    277a:	ef af       	std	Y+63, r30	; 0x3f
    277c:	fe a9       	ldd	r31, Y+54	; 0x36
    277e:	f9 8f       	std	Y+25, r31	; 0x19
    2780:	0a a1       	ldd	r16, Y+34	; 0x22
    2782:	1b a1       	ldd	r17, Y+35	; 0x23
    2784:	2c a1       	ldd	r18, Y+36	; 0x24
    2786:	29 83       	std	Y+1, r18	; 0x01
    2788:	3d a1       	ldd	r19, Y+37	; 0x25
    278a:	3d 83       	std	Y+5, r19	; 0x05
    278c:	26 cc       	rjmp	.-1972   	; 0x1fda <st_prep_buffer+0x38e>
    278e:	a5 01       	movw	r20, r10
    2790:	94 01       	movw	r18, r8
    2792:	67 2d       	mov	r22, r7
    2794:	76 2d       	mov	r23, r6
    2796:	21 96       	adiw	r28, 0x01	; 1
    2798:	8f ad       	ldd	r24, Y+63	; 0x3f
    279a:	21 97       	sbiw	r28, 0x01	; 1
    279c:	9f ad       	ldd	r25, Y+63	; 0x3f
    279e:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    27a2:	76 2e       	mov	r7, r22
    27a4:	67 2e       	mov	r6, r23
    27a6:	21 96       	adiw	r28, 0x01	; 1
    27a8:	8f af       	std	Y+63, r24	; 0x3f
    27aa:	21 97       	sbiw	r28, 0x01	; 1
    27ac:	9f af       	std	Y+63, r25	; 0x3f
    27ae:	15 cc       	rjmp	.-2006   	; 0x1fda <st_prep_buffer+0x38e>
    27b0:	2a 8d       	ldd	r18, Y+26	; 0x1a
    27b2:	3b 8d       	ldd	r19, Y+27	; 0x1b
    27b4:	4c 8d       	ldd	r20, Y+28	; 0x1c
    27b6:	5d 8d       	ldd	r21, Y+29	; 0x1d
    27b8:	c7 01       	movw	r24, r14
    27ba:	b6 01       	movw	r22, r12
    27bc:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    27c0:	9b 01       	movw	r18, r22
    27c2:	ac 01       	movw	r20, r24
    27c4:	6d 85       	ldd	r22, Y+13	; 0x0d
    27c6:	79 89       	ldd	r23, Y+17	; 0x11
    27c8:	8d 89       	ldd	r24, Y+21	; 0x15
    27ca:	9e 89       	ldd	r25, Y+22	; 0x16
    27cc:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    27d0:	8b 01       	movw	r16, r22
    27d2:	89 83       	std	Y+1, r24	; 0x01
    27d4:	9d 83       	std	Y+5, r25	; 0x05
    27d6:	2e a1       	ldd	r18, Y+38	; 0x26
    27d8:	3f a1       	ldd	r19, Y+39	; 0x27
    27da:	48 a5       	ldd	r20, Y+40	; 0x28
    27dc:	59 a5       	ldd	r21, Y+41	; 0x29
    27de:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    27e2:	87 ff       	sbrs	r24, 7
    27e4:	fa cb       	rjmp	.-2060   	; 0x1fda <st_prep_buffer+0x38e>
    27e6:	2e a1       	ldd	r18, Y+38	; 0x26
    27e8:	3f a1       	ldd	r19, Y+39	; 0x27
    27ea:	48 a5       	ldd	r20, Y+40	; 0x28
    27ec:	59 a5       	ldd	r21, Y+41	; 0x29
    27ee:	6d 85       	ldd	r22, Y+13	; 0x0d
    27f0:	79 89       	ldd	r23, Y+17	; 0x11
    27f2:	8d 89       	ldd	r24, Y+21	; 0x15
    27f4:	9e 89       	ldd	r25, Y+22	; 0x16
    27f6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    27fa:	2b ad       	ldd	r18, Y+59	; 0x3b
    27fc:	3c ad       	ldd	r19, Y+60	; 0x3c
    27fe:	4d ad       	ldd	r20, Y+61	; 0x3d
    2800:	5e ad       	ldd	r21, Y+62	; 0x3e
    2802:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2806:	6b 01       	movw	r12, r22
    2808:	7c 01       	movw	r14, r24
    280a:	0e a1       	ldd	r16, Y+38	; 0x26
    280c:	1f a1       	ldd	r17, Y+39	; 0x27
    280e:	48 a5       	ldd	r20, Y+40	; 0x28
    2810:	49 83       	std	Y+1, r20	; 0x01
    2812:	59 a5       	ldd	r21, Y+41	; 0x29
    2814:	5d 83       	std	Y+5, r21	; 0x05
    2816:	82 e0       	ldi	r24, 0x02	; 2
    2818:	89 8f       	std	Y+25, r24	; 0x19
    281a:	df cb       	rjmp	.-2114   	; 0x1fda <st_prep_buffer+0x38e>
    281c:	5a 96       	adiw	r26, 0x1a	; 26
    281e:	2d 91       	ld	r18, X+
    2820:	3d 91       	ld	r19, X+
    2822:	4d 91       	ld	r20, X+
    2824:	5c 91       	ld	r21, X
    2826:	5d 97       	sbiw	r26, 0x1d	; 29
    2828:	c7 01       	movw	r24, r14
    282a:	b6 01       	movw	r22, r12
    282c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2830:	4b 01       	movw	r8, r22
    2832:	5c 01       	movw	r10, r24
    2834:	27 2d       	mov	r18, r7
    2836:	36 2d       	mov	r19, r6
    2838:	21 96       	adiw	r28, 0x01	; 1
    283a:	4f ad       	ldd	r20, Y+63	; 0x3f
    283c:	21 97       	sbiw	r28, 0x01	; 1
    283e:	5f ad       	ldd	r21, Y+63	; 0x3f
    2840:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    2844:	87 ff       	sbrs	r24, 7
    2846:	26 c0       	rjmp	.+76     	; 0x2894 <st_prep_buffer+0xc48>
    2848:	20 e0       	ldi	r18, 0x00	; 0
    284a:	30 e0       	ldi	r19, 0x00	; 0
    284c:	40 e0       	ldi	r20, 0x00	; 0
    284e:	5f e3       	ldi	r21, 0x3F	; 63
    2850:	c5 01       	movw	r24, r10
    2852:	b4 01       	movw	r22, r8
    2854:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2858:	27 2d       	mov	r18, r7
    285a:	36 2d       	mov	r19, r6
    285c:	21 96       	adiw	r28, 0x01	; 1
    285e:	4f ad       	ldd	r20, Y+63	; 0x3f
    2860:	21 97       	sbiw	r28, 0x01	; 1
    2862:	5f ad       	ldd	r21, Y+63	; 0x3f
    2864:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2868:	a7 01       	movw	r20, r14
    286a:	96 01       	movw	r18, r12
    286c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2870:	2d 85       	ldd	r18, Y+13	; 0x0d
    2872:	39 89       	ldd	r19, Y+17	; 0x11
    2874:	4d 89       	ldd	r20, Y+21	; 0x15
    2876:	5e 89       	ldd	r21, Y+22	; 0x16
    2878:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    287c:	8b 01       	movw	r16, r22
    287e:	89 83       	std	Y+1, r24	; 0x01
    2880:	9d 83       	std	Y+5, r25	; 0x05
    2882:	2a a5       	ldd	r18, Y+42	; 0x2a
    2884:	3b a5       	ldd	r19, Y+43	; 0x2b
    2886:	4c a5       	ldd	r20, Y+44	; 0x2c
    2888:	5d a5       	ldd	r21, Y+45	; 0x2d
    288a:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    288e:	18 16       	cp	r1, r24
    2890:	0c f4       	brge	.+2      	; 0x2894 <st_prep_buffer+0xc48>
    2892:	18 cf       	rjmp	.-464    	; 0x26c4 <st_prep_buffer+0xa78>
    2894:	2a a5       	ldd	r18, Y+42	; 0x2a
    2896:	3b a5       	ldd	r19, Y+43	; 0x2b
    2898:	4c a5       	ldd	r20, Y+44	; 0x2c
    289a:	5d a5       	ldd	r21, Y+45	; 0x2d
    289c:	6d 85       	ldd	r22, Y+13	; 0x0d
    289e:	79 89       	ldd	r23, Y+17	; 0x11
    28a0:	8d 89       	ldd	r24, Y+21	; 0x15
    28a2:	9e 89       	ldd	r25, Y+22	; 0x16
    28a4:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    28a8:	9b 01       	movw	r18, r22
    28aa:	ac 01       	movw	r20, r24
    28ac:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    28b0:	6b 01       	movw	r12, r22
    28b2:	7c 01       	movw	r14, r24
    28b4:	27 2d       	mov	r18, r7
    28b6:	36 2d       	mov	r19, r6
    28b8:	21 96       	adiw	r28, 0x01	; 1
    28ba:	4f ad       	ldd	r20, Y+63	; 0x3f
    28bc:	21 97       	sbiw	r28, 0x01	; 1
    28be:	5f ad       	ldd	r21, Y+63	; 0x3f
    28c0:	6f a9       	ldd	r22, Y+55	; 0x37
    28c2:	78 ad       	ldd	r23, Y+56	; 0x38
    28c4:	89 ad       	ldd	r24, Y+57	; 0x39
    28c6:	9a ad       	ldd	r25, Y+58	; 0x3a
    28c8:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    28cc:	9b 01       	movw	r18, r22
    28ce:	ac 01       	movw	r20, r24
    28d0:	c7 01       	movw	r24, r14
    28d2:	b6 01       	movw	r22, r12
    28d4:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    28d8:	6b 01       	movw	r12, r22
    28da:	7c 01       	movw	r14, r24
    28dc:	7f a8       	ldd	r7, Y+55	; 0x37
    28de:	68 ac       	ldd	r6, Y+56	; 0x38
    28e0:	b9 ad       	ldd	r27, Y+57	; 0x39
    28e2:	21 96       	adiw	r28, 0x01	; 1
    28e4:	bf af       	std	Y+63, r27	; 0x3f
    28e6:	21 97       	sbiw	r28, 0x01	; 1
    28e8:	ea ad       	ldd	r30, Y+58	; 0x3a
    28ea:	ef af       	std	Y+63, r30	; 0x3f
    28ec:	0a a5       	ldd	r16, Y+42	; 0x2a
    28ee:	1b a5       	ldd	r17, Y+43	; 0x2b
    28f0:	fc a5       	ldd	r31, Y+44	; 0x2c
    28f2:	f9 83       	std	Y+1, r31	; 0x01
    28f4:	2d a5       	ldd	r18, Y+45	; 0x2d
    28f6:	2d 83       	std	Y+5, r18	; 0x05
    28f8:	70 cb       	rjmp	.-2336   	; 0x1fda <st_prep_buffer+0x38e>
    28fa:	98 01       	movw	r18, r16
    28fc:	49 81       	ldd	r20, Y+1	; 0x01
    28fe:	5d 81       	ldd	r21, Y+5	; 0x05
    2900:	6e a5       	ldd	r22, Y+46	; 0x2e
    2902:	7f a5       	ldd	r23, Y+47	; 0x2f
    2904:	88 a9       	ldd	r24, Y+48	; 0x30
    2906:	99 a9       	ldd	r25, Y+49	; 0x31
    2908:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    290c:	87 ff       	sbrs	r24, 7
    290e:	11 c0       	rjmp	.+34     	; 0x2932 <st_prep_buffer+0xce6>
    2910:	2e e3       	ldi	r18, 0x3E	; 62
    2912:	33 ec       	ldi	r19, 0xC3	; 195
    2914:	4e e2       	ldi	r20, 0x2E	; 46
    2916:	59 e3       	ldi	r21, 0x39	; 57
    2918:	6e 8d       	ldd	r22, Y+30	; 0x1e
    291a:	7f 8d       	ldd	r23, Y+31	; 0x1f
    291c:	88 a1       	ldd	r24, Y+32	; 0x20
    291e:	99 a1       	ldd	r25, Y+33	; 0x21
    2920:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2924:	6e 8f       	std	Y+30, r22	; 0x1e
    2926:	7f 8f       	std	Y+31, r23	; 0x1f
    2928:	88 a3       	std	Y+32, r24	; 0x20
    292a:	99 a3       	std	Y+33, r25	; 0x21
    292c:	a2 01       	movw	r20, r4
    292e:	91 01       	movw	r18, r2
    2930:	6a cb       	rjmp	.-2348   	; 0x2006 <st_prep_buffer+0x3ba>
    2932:	49 8d       	ldd	r20, Y+25	; 0x19
    2934:	40 93 b3 02 	sts	0x02B3, r20	; 0x8002b3 <prep+0x12>
    2938:	78 cb       	rjmp	.-2320   	; 0x202a <st_prep_buffer+0x3de>
    293a:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    293e:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    2942:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    2946:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    294a:	10 92 d0 02 	sts	0x02D0, r1	; 0x8002d0 <prep+0x2f>
    294e:	ae cb       	rjmp	.-2212   	; 0x20ac <st_prep_buffer+0x460>
    2950:	20 91 a3 02 	lds	r18, 0x02A3	; 0x8002a3 <prep+0x2>
    2954:	30 91 a4 02 	lds	r19, 0x02A4	; 0x8002a4 <prep+0x3>
    2958:	40 91 a5 02 	lds	r20, 0x02A5	; 0x8002a5 <prep+0x4>
    295c:	50 91 a6 02 	lds	r21, 0x02A6	; 0x8002a6 <prep+0x5>
    2960:	c2 01       	movw	r24, r4
    2962:	b1 01       	movw	r22, r2
    2964:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2968:	2b 01       	movw	r4, r22
    296a:	3c 01       	movw	r6, r24
    296c:	29 85       	ldd	r18, Y+9	; 0x09
    296e:	3a 85       	ldd	r19, Y+10	; 0x0a
    2970:	4b 85       	ldd	r20, Y+11	; 0x0b
    2972:	5c 85       	ldd	r21, Y+12	; 0x0c
    2974:	c5 01       	movw	r24, r10
    2976:	b4 01       	movw	r22, r8
    2978:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    297c:	9b 01       	movw	r18, r22
    297e:	ac 01       	movw	r20, r24
    2980:	c3 01       	movw	r24, r6
    2982:	b2 01       	movw	r22, r4
    2984:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    2988:	4b 01       	movw	r8, r22
    298a:	5c 01       	movw	r10, r24
    298c:	20 ec       	ldi	r18, 0xC0	; 192
    298e:	31 ee       	ldi	r19, 0xE1	; 225
    2990:	44 e6       	ldi	r20, 0x64	; 100
    2992:	5e e4       	ldi	r21, 0x4E	; 78
    2994:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2998:	0e 94 ef 35 	call	0x6bde	; 0x6bde <ceil>
    299c:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    29a0:	60 3d       	cpi	r22, 0xD0	; 208
    29a2:	57 e0       	ldi	r21, 0x07	; 7
    29a4:	75 07       	cpc	r23, r21
    29a6:	81 05       	cpc	r24, r1
    29a8:	91 05       	cpc	r25, r1
    29aa:	08 f0       	brcs	.+2      	; 0x29ae <st_prep_buffer+0xd62>
    29ac:	66 c0       	rjmp	.+204    	; 0x2a7a <st_prep_buffer+0xe2e>
    29ae:	27 e0       	ldi	r18, 0x07	; 7
    29b0:	af 89       	ldd	r26, Y+23	; 0x17
    29b2:	b8 8d       	ldd	r27, Y+24	; 0x18
    29b4:	2a 9f       	mul	r18, r26
    29b6:	f0 01       	movw	r30, r0
    29b8:	2b 9f       	mul	r18, r27
    29ba:	f0 0d       	add	r31, r0
    29bc:	11 24       	eor	r1, r1
    29be:	e6 5e       	subi	r30, 0xE6	; 230
    29c0:	fd 4f       	sbci	r31, 0xFD	; 253
    29c2:	15 82       	std	Z+5, r1	; 0x05
    29c4:	27 e0       	ldi	r18, 0x07	; 7
    29c6:	af 89       	ldd	r26, Y+23	; 0x17
    29c8:	b8 8d       	ldd	r27, Y+24	; 0x18
    29ca:	2a 9f       	mul	r18, r26
    29cc:	f0 01       	movw	r30, r0
    29ce:	2b 9f       	mul	r18, r27
    29d0:	f0 0d       	add	r31, r0
    29d2:	11 24       	eor	r1, r1
    29d4:	e6 5e       	subi	r30, 0xE6	; 230
    29d6:	fd 4f       	sbci	r31, 0xFD	; 253
    29d8:	73 83       	std	Z+3, r23	; 0x03
    29da:	62 83       	std	Z+2, r22	; 0x02
    29dc:	80 91 19 02 	lds	r24, 0x0219	; 0x800219 <segment_next_head>
    29e0:	80 93 44 02 	sts	0x0244, r24	; 0x800244 <segment_buffer_head>
    29e4:	8f 5f       	subi	r24, 0xFF	; 255
    29e6:	86 30       	cpi	r24, 0x06	; 6
    29e8:	09 f4       	brne	.+2      	; 0x29ec <st_prep_buffer+0xda0>
    29ea:	a1 c0       	rjmp	.+322    	; 0x2b2e <st_prep_buffer+0xee2>
    29ec:	80 93 19 02 	sts	0x0219, r24	; 0x800219 <segment_next_head>
    29f0:	e0 91 d1 02 	lds	r30, 0x02D1	; 0x8002d1 <pl_block>
    29f4:	f0 91 d2 02 	lds	r31, 0x02D2	; 0x8002d2 <pl_block+0x1>
    29f8:	c8 01       	movw	r24, r16
    29fa:	a9 81       	ldd	r26, Y+1	; 0x01
    29fc:	bd 81       	ldd	r27, Y+5	; 0x05
    29fe:	86 8f       	std	Z+30, r24	; 0x1e
    2a00:	97 8f       	std	Z+31, r25	; 0x1f
    2a02:	a0 a3       	std	Z+32, r26	; 0x20
    2a04:	b1 a3       	std	Z+33, r27	; 0x21
    2a06:	c0 92 a7 02 	sts	0x02A7, r12	; 0x8002a7 <prep+0x6>
    2a0a:	d0 92 a8 02 	sts	0x02A8, r13	; 0x8002a8 <prep+0x7>
    2a0e:	e0 92 a9 02 	sts	0x02A9, r14	; 0x8002a9 <prep+0x8>
    2a12:	f0 92 aa 02 	sts	0x02AA, r15	; 0x8002aa <prep+0x9>
    2a16:	29 85       	ldd	r18, Y+9	; 0x09
    2a18:	3a 85       	ldd	r19, Y+10	; 0x0a
    2a1a:	4b 85       	ldd	r20, Y+11	; 0x0b
    2a1c:	5c 85       	ldd	r21, Y+12	; 0x0c
    2a1e:	c7 01       	movw	r24, r14
    2a20:	b6 01       	movw	r22, r12
    2a22:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2a26:	a5 01       	movw	r20, r10
    2a28:	94 01       	movw	r18, r8
    2a2a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    2a2e:	60 93 a3 02 	sts	0x02A3, r22	; 0x8002a3 <prep+0x2>
    2a32:	70 93 a4 02 	sts	0x02A4, r23	; 0x8002a4 <prep+0x3>
    2a36:	80 93 a5 02 	sts	0x02A5, r24	; 0x8002a5 <prep+0x4>
    2a3a:	90 93 a6 02 	sts	0x02A6, r25	; 0x8002a6 <prep+0x5>
    2a3e:	20 91 b4 02 	lds	r18, 0x02B4	; 0x8002b4 <prep+0x13>
    2a42:	30 91 b5 02 	lds	r19, 0x02B5	; 0x8002b5 <prep+0x14>
    2a46:	40 91 b6 02 	lds	r20, 0x02B6	; 0x8002b6 <prep+0x15>
    2a4a:	50 91 b7 02 	lds	r21, 0x02B7	; 0x8002b7 <prep+0x16>
    2a4e:	b8 01       	movw	r22, r16
    2a50:	89 81       	ldd	r24, Y+1	; 0x01
    2a52:	9d 81       	ldd	r25, Y+5	; 0x05
    2a54:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    2a58:	81 11       	cpse	r24, r1
    2a5a:	17 c9       	rjmp	.-3538   	; 0x1c8a <st_prep_buffer+0x3e>
    2a5c:	f0 90 35 06 	lds	r15, 0x0635	; 0x800635 <sys+0x4>
    2a60:	20 e0       	ldi	r18, 0x00	; 0
    2a62:	30 e0       	ldi	r19, 0x00	; 0
    2a64:	a9 01       	movw	r20, r18
    2a66:	b8 01       	movw	r22, r16
    2a68:	89 81       	ldd	r24, Y+1	; 0x01
    2a6a:	9d 81       	ldd	r25, Y+5	; 0x05
    2a6c:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    2a70:	18 16       	cp	r1, r24
    2a72:	0c f0       	brlt	.+2      	; 0x2a76 <st_prep_buffer+0xe2a>
    2a74:	5f c0       	rjmp	.+190    	; 0x2b34 <st_prep_buffer+0xee8>
    2a76:	8f 2d       	mov	r24, r15
    2a78:	66 cb       	rjmp	.-2356   	; 0x2146 <st_prep_buffer+0x4fa>
    2a7a:	60 3a       	cpi	r22, 0xA0	; 160
    2a7c:	3f e0       	ldi	r19, 0x0F	; 15
    2a7e:	73 07       	cpc	r23, r19
    2a80:	81 05       	cpc	r24, r1
    2a82:	91 05       	cpc	r25, r1
    2a84:	a0 f5       	brcc	.+104    	; 0x2aee <st_prep_buffer+0xea2>
    2a86:	a7 e0       	ldi	r26, 0x07	; 7
    2a88:	4f 89       	ldd	r20, Y+23	; 0x17
    2a8a:	58 8d       	ldd	r21, Y+24	; 0x18
    2a8c:	a4 9f       	mul	r26, r20
    2a8e:	f0 01       	movw	r30, r0
    2a90:	a5 9f       	mul	r26, r21
    2a92:	f0 0d       	add	r31, r0
    2a94:	11 24       	eor	r1, r1
    2a96:	e6 5e       	subi	r30, 0xE6	; 230
    2a98:	fd 4f       	sbci	r31, 0xFD	; 253
    2a9a:	b1 e0       	ldi	r27, 0x01	; 1
    2a9c:	b5 83       	std	Z+5, r27	; 0x05
    2a9e:	a7 e0       	ldi	r26, 0x07	; 7
    2aa0:	4f 89       	ldd	r20, Y+23	; 0x17
    2aa2:	58 8d       	ldd	r21, Y+24	; 0x18
    2aa4:	a4 9f       	mul	r26, r20
    2aa6:	f0 01       	movw	r30, r0
    2aa8:	a5 9f       	mul	r26, r21
    2aaa:	f0 0d       	add	r31, r0
    2aac:	11 24       	eor	r1, r1
    2aae:	e6 5e       	subi	r30, 0xE6	; 230
    2ab0:	fd 4f       	sbci	r31, 0xFD	; 253
    2ab2:	25 81       	ldd	r18, Z+5	; 0x05
    2ab4:	02 2e       	mov	r0, r18
    2ab6:	04 c0       	rjmp	.+8      	; 0x2ac0 <st_prep_buffer+0xe74>
    2ab8:	96 95       	lsr	r25
    2aba:	87 95       	ror	r24
    2abc:	77 95       	ror	r23
    2abe:	67 95       	ror	r22
    2ac0:	0a 94       	dec	r0
    2ac2:	d2 f7       	brpl	.-12     	; 0x2ab8 <st_prep_buffer+0xe6c>
    2ac4:	4d 85       	ldd	r20, Y+13	; 0x0d
    2ac6:	5e 85       	ldd	r21, Y+14	; 0x0e
    2ac8:	02 c0       	rjmp	.+4      	; 0x2ace <st_prep_buffer+0xe82>
    2aca:	44 0f       	add	r20, r20
    2acc:	55 1f       	adc	r21, r21
    2ace:	2a 95       	dec	r18
    2ad0:	e2 f7       	brpl	.-8      	; 0x2aca <st_prep_buffer+0xe7e>
    2ad2:	51 83       	std	Z+1, r21	; 0x01
    2ad4:	40 83       	st	Z, r20
    2ad6:	61 15       	cp	r22, r1
    2ad8:	71 05       	cpc	r23, r1
    2ada:	51 e0       	ldi	r21, 0x01	; 1
    2adc:	85 07       	cpc	r24, r21
    2ade:	91 05       	cpc	r25, r1
    2ae0:	08 f4       	brcc	.+2      	; 0x2ae4 <st_prep_buffer+0xe98>
    2ae2:	70 cf       	rjmp	.-288    	; 0x29c4 <st_prep_buffer+0xd78>
    2ae4:	4f ef       	ldi	r20, 0xFF	; 255
    2ae6:	5f ef       	ldi	r21, 0xFF	; 255
    2ae8:	53 83       	std	Z+3, r21	; 0x03
    2aea:	42 83       	std	Z+2, r20	; 0x02
    2aec:	77 cf       	rjmp	.-274    	; 0x29dc <st_prep_buffer+0xd90>
    2aee:	60 34       	cpi	r22, 0x40	; 64
    2af0:	ef e1       	ldi	r30, 0x1F	; 31
    2af2:	7e 07       	cpc	r23, r30
    2af4:	81 05       	cpc	r24, r1
    2af6:	91 05       	cpc	r25, r1
    2af8:	68 f4       	brcc	.+26     	; 0x2b14 <st_prep_buffer+0xec8>
    2afa:	47 e0       	ldi	r20, 0x07	; 7
    2afc:	2f 89       	ldd	r18, Y+23	; 0x17
    2afe:	38 8d       	ldd	r19, Y+24	; 0x18
    2b00:	42 9f       	mul	r20, r18
    2b02:	f0 01       	movw	r30, r0
    2b04:	43 9f       	mul	r20, r19
    2b06:	f0 0d       	add	r31, r0
    2b08:	11 24       	eor	r1, r1
    2b0a:	e6 5e       	subi	r30, 0xE6	; 230
    2b0c:	fd 4f       	sbci	r31, 0xFD	; 253
    2b0e:	52 e0       	ldi	r21, 0x02	; 2
    2b10:	55 83       	std	Z+5, r21	; 0x05
    2b12:	c5 cf       	rjmp	.-118    	; 0x2a9e <st_prep_buffer+0xe52>
    2b14:	27 e0       	ldi	r18, 0x07	; 7
    2b16:	af 89       	ldd	r26, Y+23	; 0x17
    2b18:	b8 8d       	ldd	r27, Y+24	; 0x18
    2b1a:	2a 9f       	mul	r18, r26
    2b1c:	f0 01       	movw	r30, r0
    2b1e:	2b 9f       	mul	r18, r27
    2b20:	f0 0d       	add	r31, r0
    2b22:	11 24       	eor	r1, r1
    2b24:	e6 5e       	subi	r30, 0xE6	; 230
    2b26:	fd 4f       	sbci	r31, 0xFD	; 253
    2b28:	33 e0       	ldi	r19, 0x03	; 3
    2b2a:	35 83       	std	Z+5, r19	; 0x05
    2b2c:	b8 cf       	rjmp	.-144    	; 0x2a9e <st_prep_buffer+0xe52>
    2b2e:	10 92 19 02 	sts	0x0219, r1	; 0x800219 <segment_next_head>
    2b32:	5e cf       	rjmp	.-324    	; 0x29f0 <st_prep_buffer+0xda4>
    2b34:	f2 fc       	sbrc	r15, 2
    2b36:	9f cf       	rjmp	.-194    	; 0x2a76 <st_prep_buffer+0xe2a>
    2b38:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
    2b3c:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
    2b40:	90 91 d5 02 	lds	r25, 0x02D5	; 0x8002d5 <block_buffer_tail>
    2b44:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    2b48:	89 17       	cp	r24, r25
    2b4a:	09 f4       	brne	.+2      	; 0x2b4e <st_prep_buffer+0xf02>
    2b4c:	9e c8       	rjmp	.-3780   	; 0x1c8a <st_prep_buffer+0x3e>
    2b4e:	81 e0       	ldi	r24, 0x01	; 1
    2b50:	89 0f       	add	r24, r25
    2b52:	80 31       	cpi	r24, 0x10	; 16
    2b54:	09 f4       	brne	.+2      	; 0x2b58 <st_prep_buffer+0xf0c>
    2b56:	80 e0       	ldi	r24, 0x00	; 0
    2b58:	20 91 d3 02 	lds	r18, 0x02D3	; 0x8002d3 <block_buffer_planned>
    2b5c:	92 13       	cpse	r25, r18
    2b5e:	02 c0       	rjmp	.+4      	; 0x2b64 <st_prep_buffer+0xf18>
    2b60:	80 93 d3 02 	sts	0x02D3, r24	; 0x8002d3 <block_buffer_planned>
    2b64:	80 93 d5 02 	sts	0x02D5, r24	; 0x8002d5 <block_buffer_tail>
    2b68:	90 c8       	rjmp	.-3808   	; 0x1c8a <st_prep_buffer+0x3e>

00002b6a <protocol_exec_rt_system>:
    2b6a:	2f 92       	push	r2
    2b6c:	3f 92       	push	r3
    2b6e:	4f 92       	push	r4
    2b70:	5f 92       	push	r5
    2b72:	6f 92       	push	r6
    2b74:	7f 92       	push	r7
    2b76:	8f 92       	push	r8
    2b78:	9f 92       	push	r9
    2b7a:	af 92       	push	r10
    2b7c:	bf 92       	push	r11
    2b7e:	cf 92       	push	r12
    2b80:	df 92       	push	r13
    2b82:	ef 92       	push	r14
    2b84:	ff 92       	push	r15
    2b86:	0f 93       	push	r16
    2b88:	1f 93       	push	r17
    2b8a:	cf 93       	push	r28
    2b8c:	df 93       	push	r29
    2b8e:	cd b7       	in	r28, 0x3d	; 61
    2b90:	de b7       	in	r29, 0x3e	; 62
    2b92:	a4 97       	sbiw	r28, 0x24	; 36
    2b94:	0f b6       	in	r0, 0x3f	; 63
    2b96:	f8 94       	cli
    2b98:	de bf       	out	0x3e, r29	; 62
    2b9a:	0f be       	out	0x3f, r0	; 63
    2b9c:	cd bf       	out	0x3d, r28	; 61
    2b9e:	10 91 14 06 	lds	r17, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    2ba2:	11 23       	and	r17, r17
    2ba4:	49 f1       	breq	.+82     	; 0x2bf8 <protocol_exec_rt_system+0x8e>
    2ba6:	81 e0       	ldi	r24, 0x01	; 1
    2ba8:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2bac:	86 e6       	ldi	r24, 0x66	; 102
    2bae:	91 e0       	ldi	r25, 0x01	; 1
    2bb0:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2bb4:	81 2f       	mov	r24, r17
    2bb6:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    2bba:	0e 94 c8 07 	call	0xf90	; 0xf90 <report_util_line_feed>
    2bbe:	85 ef       	ldi	r24, 0xF5	; 245
    2bc0:	91 e0       	ldi	r25, 0x01	; 1
    2bc2:	01 97       	sbiw	r24, 0x01	; 1
    2bc4:	e1 f5       	brne	.+120    	; 0x2c3e <protocol_exec_rt_system+0xd4>
    2bc6:	11 50       	subi	r17, 0x01	; 1
    2bc8:	12 30       	cpi	r17, 0x02	; 2
    2bca:	88 f4       	brcc	.+34     	; 0x2bee <protocol_exec_rt_system+0x84>
    2bcc:	8a ec       	ldi	r24, 0xCA	; 202
    2bce:	92 e0       	ldi	r25, 0x02	; 2
    2bd0:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2bd4:	88 eb       	ldi	r24, 0xB8	; 184
    2bd6:	92 e0       	ldi	r25, 0x02	; 2
    2bd8:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2bdc:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    2be0:	80 e1       	ldi	r24, 0x10	; 16
    2be2:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    2be6:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    2bea:	84 ff       	sbrs	r24, 4
    2bec:	fc cf       	rjmp	.-8      	; 0x2be6 <protocol_exec_rt_system+0x7c>
    2bee:	8f b7       	in	r24, 0x3f	; 63
    2bf0:	f8 94       	cli
    2bf2:	10 92 14 06 	sts	0x0614, r1	; 0x800614 <sys_rt_exec_alarm>
    2bf6:	8f bf       	out	0x3f, r24	; 63
    2bf8:	10 91 13 06 	lds	r17, 0x0613	; 0x800613 <sys_rt_exec_state>
    2bfc:	11 23       	and	r17, r17
    2bfe:	09 f4       	brne	.+2      	; 0x2c02 <protocol_exec_rt_system+0x98>
    2c00:	a9 c2       	rjmp	.+1362   	; 0x3154 <protocol_exec_rt_system+0x5ea>
    2c02:	14 ff       	sbrs	r17, 4
    2c04:	23 c0       	rjmp	.+70     	; 0x2c4c <protocol_exec_rt_system+0xe2>
    2c06:	81 e0       	ldi	r24, 0x01	; 1
    2c08:	80 93 32 06 	sts	0x0632, r24	; 0x800632 <sys+0x1>
    2c0c:	a4 96       	adiw	r28, 0x24	; 36
    2c0e:	0f b6       	in	r0, 0x3f	; 63
    2c10:	f8 94       	cli
    2c12:	de bf       	out	0x3e, r29	; 62
    2c14:	0f be       	out	0x3f, r0	; 63
    2c16:	cd bf       	out	0x3d, r28	; 61
    2c18:	df 91       	pop	r29
    2c1a:	cf 91       	pop	r28
    2c1c:	1f 91       	pop	r17
    2c1e:	0f 91       	pop	r16
    2c20:	ff 90       	pop	r15
    2c22:	ef 90       	pop	r14
    2c24:	df 90       	pop	r13
    2c26:	cf 90       	pop	r12
    2c28:	bf 90       	pop	r11
    2c2a:	af 90       	pop	r10
    2c2c:	9f 90       	pop	r9
    2c2e:	8f 90       	pop	r8
    2c30:	7f 90       	pop	r7
    2c32:	6f 90       	pop	r6
    2c34:	5f 90       	pop	r5
    2c36:	4f 90       	pop	r4
    2c38:	3f 90       	pop	r3
    2c3a:	2f 90       	pop	r2
    2c3c:	08 95       	ret
    2c3e:	ef e9       	ldi	r30, 0x9F	; 159
    2c40:	ff e0       	ldi	r31, 0x0F	; 15
    2c42:	31 97       	sbiw	r30, 0x01	; 1
    2c44:	f1 f7       	brne	.-4      	; 0x2c42 <protocol_exec_rt_system+0xd8>
    2c46:	00 c0       	rjmp	.+0      	; 0x2c48 <protocol_exec_rt_system+0xde>
    2c48:	00 00       	nop
    2c4a:	bb cf       	rjmp	.-138    	; 0x2bc2 <protocol_exec_rt_system+0x58>
    2c4c:	10 ff       	sbrs	r17, 0
    2c4e:	cd c0       	rjmp	.+410    	; 0x2dea <protocol_exec_rt_system+0x280>
    2c50:	8c e0       	ldi	r24, 0x0C	; 12
    2c52:	e8 e1       	ldi	r30, 0x18	; 24
    2c54:	f6 e0       	ldi	r31, 0x06	; 6
    2c56:	de 01       	movw	r26, r28
    2c58:	59 96       	adiw	r26, 0x19	; 25
    2c5a:	01 90       	ld	r0, Z+
    2c5c:	0d 92       	st	X+, r0
    2c5e:	8a 95       	dec	r24
    2c60:	e1 f7       	brne	.-8      	; 0x2c5a <protocol_exec_rt_system+0xf0>
    2c62:	be 01       	movw	r22, r28
    2c64:	67 5e       	subi	r22, 0xE7	; 231
    2c66:	7f 4f       	sbci	r23, 0xFF	; 255
    2c68:	ce 01       	movw	r24, r28
    2c6a:	0d 96       	adiw	r24, 0x0d	; 13
    2c6c:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    2c70:	8c e3       	ldi	r24, 0x3C	; 60
    2c72:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2c76:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2c7a:	88 30       	cpi	r24, 0x08	; 8
    2c7c:	09 f4       	brne	.+2      	; 0x2c80 <protocol_exec_rt_system+0x116>
    2c7e:	2f c1       	rjmp	.+606    	; 0x2ede <protocol_exec_rt_system+0x374>
    2c80:	08 f0       	brcs	.+2      	; 0x2c84 <protocol_exec_rt_system+0x11a>
    2c82:	0a c1       	rjmp	.+532    	; 0x2e98 <protocol_exec_rt_system+0x32e>
    2c84:	81 30       	cpi	r24, 0x01	; 1
    2c86:	09 f4       	brne	.+2      	; 0x2c8a <protocol_exec_rt_system+0x120>
    2c88:	33 c1       	rjmp	.+614    	; 0x2ef0 <protocol_exec_rt_system+0x386>
    2c8a:	08 f4       	brcc	.+2      	; 0x2c8e <protocol_exec_rt_system+0x124>
    2c8c:	23 c1       	rjmp	.+582    	; 0x2ed4 <protocol_exec_rt_system+0x36a>
    2c8e:	82 30       	cpi	r24, 0x02	; 2
    2c90:	09 f4       	brne	.+2      	; 0x2c94 <protocol_exec_rt_system+0x12a>
    2c92:	31 c1       	rjmp	.+610    	; 0x2ef6 <protocol_exec_rt_system+0x38c>
    2c94:	84 30       	cpi	r24, 0x04	; 4
    2c96:	09 f4       	brne	.+2      	; 0x2c9a <protocol_exec_rt_system+0x130>
    2c98:	28 c1       	rjmp	.+592    	; 0x2eea <protocol_exec_rt_system+0x380>
    2c9a:	80 91 76 06 	lds	r24, 0x0676	; 0x800676 <settings+0x34>
    2c9e:	f8 2f       	mov	r31, r24
    2ca0:	f1 70       	andi	r31, 0x01	; 1
    2ca2:	9f 2e       	mov	r9, r31
    2ca4:	80 ff       	sbrs	r24, 0
    2ca6:	3c c1       	rjmp	.+632    	; 0x2f20 <protocol_exec_rt_system+0x3b6>
    2ca8:	80 91 3d 06 	lds	r24, 0x063D	; 0x80063d <sys+0xc>
    2cac:	88 23       	and	r24, r24
    2cae:	09 f4       	brne	.+2      	; 0x2cb2 <protocol_exec_rt_system+0x148>
    2cb0:	37 c1       	rjmp	.+622    	; 0x2f20 <protocol_exec_rt_system+0x3b6>
    2cb2:	82 e9       	ldi	r24, 0x92	; 146
    2cb4:	91 e0       	ldi	r25, 0x01	; 1
    2cb6:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2cba:	ce 01       	movw	r24, r28
    2cbc:	0d 96       	adiw	r24, 0x0d	; 13
    2cbe:	0e 94 7c 07 	call	0xef8	; 0xef8 <report_util_axis_values>
    2cc2:	80 91 76 06 	lds	r24, 0x0676	; 0x800676 <settings+0x34>
    2cc6:	81 ff       	sbrs	r24, 1
    2cc8:	1d c0       	rjmp	.+58     	; 0x2d04 <protocol_exec_rt_system+0x19a>
    2cca:	86 e8       	ldi	r24, 0x86	; 134
    2ccc:	91 e0       	ldi	r25, 0x01	; 1
    2cce:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2cd2:	90 91 f6 05 	lds	r25, 0x05F6	; 0x8005f6 <block_buffer_head>
    2cd6:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    2cda:	98 17       	cp	r25, r24
    2cdc:	08 f4       	brcc	.+2      	; 0x2ce0 <protocol_exec_rt_system+0x176>
    2cde:	6f c1       	rjmp	.+734    	; 0x2fbe <protocol_exec_rt_system+0x454>
    2ce0:	81 5f       	subi	r24, 0xF1	; 241
    2ce2:	89 1b       	sub	r24, r25
    2ce4:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    2ce8:	8c e2       	ldi	r24, 0x2C	; 44
    2cea:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2cee:	80 91 f1 01 	lds	r24, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    2cf2:	90 91 f0 01 	lds	r25, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    2cf6:	98 17       	cp	r25, r24
    2cf8:	08 f4       	brcc	.+2      	; 0x2cfc <protocol_exec_rt_system+0x192>
    2cfa:	63 c1       	rjmp	.+710    	; 0x2fc2 <protocol_exec_rt_system+0x458>
    2cfc:	80 58       	subi	r24, 0x80	; 128
    2cfe:	89 1b       	sub	r24, r25
    2d00:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    2d04:	81 e8       	ldi	r24, 0x81	; 129
    2d06:	91 e0       	ldi	r25, 0x01	; 1
    2d08:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2d0c:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2d10:	8c 77       	andi	r24, 0x7C	; 124
    2d12:	09 f4       	brne	.+2      	; 0x2d16 <protocol_exec_rt_system+0x1ac>
    2d14:	58 c1       	rjmp	.+688    	; 0x2fc6 <protocol_exec_rt_system+0x45c>
    2d16:	60 91 b8 02 	lds	r22, 0x02B8	; 0x8002b8 <prep+0x17>
    2d1a:	70 91 b9 02 	lds	r23, 0x02B9	; 0x8002b9 <prep+0x18>
    2d1e:	80 91 ba 02 	lds	r24, 0x02BA	; 0x8002ba <prep+0x19>
    2d22:	90 91 bb 02 	lds	r25, 0x02BB	; 0x8002bb <prep+0x1a>
    2d26:	0e 94 60 07 	call	0xec0	; 0xec0 <printFloat_RateValue>
    2d2a:	8c e2       	ldi	r24, 0x2C	; 44
    2d2c:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2d30:	60 91 3e 06 	lds	r22, 0x063E	; 0x80063e <sys+0xd>
    2d34:	70 91 3f 06 	lds	r23, 0x063F	; 0x80063f <sys+0xe>
    2d38:	80 91 40 06 	lds	r24, 0x0640	; 0x800640 <sys+0xf>
    2d3c:	90 91 41 06 	lds	r25, 0x0641	; 0x800641 <sys+0x10>
    2d40:	40 e0       	ldi	r20, 0x00	; 0
    2d42:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printFloat>
    2d46:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    2d4a:	e8 2e       	mov	r14, r24
    2d4c:	0e 94 cb 02 	call	0x596	; 0x596 <system_control_get_state>
    2d50:	f8 2e       	mov	r15, r24
    2d52:	06 b1       	in	r16, 0x06	; 6
    2d54:	00 72       	andi	r16, 0x20	; 32
    2d56:	80 91 17 06 	lds	r24, 0x0617	; 0x800617 <probe_invert_mask>
    2d5a:	08 27       	eor	r16, r24
    2d5c:	8e 2d       	mov	r24, r14
    2d5e:	8f 29       	or	r24, r15
    2d60:	80 2b       	or	r24, r16
    2d62:	59 f1       	breq	.+86     	; 0x2dba <protocol_exec_rt_system+0x250>
    2d64:	8c e7       	ldi	r24, 0x7C	; 124
    2d66:	91 e0       	ldi	r25, 0x01	; 1
    2d68:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2d6c:	00 23       	and	r16, r16
    2d6e:	19 f0       	breq	.+6      	; 0x2d76 <protocol_exec_rt_system+0x20c>
    2d70:	80 e5       	ldi	r24, 0x50	; 80
    2d72:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2d76:	ee 20       	and	r14, r14
    2d78:	79 f0       	breq	.+30     	; 0x2d98 <protocol_exec_rt_system+0x22e>
    2d7a:	e0 fe       	sbrs	r14, 0
    2d7c:	03 c0       	rjmp	.+6      	; 0x2d84 <protocol_exec_rt_system+0x21a>
    2d7e:	88 e5       	ldi	r24, 0x58	; 88
    2d80:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2d84:	e1 fe       	sbrs	r14, 1
    2d86:	03 c0       	rjmp	.+6      	; 0x2d8e <protocol_exec_rt_system+0x224>
    2d88:	89 e5       	ldi	r24, 0x59	; 89
    2d8a:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2d8e:	e2 fe       	sbrs	r14, 2
    2d90:	03 c0       	rjmp	.+6      	; 0x2d98 <protocol_exec_rt_system+0x22e>
    2d92:	8a e5       	ldi	r24, 0x5A	; 90
    2d94:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2d98:	ff 20       	and	r15, r15
    2d9a:	79 f0       	breq	.+30     	; 0x2dba <protocol_exec_rt_system+0x250>
    2d9c:	f0 fe       	sbrs	r15, 0
    2d9e:	03 c0       	rjmp	.+6      	; 0x2da6 <protocol_exec_rt_system+0x23c>
    2da0:	82 e5       	ldi	r24, 0x52	; 82
    2da2:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2da6:	f1 fe       	sbrs	r15, 1
    2da8:	03 c0       	rjmp	.+6      	; 0x2db0 <protocol_exec_rt_system+0x246>
    2daa:	88 e4       	ldi	r24, 0x48	; 72
    2dac:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2db0:	f2 fe       	sbrs	r15, 2
    2db2:	03 c0       	rjmp	.+6      	; 0x2dba <protocol_exec_rt_system+0x250>
    2db4:	83 e5       	ldi	r24, 0x53	; 83
    2db6:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2dba:	80 91 3d 06 	lds	r24, 0x063D	; 0x80063d <sys+0xc>
    2dbe:	88 23       	and	r24, r24
    2dc0:	09 f4       	brne	.+2      	; 0x2dc4 <protocol_exec_rt_system+0x25a>
    2dc2:	05 c1       	rjmp	.+522    	; 0x2fce <protocol_exec_rt_system+0x464>
    2dc4:	81 50       	subi	r24, 0x01	; 1
    2dc6:	80 93 3d 06 	sts	0x063D, r24	; 0x80063d <sys+0xc>
    2dca:	00 91 3c 06 	lds	r16, 0x063C	; 0x80063c <sys+0xb>
    2dce:	00 23       	and	r16, r16
    2dd0:	09 f4       	brne	.+2      	; 0x2dd4 <protocol_exec_rt_system+0x26a>
    2dd2:	16 c1       	rjmp	.+556    	; 0x3000 <protocol_exec_rt_system+0x496>
    2dd4:	01 50       	subi	r16, 0x01	; 1
    2dd6:	00 93 3c 06 	sts	0x063C, r16	; 0x80063c <sys+0xb>
    2dda:	8e e3       	ldi	r24, 0x3E	; 62
    2ddc:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2de0:	0e 94 c8 07 	call	0xf90	; 0xf90 <report_util_line_feed>
    2de4:	81 e0       	ldi	r24, 0x01	; 1
    2de6:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    2dea:	81 2f       	mov	r24, r17
    2dec:	88 7e       	andi	r24, 0xE8	; 232
    2dee:	09 f4       	brne	.+2      	; 0x2df2 <protocol_exec_rt_system+0x288>
    2df0:	61 c1       	rjmp	.+706    	; 0x30b4 <protocol_exec_rt_system+0x54a>
    2df2:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2df6:	98 2f       	mov	r25, r24
    2df8:	93 70       	andi	r25, 0x03	; 3
    2dfa:	09 f0       	breq	.+2      	; 0x2dfe <protocol_exec_rt_system+0x294>
    2dfc:	4a c1       	rjmp	.+660    	; 0x3092 <protocol_exec_rt_system+0x528>
    2dfe:	88 72       	andi	r24, 0x28	; 40
    2e00:	a9 f0       	breq	.+42     	; 0x2e2c <protocol_exec_rt_system+0x2c2>
    2e02:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e06:	80 7c       	andi	r24, 0xC0	; 192
    2e08:	89 f4       	brne	.+34     	; 0x2e2c <protocol_exec_rt_system+0x2c2>
    2e0a:	0e 94 d0 04 	call	0x9a0	; 0x9a0 <st_update_plan_block_parameters>
    2e0e:	82 e0       	ldi	r24, 0x02	; 2
    2e10:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    2e14:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2e18:	80 32       	cpi	r24, 0x20	; 32
    2e1a:	41 f4       	brne	.+16     	; 0x2e2c <protocol_exec_rt_system+0x2c2>
    2e1c:	80 e2       	ldi	r24, 0x20	; 32
    2e1e:	17 fd       	sbrc	r17, 7
    2e20:	0c c0       	rjmp	.+24     	; 0x2e3a <protocol_exec_rt_system+0x2d0>
    2e22:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e26:	80 68       	ori	r24, 0x80	; 128
    2e28:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    2e2c:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2e30:	81 11       	cpse	r24, r1
    2e32:	03 c0       	rjmp	.+6      	; 0x2e3a <protocol_exec_rt_system+0x2d0>
    2e34:	91 e0       	ldi	r25, 0x01	; 1
    2e36:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    2e3a:	16 ff       	sbrs	r17, 6
    2e3c:	07 c0       	rjmp	.+14     	; 0x2e4c <protocol_exec_rt_system+0x2e2>
    2e3e:	85 fd       	sbrc	r24, 5
    2e40:	05 c0       	rjmp	.+10     	; 0x2e4c <protocol_exec_rt_system+0x2e2>
    2e42:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    2e46:	90 64       	ori	r25, 0x40	; 64
    2e48:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    2e4c:	13 ff       	sbrs	r17, 3
    2e4e:	05 c0       	rjmp	.+10     	; 0x2e5a <protocol_exec_rt_system+0x2f0>
    2e50:	80 7e       	andi	r24, 0xE0	; 224
    2e52:	19 f4       	brne	.+6      	; 0x2e5a <protocol_exec_rt_system+0x2f0>
    2e54:	80 e1       	ldi	r24, 0x10	; 16
    2e56:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2e5a:	15 ff       	sbrs	r17, 5
    2e5c:	1a c1       	rjmp	.+564    	; 0x3092 <protocol_exec_rt_system+0x528>
    2e5e:	8a ec       	ldi	r24, 0xCA	; 202
    2e60:	92 e0       	ldi	r25, 0x02	; 2
    2e62:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2e66:	86 e7       	ldi	r24, 0x76	; 118
    2e68:	92 e0       	ldi	r25, 0x02	; 2
    2e6a:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2e6e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    2e72:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e76:	87 fd       	sbrc	r24, 7
    2e78:	07 c1       	rjmp	.+526    	; 0x3088 <protocol_exec_rt_system+0x51e>
    2e7a:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    2e7e:	90 34       	cpi	r25, 0x40	; 64
    2e80:	09 f0       	breq	.+2      	; 0x2e84 <protocol_exec_rt_system+0x31a>
    2e82:	ff c0       	rjmp	.+510    	; 0x3082 <protocol_exec_rt_system+0x518>
    2e84:	83 ff       	sbrs	r24, 3
    2e86:	04 c0       	rjmp	.+8      	; 0x2e90 <protocol_exec_rt_system+0x326>
    2e88:	83 7e       	andi	r24, 0xE3	; 227
    2e8a:	82 60       	ori	r24, 0x02	; 2
    2e8c:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    2e90:	80 e4       	ldi	r24, 0x40	; 64
    2e92:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2e96:	f8 c0       	rjmp	.+496    	; 0x3088 <protocol_exec_rt_system+0x51e>
    2e98:	80 32       	cpi	r24, 0x20	; 32
    2e9a:	21 f1       	breq	.+72     	; 0x2ee4 <protocol_exec_rt_system+0x37a>
    2e9c:	98 f4       	brcc	.+38     	; 0x2ec4 <protocol_exec_rt_system+0x35a>
    2e9e:	80 31       	cpi	r24, 0x10	; 16
    2ea0:	09 f0       	breq	.+2      	; 0x2ea4 <protocol_exec_rt_system+0x33a>
    2ea2:	fb ce       	rjmp	.-522    	; 0x2c9a <protocol_exec_rt_system+0x130>
    2ea4:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2ea8:	87 fd       	sbrc	r24, 7
    2eaa:	1c c0       	rjmp	.+56     	; 0x2ee4 <protocol_exec_rt_system+0x37a>
    2eac:	8a eb       	ldi	r24, 0xBA	; 186
    2eae:	91 e0       	ldi	r25, 0x01	; 1
    2eb0:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2eb4:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2eb8:	80 ff       	sbrs	r24, 0
    2eba:	2e c0       	rjmp	.+92     	; 0x2f18 <protocol_exec_rt_system+0x3ae>
    2ebc:	80 e3       	ldi	r24, 0x30	; 48
    2ebe:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    2ec2:	eb ce       	rjmp	.-554    	; 0x2c9a <protocol_exec_rt_system+0x130>
    2ec4:	80 34       	cpi	r24, 0x40	; 64
    2ec6:	d1 f0       	breq	.+52     	; 0x2efc <protocol_exec_rt_system+0x392>
    2ec8:	80 38       	cpi	r24, 0x80	; 128
    2eca:	09 f0       	breq	.+2      	; 0x2ece <protocol_exec_rt_system+0x364>
    2ecc:	e6 ce       	rjmp	.-564    	; 0x2c9a <protocol_exec_rt_system+0x130>
    2ece:	89 e9       	ldi	r24, 0x99	; 153
    2ed0:	91 e0       	ldi	r25, 0x01	; 1
    2ed2:	02 c0       	rjmp	.+4      	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2ed4:	84 ec       	ldi	r24, 0xC4	; 196
    2ed6:	91 e0       	ldi	r25, 0x01	; 1
    2ed8:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2edc:	de ce       	rjmp	.-580    	; 0x2c9a <protocol_exec_rt_system+0x130>
    2ede:	80 ec       	ldi	r24, 0xC0	; 192
    2ee0:	91 e0       	ldi	r25, 0x01	; 1
    2ee2:	fa cf       	rjmp	.-12     	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2ee4:	86 eb       	ldi	r24, 0xB6	; 182
    2ee6:	91 e0       	ldi	r25, 0x01	; 1
    2ee8:	f7 cf       	rjmp	.-18     	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2eea:	81 eb       	ldi	r24, 0xB1	; 177
    2eec:	91 e0       	ldi	r25, 0x01	; 1
    2eee:	f4 cf       	rjmp	.-24     	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2ef0:	8b ea       	ldi	r24, 0xAB	; 171
    2ef2:	91 e0       	ldi	r25, 0x01	; 1
    2ef4:	f1 cf       	rjmp	.-30     	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2ef6:	85 ea       	ldi	r24, 0xA5	; 165
    2ef8:	91 e0       	ldi	r25, 0x01	; 1
    2efa:	ee cf       	rjmp	.-36     	; 0x2ed8 <protocol_exec_rt_system+0x36e>
    2efc:	8f e9       	ldi	r24, 0x9F	; 159
    2efe:	91 e0       	ldi	r25, 0x01	; 1
    2f00:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2f04:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2f08:	83 ff       	sbrs	r24, 3
    2f0a:	02 c0       	rjmp	.+4      	; 0x2f10 <protocol_exec_rt_system+0x3a6>
    2f0c:	83 e3       	ldi	r24, 0x33	; 51
    2f0e:	d7 cf       	rjmp	.-82     	; 0x2ebe <protocol_exec_rt_system+0x354>
    2f10:	82 ff       	sbrs	r24, 2
    2f12:	04 c0       	rjmp	.+8      	; 0x2f1c <protocol_exec_rt_system+0x3b2>
    2f14:	85 ff       	sbrs	r24, 5
    2f16:	d2 cf       	rjmp	.-92     	; 0x2ebc <protocol_exec_rt_system+0x352>
    2f18:	81 e3       	ldi	r24, 0x31	; 49
    2f1a:	d1 cf       	rjmp	.-94     	; 0x2ebe <protocol_exec_rt_system+0x354>
    2f1c:	82 e3       	ldi	r24, 0x32	; 50
    2f1e:	cf cf       	rjmp	.-98     	; 0x2ebe <protocol_exec_rt_system+0x354>
    2f20:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    2f24:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    2f28:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    2f2c:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    2f30:	6b eb       	ldi	r22, 0xBB	; 187
    2f32:	a6 2e       	mov	r10, r22
    2f34:	66 e0       	ldi	r22, 0x06	; 6
    2f36:	b6 2e       	mov	r11, r22
    2f38:	9e 01       	movw	r18, r28
    2f3a:	2f 5f       	subi	r18, 0xFF	; 255
    2f3c:	3f 4f       	sbci	r19, 0xFF	; 255
    2f3e:	69 01       	movw	r12, r18
    2f40:	ce 01       	movw	r24, r28
    2f42:	0d 96       	adiw	r24, 0x0d	; 13
    2f44:	7c 01       	movw	r14, r24
    2f46:	00 e0       	ldi	r16, 0x00	; 0
    2f48:	f5 01       	movw	r30, r10
    2f4a:	61 91       	ld	r22, Z+
    2f4c:	71 91       	ld	r23, Z+
    2f4e:	81 91       	ld	r24, Z+
    2f50:	91 91       	ld	r25, Z+
    2f52:	5f 01       	movw	r10, r30
    2f54:	20 85       	ldd	r18, Z+8	; 0x08
    2f56:	31 85       	ldd	r19, Z+9	; 0x09
    2f58:	42 85       	ldd	r20, Z+10	; 0x0a
    2f5a:	53 85       	ldd	r21, Z+11	; 0x0b
    2f5c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2f60:	f6 01       	movw	r30, r12
    2f62:	61 93       	st	Z+, r22
    2f64:	71 93       	st	Z+, r23
    2f66:	81 93       	st	Z+, r24
    2f68:	91 93       	st	Z+, r25
    2f6a:	6f 01       	movw	r12, r30
    2f6c:	02 30       	cpi	r16, 0x02	; 2
    2f6e:	41 f4       	brne	.+16     	; 0x2f80 <protocol_exec_rt_system+0x416>
    2f70:	a3 01       	movw	r20, r6
    2f72:	92 01       	movw	r18, r4
    2f74:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    2f78:	69 87       	std	Y+9, r22	; 0x09
    2f7a:	7a 87       	std	Y+10, r23	; 0x0a
    2f7c:	8b 87       	std	Y+11, r24	; 0x0b
    2f7e:	9c 87       	std	Y+12, r25	; 0x0c
    2f80:	91 10       	cpse	r9, r1
    2f82:	12 c0       	rjmp	.+36     	; 0x2fa8 <protocol_exec_rt_system+0x43e>
    2f84:	f6 01       	movw	r30, r12
    2f86:	34 97       	sbiw	r30, 0x04	; 4
    2f88:	20 81       	ld	r18, Z
    2f8a:	31 81       	ldd	r19, Z+1	; 0x01
    2f8c:	42 81       	ldd	r20, Z+2	; 0x02
    2f8e:	53 81       	ldd	r21, Z+3	; 0x03
    2f90:	f7 01       	movw	r30, r14
    2f92:	60 81       	ld	r22, Z
    2f94:	71 81       	ldd	r23, Z+1	; 0x01
    2f96:	82 81       	ldd	r24, Z+2	; 0x02
    2f98:	93 81       	ldd	r25, Z+3	; 0x03
    2f9a:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    2f9e:	f7 01       	movw	r30, r14
    2fa0:	60 83       	st	Z, r22
    2fa2:	71 83       	std	Z+1, r23	; 0x01
    2fa4:	82 83       	std	Z+2, r24	; 0x02
    2fa6:	93 83       	std	Z+3, r25	; 0x03
    2fa8:	0f 5f       	subi	r16, 0xFF	; 255
    2faa:	f4 e0       	ldi	r31, 0x04	; 4
    2fac:	ef 0e       	add	r14, r31
    2fae:	f1 1c       	adc	r15, r1
    2fb0:	03 30       	cpi	r16, 0x03	; 3
    2fb2:	51 f6       	brne	.-108    	; 0x2f48 <protocol_exec_rt_system+0x3de>
    2fb4:	91 10       	cpse	r9, r1
    2fb6:	7d ce       	rjmp	.-774    	; 0x2cb2 <protocol_exec_rt_system+0x148>
    2fb8:	8b e8       	ldi	r24, 0x8B	; 139
    2fba:	91 e0       	ldi	r25, 0x01	; 1
    2fbc:	7c ce       	rjmp	.-776    	; 0x2cb6 <protocol_exec_rt_system+0x14c>
    2fbe:	81 50       	subi	r24, 0x01	; 1
    2fc0:	90 ce       	rjmp	.-736    	; 0x2ce2 <protocol_exec_rt_system+0x178>
    2fc2:	81 50       	subi	r24, 0x01	; 1
    2fc4:	9c ce       	rjmp	.-712    	; 0x2cfe <protocol_exec_rt_system+0x194>
    2fc6:	60 e0       	ldi	r22, 0x00	; 0
    2fc8:	70 e0       	ldi	r23, 0x00	; 0
    2fca:	cb 01       	movw	r24, r22
    2fcc:	ac ce       	rjmp	.-680    	; 0x2d26 <protocol_exec_rt_system+0x1bc>
    2fce:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2fd2:	8c 77       	andi	r24, 0x7C	; 124
    2fd4:	99 f0       	breq	.+38     	; 0x2ffc <protocol_exec_rt_system+0x492>
    2fd6:	8d e1       	ldi	r24, 0x1D	; 29
    2fd8:	80 93 3d 06 	sts	0x063D, r24	; 0x80063d <sys+0xc>
    2fdc:	80 91 3c 06 	lds	r24, 0x063C	; 0x80063c <sys+0xb>
    2fe0:	81 11       	cpse	r24, r1
    2fe2:	03 c0       	rjmp	.+6      	; 0x2fea <protocol_exec_rt_system+0x480>
    2fe4:	81 e0       	ldi	r24, 0x01	; 1
    2fe6:	80 93 3c 06 	sts	0x063C, r24	; 0x80063c <sys+0xb>
    2fea:	86 e7       	ldi	r24, 0x76	; 118
    2fec:	91 e0       	ldi	r25, 0x01	; 1
    2fee:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    2ff2:	ce 01       	movw	r24, r28
    2ff4:	01 96       	adiw	r24, 0x01	; 1
    2ff6:	0e 94 7c 07 	call	0xef8	; 0xef8 <report_util_axis_values>
    2ffa:	e7 ce       	rjmp	.-562    	; 0x2dca <protocol_exec_rt_system+0x260>
    2ffc:	89 e0       	ldi	r24, 0x09	; 9
    2ffe:	ec cf       	rjmp	.-40     	; 0x2fd8 <protocol_exec_rt_system+0x46e>
    3000:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3004:	8c 77       	andi	r24, 0x7C	; 124
    3006:	c1 f1       	breq	.+112    	; 0x3078 <protocol_exec_rt_system+0x50e>
    3008:	83 e1       	ldi	r24, 0x13	; 19
    300a:	80 93 3c 06 	sts	0x063C, r24	; 0x80063c <sys+0xb>
    300e:	81 e7       	ldi	r24, 0x71	; 113
    3010:	91 e0       	ldi	r25, 0x01	; 1
    3012:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    3016:	80 91 38 06 	lds	r24, 0x0638	; 0x800638 <sys+0x7>
    301a:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    301e:	8c e2       	ldi	r24, 0x2C	; 44
    3020:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    3024:	80 91 39 06 	lds	r24, 0x0639	; 0x800639 <sys+0x8>
    3028:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    302c:	8c e2       	ldi	r24, 0x2C	; 44
    302e:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    3032:	80 91 3a 06 	lds	r24, 0x063A	; 0x80063a <sys+0x9>
    3036:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    303a:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    303e:	f1 2c       	mov	r15, r1
    3040:	87 ff       	sbrs	r24, 7
    3042:	04 c0       	rjmp	.+8      	; 0x304c <protocol_exec_rt_system+0x4e2>
    3044:	2d 9b       	sbis	0x05, 5	; 5
    3046:	1a c0       	rjmp	.+52     	; 0x307c <protocol_exec_rt_system+0x512>
    3048:	52 e0       	ldi	r21, 0x02	; 2
    304a:	f5 2e       	mov	r15, r21
    304c:	43 9b       	sbis	0x08, 3	; 8
    304e:	cd c1       	rjmp	.+922    	; 0x33ea <protocol_exec_rt_system+0x880>
    3050:	00 e4       	ldi	r16, 0x40	; 64
    3052:	8d e6       	ldi	r24, 0x6D	; 109
    3054:	91 e0       	ldi	r25, 0x01	; 1
    3056:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    305a:	ff 20       	and	r15, r15
    305c:	31 f0       	breq	.+12     	; 0x306a <protocol_exec_rt_system+0x500>
    305e:	21 e0       	ldi	r18, 0x01	; 1
    3060:	83 e5       	ldi	r24, 0x53	; 83
    3062:	f2 12       	cpse	r15, r18
    3064:	83 e4       	ldi	r24, 0x43	; 67
    3066:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    306a:	00 23       	and	r16, r16
    306c:	09 f4       	brne	.+2      	; 0x3070 <protocol_exec_rt_system+0x506>
    306e:	b5 ce       	rjmp	.-662    	; 0x2dda <protocol_exec_rt_system+0x270>
    3070:	86 e4       	ldi	r24, 0x46	; 70
    3072:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    3076:	b1 ce       	rjmp	.-670    	; 0x2dda <protocol_exec_rt_system+0x270>
    3078:	89 e0       	ldi	r24, 0x09	; 9
    307a:	c7 cf       	rjmp	.-114    	; 0x300a <protocol_exec_rt_system+0x4a0>
    307c:	ff 24       	eor	r15, r15
    307e:	f3 94       	inc	r15
    3080:	e5 cf       	rjmp	.-54     	; 0x304c <protocol_exec_rt_system+0x4e2>
    3082:	90 38       	cpi	r25, 0x80	; 128
    3084:	09 f0       	breq	.+2      	; 0x3088 <protocol_exec_rt_system+0x51e>
    3086:	04 cf       	rjmp	.-504    	; 0x2e90 <protocol_exec_rt_system+0x326>
    3088:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    308c:	80 62       	ori	r24, 0x20	; 32
    308e:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3092:	17 ff       	sbrs	r17, 7
    3094:	0c c0       	rjmp	.+24     	; 0x30ae <protocol_exec_rt_system+0x544>
    3096:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    309a:	81 30       	cpi	r24, 0x01	; 1
    309c:	29 f4       	brne	.+10     	; 0x30a8 <protocol_exec_rt_system+0x53e>
    309e:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    30a2:	85 60       	ori	r24, 0x05	; 5
    30a4:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    30a8:	80 e8       	ldi	r24, 0x80	; 128
    30aa:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    30ae:	88 ee       	ldi	r24, 0xE8	; 232
    30b0:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    30b4:	11 ff       	sbrs	r17, 1
    30b6:	28 c0       	rjmp	.+80     	; 0x3108 <protocol_exec_rt_system+0x59e>
    30b8:	81 2f       	mov	r24, r17
    30ba:	88 76       	andi	r24, 0x68	; 104
    30bc:	11 f5       	brne	.+68     	; 0x3102 <protocol_exec_rt_system+0x598>
    30be:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    30c2:	80 34       	cpi	r24, 0x40	; 64
    30c4:	41 f4       	brne	.+16     	; 0x30d6 <protocol_exec_rt_system+0x56c>
    30c6:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    30ca:	85 fd       	sbrc	r24, 5
    30cc:	04 c0       	rjmp	.+8      	; 0x30d6 <protocol_exec_rt_system+0x56c>
    30ce:	84 ff       	sbrs	r24, 4
    30d0:	ea c0       	rjmp	.+468    	; 0x32a6 <protocol_exec_rt_system+0x73c>
    30d2:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    30d6:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    30da:	88 23       	and	r24, r24
    30dc:	09 f4       	brne	.+2      	; 0x30e0 <protocol_exec_rt_system+0x576>
    30de:	e9 c0       	rjmp	.+466    	; 0x32b2 <protocol_exec_rt_system+0x748>
    30e0:	84 ff       	sbrs	r24, 4
    30e2:	0f c0       	rjmp	.+30     	; 0x3102 <protocol_exec_rt_system+0x598>
    30e4:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    30e8:	90 ff       	sbrs	r25, 0
    30ea:	0b c0       	rjmp	.+22     	; 0x3102 <protocol_exec_rt_system+0x598>
    30ec:	80 31       	cpi	r24, 0x10	; 16
    30ee:	09 f0       	breq	.+2      	; 0x30f2 <protocol_exec_rt_system+0x588>
    30f0:	e0 c0       	rjmp	.+448    	; 0x32b2 <protocol_exec_rt_system+0x748>
    30f2:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    30f6:	88 23       	and	r24, r24
    30f8:	09 f4       	brne	.+2      	; 0x30fc <protocol_exec_rt_system+0x592>
    30fa:	db c0       	rjmp	.+438    	; 0x32b2 <protocol_exec_rt_system+0x748>
    30fc:	88 60       	ori	r24, 0x08	; 8
    30fe:	80 93 3b 06 	sts	0x063B, r24	; 0x80063b <sys+0xa>
    3102:	82 e0       	ldi	r24, 0x02	; 2
    3104:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    3108:	12 ff       	sbrs	r17, 2
    310a:	24 c0       	rjmp	.+72     	; 0x3154 <protocol_exec_rt_system+0x5ea>
    310c:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    3110:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3114:	80 7d       	andi	r24, 0xD0	; 208
    3116:	09 f4       	brne	.+2      	; 0x311a <protocol_exec_rt_system+0x5b0>
    3118:	e5 c0       	rjmp	.+458    	; 0x32e4 <protocol_exec_rt_system+0x77a>
    311a:	80 91 34 06 	lds	r24, 0x0634	; 0x800634 <sys+0x3>
    311e:	81 11       	cpse	r24, r1
    3120:	e1 c0       	rjmp	.+450    	; 0x32e4 <protocol_exec_rt_system+0x77a>
    3122:	97 fd       	sbrc	r25, 7
    3124:	e1 c0       	rjmp	.+450    	; 0x32e8 <protocol_exec_rt_system+0x77e>
    3126:	0e 94 d0 04 	call	0x9a0	; 0x9a0 <st_update_plan_block_parameters>
    312a:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    312e:	80 93 d3 02 	sts	0x02D3, r24	; 0x8002d3 <block_buffer_planned>
    3132:	0e 94 f4 04 	call	0x9e8	; 0x9e8 <planner_recalculate>
    3136:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    313a:	81 ff       	sbrs	r24, 1
    313c:	05 c0       	rjmp	.+10     	; 0x3148 <protocol_exec_rt_system+0x5de>
    313e:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    3142:	91 60       	ori	r25, 0x01	; 1
    3144:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    3148:	89 7f       	andi	r24, 0xF9	; 249
    314a:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    314e:	84 e0       	ldi	r24, 0x04	; 4
    3150:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    3154:	90 91 15 06 	lds	r25, 0x0615	; 0x800615 <sys_rt_exec_motion_override>
    3158:	99 23       	and	r25, r25
    315a:	09 f4       	brne	.+2      	; 0x315e <protocol_exec_rt_system+0x5f4>
    315c:	4c c0       	rjmp	.+152    	; 0x31f6 <protocol_exec_rt_system+0x68c>
    315e:	8f b7       	in	r24, 0x3f	; 63
    3160:	f8 94       	cli
    3162:	10 92 15 06 	sts	0x0615, r1	; 0x800615 <sys_rt_exec_motion_override>
    3166:	8f bf       	out	0x3f, r24	; 63
    3168:	40 91 38 06 	lds	r20, 0x0638	; 0x800638 <sys+0x7>
    316c:	84 2f       	mov	r24, r20
    316e:	90 fd       	sbrc	r25, 0
    3170:	84 e6       	ldi	r24, 0x64	; 100
    3172:	91 fd       	sbrc	r25, 1
    3174:	86 5f       	subi	r24, 0xF6	; 246
    3176:	92 fd       	sbrc	r25, 2
    3178:	8a 50       	subi	r24, 0x0A	; 10
    317a:	93 fd       	sbrc	r25, 3
    317c:	8f 5f       	subi	r24, 0xFF	; 255
    317e:	94 fd       	sbrc	r25, 4
    3180:	81 50       	subi	r24, 0x01	; 1
    3182:	89 3c       	cpi	r24, 0xC9	; 201
    3184:	08 f0       	brcs	.+2      	; 0x3188 <protocol_exec_rt_system+0x61e>
    3186:	88 ec       	ldi	r24, 0xC8	; 200
    3188:	8a 30       	cpi	r24, 0x0A	; 10
    318a:	08 f4       	brcc	.+2      	; 0x318e <protocol_exec_rt_system+0x624>
    318c:	8a e0       	ldi	r24, 0x0A	; 10
    318e:	30 91 39 06 	lds	r19, 0x0639	; 0x800639 <sys+0x8>
    3192:	23 2f       	mov	r18, r19
    3194:	95 fd       	sbrc	r25, 5
    3196:	24 e6       	ldi	r18, 0x64	; 100
    3198:	96 fd       	sbrc	r25, 6
    319a:	22 e3       	ldi	r18, 0x32	; 50
    319c:	97 fd       	sbrc	r25, 7
    319e:	29 e1       	ldi	r18, 0x19	; 25
    31a0:	48 13       	cpse	r20, r24
    31a2:	02 c0       	rjmp	.+4      	; 0x31a8 <protocol_exec_rt_system+0x63e>
    31a4:	23 17       	cp	r18, r19
    31a6:	39 f1       	breq	.+78     	; 0x31f6 <protocol_exec_rt_system+0x68c>
    31a8:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    31ac:	20 93 39 06 	sts	0x0639, r18	; 0x800639 <sys+0x8>
    31b0:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    31b4:	70 90 d5 02 	lds	r7, 0x02D5	; 0x8002d5 <block_buffer_tail>
    31b8:	60 90 f6 05 	lds	r6, 0x05F6	; 0x8005f6 <block_buffer_head>
    31bc:	17 2d       	mov	r17, r7
    31be:	89 e9       	ldi	r24, 0x99	; 153
    31c0:	28 2e       	mov	r2, r24
    31c2:	96 e7       	ldi	r25, 0x76	; 118
    31c4:	39 2e       	mov	r3, r25
    31c6:	26 e9       	ldi	r18, 0x96	; 150
    31c8:	42 2e       	mov	r4, r18
    31ca:	3e e7       	ldi	r19, 0x7E	; 126
    31cc:	53 2e       	mov	r5, r19
    31ce:	42 e3       	ldi	r20, 0x32	; 50
    31d0:	84 2e       	mov	r8, r20
    31d2:	16 11       	cpse	r17, r6
    31d4:	a4 c0       	rjmp	.+328    	; 0x331e <protocol_exec_rt_system+0x7b4>
    31d6:	c1 01       	movw	r24, r2
    31d8:	d2 01       	movw	r26, r4
    31da:	80 93 0f 06 	sts	0x060F, r24	; 0x80060f <pl+0x18>
    31de:	90 93 10 06 	sts	0x0610, r25	; 0x800610 <pl+0x19>
    31e2:	a0 93 11 06 	sts	0x0611, r26	; 0x800611 <pl+0x1a>
    31e6:	b0 93 12 06 	sts	0x0612, r27	; 0x800612 <pl+0x1b>
    31ea:	0e 94 d0 04 	call	0x9a0	; 0x9a0 <st_update_plan_block_parameters>
    31ee:	70 92 d3 02 	sts	0x02D3, r7	; 0x8002d3 <block_buffer_planned>
    31f2:	0e 94 f4 04 	call	0x9e8	; 0x9e8 <planner_recalculate>
    31f6:	10 91 16 06 	lds	r17, 0x0616	; 0x800616 <sys_rt_exec_accessory_override>
    31fa:	11 23       	and	r17, r17
    31fc:	09 f4       	brne	.+2      	; 0x3200 <protocol_exec_rt_system+0x696>
    31fe:	4b c0       	rjmp	.+150    	; 0x3296 <protocol_exec_rt_system+0x72c>
    3200:	8f b7       	in	r24, 0x3f	; 63
    3202:	f8 94       	cli
    3204:	10 92 16 06 	sts	0x0616, r1	; 0x800616 <sys_rt_exec_accessory_override>
    3208:	8f bf       	out	0x3f, r24	; 63
    320a:	90 91 3a 06 	lds	r25, 0x063A	; 0x80063a <sys+0x9>
    320e:	89 2f       	mov	r24, r25
    3210:	10 fd       	sbrc	r17, 0
    3212:	84 e6       	ldi	r24, 0x64	; 100
    3214:	11 fd       	sbrc	r17, 1
    3216:	86 5f       	subi	r24, 0xF6	; 246
    3218:	12 fd       	sbrc	r17, 2
    321a:	8a 50       	subi	r24, 0x0A	; 10
    321c:	13 fd       	sbrc	r17, 3
    321e:	8f 5f       	subi	r24, 0xFF	; 255
    3220:	14 fd       	sbrc	r17, 4
    3222:	81 50       	subi	r24, 0x01	; 1
    3224:	89 3c       	cpi	r24, 0xC9	; 201
    3226:	08 f0       	brcs	.+2      	; 0x322a <protocol_exec_rt_system+0x6c0>
    3228:	88 ec       	ldi	r24, 0xC8	; 200
    322a:	8a 30       	cpi	r24, 0x0A	; 10
    322c:	08 f4       	brcc	.+2      	; 0x3230 <protocol_exec_rt_system+0x6c6>
    322e:	8a e0       	ldi	r24, 0x0A	; 10
    3230:	98 17       	cp	r25, r24
    3232:	a1 f0       	breq	.+40     	; 0x325c <protocol_exec_rt_system+0x6f2>
    3234:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    3238:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    323c:	91 11       	cpse	r25, r1
    323e:	c9 c0       	rjmp	.+402    	; 0x33d2 <protocol_exec_rt_system+0x868>
    3240:	40 91 a2 06 	lds	r20, 0x06A2	; 0x8006a2 <gc_state+0xb>
    3244:	50 91 a3 06 	lds	r21, 0x06A3	; 0x8006a3 <gc_state+0xc>
    3248:	60 91 a4 06 	lds	r22, 0x06A4	; 0x8006a4 <gc_state+0xd>
    324c:	70 91 a5 06 	lds	r23, 0x06A5	; 0x8006a5 <gc_state+0xe>
    3250:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3254:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    3258:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    325c:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3260:	15 ff       	sbrs	r17, 5
    3262:	09 c0       	rjmp	.+18     	; 0x3276 <protocol_exec_rt_system+0x70c>
    3264:	80 31       	cpi	r24, 0x10	; 16
    3266:	39 f4       	brne	.+14     	; 0x3276 <protocol_exec_rt_system+0x70c>
    3268:	90 91 3b 06 	lds	r25, 0x063B	; 0x80063b <sys+0xa>
    326c:	91 11       	cpse	r25, r1
    326e:	b7 c0       	rjmp	.+366    	; 0x33de <protocol_exec_rt_system+0x874>
    3270:	92 e0       	ldi	r25, 0x02	; 2
    3272:	90 93 3b 06 	sts	0x063B, r25	; 0x80063b <sys+0xa>
    3276:	10 7c       	andi	r17, 0xC0	; 192
    3278:	71 f0       	breq	.+28     	; 0x3296 <protocol_exec_rt_system+0x72c>
    327a:	88 23       	and	r24, r24
    327c:	11 f0       	breq	.+4      	; 0x3282 <protocol_exec_rt_system+0x718>
    327e:	88 73       	andi	r24, 0x38	; 56
    3280:	51 f0       	breq	.+20     	; 0x3296 <protocol_exec_rt_system+0x72c>
    3282:	10 91 9f 06 	lds	r17, 0x069F	; 0x80069f <gc_state+0x8>
    3286:	16 ff       	sbrs	r17, 6
    3288:	ae c0       	rjmp	.+348    	; 0x33e6 <protocol_exec_rt_system+0x87c>
    328a:	1f 7b       	andi	r17, 0xBF	; 191
    328c:	81 2f       	mov	r24, r17
    328e:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    3292:	10 93 9f 06 	sts	0x069F, r17	; 0x80069f <gc_state+0x8>
    3296:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    329a:	8c 7f       	andi	r24, 0xFC	; 252
    329c:	09 f4       	brne	.+2      	; 0x32a0 <protocol_exec_rt_system+0x736>
    329e:	b6 cc       	rjmp	.-1684   	; 0x2c0c <protocol_exec_rt_system+0xa2>
    32a0:	0e 94 26 0e 	call	0x1c4c	; 0x1c4c <st_prep_buffer>
    32a4:	b3 cc       	rjmp	.-1690   	; 0x2c0c <protocol_exec_rt_system+0xa2>
    32a6:	82 ff       	sbrs	r24, 2
    32a8:	16 cf       	rjmp	.-468    	; 0x30d6 <protocol_exec_rt_system+0x56c>
    32aa:	88 60       	ori	r24, 0x08	; 8
    32ac:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    32b0:	12 cf       	rjmp	.-476    	; 0x30d6 <protocol_exec_rt_system+0x56c>
    32b2:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    32b6:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
    32ba:	89 2b       	or	r24, r25
    32bc:	71 f0       	breq	.+28     	; 0x32da <protocol_exec_rt_system+0x770>
    32be:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    32c2:	86 fd       	sbrc	r24, 6
    32c4:	0a c0       	rjmp	.+20     	; 0x32da <protocol_exec_rt_system+0x770>
    32c6:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    32ca:	88 e0       	ldi	r24, 0x08	; 8
    32cc:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    32d0:	0e 94 26 0e 	call	0x1c4c	; 0x1c4c <st_prep_buffer>
    32d4:	0e 94 6c 06 	call	0xcd8	; 0xcd8 <st_wake_up>
    32d8:	14 cf       	rjmp	.-472    	; 0x3102 <protocol_exec_rt_system+0x598>
    32da:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    32de:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    32e2:	0f cf       	rjmp	.-482    	; 0x3102 <protocol_exec_rt_system+0x598>
    32e4:	97 ff       	sbrs	r25, 7
    32e6:	0a c0       	rjmp	.+20     	; 0x32fc <protocol_exec_rt_system+0x792>
    32e8:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    32ec:	0e 94 a2 09 	call	0x1344	; 0x1344 <plan_reset>
    32f0:	0e 94 cf 0d 	call	0x1b9e	; 0x1b9e <st_reset>
    32f4:	0e 94 9c 09 	call	0x1338	; 0x1338 <gc_sync_position>
    32f8:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    32fc:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3300:	85 ff       	sbrs	r24, 5
    3302:	08 c0       	rjmp	.+16     	; 0x3314 <protocol_exec_rt_system+0x7aa>
    3304:	8f 77       	andi	r24, 0x7F	; 127
    3306:	81 60       	ori	r24, 0x01	; 1
    3308:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    330c:	80 e4       	ldi	r24, 0x40	; 64
    330e:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    3312:	1d cf       	rjmp	.-454    	; 0x314e <protocol_exec_rt_system+0x5e4>
    3314:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    3318:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    331c:	18 cf       	rjmp	.-464    	; 0x314e <protocol_exec_rt_system+0x5e4>
    331e:	a1 2e       	mov	r10, r17
    3320:	b1 2c       	mov	r11, r1
    3322:	18 9d       	mul	r17, r8
    3324:	c0 01       	movw	r24, r0
    3326:	11 24       	eor	r1, r1
    3328:	8a 52       	subi	r24, 0x2A	; 42
    332a:	9d 4f       	sbci	r25, 0xFD	; 253
    332c:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    3330:	96 2e       	mov	r9, r22
    3332:	c7 2e       	mov	r12, r23
    3334:	d8 2e       	mov	r13, r24
    3336:	09 2f       	mov	r16, r25
    3338:	91 01       	movw	r18, r2
    333a:	a2 01       	movw	r20, r4
    333c:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    3340:	8a 9c       	mul	r8, r10
    3342:	70 01       	movw	r14, r0
    3344:	8b 9c       	mul	r8, r11
    3346:	f0 0c       	add	r15, r0
    3348:	11 24       	eor	r1, r1
    334a:	18 16       	cp	r1, r24
    334c:	ac f5       	brge	.+106    	; 0x33b8 <protocol_exec_rt_system+0x84e>
    334e:	c7 01       	movw	r24, r14
    3350:	8a 52       	subi	r24, 0x2A	; 42
    3352:	9d 4f       	sbci	r25, 0xFD	; 253
    3354:	7c 01       	movw	r14, r24
    3356:	91 01       	movw	r18, r2
    3358:	a2 01       	movw	r20, r4
    335a:	b1 01       	movw	r22, r2
    335c:	c2 01       	movw	r24, r4
    335e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    3362:	f7 01       	movw	r30, r14
    3364:	66 8b       	std	Z+22, r22	; 0x16
    3366:	77 8b       	std	Z+23, r23	; 0x17
    3368:	80 8f       	std	Z+24, r24	; 0x18
    336a:	91 8f       	std	Z+25, r25	; 0x19
    336c:	8a 9c       	mul	r8, r10
    336e:	c0 01       	movw	r24, r0
    3370:	8b 9c       	mul	r8, r11
    3372:	90 0d       	add	r25, r0
    3374:	11 24       	eor	r1, r1
    3376:	9c 01       	movw	r18, r24
    3378:	2a 52       	subi	r18, 0x2A	; 42
    337a:	3d 4f       	sbci	r19, 0xFD	; 253
    337c:	79 01       	movw	r14, r18
    337e:	f9 01       	movw	r30, r18
    3380:	22 a0       	ldd	r2, Z+34	; 0x22
    3382:	33 a0       	ldd	r3, Z+35	; 0x23
    3384:	44 a0       	ldd	r4, Z+36	; 0x24
    3386:	55 a0       	ldd	r5, Z+37	; 0x25
    3388:	a2 01       	movw	r20, r4
    338a:	91 01       	movw	r18, r2
    338c:	66 89       	ldd	r22, Z+22	; 0x16
    338e:	77 89       	ldd	r23, Z+23	; 0x17
    3390:	80 8d       	ldd	r24, Z+24	; 0x18
    3392:	91 8d       	ldd	r25, Z+25	; 0x19
    3394:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    3398:	18 16       	cp	r1, r24
    339a:	2c f4       	brge	.+10     	; 0x33a6 <protocol_exec_rt_system+0x83c>
    339c:	f7 01       	movw	r30, r14
    339e:	26 8a       	std	Z+22, r2	; 0x16
    33a0:	37 8a       	std	Z+23, r3	; 0x17
    33a2:	40 8e       	std	Z+24, r4	; 0x18
    33a4:	51 8e       	std	Z+25, r5	; 0x19
    33a6:	1f 5f       	subi	r17, 0xFF	; 255
    33a8:	10 31       	cpi	r17, 0x10	; 16
    33aa:	09 f4       	brne	.+2      	; 0x33ae <protocol_exec_rt_system+0x844>
    33ac:	10 e0       	ldi	r17, 0x00	; 0
    33ae:	29 2c       	mov	r2, r9
    33b0:	3c 2c       	mov	r3, r12
    33b2:	4d 2c       	mov	r4, r13
    33b4:	50 2e       	mov	r5, r16
    33b6:	0d cf       	rjmp	.-486    	; 0x31d2 <protocol_exec_rt_system+0x668>
    33b8:	97 01       	movw	r18, r14
    33ba:	2a 52       	subi	r18, 0x2A	; 42
    33bc:	3d 4f       	sbci	r19, 0xFD	; 253
    33be:	79 01       	movw	r14, r18
    33c0:	29 2d       	mov	r18, r9
    33c2:	3c 2d       	mov	r19, r12
    33c4:	4d 2d       	mov	r20, r13
    33c6:	50 2f       	mov	r21, r16
    33c8:	69 2d       	mov	r22, r9
    33ca:	7c 2d       	mov	r23, r12
    33cc:	8d 2d       	mov	r24, r13
    33ce:	90 2f       	mov	r25, r16
    33d0:	c6 cf       	rjmp	.-116    	; 0x335e <protocol_exec_rt_system+0x7f4>
    33d2:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    33d6:	88 60       	ori	r24, 0x08	; 8
    33d8:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    33dc:	3d cf       	rjmp	.-390    	; 0x3258 <protocol_exec_rt_system+0x6ee>
    33de:	90 ff       	sbrs	r25, 0
    33e0:	4a cf       	rjmp	.-364    	; 0x3276 <protocol_exec_rt_system+0x70c>
    33e2:	94 60       	ori	r25, 0x04	; 4
    33e4:	46 cf       	rjmp	.-372    	; 0x3272 <protocol_exec_rt_system+0x708>
    33e6:	10 64       	ori	r17, 0x40	; 64
    33e8:	51 cf       	rjmp	.-350    	; 0x328c <protocol_exec_rt_system+0x722>
    33ea:	f1 10       	cpse	r15, r1
    33ec:	32 ce       	rjmp	.-924    	; 0x3052 <protocol_exec_rt_system+0x4e8>
    33ee:	f5 cc       	rjmp	.-1558   	; 0x2dda <protocol_exec_rt_system+0x270>

000033f0 <protocol_execute_realtime>:
    33f0:	cf 92       	push	r12
    33f2:	df 92       	push	r13
    33f4:	ef 92       	push	r14
    33f6:	ff 92       	push	r15
    33f8:	1f 93       	push	r17
    33fa:	cf 93       	push	r28
    33fc:	df 93       	push	r29
    33fe:	0e 94 b5 15 	call	0x2b6a	; 0x2b6a <protocol_exec_rt_system>
    3402:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3406:	88 23       	and	r24, r24
    3408:	09 f4       	brne	.+2      	; 0x340c <protocol_execute_realtime+0x1c>
    340a:	6e c0       	rjmp	.+220    	; 0x34e8 <protocol_execute_realtime+0xf8>
    340c:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
    3410:	00 97       	sbiw	r24, 0x00	; 0
    3412:	09 f0       	breq	.+2      	; 0x3416 <protocol_execute_realtime+0x26>
    3414:	3f c0       	rjmp	.+126    	; 0x3494 <protocol_execute_realtime+0xa4>
    3416:	c0 91 a0 06 	lds	r28, 0x06A0	; 0x8006a0 <gc_state+0x9>
    341a:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    341e:	c8 2b       	or	r28, r24
    3420:	c0 90 a2 06 	lds	r12, 0x06A2	; 0x8006a2 <gc_state+0xb>
    3424:	d0 90 a3 06 	lds	r13, 0x06A3	; 0x8006a3 <gc_state+0xc>
    3428:	e0 90 a4 06 	lds	r14, 0x06A4	; 0x8006a4 <gc_state+0xd>
    342c:	f0 90 a5 06 	lds	r15, 0x06A5	; 0x8006a5 <gc_state+0xe>
    3430:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3434:	81 ff       	sbrs	r24, 1
    3436:	03 c0       	rjmp	.+6      	; 0x343e <protocol_execute_realtime+0x4e>
    3438:	80 e2       	ldi	r24, 0x20	; 32
    343a:	0e 94 29 02 	call	0x452	; 0x452 <system_set_exec_accessory_override_flag>
    343e:	dc 2f       	mov	r29, r28
    3440:	d0 73       	andi	r29, 0x30	; 48
    3442:	11 e0       	ldi	r17, 0x01	; 1
    3444:	c0 7c       	andi	r28, 0xC0	; 192
    3446:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    344a:	88 23       	and	r24, r24
    344c:	09 f4       	brne	.+2      	; 0x3450 <protocol_execute_realtime+0x60>
    344e:	4c c0       	rjmp	.+152    	; 0x34e8 <protocol_execute_realtime+0xf8>
    3450:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    3454:	91 11       	cpse	r25, r1
    3456:	48 c0       	rjmp	.+144    	; 0x34e8 <protocol_execute_realtime+0xf8>
    3458:	80 ff       	sbrs	r24, 0
    345a:	19 c0       	rjmp	.+50     	; 0x348e <protocol_execute_realtime+0x9e>
    345c:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    3460:	29 2f       	mov	r18, r25
    3462:	20 7c       	andi	r18, 0xC0	; 192
    3464:	09 f4       	brne	.+2      	; 0x3468 <protocol_execute_realtime+0x78>
    3466:	8d c0       	rjmp	.+282    	; 0x3582 <protocol_execute_realtime+0x192>
    3468:	82 fd       	sbrc	r24, 2
    346a:	23 c0       	rjmp	.+70     	; 0x34b2 <protocol_execute_realtime+0xc2>
    346c:	10 92 3b 06 	sts	0x063B, r1	; 0x80063b <sys+0xa>
    3470:	40 e0       	ldi	r20, 0x00	; 0
    3472:	50 e0       	ldi	r21, 0x00	; 0
    3474:	ba 01       	movw	r22, r20
    3476:	80 e0       	ldi	r24, 0x00	; 0
    3478:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    347c:	80 e0       	ldi	r24, 0x00	; 0
    347e:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    3482:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3486:	8d 7f       	andi	r24, 0xFD	; 253
    3488:	84 60       	ori	r24, 0x04	; 4
    348a:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    348e:	0e 94 b5 15 	call	0x2b6a	; 0x2b6a <protocol_exec_rt_system>
    3492:	d9 cf       	rjmp	.-78     	; 0x3446 <protocol_execute_realtime+0x56>
    3494:	fc 01       	movw	r30, r24
    3496:	21 89       	ldd	r18, Z+17	; 0x11
    3498:	20 73       	andi	r18, 0x30	; 48
    349a:	43 99       	sbic	0x08, 3	; 8
    349c:	08 c0       	rjmp	.+16     	; 0x34ae <protocol_execute_realtime+0xbe>
    349e:	c0 e0       	ldi	r28, 0x00	; 0
    34a0:	c2 2b       	or	r28, r18
    34a2:	fc 01       	movw	r30, r24
    34a4:	c6 a4       	ldd	r12, Z+46	; 0x2e
    34a6:	d7 a4       	ldd	r13, Z+47	; 0x2f
    34a8:	e0 a8       	ldd	r14, Z+48	; 0x30
    34aa:	f1 a8       	ldd	r15, Z+49	; 0x31
    34ac:	c1 cf       	rjmp	.-126    	; 0x3430 <protocol_execute_realtime+0x40>
    34ae:	c0 e4       	ldi	r28, 0x40	; 64
    34b0:	f7 cf       	rjmp	.-18     	; 0x34a0 <protocol_execute_realtime+0xb0>
    34b2:	90 38       	cpi	r25, 0x80	; 128
    34b4:	21 f5       	brne	.+72     	; 0x34fe <protocol_execute_realtime+0x10e>
    34b6:	8a ec       	ldi	r24, 0xCA	; 202
    34b8:	92 e0       	ldi	r25, 0x02	; 2
    34ba:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    34be:	83 e3       	ldi	r24, 0x33	; 51
    34c0:	92 e0       	ldi	r25, 0x02	; 2
    34c2:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    34c6:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    34ca:	40 e0       	ldi	r20, 0x00	; 0
    34cc:	50 e0       	ldi	r21, 0x00	; 0
    34ce:	ba 01       	movw	r22, r20
    34d0:	80 e0       	ldi	r24, 0x00	; 0
    34d2:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    34d6:	80 e0       	ldi	r24, 0x00	; 0
    34d8:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    34dc:	0e 94 9b 0d 	call	0x1b36	; 0x1b36 <st_go_idle>
    34e0:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    34e4:	88 23       	and	r24, r24
    34e6:	41 f0       	breq	.+16     	; 0x34f8 <protocol_execute_realtime+0x108>
    34e8:	df 91       	pop	r29
    34ea:	cf 91       	pop	r28
    34ec:	1f 91       	pop	r17
    34ee:	ff 90       	pop	r15
    34f0:	ef 90       	pop	r14
    34f2:	df 90       	pop	r13
    34f4:	cf 90       	pop	r12
    34f6:	08 95       	ret
    34f8:	0e 94 b5 15 	call	0x2b6a	; 0x2b6a <protocol_exec_rt_system>
    34fc:	f1 cf       	rjmp	.-30     	; 0x34e0 <protocol_execute_realtime+0xf0>
    34fe:	90 34       	cpi	r25, 0x40	; 64
    3500:	19 f4       	brne	.+6      	; 0x3508 <protocol_execute_realtime+0x118>
    3502:	8f 7d       	andi	r24, 0xDF	; 223
    3504:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3508:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    350c:	83 ff       	sbrs	r24, 3
    350e:	bf cf       	rjmp	.-130    	; 0x348e <protocol_execute_realtime+0x9e>
    3510:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3514:	99 23       	and	r25, r25
    3516:	59 f0       	breq	.+22     	; 0x352e <protocol_execute_realtime+0x13e>
    3518:	81 fd       	sbrc	r24, 1
    351a:	09 c0       	rjmp	.+18     	; 0x352e <protocol_execute_realtime+0x13e>
    351c:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3520:	81 ff       	sbrs	r24, 1
    3522:	22 c0       	rjmp	.+68     	; 0x3568 <protocol_execute_realtime+0x178>
    3524:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    3528:	88 60       	ori	r24, 0x08	; 8
    352a:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    352e:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    3532:	88 23       	and	r24, r24
    3534:	71 f0       	breq	.+28     	; 0x3552 <protocol_execute_realtime+0x162>
    3536:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    353a:	81 fd       	sbrc	r24, 1
    353c:	0a c0       	rjmp	.+20     	; 0x3552 <protocol_execute_realtime+0x162>
    353e:	8c 2f       	mov	r24, r28
    3540:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    3544:	41 e0       	ldi	r20, 0x01	; 1
    3546:	60 e0       	ldi	r22, 0x00	; 0
    3548:	70 e0       	ldi	r23, 0x00	; 0
    354a:	80 e8       	ldi	r24, 0x80	; 128
    354c:	9f e3       	ldi	r25, 0x3F	; 63
    354e:	0e 94 02 1d 	call	0x3a04	; 0x3a04 <delay_sec>
    3552:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3556:	81 fd       	sbrc	r24, 1
    3558:	9a cf       	rjmp	.-204    	; 0x348e <protocol_execute_realtime+0x9e>
    355a:	80 61       	ori	r24, 0x10	; 16
    355c:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3560:	82 e0       	ldi	r24, 0x02	; 2
    3562:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    3566:	93 cf       	rjmp	.-218    	; 0x348e <protocol_execute_realtime+0x9e>
    3568:	b7 01       	movw	r22, r14
    356a:	a6 01       	movw	r20, r12
    356c:	8d 2f       	mov	r24, r29
    356e:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    3572:	41 e0       	ldi	r20, 0x01	; 1
    3574:	60 e0       	ldi	r22, 0x00	; 0
    3576:	70 e0       	ldi	r23, 0x00	; 0
    3578:	80 e8       	ldi	r24, 0x80	; 128
    357a:	90 e4       	ldi	r25, 0x40	; 64
    357c:	0e 94 02 1d 	call	0x3a04	; 0x3a04 <delay_sec>
    3580:	d6 cf       	rjmp	.-84     	; 0x352e <protocol_execute_realtime+0x13e>
    3582:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    3586:	88 23       	and	r24, r24
    3588:	c9 f1       	breq	.+114    	; 0x35fc <protocol_execute_realtime+0x20c>
    358a:	81 ff       	sbrs	r24, 1
    358c:	0d c0       	rjmp	.+26     	; 0x35a8 <protocol_execute_realtime+0x1b8>
    358e:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3592:	88 23       	and	r24, r24
    3594:	51 f1       	breq	.+84     	; 0x35ea <protocol_execute_realtime+0x1fa>
    3596:	40 e0       	ldi	r20, 0x00	; 0
    3598:	50 e0       	ldi	r21, 0x00	; 0
    359a:	ba 01       	movw	r22, r20
    359c:	80 e0       	ldi	r24, 0x00	; 0
    359e:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    35a2:	10 93 3b 06 	sts	0x063B, r17	; 0x80063b <sys+0xa>
    35a6:	73 cf       	rjmp	.-282    	; 0x348e <protocol_execute_realtime+0x9e>
    35a8:	8c 70       	andi	r24, 0x0C	; 12
    35aa:	09 f4       	brne	.+2      	; 0x35ae <protocol_execute_realtime+0x1be>
    35ac:	70 cf       	rjmp	.-288    	; 0x348e <protocol_execute_realtime+0x9e>
    35ae:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    35b2:	88 23       	and	r24, r24
    35b4:	99 f0       	breq	.+38     	; 0x35dc <protocol_execute_realtime+0x1ec>
    35b6:	8a ec       	ldi	r24, 0xCA	; 202
    35b8:	92 e0       	ldi	r25, 0x02	; 2
    35ba:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    35be:	8c e3       	ldi	r24, 0x3C	; 60
    35c0:	92 e0       	ldi	r25, 0x02	; 2
    35c2:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    35c6:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    35ca:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    35ce:	81 ff       	sbrs	r24, 1
    35d0:	0f c0       	rjmp	.+30     	; 0x35f0 <protocol_execute_realtime+0x200>
    35d2:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    35d6:	88 60       	ori	r24, 0x08	; 8
    35d8:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    35dc:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    35e0:	83 ff       	sbrs	r24, 3
    35e2:	03 c0       	rjmp	.+6      	; 0x35ea <protocol_execute_realtime+0x1fa>
    35e4:	82 e0       	ldi	r24, 0x02	; 2
    35e6:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    35ea:	10 92 3b 06 	sts	0x063B, r1	; 0x80063b <sys+0xa>
    35ee:	4f cf       	rjmp	.-354    	; 0x348e <protocol_execute_realtime+0x9e>
    35f0:	b7 01       	movw	r22, r14
    35f2:	a6 01       	movw	r20, r12
    35f4:	8d 2f       	mov	r24, r29
    35f6:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    35fa:	f0 cf       	rjmp	.-32     	; 0x35dc <protocol_execute_realtime+0x1ec>
    35fc:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    3600:	83 ff       	sbrs	r24, 3
    3602:	45 cf       	rjmp	.-374    	; 0x348e <protocol_execute_realtime+0x9e>
    3604:	b7 01       	movw	r22, r14
    3606:	a6 01       	movw	r20, r12
    3608:	8d 2f       	mov	r24, r29
    360a:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    360e:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    3612:	87 7f       	andi	r24, 0xF7	; 247
    3614:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    3618:	3a cf       	rjmp	.-396    	; 0x348e <protocol_execute_realtime+0x9e>

0000361a <limits_go_home>:
    361a:	2f 92       	push	r2
    361c:	3f 92       	push	r3
    361e:	4f 92       	push	r4
    3620:	5f 92       	push	r5
    3622:	6f 92       	push	r6
    3624:	7f 92       	push	r7
    3626:	8f 92       	push	r8
    3628:	9f 92       	push	r9
    362a:	af 92       	push	r10
    362c:	bf 92       	push	r11
    362e:	cf 92       	push	r12
    3630:	df 92       	push	r13
    3632:	ef 92       	push	r14
    3634:	ff 92       	push	r15
    3636:	0f 93       	push	r16
    3638:	1f 93       	push	r17
    363a:	cf 93       	push	r28
    363c:	df 93       	push	r29
    363e:	cd b7       	in	r28, 0x3d	; 61
    3640:	de b7       	in	r29, 0x3e	; 62
    3642:	a2 97       	sbiw	r28, 0x22	; 34
    3644:	0f b6       	in	r0, 0x3f	; 63
    3646:	f8 94       	cli
    3648:	de bf       	out	0x3e, r29	; 62
    364a:	0f be       	out	0x3f, r0	; 63
    364c:	cd bf       	out	0x3d, r28	; 61
    364e:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    3652:	91 11       	cpse	r25, r1
    3654:	1a c1       	rjmp	.+564    	; 0x388a <limits_go_home+0x270>
    3656:	78 2e       	mov	r7, r24
    3658:	9e 01       	movw	r18, r28
    365a:	23 5f       	subi	r18, 0xF3	; 243
    365c:	3f 4f       	sbci	r19, 0xFF	; 255
    365e:	3a 8f       	std	Y+26, r19	; 0x1a
    3660:	29 8f       	std	Y+25, r18	; 0x19
    3662:	89 e0       	ldi	r24, 0x09	; 9
    3664:	d9 01       	movw	r26, r18
    3666:	1d 92       	st	X+, r1
    3668:	8a 95       	dec	r24
    366a:	e9 f7       	brne	.-6      	; 0x3666 <limits_go_home+0x4c>
    366c:	86 e0       	ldi	r24, 0x06	; 6
    366e:	8d 8b       	std	Y+21, r24	; 0x15
    3670:	e2 e4       	ldi	r30, 0x42	; 66
    3672:	f6 e0       	ldi	r31, 0x06	; 6
    3674:	fc 8f       	std	Y+28, r31	; 0x1c
    3676:	eb 8f       	std	Y+27, r30	; 0x1b
    3678:	5f 01       	movw	r10, r30
    367a:	27 5f       	subi	r18, 0xF7	; 247
    367c:	3f 4f       	sbci	r19, 0xFF	; 255
    367e:	49 01       	movw	r8, r18
    3680:	10 e0       	ldi	r17, 0x00	; 0
    3682:	00 e0       	ldi	r16, 0x00	; 0
    3684:	c1 2c       	mov	r12, r1
    3686:	d1 2c       	mov	r13, r1
    3688:	76 01       	movw	r14, r12
    368a:	87 2d       	mov	r24, r7
    368c:	90 e0       	ldi	r25, 0x00	; 0
    368e:	9e 8f       	std	Y+30, r25	; 0x1e
    3690:	8d 8f       	std	Y+29, r24	; 0x1d
    3692:	80 2f       	mov	r24, r16
    3694:	94 e0       	ldi	r25, 0x04	; 4
    3696:	00 23       	and	r16, r16
    3698:	21 f0       	breq	.+8      	; 0x36a2 <limits_go_home+0x88>
    369a:	90 e1       	ldi	r25, 0x10	; 16
    369c:	01 30       	cpi	r16, 0x01	; 1
    369e:	09 f4       	brne	.+2      	; 0x36a2 <limits_go_home+0x88>
    36a0:	98 e0       	ldi	r25, 0x08	; 8
    36a2:	d4 01       	movw	r26, r8
    36a4:	9d 93       	st	X+, r25
    36a6:	4d 01       	movw	r8, r26
    36a8:	ed 8d       	ldd	r30, Y+29	; 0x1d
    36aa:	fe 8d       	ldd	r31, Y+30	; 0x1e
    36ac:	02 c0       	rjmp	.+4      	; 0x36b2 <limits_go_home+0x98>
    36ae:	f5 95       	asr	r31
    36b0:	e7 95       	ror	r30
    36b2:	8a 95       	dec	r24
    36b4:	e2 f7       	brpl	.-8      	; 0x36ae <limits_go_home+0x94>
    36b6:	e0 ff       	sbrs	r30, 0
    36b8:	1f c0       	rjmp	.+62     	; 0x36f8 <limits_go_home+0xde>
    36ba:	20 e0       	ldi	r18, 0x00	; 0
    36bc:	30 e0       	ldi	r19, 0x00	; 0
    36be:	40 ec       	ldi	r20, 0xC0	; 192
    36c0:	5f eb       	ldi	r21, 0xBF	; 191
    36c2:	d5 01       	movw	r26, r10
    36c4:	94 96       	adiw	r26, 0x24	; 36
    36c6:	6d 91       	ld	r22, X+
    36c8:	7d 91       	ld	r23, X+
    36ca:	8d 91       	ld	r24, X+
    36cc:	9c 91       	ld	r25, X
    36ce:	97 97       	sbiw	r26, 0x27	; 39
    36d0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    36d4:	36 2e       	mov	r3, r22
    36d6:	47 2e       	mov	r4, r23
    36d8:	58 2e       	mov	r5, r24
    36da:	69 2e       	mov	r6, r25
    36dc:	26 2f       	mov	r18, r22
    36de:	37 2f       	mov	r19, r23
    36e0:	48 2f       	mov	r20, r24
    36e2:	59 2f       	mov	r21, r25
    36e4:	c7 01       	movw	r24, r14
    36e6:	b6 01       	movw	r22, r12
    36e8:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    36ec:	87 ff       	sbrs	r24, 7
    36ee:	04 c0       	rjmp	.+8      	; 0x36f8 <limits_go_home+0xde>
    36f0:	c3 2c       	mov	r12, r3
    36f2:	d4 2c       	mov	r13, r4
    36f4:	e5 2c       	mov	r14, r5
    36f6:	f6 2c       	mov	r15, r6
    36f8:	0f 5f       	subi	r16, 0xFF	; 255
    36fa:	1f 4f       	sbci	r17, 0xFF	; 255
    36fc:	b4 e0       	ldi	r27, 0x04	; 4
    36fe:	ab 0e       	add	r10, r27
    3700:	b1 1c       	adc	r11, r1
    3702:	03 30       	cpi	r16, 0x03	; 3
    3704:	11 05       	cpc	r17, r1
    3706:	29 f6       	brne	.-118    	; 0x3692 <limits_go_home+0x78>
    3708:	80 90 8d 06 	lds	r8, 0x068D	; 0x80068d <settings+0x4b>
    370c:	90 90 8e 06 	lds	r9, 0x068E	; 0x80068e <settings+0x4c>
    3710:	a0 90 8f 06 	lds	r10, 0x068F	; 0x80068f <settings+0x4d>
    3714:	b0 90 90 06 	lds	r11, 0x0690	; 0x800690 <settings+0x4e>
    3718:	84 e0       	ldi	r24, 0x04	; 4
    371a:	68 2e       	mov	r6, r24
    371c:	01 e0       	ldi	r16, 0x01	; 1
    371e:	68 e1       	ldi	r22, 0x18	; 24
    3720:	76 e0       	ldi	r23, 0x06	; 6
    3722:	ce 01       	movw	r24, r28
    3724:	01 96       	adiw	r24, 0x01	; 1
    3726:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    372a:	80 91 88 06 	lds	r24, 0x0688	; 0x800688 <settings+0x46>
    372e:	e8 2f       	mov	r30, r24
    3730:	f0 e0       	ldi	r31, 0x00	; 0
    3732:	fa a3       	std	Y+34, r31	; 0x22
    3734:	e9 a3       	std	Y+33, r30	; 0x21
    3736:	fe 01       	movw	r30, r28
    3738:	31 96       	adiw	r30, 0x01	; 1
    373a:	28 e1       	ldi	r18, 0x18	; 24
    373c:	36 e0       	ldi	r19, 0x06	; 6
    373e:	38 a3       	std	Y+32, r19	; 0x20
    3740:	2f 8f       	std	Y+31, r18	; 0x1f
    3742:	19 01       	movw	r2, r18
    3744:	51 2c       	mov	r5, r1
    3746:	10 e0       	ldi	r17, 0x00	; 0
    3748:	30 e0       	ldi	r19, 0x00	; 0
    374a:	20 e0       	ldi	r18, 0x00	; 0
    374c:	b7 01       	movw	r22, r14
    374e:	a6 01       	movw	r20, r12
    3750:	70 58       	subi	r23, 0x80	; 128
    3752:	8d 8d       	ldd	r24, Y+29	; 0x1d
    3754:	9e 8d       	ldd	r25, Y+30	; 0x1e
    3756:	02 2e       	mov	r0, r18
    3758:	02 c0       	rjmp	.+4      	; 0x375e <limits_go_home+0x144>
    375a:	95 95       	asr	r25
    375c:	87 95       	ror	r24
    375e:	0a 94       	dec	r0
    3760:	e2 f7       	brpl	.-8      	; 0x375a <limits_go_home+0x140>
    3762:	80 ff       	sbrs	r24, 0
    3764:	26 c0       	rjmp	.+76     	; 0x37b2 <limits_go_home+0x198>
    3766:	53 94       	inc	r5
    3768:	d1 01       	movw	r26, r2
    376a:	1d 92       	st	X+, r1
    376c:	1d 92       	st	X+, r1
    376e:	1d 92       	st	X+, r1
    3770:	1c 92       	st	X, r1
    3772:	13 97       	sbiw	r26, 0x03	; 3
    3774:	89 a1       	ldd	r24, Y+33	; 0x21
    3776:	9a a1       	ldd	r25, Y+34	; 0x22
    3778:	02 2e       	mov	r0, r18
    377a:	02 c0       	rjmp	.+4      	; 0x3780 <limits_go_home+0x166>
    377c:	95 95       	asr	r25
    377e:	87 95       	ror	r24
    3780:	0a 94       	dec	r0
    3782:	e2 f7       	brpl	.-8      	; 0x377c <limits_go_home+0x162>
    3784:	80 ff       	sbrs	r24, 0
    3786:	07 c0       	rjmp	.+14     	; 0x3796 <limits_go_home+0x17c>
    3788:	00 23       	and	r16, r16
    378a:	39 f0       	breq	.+14     	; 0x379a <limits_go_home+0x180>
    378c:	40 83       	st	Z, r20
    378e:	51 83       	std	Z+1, r21	; 0x01
    3790:	62 83       	std	Z+2, r22	; 0x02
    3792:	73 83       	std	Z+3, r23	; 0x03
    3794:	06 c0       	rjmp	.+12     	; 0x37a2 <limits_go_home+0x188>
    3796:	00 23       	and	r16, r16
    3798:	c9 f3       	breq	.-14     	; 0x378c <limits_go_home+0x172>
    379a:	c0 82       	st	Z, r12
    379c:	d1 82       	std	Z+1, r13	; 0x01
    379e:	e2 82       	std	Z+2, r14	; 0x02
    37a0:	f3 82       	std	Z+3, r15	; 0x03
    37a2:	a6 e1       	ldi	r26, 0x16	; 22
    37a4:	b0 e0       	ldi	r27, 0x00	; 0
    37a6:	ac 0f       	add	r26, r28
    37a8:	bd 1f       	adc	r27, r29
    37aa:	a2 0f       	add	r26, r18
    37ac:	b3 1f       	adc	r27, r19
    37ae:	8c 91       	ld	r24, X
    37b0:	18 2b       	or	r17, r24
    37b2:	2f 5f       	subi	r18, 0xFF	; 255
    37b4:	3f 4f       	sbci	r19, 0xFF	; 255
    37b6:	34 96       	adiw	r30, 0x04	; 4
    37b8:	b4 e0       	ldi	r27, 0x04	; 4
    37ba:	2b 0e       	add	r2, r27
    37bc:	31 1c       	adc	r3, r1
    37be:	23 30       	cpi	r18, 0x03	; 3
    37c0:	31 05       	cpc	r19, r1
    37c2:	39 f6       	brne	.-114    	; 0x3752 <limits_go_home+0x138>
    37c4:	65 2d       	mov	r22, r5
    37c6:	70 e0       	ldi	r23, 0x00	; 0
    37c8:	90 e0       	ldi	r25, 0x00	; 0
    37ca:	80 e0       	ldi	r24, 0x00	; 0
    37cc:	0e 94 b8 36 	call	0x6d70	; 0x6d70 <__floatunsisf>
    37d0:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    37d4:	10 93 37 06 	sts	0x0637, r17	; 0x800637 <sys+0x6>
    37d8:	a5 01       	movw	r20, r10
    37da:	94 01       	movw	r18, r8
    37dc:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    37e0:	6d 87       	std	Y+13, r22	; 0x0d
    37e2:	7e 87       	std	Y+14, r23	; 0x0e
    37e4:	8f 87       	std	Y+15, r24	; 0x0f
    37e6:	98 8b       	std	Y+16, r25	; 0x10
    37e8:	be 01       	movw	r22, r28
    37ea:	63 5f       	subi	r22, 0xF3	; 243
    37ec:	7f 4f       	sbci	r23, 0xFF	; 255
    37ee:	ce 01       	movw	r24, r28
    37f0:	01 96       	adiw	r24, 0x01	; 1
    37f2:	0e 94 e9 0a 	call	0x15d2	; 0x15d2 <plan_buffer_line>
    37f6:	e4 e0       	ldi	r30, 0x04	; 4
    37f8:	e0 93 35 06 	sts	0x0635, r30	; 0x800635 <sys+0x4>
    37fc:	0e 94 26 0e 	call	0x1c4c	; 0x1c4c <st_prep_buffer>
    3800:	0e 94 6c 06 	call	0xcd8	; 0xcd8 <st_wake_up>
    3804:	00 23       	and	r16, r16
    3806:	e9 f0       	breq	.+58     	; 0x3842 <limits_go_home+0x228>
    3808:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    380c:	fe 01       	movw	r30, r28
    380e:	76 96       	adiw	r30, 0x16	; 22
    3810:	30 e0       	ldi	r19, 0x00	; 0
    3812:	20 e0       	ldi	r18, 0x00	; 0
    3814:	90 e0       	ldi	r25, 0x00	; 0
    3816:	61 91       	ld	r22, Z+
    3818:	46 2f       	mov	r20, r22
    381a:	41 23       	and	r20, r17
    381c:	59 f0       	breq	.+22     	; 0x3834 <limits_go_home+0x21a>
    381e:	ac 01       	movw	r20, r24
    3820:	02 2e       	mov	r0, r18
    3822:	02 c0       	rjmp	.+4      	; 0x3828 <limits_go_home+0x20e>
    3824:	55 95       	asr	r21
    3826:	47 95       	ror	r20
    3828:	0a 94       	dec	r0
    382a:	e2 f7       	brpl	.-8      	; 0x3824 <limits_go_home+0x20a>
    382c:	40 ff       	sbrs	r20, 0
    382e:	02 c0       	rjmp	.+4      	; 0x3834 <limits_go_home+0x21a>
    3830:	60 95       	com	r22
    3832:	16 23       	and	r17, r22
    3834:	2f 5f       	subi	r18, 0xFF	; 255
    3836:	3f 4f       	sbci	r19, 0xFF	; 255
    3838:	23 30       	cpi	r18, 0x03	; 3
    383a:	31 05       	cpc	r19, r1
    383c:	61 f7       	brne	.-40     	; 0x3816 <limits_go_home+0x1fc>
    383e:	10 93 37 06 	sts	0x0637, r17	; 0x800637 <sys+0x6>
    3842:	0e 94 26 0e 	call	0x1c4c	; 0x1c4c <st_prep_buffer>
    3846:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    384a:	84 73       	andi	r24, 0x34	; 52
    384c:	09 f4       	brne	.+2      	; 0x3850 <limits_go_home+0x236>
    384e:	b3 c0       	rjmp	.+358    	; 0x39b6 <limits_go_home+0x39c>
    3850:	10 91 13 06 	lds	r17, 0x0613	; 0x800613 <sys_rt_exec_state>
    3854:	14 ff       	sbrs	r17, 4
    3856:	03 c0       	rjmp	.+6      	; 0x385e <limits_go_home+0x244>
    3858:	86 e0       	ldi	r24, 0x06	; 6
    385a:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    385e:	15 ff       	sbrs	r17, 5
    3860:	03 c0       	rjmp	.+6      	; 0x3868 <limits_go_home+0x24e>
    3862:	87 e0       	ldi	r24, 0x07	; 7
    3864:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3868:	01 11       	cpse	r16, r1
    386a:	c8 c0       	rjmp	.+400    	; 0x39fc <limits_go_home+0x3e2>
    386c:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    3870:	87 21       	and	r24, r7
    3872:	19 f0       	breq	.+6      	; 0x387a <limits_go_home+0x260>
    3874:	88 e0       	ldi	r24, 0x08	; 8
    3876:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    387a:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    387e:	88 23       	and	r24, r24
    3880:	e9 f0       	breq	.+58     	; 0x38bc <limits_go_home+0x2a2>
    3882:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    3886:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    388a:	a2 96       	adiw	r28, 0x22	; 34
    388c:	0f b6       	in	r0, 0x3f	; 63
    388e:	f8 94       	cli
    3890:	de bf       	out	0x3e, r29	; 62
    3892:	0f be       	out	0x3f, r0	; 63
    3894:	cd bf       	out	0x3d, r28	; 61
    3896:	df 91       	pop	r29
    3898:	cf 91       	pop	r28
    389a:	1f 91       	pop	r17
    389c:	0f 91       	pop	r16
    389e:	ff 90       	pop	r15
    38a0:	ef 90       	pop	r14
    38a2:	df 90       	pop	r13
    38a4:	cf 90       	pop	r12
    38a6:	bf 90       	pop	r11
    38a8:	af 90       	pop	r10
    38aa:	9f 90       	pop	r9
    38ac:	8f 90       	pop	r8
    38ae:	7f 90       	pop	r7
    38b0:	6f 90       	pop	r6
    38b2:	5f 90       	pop	r5
    38b4:	4f 90       	pop	r4
    38b6:	3f 90       	pop	r3
    38b8:	2f 90       	pop	r2
    38ba:	08 95       	ret
    38bc:	84 e0       	ldi	r24, 0x04	; 4
    38be:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    38c2:	0e 94 cf 0d 	call	0x1b9e	; 0x1b9e <st_reset>
    38c6:	80 91 91 06 	lds	r24, 0x0691	; 0x800691 <settings+0x4f>
    38ca:	90 91 92 06 	lds	r25, 0x0692	; 0x800692 <settings+0x50>
    38ce:	01 97       	sbiw	r24, 0x01	; 1
    38d0:	08 f0       	brcs	.+2      	; 0x38d4 <limits_go_home+0x2ba>
    38d2:	76 c0       	rjmp	.+236    	; 0x39c0 <limits_go_home+0x3a6>
    38d4:	e1 e0       	ldi	r30, 0x01	; 1
    38d6:	0e 27       	eor	r16, r30
    38d8:	10 91 93 06 	lds	r17, 0x0693	; 0x800693 <settings+0x51>
    38dc:	50 90 94 06 	lds	r5, 0x0694	; 0x800694 <settings+0x52>
    38e0:	40 90 95 06 	lds	r4, 0x0695	; 0x800695 <settings+0x53>
    38e4:	30 90 96 06 	lds	r3, 0x0696	; 0x800696 <settings+0x54>
    38e8:	00 23       	and	r16, r16
    38ea:	09 f4       	brne	.+2      	; 0x38ee <limits_go_home+0x2d4>
    38ec:	70 c0       	rjmp	.+224    	; 0x39ce <limits_go_home+0x3b4>
    38ee:	20 e0       	ldi	r18, 0x00	; 0
    38f0:	30 e0       	ldi	r19, 0x00	; 0
    38f2:	40 ea       	ldi	r20, 0xA0	; 160
    38f4:	50 e4       	ldi	r21, 0x40	; 64
    38f6:	61 2f       	mov	r22, r17
    38f8:	75 2d       	mov	r23, r5
    38fa:	84 2d       	mov	r24, r4
    38fc:	93 2d       	mov	r25, r3
    38fe:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    3902:	6b 01       	movw	r12, r22
    3904:	7c 01       	movw	r14, r24
    3906:	80 90 89 06 	lds	r8, 0x0689	; 0x800689 <settings+0x47>
    390a:	90 90 8a 06 	lds	r9, 0x068A	; 0x80068a <settings+0x48>
    390e:	a0 90 8b 06 	lds	r10, 0x068B	; 0x80068b <settings+0x49>
    3912:	b0 90 8c 06 	lds	r11, 0x068C	; 0x80068c <settings+0x4a>
    3916:	6a 94       	dec	r6
    3918:	61 10       	cpse	r6, r1
    391a:	01 cf       	rjmp	.-510    	; 0x371e <limits_go_home+0x104>
    391c:	c0 90 88 06 	lds	r12, 0x0688	; 0x800688 <settings+0x46>
    3920:	d1 2c       	mov	r13, r1
    3922:	f1 2c       	mov	r15, r1
    3924:	e1 2c       	mov	r14, r1
    3926:	8d 8d       	ldd	r24, Y+29	; 0x1d
    3928:	9e 8d       	ldd	r25, Y+30	; 0x1e
    392a:	0e 2c       	mov	r0, r14
    392c:	02 c0       	rjmp	.+4      	; 0x3932 <limits_go_home+0x318>
    392e:	95 95       	asr	r25
    3930:	87 95       	ror	r24
    3932:	0a 94       	dec	r0
    3934:	e2 f7       	brpl	.-8      	; 0x392e <limits_go_home+0x314>
    3936:	80 ff       	sbrs	r24, 0
    3938:	28 c0       	rjmp	.+80     	; 0x398a <limits_go_home+0x370>
    393a:	ab 8d       	ldd	r26, Y+27	; 0x1b
    393c:	bc 8d       	ldd	r27, Y+28	; 0x1c
    393e:	8d 90       	ld	r8, X+
    3940:	9d 90       	ld	r9, X+
    3942:	ad 90       	ld	r10, X+
    3944:	bc 90       	ld	r11, X
    3946:	13 97       	sbiw	r26, 0x03	; 3
    3948:	c6 01       	movw	r24, r12
    394a:	0e 2c       	mov	r0, r14
    394c:	02 c0       	rjmp	.+4      	; 0x3952 <limits_go_home+0x338>
    394e:	95 95       	asr	r25
    3950:	87 95       	ror	r24
    3952:	0a 94       	dec	r0
    3954:	e2 f7       	brpl	.-8      	; 0x394e <limits_go_home+0x334>
    3956:	80 ff       	sbrs	r24, 0
    3958:	47 c0       	rjmp	.+142    	; 0x39e8 <limits_go_home+0x3ce>
    395a:	94 96       	adiw	r26, 0x24	; 36
    395c:	2d 91       	ld	r18, X+
    395e:	3d 91       	ld	r19, X+
    3960:	4d 91       	ld	r20, X+
    3962:	5c 91       	ld	r21, X
    3964:	97 97       	sbiw	r26, 0x27	; 39
    3966:	61 2f       	mov	r22, r17
    3968:	75 2d       	mov	r23, r5
    396a:	84 2d       	mov	r24, r4
    396c:	93 2d       	mov	r25, r3
    396e:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    3972:	a5 01       	movw	r20, r10
    3974:	94 01       	movw	r18, r8
    3976:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    397a:	0e 94 35 38 	call	0x706a	; 0x706a <lround>
    397e:	ef 8d       	ldd	r30, Y+31	; 0x1f
    3980:	f8 a1       	ldd	r31, Y+32	; 0x20
    3982:	60 83       	st	Z, r22
    3984:	71 83       	std	Z+1, r23	; 0x01
    3986:	82 83       	std	Z+2, r24	; 0x02
    3988:	93 83       	std	Z+3, r25	; 0x03
    398a:	ff ef       	ldi	r31, 0xFF	; 255
    398c:	ef 1a       	sub	r14, r31
    398e:	ff 0a       	sbc	r15, r31
    3990:	2f 8d       	ldd	r18, Y+31	; 0x1f
    3992:	38 a1       	ldd	r19, Y+32	; 0x20
    3994:	2c 5f       	subi	r18, 0xFC	; 252
    3996:	3f 4f       	sbci	r19, 0xFF	; 255
    3998:	38 a3       	std	Y+32, r19	; 0x20
    399a:	2f 8f       	std	Y+31, r18	; 0x1f
    399c:	8b 8d       	ldd	r24, Y+27	; 0x1b
    399e:	9c 8d       	ldd	r25, Y+28	; 0x1c
    39a0:	04 96       	adiw	r24, 0x04	; 4
    39a2:	9c 8f       	std	Y+28, r25	; 0x1c
    39a4:	8b 8f       	std	Y+27, r24	; 0x1b
    39a6:	93 e0       	ldi	r25, 0x03	; 3
    39a8:	e9 16       	cp	r14, r25
    39aa:	f1 04       	cpc	r15, r1
    39ac:	09 f0       	breq	.+2      	; 0x39b0 <limits_go_home+0x396>
    39ae:	bb cf       	rjmp	.-138    	; 0x3926 <limits_go_home+0x30c>
    39b0:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    39b4:	6a cf       	rjmp	.-300    	; 0x388a <limits_go_home+0x270>
    39b6:	81 2f       	mov	r24, r17
    39b8:	8c 71       	andi	r24, 0x1C	; 28
    39ba:	09 f0       	breq	.+2      	; 0x39be <limits_go_home+0x3a4>
    39bc:	23 cf       	rjmp	.-442    	; 0x3804 <limits_go_home+0x1ea>
    39be:	81 cf       	rjmp	.-254    	; 0x38c2 <limits_go_home+0x2a8>
    39c0:	af e9       	ldi	r26, 0x9F	; 159
    39c2:	bf e0       	ldi	r27, 0x0F	; 15
    39c4:	11 97       	sbiw	r26, 0x01	; 1
    39c6:	f1 f7       	brne	.-4      	; 0x39c4 <limits_go_home+0x3aa>
    39c8:	00 c0       	rjmp	.+0      	; 0x39ca <limits_go_home+0x3b0>
    39ca:	00 00       	nop
    39cc:	80 cf       	rjmp	.-256    	; 0x38ce <limits_go_home+0x2b4>
    39ce:	80 90 8d 06 	lds	r8, 0x068D	; 0x80068d <settings+0x4b>
    39d2:	90 90 8e 06 	lds	r9, 0x068E	; 0x80068e <settings+0x4c>
    39d6:	a0 90 8f 06 	lds	r10, 0x068F	; 0x80068f <settings+0x4d>
    39da:	b0 90 90 06 	lds	r11, 0x0690	; 0x800690 <settings+0x4e>
    39de:	c1 2e       	mov	r12, r17
    39e0:	d5 2c       	mov	r13, r5
    39e2:	e4 2c       	mov	r14, r4
    39e4:	f3 2c       	mov	r15, r3
    39e6:	97 cf       	rjmp	.-210    	; 0x3916 <limits_go_home+0x2fc>
    39e8:	a5 01       	movw	r20, r10
    39ea:	94 01       	movw	r18, r8
    39ec:	61 2f       	mov	r22, r17
    39ee:	75 2d       	mov	r23, r5
    39f0:	84 2d       	mov	r24, r4
    39f2:	93 2d       	mov	r25, r3
    39f4:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    39f8:	90 58       	subi	r25, 0x80	; 128
    39fa:	bf cf       	rjmp	.-130    	; 0x397a <limits_go_home+0x360>
    39fc:	12 ff       	sbrs	r17, 2
    39fe:	3d cf       	rjmp	.-390    	; 0x387a <limits_go_home+0x260>
    3a00:	89 e0       	ldi	r24, 0x09	; 9
    3a02:	39 cf       	rjmp	.-398    	; 0x3876 <limits_go_home+0x25c>

00003a04 <delay_sec>:
    3a04:	1f 93       	push	r17
    3a06:	cf 93       	push	r28
    3a08:	df 93       	push	r29
    3a0a:	14 2f       	mov	r17, r20
    3a0c:	20 e0       	ldi	r18, 0x00	; 0
    3a0e:	30 e0       	ldi	r19, 0x00	; 0
    3a10:	40 ea       	ldi	r20, 0xA0	; 160
    3a12:	51 e4       	ldi	r21, 0x41	; 65
    3a14:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    3a18:	0e 94 ef 35 	call	0x6bde	; 0x6bde <ceil>
    3a1c:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    3a20:	eb 01       	movw	r28, r22
    3a22:	20 97       	sbiw	r28, 0x00	; 0
    3a24:	c9 f0       	breq	.+50     	; 0x3a58 <delay_sec+0x54>
    3a26:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3a2a:	81 11       	cpse	r24, r1
    3a2c:	15 c0       	rjmp	.+42     	; 0x3a58 <delay_sec+0x54>
    3a2e:	11 11       	cpse	r17, r1
    3a30:	0d c0       	rjmp	.+26     	; 0x3a4c <delay_sec+0x48>
    3a32:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    3a36:	2f ef       	ldi	r18, 0xFF	; 255
    3a38:	80 e7       	ldi	r24, 0x70	; 112
    3a3a:	92 e0       	ldi	r25, 0x02	; 2
    3a3c:	21 50       	subi	r18, 0x01	; 1
    3a3e:	80 40       	sbci	r24, 0x00	; 0
    3a40:	90 40       	sbci	r25, 0x00	; 0
    3a42:	e1 f7       	brne	.-8      	; 0x3a3c <delay_sec+0x38>
    3a44:	00 c0       	rjmp	.+0      	; 0x3a46 <delay_sec+0x42>
    3a46:	00 00       	nop
    3a48:	21 97       	sbiw	r28, 0x01	; 1
    3a4a:	eb cf       	rjmp	.-42     	; 0x3a22 <delay_sec+0x1e>
    3a4c:	0e 94 b5 15 	call	0x2b6a	; 0x2b6a <protocol_exec_rt_system>
    3a50:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3a54:	81 ff       	sbrs	r24, 1
    3a56:	ef cf       	rjmp	.-34     	; 0x3a36 <delay_sec+0x32>
    3a58:	df 91       	pop	r29
    3a5a:	cf 91       	pop	r28
    3a5c:	1f 91       	pop	r17
    3a5e:	08 95       	ret

00003a60 <protocol_buffer_synchronize>:
    3a60:	0e 94 85 06 	call	0xd0a	; 0xd0a <protocol_auto_cycle_start>
    3a64:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    3a68:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3a6c:	81 11       	cpse	r24, r1
    3a6e:	08 c0       	rjmp	.+16     	; 0x3a80 <protocol_buffer_synchronize+0x20>
    3a70:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
    3a74:	89 2b       	or	r24, r25
    3a76:	b1 f7       	brne	.-20     	; 0x3a64 <protocol_buffer_synchronize+0x4>
    3a78:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3a7c:	88 30       	cpi	r24, 0x08	; 8
    3a7e:	91 f3       	breq	.-28     	; 0x3a64 <protocol_buffer_synchronize+0x4>
    3a80:	08 95       	ret

00003a82 <settings_read_startup_line.constprop.7>:
    3a82:	cf 93       	push	r28
    3a84:	df 93       	push	r29
    3a86:	91 e5       	ldi	r25, 0x51	; 81
    3a88:	89 9f       	mul	r24, r25
    3a8a:	e0 01       	movw	r28, r0
    3a8c:	11 24       	eor	r1, r1
    3a8e:	dd 5f       	subi	r29, 0xFD	; 253
    3a90:	40 e5       	ldi	r20, 0x50	; 80
    3a92:	50 e0       	ldi	r21, 0x00	; 0
    3a94:	be 01       	movw	r22, r28
    3a96:	81 e1       	ldi	r24, 0x11	; 17
    3a98:	97 e0       	ldi	r25, 0x07	; 7
    3a9a:	0e 94 8e 04 	call	0x91c	; 0x91c <memcpy_from_eeprom_with_checksum>
    3a9e:	89 2b       	or	r24, r25
    3aa0:	79 f4       	brne	.+30     	; 0x3ac0 <settings_read_startup_line.constprop.7+0x3e>
    3aa2:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    3aa6:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    3aaa:	40 e5       	ldi	r20, 0x50	; 80
    3aac:	50 e0       	ldi	r21, 0x00	; 0
    3aae:	61 e1       	ldi	r22, 0x11	; 17
    3ab0:	77 e0       	ldi	r23, 0x07	; 7
    3ab2:	ce 01       	movw	r24, r28
    3ab4:	0e 94 3e 04 	call	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>
    3ab8:	80 e0       	ldi	r24, 0x00	; 0
    3aba:	df 91       	pop	r29
    3abc:	cf 91       	pop	r28
    3abe:	08 95       	ret
    3ac0:	81 e0       	ldi	r24, 0x01	; 1
    3ac2:	fb cf       	rjmp	.-10     	; 0x3aba <settings_read_startup_line.constprop.7+0x38>

00003ac4 <system_flag_wco_change>:
    3ac4:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    3ac8:	10 92 3d 06 	sts	0x063D, r1	; 0x80063d <sys+0xc>
    3acc:	08 95       	ret

00003ace <settings_write_coord_data>:
    3ace:	0f 93       	push	r16
    3ad0:	1f 93       	push	r17
    3ad2:	cf 93       	push	r28
    3ad4:	c8 2f       	mov	r28, r24
    3ad6:	8b 01       	movw	r16, r22
    3ad8:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    3adc:	2d e0       	ldi	r18, 0x0D	; 13
    3ade:	c2 9f       	mul	r28, r18
    3ae0:	c0 01       	movw	r24, r0
    3ae2:	11 24       	eor	r1, r1
    3ae4:	4c e0       	ldi	r20, 0x0C	; 12
    3ae6:	50 e0       	ldi	r21, 0x00	; 0
    3ae8:	b8 01       	movw	r22, r16
    3aea:	9e 5f       	subi	r25, 0xFE	; 254
    3aec:	cf 91       	pop	r28
    3aee:	1f 91       	pop	r17
    3af0:	0f 91       	pop	r16
    3af2:	0c 94 3e 04 	jmp	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>

00003af6 <settings_read_coord_data>:
    3af6:	1f 93       	push	r17
    3af8:	cf 93       	push	r28
    3afa:	df 93       	push	r29
    3afc:	18 2f       	mov	r17, r24
    3afe:	eb 01       	movw	r28, r22
    3b00:	8d e0       	ldi	r24, 0x0D	; 13
    3b02:	18 9f       	mul	r17, r24
    3b04:	b0 01       	movw	r22, r0
    3b06:	11 24       	eor	r1, r1
    3b08:	7e 5f       	subi	r23, 0xFE	; 254
    3b0a:	4c e0       	ldi	r20, 0x0C	; 12
    3b0c:	50 e0       	ldi	r21, 0x00	; 0
    3b0e:	ce 01       	movw	r24, r28
    3b10:	0e 94 8e 04 	call	0x91c	; 0x91c <memcpy_from_eeprom_with_checksum>
    3b14:	89 2b       	or	r24, r25
    3b16:	71 f4       	brne	.+28     	; 0x3b34 <settings_read_coord_data+0x3e>
    3b18:	8c e0       	ldi	r24, 0x0C	; 12
    3b1a:	fe 01       	movw	r30, r28
    3b1c:	11 92       	st	Z+, r1
    3b1e:	8a 95       	dec	r24
    3b20:	e9 f7       	brne	.-6      	; 0x3b1c <settings_read_coord_data+0x26>
    3b22:	be 01       	movw	r22, r28
    3b24:	81 2f       	mov	r24, r17
    3b26:	0e 94 67 1d 	call	0x3ace	; 0x3ace <settings_write_coord_data>
    3b2a:	80 e0       	ldi	r24, 0x00	; 0
    3b2c:	df 91       	pop	r29
    3b2e:	cf 91       	pop	r28
    3b30:	1f 91       	pop	r17
    3b32:	08 95       	ret
    3b34:	81 e0       	ldi	r24, 0x01	; 1
    3b36:	fa cf       	rjmp	.-12     	; 0x3b2c <settings_read_coord_data+0x36>

00003b38 <settings_restore>:
    3b38:	ef 92       	push	r14
    3b3a:	ff 92       	push	r15
    3b3c:	0f 93       	push	r16
    3b3e:	1f 93       	push	r17
    3b40:	cf 93       	push	r28
    3b42:	df 93       	push	r29
    3b44:	cd b7       	in	r28, 0x3d	; 61
    3b46:	de b7       	in	r29, 0x3e	; 62
    3b48:	2c 97       	sbiw	r28, 0x0c	; 12
    3b4a:	0f b6       	in	r0, 0x3f	; 63
    3b4c:	f8 94       	cli
    3b4e:	de bf       	out	0x3e, r29	; 62
    3b50:	0f be       	out	0x3f, r0	; 63
    3b52:	cd bf       	out	0x3d, r28	; 61
    3b54:	18 2f       	mov	r17, r24
    3b56:	80 ff       	sbrs	r24, 0
    3b58:	0b c0       	rjmp	.+22     	; 0x3b70 <settings_restore+0x38>
    3b5a:	85 e5       	ldi	r24, 0x55	; 85
    3b5c:	e9 ec       	ldi	r30, 0xC9	; 201
    3b5e:	f1 e0       	ldi	r31, 0x01	; 1
    3b60:	a2 e4       	ldi	r26, 0x42	; 66
    3b62:	b6 e0       	ldi	r27, 0x06	; 6
    3b64:	05 90       	lpm	r0, Z+
    3b66:	0d 92       	st	X+, r0
    3b68:	8a 95       	dec	r24
    3b6a:	e1 f7       	brne	.-8      	; 0x3b64 <settings_restore+0x2c>
    3b6c:	0e 94 79 04 	call	0x8f2	; 0x8f2 <write_global_settings>
    3b70:	11 ff       	sbrs	r17, 1
    3b72:	10 c0       	rjmp	.+32     	; 0x3b94 <settings_restore+0x5c>
    3b74:	ce 01       	movw	r24, r28
    3b76:	01 96       	adiw	r24, 0x01	; 1
    3b78:	7c 01       	movw	r14, r24
    3b7a:	8c e0       	ldi	r24, 0x0C	; 12
    3b7c:	f7 01       	movw	r30, r14
    3b7e:	11 92       	st	Z+, r1
    3b80:	8a 95       	dec	r24
    3b82:	e9 f7       	brne	.-6      	; 0x3b7e <settings_restore+0x46>
    3b84:	00 e0       	ldi	r16, 0x00	; 0
    3b86:	b7 01       	movw	r22, r14
    3b88:	80 2f       	mov	r24, r16
    3b8a:	0e 94 67 1d 	call	0x3ace	; 0x3ace <settings_write_coord_data>
    3b8e:	0f 5f       	subi	r16, 0xFF	; 255
    3b90:	08 30       	cpi	r16, 0x08	; 8
    3b92:	c9 f7       	brne	.-14     	; 0x3b86 <settings_restore+0x4e>
    3b94:	12 ff       	sbrs	r17, 2
    3b96:	14 c0       	rjmp	.+40     	; 0x3bc0 <settings_restore+0x88>
    3b98:	60 e0       	ldi	r22, 0x00	; 0
    3b9a:	80 e0       	ldi	r24, 0x00	; 0
    3b9c:	93 e0       	ldi	r25, 0x03	; 3
    3b9e:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3ba2:	60 e0       	ldi	r22, 0x00	; 0
    3ba4:	81 e0       	ldi	r24, 0x01	; 1
    3ba6:	93 e0       	ldi	r25, 0x03	; 3
    3ba8:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3bac:	60 e0       	ldi	r22, 0x00	; 0
    3bae:	81 e5       	ldi	r24, 0x51	; 81
    3bb0:	93 e0       	ldi	r25, 0x03	; 3
    3bb2:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3bb6:	60 e0       	ldi	r22, 0x00	; 0
    3bb8:	82 e5       	ldi	r24, 0x52	; 82
    3bba:	93 e0       	ldi	r25, 0x03	; 3
    3bbc:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3bc0:	13 ff       	sbrs	r17, 3
    3bc2:	0a c0       	rjmp	.+20     	; 0x3bd8 <settings_restore+0xa0>
    3bc4:	60 e0       	ldi	r22, 0x00	; 0
    3bc6:	8e ea       	ldi	r24, 0xAE	; 174
    3bc8:	93 e0       	ldi	r25, 0x03	; 3
    3bca:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3bce:	60 e0       	ldi	r22, 0x00	; 0
    3bd0:	8f ea       	ldi	r24, 0xAF	; 175
    3bd2:	93 e0       	ldi	r25, 0x03	; 3
    3bd4:	0e 94 1e 04 	call	0x83c	; 0x83c <eeprom_put_char>
    3bd8:	2c 96       	adiw	r28, 0x0c	; 12
    3bda:	0f b6       	in	r0, 0x3f	; 63
    3bdc:	f8 94       	cli
    3bde:	de bf       	out	0x3e, r29	; 62
    3be0:	0f be       	out	0x3f, r0	; 63
    3be2:	cd bf       	out	0x3d, r28	; 61
    3be4:	df 91       	pop	r29
    3be6:	cf 91       	pop	r28
    3be8:	1f 91       	pop	r17
    3bea:	0f 91       	pop	r16
    3bec:	ff 90       	pop	r15
    3bee:	ef 90       	pop	r14
    3bf0:	08 95       	ret

00003bf2 <spindle_sync>:
    3bf2:	cf 92       	push	r12
    3bf4:	df 92       	push	r13
    3bf6:	ef 92       	push	r14
    3bf8:	ff 92       	push	r15
    3bfa:	cf 93       	push	r28
    3bfc:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    3c00:	92 30       	cpi	r25, 0x02	; 2
    3c02:	79 f0       	breq	.+30     	; 0x3c22 <spindle_sync+0x30>
    3c04:	6a 01       	movw	r12, r20
    3c06:	7b 01       	movw	r14, r22
    3c08:	c8 2f       	mov	r28, r24
    3c0a:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    3c0e:	b7 01       	movw	r22, r14
    3c10:	a6 01       	movw	r20, r12
    3c12:	8c 2f       	mov	r24, r28
    3c14:	cf 91       	pop	r28
    3c16:	ff 90       	pop	r15
    3c18:	ef 90       	pop	r14
    3c1a:	df 90       	pop	r13
    3c1c:	cf 90       	pop	r12
    3c1e:	0c 94 be 0a 	jmp	0x157c	; 0x157c <spindle_set_state>
    3c22:	cf 91       	pop	r28
    3c24:	ff 90       	pop	r15
    3c26:	ef 90       	pop	r14
    3c28:	df 90       	pop	r13
    3c2a:	cf 90       	pop	r12
    3c2c:	08 95       	ret

00003c2e <mc_line>:
    3c2e:	ff 92       	push	r15
    3c30:	0f 93       	push	r16
    3c32:	1f 93       	push	r17
    3c34:	cf 93       	push	r28
    3c36:	df 93       	push	r29
    3c38:	8c 01       	movw	r16, r24
    3c3a:	eb 01       	movw	r28, r22
    3c3c:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3c40:	85 ff       	sbrs	r24, 5
    3c42:	23 c0       	rjmp	.+70     	; 0x3c8a <mc_line+0x5c>
    3c44:	f0 90 31 06 	lds	r15, 0x0631	; 0x800631 <sys>
    3c48:	80 e2       	ldi	r24, 0x20	; 32
    3c4a:	f8 16       	cp	r15, r24
    3c4c:	11 f1       	breq	.+68     	; 0x3c92 <mc_line+0x64>
    3c4e:	c8 01       	movw	r24, r16
    3c50:	0e 94 54 02 	call	0x4a8	; 0x4a8 <system_check_travel_limits>
    3c54:	88 23       	and	r24, r24
    3c56:	c9 f0       	breq	.+50     	; 0x3c8a <mc_line+0x5c>
    3c58:	81 e0       	ldi	r24, 0x01	; 1
    3c5a:	80 93 34 06 	sts	0x0634, r24	; 0x800634 <sys+0x3>
    3c5e:	88 e0       	ldi	r24, 0x08	; 8
    3c60:	f8 12       	cpse	r15, r24
    3c62:	0c c0       	rjmp	.+24     	; 0x3c7c <mc_line+0x4e>
    3c64:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    3c68:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    3c6c:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3c70:	81 11       	cpse	r24, r1
    3c72:	0b c0       	rjmp	.+22     	; 0x3c8a <mc_line+0x5c>
    3c74:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3c78:	81 11       	cpse	r24, r1
    3c7a:	f6 cf       	rjmp	.-20     	; 0x3c68 <mc_line+0x3a>
    3c7c:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    3c80:	82 e0       	ldi	r24, 0x02	; 2
    3c82:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3c86:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    3c8a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3c8e:	82 30       	cpi	r24, 0x02	; 2
    3c90:	41 f1       	breq	.+80     	; 0x3ce2 <mc_line+0xb4>
    3c92:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    3c96:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3c9a:	81 11       	cpse	r24, r1
    3c9c:	22 c0       	rjmp	.+68     	; 0x3ce2 <mc_line+0xb4>
    3c9e:	90 91 d5 02 	lds	r25, 0x02D5	; 0x8002d5 <block_buffer_tail>
    3ca2:	80 91 d4 02 	lds	r24, 0x02D4	; 0x8002d4 <next_buffer_head>
    3ca6:	98 13       	cpse	r25, r24
    3ca8:	03 c0       	rjmp	.+6      	; 0x3cb0 <mc_line+0x82>
    3caa:	0e 94 85 06 	call	0xd0a	; 0xd0a <protocol_auto_cycle_start>
    3cae:	f1 cf       	rjmp	.-30     	; 0x3c92 <mc_line+0x64>
    3cb0:	be 01       	movw	r22, r28
    3cb2:	c8 01       	movw	r24, r16
    3cb4:	0e 94 e9 0a 	call	0x15d2	; 0x15d2 <plan_buffer_line>
    3cb8:	81 11       	cpse	r24, r1
    3cba:	13 c0       	rjmp	.+38     	; 0x3ce2 <mc_line+0xb4>
    3cbc:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3cc0:	81 ff       	sbrs	r24, 1
    3cc2:	0f c0       	rjmp	.+30     	; 0x3ce2 <mc_line+0xb4>
    3cc4:	88 85       	ldd	r24, Y+8	; 0x08
    3cc6:	84 ff       	sbrs	r24, 4
    3cc8:	0c c0       	rjmp	.+24     	; 0x3ce2 <mc_line+0xb4>
    3cca:	4c 81       	ldd	r20, Y+4	; 0x04
    3ccc:	5d 81       	ldd	r21, Y+5	; 0x05
    3cce:	6e 81       	ldd	r22, Y+6	; 0x06
    3cd0:	7f 81       	ldd	r23, Y+7	; 0x07
    3cd2:	80 e1       	ldi	r24, 0x10	; 16
    3cd4:	df 91       	pop	r29
    3cd6:	cf 91       	pop	r28
    3cd8:	1f 91       	pop	r17
    3cda:	0f 91       	pop	r16
    3cdc:	ff 90       	pop	r15
    3cde:	0c 94 f9 1d 	jmp	0x3bf2	; 0x3bf2 <spindle_sync>
    3ce2:	df 91       	pop	r29
    3ce4:	cf 91       	pop	r28
    3ce6:	1f 91       	pop	r17
    3ce8:	0f 91       	pop	r16
    3cea:	ff 90       	pop	r15
    3cec:	08 95       	ret

00003cee <gc_execute_line.constprop.11>:
    3cee:	2f 92       	push	r2
    3cf0:	3f 92       	push	r3
    3cf2:	4f 92       	push	r4
    3cf4:	5f 92       	push	r5
    3cf6:	6f 92       	push	r6
    3cf8:	7f 92       	push	r7
    3cfa:	8f 92       	push	r8
    3cfc:	9f 92       	push	r9
    3cfe:	af 92       	push	r10
    3d00:	bf 92       	push	r11
    3d02:	cf 92       	push	r12
    3d04:	df 92       	push	r13
    3d06:	ef 92       	push	r14
    3d08:	ff 92       	push	r15
    3d0a:	0f 93       	push	r16
    3d0c:	1f 93       	push	r17
    3d0e:	cf 93       	push	r28
    3d10:	df 93       	push	r29
    3d12:	cd b7       	in	r28, 0x3d	; 61
    3d14:	de b7       	in	r29, 0x3e	; 62
    3d16:	ca 54       	subi	r28, 0x4A	; 74
    3d18:	d1 09       	sbc	r29, r1
    3d1a:	0f b6       	in	r0, 0x3f	; 63
    3d1c:	f8 94       	cli
    3d1e:	de bf       	out	0x3e, r29	; 62
    3d20:	0f be       	out	0x3f, r0	; 63
    3d22:	cd bf       	out	0x3d, r28	; 61
    3d24:	e7 ed       	ldi	r30, 0xD7	; 215
    3d26:	f6 e0       	ldi	r31, 0x06	; 6
    3d28:	8a e3       	ldi	r24, 0x3A	; 58
    3d2a:	df 01       	movw	r26, r30
    3d2c:	1d 92       	st	X+, r1
    3d2e:	8a 95       	dec	r24
    3d30:	e9 f7       	brne	.-6      	; 0x3d2c <gc_execute_line.constprop.11+0x3e>
    3d32:	8b e0       	ldi	r24, 0x0B	; 11
    3d34:	e7 e9       	ldi	r30, 0x97	; 151
    3d36:	f6 e0       	ldi	r31, 0x06	; 6
    3d38:	a8 ed       	ldi	r26, 0xD8	; 216
    3d3a:	b6 e0       	ldi	r27, 0x06	; 6
    3d3c:	01 90       	ld	r0, Z+
    3d3e:	0d 92       	st	X+, r0
    3d40:	8a 95       	dec	r24
    3d42:	e1 f7       	brne	.-8      	; 0x3d3c <gc_execute_line.constprop.11+0x4e>
    3d44:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    3d48:	84 32       	cpi	r24, 0x24	; 36
    3d4a:	a1 f0       	breq	.+40     	; 0x3d74 <gc_execute_line.constprop.11+0x86>
    3d4c:	1a 8e       	std	Y+26, r1	; 0x1a
    3d4e:	1b a2       	std	Y+35, r1	; 0x23
    3d50:	31 2c       	mov	r3, r1
    3d52:	21 2c       	mov	r2, r1
    3d54:	1c a6       	std	Y+44, r1	; 0x2c
    3d56:	1b a6       	std	Y+43, r1	; 0x2b
    3d58:	10 e0       	ldi	r17, 0x00	; 0
    3d5a:	1b 8e       	std	Y+27, r1	; 0x1b
    3d5c:	1f 8e       	std	Y+31, r1	; 0x1f
    3d5e:	ee 24       	eor	r14, r14
    3d60:	e3 94       	inc	r14
    3d62:	f1 2c       	mov	r15, r1
    3d64:	9a e0       	ldi	r25, 0x0A	; 10
    3d66:	a9 2e       	mov	r10, r25
    3d68:	b1 2c       	mov	r11, r1
    3d6a:	21 e6       	ldi	r18, 0x61	; 97
    3d6c:	82 2e       	mov	r8, r18
    3d6e:	23 e0       	ldi	r18, 0x03	; 3
    3d70:	92 2e       	mov	r9, r18
    3d72:	4c c1       	rjmp	.+664    	; 0x400c <gc_execute_line.constprop.11+0x31e>
    3d74:	81 e0       	ldi	r24, 0x01	; 1
    3d76:	80 93 d8 06 	sts	0x06D8, r24	; 0x8006d8 <gc_block+0x1>
    3d7a:	10 92 d9 06 	sts	0x06D9, r1	; 0x8006d9 <gc_block+0x2>
    3d7e:	83 e0       	ldi	r24, 0x03	; 3
    3d80:	8a 8f       	std	Y+26, r24	; 0x1a
    3d82:	b1 e0       	ldi	r27, 0x01	; 1
    3d84:	bb a3       	std	Y+35, r27	; 0x23
    3d86:	e4 cf       	rjmp	.-56     	; 0x3d50 <gc_execute_line.constprop.11+0x62>
    3d88:	9f eb       	ldi	r25, 0xBF	; 191
    3d8a:	9d 0d       	add	r25, r13
    3d8c:	9a 31       	cpi	r25, 0x1A	; 26
    3d8e:	10 f0       	brcs	.+4      	; 0x3d94 <gc_execute_line.constprop.11+0xa6>
    3d90:	0c 94 d8 2b 	jmp	0x57b0	; 0x57b0 <gc_execute_line.constprop.11+0x1ac2>
    3d94:	8f 5f       	subi	r24, 0xFF	; 255
    3d96:	8a 8f       	std	Y+26, r24	; 0x1a
    3d98:	be 01       	movw	r22, r28
    3d9a:	6a 5e       	subi	r22, 0xEA	; 234
    3d9c:	7f 4f       	sbci	r23, 0xFF	; 255
    3d9e:	ce 01       	movw	r24, r28
    3da0:	4a 96       	adiw	r24, 0x1a	; 26
    3da2:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    3da6:	88 23       	and	r24, r24
    3da8:	11 f4       	brne	.+4      	; 0x3dae <gc_execute_line.constprop.11+0xc0>
    3daa:	0c 94 db 2b 	jmp	0x57b6	; 0x57b6 <gc_execute_line.constprop.11+0x1ac8>
    3dae:	4e 88       	ldd	r4, Y+22	; 0x16
    3db0:	5f 88       	ldd	r5, Y+23	; 0x17
    3db2:	68 8c       	ldd	r6, Y+24	; 0x18
    3db4:	79 8c       	ldd	r7, Y+25	; 0x19
    3db6:	c3 01       	movw	r24, r6
    3db8:	b2 01       	movw	r22, r4
    3dba:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    3dbe:	06 2f       	mov	r16, r22
    3dc0:	70 e0       	ldi	r23, 0x00	; 0
    3dc2:	90 e0       	ldi	r25, 0x00	; 0
    3dc4:	80 e0       	ldi	r24, 0x00	; 0
    3dc6:	0e 94 ba 36 	call	0x6d74	; 0x6d74 <__floatsisf>
    3dca:	9b 01       	movw	r18, r22
    3dcc:	ac 01       	movw	r20, r24
    3dce:	c3 01       	movw	r24, r6
    3dd0:	b2 01       	movw	r22, r4
    3dd2:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    3dd6:	20 e0       	ldi	r18, 0x00	; 0
    3dd8:	30 e0       	ldi	r19, 0x00	; 0
    3dda:	48 ec       	ldi	r20, 0xC8	; 200
    3ddc:	52 e4       	ldi	r21, 0x42	; 66
    3dde:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    3de2:	0e 94 d5 38 	call	0x71aa	; 0x71aa <round>
    3de6:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    3dea:	cb 01       	movw	r24, r22
    3dec:	e7 e4       	ldi	r30, 0x47	; 71
    3dee:	de 16       	cp	r13, r30
    3df0:	29 f1       	breq	.+74     	; 0x3e3c <gc_execute_line.constprop.11+0x14e>
    3df2:	fd e4       	ldi	r31, 0x4D	; 77
    3df4:	df 16       	cp	r13, r31
    3df6:	09 f4       	brne	.+2      	; 0x3dfa <gc_execute_line.constprop.11+0x10c>
    3df8:	65 c1       	rjmp	.+714    	; 0x40c4 <gc_execute_line.constprop.11+0x3d6>
    3dfa:	ea eb       	ldi	r30, 0xBA	; 186
    3dfc:	ed 0d       	add	r30, r13
    3dfe:	e5 31       	cpi	r30, 0x15	; 21
    3e00:	08 f0       	brcs	.+2      	; 0x3e04 <gc_execute_line.constprop.11+0x116>
    3e02:	2c c0       	rjmp	.+88     	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3e04:	0e 2e       	mov	r0, r30
    3e06:	00 0c       	add	r0, r0
    3e08:	ff 0b       	sbc	r31, r31
    3e0a:	e7 5f       	subi	r30, 0xF7	; 247
    3e0c:	f0 4e       	sbci	r31, 0xE0	; 224
    3e0e:	0c 94 a8 39 	jmp	0x7350	; 0x7350 <__tablejump2__>
    3e12:	ab 20       	and	r10, r11
    3e14:	2e 1f       	adc	r18, r30
    3e16:	2e 1f       	adc	r18, r30
    3e18:	d8 20       	and	r13, r8
    3e1a:	e3 20       	and	r14, r3
    3e1c:	ee 20       	and	r14, r14
    3e1e:	f9 20       	and	r15, r9
    3e20:	2e 1f       	adc	r18, r30
    3e22:	fd 20       	and	r15, r13
    3e24:	2e 1f       	adc	r18, r30
    3e26:	0b 21       	and	r16, r11
    3e28:	2e 1f       	adc	r18, r30
    3e2a:	15 21       	and	r17, r5
    3e2c:	1f 21       	and	r17, r15
    3e2e:	29 21       	and	r18, r9
    3e30:	2e 1f       	adc	r18, r30
    3e32:	2e 1f       	adc	r18, r30
    3e34:	2e 1f       	adc	r18, r30
    3e36:	39 21       	and	r19, r9
    3e38:	46 21       	and	r20, r6
    3e3a:	53 21       	and	r21, r3
    3e3c:	08 32       	cpi	r16, 0x28	; 40
    3e3e:	09 f4       	brne	.+2      	; 0x3e42 <gc_execute_line.constprop.11+0x154>
    3e40:	dd c0       	rjmp	.+442    	; 0x3ffc <gc_execute_line.constprop.11+0x30e>
    3e42:	30 f5       	brcc	.+76     	; 0x3e90 <gc_execute_line.constprop.11+0x1a2>
    3e44:	04 31       	cpi	r16, 0x14	; 20
    3e46:	60 f4       	brcc	.+24     	; 0x3e60 <gc_execute_line.constprop.11+0x172>
    3e48:	01 31       	cpi	r16, 0x11	; 17
    3e4a:	08 f0       	brcs	.+2      	; 0x3e4e <gc_execute_line.constprop.11+0x160>
    3e4c:	98 c0       	rjmp	.+304    	; 0x3f7e <gc_execute_line.constprop.11+0x290>
    3e4e:	04 30       	cpi	r16, 0x04	; 4
    3e50:	09 f4       	brne	.+2      	; 0x3e54 <gc_execute_line.constprop.11+0x166>
    3e52:	74 c0       	rjmp	.+232    	; 0x3f3c <gc_execute_line.constprop.11+0x24e>
    3e54:	b0 f0       	brcs	.+44     	; 0x3e82 <gc_execute_line.constprop.11+0x194>
    3e56:	0a 30       	cpi	r16, 0x0A	; 10
    3e58:	09 f4       	brne	.+2      	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3e5a:	68 c0       	rjmp	.+208    	; 0x3f2c <gc_execute_line.constprop.11+0x23e>
    3e5c:	84 e1       	ldi	r24, 0x14	; 20
    3e5e:	96 c0       	rjmp	.+300    	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    3e60:	0c 31       	cpi	r16, 0x1C	; 28
    3e62:	09 f4       	brne	.+2      	; 0x3e66 <gc_execute_line.constprop.11+0x178>
    3e64:	63 c0       	rjmp	.+198    	; 0x3f2c <gc_execute_line.constprop.11+0x23e>
    3e66:	40 f4       	brcc	.+16     	; 0x3e78 <gc_execute_line.constprop.11+0x18a>
    3e68:	06 31       	cpi	r16, 0x16	; 22
    3e6a:	c0 f7       	brcc	.-16     	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3e6c:	25 e1       	ldi	r18, 0x15	; 21
    3e6e:	20 1b       	sub	r18, r16
    3e70:	20 93 da 06 	sts	0x06DA, r18	; 0x8006da <gc_block+0x3>
    3e74:	26 e0       	ldi	r18, 0x06	; 6
    3e76:	87 c0       	rjmp	.+270    	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    3e78:	0e 31       	cpi	r16, 0x1E	; 30
    3e7a:	09 f4       	brne	.+2      	; 0x3e7e <gc_execute_line.constprop.11+0x190>
    3e7c:	57 c0       	rjmp	.+174    	; 0x3f2c <gc_execute_line.constprop.11+0x23e>
    3e7e:	06 32       	cpi	r16, 0x26	; 38
    3e80:	69 f7       	brne	.-38     	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3e82:	4f 8d       	ldd	r20, Y+31	; 0x1f
    3e84:	41 11       	cpse	r20, r1
    3e86:	0c 94 de 2b 	jmp	0x57bc	; 0x57bc <gc_execute_line.constprop.11+0x1ace>
    3e8a:	52 e0       	ldi	r21, 0x02	; 2
    3e8c:	5f 8f       	std	Y+31, r21	; 0x1f
    3e8e:	28 c0       	rjmp	.+80     	; 0x3ee0 <gc_execute_line.constprop.11+0x1f2>
    3e90:	0d 33       	cpi	r16, 0x3D	; 61
    3e92:	09 f4       	brne	.+2      	; 0x3e96 <gc_execute_line.constprop.11+0x1a8>
    3e94:	ae c0       	rjmp	.+348    	; 0x3ff2 <gc_execute_line.constprop.11+0x304>
    3e96:	e0 f4       	brcc	.+56     	; 0x3ed0 <gc_execute_line.constprop.11+0x1e2>
    3e98:	05 33       	cpi	r16, 0x35	; 53
    3e9a:	09 f4       	brne	.+2      	; 0x3e9e <gc_execute_line.constprop.11+0x1b0>
    3e9c:	4f c0       	rjmp	.+158    	; 0x3f3c <gc_execute_line.constprop.11+0x24e>
    3e9e:	88 f4       	brcc	.+34     	; 0x3ec2 <gc_execute_line.constprop.11+0x1d4>
    3ea0:	0b 32       	cpi	r16, 0x2B	; 43
    3ea2:	11 f0       	breq	.+4      	; 0x3ea8 <gc_execute_line.constprop.11+0x1ba>
    3ea4:	01 33       	cpi	r16, 0x31	; 49
    3ea6:	d1 f6       	brne	.-76     	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3ea8:	af 8d       	ldd	r26, Y+31	; 0x1f
    3eaa:	a1 11       	cpse	r26, r1
    3eac:	0c 94 de 2b 	jmp	0x57bc	; 0x57bc <gc_execute_line.constprop.11+0x1ace>
    3eb0:	01 33       	cpi	r16, 0x31	; 49
    3eb2:	09 f0       	breq	.+2      	; 0x3eb6 <gc_execute_line.constprop.11+0x1c8>
    3eb4:	95 c0       	rjmp	.+298    	; 0x3fe0 <gc_execute_line.constprop.11+0x2f2>
    3eb6:	10 92 dd 06 	sts	0x06DD, r1	; 0x8006dd <gc_block+0x6>
    3eba:	b3 e0       	ldi	r27, 0x03	; 3
    3ebc:	bf 8f       	std	Y+31, r27	; 0x1f
    3ebe:	28 e0       	ldi	r18, 0x08	; 8
    3ec0:	4f c0       	rjmp	.+158    	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3ec2:	0c 33       	cpi	r16, 0x3C	; 60
    3ec4:	58 f6       	brcc	.-106    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3ec6:	06 53       	subi	r16, 0x36	; 54
    3ec8:	00 93 de 06 	sts	0x06DE, r16	; 0x8006de <gc_block+0x7>
    3ecc:	29 e0       	ldi	r18, 0x09	; 9
    3ece:	5b c0       	rjmp	.+182    	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    3ed0:	0c 35       	cpi	r16, 0x5C	; 92
    3ed2:	08 f5       	brcc	.+66     	; 0x3f16 <gc_execute_line.constprop.11+0x228>
    3ed4:	0a 35       	cpi	r16, 0x5A	; 90
    3ed6:	08 f0       	brcs	.+2      	; 0x3eda <gc_execute_line.constprop.11+0x1ec>
    3ed8:	73 c0       	rjmp	.+230    	; 0x3fc0 <gc_execute_line.constprop.11+0x2d2>
    3eda:	00 35       	cpi	r16, 0x50	; 80
    3edc:	09 f0       	breq	.+2      	; 0x3ee0 <gc_execute_line.constprop.11+0x1f2>
    3ede:	be cf       	rjmp	.-132    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3ee0:	00 93 d8 06 	sts	0x06D8, r16	; 0x8006d8 <gc_block+0x1>
    3ee4:	21 e0       	ldi	r18, 0x01	; 1
    3ee6:	06 32       	cpi	r16, 0x26	; 38
    3ee8:	09 f0       	breq	.+2      	; 0x3eec <gc_execute_line.constprop.11+0x1fe>
    3eea:	4d c0       	rjmp	.+154    	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    3eec:	84 31       	cpi	r24, 0x14	; 20
    3eee:	91 05       	cpc	r25, r1
    3ef0:	51 f0       	breq	.+20     	; 0x3f06 <gc_execute_line.constprop.11+0x218>
    3ef2:	8e 31       	cpi	r24, 0x1E	; 30
    3ef4:	91 05       	cpc	r25, r1
    3ef6:	39 f0       	breq	.+14     	; 0x3f06 <gc_execute_line.constprop.11+0x218>
    3ef8:	88 32       	cpi	r24, 0x28	; 40
    3efa:	91 05       	cpc	r25, r1
    3efc:	21 f0       	breq	.+8      	; 0x3f06 <gc_execute_line.constprop.11+0x218>
    3efe:	82 33       	cpi	r24, 0x32	; 50
    3f00:	91 05       	cpc	r25, r1
    3f02:	09 f0       	breq	.+2      	; 0x3f06 <gc_execute_line.constprop.11+0x218>
    3f04:	ab cf       	rjmp	.-170    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3f06:	b5 01       	movw	r22, r10
    3f08:	0e 94 72 39 	call	0x72e4	; 0x72e4 <__udivmodhi4>
    3f0c:	66 57       	subi	r22, 0x76	; 118
    3f0e:	60 93 d8 06 	sts	0x06D8, r22	; 0x8006d8 <gc_block+0x1>
    3f12:	21 e0       	ldi	r18, 0x01	; 1
    3f14:	25 c0       	rjmp	.+74     	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3f16:	0c 35       	cpi	r16, 0x5C	; 92
    3f18:	49 f0       	breq	.+18     	; 0x3f2c <gc_execute_line.constprop.11+0x23e>
    3f1a:	0f 35       	cpi	r16, 0x5F	; 95
    3f1c:	08 f0       	brcs	.+2      	; 0x3f20 <gc_execute_line.constprop.11+0x232>
    3f1e:	9e cf       	rjmp	.-196    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3f20:	2e e5       	ldi	r18, 0x5E	; 94
    3f22:	20 1b       	sub	r18, r16
    3f24:	20 93 d9 06 	sts	0x06D9, r18	; 0x8006d9 <gc_block+0x2>
    3f28:	25 e0       	ldi	r18, 0x05	; 5
    3f2a:	2d c0       	rjmp	.+90     	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    3f2c:	00 97       	sbiw	r24, 0x00	; 0
    3f2e:	31 f4       	brne	.+12     	; 0x3f3c <gc_execute_line.constprop.11+0x24e>
    3f30:	2f 8d       	ldd	r18, Y+31	; 0x1f
    3f32:	21 11       	cpse	r18, r1
    3f34:	0c 94 de 2b 	jmp	0x57bc	; 0x57bc <gc_execute_line.constprop.11+0x1ace>
    3f38:	31 e0       	ldi	r19, 0x01	; 1
    3f3a:	3f 8f       	std	Y+31, r19	; 0x1f
    3f3c:	00 93 d7 06 	sts	0x06D7, r16	; 0x8006d7 <gc_block>
    3f40:	20 2f       	mov	r18, r16
    3f42:	2d 7f       	andi	r18, 0xFD	; 253
    3f44:	2c 31       	cpi	r18, 0x1C	; 28
    3f46:	19 f0       	breq	.+6      	; 0x3f4e <gc_execute_line.constprop.11+0x260>
    3f48:	20 e0       	ldi	r18, 0x00	; 0
    3f4a:	0c 35       	cpi	r16, 0x5C	; 92
    3f4c:	e1 f4       	brne	.+56     	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    3f4e:	00 97       	sbiw	r24, 0x00	; 0
    3f50:	19 f0       	breq	.+6      	; 0x3f58 <gc_execute_line.constprop.11+0x26a>
    3f52:	0a 97       	sbiw	r24, 0x0a	; 10
    3f54:	09 f0       	breq	.+2      	; 0x3f58 <gc_execute_line.constprop.11+0x26a>
    3f56:	82 cf       	rjmp	.-252    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3f58:	60 0f       	add	r22, r16
    3f5a:	60 93 d7 06 	sts	0x06D7, r22	; 0x8006d7 <gc_block>
    3f5e:	20 e0       	ldi	r18, 0x00	; 0
    3f60:	c7 01       	movw	r24, r14
    3f62:	02 c0       	rjmp	.+4      	; 0x3f68 <gc_execute_line.constprop.11+0x27a>
    3f64:	88 0f       	add	r24, r24
    3f66:	99 1f       	adc	r25, r25
    3f68:	2a 95       	dec	r18
    3f6a:	e2 f7       	brpl	.-8      	; 0x3f64 <gc_execute_line.constprop.11+0x276>
    3f6c:	2b a5       	ldd	r18, Y+43	; 0x2b
    3f6e:	3c a5       	ldd	r19, Y+44	; 0x2c
    3f70:	28 23       	and	r18, r24
    3f72:	39 23       	and	r19, r25
    3f74:	23 2b       	or	r18, r19
    3f76:	09 f4       	brne	.+2      	; 0x3f7a <gc_execute_line.constprop.11+0x28c>
    3f78:	43 c0       	rjmp	.+134    	; 0x4000 <gc_execute_line.constprop.11+0x312>
    3f7a:	85 e1       	ldi	r24, 0x15	; 21
    3f7c:	07 c0       	rjmp	.+14     	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    3f7e:	01 51       	subi	r16, 0x11	; 17
    3f80:	00 93 dc 06 	sts	0x06DC, r16	; 0x8006dc <gc_block+0x5>
    3f84:	22 e0       	ldi	r18, 0x02	; 2
    3f86:	89 2b       	or	r24, r25
    3f88:	59 f3       	breq	.-42     	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3f8a:	87 e1       	ldi	r24, 0x17	; 23
    3f8c:	c6 5b       	subi	r28, 0xB6	; 182
    3f8e:	df 4f       	sbci	r29, 0xFF	; 255
    3f90:	0f b6       	in	r0, 0x3f	; 63
    3f92:	f8 94       	cli
    3f94:	de bf       	out	0x3e, r29	; 62
    3f96:	0f be       	out	0x3f, r0	; 63
    3f98:	cd bf       	out	0x3d, r28	; 61
    3f9a:	df 91       	pop	r29
    3f9c:	cf 91       	pop	r28
    3f9e:	1f 91       	pop	r17
    3fa0:	0f 91       	pop	r16
    3fa2:	ff 90       	pop	r15
    3fa4:	ef 90       	pop	r14
    3fa6:	df 90       	pop	r13
    3fa8:	cf 90       	pop	r12
    3faa:	bf 90       	pop	r11
    3fac:	af 90       	pop	r10
    3fae:	9f 90       	pop	r9
    3fb0:	8f 90       	pop	r8
    3fb2:	7f 90       	pop	r7
    3fb4:	6f 90       	pop	r6
    3fb6:	5f 90       	pop	r5
    3fb8:	4f 90       	pop	r4
    3fba:	3f 90       	pop	r3
    3fbc:	2f 90       	pop	r2
    3fbe:	08 95       	ret
    3fc0:	89 2b       	or	r24, r25
    3fc2:	29 f4       	brne	.+10     	; 0x3fce <gc_execute_line.constprop.11+0x2e0>
    3fc4:	0a 55       	subi	r16, 0x5A	; 90
    3fc6:	00 93 db 06 	sts	0x06DB, r16	; 0x8006db <gc_block+0x4>
    3fca:	23 e0       	ldi	r18, 0x03	; 3
    3fcc:	c9 cf       	rjmp	.-110    	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3fce:	6a 30       	cpi	r22, 0x0A	; 10
    3fd0:	71 05       	cpc	r23, r1
    3fd2:	09 f0       	breq	.+2      	; 0x3fd6 <gc_execute_line.constprop.11+0x2e8>
    3fd4:	43 cf       	rjmp	.-378    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3fd6:	0a 35       	cpi	r16, 0x5A	; 90
    3fd8:	09 f4       	brne	.+2      	; 0x3fdc <gc_execute_line.constprop.11+0x2ee>
    3fda:	40 cf       	rjmp	.-384    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3fdc:	24 e0       	ldi	r18, 0x04	; 4
    3fde:	c0 cf       	rjmp	.-128    	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3fe0:	0a 97       	sbiw	r24, 0x0a	; 10
    3fe2:	09 f0       	breq	.+2      	; 0x3fe6 <gc_execute_line.constprop.11+0x2f8>
    3fe4:	3b cf       	rjmp	.-394    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3fe6:	e1 e0       	ldi	r30, 0x01	; 1
    3fe8:	e0 93 dd 06 	sts	0x06DD, r30	; 0x8006dd <gc_block+0x6>
    3fec:	f3 e0       	ldi	r31, 0x03	; 3
    3fee:	ff 8f       	std	Y+31, r31	; 0x1f
    3ff0:	66 cf       	rjmp	.-308    	; 0x3ebe <gc_execute_line.constprop.11+0x1d0>
    3ff2:	89 2b       	or	r24, r25
    3ff4:	09 f0       	breq	.+2      	; 0x3ff8 <gc_execute_line.constprop.11+0x30a>
    3ff6:	32 cf       	rjmp	.-412    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    3ff8:	2a e0       	ldi	r18, 0x0A	; 10
    3ffa:	b2 cf       	rjmp	.-156    	; 0x3f60 <gc_execute_line.constprop.11+0x272>
    3ffc:	27 e0       	ldi	r18, 0x07	; 7
    3ffe:	c3 cf       	rjmp	.-122    	; 0x3f86 <gc_execute_line.constprop.11+0x298>
    4000:	2b a5       	ldd	r18, Y+43	; 0x2b
    4002:	3c a5       	ldd	r19, Y+44	; 0x2c
    4004:	28 2b       	or	r18, r24
    4006:	39 2b       	or	r19, r25
    4008:	3c a7       	std	Y+44, r19	; 0x2c
    400a:	2b a7       	std	Y+43, r18	; 0x2b
    400c:	8a 8d       	ldd	r24, Y+26	; 0x1a
    400e:	e8 2f       	mov	r30, r24
    4010:	f0 e0       	ldi	r31, 0x00	; 0
    4012:	ef 5e       	subi	r30, 0xEF	; 239
    4014:	f8 4f       	sbci	r31, 0xF8	; 248
    4016:	d0 80       	ld	r13, Z
    4018:	d1 10       	cpse	r13, r1
    401a:	b6 ce       	rjmp	.-660    	; 0x3d88 <gc_execute_line.constprop.11+0x9a>
    401c:	3b 8d       	ldd	r19, Y+27	; 0x1b
    401e:	33 23       	and	r19, r19
    4020:	29 f0       	breq	.+10     	; 0x402c <gc_execute_line.constprop.11+0x33e>
    4022:	4f 8d       	ldd	r20, Y+31	; 0x1f
    4024:	41 11       	cpse	r20, r1
    4026:	02 c0       	rjmp	.+4      	; 0x402c <gc_execute_line.constprop.11+0x33e>
    4028:	52 e0       	ldi	r21, 0x02	; 2
    402a:	5f 8f       	std	Y+31, r21	; 0x1f
    402c:	25 fe       	sbrs	r2, 5
    402e:	0f c0       	rjmp	.+30     	; 0x404e <gc_execute_line.constprop.11+0x360>
    4030:	80 91 f4 06 	lds	r24, 0x06F4	; 0x8006f4 <gc_block+0x1d>
    4034:	90 91 f5 06 	lds	r25, 0x06F5	; 0x8006f5 <gc_block+0x1e>
    4038:	a0 91 f6 06 	lds	r26, 0x06F6	; 0x8006f6 <gc_block+0x1f>
    403c:	b0 91 f7 06 	lds	r27, 0x06F7	; 0x8006f7 <gc_block+0x20>
    4040:	81 38       	cpi	r24, 0x81	; 129
    4042:	96 49       	sbci	r25, 0x96	; 150
    4044:	a8 49       	sbci	r26, 0x98	; 152
    4046:	b1 05       	cpc	r27, r1
    4048:	14 f0       	brlt	.+4      	; 0x404e <gc_execute_line.constprop.11+0x360>
    404a:	0c 94 ea 2b 	jmp	0x57d4	; 0x57d4 <gc_execute_line.constprop.11+0x1ae6>
    404e:	fb a1       	ldd	r31, Y+35	; 0x23
    4050:	ff 23       	and	r31, r31
    4052:	09 f4       	brne	.+2      	; 0x4056 <gc_execute_line.constprop.11+0x368>
    4054:	35 c1       	rjmp	.+618    	; 0x42c0 <gc_execute_line.constprop.11+0x5d2>
    4056:	20 fe       	sbrs	r2, 0
    4058:	45 c1       	rjmp	.+650    	; 0x42e4 <gc_execute_line.constprop.11+0x5f6>
    405a:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    405e:	81 30       	cpi	r24, 0x01	; 1
    4060:	b1 f4       	brne	.+44     	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    4062:	23 e3       	ldi	r18, 0x33	; 51
    4064:	33 e3       	ldi	r19, 0x33	; 51
    4066:	4b ec       	ldi	r20, 0xCB	; 203
    4068:	51 e4       	ldi	r21, 0x41	; 65
    406a:	60 91 e3 06 	lds	r22, 0x06E3	; 0x8006e3 <gc_block+0xc>
    406e:	70 91 e4 06 	lds	r23, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4072:	80 91 e5 06 	lds	r24, 0x06E5	; 0x8006e5 <gc_block+0xe>
    4076:	90 91 e6 06 	lds	r25, 0x06E6	; 0x8006e6 <gc_block+0xf>
    407a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    407e:	60 93 e3 06 	sts	0x06E3, r22	; 0x8006e3 <gc_block+0xc>
    4082:	70 93 e4 06 	sts	0x06E4, r23	; 0x8006e4 <gc_block+0xd>
    4086:	80 93 e5 06 	sts	0x06E5, r24	; 0x8006e5 <gc_block+0xe>
    408a:	90 93 e6 06 	sts	0x06E6, r25	; 0x8006e6 <gc_block+0xf>
    408e:	30 fc       	sbrc	r3, 0
    4090:	10 c0       	rjmp	.+32     	; 0x40b2 <gc_execute_line.constprop.11+0x3c4>
    4092:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4096:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    409a:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    409e:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    40a2:	80 93 00 07 	sts	0x0700, r24	; 0x800700 <gc_block+0x29>
    40a6:	90 93 01 07 	sts	0x0701, r25	; 0x800701 <gc_block+0x2a>
    40aa:	a0 93 02 07 	sts	0x0702, r26	; 0x800702 <gc_block+0x2b>
    40ae:	b0 93 03 07 	sts	0x0703, r27	; 0x800703 <gc_block+0x2c>
    40b2:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    40b6:	84 30       	cpi	r24, 0x04	; 4
    40b8:	09 f0       	breq	.+2      	; 0x40bc <gc_execute_line.constprop.11+0x3ce>
    40ba:	2f c1       	rjmp	.+606    	; 0x431a <gc_execute_line.constprop.11+0x62c>
    40bc:	26 fc       	sbrc	r2, 6
    40be:	2b c1       	rjmp	.+598    	; 0x4316 <gc_execute_line.constprop.11+0x628>
    40c0:	8c e1       	ldi	r24, 0x1C	; 28
    40c2:	64 cf       	rjmp	.-312    	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    40c4:	89 2b       	or	r24, r25
    40c6:	09 f0       	breq	.+2      	; 0x40ca <gc_execute_line.constprop.11+0x3dc>
    40c8:	60 cf       	rjmp	.-320    	; 0x3f8a <gc_execute_line.constprop.11+0x29c>
    40ca:	06 30       	cpi	r16, 0x06	; 6
    40cc:	50 f4       	brcc	.+20     	; 0x40e2 <gc_execute_line.constprop.11+0x3f4>
    40ce:	03 30       	cpi	r16, 0x03	; 3
    40d0:	98 f0       	brcs	.+38     	; 0x40f8 <gc_execute_line.constprop.11+0x40a>
    40d2:	04 30       	cpi	r16, 0x04	; 4
    40d4:	d9 f0       	breq	.+54     	; 0x410c <gc_execute_line.constprop.11+0x41e>
    40d6:	80 e1       	ldi	r24, 0x10	; 16
    40d8:	05 30       	cpi	r16, 0x05	; 5
    40da:	c9 f4       	brne	.+50     	; 0x410e <gc_execute_line.constprop.11+0x420>
    40dc:	10 92 e1 06 	sts	0x06E1, r1	; 0x8006e1 <gc_block+0xa>
    40e0:	18 c0       	rjmp	.+48     	; 0x4112 <gc_execute_line.constprop.11+0x424>
    40e2:	08 30       	cpi	r16, 0x08	; 8
    40e4:	08 f4       	brcc	.+2      	; 0x40e8 <gc_execute_line.constprop.11+0x3fa>
    40e6:	ba ce       	rjmp	.-652    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    40e8:	0a 30       	cpi	r16, 0x0A	; 10
    40ea:	48 f1       	brcs	.+82     	; 0x413e <gc_execute_line.constprop.11+0x450>
    40ec:	0e 31       	cpi	r16, 0x1E	; 30
    40ee:	09 f0       	breq	.+2      	; 0x40f2 <gc_execute_line.constprop.11+0x404>
    40f0:	b5 ce       	rjmp	.-662    	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    40f2:	00 93 df 06 	sts	0x06DF, r16	; 0x8006df <gc_block+0x8>
    40f6:	04 c0       	rjmp	.+8      	; 0x4100 <gc_execute_line.constprop.11+0x412>
    40f8:	00 23       	and	r16, r16
    40fa:	21 f0       	breq	.+8      	; 0x4104 <gc_execute_line.constprop.11+0x416>
    40fc:	01 30       	cpi	r16, 0x01	; 1
    40fe:	c9 f7       	brne	.-14     	; 0x40f2 <gc_execute_line.constprop.11+0x404>
    4100:	8b e0       	ldi	r24, 0x0B	; 11
    4102:	08 c0       	rjmp	.+16     	; 0x4114 <gc_execute_line.constprop.11+0x426>
    4104:	33 e0       	ldi	r19, 0x03	; 3
    4106:	30 93 df 06 	sts	0x06DF, r19	; 0x8006df <gc_block+0x8>
    410a:	fa cf       	rjmp	.-12     	; 0x4100 <gc_execute_line.constprop.11+0x412>
    410c:	80 e2       	ldi	r24, 0x20	; 32
    410e:	80 93 e1 06 	sts	0x06E1, r24	; 0x8006e1 <gc_block+0xa>
    4112:	8c e0       	ldi	r24, 0x0C	; 12
    4114:	a7 01       	movw	r20, r14
    4116:	02 c0       	rjmp	.+4      	; 0x411c <gc_execute_line.constprop.11+0x42e>
    4118:	44 0f       	add	r20, r20
    411a:	55 1f       	adc	r21, r21
    411c:	8a 95       	dec	r24
    411e:	e2 f7       	brpl	.-8      	; 0x4118 <gc_execute_line.constprop.11+0x42a>
    4120:	ca 01       	movw	r24, r20
    4122:	2b a5       	ldd	r18, Y+43	; 0x2b
    4124:	3c a5       	ldd	r19, Y+44	; 0x2c
    4126:	24 23       	and	r18, r20
    4128:	39 23       	and	r19, r25
    412a:	23 2b       	or	r18, r19
    412c:	09 f0       	breq	.+2      	; 0x4130 <gc_execute_line.constprop.11+0x442>
    412e:	25 cf       	rjmp	.-438    	; 0x3f7a <gc_execute_line.constprop.11+0x28c>
    4130:	ab a5       	ldd	r26, Y+43	; 0x2b
    4132:	bc a5       	ldd	r27, Y+44	; 0x2c
    4134:	a4 2b       	or	r26, r20
    4136:	b9 2b       	or	r27, r25
    4138:	bc a7       	std	Y+44, r27	; 0x2c
    413a:	ab a7       	std	Y+43, r26	; 0x2b
    413c:	67 cf       	rjmp	.-306    	; 0x400c <gc_execute_line.constprop.11+0x31e>
    413e:	09 30       	cpi	r16, 0x09	; 9
    4140:	39 f0       	breq	.+14     	; 0x4150 <gc_execute_line.constprop.11+0x462>
    4142:	80 91 e0 06 	lds	r24, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4146:	80 64       	ori	r24, 0x40	; 64
    4148:	80 93 e0 06 	sts	0x06E0, r24	; 0x8006e0 <gc_block+0x9>
    414c:	8d e0       	ldi	r24, 0x0D	; 13
    414e:	e2 cf       	rjmp	.-60     	; 0x4114 <gc_execute_line.constprop.11+0x426>
    4150:	10 92 e0 06 	sts	0x06E0, r1	; 0x8006e0 <gc_block+0x9>
    4154:	fb cf       	rjmp	.-10     	; 0x414c <gc_execute_line.constprop.11+0x45e>
    4156:	40 92 e3 06 	sts	0x06E3, r4	; 0x8006e3 <gc_block+0xc>
    415a:	50 92 e4 06 	sts	0x06E4, r5	; 0x8006e4 <gc_block+0xd>
    415e:	60 92 e5 06 	sts	0x06E5, r6	; 0x8006e5 <gc_block+0xe>
    4162:	70 92 e6 06 	sts	0x06E6, r7	; 0x8006e6 <gc_block+0xf>
    4166:	80 e0       	ldi	r24, 0x00	; 0
    4168:	67 01       	movw	r12, r14
    416a:	08 2e       	mov	r0, r24
    416c:	02 c0       	rjmp	.+4      	; 0x4172 <gc_execute_line.constprop.11+0x484>
    416e:	cc 0c       	add	r12, r12
    4170:	dd 1c       	adc	r13, r13
    4172:	0a 94       	dec	r0
    4174:	e2 f7       	brpl	.-8      	; 0x416e <gc_execute_line.constprop.11+0x480>
    4176:	96 01       	movw	r18, r12
    4178:	22 21       	and	r18, r2
    417a:	33 21       	and	r19, r3
    417c:	23 2b       	or	r18, r19
    417e:	11 f0       	breq	.+4      	; 0x4184 <gc_execute_line.constprop.11+0x496>
    4180:	0c 94 e4 2b 	jmp	0x57c8	; 0x57c8 <gc_execute_line.constprop.11+0x1ada>
    4184:	94 01       	movw	r18, r8
    4186:	02 c0       	rjmp	.+4      	; 0x418c <gc_execute_line.constprop.11+0x49e>
    4188:	35 95       	asr	r19
    418a:	27 95       	ror	r18
    418c:	8a 95       	dec	r24
    418e:	e2 f7       	brpl	.-8      	; 0x4188 <gc_execute_line.constprop.11+0x49a>
    4190:	20 ff       	sbrs	r18, 0
    4192:	0b c0       	rjmp	.+22     	; 0x41aa <gc_execute_line.constprop.11+0x4bc>
    4194:	20 e0       	ldi	r18, 0x00	; 0
    4196:	30 e0       	ldi	r19, 0x00	; 0
    4198:	a9 01       	movw	r20, r18
    419a:	c3 01       	movw	r24, r6
    419c:	b2 01       	movw	r22, r4
    419e:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    41a2:	87 ff       	sbrs	r24, 7
    41a4:	02 c0       	rjmp	.+4      	; 0x41aa <gc_execute_line.constprop.11+0x4bc>
    41a6:	0c 94 e7 2b 	jmp	0x57ce	; 0x57ce <gc_execute_line.constprop.11+0x1ae0>
    41aa:	2c 28       	or	r2, r12
    41ac:	3d 28       	or	r3, r13
    41ae:	2e cf       	rjmp	.-420    	; 0x400c <gc_execute_line.constprop.11+0x31e>
    41b0:	40 92 e7 06 	sts	0x06E7, r4	; 0x8006e7 <gc_block+0x10>
    41b4:	50 92 e8 06 	sts	0x06E8, r5	; 0x8006e8 <gc_block+0x11>
    41b8:	60 92 e9 06 	sts	0x06E9, r6	; 0x8006e9 <gc_block+0x12>
    41bc:	70 92 ea 06 	sts	0x06EA, r7	; 0x8006ea <gc_block+0x13>
    41c0:	11 60       	ori	r17, 0x01	; 1
    41c2:	81 e0       	ldi	r24, 0x01	; 1
    41c4:	d1 cf       	rjmp	.-94     	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    41c6:	40 92 eb 06 	sts	0x06EB, r4	; 0x8006eb <gc_block+0x14>
    41ca:	50 92 ec 06 	sts	0x06EC, r5	; 0x8006ec <gc_block+0x15>
    41ce:	60 92 ed 06 	sts	0x06ED, r6	; 0x8006ed <gc_block+0x16>
    41d2:	70 92 ee 06 	sts	0x06EE, r7	; 0x8006ee <gc_block+0x17>
    41d6:	12 60       	ori	r17, 0x02	; 2
    41d8:	82 e0       	ldi	r24, 0x02	; 2
    41da:	c6 cf       	rjmp	.-116    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    41dc:	40 92 ef 06 	sts	0x06EF, r4	; 0x8006ef <gc_block+0x18>
    41e0:	50 92 f0 06 	sts	0x06F0, r5	; 0x8006f0 <gc_block+0x19>
    41e4:	60 92 f1 06 	sts	0x06F1, r6	; 0x8006f1 <gc_block+0x1a>
    41e8:	70 92 f2 06 	sts	0x06F2, r7	; 0x8006f2 <gc_block+0x1b>
    41ec:	14 60       	ori	r17, 0x04	; 4
    41ee:	83 e0       	ldi	r24, 0x03	; 3
    41f0:	bb cf       	rjmp	.-138    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    41f2:	00 93 f3 06 	sts	0x06F3, r16	; 0x8006f3 <gc_block+0x1c>
    41f6:	84 e0       	ldi	r24, 0x04	; 4
    41f8:	b7 cf       	rjmp	.-146    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    41fa:	c3 01       	movw	r24, r6
    41fc:	b2 01       	movw	r22, r4
    41fe:	0e 94 82 36 	call	0x6d04	; 0x6d04 <__fixsfsi>
    4202:	60 93 f4 06 	sts	0x06F4, r22	; 0x8006f4 <gc_block+0x1d>
    4206:	70 93 f5 06 	sts	0x06F5, r23	; 0x8006f5 <gc_block+0x1e>
    420a:	80 93 f6 06 	sts	0x06F6, r24	; 0x8006f6 <gc_block+0x1f>
    420e:	90 93 f7 06 	sts	0x06F7, r25	; 0x8006f7 <gc_block+0x20>
    4212:	85 e0       	ldi	r24, 0x05	; 5
    4214:	a9 cf       	rjmp	.-174    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    4216:	40 92 f8 06 	sts	0x06F8, r4	; 0x8006f8 <gc_block+0x21>
    421a:	50 92 f9 06 	sts	0x06F9, r5	; 0x8006f9 <gc_block+0x22>
    421e:	60 92 fa 06 	sts	0x06FA, r6	; 0x8006fa <gc_block+0x23>
    4222:	70 92 fb 06 	sts	0x06FB, r7	; 0x8006fb <gc_block+0x24>
    4226:	86 e0       	ldi	r24, 0x06	; 6
    4228:	9f cf       	rjmp	.-194    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    422a:	40 92 fc 06 	sts	0x06FC, r4	; 0x8006fc <gc_block+0x25>
    422e:	50 92 fd 06 	sts	0x06FD, r5	; 0x8006fd <gc_block+0x26>
    4232:	60 92 fe 06 	sts	0x06FE, r6	; 0x8006fe <gc_block+0x27>
    4236:	70 92 ff 06 	sts	0x06FF, r7	; 0x8006ff <gc_block+0x28>
    423a:	87 e0       	ldi	r24, 0x07	; 7
    423c:	95 cf       	rjmp	.-214    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    423e:	40 92 00 07 	sts	0x0700, r4	; 0x800700 <gc_block+0x29>
    4242:	50 92 01 07 	sts	0x0701, r5	; 0x800701 <gc_block+0x2a>
    4246:	60 92 02 07 	sts	0x0702, r6	; 0x800702 <gc_block+0x2b>
    424a:	70 92 03 07 	sts	0x0703, r7	; 0x800703 <gc_block+0x2c>
    424e:	88 e0       	ldi	r24, 0x08	; 8
    4250:	8b cf       	rjmp	.-234    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    4252:	20 e0       	ldi	r18, 0x00	; 0
    4254:	30 e0       	ldi	r19, 0x00	; 0
    4256:	4f e7       	ldi	r20, 0x7F	; 127
    4258:	53 e4       	ldi	r21, 0x43	; 67
    425a:	c3 01       	movw	r24, r6
    425c:	b2 01       	movw	r22, r4
    425e:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    4262:	18 16       	cp	r1, r24
    4264:	14 f4       	brge	.+4      	; 0x426a <gc_execute_line.constprop.11+0x57c>
    4266:	0c 94 e1 2b 	jmp	0x57c2	; 0x57c2 <gc_execute_line.constprop.11+0x1ad4>
    426a:	00 93 04 07 	sts	0x0704, r16	; 0x800704 <gc_block+0x2d>
    426e:	89 e0       	ldi	r24, 0x09	; 9
    4270:	7b cf       	rjmp	.-266    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    4272:	40 92 05 07 	sts	0x0705, r4	; 0x800705 <gc_block+0x2e>
    4276:	50 92 06 07 	sts	0x0706, r5	; 0x800706 <gc_block+0x2f>
    427a:	60 92 07 07 	sts	0x0707, r6	; 0x800707 <gc_block+0x30>
    427e:	70 92 08 07 	sts	0x0708, r7	; 0x800708 <gc_block+0x31>
    4282:	bb 8d       	ldd	r27, Y+27	; 0x1b
    4284:	b1 60       	ori	r27, 0x01	; 1
    4286:	bb 8f       	std	Y+27, r27	; 0x1b
    4288:	8a e0       	ldi	r24, 0x0A	; 10
    428a:	6e cf       	rjmp	.-292    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    428c:	40 92 09 07 	sts	0x0709, r4	; 0x800709 <gc_block+0x32>
    4290:	50 92 0a 07 	sts	0x070A, r5	; 0x80070a <gc_block+0x33>
    4294:	60 92 0b 07 	sts	0x070B, r6	; 0x80070b <gc_block+0x34>
    4298:	70 92 0c 07 	sts	0x070C, r7	; 0x80070c <gc_block+0x35>
    429c:	eb 8d       	ldd	r30, Y+27	; 0x1b
    429e:	e2 60       	ori	r30, 0x02	; 2
    42a0:	eb 8f       	std	Y+27, r30	; 0x1b
    42a2:	8b e0       	ldi	r24, 0x0B	; 11
    42a4:	61 cf       	rjmp	.-318    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    42a6:	40 92 0d 07 	sts	0x070D, r4	; 0x80070d <gc_block+0x36>
    42aa:	50 92 0e 07 	sts	0x070E, r5	; 0x80070e <gc_block+0x37>
    42ae:	60 92 0f 07 	sts	0x070F, r6	; 0x80070f <gc_block+0x38>
    42b2:	70 92 10 07 	sts	0x0710, r7	; 0x800710 <gc_block+0x39>
    42b6:	fb 8d       	ldd	r31, Y+27	; 0x1b
    42b8:	f4 60       	ori	r31, 0x04	; 4
    42ba:	fb 8f       	std	Y+27, r31	; 0x1b
    42bc:	8c e0       	ldi	r24, 0x0C	; 12
    42be:	54 cf       	rjmp	.-344    	; 0x4168 <gc_execute_line.constprop.11+0x47a>
    42c0:	80 91 d9 06 	lds	r24, 0x06D9	; 0x8006d9 <gc_block+0x2>
    42c4:	81 30       	cpi	r24, 0x01	; 1
    42c6:	81 f4       	brne	.+32     	; 0x42e8 <gc_execute_line.constprop.11+0x5fa>
    42c8:	2f 8d       	ldd	r18, Y+31	; 0x1f
    42ca:	22 30       	cpi	r18, 0x02	; 2
    42cc:	09 f0       	breq	.+2      	; 0x42d0 <gc_execute_line.constprop.11+0x5e2>
    42ce:	df ce       	rjmp	.-578    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    42d0:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    42d4:	80 35       	cpi	r24, 0x50	; 80
    42d6:	09 f4       	brne	.+2      	; 0x42da <gc_execute_line.constprop.11+0x5ec>
    42d8:	da ce       	rjmp	.-588    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    42da:	88 23       	and	r24, r24
    42dc:	09 f4       	brne	.+2      	; 0x42e0 <gc_execute_line.constprop.11+0x5f2>
    42de:	d7 ce       	rjmp	.-594    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    42e0:	20 fc       	sbrc	r2, 0
    42e2:	d5 ce       	rjmp	.-598    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    42e4:	86 e1       	ldi	r24, 0x16	; 22
    42e6:	52 ce       	rjmp	.-860    	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    42e8:	80 91 98 06 	lds	r24, 0x0698	; 0x800698 <gc_state+0x1>
    42ec:	81 11       	cpse	r24, r1
    42ee:	cf ce       	rjmp	.-610    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    42f0:	20 fc       	sbrc	r2, 0
    42f2:	b3 ce       	rjmp	.-666    	; 0x405a <gc_execute_line.constprop.11+0x36c>
    42f4:	80 91 a6 06 	lds	r24, 0x06A6	; 0x8006a6 <gc_state+0xf>
    42f8:	90 91 a7 06 	lds	r25, 0x06A7	; 0x8006a7 <gc_state+0x10>
    42fc:	a0 91 a8 06 	lds	r26, 0x06A8	; 0x8006a8 <gc_state+0x11>
    4300:	b0 91 a9 06 	lds	r27, 0x06A9	; 0x8006a9 <gc_state+0x12>
    4304:	80 93 e3 06 	sts	0x06E3, r24	; 0x8006e3 <gc_block+0xc>
    4308:	90 93 e4 06 	sts	0x06E4, r25	; 0x8006e4 <gc_block+0xd>
    430c:	a0 93 e5 06 	sts	0x06E5, r26	; 0x8006e5 <gc_block+0xe>
    4310:	b0 93 e6 06 	sts	0x06E6, r27	; 0x8006e6 <gc_block+0xf>
    4314:	bc ce       	rjmp	.-648    	; 0x408e <gc_execute_line.constprop.11+0x3a0>
    4316:	e8 94       	clt
    4318:	26 f8       	bld	r2, 6
    431a:	80 91 dc 06 	lds	r24, 0x06DC	; 0x8006dc <gc_block+0x5>
    431e:	88 23       	and	r24, r24
    4320:	49 f0       	breq	.+18     	; 0x4334 <gc_execute_line.constprop.11+0x646>
    4322:	81 30       	cpi	r24, 0x01	; 1
    4324:	09 f4       	brne	.+2      	; 0x4328 <gc_execute_line.constprop.11+0x63a>
    4326:	b1 c0       	rjmp	.+354    	; 0x448a <gc_execute_line.constprop.11+0x79c>
    4328:	1f ae       	std	Y+63, r1	; 0x3f
    432a:	52 e0       	ldi	r21, 0x02	; 2
    432c:	59 af       	std	Y+57, r21	; 0x39
    432e:	81 e0       	ldi	r24, 0x01	; 1
    4330:	8f ab       	std	Y+55, r24	; 0x37
    4332:	05 c0       	rjmp	.+10     	; 0x433e <gc_execute_line.constprop.11+0x650>
    4334:	32 e0       	ldi	r19, 0x02	; 2
    4336:	3f af       	std	Y+63, r19	; 0x3f
    4338:	41 e0       	ldi	r20, 0x01	; 1
    433a:	49 af       	std	Y+57, r20	; 0x39
    433c:	1f aa       	std	Y+55, r1	; 0x37
    433e:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    4342:	81 30       	cpi	r24, 0x01	; 1
    4344:	71 f5       	brne	.+92     	; 0x43a2 <gc_execute_line.constprop.11+0x6b4>
    4346:	07 ed       	ldi	r16, 0xD7	; 215
    4348:	c0 2e       	mov	r12, r16
    434a:	06 e0       	ldi	r16, 0x06	; 6
    434c:	d0 2e       	mov	r13, r16
    434e:	f1 2c       	mov	r15, r1
    4350:	e1 2c       	mov	r14, r1
    4352:	bb 8d       	ldd	r27, Y+27	; 0x1b
    4354:	ab 2e       	mov	r10, r27
    4356:	b1 2c       	mov	r11, r1
    4358:	c5 01       	movw	r24, r10
    435a:	0e 2c       	mov	r0, r14
    435c:	02 c0       	rjmp	.+4      	; 0x4362 <gc_execute_line.constprop.11+0x674>
    435e:	95 95       	asr	r25
    4360:	87 95       	ror	r24
    4362:	0a 94       	dec	r0
    4364:	e2 f7       	brpl	.-8      	; 0x435e <gc_execute_line.constprop.11+0x670>
    4366:	80 ff       	sbrs	r24, 0
    4368:	12 c0       	rjmp	.+36     	; 0x438e <gc_execute_line.constprop.11+0x6a0>
    436a:	23 e3       	ldi	r18, 0x33	; 51
    436c:	33 e3       	ldi	r19, 0x33	; 51
    436e:	4b ec       	ldi	r20, 0xCB	; 203
    4370:	51 e4       	ldi	r21, 0x41	; 65
    4372:	f6 01       	movw	r30, r12
    4374:	66 a5       	ldd	r22, Z+46	; 0x2e
    4376:	77 a5       	ldd	r23, Z+47	; 0x2f
    4378:	80 a9       	ldd	r24, Z+48	; 0x30
    437a:	91 a9       	ldd	r25, Z+49	; 0x31
    437c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4380:	d6 01       	movw	r26, r12
    4382:	9e 96       	adiw	r26, 0x2e	; 46
    4384:	6d 93       	st	X+, r22
    4386:	7d 93       	st	X+, r23
    4388:	8d 93       	st	X+, r24
    438a:	9c 93       	st	X, r25
    438c:	d1 97       	sbiw	r26, 0x31	; 49
    438e:	bf ef       	ldi	r27, 0xFF	; 255
    4390:	eb 1a       	sub	r14, r27
    4392:	fb 0a       	sbc	r15, r27
    4394:	e4 e0       	ldi	r30, 0x04	; 4
    4396:	ce 0e       	add	r12, r30
    4398:	d1 1c       	adc	r13, r1
    439a:	f3 e0       	ldi	r31, 0x03	; 3
    439c:	ef 16       	cp	r14, r31
    439e:	f1 04       	cpc	r15, r1
    43a0:	d9 f6       	brne	.-74     	; 0x4358 <gc_execute_line.constprop.11+0x66a>
    43a2:	2f 8d       	ldd	r18, Y+31	; 0x1f
    43a4:	23 30       	cpi	r18, 0x03	; 3
    43a6:	49 f4       	brne	.+18     	; 0x43ba <gc_execute_line.constprop.11+0x6cc>
    43a8:	80 91 dd 06 	lds	r24, 0x06DD	; 0x8006dd <gc_block+0x6>
    43ac:	81 30       	cpi	r24, 0x01	; 1
    43ae:	29 f4       	brne	.+10     	; 0x43ba <gc_execute_line.constprop.11+0x6cc>
    43b0:	3b 8d       	ldd	r19, Y+27	; 0x1b
    43b2:	85 e2       	ldi	r24, 0x25	; 37
    43b4:	34 30       	cpi	r19, 0x04	; 4
    43b6:	09 f0       	breq	.+2      	; 0x43ba <gc_execute_line.constprop.11+0x6cc>
    43b8:	e9 cd       	rjmp	.-1070   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    43ba:	8c e0       	ldi	r24, 0x0C	; 12
    43bc:	eb eb       	ldi	r30, 0xBB	; 187
    43be:	f6 e0       	ldi	r31, 0x06	; 6
    43c0:	de 01       	movw	r26, r28
    43c2:	11 96       	adiw	r26, 0x01	; 1
    43c4:	01 90       	ld	r0, Z+
    43c6:	0d 92       	st	X+, r0
    43c8:	8a 95       	dec	r24
    43ca:	e1 f7       	brne	.-8      	; 0x43c4 <gc_execute_line.constprop.11+0x6d6>
    43cc:	4b a5       	ldd	r20, Y+43	; 0x2b
    43ce:	5c a5       	ldd	r21, Y+44	; 0x2c
    43d0:	51 fd       	sbrc	r21, 1
    43d2:	61 c0       	rjmp	.+194    	; 0x4496 <gc_execute_line.constprop.11+0x7a8>
    43d4:	00 91 d7 06 	lds	r16, 0x06D7	; 0x8006d7 <gc_block>
    43d8:	0a 30       	cpi	r16, 0x0A	; 10
    43da:	09 f4       	brne	.+2      	; 0x43de <gc_execute_line.constprop.11+0x6f0>
    43dc:	70 c0       	rjmp	.+224    	; 0x44be <gc_execute_line.constprop.11+0x7d0>
    43de:	0c 35       	cpi	r16, 0x5C	; 92
    43e0:	09 f4       	brne	.+2      	; 0x43e4 <gc_execute_line.constprop.11+0x6f6>
    43e2:	0d c1       	rjmp	.+538    	; 0x45fe <gc_execute_line.constprop.11+0x910>
    43e4:	8f 8d       	ldd	r24, Y+31	; 0x1f
    43e6:	83 30       	cpi	r24, 0x03	; 3
    43e8:	d1 f1       	breq	.+116    	; 0x445e <gc_execute_line.constprop.11+0x770>
    43ea:	9b 8d       	ldd	r25, Y+27	; 0x1b
    43ec:	99 23       	and	r25, r25
    43ee:	b9 f1       	breq	.+110    	; 0x445e <gc_execute_line.constprop.11+0x770>
    43f0:	a0 91 db 06 	lds	r26, 0x06DB	; 0x8006db <gc_block+0x4>
    43f4:	af a3       	std	Y+39, r26	; 0x27
    43f6:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    43fa:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    43fe:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4402:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4406:	57 e9       	ldi	r21, 0x97	; 151
    4408:	a5 2e       	mov	r10, r21
    440a:	56 e0       	ldi	r21, 0x06	; 6
    440c:	b5 2e       	mov	r11, r21
    440e:	67 ed       	ldi	r22, 0xD7	; 215
    4410:	c6 2e       	mov	r12, r22
    4412:	66 e0       	ldi	r22, 0x06	; 6
    4414:	d6 2e       	mov	r13, r22
    4416:	f1 2c       	mov	r15, r1
    4418:	e1 2c       	mov	r14, r1
    441a:	89 2e       	mov	r8, r25
    441c:	91 2c       	mov	r9, r1
    441e:	c4 01       	movw	r24, r8
    4420:	0e 2c       	mov	r0, r14
    4422:	02 c0       	rjmp	.+4      	; 0x4428 <gc_execute_line.constprop.11+0x73a>
    4424:	95 95       	asr	r25
    4426:	87 95       	ror	r24
    4428:	0a 94       	dec	r0
    442a:	e2 f7       	brpl	.-8      	; 0x4424 <gc_execute_line.constprop.11+0x736>
    442c:	80 fd       	sbrc	r24, 0
    442e:	57 c1       	rjmp	.+686    	; 0x46de <gc_execute_line.constprop.11+0x9f0>
    4430:	f5 01       	movw	r30, r10
    4432:	80 8d       	ldd	r24, Z+24	; 0x18
    4434:	91 8d       	ldd	r25, Z+25	; 0x19
    4436:	a2 8d       	ldd	r26, Z+26	; 0x1a
    4438:	b3 8d       	ldd	r27, Z+27	; 0x1b
    443a:	f6 01       	movw	r30, r12
    443c:	86 a7       	std	Z+46, r24	; 0x2e
    443e:	97 a7       	std	Z+47, r25	; 0x2f
    4440:	a0 ab       	std	Z+48, r26	; 0x30
    4442:	b1 ab       	std	Z+49, r27	; 0x31
    4444:	bf ef       	ldi	r27, 0xFF	; 255
    4446:	eb 1a       	sub	r14, r27
    4448:	fb 0a       	sbc	r15, r27
    444a:	e4 e0       	ldi	r30, 0x04	; 4
    444c:	ae 0e       	add	r10, r30
    444e:	b1 1c       	adc	r11, r1
    4450:	f4 e0       	ldi	r31, 0x04	; 4
    4452:	cf 0e       	add	r12, r31
    4454:	d1 1c       	adc	r13, r1
    4456:	23 e0       	ldi	r18, 0x03	; 3
    4458:	e2 16       	cp	r14, r18
    445a:	f1 04       	cpc	r15, r1
    445c:	01 f7       	brne	.-64     	; 0x441e <gc_execute_line.constprop.11+0x730>
    445e:	0e 31       	cpi	r16, 0x1E	; 30
    4460:	09 f4       	brne	.+2      	; 0x4464 <gc_execute_line.constprop.11+0x776>
    4462:	90 c1       	rjmp	.+800    	; 0x4784 <gc_execute_line.constprop.11+0xa96>
    4464:	05 33       	cpi	r16, 0x35	; 53
    4466:	09 f4       	brne	.+2      	; 0x446a <gc_execute_line.constprop.11+0x77c>
    4468:	b4 c1       	rjmp	.+872    	; 0x47d2 <gc_execute_line.constprop.11+0xae4>
    446a:	67 ee       	ldi	r22, 0xE7	; 231
    446c:	76 e0       	ldi	r23, 0x06	; 6
    446e:	86 e0       	ldi	r24, 0x06	; 6
    4470:	0c 31       	cpi	r16, 0x1C	; 28
    4472:	09 f0       	breq	.+2      	; 0x4476 <gc_execute_line.constprop.11+0x788>
    4474:	27 c1       	rjmp	.+590    	; 0x46c4 <gc_execute_line.constprop.11+0x9d6>
    4476:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    447a:	88 23       	and	r24, r24
    447c:	f1 f0       	breq	.+60     	; 0x44ba <gc_execute_line.constprop.11+0x7cc>
    447e:	3b 8d       	ldd	r19, Y+27	; 0x1b
    4480:	31 11       	cpse	r19, r1
    4482:	84 c1       	rjmp	.+776    	; 0x478c <gc_execute_line.constprop.11+0xa9e>
    4484:	19 a6       	std	Y+41, r1	; 0x29
    4486:	1f 8e       	std	Y+31, r1	; 0x1f
    4488:	a5 c0       	rjmp	.+330    	; 0x45d4 <gc_execute_line.constprop.11+0x8e6>
    448a:	91 e0       	ldi	r25, 0x01	; 1
    448c:	9f af       	std	Y+63, r25	; 0x3f
    448e:	19 ae       	std	Y+57, r1	; 0x39
    4490:	a2 e0       	ldi	r26, 0x02	; 2
    4492:	af ab       	std	Y+55, r26	; 0x37
    4494:	54 cf       	rjmp	.-344    	; 0x433e <gc_execute_line.constprop.11+0x650>
    4496:	80 91 de 06 	lds	r24, 0x06DE	; 0x8006de <gc_block+0x7>
    449a:	87 30       	cpi	r24, 0x07	; 7
    449c:	10 f0       	brcs	.+4      	; 0x44a2 <gc_execute_line.constprop.11+0x7b4>
    449e:	8d e1       	ldi	r24, 0x1D	; 29
    44a0:	75 cd       	rjmp	.-1302   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    44a2:	90 91 9d 06 	lds	r25, 0x069D	; 0x80069d <gc_state+0x6>
    44a6:	89 17       	cp	r24, r25
    44a8:	09 f4       	brne	.+2      	; 0x44ac <gc_execute_line.constprop.11+0x7be>
    44aa:	94 cf       	rjmp	.-216    	; 0x43d4 <gc_execute_line.constprop.11+0x6e6>
    44ac:	be 01       	movw	r22, r28
    44ae:	6f 5f       	subi	r22, 0xFF	; 255
    44b0:	7f 4f       	sbci	r23, 0xFF	; 255
    44b2:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    44b6:	81 11       	cpse	r24, r1
    44b8:	8d cf       	rjmp	.-230    	; 0x43d4 <gc_execute_line.constprop.11+0x6e6>
    44ba:	87 e0       	ldi	r24, 0x07	; 7
    44bc:	67 cd       	rjmp	.-1330   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    44be:	5b 8d       	ldd	r21, Y+27	; 0x1b
    44c0:	51 11       	cpse	r21, r1
    44c2:	02 c0       	rjmp	.+4      	; 0x44c8 <gc_execute_line.constprop.11+0x7da>
    44c4:	8a e1       	ldi	r24, 0x1A	; 26
    44c6:	62 cd       	rjmp	.-1340   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    44c8:	c1 01       	movw	r24, r2
    44ca:	80 75       	andi	r24, 0x50	; 80
    44cc:	99 27       	eor	r25, r25
    44ce:	89 2b       	or	r24, r25
    44d0:	09 f4       	brne	.+2      	; 0x44d4 <gc_execute_line.constprop.11+0x7e6>
    44d2:	f6 cd       	rjmp	.-1044   	; 0x40c0 <gc_execute_line.constprop.11+0x3d2>
    44d4:	60 91 f8 06 	lds	r22, 0x06F8	; 0x8006f8 <gc_block+0x21>
    44d8:	70 91 f9 06 	lds	r23, 0x06F9	; 0x8006f9 <gc_block+0x22>
    44dc:	80 91 fa 06 	lds	r24, 0x06FA	; 0x8006fa <gc_block+0x23>
    44e0:	90 91 fb 06 	lds	r25, 0x06FB	; 0x8006fb <gc_block+0x24>
    44e4:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    44e8:	67 30       	cpi	r22, 0x07	; 7
    44ea:	c8 f6       	brcc	.-78     	; 0x449e <gc_execute_line.constprop.11+0x7b0>
    44ec:	80 91 f3 06 	lds	r24, 0x06F3	; 0x8006f3 <gc_block+0x1c>
    44f0:	84 31       	cpi	r24, 0x14	; 20
    44f2:	29 f0       	breq	.+10     	; 0x44fe <gc_execute_line.constprop.11+0x810>
    44f4:	82 30       	cpi	r24, 0x02	; 2
    44f6:	09 f0       	breq	.+2      	; 0x44fa <gc_execute_line.constprop.11+0x80c>
    44f8:	b1 cc       	rjmp	.-1694   	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    44fa:	27 fc       	sbrc	r2, 7
    44fc:	af cc       	rjmp	.-1698   	; 0x3e5c <gc_execute_line.constprop.11+0x16e>
    44fe:	66 23       	and	r22, r22
    4500:	09 f4       	brne	.+2      	; 0x4504 <gc_execute_line.constprop.11+0x816>
    4502:	74 c0       	rjmp	.+232    	; 0x45ec <gc_execute_line.constprop.11+0x8fe>
    4504:	61 50       	subi	r22, 0x01	; 1
    4506:	69 a7       	std	Y+41, r22	; 0x29
    4508:	67 ee       	ldi	r22, 0xE7	; 231
    450a:	76 e0       	ldi	r23, 0x06	; 6
    450c:	89 a5       	ldd	r24, Y+41	; 0x29
    450e:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    4512:	88 23       	and	r24, r24
    4514:	91 f2       	breq	.-92     	; 0x44ba <gc_execute_line.constprop.11+0x7cc>
    4516:	00 91 f3 06 	lds	r16, 0x06F3	; 0x8006f3 <gc_block+0x1c>
    451a:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    451e:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    4522:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4526:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    452a:	b7 ed       	ldi	r27, 0xD7	; 215
    452c:	cb 2e       	mov	r12, r27
    452e:	b6 e0       	ldi	r27, 0x06	; 6
    4530:	db 2e       	mov	r13, r27
    4532:	f1 2c       	mov	r15, r1
    4534:	e1 2c       	mov	r14, r1
    4536:	bb 8d       	ldd	r27, Y+27	; 0x1b
    4538:	ab 2f       	mov	r26, r27
    453a:	b0 e0       	ldi	r27, 0x00	; 0
    453c:	b8 a7       	std	Y+40, r27	; 0x28
    453e:	af a3       	std	Y+39, r26	; 0x27
    4540:	8f a1       	ldd	r24, Y+39	; 0x27
    4542:	98 a5       	ldd	r25, Y+40	; 0x28
    4544:	0e 2c       	mov	r0, r14
    4546:	02 c0       	rjmp	.+4      	; 0x454c <gc_execute_line.constprop.11+0x85e>
    4548:	95 95       	asr	r25
    454a:	87 95       	ror	r24
    454c:	0a 94       	dec	r0
    454e:	e2 f7       	brpl	.-8      	; 0x4548 <gc_execute_line.constprop.11+0x85a>
    4550:	80 ff       	sbrs	r24, 0
    4552:	33 c0       	rjmp	.+102    	; 0x45ba <gc_execute_line.constprop.11+0x8cc>
    4554:	f6 01       	movw	r30, r12
    4556:	86 a4       	ldd	r8, Z+46	; 0x2e
    4558:	97 a4       	ldd	r9, Z+47	; 0x2f
    455a:	a0 a8       	ldd	r10, Z+48	; 0x30
    455c:	b1 a8       	ldd	r11, Z+49	; 0x31
    455e:	04 31       	cpi	r16, 0x14	; 20
    4560:	09 f0       	breq	.+2      	; 0x4564 <gc_execute_line.constprop.11+0x876>
    4562:	48 c0       	rjmp	.+144    	; 0x45f4 <gc_execute_line.constprop.11+0x906>
    4564:	f7 01       	movw	r30, r14
    4566:	ee 0f       	add	r30, r30
    4568:	ff 1f       	adc	r31, r31
    456a:	ee 0f       	add	r30, r30
    456c:	ff 1f       	adc	r31, r31
    456e:	e9 56       	subi	r30, 0x69	; 105
    4570:	f9 4f       	sbci	r31, 0xF9	; 249
    4572:	20 a9       	ldd	r18, Z+48	; 0x30
    4574:	31 a9       	ldd	r19, Z+49	; 0x31
    4576:	42 a9       	ldd	r20, Z+50	; 0x32
    4578:	53 a9       	ldd	r21, Z+51	; 0x33
    457a:	60 8d       	ldd	r22, Z+24	; 0x18
    457c:	71 8d       	ldd	r23, Z+25	; 0x19
    457e:	82 8d       	ldd	r24, Z+26	; 0x1a
    4580:	93 8d       	ldd	r25, Z+27	; 0x1b
    4582:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4586:	a5 01       	movw	r20, r10
    4588:	94 01       	movw	r18, r8
    458a:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    458e:	d6 01       	movw	r26, r12
    4590:	50 96       	adiw	r26, 0x10	; 16
    4592:	6d 93       	st	X+, r22
    4594:	7d 93       	st	X+, r23
    4596:	8d 93       	st	X+, r24
    4598:	9c 93       	st	X, r25
    459a:	53 97       	sbiw	r26, 0x13	; 19
    459c:	b2 e0       	ldi	r27, 0x02	; 2
    459e:	eb 12       	cpse	r14, r27
    45a0:	0c c0       	rjmp	.+24     	; 0x45ba <gc_execute_line.constprop.11+0x8cc>
    45a2:	a3 01       	movw	r20, r6
    45a4:	92 01       	movw	r18, r4
    45a6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    45aa:	60 93 ef 06 	sts	0x06EF, r22	; 0x8006ef <gc_block+0x18>
    45ae:	70 93 f0 06 	sts	0x06F0, r23	; 0x8006f0 <gc_block+0x19>
    45b2:	80 93 f1 06 	sts	0x06F1, r24	; 0x8006f1 <gc_block+0x1a>
    45b6:	90 93 f2 06 	sts	0x06F2, r25	; 0x8006f2 <gc_block+0x1b>
    45ba:	ff ef       	ldi	r31, 0xFF	; 255
    45bc:	ef 1a       	sub	r14, r31
    45be:	ff 0a       	sbc	r15, r31
    45c0:	24 e0       	ldi	r18, 0x04	; 4
    45c2:	c2 0e       	add	r12, r18
    45c4:	d1 1c       	adc	r13, r1
    45c6:	33 e0       	ldi	r19, 0x03	; 3
    45c8:	e3 16       	cp	r14, r19
    45ca:	f1 04       	cpc	r15, r1
    45cc:	09 f0       	breq	.+2      	; 0x45d0 <gc_execute_line.constprop.11+0x8e2>
    45ce:	b8 cf       	rjmp	.-144    	; 0x4540 <gc_execute_line.constprop.11+0x852>
    45d0:	4f ea       	ldi	r20, 0xAF	; 175
    45d2:	24 22       	and	r2, r20
    45d4:	50 91 d8 06 	lds	r21, 0x06D8	; 0x8006d8 <gc_block+0x1>
    45d8:	5f a3       	std	Y+39, r21	; 0x27
    45da:	50 35       	cpi	r21, 0x50	; 80
    45dc:	09 f0       	breq	.+2      	; 0x45e0 <gc_execute_line.constprop.11+0x8f2>
    45de:	00 c1       	rjmp	.+512    	; 0x47e0 <gc_execute_line.constprop.11+0xaf2>
    45e0:	8b 8d       	ldd	r24, Y+27	; 0x1b
    45e2:	88 23       	and	r24, r24
    45e4:	09 f4       	brne	.+2      	; 0x45e8 <gc_execute_line.constprop.11+0x8fa>
    45e6:	06 c1       	rjmp	.+524    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    45e8:	8f e1       	ldi	r24, 0x1F	; 31
    45ea:	d0 cc       	rjmp	.-1632   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    45ec:	80 91 de 06 	lds	r24, 0x06DE	; 0x8006de <gc_block+0x7>
    45f0:	89 a7       	std	Y+41, r24	; 0x29
    45f2:	8a cf       	rjmp	.-236    	; 0x4508 <gc_execute_line.constprop.11+0x81a>
    45f4:	80 8a       	std	Z+16, r8	; 0x10
    45f6:	91 8a       	std	Z+17, r9	; 0x11
    45f8:	a2 8a       	std	Z+18, r10	; 0x12
    45fa:	b3 8a       	std	Z+19, r11	; 0x13
    45fc:	de cf       	rjmp	.-68     	; 0x45ba <gc_execute_line.constprop.11+0x8cc>
    45fe:	5b 8d       	ldd	r21, Y+27	; 0x1b
    4600:	55 23       	and	r21, r21
    4602:	09 f4       	brne	.+2      	; 0x4606 <gc_execute_line.constprop.11+0x918>
    4604:	5f cf       	rjmp	.-322    	; 0x44c4 <gc_execute_line.constprop.11+0x7d6>
    4606:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    460a:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    460e:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4612:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4616:	77 e9       	ldi	r23, 0x97	; 151
    4618:	87 2e       	mov	r8, r23
    461a:	76 e0       	ldi	r23, 0x06	; 6
    461c:	97 2e       	mov	r9, r23
    461e:	ce 01       	movw	r24, r28
    4620:	01 96       	adiw	r24, 0x01	; 1
    4622:	7c 01       	movw	r14, r24
    4624:	e7 ed       	ldi	r30, 0xD7	; 215
    4626:	ae 2e       	mov	r10, r30
    4628:	e6 e0       	ldi	r30, 0x06	; 6
    462a:	be 2e       	mov	r11, r30
    462c:	d1 2c       	mov	r13, r1
    462e:	c1 2c       	mov	r12, r1
    4630:	a5 2f       	mov	r26, r21
    4632:	b0 e0       	ldi	r27, 0x00	; 0
    4634:	b8 a7       	std	Y+40, r27	; 0x28
    4636:	af a3       	std	Y+39, r26	; 0x27
    4638:	8f a1       	ldd	r24, Y+39	; 0x27
    463a:	98 a5       	ldd	r25, Y+40	; 0x28
    463c:	0c 2c       	mov	r0, r12
    463e:	02 c0       	rjmp	.+4      	; 0x4644 <gc_execute_line.constprop.11+0x956>
    4640:	95 95       	asr	r25
    4642:	87 95       	ror	r24
    4644:	0a 94       	dec	r0
    4646:	e2 f7       	brpl	.-8      	; 0x4640 <gc_execute_line.constprop.11+0x952>
    4648:	80 ff       	sbrs	r24, 0
    464a:	3e c0       	rjmp	.+124    	; 0x46c8 <gc_execute_line.constprop.11+0x9da>
    464c:	f7 01       	movw	r30, r14
    464e:	20 81       	ld	r18, Z
    4650:	31 81       	ldd	r19, Z+1	; 0x01
    4652:	42 81       	ldd	r20, Z+2	; 0x02
    4654:	53 81       	ldd	r21, Z+3	; 0x03
    4656:	d4 01       	movw	r26, r8
    4658:	58 96       	adiw	r26, 0x18	; 24
    465a:	6d 91       	ld	r22, X+
    465c:	7d 91       	ld	r23, X+
    465e:	8d 91       	ld	r24, X+
    4660:	9c 91       	ld	r25, X
    4662:	5b 97       	sbiw	r26, 0x1b	; 27
    4664:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4668:	f5 01       	movw	r30, r10
    466a:	26 a5       	ldd	r18, Z+46	; 0x2e
    466c:	37 a5       	ldd	r19, Z+47	; 0x2f
    466e:	40 a9       	ldd	r20, Z+48	; 0x30
    4670:	51 a9       	ldd	r21, Z+49	; 0x31
    4672:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4676:	d5 01       	movw	r26, r10
    4678:	9e 96       	adiw	r26, 0x2e	; 46
    467a:	6d 93       	st	X+, r22
    467c:	7d 93       	st	X+, r23
    467e:	8d 93       	st	X+, r24
    4680:	9c 93       	st	X, r25
    4682:	d1 97       	sbiw	r26, 0x31	; 49
    4684:	b2 e0       	ldi	r27, 0x02	; 2
    4686:	cb 12       	cpse	r12, r27
    4688:	0c c0       	rjmp	.+24     	; 0x46a2 <gc_execute_line.constprop.11+0x9b4>
    468a:	a3 01       	movw	r20, r6
    468c:	92 01       	movw	r18, r4
    468e:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4692:	60 93 0d 07 	sts	0x070D, r22	; 0x80070d <gc_block+0x36>
    4696:	70 93 0e 07 	sts	0x070E, r23	; 0x80070e <gc_block+0x37>
    469a:	80 93 0f 07 	sts	0x070F, r24	; 0x80070f <gc_block+0x38>
    469e:	90 93 10 07 	sts	0x0710, r25	; 0x800710 <gc_block+0x39>
    46a2:	ff ef       	ldi	r31, 0xFF	; 255
    46a4:	cf 1a       	sub	r12, r31
    46a6:	df 0a       	sbc	r13, r31
    46a8:	24 e0       	ldi	r18, 0x04	; 4
    46aa:	82 0e       	add	r8, r18
    46ac:	91 1c       	adc	r9, r1
    46ae:	34 e0       	ldi	r19, 0x04	; 4
    46b0:	e3 0e       	add	r14, r19
    46b2:	f1 1c       	adc	r15, r1
    46b4:	44 e0       	ldi	r20, 0x04	; 4
    46b6:	a4 0e       	add	r10, r20
    46b8:	b1 1c       	adc	r11, r1
    46ba:	53 e0       	ldi	r21, 0x03	; 3
    46bc:	c5 16       	cp	r12, r21
    46be:	d1 04       	cpc	r13, r1
    46c0:	09 f0       	breq	.+2      	; 0x46c4 <gc_execute_line.constprop.11+0x9d6>
    46c2:	ba cf       	rjmp	.-140    	; 0x4638 <gc_execute_line.constprop.11+0x94a>
    46c4:	19 a6       	std	Y+41, r1	; 0x29
    46c6:	86 cf       	rjmp	.-244    	; 0x45d4 <gc_execute_line.constprop.11+0x8e6>
    46c8:	f4 01       	movw	r30, r8
    46ca:	80 a9       	ldd	r24, Z+48	; 0x30
    46cc:	91 a9       	ldd	r25, Z+49	; 0x31
    46ce:	a2 a9       	ldd	r26, Z+50	; 0x32
    46d0:	b3 a9       	ldd	r27, Z+51	; 0x33
    46d2:	f5 01       	movw	r30, r10
    46d4:	86 a7       	std	Z+46, r24	; 0x2e
    46d6:	97 a7       	std	Z+47, r25	; 0x2f
    46d8:	a0 ab       	std	Z+48, r26	; 0x30
    46da:	b1 ab       	std	Z+49, r27	; 0x31
    46dc:	e2 cf       	rjmp	.-60     	; 0x46a2 <gc_execute_line.constprop.11+0x9b4>
    46de:	05 33       	cpi	r16, 0x35	; 53
    46e0:	09 f4       	brne	.+2      	; 0x46e4 <gc_execute_line.constprop.11+0x9f6>
    46e2:	b0 ce       	rjmp	.-672    	; 0x4444 <gc_execute_line.constprop.11+0x756>
    46e4:	d6 01       	movw	r26, r12
    46e6:	9e 96       	adiw	r26, 0x2e	; 46
    46e8:	6d 91       	ld	r22, X+
    46ea:	7d 91       	ld	r23, X+
    46ec:	8d 91       	ld	r24, X+
    46ee:	9c 91       	ld	r25, X
    46f0:	d1 97       	sbiw	r26, 0x31	; 49
    46f2:	bf a1       	ldd	r27, Y+39	; 0x27
    46f4:	b1 11       	cpse	r27, r1
    46f6:	35 c0       	rjmp	.+106    	; 0x4762 <gc_execute_line.constprop.11+0xa74>
    46f8:	97 01       	movw	r18, r14
    46fa:	22 0f       	add	r18, r18
    46fc:	33 1f       	adc	r19, r19
    46fe:	22 0f       	add	r18, r18
    4700:	33 1f       	adc	r19, r19
    4702:	e1 e0       	ldi	r30, 0x01	; 1
    4704:	f0 e0       	ldi	r31, 0x00	; 0
    4706:	ec 0f       	add	r30, r28
    4708:	fd 1f       	adc	r31, r29
    470a:	e2 0f       	add	r30, r18
    470c:	f3 1f       	adc	r31, r19
    470e:	fa a7       	std	Y+42, r31	; 0x2a
    4710:	e9 a7       	std	Y+41, r30	; 0x29
    4712:	d5 01       	movw	r26, r10
    4714:	d0 96       	adiw	r26, 0x30	; 48
    4716:	2d 91       	ld	r18, X+
    4718:	3d 91       	ld	r19, X+
    471a:	4d 91       	ld	r20, X+
    471c:	5c 91       	ld	r21, X
    471e:	d3 97       	sbiw	r26, 0x33	; 51
    4720:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4724:	e9 a5       	ldd	r30, Y+41	; 0x29
    4726:	fa a5       	ldd	r31, Y+42	; 0x2a
    4728:	20 81       	ld	r18, Z
    472a:	31 81       	ldd	r19, Z+1	; 0x01
    472c:	42 81       	ldd	r20, Z+2	; 0x02
    472e:	53 81       	ldd	r21, Z+3	; 0x03
    4730:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4734:	d6 01       	movw	r26, r12
    4736:	9e 96       	adiw	r26, 0x2e	; 46
    4738:	6d 93       	st	X+, r22
    473a:	7d 93       	st	X+, r23
    473c:	8d 93       	st	X+, r24
    473e:	9c 93       	st	X, r25
    4740:	d1 97       	sbiw	r26, 0x31	; 49
    4742:	b2 e0       	ldi	r27, 0x02	; 2
    4744:	eb 12       	cpse	r14, r27
    4746:	7e ce       	rjmp	.-772    	; 0x4444 <gc_execute_line.constprop.11+0x756>
    4748:	a3 01       	movw	r20, r6
    474a:	92 01       	movw	r18, r4
    474c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4750:	60 93 0d 07 	sts	0x070D, r22	; 0x80070d <gc_block+0x36>
    4754:	70 93 0e 07 	sts	0x070E, r23	; 0x80070e <gc_block+0x37>
    4758:	80 93 0f 07 	sts	0x070F, r24	; 0x80070f <gc_block+0x38>
    475c:	90 93 10 07 	sts	0x0710, r25	; 0x800710 <gc_block+0x39>
    4760:	71 ce       	rjmp	.-798    	; 0x4444 <gc_execute_line.constprop.11+0x756>
    4762:	9b 01       	movw	r18, r22
    4764:	ac 01       	movw	r20, r24
    4766:	f5 01       	movw	r30, r10
    4768:	60 8d       	ldd	r22, Z+24	; 0x18
    476a:	71 8d       	ldd	r23, Z+25	; 0x19
    476c:	82 8d       	ldd	r24, Z+26	; 0x1a
    476e:	93 8d       	ldd	r25, Z+27	; 0x1b
    4770:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4774:	d6 01       	movw	r26, r12
    4776:	9e 96       	adiw	r26, 0x2e	; 46
    4778:	6d 93       	st	X+, r22
    477a:	7d 93       	st	X+, r23
    477c:	8d 93       	st	X+, r24
    477e:	9c 93       	st	X, r25
    4780:	d1 97       	sbiw	r26, 0x31	; 49
    4782:	60 ce       	rjmp	.-832    	; 0x4444 <gc_execute_line.constprop.11+0x756>
    4784:	67 ee       	ldi	r22, 0xE7	; 231
    4786:	76 e0       	ldi	r23, 0x06	; 6
    4788:	87 e0       	ldi	r24, 0x07	; 7
    478a:	75 ce       	rjmp	.-790    	; 0x4476 <gc_execute_line.constprop.11+0x788>
    478c:	a7 e9       	ldi	r26, 0x97	; 151
    478e:	b6 e0       	ldi	r27, 0x06	; 6
    4790:	e7 ed       	ldi	r30, 0xD7	; 215
    4792:	f6 e0       	ldi	r31, 0x06	; 6
    4794:	90 e0       	ldi	r25, 0x00	; 0
    4796:	80 e0       	ldi	r24, 0x00	; 0
    4798:	4b 8d       	ldd	r20, Y+27	; 0x1b
    479a:	24 2f       	mov	r18, r20
    479c:	30 e0       	ldi	r19, 0x00	; 0
    479e:	a9 01       	movw	r20, r18
    47a0:	08 2e       	mov	r0, r24
    47a2:	02 c0       	rjmp	.+4      	; 0x47a8 <gc_execute_line.constprop.11+0xaba>
    47a4:	55 95       	asr	r21
    47a6:	47 95       	ror	r20
    47a8:	0a 94       	dec	r0
    47aa:	e2 f7       	brpl	.-8      	; 0x47a4 <gc_execute_line.constprop.11+0xab6>
    47ac:	40 fd       	sbrc	r20, 0
    47ae:	0a c0       	rjmp	.+20     	; 0x47c4 <gc_execute_line.constprop.11+0xad6>
    47b0:	58 96       	adiw	r26, 0x18	; 24
    47b2:	4d 91       	ld	r20, X+
    47b4:	5d 91       	ld	r21, X+
    47b6:	6d 91       	ld	r22, X+
    47b8:	7c 91       	ld	r23, X
    47ba:	5b 97       	sbiw	r26, 0x1b	; 27
    47bc:	40 8b       	std	Z+16, r20	; 0x10
    47be:	51 8b       	std	Z+17, r21	; 0x11
    47c0:	62 8b       	std	Z+18, r22	; 0x12
    47c2:	73 8b       	std	Z+19, r23	; 0x13
    47c4:	01 96       	adiw	r24, 0x01	; 1
    47c6:	14 96       	adiw	r26, 0x04	; 4
    47c8:	34 96       	adiw	r30, 0x04	; 4
    47ca:	83 30       	cpi	r24, 0x03	; 3
    47cc:	91 05       	cpc	r25, r1
    47ce:	39 f7       	brne	.-50     	; 0x479e <gc_execute_line.constprop.11+0xab0>
    47d0:	79 cf       	rjmp	.-270    	; 0x46c4 <gc_execute_line.constprop.11+0x9d6>
    47d2:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    47d6:	82 30       	cpi	r24, 0x02	; 2
    47d8:	08 f4       	brcc	.+2      	; 0x47dc <gc_execute_line.constprop.11+0xaee>
    47da:	74 cf       	rjmp	.-280    	; 0x46c4 <gc_execute_line.constprop.11+0x9d6>
    47dc:	8e e1       	ldi	r24, 0x1E	; 30
    47de:	d6 cb       	rjmp	.-2132   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    47e0:	9f 8d       	ldd	r25, Y+31	; 0x1f
    47e2:	92 30       	cpi	r25, 0x02	; 2
    47e4:	39 f4       	brne	.+14     	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    47e6:	af a1       	ldd	r26, Y+39	; 0x27
    47e8:	a1 11       	cpse	r26, r1
    47ea:	70 c0       	rjmp	.+224    	; 0x48cc <gc_execute_line.constprop.11+0xbde>
    47ec:	bb 8d       	ldd	r27, Y+27	; 0x1b
    47ee:	bb 23       	and	r27, r27
    47f0:	09 f4       	brne	.+2      	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    47f2:	8a c0       	rjmp	.+276    	; 0x4908 <gc_execute_line.constprop.11+0xc1a>
    47f4:	2b a1       	ldd	r18, Y+35	; 0x23
    47f6:	21 70       	andi	r18, 0x01	; 1
    47f8:	8b a1       	ldd	r24, Y+35	; 0x23
    47fa:	80 ff       	sbrs	r24, 0
    47fc:	c6 c2       	rjmp	.+1420   	; 0x4d8a <gc_execute_line.constprop.11+0x109c>
    47fe:	c1 01       	movw	r24, r2
    4800:	8e 7d       	andi	r24, 0xDE	; 222
    4802:	af 8d       	ldd	r26, Y+31	; 0x1f
    4804:	a1 11       	cpse	r26, r1
    4806:	93 7e       	andi	r25, 0xE3	; 227
    4808:	89 2b       	or	r24, r25
    480a:	09 f0       	breq	.+2      	; 0x480e <gc_execute_line.constprop.11+0xb20>
    480c:	ec c7       	rjmp	.+4056   	; 0x57e6 <gc_execute_line.constprop.11+0x1af8>
    480e:	8e 01       	movw	r16, r28
    4810:	03 5f       	subi	r16, 0xF3	; 243
    4812:	1f 4f       	sbci	r17, 0xFF	; 255
    4814:	89 e0       	ldi	r24, 0x09	; 9
    4816:	f8 01       	movw	r30, r16
    4818:	11 92       	st	Z+, r1
    481a:	8a 95       	dec	r24
    481c:	e9 f7       	brne	.-6      	; 0x4818 <gc_execute_line.constprop.11+0xb2a>
    481e:	22 23       	and	r18, r18
    4820:	09 f4       	brne	.+2      	; 0x4824 <gc_execute_line.constprop.11+0xb36>
    4822:	b7 c2       	rjmp	.+1390   	; 0x4d92 <gc_execute_line.constprop.11+0x10a4>
    4824:	8b a5       	ldd	r24, Y+43	; 0x2b
    4826:	9c a5       	ldd	r25, Y+44	; 0x2c
    4828:	86 7b       	andi	r24, 0xB6	; 182
    482a:	89 2b       	or	r24, r25
    482c:	09 f0       	breq	.+2      	; 0x4830 <gc_execute_line.constprop.11+0xb42>
    482e:	de c7       	rjmp	.+4028   	; 0x57ec <gc_execute_line.constprop.11+0x1afe>
    4830:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    4834:	85 33       	cpi	r24, 0x35	; 53
    4836:	11 f0       	breq	.+4      	; 0x483c <gc_execute_line.constprop.11+0xb4e>
    4838:	81 11       	cpse	r24, r1
    483a:	d8 c7       	rjmp	.+4016   	; 0x57ec <gc_execute_line.constprop.11+0x1afe>
    483c:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4840:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4844:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    4848:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    484c:	89 8b       	std	Y+17, r24	; 0x11
    484e:	9a 8b       	std	Y+18, r25	; 0x12
    4850:	ab 8b       	std	Y+19, r26	; 0x13
    4852:	bc 8b       	std	Y+20, r27	; 0x14
    4854:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4858:	90 91 9f 06 	lds	r25, 0x069F	; 0x80069f <gc_state+0x8>
    485c:	89 2b       	or	r24, r25
    485e:	40 91 e3 06 	lds	r20, 0x06E3	; 0x8006e3 <gc_block+0xc>
    4862:	50 91 e4 06 	lds	r21, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4866:	60 91 e5 06 	lds	r22, 0x06E5	; 0x8006e5 <gc_block+0xe>
    486a:	70 91 e6 06 	lds	r23, 0x06E6	; 0x8006e6 <gc_block+0xf>
    486e:	4d 87       	std	Y+13, r20	; 0x0d
    4870:	5e 87       	std	Y+14, r21	; 0x0e
    4872:	6f 87       	std	Y+15, r22	; 0x0f
    4874:	78 8b       	std	Y+16, r23	; 0x10
    4876:	84 60       	ori	r24, 0x04	; 4
    4878:	8d 8b       	std	Y+21, r24	; 0x15
    487a:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    487e:	85 ff       	sbrs	r24, 5
    4880:	06 c0       	rjmp	.+12     	; 0x488e <gc_execute_line.constprop.11+0xba0>
    4882:	85 e0       	ldi	r24, 0x05	; 5
    4884:	97 e0       	ldi	r25, 0x07	; 7
    4886:	0e 94 54 02 	call	0x4a8	; 0x4a8 <system_check_travel_limits>
    488a:	81 11       	cpse	r24, r1
    488c:	b2 c7       	rjmp	.+3940   	; 0x57f2 <gc_execute_line.constprop.11+0x1b04>
    488e:	b8 01       	movw	r22, r16
    4890:	85 e0       	ldi	r24, 0x05	; 5
    4892:	97 e0       	ldi	r25, 0x07	; 7
    4894:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    4898:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    489c:	81 11       	cpse	r24, r1
    489e:	0b c0       	rjmp	.+22     	; 0x48b6 <gc_execute_line.constprop.11+0xbc8>
    48a0:	0e 94 0e 04 	call	0x81c	; 0x81c <plan_get_current_block>
    48a4:	89 2b       	or	r24, r25
    48a6:	39 f0       	breq	.+14     	; 0x48b6 <gc_execute_line.constprop.11+0xbc8>
    48a8:	80 e2       	ldi	r24, 0x20	; 32
    48aa:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    48ae:	0e 94 26 0e 	call	0x1c4c	; 0x1c4c <st_prep_buffer>
    48b2:	0e 94 6c 06 	call	0xcd8	; 0xcd8 <st_wake_up>
    48b6:	8c e0       	ldi	r24, 0x0C	; 12
    48b8:	e5 e0       	ldi	r30, 0x05	; 5
    48ba:	f7 e0       	ldi	r31, 0x07	; 7
    48bc:	af ea       	ldi	r26, 0xAF	; 175
    48be:	b6 e0       	ldi	r27, 0x06	; 6
    48c0:	01 90       	ld	r0, Z+
    48c2:	0d 92       	st	X+, r0
    48c4:	8a 95       	dec	r24
    48c6:	e1 f7       	brne	.-8      	; 0x48c0 <gc_execute_line.constprop.11+0xbd2>
    48c8:	80 e0       	ldi	r24, 0x00	; 0
    48ca:	60 cb       	rjmp	.-2368   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    48cc:	20 e0       	ldi	r18, 0x00	; 0
    48ce:	30 e0       	ldi	r19, 0x00	; 0
    48d0:	a9 01       	movw	r20, r18
    48d2:	60 91 e3 06 	lds	r22, 0x06E3	; 0x8006e3 <gc_block+0xc>
    48d6:	70 91 e4 06 	lds	r23, 0x06E4	; 0x8006e4 <gc_block+0xd>
    48da:	80 91 e5 06 	lds	r24, 0x06E5	; 0x8006e5 <gc_block+0xe>
    48de:	90 91 e6 06 	lds	r25, 0x06E6	; 0x8006e6 <gc_block+0xf>
    48e2:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    48e6:	88 23       	and	r24, r24
    48e8:	09 f4       	brne	.+2      	; 0x48ec <gc_execute_line.constprop.11+0xbfe>
    48ea:	fc cc       	rjmp	.-1544   	; 0x42e4 <gc_execute_line.constprop.11+0x5f6>
    48ec:	ef a1       	ldd	r30, Y+39	; 0x27
    48ee:	ec 38       	cpi	r30, 0x8C	; 140
    48f0:	b9 f0       	breq	.+46     	; 0x4920 <gc_execute_line.constprop.11+0xc32>
    48f2:	60 f4       	brcc	.+24     	; 0x490c <gc_execute_line.constprop.11+0xc1e>
    48f4:	e2 30       	cpi	r30, 0x02	; 2
    48f6:	59 f1       	breq	.+86     	; 0x494e <gc_execute_line.constprop.11+0xc60>
    48f8:	e3 30       	cpi	r30, 0x03	; 3
    48fa:	61 f1       	breq	.+88     	; 0x4954 <gc_execute_line.constprop.11+0xc66>
    48fc:	e1 30       	cpi	r30, 0x01	; 1
    48fe:	09 f0       	breq	.+2      	; 0x4902 <gc_execute_line.constprop.11+0xc14>
    4900:	79 cf       	rjmp	.-270    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    4902:	2b 8d       	ldd	r18, Y+27	; 0x1b
    4904:	21 11       	cpse	r18, r1
    4906:	76 cf       	rjmp	.-276    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    4908:	1f 8e       	std	Y+31, r1	; 0x1f
    490a:	74 cf       	rjmp	.-280    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    490c:	ff a1       	ldd	r31, Y+39	; 0x27
    490e:	fe 38       	cpi	r31, 0x8E	; 142
    4910:	39 f0       	breq	.+14     	; 0x4920 <gc_execute_line.constprop.11+0xc32>
    4912:	18 f0       	brcs	.+6      	; 0x491a <gc_execute_line.constprop.11+0xc2c>
    4914:	ff 38       	cpi	r31, 0x8F	; 143
    4916:	09 f0       	breq	.+2      	; 0x491a <gc_execute_line.constprop.11+0xc2c>
    4918:	6d cf       	rjmp	.-294    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    491a:	3b a1       	ldd	r19, Y+35	; 0x23
    491c:	30 61       	ori	r19, 0x10	; 16
    491e:	3b a3       	std	Y+35, r19	; 0x23
    4920:	8f a1       	ldd	r24, Y+39	; 0x27
    4922:	8e 58       	subi	r24, 0x8E	; 142
    4924:	82 30       	cpi	r24, 0x02	; 2
    4926:	18 f4       	brcc	.+6      	; 0x492e <gc_execute_line.constprop.11+0xc40>
    4928:	4b a1       	ldd	r20, Y+35	; 0x23
    492a:	48 60       	ori	r20, 0x08	; 8
    492c:	4b a3       	std	Y+35, r20	; 0x23
    492e:	5b 8d       	ldd	r21, Y+27	; 0x1b
    4930:	55 23       	and	r21, r21
    4932:	09 f4       	brne	.+2      	; 0x4936 <gc_execute_line.constprop.11+0xc48>
    4934:	c7 cd       	rjmp	.-1138   	; 0x44c4 <gc_execute_line.constprop.11+0x7d6>
    4936:	4c e0       	ldi	r20, 0x0C	; 12
    4938:	50 e0       	ldi	r21, 0x00	; 0
    493a:	65 e0       	ldi	r22, 0x05	; 5
    493c:	77 e0       	ldi	r23, 0x07	; 7
    493e:	8f ea       	ldi	r24, 0xAF	; 175
    4940:	96 e0       	ldi	r25, 0x06	; 6
    4942:	0e 94 c8 39 	call	0x7390	; 0x7390 <memcmp>
    4946:	89 2b       	or	r24, r25
    4948:	09 f0       	breq	.+2      	; 0x494c <gc_execute_line.constprop.11+0xc5e>
    494a:	54 cf       	rjmp	.-344    	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    494c:	71 c0       	rjmp	.+226    	; 0x4a30 <gc_execute_line.constprop.11+0xd42>
    494e:	3b a1       	ldd	r19, Y+35	; 0x23
    4950:	34 60       	ori	r19, 0x04	; 4
    4952:	3b a3       	std	Y+35, r19	; 0x23
    4954:	4b 8d       	ldd	r20, Y+27	; 0x1b
    4956:	44 23       	and	r20, r20
    4958:	09 f4       	brne	.+2      	; 0x495c <gc_execute_line.constprop.11+0xc6e>
    495a:	b4 cd       	rjmp	.-1176   	; 0x44c4 <gc_execute_line.constprop.11+0x7d6>
    495c:	9f a9       	ldd	r25, Y+55	; 0x37
    495e:	89 2f       	mov	r24, r25
    4960:	90 e0       	ldi	r25, 0x00	; 0
    4962:	98 ab       	std	Y+48, r25	; 0x30
    4964:	8f a7       	std	Y+47, r24	; 0x2f
    4966:	b9 ad       	ldd	r27, Y+57	; 0x39
    4968:	ab 2f       	mov	r26, r27
    496a:	b0 e0       	ldi	r27, 0x00	; 0
    496c:	bc af       	std	Y+60, r27	; 0x3c
    496e:	ab af       	std	Y+59, r26	; 0x3b
    4970:	81 e0       	ldi	r24, 0x01	; 1
    4972:	90 e0       	ldi	r25, 0x00	; 0
    4974:	7c 01       	movw	r14, r24
    4976:	0f a8       	ldd	r0, Y+55	; 0x37
    4978:	02 c0       	rjmp	.+4      	; 0x497e <gc_execute_line.constprop.11+0xc90>
    497a:	ee 0c       	add	r14, r14
    497c:	ff 1c       	adc	r15, r15
    497e:	0a 94       	dec	r0
    4980:	e2 f7       	brpl	.-8      	; 0x497a <gc_execute_line.constprop.11+0xc8c>
    4982:	09 ac       	ldd	r0, Y+57	; 0x39
    4984:	02 c0       	rjmp	.+4      	; 0x498a <gc_execute_line.constprop.11+0xc9c>
    4986:	88 0f       	add	r24, r24
    4988:	99 1f       	adc	r25, r25
    498a:	0a 94       	dec	r0
    498c:	e2 f7       	brpl	.-8      	; 0x4986 <gc_execute_line.constprop.11+0xc98>
    498e:	e8 2a       	or	r14, r24
    4990:	f9 2a       	or	r15, r25
    4992:	84 2f       	mov	r24, r20
    4994:	90 e0       	ldi	r25, 0x00	; 0
    4996:	8e 21       	and	r24, r14
    4998:	9f 21       	and	r25, r15
    499a:	89 2b       	or	r24, r25
    499c:	09 f4       	brne	.+2      	; 0x49a0 <gc_execute_line.constprop.11+0xcb2>
    499e:	1d c7       	rjmp	.+3642   	; 0x57da <gc_execute_line.constprop.11+0x1aec>
    49a0:	ef a5       	ldd	r30, Y+47	; 0x2f
    49a2:	f8 a9       	ldd	r31, Y+48	; 0x30
    49a4:	ee 0f       	add	r30, r30
    49a6:	ff 1f       	adc	r31, r31
    49a8:	ee 0f       	add	r30, r30
    49aa:	ff 1f       	adc	r31, r31
    49ac:	e9 52       	subi	r30, 0x29	; 41
    49ae:	f9 4f       	sbci	r31, 0xF9	; 249
    49b0:	af a5       	ldd	r26, Y+47	; 0x2f
    49b2:	b8 a9       	ldd	r27, Y+48	; 0x30
    49b4:	aa 0f       	add	r26, r26
    49b6:	bb 1f       	adc	r27, r27
    49b8:	aa 0f       	add	r26, r26
    49ba:	bb 1f       	adc	r27, r27
    49bc:	a1 55       	subi	r26, 0x51	; 81
    49be:	b9 4f       	sbci	r27, 0xF9	; 249
    49c0:	2d 91       	ld	r18, X+
    49c2:	3d 91       	ld	r19, X+
    49c4:	4d 91       	ld	r20, X+
    49c6:	5c 91       	ld	r21, X
    49c8:	66 a5       	ldd	r22, Z+46	; 0x2e
    49ca:	77 a5       	ldd	r23, Z+47	; 0x2f
    49cc:	80 a9       	ldd	r24, Z+48	; 0x30
    49ce:	91 a9       	ldd	r25, Z+49	; 0x31
    49d0:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    49d4:	4b 01       	movw	r8, r22
    49d6:	5c 01       	movw	r10, r24
    49d8:	eb ad       	ldd	r30, Y+59	; 0x3b
    49da:	fc ad       	ldd	r31, Y+60	; 0x3c
    49dc:	ee 0f       	add	r30, r30
    49de:	ff 1f       	adc	r31, r31
    49e0:	ee 0f       	add	r30, r30
    49e2:	ff 1f       	adc	r31, r31
    49e4:	e9 52       	subi	r30, 0x29	; 41
    49e6:	f9 4f       	sbci	r31, 0xF9	; 249
    49e8:	ab ad       	ldd	r26, Y+59	; 0x3b
    49ea:	bc ad       	ldd	r27, Y+60	; 0x3c
    49ec:	aa 0f       	add	r26, r26
    49ee:	bb 1f       	adc	r27, r27
    49f0:	aa 0f       	add	r26, r26
    49f2:	bb 1f       	adc	r27, r27
    49f4:	a1 55       	subi	r26, 0x51	; 81
    49f6:	b9 4f       	sbci	r27, 0xF9	; 249
    49f8:	2d 91       	ld	r18, X+
    49fa:	3d 91       	ld	r19, X+
    49fc:	4d 91       	ld	r20, X+
    49fe:	5c 91       	ld	r21, X
    4a00:	66 a5       	ldd	r22, Z+46	; 0x2e
    4a02:	77 a5       	ldd	r23, Z+47	; 0x2f
    4a04:	80 a9       	ldd	r24, Z+48	; 0x30
    4a06:	91 a9       	ldd	r25, Z+49	; 0x31
    4a08:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4a0c:	6b ab       	std	Y+51, r22	; 0x33
    4a0e:	7c ab       	std	Y+52, r23	; 0x34
    4a10:	8d ab       	std	Y+53, r24	; 0x35
    4a12:	9e ab       	std	Y+54, r25	; 0x36
    4a14:	27 fe       	sbrs	r2, 7
    4a16:	ef c0       	rjmp	.+478    	; 0x4bf6 <gc_execute_line.constprop.11+0xf08>
    4a18:	e8 94       	clt
    4a1a:	27 f8       	bld	r2, 7
    4a1c:	4c e0       	ldi	r20, 0x0C	; 12
    4a1e:	50 e0       	ldi	r21, 0x00	; 0
    4a20:	65 e0       	ldi	r22, 0x05	; 5
    4a22:	77 e0       	ldi	r23, 0x07	; 7
    4a24:	8f ea       	ldi	r24, 0xAF	; 175
    4a26:	96 e0       	ldi	r25, 0x06	; 6
    4a28:	0e 94 c8 39 	call	0x7390	; 0x7390 <memcmp>
    4a2c:	89 2b       	or	r24, r25
    4a2e:	11 f4       	brne	.+4      	; 0x4a34 <gc_execute_line.constprop.11+0xd46>
    4a30:	81 e2       	ldi	r24, 0x21	; 33
    4a32:	ac ca       	rjmp	.-2728   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    4a34:	60 91 fc 06 	lds	r22, 0x06FC	; 0x8006fc <gc_block+0x25>
    4a38:	70 91 fd 06 	lds	r23, 0x06FD	; 0x8006fd <gc_block+0x26>
    4a3c:	80 91 fe 06 	lds	r24, 0x06FE	; 0x8006fe <gc_block+0x27>
    4a40:	90 91 ff 06 	lds	r25, 0x06FF	; 0x8006ff <gc_block+0x28>
    4a44:	20 91 da 06 	lds	r18, 0x06DA	; 0x8006da <gc_block+0x3>
    4a48:	21 30       	cpi	r18, 0x01	; 1
    4a4a:	71 f4       	brne	.+28     	; 0x4a68 <gc_execute_line.constprop.11+0xd7a>
    4a4c:	23 e3       	ldi	r18, 0x33	; 51
    4a4e:	33 e3       	ldi	r19, 0x33	; 51
    4a50:	4b ec       	ldi	r20, 0xCB	; 203
    4a52:	51 e4       	ldi	r21, 0x41	; 65
    4a54:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4a58:	60 93 fc 06 	sts	0x06FC, r22	; 0x8006fc <gc_block+0x25>
    4a5c:	70 93 fd 06 	sts	0x06FD, r23	; 0x8006fd <gc_block+0x26>
    4a60:	80 93 fe 06 	sts	0x06FE, r24	; 0x8006fe <gc_block+0x27>
    4a64:	90 93 ff 06 	sts	0x06FF, r25	; 0x8006ff <gc_block+0x28>
    4a68:	40 90 fc 06 	lds	r4, 0x06FC	; 0x8006fc <gc_block+0x25>
    4a6c:	50 90 fd 06 	lds	r5, 0x06FD	; 0x8006fd <gc_block+0x26>
    4a70:	60 90 fe 06 	lds	r6, 0x06FE	; 0x8006fe <gc_block+0x27>
    4a74:	70 90 ff 06 	lds	r7, 0x06FF	; 0x8006ff <gc_block+0x28>
    4a78:	a5 01       	movw	r20, r10
    4a7a:	94 01       	movw	r18, r8
    4a7c:	c5 01       	movw	r24, r10
    4a7e:	b4 01       	movw	r22, r8
    4a80:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4a84:	27 96       	adiw	r28, 0x07	; 7
    4a86:	6c af       	std	Y+60, r22	; 0x3c
    4a88:	7d af       	std	Y+61, r23	; 0x3d
    4a8a:	8e af       	std	Y+62, r24	; 0x3e
    4a8c:	9f af       	std	Y+63, r25	; 0x3f
    4a8e:	27 97       	sbiw	r28, 0x07	; 7
    4a90:	2b a9       	ldd	r18, Y+51	; 0x33
    4a92:	3c a9       	ldd	r19, Y+52	; 0x34
    4a94:	4d a9       	ldd	r20, Y+53	; 0x35
    4a96:	5e a9       	ldd	r21, Y+54	; 0x36
    4a98:	ca 01       	movw	r24, r20
    4a9a:	b9 01       	movw	r22, r18
    4a9c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4aa0:	2b 96       	adiw	r28, 0x0b	; 11
    4aa2:	6c af       	std	Y+60, r22	; 0x3c
    4aa4:	7d af       	std	Y+61, r23	; 0x3d
    4aa6:	8e af       	std	Y+62, r24	; 0x3e
    4aa8:	9f af       	std	Y+63, r25	; 0x3f
    4aaa:	2b 97       	sbiw	r28, 0x0b	; 11
    4aac:	a3 01       	movw	r20, r6
    4aae:	92 01       	movw	r18, r4
    4ab0:	c3 01       	movw	r24, r6
    4ab2:	b2 01       	movw	r22, r4
    4ab4:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4ab8:	20 e0       	ldi	r18, 0x00	; 0
    4aba:	30 e0       	ldi	r19, 0x00	; 0
    4abc:	40 e8       	ldi	r20, 0x80	; 128
    4abe:	50 e4       	ldi	r21, 0x40	; 64
    4ac0:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4ac4:	27 96       	adiw	r28, 0x07	; 7
    4ac6:	2c ad       	ldd	r18, Y+60	; 0x3c
    4ac8:	3d ad       	ldd	r19, Y+61	; 0x3d
    4aca:	4e ad       	ldd	r20, Y+62	; 0x3e
    4acc:	5f ad       	ldd	r21, Y+63	; 0x3f
    4ace:	27 97       	sbiw	r28, 0x07	; 7
    4ad0:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4ad4:	2b 96       	adiw	r28, 0x0b	; 11
    4ad6:	2c ad       	ldd	r18, Y+60	; 0x3c
    4ad8:	3d ad       	ldd	r19, Y+61	; 0x3d
    4ada:	4e ad       	ldd	r20, Y+62	; 0x3e
    4adc:	5f ad       	ldd	r21, Y+63	; 0x3f
    4ade:	2b 97       	sbiw	r28, 0x0b	; 11
    4ae0:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4ae4:	6b 01       	movw	r12, r22
    4ae6:	7c 01       	movw	r14, r24
    4ae8:	20 e0       	ldi	r18, 0x00	; 0
    4aea:	30 e0       	ldi	r19, 0x00	; 0
    4aec:	a9 01       	movw	r20, r18
    4aee:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    4af2:	87 fd       	sbrc	r24, 7
    4af4:	75 c6       	rjmp	.+3306   	; 0x57e0 <gc_execute_line.constprop.11+0x1af2>
    4af6:	c7 01       	movw	r24, r14
    4af8:	b6 01       	movw	r22, r12
    4afa:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    4afe:	6b 01       	movw	r12, r22
    4b00:	7c 01       	movw	r14, r24
    4b02:	27 96       	adiw	r28, 0x07	; 7
    4b04:	2c ad       	ldd	r18, Y+60	; 0x3c
    4b06:	3d ad       	ldd	r19, Y+61	; 0x3d
    4b08:	4e ad       	ldd	r20, Y+62	; 0x3e
    4b0a:	5f ad       	ldd	r21, Y+63	; 0x3f
    4b0c:	27 97       	sbiw	r28, 0x07	; 7
    4b0e:	2b 96       	adiw	r28, 0x0b	; 11
    4b10:	6c ad       	ldd	r22, Y+60	; 0x3c
    4b12:	7d ad       	ldd	r23, Y+61	; 0x3d
    4b14:	8e ad       	ldd	r24, Y+62	; 0x3e
    4b16:	9f ad       	ldd	r25, Y+63	; 0x3f
    4b18:	2b 97       	sbiw	r28, 0x0b	; 11
    4b1a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4b1e:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    4b22:	9b 01       	movw	r18, r22
    4b24:	ac 01       	movw	r20, r24
    4b26:	c7 01       	movw	r24, r14
    4b28:	b6 01       	movw	r22, r12
    4b2a:	90 58       	subi	r25, 0x80	; 128
    4b2c:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    4b30:	6b 01       	movw	r12, r22
    4b32:	7c 01       	movw	r14, r24
    4b34:	ef a1       	ldd	r30, Y+39	; 0x27
    4b36:	e3 30       	cpi	r30, 0x03	; 3
    4b38:	21 f4       	brne	.+8      	; 0x4b42 <gc_execute_line.constprop.11+0xe54>
    4b3a:	f7 fa       	bst	r15, 7
    4b3c:	f0 94       	com	r15
    4b3e:	f7 f8       	bld	r15, 7
    4b40:	f0 94       	com	r15
    4b42:	20 e0       	ldi	r18, 0x00	; 0
    4b44:	30 e0       	ldi	r19, 0x00	; 0
    4b46:	a9 01       	movw	r20, r18
    4b48:	c3 01       	movw	r24, r6
    4b4a:	b2 01       	movw	r22, r4
    4b4c:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    4b50:	87 ff       	sbrs	r24, 7
    4b52:	0f c0       	rjmp	.+30     	; 0x4b72 <gc_execute_line.constprop.11+0xe84>
    4b54:	f7 fa       	bst	r15, 7
    4b56:	f0 94       	com	r15
    4b58:	f7 f8       	bld	r15, 7
    4b5a:	f0 94       	com	r15
    4b5c:	d3 01       	movw	r26, r6
    4b5e:	c2 01       	movw	r24, r4
    4b60:	b0 58       	subi	r27, 0x80	; 128
    4b62:	80 93 fc 06 	sts	0x06FC, r24	; 0x8006fc <gc_block+0x25>
    4b66:	90 93 fd 06 	sts	0x06FD, r25	; 0x8006fd <gc_block+0x26>
    4b6a:	a0 93 fe 06 	sts	0x06FE, r26	; 0x8006fe <gc_block+0x27>
    4b6e:	b0 93 ff 06 	sts	0x06FF, r27	; 0x8006ff <gc_block+0x28>
    4b72:	0f a5       	ldd	r16, Y+47	; 0x2f
    4b74:	18 a9       	ldd	r17, Y+48	; 0x30
    4b76:	00 0f       	add	r16, r16
    4b78:	11 1f       	adc	r17, r17
    4b7a:	00 0f       	add	r16, r16
    4b7c:	11 1f       	adc	r17, r17
    4b7e:	09 51       	subi	r16, 0x19	; 25
    4b80:	19 4f       	sbci	r17, 0xF9	; 249
    4b82:	a7 01       	movw	r20, r14
    4b84:	96 01       	movw	r18, r12
    4b86:	6b a9       	ldd	r22, Y+51	; 0x33
    4b88:	7c a9       	ldd	r23, Y+52	; 0x34
    4b8a:	8d a9       	ldd	r24, Y+53	; 0x35
    4b8c:	9e a9       	ldd	r25, Y+54	; 0x36
    4b8e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4b92:	9b 01       	movw	r18, r22
    4b94:	ac 01       	movw	r20, r24
    4b96:	c5 01       	movw	r24, r10
    4b98:	b4 01       	movw	r22, r8
    4b9a:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4b9e:	20 e0       	ldi	r18, 0x00	; 0
    4ba0:	30 e0       	ldi	r19, 0x00	; 0
    4ba2:	40 e0       	ldi	r20, 0x00	; 0
    4ba4:	5f e3       	ldi	r21, 0x3F	; 63
    4ba6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4baa:	d8 01       	movw	r26, r16
    4bac:	6d 93       	st	X+, r22
    4bae:	7d 93       	st	X+, r23
    4bb0:	8d 93       	st	X+, r24
    4bb2:	9c 93       	st	X, r25
    4bb4:	13 97       	sbiw	r26, 0x03	; 3
    4bb6:	0b ad       	ldd	r16, Y+59	; 0x3b
    4bb8:	1c ad       	ldd	r17, Y+60	; 0x3c
    4bba:	00 0f       	add	r16, r16
    4bbc:	11 1f       	adc	r17, r17
    4bbe:	00 0f       	add	r16, r16
    4bc0:	11 1f       	adc	r17, r17
    4bc2:	09 51       	subi	r16, 0x19	; 25
    4bc4:	19 4f       	sbci	r17, 0xF9	; 249
    4bc6:	a7 01       	movw	r20, r14
    4bc8:	96 01       	movw	r18, r12
    4bca:	c5 01       	movw	r24, r10
    4bcc:	b4 01       	movw	r22, r8
    4bce:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4bd2:	2b a9       	ldd	r18, Y+51	; 0x33
    4bd4:	3c a9       	ldd	r19, Y+52	; 0x34
    4bd6:	4d a9       	ldd	r20, Y+53	; 0x35
    4bd8:	5e a9       	ldd	r21, Y+54	; 0x36
    4bda:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4bde:	20 e0       	ldi	r18, 0x00	; 0
    4be0:	30 e0       	ldi	r19, 0x00	; 0
    4be2:	40 e0       	ldi	r20, 0x00	; 0
    4be4:	5f e3       	ldi	r21, 0x3F	; 63
    4be6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4bea:	f8 01       	movw	r30, r16
    4bec:	60 83       	st	Z, r22
    4bee:	71 83       	std	Z+1, r23	; 0x01
    4bf0:	82 83       	std	Z+2, r24	; 0x02
    4bf2:	93 83       	std	Z+3, r25	; 0x03
    4bf4:	ff cd       	rjmp	.-1026   	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    4bf6:	c1 2e       	mov	r12, r17
    4bf8:	d1 2c       	mov	r13, r1
    4bfa:	e1 22       	and	r14, r17
    4bfc:	fd 20       	and	r15, r13
    4bfe:	83 e2       	ldi	r24, 0x23	; 35
    4c00:	ef 28       	or	r14, r15
    4c02:	09 f4       	brne	.+2      	; 0x4c06 <gc_execute_line.constprop.11+0xf18>
    4c04:	c3 c9       	rjmp	.-3194   	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    4c06:	f1 ef       	ldi	r31, 0xF1	; 241
    4c08:	2f 22       	and	r2, r31
    4c0a:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    4c0e:	81 30       	cpi	r24, 0x01	; 1
    4c10:	41 f5       	brne	.+80     	; 0x4c62 <gc_execute_line.constprop.11+0xf74>
    4c12:	07 ed       	ldi	r16, 0xD7	; 215
    4c14:	16 e0       	ldi	r17, 0x06	; 6
    4c16:	f1 2c       	mov	r15, r1
    4c18:	e1 2c       	mov	r14, r1
    4c1a:	c6 01       	movw	r24, r12
    4c1c:	0e 2c       	mov	r0, r14
    4c1e:	02 c0       	rjmp	.+4      	; 0x4c24 <gc_execute_line.constprop.11+0xf36>
    4c20:	95 95       	asr	r25
    4c22:	87 95       	ror	r24
    4c24:	0a 94       	dec	r0
    4c26:	e2 f7       	brpl	.-8      	; 0x4c20 <gc_execute_line.constprop.11+0xf32>
    4c28:	80 ff       	sbrs	r24, 0
    4c2a:	12 c0       	rjmp	.+36     	; 0x4c50 <gc_execute_line.constprop.11+0xf62>
    4c2c:	23 e3       	ldi	r18, 0x33	; 51
    4c2e:	33 e3       	ldi	r19, 0x33	; 51
    4c30:	4b ec       	ldi	r20, 0xCB	; 203
    4c32:	51 e4       	ldi	r21, 0x41	; 65
    4c34:	d8 01       	movw	r26, r16
    4c36:	50 96       	adiw	r26, 0x10	; 16
    4c38:	6d 91       	ld	r22, X+
    4c3a:	7d 91       	ld	r23, X+
    4c3c:	8d 91       	ld	r24, X+
    4c3e:	9c 91       	ld	r25, X
    4c40:	53 97       	sbiw	r26, 0x13	; 19
    4c42:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4c46:	f8 01       	movw	r30, r16
    4c48:	60 8b       	std	Z+16, r22	; 0x10
    4c4a:	71 8b       	std	Z+17, r23	; 0x11
    4c4c:	82 8b       	std	Z+18, r24	; 0x12
    4c4e:	93 8b       	std	Z+19, r25	; 0x13
    4c50:	ff ef       	ldi	r31, 0xFF	; 255
    4c52:	ef 1a       	sub	r14, r31
    4c54:	ff 0a       	sbc	r15, r31
    4c56:	0c 5f       	subi	r16, 0xFC	; 252
    4c58:	1f 4f       	sbci	r17, 0xFF	; 255
    4c5a:	23 e0       	ldi	r18, 0x03	; 3
    4c5c:	e2 16       	cp	r14, r18
    4c5e:	f1 04       	cpc	r15, r1
    4c60:	e1 f6       	brne	.-72     	; 0x4c1a <gc_execute_line.constprop.11+0xf2c>
    4c62:	ef a5       	ldd	r30, Y+47	; 0x2f
    4c64:	f8 a9       	ldd	r31, Y+48	; 0x30
    4c66:	ee 0f       	add	r30, r30
    4c68:	ff 1f       	adc	r31, r31
    4c6a:	ee 0f       	add	r30, r30
    4c6c:	ff 1f       	adc	r31, r31
    4c6e:	e9 51       	subi	r30, 0x19	; 25
    4c70:	f9 4f       	sbci	r31, 0xF9	; 249
    4c72:	c0 80       	ld	r12, Z
    4c74:	d1 80       	ldd	r13, Z+1	; 0x01
    4c76:	e2 80       	ldd	r14, Z+2	; 0x02
    4c78:	f3 80       	ldd	r15, Z+3	; 0x03
    4c7a:	a7 01       	movw	r20, r14
    4c7c:	96 01       	movw	r18, r12
    4c7e:	c5 01       	movw	r24, r10
    4c80:	b4 01       	movw	r22, r8
    4c82:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4c86:	4b 01       	movw	r8, r22
    4c88:	5c 01       	movw	r10, r24
    4c8a:	eb ad       	ldd	r30, Y+59	; 0x3b
    4c8c:	fc ad       	ldd	r31, Y+60	; 0x3c
    4c8e:	ee 0f       	add	r30, r30
    4c90:	ff 1f       	adc	r31, r31
    4c92:	ee 0f       	add	r30, r30
    4c94:	ff 1f       	adc	r31, r31
    4c96:	e9 51       	subi	r30, 0x19	; 25
    4c98:	f9 4f       	sbci	r31, 0xF9	; 249
    4c9a:	40 80       	ld	r4, Z
    4c9c:	51 80       	ldd	r5, Z+1	; 0x01
    4c9e:	62 80       	ldd	r6, Z+2	; 0x02
    4ca0:	73 80       	ldd	r7, Z+3	; 0x03
    4ca2:	a3 01       	movw	r20, r6
    4ca4:	92 01       	movw	r18, r4
    4ca6:	6b a9       	ldd	r22, Y+51	; 0x33
    4ca8:	7c a9       	ldd	r23, Y+52	; 0x34
    4caa:	8d a9       	ldd	r24, Y+53	; 0x35
    4cac:	9e a9       	ldd	r25, Y+54	; 0x36
    4cae:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4cb2:	9b 01       	movw	r18, r22
    4cb4:	ac 01       	movw	r20, r24
    4cb6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4cba:	6b ab       	std	Y+51, r22	; 0x33
    4cbc:	7c ab       	std	Y+52, r23	; 0x34
    4cbe:	8d ab       	std	Y+53, r24	; 0x35
    4cc0:	9e ab       	std	Y+54, r25	; 0x36
    4cc2:	a5 01       	movw	r20, r10
    4cc4:	94 01       	movw	r18, r8
    4cc6:	c5 01       	movw	r24, r10
    4cc8:	b4 01       	movw	r22, r8
    4cca:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4cce:	9b 01       	movw	r18, r22
    4cd0:	ac 01       	movw	r20, r24
    4cd2:	6b a9       	ldd	r22, Y+51	; 0x33
    4cd4:	7c a9       	ldd	r23, Y+52	; 0x34
    4cd6:	8d a9       	ldd	r24, Y+53	; 0x35
    4cd8:	9e a9       	ldd	r25, Y+54	; 0x36
    4cda:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4cde:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    4ce2:	4b 01       	movw	r8, r22
    4ce4:	5c 01       	movw	r10, r24
    4ce6:	a7 01       	movw	r20, r14
    4ce8:	96 01       	movw	r18, r12
    4cea:	c7 01       	movw	r24, r14
    4cec:	b6 01       	movw	r22, r12
    4cee:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4cf2:	6b 01       	movw	r12, r22
    4cf4:	7c 01       	movw	r14, r24
    4cf6:	a3 01       	movw	r20, r6
    4cf8:	92 01       	movw	r18, r4
    4cfa:	c3 01       	movw	r24, r6
    4cfc:	b2 01       	movw	r22, r4
    4cfe:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4d02:	9b 01       	movw	r18, r22
    4d04:	ac 01       	movw	r20, r24
    4d06:	c7 01       	movw	r24, r14
    4d08:	b6 01       	movw	r22, r12
    4d0a:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    4d0e:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    4d12:	6b 01       	movw	r12, r22
    4d14:	7c 01       	movw	r14, r24
    4d16:	c0 92 fc 06 	sts	0x06FC, r12	; 0x8006fc <gc_block+0x25>
    4d1a:	d0 92 fd 06 	sts	0x06FD, r13	; 0x8006fd <gc_block+0x26>
    4d1e:	e0 92 fe 06 	sts	0x06FE, r14	; 0x8006fe <gc_block+0x27>
    4d22:	f0 92 ff 06 	sts	0x06FF, r15	; 0x8006ff <gc_block+0x28>
    4d26:	ac 01       	movw	r20, r24
    4d28:	9b 01       	movw	r18, r22
    4d2a:	c5 01       	movw	r24, r10
    4d2c:	b4 01       	movw	r22, r8
    4d2e:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    4d32:	4b 01       	movw	r8, r22
    4d34:	5c 01       	movw	r10, r24
    4d36:	e8 94       	clt
    4d38:	b7 f8       	bld	r11, 7
    4d3a:	2a e0       	ldi	r18, 0x0A	; 10
    4d3c:	37 ed       	ldi	r19, 0xD7	; 215
    4d3e:	43 ea       	ldi	r20, 0xA3	; 163
    4d40:	5b e3       	ldi	r21, 0x3B	; 59
    4d42:	c5 01       	movw	r24, r10
    4d44:	b4 01       	movw	r22, r8
    4d46:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    4d4a:	18 16       	cp	r1, r24
    4d4c:	0c f0       	brlt	.+2      	; 0x4d50 <gc_execute_line.constprop.11+0x1062>
    4d4e:	52 cd       	rjmp	.-1372   	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    4d50:	20 e0       	ldi	r18, 0x00	; 0
    4d52:	30 e0       	ldi	r19, 0x00	; 0
    4d54:	40 e0       	ldi	r20, 0x00	; 0
    4d56:	5f e3       	ldi	r21, 0x3F	; 63
    4d58:	c5 01       	movw	r24, r10
    4d5a:	b4 01       	movw	r22, r8
    4d5c:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    4d60:	18 16       	cp	r1, r24
    4d62:	0c f4       	brge	.+2      	; 0x4d66 <gc_execute_line.constprop.11+0x1078>
    4d64:	65 ce       	rjmp	.-822    	; 0x4a30 <gc_execute_line.constprop.11+0xd42>
    4d66:	2f e6       	ldi	r18, 0x6F	; 111
    4d68:	32 e1       	ldi	r19, 0x12	; 18
    4d6a:	43 e8       	ldi	r20, 0x83	; 131
    4d6c:	5a e3       	ldi	r21, 0x3A	; 58
    4d6e:	c7 01       	movw	r24, r14
    4d70:	b6 01       	movw	r22, r12
    4d72:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    4d76:	9b 01       	movw	r18, r22
    4d78:	ac 01       	movw	r20, r24
    4d7a:	c5 01       	movw	r24, r10
    4d7c:	b4 01       	movw	r22, r8
    4d7e:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    4d82:	18 16       	cp	r1, r24
    4d84:	0c f0       	brlt	.+2      	; 0x4d88 <gc_execute_line.constprop.11+0x109a>
    4d86:	36 cd       	rjmp	.-1428   	; 0x47f4 <gc_execute_line.constprop.11+0xb06>
    4d88:	53 ce       	rjmp	.-858    	; 0x4a30 <gc_execute_line.constprop.11+0xd42>
    4d8a:	c1 01       	movw	r24, r2
    4d8c:	8e 7d       	andi	r24, 0xDE	; 222
    4d8e:	9c 7f       	andi	r25, 0xFC	; 252
    4d90:	38 cd       	rjmp	.-1424   	; 0x4802 <gc_execute_line.constprop.11+0xb14>
    4d92:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    4d96:	f0 90 a0 06 	lds	r15, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4d9a:	81 ff       	sbrs	r24, 1
    4d9c:	12 c0       	rjmp	.+36     	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    4d9e:	8f a1       	ldd	r24, Y+39	; 0x27
    4da0:	81 50       	subi	r24, 0x01	; 1
    4da2:	83 30       	cpi	r24, 0x03	; 3
    4da4:	18 f0       	brcs	.+6      	; 0x4dac <gc_execute_line.constprop.11+0x10be>
    4da6:	fb a1       	ldd	r31, Y+35	; 0x23
    4da8:	f0 64       	ori	r31, 0x40	; 64
    4daa:	fb a3       	std	Y+35, r31	; 0x23
    4dac:	2b 8d       	ldd	r18, Y+27	; 0x1b
    4dae:	22 23       	and	r18, r18
    4db0:	09 f4       	brne	.+2      	; 0x4db4 <gc_execute_line.constprop.11+0x10c6>
    4db2:	43 c1       	rjmp	.+646    	; 0x503a <gc_execute_line.constprop.11+0x134c>
    4db4:	3f 8d       	ldd	r19, Y+31	; 0x1f
    4db6:	32 30       	cpi	r19, 0x02	; 2
    4db8:	09 f0       	breq	.+2      	; 0x4dbc <gc_execute_line.constprop.11+0x10ce>
    4dba:	3f c1       	rjmp	.+638    	; 0x503a <gc_execute_line.constprop.11+0x134c>
    4dbc:	4b a1       	ldd	r20, Y+35	; 0x23
    4dbe:	40 68       	ori	r20, 0x80	; 128
    4dc0:	4b a3       	std	Y+35, r20	; 0x23
    4dc2:	80 91 f4 06 	lds	r24, 0x06F4	; 0x8006f4 <gc_block+0x1d>
    4dc6:	90 91 f5 06 	lds	r25, 0x06F5	; 0x8006f5 <gc_block+0x1e>
    4dca:	a0 91 f6 06 	lds	r26, 0x06F6	; 0x8006f6 <gc_block+0x1f>
    4dce:	b0 91 f7 06 	lds	r27, 0x06F7	; 0x8006f7 <gc_block+0x20>
    4dd2:	80 93 ab 06 	sts	0x06AB, r24	; 0x8006ab <gc_state+0x14>
    4dd6:	90 93 ac 06 	sts	0x06AC, r25	; 0x8006ac <gc_state+0x15>
    4dda:	a0 93 ad 06 	sts	0x06AD, r26	; 0x8006ad <gc_state+0x16>
    4dde:	b0 93 ae 06 	sts	0x06AE, r27	; 0x8006ae <gc_state+0x17>
    4de2:	80 91 d9 06 	lds	r24, 0x06D9	; 0x8006d9 <gc_block+0x2>
    4de6:	80 93 98 06 	sts	0x0698, r24	; 0x800698 <gc_state+0x1>
    4dea:	88 23       	and	r24, r24
    4dec:	11 f0       	breq	.+4      	; 0x4df2 <gc_execute_line.constprop.11+0x1104>
    4dee:	88 e0       	ldi	r24, 0x08	; 8
    4df0:	8d 8b       	std	Y+21, r24	; 0x15
    4df2:	80 91 e3 06 	lds	r24, 0x06E3	; 0x8006e3 <gc_block+0xc>
    4df6:	90 91 e4 06 	lds	r25, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4dfa:	a0 91 e5 06 	lds	r26, 0x06E5	; 0x8006e5 <gc_block+0xe>
    4dfe:	b0 91 e6 06 	lds	r27, 0x06E6	; 0x8006e6 <gc_block+0xf>
    4e02:	80 93 a6 06 	sts	0x06A6, r24	; 0x8006a6 <gc_state+0xf>
    4e06:	90 93 a7 06 	sts	0x06A7, r25	; 0x8006a7 <gc_state+0x10>
    4e0a:	a0 93 a8 06 	sts	0x06A8, r26	; 0x8006a8 <gc_state+0x11>
    4e0e:	b0 93 a9 06 	sts	0x06A9, r27	; 0x8006a9 <gc_state+0x12>
    4e12:	8d 87       	std	Y+13, r24	; 0x0d
    4e14:	9e 87       	std	Y+14, r25	; 0x0e
    4e16:	af 87       	std	Y+15, r26	; 0x0f
    4e18:	b8 8b       	std	Y+16, r27	; 0x10
    4e1a:	80 90 00 07 	lds	r8, 0x0700	; 0x800700 <gc_block+0x29>
    4e1e:	90 90 01 07 	lds	r9, 0x0701	; 0x800701 <gc_block+0x2a>
    4e22:	a0 90 02 07 	lds	r10, 0x0702	; 0x800702 <gc_block+0x2b>
    4e26:	b0 90 03 07 	lds	r11, 0x0703	; 0x800703 <gc_block+0x2c>
    4e2a:	a5 01       	movw	r20, r10
    4e2c:	94 01       	movw	r18, r8
    4e2e:	60 91 a2 06 	lds	r22, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4e32:	70 91 a3 06 	lds	r23, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4e36:	80 91 a4 06 	lds	r24, 0x06A4	; 0x8006a4 <gc_state+0xd>
    4e3a:	90 91 a5 06 	lds	r25, 0x06A5	; 0x8006a5 <gc_state+0xe>
    4e3e:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    4e42:	ab a1       	ldd	r26, Y+35	; 0x23
    4e44:	a0 74       	andi	r26, 0x40	; 64
    4e46:	ea 2e       	mov	r14, r26
    4e48:	81 11       	cpse	r24, r1
    4e4a:	03 c0       	rjmp	.+6      	; 0x4e52 <gc_execute_line.constprop.11+0x1164>
    4e4c:	bb a1       	ldd	r27, Y+35	; 0x23
    4e4e:	b5 ff       	sbrs	r27, 5
    4e50:	1f c0       	rjmp	.+62     	; 0x4e90 <gc_execute_line.constprop.11+0x11a2>
    4e52:	ff 20       	and	r15, r15
    4e54:	69 f0       	breq	.+26     	; 0x4e70 <gc_execute_line.constprop.11+0x1182>
    4e56:	eb a1       	ldd	r30, Y+35	; 0x23
    4e58:	e7 fd       	sbrc	r30, 7
    4e5a:	0a c0       	rjmp	.+20     	; 0x4e70 <gc_execute_line.constprop.11+0x1182>
    4e5c:	40 e0       	ldi	r20, 0x00	; 0
    4e5e:	50 e0       	ldi	r21, 0x00	; 0
    4e60:	ba 01       	movw	r22, r20
    4e62:	e1 10       	cpse	r14, r1
    4e64:	02 c0       	rjmp	.+4      	; 0x4e6a <gc_execute_line.constprop.11+0x117c>
    4e66:	b5 01       	movw	r22, r10
    4e68:	a4 01       	movw	r20, r8
    4e6a:	8f 2d       	mov	r24, r15
    4e6c:	0e 94 f9 1d 	call	0x3bf2	; 0x3bf2 <spindle_sync>
    4e70:	80 91 00 07 	lds	r24, 0x0700	; 0x800700 <gc_block+0x29>
    4e74:	90 91 01 07 	lds	r25, 0x0701	; 0x800701 <gc_block+0x2a>
    4e78:	a0 91 02 07 	lds	r26, 0x0702	; 0x800702 <gc_block+0x2b>
    4e7c:	b0 91 03 07 	lds	r27, 0x0703	; 0x800703 <gc_block+0x2c>
    4e80:	80 93 a2 06 	sts	0x06A2, r24	; 0x8006a2 <gc_state+0xb>
    4e84:	90 93 a3 06 	sts	0x06A3, r25	; 0x8006a3 <gc_state+0xc>
    4e88:	a0 93 a4 06 	sts	0x06A4, r26	; 0x8006a4 <gc_state+0xd>
    4e8c:	b0 93 a5 06 	sts	0x06A5, r27	; 0x8006a5 <gc_state+0xe>
    4e90:	e1 10       	cpse	r14, r1
    4e92:	0c c0       	rjmp	.+24     	; 0x4eac <gc_execute_line.constprop.11+0x11be>
    4e94:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4e98:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4e9c:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    4ea0:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    4ea4:	89 8b       	std	Y+17, r24	; 0x11
    4ea6:	9a 8b       	std	Y+18, r25	; 0x12
    4ea8:	ab 8b       	std	Y+19, r26	; 0x13
    4eaa:	bc 8b       	std	Y+20, r27	; 0x14
    4eac:	80 91 04 07 	lds	r24, 0x0704	; 0x800704 <gc_block+0x2d>
    4eb0:	80 93 aa 06 	sts	0x06AA, r24	; 0x8006aa <gc_state+0x13>
    4eb4:	80 91 e1 06 	lds	r24, 0x06E1	; 0x8006e1 <gc_block+0xa>
    4eb8:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4ebc:	98 17       	cp	r25, r24
    4ebe:	51 f0       	breq	.+20     	; 0x4ed4 <gc_execute_line.constprop.11+0x11e6>
    4ec0:	49 89       	ldd	r20, Y+17	; 0x11
    4ec2:	5a 89       	ldd	r21, Y+18	; 0x12
    4ec4:	6b 89       	ldd	r22, Y+19	; 0x13
    4ec6:	7c 89       	ldd	r23, Y+20	; 0x14
    4ec8:	0e 94 f9 1d 	call	0x3bf2	; 0x3bf2 <spindle_sync>
    4ecc:	80 91 e1 06 	lds	r24, 0x06E1	; 0x8006e1 <gc_block+0xa>
    4ed0:	80 93 a0 06 	sts	0x06A0, r24	; 0x8006a0 <gc_state+0x9>
    4ed4:	8d 89       	ldd	r24, Y+21	; 0x15
    4ed6:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4eda:	89 2b       	or	r24, r25
    4edc:	8d 8b       	std	Y+21, r24	; 0x15
    4ede:	f0 90 e0 06 	lds	r15, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4ee2:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    4ee6:	8f 15       	cp	r24, r15
    4ee8:	69 f0       	breq	.+26     	; 0x4f04 <gc_execute_line.constprop.11+0x1216>
    4eea:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    4eee:	82 30       	cpi	r24, 0x02	; 2
    4ef0:	29 f0       	breq	.+10     	; 0x4efc <gc_execute_line.constprop.11+0x120e>
    4ef2:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    4ef6:	8f 2d       	mov	r24, r15
    4ef8:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    4efc:	80 91 e0 06 	lds	r24, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4f00:	80 93 9f 06 	sts	0x069F, r24	; 0x80069f <gc_state+0x8>
    4f04:	8d 89       	ldd	r24, Y+21	; 0x15
    4f06:	90 91 9f 06 	lds	r25, 0x069F	; 0x80069f <gc_state+0x8>
    4f0a:	89 2b       	or	r24, r25
    4f0c:	8d 8b       	std	Y+21, r24	; 0x15
    4f0e:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    4f12:	84 30       	cpi	r24, 0x04	; 4
    4f14:	99 f4       	brne	.+38     	; 0x4f3c <gc_execute_line.constprop.11+0x124e>
    4f16:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    4f1a:	82 30       	cpi	r24, 0x02	; 2
    4f1c:	79 f0       	breq	.+30     	; 0x4f3c <gc_execute_line.constprop.11+0x124e>
    4f1e:	c0 90 f8 06 	lds	r12, 0x06F8	; 0x8006f8 <gc_block+0x21>
    4f22:	d0 90 f9 06 	lds	r13, 0x06F9	; 0x8006f9 <gc_block+0x22>
    4f26:	e0 90 fa 06 	lds	r14, 0x06FA	; 0x8006fa <gc_block+0x23>
    4f2a:	f0 90 fb 06 	lds	r15, 0x06FB	; 0x8006fb <gc_block+0x24>
    4f2e:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    4f32:	40 e0       	ldi	r20, 0x00	; 0
    4f34:	c7 01       	movw	r24, r14
    4f36:	b6 01       	movw	r22, r12
    4f38:	0e 94 02 1d 	call	0x3a04	; 0x3a04 <delay_sec>
    4f3c:	80 91 dc 06 	lds	r24, 0x06DC	; 0x8006dc <gc_block+0x5>
    4f40:	80 93 9b 06 	sts	0x069B, r24	; 0x80069b <gc_state+0x4>
    4f44:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    4f48:	80 93 99 06 	sts	0x0699, r24	; 0x800699 <gc_state+0x2>
    4f4c:	ff 8d       	ldd	r31, Y+31	; 0x1f
    4f4e:	f3 30       	cpi	r31, 0x03	; 3
    4f50:	71 f5       	brne	.+92     	; 0x4fae <gc_execute_line.constprop.11+0x12c0>
    4f52:	80 91 dd 06 	lds	r24, 0x06DD	; 0x8006dd <gc_block+0x6>
    4f56:	80 93 9c 06 	sts	0x069C, r24	; 0x80069c <gc_state+0x5>
    4f5a:	81 11       	cpse	r24, r1
    4f5c:	08 c0       	rjmp	.+16     	; 0x4f6e <gc_execute_line.constprop.11+0x1280>
    4f5e:	10 92 0d 07 	sts	0x070D, r1	; 0x80070d <gc_block+0x36>
    4f62:	10 92 0e 07 	sts	0x070E, r1	; 0x80070e <gc_block+0x37>
    4f66:	10 92 0f 07 	sts	0x070F, r1	; 0x80070f <gc_block+0x38>
    4f6a:	10 92 10 07 	sts	0x0710, r1	; 0x800710 <gc_block+0x39>
    4f6e:	c0 90 0d 07 	lds	r12, 0x070D	; 0x80070d <gc_block+0x36>
    4f72:	d0 90 0e 07 	lds	r13, 0x070E	; 0x80070e <gc_block+0x37>
    4f76:	e0 90 0f 07 	lds	r14, 0x070F	; 0x80070f <gc_block+0x38>
    4f7a:	f0 90 10 07 	lds	r15, 0x0710	; 0x800710 <gc_block+0x39>
    4f7e:	a7 01       	movw	r20, r14
    4f80:	96 01       	movw	r18, r12
    4f82:	60 91 d3 06 	lds	r22, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    4f86:	70 91 d4 06 	lds	r23, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    4f8a:	80 91 d5 06 	lds	r24, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4f8e:	90 91 d6 06 	lds	r25, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4f92:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    4f96:	88 23       	and	r24, r24
    4f98:	51 f0       	breq	.+20     	; 0x4fae <gc_execute_line.constprop.11+0x12c0>
    4f9a:	c0 92 d3 06 	sts	0x06D3, r12	; 0x8006d3 <gc_state+0x3c>
    4f9e:	d0 92 d4 06 	sts	0x06D4, r13	; 0x8006d4 <gc_state+0x3d>
    4fa2:	e0 92 d5 06 	sts	0x06D5, r14	; 0x8006d5 <gc_state+0x3e>
    4fa6:	f0 92 d6 06 	sts	0x06D6, r15	; 0x8006d6 <gc_state+0x3f>
    4faa:	0e 94 62 1d 	call	0x3ac4	; 0x3ac4 <system_flag_wco_change>
    4fae:	80 91 de 06 	lds	r24, 0x06DE	; 0x8006de <gc_block+0x7>
    4fb2:	90 91 9d 06 	lds	r25, 0x069D	; 0x80069d <gc_state+0x6>
    4fb6:	98 17       	cp	r25, r24
    4fb8:	69 f0       	breq	.+26     	; 0x4fd4 <gc_execute_line.constprop.11+0x12e6>
    4fba:	80 93 9d 06 	sts	0x069D, r24	; 0x80069d <gc_state+0x6>
    4fbe:	8c e0       	ldi	r24, 0x0C	; 12
    4fc0:	fe 01       	movw	r30, r28
    4fc2:	31 96       	adiw	r30, 0x01	; 1
    4fc4:	ab eb       	ldi	r26, 0xBB	; 187
    4fc6:	b6 e0       	ldi	r27, 0x06	; 6
    4fc8:	01 90       	ld	r0, Z+
    4fca:	0d 92       	st	X+, r0
    4fcc:	8a 95       	dec	r24
    4fce:	e1 f7       	brne	.-8      	; 0x4fc8 <gc_execute_line.constprop.11+0x12da>
    4fd0:	0e 94 62 1d 	call	0x3ac4	; 0x3ac4 <system_flag_wco_change>
    4fd4:	80 91 db 06 	lds	r24, 0x06DB	; 0x8006db <gc_block+0x4>
    4fd8:	80 93 9a 06 	sts	0x069A, r24	; 0x80069a <gc_state+0x3>
    4fdc:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    4fe0:	86 32       	cpi	r24, 0x26	; 38
    4fe2:	09 f4       	brne	.+2      	; 0x4fe6 <gc_execute_line.constprop.11+0x12f8>
    4fe4:	7e c0       	rjmp	.+252    	; 0x50e2 <gc_execute_line.constprop.11+0x13f4>
    4fe6:	08 f0       	brcs	.+2      	; 0x4fea <gc_execute_line.constprop.11+0x12fc>
    4fe8:	3f c0       	rjmp	.+126    	; 0x5068 <gc_execute_line.constprop.11+0x137a>
    4fea:	8c 31       	cpi	r24, 0x1C	; 28
    4fec:	09 f4       	brne	.+2      	; 0x4ff0 <gc_execute_line.constprop.11+0x1302>
    4fee:	5f c0       	rjmp	.+190    	; 0x50ae <gc_execute_line.constprop.11+0x13c0>
    4ff0:	8e 31       	cpi	r24, 0x1E	; 30
    4ff2:	09 f4       	brne	.+2      	; 0x4ff6 <gc_execute_line.constprop.11+0x1308>
    4ff4:	5c c0       	rjmp	.+184    	; 0x50ae <gc_execute_line.constprop.11+0x13c0>
    4ff6:	8a 30       	cpi	r24, 0x0A	; 10
    4ff8:	09 f4       	brne	.+2      	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    4ffa:	43 c0       	rjmp	.+134    	; 0x5082 <gc_execute_line.constprop.11+0x1394>
    4ffc:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    5000:	80 93 97 06 	sts	0x0697, r24	; 0x800697 <gc_state>
    5004:	80 35       	cpi	r24, 0x50	; 80
    5006:	09 f4       	brne	.+2      	; 0x500a <gc_execute_line.constprop.11+0x131c>
    5008:	3e c3       	rjmp	.+1660   	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    500a:	bf 8d       	ldd	r27, Y+31	; 0x1f
    500c:	b2 30       	cpi	r27, 0x02	; 2
    500e:	09 f0       	breq	.+2      	; 0x5012 <gc_execute_line.constprop.11+0x1324>
    5010:	3a c3       	rjmp	.+1652   	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    5012:	81 30       	cpi	r24, 0x01	; 1
    5014:	09 f0       	breq	.+2      	; 0x5018 <gc_execute_line.constprop.11+0x132a>
    5016:	79 c0       	rjmp	.+242    	; 0x510a <gc_execute_line.constprop.11+0x141c>
    5018:	be 01       	movw	r22, r28
    501a:	63 5f       	subi	r22, 0xF3	; 243
    501c:	7f 4f       	sbci	r23, 0xFF	; 255
    501e:	85 e0       	ldi	r24, 0x05	; 5
    5020:	97 e0       	ldi	r25, 0x07	; 7
    5022:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    5026:	8c e0       	ldi	r24, 0x0C	; 12
    5028:	e5 e0       	ldi	r30, 0x05	; 5
    502a:	f7 e0       	ldi	r31, 0x07	; 7
    502c:	af ea       	ldi	r26, 0xAF	; 175
    502e:	b6 e0       	ldi	r27, 0x06	; 6
    5030:	01 90       	ld	r0, Z+
    5032:	0d 92       	st	X+, r0
    5034:	8a 95       	dec	r24
    5036:	e1 f7       	brne	.-8      	; 0x5030 <gc_execute_line.constprop.11+0x1342>
    5038:	26 c3       	rjmp	.+1612   	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    503a:	50 e1       	ldi	r21, 0x10	; 16
    503c:	f5 12       	cpse	r15, r21
    503e:	c1 ce       	rjmp	.-638    	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    5040:	9b a1       	ldd	r25, Y+35	; 0x23
    5042:	90 74       	andi	r25, 0x40	; 64
    5044:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    5048:	81 50       	subi	r24, 0x01	; 1
    504a:	83 30       	cpi	r24, 0x03	; 3
    504c:	38 f4       	brcc	.+14     	; 0x505c <gc_execute_line.constprop.11+0x136e>
    504e:	99 23       	and	r25, r25
    5050:	09 f4       	brne	.+2      	; 0x5054 <gc_execute_line.constprop.11+0x1366>
    5052:	b7 ce       	rjmp	.-658    	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    5054:	8b a1       	ldd	r24, Y+35	; 0x23
    5056:	80 62       	ori	r24, 0x20	; 32
    5058:	8b a3       	std	Y+35, r24	; 0x23
    505a:	b3 ce       	rjmp	.-666    	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    505c:	91 11       	cpse	r25, r1
    505e:	b1 ce       	rjmp	.-670    	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    5060:	9b a1       	ldd	r25, Y+35	; 0x23
    5062:	90 62       	ori	r25, 0x20	; 32
    5064:	9b a3       	std	Y+35, r25	; 0x23
    5066:	ad ce       	rjmp	.-678    	; 0x4dc2 <gc_execute_line.constprop.11+0x10d4>
    5068:	8c 35       	cpi	r24, 0x5C	; 92
    506a:	09 f4       	brne	.+2      	; 0x506e <gc_execute_line.constprop.11+0x1380>
    506c:	40 c0       	rjmp	.+128    	; 0x50ee <gc_execute_line.constprop.11+0x1400>
    506e:	86 36       	cpi	r24, 0x66	; 102
    5070:	09 f4       	brne	.+2      	; 0x5074 <gc_execute_line.constprop.11+0x1386>
    5072:	43 c0       	rjmp	.+134    	; 0x50fa <gc_execute_line.constprop.11+0x140c>
    5074:	88 32       	cpi	r24, 0x28	; 40
    5076:	09 f0       	breq	.+2      	; 0x507a <gc_execute_line.constprop.11+0x138c>
    5078:	c1 cf       	rjmp	.-126    	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    507a:	6f ea       	ldi	r22, 0xAF	; 175
    507c:	76 e0       	ldi	r23, 0x06	; 6
    507e:	87 e0       	ldi	r24, 0x07	; 7
    5080:	33 c0       	rjmp	.+102    	; 0x50e8 <gc_execute_line.constprop.11+0x13fa>
    5082:	67 ee       	ldi	r22, 0xE7	; 231
    5084:	76 e0       	ldi	r23, 0x06	; 6
    5086:	89 a5       	ldd	r24, Y+41	; 0x29
    5088:	0e 94 67 1d 	call	0x3ace	; 0x3ace <settings_write_coord_data>
    508c:	80 91 9d 06 	lds	r24, 0x069D	; 0x80069d <gc_state+0x6>
    5090:	29 a5       	ldd	r18, Y+41	; 0x29
    5092:	28 13       	cpse	r18, r24
    5094:	b3 cf       	rjmp	.-154    	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    5096:	8c e0       	ldi	r24, 0x0C	; 12
    5098:	e7 ee       	ldi	r30, 0xE7	; 231
    509a:	f6 e0       	ldi	r31, 0x06	; 6
    509c:	ab eb       	ldi	r26, 0xBB	; 187
    509e:	b6 e0       	ldi	r27, 0x06	; 6
    50a0:	01 90       	ld	r0, Z+
    50a2:	0d 92       	st	X+, r0
    50a4:	8a 95       	dec	r24
    50a6:	e1 f7       	brne	.-8      	; 0x50a0 <gc_execute_line.constprop.11+0x13b2>
    50a8:	0e 94 62 1d 	call	0x3ac4	; 0x3ac4 <system_flag_wco_change>
    50ac:	a7 cf       	rjmp	.-178    	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    50ae:	8d 89       	ldd	r24, Y+21	; 0x15
    50b0:	81 60       	ori	r24, 0x01	; 1
    50b2:	8d 8b       	std	Y+21, r24	; 0x15
    50b4:	3f 8d       	ldd	r19, Y+31	; 0x1f
    50b6:	33 23       	and	r19, r19
    50b8:	29 f0       	breq	.+10     	; 0x50c4 <gc_execute_line.constprop.11+0x13d6>
    50ba:	b8 01       	movw	r22, r16
    50bc:	85 e0       	ldi	r24, 0x05	; 5
    50be:	97 e0       	ldi	r25, 0x07	; 7
    50c0:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    50c4:	b8 01       	movw	r22, r16
    50c6:	87 ee       	ldi	r24, 0xE7	; 231
    50c8:	96 e0       	ldi	r25, 0x06	; 6
    50ca:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    50ce:	8c e0       	ldi	r24, 0x0C	; 12
    50d0:	e7 ee       	ldi	r30, 0xE7	; 231
    50d2:	f6 e0       	ldi	r31, 0x06	; 6
    50d4:	af ea       	ldi	r26, 0xAF	; 175
    50d6:	b6 e0       	ldi	r27, 0x06	; 6
    50d8:	01 90       	ld	r0, Z+
    50da:	0d 92       	st	X+, r0
    50dc:	8a 95       	dec	r24
    50de:	e1 f7       	brne	.-8      	; 0x50d8 <gc_execute_line.constprop.11+0x13ea>
    50e0:	8d cf       	rjmp	.-230    	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    50e2:	6f ea       	ldi	r22, 0xAF	; 175
    50e4:	76 e0       	ldi	r23, 0x06	; 6
    50e6:	86 e0       	ldi	r24, 0x06	; 6
    50e8:	0e 94 67 1d 	call	0x3ace	; 0x3ace <settings_write_coord_data>
    50ec:	87 cf       	rjmp	.-242    	; 0x4ffc <gc_execute_line.constprop.11+0x130e>
    50ee:	8c e0       	ldi	r24, 0x0C	; 12
    50f0:	e5 e0       	ldi	r30, 0x05	; 5
    50f2:	f7 e0       	ldi	r31, 0x07	; 7
    50f4:	a7 ec       	ldi	r26, 0xC7	; 199
    50f6:	b6 e0       	ldi	r27, 0x06	; 6
    50f8:	d3 cf       	rjmp	.-90     	; 0x50a0 <gc_execute_line.constprop.11+0x13b2>
    50fa:	e7 ec       	ldi	r30, 0xC7	; 199
    50fc:	f6 e0       	ldi	r31, 0x06	; 6
    50fe:	8c e0       	ldi	r24, 0x0C	; 12
    5100:	df 01       	movw	r26, r30
    5102:	1d 92       	st	X+, r1
    5104:	8a 95       	dec	r24
    5106:	e9 f7       	brne	.-6      	; 0x5102 <gc_execute_line.constprop.11+0x1414>
    5108:	cf cf       	rjmp	.-98     	; 0x50a8 <gc_execute_line.constprop.11+0x13ba>
    510a:	81 11       	cpse	r24, r1
    510c:	05 c0       	rjmp	.+10     	; 0x5118 <gc_execute_line.constprop.11+0x142a>
    510e:	8d 89       	ldd	r24, Y+21	; 0x15
    5110:	81 60       	ori	r24, 0x01	; 1
    5112:	8d 8b       	std	Y+21, r24	; 0x15
    5114:	b8 01       	movw	r22, r16
    5116:	83 cf       	rjmp	.-250    	; 0x501e <gc_execute_line.constprop.11+0x1330>
    5118:	82 50       	subi	r24, 0x02	; 2
    511a:	82 30       	cpi	r24, 0x02	; 2
    511c:	08 f0       	brcs	.+2      	; 0x5120 <gc_execute_line.constprop.11+0x1432>
    511e:	8c c2       	rjmp	.+1304   	; 0x5638 <gc_execute_line.constprop.11+0x194a>
    5120:	20 91 fc 06 	lds	r18, 0x06FC	; 0x8006fc <gc_block+0x25>
    5124:	30 91 fd 06 	lds	r19, 0x06FD	; 0x8006fd <gc_block+0x26>
    5128:	40 91 fe 06 	lds	r20, 0x06FE	; 0x8006fe <gc_block+0x27>
    512c:	50 91 ff 06 	lds	r21, 0x06FF	; 0x8006ff <gc_block+0x28>
    5130:	2f 8f       	std	Y+31, r18	; 0x1f
    5132:	38 a3       	std	Y+32, r19	; 0x20
    5134:	49 a3       	std	Y+33, r20	; 0x21
    5136:	5a a3       	std	Y+34, r21	; 0x22
    5138:	4f a9       	ldd	r20, Y+55	; 0x37
    513a:	34 e0       	ldi	r19, 0x04	; 4
    513c:	43 9f       	mul	r20, r19
    513e:	80 01       	movw	r16, r0
    5140:	11 24       	eor	r1, r1
    5142:	c8 01       	movw	r24, r16
    5144:	81 55       	subi	r24, 0x51	; 81
    5146:	99 4f       	sbci	r25, 0xF9	; 249
    5148:	98 a7       	std	Y+40, r25	; 0x28
    514a:	8f a3       	std	Y+39, r24	; 0x27
    514c:	d8 01       	movw	r26, r16
    514e:	a9 51       	subi	r26, 0x19	; 25
    5150:	b9 4f       	sbci	r27, 0xF9	; 249
    5152:	ba a7       	std	Y+42, r27	; 0x2a
    5154:	a9 a7       	std	Y+41, r26	; 0x29
    5156:	4d 90       	ld	r4, X+
    5158:	5d 90       	ld	r5, X+
    515a:	6d 90       	ld	r6, X+
    515c:	7c 90       	ld	r7, X
    515e:	fc 01       	movw	r30, r24
    5160:	20 81       	ld	r18, Z
    5162:	31 81       	ldd	r19, Z+1	; 0x01
    5164:	42 81       	ldd	r20, Z+2	; 0x02
    5166:	53 81       	ldd	r21, Z+3	; 0x03
    5168:	c3 01       	movw	r24, r6
    516a:	b2 01       	movw	r22, r4
    516c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    5170:	6b a7       	std	Y+43, r22	; 0x2b
    5172:	7c a7       	std	Y+44, r23	; 0x2c
    5174:	8d a7       	std	Y+45, r24	; 0x2d
    5176:	9e a7       	std	Y+46, r25	; 0x2e
    5178:	29 ad       	ldd	r18, Y+57	; 0x39
    517a:	f4 e0       	ldi	r31, 0x04	; 4
    517c:	2f 9f       	mul	r18, r31
    517e:	50 01       	movw	r10, r0
    5180:	11 24       	eor	r1, r1
    5182:	a5 01       	movw	r20, r10
    5184:	41 55       	subi	r20, 0x51	; 81
    5186:	59 4f       	sbci	r21, 0xF9	; 249
    5188:	58 af       	std	Y+56, r21	; 0x38
    518a:	4f ab       	std	Y+55, r20	; 0x37
    518c:	c5 01       	movw	r24, r10
    518e:	89 51       	subi	r24, 0x19	; 25
    5190:	99 4f       	sbci	r25, 0xF9	; 249
    5192:	9a af       	std	Y+58, r25	; 0x3a
    5194:	89 af       	std	Y+57, r24	; 0x39
    5196:	dc 01       	movw	r26, r24
    5198:	cd 90       	ld	r12, X+
    519a:	dd 90       	ld	r13, X+
    519c:	ed 90       	ld	r14, X+
    519e:	fc 90       	ld	r15, X
    51a0:	fa 01       	movw	r30, r20
    51a2:	20 81       	ld	r18, Z
    51a4:	31 81       	ldd	r19, Z+1	; 0x01
    51a6:	42 81       	ldd	r20, Z+2	; 0x02
    51a8:	53 81       	ldd	r21, Z+3	; 0x03
    51aa:	c7 01       	movw	r24, r14
    51ac:	b6 01       	movw	r22, r12
    51ae:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    51b2:	6b ab       	std	Y+51, r22	; 0x33
    51b4:	7c ab       	std	Y+52, r23	; 0x34
    51b6:	8d ab       	std	Y+53, r24	; 0x35
    51b8:	9e ab       	std	Y+54, r25	; 0x36
    51ba:	77 fa       	bst	r7, 7
    51bc:	70 94       	com	r7
    51be:	77 f8       	bld	r7, 7
    51c0:	70 94       	com	r7
    51c2:	a7 01       	movw	r20, r14
    51c4:	96 01       	movw	r18, r12
    51c6:	50 58       	subi	r21, 0x80	; 128
    51c8:	2b 8f       	std	Y+27, r18	; 0x1b
    51ca:	3c 8f       	std	Y+28, r19	; 0x1c
    51cc:	4d 8f       	std	Y+29, r20	; 0x1d
    51ce:	5e 8f       	std	Y+30, r21	; 0x1e
    51d0:	f8 01       	movw	r30, r16
    51d2:	eb 5f       	subi	r30, 0xFB	; 251
    51d4:	f8 4f       	sbci	r31, 0xF8	; 248
    51d6:	2b a5       	ldd	r18, Y+43	; 0x2b
    51d8:	3c a5       	ldd	r19, Y+44	; 0x2c
    51da:	4d a5       	ldd	r20, Y+45	; 0x2d
    51dc:	5e a5       	ldd	r21, Y+46	; 0x2e
    51de:	60 81       	ld	r22, Z
    51e0:	71 81       	ldd	r23, Z+1	; 0x01
    51e2:	82 81       	ldd	r24, Z+2	; 0x02
    51e4:	93 81       	ldd	r25, Z+3	; 0x03
    51e6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    51ea:	6b 01       	movw	r12, r22
    51ec:	7c 01       	movw	r14, r24
    51ee:	f5 01       	movw	r30, r10
    51f0:	eb 5f       	subi	r30, 0xFB	; 251
    51f2:	f8 4f       	sbci	r31, 0xF8	; 248
    51f4:	2b a9       	ldd	r18, Y+51	; 0x33
    51f6:	3c a9       	ldd	r19, Y+52	; 0x34
    51f8:	4d a9       	ldd	r20, Y+53	; 0x35
    51fa:	5e a9       	ldd	r21, Y+54	; 0x36
    51fc:	60 81       	ld	r22, Z
    51fe:	71 81       	ldd	r23, Z+1	; 0x01
    5200:	82 81       	ldd	r24, Z+2	; 0x02
    5202:	93 81       	ldd	r25, Z+3	; 0x03
    5204:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    5208:	4b 01       	movw	r8, r22
    520a:	5c 01       	movw	r10, r24
    520c:	a7 01       	movw	r20, r14
    520e:	96 01       	movw	r18, r12
    5210:	c3 01       	movw	r24, r6
    5212:	b2 01       	movw	r22, r4
    5214:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5218:	6f a7       	std	Y+47, r22	; 0x2f
    521a:	78 ab       	std	Y+48, r23	; 0x30
    521c:	89 ab       	std	Y+49, r24	; 0x31
    521e:	9a ab       	std	Y+50, r25	; 0x32
    5220:	a5 01       	movw	r20, r10
    5222:	94 01       	movw	r18, r8
    5224:	6b 8d       	ldd	r22, Y+27	; 0x1b
    5226:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5228:	8d 8d       	ldd	r24, Y+29	; 0x1d
    522a:	9e 8d       	ldd	r25, Y+30	; 0x1e
    522c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5230:	9b 01       	movw	r18, r22
    5232:	ac 01       	movw	r20, r24
    5234:	6f a5       	ldd	r22, Y+47	; 0x2f
    5236:	78 a9       	ldd	r23, Y+48	; 0x30
    5238:	89 a9       	ldd	r24, Y+49	; 0x31
    523a:	9a a9       	ldd	r25, Y+50	; 0x32
    523c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    5240:	6f a7       	std	Y+47, r22	; 0x2f
    5242:	78 ab       	std	Y+48, r23	; 0x30
    5244:	89 ab       	std	Y+49, r24	; 0x31
    5246:	9a ab       	std	Y+50, r25	; 0x32
    5248:	a5 01       	movw	r20, r10
    524a:	94 01       	movw	r18, r8
    524c:	c3 01       	movw	r24, r6
    524e:	b2 01       	movw	r22, r4
    5250:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5254:	4b 01       	movw	r8, r22
    5256:	5c 01       	movw	r10, r24
    5258:	a7 01       	movw	r20, r14
    525a:	96 01       	movw	r18, r12
    525c:	6b 8d       	ldd	r22, Y+27	; 0x1b
    525e:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5260:	8d 8d       	ldd	r24, Y+29	; 0x1d
    5262:	9e 8d       	ldd	r25, Y+30	; 0x1e
    5264:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5268:	9b 01       	movw	r18, r22
    526a:	ac 01       	movw	r20, r24
    526c:	c5 01       	movw	r24, r10
    526e:	b4 01       	movw	r22, r8
    5270:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    5274:	2f a5       	ldd	r18, Y+47	; 0x2f
    5276:	38 a9       	ldd	r19, Y+48	; 0x30
    5278:	49 a9       	ldd	r20, Y+49	; 0x31
    527a:	5a a9       	ldd	r21, Y+50	; 0x32
    527c:	0e 94 90 35 	call	0x6b20	; 0x6b20 <atan2>
    5280:	6b 01       	movw	r12, r22
    5282:	7c 01       	movw	r14, r24
    5284:	3b a1       	ldd	r19, Y+35	; 0x23
    5286:	32 ff       	sbrs	r19, 2
    5288:	60 c1       	rjmp	.+704    	; 0x554a <gc_execute_line.constprop.11+0x185c>
    528a:	2d eb       	ldi	r18, 0xBD	; 189
    528c:	37 e3       	ldi	r19, 0x37	; 55
    528e:	46 e0       	ldi	r20, 0x06	; 6
    5290:	55 eb       	ldi	r21, 0xB5	; 181
    5292:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    5296:	87 fd       	sbrc	r24, 7
    5298:	0a c0       	rjmp	.+20     	; 0x52ae <gc_execute_line.constprop.11+0x15c0>
    529a:	2b ed       	ldi	r18, 0xDB	; 219
    529c:	3f e0       	ldi	r19, 0x0F	; 15
    529e:	49 ec       	ldi	r20, 0xC9	; 201
    52a0:	50 e4       	ldi	r21, 0x40	; 64
    52a2:	c7 01       	movw	r24, r14
    52a4:	b6 01       	movw	r22, r12
    52a6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    52aa:	6b 01       	movw	r12, r22
    52ac:	7c 01       	movw	r14, r24
    52ae:	80 90 7b 06 	lds	r8, 0x067B	; 0x80067b <settings+0x39>
    52b2:	90 90 7c 06 	lds	r9, 0x067C	; 0x80067c <settings+0x3a>
    52b6:	a0 90 7d 06 	lds	r10, 0x067D	; 0x80067d <settings+0x3b>
    52ba:	b0 90 7e 06 	lds	r11, 0x067E	; 0x80067e <settings+0x3c>
    52be:	2f 8d       	ldd	r18, Y+31	; 0x1f
    52c0:	38 a1       	ldd	r19, Y+32	; 0x20
    52c2:	49 a1       	ldd	r20, Y+33	; 0x21
    52c4:	5a a1       	ldd	r21, Y+34	; 0x22
    52c6:	ca 01       	movw	r24, r20
    52c8:	b9 01       	movw	r22, r18
    52ca:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    52ce:	a5 01       	movw	r20, r10
    52d0:	94 01       	movw	r18, r8
    52d2:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    52d6:	a5 01       	movw	r20, r10
    52d8:	94 01       	movw	r18, r8
    52da:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    52de:	0e 94 07 39 	call	0x720e	; 0x720e <sqrt>
    52e2:	4b 01       	movw	r8, r22
    52e4:	5c 01       	movw	r10, r24
    52e6:	20 e0       	ldi	r18, 0x00	; 0
    52e8:	30 e0       	ldi	r19, 0x00	; 0
    52ea:	40 e0       	ldi	r20, 0x00	; 0
    52ec:	5f e3       	ldi	r21, 0x3F	; 63
    52ee:	6f 8d       	ldd	r22, Y+31	; 0x1f
    52f0:	78 a1       	ldd	r23, Y+32	; 0x20
    52f2:	89 a1       	ldd	r24, Y+33	; 0x21
    52f4:	9a a1       	ldd	r25, Y+34	; 0x22
    52f6:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    52fa:	a7 01       	movw	r20, r14
    52fc:	96 01       	movw	r18, r12
    52fe:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5302:	9f 77       	andi	r25, 0x7F	; 127
    5304:	a5 01       	movw	r20, r10
    5306:	94 01       	movw	r18, r8
    5308:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    530c:	0e 94 f5 36 	call	0x6dea	; 0x6dea <floor>
    5310:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    5314:	78 ab       	std	Y+48, r23	; 0x30
    5316:	6f a7       	std	Y+47, r22	; 0x2f
    5318:	61 15       	cp	r22, r1
    531a:	71 05       	cpc	r23, r1
    531c:	09 f4       	brne	.+2      	; 0x5320 <gc_execute_line.constprop.11+0x1632>
    531e:	7c ce       	rjmp	.-776    	; 0x5018 <gc_execute_line.constprop.11+0x132a>
    5320:	1d 89       	ldd	r17, Y+21	; 0x15
    5322:	90 e0       	ldi	r25, 0x00	; 0
    5324:	80 e0       	ldi	r24, 0x00	; 0
    5326:	0e 94 b8 36 	call	0x6d70	; 0x6d70 <__floatunsisf>
    532a:	4b 01       	movw	r8, r22
    532c:	5c 01       	movw	r10, r24
    532e:	13 ff       	sbrs	r17, 3
    5330:	0e c0       	rjmp	.+28     	; 0x534e <gc_execute_line.constprop.11+0x1660>
    5332:	ac 01       	movw	r20, r24
    5334:	9b 01       	movw	r18, r22
    5336:	6d 85       	ldd	r22, Y+13	; 0x0d
    5338:	7e 85       	ldd	r23, Y+14	; 0x0e
    533a:	8f 85       	ldd	r24, Y+15	; 0x0f
    533c:	98 89       	ldd	r25, Y+16	; 0x10
    533e:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5342:	6d 87       	std	Y+13, r22	; 0x0d
    5344:	7e 87       	std	Y+14, r23	; 0x0e
    5346:	8f 87       	std	Y+15, r24	; 0x0f
    5348:	98 8b       	std	Y+16, r25	; 0x10
    534a:	17 7f       	andi	r17, 0xF7	; 247
    534c:	1d 8b       	std	Y+21, r17	; 0x15
    534e:	a5 01       	movw	r20, r10
    5350:	94 01       	movw	r18, r8
    5352:	c7 01       	movw	r24, r14
    5354:	b6 01       	movw	r22, r12
    5356:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    535a:	6b a3       	std	Y+35, r22	; 0x23
    535c:	7c a3       	std	Y+36, r23	; 0x24
    535e:	8d a3       	std	Y+37, r24	; 0x25
    5360:	9e a3       	std	Y+38, r25	; 0x26
    5362:	af ad       	ldd	r26, Y+63	; 0x3f
    5364:	54 e0       	ldi	r21, 0x04	; 4
    5366:	a5 9f       	mul	r26, r21
    5368:	c0 01       	movw	r24, r0
    536a:	11 24       	eor	r1, r1
    536c:	8c 01       	movw	r16, r24
    536e:	01 55       	subi	r16, 0x51	; 81
    5370:	19 4f       	sbci	r17, 0xF9	; 249
    5372:	8b 5f       	subi	r24, 0xFB	; 251
    5374:	98 4f       	sbci	r25, 0xF8	; 248
    5376:	f8 01       	movw	r30, r16
    5378:	20 81       	ld	r18, Z
    537a:	31 81       	ldd	r19, Z+1	; 0x01
    537c:	42 81       	ldd	r20, Z+2	; 0x02
    537e:	53 81       	ldd	r21, Z+3	; 0x03
    5380:	dc 01       	movw	r26, r24
    5382:	6d 91       	ld	r22, X+
    5384:	7d 91       	ld	r23, X+
    5386:	8d 91       	ld	r24, X+
    5388:	9c 91       	ld	r25, X
    538a:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    538e:	a5 01       	movw	r20, r10
    5390:	94 01       	movw	r18, r8
    5392:	0e 94 10 36 	call	0x6c20	; 0x6c20 <__divsf3>
    5396:	27 96       	adiw	r28, 0x07	; 7
    5398:	6c af       	std	Y+60, r22	; 0x3c
    539a:	7d af       	std	Y+61, r23	; 0x3d
    539c:	8e af       	std	Y+62, r24	; 0x3e
    539e:	9f af       	std	Y+63, r25	; 0x3f
    53a0:	27 97       	sbiw	r28, 0x07	; 7
    53a2:	2b a1       	ldd	r18, Y+35	; 0x23
    53a4:	3c a1       	ldd	r19, Y+36	; 0x24
    53a6:	4d a1       	ldd	r20, Y+37	; 0x25
    53a8:	5e a1       	ldd	r21, Y+38	; 0x26
    53aa:	ca 01       	movw	r24, r20
    53ac:	b9 01       	movw	r22, r18
    53ae:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    53b2:	4b 01       	movw	r8, r22
    53b4:	5c 01       	movw	r10, r24
    53b6:	ac 01       	movw	r20, r24
    53b8:	9b 01       	movw	r18, r22
    53ba:	60 e0       	ldi	r22, 0x00	; 0
    53bc:	70 e0       	ldi	r23, 0x00	; 0
    53be:	80 e0       	ldi	r24, 0x00	; 0
    53c0:	90 e4       	ldi	r25, 0x40	; 64
    53c2:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    53c6:	6b 01       	movw	r12, r22
    53c8:	7c 01       	movw	r14, r24
    53ca:	a5 01       	movw	r20, r10
    53cc:	94 01       	movw	r18, r8
    53ce:	60 e0       	ldi	r22, 0x00	; 0
    53d0:	70 e0       	ldi	r23, 0x00	; 0
    53d2:	80 ec       	ldi	r24, 0xC0	; 192
    53d4:	90 e4       	ldi	r25, 0x40	; 64
    53d6:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    53da:	4b 01       	movw	r8, r22
    53dc:	5c 01       	movw	r10, r24
    53de:	2b ea       	ldi	r18, 0xAB	; 171
    53e0:	3a ea       	ldi	r19, 0xAA	; 170
    53e2:	4a e2       	ldi	r20, 0x2A	; 42
    53e4:	5e e3       	ldi	r21, 0x3E	; 62
    53e6:	6b a1       	ldd	r22, Y+35	; 0x23
    53e8:	7c a1       	ldd	r23, Y+36	; 0x24
    53ea:	8d a1       	ldd	r24, Y+37	; 0x25
    53ec:	9e a1       	ldd	r25, Y+38	; 0x26
    53ee:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    53f2:	9b 01       	movw	r18, r22
    53f4:	ac 01       	movw	r20, r24
    53f6:	c5 01       	movw	r24, r10
    53f8:	b4 01       	movw	r22, r8
    53fa:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    53fe:	6b af       	std	Y+59, r22	; 0x3b
    5400:	7c af       	std	Y+60, r23	; 0x3c
    5402:	8d af       	std	Y+61, r24	; 0x3d
    5404:	9e af       	std	Y+62, r25	; 0x3e
    5406:	20 e0       	ldi	r18, 0x00	; 0
    5408:	30 e0       	ldi	r19, 0x00	; 0
    540a:	40 e0       	ldi	r20, 0x00	; 0
    540c:	5f e3       	ldi	r21, 0x3F	; 63
    540e:	c7 01       	movw	r24, r14
    5410:	b6 01       	movw	r22, r12
    5412:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5416:	23 96       	adiw	r28, 0x03	; 3
    5418:	6c af       	std	Y+60, r22	; 0x3c
    541a:	7d af       	std	Y+61, r23	; 0x3d
    541c:	8e af       	std	Y+62, r24	; 0x3e
    541e:	9f af       	std	Y+63, r25	; 0x3f
    5420:	23 97       	sbiw	r28, 0x03	; 3
    5422:	1f 8e       	std	Y+31, r1	; 0x1f
    5424:	22 24       	eor	r2, r2
    5426:	23 94       	inc	r2
    5428:	31 2c       	mov	r3, r1
    542a:	ef a5       	ldd	r30, Y+47	; 0x2f
    542c:	f8 a9       	ldd	r31, Y+48	; 0x30
    542e:	e2 15       	cp	r30, r2
    5430:	f3 05       	cpc	r31, r3
    5432:	09 f4       	brne	.+2      	; 0x5436 <gc_execute_line.constprop.11+0x1748>
    5434:	f1 cd       	rjmp	.-1054   	; 0x5018 <gc_execute_line.constprop.11+0x132a>
    5436:	bf 8d       	ldd	r27, Y+31	; 0x1f
    5438:	bc 30       	cpi	r27, 0x0C	; 12
    543a:	08 f0       	brcs	.+2      	; 0x543e <gc_execute_line.constprop.11+0x1750>
    543c:	98 c0       	rjmp	.+304    	; 0x556e <gc_execute_line.constprop.11+0x1880>
    543e:	a3 01       	movw	r20, r6
    5440:	92 01       	movw	r18, r4
    5442:	6b ad       	ldd	r22, Y+59	; 0x3b
    5444:	7c ad       	ldd	r23, Y+60	; 0x3c
    5446:	8d ad       	ldd	r24, Y+61	; 0x3d
    5448:	9e ad       	ldd	r25, Y+62	; 0x3e
    544a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    544e:	6b 01       	movw	r12, r22
    5450:	7c 01       	movw	r14, r24
    5452:	2b 8d       	ldd	r18, Y+27	; 0x1b
    5454:	3c 8d       	ldd	r19, Y+28	; 0x1c
    5456:	4d 8d       	ldd	r20, Y+29	; 0x1d
    5458:	5e 8d       	ldd	r21, Y+30	; 0x1e
    545a:	23 96       	adiw	r28, 0x03	; 3
    545c:	6c ad       	ldd	r22, Y+60	; 0x3c
    545e:	7d ad       	ldd	r23, Y+61	; 0x3d
    5460:	8e ad       	ldd	r24, Y+62	; 0x3e
    5462:	9f ad       	ldd	r25, Y+63	; 0x3f
    5464:	23 97       	sbiw	r28, 0x03	; 3
    5466:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    546a:	9b 01       	movw	r18, r22
    546c:	ac 01       	movw	r20, r24
    546e:	c7 01       	movw	r24, r14
    5470:	b6 01       	movw	r22, r12
    5472:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    5476:	7b 01       	movw	r14, r22
    5478:	6c 01       	movw	r12, r24
    547a:	a3 01       	movw	r20, r6
    547c:	92 01       	movw	r18, r4
    547e:	23 96       	adiw	r28, 0x03	; 3
    5480:	6c ad       	ldd	r22, Y+60	; 0x3c
    5482:	7d ad       	ldd	r23, Y+61	; 0x3d
    5484:	8e ad       	ldd	r24, Y+62	; 0x3e
    5486:	9f ad       	ldd	r25, Y+63	; 0x3f
    5488:	23 97       	sbiw	r28, 0x03	; 3
    548a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    548e:	4b 01       	movw	r8, r22
    5490:	5c 01       	movw	r10, r24
    5492:	2b 8d       	ldd	r18, Y+27	; 0x1b
    5494:	3c 8d       	ldd	r19, Y+28	; 0x1c
    5496:	4d 8d       	ldd	r20, Y+29	; 0x1d
    5498:	5e 8d       	ldd	r21, Y+30	; 0x1e
    549a:	6b ad       	ldd	r22, Y+59	; 0x3b
    549c:	7c ad       	ldd	r23, Y+60	; 0x3c
    549e:	8d ad       	ldd	r24, Y+61	; 0x3d
    54a0:	9e ad       	ldd	r25, Y+62	; 0x3e
    54a2:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    54a6:	9b 01       	movw	r18, r22
    54a8:	ac 01       	movw	r20, r24
    54aa:	c5 01       	movw	r24, r10
    54ac:	b4 01       	movw	r22, r8
    54ae:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    54b2:	2b 01       	movw	r4, r22
    54b4:	3c 01       	movw	r6, r24
    54b6:	ef 8d       	ldd	r30, Y+31	; 0x1f
    54b8:	ef 5f       	subi	r30, 0xFF	; 255
    54ba:	ef 8f       	std	Y+31, r30	; 0x1f
    54bc:	c7 01       	movw	r24, r14
    54be:	d6 01       	movw	r26, r12
    54c0:	8b 8f       	std	Y+27, r24	; 0x1b
    54c2:	9c 8f       	std	Y+28, r25	; 0x1c
    54c4:	ad 8f       	std	Y+29, r26	; 0x1d
    54c6:	be 8f       	std	Y+30, r27	; 0x1e
    54c8:	a3 01       	movw	r20, r6
    54ca:	92 01       	movw	r18, r4
    54cc:	6b a5       	ldd	r22, Y+43	; 0x2b
    54ce:	7c a5       	ldd	r23, Y+44	; 0x2c
    54d0:	8d a5       	ldd	r24, Y+45	; 0x2d
    54d2:	9e a5       	ldd	r25, Y+46	; 0x2e
    54d4:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    54d8:	ef a1       	ldd	r30, Y+39	; 0x27
    54da:	f8 a5       	ldd	r31, Y+40	; 0x28
    54dc:	60 83       	st	Z, r22
    54de:	71 83       	std	Z+1, r23	; 0x01
    54e0:	82 83       	std	Z+2, r24	; 0x02
    54e2:	93 83       	std	Z+3, r25	; 0x03
    54e4:	2b 8d       	ldd	r18, Y+27	; 0x1b
    54e6:	3c 8d       	ldd	r19, Y+28	; 0x1c
    54e8:	4d 8d       	ldd	r20, Y+29	; 0x1d
    54ea:	5e 8d       	ldd	r21, Y+30	; 0x1e
    54ec:	6b a9       	ldd	r22, Y+51	; 0x33
    54ee:	7c a9       	ldd	r23, Y+52	; 0x34
    54f0:	8d a9       	ldd	r24, Y+53	; 0x35
    54f2:	9e a9       	ldd	r25, Y+54	; 0x36
    54f4:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    54f8:	af a9       	ldd	r26, Y+55	; 0x37
    54fa:	b8 ad       	ldd	r27, Y+56	; 0x38
    54fc:	6d 93       	st	X+, r22
    54fe:	7d 93       	st	X+, r23
    5500:	8d 93       	st	X+, r24
    5502:	9c 93       	st	X, r25
    5504:	13 97       	sbiw	r26, 0x03	; 3
    5506:	27 96       	adiw	r28, 0x07	; 7
    5508:	2c ad       	ldd	r18, Y+60	; 0x3c
    550a:	3d ad       	ldd	r19, Y+61	; 0x3d
    550c:	4e ad       	ldd	r20, Y+62	; 0x3e
    550e:	5f ad       	ldd	r21, Y+63	; 0x3f
    5510:	27 97       	sbiw	r28, 0x07	; 7
    5512:	f8 01       	movw	r30, r16
    5514:	60 81       	ld	r22, Z
    5516:	71 81       	ldd	r23, Z+1	; 0x01
    5518:	82 81       	ldd	r24, Z+2	; 0x02
    551a:	93 81       	ldd	r25, Z+3	; 0x03
    551c:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    5520:	d8 01       	movw	r26, r16
    5522:	6d 93       	st	X+, r22
    5524:	7d 93       	st	X+, r23
    5526:	8d 93       	st	X+, r24
    5528:	9c 93       	st	X, r25
    552a:	13 97       	sbiw	r26, 0x03	; 3
    552c:	be 01       	movw	r22, r28
    552e:	63 5f       	subi	r22, 0xF3	; 243
    5530:	7f 4f       	sbci	r23, 0xFF	; 255
    5532:	8f ea       	ldi	r24, 0xAF	; 175
    5534:	96 e0       	ldi	r25, 0x06	; 6
    5536:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    553a:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    553e:	81 11       	cpse	r24, r1
    5540:	72 cd       	rjmp	.-1308   	; 0x5026 <gc_execute_line.constprop.11+0x1338>
    5542:	bf ef       	ldi	r27, 0xFF	; 255
    5544:	2b 1a       	sub	r2, r27
    5546:	3b 0a       	sbc	r3, r27
    5548:	70 cf       	rjmp	.-288    	; 0x542a <gc_execute_line.constprop.11+0x173c>
    554a:	2d eb       	ldi	r18, 0xBD	; 189
    554c:	37 e3       	ldi	r19, 0x37	; 55
    554e:	46 e0       	ldi	r20, 0x06	; 6
    5550:	55 e3       	ldi	r21, 0x35	; 53
    5552:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    5556:	18 16       	cp	r1, r24
    5558:	0c f4       	brge	.+2      	; 0x555c <gc_execute_line.constprop.11+0x186e>
    555a:	a9 ce       	rjmp	.-686    	; 0x52ae <gc_execute_line.constprop.11+0x15c0>
    555c:	2b ed       	ldi	r18, 0xDB	; 219
    555e:	3f e0       	ldi	r19, 0x0F	; 15
    5560:	49 ec       	ldi	r20, 0xC9	; 201
    5562:	50 e4       	ldi	r21, 0x40	; 64
    5564:	c7 01       	movw	r24, r14
    5566:	b6 01       	movw	r22, r12
    5568:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    556c:	9e ce       	rjmp	.-708    	; 0x52aa <gc_execute_line.constprop.11+0x15bc>
    556e:	b1 01       	movw	r22, r2
    5570:	90 e0       	ldi	r25, 0x00	; 0
    5572:	80 e0       	ldi	r24, 0x00	; 0
    5574:	0e 94 b8 36 	call	0x6d70	; 0x6d70 <__floatunsisf>
    5578:	2b a1       	ldd	r18, Y+35	; 0x23
    557a:	3c a1       	ldd	r19, Y+36	; 0x24
    557c:	4d a1       	ldd	r20, Y+37	; 0x25
    557e:	5e a1       	ldd	r21, Y+38	; 0x26
    5580:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5584:	6b 01       	movw	r12, r22
    5586:	7c 01       	movw	r14, r24
    5588:	0e 94 0b 36 	call	0x6c16	; 0x6c16 <cos>
    558c:	6b 8f       	std	Y+27, r22	; 0x1b
    558e:	7c 8f       	std	Y+28, r23	; 0x1c
    5590:	8d 8f       	std	Y+29, r24	; 0x1d
    5592:	9e 8f       	std	Y+30, r25	; 0x1e
    5594:	c7 01       	movw	r24, r14
    5596:	b6 01       	movw	r22, r12
    5598:	0e 94 f9 38 	call	0x71f2	; 0x71f2 <sin>
    559c:	4b 01       	movw	r8, r22
    559e:	5c 01       	movw	r10, r24
    55a0:	a9 a5       	ldd	r26, Y+41	; 0x29
    55a2:	ba a5       	ldd	r27, Y+42	; 0x2a
    55a4:	cd 90       	ld	r12, X+
    55a6:	dd 90       	ld	r13, X+
    55a8:	ed 90       	ld	r14, X+
    55aa:	fc 90       	ld	r15, X
    55ac:	f7 fa       	bst	r15, 7
    55ae:	f0 94       	com	r15
    55b0:	f7 f8       	bld	r15, 7
    55b2:	f0 94       	com	r15
    55b4:	a9 ad       	ldd	r26, Y+57	; 0x39
    55b6:	ba ad       	ldd	r27, Y+58	; 0x3a
    55b8:	2d 91       	ld	r18, X+
    55ba:	3d 91       	ld	r19, X+
    55bc:	4d 91       	ld	r20, X+
    55be:	5c 91       	ld	r21, X
    55c0:	2f 8f       	std	Y+31, r18	; 0x1f
    55c2:	38 a3       	std	Y+32, r19	; 0x20
    55c4:	49 a3       	std	Y+33, r20	; 0x21
    55c6:	5a a3       	std	Y+34, r21	; 0x22
    55c8:	a7 01       	movw	r20, r14
    55ca:	96 01       	movw	r18, r12
    55cc:	6b 8d       	ldd	r22, Y+27	; 0x1b
    55ce:	7c 8d       	ldd	r23, Y+28	; 0x1c
    55d0:	8d 8d       	ldd	r24, Y+29	; 0x1d
    55d2:	9e 8d       	ldd	r25, Y+30	; 0x1e
    55d4:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    55d8:	2b 01       	movw	r4, r22
    55da:	3c 01       	movw	r6, r24
    55dc:	2f 8d       	ldd	r18, Y+31	; 0x1f
    55de:	38 a1       	ldd	r19, Y+32	; 0x20
    55e0:	49 a1       	ldd	r20, Y+33	; 0x21
    55e2:	5a a1       	ldd	r21, Y+34	; 0x22
    55e4:	c5 01       	movw	r24, r10
    55e6:	b4 01       	movw	r22, r8
    55e8:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    55ec:	9b 01       	movw	r18, r22
    55ee:	ac 01       	movw	r20, r24
    55f0:	c3 01       	movw	r24, r6
    55f2:	b2 01       	movw	r22, r4
    55f4:	0e 94 11 35 	call	0x6a22	; 0x6a22 <__addsf3>
    55f8:	2b 01       	movw	r4, r22
    55fa:	3c 01       	movw	r6, r24
    55fc:	a7 01       	movw	r20, r14
    55fe:	96 01       	movw	r18, r12
    5600:	c5 01       	movw	r24, r10
    5602:	b4 01       	movw	r22, r8
    5604:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5608:	6b 01       	movw	r12, r22
    560a:	7c 01       	movw	r14, r24
    560c:	2f 8d       	ldd	r18, Y+31	; 0x1f
    560e:	38 a1       	ldd	r19, Y+32	; 0x20
    5610:	49 a1       	ldd	r20, Y+33	; 0x21
    5612:	5a a1       	ldd	r21, Y+34	; 0x22
    5614:	6b 8d       	ldd	r22, Y+27	; 0x1b
    5616:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5618:	8d 8d       	ldd	r24, Y+29	; 0x1d
    561a:	9e 8d       	ldd	r25, Y+30	; 0x1e
    561c:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    5620:	9b 01       	movw	r18, r22
    5622:	ac 01       	movw	r20, r24
    5624:	c7 01       	movw	r24, r14
    5626:	b6 01       	movw	r22, r12
    5628:	0e 94 10 35 	call	0x6a20	; 0x6a20 <__subsf3>
    562c:	6b 8f       	std	Y+27, r22	; 0x1b
    562e:	7c 8f       	std	Y+28, r23	; 0x1c
    5630:	8d 8f       	std	Y+29, r24	; 0x1d
    5632:	9e 8f       	std	Y+30, r25	; 0x1e
    5634:	1f 8e       	std	Y+31, r1	; 0x1f
    5636:	48 cf       	rjmp	.-368    	; 0x54c8 <gc_execute_line.constprop.11+0x17da>
    5638:	8d 89       	ldd	r24, Y+21	; 0x15
    563a:	84 60       	ori	r24, 0x04	; 4
    563c:	8d 8b       	std	Y+21, r24	; 0x15
    563e:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5642:	82 30       	cpi	r24, 0x02	; 2
    5644:	09 f4       	brne	.+2      	; 0x5648 <gc_execute_line.constprop.11+0x195a>
    5646:	ef cc       	rjmp	.-1570   	; 0x5026 <gc_execute_line.constprop.11+0x1338>
    5648:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    564c:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    5650:	81 11       	cpse	r24, r1
    5652:	19 c0       	rjmp	.+50     	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    5654:	fb a1       	ldd	r31, Y+35	; 0x23
    5656:	f0 71       	andi	r31, 0x10	; 16
    5658:	ff 2e       	mov	r15, r31
    565a:	10 92 36 06 	sts	0x0636, r1	; 0x800636 <sys+0x5>
    565e:	2b a1       	ldd	r18, Y+35	; 0x23
    5660:	23 fb       	bst	r18, 3
    5662:	88 27       	eor	r24, r24
    5664:	80 f9       	bld	r24, 0
    5666:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    566a:	86 b1       	in	r24, 0x06	; 6
    566c:	80 72       	andi	r24, 0x20	; 32
    566e:	90 91 17 06 	lds	r25, 0x0617	; 0x800617 <probe_invert_mask>
    5672:	89 17       	cp	r24, r25
    5674:	19 f1       	breq	.+70     	; 0x56bc <gc_execute_line.constprop.11+0x19ce>
    5676:	84 e0       	ldi	r24, 0x04	; 4
    5678:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    567c:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    5680:	80 e0       	ldi	r24, 0x00	; 0
    5682:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    5686:	80 91 df 06 	lds	r24, 0x06DF	; 0x8006df <gc_block+0x8>
    568a:	80 93 9e 06 	sts	0x069E, r24	; 0x80069e <gc_state+0x7>
    568e:	88 23       	and	r24, r24
    5690:	11 f4       	brne	.+4      	; 0x5696 <gc_execute_line.constprop.11+0x19a8>
    5692:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    5696:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    569a:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    569e:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    56a2:	83 30       	cpi	r24, 0x03	; 3
    56a4:	09 f0       	breq	.+2      	; 0x56a8 <gc_execute_line.constprop.11+0x19ba>
    56a6:	4d c0       	rjmp	.+154    	; 0x5742 <gc_execute_line.constprop.11+0x1a54>
    56a8:	92 30       	cpi	r25, 0x02	; 2
    56aa:	29 f0       	breq	.+10     	; 0x56b6 <gc_execute_line.constprop.11+0x19c8>
    56ac:	88 e0       	ldi	r24, 0x08	; 8
    56ae:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    56b2:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    56b6:	10 92 9e 06 	sts	0x069E, r1	; 0x80069e <gc_state+0x7>
    56ba:	06 c9       	rjmp	.-3572   	; 0x48c8 <gc_execute_line.constprop.11+0xbda>
    56bc:	b8 01       	movw	r22, r16
    56be:	85 e0       	ldi	r24, 0x05	; 5
    56c0:	97 e0       	ldi	r25, 0x07	; 7
    56c2:	0e 94 17 1e 	call	0x3c2e	; 0x3c2e <mc_line>
    56c6:	81 e0       	ldi	r24, 0x01	; 1
    56c8:	80 93 30 06 	sts	0x0630, r24	; 0x800630 <sys_probe_state>
    56cc:	82 e0       	ldi	r24, 0x02	; 2
    56ce:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    56d2:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    56d6:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    56da:	81 11       	cpse	r24, r1
    56dc:	d4 cf       	rjmp	.-88     	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    56de:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    56e2:	81 11       	cpse	r24, r1
    56e4:	f6 cf       	rjmp	.-20     	; 0x56d2 <gc_execute_line.constprop.11+0x19e4>
    56e6:	80 91 30 06 	lds	r24, 0x0630	; 0x800630 <sys_probe_state>
    56ea:	81 30       	cpi	r24, 0x01	; 1
    56ec:	31 f5       	brne	.+76     	; 0x573a <gc_execute_line.constprop.11+0x1a4c>
    56ee:	ff 20       	and	r15, r15
    56f0:	01 f1       	breq	.+64     	; 0x5732 <gc_execute_line.constprop.11+0x1a44>
    56f2:	8c e0       	ldi	r24, 0x0C	; 12
    56f4:	e8 e1       	ldi	r30, 0x18	; 24
    56f6:	f6 e0       	ldi	r31, 0x06	; 6
    56f8:	a4 e2       	ldi	r26, 0x24	; 36
    56fa:	b6 e0       	ldi	r27, 0x06	; 6
    56fc:	01 90       	ld	r0, Z+
    56fe:	0d 92       	st	X+, r0
    5700:	8a 95       	dec	r24
    5702:	e1 f7       	brne	.-8      	; 0x56fc <gc_execute_line.constprop.11+0x1a0e>
    5704:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    5708:	80 e0       	ldi	r24, 0x00	; 0
    570a:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    570e:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    5712:	0e 94 cf 0d 	call	0x1b9e	; 0x1b9e <st_reset>
    5716:	0e 94 a2 09 	call	0x1344	; 0x1344 <plan_reset>
    571a:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    571e:	0e 94 25 09 	call	0x124a	; 0x124a <report_probe_parameters>
    5722:	80 91 36 06 	lds	r24, 0x0636	; 0x800636 <sys+0x5>
    5726:	88 23       	and	r24, r24
    5728:	09 f4       	brne	.+2      	; 0x572c <gc_execute_line.constprop.11+0x1a3e>
    572a:	7d cc       	rjmp	.-1798   	; 0x5026 <gc_execute_line.constprop.11+0x1338>
    572c:	0e 94 9c 09 	call	0x1338	; 0x1338 <gc_sync_position>
    5730:	aa cf       	rjmp	.-172    	; 0x5686 <gc_execute_line.constprop.11+0x1998>
    5732:	85 e0       	ldi	r24, 0x05	; 5
    5734:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    5738:	e5 cf       	rjmp	.-54     	; 0x5704 <gc_execute_line.constprop.11+0x1a16>
    573a:	81 e0       	ldi	r24, 0x01	; 1
    573c:	80 93 36 06 	sts	0x0636, r24	; 0x800636 <sys+0x5>
    5740:	e1 cf       	rjmp	.-62     	; 0x5704 <gc_execute_line.constprop.11+0x1a16>
    5742:	81 e0       	ldi	r24, 0x01	; 1
    5744:	80 93 97 06 	sts	0x0697, r24	; 0x800697 <gc_state>
    5748:	10 92 9b 06 	sts	0x069B, r1	; 0x80069b <gc_state+0x4>
    574c:	10 92 9a 06 	sts	0x069A, r1	; 0x80069a <gc_state+0x3>
    5750:	10 92 98 06 	sts	0x0698, r1	; 0x800698 <gc_state+0x1>
    5754:	10 92 9d 06 	sts	0x069D, r1	; 0x80069d <gc_state+0x6>
    5758:	10 92 a0 06 	sts	0x06A0, r1	; 0x8006a0 <gc_state+0x9>
    575c:	10 92 9f 06 	sts	0x069F, r1	; 0x80069f <gc_state+0x8>
    5760:	84 e6       	ldi	r24, 0x64	; 100
    5762:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    5766:	80 93 39 06 	sts	0x0639, r24	; 0x800639 <sys+0x8>
    576a:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    576e:	92 30       	cpi	r25, 0x02	; 2
    5770:	a1 f0       	breq	.+40     	; 0x579a <gc_execute_line.constprop.11+0x1aac>
    5772:	6b eb       	ldi	r22, 0xBB	; 187
    5774:	76 e0       	ldi	r23, 0x06	; 6
    5776:	80 e0       	ldi	r24, 0x00	; 0
    5778:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    577c:	88 23       	and	r24, r24
    577e:	11 f4       	brne	.+4      	; 0x5784 <gc_execute_line.constprop.11+0x1a96>
    5780:	0c 94 5d 22 	jmp	0x44ba	; 0x44ba <gc_execute_line.constprop.11+0x7cc>
    5784:	0e 94 62 1d 	call	0x3ac4	; 0x3ac4 <system_flag_wco_change>
    5788:	40 e0       	ldi	r20, 0x00	; 0
    578a:	50 e0       	ldi	r21, 0x00	; 0
    578c:	ba 01       	movw	r22, r20
    578e:	80 e0       	ldi	r24, 0x00	; 0
    5790:	0e 94 be 0a 	call	0x157c	; 0x157c <spindle_set_state>
    5794:	80 e0       	ldi	r24, 0x00	; 0
    5796:	0e 94 4f 09 	call	0x129e	; 0x129e <coolant_set_state>
    579a:	8a ec       	ldi	r24, 0xCA	; 202
    579c:	92 e0       	ldi	r25, 0x02	; 2
    579e:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    57a2:	81 e6       	ldi	r24, 0x61	; 97
    57a4:	92 e0       	ldi	r25, 0x02	; 2
    57a6:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    57aa:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    57ae:	83 cf       	rjmp	.-250    	; 0x56b6 <gc_execute_line.constprop.11+0x19c8>
    57b0:	81 e0       	ldi	r24, 0x01	; 1
    57b2:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57b6:	82 e0       	ldi	r24, 0x02	; 2
    57b8:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57bc:	88 e1       	ldi	r24, 0x18	; 24
    57be:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57c2:	86 e2       	ldi	r24, 0x26	; 38
    57c4:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57c8:	89 e1       	ldi	r24, 0x19	; 25
    57ca:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57ce:	84 e0       	ldi	r24, 0x04	; 4
    57d0:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57d4:	8b e1       	ldi	r24, 0x1B	; 27
    57d6:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57da:	80 e2       	ldi	r24, 0x20	; 32
    57dc:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57e0:	82 e2       	ldi	r24, 0x22	; 34
    57e2:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57e6:	84 e2       	ldi	r24, 0x24	; 36
    57e8:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57ec:	80 e1       	ldi	r24, 0x10	; 16
    57ee:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>
    57f2:	8f e0       	ldi	r24, 0x0F	; 15
    57f4:	0c 94 c6 1f 	jmp	0x3f8c	; 0x3f8c <gc_execute_line.constprop.11+0x29e>

000057f8 <system_execute_startup.constprop.2>:
    57f8:	cf 93       	push	r28
    57fa:	df 93       	push	r29
    57fc:	c0 e0       	ldi	r28, 0x00	; 0
    57fe:	8c 2f       	mov	r24, r28
    5800:	0e 94 41 1d 	call	0x3a82	; 0x3a82 <settings_read_startup_line.constprop.7>
    5804:	81 11       	cpse	r24, r1
    5806:	14 c0       	rjmp	.+40     	; 0x5830 <system_execute_startup.constprop.2+0x38>
    5808:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    580c:	8e e3       	ldi	r24, 0x3E	; 62
    580e:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    5812:	0e 94 a9 06 	call	0xd52	; 0xd52 <printString.constprop.9>
    5816:	8a e3       	ldi	r24, 0x3A	; 58
    5818:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    581c:	87 e0       	ldi	r24, 0x07	; 7
    581e:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    5822:	c1 30       	cpi	r28, 0x01	; 1
    5824:	19 f4       	brne	.+6      	; 0x582c <system_execute_startup.constprop.2+0x34>
    5826:	df 91       	pop	r29
    5828:	cf 91       	pop	r28
    582a:	08 95       	ret
    582c:	c1 e0       	ldi	r28, 0x01	; 1
    582e:	e7 cf       	rjmp	.-50     	; 0x57fe <system_execute_startup.constprop.2+0x6>
    5830:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    5834:	88 23       	and	r24, r24
    5836:	a9 f3       	breq	.-22     	; 0x5822 <system_execute_startup.constprop.2+0x2a>
    5838:	0e 94 77 1e 	call	0x3cee	; 0x3cee <gc_execute_line.constprop.11>
    583c:	d8 2f       	mov	r29, r24
    583e:	8e e3       	ldi	r24, 0x3E	; 62
    5840:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    5844:	0e 94 a9 06 	call	0xd52	; 0xd52 <printString.constprop.9>
    5848:	8a e3       	ldi	r24, 0x3A	; 58
    584a:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    584e:	8d 2f       	mov	r24, r29
    5850:	0e 94 d8 07 	call	0xfb0	; 0xfb0 <report_status_message>
    5854:	e6 cf       	rjmp	.-52     	; 0x5822 <system_execute_startup.constprop.2+0x2a>

00005856 <__vector_4>:
    5856:	1f 92       	push	r1
    5858:	0f 92       	push	r0
    585a:	0f b6       	in	r0, 0x3f	; 63
    585c:	0f 92       	push	r0
    585e:	11 24       	eor	r1, r1
    5860:	2f 93       	push	r18
    5862:	3f 93       	push	r19
    5864:	4f 93       	push	r20
    5866:	5f 93       	push	r21
    5868:	6f 93       	push	r22
    586a:	7f 93       	push	r23
    586c:	8f 93       	push	r24
    586e:	9f 93       	push	r25
    5870:	af 93       	push	r26
    5872:	bf 93       	push	r27
    5874:	cf 93       	push	r28
    5876:	ef 93       	push	r30
    5878:	ff 93       	push	r31
    587a:	0e 94 cb 02 	call	0x596	; 0x596 <system_control_get_state>
    587e:	c8 2f       	mov	r28, r24
    5880:	88 23       	and	r24, r24
    5882:	89 f0       	breq	.+34     	; 0x58a6 <__vector_4+0x50>
    5884:	80 fd       	sbrc	r24, 0
    5886:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    588a:	c2 ff       	sbrs	r28, 2
    588c:	05 c0       	rjmp	.+10     	; 0x5898 <__vector_4+0x42>
    588e:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    5892:	82 60       	ori	r24, 0x02	; 2
    5894:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    5898:	c1 ff       	sbrs	r28, 1
    589a:	05 c0       	rjmp	.+10     	; 0x58a6 <__vector_4+0x50>
    589c:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    58a0:	88 60       	ori	r24, 0x08	; 8
    58a2:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    58a6:	ff 91       	pop	r31
    58a8:	ef 91       	pop	r30
    58aa:	cf 91       	pop	r28
    58ac:	bf 91       	pop	r27
    58ae:	af 91       	pop	r26
    58b0:	9f 91       	pop	r25
    58b2:	8f 91       	pop	r24
    58b4:	7f 91       	pop	r23
    58b6:	6f 91       	pop	r22
    58b8:	5f 91       	pop	r21
    58ba:	4f 91       	pop	r20
    58bc:	3f 91       	pop	r19
    58be:	2f 91       	pop	r18
    58c0:	0f 90       	pop	r0
    58c2:	0f be       	out	0x3f, r0	; 63
    58c4:	0f 90       	pop	r0
    58c6:	1f 90       	pop	r1
    58c8:	18 95       	reti

000058ca <__vector_3>:
    58ca:	1f 92       	push	r1
    58cc:	0f 92       	push	r0
    58ce:	0f b6       	in	r0, 0x3f	; 63
    58d0:	0f 92       	push	r0
    58d2:	11 24       	eor	r1, r1
    58d4:	2f 93       	push	r18
    58d6:	3f 93       	push	r19
    58d8:	4f 93       	push	r20
    58da:	5f 93       	push	r21
    58dc:	6f 93       	push	r22
    58de:	7f 93       	push	r23
    58e0:	8f 93       	push	r24
    58e2:	9f 93       	push	r25
    58e4:	af 93       	push	r26
    58e6:	bf 93       	push	r27
    58e8:	ef 93       	push	r30
    58ea:	ff 93       	push	r31
    58ec:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    58f0:	81 30       	cpi	r24, 0x01	; 1
    58f2:	49 f0       	breq	.+18     	; 0x5906 <__vector_3+0x3c>
    58f4:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    58f8:	81 11       	cpse	r24, r1
    58fa:	05 c0       	rjmp	.+10     	; 0x5906 <__vector_3+0x3c>
    58fc:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    5900:	81 e0       	ldi	r24, 0x01	; 1
    5902:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    5906:	ff 91       	pop	r31
    5908:	ef 91       	pop	r30
    590a:	bf 91       	pop	r27
    590c:	af 91       	pop	r26
    590e:	9f 91       	pop	r25
    5910:	8f 91       	pop	r24
    5912:	7f 91       	pop	r23
    5914:	6f 91       	pop	r22
    5916:	5f 91       	pop	r21
    5918:	4f 91       	pop	r20
    591a:	3f 91       	pop	r19
    591c:	2f 91       	pop	r18
    591e:	0f 90       	pop	r0
    5920:	0f be       	out	0x3f, r0	; 63
    5922:	0f 90       	pop	r0
    5924:	1f 90       	pop	r1
    5926:	18 95       	reti

00005928 <__vector_16>:
    5928:	1f 92       	push	r1
    592a:	0f 92       	push	r0
    592c:	0f b6       	in	r0, 0x3f	; 63
    592e:	0f 92       	push	r0
    5930:	11 24       	eor	r1, r1
    5932:	8f 93       	push	r24
    5934:	9f 93       	push	r25
    5936:	9b b1       	in	r25, 0x0b	; 11
    5938:	80 91 f2 01 	lds	r24, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    593c:	8c 71       	andi	r24, 0x1C	; 28
    593e:	93 7e       	andi	r25, 0xE3	; 227
    5940:	89 2b       	or	r24, r25
    5942:	8b b9       	out	0x0b, r24	; 11
    5944:	15 bc       	out	0x25, r1	; 37
    5946:	9f 91       	pop	r25
    5948:	8f 91       	pop	r24
    594a:	0f 90       	pop	r0
    594c:	0f be       	out	0x3f, r0	; 63
    594e:	0f 90       	pop	r0
    5950:	1f 90       	pop	r1
    5952:	18 95       	reti

00005954 <__vector_11>:
    5954:	1f 92       	push	r1
    5956:	0f 92       	push	r0
    5958:	0f b6       	in	r0, 0x3f	; 63
    595a:	0f 92       	push	r0
    595c:	11 24       	eor	r1, r1
    595e:	0f 93       	push	r16
    5960:	1f 93       	push	r17
    5962:	2f 93       	push	r18
    5964:	3f 93       	push	r19
    5966:	4f 93       	push	r20
    5968:	5f 93       	push	r21
    596a:	6f 93       	push	r22
    596c:	7f 93       	push	r23
    596e:	8f 93       	push	r24
    5970:	9f 93       	push	r25
    5972:	af 93       	push	r26
    5974:	bf 93       	push	r27
    5976:	ef 93       	push	r30
    5978:	ff 93       	push	r31
    597a:	80 91 f4 01 	lds	r24, 0x01F4	; 0x8001f4 <busy>
    597e:	81 11       	cpse	r24, r1
    5980:	01 c2       	rjmp	.+1026   	; 0x5d84 <__vector_11+0x430>
    5982:	9b b1       	in	r25, 0x0b	; 11
    5984:	80 91 04 02 	lds	r24, 0x0204	; 0x800204 <st+0xf>
    5988:	80 7e       	andi	r24, 0xE0	; 224
    598a:	9f 71       	andi	r25, 0x1F	; 31
    598c:	89 2b       	or	r24, r25
    598e:	8b b9       	out	0x0b, r24	; 11
    5990:	8b b1       	in	r24, 0x0b	; 11
    5992:	83 7e       	andi	r24, 0xE3	; 227
    5994:	90 91 03 02 	lds	r25, 0x0203	; 0x800203 <st+0xe>
    5998:	89 2b       	or	r24, r25
    599a:	8b b9       	out	0x0b, r24	; 11
    599c:	80 91 02 02 	lds	r24, 0x0202	; 0x800202 <st+0xd>
    59a0:	86 bd       	out	0x26, r24	; 38
    59a2:	82 e0       	ldi	r24, 0x02	; 2
    59a4:	85 bd       	out	0x25, r24	; 37
    59a6:	81 e0       	ldi	r24, 0x01	; 1
    59a8:	80 93 f4 01 	sts	0x01F4, r24	; 0x8001f4 <busy>
    59ac:	78 94       	sei
    59ae:	80 91 16 02 	lds	r24, 0x0216	; 0x800216 <st+0x21>
    59b2:	90 91 17 02 	lds	r25, 0x0217	; 0x800217 <st+0x22>
    59b6:	89 2b       	or	r24, r25
    59b8:	09 f0       	breq	.+2      	; 0x59bc <__vector_11+0x68>
    59ba:	aa c0       	rjmp	.+340    	; 0x5b10 <__vector_11+0x1bc>
    59bc:	80 91 18 02 	lds	r24, 0x0218	; 0x800218 <segment_buffer_tail>
    59c0:	90 91 44 02 	lds	r25, 0x0244	; 0x800244 <segment_buffer_head>
    59c4:	98 17       	cp	r25, r24
    59c6:	09 f4       	brne	.+2      	; 0x59ca <__vector_11+0x76>
    59c8:	ca c1       	rjmp	.+916    	; 0x5d5e <__vector_11+0x40a>
    59ca:	e0 91 18 02 	lds	r30, 0x0218	; 0x800218 <segment_buffer_tail>
    59ce:	2e 2f       	mov	r18, r30
    59d0:	30 e0       	ldi	r19, 0x00	; 0
    59d2:	87 e0       	ldi	r24, 0x07	; 7
    59d4:	e8 9f       	mul	r30, r24
    59d6:	f0 01       	movw	r30, r0
    59d8:	11 24       	eor	r1, r1
    59da:	e6 5e       	subi	r30, 0xE6	; 230
    59dc:	fd 4f       	sbci	r31, 0xFD	; 253
    59de:	f0 93 17 02 	sts	0x0217, r31	; 0x800217 <st+0x22>
    59e2:	e0 93 16 02 	sts	0x0216, r30	; 0x800216 <st+0x21>
    59e6:	82 81       	ldd	r24, Z+2	; 0x02
    59e8:	93 81       	ldd	r25, Z+3	; 0x03
    59ea:	90 93 89 00 	sts	0x0089, r25	; 0x800089 <__DATA_REGION_ORIGIN__+0x29>
    59ee:	80 93 88 00 	sts	0x0088, r24	; 0x800088 <__DATA_REGION_ORIGIN__+0x28>
    59f2:	80 81       	ld	r24, Z
    59f4:	91 81       	ldd	r25, Z+1	; 0x01
    59f6:	90 93 12 02 	sts	0x0212, r25	; 0x800212 <st+0x1d>
    59fa:	80 93 11 02 	sts	0x0211, r24	; 0x800211 <st+0x1c>
    59fe:	e4 81       	ldd	r30, Z+4	; 0x04
    5a00:	80 91 13 02 	lds	r24, 0x0213	; 0x800213 <st+0x1e>
    5a04:	8e 17       	cp	r24, r30
    5a06:	61 f1       	breq	.+88     	; 0x5a60 <__vector_11+0x10c>
    5a08:	e0 93 13 02 	sts	0x0213, r30	; 0x800213 <st+0x1e>
    5a0c:	82 e1       	ldi	r24, 0x12	; 18
    5a0e:	e8 9f       	mul	r30, r24
    5a10:	f0 01       	movw	r30, r0
    5a12:	11 24       	eor	r1, r1
    5a14:	e9 5b       	subi	r30, 0xB9	; 185
    5a16:	fd 4f       	sbci	r31, 0xFD	; 253
    5a18:	f0 93 15 02 	sts	0x0215, r31	; 0x800215 <st+0x20>
    5a1c:	e0 93 14 02 	sts	0x0214, r30	; 0x800214 <st+0x1f>
    5a20:	84 85       	ldd	r24, Z+12	; 0x0c
    5a22:	95 85       	ldd	r25, Z+13	; 0x0d
    5a24:	a6 85       	ldd	r26, Z+14	; 0x0e
    5a26:	b7 85       	ldd	r27, Z+15	; 0x0f
    5a28:	b6 95       	lsr	r27
    5a2a:	a7 95       	ror	r26
    5a2c:	97 95       	ror	r25
    5a2e:	87 95       	ror	r24
    5a30:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5a34:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5a38:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5a3c:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5a40:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5a44:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5a48:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5a4c:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5a50:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5a54:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5a58:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5a5c:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5a60:	a0 91 14 02 	lds	r26, 0x0214	; 0x800214 <st+0x1f>
    5a64:	b0 91 15 02 	lds	r27, 0x0215	; 0x800215 <st+0x20>
    5a68:	50 96       	adiw	r26, 0x10	; 16
    5a6a:	8c 91       	ld	r24, X
    5a6c:	50 97       	sbiw	r26, 0x10	; 16
    5a6e:	90 91 f3 01 	lds	r25, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    5a72:	89 27       	eor	r24, r25
    5a74:	80 93 04 02 	sts	0x0204, r24	; 0x800204 <st+0xf>
    5a78:	87 e0       	ldi	r24, 0x07	; 7
    5a7a:	82 9f       	mul	r24, r18
    5a7c:	f0 01       	movw	r30, r0
    5a7e:	83 9f       	mul	r24, r19
    5a80:	f0 0d       	add	r31, r0
    5a82:	11 24       	eor	r1, r1
    5a84:	e6 5e       	subi	r30, 0xE6	; 230
    5a86:	fd 4f       	sbci	r31, 0xFD	; 253
    5a88:	25 81       	ldd	r18, Z+5	; 0x05
    5a8a:	4d 91       	ld	r20, X+
    5a8c:	5d 91       	ld	r21, X+
    5a8e:	6d 91       	ld	r22, X+
    5a90:	7c 91       	ld	r23, X
    5a92:	13 97       	sbiw	r26, 0x03	; 3
    5a94:	02 2e       	mov	r0, r18
    5a96:	04 c0       	rjmp	.+8      	; 0x5aa0 <__vector_11+0x14c>
    5a98:	76 95       	lsr	r23
    5a9a:	67 95       	ror	r22
    5a9c:	57 95       	ror	r21
    5a9e:	47 95       	ror	r20
    5aa0:	0a 94       	dec	r0
    5aa2:	d2 f7       	brpl	.-12     	; 0x5a98 <__vector_11+0x144>
    5aa4:	40 93 05 02 	sts	0x0205, r20	; 0x800205 <st+0x10>
    5aa8:	50 93 06 02 	sts	0x0206, r21	; 0x800206 <st+0x11>
    5aac:	60 93 07 02 	sts	0x0207, r22	; 0x800207 <st+0x12>
    5ab0:	70 93 08 02 	sts	0x0208, r23	; 0x800208 <st+0x13>
    5ab4:	14 96       	adiw	r26, 0x04	; 4
    5ab6:	4d 91       	ld	r20, X+
    5ab8:	5d 91       	ld	r21, X+
    5aba:	6d 91       	ld	r22, X+
    5abc:	7c 91       	ld	r23, X
    5abe:	17 97       	sbiw	r26, 0x07	; 7
    5ac0:	02 2e       	mov	r0, r18
    5ac2:	04 c0       	rjmp	.+8      	; 0x5acc <__vector_11+0x178>
    5ac4:	76 95       	lsr	r23
    5ac6:	67 95       	ror	r22
    5ac8:	57 95       	ror	r21
    5aca:	47 95       	ror	r20
    5acc:	0a 94       	dec	r0
    5ace:	d2 f7       	brpl	.-12     	; 0x5ac4 <__vector_11+0x170>
    5ad0:	40 93 09 02 	sts	0x0209, r20	; 0x800209 <st+0x14>
    5ad4:	50 93 0a 02 	sts	0x020A, r21	; 0x80020a <st+0x15>
    5ad8:	60 93 0b 02 	sts	0x020B, r22	; 0x80020b <st+0x16>
    5adc:	70 93 0c 02 	sts	0x020C, r23	; 0x80020c <st+0x17>
    5ae0:	18 96       	adiw	r26, 0x08	; 8
    5ae2:	8d 91       	ld	r24, X+
    5ae4:	9d 91       	ld	r25, X+
    5ae6:	0d 90       	ld	r0, X+
    5ae8:	bc 91       	ld	r27, X
    5aea:	a0 2d       	mov	r26, r0
    5aec:	04 c0       	rjmp	.+8      	; 0x5af6 <__vector_11+0x1a2>
    5aee:	b6 95       	lsr	r27
    5af0:	a7 95       	ror	r26
    5af2:	97 95       	ror	r25
    5af4:	87 95       	ror	r24
    5af6:	2a 95       	dec	r18
    5af8:	d2 f7       	brpl	.-12     	; 0x5aee <__vector_11+0x19a>
    5afa:	80 93 0d 02 	sts	0x020D, r24	; 0x80020d <st+0x18>
    5afe:	90 93 0e 02 	sts	0x020E, r25	; 0x80020e <st+0x19>
    5b02:	a0 93 0f 02 	sts	0x020F, r26	; 0x80020f <st+0x1a>
    5b06:	b0 93 10 02 	sts	0x0210, r27	; 0x800210 <st+0x1b>
    5b0a:	86 81       	ldd	r24, Z+6	; 0x06
    5b0c:	0e 94 5b 09 	call	0x12b6	; 0x12b6 <spindle_set_speed>
    5b10:	80 91 30 06 	lds	r24, 0x0630	; 0x800630 <sys_probe_state>
    5b14:	81 30       	cpi	r24, 0x01	; 1
    5b16:	b1 f4       	brne	.+44     	; 0x5b44 <__vector_11+0x1f0>
    5b18:	86 b1       	in	r24, 0x06	; 6
    5b1a:	80 72       	andi	r24, 0x20	; 32
    5b1c:	90 91 17 06 	lds	r25, 0x0617	; 0x800617 <probe_invert_mask>
    5b20:	89 17       	cp	r24, r25
    5b22:	81 f0       	breq	.+32     	; 0x5b44 <__vector_11+0x1f0>
    5b24:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    5b28:	8c e0       	ldi	r24, 0x0C	; 12
    5b2a:	e8 e1       	ldi	r30, 0x18	; 24
    5b2c:	f6 e0       	ldi	r31, 0x06	; 6
    5b2e:	a4 e2       	ldi	r26, 0x24	; 36
    5b30:	b6 e0       	ldi	r27, 0x06	; 6
    5b32:	01 90       	ld	r0, Z+
    5b34:	0d 92       	st	X+, r0
    5b36:	8a 95       	dec	r24
    5b38:	e1 f7       	brne	.-8      	; 0x5b32 <__vector_11+0x1de>
    5b3a:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    5b3e:	80 64       	ori	r24, 0x40	; 64
    5b40:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    5b44:	10 92 03 02 	sts	0x0203, r1	; 0x800203 <st+0xe>
    5b48:	80 91 f5 01 	lds	r24, 0x01F5	; 0x8001f5 <st>
    5b4c:	90 91 f6 01 	lds	r25, 0x01F6	; 0x8001f6 <st+0x1>
    5b50:	a0 91 f7 01 	lds	r26, 0x01F7	; 0x8001f7 <st+0x2>
    5b54:	b0 91 f8 01 	lds	r27, 0x01F8	; 0x8001f8 <st+0x3>
    5b58:	40 91 05 02 	lds	r20, 0x0205	; 0x800205 <st+0x10>
    5b5c:	50 91 06 02 	lds	r21, 0x0206	; 0x800206 <st+0x11>
    5b60:	60 91 07 02 	lds	r22, 0x0207	; 0x800207 <st+0x12>
    5b64:	70 91 08 02 	lds	r23, 0x0208	; 0x800208 <st+0x13>
    5b68:	84 0f       	add	r24, r20
    5b6a:	95 1f       	adc	r25, r21
    5b6c:	a6 1f       	adc	r26, r22
    5b6e:	b7 1f       	adc	r27, r23
    5b70:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5b74:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5b78:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5b7c:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5b80:	e0 91 14 02 	lds	r30, 0x0214	; 0x800214 <st+0x1f>
    5b84:	f0 91 15 02 	lds	r31, 0x0215	; 0x800215 <st+0x20>
    5b88:	44 85       	ldd	r20, Z+12	; 0x0c
    5b8a:	55 85       	ldd	r21, Z+13	; 0x0d
    5b8c:	66 85       	ldd	r22, Z+14	; 0x0e
    5b8e:	77 85       	ldd	r23, Z+15	; 0x0f
    5b90:	48 17       	cp	r20, r24
    5b92:	59 07       	cpc	r21, r25
    5b94:	6a 07       	cpc	r22, r26
    5b96:	7b 07       	cpc	r23, r27
    5b98:	28 f5       	brcc	.+74     	; 0x5be4 <__vector_11+0x290>
    5b9a:	24 e0       	ldi	r18, 0x04	; 4
    5b9c:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5ba0:	84 1b       	sub	r24, r20
    5ba2:	95 0b       	sbc	r25, r21
    5ba4:	a6 0b       	sbc	r26, r22
    5ba6:	b7 0b       	sbc	r27, r23
    5ba8:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5bac:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5bb0:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5bb4:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5bb8:	80 91 18 06 	lds	r24, 0x0618	; 0x800618 <sys_position>
    5bbc:	90 91 19 06 	lds	r25, 0x0619	; 0x800619 <sys_position+0x1>
    5bc0:	a0 91 1a 06 	lds	r26, 0x061A	; 0x80061a <sys_position+0x2>
    5bc4:	b0 91 1b 06 	lds	r27, 0x061B	; 0x80061b <sys_position+0x3>
    5bc8:	20 89       	ldd	r18, Z+16	; 0x10
    5bca:	25 ff       	sbrs	r18, 5
    5bcc:	ee c0       	rjmp	.+476    	; 0x5daa <__vector_11+0x456>
    5bce:	01 97       	sbiw	r24, 0x01	; 1
    5bd0:	a1 09       	sbc	r26, r1
    5bd2:	b1 09       	sbc	r27, r1
    5bd4:	80 93 18 06 	sts	0x0618, r24	; 0x800618 <sys_position>
    5bd8:	90 93 19 06 	sts	0x0619, r25	; 0x800619 <sys_position+0x1>
    5bdc:	a0 93 1a 06 	sts	0x061A, r26	; 0x80061a <sys_position+0x2>
    5be0:	b0 93 1b 06 	sts	0x061B, r27	; 0x80061b <sys_position+0x3>
    5be4:	80 91 f9 01 	lds	r24, 0x01F9	; 0x8001f9 <st+0x4>
    5be8:	90 91 fa 01 	lds	r25, 0x01FA	; 0x8001fa <st+0x5>
    5bec:	a0 91 fb 01 	lds	r26, 0x01FB	; 0x8001fb <st+0x6>
    5bf0:	b0 91 fc 01 	lds	r27, 0x01FC	; 0x8001fc <st+0x7>
    5bf4:	00 91 09 02 	lds	r16, 0x0209	; 0x800209 <st+0x14>
    5bf8:	10 91 0a 02 	lds	r17, 0x020A	; 0x80020a <st+0x15>
    5bfc:	20 91 0b 02 	lds	r18, 0x020B	; 0x80020b <st+0x16>
    5c00:	30 91 0c 02 	lds	r19, 0x020C	; 0x80020c <st+0x17>
    5c04:	80 0f       	add	r24, r16
    5c06:	91 1f       	adc	r25, r17
    5c08:	a2 1f       	adc	r26, r18
    5c0a:	b3 1f       	adc	r27, r19
    5c0c:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5c10:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5c14:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5c18:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5c1c:	48 17       	cp	r20, r24
    5c1e:	59 07       	cpc	r21, r25
    5c20:	6a 07       	cpc	r22, r26
    5c22:	7b 07       	cpc	r23, r27
    5c24:	38 f5       	brcc	.+78     	; 0x5c74 <__vector_11+0x320>
    5c26:	20 91 03 02 	lds	r18, 0x0203	; 0x800203 <st+0xe>
    5c2a:	28 60       	ori	r18, 0x08	; 8
    5c2c:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5c30:	84 1b       	sub	r24, r20
    5c32:	95 0b       	sbc	r25, r21
    5c34:	a6 0b       	sbc	r26, r22
    5c36:	b7 0b       	sbc	r27, r23
    5c38:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5c3c:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5c40:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5c44:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5c48:	80 91 1c 06 	lds	r24, 0x061C	; 0x80061c <sys_position+0x4>
    5c4c:	90 91 1d 06 	lds	r25, 0x061D	; 0x80061d <sys_position+0x5>
    5c50:	a0 91 1e 06 	lds	r26, 0x061E	; 0x80061e <sys_position+0x6>
    5c54:	b0 91 1f 06 	lds	r27, 0x061F	; 0x80061f <sys_position+0x7>
    5c58:	20 89       	ldd	r18, Z+16	; 0x10
    5c5a:	26 ff       	sbrs	r18, 6
    5c5c:	aa c0       	rjmp	.+340    	; 0x5db2 <__vector_11+0x45e>
    5c5e:	01 97       	sbiw	r24, 0x01	; 1
    5c60:	a1 09       	sbc	r26, r1
    5c62:	b1 09       	sbc	r27, r1
    5c64:	80 93 1c 06 	sts	0x061C, r24	; 0x80061c <sys_position+0x4>
    5c68:	90 93 1d 06 	sts	0x061D, r25	; 0x80061d <sys_position+0x5>
    5c6c:	a0 93 1e 06 	sts	0x061E, r26	; 0x80061e <sys_position+0x6>
    5c70:	b0 93 1f 06 	sts	0x061F, r27	; 0x80061f <sys_position+0x7>
    5c74:	80 91 fd 01 	lds	r24, 0x01FD	; 0x8001fd <st+0x8>
    5c78:	90 91 fe 01 	lds	r25, 0x01FE	; 0x8001fe <st+0x9>
    5c7c:	a0 91 ff 01 	lds	r26, 0x01FF	; 0x8001ff <st+0xa>
    5c80:	b0 91 00 02 	lds	r27, 0x0200	; 0x800200 <st+0xb>
    5c84:	00 91 0d 02 	lds	r16, 0x020D	; 0x80020d <st+0x18>
    5c88:	10 91 0e 02 	lds	r17, 0x020E	; 0x80020e <st+0x19>
    5c8c:	20 91 0f 02 	lds	r18, 0x020F	; 0x80020f <st+0x1a>
    5c90:	30 91 10 02 	lds	r19, 0x0210	; 0x800210 <st+0x1b>
    5c94:	80 0f       	add	r24, r16
    5c96:	91 1f       	adc	r25, r17
    5c98:	a2 1f       	adc	r26, r18
    5c9a:	b3 1f       	adc	r27, r19
    5c9c:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5ca0:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5ca4:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5ca8:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5cac:	48 17       	cp	r20, r24
    5cae:	59 07       	cpc	r21, r25
    5cb0:	6a 07       	cpc	r22, r26
    5cb2:	7b 07       	cpc	r23, r27
    5cb4:	38 f5       	brcc	.+78     	; 0x5d04 <__vector_11+0x3b0>
    5cb6:	20 91 03 02 	lds	r18, 0x0203	; 0x800203 <st+0xe>
    5cba:	20 61       	ori	r18, 0x10	; 16
    5cbc:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5cc0:	84 1b       	sub	r24, r20
    5cc2:	95 0b       	sbc	r25, r21
    5cc4:	a6 0b       	sbc	r26, r22
    5cc6:	b7 0b       	sbc	r27, r23
    5cc8:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5ccc:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5cd0:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5cd4:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5cd8:	80 91 20 06 	lds	r24, 0x0620	; 0x800620 <sys_position+0x8>
    5cdc:	90 91 21 06 	lds	r25, 0x0621	; 0x800621 <sys_position+0x9>
    5ce0:	a0 91 22 06 	lds	r26, 0x0622	; 0x800622 <sys_position+0xa>
    5ce4:	b0 91 23 06 	lds	r27, 0x0623	; 0x800623 <sys_position+0xb>
    5ce8:	20 89       	ldd	r18, Z+16	; 0x10
    5cea:	27 ff       	sbrs	r18, 7
    5cec:	66 c0       	rjmp	.+204    	; 0x5dba <__vector_11+0x466>
    5cee:	01 97       	sbiw	r24, 0x01	; 1
    5cf0:	a1 09       	sbc	r26, r1
    5cf2:	b1 09       	sbc	r27, r1
    5cf4:	80 93 20 06 	sts	0x0620, r24	; 0x800620 <sys_position+0x8>
    5cf8:	90 93 21 06 	sts	0x0621, r25	; 0x800621 <sys_position+0x9>
    5cfc:	a0 93 22 06 	sts	0x0622, r26	; 0x800622 <sys_position+0xa>
    5d00:	b0 93 23 06 	sts	0x0623, r27	; 0x800623 <sys_position+0xb>
    5d04:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5d08:	84 30       	cpi	r24, 0x04	; 4
    5d0a:	39 f4       	brne	.+14     	; 0x5d1a <__vector_11+0x3c6>
    5d0c:	80 91 37 06 	lds	r24, 0x0637	; 0x800637 <sys+0x6>
    5d10:	90 91 03 02 	lds	r25, 0x0203	; 0x800203 <st+0xe>
    5d14:	89 23       	and	r24, r25
    5d16:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
    5d1a:	80 91 11 02 	lds	r24, 0x0211	; 0x800211 <st+0x1c>
    5d1e:	90 91 12 02 	lds	r25, 0x0212	; 0x800212 <st+0x1d>
    5d22:	01 97       	sbiw	r24, 0x01	; 1
    5d24:	90 93 12 02 	sts	0x0212, r25	; 0x800212 <st+0x1d>
    5d28:	80 93 11 02 	sts	0x0211, r24	; 0x800211 <st+0x1c>
    5d2c:	89 2b       	or	r24, r25
    5d2e:	69 f4       	brne	.+26     	; 0x5d4a <__vector_11+0x3f6>
    5d30:	10 92 17 02 	sts	0x0217, r1	; 0x800217 <st+0x22>
    5d34:	10 92 16 02 	sts	0x0216, r1	; 0x800216 <st+0x21>
    5d38:	80 91 18 02 	lds	r24, 0x0218	; 0x800218 <segment_buffer_tail>
    5d3c:	8f 5f       	subi	r24, 0xFF	; 255
    5d3e:	80 93 18 02 	sts	0x0218, r24	; 0x800218 <segment_buffer_tail>
    5d42:	86 30       	cpi	r24, 0x06	; 6
    5d44:	11 f4       	brne	.+4      	; 0x5d4a <__vector_11+0x3f6>
    5d46:	10 92 18 02 	sts	0x0218, r1	; 0x800218 <segment_buffer_tail>
    5d4a:	80 91 03 02 	lds	r24, 0x0203	; 0x800203 <st+0xe>
    5d4e:	90 91 f2 01 	lds	r25, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    5d52:	89 27       	eor	r24, r25
    5d54:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
    5d58:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    5d5c:	13 c0       	rjmp	.+38     	; 0x5d84 <__vector_11+0x430>
    5d5e:	0e 94 9b 0d 	call	0x1b36	; 0x1b36 <st_go_idle>
    5d62:	e0 91 14 02 	lds	r30, 0x0214	; 0x800214 <st+0x1f>
    5d66:	f0 91 15 02 	lds	r31, 0x0215	; 0x800215 <st+0x20>
    5d6a:	81 89       	ldd	r24, Z+17	; 0x11
    5d6c:	88 23       	and	r24, r24
    5d6e:	39 f0       	breq	.+14     	; 0x5d7e <__vector_11+0x42a>
    5d70:	10 92 b3 00 	sts	0x00B3, r1	; 0x8000b3 <__DATA_REGION_ORIGIN__+0x53>
    5d74:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    5d78:	8f 77       	andi	r24, 0x7F	; 127
    5d7a:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    5d7e:	84 e0       	ldi	r24, 0x04	; 4
    5d80:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    5d84:	ff 91       	pop	r31
    5d86:	ef 91       	pop	r30
    5d88:	bf 91       	pop	r27
    5d8a:	af 91       	pop	r26
    5d8c:	9f 91       	pop	r25
    5d8e:	8f 91       	pop	r24
    5d90:	7f 91       	pop	r23
    5d92:	6f 91       	pop	r22
    5d94:	5f 91       	pop	r21
    5d96:	4f 91       	pop	r20
    5d98:	3f 91       	pop	r19
    5d9a:	2f 91       	pop	r18
    5d9c:	1f 91       	pop	r17
    5d9e:	0f 91       	pop	r16
    5da0:	0f 90       	pop	r0
    5da2:	0f be       	out	0x3f, r0	; 63
    5da4:	0f 90       	pop	r0
    5da6:	1f 90       	pop	r1
    5da8:	18 95       	reti
    5daa:	01 96       	adiw	r24, 0x01	; 1
    5dac:	a1 1d       	adc	r26, r1
    5dae:	b1 1d       	adc	r27, r1
    5db0:	11 cf       	rjmp	.-478    	; 0x5bd4 <__vector_11+0x280>
    5db2:	01 96       	adiw	r24, 0x01	; 1
    5db4:	a1 1d       	adc	r26, r1
    5db6:	b1 1d       	adc	r27, r1
    5db8:	55 cf       	rjmp	.-342    	; 0x5c64 <__vector_11+0x310>
    5dba:	01 96       	adiw	r24, 0x01	; 1
    5dbc:	a1 1d       	adc	r26, r1
    5dbe:	b1 1d       	adc	r27, r1
    5dc0:	99 cf       	rjmp	.-206    	; 0x5cf4 <__vector_11+0x3a0>

00005dc2 <__vector_18>:
    5dc2:	1f 92       	push	r1
    5dc4:	0f 92       	push	r0
    5dc6:	0f b6       	in	r0, 0x3f	; 63
    5dc8:	0f 92       	push	r0
    5dca:	11 24       	eor	r1, r1
    5dcc:	2f 93       	push	r18
    5dce:	3f 93       	push	r19
    5dd0:	4f 93       	push	r20
    5dd2:	5f 93       	push	r21
    5dd4:	6f 93       	push	r22
    5dd6:	7f 93       	push	r23
    5dd8:	8f 93       	push	r24
    5dda:	9f 93       	push	r25
    5ddc:	af 93       	push	r26
    5dde:	bf 93       	push	r27
    5de0:	ef 93       	push	r30
    5de2:	ff 93       	push	r31
    5de4:	e0 91 c6 00 	lds	r30, 0x00C6	; 0x8000c6 <__DATA_REGION_ORIGIN__+0x66>
    5de8:	e1 32       	cpi	r30, 0x21	; 33
    5dea:	09 f4       	brne	.+2      	; 0x5dee <__vector_18+0x2c>
    5dec:	4b c0       	rjmp	.+150    	; 0x5e84 <__vector_18+0xc2>
    5dee:	08 f0       	brcs	.+2      	; 0x5df2 <__vector_18+0x30>
    5df0:	2b c0       	rjmp	.+86     	; 0x5e48 <__vector_18+0x86>
    5df2:	e8 31       	cpi	r30, 0x18	; 24
    5df4:	09 f4       	brne	.+2      	; 0x5df8 <__vector_18+0x36>
    5df6:	31 c0       	rjmp	.+98     	; 0x5e5a <__vector_18+0x98>
    5df8:	e7 ff       	sbrs	r30, 7
    5dfa:	70 c0       	rjmp	.+224    	; 0x5edc <__vector_18+0x11a>
    5dfc:	e4 58       	subi	r30, 0x84	; 132
    5dfe:	ed 31       	cpi	r30, 0x1D	; 29
    5e00:	08 f0       	brcs	.+2      	; 0x5e04 <__vector_18+0x42>
    5e02:	2d c0       	rjmp	.+90     	; 0x5e5e <__vector_18+0x9c>
    5e04:	f0 e0       	ldi	r31, 0x00	; 0
    5e06:	e9 5f       	subi	r30, 0xF9	; 249
    5e08:	f0 4d       	sbci	r31, 0xD0	; 208
    5e0a:	0c 94 a8 39 	jmp	0x7350	; 0x7350 <__tablejump2__>
    5e0e:	44 2f       	mov	r20, r20
    5e10:	46 2f       	mov	r20, r22
    5e12:	2f 2f       	mov	r18, r31
    5e14:	2f 2f       	mov	r18, r31
    5e16:	2f 2f       	mov	r18, r31
    5e18:	2f 2f       	mov	r18, r31
    5e1a:	2f 2f       	mov	r18, r31
    5e1c:	2f 2f       	mov	r18, r31
    5e1e:	2f 2f       	mov	r18, r31
    5e20:	2f 2f       	mov	r18, r31
    5e22:	2f 2f       	mov	r18, r31
    5e24:	2f 2f       	mov	r18, r31
    5e26:	4c 2f       	mov	r20, r28
    5e28:	50 2f       	mov	r21, r16
    5e2a:	52 2f       	mov	r21, r18
    5e2c:	54 2f       	mov	r21, r20
    5e2e:	56 2f       	mov	r21, r22
    5e30:	58 2f       	mov	r21, r24
    5e32:	5a 2f       	mov	r21, r26
    5e34:	5c 2f       	mov	r21, r28
    5e36:	2f 2f       	mov	r18, r31
    5e38:	5e 2f       	mov	r21, r30
    5e3a:	62 2f       	mov	r22, r18
    5e3c:	64 2f       	mov	r22, r20
    5e3e:	66 2f       	mov	r22, r22
    5e40:	68 2f       	mov	r22, r24
    5e42:	6a 2f       	mov	r22, r26
    5e44:	2f 2f       	mov	r18, r31
    5e46:	6c 2f       	mov	r22, r28
    5e48:	ef 33       	cpi	r30, 0x3F	; 63
    5e4a:	d1 f0       	breq	.+52     	; 0x5e80 <__vector_18+0xbe>
    5e4c:	82 e0       	ldi	r24, 0x02	; 2
    5e4e:	ee 37       	cpi	r30, 0x7E	; 126
    5e50:	09 f0       	breq	.+2      	; 0x5e54 <__vector_18+0x92>
    5e52:	d2 cf       	rjmp	.-92     	; 0x5df8 <__vector_18+0x36>
    5e54:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    5e58:	02 c0       	rjmp	.+4      	; 0x5e5e <__vector_18+0x9c>
    5e5a:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    5e5e:	ff 91       	pop	r31
    5e60:	ef 91       	pop	r30
    5e62:	bf 91       	pop	r27
    5e64:	af 91       	pop	r26
    5e66:	9f 91       	pop	r25
    5e68:	8f 91       	pop	r24
    5e6a:	7f 91       	pop	r23
    5e6c:	6f 91       	pop	r22
    5e6e:	5f 91       	pop	r21
    5e70:	4f 91       	pop	r20
    5e72:	3f 91       	pop	r19
    5e74:	2f 91       	pop	r18
    5e76:	0f 90       	pop	r0
    5e78:	0f be       	out	0x3f, r0	; 63
    5e7a:	0f 90       	pop	r0
    5e7c:	1f 90       	pop	r1
    5e7e:	18 95       	reti
    5e80:	81 e0       	ldi	r24, 0x01	; 1
    5e82:	e8 cf       	rjmp	.-48     	; 0x5e54 <__vector_18+0x92>
    5e84:	88 e0       	ldi	r24, 0x08	; 8
    5e86:	e6 cf       	rjmp	.-52     	; 0x5e54 <__vector_18+0x92>
    5e88:	80 e2       	ldi	r24, 0x20	; 32
    5e8a:	e4 cf       	rjmp	.-56     	; 0x5e54 <__vector_18+0x92>
    5e8c:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5e90:	85 ff       	sbrs	r24, 5
    5e92:	e5 cf       	rjmp	.-54     	; 0x5e5e <__vector_18+0x9c>
    5e94:	80 e4       	ldi	r24, 0x40	; 64
    5e96:	de cf       	rjmp	.-68     	; 0x5e54 <__vector_18+0x92>
    5e98:	81 e0       	ldi	r24, 0x01	; 1
    5e9a:	0e 94 32 02 	call	0x464	; 0x464 <system_set_exec_motion_override_flag>
    5e9e:	df cf       	rjmp	.-66     	; 0x5e5e <__vector_18+0x9c>
    5ea0:	82 e0       	ldi	r24, 0x02	; 2
    5ea2:	fb cf       	rjmp	.-10     	; 0x5e9a <__vector_18+0xd8>
    5ea4:	84 e0       	ldi	r24, 0x04	; 4
    5ea6:	f9 cf       	rjmp	.-14     	; 0x5e9a <__vector_18+0xd8>
    5ea8:	88 e0       	ldi	r24, 0x08	; 8
    5eaa:	f7 cf       	rjmp	.-18     	; 0x5e9a <__vector_18+0xd8>
    5eac:	80 e1       	ldi	r24, 0x10	; 16
    5eae:	f5 cf       	rjmp	.-22     	; 0x5e9a <__vector_18+0xd8>
    5eb0:	80 e2       	ldi	r24, 0x20	; 32
    5eb2:	f3 cf       	rjmp	.-26     	; 0x5e9a <__vector_18+0xd8>
    5eb4:	80 e4       	ldi	r24, 0x40	; 64
    5eb6:	f1 cf       	rjmp	.-30     	; 0x5e9a <__vector_18+0xd8>
    5eb8:	80 e8       	ldi	r24, 0x80	; 128
    5eba:	ef cf       	rjmp	.-34     	; 0x5e9a <__vector_18+0xd8>
    5ebc:	81 e0       	ldi	r24, 0x01	; 1
    5ebe:	0e 94 29 02 	call	0x452	; 0x452 <system_set_exec_accessory_override_flag>
    5ec2:	cd cf       	rjmp	.-102    	; 0x5e5e <__vector_18+0x9c>
    5ec4:	82 e0       	ldi	r24, 0x02	; 2
    5ec6:	fb cf       	rjmp	.-10     	; 0x5ebe <__vector_18+0xfc>
    5ec8:	84 e0       	ldi	r24, 0x04	; 4
    5eca:	f9 cf       	rjmp	.-14     	; 0x5ebe <__vector_18+0xfc>
    5ecc:	88 e0       	ldi	r24, 0x08	; 8
    5ece:	f7 cf       	rjmp	.-18     	; 0x5ebe <__vector_18+0xfc>
    5ed0:	80 e1       	ldi	r24, 0x10	; 16
    5ed2:	f5 cf       	rjmp	.-22     	; 0x5ebe <__vector_18+0xfc>
    5ed4:	80 e2       	ldi	r24, 0x20	; 32
    5ed6:	f3 cf       	rjmp	.-26     	; 0x5ebe <__vector_18+0xfc>
    5ed8:	80 e4       	ldi	r24, 0x40	; 64
    5eda:	f1 cf       	rjmp	.-30     	; 0x5ebe <__vector_18+0xfc>
    5edc:	a0 91 f0 01 	lds	r26, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    5ee0:	81 e0       	ldi	r24, 0x01	; 1
    5ee2:	8a 0f       	add	r24, r26
    5ee4:	81 38       	cpi	r24, 0x81	; 129
    5ee6:	09 f4       	brne	.+2      	; 0x5eea <__vector_18+0x128>
    5ee8:	80 e0       	ldi	r24, 0x00	; 0
    5eea:	90 91 f1 01 	lds	r25, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    5eee:	98 17       	cp	r25, r24
    5ef0:	09 f4       	brne	.+2      	; 0x5ef4 <__vector_18+0x132>
    5ef2:	b5 cf       	rjmp	.-150    	; 0x5e5e <__vector_18+0x9c>
    5ef4:	b0 e0       	ldi	r27, 0x00	; 0
    5ef6:	a1 59       	subi	r26, 0x91	; 145
    5ef8:	be 4f       	sbci	r27, 0xFE	; 254
    5efa:	ec 93       	st	X, r30
    5efc:	80 93 f0 01 	sts	0x01F0, r24	; 0x8001f0 <serial_rx_buffer_head>
    5f00:	ae cf       	rjmp	.-164    	; 0x5e5e <__vector_18+0x9c>

00005f02 <__vector_19>:
    5f02:	1f 92       	push	r1
    5f04:	0f 92       	push	r0
    5f06:	0f b6       	in	r0, 0x3f	; 63
    5f08:	0f 92       	push	r0
    5f0a:	11 24       	eor	r1, r1
    5f0c:	8f 93       	push	r24
    5f0e:	9f 93       	push	r25
    5f10:	ef 93       	push	r30
    5f12:	ff 93       	push	r31
    5f14:	80 91 6e 01 	lds	r24, 0x016E	; 0x80016e <serial_tx_buffer_tail>
    5f18:	e8 2f       	mov	r30, r24
    5f1a:	f0 e0       	ldi	r31, 0x00	; 0
    5f1c:	eb 5f       	subi	r30, 0xFB	; 251
    5f1e:	fe 4f       	sbci	r31, 0xFE	; 254
    5f20:	90 81       	ld	r25, Z
    5f22:	90 93 c6 00 	sts	0x00C6, r25	; 0x8000c6 <__DATA_REGION_ORIGIN__+0x66>
    5f26:	8f 5f       	subi	r24, 0xFF	; 255
    5f28:	89 36       	cpi	r24, 0x69	; 105
    5f2a:	09 f4       	brne	.+2      	; 0x5f2e <__vector_19+0x2c>
    5f2c:	80 e0       	ldi	r24, 0x00	; 0
    5f2e:	80 93 6e 01 	sts	0x016E, r24	; 0x80016e <serial_tx_buffer_tail>
    5f32:	90 91 04 01 	lds	r25, 0x0104	; 0x800104 <serial_tx_buffer_head>
    5f36:	98 13       	cpse	r25, r24
    5f38:	05 c0       	rjmp	.+10     	; 0x5f44 <__vector_19+0x42>
    5f3a:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f3e:	8f 7d       	andi	r24, 0xDF	; 223
    5f40:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f44:	ff 91       	pop	r31
    5f46:	ef 91       	pop	r30
    5f48:	9f 91       	pop	r25
    5f4a:	8f 91       	pop	r24
    5f4c:	0f 90       	pop	r0
    5f4e:	0f be       	out	0x3f, r0	; 63
    5f50:	0f 90       	pop	r0
    5f52:	1f 90       	pop	r1
    5f54:	18 95       	reti

00005f56 <main>:
    5f56:	cf 93       	push	r28
    5f58:	df 93       	push	r29
    5f5a:	cd b7       	in	r28, 0x3d	; 61
    5f5c:	de b7       	in	r29, 0x3e	; 62
    5f5e:	65 97       	sbiw	r28, 0x15	; 21
    5f60:	0f b6       	in	r0, 0x3f	; 63
    5f62:	f8 94       	cli
    5f64:	de bf       	out	0x3e, r29	; 62
    5f66:	0f be       	out	0x3f, r0	; 63
    5f68:	cd bf       	out	0x3d, r28	; 61
    5f6a:	80 91 c0 00 	lds	r24, 0x00C0	; 0x8000c0 <__DATA_REGION_ORIGIN__+0x60>
    5f6e:	82 60       	ori	r24, 0x02	; 2
    5f70:	80 93 c0 00 	sts	0x00C0, r24	; 0x8000c0 <__DATA_REGION_ORIGIN__+0x60>
    5f74:	10 92 c5 00 	sts	0x00C5, r1	; 0x8000c5 <__DATA_REGION_ORIGIN__+0x65>
    5f78:	80 e1       	ldi	r24, 0x10	; 16
    5f7a:	80 93 c4 00 	sts	0x00C4, r24	; 0x8000c4 <__DATA_REGION_ORIGIN__+0x64>
    5f7e:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f82:	88 69       	ori	r24, 0x98	; 152
    5f84:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f88:	90 e0       	ldi	r25, 0x00	; 0
    5f8a:	80 e0       	ldi	r24, 0x00	; 0
    5f8c:	0e 94 86 04 	call	0x90c	; 0x90c <eeprom_get_char>
    5f90:	8a 30       	cpi	r24, 0x0A	; 10
    5f92:	09 f4       	brne	.+2      	; 0x5f96 <main+0x40>
    5f94:	db c0       	rjmp	.+438    	; 0x614c <main+0x1f6>
    5f96:	87 e0       	ldi	r24, 0x07	; 7
    5f98:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    5f9c:	8f ef       	ldi	r24, 0xFF	; 255
    5f9e:	0e 94 9c 1d 	call	0x3b38	; 0x3b38 <settings_restore>
    5fa2:	0e 94 14 08 	call	0x1028	; 0x1028 <report_grbl_settings>
    5fa6:	8a b1       	in	r24, 0x0a	; 10
    5fa8:	8c 61       	ori	r24, 0x1C	; 28
    5faa:	8a b9       	out	0x0a, r24	; 10
    5fac:	20 9a       	sbi	0x04, 0	; 4
    5fae:	8a b1       	in	r24, 0x0a	; 10
    5fb0:	80 6e       	ori	r24, 0xE0	; 224
    5fb2:	8a b9       	out	0x0a, r24	; 10
    5fb4:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    5fb8:	8f 7e       	andi	r24, 0xEF	; 239
    5fba:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    5fbe:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    5fc2:	88 60       	ori	r24, 0x08	; 8
    5fc4:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    5fc8:	80 91 80 00 	lds	r24, 0x0080	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    5fcc:	8c 7f       	andi	r24, 0xFC	; 252
    5fce:	80 93 80 00 	sts	0x0080, r24	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    5fd2:	80 91 80 00 	lds	r24, 0x0080	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    5fd6:	8f 70       	andi	r24, 0x0F	; 15
    5fd8:	80 93 80 00 	sts	0x0080, r24	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    5fdc:	80 91 6e 00 	lds	r24, 0x006E	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    5fe0:	88 7f       	andi	r24, 0xF8	; 248
    5fe2:	80 93 6e 00 	sts	0x006E, r24	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    5fe6:	14 bc       	out	0x24, r1	; 36
    5fe8:	15 bc       	out	0x25, r1	; 37
    5fea:	80 91 6e 00 	lds	r24, 0x006E	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    5fee:	81 60       	ori	r24, 0x01	; 1
    5ff0:	80 93 6e 00 	sts	0x006E, r24	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    5ff4:	87 b1       	in	r24, 0x07	; 7
    5ff6:	88 7f       	andi	r24, 0xF8	; 248
    5ff8:	87 b9       	out	0x07, r24	; 7
    5ffa:	88 b1       	in	r24, 0x08	; 8
    5ffc:	87 60       	ori	r24, 0x07	; 7
    5ffe:	88 b9       	out	0x08, r24	; 8
    6000:	80 91 6c 00 	lds	r24, 0x006C	; 0x80006c <__DATA_REGION_ORIGIN__+0xc>
    6004:	87 60       	ori	r24, 0x07	; 7
    6006:	80 93 6c 00 	sts	0x006C, r24	; 0x80006c <__DATA_REGION_ORIGIN__+0xc>
    600a:	80 91 68 00 	lds	r24, 0x0068	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
    600e:	82 60       	ori	r24, 0x02	; 2
    6010:	80 93 68 00 	sts	0x0068, r24	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
    6014:	e8 e1       	ldi	r30, 0x18	; 24
    6016:	f6 e0       	ldi	r31, 0x06	; 6
    6018:	8c e0       	ldi	r24, 0x0C	; 12
    601a:	df 01       	movw	r26, r30
    601c:	1d 92       	st	X+, r1
    601e:	8a 95       	dec	r24
    6020:	e9 f7       	brne	.-6      	; 0x601c <main+0xc6>
    6022:	78 94       	sei
    6024:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6028:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    602c:	84 ff       	sbrs	r24, 4
    602e:	03 c0       	rjmp	.+6      	; 0x6036 <main+0xe0>
    6030:	81 e0       	ldi	r24, 0x01	; 1
    6032:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    6036:	31 e3       	ldi	r19, 0x31	; 49
    6038:	23 2e       	mov	r2, r19
    603a:	36 e0       	ldi	r19, 0x06	; 6
    603c:	33 2e       	mov	r3, r19
    603e:	47 e9       	ldi	r20, 0x97	; 151
    6040:	a4 2e       	mov	r10, r20
    6042:	46 e0       	ldi	r20, 0x06	; 6
    6044:	b4 2e       	mov	r11, r20
    6046:	99 24       	eor	r9, r9
    6048:	93 94       	inc	r9
    604a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    604e:	91 e1       	ldi	r25, 0x11	; 17
    6050:	f1 01       	movw	r30, r2
    6052:	11 92       	st	Z+, r1
    6054:	9a 95       	dec	r25
    6056:	e9 f7       	brne	.-6      	; 0x6052 <main+0xfc>
    6058:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    605c:	84 e6       	ldi	r24, 0x64	; 100
    605e:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    6062:	80 93 39 06 	sts	0x0639, r24	; 0x800639 <sys+0x8>
    6066:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    606a:	8c e0       	ldi	r24, 0x0C	; 12
    606c:	a4 e2       	ldi	r26, 0x24	; 36
    606e:	b6 e0       	ldi	r27, 0x06	; 6
    6070:	1d 92       	st	X+, r1
    6072:	8a 95       	dec	r24
    6074:	e9 f7       	brne	.-6      	; 0x6070 <main+0x11a>
    6076:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    607a:	10 92 13 06 	sts	0x0613, r1	; 0x800613 <sys_rt_exec_state>
    607e:	10 92 14 06 	sts	0x0614, r1	; 0x800614 <sys_rt_exec_alarm>
    6082:	10 92 15 06 	sts	0x0615, r1	; 0x800615 <sys_rt_exec_motion_override>
    6086:	10 92 16 06 	sts	0x0616, r1	; 0x800616 <sys_rt_exec_accessory_override>
    608a:	80 91 f0 01 	lds	r24, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    608e:	80 93 f1 01 	sts	0x01F1, r24	; 0x8001f1 <serial_rx_buffer_tail>
    6092:	80 e4       	ldi	r24, 0x40	; 64
    6094:	f5 01       	movw	r30, r10
    6096:	11 92       	st	Z+, r1
    6098:	8a 95       	dec	r24
    609a:	e9 f7       	brne	.-6      	; 0x6096 <main+0x140>
    609c:	6b eb       	ldi	r22, 0xBB	; 187
    609e:	76 e0       	ldi	r23, 0x06	; 6
    60a0:	80 e0       	ldi	r24, 0x00	; 0
    60a2:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    60a6:	81 11       	cpse	r24, r1
    60a8:	03 c0       	rjmp	.+6      	; 0x60b0 <main+0x15a>
    60aa:	87 e0       	ldi	r24, 0x07	; 7
    60ac:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    60b0:	0e 94 69 09 	call	0x12d2	; 0x12d2 <spindle_init>
    60b4:	3b 9a       	sbi	0x07, 3	; 7
    60b6:	43 98       	cbi	0x08, 3	; 8
    60b8:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    60bc:	3d 98       	cbi	0x07, 5	; 7
    60be:	45 9a       	sbi	0x08, 5	; 8
    60c0:	80 e0       	ldi	r24, 0x00	; 0
    60c2:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    60c6:	0e 94 a2 09 	call	0x1344	; 0x1344 <plan_reset>
    60ca:	0e 94 cf 0d 	call	0x1b9e	; 0x1b9e <st_reset>
    60ce:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    60d2:	0e 94 9c 09 	call	0x1338	; 0x1338 <gc_sync_position>
    60d6:	84 eb       	ldi	r24, 0xB4	; 180
    60d8:	90 e0       	ldi	r25, 0x00	; 0
    60da:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    60de:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    60e2:	83 ff       	sbrs	r24, 3
    60e4:	10 c0       	rjmp	.+32     	; 0x6106 <main+0x1b0>
    60e6:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    60ea:	88 23       	and	r24, r24
    60ec:	61 f0       	breq	.+24     	; 0x6106 <main+0x1b0>
    60ee:	90 92 31 06 	sts	0x0631, r9	; 0x800631 <sys>
    60f2:	8a ec       	ldi	r24, 0xCA	; 202
    60f4:	92 e0       	ldi	r25, 0x02	; 2
    60f6:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    60fa:	89 e6       	ldi	r24, 0x69	; 105
    60fc:	92 e0       	ldi	r25, 0x02	; 2
    60fe:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6102:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6106:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    610a:	81 78       	andi	r24, 0x81	; 129
    610c:	59 f1       	breq	.+86     	; 0x6164 <main+0x20e>
    610e:	8a ec       	ldi	r24, 0xCA	; 202
    6110:	92 e0       	ldi	r25, 0x02	; 2
    6112:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6116:	84 ea       	ldi	r24, 0xA4	; 164
    6118:	92 e0       	ldi	r25, 0x02	; 2
    611a:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    611e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6122:	90 92 31 06 	sts	0x0631, r9	; 0x800631 <sys>
    6126:	10 e0       	ldi	r17, 0x00	; 0
    6128:	00 e0       	ldi	r16, 0x00	; 0
    612a:	22 e0       	ldi	r18, 0x02	; 2
    612c:	82 2e       	mov	r8, r18
    612e:	90 91 f1 01 	lds	r25, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    6132:	80 91 f0 01 	lds	r24, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    6136:	98 13       	cpse	r25, r24
    6138:	4c c4       	rjmp	.+2200   	; 0x69d2 <main+0xa7c>
    613a:	0e 94 85 06 	call	0xd0a	; 0xd0a <protocol_auto_cycle_start>
    613e:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    6142:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    6146:	88 23       	and	r24, r24
    6148:	91 f3       	breq	.-28     	; 0x612e <main+0x1d8>
    614a:	7f cf       	rjmp	.-258    	; 0x604a <main+0xf4>
    614c:	45 e5       	ldi	r20, 0x55	; 85
    614e:	50 e0       	ldi	r21, 0x00	; 0
    6150:	61 e0       	ldi	r22, 0x01	; 1
    6152:	70 e0       	ldi	r23, 0x00	; 0
    6154:	82 e4       	ldi	r24, 0x42	; 66
    6156:	96 e0       	ldi	r25, 0x06	; 6
    6158:	0e 94 8e 04 	call	0x91c	; 0x91c <memcpy_from_eeprom_with_checksum>
    615c:	89 2b       	or	r24, r25
    615e:	09 f0       	breq	.+2      	; 0x6162 <main+0x20c>
    6160:	22 cf       	rjmp	.-444    	; 0x5fa6 <main+0x50>
    6162:	19 cf       	rjmp	.-462    	; 0x5f96 <main+0x40>
    6164:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6168:	0e 94 fc 2b 	call	0x57f8	; 0x57f8 <system_execute_startup.constprop.2>
    616c:	dc cf       	rjmp	.-72     	; 0x6126 <main+0x1d0>
    616e:	84 32       	cpi	r24, 0x24	; 36
    6170:	09 f0       	breq	.+2      	; 0x6174 <main+0x21e>
    6172:	fd c3       	rjmp	.+2042   	; 0x696e <main+0xa18>
    6174:	9d 8a       	std	Y+21, r9	; 0x15
    6176:	80 91 12 07 	lds	r24, 0x0712	; 0x800712 <line+0x1>
    617a:	83 34       	cpi	r24, 0x43	; 67
    617c:	29 f0       	breq	.+10     	; 0x6188 <main+0x232>
    617e:	bc f4       	brge	.+46     	; 0x61ae <main+0x258>
    6180:	88 23       	and	r24, r24
    6182:	b9 f1       	breq	.+110    	; 0x61f2 <main+0x29c>
    6184:	84 32       	cpi	r24, 0x24	; 36
    6186:	c9 f4       	brne	.+50     	; 0x61ba <main+0x264>
    6188:	90 91 13 07 	lds	r25, 0x0713	; 0x800713 <line+0x2>
    618c:	91 11       	cpse	r25, r1
    618e:	40 c0       	rjmp	.+128    	; 0x6210 <main+0x2ba>
    6190:	83 34       	cpi	r24, 0x43	; 67
    6192:	09 f4       	brne	.+2      	; 0x6196 <main+0x240>
    6194:	f9 c0       	rjmp	.+498    	; 0x6388 <main+0x432>
    6196:	0c f0       	brlt	.+2      	; 0x619a <main+0x244>
    6198:	42 c0       	rjmp	.+132    	; 0x621e <main+0x2c8>
    619a:	84 32       	cpi	r24, 0x24	; 36
    619c:	71 f5       	brne	.+92     	; 0x61fa <main+0x2a4>
    619e:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    61a2:	88 71       	andi	r24, 0x18	; 24
    61a4:	09 f0       	breq	.+2      	; 0x61a8 <main+0x252>
    61a6:	22 c1       	rjmp	.+580    	; 0x63ec <main+0x496>
    61a8:	0e 94 14 08 	call	0x1028	; 0x1028 <report_grbl_settings>
    61ac:	26 c0       	rjmp	.+76     	; 0x61fa <main+0x2a4>
    61ae:	8a 34       	cpi	r24, 0x4A	; 74
    61b0:	31 f1       	breq	.+76     	; 0x61fe <main+0x2a8>
    61b2:	88 35       	cpi	r24, 0x58	; 88
    61b4:	49 f3       	breq	.-46     	; 0x6188 <main+0x232>
    61b6:	87 34       	cpi	r24, 0x47	; 71
    61b8:	39 f3       	breq	.-50     	; 0x6188 <main+0x232>
    61ba:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    61be:	92 30       	cpi	r25, 0x02	; 2
    61c0:	08 f0       	brcs	.+2      	; 0x61c4 <main+0x26e>
    61c2:	14 c1       	rjmp	.+552    	; 0x63ec <main+0x496>
    61c4:	89 34       	cpi	r24, 0x49	; 73
    61c6:	09 f4       	brne	.+2      	; 0x61ca <main+0x274>
    61c8:	a3 c1       	rjmp	.+838    	; 0x6510 <main+0x5ba>
    61ca:	0c f0       	brlt	.+2      	; 0x61ce <main+0x278>
    61cc:	fb c0       	rjmp	.+502    	; 0x63c4 <main+0x46e>
    61ce:	83 32       	cpi	r24, 0x23	; 35
    61d0:	09 f4       	brne	.+2      	; 0x61d4 <main+0x27e>
    61d2:	0e c1       	rjmp	.+540    	; 0x63f0 <main+0x49a>
    61d4:	88 34       	cpi	r24, 0x48	; 72
    61d6:	09 f4       	brne	.+2      	; 0x61da <main+0x284>
    61d8:	5a c1       	rjmp	.+692    	; 0x648e <main+0x538>
    61da:	10 e0       	ldi	r17, 0x00	; 0
    61dc:	be 01       	movw	r22, r28
    61de:	6f 5e       	subi	r22, 0xEF	; 239
    61e0:	7f 4f       	sbci	r23, 0xFF	; 255
    61e2:	ce 01       	movw	r24, r28
    61e4:	45 96       	adiw	r24, 0x15	; 21
    61e6:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    61ea:	81 11       	cpse	r24, r1
    61ec:	2f c2       	rjmp	.+1118   	; 0x664c <main+0x6f6>
    61ee:	12 e0       	ldi	r17, 0x02	; 2
    61f0:	14 c0       	rjmp	.+40     	; 0x621a <main+0x2c4>
    61f2:	8c e1       	ldi	r24, 0x1C	; 28
    61f4:	91 e0       	ldi	r25, 0x01	; 1
    61f6:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    61fa:	10 e0       	ldi	r17, 0x00	; 0
    61fc:	0e c0       	rjmp	.+28     	; 0x621a <main+0x2c4>
    61fe:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    6202:	8f 7d       	andi	r24, 0xDF	; 223
    6204:	09 f0       	breq	.+2      	; 0x6208 <main+0x2b2>
    6206:	f2 c0       	rjmp	.+484    	; 0x63ec <main+0x496>
    6208:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    620c:	8d 33       	cpi	r24, 0x3D	; 61
    620e:	11 f0       	breq	.+4      	; 0x6214 <main+0x2be>
    6210:	13 e0       	ldi	r17, 0x03	; 3
    6212:	03 c0       	rjmp	.+6      	; 0x621a <main+0x2c4>
    6214:	0e 94 77 1e 	call	0x3cee	; 0x3cee <gc_execute_line.constprop.11>
    6218:	18 2f       	mov	r17, r24
    621a:	81 2f       	mov	r24, r17
    621c:	fe c3       	rjmp	.+2044   	; 0x6a1a <main+0xac4>
    621e:	87 34       	cpi	r24, 0x47	; 71
    6220:	99 f0       	breq	.+38     	; 0x6248 <main+0x2f2>
    6222:	88 35       	cpi	r24, 0x58	; 88
    6224:	51 f7       	brne	.-44     	; 0x61fa <main+0x2a4>
    6226:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    622a:	81 30       	cpi	r24, 0x01	; 1
    622c:	31 f7       	brne	.-52     	; 0x61fa <main+0x2a4>
    622e:	8a ec       	ldi	r24, 0xCA	; 202
    6230:	92 e0       	ldi	r25, 0x02	; 2
    6232:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6236:	82 e9       	ldi	r24, 0x92	; 146
    6238:	92 e0       	ldi	r25, 0x02	; 2
    623a:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    623e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6242:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6246:	d9 cf       	rjmp	.-78     	; 0x61fa <main+0x2a4>
    6248:	86 e1       	ldi	r24, 0x16	; 22
    624a:	91 e0       	ldi	r25, 0x01	; 1
    624c:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6250:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    6254:	8c 38       	cpi	r24, 0x8C	; 140
    6256:	38 f0       	brcs	.+14     	; 0x6266 <main+0x310>
    6258:	82 e1       	ldi	r24, 0x12	; 18
    625a:	91 e0       	ldi	r25, 0x01	; 1
    625c:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6260:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    6264:	8a 58       	subi	r24, 0x8A	; 138
    6266:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    626a:	83 e0       	ldi	r24, 0x03	; 3
    626c:	91 e0       	ldi	r25, 0x01	; 1
    626e:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6272:	80 91 9d 06 	lds	r24, 0x069D	; 0x80069d <gc_state+0x6>
    6276:	8a 5c       	subi	r24, 0xCA	; 202
    6278:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    627c:	83 e0       	ldi	r24, 0x03	; 3
    627e:	91 e0       	ldi	r25, 0x01	; 1
    6280:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6284:	80 91 9b 06 	lds	r24, 0x069B	; 0x80069b <gc_state+0x4>
    6288:	8f 5e       	subi	r24, 0xEF	; 239
    628a:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    628e:	83 e0       	ldi	r24, 0x03	; 3
    6290:	91 e0       	ldi	r25, 0x01	; 1
    6292:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6296:	80 91 99 06 	lds	r24, 0x0699	; 0x800699 <gc_state+0x2>
    629a:	f5 e1       	ldi	r31, 0x15	; 21
    629c:	f8 1b       	sub	r31, r24
    629e:	8f 2f       	mov	r24, r31
    62a0:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    62a4:	83 e0       	ldi	r24, 0x03	; 3
    62a6:	91 e0       	ldi	r25, 0x01	; 1
    62a8:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    62ac:	80 91 9a 06 	lds	r24, 0x069A	; 0x80069a <gc_state+0x3>
    62b0:	86 5a       	subi	r24, 0xA6	; 166
    62b2:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    62b6:	83 e0       	ldi	r24, 0x03	; 3
    62b8:	91 e0       	ldi	r25, 0x01	; 1
    62ba:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    62be:	80 91 98 06 	lds	r24, 0x0698	; 0x800698 <gc_state+0x1>
    62c2:	2e e5       	ldi	r18, 0x5E	; 94
    62c4:	28 1b       	sub	r18, r24
    62c6:	82 2f       	mov	r24, r18
    62c8:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    62cc:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    62d0:	88 23       	and	r24, r24
    62d2:	91 f0       	breq	.+36     	; 0x62f8 <main+0x3a2>
    62d4:	86 e0       	ldi	r24, 0x06	; 6
    62d6:	91 e0       	ldi	r25, 0x01	; 1
    62d8:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    62dc:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    62e0:	83 30       	cpi	r24, 0x03	; 3
    62e2:	39 f0       	breq	.+14     	; 0x62f2 <main+0x39c>
    62e4:	8e 31       	cpi	r24, 0x1E	; 30
    62e6:	11 f0       	breq	.+4      	; 0x62ec <main+0x396>
    62e8:	82 30       	cpi	r24, 0x02	; 2
    62ea:	31 f4       	brne	.+12     	; 0x62f8 <main+0x3a2>
    62ec:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    62f0:	03 c0       	rjmp	.+6      	; 0x62f8 <main+0x3a2>
    62f2:	80 e3       	ldi	r24, 0x30	; 48
    62f4:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    62f8:	86 e0       	ldi	r24, 0x06	; 6
    62fa:	91 e0       	ldi	r25, 0x01	; 1
    62fc:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6300:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    6304:	80 31       	cpi	r24, 0x10	; 16
    6306:	31 f0       	breq	.+12     	; 0x6314 <main+0x3be>
    6308:	80 32       	cpi	r24, 0x20	; 32
    630a:	d1 f1       	breq	.+116    	; 0x6380 <main+0x42a>
    630c:	81 11       	cpse	r24, r1
    630e:	05 c0       	rjmp	.+10     	; 0x631a <main+0x3c4>
    6310:	85 e3       	ldi	r24, 0x35	; 53
    6312:	01 c0       	rjmp	.+2      	; 0x6316 <main+0x3c0>
    6314:	83 e3       	ldi	r24, 0x33	; 51
    6316:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    631a:	86 e0       	ldi	r24, 0x06	; 6
    631c:	91 e0       	ldi	r25, 0x01	; 1
    631e:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6322:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    6326:	88 23       	and	r24, r24
    6328:	69 f1       	breq	.+90     	; 0x6384 <main+0x42e>
    632a:	88 e3       	ldi	r24, 0x38	; 56
    632c:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    6330:	8f e0       	ldi	r24, 0x0F	; 15
    6332:	91 e0       	ldi	r25, 0x01	; 1
    6334:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6338:	80 91 aa 06 	lds	r24, 0x06AA	; 0x8006aa <gc_state+0x13>
    633c:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    6340:	8c e0       	ldi	r24, 0x0C	; 12
    6342:	91 e0       	ldi	r25, 0x01	; 1
    6344:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6348:	60 91 a6 06 	lds	r22, 0x06A6	; 0x8006a6 <gc_state+0xf>
    634c:	70 91 a7 06 	lds	r23, 0x06A7	; 0x8006a7 <gc_state+0x10>
    6350:	80 91 a8 06 	lds	r24, 0x06A8	; 0x8006a8 <gc_state+0x11>
    6354:	90 91 a9 06 	lds	r25, 0x06A9	; 0x8006a9 <gc_state+0x12>
    6358:	0e 94 60 07 	call	0xec0	; 0xec0 <printFloat_RateValue>
    635c:	89 e0       	ldi	r24, 0x09	; 9
    635e:	91 e0       	ldi	r25, 0x01	; 1
    6360:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6364:	60 91 a2 06 	lds	r22, 0x06A2	; 0x8006a2 <gc_state+0xb>
    6368:	70 91 a3 06 	lds	r23, 0x06A3	; 0x8006a3 <gc_state+0xc>
    636c:	80 91 a4 06 	lds	r24, 0x06A4	; 0x8006a4 <gc_state+0xd>
    6370:	90 91 a5 06 	lds	r25, 0x06A5	; 0x8006a5 <gc_state+0xe>
    6374:	40 e0       	ldi	r20, 0x00	; 0
    6376:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printFloat>
    637a:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    637e:	3d cf       	rjmp	.-390    	; 0x61fa <main+0x2a4>
    6380:	84 e3       	ldi	r24, 0x34	; 52
    6382:	c9 cf       	rjmp	.-110    	; 0x6316 <main+0x3c0>
    6384:	89 e3       	ldi	r24, 0x39	; 57
    6386:	d2 cf       	rjmp	.-92     	; 0x632c <main+0x3d6>
    6388:	10 91 31 06 	lds	r17, 0x0631	; 0x800631 <sys>
    638c:	12 30       	cpi	r17, 0x02	; 2
    638e:	59 f4       	brne	.+22     	; 0x63a6 <main+0x450>
    6390:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    6394:	8a ec       	ldi	r24, 0xCA	; 202
    6396:	92 e0       	ldi	r25, 0x02	; 2
    6398:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    639c:	81 e8       	ldi	r24, 0x81	; 129
    639e:	92 e0       	ldi	r25, 0x02	; 2
    63a0:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    63a4:	ea cf       	rjmp	.-44     	; 0x637a <main+0x424>
    63a6:	11 11       	cpse	r17, r1
    63a8:	21 c0       	rjmp	.+66     	; 0x63ec <main+0x496>
    63aa:	80 92 31 06 	sts	0x0631, r8	; 0x800631 <sys>
    63ae:	8a ec       	ldi	r24, 0xCA	; 202
    63b0:	92 e0       	ldi	r25, 0x02	; 2
    63b2:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    63b6:	8a e8       	ldi	r24, 0x8A	; 138
    63b8:	92 e0       	ldi	r25, 0x02	; 2
    63ba:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    63be:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    63c2:	2b cf       	rjmp	.-426    	; 0x621a <main+0x2c4>
    63c4:	82 35       	cpi	r24, 0x52	; 82
    63c6:	09 f4       	brne	.+2      	; 0x63ca <main+0x474>
    63c8:	f6 c0       	rjmp	.+492    	; 0x65b6 <main+0x660>
    63ca:	83 35       	cpi	r24, 0x53	; 83
    63cc:	09 f4       	brne	.+2      	; 0x63d0 <main+0x47a>
    63ce:	8e c0       	rjmp	.+284    	; 0x64ec <main+0x596>
    63d0:	8e 34       	cpi	r24, 0x4E	; 78
    63d2:	09 f0       	breq	.+2      	; 0x63d6 <main+0x480>
    63d4:	02 cf       	rjmp	.-508    	; 0x61da <main+0x284>
    63d6:	8d 8a       	std	Y+21, r8	; 0x15
    63d8:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    63dc:	10 e0       	ldi	r17, 0x00	; 0
    63de:	88 23       	and	r24, r24
    63e0:	09 f4       	brne	.+2      	; 0x63e4 <main+0x48e>
    63e2:	1a c1       	rjmp	.+564    	; 0x6618 <main+0x6c2>
    63e4:	11 e0       	ldi	r17, 0x01	; 1
    63e6:	99 23       	and	r25, r25
    63e8:	09 f4       	brne	.+2      	; 0x63ec <main+0x496>
    63ea:	f8 ce       	rjmp	.-528    	; 0x61dc <main+0x286>
    63ec:	18 e0       	ldi	r17, 0x08	; 8
    63ee:	15 cf       	rjmp	.-470    	; 0x621a <main+0x2c4>
    63f0:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    63f4:	81 11       	cpse	r24, r1
    63f6:	0c cf       	rjmp	.-488    	; 0x6210 <main+0x2ba>
    63f8:	00 e0       	ldi	r16, 0x00	; 0
    63fa:	be 01       	movw	r22, r28
    63fc:	6f 5f       	subi	r22, 0xFF	; 255
    63fe:	7f 4f       	sbci	r23, 0xFF	; 255
    6400:	80 2f       	mov	r24, r16
    6402:	0e 94 7b 1d 	call	0x3af6	; 0x3af6 <settings_read_coord_data>
    6406:	18 2f       	mov	r17, r24
    6408:	81 11       	cpse	r24, r1
    640a:	04 c0       	rjmp	.+8      	; 0x6414 <main+0x4be>
    640c:	87 e0       	ldi	r24, 0x07	; 7
    640e:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    6412:	03 cf       	rjmp	.-506    	; 0x621a <main+0x2c4>
    6414:	80 e0       	ldi	r24, 0x00	; 0
    6416:	91 e0       	ldi	r25, 0x01	; 1
    6418:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    641c:	06 30       	cpi	r16, 0x06	; 6
    641e:	39 f0       	breq	.+14     	; 0x642e <main+0x4d8>
    6420:	07 30       	cpi	r16, 0x07	; 7
    6422:	91 f1       	breq	.+100    	; 0x6488 <main+0x532>
    6424:	86 e3       	ldi	r24, 0x36	; 54
    6426:	80 0f       	add	r24, r16
    6428:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    642c:	04 c0       	rjmp	.+8      	; 0x6436 <main+0x4e0>
    642e:	8d ef       	ldi	r24, 0xFD	; 253
    6430:	90 e0       	ldi	r25, 0x00	; 0
    6432:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6436:	8a e3       	ldi	r24, 0x3A	; 58
    6438:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    643c:	ce 01       	movw	r24, r28
    643e:	01 96       	adiw	r24, 0x01	; 1
    6440:	0e 94 7c 07 	call	0xef8	; 0xef8 <report_util_axis_values>
    6444:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6448:	0f 5f       	subi	r16, 0xFF	; 255
    644a:	08 30       	cpi	r16, 0x08	; 8
    644c:	b1 f6       	brne	.-84     	; 0x63fa <main+0x4a4>
    644e:	84 ef       	ldi	r24, 0xF4	; 244
    6450:	90 e0       	ldi	r25, 0x00	; 0
    6452:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6456:	87 ec       	ldi	r24, 0xC7	; 199
    6458:	96 e0       	ldi	r25, 0x06	; 6
    645a:	0e 94 7c 07 	call	0xef8	; 0xef8 <report_util_axis_values>
    645e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6462:	8e ee       	ldi	r24, 0xEE	; 238
    6464:	90 e0       	ldi	r25, 0x00	; 0
    6466:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    646a:	60 91 d3 06 	lds	r22, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    646e:	70 91 d4 06 	lds	r23, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    6472:	80 91 d5 06 	lds	r24, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    6476:	90 91 d6 06 	lds	r25, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    647a:	0e 94 6e 07 	call	0xedc	; 0xedc <printFloat_CoordValue>
    647e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6482:	0e 94 25 09 	call	0x124a	; 0x124a <report_probe_parameters>
    6486:	b9 ce       	rjmp	.-654    	; 0x61fa <main+0x2a4>
    6488:	8a ef       	ldi	r24, 0xFA	; 250
    648a:	90 e0       	ldi	r25, 0x00	; 0
    648c:	d2 cf       	rjmp	.-92     	; 0x6432 <main+0x4dc>
    648e:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6492:	15 e0       	ldi	r17, 0x05	; 5
    6494:	84 ff       	sbrs	r24, 4
    6496:	c1 ce       	rjmp	.-638    	; 0x621a <main+0x2c4>
    6498:	84 e0       	ldi	r24, 0x04	; 4
    649a:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    649e:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    64a2:	81 11       	cpse	r24, r1
    64a4:	b5 ce       	rjmp	.-662    	; 0x6210 <main+0x2ba>
    64a6:	0e 94 fe 02 	call	0x5fc	; 0x5fc <limits_disable>
    64aa:	84 e0       	ldi	r24, 0x04	; 4
    64ac:	0e 94 0d 1b 	call	0x361a	; 0x361a <limits_go_home>
    64b0:	83 e0       	ldi	r24, 0x03	; 3
    64b2:	0e 94 0d 1b 	call	0x361a	; 0x361a <limits_go_home>
    64b6:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    64ba:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    64be:	81 11       	cpse	r24, r1
    64c0:	06 c0       	rjmp	.+12     	; 0x64ce <main+0x578>
    64c2:	0e 94 9c 09 	call	0x1338	; 0x1338 <gc_sync_position>
    64c6:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    64ca:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    64ce:	10 91 32 06 	lds	r17, 0x0632	; 0x800632 <sys+0x1>
    64d2:	11 11       	cpse	r17, r1
    64d4:	92 ce       	rjmp	.-732    	; 0x61fa <main+0x2a4>
    64d6:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    64da:	0e 94 9b 0d 	call	0x1b36	; 0x1b36 <st_go_idle>
    64de:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    64e2:	81 11       	cpse	r24, r1
    64e4:	8a ce       	rjmp	.-748    	; 0x61fa <main+0x2a4>
    64e6:	0e 94 fc 2b 	call	0x57f8	; 0x57f8 <system_execute_startup.constprop.2>
    64ea:	97 ce       	rjmp	.-722    	; 0x621a <main+0x2c4>
    64ec:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    64f0:	8c 34       	cpi	r24, 0x4C	; 76
    64f2:	09 f0       	breq	.+2      	; 0x64f6 <main+0x5a0>
    64f4:	8d ce       	rjmp	.-742    	; 0x6210 <main+0x2ba>
    64f6:	80 91 14 07 	lds	r24, 0x0714	; 0x800714 <line+0x3>
    64fa:	80 35       	cpi	r24, 0x50	; 80
    64fc:	09 f0       	breq	.+2      	; 0x6500 <main+0x5aa>
    64fe:	88 ce       	rjmp	.-752    	; 0x6210 <main+0x2ba>
    6500:	80 91 15 07 	lds	r24, 0x0715	; 0x800715 <line+0x4>
    6504:	81 11       	cpse	r24, r1
    6506:	84 ce       	rjmp	.-760    	; 0x6210 <main+0x2ba>
    6508:	80 e8       	ldi	r24, 0x80	; 128
    650a:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    650e:	75 ce       	rjmp	.-790    	; 0x61fa <main+0x2a4>
    6510:	8d 8a       	std	Y+21, r8	; 0x15
    6512:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6516:	81 11       	cpse	r24, r1
    6518:	30 c0       	rjmp	.+96     	; 0x657a <main+0x624>
    651a:	40 e5       	ldi	r20, 0x50	; 80
    651c:	50 e0       	ldi	r21, 0x00	; 0
    651e:	6e ea       	ldi	r22, 0xAE	; 174
    6520:	73 e0       	ldi	r23, 0x03	; 3
    6522:	81 e1       	ldi	r24, 0x11	; 17
    6524:	97 e0       	ldi	r25, 0x07	; 7
    6526:	0e 94 8e 04 	call	0x91c	; 0x91c <memcpy_from_eeprom_with_checksum>
    652a:	89 2b       	or	r24, r25
    652c:	51 f4       	brne	.+20     	; 0x6542 <main+0x5ec>
    652e:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    6532:	40 e5       	ldi	r20, 0x50	; 80
    6534:	50 e0       	ldi	r21, 0x00	; 0
    6536:	61 e1       	ldi	r22, 0x11	; 17
    6538:	77 e0       	ldi	r23, 0x07	; 7
    653a:	8e ea       	ldi	r24, 0xAE	; 174
    653c:	93 e0       	ldi	r25, 0x03	; 3
    653e:	0e 94 3e 04 	call	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>
    6542:	8a ed       	ldi	r24, 0xDA	; 218
    6544:	90 e0       	ldi	r25, 0x00	; 0
    6546:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    654a:	0e 94 a9 06 	call	0xd52	; 0xd52 <printString.constprop.9>
    654e:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    6552:	84 ed       	ldi	r24, 0xD4	; 212
    6554:	90 e0       	ldi	r25, 0x00	; 0
    6556:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    655a:	86 e5       	ldi	r24, 0x56	; 86
    655c:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    6560:	8c e2       	ldi	r24, 0x2C	; 44
    6562:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    6566:	8f e0       	ldi	r24, 0x0F	; 15
    6568:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    656c:	8c e2       	ldi	r24, 0x2C	; 44
    656e:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    6572:	80 e8       	ldi	r24, 0x80	; 128
    6574:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    6578:	00 cf       	rjmp	.-512    	; 0x637a <main+0x424>
    657a:	93 e0       	ldi	r25, 0x03	; 3
    657c:	9d 8b       	std	Y+21, r25	; 0x15
    657e:	8d 33       	cpi	r24, 0x3D	; 61
    6580:	09 f0       	breq	.+2      	; 0x6584 <main+0x62e>
    6582:	46 ce       	rjmp	.-884    	; 0x6210 <main+0x2ba>
    6584:	83 e0       	ldi	r24, 0x03	; 3
    6586:	28 2f       	mov	r18, r24
    6588:	30 e0       	ldi	r19, 0x00	; 0
    658a:	f9 01       	movw	r30, r18
    658c:	ef 5e       	subi	r30, 0xEF	; 239
    658e:	f8 4f       	sbci	r31, 0xF8	; 248
    6590:	90 81       	ld	r25, Z
    6592:	22 5f       	subi	r18, 0xF2	; 242
    6594:	38 4f       	sbci	r19, 0xF8	; 248
    6596:	d9 01       	movw	r26, r18
    6598:	9c 93       	st	X, r25
    659a:	8f 5f       	subi	r24, 0xFF	; 255
    659c:	90 81       	ld	r25, Z
    659e:	91 11       	cpse	r25, r1
    65a0:	f2 cf       	rjmp	.-28     	; 0x6586 <main+0x630>
    65a2:	8d 8b       	std	Y+21, r24	; 0x15
    65a4:	40 e5       	ldi	r20, 0x50	; 80
    65a6:	50 e0       	ldi	r21, 0x00	; 0
    65a8:	61 e1       	ldi	r22, 0x11	; 17
    65aa:	77 e0       	ldi	r23, 0x07	; 7
    65ac:	8e ea       	ldi	r24, 0xAE	; 174
    65ae:	93 e0       	ldi	r25, 0x03	; 3
    65b0:	0e 94 3e 04 	call	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>
    65b4:	22 ce       	rjmp	.-956    	; 0x61fa <main+0x2a4>
    65b6:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    65ba:	83 35       	cpi	r24, 0x53	; 83
    65bc:	09 f0       	breq	.+2      	; 0x65c0 <main+0x66a>
    65be:	28 ce       	rjmp	.-944    	; 0x6210 <main+0x2ba>
    65c0:	80 91 14 07 	lds	r24, 0x0714	; 0x800714 <line+0x3>
    65c4:	84 35       	cpi	r24, 0x54	; 84
    65c6:	09 f0       	breq	.+2      	; 0x65ca <main+0x674>
    65c8:	23 ce       	rjmp	.-954    	; 0x6210 <main+0x2ba>
    65ca:	80 91 15 07 	lds	r24, 0x0715	; 0x800715 <line+0x4>
    65ce:	8d 33       	cpi	r24, 0x3D	; 61
    65d0:	09 f0       	breq	.+2      	; 0x65d4 <main+0x67e>
    65d2:	1e ce       	rjmp	.-964    	; 0x6210 <main+0x2ba>
    65d4:	80 91 17 07 	lds	r24, 0x0717	; 0x800717 <line+0x6>
    65d8:	81 11       	cpse	r24, r1
    65da:	1a ce       	rjmp	.-972    	; 0x6210 <main+0x2ba>
    65dc:	80 91 16 07 	lds	r24, 0x0716	; 0x800716 <line+0x5>
    65e0:	84 32       	cpi	r24, 0x24	; 36
    65e2:	39 f0       	breq	.+14     	; 0x65f2 <main+0x69c>
    65e4:	8a 32       	cpi	r24, 0x2A	; 42
    65e6:	a9 f0       	breq	.+42     	; 0x6612 <main+0x6bc>
    65e8:	83 32       	cpi	r24, 0x23	; 35
    65ea:	09 f0       	breq	.+2      	; 0x65ee <main+0x698>
    65ec:	11 ce       	rjmp	.-990    	; 0x6210 <main+0x2ba>
    65ee:	82 e0       	ldi	r24, 0x02	; 2
    65f0:	01 c0       	rjmp	.+2      	; 0x65f4 <main+0x69e>
    65f2:	81 e0       	ldi	r24, 0x01	; 1
    65f4:	0e 94 9c 1d 	call	0x3b38	; 0x3b38 <settings_restore>
    65f8:	8a ec       	ldi	r24, 0xCA	; 202
    65fa:	92 e0       	ldi	r25, 0x02	; 2
    65fc:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6600:	8e e4       	ldi	r24, 0x4E	; 78
    6602:	92 e0       	ldi	r25, 0x02	; 2
    6604:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6608:	0e 94 20 09 	call	0x1240	; 0x1240 <report_util_feedback_line_feed>
    660c:	0e 94 02 0e 	call	0x1c04	; 0x1c04 <mc_reset>
    6610:	f4 cd       	rjmp	.-1048   	; 0x61fa <main+0x2a4>
    6612:	8f ef       	ldi	r24, 0xFF	; 255
    6614:	ef cf       	rjmp	.-34     	; 0x65f4 <main+0x69e>
    6616:	11 e0       	ldi	r17, 0x01	; 1
    6618:	81 2f       	mov	r24, r17
    661a:	0e 94 41 1d 	call	0x3a82	; 0x3a82 <settings_read_startup_line.constprop.7>
    661e:	81 11       	cpse	r24, r1
    6620:	06 c0       	rjmp	.+12     	; 0x662e <main+0x6d8>
    6622:	87 e0       	ldi	r24, 0x07	; 7
    6624:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    6628:	11 30       	cpi	r17, 0x01	; 1
    662a:	a9 f7       	brne	.-22     	; 0x6616 <main+0x6c0>
    662c:	e6 cd       	rjmp	.-1076   	; 0x61fa <main+0x2a4>
    662e:	81 ed       	ldi	r24, 0xD1	; 209
    6630:	90 e0       	ldi	r25, 0x00	; 0
    6632:	0e 94 ba 07 	call	0xf74	; 0xf74 <printPgmString>
    6636:	81 2f       	mov	r24, r17
    6638:	0e 94 95 07 	call	0xf2a	; 0xf2a <print_uint8_base10>
    663c:	8d e3       	ldi	r24, 0x3D	; 61
    663e:	0e 94 8d 06 	call	0xd1a	; 0xd1a <serial_write>
    6642:	0e 94 a9 06 	call	0xd52	; 0xd52 <printString.constprop.9>
    6646:	0e 94 c8 07 	call	0xf90	; 0xf90 <report_util_line_feed>
    664a:	ee cf       	rjmp	.-36     	; 0x6628 <main+0x6d2>
    664c:	ed 89       	ldd	r30, Y+21	; 0x15
    664e:	81 e0       	ldi	r24, 0x01	; 1
    6650:	8e 0f       	add	r24, r30
    6652:	8d 8b       	std	Y+21, r24	; 0x15
    6654:	f0 e0       	ldi	r31, 0x00	; 0
    6656:	ef 5e       	subi	r30, 0xEF	; 239
    6658:	f8 4f       	sbci	r31, 0xF8	; 248
    665a:	90 81       	ld	r25, Z
    665c:	9d 33       	cpi	r25, 0x3D	; 61
    665e:	09 f0       	breq	.+2      	; 0x6662 <main+0x70c>
    6660:	d7 cd       	rjmp	.-1106   	; 0x6210 <main+0x2ba>
    6662:	11 23       	and	r17, r17
    6664:	69 f1       	breq	.+90     	; 0x66c0 <main+0x76a>
    6666:	48 2f       	mov	r20, r24
    6668:	50 e0       	ldi	r21, 0x00	; 0
    666a:	28 2f       	mov	r18, r24
    666c:	30 e0       	ldi	r19, 0x00	; 0
    666e:	f9 01       	movw	r30, r18
    6670:	ef 5e       	subi	r30, 0xEF	; 239
    6672:	f8 4f       	sbci	r31, 0xF8	; 248
    6674:	90 81       	ld	r25, Z
    6676:	24 1b       	sub	r18, r20
    6678:	35 0b       	sbc	r19, r21
    667a:	d9 01       	movw	r26, r18
    667c:	af 5e       	subi	r26, 0xEF	; 239
    667e:	b8 4f       	sbci	r27, 0xF8	; 248
    6680:	9c 93       	st	X, r25
    6682:	8f 5f       	subi	r24, 0xFF	; 255
    6684:	90 81       	ld	r25, Z
    6686:	91 11       	cpse	r25, r1
    6688:	f0 cf       	rjmp	.-32     	; 0x666a <main+0x714>
    668a:	8d 8b       	std	Y+21, r24	; 0x15
    668c:	0e 94 77 1e 	call	0x3cee	; 0x3cee <gc_execute_line.constprop.11>
    6690:	18 2f       	mov	r17, r24
    6692:	81 11       	cpse	r24, r1
    6694:	c2 cd       	rjmp	.-1148   	; 0x621a <main+0x2c4>
    6696:	69 89       	ldd	r22, Y+17	; 0x11
    6698:	7a 89       	ldd	r23, Y+18	; 0x12
    669a:	8b 89       	ldd	r24, Y+19	; 0x13
    669c:	9c 89       	ldd	r25, Y+20	; 0x14
    669e:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    66a2:	f6 2e       	mov	r15, r22
    66a4:	0e 94 30 1d 	call	0x3a60	; 0x3a60 <protocol_buffer_synchronize>
    66a8:	b1 e5       	ldi	r27, 0x51	; 81
    66aa:	fb 9e       	mul	r15, r27
    66ac:	c0 01       	movw	r24, r0
    66ae:	11 24       	eor	r1, r1
    66b0:	40 e5       	ldi	r20, 0x50	; 80
    66b2:	50 e0       	ldi	r21, 0x00	; 0
    66b4:	61 e1       	ldi	r22, 0x11	; 17
    66b6:	77 e0       	ldi	r23, 0x07	; 7
    66b8:	9d 5f       	subi	r25, 0xFD	; 253
    66ba:	0e 94 3e 04 	call	0x87c	; 0x87c <memcpy_to_eeprom_with_checksum>
    66be:	ad cd       	rjmp	.-1190   	; 0x621a <main+0x2c4>
    66c0:	be 01       	movw	r22, r28
    66c2:	63 5f       	subi	r22, 0xF3	; 243
    66c4:	7f 4f       	sbci	r23, 0xFF	; 255
    66c6:	ce 01       	movw	r24, r28
    66c8:	45 96       	adiw	r24, 0x15	; 21
    66ca:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    66ce:	88 23       	and	r24, r24
    66d0:	09 f4       	brne	.+2      	; 0x66d4 <main+0x77e>
    66d2:	8d cd       	rjmp	.-1254   	; 0x61ee <main+0x298>
    66d4:	ed 89       	ldd	r30, Y+21	; 0x15
    66d6:	f0 e0       	ldi	r31, 0x00	; 0
    66d8:	ef 5e       	subi	r30, 0xEF	; 239
    66da:	f8 4f       	sbci	r31, 0xF8	; 248
    66dc:	80 81       	ld	r24, Z
    66de:	81 11       	cpse	r24, r1
    66e0:	97 cd       	rjmp	.-1234   	; 0x6210 <main+0x2ba>
    66e2:	c9 88       	ldd	r12, Y+17	; 0x11
    66e4:	da 88       	ldd	r13, Y+18	; 0x12
    66e6:	eb 88       	ldd	r14, Y+19	; 0x13
    66e8:	fc 88       	ldd	r15, Y+20	; 0x14
    66ea:	20 e0       	ldi	r18, 0x00	; 0
    66ec:	30 e0       	ldi	r19, 0x00	; 0
    66ee:	4f e7       	ldi	r20, 0x7F	; 127
    66f0:	53 e4       	ldi	r21, 0x43	; 67
    66f2:	c7 01       	movw	r24, r14
    66f4:	b6 01       	movw	r22, r12
    66f6:	0e 94 28 38 	call	0x7050	; 0x7050 <__gesf2>
    66fa:	18 16       	cp	r1, r24
    66fc:	0c f4       	brge	.+2      	; 0x6700 <main+0x7aa>
    66fe:	88 cd       	rjmp	.-1264   	; 0x6210 <main+0x2ba>
    6700:	4d 84       	ldd	r4, Y+13	; 0x0d
    6702:	5e 84       	ldd	r5, Y+14	; 0x0e
    6704:	6f 84       	ldd	r6, Y+15	; 0x0f
    6706:	78 88       	ldd	r7, Y+16	; 0x10
    6708:	c7 01       	movw	r24, r14
    670a:	b6 01       	movw	r22, r12
    670c:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    6710:	06 2f       	mov	r16, r22
    6712:	20 e0       	ldi	r18, 0x00	; 0
    6714:	30 e0       	ldi	r19, 0x00	; 0
    6716:	a9 01       	movw	r20, r18
    6718:	c3 01       	movw	r24, r6
    671a:	b2 01       	movw	r22, r4
    671c:	0e 94 06 36 	call	0x6c0c	; 0x6c0c <__cmpsf2>
    6720:	87 fd       	sbrc	r24, 7
    6722:	1f c1       	rjmp	.+574    	; 0x6962 <main+0xa0c>
    6724:	04 36       	cpi	r16, 0x64	; 100
    6726:	08 f4       	brcc	.+2      	; 0x672a <main+0x7d4>
    6728:	3f c0       	rjmp	.+126    	; 0x67a8 <main+0x852>
    672a:	04 56       	subi	r16, 0x64	; 100
    672c:	80 e0       	ldi	r24, 0x00	; 0
    672e:	03 30       	cpi	r16, 0x03	; 3
    6730:	90 f5       	brcc	.+100    	; 0x6796 <main+0x840>
    6732:	e0 2f       	mov	r30, r16
    6734:	f0 e0       	ldi	r31, 0x00	; 0
    6736:	ee 0f       	add	r30, r30
    6738:	ff 1f       	adc	r31, r31
    673a:	ee 0f       	add	r30, r30
    673c:	ff 1f       	adc	r31, r31
    673e:	82 30       	cpi	r24, 0x02	; 2
    6740:	81 f0       	breq	.+32     	; 0x6762 <main+0x80c>
    6742:	83 30       	cpi	r24, 0x03	; 3
    6744:	09 f1       	breq	.+66     	; 0x6788 <main+0x832>
    6746:	81 30       	cpi	r24, 0x01	; 1
    6748:	49 f0       	breq	.+18     	; 0x675c <main+0x806>
    674a:	ee 5b       	subi	r30, 0xBE	; 190
    674c:	f9 4f       	sbci	r31, 0xF9	; 249
    674e:	40 82       	st	Z, r4
    6750:	51 82       	std	Z+1, r5	; 0x01
    6752:	62 82       	std	Z+2, r6	; 0x02
    6754:	73 82       	std	Z+3, r7	; 0x03
    6756:	0e 94 79 04 	call	0x8f2	; 0x8f2 <write_global_settings>
    675a:	5f cd       	rjmp	.-1346   	; 0x621a <main+0x2c4>
    675c:	e2 5b       	subi	r30, 0xB2	; 178
    675e:	f9 4f       	sbci	r31, 0xF9	; 249
    6760:	f6 cf       	rjmp	.-20     	; 0x674e <main+0x7f8>
    6762:	cf 01       	movw	r24, r30
    6764:	86 5a       	subi	r24, 0xA6	; 166
    6766:	99 4f       	sbci	r25, 0xF9	; 249
    6768:	7c 01       	movw	r14, r24
    676a:	20 e0       	ldi	r18, 0x00	; 0
    676c:	30 e0       	ldi	r19, 0x00	; 0
    676e:	41 e6       	ldi	r20, 0x61	; 97
    6770:	55 e4       	ldi	r21, 0x45	; 69
    6772:	c3 01       	movw	r24, r6
    6774:	b2 01       	movw	r22, r4
    6776:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    677a:	d7 01       	movw	r26, r14
    677c:	6d 93       	st	X+, r22
    677e:	7d 93       	st	X+, r23
    6780:	8d 93       	st	X+, r24
    6782:	9c 93       	st	X, r25
    6784:	13 97       	sbiw	r26, 0x03	; 3
    6786:	e7 cf       	rjmp	.-50     	; 0x6756 <main+0x800>
    6788:	ea 59       	subi	r30, 0x9A	; 154
    678a:	f9 4f       	sbci	r31, 0xF9	; 249
    678c:	77 fa       	bst	r7, 7
    678e:	70 94       	com	r7
    6790:	77 f8       	bld	r7, 7
    6792:	70 94       	com	r7
    6794:	dc cf       	rjmp	.-72     	; 0x674e <main+0x7f8>
    6796:	8f 5f       	subi	r24, 0xFF	; 255
    6798:	0a 30       	cpi	r16, 0x0A	; 10
    679a:	08 f4       	brcc	.+2      	; 0x679e <main+0x848>
    679c:	39 cd       	rjmp	.-1422   	; 0x6210 <main+0x2ba>
    679e:	84 30       	cpi	r24, 0x04	; 4
    67a0:	09 f4       	brne	.+2      	; 0x67a4 <main+0x84e>
    67a2:	36 cd       	rjmp	.-1428   	; 0x6210 <main+0x2ba>
    67a4:	0a 50       	subi	r16, 0x0A	; 10
    67a6:	c3 cf       	rjmp	.-122    	; 0x672e <main+0x7d8>
    67a8:	c3 01       	movw	r24, r6
    67aa:	b2 01       	movw	r22, r4
    67ac:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    67b0:	01 32       	cpi	r16, 0x21	; 33
    67b2:	08 f0       	brcs	.+2      	; 0x67b6 <main+0x860>
    67b4:	2d cd       	rjmp	.-1446   	; 0x6210 <main+0x2ba>
    67b6:	e0 2f       	mov	r30, r16
    67b8:	f0 e0       	ldi	r31, 0x00	; 0
    67ba:	ef 51       	subi	r30, 0x1F	; 31
    67bc:	fc 4c       	sbci	r31, 0xCC	; 204
    67be:	0c 94 a8 39 	jmp	0x7350	; 0x7350 <__tablejump2__>
    67c2:	02 34       	cpi	r16, 0x42	; 66
    67c4:	08 34       	cpi	r16, 0x48	; 72
    67c6:	0b 34       	cpi	r16, 0x4B	; 75
    67c8:	10 34       	cpi	r17, 0x40	; 64
    67ca:	13 34       	cpi	r17, 0x43	; 67
    67cc:	1d 34       	cpi	r17, 0x4D	; 77
    67ce:	25 34       	cpi	r18, 0x45	; 69
    67d0:	08 31       	cpi	r16, 0x18	; 24
    67d2:	08 31       	cpi	r16, 0x18	; 24
    67d4:	08 31       	cpi	r16, 0x18	; 24
    67d6:	32 34       	cpi	r19, 0x42	; 66
    67d8:	35 34       	cpi	r19, 0x45	; 69
    67da:	3e 34       	cpi	r19, 0x4E	; 78
    67dc:	47 34       	cpi	r20, 0x47	; 71
    67de:	08 31       	cpi	r16, 0x18	; 24
    67e0:	08 31       	cpi	r16, 0x18	; 24
    67e2:	08 31       	cpi	r16, 0x18	; 24
    67e4:	08 31       	cpi	r16, 0x18	; 24
    67e6:	08 31       	cpi	r16, 0x18	; 24
    67e8:	08 31       	cpi	r16, 0x18	; 24
    67ea:	53 34       	cpi	r21, 0x43	; 67
    67ec:	5d 34       	cpi	r21, 0x4D	; 77
    67ee:	69 34       	cpi	r22, 0x49	; 73
    67f0:	71 34       	cpi	r23, 0x41	; 65
    67f2:	74 34       	cpi	r23, 0x44	; 68
    67f4:	7d 34       	cpi	r23, 0x4D	; 77
    67f6:	86 34       	cpi	r24, 0x46	; 70
    67f8:	8c 34       	cpi	r24, 0x4C	; 76
    67fa:	08 31       	cpi	r16, 0x18	; 24
    67fc:	08 31       	cpi	r16, 0x18	; 24
    67fe:	95 34       	cpi	r25, 0x45	; 69
    6800:	a0 34       	cpi	r26, 0x40	; 64
    6802:	a9 34       	cpi	r26, 0x49	; 73
    6804:	63 30       	cpi	r22, 0x03	; 3
    6806:	08 f4       	brcc	.+2      	; 0x680a <main+0x8b4>
    6808:	ae c0       	rjmp	.+348    	; 0x6966 <main+0xa10>
    680a:	60 93 72 06 	sts	0x0672, r22	; 0x800672 <settings+0x30>
    680e:	a3 cf       	rjmp	.-186    	; 0x6756 <main+0x800>
    6810:	60 93 75 06 	sts	0x0675, r22	; 0x800675 <settings+0x33>
    6814:	a0 cf       	rjmp	.-192    	; 0x6756 <main+0x800>
    6816:	60 93 73 06 	sts	0x0673, r22	; 0x800673 <settings+0x31>
    681a:	0e 94 4f 06 	call	0xc9e	; 0xc9e <st_generate_step_dir_invert_masks>
    681e:	9b cf       	rjmp	.-202    	; 0x6756 <main+0x800>
    6820:	60 93 74 06 	sts	0x0674, r22	; 0x800674 <settings+0x32>
    6824:	fa cf       	rjmp	.-12     	; 0x681a <main+0x8c4>
    6826:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    682a:	66 23       	and	r22, r22
    682c:	21 f0       	breq	.+8      	; 0x6836 <main+0x8e0>
    682e:	84 60       	ori	r24, 0x04	; 4
    6830:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    6834:	90 cf       	rjmp	.-224    	; 0x6756 <main+0x800>
    6836:	8b 7f       	andi	r24, 0xFB	; 251
    6838:	fb cf       	rjmp	.-10     	; 0x6830 <main+0x8da>
    683a:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    683e:	66 23       	and	r22, r22
    6840:	11 f0       	breq	.+4      	; 0x6846 <main+0x8f0>
    6842:	80 64       	ori	r24, 0x40	; 64
    6844:	f5 cf       	rjmp	.-22     	; 0x6830 <main+0x8da>
    6846:	8f 7b       	andi	r24, 0xBF	; 191
    6848:	f3 cf       	rjmp	.-26     	; 0x6830 <main+0x8da>
    684a:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    684e:	66 23       	and	r22, r22
    6850:	39 f0       	breq	.+14     	; 0x6860 <main+0x90a>
    6852:	80 68       	ori	r24, 0x80	; 128
    6854:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    6858:	80 e0       	ldi	r24, 0x00	; 0
    685a:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    685e:	7b cf       	rjmp	.-266    	; 0x6756 <main+0x800>
    6860:	8f 77       	andi	r24, 0x7F	; 127
    6862:	f8 cf       	rjmp	.-16     	; 0x6854 <main+0x8fe>
    6864:	60 93 76 06 	sts	0x0676, r22	; 0x800676 <settings+0x34>
    6868:	76 cf       	rjmp	.-276    	; 0x6756 <main+0x800>
    686a:	40 92 77 06 	sts	0x0677, r4	; 0x800677 <settings+0x35>
    686e:	50 92 78 06 	sts	0x0678, r5	; 0x800678 <settings+0x36>
    6872:	60 92 79 06 	sts	0x0679, r6	; 0x800679 <settings+0x37>
    6876:	70 92 7a 06 	sts	0x067A, r7	; 0x80067a <settings+0x38>
    687a:	6d cf       	rjmp	.-294    	; 0x6756 <main+0x800>
    687c:	40 92 7b 06 	sts	0x067B, r4	; 0x80067b <settings+0x39>
    6880:	50 92 7c 06 	sts	0x067C, r5	; 0x80067c <settings+0x3a>
    6884:	60 92 7d 06 	sts	0x067D, r6	; 0x80067d <settings+0x3b>
    6888:	70 92 7e 06 	sts	0x067E, r7	; 0x80067e <settings+0x3c>
    688c:	64 cf       	rjmp	.-312    	; 0x6756 <main+0x800>
    688e:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6892:	66 23       	and	r22, r22
    6894:	31 f0       	breq	.+12     	; 0x68a2 <main+0x94c>
    6896:	81 60       	ori	r24, 0x01	; 1
    6898:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    689c:	0e 94 62 1d 	call	0x3ac4	; 0x3ac4 <system_flag_wco_change>
    68a0:	5a cf       	rjmp	.-332    	; 0x6756 <main+0x800>
    68a2:	8e 7f       	andi	r24, 0xFE	; 254
    68a4:	f9 cf       	rjmp	.-14     	; 0x6898 <main+0x942>
    68a6:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68aa:	66 23       	and	r22, r22
    68ac:	21 f0       	breq	.+8      	; 0x68b6 <main+0x960>
    68ae:	84 ff       	sbrs	r24, 4
    68b0:	5c c0       	rjmp	.+184    	; 0x696a <main+0xa14>
    68b2:	80 62       	ori	r24, 0x20	; 32
    68b4:	bd cf       	rjmp	.-134    	; 0x6830 <main+0x8da>
    68b6:	8f 7d       	andi	r24, 0xDF	; 223
    68b8:	bb cf       	rjmp	.-138    	; 0x6830 <main+0x8da>
    68ba:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68be:	66 23       	and	r22, r22
    68c0:	31 f0       	breq	.+12     	; 0x68ce <main+0x978>
    68c2:	88 60       	ori	r24, 0x08	; 8
    68c4:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    68c8:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    68cc:	44 cf       	rjmp	.-376    	; 0x6756 <main+0x800>
    68ce:	87 7f       	andi	r24, 0xF7	; 247
    68d0:	f9 cf       	rjmp	.-14     	; 0x68c4 <main+0x96e>
    68d2:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68d6:	66 23       	and	r22, r22
    68d8:	11 f0       	breq	.+4      	; 0x68de <main+0x988>
    68da:	80 61       	ori	r24, 0x10	; 16
    68dc:	a9 cf       	rjmp	.-174    	; 0x6830 <main+0x8da>
    68de:	8f 7c       	andi	r24, 0xCF	; 207
    68e0:	a7 cf       	rjmp	.-178    	; 0x6830 <main+0x8da>
    68e2:	60 93 88 06 	sts	0x0688, r22	; 0x800688 <settings+0x46>
    68e6:	37 cf       	rjmp	.-402    	; 0x6756 <main+0x800>
    68e8:	40 92 89 06 	sts	0x0689, r4	; 0x800689 <settings+0x47>
    68ec:	50 92 8a 06 	sts	0x068A, r5	; 0x80068a <settings+0x48>
    68f0:	60 92 8b 06 	sts	0x068B, r6	; 0x80068b <settings+0x49>
    68f4:	70 92 8c 06 	sts	0x068C, r7	; 0x80068c <settings+0x4a>
    68f8:	2e cf       	rjmp	.-420    	; 0x6756 <main+0x800>
    68fa:	40 92 8d 06 	sts	0x068D, r4	; 0x80068d <settings+0x4b>
    68fe:	50 92 8e 06 	sts	0x068E, r5	; 0x80068e <settings+0x4c>
    6902:	60 92 8f 06 	sts	0x068F, r6	; 0x80068f <settings+0x4d>
    6906:	70 92 90 06 	sts	0x0690, r7	; 0x800690 <settings+0x4e>
    690a:	25 cf       	rjmp	.-438    	; 0x6756 <main+0x800>
    690c:	70 e0       	ldi	r23, 0x00	; 0
    690e:	70 93 92 06 	sts	0x0692, r23	; 0x800692 <settings+0x50>
    6912:	60 93 91 06 	sts	0x0691, r22	; 0x800691 <settings+0x4f>
    6916:	1f cf       	rjmp	.-450    	; 0x6756 <main+0x800>
    6918:	40 92 93 06 	sts	0x0693, r4	; 0x800693 <settings+0x51>
    691c:	50 92 94 06 	sts	0x0694, r5	; 0x800694 <settings+0x52>
    6920:	60 92 95 06 	sts	0x0695, r6	; 0x800695 <settings+0x53>
    6924:	70 92 96 06 	sts	0x0696, r7	; 0x800696 <settings+0x54>
    6928:	16 cf       	rjmp	.-468    	; 0x6756 <main+0x800>
    692a:	40 92 7f 06 	sts	0x067F, r4	; 0x80067f <settings+0x3d>
    692e:	50 92 80 06 	sts	0x0680, r5	; 0x800680 <settings+0x3e>
    6932:	60 92 81 06 	sts	0x0681, r6	; 0x800681 <settings+0x3f>
    6936:	70 92 82 06 	sts	0x0682, r7	; 0x800682 <settings+0x40>
    693a:	0e 94 69 09 	call	0x12d2	; 0x12d2 <spindle_init>
    693e:	0b cf       	rjmp	.-490    	; 0x6756 <main+0x800>
    6940:	40 92 83 06 	sts	0x0683, r4	; 0x800683 <settings+0x41>
    6944:	50 92 84 06 	sts	0x0684, r5	; 0x800684 <settings+0x42>
    6948:	60 92 85 06 	sts	0x0685, r6	; 0x800685 <settings+0x43>
    694c:	70 92 86 06 	sts	0x0686, r7	; 0x800686 <settings+0x44>
    6950:	f4 cf       	rjmp	.-24     	; 0x693a <main+0x9e4>
    6952:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6956:	66 23       	and	r22, r22
    6958:	11 f0       	breq	.+4      	; 0x695e <main+0xa08>
    695a:	82 60       	ori	r24, 0x02	; 2
    695c:	69 cf       	rjmp	.-302    	; 0x6830 <main+0x8da>
    695e:	8d 7f       	andi	r24, 0xFD	; 253
    6960:	67 cf       	rjmp	.-306    	; 0x6830 <main+0x8da>
    6962:	14 e0       	ldi	r17, 0x04	; 4
    6964:	5a cc       	rjmp	.-1868   	; 0x621a <main+0x2c4>
    6966:	16 e0       	ldi	r17, 0x06	; 6
    6968:	58 cc       	rjmp	.-1872   	; 0x621a <main+0x2c4>
    696a:	1a e0       	ldi	r17, 0x0A	; 10
    696c:	56 cc       	rjmp	.-1876   	; 0x621a <main+0x2c4>
    696e:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    6972:	81 72       	andi	r24, 0x21	; 33
    6974:	31 f0       	breq	.+12     	; 0x6982 <main+0xa2c>
    6976:	89 e0       	ldi	r24, 0x09	; 9
    6978:	0e 94 cc 07 	call	0xf98	; 0xf98 <report_status_message.part.0>
    697c:	10 e0       	ldi	r17, 0x00	; 0
    697e:	00 e0       	ldi	r16, 0x00	; 0
    6980:	d6 cb       	rjmp	.-2132   	; 0x612e <main+0x1d8>
    6982:	0e 94 77 1e 	call	0x3cee	; 0x3cee <gc_execute_line.constprop.11>
    6986:	49 c0       	rjmp	.+146    	; 0x6a1a <main+0xac4>
    6988:	00 23       	and	r16, r16
    698a:	29 f0       	breq	.+10     	; 0x6996 <main+0xa40>
    698c:	89 32       	cpi	r24, 0x29	; 41
    698e:	09 f0       	breq	.+2      	; 0x6992 <main+0xa3c>
    6990:	ce cb       	rjmp	.-2148   	; 0x612e <main+0x1d8>
    6992:	0d 7f       	andi	r16, 0xFD	; 253
    6994:	cc cb       	rjmp	.-2152   	; 0x612e <main+0x1d8>
    6996:	81 32       	cpi	r24, 0x21	; 33
    6998:	08 f4       	brcc	.+2      	; 0x699c <main+0xa46>
    699a:	c9 cb       	rjmp	.-2158   	; 0x612e <main+0x1d8>
    699c:	8f 32       	cpi	r24, 0x2F	; 47
    699e:	09 f4       	brne	.+2      	; 0x69a2 <main+0xa4c>
    69a0:	c6 cb       	rjmp	.-2164   	; 0x612e <main+0x1d8>
    69a2:	88 32       	cpi	r24, 0x28	; 40
    69a4:	81 f0       	breq	.+32     	; 0x69c6 <main+0xa70>
    69a6:	8b 33       	cpi	r24, 0x3B	; 59
    69a8:	81 f0       	breq	.+32     	; 0x69ca <main+0xa74>
    69aa:	1f 34       	cpi	r17, 0x4F	; 79
    69ac:	80 f4       	brcc	.+32     	; 0x69ce <main+0xa78>
    69ae:	e1 2f       	mov	r30, r17
    69b0:	f0 e0       	ldi	r31, 0x00	; 0
    69b2:	ef 5e       	subi	r30, 0xEF	; 239
    69b4:	f8 4f       	sbci	r31, 0xF8	; 248
    69b6:	1f 5f       	subi	r17, 0xFF	; 255
    69b8:	9f e9       	ldi	r25, 0x9F	; 159
    69ba:	98 0f       	add	r25, r24
    69bc:	9a 31       	cpi	r25, 0x1A	; 26
    69be:	08 f4       	brcc	.+2      	; 0x69c2 <main+0xa6c>
    69c0:	80 52       	subi	r24, 0x20	; 32
    69c2:	80 83       	st	Z, r24
    69c4:	b4 cb       	rjmp	.-2200   	; 0x612e <main+0x1d8>
    69c6:	02 e0       	ldi	r16, 0x02	; 2
    69c8:	b2 cb       	rjmp	.-2204   	; 0x612e <main+0x1d8>
    69ca:	04 e0       	ldi	r16, 0x04	; 4
    69cc:	b0 cb       	rjmp	.-2208   	; 0x612e <main+0x1d8>
    69ce:	01 e0       	ldi	r16, 0x01	; 1
    69d0:	ae cb       	rjmp	.-2212   	; 0x612e <main+0x1d8>
    69d2:	e9 2f       	mov	r30, r25
    69d4:	f0 e0       	ldi	r31, 0x00	; 0
    69d6:	e1 59       	subi	r30, 0x91	; 145
    69d8:	fe 4f       	sbci	r31, 0xFE	; 254
    69da:	80 81       	ld	r24, Z
    69dc:	9f 5f       	subi	r25, 0xFF	; 255
    69de:	91 38       	cpi	r25, 0x81	; 129
    69e0:	09 f4       	brne	.+2      	; 0x69e4 <main+0xa8e>
    69e2:	90 e0       	ldi	r25, 0x00	; 0
    69e4:	90 93 f1 01 	sts	0x01F1, r25	; 0x8001f1 <serial_rx_buffer_tail>
    69e8:	8f 3f       	cpi	r24, 0xFF	; 255
    69ea:	09 f4       	brne	.+2      	; 0x69ee <main+0xa98>
    69ec:	a6 cb       	rjmp	.-2228   	; 0x613a <main+0x1e4>
    69ee:	8a 30       	cpi	r24, 0x0A	; 10
    69f0:	11 f0       	breq	.+4      	; 0x69f6 <main+0xaa0>
    69f2:	8d 30       	cpi	r24, 0x0D	; 13
    69f4:	49 f6       	brne	.-110    	; 0x6988 <main+0xa32>
    69f6:	0e 94 f8 19 	call	0x33f0	; 0x33f0 <protocol_execute_realtime>
    69fa:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    69fe:	81 11       	cpse	r24, r1
    6a00:	24 cb       	rjmp	.-2488   	; 0x604a <main+0xf4>
    6a02:	e1 2f       	mov	r30, r17
    6a04:	f0 e0       	ldi	r31, 0x00	; 0
    6a06:	ef 5e       	subi	r30, 0xEF	; 239
    6a08:	f8 4f       	sbci	r31, 0xF8	; 248
    6a0a:	10 82       	st	Z, r1
    6a0c:	8b e0       	ldi	r24, 0x0B	; 11
    6a0e:	00 fd       	sbrc	r16, 0
    6a10:	b3 cf       	rjmp	.-154    	; 0x6978 <main+0xa22>
    6a12:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    6a16:	81 11       	cpse	r24, r1
    6a18:	aa cb       	rjmp	.-2220   	; 0x616e <main+0x218>
    6a1a:	0e 94 d8 07 	call	0xfb0	; 0xfb0 <report_status_message>
    6a1e:	ae cf       	rjmp	.-164    	; 0x697c <main+0xa26>

00006a20 <__subsf3>:
    6a20:	50 58       	subi	r21, 0x80	; 128

00006a22 <__addsf3>:
    6a22:	bb 27       	eor	r27, r27
    6a24:	aa 27       	eor	r26, r26
    6a26:	0e 94 28 35 	call	0x6a50	; 0x6a50 <__addsf3x>
    6a2a:	0c 94 c2 37 	jmp	0x6f84	; 0x6f84 <__fp_round>
    6a2e:	0e 94 89 37 	call	0x6f12	; 0x6f12 <__fp_pscA>
    6a32:	38 f0       	brcs	.+14     	; 0x6a42 <__addsf3+0x20>
    6a34:	0e 94 90 37 	call	0x6f20	; 0x6f20 <__fp_pscB>
    6a38:	20 f0       	brcs	.+8      	; 0x6a42 <__addsf3+0x20>
    6a3a:	39 f4       	brne	.+14     	; 0x6a4a <__addsf3+0x28>
    6a3c:	9f 3f       	cpi	r25, 0xFF	; 255
    6a3e:	19 f4       	brne	.+6      	; 0x6a46 <__addsf3+0x24>
    6a40:	26 f4       	brtc	.+8      	; 0x6a4a <__addsf3+0x28>
    6a42:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>
    6a46:	0e f4       	brtc	.+2      	; 0x6a4a <__addsf3+0x28>
    6a48:	e0 95       	com	r30
    6a4a:	e7 fb       	bst	r30, 7
    6a4c:	0c 94 30 37 	jmp	0x6e60	; 0x6e60 <__fp_inf>

00006a50 <__addsf3x>:
    6a50:	e9 2f       	mov	r30, r25
    6a52:	0e 94 e7 37 	call	0x6fce	; 0x6fce <__fp_split3>
    6a56:	58 f3       	brcs	.-42     	; 0x6a2e <__addsf3+0xc>
    6a58:	ba 17       	cp	r27, r26
    6a5a:	62 07       	cpc	r22, r18
    6a5c:	73 07       	cpc	r23, r19
    6a5e:	84 07       	cpc	r24, r20
    6a60:	95 07       	cpc	r25, r21
    6a62:	20 f0       	brcs	.+8      	; 0x6a6c <__addsf3x+0x1c>
    6a64:	79 f4       	brne	.+30     	; 0x6a84 <__addsf3x+0x34>
    6a66:	a6 f5       	brtc	.+104    	; 0x6ad0 <__addsf3x+0x80>
    6a68:	0c 94 21 38 	jmp	0x7042	; 0x7042 <__fp_zero>
    6a6c:	0e f4       	brtc	.+2      	; 0x6a70 <__addsf3x+0x20>
    6a6e:	e0 95       	com	r30
    6a70:	0b 2e       	mov	r0, r27
    6a72:	ba 2f       	mov	r27, r26
    6a74:	a0 2d       	mov	r26, r0
    6a76:	0b 01       	movw	r0, r22
    6a78:	b9 01       	movw	r22, r18
    6a7a:	90 01       	movw	r18, r0
    6a7c:	0c 01       	movw	r0, r24
    6a7e:	ca 01       	movw	r24, r20
    6a80:	a0 01       	movw	r20, r0
    6a82:	11 24       	eor	r1, r1
    6a84:	ff 27       	eor	r31, r31
    6a86:	59 1b       	sub	r21, r25
    6a88:	99 f0       	breq	.+38     	; 0x6ab0 <__addsf3x+0x60>
    6a8a:	59 3f       	cpi	r21, 0xF9	; 249
    6a8c:	50 f4       	brcc	.+20     	; 0x6aa2 <__addsf3x+0x52>
    6a8e:	50 3e       	cpi	r21, 0xE0	; 224
    6a90:	68 f1       	brcs	.+90     	; 0x6aec <__addsf3x+0x9c>
    6a92:	1a 16       	cp	r1, r26
    6a94:	f0 40       	sbci	r31, 0x00	; 0
    6a96:	a2 2f       	mov	r26, r18
    6a98:	23 2f       	mov	r18, r19
    6a9a:	34 2f       	mov	r19, r20
    6a9c:	44 27       	eor	r20, r20
    6a9e:	58 5f       	subi	r21, 0xF8	; 248
    6aa0:	f3 cf       	rjmp	.-26     	; 0x6a88 <__addsf3x+0x38>
    6aa2:	46 95       	lsr	r20
    6aa4:	37 95       	ror	r19
    6aa6:	27 95       	ror	r18
    6aa8:	a7 95       	ror	r26
    6aaa:	f0 40       	sbci	r31, 0x00	; 0
    6aac:	53 95       	inc	r21
    6aae:	c9 f7       	brne	.-14     	; 0x6aa2 <__addsf3x+0x52>
    6ab0:	7e f4       	brtc	.+30     	; 0x6ad0 <__addsf3x+0x80>
    6ab2:	1f 16       	cp	r1, r31
    6ab4:	ba 0b       	sbc	r27, r26
    6ab6:	62 0b       	sbc	r22, r18
    6ab8:	73 0b       	sbc	r23, r19
    6aba:	84 0b       	sbc	r24, r20
    6abc:	ba f0       	brmi	.+46     	; 0x6aec <__addsf3x+0x9c>
    6abe:	91 50       	subi	r25, 0x01	; 1
    6ac0:	a1 f0       	breq	.+40     	; 0x6aea <__addsf3x+0x9a>
    6ac2:	ff 0f       	add	r31, r31
    6ac4:	bb 1f       	adc	r27, r27
    6ac6:	66 1f       	adc	r22, r22
    6ac8:	77 1f       	adc	r23, r23
    6aca:	88 1f       	adc	r24, r24
    6acc:	c2 f7       	brpl	.-16     	; 0x6abe <__addsf3x+0x6e>
    6ace:	0e c0       	rjmp	.+28     	; 0x6aec <__addsf3x+0x9c>
    6ad0:	ba 0f       	add	r27, r26
    6ad2:	62 1f       	adc	r22, r18
    6ad4:	73 1f       	adc	r23, r19
    6ad6:	84 1f       	adc	r24, r20
    6ad8:	48 f4       	brcc	.+18     	; 0x6aec <__addsf3x+0x9c>
    6ada:	87 95       	ror	r24
    6adc:	77 95       	ror	r23
    6ade:	67 95       	ror	r22
    6ae0:	b7 95       	ror	r27
    6ae2:	f7 95       	ror	r31
    6ae4:	9e 3f       	cpi	r25, 0xFE	; 254
    6ae6:	08 f0       	brcs	.+2      	; 0x6aea <__addsf3x+0x9a>
    6ae8:	b0 cf       	rjmp	.-160    	; 0x6a4a <__addsf3+0x28>
    6aea:	93 95       	inc	r25
    6aec:	88 0f       	add	r24, r24
    6aee:	08 f0       	brcs	.+2      	; 0x6af2 <__addsf3x+0xa2>
    6af0:	99 27       	eor	r25, r25
    6af2:	ee 0f       	add	r30, r30
    6af4:	97 95       	ror	r25
    6af6:	87 95       	ror	r24
    6af8:	08 95       	ret
    6afa:	0e 94 89 37 	call	0x6f12	; 0x6f12 <__fp_pscA>
    6afe:	60 f0       	brcs	.+24     	; 0x6b18 <__addsf3x+0xc8>
    6b00:	80 e8       	ldi	r24, 0x80	; 128
    6b02:	91 e0       	ldi	r25, 0x01	; 1
    6b04:	09 f4       	brne	.+2      	; 0x6b08 <__addsf3x+0xb8>
    6b06:	9e ef       	ldi	r25, 0xFE	; 254
    6b08:	0e 94 90 37 	call	0x6f20	; 0x6f20 <__fp_pscB>
    6b0c:	28 f0       	brcs	.+10     	; 0x6b18 <__addsf3x+0xc8>
    6b0e:	40 e8       	ldi	r20, 0x80	; 128
    6b10:	51 e0       	ldi	r21, 0x01	; 1
    6b12:	71 f4       	brne	.+28     	; 0x6b30 <atan2+0x10>
    6b14:	5e ef       	ldi	r21, 0xFE	; 254
    6b16:	0c c0       	rjmp	.+24     	; 0x6b30 <atan2+0x10>
    6b18:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>
    6b1c:	0c 94 21 38 	jmp	0x7042	; 0x7042 <__fp_zero>

00006b20 <atan2>:
    6b20:	e9 2f       	mov	r30, r25
    6b22:	e0 78       	andi	r30, 0x80	; 128
    6b24:	0e 94 e7 37 	call	0x6fce	; 0x6fce <__fp_split3>
    6b28:	40 f3       	brcs	.-48     	; 0x6afa <__addsf3x+0xaa>
    6b2a:	09 2e       	mov	r0, r25
    6b2c:	05 2a       	or	r0, r21
    6b2e:	b1 f3       	breq	.-20     	; 0x6b1c <__addsf3x+0xcc>
    6b30:	26 17       	cp	r18, r22
    6b32:	37 07       	cpc	r19, r23
    6b34:	48 07       	cpc	r20, r24
    6b36:	59 07       	cpc	r21, r25
    6b38:	38 f0       	brcs	.+14     	; 0x6b48 <atan2+0x28>
    6b3a:	0e 2e       	mov	r0, r30
    6b3c:	07 f8       	bld	r0, 7
    6b3e:	e0 25       	eor	r30, r0
    6b40:	69 f0       	breq	.+26     	; 0x6b5c <atan2+0x3c>
    6b42:	e0 25       	eor	r30, r0
    6b44:	e0 64       	ori	r30, 0x40	; 64
    6b46:	0a c0       	rjmp	.+20     	; 0x6b5c <atan2+0x3c>
    6b48:	ef 63       	ori	r30, 0x3F	; 63
    6b4a:	07 f8       	bld	r0, 7
    6b4c:	00 94       	com	r0
    6b4e:	07 fa       	bst	r0, 7
    6b50:	db 01       	movw	r26, r22
    6b52:	b9 01       	movw	r22, r18
    6b54:	9d 01       	movw	r18, r26
    6b56:	dc 01       	movw	r26, r24
    6b58:	ca 01       	movw	r24, r20
    6b5a:	ad 01       	movw	r20, r26
    6b5c:	ef 93       	push	r30
    6b5e:	0e 94 27 36 	call	0x6c4e	; 0x6c4e <__divsf3_pse>
    6b62:	0e 94 c2 37 	call	0x6f84	; 0x6f84 <__fp_round>
    6b66:	0e 94 c0 35 	call	0x6b80	; 0x6b80 <atan>
    6b6a:	5f 91       	pop	r21
    6b6c:	55 23       	and	r21, r21
    6b6e:	39 f0       	breq	.+14     	; 0x6b7e <atan2+0x5e>
    6b70:	2b ed       	ldi	r18, 0xDB	; 219
    6b72:	3f e0       	ldi	r19, 0x0F	; 15
    6b74:	49 e4       	ldi	r20, 0x49	; 73
    6b76:	50 fd       	sbrc	r21, 0
    6b78:	49 ec       	ldi	r20, 0xC9	; 201
    6b7a:	0c 94 11 35 	jmp	0x6a22	; 0x6a22 <__addsf3>
    6b7e:	08 95       	ret

00006b80 <atan>:
    6b80:	df 93       	push	r29
    6b82:	dd 27       	eor	r29, r29
    6b84:	b9 2f       	mov	r27, r25
    6b86:	bf 77       	andi	r27, 0x7F	; 127
    6b88:	40 e8       	ldi	r20, 0x80	; 128
    6b8a:	5f e3       	ldi	r21, 0x3F	; 63
    6b8c:	16 16       	cp	r1, r22
    6b8e:	17 06       	cpc	r1, r23
    6b90:	48 07       	cpc	r20, r24
    6b92:	5b 07       	cpc	r21, r27
    6b94:	18 f4       	brcc	.+6      	; 0x6b9c <atan+0x1c>
    6b96:	d9 2f       	mov	r29, r25
    6b98:	0e 94 2d 38 	call	0x705a	; 0x705a <inverse>
    6b9c:	9f 93       	push	r25
    6b9e:	8f 93       	push	r24
    6ba0:	7f 93       	push	r23
    6ba2:	6f 93       	push	r22
    6ba4:	0e 94 47 39 	call	0x728e	; 0x728e <square>
    6ba8:	e8 e6       	ldi	r30, 0x68	; 104
    6baa:	f0 e0       	ldi	r31, 0x00	; 0
    6bac:	0e 94 62 37 	call	0x6ec4	; 0x6ec4 <__fp_powser>
    6bb0:	0e 94 c2 37 	call	0x6f84	; 0x6f84 <__fp_round>
    6bb4:	2f 91       	pop	r18
    6bb6:	3f 91       	pop	r19
    6bb8:	4f 91       	pop	r20
    6bba:	5f 91       	pop	r21
    6bbc:	0e 94 7b 38 	call	0x70f6	; 0x70f6 <__mulsf3x>
    6bc0:	dd 23       	and	r29, r29
    6bc2:	51 f0       	breq	.+20     	; 0x6bd8 <atan+0x58>
    6bc4:	90 58       	subi	r25, 0x80	; 128
    6bc6:	a2 ea       	ldi	r26, 0xA2	; 162
    6bc8:	2a ed       	ldi	r18, 0xDA	; 218
    6bca:	3f e0       	ldi	r19, 0x0F	; 15
    6bcc:	49 ec       	ldi	r20, 0xC9	; 201
    6bce:	5f e3       	ldi	r21, 0x3F	; 63
    6bd0:	d0 78       	andi	r29, 0x80	; 128
    6bd2:	5d 27       	eor	r21, r29
    6bd4:	0e 94 28 35 	call	0x6a50	; 0x6a50 <__addsf3x>
    6bd8:	df 91       	pop	r29
    6bda:	0c 94 c2 37 	jmp	0x6f84	; 0x6f84 <__fp_round>

00006bde <ceil>:
    6bde:	0e 94 09 38 	call	0x7012	; 0x7012 <__fp_trunc>
    6be2:	90 f0       	brcs	.+36     	; 0x6c08 <ceil+0x2a>
    6be4:	9f 37       	cpi	r25, 0x7F	; 127
    6be6:	48 f4       	brcc	.+18     	; 0x6bfa <ceil+0x1c>
    6be8:	91 11       	cpse	r25, r1
    6bea:	16 f4       	brtc	.+4      	; 0x6bf0 <ceil+0x12>
    6bec:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    6bf0:	60 e0       	ldi	r22, 0x00	; 0
    6bf2:	70 e0       	ldi	r23, 0x00	; 0
    6bf4:	80 e8       	ldi	r24, 0x80	; 128
    6bf6:	9f e3       	ldi	r25, 0x3F	; 63
    6bf8:	08 95       	ret
    6bfa:	26 f0       	brts	.+8      	; 0x6c04 <ceil+0x26>
    6bfc:	1b 16       	cp	r1, r27
    6bfe:	61 1d       	adc	r22, r1
    6c00:	71 1d       	adc	r23, r1
    6c02:	81 1d       	adc	r24, r1
    6c04:	0c 94 36 37 	jmp	0x6e6c	; 0x6e6c <__fp_mintl>
    6c08:	0c 94 51 37 	jmp	0x6ea2	; 0x6ea2 <__fp_mpack>

00006c0c <__cmpsf2>:
    6c0c:	0e 94 0c 37 	call	0x6e18	; 0x6e18 <__fp_cmp>
    6c10:	08 f4       	brcc	.+2      	; 0x6c14 <__cmpsf2+0x8>
    6c12:	81 e0       	ldi	r24, 0x01	; 1
    6c14:	08 95       	ret

00006c16 <cos>:
    6c16:	0e 94 99 37 	call	0x6f32	; 0x6f32 <__fp_rempio2>
    6c1a:	e3 95       	inc	r30
    6c1c:	0c 94 d3 37 	jmp	0x6fa6	; 0x6fa6 <__fp_sinus>

00006c20 <__divsf3>:
    6c20:	0e 94 24 36 	call	0x6c48	; 0x6c48 <__divsf3x>
    6c24:	0c 94 c2 37 	jmp	0x6f84	; 0x6f84 <__fp_round>
    6c28:	0e 94 90 37 	call	0x6f20	; 0x6f20 <__fp_pscB>
    6c2c:	58 f0       	brcs	.+22     	; 0x6c44 <__divsf3+0x24>
    6c2e:	0e 94 89 37 	call	0x6f12	; 0x6f12 <__fp_pscA>
    6c32:	40 f0       	brcs	.+16     	; 0x6c44 <__divsf3+0x24>
    6c34:	29 f4       	brne	.+10     	; 0x6c40 <__divsf3+0x20>
    6c36:	5f 3f       	cpi	r21, 0xFF	; 255
    6c38:	29 f0       	breq	.+10     	; 0x6c44 <__divsf3+0x24>
    6c3a:	0c 94 30 37 	jmp	0x6e60	; 0x6e60 <__fp_inf>
    6c3e:	51 11       	cpse	r21, r1
    6c40:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    6c44:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>

00006c48 <__divsf3x>:
    6c48:	0e 94 e7 37 	call	0x6fce	; 0x6fce <__fp_split3>
    6c4c:	68 f3       	brcs	.-38     	; 0x6c28 <__divsf3+0x8>

00006c4e <__divsf3_pse>:
    6c4e:	99 23       	and	r25, r25
    6c50:	b1 f3       	breq	.-20     	; 0x6c3e <__divsf3+0x1e>
    6c52:	55 23       	and	r21, r21
    6c54:	91 f3       	breq	.-28     	; 0x6c3a <__divsf3+0x1a>
    6c56:	95 1b       	sub	r25, r21
    6c58:	55 0b       	sbc	r21, r21
    6c5a:	bb 27       	eor	r27, r27
    6c5c:	aa 27       	eor	r26, r26
    6c5e:	62 17       	cp	r22, r18
    6c60:	73 07       	cpc	r23, r19
    6c62:	84 07       	cpc	r24, r20
    6c64:	38 f0       	brcs	.+14     	; 0x6c74 <__divsf3_pse+0x26>
    6c66:	9f 5f       	subi	r25, 0xFF	; 255
    6c68:	5f 4f       	sbci	r21, 0xFF	; 255
    6c6a:	22 0f       	add	r18, r18
    6c6c:	33 1f       	adc	r19, r19
    6c6e:	44 1f       	adc	r20, r20
    6c70:	aa 1f       	adc	r26, r26
    6c72:	a9 f3       	breq	.-22     	; 0x6c5e <__divsf3_pse+0x10>
    6c74:	35 d0       	rcall	.+106    	; 0x6ce0 <__divsf3_pse+0x92>
    6c76:	0e 2e       	mov	r0, r30
    6c78:	3a f0       	brmi	.+14     	; 0x6c88 <__divsf3_pse+0x3a>
    6c7a:	e0 e8       	ldi	r30, 0x80	; 128
    6c7c:	32 d0       	rcall	.+100    	; 0x6ce2 <__divsf3_pse+0x94>
    6c7e:	91 50       	subi	r25, 0x01	; 1
    6c80:	50 40       	sbci	r21, 0x00	; 0
    6c82:	e6 95       	lsr	r30
    6c84:	00 1c       	adc	r0, r0
    6c86:	ca f7       	brpl	.-14     	; 0x6c7a <__divsf3_pse+0x2c>
    6c88:	2b d0       	rcall	.+86     	; 0x6ce0 <__divsf3_pse+0x92>
    6c8a:	fe 2f       	mov	r31, r30
    6c8c:	29 d0       	rcall	.+82     	; 0x6ce0 <__divsf3_pse+0x92>
    6c8e:	66 0f       	add	r22, r22
    6c90:	77 1f       	adc	r23, r23
    6c92:	88 1f       	adc	r24, r24
    6c94:	bb 1f       	adc	r27, r27
    6c96:	26 17       	cp	r18, r22
    6c98:	37 07       	cpc	r19, r23
    6c9a:	48 07       	cpc	r20, r24
    6c9c:	ab 07       	cpc	r26, r27
    6c9e:	b0 e8       	ldi	r27, 0x80	; 128
    6ca0:	09 f0       	breq	.+2      	; 0x6ca4 <__divsf3_pse+0x56>
    6ca2:	bb 0b       	sbc	r27, r27
    6ca4:	80 2d       	mov	r24, r0
    6ca6:	bf 01       	movw	r22, r30
    6ca8:	ff 27       	eor	r31, r31
    6caa:	93 58       	subi	r25, 0x83	; 131
    6cac:	5f 4f       	sbci	r21, 0xFF	; 255
    6cae:	3a f0       	brmi	.+14     	; 0x6cbe <__divsf3_pse+0x70>
    6cb0:	9e 3f       	cpi	r25, 0xFE	; 254
    6cb2:	51 05       	cpc	r21, r1
    6cb4:	78 f0       	brcs	.+30     	; 0x6cd4 <__divsf3_pse+0x86>
    6cb6:	0c 94 30 37 	jmp	0x6e60	; 0x6e60 <__fp_inf>
    6cba:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    6cbe:	5f 3f       	cpi	r21, 0xFF	; 255
    6cc0:	e4 f3       	brlt	.-8      	; 0x6cba <__divsf3_pse+0x6c>
    6cc2:	98 3e       	cpi	r25, 0xE8	; 232
    6cc4:	d4 f3       	brlt	.-12     	; 0x6cba <__divsf3_pse+0x6c>
    6cc6:	86 95       	lsr	r24
    6cc8:	77 95       	ror	r23
    6cca:	67 95       	ror	r22
    6ccc:	b7 95       	ror	r27
    6cce:	f7 95       	ror	r31
    6cd0:	9f 5f       	subi	r25, 0xFF	; 255
    6cd2:	c9 f7       	brne	.-14     	; 0x6cc6 <__divsf3_pse+0x78>
    6cd4:	88 0f       	add	r24, r24
    6cd6:	91 1d       	adc	r25, r1
    6cd8:	96 95       	lsr	r25
    6cda:	87 95       	ror	r24
    6cdc:	97 f9       	bld	r25, 7
    6cde:	08 95       	ret
    6ce0:	e1 e0       	ldi	r30, 0x01	; 1
    6ce2:	66 0f       	add	r22, r22
    6ce4:	77 1f       	adc	r23, r23
    6ce6:	88 1f       	adc	r24, r24
    6ce8:	bb 1f       	adc	r27, r27
    6cea:	62 17       	cp	r22, r18
    6cec:	73 07       	cpc	r23, r19
    6cee:	84 07       	cpc	r24, r20
    6cf0:	ba 07       	cpc	r27, r26
    6cf2:	20 f0       	brcs	.+8      	; 0x6cfc <__divsf3_pse+0xae>
    6cf4:	62 1b       	sub	r22, r18
    6cf6:	73 0b       	sbc	r23, r19
    6cf8:	84 0b       	sbc	r24, r20
    6cfa:	ba 0b       	sbc	r27, r26
    6cfc:	ee 1f       	adc	r30, r30
    6cfe:	88 f7       	brcc	.-30     	; 0x6ce2 <__divsf3_pse+0x94>
    6d00:	e0 95       	com	r30
    6d02:	08 95       	ret

00006d04 <__fixsfsi>:
    6d04:	0e 94 89 36 	call	0x6d12	; 0x6d12 <__fixunssfsi>
    6d08:	68 94       	set
    6d0a:	b1 11       	cpse	r27, r1
    6d0c:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    6d10:	08 95       	ret

00006d12 <__fixunssfsi>:
    6d12:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    6d16:	88 f0       	brcs	.+34     	; 0x6d3a <__fixunssfsi+0x28>
    6d18:	9f 57       	subi	r25, 0x7F	; 127
    6d1a:	98 f0       	brcs	.+38     	; 0x6d42 <__fixunssfsi+0x30>
    6d1c:	b9 2f       	mov	r27, r25
    6d1e:	99 27       	eor	r25, r25
    6d20:	b7 51       	subi	r27, 0x17	; 23
    6d22:	b0 f0       	brcs	.+44     	; 0x6d50 <__fixunssfsi+0x3e>
    6d24:	e1 f0       	breq	.+56     	; 0x6d5e <__fixunssfsi+0x4c>
    6d26:	66 0f       	add	r22, r22
    6d28:	77 1f       	adc	r23, r23
    6d2a:	88 1f       	adc	r24, r24
    6d2c:	99 1f       	adc	r25, r25
    6d2e:	1a f0       	brmi	.+6      	; 0x6d36 <__fixunssfsi+0x24>
    6d30:	ba 95       	dec	r27
    6d32:	c9 f7       	brne	.-14     	; 0x6d26 <__fixunssfsi+0x14>
    6d34:	14 c0       	rjmp	.+40     	; 0x6d5e <__fixunssfsi+0x4c>
    6d36:	b1 30       	cpi	r27, 0x01	; 1
    6d38:	91 f0       	breq	.+36     	; 0x6d5e <__fixunssfsi+0x4c>
    6d3a:	0e 94 21 38 	call	0x7042	; 0x7042 <__fp_zero>
    6d3e:	b1 e0       	ldi	r27, 0x01	; 1
    6d40:	08 95       	ret
    6d42:	0c 94 21 38 	jmp	0x7042	; 0x7042 <__fp_zero>
    6d46:	67 2f       	mov	r22, r23
    6d48:	78 2f       	mov	r23, r24
    6d4a:	88 27       	eor	r24, r24
    6d4c:	b8 5f       	subi	r27, 0xF8	; 248
    6d4e:	39 f0       	breq	.+14     	; 0x6d5e <__fixunssfsi+0x4c>
    6d50:	b9 3f       	cpi	r27, 0xF9	; 249
    6d52:	cc f3       	brlt	.-14     	; 0x6d46 <__fixunssfsi+0x34>
    6d54:	86 95       	lsr	r24
    6d56:	77 95       	ror	r23
    6d58:	67 95       	ror	r22
    6d5a:	b3 95       	inc	r27
    6d5c:	d9 f7       	brne	.-10     	; 0x6d54 <__fixunssfsi+0x42>
    6d5e:	3e f4       	brtc	.+14     	; 0x6d6e <__fixunssfsi+0x5c>
    6d60:	90 95       	com	r25
    6d62:	80 95       	com	r24
    6d64:	70 95       	com	r23
    6d66:	61 95       	neg	r22
    6d68:	7f 4f       	sbci	r23, 0xFF	; 255
    6d6a:	8f 4f       	sbci	r24, 0xFF	; 255
    6d6c:	9f 4f       	sbci	r25, 0xFF	; 255
    6d6e:	08 95       	ret

00006d70 <__floatunsisf>:
    6d70:	e8 94       	clt
    6d72:	09 c0       	rjmp	.+18     	; 0x6d86 <__floatsisf+0x12>

00006d74 <__floatsisf>:
    6d74:	97 fb       	bst	r25, 7
    6d76:	3e f4       	brtc	.+14     	; 0x6d86 <__floatsisf+0x12>
    6d78:	90 95       	com	r25
    6d7a:	80 95       	com	r24
    6d7c:	70 95       	com	r23
    6d7e:	61 95       	neg	r22
    6d80:	7f 4f       	sbci	r23, 0xFF	; 255
    6d82:	8f 4f       	sbci	r24, 0xFF	; 255
    6d84:	9f 4f       	sbci	r25, 0xFF	; 255
    6d86:	99 23       	and	r25, r25
    6d88:	a9 f0       	breq	.+42     	; 0x6db4 <__floatsisf+0x40>
    6d8a:	f9 2f       	mov	r31, r25
    6d8c:	96 e9       	ldi	r25, 0x96	; 150
    6d8e:	bb 27       	eor	r27, r27
    6d90:	93 95       	inc	r25
    6d92:	f6 95       	lsr	r31
    6d94:	87 95       	ror	r24
    6d96:	77 95       	ror	r23
    6d98:	67 95       	ror	r22
    6d9a:	b7 95       	ror	r27
    6d9c:	f1 11       	cpse	r31, r1
    6d9e:	f8 cf       	rjmp	.-16     	; 0x6d90 <__floatsisf+0x1c>
    6da0:	fa f4       	brpl	.+62     	; 0x6de0 <__floatsisf+0x6c>
    6da2:	bb 0f       	add	r27, r27
    6da4:	11 f4       	brne	.+4      	; 0x6daa <__floatsisf+0x36>
    6da6:	60 ff       	sbrs	r22, 0
    6da8:	1b c0       	rjmp	.+54     	; 0x6de0 <__floatsisf+0x6c>
    6daa:	6f 5f       	subi	r22, 0xFF	; 255
    6dac:	7f 4f       	sbci	r23, 0xFF	; 255
    6dae:	8f 4f       	sbci	r24, 0xFF	; 255
    6db0:	9f 4f       	sbci	r25, 0xFF	; 255
    6db2:	16 c0       	rjmp	.+44     	; 0x6de0 <__floatsisf+0x6c>
    6db4:	88 23       	and	r24, r24
    6db6:	11 f0       	breq	.+4      	; 0x6dbc <__floatsisf+0x48>
    6db8:	96 e9       	ldi	r25, 0x96	; 150
    6dba:	11 c0       	rjmp	.+34     	; 0x6dde <__floatsisf+0x6a>
    6dbc:	77 23       	and	r23, r23
    6dbe:	21 f0       	breq	.+8      	; 0x6dc8 <__floatsisf+0x54>
    6dc0:	9e e8       	ldi	r25, 0x8E	; 142
    6dc2:	87 2f       	mov	r24, r23
    6dc4:	76 2f       	mov	r23, r22
    6dc6:	05 c0       	rjmp	.+10     	; 0x6dd2 <__floatsisf+0x5e>
    6dc8:	66 23       	and	r22, r22
    6dca:	71 f0       	breq	.+28     	; 0x6de8 <__floatsisf+0x74>
    6dcc:	96 e8       	ldi	r25, 0x86	; 134
    6dce:	86 2f       	mov	r24, r22
    6dd0:	70 e0       	ldi	r23, 0x00	; 0
    6dd2:	60 e0       	ldi	r22, 0x00	; 0
    6dd4:	2a f0       	brmi	.+10     	; 0x6de0 <__floatsisf+0x6c>
    6dd6:	9a 95       	dec	r25
    6dd8:	66 0f       	add	r22, r22
    6dda:	77 1f       	adc	r23, r23
    6ddc:	88 1f       	adc	r24, r24
    6dde:	da f7       	brpl	.-10     	; 0x6dd6 <__floatsisf+0x62>
    6de0:	88 0f       	add	r24, r24
    6de2:	96 95       	lsr	r25
    6de4:	87 95       	ror	r24
    6de6:	97 f9       	bld	r25, 7
    6de8:	08 95       	ret

00006dea <floor>:
    6dea:	0e 94 09 38 	call	0x7012	; 0x7012 <__fp_trunc>
    6dee:	90 f0       	brcs	.+36     	; 0x6e14 <floor+0x2a>
    6df0:	9f 37       	cpi	r25, 0x7F	; 127
    6df2:	48 f4       	brcc	.+18     	; 0x6e06 <floor+0x1c>
    6df4:	91 11       	cpse	r25, r1
    6df6:	16 f0       	brts	.+4      	; 0x6dfc <floor+0x12>
    6df8:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    6dfc:	60 e0       	ldi	r22, 0x00	; 0
    6dfe:	70 e0       	ldi	r23, 0x00	; 0
    6e00:	80 e8       	ldi	r24, 0x80	; 128
    6e02:	9f eb       	ldi	r25, 0xBF	; 191
    6e04:	08 95       	ret
    6e06:	26 f4       	brtc	.+8      	; 0x6e10 <floor+0x26>
    6e08:	1b 16       	cp	r1, r27
    6e0a:	61 1d       	adc	r22, r1
    6e0c:	71 1d       	adc	r23, r1
    6e0e:	81 1d       	adc	r24, r1
    6e10:	0c 94 36 37 	jmp	0x6e6c	; 0x6e6c <__fp_mintl>
    6e14:	0c 94 51 37 	jmp	0x6ea2	; 0x6ea2 <__fp_mpack>

00006e18 <__fp_cmp>:
    6e18:	99 0f       	add	r25, r25
    6e1a:	00 08       	sbc	r0, r0
    6e1c:	55 0f       	add	r21, r21
    6e1e:	aa 0b       	sbc	r26, r26
    6e20:	e0 e8       	ldi	r30, 0x80	; 128
    6e22:	fe ef       	ldi	r31, 0xFE	; 254
    6e24:	16 16       	cp	r1, r22
    6e26:	17 06       	cpc	r1, r23
    6e28:	e8 07       	cpc	r30, r24
    6e2a:	f9 07       	cpc	r31, r25
    6e2c:	c0 f0       	brcs	.+48     	; 0x6e5e <__fp_cmp+0x46>
    6e2e:	12 16       	cp	r1, r18
    6e30:	13 06       	cpc	r1, r19
    6e32:	e4 07       	cpc	r30, r20
    6e34:	f5 07       	cpc	r31, r21
    6e36:	98 f0       	brcs	.+38     	; 0x6e5e <__fp_cmp+0x46>
    6e38:	62 1b       	sub	r22, r18
    6e3a:	73 0b       	sbc	r23, r19
    6e3c:	84 0b       	sbc	r24, r20
    6e3e:	95 0b       	sbc	r25, r21
    6e40:	39 f4       	brne	.+14     	; 0x6e50 <__fp_cmp+0x38>
    6e42:	0a 26       	eor	r0, r26
    6e44:	61 f0       	breq	.+24     	; 0x6e5e <__fp_cmp+0x46>
    6e46:	23 2b       	or	r18, r19
    6e48:	24 2b       	or	r18, r20
    6e4a:	25 2b       	or	r18, r21
    6e4c:	21 f4       	brne	.+8      	; 0x6e56 <__fp_cmp+0x3e>
    6e4e:	08 95       	ret
    6e50:	0a 26       	eor	r0, r26
    6e52:	09 f4       	brne	.+2      	; 0x6e56 <__fp_cmp+0x3e>
    6e54:	a1 40       	sbci	r26, 0x01	; 1
    6e56:	a6 95       	lsr	r26
    6e58:	8f ef       	ldi	r24, 0xFF	; 255
    6e5a:	81 1d       	adc	r24, r1
    6e5c:	81 1d       	adc	r24, r1
    6e5e:	08 95       	ret

00006e60 <__fp_inf>:
    6e60:	97 f9       	bld	r25, 7
    6e62:	9f 67       	ori	r25, 0x7F	; 127
    6e64:	80 e8       	ldi	r24, 0x80	; 128
    6e66:	70 e0       	ldi	r23, 0x00	; 0
    6e68:	60 e0       	ldi	r22, 0x00	; 0
    6e6a:	08 95       	ret

00006e6c <__fp_mintl>:
    6e6c:	88 23       	and	r24, r24
    6e6e:	71 f4       	brne	.+28     	; 0x6e8c <__fp_mintl+0x20>
    6e70:	77 23       	and	r23, r23
    6e72:	21 f0       	breq	.+8      	; 0x6e7c <__fp_mintl+0x10>
    6e74:	98 50       	subi	r25, 0x08	; 8
    6e76:	87 2b       	or	r24, r23
    6e78:	76 2f       	mov	r23, r22
    6e7a:	07 c0       	rjmp	.+14     	; 0x6e8a <__fp_mintl+0x1e>
    6e7c:	66 23       	and	r22, r22
    6e7e:	11 f4       	brne	.+4      	; 0x6e84 <__fp_mintl+0x18>
    6e80:	99 27       	eor	r25, r25
    6e82:	0d c0       	rjmp	.+26     	; 0x6e9e <__fp_mintl+0x32>
    6e84:	90 51       	subi	r25, 0x10	; 16
    6e86:	86 2b       	or	r24, r22
    6e88:	70 e0       	ldi	r23, 0x00	; 0
    6e8a:	60 e0       	ldi	r22, 0x00	; 0
    6e8c:	2a f0       	brmi	.+10     	; 0x6e98 <__fp_mintl+0x2c>
    6e8e:	9a 95       	dec	r25
    6e90:	66 0f       	add	r22, r22
    6e92:	77 1f       	adc	r23, r23
    6e94:	88 1f       	adc	r24, r24
    6e96:	da f7       	brpl	.-10     	; 0x6e8e <__fp_mintl+0x22>
    6e98:	88 0f       	add	r24, r24
    6e9a:	96 95       	lsr	r25
    6e9c:	87 95       	ror	r24
    6e9e:	97 f9       	bld	r25, 7
    6ea0:	08 95       	ret

00006ea2 <__fp_mpack>:
    6ea2:	9f 3f       	cpi	r25, 0xFF	; 255
    6ea4:	31 f0       	breq	.+12     	; 0x6eb2 <__fp_mpack_finite+0xc>

00006ea6 <__fp_mpack_finite>:
    6ea6:	91 50       	subi	r25, 0x01	; 1
    6ea8:	20 f4       	brcc	.+8      	; 0x6eb2 <__fp_mpack_finite+0xc>
    6eaa:	87 95       	ror	r24
    6eac:	77 95       	ror	r23
    6eae:	67 95       	ror	r22
    6eb0:	b7 95       	ror	r27
    6eb2:	88 0f       	add	r24, r24
    6eb4:	91 1d       	adc	r25, r1
    6eb6:	96 95       	lsr	r25
    6eb8:	87 95       	ror	r24
    6eba:	97 f9       	bld	r25, 7
    6ebc:	08 95       	ret

00006ebe <__fp_nan>:
    6ebe:	9f ef       	ldi	r25, 0xFF	; 255
    6ec0:	80 ec       	ldi	r24, 0xC0	; 192
    6ec2:	08 95       	ret

00006ec4 <__fp_powser>:
    6ec4:	df 93       	push	r29
    6ec6:	cf 93       	push	r28
    6ec8:	1f 93       	push	r17
    6eca:	0f 93       	push	r16
    6ecc:	ff 92       	push	r15
    6ece:	ef 92       	push	r14
    6ed0:	df 92       	push	r13
    6ed2:	7b 01       	movw	r14, r22
    6ed4:	8c 01       	movw	r16, r24
    6ed6:	68 94       	set
    6ed8:	06 c0       	rjmp	.+12     	; 0x6ee6 <__fp_powser+0x22>
    6eda:	da 2e       	mov	r13, r26
    6edc:	ef 01       	movw	r28, r30
    6ede:	0e 94 7b 38 	call	0x70f6	; 0x70f6 <__mulsf3x>
    6ee2:	fe 01       	movw	r30, r28
    6ee4:	e8 94       	clt
    6ee6:	a5 91       	lpm	r26, Z+
    6ee8:	25 91       	lpm	r18, Z+
    6eea:	35 91       	lpm	r19, Z+
    6eec:	45 91       	lpm	r20, Z+
    6eee:	55 91       	lpm	r21, Z+
    6ef0:	a6 f3       	brts	.-24     	; 0x6eda <__fp_powser+0x16>
    6ef2:	ef 01       	movw	r28, r30
    6ef4:	0e 94 28 35 	call	0x6a50	; 0x6a50 <__addsf3x>
    6ef8:	fe 01       	movw	r30, r28
    6efa:	97 01       	movw	r18, r14
    6efc:	a8 01       	movw	r20, r16
    6efe:	da 94       	dec	r13
    6f00:	69 f7       	brne	.-38     	; 0x6edc <__fp_powser+0x18>
    6f02:	df 90       	pop	r13
    6f04:	ef 90       	pop	r14
    6f06:	ff 90       	pop	r15
    6f08:	0f 91       	pop	r16
    6f0a:	1f 91       	pop	r17
    6f0c:	cf 91       	pop	r28
    6f0e:	df 91       	pop	r29
    6f10:	08 95       	ret

00006f12 <__fp_pscA>:
    6f12:	00 24       	eor	r0, r0
    6f14:	0a 94       	dec	r0
    6f16:	16 16       	cp	r1, r22
    6f18:	17 06       	cpc	r1, r23
    6f1a:	18 06       	cpc	r1, r24
    6f1c:	09 06       	cpc	r0, r25
    6f1e:	08 95       	ret

00006f20 <__fp_pscB>:
    6f20:	00 24       	eor	r0, r0
    6f22:	0a 94       	dec	r0
    6f24:	12 16       	cp	r1, r18
    6f26:	13 06       	cpc	r1, r19
    6f28:	14 06       	cpc	r1, r20
    6f2a:	05 06       	cpc	r0, r21
    6f2c:	08 95       	ret
    6f2e:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>

00006f32 <__fp_rempio2>:
    6f32:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    6f36:	d8 f3       	brcs	.-10     	; 0x6f2e <__fp_pscB+0xe>
    6f38:	e8 94       	clt
    6f3a:	e0 e0       	ldi	r30, 0x00	; 0
    6f3c:	bb 27       	eor	r27, r27
    6f3e:	9f 57       	subi	r25, 0x7F	; 127
    6f40:	f0 f0       	brcs	.+60     	; 0x6f7e <__fp_rempio2+0x4c>
    6f42:	2a ed       	ldi	r18, 0xDA	; 218
    6f44:	3f e0       	ldi	r19, 0x0F	; 15
    6f46:	49 ec       	ldi	r20, 0xC9	; 201
    6f48:	06 c0       	rjmp	.+12     	; 0x6f56 <__fp_rempio2+0x24>
    6f4a:	ee 0f       	add	r30, r30
    6f4c:	bb 0f       	add	r27, r27
    6f4e:	66 1f       	adc	r22, r22
    6f50:	77 1f       	adc	r23, r23
    6f52:	88 1f       	adc	r24, r24
    6f54:	28 f0       	brcs	.+10     	; 0x6f60 <__fp_rempio2+0x2e>
    6f56:	b2 3a       	cpi	r27, 0xA2	; 162
    6f58:	62 07       	cpc	r22, r18
    6f5a:	73 07       	cpc	r23, r19
    6f5c:	84 07       	cpc	r24, r20
    6f5e:	28 f0       	brcs	.+10     	; 0x6f6a <__fp_rempio2+0x38>
    6f60:	b2 5a       	subi	r27, 0xA2	; 162
    6f62:	62 0b       	sbc	r22, r18
    6f64:	73 0b       	sbc	r23, r19
    6f66:	84 0b       	sbc	r24, r20
    6f68:	e3 95       	inc	r30
    6f6a:	9a 95       	dec	r25
    6f6c:	72 f7       	brpl	.-36     	; 0x6f4a <__fp_rempio2+0x18>
    6f6e:	80 38       	cpi	r24, 0x80	; 128
    6f70:	30 f4       	brcc	.+12     	; 0x6f7e <__fp_rempio2+0x4c>
    6f72:	9a 95       	dec	r25
    6f74:	bb 0f       	add	r27, r27
    6f76:	66 1f       	adc	r22, r22
    6f78:	77 1f       	adc	r23, r23
    6f7a:	88 1f       	adc	r24, r24
    6f7c:	d2 f7       	brpl	.-12     	; 0x6f72 <__fp_rempio2+0x40>
    6f7e:	90 48       	sbci	r25, 0x80	; 128
    6f80:	0c 94 53 37 	jmp	0x6ea6	; 0x6ea6 <__fp_mpack_finite>

00006f84 <__fp_round>:
    6f84:	09 2e       	mov	r0, r25
    6f86:	03 94       	inc	r0
    6f88:	00 0c       	add	r0, r0
    6f8a:	11 f4       	brne	.+4      	; 0x6f90 <__fp_round+0xc>
    6f8c:	88 23       	and	r24, r24
    6f8e:	52 f0       	brmi	.+20     	; 0x6fa4 <__fp_round+0x20>
    6f90:	bb 0f       	add	r27, r27
    6f92:	40 f4       	brcc	.+16     	; 0x6fa4 <__fp_round+0x20>
    6f94:	bf 2b       	or	r27, r31
    6f96:	11 f4       	brne	.+4      	; 0x6f9c <__fp_round+0x18>
    6f98:	60 ff       	sbrs	r22, 0
    6f9a:	04 c0       	rjmp	.+8      	; 0x6fa4 <__fp_round+0x20>
    6f9c:	6f 5f       	subi	r22, 0xFF	; 255
    6f9e:	7f 4f       	sbci	r23, 0xFF	; 255
    6fa0:	8f 4f       	sbci	r24, 0xFF	; 255
    6fa2:	9f 4f       	sbci	r25, 0xFF	; 255
    6fa4:	08 95       	ret

00006fa6 <__fp_sinus>:
    6fa6:	ef 93       	push	r30
    6fa8:	e0 ff       	sbrs	r30, 0
    6faa:	07 c0       	rjmp	.+14     	; 0x6fba <__fp_sinus+0x14>
    6fac:	a2 ea       	ldi	r26, 0xA2	; 162
    6fae:	2a ed       	ldi	r18, 0xDA	; 218
    6fb0:	3f e0       	ldi	r19, 0x0F	; 15
    6fb2:	49 ec       	ldi	r20, 0xC9	; 201
    6fb4:	5f eb       	ldi	r21, 0xBF	; 191
    6fb6:	0e 94 28 35 	call	0x6a50	; 0x6a50 <__addsf3x>
    6fba:	0e 94 c2 37 	call	0x6f84	; 0x6f84 <__fp_round>
    6fbe:	0f 90       	pop	r0
    6fc0:	03 94       	inc	r0
    6fc2:	01 fc       	sbrc	r0, 1
    6fc4:	90 58       	subi	r25, 0x80	; 128
    6fc6:	e5 e9       	ldi	r30, 0x95	; 149
    6fc8:	f0 e0       	ldi	r31, 0x00	; 0
    6fca:	0c 94 52 39 	jmp	0x72a4	; 0x72a4 <__fp_powsodd>

00006fce <__fp_split3>:
    6fce:	57 fd       	sbrc	r21, 7
    6fd0:	90 58       	subi	r25, 0x80	; 128
    6fd2:	44 0f       	add	r20, r20
    6fd4:	55 1f       	adc	r21, r21
    6fd6:	59 f0       	breq	.+22     	; 0x6fee <__fp_splitA+0x10>
    6fd8:	5f 3f       	cpi	r21, 0xFF	; 255
    6fda:	71 f0       	breq	.+28     	; 0x6ff8 <__fp_splitA+0x1a>
    6fdc:	47 95       	ror	r20

00006fde <__fp_splitA>:
    6fde:	88 0f       	add	r24, r24
    6fe0:	97 fb       	bst	r25, 7
    6fe2:	99 1f       	adc	r25, r25
    6fe4:	61 f0       	breq	.+24     	; 0x6ffe <__fp_splitA+0x20>
    6fe6:	9f 3f       	cpi	r25, 0xFF	; 255
    6fe8:	79 f0       	breq	.+30     	; 0x7008 <__fp_splitA+0x2a>
    6fea:	87 95       	ror	r24
    6fec:	08 95       	ret
    6fee:	12 16       	cp	r1, r18
    6ff0:	13 06       	cpc	r1, r19
    6ff2:	14 06       	cpc	r1, r20
    6ff4:	55 1f       	adc	r21, r21
    6ff6:	f2 cf       	rjmp	.-28     	; 0x6fdc <__fp_split3+0xe>
    6ff8:	46 95       	lsr	r20
    6ffa:	f1 df       	rcall	.-30     	; 0x6fde <__fp_splitA>
    6ffc:	08 c0       	rjmp	.+16     	; 0x700e <__fp_splitA+0x30>
    6ffe:	16 16       	cp	r1, r22
    7000:	17 06       	cpc	r1, r23
    7002:	18 06       	cpc	r1, r24
    7004:	99 1f       	adc	r25, r25
    7006:	f1 cf       	rjmp	.-30     	; 0x6fea <__fp_splitA+0xc>
    7008:	86 95       	lsr	r24
    700a:	71 05       	cpc	r23, r1
    700c:	61 05       	cpc	r22, r1
    700e:	08 94       	sec
    7010:	08 95       	ret

00007012 <__fp_trunc>:
    7012:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    7016:	a0 f0       	brcs	.+40     	; 0x7040 <__fp_trunc+0x2e>
    7018:	be e7       	ldi	r27, 0x7E	; 126
    701a:	b9 17       	cp	r27, r25
    701c:	88 f4       	brcc	.+34     	; 0x7040 <__fp_trunc+0x2e>
    701e:	bb 27       	eor	r27, r27
    7020:	9f 38       	cpi	r25, 0x8F	; 143
    7022:	60 f4       	brcc	.+24     	; 0x703c <__fp_trunc+0x2a>
    7024:	16 16       	cp	r1, r22
    7026:	b1 1d       	adc	r27, r1
    7028:	67 2f       	mov	r22, r23
    702a:	78 2f       	mov	r23, r24
    702c:	88 27       	eor	r24, r24
    702e:	98 5f       	subi	r25, 0xF8	; 248
    7030:	f7 cf       	rjmp	.-18     	; 0x7020 <__fp_trunc+0xe>
    7032:	86 95       	lsr	r24
    7034:	77 95       	ror	r23
    7036:	67 95       	ror	r22
    7038:	b1 1d       	adc	r27, r1
    703a:	93 95       	inc	r25
    703c:	96 39       	cpi	r25, 0x96	; 150
    703e:	c8 f3       	brcs	.-14     	; 0x7032 <__fp_trunc+0x20>
    7040:	08 95       	ret

00007042 <__fp_zero>:
    7042:	e8 94       	clt

00007044 <__fp_szero>:
    7044:	bb 27       	eor	r27, r27
    7046:	66 27       	eor	r22, r22
    7048:	77 27       	eor	r23, r23
    704a:	cb 01       	movw	r24, r22
    704c:	97 f9       	bld	r25, 7
    704e:	08 95       	ret

00007050 <__gesf2>:
    7050:	0e 94 0c 37 	call	0x6e18	; 0x6e18 <__fp_cmp>
    7054:	08 f4       	brcc	.+2      	; 0x7058 <__gesf2+0x8>
    7056:	8f ef       	ldi	r24, 0xFF	; 255
    7058:	08 95       	ret

0000705a <inverse>:
    705a:	9b 01       	movw	r18, r22
    705c:	ac 01       	movw	r20, r24
    705e:	60 e0       	ldi	r22, 0x00	; 0
    7060:	70 e0       	ldi	r23, 0x00	; 0
    7062:	80 e8       	ldi	r24, 0x80	; 128
    7064:	9f e3       	ldi	r25, 0x3F	; 63
    7066:	0c 94 10 36 	jmp	0x6c20	; 0x6c20 <__divsf3>

0000706a <lround>:
    706a:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    706e:	58 f1       	brcs	.+86     	; 0x70c6 <lround+0x5c>
    7070:	9e 57       	subi	r25, 0x7E	; 126
    7072:	60 f1       	brcs	.+88     	; 0x70cc <lround+0x62>
    7074:	98 51       	subi	r25, 0x18	; 24
    7076:	a0 f0       	brcs	.+40     	; 0x70a0 <lround+0x36>
    7078:	e9 f0       	breq	.+58     	; 0x70b4 <lround+0x4a>
    707a:	98 30       	cpi	r25, 0x08	; 8
    707c:	20 f5       	brcc	.+72     	; 0x70c6 <lround+0x5c>
    707e:	09 2e       	mov	r0, r25
    7080:	99 27       	eor	r25, r25
    7082:	66 0f       	add	r22, r22
    7084:	77 1f       	adc	r23, r23
    7086:	88 1f       	adc	r24, r24
    7088:	99 1f       	adc	r25, r25
    708a:	0a 94       	dec	r0
    708c:	d1 f7       	brne	.-12     	; 0x7082 <lround+0x18>
    708e:	12 c0       	rjmp	.+36     	; 0x70b4 <lround+0x4a>
    7090:	06 2e       	mov	r0, r22
    7092:	67 2f       	mov	r22, r23
    7094:	78 2f       	mov	r23, r24
    7096:	88 27       	eor	r24, r24
    7098:	98 5f       	subi	r25, 0xF8	; 248
    709a:	11 f4       	brne	.+4      	; 0x70a0 <lround+0x36>
    709c:	00 0c       	add	r0, r0
    709e:	07 c0       	rjmp	.+14     	; 0x70ae <lround+0x44>
    70a0:	99 3f       	cpi	r25, 0xF9	; 249
    70a2:	b4 f3       	brlt	.-20     	; 0x7090 <lround+0x26>
    70a4:	86 95       	lsr	r24
    70a6:	77 95       	ror	r23
    70a8:	67 95       	ror	r22
    70aa:	93 95       	inc	r25
    70ac:	d9 f7       	brne	.-10     	; 0x70a4 <lround+0x3a>
    70ae:	61 1d       	adc	r22, r1
    70b0:	71 1d       	adc	r23, r1
    70b2:	81 1d       	adc	r24, r1
    70b4:	3e f4       	brtc	.+14     	; 0x70c4 <lround+0x5a>
    70b6:	90 95       	com	r25
    70b8:	80 95       	com	r24
    70ba:	70 95       	com	r23
    70bc:	61 95       	neg	r22
    70be:	7f 4f       	sbci	r23, 0xFF	; 255
    70c0:	8f 4f       	sbci	r24, 0xFF	; 255
    70c2:	9f 4f       	sbci	r25, 0xFF	; 255
    70c4:	08 95       	ret
    70c6:	68 94       	set
    70c8:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    70cc:	0c 94 21 38 	jmp	0x7042	; 0x7042 <__fp_zero>

000070d0 <__mulsf3>:
    70d0:	0e 94 7b 38 	call	0x70f6	; 0x70f6 <__mulsf3x>
    70d4:	0c 94 c2 37 	jmp	0x6f84	; 0x6f84 <__fp_round>
    70d8:	0e 94 89 37 	call	0x6f12	; 0x6f12 <__fp_pscA>
    70dc:	38 f0       	brcs	.+14     	; 0x70ec <__mulsf3+0x1c>
    70de:	0e 94 90 37 	call	0x6f20	; 0x6f20 <__fp_pscB>
    70e2:	20 f0       	brcs	.+8      	; 0x70ec <__mulsf3+0x1c>
    70e4:	95 23       	and	r25, r21
    70e6:	11 f0       	breq	.+4      	; 0x70ec <__mulsf3+0x1c>
    70e8:	0c 94 30 37 	jmp	0x6e60	; 0x6e60 <__fp_inf>
    70ec:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>
    70f0:	11 24       	eor	r1, r1
    70f2:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>

000070f6 <__mulsf3x>:
    70f6:	0e 94 e7 37 	call	0x6fce	; 0x6fce <__fp_split3>
    70fa:	70 f3       	brcs	.-36     	; 0x70d8 <__mulsf3+0x8>

000070fc <__mulsf3_pse>:
    70fc:	95 9f       	mul	r25, r21
    70fe:	c1 f3       	breq	.-16     	; 0x70f0 <__mulsf3+0x20>
    7100:	95 0f       	add	r25, r21
    7102:	50 e0       	ldi	r21, 0x00	; 0
    7104:	55 1f       	adc	r21, r21
    7106:	62 9f       	mul	r22, r18
    7108:	f0 01       	movw	r30, r0
    710a:	72 9f       	mul	r23, r18
    710c:	bb 27       	eor	r27, r27
    710e:	f0 0d       	add	r31, r0
    7110:	b1 1d       	adc	r27, r1
    7112:	63 9f       	mul	r22, r19
    7114:	aa 27       	eor	r26, r26
    7116:	f0 0d       	add	r31, r0
    7118:	b1 1d       	adc	r27, r1
    711a:	aa 1f       	adc	r26, r26
    711c:	64 9f       	mul	r22, r20
    711e:	66 27       	eor	r22, r22
    7120:	b0 0d       	add	r27, r0
    7122:	a1 1d       	adc	r26, r1
    7124:	66 1f       	adc	r22, r22
    7126:	82 9f       	mul	r24, r18
    7128:	22 27       	eor	r18, r18
    712a:	b0 0d       	add	r27, r0
    712c:	a1 1d       	adc	r26, r1
    712e:	62 1f       	adc	r22, r18
    7130:	73 9f       	mul	r23, r19
    7132:	b0 0d       	add	r27, r0
    7134:	a1 1d       	adc	r26, r1
    7136:	62 1f       	adc	r22, r18
    7138:	83 9f       	mul	r24, r19
    713a:	a0 0d       	add	r26, r0
    713c:	61 1d       	adc	r22, r1
    713e:	22 1f       	adc	r18, r18
    7140:	74 9f       	mul	r23, r20
    7142:	33 27       	eor	r19, r19
    7144:	a0 0d       	add	r26, r0
    7146:	61 1d       	adc	r22, r1
    7148:	23 1f       	adc	r18, r19
    714a:	84 9f       	mul	r24, r20
    714c:	60 0d       	add	r22, r0
    714e:	21 1d       	adc	r18, r1
    7150:	82 2f       	mov	r24, r18
    7152:	76 2f       	mov	r23, r22
    7154:	6a 2f       	mov	r22, r26
    7156:	11 24       	eor	r1, r1
    7158:	9f 57       	subi	r25, 0x7F	; 127
    715a:	50 40       	sbci	r21, 0x00	; 0
    715c:	9a f0       	brmi	.+38     	; 0x7184 <__mulsf3_pse+0x88>
    715e:	f1 f0       	breq	.+60     	; 0x719c <__mulsf3_pse+0xa0>
    7160:	88 23       	and	r24, r24
    7162:	4a f0       	brmi	.+18     	; 0x7176 <__mulsf3_pse+0x7a>
    7164:	ee 0f       	add	r30, r30
    7166:	ff 1f       	adc	r31, r31
    7168:	bb 1f       	adc	r27, r27
    716a:	66 1f       	adc	r22, r22
    716c:	77 1f       	adc	r23, r23
    716e:	88 1f       	adc	r24, r24
    7170:	91 50       	subi	r25, 0x01	; 1
    7172:	50 40       	sbci	r21, 0x00	; 0
    7174:	a9 f7       	brne	.-22     	; 0x7160 <__mulsf3_pse+0x64>
    7176:	9e 3f       	cpi	r25, 0xFE	; 254
    7178:	51 05       	cpc	r21, r1
    717a:	80 f0       	brcs	.+32     	; 0x719c <__mulsf3_pse+0xa0>
    717c:	0c 94 30 37 	jmp	0x6e60	; 0x6e60 <__fp_inf>
    7180:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>
    7184:	5f 3f       	cpi	r21, 0xFF	; 255
    7186:	e4 f3       	brlt	.-8      	; 0x7180 <__mulsf3_pse+0x84>
    7188:	98 3e       	cpi	r25, 0xE8	; 232
    718a:	d4 f3       	brlt	.-12     	; 0x7180 <__mulsf3_pse+0x84>
    718c:	86 95       	lsr	r24
    718e:	77 95       	ror	r23
    7190:	67 95       	ror	r22
    7192:	b7 95       	ror	r27
    7194:	f7 95       	ror	r31
    7196:	e7 95       	ror	r30
    7198:	9f 5f       	subi	r25, 0xFF	; 255
    719a:	c1 f7       	brne	.-16     	; 0x718c <__mulsf3_pse+0x90>
    719c:	fe 2b       	or	r31, r30
    719e:	88 0f       	add	r24, r24
    71a0:	91 1d       	adc	r25, r1
    71a2:	96 95       	lsr	r25
    71a4:	87 95       	ror	r24
    71a6:	97 f9       	bld	r25, 7
    71a8:	08 95       	ret

000071aa <round>:
    71aa:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    71ae:	e8 f0       	brcs	.+58     	; 0x71ea <round+0x40>
    71b0:	9e 37       	cpi	r25, 0x7E	; 126
    71b2:	e8 f0       	brcs	.+58     	; 0x71ee <round+0x44>
    71b4:	96 39       	cpi	r25, 0x96	; 150
    71b6:	b8 f4       	brcc	.+46     	; 0x71e6 <round+0x3c>
    71b8:	9e 38       	cpi	r25, 0x8E	; 142
    71ba:	48 f4       	brcc	.+18     	; 0x71ce <round+0x24>
    71bc:	67 2f       	mov	r22, r23
    71be:	78 2f       	mov	r23, r24
    71c0:	88 27       	eor	r24, r24
    71c2:	98 5f       	subi	r25, 0xF8	; 248
    71c4:	f9 cf       	rjmp	.-14     	; 0x71b8 <round+0xe>
    71c6:	86 95       	lsr	r24
    71c8:	77 95       	ror	r23
    71ca:	67 95       	ror	r22
    71cc:	93 95       	inc	r25
    71ce:	95 39       	cpi	r25, 0x95	; 149
    71d0:	d0 f3       	brcs	.-12     	; 0x71c6 <round+0x1c>
    71d2:	b6 2f       	mov	r27, r22
    71d4:	b1 70       	andi	r27, 0x01	; 1
    71d6:	6b 0f       	add	r22, r27
    71d8:	71 1d       	adc	r23, r1
    71da:	81 1d       	adc	r24, r1
    71dc:	20 f4       	brcc	.+8      	; 0x71e6 <round+0x3c>
    71de:	87 95       	ror	r24
    71e0:	77 95       	ror	r23
    71e2:	67 95       	ror	r22
    71e4:	93 95       	inc	r25
    71e6:	0c 94 36 37 	jmp	0x6e6c	; 0x6e6c <__fp_mintl>
    71ea:	0c 94 51 37 	jmp	0x6ea2	; 0x6ea2 <__fp_mpack>
    71ee:	0c 94 22 38 	jmp	0x7044	; 0x7044 <__fp_szero>

000071f2 <sin>:
    71f2:	9f 93       	push	r25
    71f4:	0e 94 99 37 	call	0x6f32	; 0x6f32 <__fp_rempio2>
    71f8:	0f 90       	pop	r0
    71fa:	07 fc       	sbrc	r0, 7
    71fc:	ee 5f       	subi	r30, 0xFE	; 254
    71fe:	0c 94 d3 37 	jmp	0x6fa6	; 0x6fa6 <__fp_sinus>
    7202:	19 f4       	brne	.+6      	; 0x720a <sin+0x18>
    7204:	16 f4       	brtc	.+4      	; 0x720a <sin+0x18>
    7206:	0c 94 5f 37 	jmp	0x6ebe	; 0x6ebe <__fp_nan>
    720a:	0c 94 51 37 	jmp	0x6ea2	; 0x6ea2 <__fp_mpack>

0000720e <sqrt>:
    720e:	0e 94 ef 37 	call	0x6fde	; 0x6fde <__fp_splitA>
    7212:	b8 f3       	brcs	.-18     	; 0x7202 <sin+0x10>
    7214:	99 23       	and	r25, r25
    7216:	c9 f3       	breq	.-14     	; 0x720a <sin+0x18>
    7218:	b6 f3       	brts	.-20     	; 0x7206 <sin+0x14>
    721a:	9f 57       	subi	r25, 0x7F	; 127
    721c:	55 0b       	sbc	r21, r21
    721e:	87 ff       	sbrs	r24, 7
    7220:	0e 94 4b 39 	call	0x7296	; 0x7296 <__fp_norm2>
    7224:	00 24       	eor	r0, r0
    7226:	a0 e6       	ldi	r26, 0x60	; 96
    7228:	40 ea       	ldi	r20, 0xA0	; 160
    722a:	90 01       	movw	r18, r0
    722c:	80 58       	subi	r24, 0x80	; 128
    722e:	56 95       	lsr	r21
    7230:	97 95       	ror	r25
    7232:	28 f4       	brcc	.+10     	; 0x723e <sqrt+0x30>
    7234:	80 5c       	subi	r24, 0xC0	; 192
    7236:	66 0f       	add	r22, r22
    7238:	77 1f       	adc	r23, r23
    723a:	88 1f       	adc	r24, r24
    723c:	20 f0       	brcs	.+8      	; 0x7246 <sqrt+0x38>
    723e:	26 17       	cp	r18, r22
    7240:	37 07       	cpc	r19, r23
    7242:	48 07       	cpc	r20, r24
    7244:	30 f4       	brcc	.+12     	; 0x7252 <sqrt+0x44>
    7246:	62 1b       	sub	r22, r18
    7248:	73 0b       	sbc	r23, r19
    724a:	84 0b       	sbc	r24, r20
    724c:	20 29       	or	r18, r0
    724e:	31 29       	or	r19, r1
    7250:	4a 2b       	or	r20, r26
    7252:	a6 95       	lsr	r26
    7254:	17 94       	ror	r1
    7256:	07 94       	ror	r0
    7258:	20 25       	eor	r18, r0
    725a:	31 25       	eor	r19, r1
    725c:	4a 27       	eor	r20, r26
    725e:	58 f7       	brcc	.-42     	; 0x7236 <sqrt+0x28>
    7260:	66 0f       	add	r22, r22
    7262:	77 1f       	adc	r23, r23
    7264:	88 1f       	adc	r24, r24
    7266:	20 f0       	brcs	.+8      	; 0x7270 <sqrt+0x62>
    7268:	26 17       	cp	r18, r22
    726a:	37 07       	cpc	r19, r23
    726c:	48 07       	cpc	r20, r24
    726e:	30 f4       	brcc	.+12     	; 0x727c <sqrt+0x6e>
    7270:	62 0b       	sbc	r22, r18
    7272:	73 0b       	sbc	r23, r19
    7274:	84 0b       	sbc	r24, r20
    7276:	20 0d       	add	r18, r0
    7278:	31 1d       	adc	r19, r1
    727a:	41 1d       	adc	r20, r1
    727c:	a0 95       	com	r26
    727e:	81 f7       	brne	.-32     	; 0x7260 <sqrt+0x52>
    7280:	b9 01       	movw	r22, r18
    7282:	84 2f       	mov	r24, r20
    7284:	91 58       	subi	r25, 0x81	; 129
    7286:	88 0f       	add	r24, r24
    7288:	96 95       	lsr	r25
    728a:	87 95       	ror	r24
    728c:	08 95       	ret

0000728e <square>:
    728e:	9b 01       	movw	r18, r22
    7290:	ac 01       	movw	r20, r24
    7292:	0c 94 68 38 	jmp	0x70d0	; 0x70d0 <__mulsf3>

00007296 <__fp_norm2>:
    7296:	91 50       	subi	r25, 0x01	; 1
    7298:	50 40       	sbci	r21, 0x00	; 0
    729a:	66 0f       	add	r22, r22
    729c:	77 1f       	adc	r23, r23
    729e:	88 1f       	adc	r24, r24
    72a0:	d2 f7       	brpl	.-12     	; 0x7296 <__fp_norm2>
    72a2:	08 95       	ret

000072a4 <__fp_powsodd>:
    72a4:	9f 93       	push	r25
    72a6:	8f 93       	push	r24
    72a8:	7f 93       	push	r23
    72aa:	6f 93       	push	r22
    72ac:	ff 93       	push	r31
    72ae:	ef 93       	push	r30
    72b0:	9b 01       	movw	r18, r22
    72b2:	ac 01       	movw	r20, r24
    72b4:	0e 94 68 38 	call	0x70d0	; 0x70d0 <__mulsf3>
    72b8:	ef 91       	pop	r30
    72ba:	ff 91       	pop	r31
    72bc:	0e 94 62 37 	call	0x6ec4	; 0x6ec4 <__fp_powser>
    72c0:	2f 91       	pop	r18
    72c2:	3f 91       	pop	r19
    72c4:	4f 91       	pop	r20
    72c6:	5f 91       	pop	r21
    72c8:	0c 94 68 38 	jmp	0x70d0	; 0x70d0 <__mulsf3>

000072cc <__udivmodqi4>:
    72cc:	99 1b       	sub	r25, r25
    72ce:	79 e0       	ldi	r23, 0x09	; 9
    72d0:	04 c0       	rjmp	.+8      	; 0x72da <__udivmodqi4_ep>

000072d2 <__udivmodqi4_loop>:
    72d2:	99 1f       	adc	r25, r25
    72d4:	96 17       	cp	r25, r22
    72d6:	08 f0       	brcs	.+2      	; 0x72da <__udivmodqi4_ep>
    72d8:	96 1b       	sub	r25, r22

000072da <__udivmodqi4_ep>:
    72da:	88 1f       	adc	r24, r24
    72dc:	7a 95       	dec	r23
    72de:	c9 f7       	brne	.-14     	; 0x72d2 <__udivmodqi4_loop>
    72e0:	80 95       	com	r24
    72e2:	08 95       	ret

000072e4 <__udivmodhi4>:
    72e4:	aa 1b       	sub	r26, r26
    72e6:	bb 1b       	sub	r27, r27
    72e8:	51 e1       	ldi	r21, 0x11	; 17
    72ea:	07 c0       	rjmp	.+14     	; 0x72fa <__udivmodhi4_ep>

000072ec <__udivmodhi4_loop>:
    72ec:	aa 1f       	adc	r26, r26
    72ee:	bb 1f       	adc	r27, r27
    72f0:	a6 17       	cp	r26, r22
    72f2:	b7 07       	cpc	r27, r23
    72f4:	10 f0       	brcs	.+4      	; 0x72fa <__udivmodhi4_ep>
    72f6:	a6 1b       	sub	r26, r22
    72f8:	b7 0b       	sbc	r27, r23

000072fa <__udivmodhi4_ep>:
    72fa:	88 1f       	adc	r24, r24
    72fc:	99 1f       	adc	r25, r25
    72fe:	5a 95       	dec	r21
    7300:	a9 f7       	brne	.-22     	; 0x72ec <__udivmodhi4_loop>
    7302:	80 95       	com	r24
    7304:	90 95       	com	r25
    7306:	bc 01       	movw	r22, r24
    7308:	cd 01       	movw	r24, r26
    730a:	08 95       	ret

0000730c <__udivmodsi4>:
    730c:	a1 e2       	ldi	r26, 0x21	; 33
    730e:	1a 2e       	mov	r1, r26
    7310:	aa 1b       	sub	r26, r26
    7312:	bb 1b       	sub	r27, r27
    7314:	fd 01       	movw	r30, r26
    7316:	0d c0       	rjmp	.+26     	; 0x7332 <__udivmodsi4_ep>

00007318 <__udivmodsi4_loop>:
    7318:	aa 1f       	adc	r26, r26
    731a:	bb 1f       	adc	r27, r27
    731c:	ee 1f       	adc	r30, r30
    731e:	ff 1f       	adc	r31, r31
    7320:	a2 17       	cp	r26, r18
    7322:	b3 07       	cpc	r27, r19
    7324:	e4 07       	cpc	r30, r20
    7326:	f5 07       	cpc	r31, r21
    7328:	20 f0       	brcs	.+8      	; 0x7332 <__udivmodsi4_ep>
    732a:	a2 1b       	sub	r26, r18
    732c:	b3 0b       	sbc	r27, r19
    732e:	e4 0b       	sbc	r30, r20
    7330:	f5 0b       	sbc	r31, r21

00007332 <__udivmodsi4_ep>:
    7332:	66 1f       	adc	r22, r22
    7334:	77 1f       	adc	r23, r23
    7336:	88 1f       	adc	r24, r24
    7338:	99 1f       	adc	r25, r25
    733a:	1a 94       	dec	r1
    733c:	69 f7       	brne	.-38     	; 0x7318 <__udivmodsi4_loop>
    733e:	60 95       	com	r22
    7340:	70 95       	com	r23
    7342:	80 95       	com	r24
    7344:	90 95       	com	r25
    7346:	9b 01       	movw	r18, r22
    7348:	ac 01       	movw	r20, r24
    734a:	bd 01       	movw	r22, r26
    734c:	cf 01       	movw	r24, r30
    734e:	08 95       	ret

00007350 <__tablejump2__>:
    7350:	ee 0f       	add	r30, r30
    7352:	ff 1f       	adc	r31, r31
    7354:	05 90       	lpm	r0, Z+
    7356:	f4 91       	lpm	r31, Z
    7358:	e0 2d       	mov	r30, r0
    735a:	09 94       	ijmp

0000735c <__muluhisi3>:
    735c:	0e 94 b9 39 	call	0x7372	; 0x7372 <__umulhisi3>
    7360:	a5 9f       	mul	r26, r21
    7362:	90 0d       	add	r25, r0
    7364:	b4 9f       	mul	r27, r20
    7366:	90 0d       	add	r25, r0
    7368:	a4 9f       	mul	r26, r20
    736a:	80 0d       	add	r24, r0
    736c:	91 1d       	adc	r25, r1
    736e:	11 24       	eor	r1, r1
    7370:	08 95       	ret

00007372 <__umulhisi3>:
    7372:	a2 9f       	mul	r26, r18
    7374:	b0 01       	movw	r22, r0
    7376:	b3 9f       	mul	r27, r19
    7378:	c0 01       	movw	r24, r0
    737a:	a3 9f       	mul	r26, r19
    737c:	70 0d       	add	r23, r0
    737e:	81 1d       	adc	r24, r1
    7380:	11 24       	eor	r1, r1
    7382:	91 1d       	adc	r25, r1
    7384:	b2 9f       	mul	r27, r18
    7386:	70 0d       	add	r23, r0
    7388:	81 1d       	adc	r24, r1
    738a:	11 24       	eor	r1, r1
    738c:	91 1d       	adc	r25, r1
    738e:	08 95       	ret

00007390 <memcmp>:
    7390:	fb 01       	movw	r30, r22
    7392:	dc 01       	movw	r26, r24
    7394:	04 c0       	rjmp	.+8      	; 0x739e <memcmp+0xe>
    7396:	8d 91       	ld	r24, X+
    7398:	01 90       	ld	r0, Z+
    739a:	80 19       	sub	r24, r0
    739c:	21 f4       	brne	.+8      	; 0x73a6 <memcmp+0x16>
    739e:	41 50       	subi	r20, 0x01	; 1
    73a0:	50 40       	sbci	r21, 0x00	; 0
    73a2:	c8 f7       	brcc	.-14     	; 0x7396 <memcmp+0x6>
    73a4:	88 1b       	sub	r24, r24
    73a6:	99 0b       	sbc	r25, r25
    73a8:	08 95       	ret

000073aa <_exit>:
    73aa:	f8 94       	cli

000073ac <__stop_program>:
    73ac:	ff cf       	rjmp	.-2      	; 0x73ac <__stop_program>
