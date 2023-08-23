.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    blt x0, a1, loop_start
    li a0, 17
    li a1, 78
    ecall
    # Prologue

loop_start:
    li t0, 0 # the counter
loop_continue:
    bge t0, a1, loop_end
    slli t1, t0, 2
    add t1, a0, t1
    lw t2, 0(t1)
    bge t2, x0, done
    sw x0, 0(t1)
done:
    addi t0, t0, 1
    j loop_continue
loop_end:
    # Epilogue
  
	ret
