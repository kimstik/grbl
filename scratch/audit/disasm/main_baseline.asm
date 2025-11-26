
scratch/audit/builds/main_baseline.elf:     file format elf32-avr


Disassembly of section .text:

00000000 <__vectors>:
       0:	0c 94 68 01 	jmp	0x2d0	; 0x2d0 <__ctors_end>
       4:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
       8:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
       c:	0c 94 8b 2c 	jmp	0x5916	; 0x5916 <__vector_3>
      10:	0c 94 51 2c 	jmp	0x58a2	; 0x58a2 <__vector_4>
      14:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      18:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      1c:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      20:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      24:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      28:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      2c:	0c 94 d0 2c 	jmp	0x59a0	; 0x59a0 <__vector_11>
      30:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      34:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      38:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      3c:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      40:	0c 94 ba 2c 	jmp	0x5974	; 0x5974 <__vector_16>
      44:	0c 94 7a 01 	jmp	0x2f4	; 0x2f4 <__bad_interrupt>
      48:	0c 94 07 2f 	jmp	0x5e0e	; 0x5e0e <__vector_18>
      4c:	0c 94 a7 2f 	jmp	0x5f4e	; 0x5f4e <__vector_19>
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
     2ec:	0e 94 d1 2f 	call	0x5fa2	; 0x5fa2 <main>
     2f0:	0c 94 13 3a 	jmp	0x7426	; 0x7426 <_exit>

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
     350:	0e 94 ec 39 	call	0x73d8	; 0x73d8 <__muluhisi3>
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
     39e:	0e 94 eb 36 	call	0x6dd6	; 0x6dd6 <__floatunsisf>
     3a2:	4b 01       	movw	r8, r22
     3a4:	5c 01       	movw	r10, r24
     3a6:	20 e0       	ldi	r18, 0x00	; 0
     3a8:	30 e0       	ldi	r19, 0x00	; 0
     3aa:	a9 01       	movw	r20, r18
     3ac:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
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
     400:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
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
     41e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
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
     438:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
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
     4dc:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
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
     4f4:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
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
     55e:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
     562:	a5 01       	movw	r20, r10
     564:	94 01       	movw	r18, r8
     566:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
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
     68a:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     68e:	88 23       	and	r24, r24
     690:	b9 f0       	breq	.+46     	; 0x6c0 <limit_value_by_axis_maximum+0x80>
     692:	a7 01       	movw	r20, r14
     694:	96 01       	movw	r18, r12
     696:	f8 01       	movw	r30, r16
     698:	60 81       	ld	r22, Z
     69a:	71 81       	ldd	r23, Z+1	; 0x01
     69c:	82 81       	ldd	r24, Z+2	; 0x02
     69e:	93 81       	ldd	r25, Z+3	; 0x03
     6a0:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
     6a4:	6b 01       	movw	r12, r22
     6a6:	7c 01       	movw	r14, r24
     6a8:	e8 94       	clt
     6aa:	f7 f8       	bld	r15, 7
     6ac:	93 01       	movw	r18, r6
     6ae:	a4 01       	movw	r20, r8
     6b0:	c7 01       	movw	r24, r14
     6b2:	b6 01       	movw	r22, r12
     6b4:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
     6b8:	18 16       	cp	r1, r24
     6ba:	14 f0       	brlt	.+4      	; 0x6c0 <limit_value_by_axis_maximum+0x80>
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
     742:	7c 01       	movw	r14, r24
     744:	fc 01       	movw	r30, r24
     746:	02 a5       	ldd	r16, Z+42	; 0x2a
     748:	13 a5       	ldd	r17, Z+43	; 0x2b
     74a:	d4 a5       	ldd	r29, Z+44	; 0x2c
     74c:	c5 a5       	ldd	r28, Z+45	; 0x2d
     74e:	81 89       	ldd	r24, Z+17	; 0x11
     750:	80 ff       	sbrs	r24, 0
     752:	33 c0       	rjmp	.+102    	; 0x7ba <plan_compute_profile_nominal_speed+0x8a>
     754:	60 91 39 06 	lds	r22, 0x0639	; 0x800639 <sys+0x8>
     758:	70 e0       	ldi	r23, 0x00	; 0
     75a:	90 e0       	ldi	r25, 0x00	; 0
     75c:	80 e0       	ldi	r24, 0x00	; 0
     75e:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
     762:	2a e0       	ldi	r18, 0x0A	; 10
     764:	37 ed       	ldi	r19, 0xD7	; 215
     766:	43 e2       	ldi	r20, 0x23	; 35
     768:	5c e3       	ldi	r21, 0x3C	; 60
     76a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     76e:	9b 01       	movw	r18, r22
     770:	ac 01       	movw	r20, r24
     772:	b8 01       	movw	r22, r16
     774:	8d 2f       	mov	r24, r29
     776:	9c 2f       	mov	r25, r28
     778:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     77c:	8b 01       	movw	r16, r22
     77e:	d8 2f       	mov	r29, r24
     780:	c9 2f       	mov	r28, r25
     782:	20 e0       	ldi	r18, 0x00	; 0
     784:	30 e0       	ldi	r19, 0x00	; 0
     786:	40 e8       	ldi	r20, 0x80	; 128
     788:	5f e3       	ldi	r21, 0x3F	; 63
     78a:	b8 01       	movw	r22, r16
     78c:	8d 2f       	mov	r24, r29
     78e:	9c 2f       	mov	r25, r28
     790:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
     794:	18 16       	cp	r1, r24
     796:	24 f0       	brlt	.+8      	; 0x7a0 <plan_compute_profile_nominal_speed+0x70>
     798:	00 e0       	ldi	r16, 0x00	; 0
     79a:	10 e0       	ldi	r17, 0x00	; 0
     79c:	d0 e8       	ldi	r29, 0x80	; 128
     79e:	cf e3       	ldi	r28, 0x3F	; 63
     7a0:	b8 01       	movw	r22, r16
     7a2:	8d 2f       	mov	r24, r29
     7a4:	9c 2f       	mov	r25, r28
     7a6:	df 91       	pop	r29
     7a8:	cf 91       	pop	r28
     7aa:	1f 91       	pop	r17
     7ac:	0f 91       	pop	r16
     7ae:	ff 90       	pop	r15
     7b0:	ef 90       	pop	r14
     7b2:	df 90       	pop	r13
     7b4:	cf 90       	pop	r12
     7b6:	bf 90       	pop	r11
     7b8:	08 95       	ret
     7ba:	82 fd       	sbrc	r24, 2
     7bc:	17 c0       	rjmp	.+46     	; 0x7ec <plan_compute_profile_nominal_speed+0xbc>
     7be:	60 91 38 06 	lds	r22, 0x0638	; 0x800638 <sys+0x7>
     7c2:	70 e0       	ldi	r23, 0x00	; 0
     7c4:	90 e0       	ldi	r25, 0x00	; 0
     7c6:	80 e0       	ldi	r24, 0x00	; 0
     7c8:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
     7cc:	2a e0       	ldi	r18, 0x0A	; 10
     7ce:	37 ed       	ldi	r19, 0xD7	; 215
     7d0:	43 e2       	ldi	r20, 0x23	; 35
     7d2:	5c e3       	ldi	r21, 0x3C	; 60
     7d4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     7d8:	9b 01       	movw	r18, r22
     7da:	ac 01       	movw	r20, r24
     7dc:	b8 01       	movw	r22, r16
     7de:	8d 2f       	mov	r24, r29
     7e0:	9c 2f       	mov	r25, r28
     7e2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     7e6:	8b 01       	movw	r16, r22
     7e8:	d8 2f       	mov	r29, r24
     7ea:	c9 2f       	mov	r28, r25
     7ec:	f7 01       	movw	r30, r14
     7ee:	b6 a0       	ldd	r11, Z+38	; 0x26
     7f0:	c7 a0       	ldd	r12, Z+39	; 0x27
     7f2:	d0 a4       	ldd	r13, Z+40	; 0x28
     7f4:	f1 a4       	ldd	r15, Z+41	; 0x29
     7f6:	98 01       	movw	r18, r16
     7f8:	4d 2f       	mov	r20, r29
     7fa:	5c 2f       	mov	r21, r28
     7fc:	6b 2d       	mov	r22, r11
     7fe:	7c 2d       	mov	r23, r12
     800:	8d 2d       	mov	r24, r13
     802:	9f 2d       	mov	r25, r15
     804:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     808:	87 ff       	sbrs	r24, 7
     80a:	bb cf       	rjmp	.-138    	; 0x782 <plan_compute_profile_nominal_speed+0x52>
     80c:	0b 2d       	mov	r16, r11
     80e:	1c 2d       	mov	r17, r12
     810:	dd 2d       	mov	r29, r13
     812:	cf 2d       	mov	r28, r15
     814:	b6 cf       	rjmp	.-148    	; 0x782 <plan_compute_profile_nominal_speed+0x52>

00000816 <plan_get_current_block>:
     816:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
     81a:	90 91 f6 05 	lds	r25, 0x05F6	; 0x8005f6 <block_buffer_head>
     81e:	98 17       	cp	r25, r24
     820:	39 f0       	breq	.+14     	; 0x830 <plan_get_current_block+0x1a>
     822:	22 e3       	ldi	r18, 0x32	; 50
     824:	82 9f       	mul	r24, r18
     826:	c0 01       	movw	r24, r0
     828:	11 24       	eor	r1, r1
     82a:	8a 52       	subi	r24, 0x2A	; 42
     82c:	9d 4f       	sbci	r25, 0xFD	; 253
     82e:	08 95       	ret
     830:	90 e0       	ldi	r25, 0x00	; 0
     832:	80 e0       	ldi	r24, 0x00	; 0
     834:	08 95       	ret

00000836 <eeprom_put_char>:
     836:	f8 94       	cli
     838:	f9 99       	sbic	0x1f, 1	; 31
     83a:	fe cf       	rjmp	.-4      	; 0x838 <eeprom_put_char+0x2>
     83c:	92 bd       	out	0x22, r25	; 34
     83e:	81 bd       	out	0x21, r24	; 33
     840:	81 e0       	ldi	r24, 0x01	; 1
     842:	8f bb       	out	0x1f, r24	; 31
     844:	20 b5       	in	r18, 0x20	; 32
     846:	86 2f       	mov	r24, r22
     848:	82 27       	eor	r24, r18
     84a:	08 2e       	mov	r0, r24
     84c:	00 0c       	add	r0, r0
     84e:	99 0b       	sbc	r25, r25
     850:	50 e0       	ldi	r21, 0x00	; 0
     852:	86 23       	and	r24, r22
     854:	95 23       	and	r25, r21
     856:	89 2b       	or	r24, r25
     858:	49 f0       	breq	.+18     	; 0x86c <eeprom_put_char+0x36>
     85a:	84 e1       	ldi	r24, 0x14	; 20
     85c:	6f 3f       	cpi	r22, 0xFF	; 255
     85e:	11 f0       	breq	.+4      	; 0x864 <eeprom_put_char+0x2e>
     860:	60 bd       	out	0x20, r22	; 32
     862:	84 e0       	ldi	r24, 0x04	; 4
     864:	8f bb       	out	0x1f, r24	; 31
     866:	f9 9a       	sbi	0x1f, 1	; 31
     868:	78 94       	sei
     86a:	08 95       	ret
     86c:	26 17       	cp	r18, r22
     86e:	e1 f3       	breq	.-8      	; 0x868 <eeprom_put_char+0x32>
     870:	60 bd       	out	0x20, r22	; 32
     872:	84 e2       	ldi	r24, 0x24	; 36
     874:	f7 cf       	rjmp	.-18     	; 0x864 <eeprom_put_char+0x2e>

00000876 <memcpy_to_eeprom_with_checksum>:
     876:	9f 92       	push	r9
     878:	af 92       	push	r10
     87a:	bf 92       	push	r11
     87c:	cf 92       	push	r12
     87e:	df 92       	push	r13
     880:	ef 92       	push	r14
     882:	ff 92       	push	r15
     884:	0f 93       	push	r16
     886:	1f 93       	push	r17
     888:	cf 93       	push	r28
     88a:	df 93       	push	r29
     88c:	5c 01       	movw	r10, r24
     88e:	8a 01       	movw	r16, r20
     890:	7b 01       	movw	r14, r22
     892:	e4 0e       	add	r14, r20
     894:	f5 1e       	adc	r15, r21
     896:	eb 01       	movw	r28, r22
     898:	91 2c       	mov	r9, r1
     89a:	6c 01       	movw	r12, r24
     89c:	c6 1a       	sub	r12, r22
     89e:	d7 0a       	sbc	r13, r23
     8a0:	ce 01       	movw	r24, r28
     8a2:	8c 0d       	add	r24, r12
     8a4:	9d 1d       	adc	r25, r13
     8a6:	21 e0       	ldi	r18, 0x01	; 1
     8a8:	91 10       	cpse	r9, r1
     8aa:	07 c0       	rjmp	.+14     	; 0x8ba <memcpy_to_eeprom_with_checksum+0x44>
     8ac:	29 2d       	mov	r18, r9
     8ae:	99 0c       	add	r9, r9
     8b0:	33 0b       	sbc	r19, r19
     8b2:	23 2f       	mov	r18, r19
     8b4:	22 1f       	adc	r18, r18
     8b6:	22 27       	eor	r18, r18
     8b8:	22 1f       	adc	r18, r18
     8ba:	69 91       	ld	r22, Y+
     8bc:	96 2e       	mov	r9, r22
     8be:	92 0e       	add	r9, r18
     8c0:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
     8c4:	ce 15       	cp	r28, r14
     8c6:	df 05       	cpc	r29, r15
     8c8:	59 f7       	brne	.-42     	; 0x8a0 <memcpy_to_eeprom_with_checksum+0x2a>
     8ca:	69 2d       	mov	r22, r9
     8cc:	c5 01       	movw	r24, r10
     8ce:	80 0f       	add	r24, r16
     8d0:	91 1f       	adc	r25, r17
     8d2:	df 91       	pop	r29
     8d4:	cf 91       	pop	r28
     8d6:	1f 91       	pop	r17
     8d8:	0f 91       	pop	r16
     8da:	ff 90       	pop	r15
     8dc:	ef 90       	pop	r14
     8de:	df 90       	pop	r13
     8e0:	cf 90       	pop	r12
     8e2:	bf 90       	pop	r11
     8e4:	af 90       	pop	r10
     8e6:	9f 90       	pop	r9
     8e8:	0c 94 1b 04 	jmp	0x836	; 0x836 <eeprom_put_char>

000008ec <write_global_settings>:
     8ec:	6a e0       	ldi	r22, 0x0A	; 10
     8ee:	90 e0       	ldi	r25, 0x00	; 0
     8f0:	80 e0       	ldi	r24, 0x00	; 0
     8f2:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
     8f6:	45 e5       	ldi	r20, 0x55	; 85
     8f8:	50 e0       	ldi	r21, 0x00	; 0
     8fa:	62 e4       	ldi	r22, 0x42	; 66
     8fc:	76 e0       	ldi	r23, 0x06	; 6
     8fe:	81 e0       	ldi	r24, 0x01	; 1
     900:	90 e0       	ldi	r25, 0x00	; 0
     902:	0c 94 3b 04 	jmp	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>

00000906 <eeprom_get_char>:
     906:	f9 99       	sbic	0x1f, 1	; 31
     908:	fe cf       	rjmp	.-4      	; 0x906 <eeprom_get_char>
     90a:	92 bd       	out	0x22, r25	; 34
     90c:	81 bd       	out	0x21, r24	; 33
     90e:	81 e0       	ldi	r24, 0x01	; 1
     910:	8f bb       	out	0x1f, r24	; 31
     912:	80 b5       	in	r24, 0x20	; 32
     914:	08 95       	ret

00000916 <memcpy_from_eeprom_with_checksum>:
     916:	9f 92       	push	r9
     918:	af 92       	push	r10
     91a:	bf 92       	push	r11
     91c:	cf 92       	push	r12
     91e:	df 92       	push	r13
     920:	ef 92       	push	r14
     922:	ff 92       	push	r15
     924:	0f 93       	push	r16
     926:	1f 93       	push	r17
     928:	cf 93       	push	r28
     92a:	df 93       	push	r29
     92c:	5b 01       	movw	r10, r22
     92e:	8a 01       	movw	r16, r20
     930:	7c 01       	movw	r14, r24
     932:	e4 0e       	add	r14, r20
     934:	f5 1e       	adc	r15, r21
     936:	ec 01       	movw	r28, r24
     938:	91 2c       	mov	r9, r1
     93a:	6b 01       	movw	r12, r22
     93c:	c8 1a       	sub	r12, r24
     93e:	d9 0a       	sbc	r13, r25
     940:	c6 01       	movw	r24, r12
     942:	8c 0f       	add	r24, r28
     944:	9d 1f       	adc	r25, r29
     946:	0e 94 83 04 	call	0x906	; 0x906 <eeprom_get_char>
     94a:	21 e0       	ldi	r18, 0x01	; 1
     94c:	91 10       	cpse	r9, r1
     94e:	07 c0       	rjmp	.+14     	; 0x95e <memcpy_from_eeprom_with_checksum+0x48>
     950:	29 2d       	mov	r18, r9
     952:	99 0c       	add	r9, r9
     954:	33 0b       	sbc	r19, r19
     956:	23 2f       	mov	r18, r19
     958:	22 1f       	adc	r18, r18
     95a:	22 27       	eor	r18, r18
     95c:	22 1f       	adc	r18, r18
     95e:	98 2e       	mov	r9, r24
     960:	92 0e       	add	r9, r18
     962:	89 93       	st	Y+, r24
     964:	ce 15       	cp	r28, r14
     966:	df 05       	cpc	r29, r15
     968:	59 f7       	brne	.-42     	; 0x940 <memcpy_from_eeprom_with_checksum+0x2a>
     96a:	c5 01       	movw	r24, r10
     96c:	80 0f       	add	r24, r16
     96e:	91 1f       	adc	r25, r17
     970:	0e 94 83 04 	call	0x906	; 0x906 <eeprom_get_char>
     974:	21 e0       	ldi	r18, 0x01	; 1
     976:	30 e0       	ldi	r19, 0x00	; 0
     978:	89 15       	cp	r24, r9
     97a:	11 f0       	breq	.+4      	; 0x980 <memcpy_from_eeprom_with_checksum+0x6a>
     97c:	30 e0       	ldi	r19, 0x00	; 0
     97e:	20 e0       	ldi	r18, 0x00	; 0
     980:	c9 01       	movw	r24, r18
     982:	df 91       	pop	r29
     984:	cf 91       	pop	r28
     986:	1f 91       	pop	r17
     988:	0f 91       	pop	r16
     98a:	ff 90       	pop	r15
     98c:	ef 90       	pop	r14
     98e:	df 90       	pop	r13
     990:	cf 90       	pop	r12
     992:	bf 90       	pop	r11
     994:	af 90       	pop	r10
     996:	9f 90       	pop	r9
     998:	08 95       	ret

0000099a <st_update_plan_block_parameters>:
     99a:	cf 93       	push	r28
     99c:	df 93       	push	r29
     99e:	c0 91 d1 02 	lds	r28, 0x02D1	; 0x8002d1 <pl_block>
     9a2:	d0 91 d2 02 	lds	r29, 0x02D2	; 0x8002d2 <pl_block+0x1>
     9a6:	20 97       	sbiw	r28, 0x00	; 0
     9a8:	c9 f0       	breq	.+50     	; 0x9dc <st_update_plan_block_parameters+0x42>
     9aa:	80 91 a2 02 	lds	r24, 0x02A2	; 0x8002a2 <prep+0x1>
     9ae:	81 60       	ori	r24, 0x01	; 1
     9b0:	80 93 a2 02 	sts	0x02A2, r24	; 0x8002a2 <prep+0x1>
     9b4:	60 91 b8 02 	lds	r22, 0x02B8	; 0x8002b8 <prep+0x17>
     9b8:	70 91 b9 02 	lds	r23, 0x02B9	; 0x8002b9 <prep+0x18>
     9bc:	80 91 ba 02 	lds	r24, 0x02BA	; 0x8002ba <prep+0x19>
     9c0:	90 91 bb 02 	lds	r25, 0x02BB	; 0x8002bb <prep+0x1a>
     9c4:	9b 01       	movw	r18, r22
     9c6:	ac 01       	movw	r20, r24
     9c8:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     9cc:	6a 8b       	std	Y+18, r22	; 0x12
     9ce:	7b 8b       	std	Y+19, r23	; 0x13
     9d0:	8c 8b       	std	Y+20, r24	; 0x14
     9d2:	9d 8b       	std	Y+21, r25	; 0x15
     9d4:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
     9d8:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
     9dc:	df 91       	pop	r29
     9de:	cf 91       	pop	r28
     9e0:	08 95       	ret

000009e2 <planner_recalculate>:
     9e2:	2f 92       	push	r2
     9e4:	3f 92       	push	r3
     9e6:	4f 92       	push	r4
     9e8:	5f 92       	push	r5
     9ea:	6f 92       	push	r6
     9ec:	7f 92       	push	r7
     9ee:	8f 92       	push	r8
     9f0:	9f 92       	push	r9
     9f2:	af 92       	push	r10
     9f4:	bf 92       	push	r11
     9f6:	cf 92       	push	r12
     9f8:	df 92       	push	r13
     9fa:	ef 92       	push	r14
     9fc:	ff 92       	push	r15
     9fe:	0f 93       	push	r16
     a00:	1f 93       	push	r17
     a02:	cf 93       	push	r28
     a04:	df 93       	push	r29
     a06:	00 d0       	rcall	.+0      	; 0xa08 <planner_recalculate+0x26>
     a08:	00 d0       	rcall	.+0      	; 0xa0a <planner_recalculate+0x28>
     a0a:	cd b7       	in	r28, 0x3d	; 61
     a0c:	de b7       	in	r29, 0x3e	; 62
     a0e:	00 91 f6 05 	lds	r16, 0x05F6	; 0x8005f6 <block_buffer_head>
     a12:	00 23       	and	r16, r16
     a14:	09 f4       	brne	.+2      	; 0xa18 <planner_recalculate+0x36>
     a16:	86 c0       	rjmp	.+268    	; 0xb24 <planner_recalculate+0x142>
     a18:	09 83       	std	Y+1, r16	; 0x01
     a1a:	39 81       	ldd	r19, Y+1	; 0x01
     a1c:	31 50       	subi	r19, 0x01	; 1
     a1e:	39 83       	std	Y+1, r19	; 0x01
     a20:	10 91 d3 02 	lds	r17, 0x02D3	; 0x8002d3 <block_buffer_planned>
     a24:	13 17       	cp	r17, r19
     a26:	09 f4       	brne	.+2      	; 0xa2a <planner_recalculate+0x48>
     a28:	66 c0       	rjmp	.+204    	; 0xaf6 <planner_recalculate+0x114>
     a2a:	c3 2e       	mov	r12, r19
     a2c:	d1 2c       	mov	r13, r1
     a2e:	e2 e3       	ldi	r30, 0x32	; 50
     a30:	3e 9f       	mul	r19, r30
     a32:	c0 01       	movw	r24, r0
     a34:	11 24       	eor	r1, r1
     a36:	9c 01       	movw	r18, r24
     a38:	2a 52       	subi	r18, 0x2A	; 42
     a3a:	3d 4f       	sbci	r19, 0xFD	; 253
     a3c:	79 01       	movw	r14, r18
     a3e:	f9 01       	movw	r30, r18
     a40:	76 88       	ldd	r7, Z+22	; 0x16
     a42:	87 88       	ldd	r8, Z+23	; 0x17
     a44:	90 8c       	ldd	r9, Z+24	; 0x18
     a46:	a1 8c       	ldd	r10, Z+25	; 0x19
     a48:	62 8d       	ldd	r22, Z+26	; 0x1a
     a4a:	73 8d       	ldd	r23, Z+27	; 0x1b
     a4c:	84 8d       	ldd	r24, Z+28	; 0x1c
     a4e:	95 8d       	ldd	r25, Z+29	; 0x1d
     a50:	9b 01       	movw	r18, r22
     a52:	ac 01       	movw	r20, r24
     a54:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     a58:	f7 01       	movw	r30, r14
     a5a:	26 8d       	ldd	r18, Z+30	; 0x1e
     a5c:	37 8d       	ldd	r19, Z+31	; 0x1f
     a5e:	40 a1       	ldd	r20, Z+32	; 0x20
     a60:	51 a1       	ldd	r21, Z+33	; 0x21
     a62:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     a66:	b6 2e       	mov	r11, r22
     a68:	e7 2e       	mov	r14, r23
     a6a:	f8 2e       	mov	r15, r24
     a6c:	9b 83       	std	Y+3, r25	; 0x03
     a6e:	26 2f       	mov	r18, r22
     a70:	37 2f       	mov	r19, r23
     a72:	48 2f       	mov	r20, r24
     a74:	59 2f       	mov	r21, r25
     a76:	67 2d       	mov	r22, r7
     a78:	78 2d       	mov	r23, r8
     a7a:	89 2d       	mov	r24, r9
     a7c:	9a 2d       	mov	r25, r10
     a7e:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     a82:	87 ff       	sbrs	r24, 7
     a84:	03 c0       	rjmp	.+6      	; 0xa8c <planner_recalculate+0xaa>
     a86:	b7 2c       	mov	r11, r7
     a88:	74 01       	movw	r14, r8
     a8a:	ab 82       	std	Y+3, r10	; 0x03
     a8c:	82 e3       	ldi	r24, 0x32	; 50
     a8e:	8c 9d       	mul	r24, r12
     a90:	f0 01       	movw	r30, r0
     a92:	8d 9d       	mul	r24, r13
     a94:	f0 0d       	add	r31, r0
     a96:	11 24       	eor	r1, r1
     a98:	ea 52       	subi	r30, 0x2A	; 42
     a9a:	fd 4f       	sbci	r31, 0xFD	; 253
     a9c:	8b 2d       	mov	r24, r11
     a9e:	9e 2d       	mov	r25, r14
     aa0:	af 2d       	mov	r26, r15
     aa2:	bb 81       	ldd	r27, Y+3	; 0x03
     aa4:	82 8b       	std	Z+18, r24	; 0x12
     aa6:	93 8b       	std	Z+19, r25	; 0x13
     aa8:	a4 8b       	std	Z+20, r26	; 0x14
     aaa:	b5 8b       	std	Z+21, r27	; 0x15
     aac:	f9 81       	ldd	r31, Y+1	; 0x01
     aae:	8f 2f       	mov	r24, r31
     ab0:	f1 11       	cpse	r31, r1
     ab2:	01 c0       	rjmp	.+2      	; 0xab6 <planner_recalculate+0xd4>
     ab4:	80 e1       	ldi	r24, 0x10	; 16
     ab6:	ff 24       	eor	r15, r15
     ab8:	fa 94       	dec	r15
     aba:	f8 0e       	add	r15, r24
     abc:	30 90 d5 02 	lds	r3, 0x02D5	; 0x8002d5 <block_buffer_tail>
     ac0:	1f 11       	cpse	r17, r15
     ac2:	33 c0       	rjmp	.+102    	; 0xb2a <planner_recalculate+0x148>
     ac4:	13 11       	cpse	r17, r3
     ac6:	02 c0       	rjmp	.+4      	; 0xacc <planner_recalculate+0xea>
     ac8:	0e 94 cd 04 	call	0x99a	; 0x99a <st_update_plan_block_parameters>
     acc:	e2 e3       	ldi	r30, 0x32	; 50
     ace:	1e 9f       	mul	r17, r30
     ad0:	c0 01       	movw	r24, r0
     ad2:	11 24       	eor	r1, r1
     ad4:	8a 52       	subi	r24, 0x2A	; 42
     ad6:	9d 4f       	sbci	r25, 0xFD	; 253
     ad8:	9a 83       	std	Y+2, r25	; 0x02
     ada:	89 83       	std	Y+1, r24	; 0x01
     adc:	33 24       	eor	r3, r3
     ade:	33 94       	inc	r3
     ae0:	31 0e       	add	r3, r17
     ae2:	f0 e1       	ldi	r31, 0x10	; 16
     ae4:	3f 12       	cpse	r3, r31
     ae6:	01 c0       	rjmp	.+2      	; 0xaea <planner_recalculate+0x108>
     ae8:	31 2c       	mov	r3, r1
     aea:	82 e3       	ldi	r24, 0x32	; 50
     aec:	28 2e       	mov	r2, r24
     aee:	03 11       	cpse	r16, r3
     af0:	85 c0       	rjmp	.+266    	; 0xbfc <planner_recalculate+0x21a>
     af2:	10 93 d3 02 	sts	0x02D3, r17	; 0x8002d3 <block_buffer_planned>
     af6:	0f 90       	pop	r0
     af8:	0f 90       	pop	r0
     afa:	0f 90       	pop	r0
     afc:	0f 90       	pop	r0
     afe:	df 91       	pop	r29
     b00:	cf 91       	pop	r28
     b02:	1f 91       	pop	r17
     b04:	0f 91       	pop	r16
     b06:	ff 90       	pop	r15
     b08:	ef 90       	pop	r14
     b0a:	df 90       	pop	r13
     b0c:	cf 90       	pop	r12
     b0e:	bf 90       	pop	r11
     b10:	af 90       	pop	r10
     b12:	9f 90       	pop	r9
     b14:	8f 90       	pop	r8
     b16:	7f 90       	pop	r7
     b18:	6f 90       	pop	r6
     b1a:	5f 90       	pop	r5
     b1c:	4f 90       	pop	r4
     b1e:	3f 90       	pop	r3
     b20:	2f 90       	pop	r2
     b22:	08 95       	ret
     b24:	20 e1       	ldi	r18, 0x10	; 16
     b26:	29 83       	std	Y+1, r18	; 0x01
     b28:	78 cf       	rjmp	.-272    	; 0xa1a <planner_recalculate+0x38>
     b2a:	29 81       	ldd	r18, Y+1	; 0x01
     b2c:	82 e3       	ldi	r24, 0x32	; 50
     b2e:	28 9f       	mul	r18, r24
     b30:	90 01       	movw	r18, r0
     b32:	11 24       	eor	r1, r1
     b34:	2a 52       	subi	r18, 0x2A	; 42
     b36:	3d 4f       	sbci	r19, 0xFD	; 253
     b38:	3c 83       	std	Y+4, r19	; 0x04
     b3a:	2b 83       	std	Y+3, r18	; 0x03
     b3c:	22 e3       	ldi	r18, 0x32	; 50
     b3e:	e2 2e       	mov	r14, r18
     b40:	8f 2c       	mov	r8, r15
     b42:	91 2c       	mov	r9, r1
     b44:	fe 9c       	mul	r15, r14
     b46:	c0 01       	movw	r24, r0
     b48:	11 24       	eor	r1, r1
     b4a:	fc 01       	movw	r30, r24
     b4c:	ea 52       	subi	r30, 0x2A	; 42
     b4e:	fd 4f       	sbci	r31, 0xFD	; 253
     b50:	fa 83       	std	Y+2, r31	; 0x02
     b52:	e9 83       	std	Y+1, r30	; 0x01
     b54:	f1 10       	cpse	r15, r1
     b56:	02 c0       	rjmp	.+4      	; 0xb5c <planner_recalculate+0x17a>
     b58:	90 e1       	ldi	r25, 0x10	; 16
     b5a:	f9 2e       	mov	r15, r25
     b5c:	fa 94       	dec	r15
     b5e:	f3 10       	cpse	r15, r3
     b60:	02 c0       	rjmp	.+4      	; 0xb66 <planner_recalculate+0x184>
     b62:	0e 94 cd 04 	call	0x99a	; 0x99a <st_update_plan_block_parameters>
     b66:	e8 9c       	mul	r14, r8
     b68:	c0 01       	movw	r24, r0
     b6a:	e9 9c       	mul	r14, r9
     b6c:	90 0d       	add	r25, r0
     b6e:	11 24       	eor	r1, r1
     b70:	9c 01       	movw	r18, r24
     b72:	2a 52       	subi	r18, 0x2A	; 42
     b74:	3d 4f       	sbci	r19, 0xFD	; 253
     b76:	69 01       	movw	r12, r18
     b78:	f9 01       	movw	r30, r18
     b7a:	46 88       	ldd	r4, Z+22	; 0x16
     b7c:	57 88       	ldd	r5, Z+23	; 0x17
     b7e:	60 8c       	ldd	r6, Z+24	; 0x18
     b80:	71 8c       	ldd	r7, Z+25	; 0x19
     b82:	a3 01       	movw	r20, r6
     b84:	92 01       	movw	r18, r4
     b86:	62 89       	ldd	r22, Z+18	; 0x12
     b88:	73 89       	ldd	r23, Z+19	; 0x13
     b8a:	84 89       	ldd	r24, Z+20	; 0x14
     b8c:	95 89       	ldd	r25, Z+21	; 0x15
     b8e:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     b92:	88 23       	and	r24, r24
     b94:	39 f1       	breq	.+78     	; 0xbe4 <planner_recalculate+0x202>
     b96:	f6 01       	movw	r30, r12
     b98:	62 8d       	ldd	r22, Z+26	; 0x1a
     b9a:	73 8d       	ldd	r23, Z+27	; 0x1b
     b9c:	84 8d       	ldd	r24, Z+28	; 0x1c
     b9e:	95 8d       	ldd	r25, Z+29	; 0x1d
     ba0:	9b 01       	movw	r18, r22
     ba2:	ac 01       	movw	r20, r24
     ba4:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     ba8:	f6 01       	movw	r30, r12
     baa:	26 8d       	ldd	r18, Z+30	; 0x1e
     bac:	37 8d       	ldd	r19, Z+31	; 0x1f
     bae:	40 a1       	ldd	r20, Z+32	; 0x20
     bb0:	51 a1       	ldd	r21, Z+33	; 0x21
     bb2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     bb6:	eb 81       	ldd	r30, Y+3	; 0x03
     bb8:	fc 81       	ldd	r31, Y+4	; 0x04
     bba:	22 89       	ldd	r18, Z+18	; 0x12
     bbc:	33 89       	ldd	r19, Z+19	; 0x13
     bbe:	44 89       	ldd	r20, Z+20	; 0x14
     bc0:	55 89       	ldd	r21, Z+21	; 0x15
     bc2:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     bc6:	4b 01       	movw	r8, r22
     bc8:	5c 01       	movw	r10, r24
     bca:	ac 01       	movw	r20, r24
     bcc:	9b 01       	movw	r18, r22
     bce:	c3 01       	movw	r24, r6
     bd0:	b2 01       	movw	r22, r4
     bd2:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
     bd6:	f6 01       	movw	r30, r12
     bd8:	18 16       	cp	r1, r24
     bda:	5c f4       	brge	.+22     	; 0xbf2 <planner_recalculate+0x210>
     bdc:	82 8a       	std	Z+18, r8	; 0x12
     bde:	93 8a       	std	Z+19, r9	; 0x13
     be0:	a4 8a       	std	Z+20, r10	; 0x14
     be2:	b5 8a       	std	Z+21, r11	; 0x15
     be4:	29 81       	ldd	r18, Y+1	; 0x01
     be6:	3a 81       	ldd	r19, Y+2	; 0x02
     be8:	3c 83       	std	Y+4, r19	; 0x04
     bea:	2b 83       	std	Y+3, r18	; 0x03
     bec:	1f 11       	cpse	r17, r15
     bee:	a8 cf       	rjmp	.-176    	; 0xb40 <planner_recalculate+0x15e>
     bf0:	6d cf       	rjmp	.-294    	; 0xacc <planner_recalculate+0xea>
     bf2:	42 8a       	std	Z+18, r4	; 0x12
     bf4:	53 8a       	std	Z+19, r5	; 0x13
     bf6:	64 8a       	std	Z+20, r6	; 0x14
     bf8:	75 8a       	std	Z+21, r7	; 0x15
     bfa:	f4 cf       	rjmp	.-24     	; 0xbe4 <planner_recalculate+0x202>
     bfc:	c3 2c       	mov	r12, r3
     bfe:	d1 2c       	mov	r13, r1
     c00:	32 9c       	mul	r3, r2
     c02:	c0 01       	movw	r24, r0
     c04:	11 24       	eor	r1, r1
     c06:	9c 01       	movw	r18, r24
     c08:	2a 52       	subi	r18, 0x2A	; 42
     c0a:	3d 4f       	sbci	r19, 0xFD	; 253
     c0c:	79 01       	movw	r14, r18
     c0e:	e9 81       	ldd	r30, Y+1	; 0x01
     c10:	fa 81       	ldd	r31, Y+2	; 0x02
     c12:	42 88       	ldd	r4, Z+18	; 0x12
     c14:	53 88       	ldd	r5, Z+19	; 0x13
     c16:	64 88       	ldd	r6, Z+20	; 0x14
     c18:	75 88       	ldd	r7, Z+21	; 0x15
     c1a:	f9 01       	movw	r30, r18
     c1c:	82 88       	ldd	r8, Z+18	; 0x12
     c1e:	93 88       	ldd	r9, Z+19	; 0x13
     c20:	a4 88       	ldd	r10, Z+20	; 0x14
     c22:	b5 88       	ldd	r11, Z+21	; 0x15
     c24:	a5 01       	movw	r20, r10
     c26:	94 01       	movw	r18, r8
     c28:	c3 01       	movw	r24, r6
     c2a:	b2 01       	movw	r22, r4
     c2c:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     c30:	87 ff       	sbrs	r24, 7
     c32:	26 c0       	rjmp	.+76     	; 0xc80 <planner_recalculate+0x29e>
     c34:	e9 81       	ldd	r30, Y+1	; 0x01
     c36:	fa 81       	ldd	r31, Y+2	; 0x02
     c38:	62 8d       	ldd	r22, Z+26	; 0x1a
     c3a:	73 8d       	ldd	r23, Z+27	; 0x1b
     c3c:	84 8d       	ldd	r24, Z+28	; 0x1c
     c3e:	95 8d       	ldd	r25, Z+29	; 0x1d
     c40:	9b 01       	movw	r18, r22
     c42:	ac 01       	movw	r20, r24
     c44:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     c48:	e9 81       	ldd	r30, Y+1	; 0x01
     c4a:	fa 81       	ldd	r31, Y+2	; 0x02
     c4c:	26 8d       	ldd	r18, Z+30	; 0x1e
     c4e:	37 8d       	ldd	r19, Z+31	; 0x1f
     c50:	40 a1       	ldd	r20, Z+32	; 0x20
     c52:	51 a1       	ldd	r21, Z+33	; 0x21
     c54:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     c58:	a3 01       	movw	r20, r6
     c5a:	92 01       	movw	r18, r4
     c5c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     c60:	2b 01       	movw	r4, r22
     c62:	3c 01       	movw	r6, r24
     c64:	ac 01       	movw	r20, r24
     c66:	9b 01       	movw	r18, r22
     c68:	c5 01       	movw	r24, r10
     c6a:	b4 01       	movw	r22, r8
     c6c:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
     c70:	18 16       	cp	r1, r24
     c72:	34 f4       	brge	.+12     	; 0xc80 <planner_recalculate+0x29e>
     c74:	f7 01       	movw	r30, r14
     c76:	42 8a       	std	Z+18, r4	; 0x12
     c78:	53 8a       	std	Z+19, r5	; 0x13
     c7a:	64 8a       	std	Z+20, r6	; 0x14
     c7c:	75 8a       	std	Z+21, r7	; 0x15
     c7e:	13 2d       	mov	r17, r3
     c80:	2c 9c       	mul	r2, r12
     c82:	f0 01       	movw	r30, r0
     c84:	2d 9c       	mul	r2, r13
     c86:	f0 0d       	add	r31, r0
     c88:	11 24       	eor	r1, r1
     c8a:	ea 52       	subi	r30, 0x2A	; 42
     c8c:	fd 4f       	sbci	r31, 0xFD	; 253
     c8e:	26 89       	ldd	r18, Z+22	; 0x16
     c90:	37 89       	ldd	r19, Z+23	; 0x17
     c92:	40 8d       	ldd	r20, Z+24	; 0x18
     c94:	51 8d       	ldd	r21, Z+25	; 0x19
     c96:	62 89       	ldd	r22, Z+18	; 0x12
     c98:	73 89       	ldd	r23, Z+19	; 0x13
     c9a:	84 89       	ldd	r24, Z+20	; 0x14
     c9c:	95 89       	ldd	r25, Z+21	; 0x15
     c9e:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     ca2:	81 11       	cpse	r24, r1
     ca4:	01 c0       	rjmp	.+2      	; 0xca8 <planner_recalculate+0x2c6>
     ca6:	13 2d       	mov	r17, r3
     ca8:	33 94       	inc	r3
     caa:	f0 e1       	ldi	r31, 0x10	; 16
     cac:	3f 12       	cpse	r3, r31
     cae:	01 c0       	rjmp	.+2      	; 0xcb2 <planner_recalculate+0x2d0>
     cb0:	31 2c       	mov	r3, r1
     cb2:	fa 82       	std	Y+2, r15	; 0x02
     cb4:	e9 82       	std	Y+1, r14	; 0x01
     cb6:	1b cf       	rjmp	.-458    	; 0xaee <planner_recalculate+0x10c>

00000cb8 <st_generate_step_dir_invert_masks>:
     cb8:	90 91 73 06 	lds	r25, 0x0673	; 0x800673 <settings+0x31>
     cbc:	49 2f       	mov	r20, r25
     cbe:	80 91 74 06 	lds	r24, 0x0674	; 0x800674 <settings+0x32>
     cc2:	28 2f       	mov	r18, r24
     cc4:	90 ff       	sbrs	r25, 0
     cc6:	11 c0       	rjmp	.+34     	; 0xcea <st_generate_step_dir_invert_masks+0x32>
     cc8:	94 e0       	ldi	r25, 0x04	; 4
     cca:	80 ff       	sbrs	r24, 0
     ccc:	10 c0       	rjmp	.+32     	; 0xcee <st_generate_step_dir_invert_masks+0x36>
     cce:	80 e2       	ldi	r24, 0x20	; 32
     cd0:	41 fd       	sbrc	r20, 1
     cd2:	98 60       	ori	r25, 0x08	; 8
     cd4:	21 fd       	sbrc	r18, 1
     cd6:	80 64       	ori	r24, 0x40	; 64
     cd8:	42 fd       	sbrc	r20, 2
     cda:	90 61       	ori	r25, 0x10	; 16
     cdc:	22 fd       	sbrc	r18, 2
     cde:	80 68       	ori	r24, 0x80	; 128
     ce0:	90 93 f2 01 	sts	0x01F2, r25	; 0x8001f2 <step_port_invert_mask>
     ce4:	80 93 f3 01 	sts	0x01F3, r24	; 0x8001f3 <dir_port_invert_mask>
     ce8:	08 95       	ret
     cea:	90 e0       	ldi	r25, 0x00	; 0
     cec:	ee cf       	rjmp	.-36     	; 0xcca <st_generate_step_dir_invert_masks+0x12>
     cee:	80 e0       	ldi	r24, 0x00	; 0
     cf0:	ef cf       	rjmp	.-34     	; 0xcd0 <st_generate_step_dir_invert_masks+0x18>

00000cf2 <st_wake_up>:
     cf2:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
     cf6:	82 ff       	sbrs	r24, 2
     cf8:	13 c0       	rjmp	.+38     	; 0xd20 <st_wake_up+0x2e>
     cfa:	28 9a       	sbi	0x05, 0	; 5
     cfc:	80 91 f2 01 	lds	r24, 0x01F2	; 0x8001f2 <step_port_invert_mask>
     d00:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
     d04:	80 91 72 06 	lds	r24, 0x0672	; 0x800672 <settings+0x30>
     d08:	82 50       	subi	r24, 0x02	; 2
     d0a:	99 0b       	sbc	r25, r25
     d0c:	88 0f       	add	r24, r24
     d0e:	81 95       	neg	r24
     d10:	80 93 02 02 	sts	0x0202, r24	; 0x800202 <st+0xd>
     d14:	80 91 6f 00 	lds	r24, 0x006F	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
     d18:	82 60       	ori	r24, 0x02	; 2
     d1a:	80 93 6f 00 	sts	0x006F, r24	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
     d1e:	08 95       	ret
     d20:	28 98       	cbi	0x05, 0	; 5
     d22:	ec cf       	rjmp	.-40     	; 0xcfc <st_wake_up+0xa>

00000d24 <protocol_auto_cycle_start>:
     d24:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
     d28:	89 2b       	or	r24, r25
     d2a:	19 f0       	breq	.+6      	; 0xd32 <protocol_auto_cycle_start+0xe>
     d2c:	82 e0       	ldi	r24, 0x02	; 2
     d2e:	0c 94 4b 02 	jmp	0x496	; 0x496 <system_set_exec_state_flag>
     d32:	08 95       	ret

00000d34 <serial_write>:
     d34:	e0 91 04 01 	lds	r30, 0x0104	; 0x800104 <serial_tx_buffer_head>
     d38:	91 e0       	ldi	r25, 0x01	; 1
     d3a:	9e 0f       	add	r25, r30
     d3c:	99 36       	cpi	r25, 0x69	; 105
     d3e:	09 f4       	brne	.+2      	; 0xd42 <serial_write+0xe>
     d40:	90 e0       	ldi	r25, 0x00	; 0
     d42:	20 91 6e 01 	lds	r18, 0x016E	; 0x80016e <serial_tx_buffer_tail>
     d46:	29 17       	cp	r18, r25
     d48:	61 f0       	breq	.+24     	; 0xd62 <serial_write+0x2e>
     d4a:	f0 e0       	ldi	r31, 0x00	; 0
     d4c:	eb 5f       	subi	r30, 0xFB	; 251
     d4e:	fe 4f       	sbci	r31, 0xFE	; 254
     d50:	80 83       	st	Z, r24
     d52:	90 93 04 01 	sts	0x0104, r25	; 0x800104 <serial_tx_buffer_head>
     d56:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
     d5a:	80 62       	ori	r24, 0x20	; 32
     d5c:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
     d60:	04 c0       	rjmp	.+8      	; 0xd6a <serial_write+0x36>
     d62:	20 91 13 06 	lds	r18, 0x0613	; 0x800613 <sys_rt_exec_state>
     d66:	24 ff       	sbrs	r18, 4
     d68:	ec cf       	rjmp	.-40     	; 0xd42 <serial_write+0xe>
     d6a:	08 95       	ret

00000d6c <printString.constprop.9>:
     d6c:	cf 93       	push	r28
     d6e:	df 93       	push	r29
     d70:	c1 e1       	ldi	r28, 0x11	; 17
     d72:	d7 e0       	ldi	r29, 0x07	; 7
     d74:	89 91       	ld	r24, Y+
     d76:	81 11       	cpse	r24, r1
     d78:	03 c0       	rjmp	.+6      	; 0xd80 <printString.constprop.9+0x14>
     d7a:	df 91       	pop	r29
     d7c:	cf 91       	pop	r28
     d7e:	08 95       	ret
     d80:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     d84:	f7 cf       	rjmp	.-18     	; 0xd74 <printString.constprop.9+0x8>

00000d86 <printFloat>:
     d86:	8f 92       	push	r8
     d88:	9f 92       	push	r9
     d8a:	af 92       	push	r10
     d8c:	bf 92       	push	r11
     d8e:	cf 92       	push	r12
     d90:	df 92       	push	r13
     d92:	ef 92       	push	r14
     d94:	ff 92       	push	r15
     d96:	0f 93       	push	r16
     d98:	1f 93       	push	r17
     d9a:	cf 93       	push	r28
     d9c:	df 93       	push	r29
     d9e:	cd b7       	in	r28, 0x3d	; 61
     da0:	de b7       	in	r29, 0x3e	; 62
     da2:	2d 97       	sbiw	r28, 0x0d	; 13
     da4:	0f b6       	in	r0, 0x3f	; 63
     da6:	f8 94       	cli
     da8:	de bf       	out	0x3e, r29	; 62
     daa:	0f be       	out	0x3f, r0	; 63
     dac:	cd bf       	out	0x3d, r28	; 61
     dae:	6b 01       	movw	r12, r22
     db0:	7c 01       	movw	r14, r24
     db2:	04 2f       	mov	r16, r20
     db4:	20 e0       	ldi	r18, 0x00	; 0
     db6:	30 e0       	ldi	r19, 0x00	; 0
     db8:	a9 01       	movw	r20, r18
     dba:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
     dbe:	87 ff       	sbrs	r24, 7
     dc0:	07 c0       	rjmp	.+14     	; 0xdd0 <printFloat+0x4a>
     dc2:	8d e2       	ldi	r24, 0x2D	; 45
     dc4:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     dc8:	f7 fa       	bst	r15, 7
     dca:	f0 94       	com	r15
     dcc:	f7 f8       	bld	r15, 7
     dce:	f0 94       	com	r15
     dd0:	10 2f       	mov	r17, r16
     dd2:	12 30       	cpi	r17, 0x02	; 2
     dd4:	08 f0       	brcs	.+2      	; 0xdd8 <printFloat+0x52>
     dd6:	54 c0       	rjmp	.+168    	; 0xe80 <printFloat+0xfa>
     dd8:	00 ff       	sbrs	r16, 0
     dda:	0a c0       	rjmp	.+20     	; 0xdf0 <printFloat+0x6a>
     ddc:	20 e0       	ldi	r18, 0x00	; 0
     dde:	30 e0       	ldi	r19, 0x00	; 0
     de0:	40 e2       	ldi	r20, 0x20	; 32
     de2:	51 e4       	ldi	r21, 0x41	; 65
     de4:	c7 01       	movw	r24, r14
     de6:	b6 01       	movw	r22, r12
     de8:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     dec:	6b 01       	movw	r12, r22
     dee:	7c 01       	movw	r14, r24
     df0:	20 e0       	ldi	r18, 0x00	; 0
     df2:	30 e0       	ldi	r19, 0x00	; 0
     df4:	40 e0       	ldi	r20, 0x00	; 0
     df6:	5f e3       	ldi	r21, 0x3F	; 63
     df8:	c7 01       	movw	r24, r14
     dfa:	b6 01       	movw	r22, r12
     dfc:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
     e00:	0e 94 b5 36 	call	0x6d6a	; 0x6d6a <__fixsfsi>
     e04:	10 e0       	ldi	r17, 0x00	; 0
     e06:	3a e0       	ldi	r19, 0x0A	; 10
     e08:	83 2e       	mov	r8, r19
     e0a:	91 2c       	mov	r9, r1
     e0c:	a1 2c       	mov	r10, r1
     e0e:	b1 2c       	mov	r11, r1
     e10:	e1 2f       	mov	r30, r17
     e12:	f0 e0       	ldi	r31, 0x00	; 0
     e14:	61 15       	cp	r22, r1
     e16:	71 05       	cpc	r23, r1
     e18:	81 05       	cpc	r24, r1
     e1a:	91 05       	cpc	r25, r1
     e1c:	e9 f5       	brne	.+122    	; 0xe98 <printFloat+0x112>
     e1e:	81 e0       	ldi	r24, 0x01	; 1
     e20:	90 e0       	ldi	r25, 0x00	; 0
     e22:	8c 0f       	add	r24, r28
     e24:	9d 1f       	adc	r25, r29
     e26:	e8 0f       	add	r30, r24
     e28:	f9 1f       	adc	r31, r25
     e2a:	80 e3       	ldi	r24, 0x30	; 48
     e2c:	10 17       	cp	r17, r16
     e2e:	08 f4       	brcc	.+2      	; 0xe32 <printFloat+0xac>
     e30:	45 c0       	rjmp	.+138    	; 0xebc <printFloat+0x136>
     e32:	10 13       	cpse	r17, r16
     e34:	09 c0       	rjmp	.+18     	; 0xe48 <printFloat+0xc2>
     e36:	e1 e0       	ldi	r30, 0x01	; 1
     e38:	f0 e0       	ldi	r31, 0x00	; 0
     e3a:	ec 0f       	add	r30, r28
     e3c:	fd 1f       	adc	r31, r29
     e3e:	e1 0f       	add	r30, r17
     e40:	f1 1d       	adc	r31, r1
     e42:	80 e3       	ldi	r24, 0x30	; 48
     e44:	80 83       	st	Z, r24
     e46:	1f 5f       	subi	r17, 0xFF	; 255
     e48:	ee 24       	eor	r14, r14
     e4a:	e3 94       	inc	r14
     e4c:	f1 2c       	mov	r15, r1
     e4e:	ec 0e       	add	r14, r28
     e50:	fd 1e       	adc	r15, r29
     e52:	e1 0e       	add	r14, r17
     e54:	f1 1c       	adc	r15, r1
     e56:	11 11       	cpse	r17, r1
     e58:	34 c0       	rjmp	.+104    	; 0xec2 <printFloat+0x13c>
     e5a:	2d 96       	adiw	r28, 0x0d	; 13
     e5c:	0f b6       	in	r0, 0x3f	; 63
     e5e:	f8 94       	cli
     e60:	de bf       	out	0x3e, r29	; 62
     e62:	0f be       	out	0x3f, r0	; 63
     e64:	cd bf       	out	0x3d, r28	; 61
     e66:	df 91       	pop	r29
     e68:	cf 91       	pop	r28
     e6a:	1f 91       	pop	r17
     e6c:	0f 91       	pop	r16
     e6e:	ff 90       	pop	r15
     e70:	ef 90       	pop	r14
     e72:	df 90       	pop	r13
     e74:	cf 90       	pop	r12
     e76:	bf 90       	pop	r11
     e78:	af 90       	pop	r10
     e7a:	9f 90       	pop	r9
     e7c:	8f 90       	pop	r8
     e7e:	08 95       	ret
     e80:	20 e0       	ldi	r18, 0x00	; 0
     e82:	30 e0       	ldi	r19, 0x00	; 0
     e84:	48 ec       	ldi	r20, 0xC8	; 200
     e86:	52 e4       	ldi	r21, 0x42	; 66
     e88:	c7 01       	movw	r24, r14
     e8a:	b6 01       	movw	r22, r12
     e8c:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     e90:	6b 01       	movw	r12, r22
     e92:	7c 01       	movw	r14, r24
     e94:	12 50       	subi	r17, 0x02	; 2
     e96:	9d cf       	rjmp	.-198    	; 0xdd2 <printFloat+0x4c>
     e98:	ee 24       	eor	r14, r14
     e9a:	e3 94       	inc	r14
     e9c:	f1 2c       	mov	r15, r1
     e9e:	ec 0e       	add	r14, r28
     ea0:	fd 1e       	adc	r15, r29
     ea2:	ee 0e       	add	r14, r30
     ea4:	ff 1e       	adc	r15, r31
     ea6:	a5 01       	movw	r20, r10
     ea8:	94 01       	movw	r18, r8
     eaa:	0e 94 c4 39 	call	0x7388	; 0x7388 <__udivmodsi4>
     eae:	60 5d       	subi	r22, 0xD0	; 208
     eb0:	f7 01       	movw	r30, r14
     eb2:	60 83       	st	Z, r22
     eb4:	b9 01       	movw	r22, r18
     eb6:	ca 01       	movw	r24, r20
     eb8:	1f 5f       	subi	r17, 0xFF	; 255
     eba:	aa cf       	rjmp	.-172    	; 0xe10 <printFloat+0x8a>
     ebc:	1f 5f       	subi	r17, 0xFF	; 255
     ebe:	81 93       	st	Z+, r24
     ec0:	b5 cf       	rjmp	.-150    	; 0xe2c <printFloat+0xa6>
     ec2:	10 13       	cpse	r17, r16
     ec4:	03 c0       	rjmp	.+6      	; 0xecc <printFloat+0x146>
     ec6:	8e e2       	ldi	r24, 0x2E	; 46
     ec8:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     ecc:	f7 01       	movw	r30, r14
     ece:	82 91       	ld	r24, -Z
     ed0:	7f 01       	movw	r14, r30
     ed2:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     ed6:	11 50       	subi	r17, 0x01	; 1
     ed8:	be cf       	rjmp	.-132    	; 0xe56 <printFloat+0xd0>

00000eda <printFloat_RateValue>:
     eda:	20 91 87 06 	lds	r18, 0x0687	; 0x800687 <settings+0x45>
     ede:	40 e0       	ldi	r20, 0x00	; 0
     ee0:	20 ff       	sbrs	r18, 0
     ee2:	07 c0       	rjmp	.+14     	; 0xef2 <printFloat_RateValue+0x18>
     ee4:	2b e8       	ldi	r18, 0x8B	; 139
     ee6:	32 e4       	ldi	r19, 0x42	; 66
     ee8:	41 e2       	ldi	r20, 0x21	; 33
     eea:	5d e3       	ldi	r21, 0x3D	; 61
     eec:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     ef0:	41 e0       	ldi	r20, 0x01	; 1
     ef2:	0c 94 c3 06 	jmp	0xd86	; 0xd86 <printFloat>

00000ef6 <printFloat_CoordValue>:
     ef6:	20 91 87 06 	lds	r18, 0x0687	; 0x800687 <settings+0x45>
     efa:	43 e0       	ldi	r20, 0x03	; 3
     efc:	20 ff       	sbrs	r18, 0
     efe:	07 c0       	rjmp	.+14     	; 0xf0e <printFloat_CoordValue+0x18>
     f00:	2b e8       	ldi	r18, 0x8B	; 139
     f02:	32 e4       	ldi	r19, 0x42	; 66
     f04:	41 e2       	ldi	r20, 0x21	; 33
     f06:	5d e3       	ldi	r21, 0x3D	; 61
     f08:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
     f0c:	44 e0       	ldi	r20, 0x04	; 4
     f0e:	0c 94 c3 06 	jmp	0xd86	; 0xd86 <printFloat>

00000f12 <report_util_axis_values>:
     f12:	0f 93       	push	r16
     f14:	1f 93       	push	r17
     f16:	cf 93       	push	r28
     f18:	8c 01       	movw	r16, r24
     f1a:	c0 e0       	ldi	r28, 0x00	; 0
     f1c:	f8 01       	movw	r30, r16
     f1e:	61 91       	ld	r22, Z+
     f20:	71 91       	ld	r23, Z+
     f22:	81 91       	ld	r24, Z+
     f24:	91 91       	ld	r25, Z+
     f26:	8f 01       	movw	r16, r30
     f28:	0e 94 7b 07 	call	0xef6	; 0xef6 <printFloat_CoordValue>
     f2c:	c2 30       	cpi	r28, 0x02	; 2
     f2e:	19 f0       	breq	.+6      	; 0xf36 <report_util_axis_values+0x24>
     f30:	8c e2       	ldi	r24, 0x2C	; 44
     f32:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     f36:	cf 5f       	subi	r28, 0xFF	; 255
     f38:	c3 30       	cpi	r28, 0x03	; 3
     f3a:	81 f7       	brne	.-32     	; 0xf1c <report_util_axis_values+0xa>
     f3c:	cf 91       	pop	r28
     f3e:	1f 91       	pop	r17
     f40:	0f 91       	pop	r16
     f42:	08 95       	ret

00000f44 <print_uint8_base10>:
     f44:	cf 93       	push	r28
     f46:	df 93       	push	r29
     f48:	84 36       	cpi	r24, 0x64	; 100
     f4a:	58 f0       	brcs	.+22     	; 0xf62 <print_uint8_base10+0x1e>
     f4c:	6a e0       	ldi	r22, 0x0A	; 10
     f4e:	0e 94 a4 39 	call	0x7348	; 0x7348 <__udivmodqi4>
     f52:	c0 e3       	ldi	r28, 0x30	; 48
     f54:	c9 0f       	add	r28, r25
     f56:	6a e0       	ldi	r22, 0x0A	; 10
     f58:	0e 94 a4 39 	call	0x7348	; 0x7348 <__udivmodqi4>
     f5c:	d0 e3       	ldi	r29, 0x30	; 48
     f5e:	d9 0f       	add	r29, r25
     f60:	04 c0       	rjmp	.+8      	; 0xf6a <print_uint8_base10+0x26>
     f62:	c0 e0       	ldi	r28, 0x00	; 0
     f64:	d0 e0       	ldi	r29, 0x00	; 0
     f66:	8a 30       	cpi	r24, 0x0A	; 10
     f68:	b0 f7       	brcc	.-20     	; 0xf56 <print_uint8_base10+0x12>
     f6a:	80 5d       	subi	r24, 0xD0	; 208
     f6c:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     f70:	dd 23       	and	r29, r29
     f72:	19 f0       	breq	.+6      	; 0xf7a <print_uint8_base10+0x36>
     f74:	8d 2f       	mov	r24, r29
     f76:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     f7a:	cc 23       	and	r28, r28
     f7c:	29 f0       	breq	.+10     	; 0xf88 <print_uint8_base10+0x44>
     f7e:	8c 2f       	mov	r24, r28
     f80:	df 91       	pop	r29
     f82:	cf 91       	pop	r28
     f84:	0c 94 9a 06 	jmp	0xd34	; 0xd34 <serial_write>
     f88:	df 91       	pop	r29
     f8a:	cf 91       	pop	r28
     f8c:	08 95       	ret

00000f8e <printPgmString>:
     f8e:	cf 93       	push	r28
     f90:	df 93       	push	r29
     f92:	ec 01       	movw	r28, r24
     f94:	fe 01       	movw	r30, r28
     f96:	84 91       	lpm	r24, Z
     f98:	21 96       	adiw	r28, 0x01	; 1
     f9a:	81 11       	cpse	r24, r1
     f9c:	03 c0       	rjmp	.+6      	; 0xfa4 <printPgmString+0x16>
     f9e:	df 91       	pop	r29
     fa0:	cf 91       	pop	r28
     fa2:	08 95       	ret
     fa4:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     fa8:	f5 cf       	rjmp	.-22     	; 0xf94 <printPgmString+0x6>

00000faa <report_util_line_feed>:
     faa:	8e e1       	ldi	r24, 0x1E	; 30
     fac:	92 e0       	ldi	r25, 0x02	; 2
     fae:	0c 94 c7 07 	jmp	0xf8e	; 0xf8e <printPgmString>

00000fb2 <report_status_message.part.0>:
     fb2:	cf 93       	push	r28
     fb4:	c8 2f       	mov	r28, r24
     fb6:	87 e2       	ldi	r24, 0x27	; 39
     fb8:	92 e0       	ldi	r25, 0x02	; 2
     fba:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
     fbe:	8c 2f       	mov	r24, r28
     fc0:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
     fc4:	cf 91       	pop	r28
     fc6:	0c 94 d5 07 	jmp	0xfaa	; 0xfaa <report_util_line_feed>

00000fca <report_status_message>:
     fca:	81 11       	cpse	r24, r1
     fcc:	04 c0       	rjmp	.+8      	; 0xfd6 <report_status_message+0xc>
     fce:	8e e2       	ldi	r24, 0x2E	; 46
     fd0:	92 e0       	ldi	r25, 0x02	; 2
     fd2:	0c 94 c7 07 	jmp	0xf8e	; 0xf8e <printPgmString>
     fd6:	0c 94 d9 07 	jmp	0xfb2	; 0xfb2 <report_status_message.part.0>

00000fda <report_util_float_setting>:
     fda:	cf 92       	push	r12
     fdc:	df 92       	push	r13
     fde:	ef 92       	push	r14
     fe0:	ff 92       	push	r15
     fe2:	cf 93       	push	r28
     fe4:	df 93       	push	r29
     fe6:	d8 2f       	mov	r29, r24
     fe8:	6a 01       	movw	r12, r20
     fea:	7b 01       	movw	r14, r22
     fec:	c2 2f       	mov	r28, r18
     fee:	84 e2       	ldi	r24, 0x24	; 36
     ff0:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
     ff4:	8d 2f       	mov	r24, r29
     ff6:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
     ffa:	8d e3       	ldi	r24, 0x3D	; 61
     ffc:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    1000:	4c 2f       	mov	r20, r28
    1002:	c7 01       	movw	r24, r14
    1004:	b6 01       	movw	r22, r12
    1006:	0e 94 c3 06 	call	0xd86	; 0xd86 <printFloat>
    100a:	df 91       	pop	r29
    100c:	cf 91       	pop	r28
    100e:	ff 90       	pop	r15
    1010:	ef 90       	pop	r14
    1012:	df 90       	pop	r13
    1014:	cf 90       	pop	r12
    1016:	0c 94 d5 07 	jmp	0xfaa	; 0xfaa <report_util_line_feed>

0000101a <report_util_uint8_setting>:
    101a:	cf 93       	push	r28
    101c:	df 93       	push	r29
    101e:	d8 2f       	mov	r29, r24
    1020:	c6 2f       	mov	r28, r22
    1022:	84 e2       	ldi	r24, 0x24	; 36
    1024:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    1028:	8d 2f       	mov	r24, r29
    102a:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    102e:	8d e3       	ldi	r24, 0x3D	; 61
    1030:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    1034:	8c 2f       	mov	r24, r28
    1036:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    103a:	df 91       	pop	r29
    103c:	cf 91       	pop	r28
    103e:	0c 94 d5 07 	jmp	0xfaa	; 0xfaa <report_util_line_feed>

00001042 <report_grbl_settings>:
    1042:	ef 92       	push	r14
    1044:	ff 92       	push	r15
    1046:	0f 93       	push	r16
    1048:	1f 93       	push	r17
    104a:	cf 93       	push	r28
    104c:	df 93       	push	r29
    104e:	60 91 72 06 	lds	r22, 0x0672	; 0x800672 <settings+0x30>
    1052:	70 e0       	ldi	r23, 0x00	; 0
    1054:	80 e0       	ldi	r24, 0x00	; 0
    1056:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    105a:	60 91 75 06 	lds	r22, 0x0675	; 0x800675 <settings+0x33>
    105e:	70 e0       	ldi	r23, 0x00	; 0
    1060:	81 e0       	ldi	r24, 0x01	; 1
    1062:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1066:	60 91 73 06 	lds	r22, 0x0673	; 0x800673 <settings+0x31>
    106a:	70 e0       	ldi	r23, 0x00	; 0
    106c:	82 e0       	ldi	r24, 0x02	; 2
    106e:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1072:	60 91 74 06 	lds	r22, 0x0674	; 0x800674 <settings+0x32>
    1076:	70 e0       	ldi	r23, 0x00	; 0
    1078:	83 e0       	ldi	r24, 0x03	; 3
    107a:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    107e:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    1082:	62 fb       	bst	r22, 2
    1084:	66 27       	eor	r22, r22
    1086:	60 f9       	bld	r22, 0
    1088:	70 e0       	ldi	r23, 0x00	; 0
    108a:	84 e0       	ldi	r24, 0x04	; 4
    108c:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1090:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    1094:	66 fb       	bst	r22, 6
    1096:	66 27       	eor	r22, r22
    1098:	60 f9       	bld	r22, 0
    109a:	70 e0       	ldi	r23, 0x00	; 0
    109c:	85 e0       	ldi	r24, 0x05	; 5
    109e:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    10a2:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    10a6:	08 2e       	mov	r0, r24
    10a8:	00 0c       	add	r0, r0
    10aa:	99 0b       	sbc	r25, r25
    10ac:	69 2f       	mov	r22, r25
    10ae:	66 1f       	adc	r22, r22
    10b0:	66 27       	eor	r22, r22
    10b2:	66 1f       	adc	r22, r22
    10b4:	70 e0       	ldi	r23, 0x00	; 0
    10b6:	86 e0       	ldi	r24, 0x06	; 6
    10b8:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    10bc:	60 91 76 06 	lds	r22, 0x0676	; 0x800676 <settings+0x34>
    10c0:	70 e0       	ldi	r23, 0x00	; 0
    10c2:	8a e0       	ldi	r24, 0x0A	; 10
    10c4:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    10c8:	40 91 77 06 	lds	r20, 0x0677	; 0x800677 <settings+0x35>
    10cc:	50 91 78 06 	lds	r21, 0x0678	; 0x800678 <settings+0x36>
    10d0:	60 91 79 06 	lds	r22, 0x0679	; 0x800679 <settings+0x37>
    10d4:	70 91 7a 06 	lds	r23, 0x067A	; 0x80067a <settings+0x38>
    10d8:	23 e0       	ldi	r18, 0x03	; 3
    10da:	8b e0       	ldi	r24, 0x0B	; 11
    10dc:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    10e0:	40 91 7b 06 	lds	r20, 0x067B	; 0x80067b <settings+0x39>
    10e4:	50 91 7c 06 	lds	r21, 0x067C	; 0x80067c <settings+0x3a>
    10e8:	60 91 7d 06 	lds	r22, 0x067D	; 0x80067d <settings+0x3b>
    10ec:	70 91 7e 06 	lds	r23, 0x067E	; 0x80067e <settings+0x3c>
    10f0:	23 e0       	ldi	r18, 0x03	; 3
    10f2:	8c e0       	ldi	r24, 0x0C	; 12
    10f4:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    10f8:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    10fc:	61 70       	andi	r22, 0x01	; 1
    10fe:	70 e0       	ldi	r23, 0x00	; 0
    1100:	8d e0       	ldi	r24, 0x0D	; 13
    1102:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1106:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    110a:	65 fb       	bst	r22, 5
    110c:	66 27       	eor	r22, r22
    110e:	60 f9       	bld	r22, 0
    1110:	70 e0       	ldi	r23, 0x00	; 0
    1112:	84 e1       	ldi	r24, 0x14	; 20
    1114:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1118:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    111c:	63 fb       	bst	r22, 3
    111e:	66 27       	eor	r22, r22
    1120:	60 f9       	bld	r22, 0
    1122:	70 e0       	ldi	r23, 0x00	; 0
    1124:	85 e1       	ldi	r24, 0x15	; 21
    1126:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    112a:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    112e:	62 95       	swap	r22
    1130:	61 70       	andi	r22, 0x01	; 1
    1132:	70 e0       	ldi	r23, 0x00	; 0
    1134:	86 e1       	ldi	r24, 0x16	; 22
    1136:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    113a:	60 91 88 06 	lds	r22, 0x0688	; 0x800688 <settings+0x46>
    113e:	70 e0       	ldi	r23, 0x00	; 0
    1140:	87 e1       	ldi	r24, 0x17	; 23
    1142:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1146:	40 91 89 06 	lds	r20, 0x0689	; 0x800689 <settings+0x47>
    114a:	50 91 8a 06 	lds	r21, 0x068A	; 0x80068a <settings+0x48>
    114e:	60 91 8b 06 	lds	r22, 0x068B	; 0x80068b <settings+0x49>
    1152:	70 91 8c 06 	lds	r23, 0x068C	; 0x80068c <settings+0x4a>
    1156:	23 e0       	ldi	r18, 0x03	; 3
    1158:	88 e1       	ldi	r24, 0x18	; 24
    115a:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    115e:	40 91 8d 06 	lds	r20, 0x068D	; 0x80068d <settings+0x4b>
    1162:	50 91 8e 06 	lds	r21, 0x068E	; 0x80068e <settings+0x4c>
    1166:	60 91 8f 06 	lds	r22, 0x068F	; 0x80068f <settings+0x4d>
    116a:	70 91 90 06 	lds	r23, 0x0690	; 0x800690 <settings+0x4e>
    116e:	23 e0       	ldi	r18, 0x03	; 3
    1170:	89 e1       	ldi	r24, 0x19	; 25
    1172:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    1176:	60 91 91 06 	lds	r22, 0x0691	; 0x800691 <settings+0x4f>
    117a:	70 91 92 06 	lds	r23, 0x0692	; 0x800692 <settings+0x50>
    117e:	8a e1       	ldi	r24, 0x1A	; 26
    1180:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    1184:	40 91 93 06 	lds	r20, 0x0693	; 0x800693 <settings+0x51>
    1188:	50 91 94 06 	lds	r21, 0x0694	; 0x800694 <settings+0x52>
    118c:	60 91 95 06 	lds	r22, 0x0695	; 0x800695 <settings+0x53>
    1190:	70 91 96 06 	lds	r23, 0x0696	; 0x800696 <settings+0x54>
    1194:	23 e0       	ldi	r18, 0x03	; 3
    1196:	8b e1       	ldi	r24, 0x1B	; 27
    1198:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    119c:	40 91 7f 06 	lds	r20, 0x067F	; 0x80067f <settings+0x3d>
    11a0:	50 91 80 06 	lds	r21, 0x0680	; 0x800680 <settings+0x3e>
    11a4:	60 91 81 06 	lds	r22, 0x0681	; 0x800681 <settings+0x3f>
    11a8:	70 91 82 06 	lds	r23, 0x0682	; 0x800682 <settings+0x40>
    11ac:	20 e0       	ldi	r18, 0x00	; 0
    11ae:	8e e1       	ldi	r24, 0x1E	; 30
    11b0:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    11b4:	40 91 83 06 	lds	r20, 0x0683	; 0x800683 <settings+0x41>
    11b8:	50 91 84 06 	lds	r21, 0x0684	; 0x800684 <settings+0x42>
    11bc:	60 91 85 06 	lds	r22, 0x0685	; 0x800685 <settings+0x43>
    11c0:	70 91 86 06 	lds	r23, 0x0686	; 0x800686 <settings+0x44>
    11c4:	20 e0       	ldi	r18, 0x00	; 0
    11c6:	8f e1       	ldi	r24, 0x1F	; 31
    11c8:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    11cc:	60 91 87 06 	lds	r22, 0x0687	; 0x800687 <settings+0x45>
    11d0:	66 95       	lsr	r22
    11d2:	61 70       	andi	r22, 0x01	; 1
    11d4:	70 e0       	ldi	r23, 0x00	; 0
    11d6:	80 e2       	ldi	r24, 0x20	; 32
    11d8:	0e 94 0d 08 	call	0x101a	; 0x101a <report_util_uint8_setting>
    11dc:	84 e6       	ldi	r24, 0x64	; 100
    11de:	f8 2e       	mov	r15, r24
    11e0:	10 e0       	ldi	r17, 0x00	; 0
    11e2:	c2 e4       	ldi	r28, 0x42	; 66
    11e4:	d6 e0       	ldi	r29, 0x06	; 6
    11e6:	00 e0       	ldi	r16, 0x00	; 0
    11e8:	e0 2e       	mov	r14, r16
    11ea:	ef 0c       	add	r14, r15
    11ec:	12 30       	cpi	r17, 0x02	; 2
    11ee:	11 f1       	breq	.+68     	; 0x1234 <report_grbl_settings+0x1f2>
    11f0:	13 30       	cpi	r17, 0x03	; 3
    11f2:	69 f1       	breq	.+90     	; 0x124e <report_grbl_settings+0x20c>
    11f4:	11 30       	cpi	r17, 0x01	; 1
    11f6:	c9 f0       	breq	.+50     	; 0x122a <report_grbl_settings+0x1e8>
    11f8:	48 81       	ld	r20, Y
    11fa:	59 81       	ldd	r21, Y+1	; 0x01
    11fc:	6a 81       	ldd	r22, Y+2	; 0x02
    11fe:	7b 81       	ldd	r23, Y+3	; 0x03
    1200:	23 e0       	ldi	r18, 0x03	; 3
    1202:	8e 2d       	mov	r24, r14
    1204:	0e 94 ed 07 	call	0xfda	; 0xfda <report_util_float_setting>
    1208:	0f 5f       	subi	r16, 0xFF	; 255
    120a:	24 96       	adiw	r28, 0x04	; 4
    120c:	03 30       	cpi	r16, 0x03	; 3
    120e:	61 f7       	brne	.-40     	; 0x11e8 <report_grbl_settings+0x1a6>
    1210:	8a e0       	ldi	r24, 0x0A	; 10
    1212:	f8 0e       	add	r15, r24
    1214:	1f 5f       	subi	r17, 0xFF	; 255
    1216:	8c e8       	ldi	r24, 0x8C	; 140
    1218:	f8 12       	cpse	r15, r24
    121a:	e3 cf       	rjmp	.-58     	; 0x11e2 <report_grbl_settings+0x1a0>
    121c:	df 91       	pop	r29
    121e:	cf 91       	pop	r28
    1220:	1f 91       	pop	r17
    1222:	0f 91       	pop	r16
    1224:	ff 90       	pop	r15
    1226:	ef 90       	pop	r14
    1228:	08 95       	ret
    122a:	4c 85       	ldd	r20, Y+12	; 0x0c
    122c:	5d 85       	ldd	r21, Y+13	; 0x0d
    122e:	6e 85       	ldd	r22, Y+14	; 0x0e
    1230:	7f 85       	ldd	r23, Y+15	; 0x0f
    1232:	e6 cf       	rjmp	.-52     	; 0x1200 <report_grbl_settings+0x1be>
    1234:	20 e0       	ldi	r18, 0x00	; 0
    1236:	30 e0       	ldi	r19, 0x00	; 0
    1238:	41 e6       	ldi	r20, 0x61	; 97
    123a:	55 e4       	ldi	r21, 0x45	; 69
    123c:	68 8d       	ldd	r22, Y+24	; 0x18
    123e:	79 8d       	ldd	r23, Y+25	; 0x19
    1240:	8a 8d       	ldd	r24, Y+26	; 0x1a
    1242:	9b 8d       	ldd	r25, Y+27	; 0x1b
    1244:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1248:	ab 01       	movw	r20, r22
    124a:	bc 01       	movw	r22, r24
    124c:	d9 cf       	rjmp	.-78     	; 0x1200 <report_grbl_settings+0x1be>
    124e:	4c a1       	ldd	r20, Y+36	; 0x24
    1250:	5d a1       	ldd	r21, Y+37	; 0x25
    1252:	6e a1       	ldd	r22, Y+38	; 0x26
    1254:	7f a1       	ldd	r23, Y+39	; 0x27
    1256:	70 58       	subi	r23, 0x80	; 128
    1258:	d3 cf       	rjmp	.-90     	; 0x1200 <report_grbl_settings+0x1be>

0000125a <report_util_feedback_line_feed>:
    125a:	8d e5       	ldi	r24, 0x5D	; 93
    125c:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    1260:	0c 94 d5 07 	jmp	0xfaa	; 0xfaa <report_util_line_feed>

00001264 <report_probe_parameters>:
    1264:	cf 93       	push	r28
    1266:	df 93       	push	r29
    1268:	cd b7       	in	r28, 0x3d	; 61
    126a:	de b7       	in	r29, 0x3e	; 62
    126c:	2c 97       	sbiw	r28, 0x0c	; 12
    126e:	0f b6       	in	r0, 0x3f	; 63
    1270:	f8 94       	cli
    1272:	de bf       	out	0x3e, r29	; 62
    1274:	0f be       	out	0x3f, r0	; 63
    1276:	cd bf       	out	0x3d, r28	; 61
    1278:	81 e2       	ldi	r24, 0x21	; 33
    127a:	92 e0       	ldi	r25, 0x02	; 2
    127c:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    1280:	64 e2       	ldi	r22, 0x24	; 36
    1282:	76 e0       	ldi	r23, 0x06	; 6
    1284:	ce 01       	movw	r24, r28
    1286:	01 96       	adiw	r24, 0x01	; 1
    1288:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    128c:	ce 01       	movw	r24, r28
    128e:	01 96       	adiw	r24, 0x01	; 1
    1290:	0e 94 89 07 	call	0xf12	; 0xf12 <report_util_axis_values>
    1294:	8a e3       	ldi	r24, 0x3A	; 58
    1296:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    129a:	80 91 36 06 	lds	r24, 0x0636	; 0x800636 <sys+0x5>
    129e:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    12a2:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    12a6:	2c 96       	adiw	r28, 0x0c	; 12
    12a8:	0f b6       	in	r0, 0x3f	; 63
    12aa:	f8 94       	cli
    12ac:	de bf       	out	0x3e, r29	; 62
    12ae:	0f be       	out	0x3f, r0	; 63
    12b0:	cd bf       	out	0x3d, r28	; 61
    12b2:	df 91       	pop	r29
    12b4:	cf 91       	pop	r28
    12b6:	08 95       	ret

000012b8 <coolant_set_state>:
    12b8:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    12bc:	91 11       	cpse	r25, r1
    12be:	05 c0       	rjmp	.+10     	; 0x12ca <coolant_set_state+0x12>
    12c0:	86 ff       	sbrs	r24, 6
    12c2:	04 c0       	rjmp	.+8      	; 0x12cc <coolant_set_state+0x14>
    12c4:	43 9a       	sbi	0x08, 3	; 8
    12c6:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    12ca:	08 95       	ret
    12cc:	43 98       	cbi	0x08, 3	; 8
    12ce:	fb cf       	rjmp	.-10     	; 0x12c6 <coolant_set_state+0xe>

000012d0 <spindle_set_speed>:
    12d0:	80 93 b3 00 	sts	0x00B3, r24	; 0x8000b3 <__DATA_REGION_ORIGIN__+0x53>
    12d4:	81 11       	cpse	r24, r1
    12d6:	06 c0       	rjmp	.+12     	; 0x12e4 <spindle_set_speed+0x14>
    12d8:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12dc:	8f 77       	andi	r24, 0x7F	; 127
    12de:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12e2:	08 95       	ret
    12e4:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    12e8:	80 68       	ori	r24, 0x80	; 128
    12ea:	f9 cf       	rjmp	.-14     	; 0x12de <spindle_set_speed+0xe>

000012ec <spindle_init>:
    12ec:	cf 93       	push	r28
    12ee:	df 93       	push	r29
    12f0:	23 9a       	sbi	0x04, 3	; 4
    12f2:	c0 eb       	ldi	r28, 0xB0	; 176
    12f4:	d0 e0       	ldi	r29, 0x00	; 0
    12f6:	83 e0       	ldi	r24, 0x03	; 3
    12f8:	88 83       	st	Y, r24
    12fa:	84 e0       	ldi	r24, 0x04	; 4
    12fc:	80 93 b1 00 	sts	0x00B1, r24	; 0x8000b1 <__DATA_REGION_ORIGIN__+0x51>
    1300:	25 9a       	sbi	0x04, 5	; 4
    1302:	20 91 83 06 	lds	r18, 0x0683	; 0x800683 <settings+0x41>
    1306:	30 91 84 06 	lds	r19, 0x0684	; 0x800684 <settings+0x42>
    130a:	40 91 85 06 	lds	r20, 0x0685	; 0x800685 <settings+0x43>
    130e:	50 91 86 06 	lds	r21, 0x0686	; 0x800686 <settings+0x44>
    1312:	60 91 7f 06 	lds	r22, 0x067F	; 0x80067f <settings+0x3d>
    1316:	70 91 80 06 	lds	r23, 0x0680	; 0x800680 <settings+0x3e>
    131a:	80 91 81 06 	lds	r24, 0x0681	; 0x800681 <settings+0x3f>
    131e:	90 91 82 06 	lds	r25, 0x0682	; 0x800682 <settings+0x40>
    1322:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1326:	9b 01       	movw	r18, r22
    1328:	ac 01       	movw	r20, r24
    132a:	60 e0       	ldi	r22, 0x00	; 0
    132c:	70 e0       	ldi	r23, 0x00	; 0
    132e:	8e e7       	ldi	r24, 0x7E	; 126
    1330:	93 e4       	ldi	r25, 0x43	; 67
    1332:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1336:	60 93 00 01 	sts	0x0100, r22	; 0x800100 <_edata>
    133a:	70 93 01 01 	sts	0x0101, r23	; 0x800101 <_edata+0x1>
    133e:	80 93 02 01 	sts	0x0102, r24	; 0x800102 <_edata+0x2>
    1342:	90 93 03 01 	sts	0x0103, r25	; 0x800103 <_edata+0x3>
    1346:	88 81       	ld	r24, Y
    1348:	8f 77       	andi	r24, 0x7F	; 127
    134a:	88 83       	st	Y, r24
    134c:	df 91       	pop	r29
    134e:	cf 91       	pop	r28
    1350:	08 95       	ret

00001352 <gc_sync_position>:
    1352:	68 e1       	ldi	r22, 0x18	; 24
    1354:	76 e0       	ldi	r23, 0x06	; 6
    1356:	8f ea       	ldi	r24, 0xAF	; 175
    1358:	96 e0       	ldi	r25, 0x06	; 6
    135a:	0c 94 8f 02 	jmp	0x51e	; 0x51e <system_convert_array_steps_to_mpos>

0000135e <plan_reset>:
    135e:	e7 ef       	ldi	r30, 0xF7	; 247
    1360:	f5 e0       	ldi	r31, 0x05	; 5
    1362:	8c e1       	ldi	r24, 0x1C	; 28
    1364:	df 01       	movw	r26, r30
    1366:	1d 92       	st	X+, r1
    1368:	8a 95       	dec	r24
    136a:	e9 f7       	brne	.-6      	; 0x1366 <plan_reset+0x8>
    136c:	10 92 d5 02 	sts	0x02D5, r1	; 0x8002d5 <block_buffer_tail>
    1370:	10 92 f6 05 	sts	0x05F6, r1	; 0x8005f6 <block_buffer_head>
    1374:	81 e0       	ldi	r24, 0x01	; 1
    1376:	80 93 d4 02 	sts	0x02D4, r24	; 0x8002d4 <next_buffer_head>
    137a:	10 92 d3 02 	sts	0x02D3, r1	; 0x8002d3 <block_buffer_planned>
    137e:	08 95       	ret

00001380 <convert_delta_vector_to_unit_vector>:
    1380:	4f 92       	push	r4
    1382:	5f 92       	push	r5
    1384:	6f 92       	push	r6
    1386:	7f 92       	push	r7
    1388:	af 92       	push	r10
    138a:	bf 92       	push	r11
    138c:	cf 92       	push	r12
    138e:	df 92       	push	r13
    1390:	ef 92       	push	r14
    1392:	ff 92       	push	r15
    1394:	0f 93       	push	r16
    1396:	1f 93       	push	r17
    1398:	cf 93       	push	r28
    139a:	df 93       	push	r29
    139c:	ec 01       	movw	r28, r24
    139e:	5c 01       	movw	r10, r24
    13a0:	2c e0       	ldi	r18, 0x0C	; 12
    13a2:	a2 0e       	add	r10, r18
    13a4:	b1 1c       	adc	r11, r1
    13a6:	8c 01       	movw	r16, r24
    13a8:	c1 2c       	mov	r12, r1
    13aa:	d1 2c       	mov	r13, r1
    13ac:	76 01       	movw	r14, r12
    13ae:	f8 01       	movw	r30, r16
    13b0:	41 90       	ld	r4, Z+
    13b2:	51 90       	ld	r5, Z+
    13b4:	61 90       	ld	r6, Z+
    13b6:	71 90       	ld	r7, Z+
    13b8:	8f 01       	movw	r16, r30
    13ba:	20 e0       	ldi	r18, 0x00	; 0
    13bc:	30 e0       	ldi	r19, 0x00	; 0
    13be:	a9 01       	movw	r20, r18
    13c0:	c3 01       	movw	r24, r6
    13c2:	b2 01       	movw	r22, r4
    13c4:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    13c8:	88 23       	and	r24, r24
    13ca:	71 f0       	breq	.+28     	; 0x13e8 <convert_delta_vector_to_unit_vector+0x68>
    13cc:	a3 01       	movw	r20, r6
    13ce:	92 01       	movw	r18, r4
    13d0:	c3 01       	movw	r24, r6
    13d2:	b2 01       	movw	r22, r4
    13d4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    13d8:	9b 01       	movw	r18, r22
    13da:	ac 01       	movw	r20, r24
    13dc:	c7 01       	movw	r24, r14
    13de:	b6 01       	movw	r22, r12
    13e0:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    13e4:	6b 01       	movw	r12, r22
    13e6:	7c 01       	movw	r14, r24
    13e8:	0a 15       	cp	r16, r10
    13ea:	1b 05       	cpc	r17, r11
    13ec:	01 f7       	brne	.-64     	; 0x13ae <convert_delta_vector_to_unit_vector+0x2e>
    13ee:	c7 01       	movw	r24, r14
    13f0:	b6 01       	movw	r22, r12
    13f2:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    13f6:	6b 01       	movw	r12, r22
    13f8:	7c 01       	movw	r14, r24
    13fa:	ac 01       	movw	r20, r24
    13fc:	9b 01       	movw	r18, r22
    13fe:	60 e0       	ldi	r22, 0x00	; 0
    1400:	70 e0       	ldi	r23, 0x00	; 0
    1402:	80 e8       	ldi	r24, 0x80	; 128
    1404:	9f e3       	ldi	r25, 0x3F	; 63
    1406:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    140a:	2b 01       	movw	r4, r22
    140c:	3c 01       	movw	r6, r24
    140e:	69 91       	ld	r22, Y+
    1410:	79 91       	ld	r23, Y+
    1412:	89 91       	ld	r24, Y+
    1414:	99 91       	ld	r25, Y+
    1416:	5e 01       	movw	r10, r28
    1418:	f4 e0       	ldi	r31, 0x04	; 4
    141a:	af 1a       	sub	r10, r31
    141c:	b1 08       	sbc	r11, r1
    141e:	a3 01       	movw	r20, r6
    1420:	92 01       	movw	r18, r4
    1422:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1426:	f5 01       	movw	r30, r10
    1428:	60 83       	st	Z, r22
    142a:	71 83       	std	Z+1, r23	; 0x01
    142c:	82 83       	std	Z+2, r24	; 0x02
    142e:	93 83       	std	Z+3, r25	; 0x03
    1430:	c0 17       	cp	r28, r16
    1432:	d1 07       	cpc	r29, r17
    1434:	61 f7       	brne	.-40     	; 0x140e <convert_delta_vector_to_unit_vector+0x8e>
    1436:	c7 01       	movw	r24, r14
    1438:	b6 01       	movw	r22, r12
    143a:	df 91       	pop	r29
    143c:	cf 91       	pop	r28
    143e:	1f 91       	pop	r17
    1440:	0f 91       	pop	r16
    1442:	ff 90       	pop	r15
    1444:	ef 90       	pop	r14
    1446:	df 90       	pop	r13
    1448:	cf 90       	pop	r12
    144a:	bf 90       	pop	r11
    144c:	af 90       	pop	r10
    144e:	7f 90       	pop	r7
    1450:	6f 90       	pop	r6
    1452:	5f 90       	pop	r5
    1454:	4f 90       	pop	r4
    1456:	08 95       	ret

00001458 <spindle_compute_pwm_value>:
    1458:	4f 92       	push	r4
    145a:	5f 92       	push	r5
    145c:	6f 92       	push	r6
    145e:	7f 92       	push	r7
    1460:	8f 92       	push	r8
    1462:	9f 92       	push	r9
    1464:	af 92       	push	r10
    1466:	bf 92       	push	r11
    1468:	cf 92       	push	r12
    146a:	df 92       	push	r13
    146c:	ef 92       	push	r14
    146e:	ff 92       	push	r15
    1470:	6b 01       	movw	r12, r22
    1472:	7c 01       	movw	r14, r24
    1474:	80 90 83 06 	lds	r8, 0x0683	; 0x800683 <settings+0x41>
    1478:	90 90 84 06 	lds	r9, 0x0684	; 0x800684 <settings+0x42>
    147c:	a0 90 85 06 	lds	r10, 0x0685	; 0x800685 <settings+0x43>
    1480:	b0 90 86 06 	lds	r11, 0x0686	; 0x800686 <settings+0x44>
    1484:	40 90 7f 06 	lds	r4, 0x067F	; 0x80067f <settings+0x3d>
    1488:	50 90 80 06 	lds	r5, 0x0680	; 0x800680 <settings+0x3e>
    148c:	60 90 81 06 	lds	r6, 0x0681	; 0x800681 <settings+0x3f>
    1490:	70 90 82 06 	lds	r7, 0x0682	; 0x800682 <settings+0x40>
    1494:	a3 01       	movw	r20, r6
    1496:	92 01       	movw	r18, r4
    1498:	c5 01       	movw	r24, r10
    149a:	b4 01       	movw	r22, r8
    149c:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    14a0:	87 ff       	sbrs	r24, 7
    14a2:	1b c0       	rjmp	.+54     	; 0x14da <spindle_compute_pwm_value+0x82>
    14a4:	60 91 3a 06 	lds	r22, 0x063A	; 0x80063a <sys+0x9>
    14a8:	70 e0       	ldi	r23, 0x00	; 0
    14aa:	90 e0       	ldi	r25, 0x00	; 0
    14ac:	80 e0       	ldi	r24, 0x00	; 0
    14ae:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
    14b2:	2a e0       	ldi	r18, 0x0A	; 10
    14b4:	37 ed       	ldi	r19, 0xD7	; 215
    14b6:	43 e2       	ldi	r20, 0x23	; 35
    14b8:	5c e3       	ldi	r21, 0x3C	; 60
    14ba:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    14be:	a7 01       	movw	r20, r14
    14c0:	96 01       	movw	r18, r12
    14c2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    14c6:	6b 01       	movw	r12, r22
    14c8:	7c 01       	movw	r14, r24
    14ca:	ac 01       	movw	r20, r24
    14cc:	9b 01       	movw	r18, r22
    14ce:	c3 01       	movw	r24, r6
    14d0:	b2 01       	movw	r22, r4
    14d2:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    14d6:	18 16       	cp	r1, r24
    14d8:	b4 f0       	brlt	.+44     	; 0x1506 <spindle_compute_pwm_value+0xae>
    14da:	40 92 3e 06 	sts	0x063E, r4	; 0x80063e <sys+0xd>
    14de:	50 92 3f 06 	sts	0x063F, r5	; 0x80063f <sys+0xe>
    14e2:	60 92 40 06 	sts	0x0640, r6	; 0x800640 <sys+0xf>
    14e6:	70 92 41 06 	sts	0x0641, r7	; 0x800641 <sys+0x10>
    14ea:	8f ef       	ldi	r24, 0xFF	; 255
    14ec:	ff 90       	pop	r15
    14ee:	ef 90       	pop	r14
    14f0:	df 90       	pop	r13
    14f2:	cf 90       	pop	r12
    14f4:	bf 90       	pop	r11
    14f6:	af 90       	pop	r10
    14f8:	9f 90       	pop	r9
    14fa:	8f 90       	pop	r8
    14fc:	7f 90       	pop	r7
    14fe:	6f 90       	pop	r6
    1500:	5f 90       	pop	r5
    1502:	4f 90       	pop	r4
    1504:	08 95       	ret
    1506:	a7 01       	movw	r20, r14
    1508:	96 01       	movw	r18, r12
    150a:	c5 01       	movw	r24, r10
    150c:	b4 01       	movw	r22, r8
    150e:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    1512:	87 fd       	sbrc	r24, 7
    1514:	1c c0       	rjmp	.+56     	; 0x154e <spindle_compute_pwm_value+0xf6>
    1516:	20 e0       	ldi	r18, 0x00	; 0
    1518:	30 e0       	ldi	r19, 0x00	; 0
    151a:	a9 01       	movw	r20, r18
    151c:	c7 01       	movw	r24, r14
    151e:	b6 01       	movw	r22, r12
    1520:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1524:	81 11       	cpse	r24, r1
    1526:	09 c0       	rjmp	.+18     	; 0x153a <spindle_compute_pwm_value+0xe2>
    1528:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    152c:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    1530:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    1534:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    1538:	d9 cf       	rjmp	.-78     	; 0x14ec <spindle_compute_pwm_value+0x94>
    153a:	80 92 3e 06 	sts	0x063E, r8	; 0x80063e <sys+0xd>
    153e:	90 92 3f 06 	sts	0x063F, r9	; 0x80063f <sys+0xe>
    1542:	a0 92 40 06 	sts	0x0640, r10	; 0x800640 <sys+0xf>
    1546:	b0 92 41 06 	sts	0x0641, r11	; 0x800641 <sys+0x10>
    154a:	81 e0       	ldi	r24, 0x01	; 1
    154c:	cf cf       	rjmp	.-98     	; 0x14ec <spindle_compute_pwm_value+0x94>
    154e:	c0 92 3e 06 	sts	0x063E, r12	; 0x80063e <sys+0xd>
    1552:	d0 92 3f 06 	sts	0x063F, r13	; 0x80063f <sys+0xe>
    1556:	e0 92 40 06 	sts	0x0640, r14	; 0x800640 <sys+0xf>
    155a:	f0 92 41 06 	sts	0x0641, r15	; 0x800641 <sys+0x10>
    155e:	a5 01       	movw	r20, r10
    1560:	94 01       	movw	r18, r8
    1562:	c7 01       	movw	r24, r14
    1564:	b6 01       	movw	r22, r12
    1566:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    156a:	20 91 00 01 	lds	r18, 0x0100	; 0x800100 <_edata>
    156e:	30 91 01 01 	lds	r19, 0x0101	; 0x800101 <_edata+0x1>
    1572:	40 91 02 01 	lds	r20, 0x0102	; 0x800102 <_edata+0x2>
    1576:	50 91 03 01 	lds	r21, 0x0103	; 0x800103 <_edata+0x3>
    157a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    157e:	0e 94 28 37 	call	0x6e50	; 0x6e50 <floor>
    1582:	20 e0       	ldi	r18, 0x00	; 0
    1584:	30 e0       	ldi	r19, 0x00	; 0
    1586:	40 e8       	ldi	r20, 0x80	; 128
    1588:	5f e3       	ldi	r21, 0x3F	; 63
    158a:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    158e:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    1592:	86 2f       	mov	r24, r22
    1594:	ab cf       	rjmp	.-170    	; 0x14ec <spindle_compute_pwm_value+0x94>

00001596 <spindle_set_state>:
    1596:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    159a:	91 11       	cpse	r25, r1
    159c:	11 c0       	rjmp	.+34     	; 0x15c0 <spindle_set_state+0x2a>
    159e:	81 11       	cpse	r24, r1
    15a0:	10 c0       	rjmp	.+32     	; 0x15c2 <spindle_set_state+0x2c>
    15a2:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    15a6:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    15aa:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    15ae:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    15b2:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    15b6:	8f 77       	andi	r24, 0x7F	; 127
    15b8:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    15bc:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    15c0:	08 95       	ret
    15c2:	80 31       	cpi	r24, 0x10	; 16
    15c4:	89 f4       	brne	.+34     	; 0x15e8 <spindle_set_state+0x52>
    15c6:	2d 98       	cbi	0x05, 5	; 5
    15c8:	90 91 87 06 	lds	r25, 0x0687	; 0x800687 <settings+0x45>
    15cc:	91 ff       	sbrs	r25, 1
    15ce:	05 c0       	rjmp	.+10     	; 0x15da <spindle_set_state+0x44>
    15d0:	80 32       	cpi	r24, 0x20	; 32
    15d2:	19 f4       	brne	.+6      	; 0x15da <spindle_set_state+0x44>
    15d4:	40 e0       	ldi	r20, 0x00	; 0
    15d6:	50 e0       	ldi	r21, 0x00	; 0
    15d8:	ba 01       	movw	r22, r20
    15da:	cb 01       	movw	r24, r22
    15dc:	ba 01       	movw	r22, r20
    15de:	0e 94 2c 0a 	call	0x1458	; 0x1458 <spindle_compute_pwm_value>
    15e2:	0e 94 68 09 	call	0x12d0	; 0x12d0 <spindle_set_speed>
    15e6:	ea cf       	rjmp	.-44     	; 0x15bc <spindle_set_state+0x26>
    15e8:	2d 9a       	sbi	0x05, 5	; 5
    15ea:	ee cf       	rjmp	.-36     	; 0x15c8 <spindle_set_state+0x32>

000015ec <plan_buffer_line>:
    15ec:	2f 92       	push	r2
    15ee:	3f 92       	push	r3
    15f0:	4f 92       	push	r4
    15f2:	5f 92       	push	r5
    15f4:	6f 92       	push	r6
    15f6:	7f 92       	push	r7
    15f8:	8f 92       	push	r8
    15fa:	9f 92       	push	r9
    15fc:	af 92       	push	r10
    15fe:	bf 92       	push	r11
    1600:	cf 92       	push	r12
    1602:	df 92       	push	r13
    1604:	ef 92       	push	r14
    1606:	ff 92       	push	r15
    1608:	0f 93       	push	r16
    160a:	1f 93       	push	r17
    160c:	cf 93       	push	r28
    160e:	df 93       	push	r29
    1610:	cd b7       	in	r28, 0x3d	; 61
    1612:	de b7       	in	r29, 0x3e	; 62
    1614:	c2 54       	subi	r28, 0x42	; 66
    1616:	d1 09       	sbc	r29, r1
    1618:	0f b6       	in	r0, 0x3f	; 63
    161a:	f8 94       	cli
    161c:	de bf       	out	0x3e, r29	; 62
    161e:	0f be       	out	0x3f, r0	; 63
    1620:	cd bf       	out	0x3d, r28	; 61
    1622:	3b 01       	movw	r6, r22
    1624:	00 91 f6 05 	lds	r16, 0x05F6	; 0x8005f6 <block_buffer_head>
    1628:	20 2e       	mov	r2, r16
    162a:	31 2c       	mov	r3, r1
    162c:	22 e3       	ldi	r18, 0x32	; 50
    162e:	02 9f       	mul	r16, r18
    1630:	a0 01       	movw	r20, r0
    1632:	11 24       	eor	r1, r1
    1634:	ba 01       	movw	r22, r20
    1636:	6a 52       	subi	r22, 0x2A	; 42
    1638:	7d 4f       	sbci	r23, 0xFD	; 253
    163a:	7c ab       	std	Y+52, r23	; 0x34
    163c:	6b ab       	std	Y+51, r22	; 0x33
    163e:	fb 01       	movw	r30, r22
    1640:	11 92       	st	Z+, r1
    1642:	2a 95       	dec	r18
    1644:	e9 f7       	brne	.-6      	; 0x1640 <plan_buffer_line+0x54>
    1646:	f3 01       	movw	r30, r6
    1648:	20 85       	ldd	r18, Z+8	; 0x08
    164a:	fb 01       	movw	r30, r22
    164c:	21 8b       	std	Z+17, r18	; 0x11
    164e:	f3 01       	movw	r30, r6
    1650:	44 81       	ldd	r20, Z+4	; 0x04
    1652:	55 81       	ldd	r21, Z+5	; 0x05
    1654:	66 81       	ldd	r22, Z+6	; 0x06
    1656:	77 81       	ldd	r23, Z+7	; 0x07
    1658:	eb a9       	ldd	r30, Y+51	; 0x33
    165a:	fc a9       	ldd	r31, Y+52	; 0x34
    165c:	46 a7       	std	Z+46, r20	; 0x2e
    165e:	57 a7       	std	Z+47, r21	; 0x2f
    1660:	60 ab       	std	Z+48, r22	; 0x30
    1662:	71 ab       	std	Z+49, r23	; 0x31
    1664:	21 ff       	sbrs	r18, 1
    1666:	f0 c0       	rjmp	.+480    	; 0x1848 <plan_buffer_line+0x25c>
    1668:	2c e0       	ldi	r18, 0x0C	; 12
    166a:	e8 e1       	ldi	r30, 0x18	; 24
    166c:	f6 e0       	ldi	r31, 0x06	; 6
    166e:	de 01       	movw	r26, r28
    1670:	59 96       	adiw	r26, 0x19	; 25
    1672:	01 90       	ld	r0, Z+
    1674:	0d 92       	st	X+, r0
    1676:	2a 95       	dec	r18
    1678:	e1 f7       	brne	.-8      	; 0x1672 <plan_buffer_line+0x86>
    167a:	89 ab       	std	Y+49, r24	; 0x31
    167c:	9a ab       	std	Y+50, r25	; 0x32
    167e:	22 e4       	ldi	r18, 0x42	; 66
    1680:	36 e0       	ldi	r19, 0x06	; 6
    1682:	21 96       	adiw	r28, 0x01	; 1
    1684:	3f af       	std	Y+63, r19	; 0x3f
    1686:	2e af       	std	Y+62, r18	; 0x3e
    1688:	21 97       	sbiw	r28, 0x01	; 1
    168a:	be 01       	movw	r22, r28
    168c:	63 5f       	subi	r22, 0xF3	; 243
    168e:	7f 4f       	sbci	r23, 0xFF	; 255
    1690:	7e af       	std	Y+62, r23	; 0x3e
    1692:	6d af       	std	Y+61, r22	; 0x3d
    1694:	ce 01       	movw	r24, r28
    1696:	49 96       	adiw	r24, 0x19	; 25
    1698:	9c af       	std	Y+60, r25	; 0x3c
    169a:	8b af       	std	Y+59, r24	; 0x3b
    169c:	eb a9       	ldd	r30, Y+51	; 0x33
    169e:	fc a9       	ldd	r31, Y+52	; 0x34
    16a0:	fa af       	std	Y+58, r31	; 0x3a
    16a2:	e9 af       	std	Y+57, r30	; 0x39
    16a4:	9e 01       	movw	r18, r28
    16a6:	2b 5d       	subi	r18, 0xDB	; 219
    16a8:	3f 4f       	sbci	r19, 0xFF	; 255
    16aa:	3e ab       	std	Y+54, r19	; 0x36
    16ac:	2d ab       	std	Y+53, r18	; 0x35
    16ae:	38 af       	std	Y+56, r19	; 0x38
    16b0:	2f ab       	std	Y+55, r18	; 0x37
    16b2:	10 e0       	ldi	r17, 0x00	; 0
    16b4:	82 e3       	ldi	r24, 0x32	; 50
    16b6:	82 9d       	mul	r24, r2
    16b8:	20 01       	movw	r4, r0
    16ba:	83 9d       	mul	r24, r3
    16bc:	50 0c       	add	r5, r0
    16be:	11 24       	eor	r1, r1
    16c0:	b2 01       	movw	r22, r4
    16c2:	6a 52       	subi	r22, 0x2A	; 42
    16c4:	7d 4f       	sbci	r23, 0xFD	; 253
    16c6:	2b 01       	movw	r4, r22
    16c8:	cb 01       	movw	r24, r22
    16ca:	0c 96       	adiw	r24, 0x0c	; 12
    16cc:	23 96       	adiw	r28, 0x03	; 3
    16ce:	9f af       	std	Y+63, r25	; 0x3f
    16d0:	8e af       	std	Y+62, r24	; 0x3e
    16d2:	23 97       	sbiw	r28, 0x03	; 3
    16d4:	90 e1       	ldi	r25, 0x10	; 16
    16d6:	49 0e       	add	r4, r25
    16d8:	51 1c       	adc	r5, r1
    16da:	e9 a9       	ldd	r30, Y+49	; 0x31
    16dc:	fa a9       	ldd	r31, Y+50	; 0x32
    16de:	61 91       	ld	r22, Z+
    16e0:	71 91       	ld	r23, Z+
    16e2:	81 91       	ld	r24, Z+
    16e4:	91 91       	ld	r25, Z+
    16e6:	fa ab       	std	Y+50, r31	; 0x32
    16e8:	e9 ab       	std	Y+49, r30	; 0x31
    16ea:	21 96       	adiw	r28, 0x01	; 1
    16ec:	ee ad       	ldd	r30, Y+62	; 0x3e
    16ee:	ff ad       	ldd	r31, Y+63	; 0x3f
    16f0:	21 97       	sbiw	r28, 0x01	; 1
    16f2:	81 90       	ld	r8, Z+
    16f4:	91 90       	ld	r9, Z+
    16f6:	a1 90       	ld	r10, Z+
    16f8:	b1 90       	ld	r11, Z+
    16fa:	21 96       	adiw	r28, 0x01	; 1
    16fc:	ff af       	std	Y+63, r31	; 0x3f
    16fe:	ee af       	std	Y+62, r30	; 0x3e
    1700:	21 97       	sbiw	r28, 0x01	; 1
    1702:	a5 01       	movw	r20, r10
    1704:	94 01       	movw	r18, r8
    1706:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    170a:	0e 94 68 38 	call	0x70d0	; 0x70d0 <lround>
    170e:	ed ad       	ldd	r30, Y+61	; 0x3d
    1710:	fe ad       	ldd	r31, Y+62	; 0x3e
    1712:	61 93       	st	Z+, r22
    1714:	71 93       	st	Z+, r23
    1716:	81 93       	st	Z+, r24
    1718:	91 93       	st	Z+, r25
    171a:	fe af       	std	Y+62, r31	; 0x3e
    171c:	ed af       	std	Y+61, r30	; 0x3d
    171e:	eb ad       	ldd	r30, Y+59	; 0x3b
    1720:	fc ad       	ldd	r31, Y+60	; 0x3c
    1722:	c1 90       	ld	r12, Z+
    1724:	d1 90       	ld	r13, Z+
    1726:	e1 90       	ld	r14, Z+
    1728:	f1 90       	ld	r15, Z+
    172a:	fc af       	std	Y+60, r31	; 0x3c
    172c:	eb af       	std	Y+59, r30	; 0x3b
    172e:	6c 19       	sub	r22, r12
    1730:	7d 09       	sbc	r23, r13
    1732:	8e 09       	sbc	r24, r14
    1734:	9f 09       	sbc	r25, r15
    1736:	9b 01       	movw	r18, r22
    1738:	ac 01       	movw	r20, r24
    173a:	97 ff       	sbrs	r25, 7
    173c:	07 c0       	rjmp	.+14     	; 0x174c <plan_buffer_line+0x160>
    173e:	22 27       	eor	r18, r18
    1740:	33 27       	eor	r19, r19
    1742:	a9 01       	movw	r20, r18
    1744:	26 1b       	sub	r18, r22
    1746:	37 0b       	sbc	r19, r23
    1748:	48 0b       	sbc	r20, r24
    174a:	59 0b       	sbc	r21, r25
    174c:	e9 ad       	ldd	r30, Y+57	; 0x39
    174e:	fa ad       	ldd	r31, Y+58	; 0x3a
    1750:	21 93       	st	Z+, r18
    1752:	31 93       	st	Z+, r19
    1754:	41 93       	st	Z+, r20
    1756:	51 93       	st	Z+, r21
    1758:	fa af       	std	Y+58, r31	; 0x3a
    175a:	e9 af       	std	Y+57, r30	; 0x39
    175c:	23 96       	adiw	r28, 0x03	; 3
    175e:	ee ad       	ldd	r30, Y+62	; 0x3e
    1760:	ff ad       	ldd	r31, Y+63	; 0x3f
    1762:	23 97       	sbiw	r28, 0x03	; 3
    1764:	c0 80       	ld	r12, Z
    1766:	d1 80       	ldd	r13, Z+1	; 0x01
    1768:	e2 80       	ldd	r14, Z+2	; 0x02
    176a:	f3 80       	ldd	r15, Z+3	; 0x03
    176c:	c2 16       	cp	r12, r18
    176e:	d3 06       	cpc	r13, r19
    1770:	e4 06       	cpc	r14, r20
    1772:	f5 06       	cpc	r15, r21
    1774:	10 f4       	brcc	.+4      	; 0x177a <plan_buffer_line+0x18e>
    1776:	69 01       	movw	r12, r18
    1778:	7a 01       	movw	r14, r20
    177a:	23 96       	adiw	r28, 0x03	; 3
    177c:	ee ad       	ldd	r30, Y+62	; 0x3e
    177e:	ff ad       	ldd	r31, Y+63	; 0x3f
    1780:	23 97       	sbiw	r28, 0x03	; 3
    1782:	c0 82       	st	Z, r12
    1784:	d1 82       	std	Z+1, r13	; 0x01
    1786:	e2 82       	std	Z+2, r14	; 0x02
    1788:	f3 82       	std	Z+3, r15	; 0x03
    178a:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
    178e:	a5 01       	movw	r20, r10
    1790:	94 01       	movw	r18, r8
    1792:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1796:	ef a9       	ldd	r30, Y+55	; 0x37
    1798:	f8 ad       	ldd	r31, Y+56	; 0x38
    179a:	61 93       	st	Z+, r22
    179c:	71 93       	st	Z+, r23
    179e:	81 93       	st	Z+, r24
    17a0:	91 93       	st	Z+, r25
    17a2:	f8 af       	std	Y+56, r31	; 0x38
    17a4:	ef ab       	std	Y+55, r30	; 0x37
    17a6:	20 e0       	ldi	r18, 0x00	; 0
    17a8:	30 e0       	ldi	r19, 0x00	; 0
    17aa:	a9 01       	movw	r20, r18
    17ac:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    17b0:	87 ff       	sbrs	r24, 7
    17b2:	0b c0       	rjmp	.+22     	; 0x17ca <plan_buffer_line+0x1de>
    17b4:	90 e2       	ldi	r25, 0x20	; 32
    17b6:	11 23       	and	r17, r17
    17b8:	21 f0       	breq	.+8      	; 0x17c2 <plan_buffer_line+0x1d6>
    17ba:	90 e8       	ldi	r25, 0x80	; 128
    17bc:	11 30       	cpi	r17, 0x01	; 1
    17be:	09 f4       	brne	.+2      	; 0x17c2 <plan_buffer_line+0x1d6>
    17c0:	90 e4       	ldi	r25, 0x40	; 64
    17c2:	f2 01       	movw	r30, r4
    17c4:	80 81       	ld	r24, Z
    17c6:	89 2b       	or	r24, r25
    17c8:	80 83       	st	Z, r24
    17ca:	1f 5f       	subi	r17, 0xFF	; 255
    17cc:	13 30       	cpi	r17, 0x03	; 3
    17ce:	09 f0       	breq	.+2      	; 0x17d2 <plan_buffer_line+0x1e6>
    17d0:	84 cf       	rjmp	.-248    	; 0x16da <plan_buffer_line+0xee>
    17d2:	80 e0       	ldi	r24, 0x00	; 0
    17d4:	cd 28       	or	r12, r13
    17d6:	ce 28       	or	r12, r14
    17d8:	cf 28       	or	r12, r15
    17da:	09 f4       	brne	.+2      	; 0x17de <plan_buffer_line+0x1f2>
    17dc:	cb c0       	rjmp	.+406    	; 0x1974 <plan_buffer_line+0x388>
    17de:	ce 01       	movw	r24, r28
    17e0:	85 96       	adiw	r24, 0x25	; 37
    17e2:	0e 94 c0 09 	call	0x1380	; 0x1380 <convert_delta_vector_to_unit_vector>
    17e6:	4b 01       	movw	r8, r22
    17e8:	5c 01       	movw	r10, r24
    17ea:	22 e3       	ldi	r18, 0x32	; 50
    17ec:	22 9d       	mul	r18, r2
    17ee:	c0 01       	movw	r24, r0
    17f0:	23 9d       	mul	r18, r3
    17f2:	90 0d       	add	r25, r0
    17f4:	11 24       	eor	r1, r1
    17f6:	9c 01       	movw	r18, r24
    17f8:	2a 52       	subi	r18, 0x2A	; 42
    17fa:	3d 4f       	sbci	r19, 0xFD	; 253
    17fc:	79 01       	movw	r14, r18
    17fe:	f9 01       	movw	r30, r18
    1800:	86 8e       	std	Z+30, r8	; 0x1e
    1802:	97 8e       	std	Z+31, r9	; 0x1f
    1804:	a0 a2       	std	Z+32, r10	; 0x20
    1806:	b1 a2       	std	Z+33, r11	; 0x21
    1808:	be 01       	movw	r22, r28
    180a:	6b 5d       	subi	r22, 0xDB	; 219
    180c:	7f 4f       	sbci	r23, 0xFF	; 255
    180e:	8a e5       	ldi	r24, 0x5A	; 90
    1810:	96 e0       	ldi	r25, 0x06	; 6
    1812:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    1816:	f7 01       	movw	r30, r14
    1818:	62 8f       	std	Z+26, r22	; 0x1a
    181a:	73 8f       	std	Z+27, r23	; 0x1b
    181c:	84 8f       	std	Z+28, r24	; 0x1c
    181e:	95 8f       	std	Z+29, r25	; 0x1d
    1820:	be 01       	movw	r22, r28
    1822:	6b 5d       	subi	r22, 0xDB	; 219
    1824:	7f 4f       	sbci	r23, 0xFF	; 255
    1826:	8e e4       	ldi	r24, 0x4E	; 78
    1828:	96 e0       	ldi	r25, 0x06	; 6
    182a:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    182e:	f7 01       	movw	r30, r14
    1830:	66 a3       	std	Z+38, r22	; 0x26
    1832:	77 a3       	std	Z+39, r23	; 0x27
    1834:	80 a7       	std	Z+40, r24	; 0x28
    1836:	91 a7       	std	Z+41, r25	; 0x29
    1838:	11 89       	ldd	r17, Z+17	; 0x11
    183a:	10 ff       	sbrs	r17, 0
    183c:	09 c0       	rjmp	.+18     	; 0x1850 <plan_buffer_line+0x264>
    183e:	62 a7       	std	Z+42, r22	; 0x2a
    1840:	73 a7       	std	Z+43, r23	; 0x2b
    1842:	84 a7       	std	Z+44, r24	; 0x2c
    1844:	95 a7       	std	Z+45, r25	; 0x2d
    1846:	10 c0       	rjmp	.+32     	; 0x1868 <plan_buffer_line+0x27c>
    1848:	2c e0       	ldi	r18, 0x0C	; 12
    184a:	e7 ef       	ldi	r30, 0xF7	; 247
    184c:	f5 e0       	ldi	r31, 0x05	; 5
    184e:	0f cf       	rjmp	.-482    	; 0x166e <plan_buffer_line+0x82>
    1850:	f3 01       	movw	r30, r6
    1852:	20 81       	ld	r18, Z
    1854:	31 81       	ldd	r19, Z+1	; 0x01
    1856:	42 81       	ldd	r20, Z+2	; 0x02
    1858:	53 81       	ldd	r21, Z+3	; 0x03
    185a:	13 fd       	sbrc	r17, 3
    185c:	a5 c0       	rjmp	.+330    	; 0x19a8 <plan_buffer_line+0x3bc>
    185e:	f7 01       	movw	r30, r14
    1860:	22 a7       	std	Z+42, r18	; 0x2a
    1862:	33 a7       	std	Z+43, r19	; 0x2b
    1864:	44 a7       	std	Z+44, r20	; 0x2c
    1866:	55 a7       	std	Z+45, r21	; 0x2d
    1868:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    186c:	08 17       	cp	r16, r24
    186e:	11 f0       	breq	.+4      	; 0x1874 <plan_buffer_line+0x288>
    1870:	11 ff       	sbrs	r17, 1
    1872:	a0 c0       	rjmp	.+320    	; 0x19b4 <plan_buffer_line+0x3c8>
    1874:	82 e3       	ldi	r24, 0x32	; 50
    1876:	82 9d       	mul	r24, r2
    1878:	f0 01       	movw	r30, r0
    187a:	83 9d       	mul	r24, r3
    187c:	f0 0d       	add	r31, r0
    187e:	11 24       	eor	r1, r1
    1880:	ea 52       	subi	r30, 0x2A	; 42
    1882:	fd 4f       	sbci	r31, 0xFD	; 253
    1884:	12 8a       	std	Z+18, r1	; 0x12
    1886:	13 8a       	std	Z+19, r1	; 0x13
    1888:	14 8a       	std	Z+20, r1	; 0x14
    188a:	15 8a       	std	Z+21, r1	; 0x15
    188c:	12 a2       	std	Z+34, r1	; 0x22
    188e:	13 a2       	std	Z+35, r1	; 0x23
    1890:	14 a2       	std	Z+36, r1	; 0x24
    1892:	15 a2       	std	Z+37, r1	; 0x25
    1894:	82 e3       	ldi	r24, 0x32	; 50
    1896:	82 9d       	mul	r24, r2
    1898:	80 01       	movw	r16, r0
    189a:	83 9d       	mul	r24, r3
    189c:	10 0d       	add	r17, r0
    189e:	11 24       	eor	r1, r1
    18a0:	0a 52       	subi	r16, 0x2A	; 42
    18a2:	1d 4f       	sbci	r17, 0xFD	; 253
    18a4:	f8 01       	movw	r30, r16
    18a6:	81 89       	ldd	r24, Z+17	; 0x11
    18a8:	81 fd       	sbrc	r24, 1
    18aa:	63 c0       	rjmp	.+198    	; 0x1972 <plan_buffer_line+0x386>
    18ac:	8b a9       	ldd	r24, Y+51	; 0x33
    18ae:	9c a9       	ldd	r25, Y+52	; 0x34
    18b0:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    18b4:	6b 01       	movw	r12, r22
    18b6:	7c 01       	movw	r14, r24
    18b8:	80 90 0f 06 	lds	r8, 0x060F	; 0x80060f <pl+0x18>
    18bc:	90 90 10 06 	lds	r9, 0x0610	; 0x800610 <pl+0x19>
    18c0:	a0 90 11 06 	lds	r10, 0x0611	; 0x800611 <pl+0x1a>
    18c4:	b0 90 12 06 	lds	r11, 0x0612	; 0x800612 <pl+0x1b>
    18c8:	ac 01       	movw	r20, r24
    18ca:	9b 01       	movw	r18, r22
    18cc:	c5 01       	movw	r24, r10
    18ce:	b4 01       	movw	r22, r8
    18d0:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    18d4:	87 ff       	sbrs	r24, 7
    18d6:	36 c1       	rjmp	.+620    	; 0x1b44 <plan_buffer_line+0x558>
    18d8:	a5 01       	movw	r20, r10
    18da:	94 01       	movw	r18, r8
    18dc:	c5 01       	movw	r24, r10
    18de:	b4 01       	movw	r22, r8
    18e0:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    18e4:	f8 01       	movw	r30, r16
    18e6:	66 8b       	std	Z+22, r22	; 0x16
    18e8:	77 8b       	std	Z+23, r23	; 0x17
    18ea:	80 8f       	std	Z+24, r24	; 0x18
    18ec:	91 8f       	std	Z+25, r25	; 0x19
    18ee:	82 e3       	ldi	r24, 0x32	; 50
    18f0:	82 9d       	mul	r24, r2
    18f2:	80 01       	movw	r16, r0
    18f4:	83 9d       	mul	r24, r3
    18f6:	10 0d       	add	r17, r0
    18f8:	11 24       	eor	r1, r1
    18fa:	0a 52       	subi	r16, 0x2A	; 42
    18fc:	1d 4f       	sbci	r17, 0xFD	; 253
    18fe:	f8 01       	movw	r30, r16
    1900:	82 a0       	ldd	r8, Z+34	; 0x22
    1902:	93 a0       	ldd	r9, Z+35	; 0x23
    1904:	a4 a0       	ldd	r10, Z+36	; 0x24
    1906:	b5 a0       	ldd	r11, Z+37	; 0x25
    1908:	a5 01       	movw	r20, r10
    190a:	94 01       	movw	r18, r8
    190c:	66 89       	ldd	r22, Z+22	; 0x16
    190e:	77 89       	ldd	r23, Z+23	; 0x17
    1910:	80 8d       	ldd	r24, Z+24	; 0x18
    1912:	91 8d       	ldd	r25, Z+25	; 0x19
    1914:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    1918:	18 16       	cp	r1, r24
    191a:	2c f4       	brge	.+10     	; 0x1926 <plan_buffer_line+0x33a>
    191c:	f8 01       	movw	r30, r16
    191e:	86 8a       	std	Z+22, r8	; 0x16
    1920:	97 8a       	std	Z+23, r9	; 0x17
    1922:	a0 8e       	std	Z+24, r10	; 0x18
    1924:	b1 8e       	std	Z+25, r11	; 0x19
    1926:	c0 92 0f 06 	sts	0x060F, r12	; 0x80060f <pl+0x18>
    192a:	d0 92 10 06 	sts	0x0610, r13	; 0x800610 <pl+0x19>
    192e:	e0 92 11 06 	sts	0x0611, r14	; 0x800611 <pl+0x1a>
    1932:	f0 92 12 06 	sts	0x0612, r15	; 0x800612 <pl+0x1b>
    1936:	8c e0       	ldi	r24, 0x0C	; 12
    1938:	fe 01       	movw	r30, r28
    193a:	b5 96       	adiw	r30, 0x25	; 37
    193c:	a3 e0       	ldi	r26, 0x03	; 3
    193e:	b6 e0       	ldi	r27, 0x06	; 6
    1940:	01 90       	ld	r0, Z+
    1942:	0d 92       	st	X+, r0
    1944:	8a 95       	dec	r24
    1946:	e1 f7       	brne	.-8      	; 0x1940 <plan_buffer_line+0x354>
    1948:	8c e0       	ldi	r24, 0x0C	; 12
    194a:	fe 01       	movw	r30, r28
    194c:	3d 96       	adiw	r30, 0x0d	; 13
    194e:	a7 ef       	ldi	r26, 0xF7	; 247
    1950:	b5 e0       	ldi	r27, 0x05	; 5
    1952:	01 90       	ld	r0, Z+
    1954:	0d 92       	st	X+, r0
    1956:	8a 95       	dec	r24
    1958:	e1 f7       	brne	.-8      	; 0x1952 <plan_buffer_line+0x366>
    195a:	80 91 d4 02 	lds	r24, 0x02D4	; 0x8002d4 <next_buffer_head>
    195e:	80 93 f6 05 	sts	0x05F6, r24	; 0x8005f6 <block_buffer_head>
    1962:	8f 5f       	subi	r24, 0xFF	; 255
    1964:	80 31       	cpi	r24, 0x10	; 16
    1966:	09 f4       	brne	.+2      	; 0x196a <plan_buffer_line+0x37e>
    1968:	80 e0       	ldi	r24, 0x00	; 0
    196a:	80 93 d4 02 	sts	0x02D4, r24	; 0x8002d4 <next_buffer_head>
    196e:	0e 94 f1 04 	call	0x9e2	; 0x9e2 <planner_recalculate>
    1972:	81 e0       	ldi	r24, 0x01	; 1
    1974:	ce 5b       	subi	r28, 0xBE	; 190
    1976:	df 4f       	sbci	r29, 0xFF	; 255
    1978:	0f b6       	in	r0, 0x3f	; 63
    197a:	f8 94       	cli
    197c:	de bf       	out	0x3e, r29	; 62
    197e:	0f be       	out	0x3f, r0	; 63
    1980:	cd bf       	out	0x3d, r28	; 61
    1982:	df 91       	pop	r29
    1984:	cf 91       	pop	r28
    1986:	1f 91       	pop	r17
    1988:	0f 91       	pop	r16
    198a:	ff 90       	pop	r15
    198c:	ef 90       	pop	r14
    198e:	df 90       	pop	r13
    1990:	cf 90       	pop	r12
    1992:	bf 90       	pop	r11
    1994:	af 90       	pop	r10
    1996:	9f 90       	pop	r9
    1998:	8f 90       	pop	r8
    199a:	7f 90       	pop	r7
    199c:	6f 90       	pop	r6
    199e:	5f 90       	pop	r5
    19a0:	4f 90       	pop	r4
    19a2:	3f 90       	pop	r3
    19a4:	2f 90       	pop	r2
    19a6:	08 95       	ret
    19a8:	c5 01       	movw	r24, r10
    19aa:	b4 01       	movw	r22, r8
    19ac:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    19b0:	f7 01       	movw	r30, r14
    19b2:	45 cf       	rjmp	.-374    	; 0x183e <plan_buffer_line+0x252>
    19b4:	23 e0       	ldi	r18, 0x03	; 3
    19b6:	36 e0       	ldi	r19, 0x06	; 6
    19b8:	3a ab       	std	Y+50, r19	; 0x32
    19ba:	29 ab       	std	Y+49, r18	; 0x31
    19bc:	8e 01       	movw	r16, r28
    19be:	0f 5f       	subi	r16, 0xFF	; 255
    19c0:	1f 4f       	sbci	r17, 0xFF	; 255
    19c2:	6d a9       	ldd	r22, Y+53	; 0x35
    19c4:	7e a9       	ldd	r23, Y+54	; 0x36
    19c6:	64 5f       	subi	r22, 0xF4	; 244
    19c8:	7f 4f       	sbci	r23, 0xFF	; 255
    19ca:	7c af       	std	Y+60, r23	; 0x3c
    19cc:	6b af       	std	Y+59, r22	; 0x3b
    19ce:	c1 2c       	mov	r12, r1
    19d0:	d1 2c       	mov	r13, r1
    19d2:	76 01       	movw	r14, r12
    19d4:	0f ab       	std	Y+55, r16	; 0x37
    19d6:	19 af       	std	Y+57, r17	; 0x39
    19d8:	e9 a9       	ldd	r30, Y+49	; 0x31
    19da:	fa a9       	ldd	r31, Y+50	; 0x32
    19dc:	81 90       	ld	r8, Z+
    19de:	91 90       	ld	r9, Z+
    19e0:	a1 90       	ld	r10, Z+
    19e2:	b1 90       	ld	r11, Z+
    19e4:	fa ab       	std	Y+50, r31	; 0x32
    19e6:	e9 ab       	std	Y+49, r30	; 0x31
    19e8:	ed a9       	ldd	r30, Y+53	; 0x35
    19ea:	fe a9       	ldd	r31, Y+54	; 0x36
    19ec:	41 90       	ld	r4, Z+
    19ee:	51 90       	ld	r5, Z+
    19f0:	61 90       	ld	r6, Z+
    19f2:	71 90       	ld	r7, Z+
    19f4:	fe ab       	std	Y+54, r31	; 0x36
    19f6:	ed ab       	std	Y+53, r30	; 0x35
    19f8:	a3 01       	movw	r20, r6
    19fa:	92 01       	movw	r18, r4
    19fc:	c5 01       	movw	r24, r10
    19fe:	b4 01       	movw	r22, r8
    1a00:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1a04:	9b 01       	movw	r18, r22
    1a06:	ac 01       	movw	r20, r24
    1a08:	c7 01       	movw	r24, r14
    1a0a:	b6 01       	movw	r22, r12
    1a0c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1a10:	6b 01       	movw	r12, r22
    1a12:	7c 01       	movw	r14, r24
    1a14:	a5 01       	movw	r20, r10
    1a16:	94 01       	movw	r18, r8
    1a18:	c3 01       	movw	r24, r6
    1a1a:	b2 01       	movw	r22, r4
    1a1c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1a20:	f8 01       	movw	r30, r16
    1a22:	61 93       	st	Z+, r22
    1a24:	71 93       	st	Z+, r23
    1a26:	81 93       	st	Z+, r24
    1a28:	91 93       	st	Z+, r25
    1a2a:	8f 01       	movw	r16, r30
    1a2c:	2b ad       	ldd	r18, Y+59	; 0x3b
    1a2e:	3c ad       	ldd	r19, Y+60	; 0x3c
    1a30:	6d a9       	ldd	r22, Y+53	; 0x35
    1a32:	7e a9       	ldd	r23, Y+54	; 0x36
    1a34:	26 17       	cp	r18, r22
    1a36:	37 07       	cpc	r19, r23
    1a38:	79 f6       	brne	.-98     	; 0x19d8 <plan_buffer_line+0x3ec>
    1a3a:	2f ee       	ldi	r18, 0xEF	; 239
    1a3c:	3f ef       	ldi	r19, 0xFF	; 255
    1a3e:	4f e7       	ldi	r20, 0x7F	; 127
    1a40:	5f e3       	ldi	r21, 0x3F	; 63
    1a42:	c7 01       	movw	r24, r14
    1a44:	b6 01       	movw	r22, r12
    1a46:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    1a4a:	18 16       	cp	r1, r24
    1a4c:	4c f4       	brge	.+18     	; 0x1a60 <plan_buffer_line+0x474>
    1a4e:	82 e3       	ldi	r24, 0x32	; 50
    1a50:	82 9d       	mul	r24, r2
    1a52:	f0 01       	movw	r30, r0
    1a54:	83 9d       	mul	r24, r3
    1a56:	f0 0d       	add	r31, r0
    1a58:	11 24       	eor	r1, r1
    1a5a:	ea 52       	subi	r30, 0x2A	; 42
    1a5c:	fd 4f       	sbci	r31, 0xFD	; 253
    1a5e:	16 cf       	rjmp	.-468    	; 0x188c <plan_buffer_line+0x2a0>
    1a60:	2f ee       	ldi	r18, 0xEF	; 239
    1a62:	3f ef       	ldi	r19, 0xFF	; 255
    1a64:	4f e7       	ldi	r20, 0x7F	; 127
    1a66:	5f eb       	ldi	r21, 0xBF	; 191
    1a68:	c7 01       	movw	r24, r14
    1a6a:	b6 01       	movw	r22, r12
    1a6c:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1a70:	87 ff       	sbrs	r24, 7
    1a72:	11 c0       	rjmp	.+34     	; 0x1a96 <plan_buffer_line+0x4aa>
    1a74:	82 e3       	ldi	r24, 0x32	; 50
    1a76:	82 9d       	mul	r24, r2
    1a78:	f0 01       	movw	r30, r0
    1a7a:	83 9d       	mul	r24, r3
    1a7c:	f0 0d       	add	r31, r0
    1a7e:	11 24       	eor	r1, r1
    1a80:	ea 52       	subi	r30, 0x2A	; 42
    1a82:	fd 4f       	sbci	r31, 0xFD	; 253
    1a84:	89 e9       	ldi	r24, 0x99	; 153
    1a86:	96 e7       	ldi	r25, 0x76	; 118
    1a88:	a6 e9       	ldi	r26, 0x96	; 150
    1a8a:	be e7       	ldi	r27, 0x7E	; 126
    1a8c:	82 a3       	std	Z+34, r24	; 0x22
    1a8e:	93 a3       	std	Z+35, r25	; 0x23
    1a90:	a4 a3       	std	Z+36, r26	; 0x24
    1a92:	b5 a3       	std	Z+37, r27	; 0x25
    1a94:	ff ce       	rjmp	.-514    	; 0x1894 <plan_buffer_line+0x2a8>
    1a96:	8f a9       	ldd	r24, Y+55	; 0x37
    1a98:	99 ad       	ldd	r25, Y+57	; 0x39
    1a9a:	0e 94 c0 09 	call	0x1380	; 0x1380 <convert_delta_vector_to_unit_vector>
    1a9e:	6f a9       	ldd	r22, Y+55	; 0x37
    1aa0:	79 ad       	ldd	r23, Y+57	; 0x39
    1aa2:	8a e5       	ldi	r24, 0x5A	; 90
    1aa4:	96 e0       	ldi	r25, 0x06	; 6
    1aa6:	0e 94 20 03 	call	0x640	; 0x640 <limit_value_by_axis_maximum>
    1aaa:	4b 01       	movw	r8, r22
    1aac:	5c 01       	movw	r10, r24
    1aae:	a7 01       	movw	r20, r14
    1ab0:	96 01       	movw	r18, r12
    1ab2:	60 e0       	ldi	r22, 0x00	; 0
    1ab4:	70 e0       	ldi	r23, 0x00	; 0
    1ab6:	80 e8       	ldi	r24, 0x80	; 128
    1ab8:	9f e3       	ldi	r25, 0x3F	; 63
    1aba:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1abe:	20 e0       	ldi	r18, 0x00	; 0
    1ac0:	30 e0       	ldi	r19, 0x00	; 0
    1ac2:	40 e0       	ldi	r20, 0x00	; 0
    1ac4:	5f e3       	ldi	r21, 0x3F	; 63
    1ac6:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1aca:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    1ace:	6b 01       	movw	r12, r22
    1ad0:	7c 01       	movw	r14, r24
    1ad2:	20 91 77 06 	lds	r18, 0x0677	; 0x800677 <settings+0x35>
    1ad6:	30 91 78 06 	lds	r19, 0x0678	; 0x800678 <settings+0x36>
    1ada:	40 91 79 06 	lds	r20, 0x0679	; 0x800679 <settings+0x37>
    1ade:	50 91 7a 06 	lds	r21, 0x067A	; 0x80067a <settings+0x38>
    1ae2:	c5 01       	movw	r24, r10
    1ae4:	b4 01       	movw	r22, r8
    1ae6:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1aea:	a7 01       	movw	r20, r14
    1aec:	96 01       	movw	r18, r12
    1aee:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1af2:	4b 01       	movw	r8, r22
    1af4:	5c 01       	movw	r10, r24
    1af6:	a7 01       	movw	r20, r14
    1af8:	96 01       	movw	r18, r12
    1afa:	60 e0       	ldi	r22, 0x00	; 0
    1afc:	70 e0       	ldi	r23, 0x00	; 0
    1afe:	80 e8       	ldi	r24, 0x80	; 128
    1b00:	9f e3       	ldi	r25, 0x3F	; 63
    1b02:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1b06:	9b 01       	movw	r18, r22
    1b08:	ac 01       	movw	r20, r24
    1b0a:	c5 01       	movw	r24, r10
    1b0c:	b4 01       	movw	r22, r8
    1b0e:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1b12:	6b 01       	movw	r12, r22
    1b14:	7c 01       	movw	r14, r24
    1b16:	20 e0       	ldi	r18, 0x00	; 0
    1b18:	30 e0       	ldi	r19, 0x00	; 0
    1b1a:	a9 01       	movw	r20, r18
    1b1c:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1b20:	87 ff       	sbrs	r24, 7
    1b22:	03 c0       	rjmp	.+6      	; 0x1b2a <plan_buffer_line+0x53e>
    1b24:	c1 2c       	mov	r12, r1
    1b26:	d1 2c       	mov	r13, r1
    1b28:	76 01       	movw	r14, r12
    1b2a:	82 e3       	ldi	r24, 0x32	; 50
    1b2c:	82 9d       	mul	r24, r2
    1b2e:	f0 01       	movw	r30, r0
    1b30:	83 9d       	mul	r24, r3
    1b32:	f0 0d       	add	r31, r0
    1b34:	11 24       	eor	r1, r1
    1b36:	ea 52       	subi	r30, 0x2A	; 42
    1b38:	fd 4f       	sbci	r31, 0xFD	; 253
    1b3a:	c2 a2       	std	Z+34, r12	; 0x22
    1b3c:	d3 a2       	std	Z+35, r13	; 0x23
    1b3e:	e4 a2       	std	Z+36, r14	; 0x24
    1b40:	f5 a2       	std	Z+37, r15	; 0x25
    1b42:	a8 ce       	rjmp	.-688    	; 0x1894 <plan_buffer_line+0x2a8>
    1b44:	a7 01       	movw	r20, r14
    1b46:	96 01       	movw	r18, r12
    1b48:	c7 01       	movw	r24, r14
    1b4a:	b6 01       	movw	r22, r12
    1b4c:	c9 ce       	rjmp	.-622    	; 0x18e0 <plan_buffer_line+0x2f4>

00001b4e <st_go_idle>:
    1b4e:	80 91 6f 00 	lds	r24, 0x006F	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
    1b52:	8d 7f       	andi	r24, 0xFD	; 253
    1b54:	80 93 6f 00 	sts	0x006F, r24	; 0x80006f <__DATA_REGION_ORIGIN__+0xf>
    1b58:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    1b5c:	88 7f       	andi	r24, 0xF8	; 248
    1b5e:	81 60       	ori	r24, 0x01	; 1
    1b60:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    1b64:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    1b68:	80 91 75 06 	lds	r24, 0x0675	; 0x800675 <settings+0x33>
    1b6c:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    1b70:	8f 3f       	cpi	r24, 0xFF	; 255
    1b72:	a1 f4       	brne	.+40     	; 0x1b9c <st_go_idle+0x4e>
    1b74:	20 91 14 06 	lds	r18, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    1b78:	21 11       	cpse	r18, r1
    1b7a:	10 c0       	rjmp	.+32     	; 0x1b9c <st_go_idle+0x4e>
    1b7c:	90 38       	cpi	r25, 0x80	; 128
    1b7e:	81 f4       	brne	.+32     	; 0x1ba0 <st_go_idle+0x52>
    1b80:	90 e0       	ldi	r25, 0x00	; 0
    1b82:	01 97       	sbiw	r24, 0x01	; 1
    1b84:	78 f4       	brcc	.+30     	; 0x1ba4 <st_go_idle+0x56>
    1b86:	81 e0       	ldi	r24, 0x01	; 1
    1b88:	90 91 87 06 	lds	r25, 0x0687	; 0x800687 <settings+0x45>
    1b8c:	92 ff       	sbrs	r25, 2
    1b8e:	02 c0       	rjmp	.+4      	; 0x1b94 <st_go_idle+0x46>
    1b90:	91 e0       	ldi	r25, 0x01	; 1
    1b92:	89 27       	eor	r24, r25
    1b94:	88 23       	and	r24, r24
    1b96:	69 f0       	breq	.+26     	; 0x1bb2 <st_go_idle+0x64>
    1b98:	28 9a       	sbi	0x05, 0	; 5
    1b9a:	08 95       	ret
    1b9c:	94 30       	cpi	r25, 0x04	; 4
    1b9e:	81 f7       	brne	.-32     	; 0x1b80 <st_go_idle+0x32>
    1ba0:	80 e0       	ldi	r24, 0x00	; 0
    1ba2:	f2 cf       	rjmp	.-28     	; 0x1b88 <st_go_idle+0x3a>
    1ba4:	ef e9       	ldi	r30, 0x9F	; 159
    1ba6:	ff e0       	ldi	r31, 0x0F	; 15
    1ba8:	31 97       	sbiw	r30, 0x01	; 1
    1baa:	f1 f7       	brne	.-4      	; 0x1ba8 <st_go_idle+0x5a>
    1bac:	00 c0       	rjmp	.+0      	; 0x1bae <st_go_idle+0x60>
    1bae:	00 00       	nop
    1bb0:	e8 cf       	rjmp	.-48     	; 0x1b82 <st_go_idle+0x34>
    1bb2:	28 98       	cbi	0x05, 0	; 5
    1bb4:	08 95       	ret

00001bb6 <st_reset>:
    1bb6:	cf 93       	push	r28
    1bb8:	df 93       	push	r29
    1bba:	0e 94 a7 0d 	call	0x1b4e	; 0x1b4e <st_go_idle>
    1bbe:	e1 ea       	ldi	r30, 0xA1	; 161
    1bc0:	f2 e0       	ldi	r31, 0x02	; 2
    1bc2:	80 e3       	ldi	r24, 0x30	; 48
    1bc4:	df 01       	movw	r26, r30
    1bc6:	1d 92       	st	X+, r1
    1bc8:	8a 95       	dec	r24
    1bca:	e9 f7       	brne	.-6      	; 0x1bc6 <st_reset+0x10>
    1bcc:	c5 ef       	ldi	r28, 0xF5	; 245
    1bce:	d1 e0       	ldi	r29, 0x01	; 1
    1bd0:	83 e2       	ldi	r24, 0x23	; 35
    1bd2:	fe 01       	movw	r30, r28
    1bd4:	11 92       	st	Z+, r1
    1bd6:	8a 95       	dec	r24
    1bd8:	e9 f7       	brne	.-6      	; 0x1bd4 <st_reset+0x1e>
    1bda:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
    1bde:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
    1be2:	10 92 18 02 	sts	0x0218, r1	; 0x800218 <segment_buffer_tail>
    1be6:	10 92 44 02 	sts	0x0244, r1	; 0x800244 <segment_buffer_head>
    1bea:	81 e0       	ldi	r24, 0x01	; 1
    1bec:	80 93 19 02 	sts	0x0219, r24	; 0x800219 <segment_next_head>
    1bf0:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    1bf4:	0e 94 5c 06 	call	0xcb8	; 0xcb8 <st_generate_step_dir_invert_masks>
    1bf8:	80 91 f3 01 	lds	r24, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    1bfc:	8f 87       	std	Y+15, r24	; 0x0f
    1bfe:	8b b1       	in	r24, 0x0b	; 11
    1c00:	83 7e       	andi	r24, 0xE3	; 227
    1c02:	90 91 f2 01 	lds	r25, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    1c06:	89 2b       	or	r24, r25
    1c08:	8b b9       	out	0x0b, r24	; 11
    1c0a:	8b b1       	in	r24, 0x0b	; 11
    1c0c:	8f 71       	andi	r24, 0x1F	; 31
    1c0e:	90 91 f3 01 	lds	r25, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    1c12:	89 2b       	or	r24, r25
    1c14:	8b b9       	out	0x0b, r24	; 11
    1c16:	df 91       	pop	r29
    1c18:	cf 91       	pop	r28
    1c1a:	08 95       	ret

00001c1c <mc_reset>:
    1c1c:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    1c20:	84 fd       	sbrc	r24, 4
    1c22:	1f c0       	rjmp	.+62     	; 0x1c62 <mc_reset+0x46>
    1c24:	80 e1       	ldi	r24, 0x10	; 16
    1c26:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    1c2a:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    1c2e:	8f 77       	andi	r24, 0x7F	; 127
    1c30:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    1c34:	43 98       	cbi	0x08, 3	; 8
    1c36:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    1c3a:	89 2f       	mov	r24, r25
    1c3c:	8c 72       	andi	r24, 0x2C	; 44
    1c3e:	21 f4       	brne	.+8      	; 0x1c48 <mc_reset+0x2c>
    1c40:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    1c44:	86 70       	andi	r24, 0x06	; 6
    1c46:	69 f0       	breq	.+26     	; 0x1c62 <mc_reset+0x46>
    1c48:	94 30       	cpi	r25, 0x04	; 4
    1c4a:	49 f4       	brne	.+18     	; 0x1c5e <mc_reset+0x42>
    1c4c:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    1c50:	81 11       	cpse	r24, r1
    1c52:	03 c0       	rjmp	.+6      	; 0x1c5a <mc_reset+0x3e>
    1c54:	86 e0       	ldi	r24, 0x06	; 6
    1c56:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    1c5a:	0c 94 a7 0d 	jmp	0x1b4e	; 0x1b4e <st_go_idle>
    1c5e:	83 e0       	ldi	r24, 0x03	; 3
    1c60:	fa cf       	rjmp	.-12     	; 0x1c56 <mc_reset+0x3a>
    1c62:	08 95       	ret

00001c64 <st_prep_buffer>:
    1c64:	2f 92       	push	r2
    1c66:	3f 92       	push	r3
    1c68:	4f 92       	push	r4
    1c6a:	5f 92       	push	r5
    1c6c:	6f 92       	push	r6
    1c6e:	7f 92       	push	r7
    1c70:	8f 92       	push	r8
    1c72:	9f 92       	push	r9
    1c74:	af 92       	push	r10
    1c76:	bf 92       	push	r11
    1c78:	cf 92       	push	r12
    1c7a:	df 92       	push	r13
    1c7c:	ef 92       	push	r14
    1c7e:	ff 92       	push	r15
    1c80:	0f 93       	push	r16
    1c82:	1f 93       	push	r17
    1c84:	cf 93       	push	r28
    1c86:	df 93       	push	r29
    1c88:	cd b7       	in	r28, 0x3d	; 61
    1c8a:	de b7       	in	r29, 0x3e	; 62
    1c8c:	eb 97       	sbiw	r28, 0x3b	; 59
    1c8e:	0f b6       	in	r0, 0x3f	; 63
    1c90:	f8 94       	cli
    1c92:	de bf       	out	0x3e, r29	; 62
    1c94:	0f be       	out	0x3f, r0	; 63
    1c96:	cd bf       	out	0x3d, r28	; 61
    1c98:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    1c9c:	80 fd       	sbrc	r24, 0
    1c9e:	53 c2       	rjmp	.+1190   	; 0x2146 <st_prep_buffer+0x4e2>
    1ca0:	90 91 18 02 	lds	r25, 0x0218	; 0x800218 <segment_buffer_tail>
    1ca4:	80 91 19 02 	lds	r24, 0x0219	; 0x800219 <segment_next_head>
    1ca8:	98 17       	cp	r25, r24
    1caa:	09 f4       	brne	.+2      	; 0x1cae <st_prep_buffer+0x4a>
    1cac:	4c c2       	rjmp	.+1176   	; 0x2146 <st_prep_buffer+0x4e2>
    1cae:	80 91 d1 02 	lds	r24, 0x02D1	; 0x8002d1 <pl_block>
    1cb2:	90 91 d2 02 	lds	r25, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1cb6:	89 2b       	or	r24, r25
    1cb8:	09 f0       	breq	.+2      	; 0x1cbc <st_prep_buffer+0x58>
    1cba:	7e c0       	rjmp	.+252    	; 0x1db8 <st_prep_buffer+0x154>
    1cbc:	10 91 35 06 	lds	r17, 0x0635	; 0x800635 <sys+0x4>
    1cc0:	12 ff       	sbrs	r17, 2
    1cc2:	5a c2       	rjmp	.+1204   	; 0x2178 <st_prep_buffer+0x514>
    1cc4:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    1cc8:	22 e3       	ldi	r18, 0x32	; 50
    1cca:	82 9f       	mul	r24, r18
    1ccc:	c0 01       	movw	r24, r0
    1cce:	11 24       	eor	r1, r1
    1cd0:	8a 52       	subi	r24, 0x2A	; 42
    1cd2:	9d 4f       	sbci	r25, 0xFD	; 253
    1cd4:	90 93 d2 02 	sts	0x02D2, r25	; 0x8002d2 <pl_block+0x1>
    1cd8:	80 93 d1 02 	sts	0x02D1, r24	; 0x8002d1 <pl_block>
    1cdc:	40 91 d1 02 	lds	r20, 0x02D1	; 0x8002d1 <pl_block>
    1ce0:	50 91 d2 02 	lds	r21, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1ce4:	5a 87       	std	Y+10, r21	; 0x0a
    1ce6:	49 87       	std	Y+9, r20	; 0x09
    1ce8:	45 2b       	or	r20, r21
    1cea:	09 f4       	brne	.+2      	; 0x1cee <st_prep_buffer+0x8a>
    1cec:	2c c2       	rjmp	.+1112   	; 0x2146 <st_prep_buffer+0x4e2>
    1cee:	00 91 a2 02 	lds	r16, 0x02A2	; 0x8002a2 <prep+0x1>
    1cf2:	00 ff       	sbrs	r16, 0
    1cf4:	44 c2       	rjmp	.+1160   	; 0x217e <st_prep_buffer+0x51a>
    1cf6:	10 92 a2 02 	sts	0x02A2, r1	; 0x8002a2 <prep+0x1>
    1cfa:	10 92 b4 02 	sts	0x02B4, r1	; 0x8002b4 <prep+0x13>
    1cfe:	10 92 b5 02 	sts	0x02B5, r1	; 0x8002b5 <prep+0x14>
    1d02:	10 92 b6 02 	sts	0x02B6, r1	; 0x8002b6 <prep+0x15>
    1d06:	10 92 b7 02 	sts	0x02B7, r1	; 0x8002b7 <prep+0x16>
    1d0a:	a9 85       	ldd	r26, Y+9	; 0x09
    1d0c:	ba 85       	ldd	r27, Y+10	; 0x0a
    1d0e:	5a 96       	adiw	r26, 0x1a	; 26
    1d10:	2d 91       	ld	r18, X+
    1d12:	3d 91       	ld	r19, X+
    1d14:	4d 91       	ld	r20, X+
    1d16:	5c 91       	ld	r21, X
    1d18:	5d 97       	sbiw	r26, 0x1d	; 29
    1d1a:	29 83       	std	Y+1, r18	; 0x01
    1d1c:	3a 83       	std	Y+2, r19	; 0x02
    1d1e:	4b 83       	std	Y+3, r20	; 0x03
    1d20:	5c 83       	std	Y+4, r21	; 0x04
    1d22:	60 e0       	ldi	r22, 0x00	; 0
    1d24:	70 e0       	ldi	r23, 0x00	; 0
    1d26:	80 e0       	ldi	r24, 0x00	; 0
    1d28:	9f e3       	ldi	r25, 0x3F	; 63
    1d2a:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1d2e:	6d 83       	std	Y+5, r22	; 0x05
    1d30:	7e 83       	std	Y+6, r23	; 0x06
    1d32:	8f 83       	std	Y+7, r24	; 0x07
    1d34:	98 87       	std	Y+8, r25	; 0x08
    1d36:	e9 85       	ldd	r30, Y+9	; 0x09
    1d38:	fa 85       	ldd	r31, Y+10	; 0x0a
    1d3a:	46 8c       	ldd	r4, Z+30	; 0x1e
    1d3c:	57 8c       	ldd	r5, Z+31	; 0x1f
    1d3e:	60 a0       	ldd	r6, Z+32	; 0x20
    1d40:	71 a0       	ldd	r7, Z+33	; 0x21
    1d42:	82 88       	ldd	r8, Z+18	; 0x12
    1d44:	93 88       	ldd	r9, Z+19	; 0x13
    1d46:	a4 88       	ldd	r10, Z+20	; 0x14
    1d48:	b5 88       	ldd	r11, Z+21	; 0x15
    1d4a:	11 ff       	sbrs	r17, 1
    1d4c:	05 c3       	rjmp	.+1546   	; 0x2358 <st_prep_buffer+0x6f4>
    1d4e:	f2 e0       	ldi	r31, 0x02	; 2
    1d50:	f0 93 b3 02 	sts	0x02B3, r31	; 0x8002b3 <prep+0x12>
    1d54:	a5 01       	movw	r20, r10
    1d56:	94 01       	movw	r18, r8
    1d58:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1d5c:	9b 01       	movw	r18, r22
    1d5e:	ac 01       	movw	r20, r24
    1d60:	c3 01       	movw	r24, r6
    1d62:	b2 01       	movw	r22, r4
    1d64:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1d68:	6b 01       	movw	r12, r22
    1d6a:	7c 01       	movw	r14, r24
    1d6c:	20 e0       	ldi	r18, 0x00	; 0
    1d6e:	30 e0       	ldi	r19, 0x00	; 0
    1d70:	a9 01       	movw	r20, r18
    1d72:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1d76:	87 ff       	sbrs	r24, 7
    1d78:	de c2       	rjmp	.+1468   	; 0x2336 <st_prep_buffer+0x6d2>
    1d7a:	29 81       	ldd	r18, Y+1	; 0x01
    1d7c:	3a 81       	ldd	r19, Y+2	; 0x02
    1d7e:	4b 81       	ldd	r20, Y+3	; 0x03
    1d80:	5c 81       	ldd	r21, Y+4	; 0x04
    1d82:	ca 01       	movw	r24, r20
    1d84:	b9 01       	movw	r22, r18
    1d86:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    1d8a:	a3 01       	movw	r20, r6
    1d8c:	92 01       	movw	r18, r4
    1d8e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1d92:	9b 01       	movw	r18, r22
    1d94:	ac 01       	movw	r20, r24
    1d96:	c5 01       	movw	r24, r10
    1d98:	b4 01       	movw	r22, r8
    1d9a:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1d9e:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    1da2:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    1da6:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    1daa:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    1dae:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    1db2:	18 60       	ori	r17, 0x08	; 8
    1db4:	10 93 35 06 	sts	0x0635, r17	; 0x800635 <sys+0x4>
    1db8:	80 91 44 02 	lds	r24, 0x0244	; 0x800244 <segment_buffer_head>
    1dbc:	a8 2f       	mov	r26, r24
    1dbe:	b0 e0       	ldi	r27, 0x00	; 0
    1dc0:	ba 8b       	std	Y+18, r27	; 0x12
    1dc2:	a9 8b       	std	Y+17, r26	; 0x11
    1dc4:	27 e0       	ldi	r18, 0x07	; 7
    1dc6:	2a 9f       	mul	r18, r26
    1dc8:	f0 01       	movw	r30, r0
    1dca:	2b 9f       	mul	r18, r27
    1dcc:	f0 0d       	add	r31, r0
    1dce:	11 24       	eor	r1, r1
    1dd0:	e6 5e       	subi	r30, 0xE6	; 230
    1dd2:	fd 4f       	sbci	r31, 0xFD	; 253
    1dd4:	80 91 a1 02 	lds	r24, 0x02A1	; 0x8002a1 <prep>
    1dd8:	84 83       	std	Z+4, r24	; 0x04
    1dda:	40 91 d1 02 	lds	r20, 0x02D1	; 0x8002d1 <pl_block>
    1dde:	50 91 d2 02 	lds	r21, 0x02D2	; 0x8002d2 <pl_block+0x1>
    1de2:	5a 87       	std	Y+10, r21	; 0x0a
    1de4:	49 87       	std	Y+9, r20	; 0x09
    1de6:	da 01       	movw	r26, r20
    1de8:	5e 96       	adiw	r26, 0x1e	; 30
    1dea:	bc 91       	ld	r27, X
    1dec:	bd a3       	std	Y+37, r27	; 0x25
    1dee:	fa 01       	movw	r30, r20
    1df0:	f7 8d       	ldd	r31, Z+31	; 0x1f
    1df2:	fe a3       	std	Y+38, r31	; 0x26
    1df4:	da 01       	movw	r26, r20
    1df6:	90 96       	adiw	r26, 0x20	; 32
    1df8:	bc 91       	ld	r27, X
    1dfa:	bf a3       	std	Y+39, r27	; 0x27
    1dfc:	fa 01       	movw	r30, r20
    1dfe:	f1 a1       	ldd	r31, Z+33	; 0x21
    1e00:	f8 a7       	std	Y+40, r31	; 0x28
    1e02:	20 91 af 02 	lds	r18, 0x02AF	; 0x8002af <prep+0xe>
    1e06:	30 91 b0 02 	lds	r19, 0x02B0	; 0x8002b0 <prep+0xf>
    1e0a:	40 91 b1 02 	lds	r20, 0x02B1	; 0x8002b1 <prep+0x10>
    1e0e:	50 91 b2 02 	lds	r21, 0x02B2	; 0x8002b2 <prep+0x11>
    1e12:	6d a1       	ldd	r22, Y+37	; 0x25
    1e14:	7e a1       	ldd	r23, Y+38	; 0x26
    1e16:	8b 2f       	mov	r24, r27
    1e18:	9f 2f       	mov	r25, r31
    1e1a:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1e1e:	69 ab       	std	Y+49, r22	; 0x31
    1e20:	7a ab       	std	Y+50, r23	; 0x32
    1e22:	8b ab       	std	Y+51, r24	; 0x33
    1e24:	9c ab       	std	Y+52, r25	; 0x34
    1e26:	20 e0       	ldi	r18, 0x00	; 0
    1e28:	30 e0       	ldi	r19, 0x00	; 0
    1e2a:	a9 01       	movw	r20, r18
    1e2c:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1e30:	87 ff       	sbrs	r24, 7
    1e32:	04 c0       	rjmp	.+8      	; 0x1e3c <st_prep_buffer+0x1d8>
    1e34:	19 aa       	std	Y+49, r1	; 0x31
    1e36:	1a aa       	std	Y+50, r1	; 0x32
    1e38:	1b aa       	std	Y+51, r1	; 0x33
    1e3a:	1c aa       	std	Y+52, r1	; 0x34
    1e3c:	20 91 bc 02 	lds	r18, 0x02BC	; 0x8002bc <prep+0x1b>
    1e40:	2d 8b       	std	Y+21, r18	; 0x15
    1e42:	30 91 bd 02 	lds	r19, 0x02BD	; 0x8002bd <prep+0x1c>
    1e46:	3e 8b       	std	Y+22, r19	; 0x16
    1e48:	40 91 be 02 	lds	r20, 0x02BE	; 0x8002be <prep+0x1d>
    1e4c:	4f 8b       	std	Y+23, r20	; 0x17
    1e4e:	50 91 bf 02 	lds	r21, 0x02BF	; 0x8002bf <prep+0x1e>
    1e52:	58 8f       	std	Y+24, r21	; 0x18
    1e54:	80 91 c4 02 	lds	r24, 0x02C4	; 0x8002c4 <prep+0x23>
    1e58:	8d 8f       	std	Y+29, r24	; 0x1d
    1e5a:	90 91 c5 02 	lds	r25, 0x02C5	; 0x8002c5 <prep+0x24>
    1e5e:	9e 8f       	std	Y+30, r25	; 0x1e
    1e60:	a0 91 c6 02 	lds	r26, 0x02C6	; 0x8002c6 <prep+0x25>
    1e64:	af 8f       	std	Y+31, r26	; 0x1f
    1e66:	b0 91 c7 02 	lds	r27, 0x02C7	; 0x8002c7 <prep+0x26>
    1e6a:	b8 a3       	std	Y+32, r27	; 0x20
    1e6c:	e0 91 b3 02 	lds	r30, 0x02B3	; 0x8002b3 <prep+0x12>
    1e70:	ed 87       	std	Y+13, r30	; 0x0d
    1e72:	f0 91 c8 02 	lds	r31, 0x02C8	; 0x8002c8 <prep+0x27>
    1e76:	f9 a7       	std	Y+41, r31	; 0x29
    1e78:	20 91 c9 02 	lds	r18, 0x02C9	; 0x8002c9 <prep+0x28>
    1e7c:	2a a7       	std	Y+42, r18	; 0x2a
    1e7e:	30 91 ca 02 	lds	r19, 0x02CA	; 0x8002ca <prep+0x29>
    1e82:	3b a7       	std	Y+43, r19	; 0x2b
    1e84:	40 91 cb 02 	lds	r20, 0x02CB	; 0x8002cb <prep+0x2a>
    1e88:	4c a7       	std	Y+44, r20	; 0x2c
    1e8a:	70 90 b8 02 	lds	r7, 0x02B8	; 0x8002b8 <prep+0x17>
    1e8e:	60 90 b9 02 	lds	r6, 0x02B9	; 0x8002b9 <prep+0x18>
    1e92:	50 91 ba 02 	lds	r21, 0x02BA	; 0x8002ba <prep+0x19>
    1e96:	5b af       	std	Y+59, r21	; 0x3b
    1e98:	80 91 bb 02 	lds	r24, 0x02BB	; 0x8002bb <prep+0x1a>
    1e9c:	8a af       	std	Y+58, r24	; 0x3a
    1e9e:	90 91 b4 02 	lds	r25, 0x02B4	; 0x8002b4 <prep+0x13>
    1ea2:	9d a7       	std	Y+45, r25	; 0x2d
    1ea4:	a0 91 b5 02 	lds	r26, 0x02B5	; 0x8002b5 <prep+0x14>
    1ea8:	ae a7       	std	Y+46, r26	; 0x2e
    1eaa:	b0 91 b6 02 	lds	r27, 0x02B6	; 0x8002b6 <prep+0x15>
    1eae:	bf a7       	std	Y+47, r27	; 0x2f
    1eb0:	e0 91 b7 02 	lds	r30, 0x02B7	; 0x8002b7 <prep+0x16>
    1eb4:	e8 ab       	std	Y+48, r30	; 0x30
    1eb6:	f0 91 c0 02 	lds	r31, 0x02C0	; 0x8002c0 <prep+0x1f>
    1eba:	fe ab       	std	Y+54, r31	; 0x36
    1ebc:	20 91 c1 02 	lds	r18, 0x02C1	; 0x8002c1 <prep+0x20>
    1ec0:	2f ab       	std	Y+55, r18	; 0x37
    1ec2:	30 91 c2 02 	lds	r19, 0x02C2	; 0x8002c2 <prep+0x21>
    1ec6:	38 af       	std	Y+56, r19	; 0x38
    1ec8:	40 91 c3 02 	lds	r20, 0x02C3	; 0x8002c3 <prep+0x22>
    1ecc:	49 af       	std	Y+57, r20	; 0x39
    1ece:	29 a5       	ldd	r18, Y+41	; 0x29
    1ed0:	3a a5       	ldd	r19, Y+42	; 0x2a
    1ed2:	4b a5       	ldd	r20, Y+43	; 0x2b
    1ed4:	5c a5       	ldd	r21, Y+44	; 0x2c
    1ed6:	6d 8d       	ldd	r22, Y+29	; 0x1d
    1ed8:	7e 8d       	ldd	r23, Y+30	; 0x1e
    1eda:	8f 8d       	ldd	r24, Y+31	; 0x1f
    1edc:	98 a1       	ldd	r25, Y+32	; 0x20
    1ede:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1ee2:	81 11       	cpse	r24, r1
    1ee4:	c8 c3       	rjmp	.+1936   	; 0x2676 <st_prep_buffer+0xa12>
    1ee6:	52 e0       	ldi	r21, 0x02	; 2
    1ee8:	5d ab       	std	Y+53, r21	; 0x35
    1eea:	9d a1       	ldd	r25, Y+37	; 0x25
    1eec:	99 8f       	std	Y+25, r25	; 0x19
    1eee:	ae a1       	ldd	r26, Y+38	; 0x26
    1ef0:	aa 8f       	std	Y+26, r26	; 0x1a
    1ef2:	bf a1       	ldd	r27, Y+39	; 0x27
    1ef4:	bb 8f       	std	Y+27, r27	; 0x1b
    1ef6:	e8 a5       	ldd	r30, Y+40	; 0x28
    1ef8:	ec 8f       	std	Y+28, r30	; 0x1c
    1efa:	8e e3       	ldi	r24, 0x3E	; 62
    1efc:	c8 2e       	mov	r12, r24
    1efe:	83 ec       	ldi	r24, 0xC3	; 195
    1f00:	d8 2e       	mov	r13, r24
    1f02:	8e e2       	ldi	r24, 0x2E	; 46
    1f04:	e8 2e       	mov	r14, r24
    1f06:	89 e3       	ldi	r24, 0x39	; 57
    1f08:	f8 2e       	mov	r15, r24
    1f0a:	21 2c       	mov	r2, r1
    1f0c:	31 2c       	mov	r3, r1
    1f0e:	21 01       	movw	r4, r2
    1f10:	a7 01       	movw	r20, r14
    1f12:	96 01       	movw	r18, r12
    1f14:	29 a3       	std	Y+33, r18	; 0x21
    1f16:	3a a3       	std	Y+34, r19	; 0x22
    1f18:	4b a3       	std	Y+35, r20	; 0x23
    1f1a:	5c a3       	std	Y+36, r21	; 0x24
    1f1c:	5d 85       	ldd	r21, Y+13	; 0x0d
    1f1e:	51 30       	cpi	r21, 0x01	; 1
    1f20:	09 f4       	brne	.+2      	; 0x1f24 <st_prep_buffer+0x2c0>
    1f22:	4a c4       	rjmp	.+2196   	; 0x27b8 <st_prep_buffer+0xb54>
    1f24:	a9 85       	ldd	r26, Y+9	; 0x09
    1f26:	ba 85       	ldd	r27, Y+10	; 0x0a
    1f28:	51 30       	cpi	r21, 0x01	; 1
    1f2a:	08 f4       	brcc	.+2      	; 0x1f2e <st_prep_buffer+0x2ca>
    1f2c:	d6 c3       	rjmp	.+1964   	; 0x26da <st_prep_buffer+0xa76>
    1f2e:	53 30       	cpi	r21, 0x03	; 3
    1f30:	09 f0       	breq	.+2      	; 0x1f34 <st_prep_buffer+0x2d0>
    1f32:	78 c4       	rjmp	.+2288   	; 0x2824 <st_prep_buffer+0xbc0>
    1f34:	5a 96       	adiw	r26, 0x1a	; 26
    1f36:	2d 91       	ld	r18, X+
    1f38:	3d 91       	ld	r19, X+
    1f3a:	4d 91       	ld	r20, X+
    1f3c:	5c 91       	ld	r21, X
    1f3e:	5d 97       	sbiw	r26, 0x1d	; 29
    1f40:	c7 01       	movw	r24, r14
    1f42:	b6 01       	movw	r22, r12
    1f44:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    1f48:	4b 01       	movw	r8, r22
    1f4a:	5c 01       	movw	r10, r24
    1f4c:	2d 89       	ldd	r18, Y+21	; 0x15
    1f4e:	3e 89       	ldd	r19, Y+22	; 0x16
    1f50:	4f 89       	ldd	r20, Y+23	; 0x17
    1f52:	58 8d       	ldd	r21, Y+24	; 0x18
    1f54:	67 2d       	mov	r22, r7
    1f56:	76 2d       	mov	r23, r6
    1f58:	8b ad       	ldd	r24, Y+59	; 0x3b
    1f5a:	9a ad       	ldd	r25, Y+58	; 0x3a
    1f5c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1f60:	9b 01       	movw	r18, r22
    1f62:	ac 01       	movw	r20, r24
    1f64:	c5 01       	movw	r24, r10
    1f66:	b4 01       	movw	r22, r8
    1f68:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    1f6c:	87 fd       	sbrc	r24, 7
    1f6e:	8d c3       	rjmp	.+1818   	; 0x268a <st_prep_buffer+0xa26>
    1f70:	2d 8d       	ldd	r18, Y+29	; 0x1d
    1f72:	3e 8d       	ldd	r19, Y+30	; 0x1e
    1f74:	4f 8d       	ldd	r20, Y+31	; 0x1f
    1f76:	58 a1       	ldd	r21, Y+32	; 0x20
    1f78:	6d a1       	ldd	r22, Y+37	; 0x25
    1f7a:	7e a1       	ldd	r23, Y+38	; 0x26
    1f7c:	8f a1       	ldd	r24, Y+39	; 0x27
    1f7e:	98 a5       	ldd	r25, Y+40	; 0x28
    1f80:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    1f84:	9b 01       	movw	r18, r22
    1f86:	ac 01       	movw	r20, r24
    1f88:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    1f8c:	6b 01       	movw	r12, r22
    1f8e:	7c 01       	movw	r14, r24
    1f90:	2d 89       	ldd	r18, Y+21	; 0x15
    1f92:	3e 89       	ldd	r19, Y+22	; 0x16
    1f94:	4f 89       	ldd	r20, Y+23	; 0x17
    1f96:	58 8d       	ldd	r21, Y+24	; 0x18
    1f98:	67 2d       	mov	r22, r7
    1f9a:	76 2d       	mov	r23, r6
    1f9c:	8b ad       	ldd	r24, Y+59	; 0x3b
    1f9e:	9a ad       	ldd	r25, Y+58	; 0x3a
    1fa0:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    1fa4:	9b 01       	movw	r18, r22
    1fa6:	ac 01       	movw	r20, r24
    1fa8:	c7 01       	movw	r24, r14
    1faa:	b6 01       	movw	r22, r12
    1fac:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    1fb0:	6b 01       	movw	r12, r22
    1fb2:	7c 01       	movw	r14, r24
    1fb4:	7d 88       	ldd	r7, Y+21	; 0x15
    1fb6:	6e 88       	ldd	r6, Y+22	; 0x16
    1fb8:	bf 89       	ldd	r27, Y+23	; 0x17
    1fba:	bb af       	std	Y+59, r27	; 0x3b
    1fbc:	e8 8d       	ldd	r30, Y+24	; 0x18
    1fbe:	ea af       	std	Y+58, r30	; 0x3a
    1fc0:	0d 8d       	ldd	r16, Y+29	; 0x1d
    1fc2:	1e 8d       	ldd	r17, Y+30	; 0x1e
    1fc4:	ff 8d       	ldd	r31, Y+31	; 0x1f
    1fc6:	f9 83       	std	Y+1, r31	; 0x01
    1fc8:	28 a1       	ldd	r18, Y+32	; 0x20
    1fca:	2d 83       	std	Y+5, r18	; 0x05
    1fcc:	31 e0       	ldi	r19, 0x01	; 1
    1fce:	3d 87       	std	Y+13, r19	; 0x0d
    1fd0:	a7 01       	movw	r20, r14
    1fd2:	96 01       	movw	r18, r12
    1fd4:	c2 01       	movw	r24, r4
    1fd6:	b1 01       	movw	r22, r2
    1fd8:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    1fdc:	1b 01       	movw	r2, r22
    1fde:	2c 01       	movw	r4, r24
    1fe0:	29 a1       	ldd	r18, Y+33	; 0x21
    1fe2:	3a a1       	ldd	r19, Y+34	; 0x22
    1fe4:	4b a1       	ldd	r20, Y+35	; 0x23
    1fe6:	5c a1       	ldd	r21, Y+36	; 0x24
    1fe8:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    1fec:	87 ff       	sbrs	r24, 7
    1fee:	87 c4       	rjmp	.+2318   	; 0x28fe <st_prep_buffer+0xc9a>
    1ff0:	a2 01       	movw	r20, r4
    1ff2:	91 01       	movw	r18, r2
    1ff4:	69 a1       	ldd	r22, Y+33	; 0x21
    1ff6:	7a a1       	ldd	r23, Y+34	; 0x22
    1ff8:	8b a1       	ldd	r24, Y+35	; 0x23
    1ffa:	9c a1       	ldd	r25, Y+36	; 0x24
    1ffc:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2000:	6b 01       	movw	r12, r22
    2002:	7c 01       	movw	r14, r24
    2004:	98 01       	movw	r18, r16
    2006:	49 81       	ldd	r20, Y+1	; 0x01
    2008:	5d 81       	ldd	r21, Y+5	; 0x05
    200a:	6d a5       	ldd	r22, Y+45	; 0x2d
    200c:	7e a5       	ldd	r23, Y+46	; 0x2e
    200e:	8f a5       	ldd	r24, Y+47	; 0x2f
    2010:	98 a9       	ldd	r25, Y+48	; 0x30
    2012:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    2016:	87 fd       	sbrc	r24, 7
    2018:	31 c3       	rjmp	.+1634   	; 0x267c <st_prep_buffer+0xa18>
    201a:	3d 85       	ldd	r19, Y+13	; 0x0d
    201c:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    2020:	87 2d       	mov	r24, r7
    2022:	96 2d       	mov	r25, r6
    2024:	ab ad       	ldd	r26, Y+59	; 0x3b
    2026:	ba ad       	ldd	r27, Y+58	; 0x3a
    2028:	80 93 b8 02 	sts	0x02B8, r24	; 0x8002b8 <prep+0x17>
    202c:	90 93 b9 02 	sts	0x02B9, r25	; 0x8002b9 <prep+0x18>
    2030:	a0 93 ba 02 	sts	0x02BA, r26	; 0x8002ba <prep+0x19>
    2034:	b0 93 bb 02 	sts	0x02BB, r27	; 0x8002bb <prep+0x1a>
    2038:	e0 91 45 02 	lds	r30, 0x0245	; 0x800245 <st_prep_block>
    203c:	f0 91 46 02 	lds	r31, 0x0246	; 0x800246 <st_prep_block+0x1>
    2040:	81 89       	ldd	r24, Z+17	; 0x11
    2042:	81 11       	cpse	r24, r1
    2044:	04 c0       	rjmp	.+8      	; 0x204e <st_prep_buffer+0x3ea>
    2046:	90 91 35 06 	lds	r25, 0x0635	; 0x800635 <sys+0x4>
    204a:	93 ff       	sbrs	r25, 3
    204c:	31 c0       	rjmp	.+98     	; 0x20b0 <st_prep_buffer+0x44c>
    204e:	a9 85       	ldd	r26, Y+9	; 0x09
    2050:	ba 85       	ldd	r27, Y+10	; 0x0a
    2052:	51 96       	adiw	r26, 0x11	; 17
    2054:	9c 91       	ld	r25, X
    2056:	51 97       	sbiw	r26, 0x11	; 17
    2058:	90 73       	andi	r25, 0x30	; 48
    205a:	09 f4       	brne	.+2      	; 0x205e <st_prep_buffer+0x3fa>
    205c:	70 c4       	rjmp	.+2272   	; 0x293e <st_prep_buffer+0xcda>
    205e:	9e 96       	adiw	r26, 0x2e	; 46
    2060:	cd 90       	ld	r12, X+
    2062:	dd 90       	ld	r13, X+
    2064:	ed 90       	ld	r14, X+
    2066:	fc 90       	ld	r15, X
    2068:	d1 97       	sbiw	r26, 0x31	; 49
    206a:	88 23       	and	r24, r24
    206c:	b1 f0       	breq	.+44     	; 0x209a <st_prep_buffer+0x436>
    206e:	20 91 cc 02 	lds	r18, 0x02CC	; 0x8002cc <prep+0x2b>
    2072:	30 91 cd 02 	lds	r19, 0x02CD	; 0x8002cd <prep+0x2c>
    2076:	40 91 ce 02 	lds	r20, 0x02CE	; 0x8002ce <prep+0x2d>
    207a:	50 91 cf 02 	lds	r21, 0x02CF	; 0x8002cf <prep+0x2e>
    207e:	67 2d       	mov	r22, r7
    2080:	76 2d       	mov	r23, r6
    2082:	8b ad       	ldd	r24, Y+59	; 0x3b
    2084:	9a ad       	ldd	r25, Y+58	; 0x3a
    2086:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    208a:	9b 01       	movw	r18, r22
    208c:	ac 01       	movw	r20, r24
    208e:	c7 01       	movw	r24, r14
    2090:	b6 01       	movw	r22, r12
    2092:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2096:	6b 01       	movw	r12, r22
    2098:	7c 01       	movw	r14, r24
    209a:	c7 01       	movw	r24, r14
    209c:	b6 01       	movw	r22, r12
    209e:	0e 94 2c 0a 	call	0x1458	; 0x1458 <spindle_compute_pwm_value>
    20a2:	80 93 d0 02 	sts	0x02D0, r24	; 0x8002d0 <prep+0x2f>
    20a6:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    20aa:	87 7f       	andi	r24, 0xF7	; 247
    20ac:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    20b0:	27 e0       	ldi	r18, 0x07	; 7
    20b2:	e9 89       	ldd	r30, Y+17	; 0x11
    20b4:	fa 89       	ldd	r31, Y+18	; 0x12
    20b6:	2e 9f       	mul	r18, r30
    20b8:	c0 01       	movw	r24, r0
    20ba:	2f 9f       	mul	r18, r31
    20bc:	90 0d       	add	r25, r0
    20be:	11 24       	eor	r1, r1
    20c0:	ac 01       	movw	r20, r24
    20c2:	46 5e       	subi	r20, 0xE6	; 230
    20c4:	5d 4f       	sbci	r21, 0xFD	; 253
    20c6:	3a 01       	movw	r6, r20
    20c8:	80 91 d0 02 	lds	r24, 0x02D0	; 0x8002d0 <prep+0x2f>
    20cc:	da 01       	movw	r26, r20
    20ce:	16 96       	adiw	r26, 0x06	; 6
    20d0:	8c 93       	st	X, r24
    20d2:	20 91 ab 02 	lds	r18, 0x02AB	; 0x8002ab <prep+0xa>
    20d6:	30 91 ac 02 	lds	r19, 0x02AC	; 0x8002ac <prep+0xb>
    20da:	40 91 ad 02 	lds	r20, 0x02AD	; 0x8002ad <prep+0xc>
    20de:	50 91 ae 02 	lds	r21, 0x02AE	; 0x8002ae <prep+0xd>
    20e2:	b8 01       	movw	r22, r16
    20e4:	89 81       	ldd	r24, Y+1	; 0x01
    20e6:	9d 81       	ldd	r25, Y+5	; 0x05
    20e8:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    20ec:	69 87       	std	Y+9, r22	; 0x09
    20ee:	7a 87       	std	Y+10, r23	; 0x0a
    20f0:	8b 87       	std	Y+11, r24	; 0x0b
    20f2:	9c 87       	std	Y+12, r25	; 0x0c
    20f4:	0e 94 22 36 	call	0x6c44	; 0x6c44 <ceil>
    20f8:	6b 01       	movw	r12, r22
    20fa:	7c 01       	movw	r14, r24
    20fc:	60 91 a7 02 	lds	r22, 0x02A7	; 0x8002a7 <prep+0x6>
    2100:	70 91 a8 02 	lds	r23, 0x02A8	; 0x8002a8 <prep+0x7>
    2104:	80 91 a9 02 	lds	r24, 0x02A9	; 0x8002a9 <prep+0x8>
    2108:	90 91 aa 02 	lds	r25, 0x02AA	; 0x8002aa <prep+0x9>
    210c:	0e 94 22 36 	call	0x6c44	; 0x6c44 <ceil>
    2110:	4b 01       	movw	r8, r22
    2112:	5c 01       	movw	r10, r24
    2114:	a7 01       	movw	r20, r14
    2116:	96 01       	movw	r18, r12
    2118:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    211c:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    2120:	6d 87       	std	Y+13, r22	; 0x0d
    2122:	7e 87       	std	Y+14, r23	; 0x0e
    2124:	8f 87       	std	Y+15, r24	; 0x0f
    2126:	98 8b       	std	Y+16, r25	; 0x10
    2128:	2d 85       	ldd	r18, Y+13	; 0x0d
    212a:	3e 85       	ldd	r19, Y+14	; 0x0e
    212c:	f3 01       	movw	r30, r6
    212e:	31 83       	std	Z+1, r19	; 0x01
    2130:	20 83       	st	Z, r18
    2132:	23 2b       	or	r18, r19
    2134:	09 f0       	breq	.+2      	; 0x2138 <st_prep_buffer+0x4d4>
    2136:	0e c4       	rjmp	.+2076   	; 0x2954 <st_prep_buffer+0xcf0>
    2138:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    213c:	81 ff       	sbrs	r24, 1
    213e:	0a c4       	rjmp	.+2068   	; 0x2954 <st_prep_buffer+0xcf0>
    2140:	81 60       	ori	r24, 0x01	; 1
    2142:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    2146:	eb 96       	adiw	r28, 0x3b	; 59
    2148:	0f b6       	in	r0, 0x3f	; 63
    214a:	f8 94       	cli
    214c:	de bf       	out	0x3e, r29	; 62
    214e:	0f be       	out	0x3f, r0	; 63
    2150:	cd bf       	out	0x3d, r28	; 61
    2152:	df 91       	pop	r29
    2154:	cf 91       	pop	r28
    2156:	1f 91       	pop	r17
    2158:	0f 91       	pop	r16
    215a:	ff 90       	pop	r15
    215c:	ef 90       	pop	r14
    215e:	df 90       	pop	r13
    2160:	cf 90       	pop	r12
    2162:	bf 90       	pop	r11
    2164:	af 90       	pop	r10
    2166:	9f 90       	pop	r9
    2168:	8f 90       	pop	r8
    216a:	7f 90       	pop	r7
    216c:	6f 90       	pop	r6
    216e:	5f 90       	pop	r5
    2170:	4f 90       	pop	r4
    2172:	3f 90       	pop	r3
    2174:	2f 90       	pop	r2
    2176:	08 95       	ret
    2178:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
    217c:	ab cd       	rjmp	.-1194   	; 0x1cd4 <st_prep_buffer+0x70>
    217e:	80 91 a1 02 	lds	r24, 0x02A1	; 0x8002a1 <prep>
    2182:	8f 5f       	subi	r24, 0xFF	; 255
    2184:	85 30       	cpi	r24, 0x05	; 5
    2186:	09 f4       	brne	.+2      	; 0x218a <st_prep_buffer+0x526>
    2188:	80 e0       	ldi	r24, 0x00	; 0
    218a:	80 93 a1 02 	sts	0x02A1, r24	; 0x8002a1 <prep>
    218e:	28 2f       	mov	r18, r24
    2190:	30 e0       	ldi	r19, 0x00	; 0
    2192:	52 e1       	ldi	r21, 0x12	; 18
    2194:	85 9f       	mul	r24, r21
    2196:	c0 01       	movw	r24, r0
    2198:	11 24       	eor	r1, r1
    219a:	dc 01       	movw	r26, r24
    219c:	a9 5b       	subi	r26, 0xB9	; 185
    219e:	bd 4f       	sbci	r27, 0xFD	; 253
    21a0:	7d 01       	movw	r14, r26
    21a2:	b0 93 46 02 	sts	0x0246, r27	; 0x800246 <st_prep_block+0x1>
    21a6:	a0 93 45 02 	sts	0x0245, r26	; 0x800245 <st_prep_block>
    21aa:	e9 85       	ldd	r30, Y+9	; 0x09
    21ac:	fa 85       	ldd	r31, Y+10	; 0x0a
    21ae:	80 89       	ldd	r24, Z+16	; 0x10
    21b0:	50 96       	adiw	r26, 0x10	; 16
    21b2:	8c 93       	st	X, r24
    21b4:	90 e0       	ldi	r25, 0x00	; 0
    21b6:	80 e0       	ldi	r24, 0x00	; 0
    21b8:	41 91       	ld	r20, Z+
    21ba:	51 91       	ld	r21, Z+
    21bc:	61 91       	ld	r22, Z+
    21be:	71 91       	ld	r23, Z+
    21c0:	d7 01       	movw	r26, r14
    21c2:	a8 0f       	add	r26, r24
    21c4:	b9 1f       	adc	r27, r25
    21c6:	68 94       	set
    21c8:	12 f8       	bld	r1, 2
    21ca:	44 0f       	add	r20, r20
    21cc:	55 1f       	adc	r21, r21
    21ce:	66 1f       	adc	r22, r22
    21d0:	77 1f       	adc	r23, r23
    21d2:	16 94       	lsr	r1
    21d4:	d1 f7       	brne	.-12     	; 0x21ca <st_prep_buffer+0x566>
    21d6:	4d 93       	st	X+, r20
    21d8:	5d 93       	st	X+, r21
    21da:	6d 93       	st	X+, r22
    21dc:	7c 93       	st	X, r23
    21de:	13 97       	sbiw	r26, 0x03	; 3
    21e0:	04 96       	adiw	r24, 0x04	; 4
    21e2:	8c 30       	cpi	r24, 0x0C	; 12
    21e4:	91 05       	cpc	r25, r1
    21e6:	41 f7       	brne	.-48     	; 0x21b8 <st_prep_buffer+0x554>
    21e8:	a9 85       	ldd	r26, Y+9	; 0x09
    21ea:	ba 85       	ldd	r27, Y+10	; 0x0a
    21ec:	1c 96       	adiw	r26, 0x0c	; 12
    21ee:	6d 91       	ld	r22, X+
    21f0:	7d 91       	ld	r23, X+
    21f2:	8d 91       	ld	r24, X+
    21f4:	9c 91       	ld	r25, X
    21f6:	1f 97       	sbiw	r26, 0x0f	; 15
    21f8:	b2 e1       	ldi	r27, 0x12	; 18
    21fa:	b2 9f       	mul	r27, r18
    21fc:	a0 01       	movw	r20, r0
    21fe:	b3 9f       	mul	r27, r19
    2200:	50 0d       	add	r21, r0
    2202:	11 24       	eor	r1, r1
    2204:	fa 01       	movw	r30, r20
    2206:	e9 5b       	subi	r30, 0xB9	; 185
    2208:	fd 4f       	sbci	r31, 0xFD	; 253
    220a:	4b 01       	movw	r8, r22
    220c:	5c 01       	movw	r10, r24
    220e:	23 e0       	ldi	r18, 0x03	; 3
    2210:	88 0c       	add	r8, r8
    2212:	99 1c       	adc	r9, r9
    2214:	aa 1c       	adc	r10, r10
    2216:	bb 1c       	adc	r11, r11
    2218:	2a 95       	dec	r18
    221a:	d1 f7       	brne	.-12     	; 0x2210 <st_prep_buffer+0x5ac>
    221c:	84 86       	std	Z+12, r8	; 0x0c
    221e:	95 86       	std	Z+13, r9	; 0x0d
    2220:	a6 86       	std	Z+14, r10	; 0x0e
    2222:	b7 86       	std	Z+15, r11	; 0x0f
    2224:	0e 94 eb 36 	call	0x6dd6	; 0x6dd6 <__floatunsisf>
    2228:	60 93 a7 02 	sts	0x02A7, r22	; 0x8002a7 <prep+0x6>
    222c:	70 93 a8 02 	sts	0x02A8, r23	; 0x8002a8 <prep+0x7>
    2230:	80 93 a9 02 	sts	0x02A9, r24	; 0x8002a9 <prep+0x8>
    2234:	90 93 aa 02 	sts	0x02AA, r25	; 0x8002aa <prep+0x9>
    2238:	e9 85       	ldd	r30, Y+9	; 0x09
    223a:	fa 85       	ldd	r31, Y+10	; 0x0a
    223c:	26 8d       	ldd	r18, Z+30	; 0x1e
    223e:	37 8d       	ldd	r19, Z+31	; 0x1f
    2240:	40 a1       	ldd	r20, Z+32	; 0x20
    2242:	51 a1       	ldd	r21, Z+33	; 0x21
    2244:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    2248:	9b 01       	movw	r18, r22
    224a:	ac 01       	movw	r20, r24
    224c:	20 93 ab 02 	sts	0x02AB, r18	; 0x8002ab <prep+0xa>
    2250:	30 93 ac 02 	sts	0x02AC, r19	; 0x8002ac <prep+0xb>
    2254:	40 93 ad 02 	sts	0x02AD, r20	; 0x8002ad <prep+0xc>
    2258:	50 93 ae 02 	sts	0x02AE, r21	; 0x8002ae <prep+0xd>
    225c:	60 e0       	ldi	r22, 0x00	; 0
    225e:	70 e0       	ldi	r23, 0x00	; 0
    2260:	80 ea       	ldi	r24, 0xA0	; 160
    2262:	9f e3       	ldi	r25, 0x3F	; 63
    2264:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    2268:	60 93 af 02 	sts	0x02AF, r22	; 0x8002af <prep+0xe>
    226c:	70 93 b0 02 	sts	0x02B0, r23	; 0x8002b0 <prep+0xf>
    2270:	80 93 b1 02 	sts	0x02B1, r24	; 0x8002b1 <prep+0x10>
    2274:	90 93 b2 02 	sts	0x02B2, r25	; 0x8002b2 <prep+0x11>
    2278:	10 92 a3 02 	sts	0x02A3, r1	; 0x8002a3 <prep+0x2>
    227c:	10 92 a4 02 	sts	0x02A4, r1	; 0x8002a4 <prep+0x3>
    2280:	10 92 a5 02 	sts	0x02A5, r1	; 0x8002a5 <prep+0x4>
    2284:	10 92 a6 02 	sts	0x02A6, r1	; 0x8002a6 <prep+0x5>
    2288:	11 fd       	sbrc	r17, 1
    228a:	02 c0       	rjmp	.+4      	; 0x2290 <st_prep_buffer+0x62c>
    228c:	03 ff       	sbrs	r16, 3
    228e:	42 c0       	rjmp	.+132    	; 0x2314 <st_prep_buffer+0x6b0>
    2290:	60 91 c0 02 	lds	r22, 0x02C0	; 0x8002c0 <prep+0x1f>
    2294:	70 91 c1 02 	lds	r23, 0x02C1	; 0x8002c1 <prep+0x20>
    2298:	80 91 c2 02 	lds	r24, 0x02C2	; 0x8002c2 <prep+0x21>
    229c:	90 91 c3 02 	lds	r25, 0x02C3	; 0x8002c3 <prep+0x22>
    22a0:	60 93 b8 02 	sts	0x02B8, r22	; 0x8002b8 <prep+0x17>
    22a4:	70 93 b9 02 	sts	0x02B9, r23	; 0x8002b9 <prep+0x18>
    22a8:	80 93 ba 02 	sts	0x02BA, r24	; 0x8002ba <prep+0x19>
    22ac:	90 93 bb 02 	sts	0x02BB, r25	; 0x8002bb <prep+0x1a>
    22b0:	9b 01       	movw	r18, r22
    22b2:	ac 01       	movw	r20, r24
    22b4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    22b8:	a9 85       	ldd	r26, Y+9	; 0x09
    22ba:	ba 85       	ldd	r27, Y+10	; 0x0a
    22bc:	52 96       	adiw	r26, 0x12	; 18
    22be:	6d 93       	st	X+, r22
    22c0:	7d 93       	st	X+, r23
    22c2:	8d 93       	st	X+, r24
    22c4:	9c 93       	st	X, r25
    22c6:	55 97       	sbiw	r26, 0x15	; 21
    22c8:	07 7f       	andi	r16, 0xF7	; 247
    22ca:	00 93 a2 02 	sts	0x02A2, r16	; 0x8002a2 <prep+0x1>
    22ce:	d7 01       	movw	r26, r14
    22d0:	51 96       	adiw	r26, 0x11	; 17
    22d2:	1c 92       	st	X, r1
    22d4:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    22d8:	81 ff       	sbrs	r24, 1
    22da:	0f cd       	rjmp	.-1506   	; 0x1cfa <st_prep_buffer+0x96>
    22dc:	e9 85       	ldd	r30, Y+9	; 0x09
    22de:	fa 85       	ldd	r31, Y+10	; 0x0a
    22e0:	81 89       	ldd	r24, Z+17	; 0x11
    22e2:	85 ff       	sbrs	r24, 5
    22e4:	0a cd       	rjmp	.-1516   	; 0x1cfa <st_prep_buffer+0x96>
    22e6:	22 a5       	ldd	r18, Z+42	; 0x2a
    22e8:	33 a5       	ldd	r19, Z+43	; 0x2b
    22ea:	44 a5       	ldd	r20, Z+44	; 0x2c
    22ec:	55 a5       	ldd	r21, Z+45	; 0x2d
    22ee:	60 e0       	ldi	r22, 0x00	; 0
    22f0:	70 e0       	ldi	r23, 0x00	; 0
    22f2:	80 e8       	ldi	r24, 0x80	; 128
    22f4:	9f e3       	ldi	r25, 0x3F	; 63
    22f6:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    22fa:	60 93 cc 02 	sts	0x02CC, r22	; 0x8002cc <prep+0x2b>
    22fe:	70 93 cd 02 	sts	0x02CD, r23	; 0x8002cd <prep+0x2c>
    2302:	80 93 ce 02 	sts	0x02CE, r24	; 0x8002ce <prep+0x2d>
    2306:	90 93 cf 02 	sts	0x02CF, r25	; 0x8002cf <prep+0x2e>
    230a:	e1 e0       	ldi	r30, 0x01	; 1
    230c:	d7 01       	movw	r26, r14
    230e:	51 96       	adiw	r26, 0x11	; 17
    2310:	ec 93       	st	X, r30
    2312:	f3 cc       	rjmp	.-1562   	; 0x1cfa <st_prep_buffer+0x96>
    2314:	e9 85       	ldd	r30, Y+9	; 0x09
    2316:	fa 85       	ldd	r31, Y+10	; 0x0a
    2318:	62 89       	ldd	r22, Z+18	; 0x12
    231a:	73 89       	ldd	r23, Z+19	; 0x13
    231c:	84 89       	ldd	r24, Z+20	; 0x14
    231e:	95 89       	ldd	r25, Z+21	; 0x15
    2320:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    2324:	60 93 b8 02 	sts	0x02B8, r22	; 0x8002b8 <prep+0x17>
    2328:	70 93 b9 02 	sts	0x02B9, r23	; 0x8002b9 <prep+0x18>
    232c:	80 93 ba 02 	sts	0x02BA, r24	; 0x8002ba <prep+0x19>
    2330:	90 93 bb 02 	sts	0x02BB, r25	; 0x8002bb <prep+0x1a>
    2334:	cc cf       	rjmp	.-104    	; 0x22ce <st_prep_buffer+0x66a>
    2336:	c0 92 b4 02 	sts	0x02B4, r12	; 0x8002b4 <prep+0x13>
    233a:	d0 92 b5 02 	sts	0x02B5, r13	; 0x8002b5 <prep+0x14>
    233e:	e0 92 b6 02 	sts	0x02B6, r14	; 0x8002b6 <prep+0x15>
    2342:	f0 92 b7 02 	sts	0x02B7, r15	; 0x8002b7 <prep+0x16>
    2346:	10 92 c0 02 	sts	0x02C0, r1	; 0x8002c0 <prep+0x1f>
    234a:	10 92 c1 02 	sts	0x02C1, r1	; 0x8002c1 <prep+0x20>
    234e:	10 92 c2 02 	sts	0x02C2, r1	; 0x8002c2 <prep+0x21>
    2352:	10 92 c3 02 	sts	0x02C3, r1	; 0x8002c3 <prep+0x22>
    2356:	2d cd       	rjmp	.-1446   	; 0x1db2 <st_prep_buffer+0x14e>
    2358:	10 92 b3 02 	sts	0x02B3, r1	; 0x8002b3 <prep+0x12>
    235c:	40 92 c4 02 	sts	0x02C4, r4	; 0x8002c4 <prep+0x23>
    2360:	50 92 c5 02 	sts	0x02C5, r5	; 0x8002c5 <prep+0x24>
    2364:	60 92 c6 02 	sts	0x02C6, r6	; 0x8002c6 <prep+0x25>
    2368:	70 92 c7 02 	sts	0x02C7, r7	; 0x8002c7 <prep+0x26>
    236c:	12 ff       	sbrs	r17, 2
    236e:	6a c0       	rjmp	.+212    	; 0x2444 <st_prep_buffer+0x7e0>
    2370:	10 92 c0 02 	sts	0x02C0, r1	; 0x8002c0 <prep+0x1f>
    2374:	10 92 c1 02 	sts	0x02C1, r1	; 0x8002c1 <prep+0x20>
    2378:	10 92 c2 02 	sts	0x02C2, r1	; 0x8002c2 <prep+0x21>
    237c:	10 92 c3 02 	sts	0x02C3, r1	; 0x8002c3 <prep+0x22>
    2380:	c1 2c       	mov	r12, r1
    2382:	d1 2c       	mov	r13, r1
    2384:	76 01       	movw	r14, r12
    2386:	89 85       	ldd	r24, Y+9	; 0x09
    2388:	9a 85       	ldd	r25, Y+10	; 0x0a
    238a:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    238e:	69 8b       	std	Y+17, r22	; 0x11
    2390:	7a 8b       	std	Y+18, r23	; 0x12
    2392:	8b 8b       	std	Y+19, r24	; 0x13
    2394:	9c 8b       	std	Y+20, r25	; 0x14
    2396:	9b 01       	movw	r18, r22
    2398:	ac 01       	movw	r20, r24
    239a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    239e:	69 87       	std	Y+9, r22	; 0x09
    23a0:	7a 87       	std	Y+10, r23	; 0x0a
    23a2:	8b 87       	std	Y+11, r24	; 0x0b
    23a4:	9c 87       	std	Y+12, r25	; 0x0c
    23a6:	a5 01       	movw	r20, r10
    23a8:	94 01       	movw	r18, r8
    23aa:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    23ae:	87 ff       	sbrs	r24, 7
    23b0:	93 c0       	rjmp	.+294    	; 0x24d8 <st_prep_buffer+0x874>
    23b2:	29 85       	ldd	r18, Y+9	; 0x09
    23b4:	3a 85       	ldd	r19, Y+10	; 0x0a
    23b6:	4b 85       	ldd	r20, Y+11	; 0x0b
    23b8:	5c 85       	ldd	r21, Y+12	; 0x0c
    23ba:	c5 01       	movw	r24, r10
    23bc:	b4 01       	movw	r22, r8
    23be:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    23c2:	2d 81       	ldd	r18, Y+5	; 0x05
    23c4:	3e 81       	ldd	r19, Y+6	; 0x06
    23c6:	4f 81       	ldd	r20, Y+7	; 0x07
    23c8:	58 85       	ldd	r21, Y+8	; 0x08
    23ca:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    23ce:	9b 01       	movw	r18, r22
    23d0:	ac 01       	movw	r20, r24
    23d2:	c3 01       	movw	r24, r6
    23d4:	b2 01       	movw	r22, r4
    23d6:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    23da:	60 93 c4 02 	sts	0x02C4, r22	; 0x8002c4 <prep+0x23>
    23de:	70 93 c5 02 	sts	0x02C5, r23	; 0x8002c5 <prep+0x24>
    23e2:	80 93 c6 02 	sts	0x02C6, r24	; 0x8002c6 <prep+0x25>
    23e6:	90 93 c7 02 	sts	0x02C7, r25	; 0x8002c7 <prep+0x26>
    23ea:	20 e0       	ldi	r18, 0x00	; 0
    23ec:	30 e0       	ldi	r19, 0x00	; 0
    23ee:	a9 01       	movw	r20, r18
    23f0:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    23f4:	18 16       	cp	r1, r24
    23f6:	0c f4       	brge	.+2      	; 0x23fa <st_prep_buffer+0x796>
    23f8:	49 c0       	rjmp	.+146    	; 0x248c <st_prep_buffer+0x828>
    23fa:	32 e0       	ldi	r19, 0x02	; 2
    23fc:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    2400:	29 81       	ldd	r18, Y+1	; 0x01
    2402:	3a 81       	ldd	r19, Y+2	; 0x02
    2404:	4b 81       	ldd	r20, Y+3	; 0x03
    2406:	5c 81       	ldd	r21, Y+4	; 0x04
    2408:	ca 01       	movw	r24, r20
    240a:	b9 01       	movw	r22, r18
    240c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2410:	a3 01       	movw	r20, r6
    2412:	92 01       	movw	r18, r4
    2414:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2418:	9b 01       	movw	r18, r22
    241a:	ac 01       	movw	r20, r24
    241c:	c5 01       	movw	r24, r10
    241e:	b4 01       	movw	r22, r8
    2420:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2424:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    2428:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    242c:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    2430:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    2434:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    2438:	80 91 a2 02 	lds	r24, 0x02A2	; 0x8002a2 <prep+0x1>
    243c:	88 60       	ori	r24, 0x08	; 8
    243e:	80 93 a2 02 	sts	0x02A2, r24	; 0x8002a2 <prep+0x1>
    2442:	b7 cc       	rjmp	.-1682   	; 0x1db2 <st_prep_buffer+0x14e>
    2444:	e0 91 d5 02 	lds	r30, 0x02D5	; 0x8002d5 <block_buffer_tail>
    2448:	ef 5f       	subi	r30, 0xFF	; 255
    244a:	e0 31       	cpi	r30, 0x10	; 16
    244c:	09 f4       	brne	.+2      	; 0x2450 <st_prep_buffer+0x7ec>
    244e:	e0 e0       	ldi	r30, 0x00	; 0
    2450:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    2454:	c1 2c       	mov	r12, r1
    2456:	d1 2c       	mov	r13, r1
    2458:	76 01       	movw	r14, r12
    245a:	8e 17       	cp	r24, r30
    245c:	51 f0       	breq	.+20     	; 0x2472 <st_prep_buffer+0x80e>
    245e:	22 e3       	ldi	r18, 0x32	; 50
    2460:	2e 9f       	mul	r18, r30
    2462:	f0 01       	movw	r30, r0
    2464:	11 24       	eor	r1, r1
    2466:	ea 52       	subi	r30, 0x2A	; 42
    2468:	fd 4f       	sbci	r31, 0xFD	; 253
    246a:	c2 88       	ldd	r12, Z+18	; 0x12
    246c:	d3 88       	ldd	r13, Z+19	; 0x13
    246e:	e4 88       	ldd	r14, Z+20	; 0x14
    2470:	f5 88       	ldd	r15, Z+21	; 0x15
    2472:	c7 01       	movw	r24, r14
    2474:	b6 01       	movw	r22, r12
    2476:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    247a:	60 93 c0 02 	sts	0x02C0, r22	; 0x8002c0 <prep+0x1f>
    247e:	70 93 c1 02 	sts	0x02C1, r23	; 0x8002c1 <prep+0x20>
    2482:	80 93 c2 02 	sts	0x02C2, r24	; 0x8002c2 <prep+0x21>
    2486:	90 93 c3 02 	sts	0x02C3, r25	; 0x8002c3 <prep+0x22>
    248a:	7d cf       	rjmp	.-262    	; 0x2386 <st_prep_buffer+0x722>
    248c:	a7 01       	movw	r20, r14
    248e:	96 01       	movw	r18, r12
    2490:	69 85       	ldd	r22, Y+9	; 0x09
    2492:	7a 85       	ldd	r23, Y+10	; 0x0a
    2494:	8b 85       	ldd	r24, Y+11	; 0x0b
    2496:	9c 85       	ldd	r25, Y+12	; 0x0c
    2498:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    249c:	2d 81       	ldd	r18, Y+5	; 0x05
    249e:	3e 81       	ldd	r19, Y+6	; 0x06
    24a0:	4f 81       	ldd	r20, Y+7	; 0x07
    24a2:	58 85       	ldd	r21, Y+8	; 0x08
    24a4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    24a8:	60 93 c8 02 	sts	0x02C8, r22	; 0x8002c8 <prep+0x27>
    24ac:	70 93 c9 02 	sts	0x02C9, r23	; 0x8002c9 <prep+0x28>
    24b0:	80 93 ca 02 	sts	0x02CA, r24	; 0x8002ca <prep+0x29>
    24b4:	90 93 cb 02 	sts	0x02CB, r25	; 0x8002cb <prep+0x2a>
    24b8:	89 89       	ldd	r24, Y+17	; 0x11
    24ba:	9a 89       	ldd	r25, Y+18	; 0x12
    24bc:	ab 89       	ldd	r26, Y+19	; 0x13
    24be:	bc 89       	ldd	r27, Y+20	; 0x14
    24c0:	80 93 bc 02 	sts	0x02BC, r24	; 0x8002bc <prep+0x1b>
    24c4:	90 93 bd 02 	sts	0x02BD, r25	; 0x8002bd <prep+0x1c>
    24c8:	a0 93 be 02 	sts	0x02BE, r26	; 0x8002be <prep+0x1d>
    24cc:	b0 93 bf 02 	sts	0x02BF, r27	; 0x8002bf <prep+0x1e>
    24d0:	93 e0       	ldi	r25, 0x03	; 3
    24d2:	90 93 b3 02 	sts	0x02B3, r25	; 0x8002b3 <prep+0x12>
    24d6:	6d cc       	rjmp	.-1830   	; 0x1db2 <st_prep_buffer+0x14e>
    24d8:	a7 01       	movw	r20, r14
    24da:	96 01       	movw	r18, r12
    24dc:	c5 01       	movw	r24, r10
    24de:	b4 01       	movw	r22, r8
    24e0:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    24e4:	2d 81       	ldd	r18, Y+5	; 0x05
    24e6:	3e 81       	ldd	r19, Y+6	; 0x06
    24e8:	4f 81       	ldd	r20, Y+7	; 0x07
    24ea:	58 85       	ldd	r21, Y+8	; 0x08
    24ec:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    24f0:	a3 01       	movw	r20, r6
    24f2:	92 01       	movw	r18, r4
    24f4:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    24f8:	20 e0       	ldi	r18, 0x00	; 0
    24fa:	30 e0       	ldi	r19, 0x00	; 0
    24fc:	40 e0       	ldi	r20, 0x00	; 0
    24fe:	5f e3       	ldi	r21, 0x3F	; 63
    2500:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2504:	6d 87       	std	Y+13, r22	; 0x0d
    2506:	7e 87       	std	Y+14, r23	; 0x0e
    2508:	8f 87       	std	Y+15, r24	; 0x0f
    250a:	98 8b       	std	Y+16, r25	; 0x10
    250c:	20 e0       	ldi	r18, 0x00	; 0
    250e:	30 e0       	ldi	r19, 0x00	; 0
    2510:	a9 01       	movw	r20, r18
    2512:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    2516:	18 16       	cp	r1, r24
    2518:	0c f0       	brlt	.+2      	; 0x251c <st_prep_buffer+0x8b8>
    251a:	94 c0       	rjmp	.+296    	; 0x2644 <st_prep_buffer+0x9e0>
    251c:	a3 01       	movw	r20, r6
    251e:	92 01       	movw	r18, r4
    2520:	6d 85       	ldd	r22, Y+13	; 0x0d
    2522:	7e 85       	ldd	r23, Y+14	; 0x0e
    2524:	8f 85       	ldd	r24, Y+15	; 0x0f
    2526:	98 89       	ldd	r25, Y+16	; 0x10
    2528:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    252c:	87 ff       	sbrs	r24, 7
    252e:	88 c0       	rjmp	.+272    	; 0x2640 <st_prep_buffer+0x9dc>
    2530:	a7 01       	movw	r20, r14
    2532:	96 01       	movw	r18, r12
    2534:	69 85       	ldd	r22, Y+9	; 0x09
    2536:	7a 85       	ldd	r23, Y+10	; 0x0a
    2538:	8b 85       	ldd	r24, Y+11	; 0x0b
    253a:	9c 85       	ldd	r25, Y+12	; 0x0c
    253c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2540:	2d 81       	ldd	r18, Y+5	; 0x05
    2542:	3e 81       	ldd	r19, Y+6	; 0x06
    2544:	4f 81       	ldd	r20, Y+7	; 0x07
    2546:	58 85       	ldd	r21, Y+8	; 0x08
    2548:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    254c:	9b 01       	movw	r18, r22
    254e:	ac 01       	movw	r20, r24
    2550:	20 93 c8 02 	sts	0x02C8, r18	; 0x8002c8 <prep+0x27>
    2554:	30 93 c9 02 	sts	0x02C9, r19	; 0x8002c9 <prep+0x28>
    2558:	40 93 ca 02 	sts	0x02CA, r20	; 0x8002ca <prep+0x29>
    255c:	50 93 cb 02 	sts	0x02CB, r21	; 0x8002cb <prep+0x2a>
    2560:	6d 85       	ldd	r22, Y+13	; 0x0d
    2562:	7e 85       	ldd	r23, Y+14	; 0x0e
    2564:	8f 85       	ldd	r24, Y+15	; 0x0f
    2566:	98 89       	ldd	r25, Y+16	; 0x10
    2568:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    256c:	18 16       	cp	r1, r24
    256e:	bc f5       	brge	.+110    	; 0x25de <st_prep_buffer+0x97a>
    2570:	29 89       	ldd	r18, Y+17	; 0x11
    2572:	3a 89       	ldd	r19, Y+18	; 0x12
    2574:	4b 89       	ldd	r20, Y+19	; 0x13
    2576:	5c 89       	ldd	r21, Y+20	; 0x14
    2578:	20 93 bc 02 	sts	0x02BC, r18	; 0x8002bc <prep+0x1b>
    257c:	30 93 bd 02 	sts	0x02BD, r19	; 0x8002bd <prep+0x1c>
    2580:	40 93 be 02 	sts	0x02BE, r20	; 0x8002be <prep+0x1d>
    2584:	50 93 bf 02 	sts	0x02BF, r21	; 0x8002bf <prep+0x1e>
    2588:	a5 01       	movw	r20, r10
    258a:	94 01       	movw	r18, r8
    258c:	69 85       	ldd	r22, Y+9	; 0x09
    258e:	7a 85       	ldd	r23, Y+10	; 0x0a
    2590:	8b 85       	ldd	r24, Y+11	; 0x0b
    2592:	9c 85       	ldd	r25, Y+12	; 0x0c
    2594:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    2598:	81 11       	cpse	r24, r1
    259a:	04 c0       	rjmp	.+8      	; 0x25a4 <st_prep_buffer+0x940>
    259c:	31 e0       	ldi	r19, 0x01	; 1
    259e:	30 93 b3 02 	sts	0x02B3, r19	; 0x8002b3 <prep+0x12>
    25a2:	07 cc       	rjmp	.-2034   	; 0x1db2 <st_prep_buffer+0x14e>
    25a4:	a5 01       	movw	r20, r10
    25a6:	94 01       	movw	r18, r8
    25a8:	69 85       	ldd	r22, Y+9	; 0x09
    25aa:	7a 85       	ldd	r23, Y+10	; 0x0a
    25ac:	8b 85       	ldd	r24, Y+11	; 0x0b
    25ae:	9c 85       	ldd	r25, Y+12	; 0x0c
    25b0:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    25b4:	2d 81       	ldd	r18, Y+5	; 0x05
    25b6:	3e 81       	ldd	r19, Y+6	; 0x06
    25b8:	4f 81       	ldd	r20, Y+7	; 0x07
    25ba:	58 85       	ldd	r21, Y+8	; 0x08
    25bc:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    25c0:	9b 01       	movw	r18, r22
    25c2:	ac 01       	movw	r20, r24
    25c4:	c3 01       	movw	r24, r6
    25c6:	b2 01       	movw	r22, r4
    25c8:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    25cc:	60 93 c4 02 	sts	0x02C4, r22	; 0x8002c4 <prep+0x23>
    25d0:	70 93 c5 02 	sts	0x02C5, r23	; 0x8002c5 <prep+0x24>
    25d4:	80 93 c6 02 	sts	0x02C6, r24	; 0x8002c6 <prep+0x25>
    25d8:	90 93 c7 02 	sts	0x02C7, r25	; 0x8002c7 <prep+0x26>
    25dc:	ea cb       	rjmp	.-2092   	; 0x1db2 <st_prep_buffer+0x14e>
    25de:	8d 85       	ldd	r24, Y+13	; 0x0d
    25e0:	9e 85       	ldd	r25, Y+14	; 0x0e
    25e2:	af 85       	ldd	r26, Y+15	; 0x0f
    25e4:	b8 89       	ldd	r27, Y+16	; 0x10
    25e6:	80 93 c4 02 	sts	0x02C4, r24	; 0x8002c4 <prep+0x23>
    25ea:	90 93 c5 02 	sts	0x02C5, r25	; 0x8002c5 <prep+0x24>
    25ee:	a0 93 c6 02 	sts	0x02C6, r26	; 0x8002c6 <prep+0x25>
    25f2:	b0 93 c7 02 	sts	0x02C7, r27	; 0x8002c7 <prep+0x26>
    25f6:	80 93 c8 02 	sts	0x02C8, r24	; 0x8002c8 <prep+0x27>
    25fa:	90 93 c9 02 	sts	0x02C9, r25	; 0x8002c9 <prep+0x28>
    25fe:	a0 93 ca 02 	sts	0x02CA, r26	; 0x8002ca <prep+0x29>
    2602:	b0 93 cb 02 	sts	0x02CB, r27	; 0x8002cb <prep+0x2a>
    2606:	29 81       	ldd	r18, Y+1	; 0x01
    2608:	3a 81       	ldd	r19, Y+2	; 0x02
    260a:	4b 81       	ldd	r20, Y+3	; 0x03
    260c:	5c 81       	ldd	r21, Y+4	; 0x04
    260e:	ca 01       	movw	r24, r20
    2610:	b9 01       	movw	r22, r18
    2612:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2616:	2d 85       	ldd	r18, Y+13	; 0x0d
    2618:	3e 85       	ldd	r19, Y+14	; 0x0e
    261a:	4f 85       	ldd	r20, Y+15	; 0x0f
    261c:	58 89       	ldd	r21, Y+16	; 0x10
    261e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2622:	a7 01       	movw	r20, r14
    2624:	96 01       	movw	r18, r12
    2626:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    262a:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    262e:	60 93 bc 02 	sts	0x02BC, r22	; 0x8002bc <prep+0x1b>
    2632:	70 93 bd 02 	sts	0x02BD, r23	; 0x8002bd <prep+0x1c>
    2636:	80 93 be 02 	sts	0x02BE, r24	; 0x8002be <prep+0x1d>
    263a:	90 93 bf 02 	sts	0x02BF, r25	; 0x8002bf <prep+0x1e>
    263e:	b9 cb       	rjmp	.-2190   	; 0x1db2 <st_prep_buffer+0x14e>
    2640:	92 e0       	ldi	r25, 0x02	; 2
    2642:	47 cf       	rjmp	.-370    	; 0x24d2 <st_prep_buffer+0x86e>
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
    2674:	9e cb       	rjmp	.-2244   	; 0x1db2 <st_prep_buffer+0x14e>
    2676:	81 e0       	ldi	r24, 0x01	; 1
    2678:	8d ab       	std	Y+53, r24	; 0x35
    267a:	37 cc       	rjmp	.-1938   	; 0x1eea <st_prep_buffer+0x286>
    267c:	09 8f       	std	Y+25, r16	; 0x19
    267e:	1a 8f       	std	Y+26, r17	; 0x1a
    2680:	39 81       	ldd	r19, Y+1	; 0x01
    2682:	3b 8f       	std	Y+27, r19	; 0x1b
    2684:	4d 81       	ldd	r20, Y+5	; 0x05
    2686:	4c 8f       	std	Y+28, r20	; 0x1c
    2688:	49 cc       	rjmp	.-1902   	; 0x1f1c <st_prep_buffer+0x2b8>
    268a:	20 e0       	ldi	r18, 0x00	; 0
    268c:	30 e0       	ldi	r19, 0x00	; 0
    268e:	40 e0       	ldi	r20, 0x00	; 0
    2690:	5f e3       	ldi	r21, 0x3F	; 63
    2692:	c5 01       	movw	r24, r10
    2694:	b4 01       	movw	r22, r8
    2696:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    269a:	9b 01       	movw	r18, r22
    269c:	ac 01       	movw	r20, r24
    269e:	67 2d       	mov	r22, r7
    26a0:	76 2d       	mov	r23, r6
    26a2:	8b ad       	ldd	r24, Y+59	; 0x3b
    26a4:	9a ad       	ldd	r25, Y+58	; 0x3a
    26a6:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    26aa:	a7 01       	movw	r20, r14
    26ac:	96 01       	movw	r18, r12
    26ae:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    26b2:	9b 01       	movw	r18, r22
    26b4:	ac 01       	movw	r20, r24
    26b6:	69 8d       	ldd	r22, Y+25	; 0x19
    26b8:	7a 8d       	ldd	r23, Y+26	; 0x1a
    26ba:	8b 8d       	ldd	r24, Y+27	; 0x1b
    26bc:	9c 8d       	ldd	r25, Y+28	; 0x1c
    26be:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    26c2:	8b 01       	movw	r16, r22
    26c4:	89 83       	std	Y+1, r24	; 0x01
    26c6:	9d 83       	std	Y+5, r25	; 0x05
    26c8:	a5 01       	movw	r20, r10
    26ca:	94 01       	movw	r18, r8
    26cc:	67 2d       	mov	r22, r7
    26ce:	76 2d       	mov	r23, r6
    26d0:	8b ad       	ldd	r24, Y+59	; 0x3b
    26d2:	9a ad       	ldd	r25, Y+58	; 0x3a
    26d4:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    26d8:	6a c0       	rjmp	.+212    	; 0x27ae <st_prep_buffer+0xb4a>
    26da:	5a 96       	adiw	r26, 0x1a	; 26
    26dc:	2d 91       	ld	r18, X+
    26de:	3d 91       	ld	r19, X+
    26e0:	4d 91       	ld	r20, X+
    26e2:	5c 91       	ld	r21, X
    26e4:	5d 97       	sbiw	r26, 0x1d	; 29
    26e6:	c7 01       	movw	r24, r14
    26e8:	b6 01       	movw	r22, r12
    26ea:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    26ee:	4b 01       	movw	r8, r22
    26f0:	5c 01       	movw	r10, r24
    26f2:	20 e0       	ldi	r18, 0x00	; 0
    26f4:	30 e0       	ldi	r19, 0x00	; 0
    26f6:	40 e0       	ldi	r20, 0x00	; 0
    26f8:	5f e3       	ldi	r21, 0x3F	; 63
    26fa:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    26fe:	27 2d       	mov	r18, r7
    2700:	36 2d       	mov	r19, r6
    2702:	4b ad       	ldd	r20, Y+59	; 0x3b
    2704:	5a ad       	ldd	r21, Y+58	; 0x3a
    2706:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    270a:	a7 01       	movw	r20, r14
    270c:	96 01       	movw	r18, r12
    270e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2712:	9b 01       	movw	r18, r22
    2714:	ac 01       	movw	r20, r24
    2716:	69 8d       	ldd	r22, Y+25	; 0x19
    2718:	7a 8d       	ldd	r23, Y+26	; 0x1a
    271a:	8b 8d       	ldd	r24, Y+27	; 0x1b
    271c:	9c 8d       	ldd	r25, Y+28	; 0x1c
    271e:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2722:	8b 01       	movw	r16, r22
    2724:	89 83       	std	Y+1, r24	; 0x01
    2726:	9d 83       	std	Y+5, r25	; 0x05
    2728:	9b 01       	movw	r18, r22
    272a:	ac 01       	movw	r20, r24
    272c:	6d 8d       	ldd	r22, Y+29	; 0x1d
    272e:	7e 8d       	ldd	r23, Y+30	; 0x1e
    2730:	8f 8d       	ldd	r24, Y+31	; 0x1f
    2732:	98 a1       	ldd	r25, Y+32	; 0x20
    2734:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    2738:	18 16       	cp	r1, r24
    273a:	8c f5       	brge	.+98     	; 0x279e <st_prep_buffer+0xb3a>
    273c:	2d 8d       	ldd	r18, Y+29	; 0x1d
    273e:	3e 8d       	ldd	r19, Y+30	; 0x1e
    2740:	4f 8d       	ldd	r20, Y+31	; 0x1f
    2742:	58 a1       	ldd	r21, Y+32	; 0x20
    2744:	6d a1       	ldd	r22, Y+37	; 0x25
    2746:	7e a1       	ldd	r23, Y+38	; 0x26
    2748:	8f a1       	ldd	r24, Y+39	; 0x27
    274a:	98 a5       	ldd	r25, Y+40	; 0x28
    274c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2750:	9b 01       	movw	r18, r22
    2752:	ac 01       	movw	r20, r24
    2754:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2758:	6b 01       	movw	r12, r22
    275a:	7c 01       	movw	r14, r24
    275c:	2d 89       	ldd	r18, Y+21	; 0x15
    275e:	3e 89       	ldd	r19, Y+22	; 0x16
    2760:	4f 89       	ldd	r20, Y+23	; 0x17
    2762:	58 8d       	ldd	r21, Y+24	; 0x18
    2764:	67 2d       	mov	r22, r7
    2766:	76 2d       	mov	r23, r6
    2768:	8b ad       	ldd	r24, Y+59	; 0x3b
    276a:	9a ad       	ldd	r25, Y+58	; 0x3a
    276c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2770:	9b 01       	movw	r18, r22
    2772:	ac 01       	movw	r20, r24
    2774:	c7 01       	movw	r24, r14
    2776:	b6 01       	movw	r22, r12
    2778:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    277c:	6b 01       	movw	r12, r22
    277e:	7c 01       	movw	r14, r24
    2780:	7d 88       	ldd	r7, Y+21	; 0x15
    2782:	6e 88       	ldd	r6, Y+22	; 0x16
    2784:	bf 89       	ldd	r27, Y+23	; 0x17
    2786:	bb af       	std	Y+59, r27	; 0x3b
    2788:	e8 8d       	ldd	r30, Y+24	; 0x18
    278a:	ea af       	std	Y+58, r30	; 0x3a
    278c:	fd a9       	ldd	r31, Y+53	; 0x35
    278e:	fd 87       	std	Y+13, r31	; 0x0d
    2790:	0d 8d       	ldd	r16, Y+29	; 0x1d
    2792:	1e 8d       	ldd	r17, Y+30	; 0x1e
    2794:	2f 8d       	ldd	r18, Y+31	; 0x1f
    2796:	29 83       	std	Y+1, r18	; 0x01
    2798:	38 a1       	ldd	r19, Y+32	; 0x20
    279a:	3d 83       	std	Y+5, r19	; 0x05
    279c:	19 cc       	rjmp	.-1998   	; 0x1fd0 <st_prep_buffer+0x36c>
    279e:	a5 01       	movw	r20, r10
    27a0:	94 01       	movw	r18, r8
    27a2:	67 2d       	mov	r22, r7
    27a4:	76 2d       	mov	r23, r6
    27a6:	8b ad       	ldd	r24, Y+59	; 0x3b
    27a8:	9a ad       	ldd	r25, Y+58	; 0x3a
    27aa:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    27ae:	76 2e       	mov	r7, r22
    27b0:	67 2e       	mov	r6, r23
    27b2:	8b af       	std	Y+59, r24	; 0x3b
    27b4:	9a af       	std	Y+58, r25	; 0x3a
    27b6:	0c cc       	rjmp	.-2024   	; 0x1fd0 <st_prep_buffer+0x36c>
    27b8:	2d 89       	ldd	r18, Y+21	; 0x15
    27ba:	3e 89       	ldd	r19, Y+22	; 0x16
    27bc:	4f 89       	ldd	r20, Y+23	; 0x17
    27be:	58 8d       	ldd	r21, Y+24	; 0x18
    27c0:	c7 01       	movw	r24, r14
    27c2:	b6 01       	movw	r22, r12
    27c4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    27c8:	9b 01       	movw	r18, r22
    27ca:	ac 01       	movw	r20, r24
    27cc:	69 8d       	ldd	r22, Y+25	; 0x19
    27ce:	7a 8d       	ldd	r23, Y+26	; 0x1a
    27d0:	8b 8d       	ldd	r24, Y+27	; 0x1b
    27d2:	9c 8d       	ldd	r25, Y+28	; 0x1c
    27d4:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    27d8:	8b 01       	movw	r16, r22
    27da:	89 83       	std	Y+1, r24	; 0x01
    27dc:	9d 83       	std	Y+5, r25	; 0x05
    27de:	29 a5       	ldd	r18, Y+41	; 0x29
    27e0:	3a a5       	ldd	r19, Y+42	; 0x2a
    27e2:	4b a5       	ldd	r20, Y+43	; 0x2b
    27e4:	5c a5       	ldd	r21, Y+44	; 0x2c
    27e6:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    27ea:	87 ff       	sbrs	r24, 7
    27ec:	f1 cb       	rjmp	.-2078   	; 0x1fd0 <st_prep_buffer+0x36c>
    27ee:	29 a5       	ldd	r18, Y+41	; 0x29
    27f0:	3a a5       	ldd	r19, Y+42	; 0x2a
    27f2:	4b a5       	ldd	r20, Y+43	; 0x2b
    27f4:	5c a5       	ldd	r21, Y+44	; 0x2c
    27f6:	69 8d       	ldd	r22, Y+25	; 0x19
    27f8:	7a 8d       	ldd	r23, Y+26	; 0x1a
    27fa:	8b 8d       	ldd	r24, Y+27	; 0x1b
    27fc:	9c 8d       	ldd	r25, Y+28	; 0x1c
    27fe:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2802:	2d 89       	ldd	r18, Y+21	; 0x15
    2804:	3e 89       	ldd	r19, Y+22	; 0x16
    2806:	4f 89       	ldd	r20, Y+23	; 0x17
    2808:	58 8d       	ldd	r21, Y+24	; 0x18
    280a:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    280e:	6b 01       	movw	r12, r22
    2810:	7c 01       	movw	r14, r24
    2812:	09 a5       	ldd	r16, Y+41	; 0x29
    2814:	1a a5       	ldd	r17, Y+42	; 0x2a
    2816:	4b a5       	ldd	r20, Y+43	; 0x2b
    2818:	49 83       	std	Y+1, r20	; 0x01
    281a:	5c a5       	ldd	r21, Y+44	; 0x2c
    281c:	5d 83       	std	Y+5, r21	; 0x05
    281e:	82 e0       	ldi	r24, 0x02	; 2
    2820:	8d 87       	std	Y+13, r24	; 0x0d
    2822:	d6 cb       	rjmp	.-2132   	; 0x1fd0 <st_prep_buffer+0x36c>
    2824:	5a 96       	adiw	r26, 0x1a	; 26
    2826:	2d 91       	ld	r18, X+
    2828:	3d 91       	ld	r19, X+
    282a:	4d 91       	ld	r20, X+
    282c:	5c 91       	ld	r21, X
    282e:	5d 97       	sbiw	r26, 0x1d	; 29
    2830:	c7 01       	movw	r24, r14
    2832:	b6 01       	movw	r22, r12
    2834:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2838:	4b 01       	movw	r8, r22
    283a:	5c 01       	movw	r10, r24
    283c:	ac 01       	movw	r20, r24
    283e:	9b 01       	movw	r18, r22
    2840:	67 2d       	mov	r22, r7
    2842:	76 2d       	mov	r23, r6
    2844:	8b ad       	ldd	r24, Y+59	; 0x3b
    2846:	9a ad       	ldd	r25, Y+58	; 0x3a
    2848:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    284c:	18 16       	cp	r1, r24
    284e:	44 f5       	brge	.+80     	; 0x28a0 <st_prep_buffer+0xc3c>
    2850:	20 e0       	ldi	r18, 0x00	; 0
    2852:	30 e0       	ldi	r19, 0x00	; 0
    2854:	40 e0       	ldi	r20, 0x00	; 0
    2856:	5f e3       	ldi	r21, 0x3F	; 63
    2858:	c5 01       	movw	r24, r10
    285a:	b4 01       	movw	r22, r8
    285c:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2860:	9b 01       	movw	r18, r22
    2862:	ac 01       	movw	r20, r24
    2864:	67 2d       	mov	r22, r7
    2866:	76 2d       	mov	r23, r6
    2868:	8b ad       	ldd	r24, Y+59	; 0x3b
    286a:	9a ad       	ldd	r25, Y+58	; 0x3a
    286c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2870:	a7 01       	movw	r20, r14
    2872:	96 01       	movw	r18, r12
    2874:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2878:	9b 01       	movw	r18, r22
    287a:	ac 01       	movw	r20, r24
    287c:	69 8d       	ldd	r22, Y+25	; 0x19
    287e:	7a 8d       	ldd	r23, Y+26	; 0x1a
    2880:	8b 8d       	ldd	r24, Y+27	; 0x1b
    2882:	9c 8d       	ldd	r25, Y+28	; 0x1c
    2884:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2888:	8b 01       	movw	r16, r22
    288a:	89 83       	std	Y+1, r24	; 0x01
    288c:	9d 83       	std	Y+5, r25	; 0x05
    288e:	2d a5       	ldd	r18, Y+45	; 0x2d
    2890:	3e a5       	ldd	r19, Y+46	; 0x2e
    2892:	4f a5       	ldd	r20, Y+47	; 0x2f
    2894:	58 a9       	ldd	r21, Y+48	; 0x30
    2896:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    289a:	18 16       	cp	r1, r24
    289c:	0c f4       	brge	.+2      	; 0x28a0 <st_prep_buffer+0xc3c>
    289e:	14 cf       	rjmp	.-472    	; 0x26c8 <st_prep_buffer+0xa64>
    28a0:	2d a5       	ldd	r18, Y+45	; 0x2d
    28a2:	3e a5       	ldd	r19, Y+46	; 0x2e
    28a4:	4f a5       	ldd	r20, Y+47	; 0x2f
    28a6:	58 a9       	ldd	r21, Y+48	; 0x30
    28a8:	69 8d       	ldd	r22, Y+25	; 0x19
    28aa:	7a 8d       	ldd	r23, Y+26	; 0x1a
    28ac:	8b 8d       	ldd	r24, Y+27	; 0x1b
    28ae:	9c 8d       	ldd	r25, Y+28	; 0x1c
    28b0:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    28b4:	9b 01       	movw	r18, r22
    28b6:	ac 01       	movw	r20, r24
    28b8:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    28bc:	6b 01       	movw	r12, r22
    28be:	7c 01       	movw	r14, r24
    28c0:	2e a9       	ldd	r18, Y+54	; 0x36
    28c2:	3f a9       	ldd	r19, Y+55	; 0x37
    28c4:	48 ad       	ldd	r20, Y+56	; 0x38
    28c6:	59 ad       	ldd	r21, Y+57	; 0x39
    28c8:	67 2d       	mov	r22, r7
    28ca:	76 2d       	mov	r23, r6
    28cc:	8b ad       	ldd	r24, Y+59	; 0x3b
    28ce:	9a ad       	ldd	r25, Y+58	; 0x3a
    28d0:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    28d4:	9b 01       	movw	r18, r22
    28d6:	ac 01       	movw	r20, r24
    28d8:	c7 01       	movw	r24, r14
    28da:	b6 01       	movw	r22, r12
    28dc:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    28e0:	6b 01       	movw	r12, r22
    28e2:	7c 01       	movw	r14, r24
    28e4:	7e a8       	ldd	r7, Y+54	; 0x36
    28e6:	6f a8       	ldd	r6, Y+55	; 0x37
    28e8:	b8 ad       	ldd	r27, Y+56	; 0x38
    28ea:	bb af       	std	Y+59, r27	; 0x3b
    28ec:	e9 ad       	ldd	r30, Y+57	; 0x39
    28ee:	ea af       	std	Y+58, r30	; 0x3a
    28f0:	0d a5       	ldd	r16, Y+45	; 0x2d
    28f2:	1e a5       	ldd	r17, Y+46	; 0x2e
    28f4:	ff a5       	ldd	r31, Y+47	; 0x2f
    28f6:	f9 83       	std	Y+1, r31	; 0x01
    28f8:	28 a9       	ldd	r18, Y+48	; 0x30
    28fa:	2d 83       	std	Y+5, r18	; 0x05
    28fc:	69 cb       	rjmp	.-2350   	; 0x1fd0 <st_prep_buffer+0x36c>
    28fe:	29 a9       	ldd	r18, Y+49	; 0x31
    2900:	3a a9       	ldd	r19, Y+50	; 0x32
    2902:	4b a9       	ldd	r20, Y+51	; 0x33
    2904:	5c a9       	ldd	r21, Y+52	; 0x34
    2906:	b8 01       	movw	r22, r16
    2908:	89 81       	ldd	r24, Y+1	; 0x01
    290a:	9d 81       	ldd	r25, Y+5	; 0x05
    290c:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    2910:	18 16       	cp	r1, r24
    2912:	8c f4       	brge	.+34     	; 0x2936 <st_prep_buffer+0xcd2>
    2914:	2e e3       	ldi	r18, 0x3E	; 62
    2916:	33 ec       	ldi	r19, 0xC3	; 195
    2918:	4e e2       	ldi	r20, 0x2E	; 46
    291a:	59 e3       	ldi	r21, 0x39	; 57
    291c:	69 a1       	ldd	r22, Y+33	; 0x21
    291e:	7a a1       	ldd	r23, Y+34	; 0x22
    2920:	8b a1       	ldd	r24, Y+35	; 0x23
    2922:	9c a1       	ldd	r25, Y+36	; 0x24
    2924:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2928:	69 a3       	std	Y+33, r22	; 0x21
    292a:	7a a3       	std	Y+34, r23	; 0x22
    292c:	8b a3       	std	Y+35, r24	; 0x23
    292e:	9c a3       	std	Y+36, r25	; 0x24
    2930:	a2 01       	movw	r20, r4
    2932:	91 01       	movw	r18, r2
    2934:	63 cb       	rjmp	.-2362   	; 0x1ffc <st_prep_buffer+0x398>
    2936:	4d 85       	ldd	r20, Y+13	; 0x0d
    2938:	40 93 b3 02 	sts	0x02B3, r20	; 0x8002b3 <prep+0x12>
    293c:	71 cb       	rjmp	.-2334   	; 0x2020 <st_prep_buffer+0x3bc>
    293e:	10 92 3e 06 	sts	0x063E, r1	; 0x80063e <sys+0xd>
    2942:	10 92 3f 06 	sts	0x063F, r1	; 0x80063f <sys+0xe>
    2946:	10 92 40 06 	sts	0x0640, r1	; 0x800640 <sys+0xf>
    294a:	10 92 41 06 	sts	0x0641, r1	; 0x800641 <sys+0x10>
    294e:	10 92 d0 02 	sts	0x02D0, r1	; 0x8002d0 <prep+0x2f>
    2952:	a9 cb       	rjmp	.-2222   	; 0x20a6 <st_prep_buffer+0x442>
    2954:	20 91 a3 02 	lds	r18, 0x02A3	; 0x8002a3 <prep+0x2>
    2958:	30 91 a4 02 	lds	r19, 0x02A4	; 0x8002a4 <prep+0x3>
    295c:	40 91 a5 02 	lds	r20, 0x02A5	; 0x8002a5 <prep+0x4>
    2960:	50 91 a6 02 	lds	r21, 0x02A6	; 0x8002a6 <prep+0x5>
    2964:	c2 01       	movw	r24, r4
    2966:	b1 01       	movw	r22, r2
    2968:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    296c:	2b 01       	movw	r4, r22
    296e:	3c 01       	movw	r6, r24
    2970:	29 85       	ldd	r18, Y+9	; 0x09
    2972:	3a 85       	ldd	r19, Y+10	; 0x0a
    2974:	4b 85       	ldd	r20, Y+11	; 0x0b
    2976:	5c 85       	ldd	r21, Y+12	; 0x0c
    2978:	c5 01       	movw	r24, r10
    297a:	b4 01       	movw	r22, r8
    297c:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2980:	9b 01       	movw	r18, r22
    2982:	ac 01       	movw	r20, r24
    2984:	c3 01       	movw	r24, r6
    2986:	b2 01       	movw	r22, r4
    2988:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    298c:	4b 01       	movw	r8, r22
    298e:	5c 01       	movw	r10, r24
    2990:	20 ec       	ldi	r18, 0xC0	; 192
    2992:	31 ee       	ldi	r19, 0xE1	; 225
    2994:	44 e6       	ldi	r20, 0x64	; 100
    2996:	5e e4       	ldi	r21, 0x4E	; 78
    2998:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    299c:	0e 94 22 36 	call	0x6c44	; 0x6c44 <ceil>
    29a0:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    29a4:	60 3d       	cpi	r22, 0xD0	; 208
    29a6:	57 e0       	ldi	r21, 0x07	; 7
    29a8:	75 07       	cpc	r23, r21
    29aa:	81 05       	cpc	r24, r1
    29ac:	91 05       	cpc	r25, r1
    29ae:	08 f0       	brcs	.+2      	; 0x29b2 <st_prep_buffer+0xd4e>
    29b0:	66 c0       	rjmp	.+204    	; 0x2a7e <st_prep_buffer+0xe1a>
    29b2:	27 e0       	ldi	r18, 0x07	; 7
    29b4:	a9 89       	ldd	r26, Y+17	; 0x11
    29b6:	ba 89       	ldd	r27, Y+18	; 0x12
    29b8:	2a 9f       	mul	r18, r26
    29ba:	f0 01       	movw	r30, r0
    29bc:	2b 9f       	mul	r18, r27
    29be:	f0 0d       	add	r31, r0
    29c0:	11 24       	eor	r1, r1
    29c2:	e6 5e       	subi	r30, 0xE6	; 230
    29c4:	fd 4f       	sbci	r31, 0xFD	; 253
    29c6:	15 82       	std	Z+5, r1	; 0x05
    29c8:	27 e0       	ldi	r18, 0x07	; 7
    29ca:	a9 89       	ldd	r26, Y+17	; 0x11
    29cc:	ba 89       	ldd	r27, Y+18	; 0x12
    29ce:	2a 9f       	mul	r18, r26
    29d0:	f0 01       	movw	r30, r0
    29d2:	2b 9f       	mul	r18, r27
    29d4:	f0 0d       	add	r31, r0
    29d6:	11 24       	eor	r1, r1
    29d8:	e6 5e       	subi	r30, 0xE6	; 230
    29da:	fd 4f       	sbci	r31, 0xFD	; 253
    29dc:	73 83       	std	Z+3, r23	; 0x03
    29de:	62 83       	std	Z+2, r22	; 0x02
    29e0:	80 91 19 02 	lds	r24, 0x0219	; 0x800219 <segment_next_head>
    29e4:	80 93 44 02 	sts	0x0244, r24	; 0x800244 <segment_buffer_head>
    29e8:	8f 5f       	subi	r24, 0xFF	; 255
    29ea:	86 30       	cpi	r24, 0x06	; 6
    29ec:	09 f4       	brne	.+2      	; 0x29f0 <st_prep_buffer+0xd8c>
    29ee:	a1 c0       	rjmp	.+322    	; 0x2b32 <st_prep_buffer+0xece>
    29f0:	80 93 19 02 	sts	0x0219, r24	; 0x800219 <segment_next_head>
    29f4:	e0 91 d1 02 	lds	r30, 0x02D1	; 0x8002d1 <pl_block>
    29f8:	f0 91 d2 02 	lds	r31, 0x02D2	; 0x8002d2 <pl_block+0x1>
    29fc:	c8 01       	movw	r24, r16
    29fe:	a9 81       	ldd	r26, Y+1	; 0x01
    2a00:	bd 81       	ldd	r27, Y+5	; 0x05
    2a02:	86 8f       	std	Z+30, r24	; 0x1e
    2a04:	97 8f       	std	Z+31, r25	; 0x1f
    2a06:	a0 a3       	std	Z+32, r26	; 0x20
    2a08:	b1 a3       	std	Z+33, r27	; 0x21
    2a0a:	c0 92 a7 02 	sts	0x02A7, r12	; 0x8002a7 <prep+0x6>
    2a0e:	d0 92 a8 02 	sts	0x02A8, r13	; 0x8002a8 <prep+0x7>
    2a12:	e0 92 a9 02 	sts	0x02A9, r14	; 0x8002a9 <prep+0x8>
    2a16:	f0 92 aa 02 	sts	0x02AA, r15	; 0x8002aa <prep+0x9>
    2a1a:	29 85       	ldd	r18, Y+9	; 0x09
    2a1c:	3a 85       	ldd	r19, Y+10	; 0x0a
    2a1e:	4b 85       	ldd	r20, Y+11	; 0x0b
    2a20:	5c 85       	ldd	r21, Y+12	; 0x0c
    2a22:	c7 01       	movw	r24, r14
    2a24:	b6 01       	movw	r22, r12
    2a26:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2a2a:	a5 01       	movw	r20, r10
    2a2c:	94 01       	movw	r18, r8
    2a2e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    2a32:	60 93 a3 02 	sts	0x02A3, r22	; 0x8002a3 <prep+0x2>
    2a36:	70 93 a4 02 	sts	0x02A4, r23	; 0x8002a4 <prep+0x3>
    2a3a:	80 93 a5 02 	sts	0x02A5, r24	; 0x8002a5 <prep+0x4>
    2a3e:	90 93 a6 02 	sts	0x02A6, r25	; 0x8002a6 <prep+0x5>
    2a42:	20 91 b4 02 	lds	r18, 0x02B4	; 0x8002b4 <prep+0x13>
    2a46:	30 91 b5 02 	lds	r19, 0x02B5	; 0x8002b5 <prep+0x14>
    2a4a:	40 91 b6 02 	lds	r20, 0x02B6	; 0x8002b6 <prep+0x15>
    2a4e:	50 91 b7 02 	lds	r21, 0x02B7	; 0x8002b7 <prep+0x16>
    2a52:	b8 01       	movw	r22, r16
    2a54:	89 81       	ldd	r24, Y+1	; 0x01
    2a56:	9d 81       	ldd	r25, Y+5	; 0x05
    2a58:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    2a5c:	81 11       	cpse	r24, r1
    2a5e:	20 c9       	rjmp	.-3520   	; 0x1ca0 <st_prep_buffer+0x3c>
    2a60:	f0 90 35 06 	lds	r15, 0x0635	; 0x800635 <sys+0x4>
    2a64:	20 e0       	ldi	r18, 0x00	; 0
    2a66:	30 e0       	ldi	r19, 0x00	; 0
    2a68:	a9 01       	movw	r20, r18
    2a6a:	b8 01       	movw	r22, r16
    2a6c:	89 81       	ldd	r24, Y+1	; 0x01
    2a6e:	9d 81       	ldd	r25, Y+5	; 0x05
    2a70:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    2a74:	18 16       	cp	r1, r24
    2a76:	0c f0       	brlt	.+2      	; 0x2a7a <st_prep_buffer+0xe16>
    2a78:	5f c0       	rjmp	.+190    	; 0x2b38 <st_prep_buffer+0xed4>
    2a7a:	8f 2d       	mov	r24, r15
    2a7c:	61 cb       	rjmp	.-2366   	; 0x2140 <st_prep_buffer+0x4dc>
    2a7e:	60 3a       	cpi	r22, 0xA0	; 160
    2a80:	3f e0       	ldi	r19, 0x0F	; 15
    2a82:	73 07       	cpc	r23, r19
    2a84:	81 05       	cpc	r24, r1
    2a86:	91 05       	cpc	r25, r1
    2a88:	a0 f5       	brcc	.+104    	; 0x2af2 <st_prep_buffer+0xe8e>
    2a8a:	a7 e0       	ldi	r26, 0x07	; 7
    2a8c:	49 89       	ldd	r20, Y+17	; 0x11
    2a8e:	5a 89       	ldd	r21, Y+18	; 0x12
    2a90:	a4 9f       	mul	r26, r20
    2a92:	f0 01       	movw	r30, r0
    2a94:	a5 9f       	mul	r26, r21
    2a96:	f0 0d       	add	r31, r0
    2a98:	11 24       	eor	r1, r1
    2a9a:	e6 5e       	subi	r30, 0xE6	; 230
    2a9c:	fd 4f       	sbci	r31, 0xFD	; 253
    2a9e:	b1 e0       	ldi	r27, 0x01	; 1
    2aa0:	b5 83       	std	Z+5, r27	; 0x05
    2aa2:	a7 e0       	ldi	r26, 0x07	; 7
    2aa4:	49 89       	ldd	r20, Y+17	; 0x11
    2aa6:	5a 89       	ldd	r21, Y+18	; 0x12
    2aa8:	a4 9f       	mul	r26, r20
    2aaa:	f0 01       	movw	r30, r0
    2aac:	a5 9f       	mul	r26, r21
    2aae:	f0 0d       	add	r31, r0
    2ab0:	11 24       	eor	r1, r1
    2ab2:	e6 5e       	subi	r30, 0xE6	; 230
    2ab4:	fd 4f       	sbci	r31, 0xFD	; 253
    2ab6:	25 81       	ldd	r18, Z+5	; 0x05
    2ab8:	02 2e       	mov	r0, r18
    2aba:	04 c0       	rjmp	.+8      	; 0x2ac4 <st_prep_buffer+0xe60>
    2abc:	96 95       	lsr	r25
    2abe:	87 95       	ror	r24
    2ac0:	77 95       	ror	r23
    2ac2:	67 95       	ror	r22
    2ac4:	0a 94       	dec	r0
    2ac6:	d2 f7       	brpl	.-12     	; 0x2abc <st_prep_buffer+0xe58>
    2ac8:	4d 85       	ldd	r20, Y+13	; 0x0d
    2aca:	5e 85       	ldd	r21, Y+14	; 0x0e
    2acc:	02 c0       	rjmp	.+4      	; 0x2ad2 <st_prep_buffer+0xe6e>
    2ace:	44 0f       	add	r20, r20
    2ad0:	55 1f       	adc	r21, r21
    2ad2:	2a 95       	dec	r18
    2ad4:	e2 f7       	brpl	.-8      	; 0x2ace <st_prep_buffer+0xe6a>
    2ad6:	51 83       	std	Z+1, r21	; 0x01
    2ad8:	40 83       	st	Z, r20
    2ada:	61 15       	cp	r22, r1
    2adc:	71 05       	cpc	r23, r1
    2ade:	51 e0       	ldi	r21, 0x01	; 1
    2ae0:	85 07       	cpc	r24, r21
    2ae2:	91 05       	cpc	r25, r1
    2ae4:	08 f4       	brcc	.+2      	; 0x2ae8 <st_prep_buffer+0xe84>
    2ae6:	70 cf       	rjmp	.-288    	; 0x29c8 <st_prep_buffer+0xd64>
    2ae8:	4f ef       	ldi	r20, 0xFF	; 255
    2aea:	5f ef       	ldi	r21, 0xFF	; 255
    2aec:	53 83       	std	Z+3, r21	; 0x03
    2aee:	42 83       	std	Z+2, r20	; 0x02
    2af0:	77 cf       	rjmp	.-274    	; 0x29e0 <st_prep_buffer+0xd7c>
    2af2:	60 34       	cpi	r22, 0x40	; 64
    2af4:	ef e1       	ldi	r30, 0x1F	; 31
    2af6:	7e 07       	cpc	r23, r30
    2af8:	81 05       	cpc	r24, r1
    2afa:	91 05       	cpc	r25, r1
    2afc:	68 f4       	brcc	.+26     	; 0x2b18 <st_prep_buffer+0xeb4>
    2afe:	47 e0       	ldi	r20, 0x07	; 7
    2b00:	29 89       	ldd	r18, Y+17	; 0x11
    2b02:	3a 89       	ldd	r19, Y+18	; 0x12
    2b04:	42 9f       	mul	r20, r18
    2b06:	f0 01       	movw	r30, r0
    2b08:	43 9f       	mul	r20, r19
    2b0a:	f0 0d       	add	r31, r0
    2b0c:	11 24       	eor	r1, r1
    2b0e:	e6 5e       	subi	r30, 0xE6	; 230
    2b10:	fd 4f       	sbci	r31, 0xFD	; 253
    2b12:	52 e0       	ldi	r21, 0x02	; 2
    2b14:	55 83       	std	Z+5, r21	; 0x05
    2b16:	c5 cf       	rjmp	.-118    	; 0x2aa2 <st_prep_buffer+0xe3e>
    2b18:	27 e0       	ldi	r18, 0x07	; 7
    2b1a:	a9 89       	ldd	r26, Y+17	; 0x11
    2b1c:	ba 89       	ldd	r27, Y+18	; 0x12
    2b1e:	2a 9f       	mul	r18, r26
    2b20:	f0 01       	movw	r30, r0
    2b22:	2b 9f       	mul	r18, r27
    2b24:	f0 0d       	add	r31, r0
    2b26:	11 24       	eor	r1, r1
    2b28:	e6 5e       	subi	r30, 0xE6	; 230
    2b2a:	fd 4f       	sbci	r31, 0xFD	; 253
    2b2c:	33 e0       	ldi	r19, 0x03	; 3
    2b2e:	35 83       	std	Z+5, r19	; 0x05
    2b30:	b8 cf       	rjmp	.-144    	; 0x2aa2 <st_prep_buffer+0xe3e>
    2b32:	10 92 19 02 	sts	0x0219, r1	; 0x800219 <segment_next_head>
    2b36:	5e cf       	rjmp	.-324    	; 0x29f4 <st_prep_buffer+0xd90>
    2b38:	f2 fc       	sbrc	r15, 2
    2b3a:	9f cf       	rjmp	.-194    	; 0x2a7a <st_prep_buffer+0xe16>
    2b3c:	10 92 d2 02 	sts	0x02D2, r1	; 0x8002d2 <pl_block+0x1>
    2b40:	10 92 d1 02 	sts	0x02D1, r1	; 0x8002d1 <pl_block>
    2b44:	90 91 d5 02 	lds	r25, 0x02D5	; 0x8002d5 <block_buffer_tail>
    2b48:	80 91 f6 05 	lds	r24, 0x05F6	; 0x8005f6 <block_buffer_head>
    2b4c:	89 17       	cp	r24, r25
    2b4e:	09 f4       	brne	.+2      	; 0x2b52 <st_prep_buffer+0xeee>
    2b50:	a7 c8       	rjmp	.-3762   	; 0x1ca0 <st_prep_buffer+0x3c>
    2b52:	81 e0       	ldi	r24, 0x01	; 1
    2b54:	89 0f       	add	r24, r25
    2b56:	80 31       	cpi	r24, 0x10	; 16
    2b58:	09 f4       	brne	.+2      	; 0x2b5c <st_prep_buffer+0xef8>
    2b5a:	80 e0       	ldi	r24, 0x00	; 0
    2b5c:	20 91 d3 02 	lds	r18, 0x02D3	; 0x8002d3 <block_buffer_planned>
    2b60:	92 13       	cpse	r25, r18
    2b62:	02 c0       	rjmp	.+4      	; 0x2b68 <st_prep_buffer+0xf04>
    2b64:	80 93 d3 02 	sts	0x02D3, r24	; 0x8002d3 <block_buffer_planned>
    2b68:	80 93 d5 02 	sts	0x02D5, r24	; 0x8002d5 <block_buffer_tail>
    2b6c:	99 c8       	rjmp	.-3790   	; 0x1ca0 <st_prep_buffer+0x3c>

00002b6e <protocol_exec_rt_system>:
    2b6e:	2f 92       	push	r2
    2b70:	3f 92       	push	r3
    2b72:	4f 92       	push	r4
    2b74:	5f 92       	push	r5
    2b76:	6f 92       	push	r6
    2b78:	7f 92       	push	r7
    2b7a:	8f 92       	push	r8
    2b7c:	9f 92       	push	r9
    2b7e:	af 92       	push	r10
    2b80:	bf 92       	push	r11
    2b82:	cf 92       	push	r12
    2b84:	df 92       	push	r13
    2b86:	ef 92       	push	r14
    2b88:	ff 92       	push	r15
    2b8a:	0f 93       	push	r16
    2b8c:	1f 93       	push	r17
    2b8e:	cf 93       	push	r28
    2b90:	df 93       	push	r29
    2b92:	cd b7       	in	r28, 0x3d	; 61
    2b94:	de b7       	in	r29, 0x3e	; 62
    2b96:	a4 97       	sbiw	r28, 0x24	; 36
    2b98:	0f b6       	in	r0, 0x3f	; 63
    2b9a:	f8 94       	cli
    2b9c:	de bf       	out	0x3e, r29	; 62
    2b9e:	0f be       	out	0x3f, r0	; 63
    2ba0:	cd bf       	out	0x3d, r28	; 61
    2ba2:	10 91 14 06 	lds	r17, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    2ba6:	11 23       	and	r17, r17
    2ba8:	49 f1       	breq	.+82     	; 0x2bfc <protocol_exec_rt_system+0x8e>
    2baa:	81 e0       	ldi	r24, 0x01	; 1
    2bac:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2bb0:	86 e6       	ldi	r24, 0x66	; 102
    2bb2:	91 e0       	ldi	r25, 0x01	; 1
    2bb4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2bb8:	81 2f       	mov	r24, r17
    2bba:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    2bbe:	0e 94 d5 07 	call	0xfaa	; 0xfaa <report_util_line_feed>
    2bc2:	85 ef       	ldi	r24, 0xF5	; 245
    2bc4:	91 e0       	ldi	r25, 0x01	; 1
    2bc6:	01 97       	sbiw	r24, 0x01	; 1
    2bc8:	e1 f5       	brne	.+120    	; 0x2c42 <protocol_exec_rt_system+0xd4>
    2bca:	11 50       	subi	r17, 0x01	; 1
    2bcc:	12 30       	cpi	r17, 0x02	; 2
    2bce:	88 f4       	brcc	.+34     	; 0x2bf2 <protocol_exec_rt_system+0x84>
    2bd0:	8a ec       	ldi	r24, 0xCA	; 202
    2bd2:	92 e0       	ldi	r25, 0x02	; 2
    2bd4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2bd8:	88 eb       	ldi	r24, 0xB8	; 184
    2bda:	92 e0       	ldi	r25, 0x02	; 2
    2bdc:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2be0:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    2be4:	80 e1       	ldi	r24, 0x10	; 16
    2be6:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    2bea:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    2bee:	84 ff       	sbrs	r24, 4
    2bf0:	fc cf       	rjmp	.-8      	; 0x2bea <protocol_exec_rt_system+0x7c>
    2bf2:	8f b7       	in	r24, 0x3f	; 63
    2bf4:	f8 94       	cli
    2bf6:	10 92 14 06 	sts	0x0614, r1	; 0x800614 <sys_rt_exec_alarm>
    2bfa:	8f bf       	out	0x3f, r24	; 63
    2bfc:	10 91 13 06 	lds	r17, 0x0613	; 0x800613 <sys_rt_exec_state>
    2c00:	11 23       	and	r17, r17
    2c02:	09 f4       	brne	.+2      	; 0x2c06 <protocol_exec_rt_system+0x98>
    2c04:	a9 c2       	rjmp	.+1362   	; 0x3158 <protocol_exec_rt_system+0x5ea>
    2c06:	14 ff       	sbrs	r17, 4
    2c08:	23 c0       	rjmp	.+70     	; 0x2c50 <protocol_exec_rt_system+0xe2>
    2c0a:	81 e0       	ldi	r24, 0x01	; 1
    2c0c:	80 93 32 06 	sts	0x0632, r24	; 0x800632 <sys+0x1>
    2c10:	a4 96       	adiw	r28, 0x24	; 36
    2c12:	0f b6       	in	r0, 0x3f	; 63
    2c14:	f8 94       	cli
    2c16:	de bf       	out	0x3e, r29	; 62
    2c18:	0f be       	out	0x3f, r0	; 63
    2c1a:	cd bf       	out	0x3d, r28	; 61
    2c1c:	df 91       	pop	r29
    2c1e:	cf 91       	pop	r28
    2c20:	1f 91       	pop	r17
    2c22:	0f 91       	pop	r16
    2c24:	ff 90       	pop	r15
    2c26:	ef 90       	pop	r14
    2c28:	df 90       	pop	r13
    2c2a:	cf 90       	pop	r12
    2c2c:	bf 90       	pop	r11
    2c2e:	af 90       	pop	r10
    2c30:	9f 90       	pop	r9
    2c32:	8f 90       	pop	r8
    2c34:	7f 90       	pop	r7
    2c36:	6f 90       	pop	r6
    2c38:	5f 90       	pop	r5
    2c3a:	4f 90       	pop	r4
    2c3c:	3f 90       	pop	r3
    2c3e:	2f 90       	pop	r2
    2c40:	08 95       	ret
    2c42:	ef e9       	ldi	r30, 0x9F	; 159
    2c44:	ff e0       	ldi	r31, 0x0F	; 15
    2c46:	31 97       	sbiw	r30, 0x01	; 1
    2c48:	f1 f7       	brne	.-4      	; 0x2c46 <protocol_exec_rt_system+0xd8>
    2c4a:	00 c0       	rjmp	.+0      	; 0x2c4c <protocol_exec_rt_system+0xde>
    2c4c:	00 00       	nop
    2c4e:	bb cf       	rjmp	.-138    	; 0x2bc6 <protocol_exec_rt_system+0x58>
    2c50:	10 ff       	sbrs	r17, 0
    2c52:	cd c0       	rjmp	.+410    	; 0x2dee <protocol_exec_rt_system+0x280>
    2c54:	8c e0       	ldi	r24, 0x0C	; 12
    2c56:	e8 e1       	ldi	r30, 0x18	; 24
    2c58:	f6 e0       	ldi	r31, 0x06	; 6
    2c5a:	de 01       	movw	r26, r28
    2c5c:	59 96       	adiw	r26, 0x19	; 25
    2c5e:	01 90       	ld	r0, Z+
    2c60:	0d 92       	st	X+, r0
    2c62:	8a 95       	dec	r24
    2c64:	e1 f7       	brne	.-8      	; 0x2c5e <protocol_exec_rt_system+0xf0>
    2c66:	be 01       	movw	r22, r28
    2c68:	67 5e       	subi	r22, 0xE7	; 231
    2c6a:	7f 4f       	sbci	r23, 0xFF	; 255
    2c6c:	ce 01       	movw	r24, r28
    2c6e:	0d 96       	adiw	r24, 0x0d	; 13
    2c70:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    2c74:	8c e3       	ldi	r24, 0x3C	; 60
    2c76:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2c7a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2c7e:	88 30       	cpi	r24, 0x08	; 8
    2c80:	09 f4       	brne	.+2      	; 0x2c84 <protocol_exec_rt_system+0x116>
    2c82:	2f c1       	rjmp	.+606    	; 0x2ee2 <protocol_exec_rt_system+0x374>
    2c84:	08 f0       	brcs	.+2      	; 0x2c88 <protocol_exec_rt_system+0x11a>
    2c86:	0a c1       	rjmp	.+532    	; 0x2e9c <protocol_exec_rt_system+0x32e>
    2c88:	81 30       	cpi	r24, 0x01	; 1
    2c8a:	09 f4       	brne	.+2      	; 0x2c8e <protocol_exec_rt_system+0x120>
    2c8c:	33 c1       	rjmp	.+614    	; 0x2ef4 <protocol_exec_rt_system+0x386>
    2c8e:	08 f4       	brcc	.+2      	; 0x2c92 <protocol_exec_rt_system+0x124>
    2c90:	23 c1       	rjmp	.+582    	; 0x2ed8 <protocol_exec_rt_system+0x36a>
    2c92:	82 30       	cpi	r24, 0x02	; 2
    2c94:	09 f4       	brne	.+2      	; 0x2c98 <protocol_exec_rt_system+0x12a>
    2c96:	31 c1       	rjmp	.+610    	; 0x2efa <protocol_exec_rt_system+0x38c>
    2c98:	84 30       	cpi	r24, 0x04	; 4
    2c9a:	09 f4       	brne	.+2      	; 0x2c9e <protocol_exec_rt_system+0x130>
    2c9c:	28 c1       	rjmp	.+592    	; 0x2eee <protocol_exec_rt_system+0x380>
    2c9e:	80 91 76 06 	lds	r24, 0x0676	; 0x800676 <settings+0x34>
    2ca2:	f8 2f       	mov	r31, r24
    2ca4:	f1 70       	andi	r31, 0x01	; 1
    2ca6:	9f 2e       	mov	r9, r31
    2ca8:	80 ff       	sbrs	r24, 0
    2caa:	3c c1       	rjmp	.+632    	; 0x2f24 <protocol_exec_rt_system+0x3b6>
    2cac:	80 91 3d 06 	lds	r24, 0x063D	; 0x80063d <sys+0xc>
    2cb0:	88 23       	and	r24, r24
    2cb2:	09 f4       	brne	.+2      	; 0x2cb6 <protocol_exec_rt_system+0x148>
    2cb4:	37 c1       	rjmp	.+622    	; 0x2f24 <protocol_exec_rt_system+0x3b6>
    2cb6:	82 e9       	ldi	r24, 0x92	; 146
    2cb8:	91 e0       	ldi	r25, 0x01	; 1
    2cba:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2cbe:	ce 01       	movw	r24, r28
    2cc0:	0d 96       	adiw	r24, 0x0d	; 13
    2cc2:	0e 94 89 07 	call	0xf12	; 0xf12 <report_util_axis_values>
    2cc6:	80 91 76 06 	lds	r24, 0x0676	; 0x800676 <settings+0x34>
    2cca:	81 ff       	sbrs	r24, 1
    2ccc:	1d c0       	rjmp	.+58     	; 0x2d08 <protocol_exec_rt_system+0x19a>
    2cce:	86 e8       	ldi	r24, 0x86	; 134
    2cd0:	91 e0       	ldi	r25, 0x01	; 1
    2cd2:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2cd6:	90 91 f6 05 	lds	r25, 0x05F6	; 0x8005f6 <block_buffer_head>
    2cda:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    2cde:	98 17       	cp	r25, r24
    2ce0:	08 f4       	brcc	.+2      	; 0x2ce4 <protocol_exec_rt_system+0x176>
    2ce2:	6f c1       	rjmp	.+734    	; 0x2fc2 <protocol_exec_rt_system+0x454>
    2ce4:	81 5f       	subi	r24, 0xF1	; 241
    2ce6:	89 1b       	sub	r24, r25
    2ce8:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    2cec:	8c e2       	ldi	r24, 0x2C	; 44
    2cee:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2cf2:	80 91 f1 01 	lds	r24, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    2cf6:	90 91 f0 01 	lds	r25, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    2cfa:	98 17       	cp	r25, r24
    2cfc:	08 f4       	brcc	.+2      	; 0x2d00 <protocol_exec_rt_system+0x192>
    2cfe:	63 c1       	rjmp	.+710    	; 0x2fc6 <protocol_exec_rt_system+0x458>
    2d00:	80 58       	subi	r24, 0x80	; 128
    2d02:	89 1b       	sub	r24, r25
    2d04:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    2d08:	81 e8       	ldi	r24, 0x81	; 129
    2d0a:	91 e0       	ldi	r25, 0x01	; 1
    2d0c:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2d10:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2d14:	8c 77       	andi	r24, 0x7C	; 124
    2d16:	09 f4       	brne	.+2      	; 0x2d1a <protocol_exec_rt_system+0x1ac>
    2d18:	58 c1       	rjmp	.+688    	; 0x2fca <protocol_exec_rt_system+0x45c>
    2d1a:	60 91 b8 02 	lds	r22, 0x02B8	; 0x8002b8 <prep+0x17>
    2d1e:	70 91 b9 02 	lds	r23, 0x02B9	; 0x8002b9 <prep+0x18>
    2d22:	80 91 ba 02 	lds	r24, 0x02BA	; 0x8002ba <prep+0x19>
    2d26:	90 91 bb 02 	lds	r25, 0x02BB	; 0x8002bb <prep+0x1a>
    2d2a:	0e 94 6d 07 	call	0xeda	; 0xeda <printFloat_RateValue>
    2d2e:	8c e2       	ldi	r24, 0x2C	; 44
    2d30:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2d34:	60 91 3e 06 	lds	r22, 0x063E	; 0x80063e <sys+0xd>
    2d38:	70 91 3f 06 	lds	r23, 0x063F	; 0x80063f <sys+0xe>
    2d3c:	80 91 40 06 	lds	r24, 0x0640	; 0x800640 <sys+0xf>
    2d40:	90 91 41 06 	lds	r25, 0x0641	; 0x800641 <sys+0x10>
    2d44:	40 e0       	ldi	r20, 0x00	; 0
    2d46:	0e 94 c3 06 	call	0xd86	; 0xd86 <printFloat>
    2d4a:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    2d4e:	e8 2e       	mov	r14, r24
    2d50:	0e 94 cb 02 	call	0x596	; 0x596 <system_control_get_state>
    2d54:	f8 2e       	mov	r15, r24
    2d56:	06 b1       	in	r16, 0x06	; 6
    2d58:	00 72       	andi	r16, 0x20	; 32
    2d5a:	80 91 17 06 	lds	r24, 0x0617	; 0x800617 <probe_invert_mask>
    2d5e:	08 27       	eor	r16, r24
    2d60:	8e 2d       	mov	r24, r14
    2d62:	8f 29       	or	r24, r15
    2d64:	80 2b       	or	r24, r16
    2d66:	59 f1       	breq	.+86     	; 0x2dbe <protocol_exec_rt_system+0x250>
    2d68:	8c e7       	ldi	r24, 0x7C	; 124
    2d6a:	91 e0       	ldi	r25, 0x01	; 1
    2d6c:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2d70:	00 23       	and	r16, r16
    2d72:	19 f0       	breq	.+6      	; 0x2d7a <protocol_exec_rt_system+0x20c>
    2d74:	80 e5       	ldi	r24, 0x50	; 80
    2d76:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2d7a:	ee 20       	and	r14, r14
    2d7c:	79 f0       	breq	.+30     	; 0x2d9c <protocol_exec_rt_system+0x22e>
    2d7e:	e0 fe       	sbrs	r14, 0
    2d80:	03 c0       	rjmp	.+6      	; 0x2d88 <protocol_exec_rt_system+0x21a>
    2d82:	88 e5       	ldi	r24, 0x58	; 88
    2d84:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2d88:	e1 fe       	sbrs	r14, 1
    2d8a:	03 c0       	rjmp	.+6      	; 0x2d92 <protocol_exec_rt_system+0x224>
    2d8c:	89 e5       	ldi	r24, 0x59	; 89
    2d8e:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2d92:	e2 fe       	sbrs	r14, 2
    2d94:	03 c0       	rjmp	.+6      	; 0x2d9c <protocol_exec_rt_system+0x22e>
    2d96:	8a e5       	ldi	r24, 0x5A	; 90
    2d98:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2d9c:	ff 20       	and	r15, r15
    2d9e:	79 f0       	breq	.+30     	; 0x2dbe <protocol_exec_rt_system+0x250>
    2da0:	f0 fe       	sbrs	r15, 0
    2da2:	03 c0       	rjmp	.+6      	; 0x2daa <protocol_exec_rt_system+0x23c>
    2da4:	82 e5       	ldi	r24, 0x52	; 82
    2da6:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2daa:	f1 fe       	sbrs	r15, 1
    2dac:	03 c0       	rjmp	.+6      	; 0x2db4 <protocol_exec_rt_system+0x246>
    2dae:	88 e4       	ldi	r24, 0x48	; 72
    2db0:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2db4:	f2 fe       	sbrs	r15, 2
    2db6:	03 c0       	rjmp	.+6      	; 0x2dbe <protocol_exec_rt_system+0x250>
    2db8:	83 e5       	ldi	r24, 0x53	; 83
    2dba:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2dbe:	80 91 3d 06 	lds	r24, 0x063D	; 0x80063d <sys+0xc>
    2dc2:	88 23       	and	r24, r24
    2dc4:	09 f4       	brne	.+2      	; 0x2dc8 <protocol_exec_rt_system+0x25a>
    2dc6:	05 c1       	rjmp	.+522    	; 0x2fd2 <protocol_exec_rt_system+0x464>
    2dc8:	81 50       	subi	r24, 0x01	; 1
    2dca:	80 93 3d 06 	sts	0x063D, r24	; 0x80063d <sys+0xc>
    2dce:	00 91 3c 06 	lds	r16, 0x063C	; 0x80063c <sys+0xb>
    2dd2:	00 23       	and	r16, r16
    2dd4:	09 f4       	brne	.+2      	; 0x2dd8 <protocol_exec_rt_system+0x26a>
    2dd6:	16 c1       	rjmp	.+556    	; 0x3004 <protocol_exec_rt_system+0x496>
    2dd8:	01 50       	subi	r16, 0x01	; 1
    2dda:	00 93 3c 06 	sts	0x063C, r16	; 0x80063c <sys+0xb>
    2dde:	8e e3       	ldi	r24, 0x3E	; 62
    2de0:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2de4:	0e 94 d5 07 	call	0xfaa	; 0xfaa <report_util_line_feed>
    2de8:	81 e0       	ldi	r24, 0x01	; 1
    2dea:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    2dee:	81 2f       	mov	r24, r17
    2df0:	88 7e       	andi	r24, 0xE8	; 232
    2df2:	09 f4       	brne	.+2      	; 0x2df6 <protocol_exec_rt_system+0x288>
    2df4:	61 c1       	rjmp	.+706    	; 0x30b8 <protocol_exec_rt_system+0x54a>
    2df6:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2dfa:	98 2f       	mov	r25, r24
    2dfc:	93 70       	andi	r25, 0x03	; 3
    2dfe:	09 f0       	breq	.+2      	; 0x2e02 <protocol_exec_rt_system+0x294>
    2e00:	4a c1       	rjmp	.+660    	; 0x3096 <protocol_exec_rt_system+0x528>
    2e02:	88 72       	andi	r24, 0x28	; 40
    2e04:	a9 f0       	breq	.+42     	; 0x2e30 <protocol_exec_rt_system+0x2c2>
    2e06:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e0a:	80 7c       	andi	r24, 0xC0	; 192
    2e0c:	89 f4       	brne	.+34     	; 0x2e30 <protocol_exec_rt_system+0x2c2>
    2e0e:	0e 94 cd 04 	call	0x99a	; 0x99a <st_update_plan_block_parameters>
    2e12:	82 e0       	ldi	r24, 0x02	; 2
    2e14:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    2e18:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2e1c:	80 32       	cpi	r24, 0x20	; 32
    2e1e:	41 f4       	brne	.+16     	; 0x2e30 <protocol_exec_rt_system+0x2c2>
    2e20:	80 e2       	ldi	r24, 0x20	; 32
    2e22:	17 fd       	sbrc	r17, 7
    2e24:	0c c0       	rjmp	.+24     	; 0x2e3e <protocol_exec_rt_system+0x2d0>
    2e26:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e2a:	80 68       	ori	r24, 0x80	; 128
    2e2c:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    2e30:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2e34:	81 11       	cpse	r24, r1
    2e36:	03 c0       	rjmp	.+6      	; 0x2e3e <protocol_exec_rt_system+0x2d0>
    2e38:	91 e0       	ldi	r25, 0x01	; 1
    2e3a:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    2e3e:	16 ff       	sbrs	r17, 6
    2e40:	07 c0       	rjmp	.+14     	; 0x2e50 <protocol_exec_rt_system+0x2e2>
    2e42:	85 fd       	sbrc	r24, 5
    2e44:	05 c0       	rjmp	.+10     	; 0x2e50 <protocol_exec_rt_system+0x2e2>
    2e46:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    2e4a:	90 64       	ori	r25, 0x40	; 64
    2e4c:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    2e50:	13 ff       	sbrs	r17, 3
    2e52:	05 c0       	rjmp	.+10     	; 0x2e5e <protocol_exec_rt_system+0x2f0>
    2e54:	80 7e       	andi	r24, 0xE0	; 224
    2e56:	19 f4       	brne	.+6      	; 0x2e5e <protocol_exec_rt_system+0x2f0>
    2e58:	80 e1       	ldi	r24, 0x10	; 16
    2e5a:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2e5e:	15 ff       	sbrs	r17, 5
    2e60:	1a c1       	rjmp	.+564    	; 0x3096 <protocol_exec_rt_system+0x528>
    2e62:	8a ec       	ldi	r24, 0xCA	; 202
    2e64:	92 e0       	ldi	r25, 0x02	; 2
    2e66:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2e6a:	86 e7       	ldi	r24, 0x76	; 118
    2e6c:	92 e0       	ldi	r25, 0x02	; 2
    2e6e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2e72:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    2e76:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2e7a:	87 fd       	sbrc	r24, 7
    2e7c:	07 c1       	rjmp	.+526    	; 0x308c <protocol_exec_rt_system+0x51e>
    2e7e:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    2e82:	90 34       	cpi	r25, 0x40	; 64
    2e84:	09 f0       	breq	.+2      	; 0x2e88 <protocol_exec_rt_system+0x31a>
    2e86:	ff c0       	rjmp	.+510    	; 0x3086 <protocol_exec_rt_system+0x518>
    2e88:	83 ff       	sbrs	r24, 3
    2e8a:	04 c0       	rjmp	.+8      	; 0x2e94 <protocol_exec_rt_system+0x326>
    2e8c:	83 7e       	andi	r24, 0xE3	; 227
    2e8e:	82 60       	ori	r24, 0x02	; 2
    2e90:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    2e94:	80 e4       	ldi	r24, 0x40	; 64
    2e96:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    2e9a:	f8 c0       	rjmp	.+496    	; 0x308c <protocol_exec_rt_system+0x51e>
    2e9c:	80 32       	cpi	r24, 0x20	; 32
    2e9e:	21 f1       	breq	.+72     	; 0x2ee8 <protocol_exec_rt_system+0x37a>
    2ea0:	98 f4       	brcc	.+38     	; 0x2ec8 <protocol_exec_rt_system+0x35a>
    2ea2:	80 31       	cpi	r24, 0x10	; 16
    2ea4:	09 f0       	breq	.+2      	; 0x2ea8 <protocol_exec_rt_system+0x33a>
    2ea6:	fb ce       	rjmp	.-522    	; 0x2c9e <protocol_exec_rt_system+0x130>
    2ea8:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2eac:	87 fd       	sbrc	r24, 7
    2eae:	1c c0       	rjmp	.+56     	; 0x2ee8 <protocol_exec_rt_system+0x37a>
    2eb0:	8a eb       	ldi	r24, 0xBA	; 186
    2eb2:	91 e0       	ldi	r25, 0x01	; 1
    2eb4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2eb8:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2ebc:	80 ff       	sbrs	r24, 0
    2ebe:	2e c0       	rjmp	.+92     	; 0x2f1c <protocol_exec_rt_system+0x3ae>
    2ec0:	80 e3       	ldi	r24, 0x30	; 48
    2ec2:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    2ec6:	eb ce       	rjmp	.-554    	; 0x2c9e <protocol_exec_rt_system+0x130>
    2ec8:	80 34       	cpi	r24, 0x40	; 64
    2eca:	d1 f0       	breq	.+52     	; 0x2f00 <protocol_exec_rt_system+0x392>
    2ecc:	80 38       	cpi	r24, 0x80	; 128
    2ece:	09 f0       	breq	.+2      	; 0x2ed2 <protocol_exec_rt_system+0x364>
    2ed0:	e6 ce       	rjmp	.-564    	; 0x2c9e <protocol_exec_rt_system+0x130>
    2ed2:	89 e9       	ldi	r24, 0x99	; 153
    2ed4:	91 e0       	ldi	r25, 0x01	; 1
    2ed6:	02 c0       	rjmp	.+4      	; 0x2edc <protocol_exec_rt_system+0x36e>
    2ed8:	84 ec       	ldi	r24, 0xC4	; 196
    2eda:	91 e0       	ldi	r25, 0x01	; 1
    2edc:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2ee0:	de ce       	rjmp	.-580    	; 0x2c9e <protocol_exec_rt_system+0x130>
    2ee2:	80 ec       	ldi	r24, 0xC0	; 192
    2ee4:	91 e0       	ldi	r25, 0x01	; 1
    2ee6:	fa cf       	rjmp	.-12     	; 0x2edc <protocol_exec_rt_system+0x36e>
    2ee8:	86 eb       	ldi	r24, 0xB6	; 182
    2eea:	91 e0       	ldi	r25, 0x01	; 1
    2eec:	f7 cf       	rjmp	.-18     	; 0x2edc <protocol_exec_rt_system+0x36e>
    2eee:	81 eb       	ldi	r24, 0xB1	; 177
    2ef0:	91 e0       	ldi	r25, 0x01	; 1
    2ef2:	f4 cf       	rjmp	.-24     	; 0x2edc <protocol_exec_rt_system+0x36e>
    2ef4:	8b ea       	ldi	r24, 0xAB	; 171
    2ef6:	91 e0       	ldi	r25, 0x01	; 1
    2ef8:	f1 cf       	rjmp	.-30     	; 0x2edc <protocol_exec_rt_system+0x36e>
    2efa:	85 ea       	ldi	r24, 0xA5	; 165
    2efc:	91 e0       	ldi	r25, 0x01	; 1
    2efe:	ee cf       	rjmp	.-36     	; 0x2edc <protocol_exec_rt_system+0x36e>
    2f00:	8f e9       	ldi	r24, 0x9F	; 159
    2f02:	91 e0       	ldi	r25, 0x01	; 1
    2f04:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2f08:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    2f0c:	83 ff       	sbrs	r24, 3
    2f0e:	02 c0       	rjmp	.+4      	; 0x2f14 <protocol_exec_rt_system+0x3a6>
    2f10:	83 e3       	ldi	r24, 0x33	; 51
    2f12:	d7 cf       	rjmp	.-82     	; 0x2ec2 <protocol_exec_rt_system+0x354>
    2f14:	82 ff       	sbrs	r24, 2
    2f16:	04 c0       	rjmp	.+8      	; 0x2f20 <protocol_exec_rt_system+0x3b2>
    2f18:	85 ff       	sbrs	r24, 5
    2f1a:	d2 cf       	rjmp	.-92     	; 0x2ec0 <protocol_exec_rt_system+0x352>
    2f1c:	81 e3       	ldi	r24, 0x31	; 49
    2f1e:	d1 cf       	rjmp	.-94     	; 0x2ec2 <protocol_exec_rt_system+0x354>
    2f20:	82 e3       	ldi	r24, 0x32	; 50
    2f22:	cf cf       	rjmp	.-98     	; 0x2ec2 <protocol_exec_rt_system+0x354>
    2f24:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    2f28:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    2f2c:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    2f30:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    2f34:	6b eb       	ldi	r22, 0xBB	; 187
    2f36:	a6 2e       	mov	r10, r22
    2f38:	66 e0       	ldi	r22, 0x06	; 6
    2f3a:	b6 2e       	mov	r11, r22
    2f3c:	9e 01       	movw	r18, r28
    2f3e:	2f 5f       	subi	r18, 0xFF	; 255
    2f40:	3f 4f       	sbci	r19, 0xFF	; 255
    2f42:	69 01       	movw	r12, r18
    2f44:	ce 01       	movw	r24, r28
    2f46:	0d 96       	adiw	r24, 0x0d	; 13
    2f48:	7c 01       	movw	r14, r24
    2f4a:	00 e0       	ldi	r16, 0x00	; 0
    2f4c:	f5 01       	movw	r30, r10
    2f4e:	61 91       	ld	r22, Z+
    2f50:	71 91       	ld	r23, Z+
    2f52:	81 91       	ld	r24, Z+
    2f54:	91 91       	ld	r25, Z+
    2f56:	5f 01       	movw	r10, r30
    2f58:	20 85       	ldd	r18, Z+8	; 0x08
    2f5a:	31 85       	ldd	r19, Z+9	; 0x09
    2f5c:	42 85       	ldd	r20, Z+10	; 0x0a
    2f5e:	53 85       	ldd	r21, Z+11	; 0x0b
    2f60:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2f64:	f6 01       	movw	r30, r12
    2f66:	61 93       	st	Z+, r22
    2f68:	71 93       	st	Z+, r23
    2f6a:	81 93       	st	Z+, r24
    2f6c:	91 93       	st	Z+, r25
    2f6e:	6f 01       	movw	r12, r30
    2f70:	02 30       	cpi	r16, 0x02	; 2
    2f72:	41 f4       	brne	.+16     	; 0x2f84 <protocol_exec_rt_system+0x416>
    2f74:	a3 01       	movw	r20, r6
    2f76:	92 01       	movw	r18, r4
    2f78:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    2f7c:	69 87       	std	Y+9, r22	; 0x09
    2f7e:	7a 87       	std	Y+10, r23	; 0x0a
    2f80:	8b 87       	std	Y+11, r24	; 0x0b
    2f82:	9c 87       	std	Y+12, r25	; 0x0c
    2f84:	91 10       	cpse	r9, r1
    2f86:	12 c0       	rjmp	.+36     	; 0x2fac <protocol_exec_rt_system+0x43e>
    2f88:	f6 01       	movw	r30, r12
    2f8a:	34 97       	sbiw	r30, 0x04	; 4
    2f8c:	20 81       	ld	r18, Z
    2f8e:	31 81       	ldd	r19, Z+1	; 0x01
    2f90:	42 81       	ldd	r20, Z+2	; 0x02
    2f92:	53 81       	ldd	r21, Z+3	; 0x03
    2f94:	f7 01       	movw	r30, r14
    2f96:	60 81       	ld	r22, Z
    2f98:	71 81       	ldd	r23, Z+1	; 0x01
    2f9a:	82 81       	ldd	r24, Z+2	; 0x02
    2f9c:	93 81       	ldd	r25, Z+3	; 0x03
    2f9e:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    2fa2:	f7 01       	movw	r30, r14
    2fa4:	60 83       	st	Z, r22
    2fa6:	71 83       	std	Z+1, r23	; 0x01
    2fa8:	82 83       	std	Z+2, r24	; 0x02
    2faa:	93 83       	std	Z+3, r25	; 0x03
    2fac:	0f 5f       	subi	r16, 0xFF	; 255
    2fae:	f4 e0       	ldi	r31, 0x04	; 4
    2fb0:	ef 0e       	add	r14, r31
    2fb2:	f1 1c       	adc	r15, r1
    2fb4:	03 30       	cpi	r16, 0x03	; 3
    2fb6:	51 f6       	brne	.-108    	; 0x2f4c <protocol_exec_rt_system+0x3de>
    2fb8:	91 10       	cpse	r9, r1
    2fba:	7d ce       	rjmp	.-774    	; 0x2cb6 <protocol_exec_rt_system+0x148>
    2fbc:	8b e8       	ldi	r24, 0x8B	; 139
    2fbe:	91 e0       	ldi	r25, 0x01	; 1
    2fc0:	7c ce       	rjmp	.-776    	; 0x2cba <protocol_exec_rt_system+0x14c>
    2fc2:	81 50       	subi	r24, 0x01	; 1
    2fc4:	90 ce       	rjmp	.-736    	; 0x2ce6 <protocol_exec_rt_system+0x178>
    2fc6:	81 50       	subi	r24, 0x01	; 1
    2fc8:	9c ce       	rjmp	.-712    	; 0x2d02 <protocol_exec_rt_system+0x194>
    2fca:	60 e0       	ldi	r22, 0x00	; 0
    2fcc:	70 e0       	ldi	r23, 0x00	; 0
    2fce:	cb 01       	movw	r24, r22
    2fd0:	ac ce       	rjmp	.-680    	; 0x2d2a <protocol_exec_rt_system+0x1bc>
    2fd2:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    2fd6:	8c 77       	andi	r24, 0x7C	; 124
    2fd8:	99 f0       	breq	.+38     	; 0x3000 <protocol_exec_rt_system+0x492>
    2fda:	8d e1       	ldi	r24, 0x1D	; 29
    2fdc:	80 93 3d 06 	sts	0x063D, r24	; 0x80063d <sys+0xc>
    2fe0:	80 91 3c 06 	lds	r24, 0x063C	; 0x80063c <sys+0xb>
    2fe4:	81 11       	cpse	r24, r1
    2fe6:	03 c0       	rjmp	.+6      	; 0x2fee <protocol_exec_rt_system+0x480>
    2fe8:	81 e0       	ldi	r24, 0x01	; 1
    2fea:	80 93 3c 06 	sts	0x063C, r24	; 0x80063c <sys+0xb>
    2fee:	86 e7       	ldi	r24, 0x76	; 118
    2ff0:	91 e0       	ldi	r25, 0x01	; 1
    2ff2:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    2ff6:	ce 01       	movw	r24, r28
    2ff8:	01 96       	adiw	r24, 0x01	; 1
    2ffa:	0e 94 89 07 	call	0xf12	; 0xf12 <report_util_axis_values>
    2ffe:	e7 ce       	rjmp	.-562    	; 0x2dce <protocol_exec_rt_system+0x260>
    3000:	89 e0       	ldi	r24, 0x09	; 9
    3002:	ec cf       	rjmp	.-40     	; 0x2fdc <protocol_exec_rt_system+0x46e>
    3004:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3008:	8c 77       	andi	r24, 0x7C	; 124
    300a:	c1 f1       	breq	.+112    	; 0x307c <protocol_exec_rt_system+0x50e>
    300c:	83 e1       	ldi	r24, 0x13	; 19
    300e:	80 93 3c 06 	sts	0x063C, r24	; 0x80063c <sys+0xb>
    3012:	81 e7       	ldi	r24, 0x71	; 113
    3014:	91 e0       	ldi	r25, 0x01	; 1
    3016:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    301a:	80 91 38 06 	lds	r24, 0x0638	; 0x800638 <sys+0x7>
    301e:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    3022:	8c e2       	ldi	r24, 0x2C	; 44
    3024:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    3028:	80 91 39 06 	lds	r24, 0x0639	; 0x800639 <sys+0x8>
    302c:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    3030:	8c e2       	ldi	r24, 0x2C	; 44
    3032:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    3036:	80 91 3a 06 	lds	r24, 0x063A	; 0x80063a <sys+0x9>
    303a:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    303e:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    3042:	f1 2c       	mov	r15, r1
    3044:	87 ff       	sbrs	r24, 7
    3046:	04 c0       	rjmp	.+8      	; 0x3050 <protocol_exec_rt_system+0x4e2>
    3048:	2d 9b       	sbis	0x05, 5	; 5
    304a:	1a c0       	rjmp	.+52     	; 0x3080 <protocol_exec_rt_system+0x512>
    304c:	52 e0       	ldi	r21, 0x02	; 2
    304e:	f5 2e       	mov	r15, r21
    3050:	43 9b       	sbis	0x08, 3	; 8
    3052:	cd c1       	rjmp	.+922    	; 0x33ee <protocol_exec_rt_system+0x880>
    3054:	00 e4       	ldi	r16, 0x40	; 64
    3056:	8d e6       	ldi	r24, 0x6D	; 109
    3058:	91 e0       	ldi	r25, 0x01	; 1
    305a:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    305e:	ff 20       	and	r15, r15
    3060:	31 f0       	breq	.+12     	; 0x306e <protocol_exec_rt_system+0x500>
    3062:	21 e0       	ldi	r18, 0x01	; 1
    3064:	83 e5       	ldi	r24, 0x53	; 83
    3066:	f2 12       	cpse	r15, r18
    3068:	83 e4       	ldi	r24, 0x43	; 67
    306a:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    306e:	00 23       	and	r16, r16
    3070:	09 f4       	brne	.+2      	; 0x3074 <protocol_exec_rt_system+0x506>
    3072:	b5 ce       	rjmp	.-662    	; 0x2dde <protocol_exec_rt_system+0x270>
    3074:	86 e4       	ldi	r24, 0x46	; 70
    3076:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    307a:	b1 ce       	rjmp	.-670    	; 0x2dde <protocol_exec_rt_system+0x270>
    307c:	89 e0       	ldi	r24, 0x09	; 9
    307e:	c7 cf       	rjmp	.-114    	; 0x300e <protocol_exec_rt_system+0x4a0>
    3080:	ff 24       	eor	r15, r15
    3082:	f3 94       	inc	r15
    3084:	e5 cf       	rjmp	.-54     	; 0x3050 <protocol_exec_rt_system+0x4e2>
    3086:	90 38       	cpi	r25, 0x80	; 128
    3088:	09 f0       	breq	.+2      	; 0x308c <protocol_exec_rt_system+0x51e>
    308a:	04 cf       	rjmp	.-504    	; 0x2e94 <protocol_exec_rt_system+0x326>
    308c:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3090:	80 62       	ori	r24, 0x20	; 32
    3092:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3096:	17 ff       	sbrs	r17, 7
    3098:	0c c0       	rjmp	.+24     	; 0x30b2 <protocol_exec_rt_system+0x544>
    309a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    309e:	81 30       	cpi	r24, 0x01	; 1
    30a0:	29 f4       	brne	.+10     	; 0x30ac <protocol_exec_rt_system+0x53e>
    30a2:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    30a6:	85 60       	ori	r24, 0x05	; 5
    30a8:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    30ac:	80 e8       	ldi	r24, 0x80	; 128
    30ae:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    30b2:	88 ee       	ldi	r24, 0xE8	; 232
    30b4:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    30b8:	11 ff       	sbrs	r17, 1
    30ba:	28 c0       	rjmp	.+80     	; 0x310c <protocol_exec_rt_system+0x59e>
    30bc:	81 2f       	mov	r24, r17
    30be:	88 76       	andi	r24, 0x68	; 104
    30c0:	11 f5       	brne	.+68     	; 0x3106 <protocol_exec_rt_system+0x598>
    30c2:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    30c6:	80 34       	cpi	r24, 0x40	; 64
    30c8:	41 f4       	brne	.+16     	; 0x30da <protocol_exec_rt_system+0x56c>
    30ca:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    30ce:	85 fd       	sbrc	r24, 5
    30d0:	04 c0       	rjmp	.+8      	; 0x30da <protocol_exec_rt_system+0x56c>
    30d2:	84 ff       	sbrs	r24, 4
    30d4:	ea c0       	rjmp	.+468    	; 0x32aa <protocol_exec_rt_system+0x73c>
    30d6:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    30da:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    30de:	88 23       	and	r24, r24
    30e0:	09 f4       	brne	.+2      	; 0x30e4 <protocol_exec_rt_system+0x576>
    30e2:	e9 c0       	rjmp	.+466    	; 0x32b6 <protocol_exec_rt_system+0x748>
    30e4:	84 ff       	sbrs	r24, 4
    30e6:	0f c0       	rjmp	.+30     	; 0x3106 <protocol_exec_rt_system+0x598>
    30e8:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    30ec:	90 ff       	sbrs	r25, 0
    30ee:	0b c0       	rjmp	.+22     	; 0x3106 <protocol_exec_rt_system+0x598>
    30f0:	80 31       	cpi	r24, 0x10	; 16
    30f2:	09 f0       	breq	.+2      	; 0x30f6 <protocol_exec_rt_system+0x588>
    30f4:	e0 c0       	rjmp	.+448    	; 0x32b6 <protocol_exec_rt_system+0x748>
    30f6:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    30fa:	88 23       	and	r24, r24
    30fc:	09 f4       	brne	.+2      	; 0x3100 <protocol_exec_rt_system+0x592>
    30fe:	db c0       	rjmp	.+438    	; 0x32b6 <protocol_exec_rt_system+0x748>
    3100:	88 60       	ori	r24, 0x08	; 8
    3102:	80 93 3b 06 	sts	0x063B, r24	; 0x80063b <sys+0xa>
    3106:	82 e0       	ldi	r24, 0x02	; 2
    3108:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    310c:	12 ff       	sbrs	r17, 2
    310e:	24 c0       	rjmp	.+72     	; 0x3158 <protocol_exec_rt_system+0x5ea>
    3110:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    3114:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3118:	80 7d       	andi	r24, 0xD0	; 208
    311a:	09 f4       	brne	.+2      	; 0x311e <protocol_exec_rt_system+0x5b0>
    311c:	e5 c0       	rjmp	.+458    	; 0x32e8 <protocol_exec_rt_system+0x77a>
    311e:	80 91 34 06 	lds	r24, 0x0634	; 0x800634 <sys+0x3>
    3122:	81 11       	cpse	r24, r1
    3124:	e1 c0       	rjmp	.+450    	; 0x32e8 <protocol_exec_rt_system+0x77a>
    3126:	97 fd       	sbrc	r25, 7
    3128:	e1 c0       	rjmp	.+450    	; 0x32ec <protocol_exec_rt_system+0x77e>
    312a:	0e 94 cd 04 	call	0x99a	; 0x99a <st_update_plan_block_parameters>
    312e:	80 91 d5 02 	lds	r24, 0x02D5	; 0x8002d5 <block_buffer_tail>
    3132:	80 93 d3 02 	sts	0x02D3, r24	; 0x8002d3 <block_buffer_planned>
    3136:	0e 94 f1 04 	call	0x9e2	; 0x9e2 <planner_recalculate>
    313a:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    313e:	81 ff       	sbrs	r24, 1
    3140:	05 c0       	rjmp	.+10     	; 0x314c <protocol_exec_rt_system+0x5de>
    3142:	90 91 33 06 	lds	r25, 0x0633	; 0x800633 <sys+0x2>
    3146:	91 60       	ori	r25, 0x01	; 1
    3148:	90 93 33 06 	sts	0x0633, r25	; 0x800633 <sys+0x2>
    314c:	89 7f       	andi	r24, 0xF9	; 249
    314e:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    3152:	84 e0       	ldi	r24, 0x04	; 4
    3154:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    3158:	90 91 15 06 	lds	r25, 0x0615	; 0x800615 <sys_rt_exec_motion_override>
    315c:	99 23       	and	r25, r25
    315e:	09 f4       	brne	.+2      	; 0x3162 <protocol_exec_rt_system+0x5f4>
    3160:	4c c0       	rjmp	.+152    	; 0x31fa <protocol_exec_rt_system+0x68c>
    3162:	8f b7       	in	r24, 0x3f	; 63
    3164:	f8 94       	cli
    3166:	10 92 15 06 	sts	0x0615, r1	; 0x800615 <sys_rt_exec_motion_override>
    316a:	8f bf       	out	0x3f, r24	; 63
    316c:	40 91 38 06 	lds	r20, 0x0638	; 0x800638 <sys+0x7>
    3170:	84 2f       	mov	r24, r20
    3172:	90 fd       	sbrc	r25, 0
    3174:	84 e6       	ldi	r24, 0x64	; 100
    3176:	91 fd       	sbrc	r25, 1
    3178:	86 5f       	subi	r24, 0xF6	; 246
    317a:	92 fd       	sbrc	r25, 2
    317c:	8a 50       	subi	r24, 0x0A	; 10
    317e:	93 fd       	sbrc	r25, 3
    3180:	8f 5f       	subi	r24, 0xFF	; 255
    3182:	94 fd       	sbrc	r25, 4
    3184:	81 50       	subi	r24, 0x01	; 1
    3186:	89 3c       	cpi	r24, 0xC9	; 201
    3188:	08 f0       	brcs	.+2      	; 0x318c <protocol_exec_rt_system+0x61e>
    318a:	88 ec       	ldi	r24, 0xC8	; 200
    318c:	8a 30       	cpi	r24, 0x0A	; 10
    318e:	08 f4       	brcc	.+2      	; 0x3192 <protocol_exec_rt_system+0x624>
    3190:	8a e0       	ldi	r24, 0x0A	; 10
    3192:	30 91 39 06 	lds	r19, 0x0639	; 0x800639 <sys+0x8>
    3196:	23 2f       	mov	r18, r19
    3198:	95 fd       	sbrc	r25, 5
    319a:	24 e6       	ldi	r18, 0x64	; 100
    319c:	96 fd       	sbrc	r25, 6
    319e:	22 e3       	ldi	r18, 0x32	; 50
    31a0:	97 fd       	sbrc	r25, 7
    31a2:	29 e1       	ldi	r18, 0x19	; 25
    31a4:	48 13       	cpse	r20, r24
    31a6:	02 c0       	rjmp	.+4      	; 0x31ac <protocol_exec_rt_system+0x63e>
    31a8:	23 17       	cp	r18, r19
    31aa:	39 f1       	breq	.+78     	; 0x31fa <protocol_exec_rt_system+0x68c>
    31ac:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    31b0:	20 93 39 06 	sts	0x0639, r18	; 0x800639 <sys+0x8>
    31b4:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    31b8:	70 90 d5 02 	lds	r7, 0x02D5	; 0x8002d5 <block_buffer_tail>
    31bc:	60 90 f6 05 	lds	r6, 0x05F6	; 0x8005f6 <block_buffer_head>
    31c0:	17 2d       	mov	r17, r7
    31c2:	89 e9       	ldi	r24, 0x99	; 153
    31c4:	28 2e       	mov	r2, r24
    31c6:	96 e7       	ldi	r25, 0x76	; 118
    31c8:	39 2e       	mov	r3, r25
    31ca:	26 e9       	ldi	r18, 0x96	; 150
    31cc:	42 2e       	mov	r4, r18
    31ce:	3e e7       	ldi	r19, 0x7E	; 126
    31d0:	53 2e       	mov	r5, r19
    31d2:	42 e3       	ldi	r20, 0x32	; 50
    31d4:	84 2e       	mov	r8, r20
    31d6:	16 11       	cpse	r17, r6
    31d8:	a4 c0       	rjmp	.+328    	; 0x3322 <protocol_exec_rt_system+0x7b4>
    31da:	c1 01       	movw	r24, r2
    31dc:	d2 01       	movw	r26, r4
    31de:	80 93 0f 06 	sts	0x060F, r24	; 0x80060f <pl+0x18>
    31e2:	90 93 10 06 	sts	0x0610, r25	; 0x800610 <pl+0x19>
    31e6:	a0 93 11 06 	sts	0x0611, r26	; 0x800611 <pl+0x1a>
    31ea:	b0 93 12 06 	sts	0x0612, r27	; 0x800612 <pl+0x1b>
    31ee:	0e 94 cd 04 	call	0x99a	; 0x99a <st_update_plan_block_parameters>
    31f2:	70 92 d3 02 	sts	0x02D3, r7	; 0x8002d3 <block_buffer_planned>
    31f6:	0e 94 f1 04 	call	0x9e2	; 0x9e2 <planner_recalculate>
    31fa:	10 91 16 06 	lds	r17, 0x0616	; 0x800616 <sys_rt_exec_accessory_override>
    31fe:	11 23       	and	r17, r17
    3200:	09 f4       	brne	.+2      	; 0x3204 <protocol_exec_rt_system+0x696>
    3202:	4b c0       	rjmp	.+150    	; 0x329a <protocol_exec_rt_system+0x72c>
    3204:	8f b7       	in	r24, 0x3f	; 63
    3206:	f8 94       	cli
    3208:	10 92 16 06 	sts	0x0616, r1	; 0x800616 <sys_rt_exec_accessory_override>
    320c:	8f bf       	out	0x3f, r24	; 63
    320e:	90 91 3a 06 	lds	r25, 0x063A	; 0x80063a <sys+0x9>
    3212:	89 2f       	mov	r24, r25
    3214:	10 fd       	sbrc	r17, 0
    3216:	84 e6       	ldi	r24, 0x64	; 100
    3218:	11 fd       	sbrc	r17, 1
    321a:	86 5f       	subi	r24, 0xF6	; 246
    321c:	12 fd       	sbrc	r17, 2
    321e:	8a 50       	subi	r24, 0x0A	; 10
    3220:	13 fd       	sbrc	r17, 3
    3222:	8f 5f       	subi	r24, 0xFF	; 255
    3224:	14 fd       	sbrc	r17, 4
    3226:	81 50       	subi	r24, 0x01	; 1
    3228:	89 3c       	cpi	r24, 0xC9	; 201
    322a:	08 f0       	brcs	.+2      	; 0x322e <protocol_exec_rt_system+0x6c0>
    322c:	88 ec       	ldi	r24, 0xC8	; 200
    322e:	8a 30       	cpi	r24, 0x0A	; 10
    3230:	08 f4       	brcc	.+2      	; 0x3234 <protocol_exec_rt_system+0x6c6>
    3232:	8a e0       	ldi	r24, 0x0A	; 10
    3234:	98 17       	cp	r25, r24
    3236:	a1 f0       	breq	.+40     	; 0x3260 <protocol_exec_rt_system+0x6f2>
    3238:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    323c:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    3240:	91 11       	cpse	r25, r1
    3242:	c9 c0       	rjmp	.+402    	; 0x33d6 <protocol_exec_rt_system+0x868>
    3244:	40 91 a2 06 	lds	r20, 0x06A2	; 0x8006a2 <gc_state+0xb>
    3248:	50 91 a3 06 	lds	r21, 0x06A3	; 0x8006a3 <gc_state+0xc>
    324c:	60 91 a4 06 	lds	r22, 0x06A4	; 0x8006a4 <gc_state+0xd>
    3250:	70 91 a5 06 	lds	r23, 0x06A5	; 0x8006a5 <gc_state+0xe>
    3254:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3258:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    325c:	10 92 3c 06 	sts	0x063C, r1	; 0x80063c <sys+0xb>
    3260:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3264:	15 ff       	sbrs	r17, 5
    3266:	09 c0       	rjmp	.+18     	; 0x327a <protocol_exec_rt_system+0x70c>
    3268:	80 31       	cpi	r24, 0x10	; 16
    326a:	39 f4       	brne	.+14     	; 0x327a <protocol_exec_rt_system+0x70c>
    326c:	90 91 3b 06 	lds	r25, 0x063B	; 0x80063b <sys+0xa>
    3270:	91 11       	cpse	r25, r1
    3272:	b7 c0       	rjmp	.+366    	; 0x33e2 <protocol_exec_rt_system+0x874>
    3274:	92 e0       	ldi	r25, 0x02	; 2
    3276:	90 93 3b 06 	sts	0x063B, r25	; 0x80063b <sys+0xa>
    327a:	10 7c       	andi	r17, 0xC0	; 192
    327c:	71 f0       	breq	.+28     	; 0x329a <protocol_exec_rt_system+0x72c>
    327e:	88 23       	and	r24, r24
    3280:	11 f0       	breq	.+4      	; 0x3286 <protocol_exec_rt_system+0x718>
    3282:	88 73       	andi	r24, 0x38	; 56
    3284:	51 f0       	breq	.+20     	; 0x329a <protocol_exec_rt_system+0x72c>
    3286:	10 91 9f 06 	lds	r17, 0x069F	; 0x80069f <gc_state+0x8>
    328a:	16 ff       	sbrs	r17, 6
    328c:	ae c0       	rjmp	.+348    	; 0x33ea <protocol_exec_rt_system+0x87c>
    328e:	1f 7b       	andi	r17, 0xBF	; 191
    3290:	81 2f       	mov	r24, r17
    3292:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    3296:	10 93 9f 06 	sts	0x069F, r17	; 0x80069f <gc_state+0x8>
    329a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    329e:	8c 7f       	andi	r24, 0xFC	; 252
    32a0:	09 f4       	brne	.+2      	; 0x32a4 <protocol_exec_rt_system+0x736>
    32a2:	b6 cc       	rjmp	.-1684   	; 0x2c10 <protocol_exec_rt_system+0xa2>
    32a4:	0e 94 32 0e 	call	0x1c64	; 0x1c64 <st_prep_buffer>
    32a8:	b3 cc       	rjmp	.-1690   	; 0x2c10 <protocol_exec_rt_system+0xa2>
    32aa:	82 ff       	sbrs	r24, 2
    32ac:	16 cf       	rjmp	.-468    	; 0x30da <protocol_exec_rt_system+0x56c>
    32ae:	88 60       	ori	r24, 0x08	; 8
    32b0:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    32b4:	12 cf       	rjmp	.-476    	; 0x30da <protocol_exec_rt_system+0x56c>
    32b6:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    32ba:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
    32be:	89 2b       	or	r24, r25
    32c0:	71 f0       	breq	.+28     	; 0x32de <protocol_exec_rt_system+0x770>
    32c2:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    32c6:	86 fd       	sbrc	r24, 6
    32c8:	0a c0       	rjmp	.+20     	; 0x32de <protocol_exec_rt_system+0x770>
    32ca:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    32ce:	88 e0       	ldi	r24, 0x08	; 8
    32d0:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    32d4:	0e 94 32 0e 	call	0x1c64	; 0x1c64 <st_prep_buffer>
    32d8:	0e 94 79 06 	call	0xcf2	; 0xcf2 <st_wake_up>
    32dc:	14 cf       	rjmp	.-472    	; 0x3106 <protocol_exec_rt_system+0x598>
    32de:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    32e2:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    32e6:	0f cf       	rjmp	.-482    	; 0x3106 <protocol_exec_rt_system+0x598>
    32e8:	97 ff       	sbrs	r25, 7
    32ea:	0a c0       	rjmp	.+20     	; 0x3300 <protocol_exec_rt_system+0x792>
    32ec:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    32f0:	0e 94 af 09 	call	0x135e	; 0x135e <plan_reset>
    32f4:	0e 94 db 0d 	call	0x1bb6	; 0x1bb6 <st_reset>
    32f8:	0e 94 a9 09 	call	0x1352	; 0x1352 <gc_sync_position>
    32fc:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    3300:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3304:	85 ff       	sbrs	r24, 5
    3306:	08 c0       	rjmp	.+16     	; 0x3318 <protocol_exec_rt_system+0x7aa>
    3308:	8f 77       	andi	r24, 0x7F	; 127
    330a:	81 60       	ori	r24, 0x01	; 1
    330c:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3310:	80 e4       	ldi	r24, 0x40	; 64
    3312:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    3316:	1d cf       	rjmp	.-454    	; 0x3152 <protocol_exec_rt_system+0x5e4>
    3318:	10 92 33 06 	sts	0x0633, r1	; 0x800633 <sys+0x2>
    331c:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    3320:	18 cf       	rjmp	.-464    	; 0x3152 <protocol_exec_rt_system+0x5e4>
    3322:	a1 2e       	mov	r10, r17
    3324:	b1 2c       	mov	r11, r1
    3326:	18 9d       	mul	r17, r8
    3328:	c0 01       	movw	r24, r0
    332a:	11 24       	eor	r1, r1
    332c:	8a 52       	subi	r24, 0x2A	; 42
    332e:	9d 4f       	sbci	r25, 0xFD	; 253
    3330:	0e 94 98 03 	call	0x730	; 0x730 <plan_compute_profile_nominal_speed>
    3334:	96 2e       	mov	r9, r22
    3336:	c7 2e       	mov	r12, r23
    3338:	d8 2e       	mov	r13, r24
    333a:	09 2f       	mov	r16, r25
    333c:	91 01       	movw	r18, r2
    333e:	a2 01       	movw	r20, r4
    3340:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    3344:	8a 9c       	mul	r8, r10
    3346:	70 01       	movw	r14, r0
    3348:	8b 9c       	mul	r8, r11
    334a:	f0 0c       	add	r15, r0
    334c:	11 24       	eor	r1, r1
    334e:	18 16       	cp	r1, r24
    3350:	ac f5       	brge	.+106    	; 0x33bc <protocol_exec_rt_system+0x84e>
    3352:	c7 01       	movw	r24, r14
    3354:	8a 52       	subi	r24, 0x2A	; 42
    3356:	9d 4f       	sbci	r25, 0xFD	; 253
    3358:	7c 01       	movw	r14, r24
    335a:	91 01       	movw	r18, r2
    335c:	a2 01       	movw	r20, r4
    335e:	b1 01       	movw	r22, r2
    3360:	c2 01       	movw	r24, r4
    3362:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    3366:	f7 01       	movw	r30, r14
    3368:	66 8b       	std	Z+22, r22	; 0x16
    336a:	77 8b       	std	Z+23, r23	; 0x17
    336c:	80 8f       	std	Z+24, r24	; 0x18
    336e:	91 8f       	std	Z+25, r25	; 0x19
    3370:	8a 9c       	mul	r8, r10
    3372:	c0 01       	movw	r24, r0
    3374:	8b 9c       	mul	r8, r11
    3376:	90 0d       	add	r25, r0
    3378:	11 24       	eor	r1, r1
    337a:	9c 01       	movw	r18, r24
    337c:	2a 52       	subi	r18, 0x2A	; 42
    337e:	3d 4f       	sbci	r19, 0xFD	; 253
    3380:	79 01       	movw	r14, r18
    3382:	f9 01       	movw	r30, r18
    3384:	22 a0       	ldd	r2, Z+34	; 0x22
    3386:	33 a0       	ldd	r3, Z+35	; 0x23
    3388:	44 a0       	ldd	r4, Z+36	; 0x24
    338a:	55 a0       	ldd	r5, Z+37	; 0x25
    338c:	a2 01       	movw	r20, r4
    338e:	91 01       	movw	r18, r2
    3390:	66 89       	ldd	r22, Z+22	; 0x16
    3392:	77 89       	ldd	r23, Z+23	; 0x17
    3394:	80 8d       	ldd	r24, Z+24	; 0x18
    3396:	91 8d       	ldd	r25, Z+25	; 0x19
    3398:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    339c:	18 16       	cp	r1, r24
    339e:	2c f4       	brge	.+10     	; 0x33aa <protocol_exec_rt_system+0x83c>
    33a0:	f7 01       	movw	r30, r14
    33a2:	26 8a       	std	Z+22, r2	; 0x16
    33a4:	37 8a       	std	Z+23, r3	; 0x17
    33a6:	40 8e       	std	Z+24, r4	; 0x18
    33a8:	51 8e       	std	Z+25, r5	; 0x19
    33aa:	1f 5f       	subi	r17, 0xFF	; 255
    33ac:	10 31       	cpi	r17, 0x10	; 16
    33ae:	09 f4       	brne	.+2      	; 0x33b2 <protocol_exec_rt_system+0x844>
    33b0:	10 e0       	ldi	r17, 0x00	; 0
    33b2:	29 2c       	mov	r2, r9
    33b4:	3c 2c       	mov	r3, r12
    33b6:	4d 2c       	mov	r4, r13
    33b8:	50 2e       	mov	r5, r16
    33ba:	0d cf       	rjmp	.-486    	; 0x31d6 <protocol_exec_rt_system+0x668>
    33bc:	97 01       	movw	r18, r14
    33be:	2a 52       	subi	r18, 0x2A	; 42
    33c0:	3d 4f       	sbci	r19, 0xFD	; 253
    33c2:	79 01       	movw	r14, r18
    33c4:	29 2d       	mov	r18, r9
    33c6:	3c 2d       	mov	r19, r12
    33c8:	4d 2d       	mov	r20, r13
    33ca:	50 2f       	mov	r21, r16
    33cc:	69 2d       	mov	r22, r9
    33ce:	7c 2d       	mov	r23, r12
    33d0:	8d 2d       	mov	r24, r13
    33d2:	90 2f       	mov	r25, r16
    33d4:	c6 cf       	rjmp	.-116    	; 0x3362 <protocol_exec_rt_system+0x7f4>
    33d6:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    33da:	88 60       	ori	r24, 0x08	; 8
    33dc:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    33e0:	3d cf       	rjmp	.-390    	; 0x325c <protocol_exec_rt_system+0x6ee>
    33e2:	90 ff       	sbrs	r25, 0
    33e4:	4a cf       	rjmp	.-364    	; 0x327a <protocol_exec_rt_system+0x70c>
    33e6:	94 60       	ori	r25, 0x04	; 4
    33e8:	46 cf       	rjmp	.-372    	; 0x3276 <protocol_exec_rt_system+0x708>
    33ea:	10 64       	ori	r17, 0x40	; 64
    33ec:	51 cf       	rjmp	.-350    	; 0x3290 <protocol_exec_rt_system+0x722>
    33ee:	f1 10       	cpse	r15, r1
    33f0:	32 ce       	rjmp	.-924    	; 0x3056 <protocol_exec_rt_system+0x4e8>
    33f2:	f5 cc       	rjmp	.-1558   	; 0x2dde <protocol_exec_rt_system+0x270>

000033f4 <protocol_execute_realtime>:
    33f4:	cf 92       	push	r12
    33f6:	df 92       	push	r13
    33f8:	ef 92       	push	r14
    33fa:	ff 92       	push	r15
    33fc:	1f 93       	push	r17
    33fe:	cf 93       	push	r28
    3400:	df 93       	push	r29
    3402:	0e 94 b7 15 	call	0x2b6e	; 0x2b6e <protocol_exec_rt_system>
    3406:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    340a:	88 23       	and	r24, r24
    340c:	09 f4       	brne	.+2      	; 0x3410 <protocol_execute_realtime+0x1c>
    340e:	6e c0       	rjmp	.+220    	; 0x34ec <protocol_execute_realtime+0xf8>
    3410:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
    3414:	00 97       	sbiw	r24, 0x00	; 0
    3416:	09 f0       	breq	.+2      	; 0x341a <protocol_execute_realtime+0x26>
    3418:	3f c0       	rjmp	.+126    	; 0x3498 <protocol_execute_realtime+0xa4>
    341a:	c0 91 a0 06 	lds	r28, 0x06A0	; 0x8006a0 <gc_state+0x9>
    341e:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    3422:	c8 2b       	or	r28, r24
    3424:	c0 90 a2 06 	lds	r12, 0x06A2	; 0x8006a2 <gc_state+0xb>
    3428:	d0 90 a3 06 	lds	r13, 0x06A3	; 0x8006a3 <gc_state+0xc>
    342c:	e0 90 a4 06 	lds	r14, 0x06A4	; 0x8006a4 <gc_state+0xd>
    3430:	f0 90 a5 06 	lds	r15, 0x06A5	; 0x8006a5 <gc_state+0xe>
    3434:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3438:	81 ff       	sbrs	r24, 1
    343a:	03 c0       	rjmp	.+6      	; 0x3442 <protocol_execute_realtime+0x4e>
    343c:	80 e2       	ldi	r24, 0x20	; 32
    343e:	0e 94 29 02 	call	0x452	; 0x452 <system_set_exec_accessory_override_flag>
    3442:	dc 2f       	mov	r29, r28
    3444:	d0 73       	andi	r29, 0x30	; 48
    3446:	11 e0       	ldi	r17, 0x01	; 1
    3448:	c0 7c       	andi	r28, 0xC0	; 192
    344a:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    344e:	88 23       	and	r24, r24
    3450:	09 f4       	brne	.+2      	; 0x3454 <protocol_execute_realtime+0x60>
    3452:	4c c0       	rjmp	.+152    	; 0x34ec <protocol_execute_realtime+0xf8>
    3454:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    3458:	91 11       	cpse	r25, r1
    345a:	48 c0       	rjmp	.+144    	; 0x34ec <protocol_execute_realtime+0xf8>
    345c:	80 ff       	sbrs	r24, 0
    345e:	19 c0       	rjmp	.+50     	; 0x3492 <protocol_execute_realtime+0x9e>
    3460:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    3464:	29 2f       	mov	r18, r25
    3466:	20 7c       	andi	r18, 0xC0	; 192
    3468:	09 f4       	brne	.+2      	; 0x346c <protocol_execute_realtime+0x78>
    346a:	8d c0       	rjmp	.+282    	; 0x3586 <protocol_execute_realtime+0x192>
    346c:	82 fd       	sbrc	r24, 2
    346e:	23 c0       	rjmp	.+70     	; 0x34b6 <protocol_execute_realtime+0xc2>
    3470:	10 92 3b 06 	sts	0x063B, r1	; 0x80063b <sys+0xa>
    3474:	40 e0       	ldi	r20, 0x00	; 0
    3476:	50 e0       	ldi	r21, 0x00	; 0
    3478:	ba 01       	movw	r22, r20
    347a:	80 e0       	ldi	r24, 0x00	; 0
    347c:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    3480:	80 e0       	ldi	r24, 0x00	; 0
    3482:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    3486:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    348a:	8d 7f       	andi	r24, 0xFD	; 253
    348c:	84 60       	ori	r24, 0x04	; 4
    348e:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3492:	0e 94 b7 15 	call	0x2b6e	; 0x2b6e <protocol_exec_rt_system>
    3496:	d9 cf       	rjmp	.-78     	; 0x344a <protocol_execute_realtime+0x56>
    3498:	fc 01       	movw	r30, r24
    349a:	21 89       	ldd	r18, Z+17	; 0x11
    349c:	20 73       	andi	r18, 0x30	; 48
    349e:	43 99       	sbic	0x08, 3	; 8
    34a0:	08 c0       	rjmp	.+16     	; 0x34b2 <protocol_execute_realtime+0xbe>
    34a2:	c0 e0       	ldi	r28, 0x00	; 0
    34a4:	c2 2b       	or	r28, r18
    34a6:	fc 01       	movw	r30, r24
    34a8:	c6 a4       	ldd	r12, Z+46	; 0x2e
    34aa:	d7 a4       	ldd	r13, Z+47	; 0x2f
    34ac:	e0 a8       	ldd	r14, Z+48	; 0x30
    34ae:	f1 a8       	ldd	r15, Z+49	; 0x31
    34b0:	c1 cf       	rjmp	.-126    	; 0x3434 <protocol_execute_realtime+0x40>
    34b2:	c0 e4       	ldi	r28, 0x40	; 64
    34b4:	f7 cf       	rjmp	.-18     	; 0x34a4 <protocol_execute_realtime+0xb0>
    34b6:	90 38       	cpi	r25, 0x80	; 128
    34b8:	21 f5       	brne	.+72     	; 0x3502 <protocol_execute_realtime+0x10e>
    34ba:	8a ec       	ldi	r24, 0xCA	; 202
    34bc:	92 e0       	ldi	r25, 0x02	; 2
    34be:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    34c2:	83 e3       	ldi	r24, 0x33	; 51
    34c4:	92 e0       	ldi	r25, 0x02	; 2
    34c6:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    34ca:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    34ce:	40 e0       	ldi	r20, 0x00	; 0
    34d0:	50 e0       	ldi	r21, 0x00	; 0
    34d2:	ba 01       	movw	r22, r20
    34d4:	80 e0       	ldi	r24, 0x00	; 0
    34d6:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    34da:	80 e0       	ldi	r24, 0x00	; 0
    34dc:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    34e0:	0e 94 a7 0d 	call	0x1b4e	; 0x1b4e <st_go_idle>
    34e4:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    34e8:	88 23       	and	r24, r24
    34ea:	41 f0       	breq	.+16     	; 0x34fc <protocol_execute_realtime+0x108>
    34ec:	df 91       	pop	r29
    34ee:	cf 91       	pop	r28
    34f0:	1f 91       	pop	r17
    34f2:	ff 90       	pop	r15
    34f4:	ef 90       	pop	r14
    34f6:	df 90       	pop	r13
    34f8:	cf 90       	pop	r12
    34fa:	08 95       	ret
    34fc:	0e 94 b7 15 	call	0x2b6e	; 0x2b6e <protocol_exec_rt_system>
    3500:	f1 cf       	rjmp	.-30     	; 0x34e4 <protocol_execute_realtime+0xf0>
    3502:	90 34       	cpi	r25, 0x40	; 64
    3504:	19 f4       	brne	.+6      	; 0x350c <protocol_execute_realtime+0x118>
    3506:	8f 7d       	andi	r24, 0xDF	; 223
    3508:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    350c:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3510:	83 ff       	sbrs	r24, 3
    3512:	bf cf       	rjmp	.-130    	; 0x3492 <protocol_execute_realtime+0x9e>
    3514:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3518:	99 23       	and	r25, r25
    351a:	59 f0       	breq	.+22     	; 0x3532 <protocol_execute_realtime+0x13e>
    351c:	81 fd       	sbrc	r24, 1
    351e:	09 c0       	rjmp	.+18     	; 0x3532 <protocol_execute_realtime+0x13e>
    3520:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3524:	81 ff       	sbrs	r24, 1
    3526:	22 c0       	rjmp	.+68     	; 0x356c <protocol_execute_realtime+0x178>
    3528:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    352c:	88 60       	ori	r24, 0x08	; 8
    352e:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    3532:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    3536:	88 23       	and	r24, r24
    3538:	71 f0       	breq	.+28     	; 0x3556 <protocol_execute_realtime+0x162>
    353a:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    353e:	81 fd       	sbrc	r24, 1
    3540:	0a c0       	rjmp	.+20     	; 0x3556 <protocol_execute_realtime+0x162>
    3542:	8c 2f       	mov	r24, r28
    3544:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    3548:	41 e0       	ldi	r20, 0x01	; 1
    354a:	60 e0       	ldi	r22, 0x00	; 0
    354c:	70 e0       	ldi	r23, 0x00	; 0
    354e:	80 e8       	ldi	r24, 0x80	; 128
    3550:	9f e3       	ldi	r25, 0x3F	; 63
    3552:	0e 94 f8 1c 	call	0x39f0	; 0x39f0 <delay_sec>
    3556:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    355a:	81 fd       	sbrc	r24, 1
    355c:	9a cf       	rjmp	.-204    	; 0x3492 <protocol_execute_realtime+0x9e>
    355e:	80 61       	ori	r24, 0x10	; 16
    3560:	80 93 33 06 	sts	0x0633, r24	; 0x800633 <sys+0x2>
    3564:	82 e0       	ldi	r24, 0x02	; 2
    3566:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    356a:	93 cf       	rjmp	.-218    	; 0x3492 <protocol_execute_realtime+0x9e>
    356c:	b7 01       	movw	r22, r14
    356e:	a6 01       	movw	r20, r12
    3570:	8d 2f       	mov	r24, r29
    3572:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    3576:	41 e0       	ldi	r20, 0x01	; 1
    3578:	60 e0       	ldi	r22, 0x00	; 0
    357a:	70 e0       	ldi	r23, 0x00	; 0
    357c:	80 e8       	ldi	r24, 0x80	; 128
    357e:	90 e4       	ldi	r25, 0x40	; 64
    3580:	0e 94 f8 1c 	call	0x39f0	; 0x39f0 <delay_sec>
    3584:	d6 cf       	rjmp	.-84     	; 0x3532 <protocol_execute_realtime+0x13e>
    3586:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    358a:	88 23       	and	r24, r24
    358c:	c9 f1       	breq	.+114    	; 0x3600 <protocol_execute_realtime+0x20c>
    358e:	81 ff       	sbrs	r24, 1
    3590:	0d c0       	rjmp	.+26     	; 0x35ac <protocol_execute_realtime+0x1b8>
    3592:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    3596:	88 23       	and	r24, r24
    3598:	51 f1       	breq	.+84     	; 0x35ee <protocol_execute_realtime+0x1fa>
    359a:	40 e0       	ldi	r20, 0x00	; 0
    359c:	50 e0       	ldi	r21, 0x00	; 0
    359e:	ba 01       	movw	r22, r20
    35a0:	80 e0       	ldi	r24, 0x00	; 0
    35a2:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    35a6:	10 93 3b 06 	sts	0x063B, r17	; 0x80063b <sys+0xa>
    35aa:	73 cf       	rjmp	.-282    	; 0x3492 <protocol_execute_realtime+0x9e>
    35ac:	8c 70       	andi	r24, 0x0C	; 12
    35ae:	09 f4       	brne	.+2      	; 0x35b2 <protocol_execute_realtime+0x1be>
    35b0:	70 cf       	rjmp	.-288    	; 0x3492 <protocol_execute_realtime+0x9e>
    35b2:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    35b6:	88 23       	and	r24, r24
    35b8:	99 f0       	breq	.+38     	; 0x35e0 <protocol_execute_realtime+0x1ec>
    35ba:	8a ec       	ldi	r24, 0xCA	; 202
    35bc:	92 e0       	ldi	r25, 0x02	; 2
    35be:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    35c2:	8c e3       	ldi	r24, 0x3C	; 60
    35c4:	92 e0       	ldi	r25, 0x02	; 2
    35c6:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    35ca:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    35ce:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    35d2:	81 ff       	sbrs	r24, 1
    35d4:	0f c0       	rjmp	.+30     	; 0x35f4 <protocol_execute_realtime+0x200>
    35d6:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    35da:	88 60       	ori	r24, 0x08	; 8
    35dc:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    35e0:	80 91 3b 06 	lds	r24, 0x063B	; 0x80063b <sys+0xa>
    35e4:	83 ff       	sbrs	r24, 3
    35e6:	03 c0       	rjmp	.+6      	; 0x35ee <protocol_execute_realtime+0x1fa>
    35e8:	82 e0       	ldi	r24, 0x02	; 2
    35ea:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    35ee:	10 92 3b 06 	sts	0x063B, r1	; 0x80063b <sys+0xa>
    35f2:	4f cf       	rjmp	.-354    	; 0x3492 <protocol_execute_realtime+0x9e>
    35f4:	b7 01       	movw	r22, r14
    35f6:	a6 01       	movw	r20, r12
    35f8:	8d 2f       	mov	r24, r29
    35fa:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    35fe:	f0 cf       	rjmp	.-32     	; 0x35e0 <protocol_execute_realtime+0x1ec>
    3600:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    3604:	83 ff       	sbrs	r24, 3
    3606:	45 cf       	rjmp	.-374    	; 0x3492 <protocol_execute_realtime+0x9e>
    3608:	b7 01       	movw	r22, r14
    360a:	a6 01       	movw	r20, r12
    360c:	8d 2f       	mov	r24, r29
    360e:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    3612:	80 91 35 06 	lds	r24, 0x0635	; 0x800635 <sys+0x4>
    3616:	87 7f       	andi	r24, 0xF7	; 247
    3618:	80 93 35 06 	sts	0x0635, r24	; 0x800635 <sys+0x4>
    361c:	3a cf       	rjmp	.-396    	; 0x3492 <protocol_execute_realtime+0x9e>

0000361e <limits_go_home>:
    361e:	2f 92       	push	r2
    3620:	3f 92       	push	r3
    3622:	4f 92       	push	r4
    3624:	5f 92       	push	r5
    3626:	6f 92       	push	r6
    3628:	7f 92       	push	r7
    362a:	8f 92       	push	r8
    362c:	9f 92       	push	r9
    362e:	af 92       	push	r10
    3630:	bf 92       	push	r11
    3632:	cf 92       	push	r12
    3634:	df 92       	push	r13
    3636:	ef 92       	push	r14
    3638:	ff 92       	push	r15
    363a:	0f 93       	push	r16
    363c:	1f 93       	push	r17
    363e:	cf 93       	push	r28
    3640:	df 93       	push	r29
    3642:	cd b7       	in	r28, 0x3d	; 61
    3644:	de b7       	in	r29, 0x3e	; 62
    3646:	a2 97       	sbiw	r28, 0x22	; 34
    3648:	0f b6       	in	r0, 0x3f	; 63
    364a:	f8 94       	cli
    364c:	de bf       	out	0x3e, r29	; 62
    364e:	0f be       	out	0x3f, r0	; 63
    3650:	cd bf       	out	0x3d, r28	; 61
    3652:	90 91 32 06 	lds	r25, 0x0632	; 0x800632 <sys+0x1>
    3656:	91 11       	cpse	r25, r1
    3658:	15 c1       	rjmp	.+554    	; 0x3884 <limits_go_home+0x266>
    365a:	78 2e       	mov	r7, r24
    365c:	9e 01       	movw	r18, r28
    365e:	23 5f       	subi	r18, 0xF3	; 243
    3660:	3f 4f       	sbci	r19, 0xFF	; 255
    3662:	3a 8f       	std	Y+26, r19	; 0x1a
    3664:	29 8f       	std	Y+25, r18	; 0x19
    3666:	89 e0       	ldi	r24, 0x09	; 9
    3668:	d9 01       	movw	r26, r18
    366a:	1d 92       	st	X+, r1
    366c:	8a 95       	dec	r24
    366e:	e9 f7       	brne	.-6      	; 0x366a <limits_go_home+0x4c>
    3670:	86 e0       	ldi	r24, 0x06	; 6
    3672:	8d 8b       	std	Y+21, r24	; 0x15
    3674:	e2 e4       	ldi	r30, 0x42	; 66
    3676:	f6 e0       	ldi	r31, 0x06	; 6
    3678:	fc 8f       	std	Y+28, r31	; 0x1c
    367a:	eb 8f       	std	Y+27, r30	; 0x1b
    367c:	7f 01       	movw	r14, r30
    367e:	27 5f       	subi	r18, 0xF7	; 247
    3680:	3f 4f       	sbci	r19, 0xFF	; 255
    3682:	69 01       	movw	r12, r18
    3684:	10 e0       	ldi	r17, 0x00	; 0
    3686:	00 e0       	ldi	r16, 0x00	; 0
    3688:	81 2c       	mov	r8, r1
    368a:	91 2c       	mov	r9, r1
    368c:	54 01       	movw	r10, r8
    368e:	87 2d       	mov	r24, r7
    3690:	90 e0       	ldi	r25, 0x00	; 0
    3692:	9e 8f       	std	Y+30, r25	; 0x1e
    3694:	8d 8f       	std	Y+29, r24	; 0x1d
    3696:	80 2f       	mov	r24, r16
    3698:	94 e0       	ldi	r25, 0x04	; 4
    369a:	00 23       	and	r16, r16
    369c:	21 f0       	breq	.+8      	; 0x36a6 <limits_go_home+0x88>
    369e:	90 e1       	ldi	r25, 0x10	; 16
    36a0:	01 30       	cpi	r16, 0x01	; 1
    36a2:	09 f4       	brne	.+2      	; 0x36a6 <limits_go_home+0x88>
    36a4:	98 e0       	ldi	r25, 0x08	; 8
    36a6:	d6 01       	movw	r26, r12
    36a8:	9d 93       	st	X+, r25
    36aa:	6d 01       	movw	r12, r26
    36ac:	ed 8d       	ldd	r30, Y+29	; 0x1d
    36ae:	fe 8d       	ldd	r31, Y+30	; 0x1e
    36b0:	02 c0       	rjmp	.+4      	; 0x36b6 <limits_go_home+0x98>
    36b2:	f5 95       	asr	r31
    36b4:	e7 95       	ror	r30
    36b6:	8a 95       	dec	r24
    36b8:	e2 f7       	brpl	.-8      	; 0x36b2 <limits_go_home+0x94>
    36ba:	e0 ff       	sbrs	r30, 0
    36bc:	1b c0       	rjmp	.+54     	; 0x36f4 <limits_go_home+0xd6>
    36be:	20 e0       	ldi	r18, 0x00	; 0
    36c0:	30 e0       	ldi	r19, 0x00	; 0
    36c2:	40 ec       	ldi	r20, 0xC0	; 192
    36c4:	5f eb       	ldi	r21, 0xBF	; 191
    36c6:	d7 01       	movw	r26, r14
    36c8:	94 96       	adiw	r26, 0x24	; 36
    36ca:	6d 91       	ld	r22, X+
    36cc:	7d 91       	ld	r23, X+
    36ce:	8d 91       	ld	r24, X+
    36d0:	9c 91       	ld	r25, X
    36d2:	97 97       	sbiw	r26, 0x27	; 39
    36d4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    36d8:	36 2e       	mov	r3, r22
    36da:	47 2e       	mov	r4, r23
    36dc:	58 2e       	mov	r5, r24
    36de:	69 2e       	mov	r6, r25
    36e0:	a5 01       	movw	r20, r10
    36e2:	94 01       	movw	r18, r8
    36e4:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    36e8:	87 fd       	sbrc	r24, 7
    36ea:	04 c0       	rjmp	.+8      	; 0x36f4 <limits_go_home+0xd6>
    36ec:	83 2c       	mov	r8, r3
    36ee:	94 2c       	mov	r9, r4
    36f0:	a5 2c       	mov	r10, r5
    36f2:	b6 2c       	mov	r11, r6
    36f4:	0f 5f       	subi	r16, 0xFF	; 255
    36f6:	1f 4f       	sbci	r17, 0xFF	; 255
    36f8:	b4 e0       	ldi	r27, 0x04	; 4
    36fa:	eb 0e       	add	r14, r27
    36fc:	f1 1c       	adc	r15, r1
    36fe:	03 30       	cpi	r16, 0x03	; 3
    3700:	11 05       	cpc	r17, r1
    3702:	49 f6       	brne	.-110    	; 0x3696 <limits_go_home+0x78>
    3704:	20 90 8d 06 	lds	r2, 0x068D	; 0x80068d <settings+0x4b>
    3708:	30 90 8e 06 	lds	r3, 0x068E	; 0x80068e <settings+0x4c>
    370c:	40 90 8f 06 	lds	r4, 0x068F	; 0x80068f <settings+0x4d>
    3710:	50 90 90 06 	lds	r5, 0x0690	; 0x800690 <settings+0x4e>
    3714:	84 e0       	ldi	r24, 0x04	; 4
    3716:	68 2e       	mov	r6, r24
    3718:	01 e0       	ldi	r16, 0x01	; 1
    371a:	68 e1       	ldi	r22, 0x18	; 24
    371c:	76 e0       	ldi	r23, 0x06	; 6
    371e:	ce 01       	movw	r24, r28
    3720:	01 96       	adiw	r24, 0x01	; 1
    3722:	0e 94 8f 02 	call	0x51e	; 0x51e <system_convert_array_steps_to_mpos>
    3726:	80 91 88 06 	lds	r24, 0x0688	; 0x800688 <settings+0x46>
    372a:	e8 2f       	mov	r30, r24
    372c:	f0 e0       	ldi	r31, 0x00	; 0
    372e:	fa a3       	std	Y+34, r31	; 0x22
    3730:	e9 a3       	std	Y+33, r30	; 0x21
    3732:	fe 01       	movw	r30, r28
    3734:	31 96       	adiw	r30, 0x01	; 1
    3736:	28 e1       	ldi	r18, 0x18	; 24
    3738:	36 e0       	ldi	r19, 0x06	; 6
    373a:	38 a3       	std	Y+32, r19	; 0x20
    373c:	2f 8f       	std	Y+31, r18	; 0x1f
    373e:	69 01       	movw	r12, r18
    3740:	f1 2c       	mov	r15, r1
    3742:	10 e0       	ldi	r17, 0x00	; 0
    3744:	90 e0       	ldi	r25, 0x00	; 0
    3746:	80 e0       	ldi	r24, 0x00	; 0
    3748:	b5 01       	movw	r22, r10
    374a:	a4 01       	movw	r20, r8
    374c:	70 58       	subi	r23, 0x80	; 128
    374e:	2d 8d       	ldd	r18, Y+29	; 0x1d
    3750:	3e 8d       	ldd	r19, Y+30	; 0x1e
    3752:	08 2e       	mov	r0, r24
    3754:	02 c0       	rjmp	.+4      	; 0x375a <limits_go_home+0x13c>
    3756:	35 95       	asr	r19
    3758:	27 95       	ror	r18
    375a:	0a 94       	dec	r0
    375c:	e2 f7       	brpl	.-8      	; 0x3756 <limits_go_home+0x138>
    375e:	20 ff       	sbrs	r18, 0
    3760:	26 c0       	rjmp	.+76     	; 0x37ae <limits_go_home+0x190>
    3762:	f3 94       	inc	r15
    3764:	d6 01       	movw	r26, r12
    3766:	1d 92       	st	X+, r1
    3768:	1d 92       	st	X+, r1
    376a:	1d 92       	st	X+, r1
    376c:	1c 92       	st	X, r1
    376e:	13 97       	sbiw	r26, 0x03	; 3
    3770:	29 a1       	ldd	r18, Y+33	; 0x21
    3772:	3a a1       	ldd	r19, Y+34	; 0x22
    3774:	08 2e       	mov	r0, r24
    3776:	02 c0       	rjmp	.+4      	; 0x377c <limits_go_home+0x15e>
    3778:	35 95       	asr	r19
    377a:	27 95       	ror	r18
    377c:	0a 94       	dec	r0
    377e:	e2 f7       	brpl	.-8      	; 0x3778 <limits_go_home+0x15a>
    3780:	20 ff       	sbrs	r18, 0
    3782:	07 c0       	rjmp	.+14     	; 0x3792 <limits_go_home+0x174>
    3784:	00 23       	and	r16, r16
    3786:	39 f0       	breq	.+14     	; 0x3796 <limits_go_home+0x178>
    3788:	40 83       	st	Z, r20
    378a:	51 83       	std	Z+1, r21	; 0x01
    378c:	62 83       	std	Z+2, r22	; 0x02
    378e:	73 83       	std	Z+3, r23	; 0x03
    3790:	06 c0       	rjmp	.+12     	; 0x379e <limits_go_home+0x180>
    3792:	00 23       	and	r16, r16
    3794:	c9 f3       	breq	.-14     	; 0x3788 <limits_go_home+0x16a>
    3796:	80 82       	st	Z, r8
    3798:	91 82       	std	Z+1, r9	; 0x01
    379a:	a2 82       	std	Z+2, r10	; 0x02
    379c:	b3 82       	std	Z+3, r11	; 0x03
    379e:	a6 e1       	ldi	r26, 0x16	; 22
    37a0:	b0 e0       	ldi	r27, 0x00	; 0
    37a2:	ac 0f       	add	r26, r28
    37a4:	bd 1f       	adc	r27, r29
    37a6:	a8 0f       	add	r26, r24
    37a8:	b9 1f       	adc	r27, r25
    37aa:	2c 91       	ld	r18, X
    37ac:	12 2b       	or	r17, r18
    37ae:	01 96       	adiw	r24, 0x01	; 1
    37b0:	34 96       	adiw	r30, 0x04	; 4
    37b2:	b4 e0       	ldi	r27, 0x04	; 4
    37b4:	cb 0e       	add	r12, r27
    37b6:	d1 1c       	adc	r13, r1
    37b8:	83 30       	cpi	r24, 0x03	; 3
    37ba:	91 05       	cpc	r25, r1
    37bc:	41 f6       	brne	.-112    	; 0x374e <limits_go_home+0x130>
    37be:	6f 2d       	mov	r22, r15
    37c0:	70 e0       	ldi	r23, 0x00	; 0
    37c2:	90 e0       	ldi	r25, 0x00	; 0
    37c4:	80 e0       	ldi	r24, 0x00	; 0
    37c6:	0e 94 eb 36 	call	0x6dd6	; 0x6dd6 <__floatunsisf>
    37ca:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    37ce:	10 93 37 06 	sts	0x0637, r17	; 0x800637 <sys+0x6>
    37d2:	a2 01       	movw	r20, r4
    37d4:	91 01       	movw	r18, r2
    37d6:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    37da:	6d 87       	std	Y+13, r22	; 0x0d
    37dc:	7e 87       	std	Y+14, r23	; 0x0e
    37de:	8f 87       	std	Y+15, r24	; 0x0f
    37e0:	98 8b       	std	Y+16, r25	; 0x10
    37e2:	be 01       	movw	r22, r28
    37e4:	63 5f       	subi	r22, 0xF3	; 243
    37e6:	7f 4f       	sbci	r23, 0xFF	; 255
    37e8:	ce 01       	movw	r24, r28
    37ea:	01 96       	adiw	r24, 0x01	; 1
    37ec:	0e 94 f6 0a 	call	0x15ec	; 0x15ec <plan_buffer_line>
    37f0:	e4 e0       	ldi	r30, 0x04	; 4
    37f2:	e0 93 35 06 	sts	0x0635, r30	; 0x800635 <sys+0x4>
    37f6:	0e 94 32 0e 	call	0x1c64	; 0x1c64 <st_prep_buffer>
    37fa:	0e 94 79 06 	call	0xcf2	; 0xcf2 <st_wake_up>
    37fe:	00 23       	and	r16, r16
    3800:	e9 f0       	breq	.+58     	; 0x383c <limits_go_home+0x21e>
    3802:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    3806:	fe 01       	movw	r30, r28
    3808:	76 96       	adiw	r30, 0x16	; 22
    380a:	30 e0       	ldi	r19, 0x00	; 0
    380c:	20 e0       	ldi	r18, 0x00	; 0
    380e:	90 e0       	ldi	r25, 0x00	; 0
    3810:	61 91       	ld	r22, Z+
    3812:	46 2f       	mov	r20, r22
    3814:	41 23       	and	r20, r17
    3816:	59 f0       	breq	.+22     	; 0x382e <limits_go_home+0x210>
    3818:	ac 01       	movw	r20, r24
    381a:	02 2e       	mov	r0, r18
    381c:	02 c0       	rjmp	.+4      	; 0x3822 <limits_go_home+0x204>
    381e:	55 95       	asr	r21
    3820:	47 95       	ror	r20
    3822:	0a 94       	dec	r0
    3824:	e2 f7       	brpl	.-8      	; 0x381e <limits_go_home+0x200>
    3826:	40 ff       	sbrs	r20, 0
    3828:	02 c0       	rjmp	.+4      	; 0x382e <limits_go_home+0x210>
    382a:	60 95       	com	r22
    382c:	16 23       	and	r17, r22
    382e:	2f 5f       	subi	r18, 0xFF	; 255
    3830:	3f 4f       	sbci	r19, 0xFF	; 255
    3832:	23 30       	cpi	r18, 0x03	; 3
    3834:	31 05       	cpc	r19, r1
    3836:	61 f7       	brne	.-40     	; 0x3810 <limits_go_home+0x1f2>
    3838:	10 93 37 06 	sts	0x0637, r17	; 0x800637 <sys+0x6>
    383c:	0e 94 32 0e 	call	0x1c64	; 0x1c64 <st_prep_buffer>
    3840:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    3844:	84 73       	andi	r24, 0x34	; 52
    3846:	09 f4       	brne	.+2      	; 0x384a <limits_go_home+0x22c>
    3848:	b3 c0       	rjmp	.+358    	; 0x39b0 <limits_go_home+0x392>
    384a:	10 91 13 06 	lds	r17, 0x0613	; 0x800613 <sys_rt_exec_state>
    384e:	14 ff       	sbrs	r17, 4
    3850:	03 c0       	rjmp	.+6      	; 0x3858 <limits_go_home+0x23a>
    3852:	86 e0       	ldi	r24, 0x06	; 6
    3854:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3858:	15 ff       	sbrs	r17, 5
    385a:	03 c0       	rjmp	.+6      	; 0x3862 <limits_go_home+0x244>
    385c:	87 e0       	ldi	r24, 0x07	; 7
    385e:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3862:	01 11       	cpse	r16, r1
    3864:	c1 c0       	rjmp	.+386    	; 0x39e8 <limits_go_home+0x3ca>
    3866:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    386a:	87 21       	and	r24, r7
    386c:	19 f0       	breq	.+6      	; 0x3874 <limits_go_home+0x256>
    386e:	88 e0       	ldi	r24, 0x08	; 8
    3870:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3874:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    3878:	88 23       	and	r24, r24
    387a:	e9 f0       	breq	.+58     	; 0x38b6 <limits_go_home+0x298>
    387c:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    3880:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3884:	a2 96       	adiw	r28, 0x22	; 34
    3886:	0f b6       	in	r0, 0x3f	; 63
    3888:	f8 94       	cli
    388a:	de bf       	out	0x3e, r29	; 62
    388c:	0f be       	out	0x3f, r0	; 63
    388e:	cd bf       	out	0x3d, r28	; 61
    3890:	df 91       	pop	r29
    3892:	cf 91       	pop	r28
    3894:	1f 91       	pop	r17
    3896:	0f 91       	pop	r16
    3898:	ff 90       	pop	r15
    389a:	ef 90       	pop	r14
    389c:	df 90       	pop	r13
    389e:	cf 90       	pop	r12
    38a0:	bf 90       	pop	r11
    38a2:	af 90       	pop	r10
    38a4:	9f 90       	pop	r9
    38a6:	8f 90       	pop	r8
    38a8:	7f 90       	pop	r7
    38aa:	6f 90       	pop	r6
    38ac:	5f 90       	pop	r5
    38ae:	4f 90       	pop	r4
    38b0:	3f 90       	pop	r3
    38b2:	2f 90       	pop	r2
    38b4:	08 95       	ret
    38b6:	84 e0       	ldi	r24, 0x04	; 4
    38b8:	0e 94 41 02 	call	0x482	; 0x482 <system_clear_exec_state_flag>
    38bc:	0e 94 db 0d 	call	0x1bb6	; 0x1bb6 <st_reset>
    38c0:	80 91 91 06 	lds	r24, 0x0691	; 0x800691 <settings+0x4f>
    38c4:	90 91 92 06 	lds	r25, 0x0692	; 0x800692 <settings+0x50>
    38c8:	01 97       	sbiw	r24, 0x01	; 1
    38ca:	08 f0       	brcs	.+2      	; 0x38ce <limits_go_home+0x2b0>
    38cc:	76 c0       	rjmp	.+236    	; 0x39ba <limits_go_home+0x39c>
    38ce:	e1 e0       	ldi	r30, 0x01	; 1
    38d0:	0e 27       	eor	r16, r30
    38d2:	c0 90 93 06 	lds	r12, 0x0693	; 0x800693 <settings+0x51>
    38d6:	d0 90 94 06 	lds	r13, 0x0694	; 0x800694 <settings+0x52>
    38da:	e0 90 95 06 	lds	r14, 0x0695	; 0x800695 <settings+0x53>
    38de:	f0 90 96 06 	lds	r15, 0x0696	; 0x800696 <settings+0x54>
    38e2:	00 23       	and	r16, r16
    38e4:	09 f4       	brne	.+2      	; 0x38e8 <limits_go_home+0x2ca>
    38e6:	70 c0       	rjmp	.+224    	; 0x39c8 <limits_go_home+0x3aa>
    38e8:	20 e0       	ldi	r18, 0x00	; 0
    38ea:	30 e0       	ldi	r19, 0x00	; 0
    38ec:	40 ea       	ldi	r20, 0xA0	; 160
    38ee:	50 e4       	ldi	r21, 0x40	; 64
    38f0:	c7 01       	movw	r24, r14
    38f2:	b6 01       	movw	r22, r12
    38f4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    38f8:	4b 01       	movw	r8, r22
    38fa:	5c 01       	movw	r10, r24
    38fc:	20 90 89 06 	lds	r2, 0x0689	; 0x800689 <settings+0x47>
    3900:	30 90 8a 06 	lds	r3, 0x068A	; 0x80068a <settings+0x48>
    3904:	40 90 8b 06 	lds	r4, 0x068B	; 0x80068b <settings+0x49>
    3908:	50 90 8c 06 	lds	r5, 0x068C	; 0x80068c <settings+0x4a>
    390c:	6a 94       	dec	r6
    390e:	61 10       	cpse	r6, r1
    3910:	04 cf       	rjmp	.-504    	; 0x371a <limits_go_home+0xfc>
    3912:	20 90 88 06 	lds	r2, 0x0688	; 0x800688 <settings+0x46>
    3916:	31 2c       	mov	r3, r1
    3918:	26 01       	movw	r4, r12
    391a:	37 01       	movw	r6, r14
    391c:	77 fa       	bst	r7, 7
    391e:	70 94       	com	r7
    3920:	77 f8       	bld	r7, 7
    3922:	70 94       	com	r7
    3924:	10 e0       	ldi	r17, 0x00	; 0
    3926:	00 e0       	ldi	r16, 0x00	; 0
    3928:	8d 8d       	ldd	r24, Y+29	; 0x1d
    392a:	9e 8d       	ldd	r25, Y+30	; 0x1e
    392c:	00 2e       	mov	r0, r16
    392e:	02 c0       	rjmp	.+4      	; 0x3934 <limits_go_home+0x316>
    3930:	95 95       	asr	r25
    3932:	87 95       	ror	r24
    3934:	0a 94       	dec	r0
    3936:	e2 f7       	brpl	.-8      	; 0x3930 <limits_go_home+0x312>
    3938:	80 ff       	sbrs	r24, 0
    393a:	26 c0       	rjmp	.+76     	; 0x3988 <limits_go_home+0x36a>
    393c:	ab 8d       	ldd	r26, Y+27	; 0x1b
    393e:	bc 8d       	ldd	r27, Y+28	; 0x1c
    3940:	8d 90       	ld	r8, X+
    3942:	9d 90       	ld	r9, X+
    3944:	ad 90       	ld	r10, X+
    3946:	bc 90       	ld	r11, X
    3948:	13 97       	sbiw	r26, 0x03	; 3
    394a:	c1 01       	movw	r24, r2
    394c:	00 2e       	mov	r0, r16
    394e:	02 c0       	rjmp	.+4      	; 0x3954 <limits_go_home+0x336>
    3950:	95 95       	asr	r25
    3952:	87 95       	ror	r24
    3954:	0a 94       	dec	r0
    3956:	e2 f7       	brpl	.-8      	; 0x3950 <limits_go_home+0x332>
    3958:	80 ff       	sbrs	r24, 0
    395a:	41 c0       	rjmp	.+130    	; 0x39de <limits_go_home+0x3c0>
    395c:	94 96       	adiw	r26, 0x24	; 36
    395e:	2d 91       	ld	r18, X+
    3960:	3d 91       	ld	r19, X+
    3962:	4d 91       	ld	r20, X+
    3964:	5c 91       	ld	r21, X
    3966:	97 97       	sbiw	r26, 0x27	; 39
    3968:	c7 01       	movw	r24, r14
    396a:	b6 01       	movw	r22, r12
    396c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    3970:	a5 01       	movw	r20, r10
    3972:	94 01       	movw	r18, r8
    3974:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    3978:	0e 94 68 38 	call	0x70d0	; 0x70d0 <lround>
    397c:	ef 8d       	ldd	r30, Y+31	; 0x1f
    397e:	f8 a1       	ldd	r31, Y+32	; 0x20
    3980:	60 83       	st	Z, r22
    3982:	71 83       	std	Z+1, r23	; 0x01
    3984:	82 83       	std	Z+2, r24	; 0x02
    3986:	93 83       	std	Z+3, r25	; 0x03
    3988:	0f 5f       	subi	r16, 0xFF	; 255
    398a:	1f 4f       	sbci	r17, 0xFF	; 255
    398c:	2f 8d       	ldd	r18, Y+31	; 0x1f
    398e:	38 a1       	ldd	r19, Y+32	; 0x20
    3990:	2c 5f       	subi	r18, 0xFC	; 252
    3992:	3f 4f       	sbci	r19, 0xFF	; 255
    3994:	38 a3       	std	Y+32, r19	; 0x20
    3996:	2f 8f       	std	Y+31, r18	; 0x1f
    3998:	8b 8d       	ldd	r24, Y+27	; 0x1b
    399a:	9c 8d       	ldd	r25, Y+28	; 0x1c
    399c:	04 96       	adiw	r24, 0x04	; 4
    399e:	9c 8f       	std	Y+28, r25	; 0x1c
    39a0:	8b 8f       	std	Y+27, r24	; 0x1b
    39a2:	03 30       	cpi	r16, 0x03	; 3
    39a4:	11 05       	cpc	r17, r1
    39a6:	09 f0       	breq	.+2      	; 0x39aa <limits_go_home+0x38c>
    39a8:	bf cf       	rjmp	.-130    	; 0x3928 <limits_go_home+0x30a>
    39aa:	10 92 35 06 	sts	0x0635, r1	; 0x800635 <sys+0x4>
    39ae:	6a cf       	rjmp	.-300    	; 0x3884 <limits_go_home+0x266>
    39b0:	81 2f       	mov	r24, r17
    39b2:	8c 71       	andi	r24, 0x1C	; 28
    39b4:	09 f0       	breq	.+2      	; 0x39b8 <limits_go_home+0x39a>
    39b6:	23 cf       	rjmp	.-442    	; 0x37fe <limits_go_home+0x1e0>
    39b8:	81 cf       	rjmp	.-254    	; 0x38bc <limits_go_home+0x29e>
    39ba:	af e9       	ldi	r26, 0x9F	; 159
    39bc:	bf e0       	ldi	r27, 0x0F	; 15
    39be:	11 97       	sbiw	r26, 0x01	; 1
    39c0:	f1 f7       	brne	.-4      	; 0x39be <limits_go_home+0x3a0>
    39c2:	00 c0       	rjmp	.+0      	; 0x39c4 <limits_go_home+0x3a6>
    39c4:	00 00       	nop
    39c6:	80 cf       	rjmp	.-256    	; 0x38c8 <limits_go_home+0x2aa>
    39c8:	20 90 8d 06 	lds	r2, 0x068D	; 0x80068d <settings+0x4b>
    39cc:	30 90 8e 06 	lds	r3, 0x068E	; 0x80068e <settings+0x4c>
    39d0:	40 90 8f 06 	lds	r4, 0x068F	; 0x80068f <settings+0x4d>
    39d4:	50 90 90 06 	lds	r5, 0x0690	; 0x800690 <settings+0x4e>
    39d8:	46 01       	movw	r8, r12
    39da:	57 01       	movw	r10, r14
    39dc:	97 cf       	rjmp	.-210    	; 0x390c <limits_go_home+0x2ee>
    39de:	a5 01       	movw	r20, r10
    39e0:	94 01       	movw	r18, r8
    39e2:	c3 01       	movw	r24, r6
    39e4:	b2 01       	movw	r22, r4
    39e6:	c6 cf       	rjmp	.-116    	; 0x3974 <limits_go_home+0x356>
    39e8:	12 ff       	sbrs	r17, 2
    39ea:	44 cf       	rjmp	.-376    	; 0x3874 <limits_go_home+0x256>
    39ec:	89 e0       	ldi	r24, 0x09	; 9
    39ee:	40 cf       	rjmp	.-384    	; 0x3870 <limits_go_home+0x252>

000039f0 <delay_sec>:
    39f0:	1f 93       	push	r17
    39f2:	cf 93       	push	r28
    39f4:	df 93       	push	r29
    39f6:	14 2f       	mov	r17, r20
    39f8:	20 e0       	ldi	r18, 0x00	; 0
    39fa:	30 e0       	ldi	r19, 0x00	; 0
    39fc:	40 ea       	ldi	r20, 0xA0	; 160
    39fe:	51 e4       	ldi	r21, 0x41	; 65
    3a00:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    3a04:	0e 94 22 36 	call	0x6c44	; 0x6c44 <ceil>
    3a08:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    3a0c:	eb 01       	movw	r28, r22
    3a0e:	20 97       	sbiw	r28, 0x00	; 0
    3a10:	c9 f0       	breq	.+50     	; 0x3a44 <delay_sec+0x54>
    3a12:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3a16:	81 11       	cpse	r24, r1
    3a18:	15 c0       	rjmp	.+42     	; 0x3a44 <delay_sec+0x54>
    3a1a:	11 11       	cpse	r17, r1
    3a1c:	0d c0       	rjmp	.+26     	; 0x3a38 <delay_sec+0x48>
    3a1e:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3a22:	2f ef       	ldi	r18, 0xFF	; 255
    3a24:	80 e7       	ldi	r24, 0x70	; 112
    3a26:	92 e0       	ldi	r25, 0x02	; 2
    3a28:	21 50       	subi	r18, 0x01	; 1
    3a2a:	80 40       	sbci	r24, 0x00	; 0
    3a2c:	90 40       	sbci	r25, 0x00	; 0
    3a2e:	e1 f7       	brne	.-8      	; 0x3a28 <delay_sec+0x38>
    3a30:	00 c0       	rjmp	.+0      	; 0x3a32 <delay_sec+0x42>
    3a32:	00 00       	nop
    3a34:	21 97       	sbiw	r28, 0x01	; 1
    3a36:	eb cf       	rjmp	.-42     	; 0x3a0e <delay_sec+0x1e>
    3a38:	0e 94 b7 15 	call	0x2b6e	; 0x2b6e <protocol_exec_rt_system>
    3a3c:	80 91 33 06 	lds	r24, 0x0633	; 0x800633 <sys+0x2>
    3a40:	81 ff       	sbrs	r24, 1
    3a42:	ef cf       	rjmp	.-34     	; 0x3a22 <delay_sec+0x32>
    3a44:	df 91       	pop	r29
    3a46:	cf 91       	pop	r28
    3a48:	1f 91       	pop	r17
    3a4a:	08 95       	ret

00003a4c <protocol_buffer_synchronize>:
    3a4c:	0e 94 92 06 	call	0xd24	; 0xd24 <protocol_auto_cycle_start>
    3a50:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3a54:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3a58:	81 11       	cpse	r24, r1
    3a5a:	08 c0       	rjmp	.+16     	; 0x3a6c <protocol_buffer_synchronize+0x20>
    3a5c:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
    3a60:	89 2b       	or	r24, r25
    3a62:	b1 f7       	brne	.-20     	; 0x3a50 <protocol_buffer_synchronize+0x4>
    3a64:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3a68:	88 30       	cpi	r24, 0x08	; 8
    3a6a:	91 f3       	breq	.-28     	; 0x3a50 <protocol_buffer_synchronize+0x4>
    3a6c:	08 95       	ret

00003a6e <settings_read_startup_line.constprop.7>:
    3a6e:	cf 93       	push	r28
    3a70:	df 93       	push	r29
    3a72:	91 e5       	ldi	r25, 0x51	; 81
    3a74:	89 9f       	mul	r24, r25
    3a76:	e0 01       	movw	r28, r0
    3a78:	11 24       	eor	r1, r1
    3a7a:	dd 5f       	subi	r29, 0xFD	; 253
    3a7c:	40 e5       	ldi	r20, 0x50	; 80
    3a7e:	50 e0       	ldi	r21, 0x00	; 0
    3a80:	be 01       	movw	r22, r28
    3a82:	81 e1       	ldi	r24, 0x11	; 17
    3a84:	97 e0       	ldi	r25, 0x07	; 7
    3a86:	0e 94 8b 04 	call	0x916	; 0x916 <memcpy_from_eeprom_with_checksum>
    3a8a:	89 2b       	or	r24, r25
    3a8c:	79 f4       	brne	.+30     	; 0x3aac <settings_read_startup_line.constprop.7+0x3e>
    3a8e:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    3a92:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    3a96:	40 e5       	ldi	r20, 0x50	; 80
    3a98:	50 e0       	ldi	r21, 0x00	; 0
    3a9a:	61 e1       	ldi	r22, 0x11	; 17
    3a9c:	77 e0       	ldi	r23, 0x07	; 7
    3a9e:	ce 01       	movw	r24, r28
    3aa0:	0e 94 3b 04 	call	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>
    3aa4:	80 e0       	ldi	r24, 0x00	; 0
    3aa6:	df 91       	pop	r29
    3aa8:	cf 91       	pop	r28
    3aaa:	08 95       	ret
    3aac:	81 e0       	ldi	r24, 0x01	; 1
    3aae:	fb cf       	rjmp	.-10     	; 0x3aa6 <settings_read_startup_line.constprop.7+0x38>

00003ab0 <system_flag_wco_change>:
    3ab0:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    3ab4:	10 92 3d 06 	sts	0x063D, r1	; 0x80063d <sys+0xc>
    3ab8:	08 95       	ret

00003aba <settings_write_coord_data>:
    3aba:	0f 93       	push	r16
    3abc:	1f 93       	push	r17
    3abe:	cf 93       	push	r28
    3ac0:	c8 2f       	mov	r28, r24
    3ac2:	8b 01       	movw	r16, r22
    3ac4:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    3ac8:	2d e0       	ldi	r18, 0x0D	; 13
    3aca:	c2 9f       	mul	r28, r18
    3acc:	c0 01       	movw	r24, r0
    3ace:	11 24       	eor	r1, r1
    3ad0:	4c e0       	ldi	r20, 0x0C	; 12
    3ad2:	50 e0       	ldi	r21, 0x00	; 0
    3ad4:	b8 01       	movw	r22, r16
    3ad6:	9e 5f       	subi	r25, 0xFE	; 254
    3ad8:	cf 91       	pop	r28
    3ada:	1f 91       	pop	r17
    3adc:	0f 91       	pop	r16
    3ade:	0c 94 3b 04 	jmp	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>

00003ae2 <settings_read_coord_data>:
    3ae2:	1f 93       	push	r17
    3ae4:	cf 93       	push	r28
    3ae6:	df 93       	push	r29
    3ae8:	18 2f       	mov	r17, r24
    3aea:	eb 01       	movw	r28, r22
    3aec:	8d e0       	ldi	r24, 0x0D	; 13
    3aee:	18 9f       	mul	r17, r24
    3af0:	b0 01       	movw	r22, r0
    3af2:	11 24       	eor	r1, r1
    3af4:	7e 5f       	subi	r23, 0xFE	; 254
    3af6:	4c e0       	ldi	r20, 0x0C	; 12
    3af8:	50 e0       	ldi	r21, 0x00	; 0
    3afa:	ce 01       	movw	r24, r28
    3afc:	0e 94 8b 04 	call	0x916	; 0x916 <memcpy_from_eeprom_with_checksum>
    3b00:	89 2b       	or	r24, r25
    3b02:	71 f4       	brne	.+28     	; 0x3b20 <settings_read_coord_data+0x3e>
    3b04:	8c e0       	ldi	r24, 0x0C	; 12
    3b06:	fe 01       	movw	r30, r28
    3b08:	11 92       	st	Z+, r1
    3b0a:	8a 95       	dec	r24
    3b0c:	e9 f7       	brne	.-6      	; 0x3b08 <settings_read_coord_data+0x26>
    3b0e:	be 01       	movw	r22, r28
    3b10:	81 2f       	mov	r24, r17
    3b12:	0e 94 5d 1d 	call	0x3aba	; 0x3aba <settings_write_coord_data>
    3b16:	80 e0       	ldi	r24, 0x00	; 0
    3b18:	df 91       	pop	r29
    3b1a:	cf 91       	pop	r28
    3b1c:	1f 91       	pop	r17
    3b1e:	08 95       	ret
    3b20:	81 e0       	ldi	r24, 0x01	; 1
    3b22:	fa cf       	rjmp	.-12     	; 0x3b18 <settings_read_coord_data+0x36>

00003b24 <settings_restore>:
    3b24:	ef 92       	push	r14
    3b26:	ff 92       	push	r15
    3b28:	0f 93       	push	r16
    3b2a:	1f 93       	push	r17
    3b2c:	cf 93       	push	r28
    3b2e:	df 93       	push	r29
    3b30:	cd b7       	in	r28, 0x3d	; 61
    3b32:	de b7       	in	r29, 0x3e	; 62
    3b34:	2c 97       	sbiw	r28, 0x0c	; 12
    3b36:	0f b6       	in	r0, 0x3f	; 63
    3b38:	f8 94       	cli
    3b3a:	de bf       	out	0x3e, r29	; 62
    3b3c:	0f be       	out	0x3f, r0	; 63
    3b3e:	cd bf       	out	0x3d, r28	; 61
    3b40:	18 2f       	mov	r17, r24
    3b42:	80 ff       	sbrs	r24, 0
    3b44:	0b c0       	rjmp	.+22     	; 0x3b5c <settings_restore+0x38>
    3b46:	85 e5       	ldi	r24, 0x55	; 85
    3b48:	e9 ec       	ldi	r30, 0xC9	; 201
    3b4a:	f1 e0       	ldi	r31, 0x01	; 1
    3b4c:	a2 e4       	ldi	r26, 0x42	; 66
    3b4e:	b6 e0       	ldi	r27, 0x06	; 6
    3b50:	05 90       	lpm	r0, Z+
    3b52:	0d 92       	st	X+, r0
    3b54:	8a 95       	dec	r24
    3b56:	e1 f7       	brne	.-8      	; 0x3b50 <settings_restore+0x2c>
    3b58:	0e 94 76 04 	call	0x8ec	; 0x8ec <write_global_settings>
    3b5c:	11 ff       	sbrs	r17, 1
    3b5e:	10 c0       	rjmp	.+32     	; 0x3b80 <settings_restore+0x5c>
    3b60:	ce 01       	movw	r24, r28
    3b62:	01 96       	adiw	r24, 0x01	; 1
    3b64:	7c 01       	movw	r14, r24
    3b66:	8c e0       	ldi	r24, 0x0C	; 12
    3b68:	f7 01       	movw	r30, r14
    3b6a:	11 92       	st	Z+, r1
    3b6c:	8a 95       	dec	r24
    3b6e:	e9 f7       	brne	.-6      	; 0x3b6a <settings_restore+0x46>
    3b70:	00 e0       	ldi	r16, 0x00	; 0
    3b72:	b7 01       	movw	r22, r14
    3b74:	80 2f       	mov	r24, r16
    3b76:	0e 94 5d 1d 	call	0x3aba	; 0x3aba <settings_write_coord_data>
    3b7a:	0f 5f       	subi	r16, 0xFF	; 255
    3b7c:	08 30       	cpi	r16, 0x08	; 8
    3b7e:	c9 f7       	brne	.-14     	; 0x3b72 <settings_restore+0x4e>
    3b80:	12 ff       	sbrs	r17, 2
    3b82:	14 c0       	rjmp	.+40     	; 0x3bac <settings_restore+0x88>
    3b84:	60 e0       	ldi	r22, 0x00	; 0
    3b86:	80 e0       	ldi	r24, 0x00	; 0
    3b88:	93 e0       	ldi	r25, 0x03	; 3
    3b8a:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3b8e:	60 e0       	ldi	r22, 0x00	; 0
    3b90:	81 e0       	ldi	r24, 0x01	; 1
    3b92:	93 e0       	ldi	r25, 0x03	; 3
    3b94:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3b98:	60 e0       	ldi	r22, 0x00	; 0
    3b9a:	81 e5       	ldi	r24, 0x51	; 81
    3b9c:	93 e0       	ldi	r25, 0x03	; 3
    3b9e:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3ba2:	60 e0       	ldi	r22, 0x00	; 0
    3ba4:	82 e5       	ldi	r24, 0x52	; 82
    3ba6:	93 e0       	ldi	r25, 0x03	; 3
    3ba8:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3bac:	13 ff       	sbrs	r17, 3
    3bae:	0a c0       	rjmp	.+20     	; 0x3bc4 <settings_restore+0xa0>
    3bb0:	60 e0       	ldi	r22, 0x00	; 0
    3bb2:	8e ea       	ldi	r24, 0xAE	; 174
    3bb4:	93 e0       	ldi	r25, 0x03	; 3
    3bb6:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3bba:	60 e0       	ldi	r22, 0x00	; 0
    3bbc:	8f ea       	ldi	r24, 0xAF	; 175
    3bbe:	93 e0       	ldi	r25, 0x03	; 3
    3bc0:	0e 94 1b 04 	call	0x836	; 0x836 <eeprom_put_char>
    3bc4:	2c 96       	adiw	r28, 0x0c	; 12
    3bc6:	0f b6       	in	r0, 0x3f	; 63
    3bc8:	f8 94       	cli
    3bca:	de bf       	out	0x3e, r29	; 62
    3bcc:	0f be       	out	0x3f, r0	; 63
    3bce:	cd bf       	out	0x3d, r28	; 61
    3bd0:	df 91       	pop	r29
    3bd2:	cf 91       	pop	r28
    3bd4:	1f 91       	pop	r17
    3bd6:	0f 91       	pop	r16
    3bd8:	ff 90       	pop	r15
    3bda:	ef 90       	pop	r14
    3bdc:	08 95       	ret

00003bde <spindle_sync>:
    3bde:	cf 92       	push	r12
    3be0:	df 92       	push	r13
    3be2:	ef 92       	push	r14
    3be4:	ff 92       	push	r15
    3be6:	cf 93       	push	r28
    3be8:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    3bec:	92 30       	cpi	r25, 0x02	; 2
    3bee:	79 f0       	breq	.+30     	; 0x3c0e <spindle_sync+0x30>
    3bf0:	6a 01       	movw	r12, r20
    3bf2:	7b 01       	movw	r14, r22
    3bf4:	c8 2f       	mov	r28, r24
    3bf6:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    3bfa:	b7 01       	movw	r22, r14
    3bfc:	a6 01       	movw	r20, r12
    3bfe:	8c 2f       	mov	r24, r28
    3c00:	cf 91       	pop	r28
    3c02:	ff 90       	pop	r15
    3c04:	ef 90       	pop	r14
    3c06:	df 90       	pop	r13
    3c08:	cf 90       	pop	r12
    3c0a:	0c 94 cb 0a 	jmp	0x1596	; 0x1596 <spindle_set_state>
    3c0e:	cf 91       	pop	r28
    3c10:	ff 90       	pop	r15
    3c12:	ef 90       	pop	r14
    3c14:	df 90       	pop	r13
    3c16:	cf 90       	pop	r12
    3c18:	08 95       	ret

00003c1a <mc_line>:
    3c1a:	ff 92       	push	r15
    3c1c:	0f 93       	push	r16
    3c1e:	1f 93       	push	r17
    3c20:	cf 93       	push	r28
    3c22:	df 93       	push	r29
    3c24:	8c 01       	movw	r16, r24
    3c26:	eb 01       	movw	r28, r22
    3c28:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3c2c:	85 ff       	sbrs	r24, 5
    3c2e:	23 c0       	rjmp	.+70     	; 0x3c76 <mc_line+0x5c>
    3c30:	f0 90 31 06 	lds	r15, 0x0631	; 0x800631 <sys>
    3c34:	80 e2       	ldi	r24, 0x20	; 32
    3c36:	f8 16       	cp	r15, r24
    3c38:	11 f1       	breq	.+68     	; 0x3c7e <mc_line+0x64>
    3c3a:	c8 01       	movw	r24, r16
    3c3c:	0e 94 54 02 	call	0x4a8	; 0x4a8 <system_check_travel_limits>
    3c40:	88 23       	and	r24, r24
    3c42:	c9 f0       	breq	.+50     	; 0x3c76 <mc_line+0x5c>
    3c44:	81 e0       	ldi	r24, 0x01	; 1
    3c46:	80 93 34 06 	sts	0x0634, r24	; 0x800634 <sys+0x3>
    3c4a:	88 e0       	ldi	r24, 0x08	; 8
    3c4c:	f8 12       	cpse	r15, r24
    3c4e:	0c c0       	rjmp	.+24     	; 0x3c68 <mc_line+0x4e>
    3c50:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    3c54:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3c58:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3c5c:	81 11       	cpse	r24, r1
    3c5e:	0b c0       	rjmp	.+22     	; 0x3c76 <mc_line+0x5c>
    3c60:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3c64:	81 11       	cpse	r24, r1
    3c66:	f6 cf       	rjmp	.-20     	; 0x3c54 <mc_line+0x3a>
    3c68:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    3c6c:	82 e0       	ldi	r24, 0x02	; 2
    3c6e:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    3c72:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3c76:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    3c7a:	82 30       	cpi	r24, 0x02	; 2
    3c7c:	41 f1       	breq	.+80     	; 0x3cce <mc_line+0xb4>
    3c7e:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    3c82:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    3c86:	81 11       	cpse	r24, r1
    3c88:	22 c0       	rjmp	.+68     	; 0x3cce <mc_line+0xb4>
    3c8a:	90 91 d5 02 	lds	r25, 0x02D5	; 0x8002d5 <block_buffer_tail>
    3c8e:	80 91 d4 02 	lds	r24, 0x02D4	; 0x8002d4 <next_buffer_head>
    3c92:	98 13       	cpse	r25, r24
    3c94:	03 c0       	rjmp	.+6      	; 0x3c9c <mc_line+0x82>
    3c96:	0e 94 92 06 	call	0xd24	; 0xd24 <protocol_auto_cycle_start>
    3c9a:	f1 cf       	rjmp	.-30     	; 0x3c7e <mc_line+0x64>
    3c9c:	be 01       	movw	r22, r28
    3c9e:	c8 01       	movw	r24, r16
    3ca0:	0e 94 f6 0a 	call	0x15ec	; 0x15ec <plan_buffer_line>
    3ca4:	81 11       	cpse	r24, r1
    3ca6:	13 c0       	rjmp	.+38     	; 0x3cce <mc_line+0xb4>
    3ca8:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    3cac:	81 ff       	sbrs	r24, 1
    3cae:	0f c0       	rjmp	.+30     	; 0x3cce <mc_line+0xb4>
    3cb0:	88 85       	ldd	r24, Y+8	; 0x08
    3cb2:	84 ff       	sbrs	r24, 4
    3cb4:	0c c0       	rjmp	.+24     	; 0x3cce <mc_line+0xb4>
    3cb6:	4c 81       	ldd	r20, Y+4	; 0x04
    3cb8:	5d 81       	ldd	r21, Y+5	; 0x05
    3cba:	6e 81       	ldd	r22, Y+6	; 0x06
    3cbc:	7f 81       	ldd	r23, Y+7	; 0x07
    3cbe:	80 e1       	ldi	r24, 0x10	; 16
    3cc0:	df 91       	pop	r29
    3cc2:	cf 91       	pop	r28
    3cc4:	1f 91       	pop	r17
    3cc6:	0f 91       	pop	r16
    3cc8:	ff 90       	pop	r15
    3cca:	0c 94 ef 1d 	jmp	0x3bde	; 0x3bde <spindle_sync>
    3cce:	df 91       	pop	r29
    3cd0:	cf 91       	pop	r28
    3cd2:	1f 91       	pop	r17
    3cd4:	0f 91       	pop	r16
    3cd6:	ff 90       	pop	r15
    3cd8:	08 95       	ret

00003cda <gc_execute_line.constprop.11>:
    3cda:	2f 92       	push	r2
    3cdc:	3f 92       	push	r3
    3cde:	4f 92       	push	r4
    3ce0:	5f 92       	push	r5
    3ce2:	6f 92       	push	r6
    3ce4:	7f 92       	push	r7
    3ce6:	8f 92       	push	r8
    3ce8:	9f 92       	push	r9
    3cea:	af 92       	push	r10
    3cec:	bf 92       	push	r11
    3cee:	cf 92       	push	r12
    3cf0:	df 92       	push	r13
    3cf2:	ef 92       	push	r14
    3cf4:	ff 92       	push	r15
    3cf6:	0f 93       	push	r16
    3cf8:	1f 93       	push	r17
    3cfa:	cf 93       	push	r28
    3cfc:	df 93       	push	r29
    3cfe:	cd b7       	in	r28, 0x3d	; 61
    3d00:	de b7       	in	r29, 0x3e	; 62
    3d02:	cc 54       	subi	r28, 0x4C	; 76
    3d04:	d1 09       	sbc	r29, r1
    3d06:	0f b6       	in	r0, 0x3f	; 63
    3d08:	f8 94       	cli
    3d0a:	de bf       	out	0x3e, r29	; 62
    3d0c:	0f be       	out	0x3f, r0	; 63
    3d0e:	cd bf       	out	0x3d, r28	; 61
    3d10:	e7 ed       	ldi	r30, 0xD7	; 215
    3d12:	f6 e0       	ldi	r31, 0x06	; 6
    3d14:	8a e3       	ldi	r24, 0x3A	; 58
    3d16:	df 01       	movw	r26, r30
    3d18:	1d 92       	st	X+, r1
    3d1a:	8a 95       	dec	r24
    3d1c:	e9 f7       	brne	.-6      	; 0x3d18 <gc_execute_line.constprop.11+0x3e>
    3d1e:	8b e0       	ldi	r24, 0x0B	; 11
    3d20:	e7 e9       	ldi	r30, 0x97	; 151
    3d22:	f6 e0       	ldi	r31, 0x06	; 6
    3d24:	a8 ed       	ldi	r26, 0xD8	; 216
    3d26:	b6 e0       	ldi	r27, 0x06	; 6
    3d28:	01 90       	ld	r0, Z+
    3d2a:	0d 92       	st	X+, r0
    3d2c:	8a 95       	dec	r24
    3d2e:	e1 f7       	brne	.-8      	; 0x3d28 <gc_execute_line.constprop.11+0x4e>
    3d30:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    3d34:	84 32       	cpi	r24, 0x24	; 36
    3d36:	a1 f0       	breq	.+40     	; 0x3d60 <gc_execute_line.constprop.11+0x86>
    3d38:	1a 8e       	std	Y+26, r1	; 0x1a
    3d3a:	1b a2       	std	Y+35, r1	; 0x23
    3d3c:	31 2c       	mov	r3, r1
    3d3e:	21 2c       	mov	r2, r1
    3d40:	1e a6       	std	Y+46, r1	; 0x2e
    3d42:	1d a6       	std	Y+45, r1	; 0x2d
    3d44:	10 e0       	ldi	r17, 0x00	; 0
    3d46:	1b 8e       	std	Y+27, r1	; 0x1b
    3d48:	1f 8e       	std	Y+31, r1	; 0x1f
    3d4a:	ee 24       	eor	r14, r14
    3d4c:	e3 94       	inc	r14
    3d4e:	f1 2c       	mov	r15, r1
    3d50:	aa e0       	ldi	r26, 0x0A	; 10
    3d52:	aa 2e       	mov	r10, r26
    3d54:	b1 2c       	mov	r11, r1
    3d56:	b1 e6       	ldi	r27, 0x61	; 97
    3d58:	8b 2e       	mov	r8, r27
    3d5a:	b3 e0       	ldi	r27, 0x03	; 3
    3d5c:	9b 2e       	mov	r9, r27
    3d5e:	4e c1       	rjmp	.+668    	; 0x3ffc <gc_execute_line.constprop.11+0x322>
    3d60:	81 e0       	ldi	r24, 0x01	; 1
    3d62:	80 93 d8 06 	sts	0x06D8, r24	; 0x8006d8 <gc_block+0x1>
    3d66:	10 92 d9 06 	sts	0x06D9, r1	; 0x8006d9 <gc_block+0x2>
    3d6a:	83 e0       	ldi	r24, 0x03	; 3
    3d6c:	8a 8f       	std	Y+26, r24	; 0x1a
    3d6e:	b1 e0       	ldi	r27, 0x01	; 1
    3d70:	bb a3       	std	Y+35, r27	; 0x23
    3d72:	e4 cf       	rjmp	.-56     	; 0x3d3c <gc_execute_line.constprop.11+0x62>
    3d74:	9f eb       	ldi	r25, 0xBF	; 191
    3d76:	9d 0d       	add	r25, r13
    3d78:	9a 31       	cpi	r25, 0x1A	; 26
    3d7a:	10 f0       	brcs	.+4      	; 0x3d80 <gc_execute_line.constprop.11+0xa6>
    3d7c:	0c 94 fb 2b 	jmp	0x57f6	; 0x57f6 <gc_execute_line.constprop.11+0x1b1c>
    3d80:	8f 5f       	subi	r24, 0xFF	; 255
    3d82:	8a 8f       	std	Y+26, r24	; 0x1a
    3d84:	be 01       	movw	r22, r28
    3d86:	6a 5e       	subi	r22, 0xEA	; 234
    3d88:	7f 4f       	sbci	r23, 0xFF	; 255
    3d8a:	ce 01       	movw	r24, r28
    3d8c:	4a 96       	adiw	r24, 0x1a	; 26
    3d8e:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    3d92:	88 23       	and	r24, r24
    3d94:	11 f4       	brne	.+4      	; 0x3d9a <gc_execute_line.constprop.11+0xc0>
    3d96:	0c 94 fe 2b 	jmp	0x57fc	; 0x57fc <gc_execute_line.constprop.11+0x1b22>
    3d9a:	4e 88       	ldd	r4, Y+22	; 0x16
    3d9c:	5f 88       	ldd	r5, Y+23	; 0x17
    3d9e:	68 8c       	ldd	r6, Y+24	; 0x18
    3da0:	79 8c       	ldd	r7, Y+25	; 0x19
    3da2:	c3 01       	movw	r24, r6
    3da4:	b2 01       	movw	r22, r4
    3da6:	0e 94 7e 39 	call	0x72fc	; 0x72fc <trunc>
    3daa:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    3dae:	06 2f       	mov	r16, r22
    3db0:	70 e0       	ldi	r23, 0x00	; 0
    3db2:	90 e0       	ldi	r25, 0x00	; 0
    3db4:	80 e0       	ldi	r24, 0x00	; 0
    3db6:	0e 94 ed 36 	call	0x6dda	; 0x6dda <__floatsisf>
    3dba:	9b 01       	movw	r18, r22
    3dbc:	ac 01       	movw	r20, r24
    3dbe:	c3 01       	movw	r24, r6
    3dc0:	b2 01       	movw	r22, r4
    3dc2:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    3dc6:	20 e0       	ldi	r18, 0x00	; 0
    3dc8:	30 e0       	ldi	r19, 0x00	; 0
    3dca:	48 ec       	ldi	r20, 0xC8	; 200
    3dcc:	52 e4       	ldi	r21, 0x42	; 66
    3dce:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    3dd2:	0e 94 08 39 	call	0x7210	; 0x7210 <round>
    3dd6:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    3dda:	cb 01       	movw	r24, r22
    3ddc:	e7 e4       	ldi	r30, 0x47	; 71
    3dde:	de 16       	cp	r13, r30
    3de0:	29 f1       	breq	.+74     	; 0x3e2c <gc_execute_line.constprop.11+0x152>
    3de2:	fd e4       	ldi	r31, 0x4D	; 77
    3de4:	df 16       	cp	r13, r31
    3de6:	09 f4       	brne	.+2      	; 0x3dea <gc_execute_line.constprop.11+0x110>
    3de8:	65 c1       	rjmp	.+714    	; 0x40b4 <gc_execute_line.constprop.11+0x3da>
    3dea:	ea eb       	ldi	r30, 0xBA	; 186
    3dec:	ed 0d       	add	r30, r13
    3dee:	e5 31       	cpi	r30, 0x15	; 21
    3df0:	08 f0       	brcs	.+2      	; 0x3df4 <gc_execute_line.constprop.11+0x11a>
    3df2:	2c c0       	rjmp	.+88     	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3df4:	0e 2e       	mov	r0, r30
    3df6:	00 0c       	add	r0, r0
    3df8:	ff 0b       	sbc	r31, r31
    3dfa:	ef 5f       	subi	r30, 0xFF	; 255
    3dfc:	f0 4e       	sbci	r31, 0xE0	; 224
    3dfe:	0c 94 e6 39 	jmp	0x73cc	; 0x73cc <__tablejump2__>
    3e02:	a3 20       	and	r10, r3
    3e04:	26 1f       	adc	r18, r22
    3e06:	26 1f       	adc	r18, r22
    3e08:	d0 20       	and	r13, r0
    3e0a:	db 20       	and	r13, r11
    3e0c:	e6 20       	and	r14, r6
    3e0e:	f1 20       	and	r15, r1
    3e10:	26 1f       	adc	r18, r22
    3e12:	f5 20       	and	r15, r5
    3e14:	26 1f       	adc	r18, r22
    3e16:	03 21       	and	r16, r3
    3e18:	26 1f       	adc	r18, r22
    3e1a:	0d 21       	and	r16, r13
    3e1c:	17 21       	and	r17, r7
    3e1e:	21 21       	and	r18, r1
    3e20:	26 1f       	adc	r18, r22
    3e22:	26 1f       	adc	r18, r22
    3e24:	26 1f       	adc	r18, r22
    3e26:	31 21       	and	r19, r1
    3e28:	3e 21       	and	r19, r14
    3e2a:	4b 21       	and	r20, r11
    3e2c:	08 32       	cpi	r16, 0x28	; 40
    3e2e:	09 f4       	brne	.+2      	; 0x3e32 <gc_execute_line.constprop.11+0x158>
    3e30:	dd c0       	rjmp	.+442    	; 0x3fec <gc_execute_line.constprop.11+0x312>
    3e32:	30 f5       	brcc	.+76     	; 0x3e80 <gc_execute_line.constprop.11+0x1a6>
    3e34:	04 31       	cpi	r16, 0x14	; 20
    3e36:	60 f4       	brcc	.+24     	; 0x3e50 <gc_execute_line.constprop.11+0x176>
    3e38:	01 31       	cpi	r16, 0x11	; 17
    3e3a:	08 f0       	brcs	.+2      	; 0x3e3e <gc_execute_line.constprop.11+0x164>
    3e3c:	98 c0       	rjmp	.+304    	; 0x3f6e <gc_execute_line.constprop.11+0x294>
    3e3e:	04 30       	cpi	r16, 0x04	; 4
    3e40:	09 f4       	brne	.+2      	; 0x3e44 <gc_execute_line.constprop.11+0x16a>
    3e42:	74 c0       	rjmp	.+232    	; 0x3f2c <gc_execute_line.constprop.11+0x252>
    3e44:	b0 f0       	brcs	.+44     	; 0x3e72 <gc_execute_line.constprop.11+0x198>
    3e46:	0a 30       	cpi	r16, 0x0A	; 10
    3e48:	09 f4       	brne	.+2      	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3e4a:	68 c0       	rjmp	.+208    	; 0x3f1c <gc_execute_line.constprop.11+0x242>
    3e4c:	84 e1       	ldi	r24, 0x14	; 20
    3e4e:	96 c0       	rjmp	.+300    	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    3e50:	0c 31       	cpi	r16, 0x1C	; 28
    3e52:	09 f4       	brne	.+2      	; 0x3e56 <gc_execute_line.constprop.11+0x17c>
    3e54:	63 c0       	rjmp	.+198    	; 0x3f1c <gc_execute_line.constprop.11+0x242>
    3e56:	40 f4       	brcc	.+16     	; 0x3e68 <gc_execute_line.constprop.11+0x18e>
    3e58:	06 31       	cpi	r16, 0x16	; 22
    3e5a:	c0 f7       	brcc	.-16     	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3e5c:	25 e1       	ldi	r18, 0x15	; 21
    3e5e:	20 1b       	sub	r18, r16
    3e60:	20 93 da 06 	sts	0x06DA, r18	; 0x8006da <gc_block+0x3>
    3e64:	26 e0       	ldi	r18, 0x06	; 6
    3e66:	87 c0       	rjmp	.+270    	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3e68:	0e 31       	cpi	r16, 0x1E	; 30
    3e6a:	09 f4       	brne	.+2      	; 0x3e6e <gc_execute_line.constprop.11+0x194>
    3e6c:	57 c0       	rjmp	.+174    	; 0x3f1c <gc_execute_line.constprop.11+0x242>
    3e6e:	06 32       	cpi	r16, 0x26	; 38
    3e70:	69 f7       	brne	.-38     	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3e72:	4f 8d       	ldd	r20, Y+31	; 0x1f
    3e74:	41 11       	cpse	r20, r1
    3e76:	0c 94 01 2c 	jmp	0x5802	; 0x5802 <gc_execute_line.constprop.11+0x1b28>
    3e7a:	a2 e0       	ldi	r26, 0x02	; 2
    3e7c:	af 8f       	std	Y+31, r26	; 0x1f
    3e7e:	28 c0       	rjmp	.+80     	; 0x3ed0 <gc_execute_line.constprop.11+0x1f6>
    3e80:	0d 33       	cpi	r16, 0x3D	; 61
    3e82:	09 f4       	brne	.+2      	; 0x3e86 <gc_execute_line.constprop.11+0x1ac>
    3e84:	ae c0       	rjmp	.+348    	; 0x3fe2 <gc_execute_line.constprop.11+0x308>
    3e86:	e0 f4       	brcc	.+56     	; 0x3ec0 <gc_execute_line.constprop.11+0x1e6>
    3e88:	05 33       	cpi	r16, 0x35	; 53
    3e8a:	09 f4       	brne	.+2      	; 0x3e8e <gc_execute_line.constprop.11+0x1b4>
    3e8c:	4f c0       	rjmp	.+158    	; 0x3f2c <gc_execute_line.constprop.11+0x252>
    3e8e:	88 f4       	brcc	.+34     	; 0x3eb2 <gc_execute_line.constprop.11+0x1d8>
    3e90:	0b 32       	cpi	r16, 0x2B	; 43
    3e92:	11 f0       	breq	.+4      	; 0x3e98 <gc_execute_line.constprop.11+0x1be>
    3e94:	01 33       	cpi	r16, 0x31	; 49
    3e96:	d1 f6       	brne	.-76     	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3e98:	bf 8d       	ldd	r27, Y+31	; 0x1f
    3e9a:	b1 11       	cpse	r27, r1
    3e9c:	0c 94 01 2c 	jmp	0x5802	; 0x5802 <gc_execute_line.constprop.11+0x1b28>
    3ea0:	01 33       	cpi	r16, 0x31	; 49
    3ea2:	09 f0       	breq	.+2      	; 0x3ea6 <gc_execute_line.constprop.11+0x1cc>
    3ea4:	95 c0       	rjmp	.+298    	; 0x3fd0 <gc_execute_line.constprop.11+0x2f6>
    3ea6:	10 92 dd 06 	sts	0x06DD, r1	; 0x8006dd <gc_block+0x6>
    3eaa:	e3 e0       	ldi	r30, 0x03	; 3
    3eac:	ef 8f       	std	Y+31, r30	; 0x1f
    3eae:	28 e0       	ldi	r18, 0x08	; 8
    3eb0:	4f c0       	rjmp	.+158    	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3eb2:	0c 33       	cpi	r16, 0x3C	; 60
    3eb4:	58 f6       	brcc	.-106    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3eb6:	06 53       	subi	r16, 0x36	; 54
    3eb8:	00 93 de 06 	sts	0x06DE, r16	; 0x8006de <gc_block+0x7>
    3ebc:	29 e0       	ldi	r18, 0x09	; 9
    3ebe:	5b c0       	rjmp	.+182    	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3ec0:	0c 35       	cpi	r16, 0x5C	; 92
    3ec2:	08 f5       	brcc	.+66     	; 0x3f06 <gc_execute_line.constprop.11+0x22c>
    3ec4:	0a 35       	cpi	r16, 0x5A	; 90
    3ec6:	08 f0       	brcs	.+2      	; 0x3eca <gc_execute_line.constprop.11+0x1f0>
    3ec8:	73 c0       	rjmp	.+230    	; 0x3fb0 <gc_execute_line.constprop.11+0x2d6>
    3eca:	00 35       	cpi	r16, 0x50	; 80
    3ecc:	09 f0       	breq	.+2      	; 0x3ed0 <gc_execute_line.constprop.11+0x1f6>
    3ece:	be cf       	rjmp	.-132    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3ed0:	00 93 d8 06 	sts	0x06D8, r16	; 0x8006d8 <gc_block+0x1>
    3ed4:	21 e0       	ldi	r18, 0x01	; 1
    3ed6:	06 32       	cpi	r16, 0x26	; 38
    3ed8:	09 f0       	breq	.+2      	; 0x3edc <gc_execute_line.constprop.11+0x202>
    3eda:	4d c0       	rjmp	.+154    	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3edc:	84 31       	cpi	r24, 0x14	; 20
    3ede:	91 05       	cpc	r25, r1
    3ee0:	51 f0       	breq	.+20     	; 0x3ef6 <gc_execute_line.constprop.11+0x21c>
    3ee2:	8e 31       	cpi	r24, 0x1E	; 30
    3ee4:	91 05       	cpc	r25, r1
    3ee6:	39 f0       	breq	.+14     	; 0x3ef6 <gc_execute_line.constprop.11+0x21c>
    3ee8:	88 32       	cpi	r24, 0x28	; 40
    3eea:	91 05       	cpc	r25, r1
    3eec:	21 f0       	breq	.+8      	; 0x3ef6 <gc_execute_line.constprop.11+0x21c>
    3eee:	82 33       	cpi	r24, 0x32	; 50
    3ef0:	91 05       	cpc	r25, r1
    3ef2:	09 f0       	breq	.+2      	; 0x3ef6 <gc_execute_line.constprop.11+0x21c>
    3ef4:	ab cf       	rjmp	.-170    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3ef6:	b5 01       	movw	r22, r10
    3ef8:	0e 94 b0 39 	call	0x7360	; 0x7360 <__udivmodhi4>
    3efc:	66 57       	subi	r22, 0x76	; 118
    3efe:	60 93 d8 06 	sts	0x06D8, r22	; 0x8006d8 <gc_block+0x1>
    3f02:	21 e0       	ldi	r18, 0x01	; 1
    3f04:	25 c0       	rjmp	.+74     	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3f06:	0c 35       	cpi	r16, 0x5C	; 92
    3f08:	49 f0       	breq	.+18     	; 0x3f1c <gc_execute_line.constprop.11+0x242>
    3f0a:	0f 35       	cpi	r16, 0x5F	; 95
    3f0c:	08 f0       	brcs	.+2      	; 0x3f10 <gc_execute_line.constprop.11+0x236>
    3f0e:	9e cf       	rjmp	.-196    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3f10:	2e e5       	ldi	r18, 0x5E	; 94
    3f12:	20 1b       	sub	r18, r16
    3f14:	20 93 d9 06 	sts	0x06D9, r18	; 0x8006d9 <gc_block+0x2>
    3f18:	25 e0       	ldi	r18, 0x05	; 5
    3f1a:	2d c0       	rjmp	.+90     	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3f1c:	00 97       	sbiw	r24, 0x00	; 0
    3f1e:	31 f4       	brne	.+12     	; 0x3f2c <gc_execute_line.constprop.11+0x252>
    3f20:	2f 8d       	ldd	r18, Y+31	; 0x1f
    3f22:	21 11       	cpse	r18, r1
    3f24:	0c 94 01 2c 	jmp	0x5802	; 0x5802 <gc_execute_line.constprop.11+0x1b28>
    3f28:	31 e0       	ldi	r19, 0x01	; 1
    3f2a:	3f 8f       	std	Y+31, r19	; 0x1f
    3f2c:	00 93 d7 06 	sts	0x06D7, r16	; 0x8006d7 <gc_block>
    3f30:	20 2f       	mov	r18, r16
    3f32:	2d 7f       	andi	r18, 0xFD	; 253
    3f34:	2c 31       	cpi	r18, 0x1C	; 28
    3f36:	19 f0       	breq	.+6      	; 0x3f3e <gc_execute_line.constprop.11+0x264>
    3f38:	20 e0       	ldi	r18, 0x00	; 0
    3f3a:	0c 35       	cpi	r16, 0x5C	; 92
    3f3c:	e1 f4       	brne	.+56     	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3f3e:	00 97       	sbiw	r24, 0x00	; 0
    3f40:	19 f0       	breq	.+6      	; 0x3f48 <gc_execute_line.constprop.11+0x26e>
    3f42:	0a 97       	sbiw	r24, 0x0a	; 10
    3f44:	09 f0       	breq	.+2      	; 0x3f48 <gc_execute_line.constprop.11+0x26e>
    3f46:	82 cf       	rjmp	.-252    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3f48:	60 0f       	add	r22, r16
    3f4a:	60 93 d7 06 	sts	0x06D7, r22	; 0x8006d7 <gc_block>
    3f4e:	20 e0       	ldi	r18, 0x00	; 0
    3f50:	c7 01       	movw	r24, r14
    3f52:	02 c0       	rjmp	.+4      	; 0x3f58 <gc_execute_line.constprop.11+0x27e>
    3f54:	88 0f       	add	r24, r24
    3f56:	99 1f       	adc	r25, r25
    3f58:	2a 95       	dec	r18
    3f5a:	e2 f7       	brpl	.-8      	; 0x3f54 <gc_execute_line.constprop.11+0x27a>
    3f5c:	2d a5       	ldd	r18, Y+45	; 0x2d
    3f5e:	3e a5       	ldd	r19, Y+46	; 0x2e
    3f60:	28 23       	and	r18, r24
    3f62:	39 23       	and	r19, r25
    3f64:	23 2b       	or	r18, r19
    3f66:	09 f4       	brne	.+2      	; 0x3f6a <gc_execute_line.constprop.11+0x290>
    3f68:	43 c0       	rjmp	.+134    	; 0x3ff0 <gc_execute_line.constprop.11+0x316>
    3f6a:	85 e1       	ldi	r24, 0x15	; 21
    3f6c:	07 c0       	rjmp	.+14     	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    3f6e:	01 51       	subi	r16, 0x11	; 17
    3f70:	00 93 dc 06 	sts	0x06DC, r16	; 0x8006dc <gc_block+0x5>
    3f74:	22 e0       	ldi	r18, 0x02	; 2
    3f76:	89 2b       	or	r24, r25
    3f78:	59 f3       	breq	.-42     	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3f7a:	87 e1       	ldi	r24, 0x17	; 23
    3f7c:	c4 5b       	subi	r28, 0xB4	; 180
    3f7e:	df 4f       	sbci	r29, 0xFF	; 255
    3f80:	0f b6       	in	r0, 0x3f	; 63
    3f82:	f8 94       	cli
    3f84:	de bf       	out	0x3e, r29	; 62
    3f86:	0f be       	out	0x3f, r0	; 63
    3f88:	cd bf       	out	0x3d, r28	; 61
    3f8a:	df 91       	pop	r29
    3f8c:	cf 91       	pop	r28
    3f8e:	1f 91       	pop	r17
    3f90:	0f 91       	pop	r16
    3f92:	ff 90       	pop	r15
    3f94:	ef 90       	pop	r14
    3f96:	df 90       	pop	r13
    3f98:	cf 90       	pop	r12
    3f9a:	bf 90       	pop	r11
    3f9c:	af 90       	pop	r10
    3f9e:	9f 90       	pop	r9
    3fa0:	8f 90       	pop	r8
    3fa2:	7f 90       	pop	r7
    3fa4:	6f 90       	pop	r6
    3fa6:	5f 90       	pop	r5
    3fa8:	4f 90       	pop	r4
    3faa:	3f 90       	pop	r3
    3fac:	2f 90       	pop	r2
    3fae:	08 95       	ret
    3fb0:	89 2b       	or	r24, r25
    3fb2:	29 f4       	brne	.+10     	; 0x3fbe <gc_execute_line.constprop.11+0x2e4>
    3fb4:	0a 55       	subi	r16, 0x5A	; 90
    3fb6:	00 93 db 06 	sts	0x06DB, r16	; 0x8006db <gc_block+0x4>
    3fba:	23 e0       	ldi	r18, 0x03	; 3
    3fbc:	c9 cf       	rjmp	.-110    	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3fbe:	6a 30       	cpi	r22, 0x0A	; 10
    3fc0:	71 05       	cpc	r23, r1
    3fc2:	09 f0       	breq	.+2      	; 0x3fc6 <gc_execute_line.constprop.11+0x2ec>
    3fc4:	43 cf       	rjmp	.-378    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3fc6:	0a 35       	cpi	r16, 0x5A	; 90
    3fc8:	09 f4       	brne	.+2      	; 0x3fcc <gc_execute_line.constprop.11+0x2f2>
    3fca:	40 cf       	rjmp	.-384    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3fcc:	24 e0       	ldi	r18, 0x04	; 4
    3fce:	c0 cf       	rjmp	.-128    	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3fd0:	0a 97       	sbiw	r24, 0x0a	; 10
    3fd2:	09 f0       	breq	.+2      	; 0x3fd6 <gc_execute_line.constprop.11+0x2fc>
    3fd4:	3b cf       	rjmp	.-394    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3fd6:	f1 e0       	ldi	r31, 0x01	; 1
    3fd8:	f0 93 dd 06 	sts	0x06DD, r31	; 0x8006dd <gc_block+0x6>
    3fdc:	23 e0       	ldi	r18, 0x03	; 3
    3fde:	2f 8f       	std	Y+31, r18	; 0x1f
    3fe0:	66 cf       	rjmp	.-308    	; 0x3eae <gc_execute_line.constprop.11+0x1d4>
    3fe2:	89 2b       	or	r24, r25
    3fe4:	09 f0       	breq	.+2      	; 0x3fe8 <gc_execute_line.constprop.11+0x30e>
    3fe6:	32 cf       	rjmp	.-412    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    3fe8:	2a e0       	ldi	r18, 0x0A	; 10
    3fea:	b2 cf       	rjmp	.-156    	; 0x3f50 <gc_execute_line.constprop.11+0x276>
    3fec:	27 e0       	ldi	r18, 0x07	; 7
    3fee:	c3 cf       	rjmp	.-122    	; 0x3f76 <gc_execute_line.constprop.11+0x29c>
    3ff0:	ad a5       	ldd	r26, Y+45	; 0x2d
    3ff2:	be a5       	ldd	r27, Y+46	; 0x2e
    3ff4:	a8 2b       	or	r26, r24
    3ff6:	b9 2b       	or	r27, r25
    3ff8:	be a7       	std	Y+46, r27	; 0x2e
    3ffa:	ad a7       	std	Y+45, r26	; 0x2d
    3ffc:	8a 8d       	ldd	r24, Y+26	; 0x1a
    3ffe:	e8 2f       	mov	r30, r24
    4000:	f0 e0       	ldi	r31, 0x00	; 0
    4002:	ef 5e       	subi	r30, 0xEF	; 239
    4004:	f8 4f       	sbci	r31, 0xF8	; 248
    4006:	d0 80       	ld	r13, Z
    4008:	d1 10       	cpse	r13, r1
    400a:	b4 ce       	rjmp	.-664    	; 0x3d74 <gc_execute_line.constprop.11+0x9a>
    400c:	bb 8d       	ldd	r27, Y+27	; 0x1b
    400e:	bb 23       	and	r27, r27
    4010:	29 f0       	breq	.+10     	; 0x401c <gc_execute_line.constprop.11+0x342>
    4012:	ef 8d       	ldd	r30, Y+31	; 0x1f
    4014:	e1 11       	cpse	r30, r1
    4016:	02 c0       	rjmp	.+4      	; 0x401c <gc_execute_line.constprop.11+0x342>
    4018:	f2 e0       	ldi	r31, 0x02	; 2
    401a:	ff 8f       	std	Y+31, r31	; 0x1f
    401c:	25 fe       	sbrs	r2, 5
    401e:	0f c0       	rjmp	.+30     	; 0x403e <gc_execute_line.constprop.11+0x364>
    4020:	80 91 f4 06 	lds	r24, 0x06F4	; 0x8006f4 <gc_block+0x1d>
    4024:	90 91 f5 06 	lds	r25, 0x06F5	; 0x8006f5 <gc_block+0x1e>
    4028:	a0 91 f6 06 	lds	r26, 0x06F6	; 0x8006f6 <gc_block+0x1f>
    402c:	b0 91 f7 06 	lds	r27, 0x06F7	; 0x8006f7 <gc_block+0x20>
    4030:	81 38       	cpi	r24, 0x81	; 129
    4032:	96 49       	sbci	r25, 0x96	; 150
    4034:	a8 49       	sbci	r26, 0x98	; 152
    4036:	b1 05       	cpc	r27, r1
    4038:	14 f0       	brlt	.+4      	; 0x403e <gc_execute_line.constprop.11+0x364>
    403a:	0c 94 0d 2c 	jmp	0x581a	; 0x581a <gc_execute_line.constprop.11+0x1b40>
    403e:	3b a1       	ldd	r19, Y+35	; 0x23
    4040:	33 23       	and	r19, r19
    4042:	09 f4       	brne	.+2      	; 0x4046 <gc_execute_line.constprop.11+0x36c>
    4044:	35 c1       	rjmp	.+618    	; 0x42b0 <gc_execute_line.constprop.11+0x5d6>
    4046:	20 fe       	sbrs	r2, 0
    4048:	45 c1       	rjmp	.+650    	; 0x42d4 <gc_execute_line.constprop.11+0x5fa>
    404a:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    404e:	81 30       	cpi	r24, 0x01	; 1
    4050:	b1 f4       	brne	.+44     	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    4052:	23 e3       	ldi	r18, 0x33	; 51
    4054:	33 e3       	ldi	r19, 0x33	; 51
    4056:	4b ec       	ldi	r20, 0xCB	; 203
    4058:	51 e4       	ldi	r21, 0x41	; 65
    405a:	60 91 e3 06 	lds	r22, 0x06E3	; 0x8006e3 <gc_block+0xc>
    405e:	70 91 e4 06 	lds	r23, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4062:	80 91 e5 06 	lds	r24, 0x06E5	; 0x8006e5 <gc_block+0xe>
    4066:	90 91 e6 06 	lds	r25, 0x06E6	; 0x8006e6 <gc_block+0xf>
    406a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    406e:	60 93 e3 06 	sts	0x06E3, r22	; 0x8006e3 <gc_block+0xc>
    4072:	70 93 e4 06 	sts	0x06E4, r23	; 0x8006e4 <gc_block+0xd>
    4076:	80 93 e5 06 	sts	0x06E5, r24	; 0x8006e5 <gc_block+0xe>
    407a:	90 93 e6 06 	sts	0x06E6, r25	; 0x8006e6 <gc_block+0xf>
    407e:	30 fc       	sbrc	r3, 0
    4080:	10 c0       	rjmp	.+32     	; 0x40a2 <gc_execute_line.constprop.11+0x3c8>
    4082:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4086:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    408a:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    408e:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    4092:	80 93 00 07 	sts	0x0700, r24	; 0x800700 <gc_block+0x29>
    4096:	90 93 01 07 	sts	0x0701, r25	; 0x800701 <gc_block+0x2a>
    409a:	a0 93 02 07 	sts	0x0702, r26	; 0x800702 <gc_block+0x2b>
    409e:	b0 93 03 07 	sts	0x0703, r27	; 0x800703 <gc_block+0x2c>
    40a2:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    40a6:	84 30       	cpi	r24, 0x04	; 4
    40a8:	09 f0       	breq	.+2      	; 0x40ac <gc_execute_line.constprop.11+0x3d2>
    40aa:	2f c1       	rjmp	.+606    	; 0x430a <gc_execute_line.constprop.11+0x630>
    40ac:	26 fc       	sbrc	r2, 6
    40ae:	2b c1       	rjmp	.+598    	; 0x4306 <gc_execute_line.constprop.11+0x62c>
    40b0:	8c e1       	ldi	r24, 0x1C	; 28
    40b2:	64 cf       	rjmp	.-312    	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    40b4:	89 2b       	or	r24, r25
    40b6:	09 f0       	breq	.+2      	; 0x40ba <gc_execute_line.constprop.11+0x3e0>
    40b8:	60 cf       	rjmp	.-320    	; 0x3f7a <gc_execute_line.constprop.11+0x2a0>
    40ba:	06 30       	cpi	r16, 0x06	; 6
    40bc:	50 f4       	brcc	.+20     	; 0x40d2 <gc_execute_line.constprop.11+0x3f8>
    40be:	03 30       	cpi	r16, 0x03	; 3
    40c0:	98 f0       	brcs	.+38     	; 0x40e8 <gc_execute_line.constprop.11+0x40e>
    40c2:	04 30       	cpi	r16, 0x04	; 4
    40c4:	d9 f0       	breq	.+54     	; 0x40fc <gc_execute_line.constprop.11+0x422>
    40c6:	80 e1       	ldi	r24, 0x10	; 16
    40c8:	05 30       	cpi	r16, 0x05	; 5
    40ca:	c9 f4       	brne	.+50     	; 0x40fe <gc_execute_line.constprop.11+0x424>
    40cc:	10 92 e1 06 	sts	0x06E1, r1	; 0x8006e1 <gc_block+0xa>
    40d0:	18 c0       	rjmp	.+48     	; 0x4102 <gc_execute_line.constprop.11+0x428>
    40d2:	08 30       	cpi	r16, 0x08	; 8
    40d4:	08 f4       	brcc	.+2      	; 0x40d8 <gc_execute_line.constprop.11+0x3fe>
    40d6:	ba ce       	rjmp	.-652    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    40d8:	0a 30       	cpi	r16, 0x0A	; 10
    40da:	48 f1       	brcs	.+82     	; 0x412e <gc_execute_line.constprop.11+0x454>
    40dc:	0e 31       	cpi	r16, 0x1E	; 30
    40de:	09 f0       	breq	.+2      	; 0x40e2 <gc_execute_line.constprop.11+0x408>
    40e0:	b5 ce       	rjmp	.-662    	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    40e2:	00 93 df 06 	sts	0x06DF, r16	; 0x8006df <gc_block+0x8>
    40e6:	04 c0       	rjmp	.+8      	; 0x40f0 <gc_execute_line.constprop.11+0x416>
    40e8:	00 23       	and	r16, r16
    40ea:	21 f0       	breq	.+8      	; 0x40f4 <gc_execute_line.constprop.11+0x41a>
    40ec:	01 30       	cpi	r16, 0x01	; 1
    40ee:	c9 f7       	brne	.-14     	; 0x40e2 <gc_execute_line.constprop.11+0x408>
    40f0:	8b e0       	ldi	r24, 0x0B	; 11
    40f2:	08 c0       	rjmp	.+16     	; 0x4104 <gc_execute_line.constprop.11+0x42a>
    40f4:	b3 e0       	ldi	r27, 0x03	; 3
    40f6:	b0 93 df 06 	sts	0x06DF, r27	; 0x8006df <gc_block+0x8>
    40fa:	fa cf       	rjmp	.-12     	; 0x40f0 <gc_execute_line.constprop.11+0x416>
    40fc:	80 e2       	ldi	r24, 0x20	; 32
    40fe:	80 93 e1 06 	sts	0x06E1, r24	; 0x8006e1 <gc_block+0xa>
    4102:	8c e0       	ldi	r24, 0x0C	; 12
    4104:	f7 01       	movw	r30, r14
    4106:	02 c0       	rjmp	.+4      	; 0x410c <gc_execute_line.constprop.11+0x432>
    4108:	ee 0f       	add	r30, r30
    410a:	ff 1f       	adc	r31, r31
    410c:	8a 95       	dec	r24
    410e:	e2 f7       	brpl	.-8      	; 0x4108 <gc_execute_line.constprop.11+0x42e>
    4110:	cf 01       	movw	r24, r30
    4112:	2d a5       	ldd	r18, Y+45	; 0x2d
    4114:	3e a5       	ldd	r19, Y+46	; 0x2e
    4116:	2e 23       	and	r18, r30
    4118:	39 23       	and	r19, r25
    411a:	23 2b       	or	r18, r19
    411c:	09 f0       	breq	.+2      	; 0x4120 <gc_execute_line.constprop.11+0x446>
    411e:	25 cf       	rjmp	.-438    	; 0x3f6a <gc_execute_line.constprop.11+0x290>
    4120:	2d a5       	ldd	r18, Y+45	; 0x2d
    4122:	3e a5       	ldd	r19, Y+46	; 0x2e
    4124:	2e 2b       	or	r18, r30
    4126:	39 2b       	or	r19, r25
    4128:	3e a7       	std	Y+46, r19	; 0x2e
    412a:	2d a7       	std	Y+45, r18	; 0x2d
    412c:	67 cf       	rjmp	.-306    	; 0x3ffc <gc_execute_line.constprop.11+0x322>
    412e:	09 30       	cpi	r16, 0x09	; 9
    4130:	39 f0       	breq	.+14     	; 0x4140 <gc_execute_line.constprop.11+0x466>
    4132:	80 91 e0 06 	lds	r24, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4136:	80 64       	ori	r24, 0x40	; 64
    4138:	80 93 e0 06 	sts	0x06E0, r24	; 0x8006e0 <gc_block+0x9>
    413c:	8d e0       	ldi	r24, 0x0D	; 13
    413e:	e2 cf       	rjmp	.-60     	; 0x4104 <gc_execute_line.constprop.11+0x42a>
    4140:	10 92 e0 06 	sts	0x06E0, r1	; 0x8006e0 <gc_block+0x9>
    4144:	fb cf       	rjmp	.-10     	; 0x413c <gc_execute_line.constprop.11+0x462>
    4146:	40 92 e3 06 	sts	0x06E3, r4	; 0x8006e3 <gc_block+0xc>
    414a:	50 92 e4 06 	sts	0x06E4, r5	; 0x8006e4 <gc_block+0xd>
    414e:	60 92 e5 06 	sts	0x06E5, r6	; 0x8006e5 <gc_block+0xe>
    4152:	70 92 e6 06 	sts	0x06E6, r7	; 0x8006e6 <gc_block+0xf>
    4156:	80 e0       	ldi	r24, 0x00	; 0
    4158:	67 01       	movw	r12, r14
    415a:	08 2e       	mov	r0, r24
    415c:	02 c0       	rjmp	.+4      	; 0x4162 <gc_execute_line.constprop.11+0x488>
    415e:	cc 0c       	add	r12, r12
    4160:	dd 1c       	adc	r13, r13
    4162:	0a 94       	dec	r0
    4164:	e2 f7       	brpl	.-8      	; 0x415e <gc_execute_line.constprop.11+0x484>
    4166:	96 01       	movw	r18, r12
    4168:	22 21       	and	r18, r2
    416a:	33 21       	and	r19, r3
    416c:	23 2b       	or	r18, r19
    416e:	11 f0       	breq	.+4      	; 0x4174 <gc_execute_line.constprop.11+0x49a>
    4170:	0c 94 07 2c 	jmp	0x580e	; 0x580e <gc_execute_line.constprop.11+0x1b34>
    4174:	d4 01       	movw	r26, r8
    4176:	02 c0       	rjmp	.+4      	; 0x417c <gc_execute_line.constprop.11+0x4a2>
    4178:	b5 95       	asr	r27
    417a:	a7 95       	ror	r26
    417c:	8a 95       	dec	r24
    417e:	e2 f7       	brpl	.-8      	; 0x4178 <gc_execute_line.constprop.11+0x49e>
    4180:	a0 ff       	sbrs	r26, 0
    4182:	0b c0       	rjmp	.+22     	; 0x419a <gc_execute_line.constprop.11+0x4c0>
    4184:	20 e0       	ldi	r18, 0x00	; 0
    4186:	30 e0       	ldi	r19, 0x00	; 0
    4188:	a9 01       	movw	r20, r18
    418a:	c3 01       	movw	r24, r6
    418c:	b2 01       	movw	r22, r4
    418e:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    4192:	87 ff       	sbrs	r24, 7
    4194:	02 c0       	rjmp	.+4      	; 0x419a <gc_execute_line.constprop.11+0x4c0>
    4196:	0c 94 0a 2c 	jmp	0x5814	; 0x5814 <gc_execute_line.constprop.11+0x1b3a>
    419a:	2c 28       	or	r2, r12
    419c:	3d 28       	or	r3, r13
    419e:	2e cf       	rjmp	.-420    	; 0x3ffc <gc_execute_line.constprop.11+0x322>
    41a0:	40 92 e7 06 	sts	0x06E7, r4	; 0x8006e7 <gc_block+0x10>
    41a4:	50 92 e8 06 	sts	0x06E8, r5	; 0x8006e8 <gc_block+0x11>
    41a8:	60 92 e9 06 	sts	0x06E9, r6	; 0x8006e9 <gc_block+0x12>
    41ac:	70 92 ea 06 	sts	0x06EA, r7	; 0x8006ea <gc_block+0x13>
    41b0:	11 60       	ori	r17, 0x01	; 1
    41b2:	81 e0       	ldi	r24, 0x01	; 1
    41b4:	d1 cf       	rjmp	.-94     	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    41b6:	40 92 eb 06 	sts	0x06EB, r4	; 0x8006eb <gc_block+0x14>
    41ba:	50 92 ec 06 	sts	0x06EC, r5	; 0x8006ec <gc_block+0x15>
    41be:	60 92 ed 06 	sts	0x06ED, r6	; 0x8006ed <gc_block+0x16>
    41c2:	70 92 ee 06 	sts	0x06EE, r7	; 0x8006ee <gc_block+0x17>
    41c6:	12 60       	ori	r17, 0x02	; 2
    41c8:	82 e0       	ldi	r24, 0x02	; 2
    41ca:	c6 cf       	rjmp	.-116    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    41cc:	40 92 ef 06 	sts	0x06EF, r4	; 0x8006ef <gc_block+0x18>
    41d0:	50 92 f0 06 	sts	0x06F0, r5	; 0x8006f0 <gc_block+0x19>
    41d4:	60 92 f1 06 	sts	0x06F1, r6	; 0x8006f1 <gc_block+0x1a>
    41d8:	70 92 f2 06 	sts	0x06F2, r7	; 0x8006f2 <gc_block+0x1b>
    41dc:	14 60       	ori	r17, 0x04	; 4
    41de:	83 e0       	ldi	r24, 0x03	; 3
    41e0:	bb cf       	rjmp	.-138    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    41e2:	00 93 f3 06 	sts	0x06F3, r16	; 0x8006f3 <gc_block+0x1c>
    41e6:	84 e0       	ldi	r24, 0x04	; 4
    41e8:	b7 cf       	rjmp	.-146    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    41ea:	c3 01       	movw	r24, r6
    41ec:	b2 01       	movw	r22, r4
    41ee:	0e 94 b5 36 	call	0x6d6a	; 0x6d6a <__fixsfsi>
    41f2:	60 93 f4 06 	sts	0x06F4, r22	; 0x8006f4 <gc_block+0x1d>
    41f6:	70 93 f5 06 	sts	0x06F5, r23	; 0x8006f5 <gc_block+0x1e>
    41fa:	80 93 f6 06 	sts	0x06F6, r24	; 0x8006f6 <gc_block+0x1f>
    41fe:	90 93 f7 06 	sts	0x06F7, r25	; 0x8006f7 <gc_block+0x20>
    4202:	85 e0       	ldi	r24, 0x05	; 5
    4204:	a9 cf       	rjmp	.-174    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    4206:	40 92 f8 06 	sts	0x06F8, r4	; 0x8006f8 <gc_block+0x21>
    420a:	50 92 f9 06 	sts	0x06F9, r5	; 0x8006f9 <gc_block+0x22>
    420e:	60 92 fa 06 	sts	0x06FA, r6	; 0x8006fa <gc_block+0x23>
    4212:	70 92 fb 06 	sts	0x06FB, r7	; 0x8006fb <gc_block+0x24>
    4216:	86 e0       	ldi	r24, 0x06	; 6
    4218:	9f cf       	rjmp	.-194    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    421a:	40 92 fc 06 	sts	0x06FC, r4	; 0x8006fc <gc_block+0x25>
    421e:	50 92 fd 06 	sts	0x06FD, r5	; 0x8006fd <gc_block+0x26>
    4222:	60 92 fe 06 	sts	0x06FE, r6	; 0x8006fe <gc_block+0x27>
    4226:	70 92 ff 06 	sts	0x06FF, r7	; 0x8006ff <gc_block+0x28>
    422a:	87 e0       	ldi	r24, 0x07	; 7
    422c:	95 cf       	rjmp	.-214    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    422e:	40 92 00 07 	sts	0x0700, r4	; 0x800700 <gc_block+0x29>
    4232:	50 92 01 07 	sts	0x0701, r5	; 0x800701 <gc_block+0x2a>
    4236:	60 92 02 07 	sts	0x0702, r6	; 0x800702 <gc_block+0x2b>
    423a:	70 92 03 07 	sts	0x0703, r7	; 0x800703 <gc_block+0x2c>
    423e:	88 e0       	ldi	r24, 0x08	; 8
    4240:	8b cf       	rjmp	.-234    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    4242:	20 e0       	ldi	r18, 0x00	; 0
    4244:	30 e0       	ldi	r19, 0x00	; 0
    4246:	4f e7       	ldi	r20, 0x7F	; 127
    4248:	53 e4       	ldi	r21, 0x43	; 67
    424a:	c3 01       	movw	r24, r6
    424c:	b2 01       	movw	r22, r4
    424e:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    4252:	18 16       	cp	r1, r24
    4254:	14 f4       	brge	.+4      	; 0x425a <gc_execute_line.constprop.11+0x580>
    4256:	0c 94 04 2c 	jmp	0x5808	; 0x5808 <gc_execute_line.constprop.11+0x1b2e>
    425a:	00 93 04 07 	sts	0x0704, r16	; 0x800704 <gc_block+0x2d>
    425e:	89 e0       	ldi	r24, 0x09	; 9
    4260:	7b cf       	rjmp	.-266    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    4262:	40 92 05 07 	sts	0x0705, r4	; 0x800705 <gc_block+0x2e>
    4266:	50 92 06 07 	sts	0x0706, r5	; 0x800706 <gc_block+0x2f>
    426a:	60 92 07 07 	sts	0x0707, r6	; 0x800707 <gc_block+0x30>
    426e:	70 92 08 07 	sts	0x0708, r7	; 0x800708 <gc_block+0x31>
    4272:	3b 8d       	ldd	r19, Y+27	; 0x1b
    4274:	31 60       	ori	r19, 0x01	; 1
    4276:	3b 8f       	std	Y+27, r19	; 0x1b
    4278:	8a e0       	ldi	r24, 0x0A	; 10
    427a:	6e cf       	rjmp	.-292    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    427c:	40 92 09 07 	sts	0x0709, r4	; 0x800709 <gc_block+0x32>
    4280:	50 92 0a 07 	sts	0x070A, r5	; 0x80070a <gc_block+0x33>
    4284:	60 92 0b 07 	sts	0x070B, r6	; 0x80070b <gc_block+0x34>
    4288:	70 92 0c 07 	sts	0x070C, r7	; 0x80070c <gc_block+0x35>
    428c:	4b 8d       	ldd	r20, Y+27	; 0x1b
    428e:	42 60       	ori	r20, 0x02	; 2
    4290:	4b 8f       	std	Y+27, r20	; 0x1b
    4292:	8b e0       	ldi	r24, 0x0B	; 11
    4294:	61 cf       	rjmp	.-318    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    4296:	40 92 0d 07 	sts	0x070D, r4	; 0x80070d <gc_block+0x36>
    429a:	50 92 0e 07 	sts	0x070E, r5	; 0x80070e <gc_block+0x37>
    429e:	60 92 0f 07 	sts	0x070F, r6	; 0x80070f <gc_block+0x38>
    42a2:	70 92 10 07 	sts	0x0710, r7	; 0x800710 <gc_block+0x39>
    42a6:	8b 8d       	ldd	r24, Y+27	; 0x1b
    42a8:	84 60       	ori	r24, 0x04	; 4
    42aa:	8b 8f       	std	Y+27, r24	; 0x1b
    42ac:	8c e0       	ldi	r24, 0x0C	; 12
    42ae:	54 cf       	rjmp	.-344    	; 0x4158 <gc_execute_line.constprop.11+0x47e>
    42b0:	80 91 d9 06 	lds	r24, 0x06D9	; 0x8006d9 <gc_block+0x2>
    42b4:	81 30       	cpi	r24, 0x01	; 1
    42b6:	81 f4       	brne	.+32     	; 0x42d8 <gc_execute_line.constprop.11+0x5fe>
    42b8:	4f 8d       	ldd	r20, Y+31	; 0x1f
    42ba:	42 30       	cpi	r20, 0x02	; 2
    42bc:	09 f0       	breq	.+2      	; 0x42c0 <gc_execute_line.constprop.11+0x5e6>
    42be:	df ce       	rjmp	.-578    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    42c0:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    42c4:	80 35       	cpi	r24, 0x50	; 80
    42c6:	09 f4       	brne	.+2      	; 0x42ca <gc_execute_line.constprop.11+0x5f0>
    42c8:	da ce       	rjmp	.-588    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    42ca:	88 23       	and	r24, r24
    42cc:	09 f4       	brne	.+2      	; 0x42d0 <gc_execute_line.constprop.11+0x5f6>
    42ce:	d7 ce       	rjmp	.-594    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    42d0:	20 fc       	sbrc	r2, 0
    42d2:	d5 ce       	rjmp	.-598    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    42d4:	86 e1       	ldi	r24, 0x16	; 22
    42d6:	52 ce       	rjmp	.-860    	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    42d8:	80 91 98 06 	lds	r24, 0x0698	; 0x800698 <gc_state+0x1>
    42dc:	81 11       	cpse	r24, r1
    42de:	cf ce       	rjmp	.-610    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    42e0:	20 fc       	sbrc	r2, 0
    42e2:	b3 ce       	rjmp	.-666    	; 0x404a <gc_execute_line.constprop.11+0x370>
    42e4:	80 91 a6 06 	lds	r24, 0x06A6	; 0x8006a6 <gc_state+0xf>
    42e8:	90 91 a7 06 	lds	r25, 0x06A7	; 0x8006a7 <gc_state+0x10>
    42ec:	a0 91 a8 06 	lds	r26, 0x06A8	; 0x8006a8 <gc_state+0x11>
    42f0:	b0 91 a9 06 	lds	r27, 0x06A9	; 0x8006a9 <gc_state+0x12>
    42f4:	80 93 e3 06 	sts	0x06E3, r24	; 0x8006e3 <gc_block+0xc>
    42f8:	90 93 e4 06 	sts	0x06E4, r25	; 0x8006e4 <gc_block+0xd>
    42fc:	a0 93 e5 06 	sts	0x06E5, r26	; 0x8006e5 <gc_block+0xe>
    4300:	b0 93 e6 06 	sts	0x06E6, r27	; 0x8006e6 <gc_block+0xf>
    4304:	bc ce       	rjmp	.-648    	; 0x407e <gc_execute_line.constprop.11+0x3a4>
    4306:	e8 94       	clt
    4308:	26 f8       	bld	r2, 6
    430a:	80 91 dc 06 	lds	r24, 0x06DC	; 0x8006dc <gc_block+0x5>
    430e:	88 23       	and	r24, r24
    4310:	59 f0       	breq	.+22     	; 0x4328 <gc_execute_line.constprop.11+0x64e>
    4312:	81 30       	cpi	r24, 0x01	; 1
    4314:	09 f4       	brne	.+2      	; 0x4318 <gc_execute_line.constprop.11+0x63e>
    4316:	bb c0       	rjmp	.+374    	; 0x448e <gc_execute_line.constprop.11+0x7b4>
    4318:	22 96       	adiw	r28, 0x02	; 2
    431a:	1f ae       	std	Y+63, r1	; 0x3f
    431c:	22 97       	sbiw	r28, 0x02	; 2
    431e:	a2 e0       	ldi	r26, 0x02	; 2
    4320:	ab af       	std	Y+59, r26	; 0x3b
    4322:	b1 e0       	ldi	r27, 0x01	; 1
    4324:	b9 af       	std	Y+57, r27	; 0x39
    4326:	07 c0       	rjmp	.+14     	; 0x4336 <gc_execute_line.constprop.11+0x65c>
    4328:	82 e0       	ldi	r24, 0x02	; 2
    432a:	22 96       	adiw	r28, 0x02	; 2
    432c:	8f af       	std	Y+63, r24	; 0x3f
    432e:	22 97       	sbiw	r28, 0x02	; 2
    4330:	91 e0       	ldi	r25, 0x01	; 1
    4332:	9b af       	std	Y+59, r25	; 0x3b
    4334:	19 ae       	std	Y+57, r1	; 0x39
    4336:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    433a:	81 30       	cpi	r24, 0x01	; 1
    433c:	71 f5       	brne	.+92     	; 0x439a <gc_execute_line.constprop.11+0x6c0>
    433e:	e7 ed       	ldi	r30, 0xD7	; 215
    4340:	ce 2e       	mov	r12, r30
    4342:	e6 e0       	ldi	r30, 0x06	; 6
    4344:	de 2e       	mov	r13, r30
    4346:	f1 2c       	mov	r15, r1
    4348:	e1 2c       	mov	r14, r1
    434a:	2b 8d       	ldd	r18, Y+27	; 0x1b
    434c:	a2 2e       	mov	r10, r18
    434e:	b1 2c       	mov	r11, r1
    4350:	c5 01       	movw	r24, r10
    4352:	0e 2c       	mov	r0, r14
    4354:	02 c0       	rjmp	.+4      	; 0x435a <gc_execute_line.constprop.11+0x680>
    4356:	95 95       	asr	r25
    4358:	87 95       	ror	r24
    435a:	0a 94       	dec	r0
    435c:	e2 f7       	brpl	.-8      	; 0x4356 <gc_execute_line.constprop.11+0x67c>
    435e:	80 ff       	sbrs	r24, 0
    4360:	12 c0       	rjmp	.+36     	; 0x4386 <gc_execute_line.constprop.11+0x6ac>
    4362:	23 e3       	ldi	r18, 0x33	; 51
    4364:	33 e3       	ldi	r19, 0x33	; 51
    4366:	4b ec       	ldi	r20, 0xCB	; 203
    4368:	51 e4       	ldi	r21, 0x41	; 65
    436a:	d6 01       	movw	r26, r12
    436c:	9e 96       	adiw	r26, 0x2e	; 46
    436e:	6d 91       	ld	r22, X+
    4370:	7d 91       	ld	r23, X+
    4372:	8d 91       	ld	r24, X+
    4374:	9c 91       	ld	r25, X
    4376:	d1 97       	sbiw	r26, 0x31	; 49
    4378:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    437c:	f6 01       	movw	r30, r12
    437e:	66 a7       	std	Z+46, r22	; 0x2e
    4380:	77 a7       	std	Z+47, r23	; 0x2f
    4382:	80 ab       	std	Z+48, r24	; 0x30
    4384:	91 ab       	std	Z+49, r25	; 0x31
    4386:	ff ef       	ldi	r31, 0xFF	; 255
    4388:	ef 1a       	sub	r14, r31
    438a:	ff 0a       	sbc	r15, r31
    438c:	24 e0       	ldi	r18, 0x04	; 4
    438e:	c2 0e       	add	r12, r18
    4390:	d1 1c       	adc	r13, r1
    4392:	33 e0       	ldi	r19, 0x03	; 3
    4394:	e3 16       	cp	r14, r19
    4396:	f1 04       	cpc	r15, r1
    4398:	d9 f6       	brne	.-74     	; 0x4350 <gc_execute_line.constprop.11+0x676>
    439a:	4f 8d       	ldd	r20, Y+31	; 0x1f
    439c:	43 30       	cpi	r20, 0x03	; 3
    439e:	49 f4       	brne	.+18     	; 0x43b2 <gc_execute_line.constprop.11+0x6d8>
    43a0:	80 91 dd 06 	lds	r24, 0x06DD	; 0x8006dd <gc_block+0x6>
    43a4:	81 30       	cpi	r24, 0x01	; 1
    43a6:	29 f4       	brne	.+10     	; 0x43b2 <gc_execute_line.constprop.11+0x6d8>
    43a8:	8b 8d       	ldd	r24, Y+27	; 0x1b
    43aa:	84 30       	cpi	r24, 0x04	; 4
    43ac:	11 f0       	breq	.+4      	; 0x43b2 <gc_execute_line.constprop.11+0x6d8>
    43ae:	0c 94 10 2c 	jmp	0x5820	; 0x5820 <gc_execute_line.constprop.11+0x1b46>
    43b2:	8c e0       	ldi	r24, 0x0C	; 12
    43b4:	eb eb       	ldi	r30, 0xBB	; 187
    43b6:	f6 e0       	ldi	r31, 0x06	; 6
    43b8:	de 01       	movw	r26, r28
    43ba:	11 96       	adiw	r26, 0x01	; 1
    43bc:	01 90       	ld	r0, Z+
    43be:	0d 92       	st	X+, r0
    43c0:	8a 95       	dec	r24
    43c2:	e1 f7       	brne	.-8      	; 0x43bc <gc_execute_line.constprop.11+0x6e2>
    43c4:	ad a5       	ldd	r26, Y+45	; 0x2d
    43c6:	be a5       	ldd	r27, Y+46	; 0x2e
    43c8:	b1 fd       	sbrc	r27, 1
    43ca:	69 c0       	rjmp	.+210    	; 0x449e <gc_execute_line.constprop.11+0x7c4>
    43cc:	00 91 d7 06 	lds	r16, 0x06D7	; 0x8006d7 <gc_block>
    43d0:	0a 30       	cpi	r16, 0x0A	; 10
    43d2:	09 f4       	brne	.+2      	; 0x43d6 <gc_execute_line.constprop.11+0x6fc>
    43d4:	78 c0       	rjmp	.+240    	; 0x44c6 <gc_execute_line.constprop.11+0x7ec>
    43d6:	0c 35       	cpi	r16, 0x5C	; 92
    43d8:	09 f4       	brne	.+2      	; 0x43dc <gc_execute_line.constprop.11+0x702>
    43da:	19 c1       	rjmp	.+562    	; 0x460e <gc_execute_line.constprop.11+0x934>
    43dc:	9f 8d       	ldd	r25, Y+31	; 0x1f
    43de:	93 30       	cpi	r25, 0x03	; 3
    43e0:	09 f4       	brne	.+2      	; 0x43e4 <gc_execute_line.constprop.11+0x70a>
    43e2:	3f c0       	rjmp	.+126    	; 0x4462 <gc_execute_line.constprop.11+0x788>
    43e4:	ab 8d       	ldd	r26, Y+27	; 0x1b
    43e6:	aa 23       	and	r26, r26
    43e8:	e1 f1       	breq	.+120    	; 0x4462 <gc_execute_line.constprop.11+0x788>
    43ea:	b0 91 db 06 	lds	r27, 0x06DB	; 0x8006db <gc_block+0x4>
    43ee:	bf a3       	std	Y+39, r27	; 0x27
    43f0:	80 91 d3 06 	lds	r24, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    43f4:	90 91 d4 06 	lds	r25, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    43f8:	a0 91 d5 06 	lds	r26, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    43fc:	b0 91 d6 06 	lds	r27, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4400:	89 a7       	std	Y+41, r24	; 0x29
    4402:	9a a7       	std	Y+42, r25	; 0x2a
    4404:	ab a7       	std	Y+43, r26	; 0x2b
    4406:	bc a7       	std	Y+44, r27	; 0x2c
    4408:	97 e9       	ldi	r25, 0x97	; 151
    440a:	a9 2e       	mov	r10, r25
    440c:	96 e0       	ldi	r25, 0x06	; 6
    440e:	b9 2e       	mov	r11, r25
    4410:	27 ed       	ldi	r18, 0xD7	; 215
    4412:	c2 2e       	mov	r12, r18
    4414:	26 e0       	ldi	r18, 0x06	; 6
    4416:	d2 2e       	mov	r13, r18
    4418:	f1 2c       	mov	r15, r1
    441a:	e1 2c       	mov	r14, r1
    441c:	9b 8d       	ldd	r25, Y+27	; 0x1b
    441e:	89 2e       	mov	r8, r25
    4420:	91 2c       	mov	r9, r1
    4422:	c4 01       	movw	r24, r8
    4424:	0e 2c       	mov	r0, r14
    4426:	02 c0       	rjmp	.+4      	; 0x442c <gc_execute_line.constprop.11+0x752>
    4428:	95 95       	asr	r25
    442a:	87 95       	ror	r24
    442c:	0a 94       	dec	r0
    442e:	e2 f7       	brpl	.-8      	; 0x4428 <gc_execute_line.constprop.11+0x74e>
    4430:	80 fd       	sbrc	r24, 0
    4432:	5d c1       	rjmp	.+698    	; 0x46ee <gc_execute_line.constprop.11+0xa14>
    4434:	f5 01       	movw	r30, r10
    4436:	80 8d       	ldd	r24, Z+24	; 0x18
    4438:	91 8d       	ldd	r25, Z+25	; 0x19
    443a:	a2 8d       	ldd	r26, Z+26	; 0x1a
    443c:	b3 8d       	ldd	r27, Z+27	; 0x1b
    443e:	f6 01       	movw	r30, r12
    4440:	86 a7       	std	Z+46, r24	; 0x2e
    4442:	97 a7       	std	Z+47, r25	; 0x2f
    4444:	a0 ab       	std	Z+48, r26	; 0x30
    4446:	b1 ab       	std	Z+49, r27	; 0x31
    4448:	ff ef       	ldi	r31, 0xFF	; 255
    444a:	ef 1a       	sub	r14, r31
    444c:	ff 0a       	sbc	r15, r31
    444e:	24 e0       	ldi	r18, 0x04	; 4
    4450:	a2 0e       	add	r10, r18
    4452:	b1 1c       	adc	r11, r1
    4454:	34 e0       	ldi	r19, 0x04	; 4
    4456:	c3 0e       	add	r12, r19
    4458:	d1 1c       	adc	r13, r1
    445a:	43 e0       	ldi	r20, 0x03	; 3
    445c:	e4 16       	cp	r14, r20
    445e:	f1 04       	cpc	r15, r1
    4460:	01 f7       	brne	.-64     	; 0x4422 <gc_execute_line.constprop.11+0x748>
    4462:	0e 31       	cpi	r16, 0x1E	; 30
    4464:	09 f4       	brne	.+2      	; 0x4468 <gc_execute_line.constprop.11+0x78e>
    4466:	94 c1       	rjmp	.+808    	; 0x4790 <gc_execute_line.constprop.11+0xab6>
    4468:	05 33       	cpi	r16, 0x35	; 53
    446a:	09 f4       	brne	.+2      	; 0x446e <gc_execute_line.constprop.11+0x794>
    446c:	b8 c1       	rjmp	.+880    	; 0x47de <gc_execute_line.constprop.11+0xb04>
    446e:	67 ee       	ldi	r22, 0xE7	; 231
    4470:	76 e0       	ldi	r23, 0x06	; 6
    4472:	86 e0       	ldi	r24, 0x06	; 6
    4474:	0c 31       	cpi	r16, 0x1C	; 28
    4476:	09 f0       	breq	.+2      	; 0x447a <gc_execute_line.constprop.11+0x7a0>
    4478:	2d c1       	rjmp	.+602    	; 0x46d4 <gc_execute_line.constprop.11+0x9fa>
    447a:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    447e:	88 23       	and	r24, r24
    4480:	01 f1       	breq	.+64     	; 0x44c2 <gc_execute_line.constprop.11+0x7e8>
    4482:	8b 8d       	ldd	r24, Y+27	; 0x1b
    4484:	81 11       	cpse	r24, r1
    4486:	88 c1       	rjmp	.+784    	; 0x4798 <gc_execute_line.constprop.11+0xabe>
    4488:	19 a6       	std	Y+41, r1	; 0x29
    448a:	1f 8e       	std	Y+31, r1	; 0x1f
    448c:	a9 c0       	rjmp	.+338    	; 0x45e0 <gc_execute_line.constprop.11+0x906>
    448e:	e1 e0       	ldi	r30, 0x01	; 1
    4490:	22 96       	adiw	r28, 0x02	; 2
    4492:	ef af       	std	Y+63, r30	; 0x3f
    4494:	22 97       	sbiw	r28, 0x02	; 2
    4496:	1b ae       	std	Y+59, r1	; 0x3b
    4498:	f2 e0       	ldi	r31, 0x02	; 2
    449a:	f9 af       	std	Y+57, r31	; 0x39
    449c:	4c cf       	rjmp	.-360    	; 0x4336 <gc_execute_line.constprop.11+0x65c>
    449e:	80 91 de 06 	lds	r24, 0x06DE	; 0x8006de <gc_block+0x7>
    44a2:	87 30       	cpi	r24, 0x07	; 7
    44a4:	10 f0       	brcs	.+4      	; 0x44aa <gc_execute_line.constprop.11+0x7d0>
    44a6:	8d e1       	ldi	r24, 0x1D	; 29
    44a8:	69 cd       	rjmp	.-1326   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    44aa:	90 91 9d 06 	lds	r25, 0x069D	; 0x80069d <gc_state+0x6>
    44ae:	89 17       	cp	r24, r25
    44b0:	09 f4       	brne	.+2      	; 0x44b4 <gc_execute_line.constprop.11+0x7da>
    44b2:	8c cf       	rjmp	.-232    	; 0x43cc <gc_execute_line.constprop.11+0x6f2>
    44b4:	be 01       	movw	r22, r28
    44b6:	6f 5f       	subi	r22, 0xFF	; 255
    44b8:	7f 4f       	sbci	r23, 0xFF	; 255
    44ba:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    44be:	81 11       	cpse	r24, r1
    44c0:	85 cf       	rjmp	.-246    	; 0x43cc <gc_execute_line.constprop.11+0x6f2>
    44c2:	87 e0       	ldi	r24, 0x07	; 7
    44c4:	5b cd       	rjmp	.-1354   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    44c6:	bb 8d       	ldd	r27, Y+27	; 0x1b
    44c8:	b1 11       	cpse	r27, r1
    44ca:	02 c0       	rjmp	.+4      	; 0x44d0 <gc_execute_line.constprop.11+0x7f6>
    44cc:	8a e1       	ldi	r24, 0x1A	; 26
    44ce:	56 cd       	rjmp	.-1364   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    44d0:	c1 01       	movw	r24, r2
    44d2:	80 75       	andi	r24, 0x50	; 80
    44d4:	99 27       	eor	r25, r25
    44d6:	89 2b       	or	r24, r25
    44d8:	09 f4       	brne	.+2      	; 0x44dc <gc_execute_line.constprop.11+0x802>
    44da:	ea cd       	rjmp	.-1068   	; 0x40b0 <gc_execute_line.constprop.11+0x3d6>
    44dc:	60 91 f8 06 	lds	r22, 0x06F8	; 0x8006f8 <gc_block+0x21>
    44e0:	70 91 f9 06 	lds	r23, 0x06F9	; 0x8006f9 <gc_block+0x22>
    44e4:	80 91 fa 06 	lds	r24, 0x06FA	; 0x8006fa <gc_block+0x23>
    44e8:	90 91 fb 06 	lds	r25, 0x06FB	; 0x8006fb <gc_block+0x24>
    44ec:	0e 94 7e 39 	call	0x72fc	; 0x72fc <trunc>
    44f0:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    44f4:	67 30       	cpi	r22, 0x07	; 7
    44f6:	b8 f6       	brcc	.-82     	; 0x44a6 <gc_execute_line.constprop.11+0x7cc>
    44f8:	80 91 f3 06 	lds	r24, 0x06F3	; 0x8006f3 <gc_block+0x1c>
    44fc:	84 31       	cpi	r24, 0x14	; 20
    44fe:	29 f0       	breq	.+10     	; 0x450a <gc_execute_line.constprop.11+0x830>
    4500:	82 30       	cpi	r24, 0x02	; 2
    4502:	09 f0       	breq	.+2      	; 0x4506 <gc_execute_line.constprop.11+0x82c>
    4504:	a3 cc       	rjmp	.-1722   	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    4506:	27 fc       	sbrc	r2, 7
    4508:	a1 cc       	rjmp	.-1726   	; 0x3e4c <gc_execute_line.constprop.11+0x172>
    450a:	66 23       	and	r22, r22
    450c:	09 f4       	brne	.+2      	; 0x4510 <gc_execute_line.constprop.11+0x836>
    450e:	74 c0       	rjmp	.+232    	; 0x45f8 <gc_execute_line.constprop.11+0x91e>
    4510:	61 50       	subi	r22, 0x01	; 1
    4512:	69 a7       	std	Y+41, r22	; 0x29
    4514:	67 ee       	ldi	r22, 0xE7	; 231
    4516:	76 e0       	ldi	r23, 0x06	; 6
    4518:	89 a5       	ldd	r24, Y+41	; 0x29
    451a:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    451e:	88 23       	and	r24, r24
    4520:	81 f2       	breq	.-96     	; 0x44c2 <gc_execute_line.constprop.11+0x7e8>
    4522:	00 91 f3 06 	lds	r16, 0x06F3	; 0x8006f3 <gc_block+0x1c>
    4526:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    452a:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    452e:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4532:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4536:	77 ed       	ldi	r23, 0xD7	; 215
    4538:	c7 2e       	mov	r12, r23
    453a:	76 e0       	ldi	r23, 0x06	; 6
    453c:	d7 2e       	mov	r13, r23
    453e:	f1 2c       	mov	r15, r1
    4540:	e1 2c       	mov	r14, r1
    4542:	3b 8d       	ldd	r19, Y+27	; 0x1b
    4544:	23 2f       	mov	r18, r19
    4546:	30 e0       	ldi	r19, 0x00	; 0
    4548:	38 a7       	std	Y+40, r19	; 0x28
    454a:	2f a3       	std	Y+39, r18	; 0x27
    454c:	8f a1       	ldd	r24, Y+39	; 0x27
    454e:	98 a5       	ldd	r25, Y+40	; 0x28
    4550:	0e 2c       	mov	r0, r14
    4552:	02 c0       	rjmp	.+4      	; 0x4558 <gc_execute_line.constprop.11+0x87e>
    4554:	95 95       	asr	r25
    4556:	87 95       	ror	r24
    4558:	0a 94       	dec	r0
    455a:	e2 f7       	brpl	.-8      	; 0x4554 <gc_execute_line.constprop.11+0x87a>
    455c:	80 ff       	sbrs	r24, 0
    455e:	33 c0       	rjmp	.+102    	; 0x45c6 <gc_execute_line.constprop.11+0x8ec>
    4560:	d6 01       	movw	r26, r12
    4562:	9e 96       	adiw	r26, 0x2e	; 46
    4564:	8d 90       	ld	r8, X+
    4566:	9d 90       	ld	r9, X+
    4568:	ad 90       	ld	r10, X+
    456a:	bc 90       	ld	r11, X
    456c:	d1 97       	sbiw	r26, 0x31	; 49
    456e:	04 31       	cpi	r16, 0x14	; 20
    4570:	09 f0       	breq	.+2      	; 0x4574 <gc_execute_line.constprop.11+0x89a>
    4572:	46 c0       	rjmp	.+140    	; 0x4600 <gc_execute_line.constprop.11+0x926>
    4574:	f7 01       	movw	r30, r14
    4576:	ee 0f       	add	r30, r30
    4578:	ff 1f       	adc	r31, r31
    457a:	ee 0f       	add	r30, r30
    457c:	ff 1f       	adc	r31, r31
    457e:	e9 56       	subi	r30, 0x69	; 105
    4580:	f9 4f       	sbci	r31, 0xF9	; 249
    4582:	20 a9       	ldd	r18, Z+48	; 0x30
    4584:	31 a9       	ldd	r19, Z+49	; 0x31
    4586:	42 a9       	ldd	r20, Z+50	; 0x32
    4588:	53 a9       	ldd	r21, Z+51	; 0x33
    458a:	60 8d       	ldd	r22, Z+24	; 0x18
    458c:	71 8d       	ldd	r23, Z+25	; 0x19
    458e:	82 8d       	ldd	r24, Z+26	; 0x1a
    4590:	93 8d       	ldd	r25, Z+27	; 0x1b
    4592:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4596:	a5 01       	movw	r20, r10
    4598:	94 01       	movw	r18, r8
    459a:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    459e:	f6 01       	movw	r30, r12
    45a0:	60 8b       	std	Z+16, r22	; 0x10
    45a2:	71 8b       	std	Z+17, r23	; 0x11
    45a4:	82 8b       	std	Z+18, r24	; 0x12
    45a6:	93 8b       	std	Z+19, r25	; 0x13
    45a8:	f2 e0       	ldi	r31, 0x02	; 2
    45aa:	ef 12       	cpse	r14, r31
    45ac:	0c c0       	rjmp	.+24     	; 0x45c6 <gc_execute_line.constprop.11+0x8ec>
    45ae:	a3 01       	movw	r20, r6
    45b0:	92 01       	movw	r18, r4
    45b2:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    45b6:	60 93 ef 06 	sts	0x06EF, r22	; 0x8006ef <gc_block+0x18>
    45ba:	70 93 f0 06 	sts	0x06F0, r23	; 0x8006f0 <gc_block+0x19>
    45be:	80 93 f1 06 	sts	0x06F1, r24	; 0x8006f1 <gc_block+0x1a>
    45c2:	90 93 f2 06 	sts	0x06F2, r25	; 0x8006f2 <gc_block+0x1b>
    45c6:	bf ef       	ldi	r27, 0xFF	; 255
    45c8:	eb 1a       	sub	r14, r27
    45ca:	fb 0a       	sbc	r15, r27
    45cc:	e4 e0       	ldi	r30, 0x04	; 4
    45ce:	ce 0e       	add	r12, r30
    45d0:	d1 1c       	adc	r13, r1
    45d2:	f3 e0       	ldi	r31, 0x03	; 3
    45d4:	ef 16       	cp	r14, r31
    45d6:	f1 04       	cpc	r15, r1
    45d8:	09 f0       	breq	.+2      	; 0x45dc <gc_execute_line.constprop.11+0x902>
    45da:	b8 cf       	rjmp	.-144    	; 0x454c <gc_execute_line.constprop.11+0x872>
    45dc:	2f ea       	ldi	r18, 0xAF	; 175
    45de:	22 22       	and	r2, r18
    45e0:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    45e4:	8f a3       	std	Y+39, r24	; 0x27
    45e6:	80 35       	cpi	r24, 0x50	; 80
    45e8:	09 f0       	breq	.+2      	; 0x45ec <gc_execute_line.constprop.11+0x912>
    45ea:	00 c1       	rjmp	.+512    	; 0x47ec <gc_execute_line.constprop.11+0xb12>
    45ec:	9b 8d       	ldd	r25, Y+27	; 0x1b
    45ee:	99 23       	and	r25, r25
    45f0:	09 f4       	brne	.+2      	; 0x45f4 <gc_execute_line.constprop.11+0x91a>
    45f2:	06 c1       	rjmp	.+524    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    45f4:	8f e1       	ldi	r24, 0x1F	; 31
    45f6:	c2 cc       	rjmp	.-1660   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    45f8:	e0 91 de 06 	lds	r30, 0x06DE	; 0x8006de <gc_block+0x7>
    45fc:	e9 a7       	std	Y+41, r30	; 0x29
    45fe:	8a cf       	rjmp	.-236    	; 0x4514 <gc_execute_line.constprop.11+0x83a>
    4600:	50 96       	adiw	r26, 0x10	; 16
    4602:	8d 92       	st	X+, r8
    4604:	9d 92       	st	X+, r9
    4606:	ad 92       	st	X+, r10
    4608:	bc 92       	st	X, r11
    460a:	53 97       	sbiw	r26, 0x13	; 19
    460c:	dc cf       	rjmp	.-72     	; 0x45c6 <gc_execute_line.constprop.11+0x8ec>
    460e:	3b 8d       	ldd	r19, Y+27	; 0x1b
    4610:	33 23       	and	r19, r19
    4612:	09 f4       	brne	.+2      	; 0x4616 <gc_execute_line.constprop.11+0x93c>
    4614:	5b cf       	rjmp	.-330    	; 0x44cc <gc_execute_line.constprop.11+0x7f2>
    4616:	40 90 d3 06 	lds	r4, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    461a:	50 90 d4 06 	lds	r5, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    461e:	60 90 d5 06 	lds	r6, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4622:	70 90 d6 06 	lds	r7, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4626:	47 e9       	ldi	r20, 0x97	; 151
    4628:	84 2e       	mov	r8, r20
    462a:	46 e0       	ldi	r20, 0x06	; 6
    462c:	94 2e       	mov	r9, r20
    462e:	ce 01       	movw	r24, r28
    4630:	01 96       	adiw	r24, 0x01	; 1
    4632:	7c 01       	movw	r14, r24
    4634:	57 ed       	ldi	r21, 0xD7	; 215
    4636:	a5 2e       	mov	r10, r21
    4638:	56 e0       	ldi	r21, 0x06	; 6
    463a:	b5 2e       	mov	r11, r21
    463c:	d1 2c       	mov	r13, r1
    463e:	c1 2c       	mov	r12, r1
    4640:	a3 2f       	mov	r26, r19
    4642:	b0 e0       	ldi	r27, 0x00	; 0
    4644:	b8 a7       	std	Y+40, r27	; 0x28
    4646:	af a3       	std	Y+39, r26	; 0x27
    4648:	8f a1       	ldd	r24, Y+39	; 0x27
    464a:	98 a5       	ldd	r25, Y+40	; 0x28
    464c:	0c 2c       	mov	r0, r12
    464e:	02 c0       	rjmp	.+4      	; 0x4654 <gc_execute_line.constprop.11+0x97a>
    4650:	95 95       	asr	r25
    4652:	87 95       	ror	r24
    4654:	0a 94       	dec	r0
    4656:	e2 f7       	brpl	.-8      	; 0x4650 <gc_execute_line.constprop.11+0x976>
    4658:	80 ff       	sbrs	r24, 0
    465a:	3e c0       	rjmp	.+124    	; 0x46d8 <gc_execute_line.constprop.11+0x9fe>
    465c:	f7 01       	movw	r30, r14
    465e:	20 81       	ld	r18, Z
    4660:	31 81       	ldd	r19, Z+1	; 0x01
    4662:	42 81       	ldd	r20, Z+2	; 0x02
    4664:	53 81       	ldd	r21, Z+3	; 0x03
    4666:	d4 01       	movw	r26, r8
    4668:	58 96       	adiw	r26, 0x18	; 24
    466a:	6d 91       	ld	r22, X+
    466c:	7d 91       	ld	r23, X+
    466e:	8d 91       	ld	r24, X+
    4670:	9c 91       	ld	r25, X
    4672:	5b 97       	sbiw	r26, 0x1b	; 27
    4674:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4678:	f5 01       	movw	r30, r10
    467a:	26 a5       	ldd	r18, Z+46	; 0x2e
    467c:	37 a5       	ldd	r19, Z+47	; 0x2f
    467e:	40 a9       	ldd	r20, Z+48	; 0x30
    4680:	51 a9       	ldd	r21, Z+49	; 0x31
    4682:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4686:	d5 01       	movw	r26, r10
    4688:	9e 96       	adiw	r26, 0x2e	; 46
    468a:	6d 93       	st	X+, r22
    468c:	7d 93       	st	X+, r23
    468e:	8d 93       	st	X+, r24
    4690:	9c 93       	st	X, r25
    4692:	d1 97       	sbiw	r26, 0x31	; 49
    4694:	b2 e0       	ldi	r27, 0x02	; 2
    4696:	cb 12       	cpse	r12, r27
    4698:	0c c0       	rjmp	.+24     	; 0x46b2 <gc_execute_line.constprop.11+0x9d8>
    469a:	a3 01       	movw	r20, r6
    469c:	92 01       	movw	r18, r4
    469e:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    46a2:	60 93 0d 07 	sts	0x070D, r22	; 0x80070d <gc_block+0x36>
    46a6:	70 93 0e 07 	sts	0x070E, r23	; 0x80070e <gc_block+0x37>
    46aa:	80 93 0f 07 	sts	0x070F, r24	; 0x80070f <gc_block+0x38>
    46ae:	90 93 10 07 	sts	0x0710, r25	; 0x800710 <gc_block+0x39>
    46b2:	ff ef       	ldi	r31, 0xFF	; 255
    46b4:	cf 1a       	sub	r12, r31
    46b6:	df 0a       	sbc	r13, r31
    46b8:	24 e0       	ldi	r18, 0x04	; 4
    46ba:	82 0e       	add	r8, r18
    46bc:	91 1c       	adc	r9, r1
    46be:	34 e0       	ldi	r19, 0x04	; 4
    46c0:	e3 0e       	add	r14, r19
    46c2:	f1 1c       	adc	r15, r1
    46c4:	44 e0       	ldi	r20, 0x04	; 4
    46c6:	a4 0e       	add	r10, r20
    46c8:	b1 1c       	adc	r11, r1
    46ca:	83 e0       	ldi	r24, 0x03	; 3
    46cc:	c8 16       	cp	r12, r24
    46ce:	d1 04       	cpc	r13, r1
    46d0:	09 f0       	breq	.+2      	; 0x46d4 <gc_execute_line.constprop.11+0x9fa>
    46d2:	ba cf       	rjmp	.-140    	; 0x4648 <gc_execute_line.constprop.11+0x96e>
    46d4:	19 a6       	std	Y+41, r1	; 0x29
    46d6:	84 cf       	rjmp	.-248    	; 0x45e0 <gc_execute_line.constprop.11+0x906>
    46d8:	f4 01       	movw	r30, r8
    46da:	80 a9       	ldd	r24, Z+48	; 0x30
    46dc:	91 a9       	ldd	r25, Z+49	; 0x31
    46de:	a2 a9       	ldd	r26, Z+50	; 0x32
    46e0:	b3 a9       	ldd	r27, Z+51	; 0x33
    46e2:	f5 01       	movw	r30, r10
    46e4:	86 a7       	std	Z+46, r24	; 0x2e
    46e6:	97 a7       	std	Z+47, r25	; 0x2f
    46e8:	a0 ab       	std	Z+48, r26	; 0x30
    46ea:	b1 ab       	std	Z+49, r27	; 0x31
    46ec:	e2 cf       	rjmp	.-60     	; 0x46b2 <gc_execute_line.constprop.11+0x9d8>
    46ee:	05 33       	cpi	r16, 0x35	; 53
    46f0:	09 f4       	brne	.+2      	; 0x46f4 <gc_execute_line.constprop.11+0xa1a>
    46f2:	aa ce       	rjmp	.-684    	; 0x4448 <gc_execute_line.constprop.11+0x76e>
    46f4:	d6 01       	movw	r26, r12
    46f6:	9e 96       	adiw	r26, 0x2e	; 46
    46f8:	4d 90       	ld	r4, X+
    46fa:	5d 90       	ld	r5, X+
    46fc:	6d 90       	ld	r6, X+
    46fe:	7c 90       	ld	r7, X
    4700:	d1 97       	sbiw	r26, 0x31	; 49
    4702:	bf a1       	ldd	r27, Y+39	; 0x27
    4704:	b1 11       	cpse	r27, r1
    4706:	33 c0       	rjmp	.+102    	; 0x476e <gc_execute_line.constprop.11+0xa94>
    4708:	f7 01       	movw	r30, r14
    470a:	ee 0f       	add	r30, r30
    470c:	ff 1f       	adc	r31, r31
    470e:	ee 0f       	add	r30, r30
    4710:	ff 1f       	adc	r31, r31
    4712:	21 e0       	ldi	r18, 0x01	; 1
    4714:	30 e0       	ldi	r19, 0x00	; 0
    4716:	2c 0f       	add	r18, r28
    4718:	3d 1f       	adc	r19, r29
    471a:	e2 0f       	add	r30, r18
    471c:	f3 1f       	adc	r31, r19
    471e:	d5 01       	movw	r26, r10
    4720:	d0 96       	adiw	r26, 0x30	; 48
    4722:	2d 91       	ld	r18, X+
    4724:	3d 91       	ld	r19, X+
    4726:	4d 91       	ld	r20, X+
    4728:	5c 91       	ld	r21, X
    472a:	d3 97       	sbiw	r26, 0x33	; 51
    472c:	60 81       	ld	r22, Z
    472e:	71 81       	ldd	r23, Z+1	; 0x01
    4730:	82 81       	ldd	r24, Z+2	; 0x02
    4732:	93 81       	ldd	r25, Z+3	; 0x03
    4734:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4738:	a3 01       	movw	r20, r6
    473a:	92 01       	movw	r18, r4
    473c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4740:	f6 01       	movw	r30, r12
    4742:	66 a7       	std	Z+46, r22	; 0x2e
    4744:	77 a7       	std	Z+47, r23	; 0x2f
    4746:	80 ab       	std	Z+48, r24	; 0x30
    4748:	91 ab       	std	Z+49, r25	; 0x31
    474a:	f2 e0       	ldi	r31, 0x02	; 2
    474c:	ef 12       	cpse	r14, r31
    474e:	7c ce       	rjmp	.-776    	; 0x4448 <gc_execute_line.constprop.11+0x76e>
    4750:	29 a5       	ldd	r18, Y+41	; 0x29
    4752:	3a a5       	ldd	r19, Y+42	; 0x2a
    4754:	4b a5       	ldd	r20, Y+43	; 0x2b
    4756:	5c a5       	ldd	r21, Y+44	; 0x2c
    4758:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    475c:	60 93 0d 07 	sts	0x070D, r22	; 0x80070d <gc_block+0x36>
    4760:	70 93 0e 07 	sts	0x070E, r23	; 0x80070e <gc_block+0x37>
    4764:	80 93 0f 07 	sts	0x070F, r24	; 0x80070f <gc_block+0x38>
    4768:	90 93 10 07 	sts	0x0710, r25	; 0x800710 <gc_block+0x39>
    476c:	6d ce       	rjmp	.-806    	; 0x4448 <gc_execute_line.constprop.11+0x76e>
    476e:	a3 01       	movw	r20, r6
    4770:	92 01       	movw	r18, r4
    4772:	d5 01       	movw	r26, r10
    4774:	58 96       	adiw	r26, 0x18	; 24
    4776:	6d 91       	ld	r22, X+
    4778:	7d 91       	ld	r23, X+
    477a:	8d 91       	ld	r24, X+
    477c:	9c 91       	ld	r25, X
    477e:	5b 97       	sbiw	r26, 0x1b	; 27
    4780:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4784:	f6 01       	movw	r30, r12
    4786:	66 a7       	std	Z+46, r22	; 0x2e
    4788:	77 a7       	std	Z+47, r23	; 0x2f
    478a:	80 ab       	std	Z+48, r24	; 0x30
    478c:	91 ab       	std	Z+49, r25	; 0x31
    478e:	5c ce       	rjmp	.-840    	; 0x4448 <gc_execute_line.constprop.11+0x76e>
    4790:	67 ee       	ldi	r22, 0xE7	; 231
    4792:	76 e0       	ldi	r23, 0x06	; 6
    4794:	87 e0       	ldi	r24, 0x07	; 7
    4796:	71 ce       	rjmp	.-798    	; 0x447a <gc_execute_line.constprop.11+0x7a0>
    4798:	a7 e9       	ldi	r26, 0x97	; 151
    479a:	b6 e0       	ldi	r27, 0x06	; 6
    479c:	e7 ed       	ldi	r30, 0xD7	; 215
    479e:	f6 e0       	ldi	r31, 0x06	; 6
    47a0:	90 e0       	ldi	r25, 0x00	; 0
    47a2:	80 e0       	ldi	r24, 0x00	; 0
    47a4:	4b 8d       	ldd	r20, Y+27	; 0x1b
    47a6:	24 2f       	mov	r18, r20
    47a8:	30 e0       	ldi	r19, 0x00	; 0
    47aa:	a9 01       	movw	r20, r18
    47ac:	08 2e       	mov	r0, r24
    47ae:	02 c0       	rjmp	.+4      	; 0x47b4 <gc_execute_line.constprop.11+0xada>
    47b0:	55 95       	asr	r21
    47b2:	47 95       	ror	r20
    47b4:	0a 94       	dec	r0
    47b6:	e2 f7       	brpl	.-8      	; 0x47b0 <gc_execute_line.constprop.11+0xad6>
    47b8:	40 fd       	sbrc	r20, 0
    47ba:	0a c0       	rjmp	.+20     	; 0x47d0 <gc_execute_line.constprop.11+0xaf6>
    47bc:	58 96       	adiw	r26, 0x18	; 24
    47be:	4d 91       	ld	r20, X+
    47c0:	5d 91       	ld	r21, X+
    47c2:	6d 91       	ld	r22, X+
    47c4:	7c 91       	ld	r23, X
    47c6:	5b 97       	sbiw	r26, 0x1b	; 27
    47c8:	40 8b       	std	Z+16, r20	; 0x10
    47ca:	51 8b       	std	Z+17, r21	; 0x11
    47cc:	62 8b       	std	Z+18, r22	; 0x12
    47ce:	73 8b       	std	Z+19, r23	; 0x13
    47d0:	01 96       	adiw	r24, 0x01	; 1
    47d2:	14 96       	adiw	r26, 0x04	; 4
    47d4:	34 96       	adiw	r30, 0x04	; 4
    47d6:	83 30       	cpi	r24, 0x03	; 3
    47d8:	91 05       	cpc	r25, r1
    47da:	39 f7       	brne	.-50     	; 0x47aa <gc_execute_line.constprop.11+0xad0>
    47dc:	7b cf       	rjmp	.-266    	; 0x46d4 <gc_execute_line.constprop.11+0x9fa>
    47de:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    47e2:	82 30       	cpi	r24, 0x02	; 2
    47e4:	08 f4       	brcc	.+2      	; 0x47e8 <gc_execute_line.constprop.11+0xb0e>
    47e6:	76 cf       	rjmp	.-276    	; 0x46d4 <gc_execute_line.constprop.11+0x9fa>
    47e8:	8e e1       	ldi	r24, 0x1E	; 30
    47ea:	c8 cb       	rjmp	.-2160   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    47ec:	af 8d       	ldd	r26, Y+31	; 0x1f
    47ee:	a2 30       	cpi	r26, 0x02	; 2
    47f0:	39 f4       	brne	.+14     	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    47f2:	bf a1       	ldd	r27, Y+39	; 0x27
    47f4:	b1 11       	cpse	r27, r1
    47f6:	73 c0       	rjmp	.+230    	; 0x48de <gc_execute_line.constprop.11+0xc04>
    47f8:	eb 8d       	ldd	r30, Y+27	; 0x1b
    47fa:	ee 23       	and	r30, r30
    47fc:	09 f4       	brne	.+2      	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    47fe:	8d c0       	rjmp	.+282    	; 0x491a <gc_execute_line.constprop.11+0xc40>
    4800:	2b a1       	ldd	r18, Y+35	; 0x23
    4802:	21 70       	andi	r18, 0x01	; 1
    4804:	eb a1       	ldd	r30, Y+35	; 0x23
    4806:	c1 01       	movw	r24, r2
    4808:	e0 ff       	sbrs	r30, 0
    480a:	d8 c2       	rjmp	.+1456   	; 0x4dbc <gc_execute_line.constprop.11+0x10e2>
    480c:	8e 7d       	andi	r24, 0xDE	; 222
    480e:	ff 8d       	ldd	r31, Y+31	; 0x1f
    4810:	f1 11       	cpse	r31, r1
    4812:	93 7e       	andi	r25, 0xE3	; 227
    4814:	89 2b       	or	r24, r25
    4816:	11 f0       	breq	.+4      	; 0x481c <gc_execute_line.constprop.11+0xb42>
    4818:	0c 94 19 2c 	jmp	0x5832	; 0x5832 <gc_execute_line.constprop.11+0x1b58>
    481c:	8e 01       	movw	r16, r28
    481e:	03 5f       	subi	r16, 0xF3	; 243
    4820:	1f 4f       	sbci	r17, 0xFF	; 255
    4822:	89 e0       	ldi	r24, 0x09	; 9
    4824:	d8 01       	movw	r26, r16
    4826:	1d 92       	st	X+, r1
    4828:	8a 95       	dec	r24
    482a:	e9 f7       	brne	.-6      	; 0x4826 <gc_execute_line.constprop.11+0xb4c>
    482c:	22 23       	and	r18, r18
    482e:	09 f4       	brne	.+2      	; 0x4832 <gc_execute_line.constprop.11+0xb58>
    4830:	c8 c2       	rjmp	.+1424   	; 0x4dc2 <gc_execute_line.constprop.11+0x10e8>
    4832:	8d a5       	ldd	r24, Y+45	; 0x2d
    4834:	9e a5       	ldd	r25, Y+46	; 0x2e
    4836:	86 7b       	andi	r24, 0xB6	; 182
    4838:	89 2b       	or	r24, r25
    483a:	11 f0       	breq	.+4      	; 0x4840 <gc_execute_line.constprop.11+0xb66>
    483c:	0c 94 1c 2c 	jmp	0x5838	; 0x5838 <gc_execute_line.constprop.11+0x1b5e>
    4840:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    4844:	85 33       	cpi	r24, 0x35	; 53
    4846:	19 f0       	breq	.+6      	; 0x484e <gc_execute_line.constprop.11+0xb74>
    4848:	81 11       	cpse	r24, r1
    484a:	0c 94 1c 2c 	jmp	0x5838	; 0x5838 <gc_execute_line.constprop.11+0x1b5e>
    484e:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4852:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4856:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    485a:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    485e:	89 8b       	std	Y+17, r24	; 0x11
    4860:	9a 8b       	std	Y+18, r25	; 0x12
    4862:	ab 8b       	std	Y+19, r26	; 0x13
    4864:	bc 8b       	std	Y+20, r27	; 0x14
    4866:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    486a:	90 91 9f 06 	lds	r25, 0x069F	; 0x80069f <gc_state+0x8>
    486e:	89 2b       	or	r24, r25
    4870:	40 91 e3 06 	lds	r20, 0x06E3	; 0x8006e3 <gc_block+0xc>
    4874:	50 91 e4 06 	lds	r21, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4878:	60 91 e5 06 	lds	r22, 0x06E5	; 0x8006e5 <gc_block+0xe>
    487c:	70 91 e6 06 	lds	r23, 0x06E6	; 0x8006e6 <gc_block+0xf>
    4880:	4d 87       	std	Y+13, r20	; 0x0d
    4882:	5e 87       	std	Y+14, r21	; 0x0e
    4884:	6f 87       	std	Y+15, r22	; 0x0f
    4886:	78 8b       	std	Y+16, r23	; 0x10
    4888:	84 60       	ori	r24, 0x04	; 4
    488a:	8d 8b       	std	Y+21, r24	; 0x15
    488c:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    4890:	85 ff       	sbrs	r24, 5
    4892:	06 c0       	rjmp	.+12     	; 0x48a0 <gc_execute_line.constprop.11+0xbc6>
    4894:	85 e0       	ldi	r24, 0x05	; 5
    4896:	97 e0       	ldi	r25, 0x07	; 7
    4898:	0e 94 54 02 	call	0x4a8	; 0x4a8 <system_check_travel_limits>
    489c:	81 11       	cpse	r24, r1
    489e:	cf c7       	rjmp	.+3998   	; 0x583e <gc_execute_line.constprop.11+0x1b64>
    48a0:	b8 01       	movw	r22, r16
    48a2:	85 e0       	ldi	r24, 0x05	; 5
    48a4:	97 e0       	ldi	r25, 0x07	; 7
    48a6:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    48aa:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    48ae:	81 11       	cpse	r24, r1
    48b0:	0b c0       	rjmp	.+22     	; 0x48c8 <gc_execute_line.constprop.11+0xbee>
    48b2:	0e 94 0b 04 	call	0x816	; 0x816 <plan_get_current_block>
    48b6:	89 2b       	or	r24, r25
    48b8:	39 f0       	breq	.+14     	; 0x48c8 <gc_execute_line.constprop.11+0xbee>
    48ba:	80 e2       	ldi	r24, 0x20	; 32
    48bc:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    48c0:	0e 94 32 0e 	call	0x1c64	; 0x1c64 <st_prep_buffer>
    48c4:	0e 94 79 06 	call	0xcf2	; 0xcf2 <st_wake_up>
    48c8:	8c e0       	ldi	r24, 0x0C	; 12
    48ca:	e5 e0       	ldi	r30, 0x05	; 5
    48cc:	f7 e0       	ldi	r31, 0x07	; 7
    48ce:	af ea       	ldi	r26, 0xAF	; 175
    48d0:	b6 e0       	ldi	r27, 0x06	; 6
    48d2:	01 90       	ld	r0, Z+
    48d4:	0d 92       	st	X+, r0
    48d6:	8a 95       	dec	r24
    48d8:	e1 f7       	brne	.-8      	; 0x48d2 <gc_execute_line.constprop.11+0xbf8>
    48da:	80 e0       	ldi	r24, 0x00	; 0
    48dc:	4f cb       	rjmp	.-2402   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    48de:	20 e0       	ldi	r18, 0x00	; 0
    48e0:	30 e0       	ldi	r19, 0x00	; 0
    48e2:	a9 01       	movw	r20, r18
    48e4:	60 91 e3 06 	lds	r22, 0x06E3	; 0x8006e3 <gc_block+0xc>
    48e8:	70 91 e4 06 	lds	r23, 0x06E4	; 0x8006e4 <gc_block+0xd>
    48ec:	80 91 e5 06 	lds	r24, 0x06E5	; 0x8006e5 <gc_block+0xe>
    48f0:	90 91 e6 06 	lds	r25, 0x06E6	; 0x8006e6 <gc_block+0xf>
    48f4:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    48f8:	88 23       	and	r24, r24
    48fa:	09 f4       	brne	.+2      	; 0x48fe <gc_execute_line.constprop.11+0xc24>
    48fc:	eb cc       	rjmp	.-1578   	; 0x42d4 <gc_execute_line.constprop.11+0x5fa>
    48fe:	ff a1       	ldd	r31, Y+39	; 0x27
    4900:	fc 38       	cpi	r31, 0x8C	; 140
    4902:	b9 f0       	breq	.+46     	; 0x4932 <gc_execute_line.constprop.11+0xc58>
    4904:	60 f4       	brcc	.+24     	; 0x491e <gc_execute_line.constprop.11+0xc44>
    4906:	f2 30       	cpi	r31, 0x02	; 2
    4908:	59 f1       	breq	.+86     	; 0x4960 <gc_execute_line.constprop.11+0xc86>
    490a:	f3 30       	cpi	r31, 0x03	; 3
    490c:	61 f1       	breq	.+88     	; 0x4966 <gc_execute_line.constprop.11+0xc8c>
    490e:	f1 30       	cpi	r31, 0x01	; 1
    4910:	09 f0       	breq	.+2      	; 0x4914 <gc_execute_line.constprop.11+0xc3a>
    4912:	76 cf       	rjmp	.-276    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    4914:	3b 8d       	ldd	r19, Y+27	; 0x1b
    4916:	31 11       	cpse	r19, r1
    4918:	73 cf       	rjmp	.-282    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    491a:	1f 8e       	std	Y+31, r1	; 0x1f
    491c:	71 cf       	rjmp	.-286    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    491e:	2f a1       	ldd	r18, Y+39	; 0x27
    4920:	2e 38       	cpi	r18, 0x8E	; 142
    4922:	39 f0       	breq	.+14     	; 0x4932 <gc_execute_line.constprop.11+0xc58>
    4924:	18 f0       	brcs	.+6      	; 0x492c <gc_execute_line.constprop.11+0xc52>
    4926:	2f 38       	cpi	r18, 0x8F	; 143
    4928:	09 f0       	breq	.+2      	; 0x492c <gc_execute_line.constprop.11+0xc52>
    492a:	6a cf       	rjmp	.-300    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    492c:	9b a1       	ldd	r25, Y+35	; 0x23
    492e:	90 61       	ori	r25, 0x10	; 16
    4930:	9b a3       	std	Y+35, r25	; 0x23
    4932:	8f a1       	ldd	r24, Y+39	; 0x27
    4934:	8e 58       	subi	r24, 0x8E	; 142
    4936:	82 30       	cpi	r24, 0x02	; 2
    4938:	18 f4       	brcc	.+6      	; 0x4940 <gc_execute_line.constprop.11+0xc66>
    493a:	ab a1       	ldd	r26, Y+35	; 0x23
    493c:	a8 60       	ori	r26, 0x08	; 8
    493e:	ab a3       	std	Y+35, r26	; 0x23
    4940:	bb 8d       	ldd	r27, Y+27	; 0x1b
    4942:	bb 23       	and	r27, r27
    4944:	09 f4       	brne	.+2      	; 0x4948 <gc_execute_line.constprop.11+0xc6e>
    4946:	c2 cd       	rjmp	.-1148   	; 0x44cc <gc_execute_line.constprop.11+0x7f2>
    4948:	4c e0       	ldi	r20, 0x0C	; 12
    494a:	50 e0       	ldi	r21, 0x00	; 0
    494c:	65 e0       	ldi	r22, 0x05	; 5
    494e:	77 e0       	ldi	r23, 0x07	; 7
    4950:	8f ea       	ldi	r24, 0xAF	; 175
    4952:	96 e0       	ldi	r25, 0x06	; 6
    4954:	0e 94 06 3a 	call	0x740c	; 0x740c <memcmp>
    4958:	89 2b       	or	r24, r25
    495a:	09 f0       	breq	.+2      	; 0x495e <gc_execute_line.constprop.11+0xc84>
    495c:	51 cf       	rjmp	.-350    	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    495e:	6d c0       	rjmp	.+218    	; 0x4a3a <gc_execute_line.constprop.11+0xd60>
    4960:	4b a1       	ldd	r20, Y+35	; 0x23
    4962:	44 60       	ori	r20, 0x04	; 4
    4964:	4b a3       	std	Y+35, r20	; 0x23
    4966:	8b 8d       	ldd	r24, Y+27	; 0x1b
    4968:	88 23       	and	r24, r24
    496a:	09 f4       	brne	.+2      	; 0x496e <gc_execute_line.constprop.11+0xc94>
    496c:	af cd       	rjmp	.-1186   	; 0x44cc <gc_execute_line.constprop.11+0x7f2>
    496e:	b9 ad       	ldd	r27, Y+57	; 0x39
    4970:	ab 2f       	mov	r26, r27
    4972:	b0 e0       	ldi	r27, 0x00	; 0
    4974:	ba ab       	std	Y+50, r27	; 0x32
    4976:	a9 ab       	std	Y+49, r26	; 0x31
    4978:	fb ad       	ldd	r31, Y+59	; 0x3b
    497a:	ef 2f       	mov	r30, r31
    497c:	f0 e0       	ldi	r31, 0x00	; 0
    497e:	fe ab       	std	Y+54, r31	; 0x36
    4980:	ed ab       	std	Y+53, r30	; 0x35
    4982:	81 e0       	ldi	r24, 0x01	; 1
    4984:	90 e0       	ldi	r25, 0x00	; 0
    4986:	7c 01       	movw	r14, r24
    4988:	09 ac       	ldd	r0, Y+57	; 0x39
    498a:	02 c0       	rjmp	.+4      	; 0x4990 <gc_execute_line.constprop.11+0xcb6>
    498c:	ee 0c       	add	r14, r14
    498e:	ff 1c       	adc	r15, r15
    4990:	0a 94       	dec	r0
    4992:	e2 f7       	brpl	.-8      	; 0x498c <gc_execute_line.constprop.11+0xcb2>
    4994:	0b ac       	ldd	r0, Y+59	; 0x3b
    4996:	02 c0       	rjmp	.+4      	; 0x499c <gc_execute_line.constprop.11+0xcc2>
    4998:	88 0f       	add	r24, r24
    499a:	99 1f       	adc	r25, r25
    499c:	0a 94       	dec	r0
    499e:	e2 f7       	brpl	.-8      	; 0x4998 <gc_execute_line.constprop.11+0xcbe>
    49a0:	e8 2a       	or	r14, r24
    49a2:	f9 2a       	or	r15, r25
    49a4:	2b 8d       	ldd	r18, Y+27	; 0x1b
    49a6:	82 2f       	mov	r24, r18
    49a8:	90 e0       	ldi	r25, 0x00	; 0
    49aa:	8e 21       	and	r24, r14
    49ac:	9f 21       	and	r25, r15
    49ae:	89 2b       	or	r24, r25
    49b0:	09 f4       	brne	.+2      	; 0x49b4 <gc_execute_line.constprop.11+0xcda>
    49b2:	39 c7       	rjmp	.+3698   	; 0x5826 <gc_execute_line.constprop.11+0x1b4c>
    49b4:	fd 01       	movw	r30, r26
    49b6:	ee 0f       	add	r30, r30
    49b8:	ff 1f       	adc	r31, r31
    49ba:	ee 0f       	add	r30, r30
    49bc:	ff 1f       	adc	r31, r31
    49be:	e9 52       	subi	r30, 0x29	; 41
    49c0:	f9 4f       	sbci	r31, 0xF9	; 249
    49c2:	aa 0f       	add	r26, r26
    49c4:	bb 1f       	adc	r27, r27
    49c6:	aa 0f       	add	r26, r26
    49c8:	bb 1f       	adc	r27, r27
    49ca:	a1 55       	subi	r26, 0x51	; 81
    49cc:	b9 4f       	sbci	r27, 0xF9	; 249
    49ce:	2d 91       	ld	r18, X+
    49d0:	3d 91       	ld	r19, X+
    49d2:	4d 91       	ld	r20, X+
    49d4:	5c 91       	ld	r21, X
    49d6:	66 a5       	ldd	r22, Z+46	; 0x2e
    49d8:	77 a5       	ldd	r23, Z+47	; 0x2f
    49da:	80 a9       	ldd	r24, Z+48	; 0x30
    49dc:	91 a9       	ldd	r25, Z+49	; 0x31
    49de:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    49e2:	2b 01       	movw	r4, r22
    49e4:	3c 01       	movw	r6, r24
    49e6:	ed a9       	ldd	r30, Y+53	; 0x35
    49e8:	fe a9       	ldd	r31, Y+54	; 0x36
    49ea:	ee 0f       	add	r30, r30
    49ec:	ff 1f       	adc	r31, r31
    49ee:	ee 0f       	add	r30, r30
    49f0:	ff 1f       	adc	r31, r31
    49f2:	e9 52       	subi	r30, 0x29	; 41
    49f4:	f9 4f       	sbci	r31, 0xF9	; 249
    49f6:	ad a9       	ldd	r26, Y+53	; 0x35
    49f8:	be a9       	ldd	r27, Y+54	; 0x36
    49fa:	aa 0f       	add	r26, r26
    49fc:	bb 1f       	adc	r27, r27
    49fe:	aa 0f       	add	r26, r26
    4a00:	bb 1f       	adc	r27, r27
    4a02:	a1 55       	subi	r26, 0x51	; 81
    4a04:	b9 4f       	sbci	r27, 0xF9	; 249
    4a06:	2d 91       	ld	r18, X+
    4a08:	3d 91       	ld	r19, X+
    4a0a:	4d 91       	ld	r20, X+
    4a0c:	5c 91       	ld	r21, X
    4a0e:	66 a5       	ldd	r22, Z+46	; 0x2e
    4a10:	77 a5       	ldd	r23, Z+47	; 0x2f
    4a12:	80 a9       	ldd	r24, Z+48	; 0x30
    4a14:	91 a9       	ldd	r25, Z+49	; 0x31
    4a16:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4a1a:	4b 01       	movw	r8, r22
    4a1c:	5c 01       	movw	r10, r24
    4a1e:	27 fe       	sbrs	r2, 7
    4a20:	ff c0       	rjmp	.+510    	; 0x4c20 <gc_execute_line.constprop.11+0xf46>
    4a22:	e8 94       	clt
    4a24:	27 f8       	bld	r2, 7
    4a26:	4c e0       	ldi	r20, 0x0C	; 12
    4a28:	50 e0       	ldi	r21, 0x00	; 0
    4a2a:	65 e0       	ldi	r22, 0x05	; 5
    4a2c:	77 e0       	ldi	r23, 0x07	; 7
    4a2e:	8f ea       	ldi	r24, 0xAF	; 175
    4a30:	96 e0       	ldi	r25, 0x06	; 6
    4a32:	0e 94 06 3a 	call	0x740c	; 0x740c <memcmp>
    4a36:	89 2b       	or	r24, r25
    4a38:	11 f4       	brne	.+4      	; 0x4a3e <gc_execute_line.constprop.11+0xd64>
    4a3a:	81 e2       	ldi	r24, 0x21	; 33
    4a3c:	9f ca       	rjmp	.-2754   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    4a3e:	60 91 fc 06 	lds	r22, 0x06FC	; 0x8006fc <gc_block+0x25>
    4a42:	70 91 fd 06 	lds	r23, 0x06FD	; 0x8006fd <gc_block+0x26>
    4a46:	80 91 fe 06 	lds	r24, 0x06FE	; 0x8006fe <gc_block+0x27>
    4a4a:	90 91 ff 06 	lds	r25, 0x06FF	; 0x8006ff <gc_block+0x28>
    4a4e:	20 91 da 06 	lds	r18, 0x06DA	; 0x8006da <gc_block+0x3>
    4a52:	21 30       	cpi	r18, 0x01	; 1
    4a54:	71 f4       	brne	.+28     	; 0x4a72 <gc_execute_line.constprop.11+0xd98>
    4a56:	23 e3       	ldi	r18, 0x33	; 51
    4a58:	33 e3       	ldi	r19, 0x33	; 51
    4a5a:	4b ec       	ldi	r20, 0xCB	; 203
    4a5c:	51 e4       	ldi	r21, 0x41	; 65
    4a5e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4a62:	60 93 fc 06 	sts	0x06FC, r22	; 0x8006fc <gc_block+0x25>
    4a66:	70 93 fd 06 	sts	0x06FD, r23	; 0x8006fd <gc_block+0x26>
    4a6a:	80 93 fe 06 	sts	0x06FE, r24	; 0x8006fe <gc_block+0x27>
    4a6e:	90 93 ff 06 	sts	0x06FF, r25	; 0x8006ff <gc_block+0x28>
    4a72:	80 91 fc 06 	lds	r24, 0x06FC	; 0x8006fc <gc_block+0x25>
    4a76:	90 91 fd 06 	lds	r25, 0x06FD	; 0x8006fd <gc_block+0x26>
    4a7a:	a0 91 fe 06 	lds	r26, 0x06FE	; 0x8006fe <gc_block+0x27>
    4a7e:	b0 91 ff 06 	lds	r27, 0x06FF	; 0x8006ff <gc_block+0x28>
    4a82:	21 96       	adiw	r28, 0x01	; 1
    4a84:	8c af       	std	Y+60, r24	; 0x3c
    4a86:	9d af       	std	Y+61, r25	; 0x3d
    4a88:	ae af       	std	Y+62, r26	; 0x3e
    4a8a:	bf af       	std	Y+63, r27	; 0x3f
    4a8c:	21 97       	sbiw	r28, 0x01	; 1
    4a8e:	a3 01       	movw	r20, r6
    4a90:	92 01       	movw	r18, r4
    4a92:	c3 01       	movw	r24, r6
    4a94:	b2 01       	movw	r22, r4
    4a96:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4a9a:	29 96       	adiw	r28, 0x09	; 9
    4a9c:	6c af       	std	Y+60, r22	; 0x3c
    4a9e:	7d af       	std	Y+61, r23	; 0x3d
    4aa0:	8e af       	std	Y+62, r24	; 0x3e
    4aa2:	9f af       	std	Y+63, r25	; 0x3f
    4aa4:	29 97       	sbiw	r28, 0x09	; 9
    4aa6:	a5 01       	movw	r20, r10
    4aa8:	94 01       	movw	r18, r8
    4aaa:	c5 01       	movw	r24, r10
    4aac:	b4 01       	movw	r22, r8
    4aae:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4ab2:	2d 96       	adiw	r28, 0x0d	; 13
    4ab4:	6c af       	std	Y+60, r22	; 0x3c
    4ab6:	7d af       	std	Y+61, r23	; 0x3d
    4ab8:	8e af       	std	Y+62, r24	; 0x3e
    4aba:	9f af       	std	Y+63, r25	; 0x3f
    4abc:	2d 97       	sbiw	r28, 0x0d	; 13
    4abe:	20 e0       	ldi	r18, 0x00	; 0
    4ac0:	30 e0       	ldi	r19, 0x00	; 0
    4ac2:	40 e8       	ldi	r20, 0x80	; 128
    4ac4:	50 e4       	ldi	r21, 0x40	; 64
    4ac6:	21 96       	adiw	r28, 0x01	; 1
    4ac8:	6c ad       	ldd	r22, Y+60	; 0x3c
    4aca:	7d ad       	ldd	r23, Y+61	; 0x3d
    4acc:	8e ad       	ldd	r24, Y+62	; 0x3e
    4ace:	9f ad       	ldd	r25, Y+63	; 0x3f
    4ad0:	21 97       	sbiw	r28, 0x01	; 1
    4ad2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4ad6:	21 96       	adiw	r28, 0x01	; 1
    4ad8:	2c ad       	ldd	r18, Y+60	; 0x3c
    4ada:	3d ad       	ldd	r19, Y+61	; 0x3d
    4adc:	4e ad       	ldd	r20, Y+62	; 0x3e
    4ade:	5f ad       	ldd	r21, Y+63	; 0x3f
    4ae0:	21 97       	sbiw	r28, 0x01	; 1
    4ae2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4ae6:	29 96       	adiw	r28, 0x09	; 9
    4ae8:	2c ad       	ldd	r18, Y+60	; 0x3c
    4aea:	3d ad       	ldd	r19, Y+61	; 0x3d
    4aec:	4e ad       	ldd	r20, Y+62	; 0x3e
    4aee:	5f ad       	ldd	r21, Y+63	; 0x3f
    4af0:	29 97       	sbiw	r28, 0x09	; 9
    4af2:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4af6:	2d 96       	adiw	r28, 0x0d	; 13
    4af8:	2c ad       	ldd	r18, Y+60	; 0x3c
    4afa:	3d ad       	ldd	r19, Y+61	; 0x3d
    4afc:	4e ad       	ldd	r20, Y+62	; 0x3e
    4afe:	5f ad       	ldd	r21, Y+63	; 0x3f
    4b00:	2d 97       	sbiw	r28, 0x0d	; 13
    4b02:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4b06:	6b 01       	movw	r12, r22
    4b08:	7c 01       	movw	r14, r24
    4b0a:	20 e0       	ldi	r18, 0x00	; 0
    4b0c:	30 e0       	ldi	r19, 0x00	; 0
    4b0e:	a9 01       	movw	r20, r18
    4b10:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    4b14:	87 fd       	sbrc	r24, 7
    4b16:	8a c6       	rjmp	.+3348   	; 0x582c <gc_execute_line.constprop.11+0x1b52>
    4b18:	c7 01       	movw	r24, r14
    4b1a:	b6 01       	movw	r22, r12
    4b1c:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    4b20:	6b 01       	movw	r12, r22
    4b22:	7c 01       	movw	r14, r24
    4b24:	2d 96       	adiw	r28, 0x0d	; 13
    4b26:	2c ad       	ldd	r18, Y+60	; 0x3c
    4b28:	3d ad       	ldd	r19, Y+61	; 0x3d
    4b2a:	4e ad       	ldd	r20, Y+62	; 0x3e
    4b2c:	5f ad       	ldd	r21, Y+63	; 0x3f
    4b2e:	2d 97       	sbiw	r28, 0x0d	; 13
    4b30:	29 96       	adiw	r28, 0x09	; 9
    4b32:	6c ad       	ldd	r22, Y+60	; 0x3c
    4b34:	7d ad       	ldd	r23, Y+61	; 0x3d
    4b36:	8e ad       	ldd	r24, Y+62	; 0x3e
    4b38:	9f ad       	ldd	r25, Y+63	; 0x3f
    4b3a:	29 97       	sbiw	r28, 0x09	; 9
    4b3c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4b40:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    4b44:	9b 01       	movw	r18, r22
    4b46:	ac 01       	movw	r20, r24
    4b48:	c7 01       	movw	r24, r14
    4b4a:	b6 01       	movw	r22, r12
    4b4c:	90 58       	subi	r25, 0x80	; 128
    4b4e:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    4b52:	6b 01       	movw	r12, r22
    4b54:	7c 01       	movw	r14, r24
    4b56:	9f a1       	ldd	r25, Y+39	; 0x27
    4b58:	93 30       	cpi	r25, 0x03	; 3
    4b5a:	21 f4       	brne	.+8      	; 0x4b64 <gc_execute_line.constprop.11+0xe8a>
    4b5c:	f7 fa       	bst	r15, 7
    4b5e:	f0 94       	com	r15
    4b60:	f7 f8       	bld	r15, 7
    4b62:	f0 94       	com	r15
    4b64:	20 e0       	ldi	r18, 0x00	; 0
    4b66:	30 e0       	ldi	r19, 0x00	; 0
    4b68:	a9 01       	movw	r20, r18
    4b6a:	21 96       	adiw	r28, 0x01	; 1
    4b6c:	6c ad       	ldd	r22, Y+60	; 0x3c
    4b6e:	7d ad       	ldd	r23, Y+61	; 0x3d
    4b70:	8e ad       	ldd	r24, Y+62	; 0x3e
    4b72:	9f ad       	ldd	r25, Y+63	; 0x3f
    4b74:	21 97       	sbiw	r28, 0x01	; 1
    4b76:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    4b7a:	87 ff       	sbrs	r24, 7
    4b7c:	13 c0       	rjmp	.+38     	; 0x4ba4 <gc_execute_line.constprop.11+0xeca>
    4b7e:	f7 fa       	bst	r15, 7
    4b80:	f0 94       	com	r15
    4b82:	f7 f8       	bld	r15, 7
    4b84:	f0 94       	com	r15
    4b86:	21 96       	adiw	r28, 0x01	; 1
    4b88:	8c ad       	ldd	r24, Y+60	; 0x3c
    4b8a:	9d ad       	ldd	r25, Y+61	; 0x3d
    4b8c:	ae ad       	ldd	r26, Y+62	; 0x3e
    4b8e:	bf ad       	ldd	r27, Y+63	; 0x3f
    4b90:	21 97       	sbiw	r28, 0x01	; 1
    4b92:	b0 58       	subi	r27, 0x80	; 128
    4b94:	80 93 fc 06 	sts	0x06FC, r24	; 0x8006fc <gc_block+0x25>
    4b98:	90 93 fd 06 	sts	0x06FD, r25	; 0x8006fd <gc_block+0x26>
    4b9c:	a0 93 fe 06 	sts	0x06FE, r26	; 0x8006fe <gc_block+0x27>
    4ba0:	b0 93 ff 06 	sts	0x06FF, r27	; 0x8006ff <gc_block+0x28>
    4ba4:	09 a9       	ldd	r16, Y+49	; 0x31
    4ba6:	1a a9       	ldd	r17, Y+50	; 0x32
    4ba8:	00 0f       	add	r16, r16
    4baa:	11 1f       	adc	r17, r17
    4bac:	00 0f       	add	r16, r16
    4bae:	11 1f       	adc	r17, r17
    4bb0:	09 51       	subi	r16, 0x19	; 25
    4bb2:	19 4f       	sbci	r17, 0xF9	; 249
    4bb4:	a7 01       	movw	r20, r14
    4bb6:	96 01       	movw	r18, r12
    4bb8:	c5 01       	movw	r24, r10
    4bba:	b4 01       	movw	r22, r8
    4bbc:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4bc0:	9b 01       	movw	r18, r22
    4bc2:	ac 01       	movw	r20, r24
    4bc4:	c3 01       	movw	r24, r6
    4bc6:	b2 01       	movw	r22, r4
    4bc8:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4bcc:	20 e0       	ldi	r18, 0x00	; 0
    4bce:	30 e0       	ldi	r19, 0x00	; 0
    4bd0:	40 e0       	ldi	r20, 0x00	; 0
    4bd2:	5f e3       	ldi	r21, 0x3F	; 63
    4bd4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4bd8:	d8 01       	movw	r26, r16
    4bda:	6d 93       	st	X+, r22
    4bdc:	7d 93       	st	X+, r23
    4bde:	8d 93       	st	X+, r24
    4be0:	9c 93       	st	X, r25
    4be2:	13 97       	sbiw	r26, 0x03	; 3
    4be4:	0d a9       	ldd	r16, Y+53	; 0x35
    4be6:	1e a9       	ldd	r17, Y+54	; 0x36
    4be8:	00 0f       	add	r16, r16
    4bea:	11 1f       	adc	r17, r17
    4bec:	00 0f       	add	r16, r16
    4bee:	11 1f       	adc	r17, r17
    4bf0:	09 51       	subi	r16, 0x19	; 25
    4bf2:	19 4f       	sbci	r17, 0xF9	; 249
    4bf4:	a7 01       	movw	r20, r14
    4bf6:	96 01       	movw	r18, r12
    4bf8:	c3 01       	movw	r24, r6
    4bfa:	b2 01       	movw	r22, r4
    4bfc:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4c00:	a5 01       	movw	r20, r10
    4c02:	94 01       	movw	r18, r8
    4c04:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4c08:	20 e0       	ldi	r18, 0x00	; 0
    4c0a:	30 e0       	ldi	r19, 0x00	; 0
    4c0c:	40 e0       	ldi	r20, 0x00	; 0
    4c0e:	5f e3       	ldi	r21, 0x3F	; 63
    4c10:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4c14:	f8 01       	movw	r30, r16
    4c16:	60 83       	st	Z, r22
    4c18:	71 83       	std	Z+1, r23	; 0x01
    4c1a:	82 83       	std	Z+2, r24	; 0x02
    4c1c:	93 83       	std	Z+3, r25	; 0x03
    4c1e:	f0 cd       	rjmp	.-1056   	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    4c20:	c1 2e       	mov	r12, r17
    4c22:	d1 2c       	mov	r13, r1
    4c24:	e1 22       	and	r14, r17
    4c26:	fd 20       	and	r15, r13
    4c28:	83 e2       	ldi	r24, 0x23	; 35
    4c2a:	ef 28       	or	r14, r15
    4c2c:	09 f4       	brne	.+2      	; 0x4c30 <gc_execute_line.constprop.11+0xf56>
    4c2e:	a6 c9       	rjmp	.-3252   	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    4c30:	f1 ef       	ldi	r31, 0xF1	; 241
    4c32:	2f 22       	and	r2, r31
    4c34:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    4c38:	81 30       	cpi	r24, 0x01	; 1
    4c3a:	41 f5       	brne	.+80     	; 0x4c8c <gc_execute_line.constprop.11+0xfb2>
    4c3c:	07 ed       	ldi	r16, 0xD7	; 215
    4c3e:	16 e0       	ldi	r17, 0x06	; 6
    4c40:	f1 2c       	mov	r15, r1
    4c42:	e1 2c       	mov	r14, r1
    4c44:	c6 01       	movw	r24, r12
    4c46:	0e 2c       	mov	r0, r14
    4c48:	02 c0       	rjmp	.+4      	; 0x4c4e <gc_execute_line.constprop.11+0xf74>
    4c4a:	95 95       	asr	r25
    4c4c:	87 95       	ror	r24
    4c4e:	0a 94       	dec	r0
    4c50:	e2 f7       	brpl	.-8      	; 0x4c4a <gc_execute_line.constprop.11+0xf70>
    4c52:	80 ff       	sbrs	r24, 0
    4c54:	12 c0       	rjmp	.+36     	; 0x4c7a <gc_execute_line.constprop.11+0xfa0>
    4c56:	23 e3       	ldi	r18, 0x33	; 51
    4c58:	33 e3       	ldi	r19, 0x33	; 51
    4c5a:	4b ec       	ldi	r20, 0xCB	; 203
    4c5c:	51 e4       	ldi	r21, 0x41	; 65
    4c5e:	d8 01       	movw	r26, r16
    4c60:	50 96       	adiw	r26, 0x10	; 16
    4c62:	6d 91       	ld	r22, X+
    4c64:	7d 91       	ld	r23, X+
    4c66:	8d 91       	ld	r24, X+
    4c68:	9c 91       	ld	r25, X
    4c6a:	53 97       	sbiw	r26, 0x13	; 19
    4c6c:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4c70:	f8 01       	movw	r30, r16
    4c72:	60 8b       	std	Z+16, r22	; 0x10
    4c74:	71 8b       	std	Z+17, r23	; 0x11
    4c76:	82 8b       	std	Z+18, r24	; 0x12
    4c78:	93 8b       	std	Z+19, r25	; 0x13
    4c7a:	ff ef       	ldi	r31, 0xFF	; 255
    4c7c:	ef 1a       	sub	r14, r31
    4c7e:	ff 0a       	sbc	r15, r31
    4c80:	0c 5f       	subi	r16, 0xFC	; 252
    4c82:	1f 4f       	sbci	r17, 0xFF	; 255
    4c84:	23 e0       	ldi	r18, 0x03	; 3
    4c86:	e2 16       	cp	r14, r18
    4c88:	f1 04       	cpc	r15, r1
    4c8a:	e1 f6       	brne	.-72     	; 0x4c44 <gc_execute_line.constprop.11+0xf6a>
    4c8c:	e9 a9       	ldd	r30, Y+49	; 0x31
    4c8e:	fa a9       	ldd	r31, Y+50	; 0x32
    4c90:	ee 0f       	add	r30, r30
    4c92:	ff 1f       	adc	r31, r31
    4c94:	ee 0f       	add	r30, r30
    4c96:	ff 1f       	adc	r31, r31
    4c98:	e9 51       	subi	r30, 0x19	; 25
    4c9a:	f9 4f       	sbci	r31, 0xF9	; 249
    4c9c:	c0 80       	ld	r12, Z
    4c9e:	d1 80       	ldd	r13, Z+1	; 0x01
    4ca0:	e2 80       	ldd	r14, Z+2	; 0x02
    4ca2:	f3 80       	ldd	r15, Z+3	; 0x03
    4ca4:	a7 01       	movw	r20, r14
    4ca6:	96 01       	movw	r18, r12
    4ca8:	c3 01       	movw	r24, r6
    4caa:	b2 01       	movw	r22, r4
    4cac:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4cb0:	2b 01       	movw	r4, r22
    4cb2:	3c 01       	movw	r6, r24
    4cb4:	ed a9       	ldd	r30, Y+53	; 0x35
    4cb6:	fe a9       	ldd	r31, Y+54	; 0x36
    4cb8:	ee 0f       	add	r30, r30
    4cba:	ff 1f       	adc	r31, r31
    4cbc:	ee 0f       	add	r30, r30
    4cbe:	ff 1f       	adc	r31, r31
    4cc0:	e9 51       	subi	r30, 0x19	; 25
    4cc2:	f9 4f       	sbci	r31, 0xF9	; 249
    4cc4:	80 81       	ld	r24, Z
    4cc6:	91 81       	ldd	r25, Z+1	; 0x01
    4cc8:	a2 81       	ldd	r26, Z+2	; 0x02
    4cca:	b3 81       	ldd	r27, Z+3	; 0x03
    4ccc:	89 ab       	std	Y+49, r24	; 0x31
    4cce:	9a ab       	std	Y+50, r25	; 0x32
    4cd0:	ab ab       	std	Y+51, r26	; 0x33
    4cd2:	bc ab       	std	Y+52, r27	; 0x34
    4cd4:	9c 01       	movw	r18, r24
    4cd6:	ad 01       	movw	r20, r26
    4cd8:	c5 01       	movw	r24, r10
    4cda:	b4 01       	movw	r22, r8
    4cdc:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4ce0:	4b 01       	movw	r8, r22
    4ce2:	5c 01       	movw	r10, r24
    4ce4:	a3 01       	movw	r20, r6
    4ce6:	92 01       	movw	r18, r4
    4ce8:	c3 01       	movw	r24, r6
    4cea:	b2 01       	movw	r22, r4
    4cec:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4cf0:	2b 01       	movw	r4, r22
    4cf2:	3c 01       	movw	r6, r24
    4cf4:	a5 01       	movw	r20, r10
    4cf6:	94 01       	movw	r18, r8
    4cf8:	c5 01       	movw	r24, r10
    4cfa:	b4 01       	movw	r22, r8
    4cfc:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4d00:	9b 01       	movw	r18, r22
    4d02:	ac 01       	movw	r20, r24
    4d04:	c3 01       	movw	r24, r6
    4d06:	b2 01       	movw	r22, r4
    4d08:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4d0c:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    4d10:	4b 01       	movw	r8, r22
    4d12:	5c 01       	movw	r10, r24
    4d14:	a7 01       	movw	r20, r14
    4d16:	96 01       	movw	r18, r12
    4d18:	c7 01       	movw	r24, r14
    4d1a:	b6 01       	movw	r22, r12
    4d1c:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4d20:	6b 01       	movw	r12, r22
    4d22:	7c 01       	movw	r14, r24
    4d24:	29 a9       	ldd	r18, Y+49	; 0x31
    4d26:	3a a9       	ldd	r19, Y+50	; 0x32
    4d28:	4b a9       	ldd	r20, Y+51	; 0x33
    4d2a:	5c a9       	ldd	r21, Y+52	; 0x34
    4d2c:	ca 01       	movw	r24, r20
    4d2e:	b9 01       	movw	r22, r18
    4d30:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4d34:	9b 01       	movw	r18, r22
    4d36:	ac 01       	movw	r20, r24
    4d38:	c7 01       	movw	r24, r14
    4d3a:	b6 01       	movw	r22, r12
    4d3c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    4d40:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    4d44:	6b 01       	movw	r12, r22
    4d46:	7c 01       	movw	r14, r24
    4d48:	c0 92 fc 06 	sts	0x06FC, r12	; 0x8006fc <gc_block+0x25>
    4d4c:	d0 92 fd 06 	sts	0x06FD, r13	; 0x8006fd <gc_block+0x26>
    4d50:	e0 92 fe 06 	sts	0x06FE, r14	; 0x8006fe <gc_block+0x27>
    4d54:	f0 92 ff 06 	sts	0x06FF, r15	; 0x8006ff <gc_block+0x28>
    4d58:	ac 01       	movw	r20, r24
    4d5a:	9b 01       	movw	r18, r22
    4d5c:	c5 01       	movw	r24, r10
    4d5e:	b4 01       	movw	r22, r8
    4d60:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    4d64:	4b 01       	movw	r8, r22
    4d66:	5c 01       	movw	r10, r24
    4d68:	e8 94       	clt
    4d6a:	b7 f8       	bld	r11, 7
    4d6c:	2a e0       	ldi	r18, 0x0A	; 10
    4d6e:	37 ed       	ldi	r19, 0xD7	; 215
    4d70:	43 ea       	ldi	r20, 0xA3	; 163
    4d72:	5b e3       	ldi	r21, 0x3B	; 59
    4d74:	c5 01       	movw	r24, r10
    4d76:	b4 01       	movw	r22, r8
    4d78:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    4d7c:	18 16       	cp	r1, r24
    4d7e:	0c f0       	brlt	.+2      	; 0x4d82 <gc_execute_line.constprop.11+0x10a8>
    4d80:	3f cd       	rjmp	.-1410   	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    4d82:	20 e0       	ldi	r18, 0x00	; 0
    4d84:	30 e0       	ldi	r19, 0x00	; 0
    4d86:	40 e0       	ldi	r20, 0x00	; 0
    4d88:	5f e3       	ldi	r21, 0x3F	; 63
    4d8a:	c5 01       	movw	r24, r10
    4d8c:	b4 01       	movw	r22, r8
    4d8e:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    4d92:	18 16       	cp	r1, r24
    4d94:	0c f4       	brge	.+2      	; 0x4d98 <gc_execute_line.constprop.11+0x10be>
    4d96:	51 ce       	rjmp	.-862    	; 0x4a3a <gc_execute_line.constprop.11+0xd60>
    4d98:	2f e6       	ldi	r18, 0x6F	; 111
    4d9a:	32 e1       	ldi	r19, 0x12	; 18
    4d9c:	43 e8       	ldi	r20, 0x83	; 131
    4d9e:	5a e3       	ldi	r21, 0x3A	; 58
    4da0:	c7 01       	movw	r24, r14
    4da2:	b6 01       	movw	r22, r12
    4da4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    4da8:	9b 01       	movw	r18, r22
    4daa:	ac 01       	movw	r20, r24
    4dac:	c5 01       	movw	r24, r10
    4dae:	b4 01       	movw	r22, r8
    4db0:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    4db4:	18 16       	cp	r1, r24
    4db6:	0c f0       	brlt	.+2      	; 0x4dba <gc_execute_line.constprop.11+0x10e0>
    4db8:	23 cd       	rjmp	.-1466   	; 0x4800 <gc_execute_line.constprop.11+0xb26>
    4dba:	3f ce       	rjmp	.-898    	; 0x4a3a <gc_execute_line.constprop.11+0xd60>
    4dbc:	8e 7d       	andi	r24, 0xDE	; 222
    4dbe:	9c 7f       	andi	r25, 0xFC	; 252
    4dc0:	26 cd       	rjmp	.-1460   	; 0x480e <gc_execute_line.constprop.11+0xb34>
    4dc2:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    4dc6:	f0 90 a0 06 	lds	r15, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4dca:	81 ff       	sbrs	r24, 1
    4dcc:	12 c0       	rjmp	.+36     	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    4dce:	8f a1       	ldd	r24, Y+39	; 0x27
    4dd0:	81 50       	subi	r24, 0x01	; 1
    4dd2:	83 30       	cpi	r24, 0x03	; 3
    4dd4:	18 f0       	brcs	.+6      	; 0x4ddc <gc_execute_line.constprop.11+0x1102>
    4dd6:	bb a1       	ldd	r27, Y+35	; 0x23
    4dd8:	b0 64       	ori	r27, 0x40	; 64
    4dda:	bb a3       	std	Y+35, r27	; 0x23
    4ddc:	eb 8d       	ldd	r30, Y+27	; 0x1b
    4dde:	ee 23       	and	r30, r30
    4de0:	09 f4       	brne	.+2      	; 0x4de4 <gc_execute_line.constprop.11+0x110a>
    4de2:	43 c1       	rjmp	.+646    	; 0x506a <gc_execute_line.constprop.11+0x1390>
    4de4:	ff 8d       	ldd	r31, Y+31	; 0x1f
    4de6:	f2 30       	cpi	r31, 0x02	; 2
    4de8:	09 f0       	breq	.+2      	; 0x4dec <gc_execute_line.constprop.11+0x1112>
    4dea:	3f c1       	rjmp	.+638    	; 0x506a <gc_execute_line.constprop.11+0x1390>
    4dec:	2b a1       	ldd	r18, Y+35	; 0x23
    4dee:	20 68       	ori	r18, 0x80	; 128
    4df0:	2b a3       	std	Y+35, r18	; 0x23
    4df2:	80 91 f4 06 	lds	r24, 0x06F4	; 0x8006f4 <gc_block+0x1d>
    4df6:	90 91 f5 06 	lds	r25, 0x06F5	; 0x8006f5 <gc_block+0x1e>
    4dfa:	a0 91 f6 06 	lds	r26, 0x06F6	; 0x8006f6 <gc_block+0x1f>
    4dfe:	b0 91 f7 06 	lds	r27, 0x06F7	; 0x8006f7 <gc_block+0x20>
    4e02:	80 93 ab 06 	sts	0x06AB, r24	; 0x8006ab <gc_state+0x14>
    4e06:	90 93 ac 06 	sts	0x06AC, r25	; 0x8006ac <gc_state+0x15>
    4e0a:	a0 93 ad 06 	sts	0x06AD, r26	; 0x8006ad <gc_state+0x16>
    4e0e:	b0 93 ae 06 	sts	0x06AE, r27	; 0x8006ae <gc_state+0x17>
    4e12:	80 91 d9 06 	lds	r24, 0x06D9	; 0x8006d9 <gc_block+0x2>
    4e16:	80 93 98 06 	sts	0x0698, r24	; 0x800698 <gc_state+0x1>
    4e1a:	88 23       	and	r24, r24
    4e1c:	11 f0       	breq	.+4      	; 0x4e22 <gc_execute_line.constprop.11+0x1148>
    4e1e:	88 e0       	ldi	r24, 0x08	; 8
    4e20:	8d 8b       	std	Y+21, r24	; 0x15
    4e22:	80 91 e3 06 	lds	r24, 0x06E3	; 0x8006e3 <gc_block+0xc>
    4e26:	90 91 e4 06 	lds	r25, 0x06E4	; 0x8006e4 <gc_block+0xd>
    4e2a:	a0 91 e5 06 	lds	r26, 0x06E5	; 0x8006e5 <gc_block+0xe>
    4e2e:	b0 91 e6 06 	lds	r27, 0x06E6	; 0x8006e6 <gc_block+0xf>
    4e32:	80 93 a6 06 	sts	0x06A6, r24	; 0x8006a6 <gc_state+0xf>
    4e36:	90 93 a7 06 	sts	0x06A7, r25	; 0x8006a7 <gc_state+0x10>
    4e3a:	a0 93 a8 06 	sts	0x06A8, r26	; 0x8006a8 <gc_state+0x11>
    4e3e:	b0 93 a9 06 	sts	0x06A9, r27	; 0x8006a9 <gc_state+0x12>
    4e42:	8d 87       	std	Y+13, r24	; 0x0d
    4e44:	9e 87       	std	Y+14, r25	; 0x0e
    4e46:	af 87       	std	Y+15, r26	; 0x0f
    4e48:	b8 8b       	std	Y+16, r27	; 0x10
    4e4a:	80 90 00 07 	lds	r8, 0x0700	; 0x800700 <gc_block+0x29>
    4e4e:	90 90 01 07 	lds	r9, 0x0701	; 0x800701 <gc_block+0x2a>
    4e52:	a0 90 02 07 	lds	r10, 0x0702	; 0x800702 <gc_block+0x2b>
    4e56:	b0 90 03 07 	lds	r11, 0x0703	; 0x800703 <gc_block+0x2c>
    4e5a:	a5 01       	movw	r20, r10
    4e5c:	94 01       	movw	r18, r8
    4e5e:	60 91 a2 06 	lds	r22, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4e62:	70 91 a3 06 	lds	r23, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4e66:	80 91 a4 06 	lds	r24, 0x06A4	; 0x8006a4 <gc_state+0xd>
    4e6a:	90 91 a5 06 	lds	r25, 0x06A5	; 0x8006a5 <gc_state+0xe>
    4e6e:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    4e72:	9b a1       	ldd	r25, Y+35	; 0x23
    4e74:	90 74       	andi	r25, 0x40	; 64
    4e76:	e9 2e       	mov	r14, r25
    4e78:	81 11       	cpse	r24, r1
    4e7a:	03 c0       	rjmp	.+6      	; 0x4e82 <gc_execute_line.constprop.11+0x11a8>
    4e7c:	ab a1       	ldd	r26, Y+35	; 0x23
    4e7e:	a5 ff       	sbrs	r26, 5
    4e80:	1f c0       	rjmp	.+62     	; 0x4ec0 <gc_execute_line.constprop.11+0x11e6>
    4e82:	ff 20       	and	r15, r15
    4e84:	69 f0       	breq	.+26     	; 0x4ea0 <gc_execute_line.constprop.11+0x11c6>
    4e86:	bb a1       	ldd	r27, Y+35	; 0x23
    4e88:	b7 fd       	sbrc	r27, 7
    4e8a:	0a c0       	rjmp	.+20     	; 0x4ea0 <gc_execute_line.constprop.11+0x11c6>
    4e8c:	40 e0       	ldi	r20, 0x00	; 0
    4e8e:	50 e0       	ldi	r21, 0x00	; 0
    4e90:	ba 01       	movw	r22, r20
    4e92:	e1 10       	cpse	r14, r1
    4e94:	02 c0       	rjmp	.+4      	; 0x4e9a <gc_execute_line.constprop.11+0x11c0>
    4e96:	b5 01       	movw	r22, r10
    4e98:	a4 01       	movw	r20, r8
    4e9a:	8f 2d       	mov	r24, r15
    4e9c:	0e 94 ef 1d 	call	0x3bde	; 0x3bde <spindle_sync>
    4ea0:	80 91 00 07 	lds	r24, 0x0700	; 0x800700 <gc_block+0x29>
    4ea4:	90 91 01 07 	lds	r25, 0x0701	; 0x800701 <gc_block+0x2a>
    4ea8:	a0 91 02 07 	lds	r26, 0x0702	; 0x800702 <gc_block+0x2b>
    4eac:	b0 91 03 07 	lds	r27, 0x0703	; 0x800703 <gc_block+0x2c>
    4eb0:	80 93 a2 06 	sts	0x06A2, r24	; 0x8006a2 <gc_state+0xb>
    4eb4:	90 93 a3 06 	sts	0x06A3, r25	; 0x8006a3 <gc_state+0xc>
    4eb8:	a0 93 a4 06 	sts	0x06A4, r26	; 0x8006a4 <gc_state+0xd>
    4ebc:	b0 93 a5 06 	sts	0x06A5, r27	; 0x8006a5 <gc_state+0xe>
    4ec0:	e1 10       	cpse	r14, r1
    4ec2:	0c c0       	rjmp	.+24     	; 0x4edc <gc_execute_line.constprop.11+0x1202>
    4ec4:	80 91 a2 06 	lds	r24, 0x06A2	; 0x8006a2 <gc_state+0xb>
    4ec8:	90 91 a3 06 	lds	r25, 0x06A3	; 0x8006a3 <gc_state+0xc>
    4ecc:	a0 91 a4 06 	lds	r26, 0x06A4	; 0x8006a4 <gc_state+0xd>
    4ed0:	b0 91 a5 06 	lds	r27, 0x06A5	; 0x8006a5 <gc_state+0xe>
    4ed4:	89 8b       	std	Y+17, r24	; 0x11
    4ed6:	9a 8b       	std	Y+18, r25	; 0x12
    4ed8:	ab 8b       	std	Y+19, r26	; 0x13
    4eda:	bc 8b       	std	Y+20, r27	; 0x14
    4edc:	80 91 04 07 	lds	r24, 0x0704	; 0x800704 <gc_block+0x2d>
    4ee0:	80 93 aa 06 	sts	0x06AA, r24	; 0x8006aa <gc_state+0x13>
    4ee4:	80 91 e1 06 	lds	r24, 0x06E1	; 0x8006e1 <gc_block+0xa>
    4ee8:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4eec:	98 17       	cp	r25, r24
    4eee:	51 f0       	breq	.+20     	; 0x4f04 <gc_execute_line.constprop.11+0x122a>
    4ef0:	49 89       	ldd	r20, Y+17	; 0x11
    4ef2:	5a 89       	ldd	r21, Y+18	; 0x12
    4ef4:	6b 89       	ldd	r22, Y+19	; 0x13
    4ef6:	7c 89       	ldd	r23, Y+20	; 0x14
    4ef8:	0e 94 ef 1d 	call	0x3bde	; 0x3bde <spindle_sync>
    4efc:	80 91 e1 06 	lds	r24, 0x06E1	; 0x8006e1 <gc_block+0xa>
    4f00:	80 93 a0 06 	sts	0x06A0, r24	; 0x8006a0 <gc_state+0x9>
    4f04:	8d 89       	ldd	r24, Y+21	; 0x15
    4f06:	90 91 a0 06 	lds	r25, 0x06A0	; 0x8006a0 <gc_state+0x9>
    4f0a:	89 2b       	or	r24, r25
    4f0c:	8d 8b       	std	Y+21, r24	; 0x15
    4f0e:	f0 90 e0 06 	lds	r15, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4f12:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    4f16:	8f 15       	cp	r24, r15
    4f18:	69 f0       	breq	.+26     	; 0x4f34 <gc_execute_line.constprop.11+0x125a>
    4f1a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    4f1e:	82 30       	cpi	r24, 0x02	; 2
    4f20:	29 f0       	breq	.+10     	; 0x4f2c <gc_execute_line.constprop.11+0x1252>
    4f22:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    4f26:	8f 2d       	mov	r24, r15
    4f28:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    4f2c:	80 91 e0 06 	lds	r24, 0x06E0	; 0x8006e0 <gc_block+0x9>
    4f30:	80 93 9f 06 	sts	0x069F, r24	; 0x80069f <gc_state+0x8>
    4f34:	8d 89       	ldd	r24, Y+21	; 0x15
    4f36:	90 91 9f 06 	lds	r25, 0x069F	; 0x80069f <gc_state+0x8>
    4f3a:	89 2b       	or	r24, r25
    4f3c:	8d 8b       	std	Y+21, r24	; 0x15
    4f3e:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    4f42:	84 30       	cpi	r24, 0x04	; 4
    4f44:	99 f4       	brne	.+38     	; 0x4f6c <gc_execute_line.constprop.11+0x1292>
    4f46:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    4f4a:	82 30       	cpi	r24, 0x02	; 2
    4f4c:	79 f0       	breq	.+30     	; 0x4f6c <gc_execute_line.constprop.11+0x1292>
    4f4e:	c0 90 f8 06 	lds	r12, 0x06F8	; 0x8006f8 <gc_block+0x21>
    4f52:	d0 90 f9 06 	lds	r13, 0x06F9	; 0x8006f9 <gc_block+0x22>
    4f56:	e0 90 fa 06 	lds	r14, 0x06FA	; 0x8006fa <gc_block+0x23>
    4f5a:	f0 90 fb 06 	lds	r15, 0x06FB	; 0x8006fb <gc_block+0x24>
    4f5e:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    4f62:	40 e0       	ldi	r20, 0x00	; 0
    4f64:	c7 01       	movw	r24, r14
    4f66:	b6 01       	movw	r22, r12
    4f68:	0e 94 f8 1c 	call	0x39f0	; 0x39f0 <delay_sec>
    4f6c:	80 91 dc 06 	lds	r24, 0x06DC	; 0x8006dc <gc_block+0x5>
    4f70:	80 93 9b 06 	sts	0x069B, r24	; 0x80069b <gc_state+0x4>
    4f74:	80 91 da 06 	lds	r24, 0x06DA	; 0x8006da <gc_block+0x3>
    4f78:	80 93 99 06 	sts	0x0699, r24	; 0x800699 <gc_state+0x2>
    4f7c:	ef 8d       	ldd	r30, Y+31	; 0x1f
    4f7e:	e3 30       	cpi	r30, 0x03	; 3
    4f80:	71 f5       	brne	.+92     	; 0x4fde <gc_execute_line.constprop.11+0x1304>
    4f82:	80 91 dd 06 	lds	r24, 0x06DD	; 0x8006dd <gc_block+0x6>
    4f86:	80 93 9c 06 	sts	0x069C, r24	; 0x80069c <gc_state+0x5>
    4f8a:	81 11       	cpse	r24, r1
    4f8c:	08 c0       	rjmp	.+16     	; 0x4f9e <gc_execute_line.constprop.11+0x12c4>
    4f8e:	10 92 0d 07 	sts	0x070D, r1	; 0x80070d <gc_block+0x36>
    4f92:	10 92 0e 07 	sts	0x070E, r1	; 0x80070e <gc_block+0x37>
    4f96:	10 92 0f 07 	sts	0x070F, r1	; 0x80070f <gc_block+0x38>
    4f9a:	10 92 10 07 	sts	0x0710, r1	; 0x800710 <gc_block+0x39>
    4f9e:	c0 90 0d 07 	lds	r12, 0x070D	; 0x80070d <gc_block+0x36>
    4fa2:	d0 90 0e 07 	lds	r13, 0x070E	; 0x80070e <gc_block+0x37>
    4fa6:	e0 90 0f 07 	lds	r14, 0x070F	; 0x80070f <gc_block+0x38>
    4faa:	f0 90 10 07 	lds	r15, 0x0710	; 0x800710 <gc_block+0x39>
    4fae:	a7 01       	movw	r20, r14
    4fb0:	96 01       	movw	r18, r12
    4fb2:	60 91 d3 06 	lds	r22, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    4fb6:	70 91 d4 06 	lds	r23, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    4fba:	80 91 d5 06 	lds	r24, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    4fbe:	90 91 d6 06 	lds	r25, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    4fc2:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    4fc6:	88 23       	and	r24, r24
    4fc8:	51 f0       	breq	.+20     	; 0x4fde <gc_execute_line.constprop.11+0x1304>
    4fca:	c0 92 d3 06 	sts	0x06D3, r12	; 0x8006d3 <gc_state+0x3c>
    4fce:	d0 92 d4 06 	sts	0x06D4, r13	; 0x8006d4 <gc_state+0x3d>
    4fd2:	e0 92 d5 06 	sts	0x06D5, r14	; 0x8006d5 <gc_state+0x3e>
    4fd6:	f0 92 d6 06 	sts	0x06D6, r15	; 0x8006d6 <gc_state+0x3f>
    4fda:	0e 94 58 1d 	call	0x3ab0	; 0x3ab0 <system_flag_wco_change>
    4fde:	80 91 de 06 	lds	r24, 0x06DE	; 0x8006de <gc_block+0x7>
    4fe2:	90 91 9d 06 	lds	r25, 0x069D	; 0x80069d <gc_state+0x6>
    4fe6:	98 17       	cp	r25, r24
    4fe8:	69 f0       	breq	.+26     	; 0x5004 <gc_execute_line.constprop.11+0x132a>
    4fea:	80 93 9d 06 	sts	0x069D, r24	; 0x80069d <gc_state+0x6>
    4fee:	8c e0       	ldi	r24, 0x0C	; 12
    4ff0:	fe 01       	movw	r30, r28
    4ff2:	31 96       	adiw	r30, 0x01	; 1
    4ff4:	ab eb       	ldi	r26, 0xBB	; 187
    4ff6:	b6 e0       	ldi	r27, 0x06	; 6
    4ff8:	01 90       	ld	r0, Z+
    4ffa:	0d 92       	st	X+, r0
    4ffc:	8a 95       	dec	r24
    4ffe:	e1 f7       	brne	.-8      	; 0x4ff8 <gc_execute_line.constprop.11+0x131e>
    5000:	0e 94 58 1d 	call	0x3ab0	; 0x3ab0 <system_flag_wco_change>
    5004:	80 91 db 06 	lds	r24, 0x06DB	; 0x8006db <gc_block+0x4>
    5008:	80 93 9a 06 	sts	0x069A, r24	; 0x80069a <gc_state+0x3>
    500c:	80 91 d7 06 	lds	r24, 0x06D7	; 0x8006d7 <gc_block>
    5010:	86 32       	cpi	r24, 0x26	; 38
    5012:	09 f4       	brne	.+2      	; 0x5016 <gc_execute_line.constprop.11+0x133c>
    5014:	7e c0       	rjmp	.+252    	; 0x5112 <gc_execute_line.constprop.11+0x1438>
    5016:	08 f0       	brcs	.+2      	; 0x501a <gc_execute_line.constprop.11+0x1340>
    5018:	3f c0       	rjmp	.+126    	; 0x5098 <gc_execute_line.constprop.11+0x13be>
    501a:	8c 31       	cpi	r24, 0x1C	; 28
    501c:	09 f4       	brne	.+2      	; 0x5020 <gc_execute_line.constprop.11+0x1346>
    501e:	5f c0       	rjmp	.+190    	; 0x50de <gc_execute_line.constprop.11+0x1404>
    5020:	8e 31       	cpi	r24, 0x1E	; 30
    5022:	09 f4       	brne	.+2      	; 0x5026 <gc_execute_line.constprop.11+0x134c>
    5024:	5c c0       	rjmp	.+184    	; 0x50de <gc_execute_line.constprop.11+0x1404>
    5026:	8a 30       	cpi	r24, 0x0A	; 10
    5028:	09 f4       	brne	.+2      	; 0x502c <gc_execute_line.constprop.11+0x1352>
    502a:	43 c0       	rjmp	.+134    	; 0x50b2 <gc_execute_line.constprop.11+0x13d8>
    502c:	80 91 d8 06 	lds	r24, 0x06D8	; 0x8006d8 <gc_block+0x1>
    5030:	80 93 97 06 	sts	0x0697, r24	; 0x800697 <gc_state>
    5034:	80 35       	cpi	r24, 0x50	; 80
    5036:	09 f4       	brne	.+2      	; 0x503a <gc_execute_line.constprop.11+0x1360>
    5038:	49 c3       	rjmp	.+1682   	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    503a:	bf 8d       	ldd	r27, Y+31	; 0x1f
    503c:	b2 30       	cpi	r27, 0x02	; 2
    503e:	09 f0       	breq	.+2      	; 0x5042 <gc_execute_line.constprop.11+0x1368>
    5040:	45 c3       	rjmp	.+1674   	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    5042:	81 30       	cpi	r24, 0x01	; 1
    5044:	09 f0       	breq	.+2      	; 0x5048 <gc_execute_line.constprop.11+0x136e>
    5046:	79 c0       	rjmp	.+242    	; 0x513a <gc_execute_line.constprop.11+0x1460>
    5048:	be 01       	movw	r22, r28
    504a:	63 5f       	subi	r22, 0xF3	; 243
    504c:	7f 4f       	sbci	r23, 0xFF	; 255
    504e:	85 e0       	ldi	r24, 0x05	; 5
    5050:	97 e0       	ldi	r25, 0x07	; 7
    5052:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    5056:	8c e0       	ldi	r24, 0x0C	; 12
    5058:	e5 e0       	ldi	r30, 0x05	; 5
    505a:	f7 e0       	ldi	r31, 0x07	; 7
    505c:	af ea       	ldi	r26, 0xAF	; 175
    505e:	b6 e0       	ldi	r27, 0x06	; 6
    5060:	01 90       	ld	r0, Z+
    5062:	0d 92       	st	X+, r0
    5064:	8a 95       	dec	r24
    5066:	e1 f7       	brne	.-8      	; 0x5060 <gc_execute_line.constprop.11+0x1386>
    5068:	31 c3       	rjmp	.+1634   	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    506a:	30 e1       	ldi	r19, 0x10	; 16
    506c:	f3 12       	cpse	r15, r19
    506e:	c1 ce       	rjmp	.-638    	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    5070:	9b a1       	ldd	r25, Y+35	; 0x23
    5072:	90 74       	andi	r25, 0x40	; 64
    5074:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    5078:	81 50       	subi	r24, 0x01	; 1
    507a:	83 30       	cpi	r24, 0x03	; 3
    507c:	38 f4       	brcc	.+14     	; 0x508c <gc_execute_line.constprop.11+0x13b2>
    507e:	99 23       	and	r25, r25
    5080:	09 f4       	brne	.+2      	; 0x5084 <gc_execute_line.constprop.11+0x13aa>
    5082:	b7 ce       	rjmp	.-658    	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    5084:	4b a1       	ldd	r20, Y+35	; 0x23
    5086:	40 62       	ori	r20, 0x20	; 32
    5088:	4b a3       	std	Y+35, r20	; 0x23
    508a:	b3 ce       	rjmp	.-666    	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    508c:	91 11       	cpse	r25, r1
    508e:	b1 ce       	rjmp	.-670    	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    5090:	8b a1       	ldd	r24, Y+35	; 0x23
    5092:	80 62       	ori	r24, 0x20	; 32
    5094:	8b a3       	std	Y+35, r24	; 0x23
    5096:	ad ce       	rjmp	.-678    	; 0x4df2 <gc_execute_line.constprop.11+0x1118>
    5098:	8c 35       	cpi	r24, 0x5C	; 92
    509a:	09 f4       	brne	.+2      	; 0x509e <gc_execute_line.constprop.11+0x13c4>
    509c:	40 c0       	rjmp	.+128    	; 0x511e <gc_execute_line.constprop.11+0x1444>
    509e:	86 36       	cpi	r24, 0x66	; 102
    50a0:	09 f4       	brne	.+2      	; 0x50a4 <gc_execute_line.constprop.11+0x13ca>
    50a2:	43 c0       	rjmp	.+134    	; 0x512a <gc_execute_line.constprop.11+0x1450>
    50a4:	88 32       	cpi	r24, 0x28	; 40
    50a6:	09 f0       	breq	.+2      	; 0x50aa <gc_execute_line.constprop.11+0x13d0>
    50a8:	c1 cf       	rjmp	.-126    	; 0x502c <gc_execute_line.constprop.11+0x1352>
    50aa:	6f ea       	ldi	r22, 0xAF	; 175
    50ac:	76 e0       	ldi	r23, 0x06	; 6
    50ae:	87 e0       	ldi	r24, 0x07	; 7
    50b0:	33 c0       	rjmp	.+102    	; 0x5118 <gc_execute_line.constprop.11+0x143e>
    50b2:	67 ee       	ldi	r22, 0xE7	; 231
    50b4:	76 e0       	ldi	r23, 0x06	; 6
    50b6:	89 a5       	ldd	r24, Y+41	; 0x29
    50b8:	0e 94 5d 1d 	call	0x3aba	; 0x3aba <settings_write_coord_data>
    50bc:	80 91 9d 06 	lds	r24, 0x069D	; 0x80069d <gc_state+0x6>
    50c0:	f9 a5       	ldd	r31, Y+41	; 0x29
    50c2:	f8 13       	cpse	r31, r24
    50c4:	b3 cf       	rjmp	.-154    	; 0x502c <gc_execute_line.constprop.11+0x1352>
    50c6:	8c e0       	ldi	r24, 0x0C	; 12
    50c8:	e7 ee       	ldi	r30, 0xE7	; 231
    50ca:	f6 e0       	ldi	r31, 0x06	; 6
    50cc:	ab eb       	ldi	r26, 0xBB	; 187
    50ce:	b6 e0       	ldi	r27, 0x06	; 6
    50d0:	01 90       	ld	r0, Z+
    50d2:	0d 92       	st	X+, r0
    50d4:	8a 95       	dec	r24
    50d6:	e1 f7       	brne	.-8      	; 0x50d0 <gc_execute_line.constprop.11+0x13f6>
    50d8:	0e 94 58 1d 	call	0x3ab0	; 0x3ab0 <system_flag_wco_change>
    50dc:	a7 cf       	rjmp	.-178    	; 0x502c <gc_execute_line.constprop.11+0x1352>
    50de:	8d 89       	ldd	r24, Y+21	; 0x15
    50e0:	81 60       	ori	r24, 0x01	; 1
    50e2:	8d 8b       	std	Y+21, r24	; 0x15
    50e4:	2f 8d       	ldd	r18, Y+31	; 0x1f
    50e6:	22 23       	and	r18, r18
    50e8:	29 f0       	breq	.+10     	; 0x50f4 <gc_execute_line.constprop.11+0x141a>
    50ea:	b8 01       	movw	r22, r16
    50ec:	85 e0       	ldi	r24, 0x05	; 5
    50ee:	97 e0       	ldi	r25, 0x07	; 7
    50f0:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    50f4:	b8 01       	movw	r22, r16
    50f6:	87 ee       	ldi	r24, 0xE7	; 231
    50f8:	96 e0       	ldi	r25, 0x06	; 6
    50fa:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    50fe:	8c e0       	ldi	r24, 0x0C	; 12
    5100:	e7 ee       	ldi	r30, 0xE7	; 231
    5102:	f6 e0       	ldi	r31, 0x06	; 6
    5104:	af ea       	ldi	r26, 0xAF	; 175
    5106:	b6 e0       	ldi	r27, 0x06	; 6
    5108:	01 90       	ld	r0, Z+
    510a:	0d 92       	st	X+, r0
    510c:	8a 95       	dec	r24
    510e:	e1 f7       	brne	.-8      	; 0x5108 <gc_execute_line.constprop.11+0x142e>
    5110:	8d cf       	rjmp	.-230    	; 0x502c <gc_execute_line.constprop.11+0x1352>
    5112:	6f ea       	ldi	r22, 0xAF	; 175
    5114:	76 e0       	ldi	r23, 0x06	; 6
    5116:	86 e0       	ldi	r24, 0x06	; 6
    5118:	0e 94 5d 1d 	call	0x3aba	; 0x3aba <settings_write_coord_data>
    511c:	87 cf       	rjmp	.-242    	; 0x502c <gc_execute_line.constprop.11+0x1352>
    511e:	8c e0       	ldi	r24, 0x0C	; 12
    5120:	e5 e0       	ldi	r30, 0x05	; 5
    5122:	f7 e0       	ldi	r31, 0x07	; 7
    5124:	a7 ec       	ldi	r26, 0xC7	; 199
    5126:	b6 e0       	ldi	r27, 0x06	; 6
    5128:	d3 cf       	rjmp	.-90     	; 0x50d0 <gc_execute_line.constprop.11+0x13f6>
    512a:	e7 ec       	ldi	r30, 0xC7	; 199
    512c:	f6 e0       	ldi	r31, 0x06	; 6
    512e:	8c e0       	ldi	r24, 0x0C	; 12
    5130:	df 01       	movw	r26, r30
    5132:	1d 92       	st	X+, r1
    5134:	8a 95       	dec	r24
    5136:	e9 f7       	brne	.-6      	; 0x5132 <gc_execute_line.constprop.11+0x1458>
    5138:	cf cf       	rjmp	.-98     	; 0x50d8 <gc_execute_line.constprop.11+0x13fe>
    513a:	81 11       	cpse	r24, r1
    513c:	05 c0       	rjmp	.+10     	; 0x5148 <gc_execute_line.constprop.11+0x146e>
    513e:	8d 89       	ldd	r24, Y+21	; 0x15
    5140:	81 60       	ori	r24, 0x01	; 1
    5142:	8d 8b       	std	Y+21, r24	; 0x15
    5144:	b8 01       	movw	r22, r16
    5146:	83 cf       	rjmp	.-250    	; 0x504e <gc_execute_line.constprop.11+0x1374>
    5148:	82 50       	subi	r24, 0x02	; 2
    514a:	82 30       	cpi	r24, 0x02	; 2
    514c:	08 f0       	brcs	.+2      	; 0x5150 <gc_execute_line.constprop.11+0x1476>
    514e:	97 c2       	rjmp	.+1326   	; 0x567e <gc_execute_line.constprop.11+0x19a4>
    5150:	80 91 fc 06 	lds	r24, 0x06FC	; 0x8006fc <gc_block+0x25>
    5154:	90 91 fd 06 	lds	r25, 0x06FD	; 0x8006fd <gc_block+0x26>
    5158:	a0 91 fe 06 	lds	r26, 0x06FE	; 0x8006fe <gc_block+0x27>
    515c:	b0 91 ff 06 	lds	r27, 0x06FF	; 0x8006ff <gc_block+0x28>
    5160:	8f 8f       	std	Y+31, r24	; 0x1f
    5162:	98 a3       	std	Y+32, r25	; 0x20
    5164:	a9 a3       	std	Y+33, r26	; 0x21
    5166:	ba a3       	std	Y+34, r27	; 0x22
    5168:	a9 ad       	ldd	r26, Y+57	; 0x39
    516a:	94 e0       	ldi	r25, 0x04	; 4
    516c:	a9 9f       	mul	r26, r25
    516e:	70 01       	movw	r14, r0
    5170:	11 24       	eor	r1, r1
    5172:	f7 01       	movw	r30, r14
    5174:	e1 55       	subi	r30, 0x51	; 81
    5176:	f9 4f       	sbci	r31, 0xF9	; 249
    5178:	f8 a7       	std	Y+40, r31	; 0x28
    517a:	ef a3       	std	Y+39, r30	; 0x27
    517c:	97 01       	movw	r18, r14
    517e:	29 51       	subi	r18, 0x19	; 25
    5180:	39 4f       	sbci	r19, 0xF9	; 249
    5182:	3a a7       	std	Y+42, r19	; 0x2a
    5184:	29 a7       	std	Y+41, r18	; 0x29
    5186:	d9 01       	movw	r26, r18
    5188:	4d 90       	ld	r4, X+
    518a:	5d 90       	ld	r5, X+
    518c:	6d 90       	ld	r6, X+
    518e:	7c 90       	ld	r7, X
    5190:	20 81       	ld	r18, Z
    5192:	31 81       	ldd	r19, Z+1	; 0x01
    5194:	42 81       	ldd	r20, Z+2	; 0x02
    5196:	53 81       	ldd	r21, Z+3	; 0x03
    5198:	c3 01       	movw	r24, r6
    519a:	b2 01       	movw	r22, r4
    519c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    51a0:	6d a7       	std	Y+45, r22	; 0x2d
    51a2:	7e a7       	std	Y+46, r23	; 0x2e
    51a4:	8f a7       	std	Y+47, r24	; 0x2f
    51a6:	98 ab       	std	Y+48, r25	; 0x30
    51a8:	eb ad       	ldd	r30, Y+59	; 0x3b
    51aa:	b4 e0       	ldi	r27, 0x04	; 4
    51ac:	eb 9f       	mul	r30, r27
    51ae:	80 01       	movw	r16, r0
    51b0:	11 24       	eor	r1, r1
    51b2:	98 01       	movw	r18, r16
    51b4:	21 55       	subi	r18, 0x51	; 81
    51b6:	39 4f       	sbci	r19, 0xF9	; 249
    51b8:	3a af       	std	Y+58, r19	; 0x3a
    51ba:	29 af       	std	Y+57, r18	; 0x39
    51bc:	c8 01       	movw	r24, r16
    51be:	89 51       	subi	r24, 0x19	; 25
    51c0:	99 4f       	sbci	r25, 0xF9	; 249
    51c2:	9c af       	std	Y+60, r25	; 0x3c
    51c4:	8b af       	std	Y+59, r24	; 0x3b
    51c6:	dc 01       	movw	r26, r24
    51c8:	8d 90       	ld	r8, X+
    51ca:	9d 90       	ld	r9, X+
    51cc:	ad 90       	ld	r10, X+
    51ce:	bc 90       	ld	r11, X
    51d0:	f9 01       	movw	r30, r18
    51d2:	20 81       	ld	r18, Z
    51d4:	31 81       	ldd	r19, Z+1	; 0x01
    51d6:	42 81       	ldd	r20, Z+2	; 0x02
    51d8:	53 81       	ldd	r21, Z+3	; 0x03
    51da:	c5 01       	movw	r24, r10
    51dc:	b4 01       	movw	r22, r8
    51de:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    51e2:	69 ab       	std	Y+49, r22	; 0x31
    51e4:	7a ab       	std	Y+50, r23	; 0x32
    51e6:	8b ab       	std	Y+51, r24	; 0x33
    51e8:	9c ab       	std	Y+52, r25	; 0x34
    51ea:	77 fa       	bst	r7, 7
    51ec:	70 94       	com	r7
    51ee:	77 f8       	bld	r7, 7
    51f0:	70 94       	com	r7
    51f2:	d5 01       	movw	r26, r10
    51f4:	c4 01       	movw	r24, r8
    51f6:	b0 58       	subi	r27, 0x80	; 128
    51f8:	8b 8f       	std	Y+27, r24	; 0x1b
    51fa:	9c 8f       	std	Y+28, r25	; 0x1c
    51fc:	ad 8f       	std	Y+29, r26	; 0x1d
    51fe:	be 8f       	std	Y+30, r27	; 0x1e
    5200:	f7 01       	movw	r30, r14
    5202:	eb 5f       	subi	r30, 0xFB	; 251
    5204:	f8 4f       	sbci	r31, 0xF8	; 248
    5206:	2d a5       	ldd	r18, Y+45	; 0x2d
    5208:	3e a5       	ldd	r19, Y+46	; 0x2e
    520a:	4f a5       	ldd	r20, Y+47	; 0x2f
    520c:	58 a9       	ldd	r21, Y+48	; 0x30
    520e:	60 81       	ld	r22, Z
    5210:	71 81       	ldd	r23, Z+1	; 0x01
    5212:	82 81       	ldd	r24, Z+2	; 0x02
    5214:	93 81       	ldd	r25, Z+3	; 0x03
    5216:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    521a:	6b 01       	movw	r12, r22
    521c:	7c 01       	movw	r14, r24
    521e:	f8 01       	movw	r30, r16
    5220:	eb 5f       	subi	r30, 0xFB	; 251
    5222:	f8 4f       	sbci	r31, 0xF8	; 248
    5224:	29 a9       	ldd	r18, Y+49	; 0x31
    5226:	3a a9       	ldd	r19, Y+50	; 0x32
    5228:	4b a9       	ldd	r20, Y+51	; 0x33
    522a:	5c a9       	ldd	r21, Y+52	; 0x34
    522c:	60 81       	ld	r22, Z
    522e:	71 81       	ldd	r23, Z+1	; 0x01
    5230:	82 81       	ldd	r24, Z+2	; 0x02
    5232:	93 81       	ldd	r25, Z+3	; 0x03
    5234:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    5238:	4b 01       	movw	r8, r22
    523a:	5c 01       	movw	r10, r24
    523c:	a7 01       	movw	r20, r14
    523e:	96 01       	movw	r18, r12
    5240:	c3 01       	movw	r24, r6
    5242:	b2 01       	movw	r22, r4
    5244:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5248:	6d ab       	std	Y+53, r22	; 0x35
    524a:	7e ab       	std	Y+54, r23	; 0x36
    524c:	8f ab       	std	Y+55, r24	; 0x37
    524e:	98 af       	std	Y+56, r25	; 0x38
    5250:	a5 01       	movw	r20, r10
    5252:	94 01       	movw	r18, r8
    5254:	6b 8d       	ldd	r22, Y+27	; 0x1b
    5256:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5258:	8d 8d       	ldd	r24, Y+29	; 0x1d
    525a:	9e 8d       	ldd	r25, Y+30	; 0x1e
    525c:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5260:	9b 01       	movw	r18, r22
    5262:	ac 01       	movw	r20, r24
    5264:	6d a9       	ldd	r22, Y+53	; 0x35
    5266:	7e a9       	ldd	r23, Y+54	; 0x36
    5268:	8f a9       	ldd	r24, Y+55	; 0x37
    526a:	98 ad       	ldd	r25, Y+56	; 0x38
    526c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5270:	6d ab       	std	Y+53, r22	; 0x35
    5272:	7e ab       	std	Y+54, r23	; 0x36
    5274:	8f ab       	std	Y+55, r24	; 0x37
    5276:	98 af       	std	Y+56, r25	; 0x38
    5278:	a5 01       	movw	r20, r10
    527a:	94 01       	movw	r18, r8
    527c:	c3 01       	movw	r24, r6
    527e:	b2 01       	movw	r22, r4
    5280:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5284:	4b 01       	movw	r8, r22
    5286:	5c 01       	movw	r10, r24
    5288:	a7 01       	movw	r20, r14
    528a:	96 01       	movw	r18, r12
    528c:	6b 8d       	ldd	r22, Y+27	; 0x1b
    528e:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5290:	8d 8d       	ldd	r24, Y+29	; 0x1d
    5292:	9e 8d       	ldd	r25, Y+30	; 0x1e
    5294:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5298:	9b 01       	movw	r18, r22
    529a:	ac 01       	movw	r20, r24
    529c:	c5 01       	movw	r24, r10
    529e:	b4 01       	movw	r22, r8
    52a0:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    52a4:	2d a9       	ldd	r18, Y+53	; 0x35
    52a6:	3e a9       	ldd	r19, Y+54	; 0x36
    52a8:	4f a9       	ldd	r20, Y+55	; 0x37
    52aa:	58 ad       	ldd	r21, Y+56	; 0x38
    52ac:	0e 94 c3 35 	call	0x6b86	; 0x6b86 <atan2>
    52b0:	6b 01       	movw	r12, r22
    52b2:	7c 01       	movw	r14, r24
    52b4:	9b a1       	ldd	r25, Y+35	; 0x23
    52b6:	92 ff       	sbrs	r25, 2
    52b8:	68 c1       	rjmp	.+720    	; 0x558a <gc_execute_line.constprop.11+0x18b0>
    52ba:	2d eb       	ldi	r18, 0xBD	; 189
    52bc:	37 e3       	ldi	r19, 0x37	; 55
    52be:	46 e0       	ldi	r20, 0x06	; 6
    52c0:	55 eb       	ldi	r21, 0xB5	; 181
    52c2:	c7 01       	movw	r24, r14
    52c4:	b6 01       	movw	r22, r12
    52c6:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    52ca:	87 fd       	sbrc	r24, 7
    52cc:	0a c0       	rjmp	.+20     	; 0x52e2 <gc_execute_line.constprop.11+0x1608>
    52ce:	2b ed       	ldi	r18, 0xDB	; 219
    52d0:	3f e0       	ldi	r19, 0x0F	; 15
    52d2:	49 ec       	ldi	r20, 0xC9	; 201
    52d4:	50 e4       	ldi	r21, 0x40	; 64
    52d6:	c7 01       	movw	r24, r14
    52d8:	b6 01       	movw	r22, r12
    52da:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    52de:	6b 01       	movw	r12, r22
    52e0:	7c 01       	movw	r14, r24
    52e2:	80 90 7b 06 	lds	r8, 0x067B	; 0x80067b <settings+0x39>
    52e6:	90 90 7c 06 	lds	r9, 0x067C	; 0x80067c <settings+0x3a>
    52ea:	a0 90 7d 06 	lds	r10, 0x067D	; 0x80067d <settings+0x3b>
    52ee:	b0 90 7e 06 	lds	r11, 0x067E	; 0x80067e <settings+0x3c>
    52f2:	2f 8d       	ldd	r18, Y+31	; 0x1f
    52f4:	38 a1       	ldd	r19, Y+32	; 0x20
    52f6:	49 a1       	ldd	r20, Y+33	; 0x21
    52f8:	5a a1       	ldd	r21, Y+34	; 0x22
    52fa:	ca 01       	movw	r24, r20
    52fc:	b9 01       	movw	r22, r18
    52fe:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5302:	a5 01       	movw	r20, r10
    5304:	94 01       	movw	r18, r8
    5306:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    530a:	a5 01       	movw	r20, r10
    530c:	94 01       	movw	r18, r8
    530e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5312:	0e 94 3a 39 	call	0x7274	; 0x7274 <sqrt>
    5316:	4b 01       	movw	r8, r22
    5318:	5c 01       	movw	r10, r24
    531a:	20 e0       	ldi	r18, 0x00	; 0
    531c:	30 e0       	ldi	r19, 0x00	; 0
    531e:	40 e0       	ldi	r20, 0x00	; 0
    5320:	5f e3       	ldi	r21, 0x3F	; 63
    5322:	c7 01       	movw	r24, r14
    5324:	b6 01       	movw	r22, r12
    5326:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    532a:	2f 8d       	ldd	r18, Y+31	; 0x1f
    532c:	38 a1       	ldd	r19, Y+32	; 0x20
    532e:	49 a1       	ldd	r20, Y+33	; 0x21
    5330:	5a a1       	ldd	r21, Y+34	; 0x22
    5332:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5336:	9f 77       	andi	r25, 0x7F	; 127
    5338:	a5 01       	movw	r20, r10
    533a:	94 01       	movw	r18, r8
    533c:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    5340:	0e 94 28 37 	call	0x6e50	; 0x6e50 <floor>
    5344:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    5348:	7e ab       	std	Y+54, r23	; 0x36
    534a:	6d ab       	std	Y+53, r22	; 0x35
    534c:	db 01       	movw	r26, r22
    534e:	ab 2b       	or	r26, r27
    5350:	09 f4       	brne	.+2      	; 0x5354 <gc_execute_line.constprop.11+0x167a>
    5352:	7a ce       	rjmp	.-780    	; 0x5048 <gc_execute_line.constprop.11+0x136e>
    5354:	1d 89       	ldd	r17, Y+21	; 0x15
    5356:	90 e0       	ldi	r25, 0x00	; 0
    5358:	80 e0       	ldi	r24, 0x00	; 0
    535a:	0e 94 eb 36 	call	0x6dd6	; 0x6dd6 <__floatunsisf>
    535e:	4b 01       	movw	r8, r22
    5360:	5c 01       	movw	r10, r24
    5362:	13 ff       	sbrs	r17, 3
    5364:	0e c0       	rjmp	.+28     	; 0x5382 <gc_execute_line.constprop.11+0x16a8>
    5366:	ac 01       	movw	r20, r24
    5368:	9b 01       	movw	r18, r22
    536a:	6d 85       	ldd	r22, Y+13	; 0x0d
    536c:	7e 85       	ldd	r23, Y+14	; 0x0e
    536e:	8f 85       	ldd	r24, Y+15	; 0x0f
    5370:	98 89       	ldd	r25, Y+16	; 0x10
    5372:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5376:	6d 87       	std	Y+13, r22	; 0x0d
    5378:	7e 87       	std	Y+14, r23	; 0x0e
    537a:	8f 87       	std	Y+15, r24	; 0x0f
    537c:	98 8b       	std	Y+16, r25	; 0x10
    537e:	17 7f       	andi	r17, 0xF7	; 247
    5380:	1d 8b       	std	Y+21, r17	; 0x15
    5382:	a5 01       	movw	r20, r10
    5384:	94 01       	movw	r18, r8
    5386:	c7 01       	movw	r24, r14
    5388:	b6 01       	movw	r22, r12
    538a:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    538e:	6b a3       	std	Y+35, r22	; 0x23
    5390:	7c a3       	std	Y+36, r23	; 0x24
    5392:	8d a3       	std	Y+37, r24	; 0x25
    5394:	9e a3       	std	Y+38, r25	; 0x26
    5396:	22 96       	adiw	r28, 0x02	; 2
    5398:	ef ad       	ldd	r30, Y+63	; 0x3f
    539a:	22 97       	sbiw	r28, 0x02	; 2
    539c:	b4 e0       	ldi	r27, 0x04	; 4
    539e:	eb 9f       	mul	r30, r27
    53a0:	c0 01       	movw	r24, r0
    53a2:	11 24       	eor	r1, r1
    53a4:	8c 01       	movw	r16, r24
    53a6:	01 55       	subi	r16, 0x51	; 81
    53a8:	19 4f       	sbci	r17, 0xF9	; 249
    53aa:	8b 5f       	subi	r24, 0xFB	; 251
    53ac:	98 4f       	sbci	r25, 0xF8	; 248
    53ae:	d8 01       	movw	r26, r16
    53b0:	2d 91       	ld	r18, X+
    53b2:	3d 91       	ld	r19, X+
    53b4:	4d 91       	ld	r20, X+
    53b6:	5c 91       	ld	r21, X
    53b8:	fc 01       	movw	r30, r24
    53ba:	60 81       	ld	r22, Z
    53bc:	71 81       	ldd	r23, Z+1	; 0x01
    53be:	82 81       	ldd	r24, Z+2	; 0x02
    53c0:	93 81       	ldd	r25, Z+3	; 0x03
    53c2:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    53c6:	a5 01       	movw	r20, r10
    53c8:	94 01       	movw	r18, r8
    53ca:	0e 94 43 36 	call	0x6c86	; 0x6c86 <__divsf3>
    53ce:	29 96       	adiw	r28, 0x09	; 9
    53d0:	6c af       	std	Y+60, r22	; 0x3c
    53d2:	7d af       	std	Y+61, r23	; 0x3d
    53d4:	8e af       	std	Y+62, r24	; 0x3e
    53d6:	9f af       	std	Y+63, r25	; 0x3f
    53d8:	29 97       	sbiw	r28, 0x09	; 9
    53da:	2b a1       	ldd	r18, Y+35	; 0x23
    53dc:	3c a1       	ldd	r19, Y+36	; 0x24
    53de:	4d a1       	ldd	r20, Y+37	; 0x25
    53e0:	5e a1       	ldd	r21, Y+38	; 0x26
    53e2:	ca 01       	movw	r24, r20
    53e4:	b9 01       	movw	r22, r18
    53e6:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    53ea:	9b 01       	movw	r18, r22
    53ec:	ac 01       	movw	r20, r24
    53ee:	60 e0       	ldi	r22, 0x00	; 0
    53f0:	70 e0       	ldi	r23, 0x00	; 0
    53f2:	80 e0       	ldi	r24, 0x00	; 0
    53f4:	90 e4       	ldi	r25, 0x40	; 64
    53f6:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    53fa:	6b 01       	movw	r12, r22
    53fc:	7c 01       	movw	r14, r24
    53fe:	2b ea       	ldi	r18, 0xAB	; 171
    5400:	3a ea       	ldi	r19, 0xAA	; 170
    5402:	4a e2       	ldi	r20, 0x2A	; 42
    5404:	5e e3       	ldi	r21, 0x3E	; 62
    5406:	6b a1       	ldd	r22, Y+35	; 0x23
    5408:	7c a1       	ldd	r23, Y+36	; 0x24
    540a:	8d a1       	ldd	r24, Y+37	; 0x25
    540c:	9e a1       	ldd	r25, Y+38	; 0x26
    540e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5412:	4b 01       	movw	r8, r22
    5414:	5c 01       	movw	r10, r24
    5416:	20 e0       	ldi	r18, 0x00	; 0
    5418:	30 e0       	ldi	r19, 0x00	; 0
    541a:	40 e8       	ldi	r20, 0x80	; 128
    541c:	50 e4       	ldi	r21, 0x40	; 64
    541e:	c7 01       	movw	r24, r14
    5420:	b6 01       	movw	r22, r12
    5422:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5426:	9b 01       	movw	r18, r22
    5428:	ac 01       	movw	r20, r24
    542a:	c5 01       	movw	r24, r10
    542c:	b4 01       	movw	r22, r8
    542e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5432:	21 96       	adiw	r28, 0x01	; 1
    5434:	6c af       	std	Y+60, r22	; 0x3c
    5436:	7d af       	std	Y+61, r23	; 0x3d
    5438:	8e af       	std	Y+62, r24	; 0x3e
    543a:	9f af       	std	Y+63, r25	; 0x3f
    543c:	21 97       	sbiw	r28, 0x01	; 1
    543e:	20 e0       	ldi	r18, 0x00	; 0
    5440:	30 e0       	ldi	r19, 0x00	; 0
    5442:	40 e0       	ldi	r20, 0x00	; 0
    5444:	5f e3       	ldi	r21, 0x3F	; 63
    5446:	c7 01       	movw	r24, r14
    5448:	b6 01       	movw	r22, r12
    544a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    544e:	25 96       	adiw	r28, 0x05	; 5
    5450:	6c af       	std	Y+60, r22	; 0x3c
    5452:	7d af       	std	Y+61, r23	; 0x3d
    5454:	8e af       	std	Y+62, r24	; 0x3e
    5456:	9f af       	std	Y+63, r25	; 0x3f
    5458:	25 97       	sbiw	r28, 0x05	; 5
    545a:	1f 8e       	std	Y+31, r1	; 0x1f
    545c:	22 24       	eor	r2, r2
    545e:	23 94       	inc	r2
    5460:	31 2c       	mov	r3, r1
    5462:	ed a9       	ldd	r30, Y+53	; 0x35
    5464:	fe a9       	ldd	r31, Y+54	; 0x36
    5466:	e2 15       	cp	r30, r2
    5468:	f3 05       	cpc	r31, r3
    546a:	09 f4       	brne	.+2      	; 0x546e <gc_execute_line.constprop.11+0x1794>
    546c:	ed cd       	rjmp	.-1062   	; 0x5048 <gc_execute_line.constprop.11+0x136e>
    546e:	ff 8d       	ldd	r31, Y+31	; 0x1f
    5470:	fc 30       	cpi	r31, 0x0C	; 12
    5472:	08 f0       	brcs	.+2      	; 0x5476 <gc_execute_line.constprop.11+0x179c>
    5474:	9e c0       	rjmp	.+316    	; 0x55b2 <gc_execute_line.constprop.11+0x18d8>
    5476:	a3 01       	movw	r20, r6
    5478:	92 01       	movw	r18, r4
    547a:	21 96       	adiw	r28, 0x01	; 1
    547c:	6c ad       	ldd	r22, Y+60	; 0x3c
    547e:	7d ad       	ldd	r23, Y+61	; 0x3d
    5480:	8e ad       	ldd	r24, Y+62	; 0x3e
    5482:	9f ad       	ldd	r25, Y+63	; 0x3f
    5484:	21 97       	sbiw	r28, 0x01	; 1
    5486:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    548a:	6b 01       	movw	r12, r22
    548c:	7c 01       	movw	r14, r24
    548e:	2b 8d       	ldd	r18, Y+27	; 0x1b
    5490:	3c 8d       	ldd	r19, Y+28	; 0x1c
    5492:	4d 8d       	ldd	r20, Y+29	; 0x1d
    5494:	5e 8d       	ldd	r21, Y+30	; 0x1e
    5496:	25 96       	adiw	r28, 0x05	; 5
    5498:	6c ad       	ldd	r22, Y+60	; 0x3c
    549a:	7d ad       	ldd	r23, Y+61	; 0x3d
    549c:	8e ad       	ldd	r24, Y+62	; 0x3e
    549e:	9f ad       	ldd	r25, Y+63	; 0x3f
    54a0:	25 97       	sbiw	r28, 0x05	; 5
    54a2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    54a6:	9b 01       	movw	r18, r22
    54a8:	ac 01       	movw	r20, r24
    54aa:	c7 01       	movw	r24, r14
    54ac:	b6 01       	movw	r22, r12
    54ae:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    54b2:	7b 01       	movw	r14, r22
    54b4:	6c 01       	movw	r12, r24
    54b6:	a3 01       	movw	r20, r6
    54b8:	92 01       	movw	r18, r4
    54ba:	25 96       	adiw	r28, 0x05	; 5
    54bc:	6c ad       	ldd	r22, Y+60	; 0x3c
    54be:	7d ad       	ldd	r23, Y+61	; 0x3d
    54c0:	8e ad       	ldd	r24, Y+62	; 0x3e
    54c2:	9f ad       	ldd	r25, Y+63	; 0x3f
    54c4:	25 97       	sbiw	r28, 0x05	; 5
    54c6:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    54ca:	4b 01       	movw	r8, r22
    54cc:	5c 01       	movw	r10, r24
    54ce:	2b 8d       	ldd	r18, Y+27	; 0x1b
    54d0:	3c 8d       	ldd	r19, Y+28	; 0x1c
    54d2:	4d 8d       	ldd	r20, Y+29	; 0x1d
    54d4:	5e 8d       	ldd	r21, Y+30	; 0x1e
    54d6:	21 96       	adiw	r28, 0x01	; 1
    54d8:	6c ad       	ldd	r22, Y+60	; 0x3c
    54da:	7d ad       	ldd	r23, Y+61	; 0x3d
    54dc:	8e ad       	ldd	r24, Y+62	; 0x3e
    54de:	9f ad       	ldd	r25, Y+63	; 0x3f
    54e0:	21 97       	sbiw	r28, 0x01	; 1
    54e2:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    54e6:	9b 01       	movw	r18, r22
    54e8:	ac 01       	movw	r20, r24
    54ea:	c5 01       	movw	r24, r10
    54ec:	b4 01       	movw	r22, r8
    54ee:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    54f2:	2b 01       	movw	r4, r22
    54f4:	3c 01       	movw	r6, r24
    54f6:	2f 8d       	ldd	r18, Y+31	; 0x1f
    54f8:	2f 5f       	subi	r18, 0xFF	; 255
    54fa:	2f 8f       	std	Y+31, r18	; 0x1f
    54fc:	47 01       	movw	r8, r14
    54fe:	56 01       	movw	r10, r12
    5500:	8b 8e       	std	Y+27, r8	; 0x1b
    5502:	9c 8e       	std	Y+28, r9	; 0x1c
    5504:	ad 8e       	std	Y+29, r10	; 0x1d
    5506:	be 8e       	std	Y+30, r11	; 0x1e
    5508:	a3 01       	movw	r20, r6
    550a:	92 01       	movw	r18, r4
    550c:	6d a5       	ldd	r22, Y+45	; 0x2d
    550e:	7e a5       	ldd	r23, Y+46	; 0x2e
    5510:	8f a5       	ldd	r24, Y+47	; 0x2f
    5512:	98 a9       	ldd	r25, Y+48	; 0x30
    5514:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5518:	ef a1       	ldd	r30, Y+39	; 0x27
    551a:	f8 a5       	ldd	r31, Y+40	; 0x28
    551c:	60 83       	st	Z, r22
    551e:	71 83       	std	Z+1, r23	; 0x01
    5520:	82 83       	std	Z+2, r24	; 0x02
    5522:	93 83       	std	Z+3, r25	; 0x03
    5524:	2b 8d       	ldd	r18, Y+27	; 0x1b
    5526:	3c 8d       	ldd	r19, Y+28	; 0x1c
    5528:	4d 8d       	ldd	r20, Y+29	; 0x1d
    552a:	5e 8d       	ldd	r21, Y+30	; 0x1e
    552c:	69 a9       	ldd	r22, Y+49	; 0x31
    552e:	7a a9       	ldd	r23, Y+50	; 0x32
    5530:	8b a9       	ldd	r24, Y+51	; 0x33
    5532:	9c a9       	ldd	r25, Y+52	; 0x34
    5534:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5538:	a9 ad       	ldd	r26, Y+57	; 0x39
    553a:	ba ad       	ldd	r27, Y+58	; 0x3a
    553c:	6d 93       	st	X+, r22
    553e:	7d 93       	st	X+, r23
    5540:	8d 93       	st	X+, r24
    5542:	9c 93       	st	X, r25
    5544:	13 97       	sbiw	r26, 0x03	; 3
    5546:	29 96       	adiw	r28, 0x09	; 9
    5548:	2c ad       	ldd	r18, Y+60	; 0x3c
    554a:	3d ad       	ldd	r19, Y+61	; 0x3d
    554c:	4e ad       	ldd	r20, Y+62	; 0x3e
    554e:	5f ad       	ldd	r21, Y+63	; 0x3f
    5550:	29 97       	sbiw	r28, 0x09	; 9
    5552:	f8 01       	movw	r30, r16
    5554:	60 81       	ld	r22, Z
    5556:	71 81       	ldd	r23, Z+1	; 0x01
    5558:	82 81       	ldd	r24, Z+2	; 0x02
    555a:	93 81       	ldd	r25, Z+3	; 0x03
    555c:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    5560:	d8 01       	movw	r26, r16
    5562:	6d 93       	st	X+, r22
    5564:	7d 93       	st	X+, r23
    5566:	8d 93       	st	X+, r24
    5568:	9c 93       	st	X, r25
    556a:	13 97       	sbiw	r26, 0x03	; 3
    556c:	be 01       	movw	r22, r28
    556e:	63 5f       	subi	r22, 0xF3	; 243
    5570:	7f 4f       	sbci	r23, 0xFF	; 255
    5572:	8f ea       	ldi	r24, 0xAF	; 175
    5574:	96 e0       	ldi	r25, 0x06	; 6
    5576:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    557a:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    557e:	81 11       	cpse	r24, r1
    5580:	6a cd       	rjmp	.-1324   	; 0x5056 <gc_execute_line.constprop.11+0x137c>
    5582:	bf ef       	ldi	r27, 0xFF	; 255
    5584:	2b 1a       	sub	r2, r27
    5586:	3b 0a       	sbc	r3, r27
    5588:	6c cf       	rjmp	.-296    	; 0x5462 <gc_execute_line.constprop.11+0x1788>
    558a:	2d eb       	ldi	r18, 0xBD	; 189
    558c:	37 e3       	ldi	r19, 0x37	; 55
    558e:	46 e0       	ldi	r20, 0x06	; 6
    5590:	55 e3       	ldi	r21, 0x35	; 53
    5592:	c7 01       	movw	r24, r14
    5594:	b6 01       	movw	r22, r12
    5596:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    559a:	18 16       	cp	r1, r24
    559c:	0c f4       	brge	.+2      	; 0x55a0 <gc_execute_line.constprop.11+0x18c6>
    559e:	a1 ce       	rjmp	.-702    	; 0x52e2 <gc_execute_line.constprop.11+0x1608>
    55a0:	2b ed       	ldi	r18, 0xDB	; 219
    55a2:	3f e0       	ldi	r19, 0x0F	; 15
    55a4:	49 ec       	ldi	r20, 0xC9	; 201
    55a6:	50 e4       	ldi	r21, 0x40	; 64
    55a8:	c7 01       	movw	r24, r14
    55aa:	b6 01       	movw	r22, r12
    55ac:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    55b0:	96 ce       	rjmp	.-724    	; 0x52de <gc_execute_line.constprop.11+0x1604>
    55b2:	b1 01       	movw	r22, r2
    55b4:	90 e0       	ldi	r25, 0x00	; 0
    55b6:	80 e0       	ldi	r24, 0x00	; 0
    55b8:	0e 94 eb 36 	call	0x6dd6	; 0x6dd6 <__floatunsisf>
    55bc:	2b a1       	ldd	r18, Y+35	; 0x23
    55be:	3c a1       	ldd	r19, Y+36	; 0x24
    55c0:	4d a1       	ldd	r20, Y+37	; 0x25
    55c2:	5e a1       	ldd	r21, Y+38	; 0x26
    55c4:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    55c8:	6b 01       	movw	r12, r22
    55ca:	7c 01       	movw	r14, r24
    55cc:	0e 94 3e 36 	call	0x6c7c	; 0x6c7c <cos>
    55d0:	6b 8f       	std	Y+27, r22	; 0x1b
    55d2:	7c 8f       	std	Y+28, r23	; 0x1c
    55d4:	8d 8f       	std	Y+29, r24	; 0x1d
    55d6:	9e 8f       	std	Y+30, r25	; 0x1e
    55d8:	c7 01       	movw	r24, r14
    55da:	b6 01       	movw	r22, r12
    55dc:	0e 94 2c 39 	call	0x7258	; 0x7258 <sin>
    55e0:	4b 01       	movw	r8, r22
    55e2:	5c 01       	movw	r10, r24
    55e4:	a9 a5       	ldd	r26, Y+41	; 0x29
    55e6:	ba a5       	ldd	r27, Y+42	; 0x2a
    55e8:	cd 90       	ld	r12, X+
    55ea:	dd 90       	ld	r13, X+
    55ec:	ed 90       	ld	r14, X+
    55ee:	fc 90       	ld	r15, X
    55f0:	f7 fa       	bst	r15, 7
    55f2:	f0 94       	com	r15
    55f4:	f7 f8       	bld	r15, 7
    55f6:	f0 94       	com	r15
    55f8:	ab ad       	ldd	r26, Y+59	; 0x3b
    55fa:	bc ad       	ldd	r27, Y+60	; 0x3c
    55fc:	8d 91       	ld	r24, X+
    55fe:	9d 91       	ld	r25, X+
    5600:	0d 90       	ld	r0, X+
    5602:	bc 91       	ld	r27, X
    5604:	a0 2d       	mov	r26, r0
    5606:	8f 8f       	std	Y+31, r24	; 0x1f
    5608:	98 a3       	std	Y+32, r25	; 0x20
    560a:	a9 a3       	std	Y+33, r26	; 0x21
    560c:	ba a3       	std	Y+34, r27	; 0x22
    560e:	a7 01       	movw	r20, r14
    5610:	96 01       	movw	r18, r12
    5612:	6b 8d       	ldd	r22, Y+27	; 0x1b
    5614:	7c 8d       	ldd	r23, Y+28	; 0x1c
    5616:	8d 8d       	ldd	r24, Y+29	; 0x1d
    5618:	9e 8d       	ldd	r25, Y+30	; 0x1e
    561a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    561e:	2b 01       	movw	r4, r22
    5620:	3c 01       	movw	r6, r24
    5622:	2f 8d       	ldd	r18, Y+31	; 0x1f
    5624:	38 a1       	ldd	r19, Y+32	; 0x20
    5626:	49 a1       	ldd	r20, Y+33	; 0x21
    5628:	5a a1       	ldd	r21, Y+34	; 0x22
    562a:	c5 01       	movw	r24, r10
    562c:	b4 01       	movw	r22, r8
    562e:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5632:	9b 01       	movw	r18, r22
    5634:	ac 01       	movw	r20, r24
    5636:	c3 01       	movw	r24, r6
    5638:	b2 01       	movw	r22, r4
    563a:	0e 94 44 35 	call	0x6a88	; 0x6a88 <__addsf3>
    563e:	2b 01       	movw	r4, r22
    5640:	3c 01       	movw	r6, r24
    5642:	a7 01       	movw	r20, r14
    5644:	96 01       	movw	r18, r12
    5646:	c5 01       	movw	r24, r10
    5648:	b4 01       	movw	r22, r8
    564a:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    564e:	6b 01       	movw	r12, r22
    5650:	7c 01       	movw	r14, r24
    5652:	2f 8d       	ldd	r18, Y+31	; 0x1f
    5654:	38 a1       	ldd	r19, Y+32	; 0x20
    5656:	49 a1       	ldd	r20, Y+33	; 0x21
    5658:	5a a1       	ldd	r21, Y+34	; 0x22
    565a:	6b 8d       	ldd	r22, Y+27	; 0x1b
    565c:	7c 8d       	ldd	r23, Y+28	; 0x1c
    565e:	8d 8d       	ldd	r24, Y+29	; 0x1d
    5660:	9e 8d       	ldd	r25, Y+30	; 0x1e
    5662:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    5666:	9b 01       	movw	r18, r22
    5668:	ac 01       	movw	r20, r24
    566a:	c7 01       	movw	r24, r14
    566c:	b6 01       	movw	r22, r12
    566e:	0e 94 43 35 	call	0x6a86	; 0x6a86 <__subsf3>
    5672:	6b 8f       	std	Y+27, r22	; 0x1b
    5674:	7c 8f       	std	Y+28, r23	; 0x1c
    5676:	8d 8f       	std	Y+29, r24	; 0x1d
    5678:	9e 8f       	std	Y+30, r25	; 0x1e
    567a:	1f 8e       	std	Y+31, r1	; 0x1f
    567c:	45 cf       	rjmp	.-374    	; 0x5508 <gc_execute_line.constprop.11+0x182e>
    567e:	8d 89       	ldd	r24, Y+21	; 0x15
    5680:	84 60       	ori	r24, 0x04	; 4
    5682:	8d 8b       	std	Y+21, r24	; 0x15
    5684:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5688:	82 30       	cpi	r24, 0x02	; 2
    568a:	09 f4       	brne	.+2      	; 0x568e <gc_execute_line.constprop.11+0x19b4>
    568c:	e4 cc       	rjmp	.-1592   	; 0x5056 <gc_execute_line.constprop.11+0x137c>
    568e:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    5692:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    5696:	81 11       	cpse	r24, r1
    5698:	19 c0       	rjmp	.+50     	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    569a:	fb a1       	ldd	r31, Y+35	; 0x23
    569c:	f0 71       	andi	r31, 0x10	; 16
    569e:	ff 2e       	mov	r15, r31
    56a0:	10 92 36 06 	sts	0x0636, r1	; 0x800636 <sys+0x5>
    56a4:	2b a1       	ldd	r18, Y+35	; 0x23
    56a6:	23 fb       	bst	r18, 3
    56a8:	88 27       	eor	r24, r24
    56aa:	80 f9       	bld	r24, 0
    56ac:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    56b0:	86 b1       	in	r24, 0x06	; 6
    56b2:	80 72       	andi	r24, 0x20	; 32
    56b4:	90 91 17 06 	lds	r25, 0x0617	; 0x800617 <probe_invert_mask>
    56b8:	89 17       	cp	r24, r25
    56ba:	19 f1       	breq	.+70     	; 0x5702 <gc_execute_line.constprop.11+0x1a28>
    56bc:	84 e0       	ldi	r24, 0x04	; 4
    56be:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    56c2:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    56c6:	80 e0       	ldi	r24, 0x00	; 0
    56c8:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    56cc:	80 91 df 06 	lds	r24, 0x06DF	; 0x8006df <gc_block+0x8>
    56d0:	80 93 9e 06 	sts	0x069E, r24	; 0x80069e <gc_state+0x7>
    56d4:	88 23       	and	r24, r24
    56d6:	11 f4       	brne	.+4      	; 0x56dc <gc_execute_line.constprop.11+0x1a02>
    56d8:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    56dc:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    56e0:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    56e4:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    56e8:	83 30       	cpi	r24, 0x03	; 3
    56ea:	09 f0       	breq	.+2      	; 0x56ee <gc_execute_line.constprop.11+0x1a14>
    56ec:	4d c0       	rjmp	.+154    	; 0x5788 <gc_execute_line.constprop.11+0x1aae>
    56ee:	92 30       	cpi	r25, 0x02	; 2
    56f0:	29 f0       	breq	.+10     	; 0x56fc <gc_execute_line.constprop.11+0x1a22>
    56f2:	88 e0       	ldi	r24, 0x08	; 8
    56f4:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    56f8:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    56fc:	10 92 9e 06 	sts	0x069E, r1	; 0x80069e <gc_state+0x7>
    5700:	ec c8       	rjmp	.-3624   	; 0x48da <gc_execute_line.constprop.11+0xc00>
    5702:	b8 01       	movw	r22, r16
    5704:	85 e0       	ldi	r24, 0x05	; 5
    5706:	97 e0       	ldi	r25, 0x07	; 7
    5708:	0e 94 0d 1e 	call	0x3c1a	; 0x3c1a <mc_line>
    570c:	81 e0       	ldi	r24, 0x01	; 1
    570e:	80 93 30 06 	sts	0x0630, r24	; 0x800630 <sys_probe_state>
    5712:	82 e0       	ldi	r24, 0x02	; 2
    5714:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    5718:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    571c:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    5720:	81 11       	cpse	r24, r1
    5722:	d4 cf       	rjmp	.-88     	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    5724:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5728:	81 11       	cpse	r24, r1
    572a:	f6 cf       	rjmp	.-20     	; 0x5718 <gc_execute_line.constprop.11+0x1a3e>
    572c:	80 91 30 06 	lds	r24, 0x0630	; 0x800630 <sys_probe_state>
    5730:	81 30       	cpi	r24, 0x01	; 1
    5732:	31 f5       	brne	.+76     	; 0x5780 <gc_execute_line.constprop.11+0x1aa6>
    5734:	ff 20       	and	r15, r15
    5736:	01 f1       	breq	.+64     	; 0x5778 <gc_execute_line.constprop.11+0x1a9e>
    5738:	8c e0       	ldi	r24, 0x0C	; 12
    573a:	e8 e1       	ldi	r30, 0x18	; 24
    573c:	f6 e0       	ldi	r31, 0x06	; 6
    573e:	a4 e2       	ldi	r26, 0x24	; 36
    5740:	b6 e0       	ldi	r27, 0x06	; 6
    5742:	01 90       	ld	r0, Z+
    5744:	0d 92       	st	X+, r0
    5746:	8a 95       	dec	r24
    5748:	e1 f7       	brne	.-8      	; 0x5742 <gc_execute_line.constprop.11+0x1a68>
    574a:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    574e:	80 e0       	ldi	r24, 0x00	; 0
    5750:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    5754:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    5758:	0e 94 db 0d 	call	0x1bb6	; 0x1bb6 <st_reset>
    575c:	0e 94 af 09 	call	0x135e	; 0x135e <plan_reset>
    5760:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    5764:	0e 94 32 09 	call	0x1264	; 0x1264 <report_probe_parameters>
    5768:	80 91 36 06 	lds	r24, 0x0636	; 0x800636 <sys+0x5>
    576c:	88 23       	and	r24, r24
    576e:	09 f4       	brne	.+2      	; 0x5772 <gc_execute_line.constprop.11+0x1a98>
    5770:	72 cc       	rjmp	.-1820   	; 0x5056 <gc_execute_line.constprop.11+0x137c>
    5772:	0e 94 a9 09 	call	0x1352	; 0x1352 <gc_sync_position>
    5776:	aa cf       	rjmp	.-172    	; 0x56cc <gc_execute_line.constprop.11+0x19f2>
    5778:	85 e0       	ldi	r24, 0x05	; 5
    577a:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    577e:	e5 cf       	rjmp	.-54     	; 0x574a <gc_execute_line.constprop.11+0x1a70>
    5780:	81 e0       	ldi	r24, 0x01	; 1
    5782:	80 93 36 06 	sts	0x0636, r24	; 0x800636 <sys+0x5>
    5786:	e1 cf       	rjmp	.-62     	; 0x574a <gc_execute_line.constprop.11+0x1a70>
    5788:	81 e0       	ldi	r24, 0x01	; 1
    578a:	80 93 97 06 	sts	0x0697, r24	; 0x800697 <gc_state>
    578e:	10 92 9b 06 	sts	0x069B, r1	; 0x80069b <gc_state+0x4>
    5792:	10 92 9a 06 	sts	0x069A, r1	; 0x80069a <gc_state+0x3>
    5796:	10 92 98 06 	sts	0x0698, r1	; 0x800698 <gc_state+0x1>
    579a:	10 92 9d 06 	sts	0x069D, r1	; 0x80069d <gc_state+0x6>
    579e:	10 92 a0 06 	sts	0x06A0, r1	; 0x8006a0 <gc_state+0x9>
    57a2:	10 92 9f 06 	sts	0x069F, r1	; 0x80069f <gc_state+0x8>
    57a6:	84 e6       	ldi	r24, 0x64	; 100
    57a8:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    57ac:	80 93 39 06 	sts	0x0639, r24	; 0x800639 <sys+0x8>
    57b0:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    57b4:	92 30       	cpi	r25, 0x02	; 2
    57b6:	a1 f0       	breq	.+40     	; 0x57e0 <gc_execute_line.constprop.11+0x1b06>
    57b8:	6b eb       	ldi	r22, 0xBB	; 187
    57ba:	76 e0       	ldi	r23, 0x06	; 6
    57bc:	80 e0       	ldi	r24, 0x00	; 0
    57be:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    57c2:	88 23       	and	r24, r24
    57c4:	11 f4       	brne	.+4      	; 0x57ca <gc_execute_line.constprop.11+0x1af0>
    57c6:	0c 94 61 22 	jmp	0x44c2	; 0x44c2 <gc_execute_line.constprop.11+0x7e8>
    57ca:	0e 94 58 1d 	call	0x3ab0	; 0x3ab0 <system_flag_wco_change>
    57ce:	40 e0       	ldi	r20, 0x00	; 0
    57d0:	50 e0       	ldi	r21, 0x00	; 0
    57d2:	ba 01       	movw	r22, r20
    57d4:	80 e0       	ldi	r24, 0x00	; 0
    57d6:	0e 94 cb 0a 	call	0x1596	; 0x1596 <spindle_set_state>
    57da:	80 e0       	ldi	r24, 0x00	; 0
    57dc:	0e 94 5c 09 	call	0x12b8	; 0x12b8 <coolant_set_state>
    57e0:	8a ec       	ldi	r24, 0xCA	; 202
    57e2:	92 e0       	ldi	r25, 0x02	; 2
    57e4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    57e8:	81 e6       	ldi	r24, 0x61	; 97
    57ea:	92 e0       	ldi	r25, 0x02	; 2
    57ec:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    57f0:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    57f4:	83 cf       	rjmp	.-250    	; 0x56fc <gc_execute_line.constprop.11+0x1a22>
    57f6:	81 e0       	ldi	r24, 0x01	; 1
    57f8:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    57fc:	82 e0       	ldi	r24, 0x02	; 2
    57fe:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5802:	88 e1       	ldi	r24, 0x18	; 24
    5804:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5808:	86 e2       	ldi	r24, 0x26	; 38
    580a:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    580e:	89 e1       	ldi	r24, 0x19	; 25
    5810:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5814:	84 e0       	ldi	r24, 0x04	; 4
    5816:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    581a:	8b e1       	ldi	r24, 0x1B	; 27
    581c:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5820:	85 e2       	ldi	r24, 0x25	; 37
    5822:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5826:	80 e2       	ldi	r24, 0x20	; 32
    5828:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    582c:	82 e2       	ldi	r24, 0x22	; 34
    582e:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5832:	84 e2       	ldi	r24, 0x24	; 36
    5834:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    5838:	80 e1       	ldi	r24, 0x10	; 16
    583a:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>
    583e:	8f e0       	ldi	r24, 0x0F	; 15
    5840:	0c 94 be 1f 	jmp	0x3f7c	; 0x3f7c <gc_execute_line.constprop.11+0x2a2>

00005844 <system_execute_startup.constprop.2>:
    5844:	cf 93       	push	r28
    5846:	df 93       	push	r29
    5848:	c0 e0       	ldi	r28, 0x00	; 0
    584a:	8c 2f       	mov	r24, r28
    584c:	0e 94 37 1d 	call	0x3a6e	; 0x3a6e <settings_read_startup_line.constprop.7>
    5850:	81 11       	cpse	r24, r1
    5852:	14 c0       	rjmp	.+40     	; 0x587c <system_execute_startup.constprop.2+0x38>
    5854:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    5858:	8e e3       	ldi	r24, 0x3E	; 62
    585a:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    585e:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printString.constprop.9>
    5862:	8a e3       	ldi	r24, 0x3A	; 58
    5864:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    5868:	87 e0       	ldi	r24, 0x07	; 7
    586a:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    586e:	c1 30       	cpi	r28, 0x01	; 1
    5870:	19 f4       	brne	.+6      	; 0x5878 <system_execute_startup.constprop.2+0x34>
    5872:	df 91       	pop	r29
    5874:	cf 91       	pop	r28
    5876:	08 95       	ret
    5878:	c1 e0       	ldi	r28, 0x01	; 1
    587a:	e7 cf       	rjmp	.-50     	; 0x584a <system_execute_startup.constprop.2+0x6>
    587c:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    5880:	88 23       	and	r24, r24
    5882:	a9 f3       	breq	.-22     	; 0x586e <system_execute_startup.constprop.2+0x2a>
    5884:	0e 94 6d 1e 	call	0x3cda	; 0x3cda <gc_execute_line.constprop.11>
    5888:	d8 2f       	mov	r29, r24
    588a:	8e e3       	ldi	r24, 0x3E	; 62
    588c:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    5890:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printString.constprop.9>
    5894:	8a e3       	ldi	r24, 0x3A	; 58
    5896:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    589a:	8d 2f       	mov	r24, r29
    589c:	0e 94 e5 07 	call	0xfca	; 0xfca <report_status_message>
    58a0:	e6 cf       	rjmp	.-52     	; 0x586e <system_execute_startup.constprop.2+0x2a>

000058a2 <__vector_4>:
    58a2:	1f 92       	push	r1
    58a4:	0f 92       	push	r0
    58a6:	0f b6       	in	r0, 0x3f	; 63
    58a8:	0f 92       	push	r0
    58aa:	11 24       	eor	r1, r1
    58ac:	2f 93       	push	r18
    58ae:	3f 93       	push	r19
    58b0:	4f 93       	push	r20
    58b2:	5f 93       	push	r21
    58b4:	6f 93       	push	r22
    58b6:	7f 93       	push	r23
    58b8:	8f 93       	push	r24
    58ba:	9f 93       	push	r25
    58bc:	af 93       	push	r26
    58be:	bf 93       	push	r27
    58c0:	cf 93       	push	r28
    58c2:	ef 93       	push	r30
    58c4:	ff 93       	push	r31
    58c6:	0e 94 cb 02 	call	0x596	; 0x596 <system_control_get_state>
    58ca:	c8 2f       	mov	r28, r24
    58cc:	88 23       	and	r24, r24
    58ce:	89 f0       	breq	.+34     	; 0x58f2 <__vector_4+0x50>
    58d0:	80 fd       	sbrc	r24, 0
    58d2:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    58d6:	c2 ff       	sbrs	r28, 2
    58d8:	05 c0       	rjmp	.+10     	; 0x58e4 <__vector_4+0x42>
    58da:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    58de:	82 60       	ori	r24, 0x02	; 2
    58e0:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    58e4:	c1 ff       	sbrs	r28, 1
    58e6:	05 c0       	rjmp	.+10     	; 0x58f2 <__vector_4+0x50>
    58e8:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    58ec:	88 60       	ori	r24, 0x08	; 8
    58ee:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    58f2:	ff 91       	pop	r31
    58f4:	ef 91       	pop	r30
    58f6:	cf 91       	pop	r28
    58f8:	bf 91       	pop	r27
    58fa:	af 91       	pop	r26
    58fc:	9f 91       	pop	r25
    58fe:	8f 91       	pop	r24
    5900:	7f 91       	pop	r23
    5902:	6f 91       	pop	r22
    5904:	5f 91       	pop	r21
    5906:	4f 91       	pop	r20
    5908:	3f 91       	pop	r19
    590a:	2f 91       	pop	r18
    590c:	0f 90       	pop	r0
    590e:	0f be       	out	0x3f, r0	; 63
    5910:	0f 90       	pop	r0
    5912:	1f 90       	pop	r1
    5914:	18 95       	reti

00005916 <__vector_3>:
    5916:	1f 92       	push	r1
    5918:	0f 92       	push	r0
    591a:	0f b6       	in	r0, 0x3f	; 63
    591c:	0f 92       	push	r0
    591e:	11 24       	eor	r1, r1
    5920:	2f 93       	push	r18
    5922:	3f 93       	push	r19
    5924:	4f 93       	push	r20
    5926:	5f 93       	push	r21
    5928:	6f 93       	push	r22
    592a:	7f 93       	push	r23
    592c:	8f 93       	push	r24
    592e:	9f 93       	push	r25
    5930:	af 93       	push	r26
    5932:	bf 93       	push	r27
    5934:	ef 93       	push	r30
    5936:	ff 93       	push	r31
    5938:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    593c:	81 30       	cpi	r24, 0x01	; 1
    593e:	49 f0       	breq	.+18     	; 0x5952 <__vector_3+0x3c>
    5940:	80 91 14 06 	lds	r24, 0x0614	; 0x800614 <sys_rt_exec_alarm>
    5944:	81 11       	cpse	r24, r1
    5946:	05 c0       	rjmp	.+10     	; 0x5952 <__vector_3+0x3c>
    5948:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    594c:	81 e0       	ldi	r24, 0x01	; 1
    594e:	0e 94 3b 02 	call	0x476	; 0x476 <system_set_exec_alarm>
    5952:	ff 91       	pop	r31
    5954:	ef 91       	pop	r30
    5956:	bf 91       	pop	r27
    5958:	af 91       	pop	r26
    595a:	9f 91       	pop	r25
    595c:	8f 91       	pop	r24
    595e:	7f 91       	pop	r23
    5960:	6f 91       	pop	r22
    5962:	5f 91       	pop	r21
    5964:	4f 91       	pop	r20
    5966:	3f 91       	pop	r19
    5968:	2f 91       	pop	r18
    596a:	0f 90       	pop	r0
    596c:	0f be       	out	0x3f, r0	; 63
    596e:	0f 90       	pop	r0
    5970:	1f 90       	pop	r1
    5972:	18 95       	reti

00005974 <__vector_16>:
    5974:	1f 92       	push	r1
    5976:	0f 92       	push	r0
    5978:	0f b6       	in	r0, 0x3f	; 63
    597a:	0f 92       	push	r0
    597c:	11 24       	eor	r1, r1
    597e:	8f 93       	push	r24
    5980:	9f 93       	push	r25
    5982:	9b b1       	in	r25, 0x0b	; 11
    5984:	80 91 f2 01 	lds	r24, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    5988:	8c 71       	andi	r24, 0x1C	; 28
    598a:	93 7e       	andi	r25, 0xE3	; 227
    598c:	89 2b       	or	r24, r25
    598e:	8b b9       	out	0x0b, r24	; 11
    5990:	15 bc       	out	0x25, r1	; 37
    5992:	9f 91       	pop	r25
    5994:	8f 91       	pop	r24
    5996:	0f 90       	pop	r0
    5998:	0f be       	out	0x3f, r0	; 63
    599a:	0f 90       	pop	r0
    599c:	1f 90       	pop	r1
    599e:	18 95       	reti

000059a0 <__vector_11>:
    59a0:	1f 92       	push	r1
    59a2:	0f 92       	push	r0
    59a4:	0f b6       	in	r0, 0x3f	; 63
    59a6:	0f 92       	push	r0
    59a8:	11 24       	eor	r1, r1
    59aa:	0f 93       	push	r16
    59ac:	1f 93       	push	r17
    59ae:	2f 93       	push	r18
    59b0:	3f 93       	push	r19
    59b2:	4f 93       	push	r20
    59b4:	5f 93       	push	r21
    59b6:	6f 93       	push	r22
    59b8:	7f 93       	push	r23
    59ba:	8f 93       	push	r24
    59bc:	9f 93       	push	r25
    59be:	af 93       	push	r26
    59c0:	bf 93       	push	r27
    59c2:	ef 93       	push	r30
    59c4:	ff 93       	push	r31
    59c6:	80 91 f4 01 	lds	r24, 0x01F4	; 0x8001f4 <busy>
    59ca:	81 11       	cpse	r24, r1
    59cc:	01 c2       	rjmp	.+1026   	; 0x5dd0 <__vector_11+0x430>
    59ce:	9b b1       	in	r25, 0x0b	; 11
    59d0:	80 91 04 02 	lds	r24, 0x0204	; 0x800204 <st+0xf>
    59d4:	80 7e       	andi	r24, 0xE0	; 224
    59d6:	9f 71       	andi	r25, 0x1F	; 31
    59d8:	89 2b       	or	r24, r25
    59da:	8b b9       	out	0x0b, r24	; 11
    59dc:	8b b1       	in	r24, 0x0b	; 11
    59de:	83 7e       	andi	r24, 0xE3	; 227
    59e0:	90 91 03 02 	lds	r25, 0x0203	; 0x800203 <st+0xe>
    59e4:	89 2b       	or	r24, r25
    59e6:	8b b9       	out	0x0b, r24	; 11
    59e8:	80 91 02 02 	lds	r24, 0x0202	; 0x800202 <st+0xd>
    59ec:	86 bd       	out	0x26, r24	; 38
    59ee:	82 e0       	ldi	r24, 0x02	; 2
    59f0:	85 bd       	out	0x25, r24	; 37
    59f2:	81 e0       	ldi	r24, 0x01	; 1
    59f4:	80 93 f4 01 	sts	0x01F4, r24	; 0x8001f4 <busy>
    59f8:	78 94       	sei
    59fa:	80 91 16 02 	lds	r24, 0x0216	; 0x800216 <st+0x21>
    59fe:	90 91 17 02 	lds	r25, 0x0217	; 0x800217 <st+0x22>
    5a02:	89 2b       	or	r24, r25
    5a04:	09 f0       	breq	.+2      	; 0x5a08 <__vector_11+0x68>
    5a06:	aa c0       	rjmp	.+340    	; 0x5b5c <__vector_11+0x1bc>
    5a08:	80 91 18 02 	lds	r24, 0x0218	; 0x800218 <segment_buffer_tail>
    5a0c:	90 91 44 02 	lds	r25, 0x0244	; 0x800244 <segment_buffer_head>
    5a10:	98 17       	cp	r25, r24
    5a12:	09 f4       	brne	.+2      	; 0x5a16 <__vector_11+0x76>
    5a14:	ca c1       	rjmp	.+916    	; 0x5daa <__vector_11+0x40a>
    5a16:	e0 91 18 02 	lds	r30, 0x0218	; 0x800218 <segment_buffer_tail>
    5a1a:	2e 2f       	mov	r18, r30
    5a1c:	30 e0       	ldi	r19, 0x00	; 0
    5a1e:	87 e0       	ldi	r24, 0x07	; 7
    5a20:	e8 9f       	mul	r30, r24
    5a22:	f0 01       	movw	r30, r0
    5a24:	11 24       	eor	r1, r1
    5a26:	e6 5e       	subi	r30, 0xE6	; 230
    5a28:	fd 4f       	sbci	r31, 0xFD	; 253
    5a2a:	f0 93 17 02 	sts	0x0217, r31	; 0x800217 <st+0x22>
    5a2e:	e0 93 16 02 	sts	0x0216, r30	; 0x800216 <st+0x21>
    5a32:	82 81       	ldd	r24, Z+2	; 0x02
    5a34:	93 81       	ldd	r25, Z+3	; 0x03
    5a36:	90 93 89 00 	sts	0x0089, r25	; 0x800089 <__DATA_REGION_ORIGIN__+0x29>
    5a3a:	80 93 88 00 	sts	0x0088, r24	; 0x800088 <__DATA_REGION_ORIGIN__+0x28>
    5a3e:	80 81       	ld	r24, Z
    5a40:	91 81       	ldd	r25, Z+1	; 0x01
    5a42:	90 93 12 02 	sts	0x0212, r25	; 0x800212 <st+0x1d>
    5a46:	80 93 11 02 	sts	0x0211, r24	; 0x800211 <st+0x1c>
    5a4a:	e4 81       	ldd	r30, Z+4	; 0x04
    5a4c:	80 91 13 02 	lds	r24, 0x0213	; 0x800213 <st+0x1e>
    5a50:	8e 17       	cp	r24, r30
    5a52:	61 f1       	breq	.+88     	; 0x5aac <__vector_11+0x10c>
    5a54:	e0 93 13 02 	sts	0x0213, r30	; 0x800213 <st+0x1e>
    5a58:	82 e1       	ldi	r24, 0x12	; 18
    5a5a:	e8 9f       	mul	r30, r24
    5a5c:	f0 01       	movw	r30, r0
    5a5e:	11 24       	eor	r1, r1
    5a60:	e9 5b       	subi	r30, 0xB9	; 185
    5a62:	fd 4f       	sbci	r31, 0xFD	; 253
    5a64:	f0 93 15 02 	sts	0x0215, r31	; 0x800215 <st+0x20>
    5a68:	e0 93 14 02 	sts	0x0214, r30	; 0x800214 <st+0x1f>
    5a6c:	84 85       	ldd	r24, Z+12	; 0x0c
    5a6e:	95 85       	ldd	r25, Z+13	; 0x0d
    5a70:	a6 85       	ldd	r26, Z+14	; 0x0e
    5a72:	b7 85       	ldd	r27, Z+15	; 0x0f
    5a74:	b6 95       	lsr	r27
    5a76:	a7 95       	ror	r26
    5a78:	97 95       	ror	r25
    5a7a:	87 95       	ror	r24
    5a7c:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5a80:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5a84:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5a88:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5a8c:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5a90:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5a94:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5a98:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5a9c:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5aa0:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5aa4:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5aa8:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5aac:	a0 91 14 02 	lds	r26, 0x0214	; 0x800214 <st+0x1f>
    5ab0:	b0 91 15 02 	lds	r27, 0x0215	; 0x800215 <st+0x20>
    5ab4:	50 96       	adiw	r26, 0x10	; 16
    5ab6:	8c 91       	ld	r24, X
    5ab8:	50 97       	sbiw	r26, 0x10	; 16
    5aba:	90 91 f3 01 	lds	r25, 0x01F3	; 0x8001f3 <dir_port_invert_mask>
    5abe:	89 27       	eor	r24, r25
    5ac0:	80 93 04 02 	sts	0x0204, r24	; 0x800204 <st+0xf>
    5ac4:	87 e0       	ldi	r24, 0x07	; 7
    5ac6:	82 9f       	mul	r24, r18
    5ac8:	f0 01       	movw	r30, r0
    5aca:	83 9f       	mul	r24, r19
    5acc:	f0 0d       	add	r31, r0
    5ace:	11 24       	eor	r1, r1
    5ad0:	e6 5e       	subi	r30, 0xE6	; 230
    5ad2:	fd 4f       	sbci	r31, 0xFD	; 253
    5ad4:	25 81       	ldd	r18, Z+5	; 0x05
    5ad6:	4d 91       	ld	r20, X+
    5ad8:	5d 91       	ld	r21, X+
    5ada:	6d 91       	ld	r22, X+
    5adc:	7c 91       	ld	r23, X
    5ade:	13 97       	sbiw	r26, 0x03	; 3
    5ae0:	02 2e       	mov	r0, r18
    5ae2:	04 c0       	rjmp	.+8      	; 0x5aec <__vector_11+0x14c>
    5ae4:	76 95       	lsr	r23
    5ae6:	67 95       	ror	r22
    5ae8:	57 95       	ror	r21
    5aea:	47 95       	ror	r20
    5aec:	0a 94       	dec	r0
    5aee:	d2 f7       	brpl	.-12     	; 0x5ae4 <__vector_11+0x144>
    5af0:	40 93 05 02 	sts	0x0205, r20	; 0x800205 <st+0x10>
    5af4:	50 93 06 02 	sts	0x0206, r21	; 0x800206 <st+0x11>
    5af8:	60 93 07 02 	sts	0x0207, r22	; 0x800207 <st+0x12>
    5afc:	70 93 08 02 	sts	0x0208, r23	; 0x800208 <st+0x13>
    5b00:	14 96       	adiw	r26, 0x04	; 4
    5b02:	4d 91       	ld	r20, X+
    5b04:	5d 91       	ld	r21, X+
    5b06:	6d 91       	ld	r22, X+
    5b08:	7c 91       	ld	r23, X
    5b0a:	17 97       	sbiw	r26, 0x07	; 7
    5b0c:	02 2e       	mov	r0, r18
    5b0e:	04 c0       	rjmp	.+8      	; 0x5b18 <__vector_11+0x178>
    5b10:	76 95       	lsr	r23
    5b12:	67 95       	ror	r22
    5b14:	57 95       	ror	r21
    5b16:	47 95       	ror	r20
    5b18:	0a 94       	dec	r0
    5b1a:	d2 f7       	brpl	.-12     	; 0x5b10 <__vector_11+0x170>
    5b1c:	40 93 09 02 	sts	0x0209, r20	; 0x800209 <st+0x14>
    5b20:	50 93 0a 02 	sts	0x020A, r21	; 0x80020a <st+0x15>
    5b24:	60 93 0b 02 	sts	0x020B, r22	; 0x80020b <st+0x16>
    5b28:	70 93 0c 02 	sts	0x020C, r23	; 0x80020c <st+0x17>
    5b2c:	18 96       	adiw	r26, 0x08	; 8
    5b2e:	8d 91       	ld	r24, X+
    5b30:	9d 91       	ld	r25, X+
    5b32:	0d 90       	ld	r0, X+
    5b34:	bc 91       	ld	r27, X
    5b36:	a0 2d       	mov	r26, r0
    5b38:	04 c0       	rjmp	.+8      	; 0x5b42 <__vector_11+0x1a2>
    5b3a:	b6 95       	lsr	r27
    5b3c:	a7 95       	ror	r26
    5b3e:	97 95       	ror	r25
    5b40:	87 95       	ror	r24
    5b42:	2a 95       	dec	r18
    5b44:	d2 f7       	brpl	.-12     	; 0x5b3a <__vector_11+0x19a>
    5b46:	80 93 0d 02 	sts	0x020D, r24	; 0x80020d <st+0x18>
    5b4a:	90 93 0e 02 	sts	0x020E, r25	; 0x80020e <st+0x19>
    5b4e:	a0 93 0f 02 	sts	0x020F, r26	; 0x80020f <st+0x1a>
    5b52:	b0 93 10 02 	sts	0x0210, r27	; 0x800210 <st+0x1b>
    5b56:	86 81       	ldd	r24, Z+6	; 0x06
    5b58:	0e 94 68 09 	call	0x12d0	; 0x12d0 <spindle_set_speed>
    5b5c:	80 91 30 06 	lds	r24, 0x0630	; 0x800630 <sys_probe_state>
    5b60:	81 30       	cpi	r24, 0x01	; 1
    5b62:	b1 f4       	brne	.+44     	; 0x5b90 <__vector_11+0x1f0>
    5b64:	86 b1       	in	r24, 0x06	; 6
    5b66:	80 72       	andi	r24, 0x20	; 32
    5b68:	90 91 17 06 	lds	r25, 0x0617	; 0x800617 <probe_invert_mask>
    5b6c:	89 17       	cp	r24, r25
    5b6e:	81 f0       	breq	.+32     	; 0x5b90 <__vector_11+0x1f0>
    5b70:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    5b74:	8c e0       	ldi	r24, 0x0C	; 12
    5b76:	e8 e1       	ldi	r30, 0x18	; 24
    5b78:	f6 e0       	ldi	r31, 0x06	; 6
    5b7a:	a4 e2       	ldi	r26, 0x24	; 36
    5b7c:	b6 e0       	ldi	r27, 0x06	; 6
    5b7e:	01 90       	ld	r0, Z+
    5b80:	0d 92       	st	X+, r0
    5b82:	8a 95       	dec	r24
    5b84:	e1 f7       	brne	.-8      	; 0x5b7e <__vector_11+0x1de>
    5b86:	80 91 13 06 	lds	r24, 0x0613	; 0x800613 <sys_rt_exec_state>
    5b8a:	80 64       	ori	r24, 0x40	; 64
    5b8c:	80 93 13 06 	sts	0x0613, r24	; 0x800613 <sys_rt_exec_state>
    5b90:	10 92 03 02 	sts	0x0203, r1	; 0x800203 <st+0xe>
    5b94:	80 91 f5 01 	lds	r24, 0x01F5	; 0x8001f5 <st>
    5b98:	90 91 f6 01 	lds	r25, 0x01F6	; 0x8001f6 <st+0x1>
    5b9c:	a0 91 f7 01 	lds	r26, 0x01F7	; 0x8001f7 <st+0x2>
    5ba0:	b0 91 f8 01 	lds	r27, 0x01F8	; 0x8001f8 <st+0x3>
    5ba4:	40 91 05 02 	lds	r20, 0x0205	; 0x800205 <st+0x10>
    5ba8:	50 91 06 02 	lds	r21, 0x0206	; 0x800206 <st+0x11>
    5bac:	60 91 07 02 	lds	r22, 0x0207	; 0x800207 <st+0x12>
    5bb0:	70 91 08 02 	lds	r23, 0x0208	; 0x800208 <st+0x13>
    5bb4:	84 0f       	add	r24, r20
    5bb6:	95 1f       	adc	r25, r21
    5bb8:	a6 1f       	adc	r26, r22
    5bba:	b7 1f       	adc	r27, r23
    5bbc:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5bc0:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5bc4:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5bc8:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5bcc:	e0 91 14 02 	lds	r30, 0x0214	; 0x800214 <st+0x1f>
    5bd0:	f0 91 15 02 	lds	r31, 0x0215	; 0x800215 <st+0x20>
    5bd4:	44 85       	ldd	r20, Z+12	; 0x0c
    5bd6:	55 85       	ldd	r21, Z+13	; 0x0d
    5bd8:	66 85       	ldd	r22, Z+14	; 0x0e
    5bda:	77 85       	ldd	r23, Z+15	; 0x0f
    5bdc:	48 17       	cp	r20, r24
    5bde:	59 07       	cpc	r21, r25
    5be0:	6a 07       	cpc	r22, r26
    5be2:	7b 07       	cpc	r23, r27
    5be4:	28 f5       	brcc	.+74     	; 0x5c30 <__vector_11+0x290>
    5be6:	24 e0       	ldi	r18, 0x04	; 4
    5be8:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5bec:	84 1b       	sub	r24, r20
    5bee:	95 0b       	sbc	r25, r21
    5bf0:	a6 0b       	sbc	r26, r22
    5bf2:	b7 0b       	sbc	r27, r23
    5bf4:	80 93 f5 01 	sts	0x01F5, r24	; 0x8001f5 <st>
    5bf8:	90 93 f6 01 	sts	0x01F6, r25	; 0x8001f6 <st+0x1>
    5bfc:	a0 93 f7 01 	sts	0x01F7, r26	; 0x8001f7 <st+0x2>
    5c00:	b0 93 f8 01 	sts	0x01F8, r27	; 0x8001f8 <st+0x3>
    5c04:	80 91 18 06 	lds	r24, 0x0618	; 0x800618 <sys_position>
    5c08:	90 91 19 06 	lds	r25, 0x0619	; 0x800619 <sys_position+0x1>
    5c0c:	a0 91 1a 06 	lds	r26, 0x061A	; 0x80061a <sys_position+0x2>
    5c10:	b0 91 1b 06 	lds	r27, 0x061B	; 0x80061b <sys_position+0x3>
    5c14:	20 89       	ldd	r18, Z+16	; 0x10
    5c16:	25 ff       	sbrs	r18, 5
    5c18:	ee c0       	rjmp	.+476    	; 0x5df6 <__vector_11+0x456>
    5c1a:	01 97       	sbiw	r24, 0x01	; 1
    5c1c:	a1 09       	sbc	r26, r1
    5c1e:	b1 09       	sbc	r27, r1
    5c20:	80 93 18 06 	sts	0x0618, r24	; 0x800618 <sys_position>
    5c24:	90 93 19 06 	sts	0x0619, r25	; 0x800619 <sys_position+0x1>
    5c28:	a0 93 1a 06 	sts	0x061A, r26	; 0x80061a <sys_position+0x2>
    5c2c:	b0 93 1b 06 	sts	0x061B, r27	; 0x80061b <sys_position+0x3>
    5c30:	80 91 f9 01 	lds	r24, 0x01F9	; 0x8001f9 <st+0x4>
    5c34:	90 91 fa 01 	lds	r25, 0x01FA	; 0x8001fa <st+0x5>
    5c38:	a0 91 fb 01 	lds	r26, 0x01FB	; 0x8001fb <st+0x6>
    5c3c:	b0 91 fc 01 	lds	r27, 0x01FC	; 0x8001fc <st+0x7>
    5c40:	00 91 09 02 	lds	r16, 0x0209	; 0x800209 <st+0x14>
    5c44:	10 91 0a 02 	lds	r17, 0x020A	; 0x80020a <st+0x15>
    5c48:	20 91 0b 02 	lds	r18, 0x020B	; 0x80020b <st+0x16>
    5c4c:	30 91 0c 02 	lds	r19, 0x020C	; 0x80020c <st+0x17>
    5c50:	80 0f       	add	r24, r16
    5c52:	91 1f       	adc	r25, r17
    5c54:	a2 1f       	adc	r26, r18
    5c56:	b3 1f       	adc	r27, r19
    5c58:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5c5c:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5c60:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5c64:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5c68:	48 17       	cp	r20, r24
    5c6a:	59 07       	cpc	r21, r25
    5c6c:	6a 07       	cpc	r22, r26
    5c6e:	7b 07       	cpc	r23, r27
    5c70:	38 f5       	brcc	.+78     	; 0x5cc0 <__vector_11+0x320>
    5c72:	20 91 03 02 	lds	r18, 0x0203	; 0x800203 <st+0xe>
    5c76:	28 60       	ori	r18, 0x08	; 8
    5c78:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5c7c:	84 1b       	sub	r24, r20
    5c7e:	95 0b       	sbc	r25, r21
    5c80:	a6 0b       	sbc	r26, r22
    5c82:	b7 0b       	sbc	r27, r23
    5c84:	80 93 f9 01 	sts	0x01F9, r24	; 0x8001f9 <st+0x4>
    5c88:	90 93 fa 01 	sts	0x01FA, r25	; 0x8001fa <st+0x5>
    5c8c:	a0 93 fb 01 	sts	0x01FB, r26	; 0x8001fb <st+0x6>
    5c90:	b0 93 fc 01 	sts	0x01FC, r27	; 0x8001fc <st+0x7>
    5c94:	80 91 1c 06 	lds	r24, 0x061C	; 0x80061c <sys_position+0x4>
    5c98:	90 91 1d 06 	lds	r25, 0x061D	; 0x80061d <sys_position+0x5>
    5c9c:	a0 91 1e 06 	lds	r26, 0x061E	; 0x80061e <sys_position+0x6>
    5ca0:	b0 91 1f 06 	lds	r27, 0x061F	; 0x80061f <sys_position+0x7>
    5ca4:	20 89       	ldd	r18, Z+16	; 0x10
    5ca6:	26 ff       	sbrs	r18, 6
    5ca8:	aa c0       	rjmp	.+340    	; 0x5dfe <__vector_11+0x45e>
    5caa:	01 97       	sbiw	r24, 0x01	; 1
    5cac:	a1 09       	sbc	r26, r1
    5cae:	b1 09       	sbc	r27, r1
    5cb0:	80 93 1c 06 	sts	0x061C, r24	; 0x80061c <sys_position+0x4>
    5cb4:	90 93 1d 06 	sts	0x061D, r25	; 0x80061d <sys_position+0x5>
    5cb8:	a0 93 1e 06 	sts	0x061E, r26	; 0x80061e <sys_position+0x6>
    5cbc:	b0 93 1f 06 	sts	0x061F, r27	; 0x80061f <sys_position+0x7>
    5cc0:	80 91 fd 01 	lds	r24, 0x01FD	; 0x8001fd <st+0x8>
    5cc4:	90 91 fe 01 	lds	r25, 0x01FE	; 0x8001fe <st+0x9>
    5cc8:	a0 91 ff 01 	lds	r26, 0x01FF	; 0x8001ff <st+0xa>
    5ccc:	b0 91 00 02 	lds	r27, 0x0200	; 0x800200 <st+0xb>
    5cd0:	00 91 0d 02 	lds	r16, 0x020D	; 0x80020d <st+0x18>
    5cd4:	10 91 0e 02 	lds	r17, 0x020E	; 0x80020e <st+0x19>
    5cd8:	20 91 0f 02 	lds	r18, 0x020F	; 0x80020f <st+0x1a>
    5cdc:	30 91 10 02 	lds	r19, 0x0210	; 0x800210 <st+0x1b>
    5ce0:	80 0f       	add	r24, r16
    5ce2:	91 1f       	adc	r25, r17
    5ce4:	a2 1f       	adc	r26, r18
    5ce6:	b3 1f       	adc	r27, r19
    5ce8:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5cec:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5cf0:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5cf4:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5cf8:	48 17       	cp	r20, r24
    5cfa:	59 07       	cpc	r21, r25
    5cfc:	6a 07       	cpc	r22, r26
    5cfe:	7b 07       	cpc	r23, r27
    5d00:	38 f5       	brcc	.+78     	; 0x5d50 <__vector_11+0x3b0>
    5d02:	20 91 03 02 	lds	r18, 0x0203	; 0x800203 <st+0xe>
    5d06:	20 61       	ori	r18, 0x10	; 16
    5d08:	20 93 03 02 	sts	0x0203, r18	; 0x800203 <st+0xe>
    5d0c:	84 1b       	sub	r24, r20
    5d0e:	95 0b       	sbc	r25, r21
    5d10:	a6 0b       	sbc	r26, r22
    5d12:	b7 0b       	sbc	r27, r23
    5d14:	80 93 fd 01 	sts	0x01FD, r24	; 0x8001fd <st+0x8>
    5d18:	90 93 fe 01 	sts	0x01FE, r25	; 0x8001fe <st+0x9>
    5d1c:	a0 93 ff 01 	sts	0x01FF, r26	; 0x8001ff <st+0xa>
    5d20:	b0 93 00 02 	sts	0x0200, r27	; 0x800200 <st+0xb>
    5d24:	80 91 20 06 	lds	r24, 0x0620	; 0x800620 <sys_position+0x8>
    5d28:	90 91 21 06 	lds	r25, 0x0621	; 0x800621 <sys_position+0x9>
    5d2c:	a0 91 22 06 	lds	r26, 0x0622	; 0x800622 <sys_position+0xa>
    5d30:	b0 91 23 06 	lds	r27, 0x0623	; 0x800623 <sys_position+0xb>
    5d34:	20 89       	ldd	r18, Z+16	; 0x10
    5d36:	27 ff       	sbrs	r18, 7
    5d38:	66 c0       	rjmp	.+204    	; 0x5e06 <__vector_11+0x466>
    5d3a:	01 97       	sbiw	r24, 0x01	; 1
    5d3c:	a1 09       	sbc	r26, r1
    5d3e:	b1 09       	sbc	r27, r1
    5d40:	80 93 20 06 	sts	0x0620, r24	; 0x800620 <sys_position+0x8>
    5d44:	90 93 21 06 	sts	0x0621, r25	; 0x800621 <sys_position+0x9>
    5d48:	a0 93 22 06 	sts	0x0622, r26	; 0x800622 <sys_position+0xa>
    5d4c:	b0 93 23 06 	sts	0x0623, r27	; 0x800623 <sys_position+0xb>
    5d50:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5d54:	84 30       	cpi	r24, 0x04	; 4
    5d56:	39 f4       	brne	.+14     	; 0x5d66 <__vector_11+0x3c6>
    5d58:	80 91 37 06 	lds	r24, 0x0637	; 0x800637 <sys+0x6>
    5d5c:	90 91 03 02 	lds	r25, 0x0203	; 0x800203 <st+0xe>
    5d60:	89 23       	and	r24, r25
    5d62:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
    5d66:	80 91 11 02 	lds	r24, 0x0211	; 0x800211 <st+0x1c>
    5d6a:	90 91 12 02 	lds	r25, 0x0212	; 0x800212 <st+0x1d>
    5d6e:	01 97       	sbiw	r24, 0x01	; 1
    5d70:	90 93 12 02 	sts	0x0212, r25	; 0x800212 <st+0x1d>
    5d74:	80 93 11 02 	sts	0x0211, r24	; 0x800211 <st+0x1c>
    5d78:	89 2b       	or	r24, r25
    5d7a:	69 f4       	brne	.+26     	; 0x5d96 <__vector_11+0x3f6>
    5d7c:	10 92 17 02 	sts	0x0217, r1	; 0x800217 <st+0x22>
    5d80:	10 92 16 02 	sts	0x0216, r1	; 0x800216 <st+0x21>
    5d84:	80 91 18 02 	lds	r24, 0x0218	; 0x800218 <segment_buffer_tail>
    5d88:	8f 5f       	subi	r24, 0xFF	; 255
    5d8a:	80 93 18 02 	sts	0x0218, r24	; 0x800218 <segment_buffer_tail>
    5d8e:	86 30       	cpi	r24, 0x06	; 6
    5d90:	11 f4       	brne	.+4      	; 0x5d96 <__vector_11+0x3f6>
    5d92:	10 92 18 02 	sts	0x0218, r1	; 0x800218 <segment_buffer_tail>
    5d96:	80 91 03 02 	lds	r24, 0x0203	; 0x800203 <st+0xe>
    5d9a:	90 91 f2 01 	lds	r25, 0x01F2	; 0x8001f2 <step_port_invert_mask>
    5d9e:	89 27       	eor	r24, r25
    5da0:	80 93 03 02 	sts	0x0203, r24	; 0x800203 <st+0xe>
    5da4:	10 92 f4 01 	sts	0x01F4, r1	; 0x8001f4 <busy>
    5da8:	13 c0       	rjmp	.+38     	; 0x5dd0 <__vector_11+0x430>
    5daa:	0e 94 a7 0d 	call	0x1b4e	; 0x1b4e <st_go_idle>
    5dae:	e0 91 14 02 	lds	r30, 0x0214	; 0x800214 <st+0x1f>
    5db2:	f0 91 15 02 	lds	r31, 0x0215	; 0x800215 <st+0x20>
    5db6:	81 89       	ldd	r24, Z+17	; 0x11
    5db8:	88 23       	and	r24, r24
    5dba:	39 f0       	breq	.+14     	; 0x5dca <__vector_11+0x42a>
    5dbc:	10 92 b3 00 	sts	0x00B3, r1	; 0x8000b3 <__DATA_REGION_ORIGIN__+0x53>
    5dc0:	80 91 b0 00 	lds	r24, 0x00B0	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    5dc4:	8f 77       	andi	r24, 0x7F	; 127
    5dc6:	80 93 b0 00 	sts	0x00B0, r24	; 0x8000b0 <__DATA_REGION_ORIGIN__+0x50>
    5dca:	84 e0       	ldi	r24, 0x04	; 4
    5dcc:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    5dd0:	ff 91       	pop	r31
    5dd2:	ef 91       	pop	r30
    5dd4:	bf 91       	pop	r27
    5dd6:	af 91       	pop	r26
    5dd8:	9f 91       	pop	r25
    5dda:	8f 91       	pop	r24
    5ddc:	7f 91       	pop	r23
    5dde:	6f 91       	pop	r22
    5de0:	5f 91       	pop	r21
    5de2:	4f 91       	pop	r20
    5de4:	3f 91       	pop	r19
    5de6:	2f 91       	pop	r18
    5de8:	1f 91       	pop	r17
    5dea:	0f 91       	pop	r16
    5dec:	0f 90       	pop	r0
    5dee:	0f be       	out	0x3f, r0	; 63
    5df0:	0f 90       	pop	r0
    5df2:	1f 90       	pop	r1
    5df4:	18 95       	reti
    5df6:	01 96       	adiw	r24, 0x01	; 1
    5df8:	a1 1d       	adc	r26, r1
    5dfa:	b1 1d       	adc	r27, r1
    5dfc:	11 cf       	rjmp	.-478    	; 0x5c20 <__vector_11+0x280>
    5dfe:	01 96       	adiw	r24, 0x01	; 1
    5e00:	a1 1d       	adc	r26, r1
    5e02:	b1 1d       	adc	r27, r1
    5e04:	55 cf       	rjmp	.-342    	; 0x5cb0 <__vector_11+0x310>
    5e06:	01 96       	adiw	r24, 0x01	; 1
    5e08:	a1 1d       	adc	r26, r1
    5e0a:	b1 1d       	adc	r27, r1
    5e0c:	99 cf       	rjmp	.-206    	; 0x5d40 <__vector_11+0x3a0>

00005e0e <__vector_18>:
    5e0e:	1f 92       	push	r1
    5e10:	0f 92       	push	r0
    5e12:	0f b6       	in	r0, 0x3f	; 63
    5e14:	0f 92       	push	r0
    5e16:	11 24       	eor	r1, r1
    5e18:	2f 93       	push	r18
    5e1a:	3f 93       	push	r19
    5e1c:	4f 93       	push	r20
    5e1e:	5f 93       	push	r21
    5e20:	6f 93       	push	r22
    5e22:	7f 93       	push	r23
    5e24:	8f 93       	push	r24
    5e26:	9f 93       	push	r25
    5e28:	af 93       	push	r26
    5e2a:	bf 93       	push	r27
    5e2c:	ef 93       	push	r30
    5e2e:	ff 93       	push	r31
    5e30:	e0 91 c6 00 	lds	r30, 0x00C6	; 0x8000c6 <__DATA_REGION_ORIGIN__+0x66>
    5e34:	e1 32       	cpi	r30, 0x21	; 33
    5e36:	09 f4       	brne	.+2      	; 0x5e3a <__vector_18+0x2c>
    5e38:	4b c0       	rjmp	.+150    	; 0x5ed0 <__vector_18+0xc2>
    5e3a:	08 f0       	brcs	.+2      	; 0x5e3e <__vector_18+0x30>
    5e3c:	2b c0       	rjmp	.+86     	; 0x5e94 <__vector_18+0x86>
    5e3e:	e8 31       	cpi	r30, 0x18	; 24
    5e40:	09 f4       	brne	.+2      	; 0x5e44 <__vector_18+0x36>
    5e42:	31 c0       	rjmp	.+98     	; 0x5ea6 <__vector_18+0x98>
    5e44:	e7 ff       	sbrs	r30, 7
    5e46:	70 c0       	rjmp	.+224    	; 0x5f28 <__vector_18+0x11a>
    5e48:	e4 58       	subi	r30, 0x84	; 132
    5e4a:	ed 31       	cpi	r30, 0x1D	; 29
    5e4c:	08 f0       	brcs	.+2      	; 0x5e50 <__vector_18+0x42>
    5e4e:	2d c0       	rjmp	.+90     	; 0x5eaa <__vector_18+0x9c>
    5e50:	f0 e0       	ldi	r31, 0x00	; 0
    5e52:	e3 5d       	subi	r30, 0xD3	; 211
    5e54:	f0 4d       	sbci	r31, 0xD0	; 208
    5e56:	0c 94 e6 39 	jmp	0x73cc	; 0x73cc <__tablejump2__>
    5e5a:	6a 2f       	mov	r22, r26
    5e5c:	6c 2f       	mov	r22, r28
    5e5e:	55 2f       	mov	r21, r21
    5e60:	55 2f       	mov	r21, r21
    5e62:	55 2f       	mov	r21, r21
    5e64:	55 2f       	mov	r21, r21
    5e66:	55 2f       	mov	r21, r21
    5e68:	55 2f       	mov	r21, r21
    5e6a:	55 2f       	mov	r21, r21
    5e6c:	55 2f       	mov	r21, r21
    5e6e:	55 2f       	mov	r21, r21
    5e70:	55 2f       	mov	r21, r21
    5e72:	72 2f       	mov	r23, r18
    5e74:	76 2f       	mov	r23, r22
    5e76:	78 2f       	mov	r23, r24
    5e78:	7a 2f       	mov	r23, r26
    5e7a:	7c 2f       	mov	r23, r28
    5e7c:	7e 2f       	mov	r23, r30
    5e7e:	80 2f       	mov	r24, r16
    5e80:	82 2f       	mov	r24, r18
    5e82:	55 2f       	mov	r21, r21
    5e84:	84 2f       	mov	r24, r20
    5e86:	88 2f       	mov	r24, r24
    5e88:	8a 2f       	mov	r24, r26
    5e8a:	8c 2f       	mov	r24, r28
    5e8c:	8e 2f       	mov	r24, r30
    5e8e:	90 2f       	mov	r25, r16
    5e90:	55 2f       	mov	r21, r21
    5e92:	92 2f       	mov	r25, r18
    5e94:	ef 33       	cpi	r30, 0x3F	; 63
    5e96:	d1 f0       	breq	.+52     	; 0x5ecc <__vector_18+0xbe>
    5e98:	82 e0       	ldi	r24, 0x02	; 2
    5e9a:	ee 37       	cpi	r30, 0x7E	; 126
    5e9c:	09 f0       	breq	.+2      	; 0x5ea0 <__vector_18+0x92>
    5e9e:	d2 cf       	rjmp	.-92     	; 0x5e44 <__vector_18+0x36>
    5ea0:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    5ea4:	02 c0       	rjmp	.+4      	; 0x5eaa <__vector_18+0x9c>
    5ea6:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    5eaa:	ff 91       	pop	r31
    5eac:	ef 91       	pop	r30
    5eae:	bf 91       	pop	r27
    5eb0:	af 91       	pop	r26
    5eb2:	9f 91       	pop	r25
    5eb4:	8f 91       	pop	r24
    5eb6:	7f 91       	pop	r23
    5eb8:	6f 91       	pop	r22
    5eba:	5f 91       	pop	r21
    5ebc:	4f 91       	pop	r20
    5ebe:	3f 91       	pop	r19
    5ec0:	2f 91       	pop	r18
    5ec2:	0f 90       	pop	r0
    5ec4:	0f be       	out	0x3f, r0	; 63
    5ec6:	0f 90       	pop	r0
    5ec8:	1f 90       	pop	r1
    5eca:	18 95       	reti
    5ecc:	81 e0       	ldi	r24, 0x01	; 1
    5ece:	e8 cf       	rjmp	.-48     	; 0x5ea0 <__vector_18+0x92>
    5ed0:	88 e0       	ldi	r24, 0x08	; 8
    5ed2:	e6 cf       	rjmp	.-52     	; 0x5ea0 <__vector_18+0x92>
    5ed4:	80 e2       	ldi	r24, 0x20	; 32
    5ed6:	e4 cf       	rjmp	.-56     	; 0x5ea0 <__vector_18+0x92>
    5ed8:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    5edc:	85 ff       	sbrs	r24, 5
    5ede:	e5 cf       	rjmp	.-54     	; 0x5eaa <__vector_18+0x9c>
    5ee0:	80 e4       	ldi	r24, 0x40	; 64
    5ee2:	de cf       	rjmp	.-68     	; 0x5ea0 <__vector_18+0x92>
    5ee4:	81 e0       	ldi	r24, 0x01	; 1
    5ee6:	0e 94 32 02 	call	0x464	; 0x464 <system_set_exec_motion_override_flag>
    5eea:	df cf       	rjmp	.-66     	; 0x5eaa <__vector_18+0x9c>
    5eec:	82 e0       	ldi	r24, 0x02	; 2
    5eee:	fb cf       	rjmp	.-10     	; 0x5ee6 <__vector_18+0xd8>
    5ef0:	84 e0       	ldi	r24, 0x04	; 4
    5ef2:	f9 cf       	rjmp	.-14     	; 0x5ee6 <__vector_18+0xd8>
    5ef4:	88 e0       	ldi	r24, 0x08	; 8
    5ef6:	f7 cf       	rjmp	.-18     	; 0x5ee6 <__vector_18+0xd8>
    5ef8:	80 e1       	ldi	r24, 0x10	; 16
    5efa:	f5 cf       	rjmp	.-22     	; 0x5ee6 <__vector_18+0xd8>
    5efc:	80 e2       	ldi	r24, 0x20	; 32
    5efe:	f3 cf       	rjmp	.-26     	; 0x5ee6 <__vector_18+0xd8>
    5f00:	80 e4       	ldi	r24, 0x40	; 64
    5f02:	f1 cf       	rjmp	.-30     	; 0x5ee6 <__vector_18+0xd8>
    5f04:	80 e8       	ldi	r24, 0x80	; 128
    5f06:	ef cf       	rjmp	.-34     	; 0x5ee6 <__vector_18+0xd8>
    5f08:	81 e0       	ldi	r24, 0x01	; 1
    5f0a:	0e 94 29 02 	call	0x452	; 0x452 <system_set_exec_accessory_override_flag>
    5f0e:	cd cf       	rjmp	.-102    	; 0x5eaa <__vector_18+0x9c>
    5f10:	82 e0       	ldi	r24, 0x02	; 2
    5f12:	fb cf       	rjmp	.-10     	; 0x5f0a <__vector_18+0xfc>
    5f14:	84 e0       	ldi	r24, 0x04	; 4
    5f16:	f9 cf       	rjmp	.-14     	; 0x5f0a <__vector_18+0xfc>
    5f18:	88 e0       	ldi	r24, 0x08	; 8
    5f1a:	f7 cf       	rjmp	.-18     	; 0x5f0a <__vector_18+0xfc>
    5f1c:	80 e1       	ldi	r24, 0x10	; 16
    5f1e:	f5 cf       	rjmp	.-22     	; 0x5f0a <__vector_18+0xfc>
    5f20:	80 e2       	ldi	r24, 0x20	; 32
    5f22:	f3 cf       	rjmp	.-26     	; 0x5f0a <__vector_18+0xfc>
    5f24:	80 e4       	ldi	r24, 0x40	; 64
    5f26:	f1 cf       	rjmp	.-30     	; 0x5f0a <__vector_18+0xfc>
    5f28:	a0 91 f0 01 	lds	r26, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    5f2c:	81 e0       	ldi	r24, 0x01	; 1
    5f2e:	8a 0f       	add	r24, r26
    5f30:	81 38       	cpi	r24, 0x81	; 129
    5f32:	09 f4       	brne	.+2      	; 0x5f36 <__vector_18+0x128>
    5f34:	80 e0       	ldi	r24, 0x00	; 0
    5f36:	90 91 f1 01 	lds	r25, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    5f3a:	98 17       	cp	r25, r24
    5f3c:	09 f4       	brne	.+2      	; 0x5f40 <__vector_18+0x132>
    5f3e:	b5 cf       	rjmp	.-150    	; 0x5eaa <__vector_18+0x9c>
    5f40:	b0 e0       	ldi	r27, 0x00	; 0
    5f42:	a1 59       	subi	r26, 0x91	; 145
    5f44:	be 4f       	sbci	r27, 0xFE	; 254
    5f46:	ec 93       	st	X, r30
    5f48:	80 93 f0 01 	sts	0x01F0, r24	; 0x8001f0 <serial_rx_buffer_head>
    5f4c:	ae cf       	rjmp	.-164    	; 0x5eaa <__vector_18+0x9c>

00005f4e <__vector_19>:
    5f4e:	1f 92       	push	r1
    5f50:	0f 92       	push	r0
    5f52:	0f b6       	in	r0, 0x3f	; 63
    5f54:	0f 92       	push	r0
    5f56:	11 24       	eor	r1, r1
    5f58:	8f 93       	push	r24
    5f5a:	9f 93       	push	r25
    5f5c:	ef 93       	push	r30
    5f5e:	ff 93       	push	r31
    5f60:	80 91 6e 01 	lds	r24, 0x016E	; 0x80016e <serial_tx_buffer_tail>
    5f64:	e8 2f       	mov	r30, r24
    5f66:	f0 e0       	ldi	r31, 0x00	; 0
    5f68:	eb 5f       	subi	r30, 0xFB	; 251
    5f6a:	fe 4f       	sbci	r31, 0xFE	; 254
    5f6c:	90 81       	ld	r25, Z
    5f6e:	90 93 c6 00 	sts	0x00C6, r25	; 0x8000c6 <__DATA_REGION_ORIGIN__+0x66>
    5f72:	8f 5f       	subi	r24, 0xFF	; 255
    5f74:	89 36       	cpi	r24, 0x69	; 105
    5f76:	09 f4       	brne	.+2      	; 0x5f7a <__vector_19+0x2c>
    5f78:	80 e0       	ldi	r24, 0x00	; 0
    5f7a:	80 93 6e 01 	sts	0x016E, r24	; 0x80016e <serial_tx_buffer_tail>
    5f7e:	90 91 04 01 	lds	r25, 0x0104	; 0x800104 <serial_tx_buffer_head>
    5f82:	98 13       	cpse	r25, r24
    5f84:	05 c0       	rjmp	.+10     	; 0x5f90 <__vector_19+0x42>
    5f86:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f8a:	8f 7d       	andi	r24, 0xDF	; 223
    5f8c:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5f90:	ff 91       	pop	r31
    5f92:	ef 91       	pop	r30
    5f94:	9f 91       	pop	r25
    5f96:	8f 91       	pop	r24
    5f98:	0f 90       	pop	r0
    5f9a:	0f be       	out	0x3f, r0	; 63
    5f9c:	0f 90       	pop	r0
    5f9e:	1f 90       	pop	r1
    5fa0:	18 95       	reti

00005fa2 <main>:
    5fa2:	cf 93       	push	r28
    5fa4:	df 93       	push	r29
    5fa6:	cd b7       	in	r28, 0x3d	; 61
    5fa8:	de b7       	in	r29, 0x3e	; 62
    5faa:	65 97       	sbiw	r28, 0x15	; 21
    5fac:	0f b6       	in	r0, 0x3f	; 63
    5fae:	f8 94       	cli
    5fb0:	de bf       	out	0x3e, r29	; 62
    5fb2:	0f be       	out	0x3f, r0	; 63
    5fb4:	cd bf       	out	0x3d, r28	; 61
    5fb6:	80 91 c0 00 	lds	r24, 0x00C0	; 0x8000c0 <__DATA_REGION_ORIGIN__+0x60>
    5fba:	82 60       	ori	r24, 0x02	; 2
    5fbc:	80 93 c0 00 	sts	0x00C0, r24	; 0x8000c0 <__DATA_REGION_ORIGIN__+0x60>
    5fc0:	10 92 c5 00 	sts	0x00C5, r1	; 0x8000c5 <__DATA_REGION_ORIGIN__+0x65>
    5fc4:	80 e1       	ldi	r24, 0x10	; 16
    5fc6:	80 93 c4 00 	sts	0x00C4, r24	; 0x8000c4 <__DATA_REGION_ORIGIN__+0x64>
    5fca:	80 91 c1 00 	lds	r24, 0x00C1	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5fce:	88 69       	ori	r24, 0x98	; 152
    5fd0:	80 93 c1 00 	sts	0x00C1, r24	; 0x8000c1 <__DATA_REGION_ORIGIN__+0x61>
    5fd4:	90 e0       	ldi	r25, 0x00	; 0
    5fd6:	80 e0       	ldi	r24, 0x00	; 0
    5fd8:	0e 94 83 04 	call	0x906	; 0x906 <eeprom_get_char>
    5fdc:	8a 30       	cpi	r24, 0x0A	; 10
    5fde:	09 f4       	brne	.+2      	; 0x5fe2 <main+0x40>
    5fe0:	db c0       	rjmp	.+438    	; 0x6198 <main+0x1f6>
    5fe2:	87 e0       	ldi	r24, 0x07	; 7
    5fe4:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    5fe8:	8f ef       	ldi	r24, 0xFF	; 255
    5fea:	0e 94 92 1d 	call	0x3b24	; 0x3b24 <settings_restore>
    5fee:	0e 94 21 08 	call	0x1042	; 0x1042 <report_grbl_settings>
    5ff2:	8a b1       	in	r24, 0x0a	; 10
    5ff4:	8c 61       	ori	r24, 0x1C	; 28
    5ff6:	8a b9       	out	0x0a, r24	; 10
    5ff8:	20 9a       	sbi	0x04, 0	; 4
    5ffa:	8a b1       	in	r24, 0x0a	; 10
    5ffc:	80 6e       	ori	r24, 0xE0	; 224
    5ffe:	8a b9       	out	0x0a, r24	; 10
    6000:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    6004:	8f 7e       	andi	r24, 0xEF	; 239
    6006:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    600a:	80 91 81 00 	lds	r24, 0x0081	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    600e:	88 60       	ori	r24, 0x08	; 8
    6010:	80 93 81 00 	sts	0x0081, r24	; 0x800081 <__DATA_REGION_ORIGIN__+0x21>
    6014:	80 91 80 00 	lds	r24, 0x0080	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    6018:	8c 7f       	andi	r24, 0xFC	; 252
    601a:	80 93 80 00 	sts	0x0080, r24	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    601e:	80 91 80 00 	lds	r24, 0x0080	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    6022:	8f 70       	andi	r24, 0x0F	; 15
    6024:	80 93 80 00 	sts	0x0080, r24	; 0x800080 <__DATA_REGION_ORIGIN__+0x20>
    6028:	80 91 6e 00 	lds	r24, 0x006E	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    602c:	88 7f       	andi	r24, 0xF8	; 248
    602e:	80 93 6e 00 	sts	0x006E, r24	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    6032:	14 bc       	out	0x24, r1	; 36
    6034:	15 bc       	out	0x25, r1	; 37
    6036:	80 91 6e 00 	lds	r24, 0x006E	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    603a:	81 60       	ori	r24, 0x01	; 1
    603c:	80 93 6e 00 	sts	0x006E, r24	; 0x80006e <__DATA_REGION_ORIGIN__+0xe>
    6040:	87 b1       	in	r24, 0x07	; 7
    6042:	88 7f       	andi	r24, 0xF8	; 248
    6044:	87 b9       	out	0x07, r24	; 7
    6046:	88 b1       	in	r24, 0x08	; 8
    6048:	87 60       	ori	r24, 0x07	; 7
    604a:	88 b9       	out	0x08, r24	; 8
    604c:	80 91 6c 00 	lds	r24, 0x006C	; 0x80006c <__DATA_REGION_ORIGIN__+0xc>
    6050:	87 60       	ori	r24, 0x07	; 7
    6052:	80 93 6c 00 	sts	0x006C, r24	; 0x80006c <__DATA_REGION_ORIGIN__+0xc>
    6056:	80 91 68 00 	lds	r24, 0x0068	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
    605a:	82 60       	ori	r24, 0x02	; 2
    605c:	80 93 68 00 	sts	0x0068, r24	; 0x800068 <__DATA_REGION_ORIGIN__+0x8>
    6060:	e8 e1       	ldi	r30, 0x18	; 24
    6062:	f6 e0       	ldi	r31, 0x06	; 6
    6064:	8c e0       	ldi	r24, 0x0C	; 12
    6066:	df 01       	movw	r26, r30
    6068:	1d 92       	st	X+, r1
    606a:	8a 95       	dec	r24
    606c:	e9 f7       	brne	.-6      	; 0x6068 <main+0xc6>
    606e:	78 94       	sei
    6070:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6074:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6078:	84 ff       	sbrs	r24, 4
    607a:	03 c0       	rjmp	.+6      	; 0x6082 <main+0xe0>
    607c:	81 e0       	ldi	r24, 0x01	; 1
    607e:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    6082:	31 e3       	ldi	r19, 0x31	; 49
    6084:	23 2e       	mov	r2, r19
    6086:	36 e0       	ldi	r19, 0x06	; 6
    6088:	33 2e       	mov	r3, r19
    608a:	47 e9       	ldi	r20, 0x97	; 151
    608c:	a4 2e       	mov	r10, r20
    608e:	46 e0       	ldi	r20, 0x06	; 6
    6090:	b4 2e       	mov	r11, r20
    6092:	99 24       	eor	r9, r9
    6094:	93 94       	inc	r9
    6096:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    609a:	91 e1       	ldi	r25, 0x11	; 17
    609c:	f1 01       	movw	r30, r2
    609e:	11 92       	st	Z+, r1
    60a0:	9a 95       	dec	r25
    60a2:	e9 f7       	brne	.-6      	; 0x609e <main+0xfc>
    60a4:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    60a8:	84 e6       	ldi	r24, 0x64	; 100
    60aa:	80 93 38 06 	sts	0x0638, r24	; 0x800638 <sys+0x7>
    60ae:	80 93 39 06 	sts	0x0639, r24	; 0x800639 <sys+0x8>
    60b2:	80 93 3a 06 	sts	0x063A, r24	; 0x80063a <sys+0x9>
    60b6:	8c e0       	ldi	r24, 0x0C	; 12
    60b8:	a4 e2       	ldi	r26, 0x24	; 36
    60ba:	b6 e0       	ldi	r27, 0x06	; 6
    60bc:	1d 92       	st	X+, r1
    60be:	8a 95       	dec	r24
    60c0:	e9 f7       	brne	.-6      	; 0x60bc <main+0x11a>
    60c2:	10 92 30 06 	sts	0x0630, r1	; 0x800630 <sys_probe_state>
    60c6:	10 92 13 06 	sts	0x0613, r1	; 0x800613 <sys_rt_exec_state>
    60ca:	10 92 14 06 	sts	0x0614, r1	; 0x800614 <sys_rt_exec_alarm>
    60ce:	10 92 15 06 	sts	0x0615, r1	; 0x800615 <sys_rt_exec_motion_override>
    60d2:	10 92 16 06 	sts	0x0616, r1	; 0x800616 <sys_rt_exec_accessory_override>
    60d6:	80 91 f0 01 	lds	r24, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    60da:	80 93 f1 01 	sts	0x01F1, r24	; 0x8001f1 <serial_rx_buffer_tail>
    60de:	80 e4       	ldi	r24, 0x40	; 64
    60e0:	f5 01       	movw	r30, r10
    60e2:	11 92       	st	Z+, r1
    60e4:	8a 95       	dec	r24
    60e6:	e9 f7       	brne	.-6      	; 0x60e2 <main+0x140>
    60e8:	6b eb       	ldi	r22, 0xBB	; 187
    60ea:	76 e0       	ldi	r23, 0x06	; 6
    60ec:	80 e0       	ldi	r24, 0x00	; 0
    60ee:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    60f2:	81 11       	cpse	r24, r1
    60f4:	03 c0       	rjmp	.+6      	; 0x60fc <main+0x15a>
    60f6:	87 e0       	ldi	r24, 0x07	; 7
    60f8:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    60fc:	0e 94 76 09 	call	0x12ec	; 0x12ec <spindle_init>
    6100:	3b 9a       	sbi	0x07, 3	; 7
    6102:	43 98       	cbi	0x08, 3	; 8
    6104:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    6108:	3d 98       	cbi	0x07, 5	; 7
    610a:	45 9a       	sbi	0x08, 5	; 8
    610c:	80 e0       	ldi	r24, 0x00	; 0
    610e:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    6112:	0e 94 af 09 	call	0x135e	; 0x135e <plan_reset>
    6116:	0e 94 db 0d 	call	0x1bb6	; 0x1bb6 <st_reset>
    611a:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    611e:	0e 94 a9 09 	call	0x1352	; 0x1352 <gc_sync_position>
    6122:	84 eb       	ldi	r24, 0xB4	; 180
    6124:	90 e0       	ldi	r25, 0x00	; 0
    6126:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    612a:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    612e:	83 ff       	sbrs	r24, 3
    6130:	10 c0       	rjmp	.+32     	; 0x6152 <main+0x1b0>
    6132:	0e 94 ea 02 	call	0x5d4	; 0x5d4 <limits_get_state>
    6136:	88 23       	and	r24, r24
    6138:	61 f0       	breq	.+24     	; 0x6152 <main+0x1b0>
    613a:	90 92 31 06 	sts	0x0631, r9	; 0x800631 <sys>
    613e:	8a ec       	ldi	r24, 0xCA	; 202
    6140:	92 e0       	ldi	r25, 0x02	; 2
    6142:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6146:	89 e6       	ldi	r24, 0x69	; 105
    6148:	92 e0       	ldi	r25, 0x02	; 2
    614a:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    614e:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    6152:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    6156:	81 78       	andi	r24, 0x81	; 129
    6158:	59 f1       	breq	.+86     	; 0x61b0 <main+0x20e>
    615a:	8a ec       	ldi	r24, 0xCA	; 202
    615c:	92 e0       	ldi	r25, 0x02	; 2
    615e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6162:	84 ea       	ldi	r24, 0xA4	; 164
    6164:	92 e0       	ldi	r25, 0x02	; 2
    6166:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    616a:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    616e:	90 92 31 06 	sts	0x0631, r9	; 0x800631 <sys>
    6172:	10 e0       	ldi	r17, 0x00	; 0
    6174:	00 e0       	ldi	r16, 0x00	; 0
    6176:	22 e0       	ldi	r18, 0x02	; 2
    6178:	82 2e       	mov	r8, r18
    617a:	90 91 f1 01 	lds	r25, 0x01F1	; 0x8001f1 <serial_rx_buffer_tail>
    617e:	80 91 f0 01 	lds	r24, 0x01F0	; 0x8001f0 <serial_rx_buffer_head>
    6182:	98 13       	cpse	r25, r24
    6184:	59 c4       	rjmp	.+2226   	; 0x6a38 <main+0xa96>
    6186:	0e 94 92 06 	call	0xd24	; 0xd24 <protocol_auto_cycle_start>
    618a:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    618e:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    6192:	88 23       	and	r24, r24
    6194:	91 f3       	breq	.-28     	; 0x617a <main+0x1d8>
    6196:	7f cf       	rjmp	.-258    	; 0x6096 <main+0xf4>
    6198:	45 e5       	ldi	r20, 0x55	; 85
    619a:	50 e0       	ldi	r21, 0x00	; 0
    619c:	61 e0       	ldi	r22, 0x01	; 1
    619e:	70 e0       	ldi	r23, 0x00	; 0
    61a0:	82 e4       	ldi	r24, 0x42	; 66
    61a2:	96 e0       	ldi	r25, 0x06	; 6
    61a4:	0e 94 8b 04 	call	0x916	; 0x916 <memcpy_from_eeprom_with_checksum>
    61a8:	89 2b       	or	r24, r25
    61aa:	09 f0       	breq	.+2      	; 0x61ae <main+0x20c>
    61ac:	22 cf       	rjmp	.-444    	; 0x5ff2 <main+0x50>
    61ae:	19 cf       	rjmp	.-462    	; 0x5fe2 <main+0x40>
    61b0:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    61b4:	0e 94 22 2c 	call	0x5844	; 0x5844 <system_execute_startup.constprop.2>
    61b8:	dc cf       	rjmp	.-72     	; 0x6172 <main+0x1d0>
    61ba:	84 32       	cpi	r24, 0x24	; 36
    61bc:	09 f0       	breq	.+2      	; 0x61c0 <main+0x21e>
    61be:	0a c4       	rjmp	.+2068   	; 0x69d4 <main+0xa32>
    61c0:	9d 8a       	std	Y+21, r9	; 0x15
    61c2:	80 91 12 07 	lds	r24, 0x0712	; 0x800712 <line+0x1>
    61c6:	83 34       	cpi	r24, 0x43	; 67
    61c8:	29 f0       	breq	.+10     	; 0x61d4 <main+0x232>
    61ca:	bc f4       	brge	.+46     	; 0x61fa <main+0x258>
    61cc:	88 23       	and	r24, r24
    61ce:	b9 f1       	breq	.+110    	; 0x623e <main+0x29c>
    61d0:	84 32       	cpi	r24, 0x24	; 36
    61d2:	c9 f4       	brne	.+50     	; 0x6206 <main+0x264>
    61d4:	90 91 13 07 	lds	r25, 0x0713	; 0x800713 <line+0x2>
    61d8:	91 11       	cpse	r25, r1
    61da:	40 c0       	rjmp	.+128    	; 0x625c <main+0x2ba>
    61dc:	83 34       	cpi	r24, 0x43	; 67
    61de:	09 f4       	brne	.+2      	; 0x61e2 <main+0x240>
    61e0:	f9 c0       	rjmp	.+498    	; 0x63d4 <main+0x432>
    61e2:	0c f0       	brlt	.+2      	; 0x61e6 <main+0x244>
    61e4:	42 c0       	rjmp	.+132    	; 0x626a <main+0x2c8>
    61e6:	84 32       	cpi	r24, 0x24	; 36
    61e8:	71 f5       	brne	.+92     	; 0x6246 <main+0x2a4>
    61ea:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    61ee:	88 71       	andi	r24, 0x18	; 24
    61f0:	09 f0       	breq	.+2      	; 0x61f4 <main+0x252>
    61f2:	22 c1       	rjmp	.+580    	; 0x6438 <main+0x496>
    61f4:	0e 94 21 08 	call	0x1042	; 0x1042 <report_grbl_settings>
    61f8:	26 c0       	rjmp	.+76     	; 0x6246 <main+0x2a4>
    61fa:	8a 34       	cpi	r24, 0x4A	; 74
    61fc:	31 f1       	breq	.+76     	; 0x624a <main+0x2a8>
    61fe:	88 35       	cpi	r24, 0x58	; 88
    6200:	49 f3       	breq	.-46     	; 0x61d4 <main+0x232>
    6202:	87 34       	cpi	r24, 0x47	; 71
    6204:	39 f3       	breq	.-50     	; 0x61d4 <main+0x232>
    6206:	90 91 31 06 	lds	r25, 0x0631	; 0x800631 <sys>
    620a:	92 30       	cpi	r25, 0x02	; 2
    620c:	08 f0       	brcs	.+2      	; 0x6210 <main+0x26e>
    620e:	14 c1       	rjmp	.+552    	; 0x6438 <main+0x496>
    6210:	89 34       	cpi	r24, 0x49	; 73
    6212:	09 f4       	brne	.+2      	; 0x6216 <main+0x274>
    6214:	a3 c1       	rjmp	.+838    	; 0x655c <main+0x5ba>
    6216:	0c f0       	brlt	.+2      	; 0x621a <main+0x278>
    6218:	fb c0       	rjmp	.+502    	; 0x6410 <main+0x46e>
    621a:	83 32       	cpi	r24, 0x23	; 35
    621c:	09 f4       	brne	.+2      	; 0x6220 <main+0x27e>
    621e:	0e c1       	rjmp	.+540    	; 0x643c <main+0x49a>
    6220:	88 34       	cpi	r24, 0x48	; 72
    6222:	09 f4       	brne	.+2      	; 0x6226 <main+0x284>
    6224:	5a c1       	rjmp	.+692    	; 0x64da <main+0x538>
    6226:	10 e0       	ldi	r17, 0x00	; 0
    6228:	be 01       	movw	r22, r28
    622a:	6f 5e       	subi	r22, 0xEF	; 239
    622c:	7f 4f       	sbci	r23, 0xFF	; 255
    622e:	ce 01       	movw	r24, r28
    6230:	45 96       	adiw	r24, 0x15	; 21
    6232:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    6236:	81 11       	cpse	r24, r1
    6238:	2f c2       	rjmp	.+1118   	; 0x6698 <main+0x6f6>
    623a:	12 e0       	ldi	r17, 0x02	; 2
    623c:	14 c0       	rjmp	.+40     	; 0x6266 <main+0x2c4>
    623e:	8c e1       	ldi	r24, 0x1C	; 28
    6240:	91 e0       	ldi	r25, 0x01	; 1
    6242:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6246:	10 e0       	ldi	r17, 0x00	; 0
    6248:	0e c0       	rjmp	.+28     	; 0x6266 <main+0x2c4>
    624a:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    624e:	8f 7d       	andi	r24, 0xDF	; 223
    6250:	09 f0       	breq	.+2      	; 0x6254 <main+0x2b2>
    6252:	f2 c0       	rjmp	.+484    	; 0x6438 <main+0x496>
    6254:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6258:	8d 33       	cpi	r24, 0x3D	; 61
    625a:	11 f0       	breq	.+4      	; 0x6260 <main+0x2be>
    625c:	13 e0       	ldi	r17, 0x03	; 3
    625e:	03 c0       	rjmp	.+6      	; 0x6266 <main+0x2c4>
    6260:	0e 94 6d 1e 	call	0x3cda	; 0x3cda <gc_execute_line.constprop.11>
    6264:	18 2f       	mov	r17, r24
    6266:	81 2f       	mov	r24, r17
    6268:	0b c4       	rjmp	.+2070   	; 0x6a80 <main+0xade>
    626a:	87 34       	cpi	r24, 0x47	; 71
    626c:	99 f0       	breq	.+38     	; 0x6294 <main+0x2f2>
    626e:	88 35       	cpi	r24, 0x58	; 88
    6270:	51 f7       	brne	.-44     	; 0x6246 <main+0x2a4>
    6272:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    6276:	81 30       	cpi	r24, 0x01	; 1
    6278:	31 f7       	brne	.-52     	; 0x6246 <main+0x2a4>
    627a:	8a ec       	ldi	r24, 0xCA	; 202
    627c:	92 e0       	ldi	r25, 0x02	; 2
    627e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6282:	82 e9       	ldi	r24, 0x92	; 146
    6284:	92 e0       	ldi	r25, 0x02	; 2
    6286:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    628a:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    628e:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6292:	d9 cf       	rjmp	.-78     	; 0x6246 <main+0x2a4>
    6294:	86 e1       	ldi	r24, 0x16	; 22
    6296:	91 e0       	ldi	r25, 0x01	; 1
    6298:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    629c:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    62a0:	8c 38       	cpi	r24, 0x8C	; 140
    62a2:	38 f0       	brcs	.+14     	; 0x62b2 <main+0x310>
    62a4:	82 e1       	ldi	r24, 0x12	; 18
    62a6:	91 e0       	ldi	r25, 0x01	; 1
    62a8:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    62ac:	80 91 97 06 	lds	r24, 0x0697	; 0x800697 <gc_state>
    62b0:	8a 58       	subi	r24, 0x8A	; 138
    62b2:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    62b6:	83 e0       	ldi	r24, 0x03	; 3
    62b8:	91 e0       	ldi	r25, 0x01	; 1
    62ba:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    62be:	80 91 9d 06 	lds	r24, 0x069D	; 0x80069d <gc_state+0x6>
    62c2:	8a 5c       	subi	r24, 0xCA	; 202
    62c4:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    62c8:	83 e0       	ldi	r24, 0x03	; 3
    62ca:	91 e0       	ldi	r25, 0x01	; 1
    62cc:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    62d0:	80 91 9b 06 	lds	r24, 0x069B	; 0x80069b <gc_state+0x4>
    62d4:	8f 5e       	subi	r24, 0xEF	; 239
    62d6:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    62da:	83 e0       	ldi	r24, 0x03	; 3
    62dc:	91 e0       	ldi	r25, 0x01	; 1
    62de:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    62e2:	80 91 99 06 	lds	r24, 0x0699	; 0x800699 <gc_state+0x2>
    62e6:	f5 e1       	ldi	r31, 0x15	; 21
    62e8:	f8 1b       	sub	r31, r24
    62ea:	8f 2f       	mov	r24, r31
    62ec:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    62f0:	83 e0       	ldi	r24, 0x03	; 3
    62f2:	91 e0       	ldi	r25, 0x01	; 1
    62f4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    62f8:	80 91 9a 06 	lds	r24, 0x069A	; 0x80069a <gc_state+0x3>
    62fc:	86 5a       	subi	r24, 0xA6	; 166
    62fe:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    6302:	83 e0       	ldi	r24, 0x03	; 3
    6304:	91 e0       	ldi	r25, 0x01	; 1
    6306:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    630a:	80 91 98 06 	lds	r24, 0x0698	; 0x800698 <gc_state+0x1>
    630e:	2e e5       	ldi	r18, 0x5E	; 94
    6310:	28 1b       	sub	r18, r24
    6312:	82 2f       	mov	r24, r18
    6314:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    6318:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    631c:	88 23       	and	r24, r24
    631e:	91 f0       	breq	.+36     	; 0x6344 <main+0x3a2>
    6320:	86 e0       	ldi	r24, 0x06	; 6
    6322:	91 e0       	ldi	r25, 0x01	; 1
    6324:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6328:	80 91 9e 06 	lds	r24, 0x069E	; 0x80069e <gc_state+0x7>
    632c:	83 30       	cpi	r24, 0x03	; 3
    632e:	39 f0       	breq	.+14     	; 0x633e <main+0x39c>
    6330:	8e 31       	cpi	r24, 0x1E	; 30
    6332:	11 f0       	breq	.+4      	; 0x6338 <main+0x396>
    6334:	82 30       	cpi	r24, 0x02	; 2
    6336:	31 f4       	brne	.+12     	; 0x6344 <main+0x3a2>
    6338:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    633c:	03 c0       	rjmp	.+6      	; 0x6344 <main+0x3a2>
    633e:	80 e3       	ldi	r24, 0x30	; 48
    6340:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    6344:	86 e0       	ldi	r24, 0x06	; 6
    6346:	91 e0       	ldi	r25, 0x01	; 1
    6348:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    634c:	80 91 a0 06 	lds	r24, 0x06A0	; 0x8006a0 <gc_state+0x9>
    6350:	80 31       	cpi	r24, 0x10	; 16
    6352:	31 f0       	breq	.+12     	; 0x6360 <main+0x3be>
    6354:	80 32       	cpi	r24, 0x20	; 32
    6356:	d1 f1       	breq	.+116    	; 0x63cc <main+0x42a>
    6358:	81 11       	cpse	r24, r1
    635a:	05 c0       	rjmp	.+10     	; 0x6366 <main+0x3c4>
    635c:	85 e3       	ldi	r24, 0x35	; 53
    635e:	01 c0       	rjmp	.+2      	; 0x6362 <main+0x3c0>
    6360:	83 e3       	ldi	r24, 0x33	; 51
    6362:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    6366:	86 e0       	ldi	r24, 0x06	; 6
    6368:	91 e0       	ldi	r25, 0x01	; 1
    636a:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    636e:	80 91 9f 06 	lds	r24, 0x069F	; 0x80069f <gc_state+0x8>
    6372:	88 23       	and	r24, r24
    6374:	69 f1       	breq	.+90     	; 0x63d0 <main+0x42e>
    6376:	88 e3       	ldi	r24, 0x38	; 56
    6378:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    637c:	8f e0       	ldi	r24, 0x0F	; 15
    637e:	91 e0       	ldi	r25, 0x01	; 1
    6380:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6384:	80 91 aa 06 	lds	r24, 0x06AA	; 0x8006aa <gc_state+0x13>
    6388:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    638c:	8c e0       	ldi	r24, 0x0C	; 12
    638e:	91 e0       	ldi	r25, 0x01	; 1
    6390:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6394:	60 91 a6 06 	lds	r22, 0x06A6	; 0x8006a6 <gc_state+0xf>
    6398:	70 91 a7 06 	lds	r23, 0x06A7	; 0x8006a7 <gc_state+0x10>
    639c:	80 91 a8 06 	lds	r24, 0x06A8	; 0x8006a8 <gc_state+0x11>
    63a0:	90 91 a9 06 	lds	r25, 0x06A9	; 0x8006a9 <gc_state+0x12>
    63a4:	0e 94 6d 07 	call	0xeda	; 0xeda <printFloat_RateValue>
    63a8:	89 e0       	ldi	r24, 0x09	; 9
    63aa:	91 e0       	ldi	r25, 0x01	; 1
    63ac:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    63b0:	60 91 a2 06 	lds	r22, 0x06A2	; 0x8006a2 <gc_state+0xb>
    63b4:	70 91 a3 06 	lds	r23, 0x06A3	; 0x8006a3 <gc_state+0xc>
    63b8:	80 91 a4 06 	lds	r24, 0x06A4	; 0x8006a4 <gc_state+0xd>
    63bc:	90 91 a5 06 	lds	r25, 0x06A5	; 0x8006a5 <gc_state+0xe>
    63c0:	40 e0       	ldi	r20, 0x00	; 0
    63c2:	0e 94 c3 06 	call	0xd86	; 0xd86 <printFloat>
    63c6:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    63ca:	3d cf       	rjmp	.-390    	; 0x6246 <main+0x2a4>
    63cc:	84 e3       	ldi	r24, 0x34	; 52
    63ce:	c9 cf       	rjmp	.-110    	; 0x6362 <main+0x3c0>
    63d0:	89 e3       	ldi	r24, 0x39	; 57
    63d2:	d2 cf       	rjmp	.-92     	; 0x6378 <main+0x3d6>
    63d4:	10 91 31 06 	lds	r17, 0x0631	; 0x800631 <sys>
    63d8:	12 30       	cpi	r17, 0x02	; 2
    63da:	59 f4       	brne	.+22     	; 0x63f2 <main+0x450>
    63dc:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    63e0:	8a ec       	ldi	r24, 0xCA	; 202
    63e2:	92 e0       	ldi	r25, 0x02	; 2
    63e4:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    63e8:	81 e8       	ldi	r24, 0x81	; 129
    63ea:	92 e0       	ldi	r25, 0x02	; 2
    63ec:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    63f0:	ea cf       	rjmp	.-44     	; 0x63c6 <main+0x424>
    63f2:	11 11       	cpse	r17, r1
    63f4:	21 c0       	rjmp	.+66     	; 0x6438 <main+0x496>
    63f6:	80 92 31 06 	sts	0x0631, r8	; 0x800631 <sys>
    63fa:	8a ec       	ldi	r24, 0xCA	; 202
    63fc:	92 e0       	ldi	r25, 0x02	; 2
    63fe:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6402:	8a e8       	ldi	r24, 0x8A	; 138
    6404:	92 e0       	ldi	r25, 0x02	; 2
    6406:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    640a:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    640e:	2b cf       	rjmp	.-426    	; 0x6266 <main+0x2c4>
    6410:	82 35       	cpi	r24, 0x52	; 82
    6412:	09 f4       	brne	.+2      	; 0x6416 <main+0x474>
    6414:	f6 c0       	rjmp	.+492    	; 0x6602 <main+0x660>
    6416:	83 35       	cpi	r24, 0x53	; 83
    6418:	09 f4       	brne	.+2      	; 0x641c <main+0x47a>
    641a:	8e c0       	rjmp	.+284    	; 0x6538 <main+0x596>
    641c:	8e 34       	cpi	r24, 0x4E	; 78
    641e:	09 f0       	breq	.+2      	; 0x6422 <main+0x480>
    6420:	02 cf       	rjmp	.-508    	; 0x6226 <main+0x284>
    6422:	8d 8a       	std	Y+21, r8	; 0x15
    6424:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6428:	10 e0       	ldi	r17, 0x00	; 0
    642a:	88 23       	and	r24, r24
    642c:	09 f4       	brne	.+2      	; 0x6430 <main+0x48e>
    642e:	1a c1       	rjmp	.+564    	; 0x6664 <main+0x6c2>
    6430:	11 e0       	ldi	r17, 0x01	; 1
    6432:	99 23       	and	r25, r25
    6434:	09 f4       	brne	.+2      	; 0x6438 <main+0x496>
    6436:	f8 ce       	rjmp	.-528    	; 0x6228 <main+0x286>
    6438:	18 e0       	ldi	r17, 0x08	; 8
    643a:	15 cf       	rjmp	.-470    	; 0x6266 <main+0x2c4>
    643c:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6440:	81 11       	cpse	r24, r1
    6442:	0c cf       	rjmp	.-488    	; 0x625c <main+0x2ba>
    6444:	00 e0       	ldi	r16, 0x00	; 0
    6446:	be 01       	movw	r22, r28
    6448:	6f 5f       	subi	r22, 0xFF	; 255
    644a:	7f 4f       	sbci	r23, 0xFF	; 255
    644c:	80 2f       	mov	r24, r16
    644e:	0e 94 71 1d 	call	0x3ae2	; 0x3ae2 <settings_read_coord_data>
    6452:	18 2f       	mov	r17, r24
    6454:	81 11       	cpse	r24, r1
    6456:	04 c0       	rjmp	.+8      	; 0x6460 <main+0x4be>
    6458:	87 e0       	ldi	r24, 0x07	; 7
    645a:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    645e:	03 cf       	rjmp	.-506    	; 0x6266 <main+0x2c4>
    6460:	80 e0       	ldi	r24, 0x00	; 0
    6462:	91 e0       	ldi	r25, 0x01	; 1
    6464:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6468:	06 30       	cpi	r16, 0x06	; 6
    646a:	39 f0       	breq	.+14     	; 0x647a <main+0x4d8>
    646c:	07 30       	cpi	r16, 0x07	; 7
    646e:	91 f1       	breq	.+100    	; 0x64d4 <main+0x532>
    6470:	86 e3       	ldi	r24, 0x36	; 54
    6472:	80 0f       	add	r24, r16
    6474:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    6478:	04 c0       	rjmp	.+8      	; 0x6482 <main+0x4e0>
    647a:	8d ef       	ldi	r24, 0xFD	; 253
    647c:	90 e0       	ldi	r25, 0x00	; 0
    647e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6482:	8a e3       	ldi	r24, 0x3A	; 58
    6484:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    6488:	ce 01       	movw	r24, r28
    648a:	01 96       	adiw	r24, 0x01	; 1
    648c:	0e 94 89 07 	call	0xf12	; 0xf12 <report_util_axis_values>
    6490:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    6494:	0f 5f       	subi	r16, 0xFF	; 255
    6496:	08 30       	cpi	r16, 0x08	; 8
    6498:	b1 f6       	brne	.-84     	; 0x6446 <main+0x4a4>
    649a:	84 ef       	ldi	r24, 0xF4	; 244
    649c:	90 e0       	ldi	r25, 0x00	; 0
    649e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    64a2:	87 ec       	ldi	r24, 0xC7	; 199
    64a4:	96 e0       	ldi	r25, 0x06	; 6
    64a6:	0e 94 89 07 	call	0xf12	; 0xf12 <report_util_axis_values>
    64aa:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    64ae:	8e ee       	ldi	r24, 0xEE	; 238
    64b0:	90 e0       	ldi	r25, 0x00	; 0
    64b2:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    64b6:	60 91 d3 06 	lds	r22, 0x06D3	; 0x8006d3 <gc_state+0x3c>
    64ba:	70 91 d4 06 	lds	r23, 0x06D4	; 0x8006d4 <gc_state+0x3d>
    64be:	80 91 d5 06 	lds	r24, 0x06D5	; 0x8006d5 <gc_state+0x3e>
    64c2:	90 91 d6 06 	lds	r25, 0x06D6	; 0x8006d6 <gc_state+0x3f>
    64c6:	0e 94 7b 07 	call	0xef6	; 0xef6 <printFloat_CoordValue>
    64ca:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    64ce:	0e 94 32 09 	call	0x1264	; 0x1264 <report_probe_parameters>
    64d2:	b9 ce       	rjmp	.-654    	; 0x6246 <main+0x2a4>
    64d4:	8a ef       	ldi	r24, 0xFA	; 250
    64d6:	90 e0       	ldi	r25, 0x00	; 0
    64d8:	d2 cf       	rjmp	.-92     	; 0x647e <main+0x4dc>
    64da:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    64de:	15 e0       	ldi	r17, 0x05	; 5
    64e0:	84 ff       	sbrs	r24, 4
    64e2:	c1 ce       	rjmp	.-638    	; 0x6266 <main+0x2c4>
    64e4:	84 e0       	ldi	r24, 0x04	; 4
    64e6:	80 93 31 06 	sts	0x0631, r24	; 0x800631 <sys>
    64ea:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    64ee:	81 11       	cpse	r24, r1
    64f0:	b5 ce       	rjmp	.-662    	; 0x625c <main+0x2ba>
    64f2:	0e 94 fe 02 	call	0x5fc	; 0x5fc <limits_disable>
    64f6:	84 e0       	ldi	r24, 0x04	; 4
    64f8:	0e 94 0f 1b 	call	0x361e	; 0x361e <limits_go_home>
    64fc:	83 e0       	ldi	r24, 0x03	; 3
    64fe:	0e 94 0f 1b 	call	0x361e	; 0x361e <limits_go_home>
    6502:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    6506:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    650a:	81 11       	cpse	r24, r1
    650c:	06 c0       	rjmp	.+12     	; 0x651a <main+0x578>
    650e:	0e 94 a9 09 	call	0x1352	; 0x1352 <gc_sync_position>
    6512:	0e 94 76 03 	call	0x6ec	; 0x6ec <plan_sync_position>
    6516:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    651a:	10 91 32 06 	lds	r17, 0x0632	; 0x800632 <sys+0x1>
    651e:	11 11       	cpse	r17, r1
    6520:	92 ce       	rjmp	.-732    	; 0x6246 <main+0x2a4>
    6522:	10 92 31 06 	sts	0x0631, r1	; 0x800631 <sys>
    6526:	0e 94 a7 0d 	call	0x1b4e	; 0x1b4e <st_go_idle>
    652a:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    652e:	81 11       	cpse	r24, r1
    6530:	8a ce       	rjmp	.-748    	; 0x6246 <main+0x2a4>
    6532:	0e 94 22 2c 	call	0x5844	; 0x5844 <system_execute_startup.constprop.2>
    6536:	97 ce       	rjmp	.-722    	; 0x6266 <main+0x2c4>
    6538:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    653c:	8c 34       	cpi	r24, 0x4C	; 76
    653e:	09 f0       	breq	.+2      	; 0x6542 <main+0x5a0>
    6540:	8d ce       	rjmp	.-742    	; 0x625c <main+0x2ba>
    6542:	80 91 14 07 	lds	r24, 0x0714	; 0x800714 <line+0x3>
    6546:	80 35       	cpi	r24, 0x50	; 80
    6548:	09 f0       	breq	.+2      	; 0x654c <main+0x5aa>
    654a:	88 ce       	rjmp	.-752    	; 0x625c <main+0x2ba>
    654c:	80 91 15 07 	lds	r24, 0x0715	; 0x800715 <line+0x4>
    6550:	81 11       	cpse	r24, r1
    6552:	84 ce       	rjmp	.-760    	; 0x625c <main+0x2ba>
    6554:	80 e8       	ldi	r24, 0x80	; 128
    6556:	0e 94 4b 02 	call	0x496	; 0x496 <system_set_exec_state_flag>
    655a:	75 ce       	rjmp	.-790    	; 0x6246 <main+0x2a4>
    655c:	8d 8a       	std	Y+21, r8	; 0x15
    655e:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6562:	81 11       	cpse	r24, r1
    6564:	30 c0       	rjmp	.+96     	; 0x65c6 <main+0x624>
    6566:	40 e5       	ldi	r20, 0x50	; 80
    6568:	50 e0       	ldi	r21, 0x00	; 0
    656a:	6e ea       	ldi	r22, 0xAE	; 174
    656c:	73 e0       	ldi	r23, 0x03	; 3
    656e:	81 e1       	ldi	r24, 0x11	; 17
    6570:	97 e0       	ldi	r25, 0x07	; 7
    6572:	0e 94 8b 04 	call	0x916	; 0x916 <memcpy_from_eeprom_with_checksum>
    6576:	89 2b       	or	r24, r25
    6578:	51 f4       	brne	.+20     	; 0x658e <main+0x5ec>
    657a:	10 92 11 07 	sts	0x0711, r1	; 0x800711 <line>
    657e:	40 e5       	ldi	r20, 0x50	; 80
    6580:	50 e0       	ldi	r21, 0x00	; 0
    6582:	61 e1       	ldi	r22, 0x11	; 17
    6584:	77 e0       	ldi	r23, 0x07	; 7
    6586:	8e ea       	ldi	r24, 0xAE	; 174
    6588:	93 e0       	ldi	r25, 0x03	; 3
    658a:	0e 94 3b 04 	call	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>
    658e:	8a ed       	ldi	r24, 0xDA	; 218
    6590:	90 e0       	ldi	r25, 0x00	; 0
    6592:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6596:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printString.constprop.9>
    659a:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    659e:	84 ed       	ldi	r24, 0xD4	; 212
    65a0:	90 e0       	ldi	r25, 0x00	; 0
    65a2:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    65a6:	86 e5       	ldi	r24, 0x56	; 86
    65a8:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    65ac:	8c e2       	ldi	r24, 0x2C	; 44
    65ae:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    65b2:	8f e0       	ldi	r24, 0x0F	; 15
    65b4:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    65b8:	8c e2       	ldi	r24, 0x2C	; 44
    65ba:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    65be:	80 e8       	ldi	r24, 0x80	; 128
    65c0:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    65c4:	00 cf       	rjmp	.-512    	; 0x63c6 <main+0x424>
    65c6:	93 e0       	ldi	r25, 0x03	; 3
    65c8:	9d 8b       	std	Y+21, r25	; 0x15
    65ca:	8d 33       	cpi	r24, 0x3D	; 61
    65cc:	09 f0       	breq	.+2      	; 0x65d0 <main+0x62e>
    65ce:	46 ce       	rjmp	.-884    	; 0x625c <main+0x2ba>
    65d0:	83 e0       	ldi	r24, 0x03	; 3
    65d2:	28 2f       	mov	r18, r24
    65d4:	30 e0       	ldi	r19, 0x00	; 0
    65d6:	f9 01       	movw	r30, r18
    65d8:	ef 5e       	subi	r30, 0xEF	; 239
    65da:	f8 4f       	sbci	r31, 0xF8	; 248
    65dc:	90 81       	ld	r25, Z
    65de:	22 5f       	subi	r18, 0xF2	; 242
    65e0:	38 4f       	sbci	r19, 0xF8	; 248
    65e2:	d9 01       	movw	r26, r18
    65e4:	9c 93       	st	X, r25
    65e6:	8f 5f       	subi	r24, 0xFF	; 255
    65e8:	90 81       	ld	r25, Z
    65ea:	91 11       	cpse	r25, r1
    65ec:	f2 cf       	rjmp	.-28     	; 0x65d2 <main+0x630>
    65ee:	8d 8b       	std	Y+21, r24	; 0x15
    65f0:	40 e5       	ldi	r20, 0x50	; 80
    65f2:	50 e0       	ldi	r21, 0x00	; 0
    65f4:	61 e1       	ldi	r22, 0x11	; 17
    65f6:	77 e0       	ldi	r23, 0x07	; 7
    65f8:	8e ea       	ldi	r24, 0xAE	; 174
    65fa:	93 e0       	ldi	r25, 0x03	; 3
    65fc:	0e 94 3b 04 	call	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>
    6600:	22 ce       	rjmp	.-956    	; 0x6246 <main+0x2a4>
    6602:	80 91 13 07 	lds	r24, 0x0713	; 0x800713 <line+0x2>
    6606:	83 35       	cpi	r24, 0x53	; 83
    6608:	09 f0       	breq	.+2      	; 0x660c <main+0x66a>
    660a:	28 ce       	rjmp	.-944    	; 0x625c <main+0x2ba>
    660c:	80 91 14 07 	lds	r24, 0x0714	; 0x800714 <line+0x3>
    6610:	84 35       	cpi	r24, 0x54	; 84
    6612:	09 f0       	breq	.+2      	; 0x6616 <main+0x674>
    6614:	23 ce       	rjmp	.-954    	; 0x625c <main+0x2ba>
    6616:	80 91 15 07 	lds	r24, 0x0715	; 0x800715 <line+0x4>
    661a:	8d 33       	cpi	r24, 0x3D	; 61
    661c:	09 f0       	breq	.+2      	; 0x6620 <main+0x67e>
    661e:	1e ce       	rjmp	.-964    	; 0x625c <main+0x2ba>
    6620:	80 91 17 07 	lds	r24, 0x0717	; 0x800717 <line+0x6>
    6624:	81 11       	cpse	r24, r1
    6626:	1a ce       	rjmp	.-972    	; 0x625c <main+0x2ba>
    6628:	80 91 16 07 	lds	r24, 0x0716	; 0x800716 <line+0x5>
    662c:	84 32       	cpi	r24, 0x24	; 36
    662e:	39 f0       	breq	.+14     	; 0x663e <main+0x69c>
    6630:	8a 32       	cpi	r24, 0x2A	; 42
    6632:	a9 f0       	breq	.+42     	; 0x665e <main+0x6bc>
    6634:	83 32       	cpi	r24, 0x23	; 35
    6636:	09 f0       	breq	.+2      	; 0x663a <main+0x698>
    6638:	11 ce       	rjmp	.-990    	; 0x625c <main+0x2ba>
    663a:	82 e0       	ldi	r24, 0x02	; 2
    663c:	01 c0       	rjmp	.+2      	; 0x6640 <main+0x69e>
    663e:	81 e0       	ldi	r24, 0x01	; 1
    6640:	0e 94 92 1d 	call	0x3b24	; 0x3b24 <settings_restore>
    6644:	8a ec       	ldi	r24, 0xCA	; 202
    6646:	92 e0       	ldi	r25, 0x02	; 2
    6648:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    664c:	8e e4       	ldi	r24, 0x4E	; 78
    664e:	92 e0       	ldi	r25, 0x02	; 2
    6650:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6654:	0e 94 2d 09 	call	0x125a	; 0x125a <report_util_feedback_line_feed>
    6658:	0e 94 0e 0e 	call	0x1c1c	; 0x1c1c <mc_reset>
    665c:	f4 cd       	rjmp	.-1048   	; 0x6246 <main+0x2a4>
    665e:	8f ef       	ldi	r24, 0xFF	; 255
    6660:	ef cf       	rjmp	.-34     	; 0x6640 <main+0x69e>
    6662:	11 e0       	ldi	r17, 0x01	; 1
    6664:	81 2f       	mov	r24, r17
    6666:	0e 94 37 1d 	call	0x3a6e	; 0x3a6e <settings_read_startup_line.constprop.7>
    666a:	81 11       	cpse	r24, r1
    666c:	06 c0       	rjmp	.+12     	; 0x667a <main+0x6d8>
    666e:	87 e0       	ldi	r24, 0x07	; 7
    6670:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    6674:	11 30       	cpi	r17, 0x01	; 1
    6676:	a9 f7       	brne	.-22     	; 0x6662 <main+0x6c0>
    6678:	e6 cd       	rjmp	.-1076   	; 0x6246 <main+0x2a4>
    667a:	81 ed       	ldi	r24, 0xD1	; 209
    667c:	90 e0       	ldi	r25, 0x00	; 0
    667e:	0e 94 c7 07 	call	0xf8e	; 0xf8e <printPgmString>
    6682:	81 2f       	mov	r24, r17
    6684:	0e 94 a2 07 	call	0xf44	; 0xf44 <print_uint8_base10>
    6688:	8d e3       	ldi	r24, 0x3D	; 61
    668a:	0e 94 9a 06 	call	0xd34	; 0xd34 <serial_write>
    668e:	0e 94 b6 06 	call	0xd6c	; 0xd6c <printString.constprop.9>
    6692:	0e 94 d5 07 	call	0xfaa	; 0xfaa <report_util_line_feed>
    6696:	ee cf       	rjmp	.-36     	; 0x6674 <main+0x6d2>
    6698:	ed 89       	ldd	r30, Y+21	; 0x15
    669a:	81 e0       	ldi	r24, 0x01	; 1
    669c:	8e 0f       	add	r24, r30
    669e:	8d 8b       	std	Y+21, r24	; 0x15
    66a0:	f0 e0       	ldi	r31, 0x00	; 0
    66a2:	ef 5e       	subi	r30, 0xEF	; 239
    66a4:	f8 4f       	sbci	r31, 0xF8	; 248
    66a6:	90 81       	ld	r25, Z
    66a8:	9d 33       	cpi	r25, 0x3D	; 61
    66aa:	09 f0       	breq	.+2      	; 0x66ae <main+0x70c>
    66ac:	d7 cd       	rjmp	.-1106   	; 0x625c <main+0x2ba>
    66ae:	11 23       	and	r17, r17
    66b0:	91 f1       	breq	.+100    	; 0x6716 <main+0x774>
    66b2:	48 2f       	mov	r20, r24
    66b4:	50 e0       	ldi	r21, 0x00	; 0
    66b6:	28 2f       	mov	r18, r24
    66b8:	30 e0       	ldi	r19, 0x00	; 0
    66ba:	f9 01       	movw	r30, r18
    66bc:	ef 5e       	subi	r30, 0xEF	; 239
    66be:	f8 4f       	sbci	r31, 0xF8	; 248
    66c0:	90 81       	ld	r25, Z
    66c2:	24 1b       	sub	r18, r20
    66c4:	35 0b       	sbc	r19, r21
    66c6:	d9 01       	movw	r26, r18
    66c8:	af 5e       	subi	r26, 0xEF	; 239
    66ca:	b8 4f       	sbci	r27, 0xF8	; 248
    66cc:	9c 93       	st	X, r25
    66ce:	8f 5f       	subi	r24, 0xFF	; 255
    66d0:	90 81       	ld	r25, Z
    66d2:	91 11       	cpse	r25, r1
    66d4:	f0 cf       	rjmp	.-32     	; 0x66b6 <main+0x714>
    66d6:	8d 8b       	std	Y+21, r24	; 0x15
    66d8:	0e 94 6d 1e 	call	0x3cda	; 0x3cda <gc_execute_line.constprop.11>
    66dc:	18 2f       	mov	r17, r24
    66de:	81 11       	cpse	r24, r1
    66e0:	c2 cd       	rjmp	.-1148   	; 0x6266 <main+0x2c4>
    66e2:	69 89       	ldd	r22, Y+17	; 0x11
    66e4:	7a 89       	ldd	r23, Y+18	; 0x12
    66e6:	8b 89       	ldd	r24, Y+19	; 0x13
    66e8:	9c 89       	ldd	r25, Y+20	; 0x14
    66ea:	0e 94 7e 39 	call	0x72fc	; 0x72fc <trunc>
    66ee:	2b 01       	movw	r4, r22
    66f0:	3c 01       	movw	r6, r24
    66f2:	0e 94 26 1d 	call	0x3a4c	; 0x3a4c <protocol_buffer_synchronize>
    66f6:	c3 01       	movw	r24, r6
    66f8:	b2 01       	movw	r22, r4
    66fa:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    66fe:	b1 e5       	ldi	r27, 0x51	; 81
    6700:	6b 9f       	mul	r22, r27
    6702:	c0 01       	movw	r24, r0
    6704:	11 24       	eor	r1, r1
    6706:	40 e5       	ldi	r20, 0x50	; 80
    6708:	50 e0       	ldi	r21, 0x00	; 0
    670a:	61 e1       	ldi	r22, 0x11	; 17
    670c:	77 e0       	ldi	r23, 0x07	; 7
    670e:	9d 5f       	subi	r25, 0xFD	; 253
    6710:	0e 94 3b 04 	call	0x876	; 0x876 <memcpy_to_eeprom_with_checksum>
    6714:	a8 cd       	rjmp	.-1200   	; 0x6266 <main+0x2c4>
    6716:	be 01       	movw	r22, r28
    6718:	63 5f       	subi	r22, 0xF3	; 243
    671a:	7f 4f       	sbci	r23, 0xFF	; 255
    671c:	ce 01       	movw	r24, r28
    671e:	45 96       	adiw	r24, 0x15	; 21
    6720:	0e 94 7c 01 	call	0x2f8	; 0x2f8 <read_float.constprop.12>
    6724:	88 23       	and	r24, r24
    6726:	09 f4       	brne	.+2      	; 0x672a <main+0x788>
    6728:	88 cd       	rjmp	.-1264   	; 0x623a <main+0x298>
    672a:	ed 89       	ldd	r30, Y+21	; 0x15
    672c:	f0 e0       	ldi	r31, 0x00	; 0
    672e:	ef 5e       	subi	r30, 0xEF	; 239
    6730:	f8 4f       	sbci	r31, 0xF8	; 248
    6732:	80 81       	ld	r24, Z
    6734:	81 11       	cpse	r24, r1
    6736:	92 cd       	rjmp	.-1244   	; 0x625c <main+0x2ba>
    6738:	c9 88       	ldd	r12, Y+17	; 0x11
    673a:	da 88       	ldd	r13, Y+18	; 0x12
    673c:	eb 88       	ldd	r14, Y+19	; 0x13
    673e:	fc 88       	ldd	r15, Y+20	; 0x14
    6740:	20 e0       	ldi	r18, 0x00	; 0
    6742:	30 e0       	ldi	r19, 0x00	; 0
    6744:	4f e7       	ldi	r20, 0x7F	; 127
    6746:	53 e4       	ldi	r21, 0x43	; 67
    6748:	c7 01       	movw	r24, r14
    674a:	b6 01       	movw	r22, r12
    674c:	0e 94 5b 38 	call	0x70b6	; 0x70b6 <__gesf2>
    6750:	18 16       	cp	r1, r24
    6752:	0c f4       	brge	.+2      	; 0x6756 <main+0x7b4>
    6754:	83 cd       	rjmp	.-1274   	; 0x625c <main+0x2ba>
    6756:	4d 84       	ldd	r4, Y+13	; 0x0d
    6758:	5e 84       	ldd	r5, Y+14	; 0x0e
    675a:	6f 84       	ldd	r6, Y+15	; 0x0f
    675c:	78 88       	ldd	r7, Y+16	; 0x10
    675e:	c7 01       	movw	r24, r14
    6760:	b6 01       	movw	r22, r12
    6762:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    6766:	06 2f       	mov	r16, r22
    6768:	20 e0       	ldi	r18, 0x00	; 0
    676a:	30 e0       	ldi	r19, 0x00	; 0
    676c:	a9 01       	movw	r20, r18
    676e:	c3 01       	movw	r24, r6
    6770:	b2 01       	movw	r22, r4
    6772:	0e 94 39 36 	call	0x6c72	; 0x6c72 <__cmpsf2>
    6776:	87 fd       	sbrc	r24, 7
    6778:	27 c1       	rjmp	.+590    	; 0x69c8 <main+0xa26>
    677a:	04 36       	cpi	r16, 0x64	; 100
    677c:	08 f4       	brcc	.+2      	; 0x6780 <main+0x7de>
    677e:	45 c0       	rjmp	.+138    	; 0x680a <main+0x868>
    6780:	04 56       	subi	r16, 0x64	; 100
    6782:	80 e0       	ldi	r24, 0x00	; 0
    6784:	03 30       	cpi	r16, 0x03	; 3
    6786:	c0 f5       	brcc	.+112    	; 0x67f8 <main+0x856>
    6788:	e0 2f       	mov	r30, r16
    678a:	f0 e0       	ldi	r31, 0x00	; 0
    678c:	ee 0f       	add	r30, r30
    678e:	ff 1f       	adc	r31, r31
    6790:	ee 0f       	add	r30, r30
    6792:	ff 1f       	adc	r31, r31
    6794:	82 30       	cpi	r24, 0x02	; 2
    6796:	81 f0       	breq	.+32     	; 0x67b8 <main+0x816>
    6798:	83 30       	cpi	r24, 0x03	; 3
    679a:	39 f1       	breq	.+78     	; 0x67ea <main+0x848>
    679c:	81 30       	cpi	r24, 0x01	; 1
    679e:	49 f0       	breq	.+18     	; 0x67b2 <main+0x810>
    67a0:	ee 5b       	subi	r30, 0xBE	; 190
    67a2:	f9 4f       	sbci	r31, 0xF9	; 249
    67a4:	40 82       	st	Z, r4
    67a6:	51 82       	std	Z+1, r5	; 0x01
    67a8:	62 82       	std	Z+2, r6	; 0x02
    67aa:	73 82       	std	Z+3, r7	; 0x03
    67ac:	0e 94 76 04 	call	0x8ec	; 0x8ec <write_global_settings>
    67b0:	5a cd       	rjmp	.-1356   	; 0x6266 <main+0x2c4>
    67b2:	e2 5b       	subi	r30, 0xB2	; 178
    67b4:	f9 4f       	sbci	r31, 0xF9	; 249
    67b6:	f6 cf       	rjmp	.-20     	; 0x67a4 <main+0x802>
    67b8:	cf 01       	movw	r24, r30
    67ba:	86 5a       	subi	r24, 0xA6	; 166
    67bc:	99 4f       	sbci	r25, 0xF9	; 249
    67be:	7c 01       	movw	r14, r24
    67c0:	20 e0       	ldi	r18, 0x00	; 0
    67c2:	30 e0       	ldi	r19, 0x00	; 0
    67c4:	40 e7       	ldi	r20, 0x70	; 112
    67c6:	52 e4       	ldi	r21, 0x42	; 66
    67c8:	c3 01       	movw	r24, r6
    67ca:	b2 01       	movw	r22, r4
    67cc:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    67d0:	20 e0       	ldi	r18, 0x00	; 0
    67d2:	30 e0       	ldi	r19, 0x00	; 0
    67d4:	40 e7       	ldi	r20, 0x70	; 112
    67d6:	52 e4       	ldi	r21, 0x42	; 66
    67d8:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    67dc:	d7 01       	movw	r26, r14
    67de:	6d 93       	st	X+, r22
    67e0:	7d 93       	st	X+, r23
    67e2:	8d 93       	st	X+, r24
    67e4:	9c 93       	st	X, r25
    67e6:	13 97       	sbiw	r26, 0x03	; 3
    67e8:	e1 cf       	rjmp	.-62     	; 0x67ac <main+0x80a>
    67ea:	ea 59       	subi	r30, 0x9A	; 154
    67ec:	f9 4f       	sbci	r31, 0xF9	; 249
    67ee:	77 fa       	bst	r7, 7
    67f0:	70 94       	com	r7
    67f2:	77 f8       	bld	r7, 7
    67f4:	70 94       	com	r7
    67f6:	d6 cf       	rjmp	.-84     	; 0x67a4 <main+0x802>
    67f8:	8f 5f       	subi	r24, 0xFF	; 255
    67fa:	0a 30       	cpi	r16, 0x0A	; 10
    67fc:	08 f4       	brcc	.+2      	; 0x6800 <main+0x85e>
    67fe:	2e cd       	rjmp	.-1444   	; 0x625c <main+0x2ba>
    6800:	84 30       	cpi	r24, 0x04	; 4
    6802:	09 f4       	brne	.+2      	; 0x6806 <main+0x864>
    6804:	2b cd       	rjmp	.-1450   	; 0x625c <main+0x2ba>
    6806:	0a 50       	subi	r16, 0x0A	; 10
    6808:	bd cf       	rjmp	.-134    	; 0x6784 <main+0x7e2>
    680a:	c3 01       	movw	r24, r6
    680c:	b2 01       	movw	r22, r4
    680e:	0e 94 7e 39 	call	0x72fc	; 0x72fc <trunc>
    6812:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    6816:	01 32       	cpi	r16, 0x21	; 33
    6818:	08 f0       	brcs	.+2      	; 0x681c <main+0x87a>
    681a:	20 cd       	rjmp	.-1472   	; 0x625c <main+0x2ba>
    681c:	e0 2f       	mov	r30, r16
    681e:	f0 e0       	ldi	r31, 0x00	; 0
    6820:	ec 5e       	subi	r30, 0xEC	; 236
    6822:	fb 4c       	sbci	r31, 0xCB	; 203
    6824:	0c 94 e6 39 	jmp	0x73cc	; 0x73cc <__tablejump2__>
    6828:	35 34       	cpi	r19, 0x45	; 69
    682a:	3b 34       	cpi	r19, 0x4B	; 75
    682c:	3e 34       	cpi	r19, 0x4E	; 78
    682e:	43 34       	cpi	r20, 0x43	; 67
    6830:	46 34       	cpi	r20, 0x46	; 70
    6832:	50 34       	cpi	r21, 0x40	; 64
    6834:	58 34       	cpi	r21, 0x48	; 72
    6836:	2e 31       	cpi	r18, 0x1E	; 30
    6838:	2e 31       	cpi	r18, 0x1E	; 30
    683a:	2e 31       	cpi	r18, 0x1E	; 30
    683c:	65 34       	cpi	r22, 0x45	; 69
    683e:	68 34       	cpi	r22, 0x48	; 72
    6840:	71 34       	cpi	r23, 0x41	; 65
    6842:	7a 34       	cpi	r23, 0x4A	; 74
    6844:	2e 31       	cpi	r18, 0x1E	; 30
    6846:	2e 31       	cpi	r18, 0x1E	; 30
    6848:	2e 31       	cpi	r18, 0x1E	; 30
    684a:	2e 31       	cpi	r18, 0x1E	; 30
    684c:	2e 31       	cpi	r18, 0x1E	; 30
    684e:	2e 31       	cpi	r18, 0x1E	; 30
    6850:	86 34       	cpi	r24, 0x46	; 70
    6852:	90 34       	cpi	r25, 0x40	; 64
    6854:	9c 34       	cpi	r25, 0x4C	; 76
    6856:	a4 34       	cpi	r26, 0x44	; 68
    6858:	a7 34       	cpi	r26, 0x47	; 71
    685a:	b0 34       	cpi	r27, 0x40	; 64
    685c:	b9 34       	cpi	r27, 0x49	; 73
    685e:	bf 34       	cpi	r27, 0x4F	; 79
    6860:	2e 31       	cpi	r18, 0x1E	; 30
    6862:	2e 31       	cpi	r18, 0x1E	; 30
    6864:	c8 34       	cpi	r28, 0x48	; 72
    6866:	d3 34       	cpi	r29, 0x43	; 67
    6868:	dc 34       	cpi	r29, 0x4C	; 76
    686a:	63 30       	cpi	r22, 0x03	; 3
    686c:	08 f4       	brcc	.+2      	; 0x6870 <main+0x8ce>
    686e:	ae c0       	rjmp	.+348    	; 0x69cc <main+0xa2a>
    6870:	60 93 72 06 	sts	0x0672, r22	; 0x800672 <settings+0x30>
    6874:	9b cf       	rjmp	.-202    	; 0x67ac <main+0x80a>
    6876:	60 93 75 06 	sts	0x0675, r22	; 0x800675 <settings+0x33>
    687a:	98 cf       	rjmp	.-208    	; 0x67ac <main+0x80a>
    687c:	60 93 73 06 	sts	0x0673, r22	; 0x800673 <settings+0x31>
    6880:	0e 94 5c 06 	call	0xcb8	; 0xcb8 <st_generate_step_dir_invert_masks>
    6884:	93 cf       	rjmp	.-218    	; 0x67ac <main+0x80a>
    6886:	60 93 74 06 	sts	0x0674, r22	; 0x800674 <settings+0x32>
    688a:	fa cf       	rjmp	.-12     	; 0x6880 <main+0x8de>
    688c:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6890:	66 23       	and	r22, r22
    6892:	21 f0       	breq	.+8      	; 0x689c <main+0x8fa>
    6894:	84 60       	ori	r24, 0x04	; 4
    6896:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    689a:	88 cf       	rjmp	.-240    	; 0x67ac <main+0x80a>
    689c:	8b 7f       	andi	r24, 0xFB	; 251
    689e:	fb cf       	rjmp	.-10     	; 0x6896 <main+0x8f4>
    68a0:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68a4:	66 23       	and	r22, r22
    68a6:	11 f0       	breq	.+4      	; 0x68ac <main+0x90a>
    68a8:	80 64       	ori	r24, 0x40	; 64
    68aa:	f5 cf       	rjmp	.-22     	; 0x6896 <main+0x8f4>
    68ac:	8f 7b       	andi	r24, 0xBF	; 191
    68ae:	f3 cf       	rjmp	.-26     	; 0x6896 <main+0x8f4>
    68b0:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68b4:	66 23       	and	r22, r22
    68b6:	39 f0       	breq	.+14     	; 0x68c6 <main+0x924>
    68b8:	80 68       	ori	r24, 0x80	; 128
    68ba:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    68be:	80 e0       	ldi	r24, 0x00	; 0
    68c0:	0e 94 d8 02 	call	0x5b0	; 0x5b0 <probe_configure_invert_mask>
    68c4:	73 cf       	rjmp	.-282    	; 0x67ac <main+0x80a>
    68c6:	8f 77       	andi	r24, 0x7F	; 127
    68c8:	f8 cf       	rjmp	.-16     	; 0x68ba <main+0x918>
    68ca:	60 93 76 06 	sts	0x0676, r22	; 0x800676 <settings+0x34>
    68ce:	6e cf       	rjmp	.-292    	; 0x67ac <main+0x80a>
    68d0:	40 92 77 06 	sts	0x0677, r4	; 0x800677 <settings+0x35>
    68d4:	50 92 78 06 	sts	0x0678, r5	; 0x800678 <settings+0x36>
    68d8:	60 92 79 06 	sts	0x0679, r6	; 0x800679 <settings+0x37>
    68dc:	70 92 7a 06 	sts	0x067A, r7	; 0x80067a <settings+0x38>
    68e0:	65 cf       	rjmp	.-310    	; 0x67ac <main+0x80a>
    68e2:	40 92 7b 06 	sts	0x067B, r4	; 0x80067b <settings+0x39>
    68e6:	50 92 7c 06 	sts	0x067C, r5	; 0x80067c <settings+0x3a>
    68ea:	60 92 7d 06 	sts	0x067D, r6	; 0x80067d <settings+0x3b>
    68ee:	70 92 7e 06 	sts	0x067E, r7	; 0x80067e <settings+0x3c>
    68f2:	5c cf       	rjmp	.-328    	; 0x67ac <main+0x80a>
    68f4:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    68f8:	66 23       	and	r22, r22
    68fa:	31 f0       	breq	.+12     	; 0x6908 <main+0x966>
    68fc:	81 60       	ori	r24, 0x01	; 1
    68fe:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    6902:	0e 94 58 1d 	call	0x3ab0	; 0x3ab0 <system_flag_wco_change>
    6906:	52 cf       	rjmp	.-348    	; 0x67ac <main+0x80a>
    6908:	8e 7f       	andi	r24, 0xFE	; 254
    690a:	f9 cf       	rjmp	.-14     	; 0x68fe <main+0x95c>
    690c:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6910:	66 23       	and	r22, r22
    6912:	21 f0       	breq	.+8      	; 0x691c <main+0x97a>
    6914:	84 ff       	sbrs	r24, 4
    6916:	5c c0       	rjmp	.+184    	; 0x69d0 <main+0xa2e>
    6918:	80 62       	ori	r24, 0x20	; 32
    691a:	bd cf       	rjmp	.-134    	; 0x6896 <main+0x8f4>
    691c:	8f 7d       	andi	r24, 0xDF	; 223
    691e:	bb cf       	rjmp	.-138    	; 0x6896 <main+0x8f4>
    6920:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    6924:	66 23       	and	r22, r22
    6926:	31 f0       	breq	.+12     	; 0x6934 <main+0x992>
    6928:	88 60       	ori	r24, 0x08	; 8
    692a:	80 93 87 06 	sts	0x0687, r24	; 0x800687 <settings+0x45>
    692e:	0e 94 09 03 	call	0x612	; 0x612 <limits_init>
    6932:	3c cf       	rjmp	.-392    	; 0x67ac <main+0x80a>
    6934:	87 7f       	andi	r24, 0xF7	; 247
    6936:	f9 cf       	rjmp	.-14     	; 0x692a <main+0x988>
    6938:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    693c:	66 23       	and	r22, r22
    693e:	11 f0       	breq	.+4      	; 0x6944 <main+0x9a2>
    6940:	80 61       	ori	r24, 0x10	; 16
    6942:	a9 cf       	rjmp	.-174    	; 0x6896 <main+0x8f4>
    6944:	8f 7c       	andi	r24, 0xCF	; 207
    6946:	a7 cf       	rjmp	.-178    	; 0x6896 <main+0x8f4>
    6948:	60 93 88 06 	sts	0x0688, r22	; 0x800688 <settings+0x46>
    694c:	2f cf       	rjmp	.-418    	; 0x67ac <main+0x80a>
    694e:	40 92 89 06 	sts	0x0689, r4	; 0x800689 <settings+0x47>
    6952:	50 92 8a 06 	sts	0x068A, r5	; 0x80068a <settings+0x48>
    6956:	60 92 8b 06 	sts	0x068B, r6	; 0x80068b <settings+0x49>
    695a:	70 92 8c 06 	sts	0x068C, r7	; 0x80068c <settings+0x4a>
    695e:	26 cf       	rjmp	.-436    	; 0x67ac <main+0x80a>
    6960:	40 92 8d 06 	sts	0x068D, r4	; 0x80068d <settings+0x4b>
    6964:	50 92 8e 06 	sts	0x068E, r5	; 0x80068e <settings+0x4c>
    6968:	60 92 8f 06 	sts	0x068F, r6	; 0x80068f <settings+0x4d>
    696c:	70 92 90 06 	sts	0x0690, r7	; 0x800690 <settings+0x4e>
    6970:	1d cf       	rjmp	.-454    	; 0x67ac <main+0x80a>
    6972:	70 e0       	ldi	r23, 0x00	; 0
    6974:	70 93 92 06 	sts	0x0692, r23	; 0x800692 <settings+0x50>
    6978:	60 93 91 06 	sts	0x0691, r22	; 0x800691 <settings+0x4f>
    697c:	17 cf       	rjmp	.-466    	; 0x67ac <main+0x80a>
    697e:	40 92 93 06 	sts	0x0693, r4	; 0x800693 <settings+0x51>
    6982:	50 92 94 06 	sts	0x0694, r5	; 0x800694 <settings+0x52>
    6986:	60 92 95 06 	sts	0x0695, r6	; 0x800695 <settings+0x53>
    698a:	70 92 96 06 	sts	0x0696, r7	; 0x800696 <settings+0x54>
    698e:	0e cf       	rjmp	.-484    	; 0x67ac <main+0x80a>
    6990:	40 92 7f 06 	sts	0x067F, r4	; 0x80067f <settings+0x3d>
    6994:	50 92 80 06 	sts	0x0680, r5	; 0x800680 <settings+0x3e>
    6998:	60 92 81 06 	sts	0x0681, r6	; 0x800681 <settings+0x3f>
    699c:	70 92 82 06 	sts	0x0682, r7	; 0x800682 <settings+0x40>
    69a0:	0e 94 76 09 	call	0x12ec	; 0x12ec <spindle_init>
    69a4:	03 cf       	rjmp	.-506    	; 0x67ac <main+0x80a>
    69a6:	40 92 83 06 	sts	0x0683, r4	; 0x800683 <settings+0x41>
    69aa:	50 92 84 06 	sts	0x0684, r5	; 0x800684 <settings+0x42>
    69ae:	60 92 85 06 	sts	0x0685, r6	; 0x800685 <settings+0x43>
    69b2:	70 92 86 06 	sts	0x0686, r7	; 0x800686 <settings+0x44>
    69b6:	f4 cf       	rjmp	.-24     	; 0x69a0 <main+0x9fe>
    69b8:	80 91 87 06 	lds	r24, 0x0687	; 0x800687 <settings+0x45>
    69bc:	66 23       	and	r22, r22
    69be:	11 f0       	breq	.+4      	; 0x69c4 <main+0xa22>
    69c0:	82 60       	ori	r24, 0x02	; 2
    69c2:	69 cf       	rjmp	.-302    	; 0x6896 <main+0x8f4>
    69c4:	8d 7f       	andi	r24, 0xFD	; 253
    69c6:	67 cf       	rjmp	.-306    	; 0x6896 <main+0x8f4>
    69c8:	14 e0       	ldi	r17, 0x04	; 4
    69ca:	4d cc       	rjmp	.-1894   	; 0x6266 <main+0x2c4>
    69cc:	16 e0       	ldi	r17, 0x06	; 6
    69ce:	4b cc       	rjmp	.-1898   	; 0x6266 <main+0x2c4>
    69d0:	1a e0       	ldi	r17, 0x0A	; 10
    69d2:	49 cc       	rjmp	.-1902   	; 0x6266 <main+0x2c4>
    69d4:	80 91 31 06 	lds	r24, 0x0631	; 0x800631 <sys>
    69d8:	81 72       	andi	r24, 0x21	; 33
    69da:	31 f0       	breq	.+12     	; 0x69e8 <main+0xa46>
    69dc:	89 e0       	ldi	r24, 0x09	; 9
    69de:	0e 94 d9 07 	call	0xfb2	; 0xfb2 <report_status_message.part.0>
    69e2:	10 e0       	ldi	r17, 0x00	; 0
    69e4:	00 e0       	ldi	r16, 0x00	; 0
    69e6:	c9 cb       	rjmp	.-2158   	; 0x617a <main+0x1d8>
    69e8:	0e 94 6d 1e 	call	0x3cda	; 0x3cda <gc_execute_line.constprop.11>
    69ec:	49 c0       	rjmp	.+146    	; 0x6a80 <main+0xade>
    69ee:	00 23       	and	r16, r16
    69f0:	29 f0       	breq	.+10     	; 0x69fc <main+0xa5a>
    69f2:	89 32       	cpi	r24, 0x29	; 41
    69f4:	09 f0       	breq	.+2      	; 0x69f8 <main+0xa56>
    69f6:	c1 cb       	rjmp	.-2174   	; 0x617a <main+0x1d8>
    69f8:	0d 7f       	andi	r16, 0xFD	; 253
    69fa:	bf cb       	rjmp	.-2178   	; 0x617a <main+0x1d8>
    69fc:	81 32       	cpi	r24, 0x21	; 33
    69fe:	08 f4       	brcc	.+2      	; 0x6a02 <main+0xa60>
    6a00:	bc cb       	rjmp	.-2184   	; 0x617a <main+0x1d8>
    6a02:	8f 32       	cpi	r24, 0x2F	; 47
    6a04:	09 f4       	brne	.+2      	; 0x6a08 <main+0xa66>
    6a06:	b9 cb       	rjmp	.-2190   	; 0x617a <main+0x1d8>
    6a08:	88 32       	cpi	r24, 0x28	; 40
    6a0a:	81 f0       	breq	.+32     	; 0x6a2c <main+0xa8a>
    6a0c:	8b 33       	cpi	r24, 0x3B	; 59
    6a0e:	81 f0       	breq	.+32     	; 0x6a30 <main+0xa8e>
    6a10:	1f 34       	cpi	r17, 0x4F	; 79
    6a12:	80 f4       	brcc	.+32     	; 0x6a34 <main+0xa92>
    6a14:	e1 2f       	mov	r30, r17
    6a16:	f0 e0       	ldi	r31, 0x00	; 0
    6a18:	ef 5e       	subi	r30, 0xEF	; 239
    6a1a:	f8 4f       	sbci	r31, 0xF8	; 248
    6a1c:	1f 5f       	subi	r17, 0xFF	; 255
    6a1e:	9f e9       	ldi	r25, 0x9F	; 159
    6a20:	98 0f       	add	r25, r24
    6a22:	9a 31       	cpi	r25, 0x1A	; 26
    6a24:	08 f4       	brcc	.+2      	; 0x6a28 <main+0xa86>
    6a26:	80 52       	subi	r24, 0x20	; 32
    6a28:	80 83       	st	Z, r24
    6a2a:	a7 cb       	rjmp	.-2226   	; 0x617a <main+0x1d8>
    6a2c:	02 e0       	ldi	r16, 0x02	; 2
    6a2e:	a5 cb       	rjmp	.-2230   	; 0x617a <main+0x1d8>
    6a30:	04 e0       	ldi	r16, 0x04	; 4
    6a32:	a3 cb       	rjmp	.-2234   	; 0x617a <main+0x1d8>
    6a34:	01 e0       	ldi	r16, 0x01	; 1
    6a36:	a1 cb       	rjmp	.-2238   	; 0x617a <main+0x1d8>
    6a38:	e9 2f       	mov	r30, r25
    6a3a:	f0 e0       	ldi	r31, 0x00	; 0
    6a3c:	e1 59       	subi	r30, 0x91	; 145
    6a3e:	fe 4f       	sbci	r31, 0xFE	; 254
    6a40:	80 81       	ld	r24, Z
    6a42:	9f 5f       	subi	r25, 0xFF	; 255
    6a44:	91 38       	cpi	r25, 0x81	; 129
    6a46:	09 f4       	brne	.+2      	; 0x6a4a <main+0xaa8>
    6a48:	90 e0       	ldi	r25, 0x00	; 0
    6a4a:	90 93 f1 01 	sts	0x01F1, r25	; 0x8001f1 <serial_rx_buffer_tail>
    6a4e:	8f 3f       	cpi	r24, 0xFF	; 255
    6a50:	09 f4       	brne	.+2      	; 0x6a54 <main+0xab2>
    6a52:	99 cb       	rjmp	.-2254   	; 0x6186 <main+0x1e4>
    6a54:	8a 30       	cpi	r24, 0x0A	; 10
    6a56:	11 f0       	breq	.+4      	; 0x6a5c <main+0xaba>
    6a58:	8d 30       	cpi	r24, 0x0D	; 13
    6a5a:	49 f6       	brne	.-110    	; 0x69ee <main+0xa4c>
    6a5c:	0e 94 fa 19 	call	0x33f4	; 0x33f4 <protocol_execute_realtime>
    6a60:	80 91 32 06 	lds	r24, 0x0632	; 0x800632 <sys+0x1>
    6a64:	81 11       	cpse	r24, r1
    6a66:	17 cb       	rjmp	.-2514   	; 0x6096 <main+0xf4>
    6a68:	e1 2f       	mov	r30, r17
    6a6a:	f0 e0       	ldi	r31, 0x00	; 0
    6a6c:	ef 5e       	subi	r30, 0xEF	; 239
    6a6e:	f8 4f       	sbci	r31, 0xF8	; 248
    6a70:	10 82       	st	Z, r1
    6a72:	8b e0       	ldi	r24, 0x0B	; 11
    6a74:	00 fd       	sbrc	r16, 0
    6a76:	b3 cf       	rjmp	.-154    	; 0x69de <main+0xa3c>
    6a78:	80 91 11 07 	lds	r24, 0x0711	; 0x800711 <line>
    6a7c:	81 11       	cpse	r24, r1
    6a7e:	9d cb       	rjmp	.-2246   	; 0x61ba <main+0x218>
    6a80:	0e 94 e5 07 	call	0xfca	; 0xfca <report_status_message>
    6a84:	ae cf       	rjmp	.-164    	; 0x69e2 <main+0xa40>

00006a86 <__subsf3>:
    6a86:	50 58       	subi	r21, 0x80	; 128

00006a88 <__addsf3>:
    6a88:	bb 27       	eor	r27, r27
    6a8a:	aa 27       	eor	r26, r26
    6a8c:	0e 94 5b 35 	call	0x6ab6	; 0x6ab6 <__addsf3x>
    6a90:	0c 94 f5 37 	jmp	0x6fea	; 0x6fea <__fp_round>
    6a94:	0e 94 bc 37 	call	0x6f78	; 0x6f78 <__fp_pscA>
    6a98:	38 f0       	brcs	.+14     	; 0x6aa8 <__addsf3+0x20>
    6a9a:	0e 94 c3 37 	call	0x6f86	; 0x6f86 <__fp_pscB>
    6a9e:	20 f0       	brcs	.+8      	; 0x6aa8 <__addsf3+0x20>
    6aa0:	39 f4       	brne	.+14     	; 0x6ab0 <__addsf3+0x28>
    6aa2:	9f 3f       	cpi	r25, 0xFF	; 255
    6aa4:	19 f4       	brne	.+6      	; 0x6aac <__addsf3+0x24>
    6aa6:	26 f4       	brtc	.+8      	; 0x6ab0 <__addsf3+0x28>
    6aa8:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>
    6aac:	0e f4       	brtc	.+2      	; 0x6ab0 <__addsf3+0x28>
    6aae:	e0 95       	com	r30
    6ab0:	e7 fb       	bst	r30, 7
    6ab2:	0c 94 63 37 	jmp	0x6ec6	; 0x6ec6 <__fp_inf>

00006ab6 <__addsf3x>:
    6ab6:	e9 2f       	mov	r30, r25
    6ab8:	0e 94 1a 38 	call	0x7034	; 0x7034 <__fp_split3>
    6abc:	58 f3       	brcs	.-42     	; 0x6a94 <__addsf3+0xc>
    6abe:	ba 17       	cp	r27, r26
    6ac0:	62 07       	cpc	r22, r18
    6ac2:	73 07       	cpc	r23, r19
    6ac4:	84 07       	cpc	r24, r20
    6ac6:	95 07       	cpc	r25, r21
    6ac8:	20 f0       	brcs	.+8      	; 0x6ad2 <__addsf3x+0x1c>
    6aca:	79 f4       	brne	.+30     	; 0x6aea <__addsf3x+0x34>
    6acc:	a6 f5       	brtc	.+104    	; 0x6b36 <__addsf3x+0x80>
    6ace:	0c 94 54 38 	jmp	0x70a8	; 0x70a8 <__fp_zero>
    6ad2:	0e f4       	brtc	.+2      	; 0x6ad6 <__addsf3x+0x20>
    6ad4:	e0 95       	com	r30
    6ad6:	0b 2e       	mov	r0, r27
    6ad8:	ba 2f       	mov	r27, r26
    6ada:	a0 2d       	mov	r26, r0
    6adc:	0b 01       	movw	r0, r22
    6ade:	b9 01       	movw	r22, r18
    6ae0:	90 01       	movw	r18, r0
    6ae2:	0c 01       	movw	r0, r24
    6ae4:	ca 01       	movw	r24, r20
    6ae6:	a0 01       	movw	r20, r0
    6ae8:	11 24       	eor	r1, r1
    6aea:	ff 27       	eor	r31, r31
    6aec:	59 1b       	sub	r21, r25
    6aee:	99 f0       	breq	.+38     	; 0x6b16 <__addsf3x+0x60>
    6af0:	59 3f       	cpi	r21, 0xF9	; 249
    6af2:	50 f4       	brcc	.+20     	; 0x6b08 <__addsf3x+0x52>
    6af4:	50 3e       	cpi	r21, 0xE0	; 224
    6af6:	68 f1       	brcs	.+90     	; 0x6b52 <__addsf3x+0x9c>
    6af8:	1a 16       	cp	r1, r26
    6afa:	f0 40       	sbci	r31, 0x00	; 0
    6afc:	a2 2f       	mov	r26, r18
    6afe:	23 2f       	mov	r18, r19
    6b00:	34 2f       	mov	r19, r20
    6b02:	44 27       	eor	r20, r20
    6b04:	58 5f       	subi	r21, 0xF8	; 248
    6b06:	f3 cf       	rjmp	.-26     	; 0x6aee <__addsf3x+0x38>
    6b08:	46 95       	lsr	r20
    6b0a:	37 95       	ror	r19
    6b0c:	27 95       	ror	r18
    6b0e:	a7 95       	ror	r26
    6b10:	f0 40       	sbci	r31, 0x00	; 0
    6b12:	53 95       	inc	r21
    6b14:	c9 f7       	brne	.-14     	; 0x6b08 <__addsf3x+0x52>
    6b16:	7e f4       	brtc	.+30     	; 0x6b36 <__addsf3x+0x80>
    6b18:	1f 16       	cp	r1, r31
    6b1a:	ba 0b       	sbc	r27, r26
    6b1c:	62 0b       	sbc	r22, r18
    6b1e:	73 0b       	sbc	r23, r19
    6b20:	84 0b       	sbc	r24, r20
    6b22:	ba f0       	brmi	.+46     	; 0x6b52 <__addsf3x+0x9c>
    6b24:	91 50       	subi	r25, 0x01	; 1
    6b26:	a1 f0       	breq	.+40     	; 0x6b50 <__addsf3x+0x9a>
    6b28:	ff 0f       	add	r31, r31
    6b2a:	bb 1f       	adc	r27, r27
    6b2c:	66 1f       	adc	r22, r22
    6b2e:	77 1f       	adc	r23, r23
    6b30:	88 1f       	adc	r24, r24
    6b32:	c2 f7       	brpl	.-16     	; 0x6b24 <__addsf3x+0x6e>
    6b34:	0e c0       	rjmp	.+28     	; 0x6b52 <__addsf3x+0x9c>
    6b36:	ba 0f       	add	r27, r26
    6b38:	62 1f       	adc	r22, r18
    6b3a:	73 1f       	adc	r23, r19
    6b3c:	84 1f       	adc	r24, r20
    6b3e:	48 f4       	brcc	.+18     	; 0x6b52 <__addsf3x+0x9c>
    6b40:	87 95       	ror	r24
    6b42:	77 95       	ror	r23
    6b44:	67 95       	ror	r22
    6b46:	b7 95       	ror	r27
    6b48:	f7 95       	ror	r31
    6b4a:	9e 3f       	cpi	r25, 0xFE	; 254
    6b4c:	08 f0       	brcs	.+2      	; 0x6b50 <__addsf3x+0x9a>
    6b4e:	b0 cf       	rjmp	.-160    	; 0x6ab0 <__addsf3+0x28>
    6b50:	93 95       	inc	r25
    6b52:	88 0f       	add	r24, r24
    6b54:	08 f0       	brcs	.+2      	; 0x6b58 <__addsf3x+0xa2>
    6b56:	99 27       	eor	r25, r25
    6b58:	ee 0f       	add	r30, r30
    6b5a:	97 95       	ror	r25
    6b5c:	87 95       	ror	r24
    6b5e:	08 95       	ret
    6b60:	0e 94 bc 37 	call	0x6f78	; 0x6f78 <__fp_pscA>
    6b64:	60 f0       	brcs	.+24     	; 0x6b7e <__addsf3x+0xc8>
    6b66:	80 e8       	ldi	r24, 0x80	; 128
    6b68:	91 e0       	ldi	r25, 0x01	; 1
    6b6a:	09 f4       	brne	.+2      	; 0x6b6e <__addsf3x+0xb8>
    6b6c:	9e ef       	ldi	r25, 0xFE	; 254
    6b6e:	0e 94 c3 37 	call	0x6f86	; 0x6f86 <__fp_pscB>
    6b72:	28 f0       	brcs	.+10     	; 0x6b7e <__addsf3x+0xc8>
    6b74:	40 e8       	ldi	r20, 0x80	; 128
    6b76:	51 e0       	ldi	r21, 0x01	; 1
    6b78:	71 f4       	brne	.+28     	; 0x6b96 <atan2+0x10>
    6b7a:	5e ef       	ldi	r21, 0xFE	; 254
    6b7c:	0c c0       	rjmp	.+24     	; 0x6b96 <atan2+0x10>
    6b7e:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>
    6b82:	0c 94 54 38 	jmp	0x70a8	; 0x70a8 <__fp_zero>

00006b86 <atan2>:
    6b86:	e9 2f       	mov	r30, r25
    6b88:	e0 78       	andi	r30, 0x80	; 128
    6b8a:	0e 94 1a 38 	call	0x7034	; 0x7034 <__fp_split3>
    6b8e:	40 f3       	brcs	.-48     	; 0x6b60 <__addsf3x+0xaa>
    6b90:	09 2e       	mov	r0, r25
    6b92:	05 2a       	or	r0, r21
    6b94:	b1 f3       	breq	.-20     	; 0x6b82 <__addsf3x+0xcc>
    6b96:	26 17       	cp	r18, r22
    6b98:	37 07       	cpc	r19, r23
    6b9a:	48 07       	cpc	r20, r24
    6b9c:	59 07       	cpc	r21, r25
    6b9e:	38 f0       	brcs	.+14     	; 0x6bae <atan2+0x28>
    6ba0:	0e 2e       	mov	r0, r30
    6ba2:	07 f8       	bld	r0, 7
    6ba4:	e0 25       	eor	r30, r0
    6ba6:	69 f0       	breq	.+26     	; 0x6bc2 <atan2+0x3c>
    6ba8:	e0 25       	eor	r30, r0
    6baa:	e0 64       	ori	r30, 0x40	; 64
    6bac:	0a c0       	rjmp	.+20     	; 0x6bc2 <atan2+0x3c>
    6bae:	ef 63       	ori	r30, 0x3F	; 63
    6bb0:	07 f8       	bld	r0, 7
    6bb2:	00 94       	com	r0
    6bb4:	07 fa       	bst	r0, 7
    6bb6:	db 01       	movw	r26, r22
    6bb8:	b9 01       	movw	r22, r18
    6bba:	9d 01       	movw	r18, r26
    6bbc:	dc 01       	movw	r26, r24
    6bbe:	ca 01       	movw	r24, r20
    6bc0:	ad 01       	movw	r20, r26
    6bc2:	ef 93       	push	r30
    6bc4:	0e 94 5a 36 	call	0x6cb4	; 0x6cb4 <__divsf3_pse>
    6bc8:	0e 94 f5 37 	call	0x6fea	; 0x6fea <__fp_round>
    6bcc:	0e 94 f3 35 	call	0x6be6	; 0x6be6 <atan>
    6bd0:	5f 91       	pop	r21
    6bd2:	55 23       	and	r21, r21
    6bd4:	39 f0       	breq	.+14     	; 0x6be4 <atan2+0x5e>
    6bd6:	2b ed       	ldi	r18, 0xDB	; 219
    6bd8:	3f e0       	ldi	r19, 0x0F	; 15
    6bda:	49 e4       	ldi	r20, 0x49	; 73
    6bdc:	50 fd       	sbrc	r21, 0
    6bde:	49 ec       	ldi	r20, 0xC9	; 201
    6be0:	0c 94 44 35 	jmp	0x6a88	; 0x6a88 <__addsf3>
    6be4:	08 95       	ret

00006be6 <atan>:
    6be6:	df 93       	push	r29
    6be8:	dd 27       	eor	r29, r29
    6bea:	b9 2f       	mov	r27, r25
    6bec:	bf 77       	andi	r27, 0x7F	; 127
    6bee:	40 e8       	ldi	r20, 0x80	; 128
    6bf0:	5f e3       	ldi	r21, 0x3F	; 63
    6bf2:	16 16       	cp	r1, r22
    6bf4:	17 06       	cpc	r1, r23
    6bf6:	48 07       	cpc	r20, r24
    6bf8:	5b 07       	cpc	r21, r27
    6bfa:	18 f4       	brcc	.+6      	; 0x6c02 <atan+0x1c>
    6bfc:	d9 2f       	mov	r29, r25
    6bfe:	0e 94 60 38 	call	0x70c0	; 0x70c0 <inverse>
    6c02:	9f 93       	push	r25
    6c04:	8f 93       	push	r24
    6c06:	7f 93       	push	r23
    6c08:	6f 93       	push	r22
    6c0a:	0e 94 7a 39 	call	0x72f4	; 0x72f4 <square>
    6c0e:	e8 e6       	ldi	r30, 0x68	; 104
    6c10:	f0 e0       	ldi	r31, 0x00	; 0
    6c12:	0e 94 95 37 	call	0x6f2a	; 0x6f2a <__fp_powser>
    6c16:	0e 94 f5 37 	call	0x6fea	; 0x6fea <__fp_round>
    6c1a:	2f 91       	pop	r18
    6c1c:	3f 91       	pop	r19
    6c1e:	4f 91       	pop	r20
    6c20:	5f 91       	pop	r21
    6c22:	0e 94 ae 38 	call	0x715c	; 0x715c <__mulsf3x>
    6c26:	dd 23       	and	r29, r29
    6c28:	51 f0       	breq	.+20     	; 0x6c3e <atan+0x58>
    6c2a:	90 58       	subi	r25, 0x80	; 128
    6c2c:	a2 ea       	ldi	r26, 0xA2	; 162
    6c2e:	2a ed       	ldi	r18, 0xDA	; 218
    6c30:	3f e0       	ldi	r19, 0x0F	; 15
    6c32:	49 ec       	ldi	r20, 0xC9	; 201
    6c34:	5f e3       	ldi	r21, 0x3F	; 63
    6c36:	d0 78       	andi	r29, 0x80	; 128
    6c38:	5d 27       	eor	r21, r29
    6c3a:	0e 94 5b 35 	call	0x6ab6	; 0x6ab6 <__addsf3x>
    6c3e:	df 91       	pop	r29
    6c40:	0c 94 f5 37 	jmp	0x6fea	; 0x6fea <__fp_round>

00006c44 <ceil>:
    6c44:	0e 94 3c 38 	call	0x7078	; 0x7078 <__fp_trunc>
    6c48:	90 f0       	brcs	.+36     	; 0x6c6e <ceil+0x2a>
    6c4a:	9f 37       	cpi	r25, 0x7F	; 127
    6c4c:	48 f4       	brcc	.+18     	; 0x6c60 <ceil+0x1c>
    6c4e:	91 11       	cpse	r25, r1
    6c50:	16 f4       	brtc	.+4      	; 0x6c56 <ceil+0x12>
    6c52:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    6c56:	60 e0       	ldi	r22, 0x00	; 0
    6c58:	70 e0       	ldi	r23, 0x00	; 0
    6c5a:	80 e8       	ldi	r24, 0x80	; 128
    6c5c:	9f e3       	ldi	r25, 0x3F	; 63
    6c5e:	08 95       	ret
    6c60:	26 f0       	brts	.+8      	; 0x6c6a <ceil+0x26>
    6c62:	1b 16       	cp	r1, r27
    6c64:	61 1d       	adc	r22, r1
    6c66:	71 1d       	adc	r23, r1
    6c68:	81 1d       	adc	r24, r1
    6c6a:	0c 94 69 37 	jmp	0x6ed2	; 0x6ed2 <__fp_mintl>
    6c6e:	0c 94 84 37 	jmp	0x6f08	; 0x6f08 <__fp_mpack>

00006c72 <__cmpsf2>:
    6c72:	0e 94 3f 37 	call	0x6e7e	; 0x6e7e <__fp_cmp>
    6c76:	08 f4       	brcc	.+2      	; 0x6c7a <__cmpsf2+0x8>
    6c78:	81 e0       	ldi	r24, 0x01	; 1
    6c7a:	08 95       	ret

00006c7c <cos>:
    6c7c:	0e 94 cc 37 	call	0x6f98	; 0x6f98 <__fp_rempio2>
    6c80:	e3 95       	inc	r30
    6c82:	0c 94 06 38 	jmp	0x700c	; 0x700c <__fp_sinus>

00006c86 <__divsf3>:
    6c86:	0e 94 57 36 	call	0x6cae	; 0x6cae <__divsf3x>
    6c8a:	0c 94 f5 37 	jmp	0x6fea	; 0x6fea <__fp_round>
    6c8e:	0e 94 c3 37 	call	0x6f86	; 0x6f86 <__fp_pscB>
    6c92:	58 f0       	brcs	.+22     	; 0x6caa <__divsf3+0x24>
    6c94:	0e 94 bc 37 	call	0x6f78	; 0x6f78 <__fp_pscA>
    6c98:	40 f0       	brcs	.+16     	; 0x6caa <__divsf3+0x24>
    6c9a:	29 f4       	brne	.+10     	; 0x6ca6 <__divsf3+0x20>
    6c9c:	5f 3f       	cpi	r21, 0xFF	; 255
    6c9e:	29 f0       	breq	.+10     	; 0x6caa <__divsf3+0x24>
    6ca0:	0c 94 63 37 	jmp	0x6ec6	; 0x6ec6 <__fp_inf>
    6ca4:	51 11       	cpse	r21, r1
    6ca6:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    6caa:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>

00006cae <__divsf3x>:
    6cae:	0e 94 1a 38 	call	0x7034	; 0x7034 <__fp_split3>
    6cb2:	68 f3       	brcs	.-38     	; 0x6c8e <__divsf3+0x8>

00006cb4 <__divsf3_pse>:
    6cb4:	99 23       	and	r25, r25
    6cb6:	b1 f3       	breq	.-20     	; 0x6ca4 <__divsf3+0x1e>
    6cb8:	55 23       	and	r21, r21
    6cba:	91 f3       	breq	.-28     	; 0x6ca0 <__divsf3+0x1a>
    6cbc:	95 1b       	sub	r25, r21
    6cbe:	55 0b       	sbc	r21, r21
    6cc0:	bb 27       	eor	r27, r27
    6cc2:	aa 27       	eor	r26, r26
    6cc4:	62 17       	cp	r22, r18
    6cc6:	73 07       	cpc	r23, r19
    6cc8:	84 07       	cpc	r24, r20
    6cca:	38 f0       	brcs	.+14     	; 0x6cda <__divsf3_pse+0x26>
    6ccc:	9f 5f       	subi	r25, 0xFF	; 255
    6cce:	5f 4f       	sbci	r21, 0xFF	; 255
    6cd0:	22 0f       	add	r18, r18
    6cd2:	33 1f       	adc	r19, r19
    6cd4:	44 1f       	adc	r20, r20
    6cd6:	aa 1f       	adc	r26, r26
    6cd8:	a9 f3       	breq	.-22     	; 0x6cc4 <__divsf3_pse+0x10>
    6cda:	35 d0       	rcall	.+106    	; 0x6d46 <__divsf3_pse+0x92>
    6cdc:	0e 2e       	mov	r0, r30
    6cde:	3a f0       	brmi	.+14     	; 0x6cee <__divsf3_pse+0x3a>
    6ce0:	e0 e8       	ldi	r30, 0x80	; 128
    6ce2:	32 d0       	rcall	.+100    	; 0x6d48 <__divsf3_pse+0x94>
    6ce4:	91 50       	subi	r25, 0x01	; 1
    6ce6:	50 40       	sbci	r21, 0x00	; 0
    6ce8:	e6 95       	lsr	r30
    6cea:	00 1c       	adc	r0, r0
    6cec:	ca f7       	brpl	.-14     	; 0x6ce0 <__divsf3_pse+0x2c>
    6cee:	2b d0       	rcall	.+86     	; 0x6d46 <__divsf3_pse+0x92>
    6cf0:	fe 2f       	mov	r31, r30
    6cf2:	29 d0       	rcall	.+82     	; 0x6d46 <__divsf3_pse+0x92>
    6cf4:	66 0f       	add	r22, r22
    6cf6:	77 1f       	adc	r23, r23
    6cf8:	88 1f       	adc	r24, r24
    6cfa:	bb 1f       	adc	r27, r27
    6cfc:	26 17       	cp	r18, r22
    6cfe:	37 07       	cpc	r19, r23
    6d00:	48 07       	cpc	r20, r24
    6d02:	ab 07       	cpc	r26, r27
    6d04:	b0 e8       	ldi	r27, 0x80	; 128
    6d06:	09 f0       	breq	.+2      	; 0x6d0a <__divsf3_pse+0x56>
    6d08:	bb 0b       	sbc	r27, r27
    6d0a:	80 2d       	mov	r24, r0
    6d0c:	bf 01       	movw	r22, r30
    6d0e:	ff 27       	eor	r31, r31
    6d10:	93 58       	subi	r25, 0x83	; 131
    6d12:	5f 4f       	sbci	r21, 0xFF	; 255
    6d14:	3a f0       	brmi	.+14     	; 0x6d24 <__divsf3_pse+0x70>
    6d16:	9e 3f       	cpi	r25, 0xFE	; 254
    6d18:	51 05       	cpc	r21, r1
    6d1a:	78 f0       	brcs	.+30     	; 0x6d3a <__divsf3_pse+0x86>
    6d1c:	0c 94 63 37 	jmp	0x6ec6	; 0x6ec6 <__fp_inf>
    6d20:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    6d24:	5f 3f       	cpi	r21, 0xFF	; 255
    6d26:	e4 f3       	brlt	.-8      	; 0x6d20 <__divsf3_pse+0x6c>
    6d28:	98 3e       	cpi	r25, 0xE8	; 232
    6d2a:	d4 f3       	brlt	.-12     	; 0x6d20 <__divsf3_pse+0x6c>
    6d2c:	86 95       	lsr	r24
    6d2e:	77 95       	ror	r23
    6d30:	67 95       	ror	r22
    6d32:	b7 95       	ror	r27
    6d34:	f7 95       	ror	r31
    6d36:	9f 5f       	subi	r25, 0xFF	; 255
    6d38:	c9 f7       	brne	.-14     	; 0x6d2c <__divsf3_pse+0x78>
    6d3a:	88 0f       	add	r24, r24
    6d3c:	91 1d       	adc	r25, r1
    6d3e:	96 95       	lsr	r25
    6d40:	87 95       	ror	r24
    6d42:	97 f9       	bld	r25, 7
    6d44:	08 95       	ret
    6d46:	e1 e0       	ldi	r30, 0x01	; 1
    6d48:	66 0f       	add	r22, r22
    6d4a:	77 1f       	adc	r23, r23
    6d4c:	88 1f       	adc	r24, r24
    6d4e:	bb 1f       	adc	r27, r27
    6d50:	62 17       	cp	r22, r18
    6d52:	73 07       	cpc	r23, r19
    6d54:	84 07       	cpc	r24, r20
    6d56:	ba 07       	cpc	r27, r26
    6d58:	20 f0       	brcs	.+8      	; 0x6d62 <__divsf3_pse+0xae>
    6d5a:	62 1b       	sub	r22, r18
    6d5c:	73 0b       	sbc	r23, r19
    6d5e:	84 0b       	sbc	r24, r20
    6d60:	ba 0b       	sbc	r27, r26
    6d62:	ee 1f       	adc	r30, r30
    6d64:	88 f7       	brcc	.-30     	; 0x6d48 <__divsf3_pse+0x94>
    6d66:	e0 95       	com	r30
    6d68:	08 95       	ret

00006d6a <__fixsfsi>:
    6d6a:	0e 94 bc 36 	call	0x6d78	; 0x6d78 <__fixunssfsi>
    6d6e:	68 94       	set
    6d70:	b1 11       	cpse	r27, r1
    6d72:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    6d76:	08 95       	ret

00006d78 <__fixunssfsi>:
    6d78:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    6d7c:	88 f0       	brcs	.+34     	; 0x6da0 <__fixunssfsi+0x28>
    6d7e:	9f 57       	subi	r25, 0x7F	; 127
    6d80:	98 f0       	brcs	.+38     	; 0x6da8 <__fixunssfsi+0x30>
    6d82:	b9 2f       	mov	r27, r25
    6d84:	99 27       	eor	r25, r25
    6d86:	b7 51       	subi	r27, 0x17	; 23
    6d88:	b0 f0       	brcs	.+44     	; 0x6db6 <__fixunssfsi+0x3e>
    6d8a:	e1 f0       	breq	.+56     	; 0x6dc4 <__fixunssfsi+0x4c>
    6d8c:	66 0f       	add	r22, r22
    6d8e:	77 1f       	adc	r23, r23
    6d90:	88 1f       	adc	r24, r24
    6d92:	99 1f       	adc	r25, r25
    6d94:	1a f0       	brmi	.+6      	; 0x6d9c <__fixunssfsi+0x24>
    6d96:	ba 95       	dec	r27
    6d98:	c9 f7       	brne	.-14     	; 0x6d8c <__fixunssfsi+0x14>
    6d9a:	14 c0       	rjmp	.+40     	; 0x6dc4 <__fixunssfsi+0x4c>
    6d9c:	b1 30       	cpi	r27, 0x01	; 1
    6d9e:	91 f0       	breq	.+36     	; 0x6dc4 <__fixunssfsi+0x4c>
    6da0:	0e 94 54 38 	call	0x70a8	; 0x70a8 <__fp_zero>
    6da4:	b1 e0       	ldi	r27, 0x01	; 1
    6da6:	08 95       	ret
    6da8:	0c 94 54 38 	jmp	0x70a8	; 0x70a8 <__fp_zero>
    6dac:	67 2f       	mov	r22, r23
    6dae:	78 2f       	mov	r23, r24
    6db0:	88 27       	eor	r24, r24
    6db2:	b8 5f       	subi	r27, 0xF8	; 248
    6db4:	39 f0       	breq	.+14     	; 0x6dc4 <__fixunssfsi+0x4c>
    6db6:	b9 3f       	cpi	r27, 0xF9	; 249
    6db8:	cc f3       	brlt	.-14     	; 0x6dac <__fixunssfsi+0x34>
    6dba:	86 95       	lsr	r24
    6dbc:	77 95       	ror	r23
    6dbe:	67 95       	ror	r22
    6dc0:	b3 95       	inc	r27
    6dc2:	d9 f7       	brne	.-10     	; 0x6dba <__fixunssfsi+0x42>
    6dc4:	3e f4       	brtc	.+14     	; 0x6dd4 <__fixunssfsi+0x5c>
    6dc6:	90 95       	com	r25
    6dc8:	80 95       	com	r24
    6dca:	70 95       	com	r23
    6dcc:	61 95       	neg	r22
    6dce:	7f 4f       	sbci	r23, 0xFF	; 255
    6dd0:	8f 4f       	sbci	r24, 0xFF	; 255
    6dd2:	9f 4f       	sbci	r25, 0xFF	; 255
    6dd4:	08 95       	ret

00006dd6 <__floatunsisf>:
    6dd6:	e8 94       	clt
    6dd8:	09 c0       	rjmp	.+18     	; 0x6dec <__floatsisf+0x12>

00006dda <__floatsisf>:
    6dda:	97 fb       	bst	r25, 7
    6ddc:	3e f4       	brtc	.+14     	; 0x6dec <__floatsisf+0x12>
    6dde:	90 95       	com	r25
    6de0:	80 95       	com	r24
    6de2:	70 95       	com	r23
    6de4:	61 95       	neg	r22
    6de6:	7f 4f       	sbci	r23, 0xFF	; 255
    6de8:	8f 4f       	sbci	r24, 0xFF	; 255
    6dea:	9f 4f       	sbci	r25, 0xFF	; 255
    6dec:	99 23       	and	r25, r25
    6dee:	a9 f0       	breq	.+42     	; 0x6e1a <__floatsisf+0x40>
    6df0:	f9 2f       	mov	r31, r25
    6df2:	96 e9       	ldi	r25, 0x96	; 150
    6df4:	bb 27       	eor	r27, r27
    6df6:	93 95       	inc	r25
    6df8:	f6 95       	lsr	r31
    6dfa:	87 95       	ror	r24
    6dfc:	77 95       	ror	r23
    6dfe:	67 95       	ror	r22
    6e00:	b7 95       	ror	r27
    6e02:	f1 11       	cpse	r31, r1
    6e04:	f8 cf       	rjmp	.-16     	; 0x6df6 <__floatsisf+0x1c>
    6e06:	fa f4       	brpl	.+62     	; 0x6e46 <__floatsisf+0x6c>
    6e08:	bb 0f       	add	r27, r27
    6e0a:	11 f4       	brne	.+4      	; 0x6e10 <__floatsisf+0x36>
    6e0c:	60 ff       	sbrs	r22, 0
    6e0e:	1b c0       	rjmp	.+54     	; 0x6e46 <__floatsisf+0x6c>
    6e10:	6f 5f       	subi	r22, 0xFF	; 255
    6e12:	7f 4f       	sbci	r23, 0xFF	; 255
    6e14:	8f 4f       	sbci	r24, 0xFF	; 255
    6e16:	9f 4f       	sbci	r25, 0xFF	; 255
    6e18:	16 c0       	rjmp	.+44     	; 0x6e46 <__floatsisf+0x6c>
    6e1a:	88 23       	and	r24, r24
    6e1c:	11 f0       	breq	.+4      	; 0x6e22 <__floatsisf+0x48>
    6e1e:	96 e9       	ldi	r25, 0x96	; 150
    6e20:	11 c0       	rjmp	.+34     	; 0x6e44 <__floatsisf+0x6a>
    6e22:	77 23       	and	r23, r23
    6e24:	21 f0       	breq	.+8      	; 0x6e2e <__floatsisf+0x54>
    6e26:	9e e8       	ldi	r25, 0x8E	; 142
    6e28:	87 2f       	mov	r24, r23
    6e2a:	76 2f       	mov	r23, r22
    6e2c:	05 c0       	rjmp	.+10     	; 0x6e38 <__floatsisf+0x5e>
    6e2e:	66 23       	and	r22, r22
    6e30:	71 f0       	breq	.+28     	; 0x6e4e <__floatsisf+0x74>
    6e32:	96 e8       	ldi	r25, 0x86	; 134
    6e34:	86 2f       	mov	r24, r22
    6e36:	70 e0       	ldi	r23, 0x00	; 0
    6e38:	60 e0       	ldi	r22, 0x00	; 0
    6e3a:	2a f0       	brmi	.+10     	; 0x6e46 <__floatsisf+0x6c>
    6e3c:	9a 95       	dec	r25
    6e3e:	66 0f       	add	r22, r22
    6e40:	77 1f       	adc	r23, r23
    6e42:	88 1f       	adc	r24, r24
    6e44:	da f7       	brpl	.-10     	; 0x6e3c <__floatsisf+0x62>
    6e46:	88 0f       	add	r24, r24
    6e48:	96 95       	lsr	r25
    6e4a:	87 95       	ror	r24
    6e4c:	97 f9       	bld	r25, 7
    6e4e:	08 95       	ret

00006e50 <floor>:
    6e50:	0e 94 3c 38 	call	0x7078	; 0x7078 <__fp_trunc>
    6e54:	90 f0       	brcs	.+36     	; 0x6e7a <floor+0x2a>
    6e56:	9f 37       	cpi	r25, 0x7F	; 127
    6e58:	48 f4       	brcc	.+18     	; 0x6e6c <floor+0x1c>
    6e5a:	91 11       	cpse	r25, r1
    6e5c:	16 f0       	brts	.+4      	; 0x6e62 <floor+0x12>
    6e5e:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    6e62:	60 e0       	ldi	r22, 0x00	; 0
    6e64:	70 e0       	ldi	r23, 0x00	; 0
    6e66:	80 e8       	ldi	r24, 0x80	; 128
    6e68:	9f eb       	ldi	r25, 0xBF	; 191
    6e6a:	08 95       	ret
    6e6c:	26 f4       	brtc	.+8      	; 0x6e76 <floor+0x26>
    6e6e:	1b 16       	cp	r1, r27
    6e70:	61 1d       	adc	r22, r1
    6e72:	71 1d       	adc	r23, r1
    6e74:	81 1d       	adc	r24, r1
    6e76:	0c 94 69 37 	jmp	0x6ed2	; 0x6ed2 <__fp_mintl>
    6e7a:	0c 94 84 37 	jmp	0x6f08	; 0x6f08 <__fp_mpack>

00006e7e <__fp_cmp>:
    6e7e:	99 0f       	add	r25, r25
    6e80:	00 08       	sbc	r0, r0
    6e82:	55 0f       	add	r21, r21
    6e84:	aa 0b       	sbc	r26, r26
    6e86:	e0 e8       	ldi	r30, 0x80	; 128
    6e88:	fe ef       	ldi	r31, 0xFE	; 254
    6e8a:	16 16       	cp	r1, r22
    6e8c:	17 06       	cpc	r1, r23
    6e8e:	e8 07       	cpc	r30, r24
    6e90:	f9 07       	cpc	r31, r25
    6e92:	c0 f0       	brcs	.+48     	; 0x6ec4 <__fp_cmp+0x46>
    6e94:	12 16       	cp	r1, r18
    6e96:	13 06       	cpc	r1, r19
    6e98:	e4 07       	cpc	r30, r20
    6e9a:	f5 07       	cpc	r31, r21
    6e9c:	98 f0       	brcs	.+38     	; 0x6ec4 <__fp_cmp+0x46>
    6e9e:	62 1b       	sub	r22, r18
    6ea0:	73 0b       	sbc	r23, r19
    6ea2:	84 0b       	sbc	r24, r20
    6ea4:	95 0b       	sbc	r25, r21
    6ea6:	39 f4       	brne	.+14     	; 0x6eb6 <__fp_cmp+0x38>
    6ea8:	0a 26       	eor	r0, r26
    6eaa:	61 f0       	breq	.+24     	; 0x6ec4 <__fp_cmp+0x46>
    6eac:	23 2b       	or	r18, r19
    6eae:	24 2b       	or	r18, r20
    6eb0:	25 2b       	or	r18, r21
    6eb2:	21 f4       	brne	.+8      	; 0x6ebc <__fp_cmp+0x3e>
    6eb4:	08 95       	ret
    6eb6:	0a 26       	eor	r0, r26
    6eb8:	09 f4       	brne	.+2      	; 0x6ebc <__fp_cmp+0x3e>
    6eba:	a1 40       	sbci	r26, 0x01	; 1
    6ebc:	a6 95       	lsr	r26
    6ebe:	8f ef       	ldi	r24, 0xFF	; 255
    6ec0:	81 1d       	adc	r24, r1
    6ec2:	81 1d       	adc	r24, r1
    6ec4:	08 95       	ret

00006ec6 <__fp_inf>:
    6ec6:	97 f9       	bld	r25, 7
    6ec8:	9f 67       	ori	r25, 0x7F	; 127
    6eca:	80 e8       	ldi	r24, 0x80	; 128
    6ecc:	70 e0       	ldi	r23, 0x00	; 0
    6ece:	60 e0       	ldi	r22, 0x00	; 0
    6ed0:	08 95       	ret

00006ed2 <__fp_mintl>:
    6ed2:	88 23       	and	r24, r24
    6ed4:	71 f4       	brne	.+28     	; 0x6ef2 <__fp_mintl+0x20>
    6ed6:	77 23       	and	r23, r23
    6ed8:	21 f0       	breq	.+8      	; 0x6ee2 <__fp_mintl+0x10>
    6eda:	98 50       	subi	r25, 0x08	; 8
    6edc:	87 2b       	or	r24, r23
    6ede:	76 2f       	mov	r23, r22
    6ee0:	07 c0       	rjmp	.+14     	; 0x6ef0 <__fp_mintl+0x1e>
    6ee2:	66 23       	and	r22, r22
    6ee4:	11 f4       	brne	.+4      	; 0x6eea <__fp_mintl+0x18>
    6ee6:	99 27       	eor	r25, r25
    6ee8:	0d c0       	rjmp	.+26     	; 0x6f04 <__fp_mintl+0x32>
    6eea:	90 51       	subi	r25, 0x10	; 16
    6eec:	86 2b       	or	r24, r22
    6eee:	70 e0       	ldi	r23, 0x00	; 0
    6ef0:	60 e0       	ldi	r22, 0x00	; 0
    6ef2:	2a f0       	brmi	.+10     	; 0x6efe <__fp_mintl+0x2c>
    6ef4:	9a 95       	dec	r25
    6ef6:	66 0f       	add	r22, r22
    6ef8:	77 1f       	adc	r23, r23
    6efa:	88 1f       	adc	r24, r24
    6efc:	da f7       	brpl	.-10     	; 0x6ef4 <__fp_mintl+0x22>
    6efe:	88 0f       	add	r24, r24
    6f00:	96 95       	lsr	r25
    6f02:	87 95       	ror	r24
    6f04:	97 f9       	bld	r25, 7
    6f06:	08 95       	ret

00006f08 <__fp_mpack>:
    6f08:	9f 3f       	cpi	r25, 0xFF	; 255
    6f0a:	31 f0       	breq	.+12     	; 0x6f18 <__fp_mpack_finite+0xc>

00006f0c <__fp_mpack_finite>:
    6f0c:	91 50       	subi	r25, 0x01	; 1
    6f0e:	20 f4       	brcc	.+8      	; 0x6f18 <__fp_mpack_finite+0xc>
    6f10:	87 95       	ror	r24
    6f12:	77 95       	ror	r23
    6f14:	67 95       	ror	r22
    6f16:	b7 95       	ror	r27
    6f18:	88 0f       	add	r24, r24
    6f1a:	91 1d       	adc	r25, r1
    6f1c:	96 95       	lsr	r25
    6f1e:	87 95       	ror	r24
    6f20:	97 f9       	bld	r25, 7
    6f22:	08 95       	ret

00006f24 <__fp_nan>:
    6f24:	9f ef       	ldi	r25, 0xFF	; 255
    6f26:	80 ec       	ldi	r24, 0xC0	; 192
    6f28:	08 95       	ret

00006f2a <__fp_powser>:
    6f2a:	df 93       	push	r29
    6f2c:	cf 93       	push	r28
    6f2e:	1f 93       	push	r17
    6f30:	0f 93       	push	r16
    6f32:	ff 92       	push	r15
    6f34:	ef 92       	push	r14
    6f36:	df 92       	push	r13
    6f38:	7b 01       	movw	r14, r22
    6f3a:	8c 01       	movw	r16, r24
    6f3c:	68 94       	set
    6f3e:	06 c0       	rjmp	.+12     	; 0x6f4c <__fp_powser+0x22>
    6f40:	da 2e       	mov	r13, r26
    6f42:	ef 01       	movw	r28, r30
    6f44:	0e 94 ae 38 	call	0x715c	; 0x715c <__mulsf3x>
    6f48:	fe 01       	movw	r30, r28
    6f4a:	e8 94       	clt
    6f4c:	a5 91       	lpm	r26, Z+
    6f4e:	25 91       	lpm	r18, Z+
    6f50:	35 91       	lpm	r19, Z+
    6f52:	45 91       	lpm	r20, Z+
    6f54:	55 91       	lpm	r21, Z+
    6f56:	a6 f3       	brts	.-24     	; 0x6f40 <__fp_powser+0x16>
    6f58:	ef 01       	movw	r28, r30
    6f5a:	0e 94 5b 35 	call	0x6ab6	; 0x6ab6 <__addsf3x>
    6f5e:	fe 01       	movw	r30, r28
    6f60:	97 01       	movw	r18, r14
    6f62:	a8 01       	movw	r20, r16
    6f64:	da 94       	dec	r13
    6f66:	69 f7       	brne	.-38     	; 0x6f42 <__fp_powser+0x18>
    6f68:	df 90       	pop	r13
    6f6a:	ef 90       	pop	r14
    6f6c:	ff 90       	pop	r15
    6f6e:	0f 91       	pop	r16
    6f70:	1f 91       	pop	r17
    6f72:	cf 91       	pop	r28
    6f74:	df 91       	pop	r29
    6f76:	08 95       	ret

00006f78 <__fp_pscA>:
    6f78:	00 24       	eor	r0, r0
    6f7a:	0a 94       	dec	r0
    6f7c:	16 16       	cp	r1, r22
    6f7e:	17 06       	cpc	r1, r23
    6f80:	18 06       	cpc	r1, r24
    6f82:	09 06       	cpc	r0, r25
    6f84:	08 95       	ret

00006f86 <__fp_pscB>:
    6f86:	00 24       	eor	r0, r0
    6f88:	0a 94       	dec	r0
    6f8a:	12 16       	cp	r1, r18
    6f8c:	13 06       	cpc	r1, r19
    6f8e:	14 06       	cpc	r1, r20
    6f90:	05 06       	cpc	r0, r21
    6f92:	08 95       	ret
    6f94:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>

00006f98 <__fp_rempio2>:
    6f98:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    6f9c:	d8 f3       	brcs	.-10     	; 0x6f94 <__fp_pscB+0xe>
    6f9e:	e8 94       	clt
    6fa0:	e0 e0       	ldi	r30, 0x00	; 0
    6fa2:	bb 27       	eor	r27, r27
    6fa4:	9f 57       	subi	r25, 0x7F	; 127
    6fa6:	f0 f0       	brcs	.+60     	; 0x6fe4 <__fp_rempio2+0x4c>
    6fa8:	2a ed       	ldi	r18, 0xDA	; 218
    6faa:	3f e0       	ldi	r19, 0x0F	; 15
    6fac:	49 ec       	ldi	r20, 0xC9	; 201
    6fae:	06 c0       	rjmp	.+12     	; 0x6fbc <__fp_rempio2+0x24>
    6fb0:	ee 0f       	add	r30, r30
    6fb2:	bb 0f       	add	r27, r27
    6fb4:	66 1f       	adc	r22, r22
    6fb6:	77 1f       	adc	r23, r23
    6fb8:	88 1f       	adc	r24, r24
    6fba:	28 f0       	brcs	.+10     	; 0x6fc6 <__fp_rempio2+0x2e>
    6fbc:	b2 3a       	cpi	r27, 0xA2	; 162
    6fbe:	62 07       	cpc	r22, r18
    6fc0:	73 07       	cpc	r23, r19
    6fc2:	84 07       	cpc	r24, r20
    6fc4:	28 f0       	brcs	.+10     	; 0x6fd0 <__fp_rempio2+0x38>
    6fc6:	b2 5a       	subi	r27, 0xA2	; 162
    6fc8:	62 0b       	sbc	r22, r18
    6fca:	73 0b       	sbc	r23, r19
    6fcc:	84 0b       	sbc	r24, r20
    6fce:	e3 95       	inc	r30
    6fd0:	9a 95       	dec	r25
    6fd2:	72 f7       	brpl	.-36     	; 0x6fb0 <__fp_rempio2+0x18>
    6fd4:	80 38       	cpi	r24, 0x80	; 128
    6fd6:	30 f4       	brcc	.+12     	; 0x6fe4 <__fp_rempio2+0x4c>
    6fd8:	9a 95       	dec	r25
    6fda:	bb 0f       	add	r27, r27
    6fdc:	66 1f       	adc	r22, r22
    6fde:	77 1f       	adc	r23, r23
    6fe0:	88 1f       	adc	r24, r24
    6fe2:	d2 f7       	brpl	.-12     	; 0x6fd8 <__fp_rempio2+0x40>
    6fe4:	90 48       	sbci	r25, 0x80	; 128
    6fe6:	0c 94 86 37 	jmp	0x6f0c	; 0x6f0c <__fp_mpack_finite>

00006fea <__fp_round>:
    6fea:	09 2e       	mov	r0, r25
    6fec:	03 94       	inc	r0
    6fee:	00 0c       	add	r0, r0
    6ff0:	11 f4       	brne	.+4      	; 0x6ff6 <__fp_round+0xc>
    6ff2:	88 23       	and	r24, r24
    6ff4:	52 f0       	brmi	.+20     	; 0x700a <__fp_round+0x20>
    6ff6:	bb 0f       	add	r27, r27
    6ff8:	40 f4       	brcc	.+16     	; 0x700a <__fp_round+0x20>
    6ffa:	bf 2b       	or	r27, r31
    6ffc:	11 f4       	brne	.+4      	; 0x7002 <__fp_round+0x18>
    6ffe:	60 ff       	sbrs	r22, 0
    7000:	04 c0       	rjmp	.+8      	; 0x700a <__fp_round+0x20>
    7002:	6f 5f       	subi	r22, 0xFF	; 255
    7004:	7f 4f       	sbci	r23, 0xFF	; 255
    7006:	8f 4f       	sbci	r24, 0xFF	; 255
    7008:	9f 4f       	sbci	r25, 0xFF	; 255
    700a:	08 95       	ret

0000700c <__fp_sinus>:
    700c:	ef 93       	push	r30
    700e:	e0 ff       	sbrs	r30, 0
    7010:	07 c0       	rjmp	.+14     	; 0x7020 <__fp_sinus+0x14>
    7012:	a2 ea       	ldi	r26, 0xA2	; 162
    7014:	2a ed       	ldi	r18, 0xDA	; 218
    7016:	3f e0       	ldi	r19, 0x0F	; 15
    7018:	49 ec       	ldi	r20, 0xC9	; 201
    701a:	5f eb       	ldi	r21, 0xBF	; 191
    701c:	0e 94 5b 35 	call	0x6ab6	; 0x6ab6 <__addsf3x>
    7020:	0e 94 f5 37 	call	0x6fea	; 0x6fea <__fp_round>
    7024:	0f 90       	pop	r0
    7026:	03 94       	inc	r0
    7028:	01 fc       	sbrc	r0, 1
    702a:	90 58       	subi	r25, 0x80	; 128
    702c:	e5 e9       	ldi	r30, 0x95	; 149
    702e:	f0 e0       	ldi	r31, 0x00	; 0
    7030:	0c 94 90 39 	jmp	0x7320	; 0x7320 <__fp_powsodd>

00007034 <__fp_split3>:
    7034:	57 fd       	sbrc	r21, 7
    7036:	90 58       	subi	r25, 0x80	; 128
    7038:	44 0f       	add	r20, r20
    703a:	55 1f       	adc	r21, r21
    703c:	59 f0       	breq	.+22     	; 0x7054 <__fp_splitA+0x10>
    703e:	5f 3f       	cpi	r21, 0xFF	; 255
    7040:	71 f0       	breq	.+28     	; 0x705e <__fp_splitA+0x1a>
    7042:	47 95       	ror	r20

00007044 <__fp_splitA>:
    7044:	88 0f       	add	r24, r24
    7046:	97 fb       	bst	r25, 7
    7048:	99 1f       	adc	r25, r25
    704a:	61 f0       	breq	.+24     	; 0x7064 <__fp_splitA+0x20>
    704c:	9f 3f       	cpi	r25, 0xFF	; 255
    704e:	79 f0       	breq	.+30     	; 0x706e <__fp_splitA+0x2a>
    7050:	87 95       	ror	r24
    7052:	08 95       	ret
    7054:	12 16       	cp	r1, r18
    7056:	13 06       	cpc	r1, r19
    7058:	14 06       	cpc	r1, r20
    705a:	55 1f       	adc	r21, r21
    705c:	f2 cf       	rjmp	.-28     	; 0x7042 <__fp_split3+0xe>
    705e:	46 95       	lsr	r20
    7060:	f1 df       	rcall	.-30     	; 0x7044 <__fp_splitA>
    7062:	08 c0       	rjmp	.+16     	; 0x7074 <__fp_splitA+0x30>
    7064:	16 16       	cp	r1, r22
    7066:	17 06       	cpc	r1, r23
    7068:	18 06       	cpc	r1, r24
    706a:	99 1f       	adc	r25, r25
    706c:	f1 cf       	rjmp	.-30     	; 0x7050 <__fp_splitA+0xc>
    706e:	86 95       	lsr	r24
    7070:	71 05       	cpc	r23, r1
    7072:	61 05       	cpc	r22, r1
    7074:	08 94       	sec
    7076:	08 95       	ret

00007078 <__fp_trunc>:
    7078:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    707c:	a0 f0       	brcs	.+40     	; 0x70a6 <__fp_trunc+0x2e>
    707e:	be e7       	ldi	r27, 0x7E	; 126
    7080:	b9 17       	cp	r27, r25
    7082:	88 f4       	brcc	.+34     	; 0x70a6 <__fp_trunc+0x2e>
    7084:	bb 27       	eor	r27, r27
    7086:	9f 38       	cpi	r25, 0x8F	; 143
    7088:	60 f4       	brcc	.+24     	; 0x70a2 <__fp_trunc+0x2a>
    708a:	16 16       	cp	r1, r22
    708c:	b1 1d       	adc	r27, r1
    708e:	67 2f       	mov	r22, r23
    7090:	78 2f       	mov	r23, r24
    7092:	88 27       	eor	r24, r24
    7094:	98 5f       	subi	r25, 0xF8	; 248
    7096:	f7 cf       	rjmp	.-18     	; 0x7086 <__fp_trunc+0xe>
    7098:	86 95       	lsr	r24
    709a:	77 95       	ror	r23
    709c:	67 95       	ror	r22
    709e:	b1 1d       	adc	r27, r1
    70a0:	93 95       	inc	r25
    70a2:	96 39       	cpi	r25, 0x96	; 150
    70a4:	c8 f3       	brcs	.-14     	; 0x7098 <__fp_trunc+0x20>
    70a6:	08 95       	ret

000070a8 <__fp_zero>:
    70a8:	e8 94       	clt

000070aa <__fp_szero>:
    70aa:	bb 27       	eor	r27, r27
    70ac:	66 27       	eor	r22, r22
    70ae:	77 27       	eor	r23, r23
    70b0:	cb 01       	movw	r24, r22
    70b2:	97 f9       	bld	r25, 7
    70b4:	08 95       	ret

000070b6 <__gesf2>:
    70b6:	0e 94 3f 37 	call	0x6e7e	; 0x6e7e <__fp_cmp>
    70ba:	08 f4       	brcc	.+2      	; 0x70be <__gesf2+0x8>
    70bc:	8f ef       	ldi	r24, 0xFF	; 255
    70be:	08 95       	ret

000070c0 <inverse>:
    70c0:	9b 01       	movw	r18, r22
    70c2:	ac 01       	movw	r20, r24
    70c4:	60 e0       	ldi	r22, 0x00	; 0
    70c6:	70 e0       	ldi	r23, 0x00	; 0
    70c8:	80 e8       	ldi	r24, 0x80	; 128
    70ca:	9f e3       	ldi	r25, 0x3F	; 63
    70cc:	0c 94 43 36 	jmp	0x6c86	; 0x6c86 <__divsf3>

000070d0 <lround>:
    70d0:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    70d4:	58 f1       	brcs	.+86     	; 0x712c <lround+0x5c>
    70d6:	9e 57       	subi	r25, 0x7E	; 126
    70d8:	60 f1       	brcs	.+88     	; 0x7132 <lround+0x62>
    70da:	98 51       	subi	r25, 0x18	; 24
    70dc:	a0 f0       	brcs	.+40     	; 0x7106 <lround+0x36>
    70de:	e9 f0       	breq	.+58     	; 0x711a <lround+0x4a>
    70e0:	98 30       	cpi	r25, 0x08	; 8
    70e2:	20 f5       	brcc	.+72     	; 0x712c <lround+0x5c>
    70e4:	09 2e       	mov	r0, r25
    70e6:	99 27       	eor	r25, r25
    70e8:	66 0f       	add	r22, r22
    70ea:	77 1f       	adc	r23, r23
    70ec:	88 1f       	adc	r24, r24
    70ee:	99 1f       	adc	r25, r25
    70f0:	0a 94       	dec	r0
    70f2:	d1 f7       	brne	.-12     	; 0x70e8 <lround+0x18>
    70f4:	12 c0       	rjmp	.+36     	; 0x711a <lround+0x4a>
    70f6:	06 2e       	mov	r0, r22
    70f8:	67 2f       	mov	r22, r23
    70fa:	78 2f       	mov	r23, r24
    70fc:	88 27       	eor	r24, r24
    70fe:	98 5f       	subi	r25, 0xF8	; 248
    7100:	11 f4       	brne	.+4      	; 0x7106 <lround+0x36>
    7102:	00 0c       	add	r0, r0
    7104:	07 c0       	rjmp	.+14     	; 0x7114 <lround+0x44>
    7106:	99 3f       	cpi	r25, 0xF9	; 249
    7108:	b4 f3       	brlt	.-20     	; 0x70f6 <lround+0x26>
    710a:	86 95       	lsr	r24
    710c:	77 95       	ror	r23
    710e:	67 95       	ror	r22
    7110:	93 95       	inc	r25
    7112:	d9 f7       	brne	.-10     	; 0x710a <lround+0x3a>
    7114:	61 1d       	adc	r22, r1
    7116:	71 1d       	adc	r23, r1
    7118:	81 1d       	adc	r24, r1
    711a:	3e f4       	brtc	.+14     	; 0x712a <lround+0x5a>
    711c:	90 95       	com	r25
    711e:	80 95       	com	r24
    7120:	70 95       	com	r23
    7122:	61 95       	neg	r22
    7124:	7f 4f       	sbci	r23, 0xFF	; 255
    7126:	8f 4f       	sbci	r24, 0xFF	; 255
    7128:	9f 4f       	sbci	r25, 0xFF	; 255
    712a:	08 95       	ret
    712c:	68 94       	set
    712e:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    7132:	0c 94 54 38 	jmp	0x70a8	; 0x70a8 <__fp_zero>

00007136 <__mulsf3>:
    7136:	0e 94 ae 38 	call	0x715c	; 0x715c <__mulsf3x>
    713a:	0c 94 f5 37 	jmp	0x6fea	; 0x6fea <__fp_round>
    713e:	0e 94 bc 37 	call	0x6f78	; 0x6f78 <__fp_pscA>
    7142:	38 f0       	brcs	.+14     	; 0x7152 <__mulsf3+0x1c>
    7144:	0e 94 c3 37 	call	0x6f86	; 0x6f86 <__fp_pscB>
    7148:	20 f0       	brcs	.+8      	; 0x7152 <__mulsf3+0x1c>
    714a:	95 23       	and	r25, r21
    714c:	11 f0       	breq	.+4      	; 0x7152 <__mulsf3+0x1c>
    714e:	0c 94 63 37 	jmp	0x6ec6	; 0x6ec6 <__fp_inf>
    7152:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>
    7156:	11 24       	eor	r1, r1
    7158:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>

0000715c <__mulsf3x>:
    715c:	0e 94 1a 38 	call	0x7034	; 0x7034 <__fp_split3>
    7160:	70 f3       	brcs	.-36     	; 0x713e <__mulsf3+0x8>

00007162 <__mulsf3_pse>:
    7162:	95 9f       	mul	r25, r21
    7164:	c1 f3       	breq	.-16     	; 0x7156 <__mulsf3+0x20>
    7166:	95 0f       	add	r25, r21
    7168:	50 e0       	ldi	r21, 0x00	; 0
    716a:	55 1f       	adc	r21, r21
    716c:	62 9f       	mul	r22, r18
    716e:	f0 01       	movw	r30, r0
    7170:	72 9f       	mul	r23, r18
    7172:	bb 27       	eor	r27, r27
    7174:	f0 0d       	add	r31, r0
    7176:	b1 1d       	adc	r27, r1
    7178:	63 9f       	mul	r22, r19
    717a:	aa 27       	eor	r26, r26
    717c:	f0 0d       	add	r31, r0
    717e:	b1 1d       	adc	r27, r1
    7180:	aa 1f       	adc	r26, r26
    7182:	64 9f       	mul	r22, r20
    7184:	66 27       	eor	r22, r22
    7186:	b0 0d       	add	r27, r0
    7188:	a1 1d       	adc	r26, r1
    718a:	66 1f       	adc	r22, r22
    718c:	82 9f       	mul	r24, r18
    718e:	22 27       	eor	r18, r18
    7190:	b0 0d       	add	r27, r0
    7192:	a1 1d       	adc	r26, r1
    7194:	62 1f       	adc	r22, r18
    7196:	73 9f       	mul	r23, r19
    7198:	b0 0d       	add	r27, r0
    719a:	a1 1d       	adc	r26, r1
    719c:	62 1f       	adc	r22, r18
    719e:	83 9f       	mul	r24, r19
    71a0:	a0 0d       	add	r26, r0
    71a2:	61 1d       	adc	r22, r1
    71a4:	22 1f       	adc	r18, r18
    71a6:	74 9f       	mul	r23, r20
    71a8:	33 27       	eor	r19, r19
    71aa:	a0 0d       	add	r26, r0
    71ac:	61 1d       	adc	r22, r1
    71ae:	23 1f       	adc	r18, r19
    71b0:	84 9f       	mul	r24, r20
    71b2:	60 0d       	add	r22, r0
    71b4:	21 1d       	adc	r18, r1
    71b6:	82 2f       	mov	r24, r18
    71b8:	76 2f       	mov	r23, r22
    71ba:	6a 2f       	mov	r22, r26
    71bc:	11 24       	eor	r1, r1
    71be:	9f 57       	subi	r25, 0x7F	; 127
    71c0:	50 40       	sbci	r21, 0x00	; 0
    71c2:	9a f0       	brmi	.+38     	; 0x71ea <__mulsf3_pse+0x88>
    71c4:	f1 f0       	breq	.+60     	; 0x7202 <__mulsf3_pse+0xa0>
    71c6:	88 23       	and	r24, r24
    71c8:	4a f0       	brmi	.+18     	; 0x71dc <__mulsf3_pse+0x7a>
    71ca:	ee 0f       	add	r30, r30
    71cc:	ff 1f       	adc	r31, r31
    71ce:	bb 1f       	adc	r27, r27
    71d0:	66 1f       	adc	r22, r22
    71d2:	77 1f       	adc	r23, r23
    71d4:	88 1f       	adc	r24, r24
    71d6:	91 50       	subi	r25, 0x01	; 1
    71d8:	50 40       	sbci	r21, 0x00	; 0
    71da:	a9 f7       	brne	.-22     	; 0x71c6 <__mulsf3_pse+0x64>
    71dc:	9e 3f       	cpi	r25, 0xFE	; 254
    71de:	51 05       	cpc	r21, r1
    71e0:	80 f0       	brcs	.+32     	; 0x7202 <__mulsf3_pse+0xa0>
    71e2:	0c 94 63 37 	jmp	0x6ec6	; 0x6ec6 <__fp_inf>
    71e6:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    71ea:	5f 3f       	cpi	r21, 0xFF	; 255
    71ec:	e4 f3       	brlt	.-8      	; 0x71e6 <__mulsf3_pse+0x84>
    71ee:	98 3e       	cpi	r25, 0xE8	; 232
    71f0:	d4 f3       	brlt	.-12     	; 0x71e6 <__mulsf3_pse+0x84>
    71f2:	86 95       	lsr	r24
    71f4:	77 95       	ror	r23
    71f6:	67 95       	ror	r22
    71f8:	b7 95       	ror	r27
    71fa:	f7 95       	ror	r31
    71fc:	e7 95       	ror	r30
    71fe:	9f 5f       	subi	r25, 0xFF	; 255
    7200:	c1 f7       	brne	.-16     	; 0x71f2 <__mulsf3_pse+0x90>
    7202:	fe 2b       	or	r31, r30
    7204:	88 0f       	add	r24, r24
    7206:	91 1d       	adc	r25, r1
    7208:	96 95       	lsr	r25
    720a:	87 95       	ror	r24
    720c:	97 f9       	bld	r25, 7
    720e:	08 95       	ret

00007210 <round>:
    7210:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    7214:	e8 f0       	brcs	.+58     	; 0x7250 <round+0x40>
    7216:	9e 37       	cpi	r25, 0x7E	; 126
    7218:	e8 f0       	brcs	.+58     	; 0x7254 <round+0x44>
    721a:	96 39       	cpi	r25, 0x96	; 150
    721c:	b8 f4       	brcc	.+46     	; 0x724c <round+0x3c>
    721e:	9e 38       	cpi	r25, 0x8E	; 142
    7220:	48 f4       	brcc	.+18     	; 0x7234 <round+0x24>
    7222:	67 2f       	mov	r22, r23
    7224:	78 2f       	mov	r23, r24
    7226:	88 27       	eor	r24, r24
    7228:	98 5f       	subi	r25, 0xF8	; 248
    722a:	f9 cf       	rjmp	.-14     	; 0x721e <round+0xe>
    722c:	86 95       	lsr	r24
    722e:	77 95       	ror	r23
    7230:	67 95       	ror	r22
    7232:	93 95       	inc	r25
    7234:	95 39       	cpi	r25, 0x95	; 149
    7236:	d0 f3       	brcs	.-12     	; 0x722c <round+0x1c>
    7238:	b6 2f       	mov	r27, r22
    723a:	b1 70       	andi	r27, 0x01	; 1
    723c:	6b 0f       	add	r22, r27
    723e:	71 1d       	adc	r23, r1
    7240:	81 1d       	adc	r24, r1
    7242:	20 f4       	brcc	.+8      	; 0x724c <round+0x3c>
    7244:	87 95       	ror	r24
    7246:	77 95       	ror	r23
    7248:	67 95       	ror	r22
    724a:	93 95       	inc	r25
    724c:	0c 94 69 37 	jmp	0x6ed2	; 0x6ed2 <__fp_mintl>
    7250:	0c 94 84 37 	jmp	0x6f08	; 0x6f08 <__fp_mpack>
    7254:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>

00007258 <sin>:
    7258:	9f 93       	push	r25
    725a:	0e 94 cc 37 	call	0x6f98	; 0x6f98 <__fp_rempio2>
    725e:	0f 90       	pop	r0
    7260:	07 fc       	sbrc	r0, 7
    7262:	ee 5f       	subi	r30, 0xFE	; 254
    7264:	0c 94 06 38 	jmp	0x700c	; 0x700c <__fp_sinus>
    7268:	19 f4       	brne	.+6      	; 0x7270 <sin+0x18>
    726a:	16 f4       	brtc	.+4      	; 0x7270 <sin+0x18>
    726c:	0c 94 92 37 	jmp	0x6f24	; 0x6f24 <__fp_nan>
    7270:	0c 94 84 37 	jmp	0x6f08	; 0x6f08 <__fp_mpack>

00007274 <sqrt>:
    7274:	0e 94 22 38 	call	0x7044	; 0x7044 <__fp_splitA>
    7278:	b8 f3       	brcs	.-18     	; 0x7268 <sin+0x10>
    727a:	99 23       	and	r25, r25
    727c:	c9 f3       	breq	.-14     	; 0x7270 <sin+0x18>
    727e:	b6 f3       	brts	.-20     	; 0x726c <sin+0x14>
    7280:	9f 57       	subi	r25, 0x7F	; 127
    7282:	55 0b       	sbc	r21, r21
    7284:	87 ff       	sbrs	r24, 7
    7286:	0e 94 89 39 	call	0x7312	; 0x7312 <__fp_norm2>
    728a:	00 24       	eor	r0, r0
    728c:	a0 e6       	ldi	r26, 0x60	; 96
    728e:	40 ea       	ldi	r20, 0xA0	; 160
    7290:	90 01       	movw	r18, r0
    7292:	80 58       	subi	r24, 0x80	; 128
    7294:	56 95       	lsr	r21
    7296:	97 95       	ror	r25
    7298:	28 f4       	brcc	.+10     	; 0x72a4 <sqrt+0x30>
    729a:	80 5c       	subi	r24, 0xC0	; 192
    729c:	66 0f       	add	r22, r22
    729e:	77 1f       	adc	r23, r23
    72a0:	88 1f       	adc	r24, r24
    72a2:	20 f0       	brcs	.+8      	; 0x72ac <sqrt+0x38>
    72a4:	26 17       	cp	r18, r22
    72a6:	37 07       	cpc	r19, r23
    72a8:	48 07       	cpc	r20, r24
    72aa:	30 f4       	brcc	.+12     	; 0x72b8 <sqrt+0x44>
    72ac:	62 1b       	sub	r22, r18
    72ae:	73 0b       	sbc	r23, r19
    72b0:	84 0b       	sbc	r24, r20
    72b2:	20 29       	or	r18, r0
    72b4:	31 29       	or	r19, r1
    72b6:	4a 2b       	or	r20, r26
    72b8:	a6 95       	lsr	r26
    72ba:	17 94       	ror	r1
    72bc:	07 94       	ror	r0
    72be:	20 25       	eor	r18, r0
    72c0:	31 25       	eor	r19, r1
    72c2:	4a 27       	eor	r20, r26
    72c4:	58 f7       	brcc	.-42     	; 0x729c <sqrt+0x28>
    72c6:	66 0f       	add	r22, r22
    72c8:	77 1f       	adc	r23, r23
    72ca:	88 1f       	adc	r24, r24
    72cc:	20 f0       	brcs	.+8      	; 0x72d6 <sqrt+0x62>
    72ce:	26 17       	cp	r18, r22
    72d0:	37 07       	cpc	r19, r23
    72d2:	48 07       	cpc	r20, r24
    72d4:	30 f4       	brcc	.+12     	; 0x72e2 <sqrt+0x6e>
    72d6:	62 0b       	sbc	r22, r18
    72d8:	73 0b       	sbc	r23, r19
    72da:	84 0b       	sbc	r24, r20
    72dc:	20 0d       	add	r18, r0
    72de:	31 1d       	adc	r19, r1
    72e0:	41 1d       	adc	r20, r1
    72e2:	a0 95       	com	r26
    72e4:	81 f7       	brne	.-32     	; 0x72c6 <sqrt+0x52>
    72e6:	b9 01       	movw	r22, r18
    72e8:	84 2f       	mov	r24, r20
    72ea:	91 58       	subi	r25, 0x81	; 129
    72ec:	88 0f       	add	r24, r24
    72ee:	96 95       	lsr	r25
    72f0:	87 95       	ror	r24
    72f2:	08 95       	ret

000072f4 <square>:
    72f4:	9b 01       	movw	r18, r22
    72f6:	ac 01       	movw	r20, r24
    72f8:	0c 94 9b 38 	jmp	0x7136	; 0x7136 <__mulsf3>

000072fc <trunc>:
    72fc:	0e 94 3c 38 	call	0x7078	; 0x7078 <__fp_trunc>
    7300:	30 f0       	brcs	.+12     	; 0x730e <trunc+0x12>
    7302:	9f 37       	cpi	r25, 0x7F	; 127
    7304:	10 f4       	brcc	.+4      	; 0x730a <trunc+0xe>
    7306:	0c 94 55 38 	jmp	0x70aa	; 0x70aa <__fp_szero>
    730a:	0c 94 69 37 	jmp	0x6ed2	; 0x6ed2 <__fp_mintl>
    730e:	0c 94 84 37 	jmp	0x6f08	; 0x6f08 <__fp_mpack>

00007312 <__fp_norm2>:
    7312:	91 50       	subi	r25, 0x01	; 1
    7314:	50 40       	sbci	r21, 0x00	; 0
    7316:	66 0f       	add	r22, r22
    7318:	77 1f       	adc	r23, r23
    731a:	88 1f       	adc	r24, r24
    731c:	d2 f7       	brpl	.-12     	; 0x7312 <__fp_norm2>
    731e:	08 95       	ret

00007320 <__fp_powsodd>:
    7320:	9f 93       	push	r25
    7322:	8f 93       	push	r24
    7324:	7f 93       	push	r23
    7326:	6f 93       	push	r22
    7328:	ff 93       	push	r31
    732a:	ef 93       	push	r30
    732c:	9b 01       	movw	r18, r22
    732e:	ac 01       	movw	r20, r24
    7330:	0e 94 9b 38 	call	0x7136	; 0x7136 <__mulsf3>
    7334:	ef 91       	pop	r30
    7336:	ff 91       	pop	r31
    7338:	0e 94 95 37 	call	0x6f2a	; 0x6f2a <__fp_powser>
    733c:	2f 91       	pop	r18
    733e:	3f 91       	pop	r19
    7340:	4f 91       	pop	r20
    7342:	5f 91       	pop	r21
    7344:	0c 94 9b 38 	jmp	0x7136	; 0x7136 <__mulsf3>

00007348 <__udivmodqi4>:
    7348:	99 1b       	sub	r25, r25
    734a:	79 e0       	ldi	r23, 0x09	; 9
    734c:	04 c0       	rjmp	.+8      	; 0x7356 <__udivmodqi4_ep>

0000734e <__udivmodqi4_loop>:
    734e:	99 1f       	adc	r25, r25
    7350:	96 17       	cp	r25, r22
    7352:	08 f0       	brcs	.+2      	; 0x7356 <__udivmodqi4_ep>
    7354:	96 1b       	sub	r25, r22

00007356 <__udivmodqi4_ep>:
    7356:	88 1f       	adc	r24, r24
    7358:	7a 95       	dec	r23
    735a:	c9 f7       	brne	.-14     	; 0x734e <__udivmodqi4_loop>
    735c:	80 95       	com	r24
    735e:	08 95       	ret

00007360 <__udivmodhi4>:
    7360:	aa 1b       	sub	r26, r26
    7362:	bb 1b       	sub	r27, r27
    7364:	51 e1       	ldi	r21, 0x11	; 17
    7366:	07 c0       	rjmp	.+14     	; 0x7376 <__udivmodhi4_ep>

00007368 <__udivmodhi4_loop>:
    7368:	aa 1f       	adc	r26, r26
    736a:	bb 1f       	adc	r27, r27
    736c:	a6 17       	cp	r26, r22
    736e:	b7 07       	cpc	r27, r23
    7370:	10 f0       	brcs	.+4      	; 0x7376 <__udivmodhi4_ep>
    7372:	a6 1b       	sub	r26, r22
    7374:	b7 0b       	sbc	r27, r23

00007376 <__udivmodhi4_ep>:
    7376:	88 1f       	adc	r24, r24
    7378:	99 1f       	adc	r25, r25
    737a:	5a 95       	dec	r21
    737c:	a9 f7       	brne	.-22     	; 0x7368 <__udivmodhi4_loop>
    737e:	80 95       	com	r24
    7380:	90 95       	com	r25
    7382:	bc 01       	movw	r22, r24
    7384:	cd 01       	movw	r24, r26
    7386:	08 95       	ret

00007388 <__udivmodsi4>:
    7388:	a1 e2       	ldi	r26, 0x21	; 33
    738a:	1a 2e       	mov	r1, r26
    738c:	aa 1b       	sub	r26, r26
    738e:	bb 1b       	sub	r27, r27
    7390:	fd 01       	movw	r30, r26
    7392:	0d c0       	rjmp	.+26     	; 0x73ae <__udivmodsi4_ep>

00007394 <__udivmodsi4_loop>:
    7394:	aa 1f       	adc	r26, r26
    7396:	bb 1f       	adc	r27, r27
    7398:	ee 1f       	adc	r30, r30
    739a:	ff 1f       	adc	r31, r31
    739c:	a2 17       	cp	r26, r18
    739e:	b3 07       	cpc	r27, r19
    73a0:	e4 07       	cpc	r30, r20
    73a2:	f5 07       	cpc	r31, r21
    73a4:	20 f0       	brcs	.+8      	; 0x73ae <__udivmodsi4_ep>
    73a6:	a2 1b       	sub	r26, r18
    73a8:	b3 0b       	sbc	r27, r19
    73aa:	e4 0b       	sbc	r30, r20
    73ac:	f5 0b       	sbc	r31, r21

000073ae <__udivmodsi4_ep>:
    73ae:	66 1f       	adc	r22, r22
    73b0:	77 1f       	adc	r23, r23
    73b2:	88 1f       	adc	r24, r24
    73b4:	99 1f       	adc	r25, r25
    73b6:	1a 94       	dec	r1
    73b8:	69 f7       	brne	.-38     	; 0x7394 <__udivmodsi4_loop>
    73ba:	60 95       	com	r22
    73bc:	70 95       	com	r23
    73be:	80 95       	com	r24
    73c0:	90 95       	com	r25
    73c2:	9b 01       	movw	r18, r22
    73c4:	ac 01       	movw	r20, r24
    73c6:	bd 01       	movw	r22, r26
    73c8:	cf 01       	movw	r24, r30
    73ca:	08 95       	ret

000073cc <__tablejump2__>:
    73cc:	ee 0f       	add	r30, r30
    73ce:	ff 1f       	adc	r31, r31
    73d0:	05 90       	lpm	r0, Z+
    73d2:	f4 91       	lpm	r31, Z
    73d4:	e0 2d       	mov	r30, r0
    73d6:	09 94       	ijmp

000073d8 <__muluhisi3>:
    73d8:	0e 94 f7 39 	call	0x73ee	; 0x73ee <__umulhisi3>
    73dc:	a5 9f       	mul	r26, r21
    73de:	90 0d       	add	r25, r0
    73e0:	b4 9f       	mul	r27, r20
    73e2:	90 0d       	add	r25, r0
    73e4:	a4 9f       	mul	r26, r20
    73e6:	80 0d       	add	r24, r0
    73e8:	91 1d       	adc	r25, r1
    73ea:	11 24       	eor	r1, r1
    73ec:	08 95       	ret

000073ee <__umulhisi3>:
    73ee:	a2 9f       	mul	r26, r18
    73f0:	b0 01       	movw	r22, r0
    73f2:	b3 9f       	mul	r27, r19
    73f4:	c0 01       	movw	r24, r0
    73f6:	a3 9f       	mul	r26, r19
    73f8:	70 0d       	add	r23, r0
    73fa:	81 1d       	adc	r24, r1
    73fc:	11 24       	eor	r1, r1
    73fe:	91 1d       	adc	r25, r1
    7400:	b2 9f       	mul	r27, r18
    7402:	70 0d       	add	r23, r0
    7404:	81 1d       	adc	r24, r1
    7406:	11 24       	eor	r1, r1
    7408:	91 1d       	adc	r25, r1
    740a:	08 95       	ret

0000740c <memcmp>:
    740c:	fb 01       	movw	r30, r22
    740e:	dc 01       	movw	r26, r24
    7410:	04 c0       	rjmp	.+8      	; 0x741a <memcmp+0xe>
    7412:	8d 91       	ld	r24, X+
    7414:	01 90       	ld	r0, Z+
    7416:	80 19       	sub	r24, r0
    7418:	21 f4       	brne	.+8      	; 0x7422 <memcmp+0x16>
    741a:	41 50       	subi	r20, 0x01	; 1
    741c:	50 40       	sbci	r21, 0x00	; 0
    741e:	c8 f7       	brcc	.-14     	; 0x7412 <memcmp+0x6>
    7420:	88 1b       	sub	r24, r24
    7422:	99 0b       	sbc	r25, r25
    7424:	08 95       	ret

00007426 <_exit>:
    7426:	f8 94       	cli

00007428 <__stop_program>:
    7428:	ff cf       	rjmp	.-2      	; 0x7428 <__stop_program>
