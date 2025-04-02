 ADDI R1,R0,5    # R1 (registro 5)    # completa en ciclo 5
 ADDI R2,R0,6    # R2 (registro 6)    # completa en ciclo 6
 ADDI R3,R0,10   # R3 (registro 10)   # completa en ciclo 8
 ADDI R4,R0,11   # R4 (registro 11)   # completa en ciclo 9
 ADDI R5,R0,12   # R5 (registro 12)   # completa en ciclo 10
 ADDI R6,R0,13   # R6 (registro 13)   # completa en ciclo 11
 ADDI R7,R0,14   # R7 (registro 14)   # completa en ciclo 12
 ADDI R8,R0,18   # R8 (registro 18)   # completa en ciclo 13
 ADDI R9,R0,19   # R9 (registro 19)   # completa en ciclo 14

ADDU R10,R8,R9                       # completa en ciclo 15
ADDU R11,R1,R2                       # completa en ciclo 16
J 5                                 # completa en ciclo 17       
ADDU R12,R3,R4                       # SE DESCARTA EN en ciclo 15
ADDU R3,R4,R5                       
ADDU R4,R5,R6 
5: ADDU R5,R6,R7                       # completa en ciclo 19
ADDU R6,R12,R3                       # completa en ciclo 20

HALT                                    # completa en ciclo 21