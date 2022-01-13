@ The two numbers we want to add
num1:   .word   0x40000000
num2:   .word   0x3f010000

.text
.global main
main:
    @ Load numbers
    LDR r0, num1
    LDR r1, num2
	@ den foerste eksponenten
	LSR r2, r0, #23
	AND r2, r2, #0xff
	@ den andre eksponenten
	LSR r3, r1, #23
	AND r3, r3, #0xff
	@ lage mantissaene
	@ Generere tallet 0x7ffff for masking
	MOV r4, #0x7f0000
	ORR r4,r4, #0xff00 
	ORR r4,r4, #0xff 
	@ Masking
	AND r0, r0, r4
	AND r1, r1, r4
	@ naa maa vi legge til 1 dersom eksponenten ikke er 0
	@ Generere tallet 0x800000 for aa legge 1 paa slutten
	CMP r2, #0
	ORRNE r0, r0, #0x800000

	CMP r3, #0
	ORRNE r1, r1, #0x800000
	
	@ naa har vi to eksponenter
	@ og vi tar den ene minus den andre
	@ for aa finne ut hvilken som er stoerst
	@ subs setter flaggene samtidig som man subtraherer
	SUBS r4, r2, r3

	@ Dersom tallene er like trenger vi ikke
	@ aa gjoere noe. Dersom den ene er stoerre
	@ en den andre maa vi gjoere ting
	BEQ past
	BLE neg

	@ Her er vi dersom r2 er stoerst 
	@ Da maa det tilhoerende registeret til r3 shiftes r4 ganger
	LSR r1, r1, r4
	B past

	neg:
		@ Her er vi dersom r3 er stoerst
		@ naa setter jeg r2 til aa vaere den stoerste
		@ eksponenten og anser r3 som ledig
		MOV r2, r3
		LSR r0, r0, r4

	past:

	@ naa har vi shifta og kan legge sammen mantissaene
	ADD r0, r0, r1
	@ Naa maa vi sjekke om det 25. bitet er 1, da maa
	@ maa vi rightshifte en gang og oeke eksponenten med 1
	@ For aa sjekke om det er noe bit der hoeyreshifter vi 
	@ helt til bare dette bitet er igjen
	LSR r3, r0, #24
	CMP r3, #1
	LSREQ r0, r0, #1	
	ADDEQ r2, r2, #1	
	@ tar bort det paa plass 24
	LSL r0, r0, #9
	LSR r0, r0, #9
	@ shifter eksponenten
	LSL r2, r2, #23
	@ legger sammen bitsene
	ORR r0, r0, r2

	BX lr
