ADDI R1,R0,2      # completa en ciclo 5
ADDU R2,R1,R1       # completa en ciclo 6
ADDI R3,R0,6      # completa en ciclo 7
ADDI R4,R0,10     # completa en ciclo 8
SW R4,14(R3)        # completa en ciclo 9


LW R5,16(R2)   # completa en ciclo 9
ADDU R6,R5,R2  # completa en ciclo 11

HALT