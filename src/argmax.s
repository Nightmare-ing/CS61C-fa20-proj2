.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    blt x0, a1, loop_start
    li a1, 77
    jal exit2
    # Prologue

loop_start:
    li t0, 1 # the current index
    lw t1, 0(a0) # default largest element
    mv t4, x0 # index of default largest element
loop_continue:
    bge t0, a1, loop_end
    slli t2, t0, 2
    add t2, t2, a0
    lw t3, 0(t2)
    bge t1, t3, done
    mv t1, t3
    mv t4, t0
done:
    addi t0, t0, 1
    j loop_continue
   
loop_end:
    mv a0, t4
    # Epilogue

    ret
