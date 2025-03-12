ADDI t1,zero,9
ADDI t2,zero,10
ADDI s2,zero,18
ADDI s3,zero,19
ADDI a1,zero,5
ADDI a2,zero,6

ADDU t0,t1,t2 # 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144, Registro 08h (08d) = 13h
ADDU s1,s2,s3 # 000000 10010 10011 10001 00000 100000  -> 0x2538820  -> 39028768, Registro 11h (17d) = 25h
ADDU a0,a1,a2 # 000000 00101 00110 00100 00000 100000  -> 0xA62020   -> 10887200, Registro 04h (04d) = 0bh
HALT



# ADDI zero, zero, 0  # zero (registro 0)
# ADDI at, zero, 1    # at (registro 1)
# ADDI v0, zero, 2    # v0 (registro 2)
# ADDI v1, zero, 3    # v1 (registro 3)
# ADDI a0, zero, 4    # a0 (registro 4)
# ADDI a1, zero, 5    # a1 (registro 5)
# ADDI a2, zero, 6    # a2 (registro 6)
# ADDI t1, zero, 9    # t1 (registro 9)
# ADDI t2, zero, 10   # t2 (registro 10)
# ADDI t3, zero, 11   # t3 (registro 11)
# ADDI t4, zero, 12   # t4 (registro 12)
# ADDI t5, zero, 13   # t5 (registro 13)
# ADDI t6, zero, 14   # t6 (registro 14)
# ADDI t7, zero, 15   # t7 (registro 15)
# ADDI s0, zero, 16   # s0 (registro 16)
# ADDI s1, zero, 17   # s1 (registro 17)
# ADDI s2, zero, 18   # s2 (registro 18)
# ADDI s3, zero, 19   # s3 (registro 19)
# ADDI s4, zero, 20   # s4 (registro 20)
# ADDI s5, zero, 21   # s5 (registro 21)
# ADDI s6, zero, 22   # s6 (registro 22)
# ADDI s7, zero, 23   # s7 (registro 23)
# ADDI t8, zero, 24   # t8 (registro 24)
# ADDI t9, zero, 25   # t9 (registro 25)
# ADDI k0, zero, 26   # k0 (registro 26)
# ADDI k1, zero, 27   # k1 (registro 27)
# ADDI gp, zero, 28   # gp (registro 28)
# ADDI sp, zero, 29   # sp (registro 29)
# ADDI fp, zero, 30   # fp (registro 30)
# ADDI ra, zero, 31   # ra (registro 31)
