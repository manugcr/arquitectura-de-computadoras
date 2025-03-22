
 ADDI a1,zero,5    # a1 (registro 5)    # completa en ciclo 5
 ADDI a2,zero,6    # a2 (registro 6)    # completa en ciclo 6
 ADDI t2,zero,10   # t2 (registro 10)   # completa en ciclo 8
 ADDI t3,zero,11   # t3 (registro 11)   # completa en ciclo 9
 ADDI t4,zero,30   # t4 (registro 12)   # completa en ciclo 10
 ADDI t5,zero,13   # t5 (registro 13)   # completa en ciclo 11
 ADDI t6,zero,14   # t6 (registro 14)   # completa en ciclo 12
 ADDI s2,zero,18   # s2 (registro 18)   # completa en ciclo 13
 ADDI s3,zero,19   # s3 (registro 19)   # completa en ciclo 14


ADDU  s1,s2,s3  
ADDU  v0,t4,t4  
JR   v0  
ADDU  t1,t2,t3  
ADDU  t2,t3,t4  
ADDU  t3,t4,t5  
ADDU  t4,t5,t6  
ADDU  t5,t1,t2  

HALT
