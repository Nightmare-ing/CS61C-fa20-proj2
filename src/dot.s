.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    blt x0, a2, check_strides
    li a1, 75
    jal exit2
check_strides:
    slt t0, x0, a3
    slt t1, x0, a4
    and t0, t0, t1
    bne x0, t0, loop_start
    li a1, 76
    jal exit2

loop_start:
    # Prologue
    addi sp, sp, -4
    sw s0 0(sp)
    
    li t0, 0 # the counter
    li s0, 0
loop_continue:
    bge t0, a2, loop_end
    mul t1, t0, a3
    mul t2, t0, a4
    slli t1, t1, 2
    slli t2, t2, 2
    add t1, a0, t1
    add t2, a1, t2
    lw t1, 0(t1)
    lw t2, 0(t2)
    mul t1, t1, t2
    add s0, s0, t1
    addi t0, t0, 1
    j loop_continue

loop_end:
    mv a0, s0
    # Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
    
    ret
