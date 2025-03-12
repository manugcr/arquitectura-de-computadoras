 ADDI a1,zero,5    # a1 (registro 5)    # completa en ciclo 5
 ADDI a2,zero,6    # a2 (registro 6)    # completa en ciclo 6
 ADDI t1,zero,9    # t1 (registro 9)    # completa en ciclo 7
 JAL end
 ADDI t2,zero,10   # t2 (registro 10)   # completa en ciclo 8
 ADDI t3,zero,11   # t3 (registro 11)   # completa en ciclo 9
 ADDI t4,zero,12   # t4 (registro 12)   # completa en ciclo 10
 ADDI t5,zero,13   # t5 (registro 13)   # completa en ciclo 11
 end: ADDI t6,zero,14   # t6 (registro 14)   # completa en ciclo 12
 ADDI s2,zero,18   # s2 (registro 18)   # completa en ciclo 13
 ADDI s3,zero,19   # s3 (registro 19)   # completa en ciclo 14


HALT                                    # completa en ciclo 21