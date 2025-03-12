ADDI v0,zero,2      # completa en ciclo 5
ADDU s3,v0,v0       # completa en ciclo 6
ADDI s1,zero,6      # completa en ciclo 7
ADDI a0,zero,10     # completa en ciclo 8
SW a0,14(s1)        # completa en ciclo 9


LW s2,16(s3)   # completa en ciclo 9
ADDU v1,s2,s3  # completa en ciclo 11

HALT