#PART A – Number Array A[]: 

addi $7, $0, 3 # $7 init to x
addi $8, $0, 4 # $8 init to y

# Store x and y in A[0] and A[1]
sw $7, 0x2010($0) # A[0] = x
sw $8, 0x2014($0) # A[1] = y

# Initialize loop counter and array index
addi $9, $0, 0          # $9 = i (start from A[0])
addi $10, $0, 0x2010    # $10 = Address of A[0]

# Calculate A[2] and A[3] manually as they depend on A[0] and A[1]
lw $11, 0($10)      # Load A[0] into $11
lw $12, 4($10)      # Load A[1] into $12
sll $11, $11, 1     # $11 = 2 * A[0]
sub $13, $11, $12   # $13 = 2 * A[0] - A[1]
sw $13, 0x2018($0)  # Store A[2] 
addi $9, $9, 1      # Increment i
addi $10, $10, 4    # Move to the next element in the array

loop:

	# Calculate A[i+2] = 2 * A[i] - A[i+1]
	lw $11, 0($10)      
	lw $12, 4($10)      
	sll $11, $11, 1     
	sub $13, $11, $12   

	# Store A[i+2] at the current array index
	sw $13, 8($10)     

	# Update loop counter and array index
	addi $9, $9, 1      
	addi $10, $10, 4   

	# Check if we have calculated all 21 elements
	addi $14, $0, 19    
	bne $9, $14, loop   


#PART B – EF count Array C[]:

# Initialize loop counter
addi $12, $0, 0

# mask for lowest 4 bits
addi $13, $0, 0xF

# Load first addresses of A[] and C[]
addi $10, $0, 0x2010    # first address of A[]
addi $11, $0, 0x2080    # first address of C[]

# Start loop
loop2:
	# Load current element from A[]
	lw $14, 0($10)

	# Initialize EF count to 0
    	addi $15, $0, 0

    	# Start inner loop for each hex digit
    	addi $16, $0, 8   # Inner loop counter
inner_loop:
        # Extract lowest 4 bits
        and $17, $14, $13

        # Check if each bit is 'E' (0xE) or 'F' (0xF)
        addi $18, $0, 0xE
        addi $19, $0, 0xF
        beq $17, $18, found_E
        beq $17, $19, found_E

        # Shift right by 4 bits
        srl $14, $14, 4
        j continue

found_E:
        # Increment EF count
        addi $15, $15, 1

continue:
        # Decrement inner loop counter
        subi $16, $16, 1
        bnez $16, inner_loop

    	# Store EF count in array C[]
    	sw $15, 0($11)

    	# Increment loop counter and update addresses
    	addi $12, $12, 1
    	addi $10, $10, 4
    	addi $11, $11, 4

    	# Check if we have processed all 21 elements
    	addi $16, $0, 21
    	bne $12, $16, loop2

#PART C – Col max and min for 3x7 matrix A:

addi $8, $0, 0      # Loop counter
addi $9, $0, 0x2010 # Address of A[]
addi $10, $0, 0x2180 # Address of min values

# Start min loop
loop_min:
	# Load first element of column A into $11
    	add $12, $9, $8   # Address of first element of column
    	lw $11, 0($12)

    	# Start inner loop for each row
    	addi $13, $0, 3   # Inner loop counter
row_loop_min:
        # Load next element of column into $14
        addi $12, $12, 28  # Address of next element of column
        lw $14, 0($12)

        # Compare with current min and update if necessary
        slt $15, $14, $11
    	beq $15, $0, cont_min
    	add $11, $14, $0

cont_min:
        # Decrement inner loop counter
        subi $13, $13, 1
        bnez $13, row_loop_min

    	# Store min value in array at M[0x2100] to M[0x2118]
    	sw $11, 0($10)

    	# Increment loop counter and update base address for min values
    	addi $8, $8, 4
    	addi $10, $10, 4

    	# Check if we have processed all 7 columns
    	addi $14, $0, 28
    	blt $8, $14, loop_min
    
addi $8, $0, 0      # Loop counter
addi $9, $0, 0x2010 # Base address of A[]
addi $10, $0, 0x2100 # Base address of max values

# Start max loop
loop_max:
    	# Load first element of column into $11
    	add $12, $9, $8   # Address of first element of column
    	lw $11, 0($12)

    	# Start inner loop for each row
    	addi $13, $0, 3   # Inner loop counter
row_loop_max:
        # Load next element of column into $14
        addi $12, $12, 28  # Address of next element of column
        lw $14, 0($12)

        # Compare with current max and update if necessary
        slt $15, $11, $14
    	beq $15, $0, cont_max
    	add $11, $14, $0

cont_max:

        # Decrement inner loop counter
        subi $13, $13, 1
        bnez $13, row_loop_max

    	# Store max value in array at M[0x2180] to M[0x2198]
    	sw $11, 0($10)

    	# Increment loop counter and update base address for max values
    	addi $8, $8, 4
    	addi $10, $10, 4

    	# Check if we have processed all 7 columns
	addi $14, $0, 28
    	blt $8, $14, loop_max
