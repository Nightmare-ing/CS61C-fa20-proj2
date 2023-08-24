.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -36
    sw ra 0(sp)
    sw s0, 4(sp) # file descriptor
    sw s1, 8(sp) # buffer pointer
    sw s2, 12(sp) # num of row
    sw s3, 16(sp) # num of col
    sw s4, 20(sp) # pointer to filename
    sw s5, 24(sp) # pointer to represent row
    sw s6, 28(sp) # pointer to represent col
    sw s7, 32(sp) # num of elem
    
    mv s4, a0
    mv s5, a1
    mv s6, a2
	
    # open the file
    mv a1, s4
    mv a2, x0
    jal fopen
    mv s0, a0
    li t0, -1
    beq t0, s0, fopen_error
    
    # read the num of row and col
    li a0, 8
    jal malloc
    mv s1, a0
    beq x0, s1, malloc_error
    mv a1, s0
    mv a2, s1
    li a3, 8
    jal fread
    li t0, 8
    blt a0, t0, fread_error
    lw s2, 0(s1)
    lw s3, 4(s1)
    
    # store row and col to destination
    sw s2, 0(s5)
    sw s3, 0(s6)
    
    # read the matrix
    mul s7, s2, s3 # num of elem
    slli a0, s7, 2
    jal malloc
    mv s1, a0
    beq x0, s1, malloc_error
    mv a1, s0
    mv a2, s1
    slli a3, s7, 2
    jal fread
    blt a0, s7, fread_error
    
    mv a1, s0
    jal fclose
    bne a0, x0, fclose_error
    
    mv a0, s1
    # Epilogue
    lw ra 0(sp)
    lw s0, 4(sp) 
    lw s1, 8(sp) 
    lw s2, 12(sp) 
    lw s3, 16(sp) 
    lw s4, 20(sp) 
    lw s5, 24(sp) 
    lw s6, 28(sp) 
    lw s7, 32(sp) 
    addi sp, sp, 36
    ret
    
fopen_error:
    li a1, 90
    jal exit2

malloc_error:
    li a1, 88
    jal exit2
    
fread_error:
    li a1, 91
    jal exit2

fclose_error:
    li a1, 92
    jal exit2