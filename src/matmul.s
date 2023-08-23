.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    slt t0, x0, a1
    slt t1, x0, a2
    and t0, t0, t1
    bne x0, t0, check_m1
    li a0, 17
    li a1, 72
    ecall
check_m1:
    slt t0, x0, a4
    slt t1, x0, a5
    and t0, t0, t1
    bne x0, t0, check_match
    li a0, 17
    li a1, 73
    ecall
check_match:
    beq a2, a4, check_done
    li a0, 17
    li a1, 74
    ecall
check_done:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)

    mv s0, a0
    mv s1, a1 # num of row
    mv s2, a2
    mv s3, a3
    mv s4, a4 # num of row
    mv s5, a5
    mv s6, a6
    li s7, 0 # row index
outer_loop_start:
    bge s7, s1, outer_loop_end
    li s8, 0 # column index
    
    mul t0, s7, s2
    slli t0, t0, 2
    add s9, t0, s0 # the start address of the cur row
inner_loop_start:
    bge s8, s5, inner_loop_end
    slli t0, s8, 2
    add a1, t0, s3 # the start address of the cur col
    mv a0, s9
    mv a2, s2
    li a3, 1
    mv a4, s5
    
    jal dot
    
    mul t0, s7, s5
    add t0, t0, s8
    slli t0, t0, 2
    add t0, t0, s6
    sw a0, 0(t0) # store to destination
    
    addi s8, s8, 1
    j inner_loop_start
inner_loop_end:
    addi s7, s7, 1
    j outer_loop_start
outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    addi sp, sp, 44
    
    ret
