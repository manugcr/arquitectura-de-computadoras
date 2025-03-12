
ADDI v0,zero,2      # completa en ciclo 5
ADDU s3,v0,v0       # completa en ciclo 6
ADDI t8,zero,8      # completa en ciclo 7
ADDI s1,zero,6      # completa en ciclo 8
ADDI t0,zero,12     # completa en ciclo 9
ADDI a0,zero,10     # completa en ciclo 10
SW   a0,14(s1)      # completa en ciclo 11

SW  t8,24(s3)       # completa en ciclo 12
LW  s2,16(s3)       # completa en ciclo 13
SW  s3,14(s2)       # completa en ciclo 14
LW  t1,16(t0)       # completa en ciclo 15
ADDU v0,s3,s2       # completa en ciclo 16
ADDU t2,t1,v0       # completa en ciclo 17

HALT                # completa en ciclo 18

 # completa en PC 18*4 = 72d = 48h