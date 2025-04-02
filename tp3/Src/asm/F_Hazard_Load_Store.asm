
ADDI R1,R0,2      # completa en ciclo 5
ADDU R2,R1,R1       # completa en ciclo 6
ADDI R3,R0,8      # completa en ciclo 7
ADDI R4,R0,6      # completa en ciclo 8
ADDI R5,R0,12     # completa en ciclo 9
ADDI R6,R0,10     # completa en ciclo 10
SW   R6,14(R4)      # completa en ciclo 11

SW  R3,24(R2)       # completa en ciclo 12
LW  R7,16(R2)       # completa en ciclo 13
SW  R2,14(R7)       # completa en ciclo 14
LW  R8,16(R5)       # completa en ciclo 15
ADDU R1,R2,R7       # completa en ciclo 16
ADDU R9,R8,R1       # completa en ciclo 17

HALT                # completa en ciclo 18

 # completa en PC 18*4 = 72d = 48h