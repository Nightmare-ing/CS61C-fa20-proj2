.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp) # pointer to represent filename
    sw s1, 8(sp) # pointer to the start of the matrix in memory
    sw s2, 12(sp) # num of rows
    sw s3, 16(sp) #num of cols
    sw s4, 20(sp) # file descriptor
    sw s5, 24(sp) # malloced pointer
    sw s6, 28(sp) # num of elems
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open the file
    mv a1, s0
    li a2, 1
    jal fopen
    li t0, -1
    beq t0, a0, fopen_error
    mv s4, a0
  
    # store row and col into buffer
    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0
    sw s2, 0(s5)
    sw s3, 4(s5)
    
    # start writing
    mv a1, s4
    mv a2, s5
    li a3, 2
    li a4, 4
    jal fwrite
    li t0, 2
    blt a0, t0, fwrite_error
    
    mv a1, s4
    mv a2, s1
    mul s6, s2, s3
    mv a3, s6
    li a4, 4
    jal fwrite
    blt a0, s6, fwrite_error
    
    # free the buffer, close the file
    mv a0, s5
    jal free
    mv a1, s4
    jal fclose
    li t0, -1
    beq t0, a0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp) 
    lw s1, 8(sp) 
    lw s2, 12(sp) 
    lw s3, 16(sp) 
    lw s4, 20(sp) 
    lw s5, 24(sp) 
    lw s6, 28(sp) 
    addi sp, sp, 32

    ret
    
    
fopen_error:
    li a1 93
    jal exit2
    
malloc_error:
    li a1 88
    jal exit2
    
fwrite_error:
    li a1, 94
    jal exit2

fclose_error:
    li a1, 95
    jal exit2