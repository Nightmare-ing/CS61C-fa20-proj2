.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne a0, t0, num_of_args_error

    # prologue
    addi sp, sp, -56
    sw ra, 0(sp)
    sw s0, 4(sp) # pointer to input
    sw s1, 8(sp) # num of rows for input
    sw s2, 12(sp) # num of cols for input
    sw s3, 16(sp) # pointer to m0 * input or pointer to argv
    sw s4, 20(sp) # malloced pointer for row & col info
    sw s5, 24(sp) # pointer to matrix m0
    sw s6, 28(sp) # pointer to matrix m1
    sw s7, 32(sp) # num of rows for m0
    sw s8, 36(sp) # num of cols for m0
    sw s9, 40(sp) # num of rows for m1
    sw s10, 44(sp) # num of cols for m1
    sw s11, 48(sp) # pointer to m1 * ReLU(m0 * input)
    sw a1, 52(sp)

    mv s3, a1
	# =====================================
    # LOAD MATRICES
    # =====================================
    # allocate memory for storing the row and col info
    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s4, a0

    # Load pretrained m0
    lw a0, 4(s3)
    mv a1, s4
    addi a2, s4, 4
    jal read_matrix
    mv s5, a0
    lw s7, 0(s4)
    lw s8, 4(s4)
    # Load pretrained m1
    lw a0, 8(s3)
    mv a1, s4
    addi a2, s4, 4
    jal read_matrix
    mv s6, a0
    lw s9, 0(s4)
    lw s10, 4(s4)
    # Load input matrix
    lw a0, 12(s3)
    mv a1, s4
    addi a2, s4, 4
    jal read_matrix
    mv s0, a0
    lw s1, 0(s4)
    lw s2, 4(s4)
    # free the malloc
    mv a0, s4
    jal free
    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    mul a0, s7, s2
    slli a0, a0, 2
    jal malloc
    mv s3, a0
    beq s3, x0, malloc_error
    
    mv a0, s5
    mv a1, s7
    mv a2, s8
    mv a3, s0
    mv a4, s1
    mv a5, s2
    mv a6, s3
    jal matmul
    
    mv a0, s3
    mul a1, s7, s2
    jal relu
    
    mul a0, s9, s2
    slli a0, a0, 2
    jal malloc
    mv s11, a0
    beq s11, x0, malloc_error
    
    mv a0, s6
    mv a1, s9
    mv a2, s10
    mv a3, s3
    mv a4, s7
    mv a5, s2
    mv a6, s11
    jal matmul
    
    mv a0, s3
    jal free
    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw s3, 52(sp)
    lw a0, 16(s3)
    mv a1, s11
    mv a2, s9
    mv a3, s2
    jal write_matrix
    # free the malloced space
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s0
    jal free
    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s11
    mul a1, s9, s2
    jal argmax

    # Print classification
    mv a1, a0
    jal print_int    

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char
    
    mv a0, s11
    jal free

    # epilogue
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
    lw s10, 44(sp) 
    lw s11, 48(sp) 
    addi sp, sp, 56
    ret

num_of_args_error:
    li a1, 89
    jal exit2
    
malloc_error:
    li a1, 88
    jal exit2
