
# Testat - Verkettete Liste: Element Einfuegen bei sortierter Liste
#
# Aufgabe: Implementieren der Funktion addToSortedList
#

.data
# Note: list elements are defined in reverse order here
standard_list:
    .word 9, 5, 4, 2, 1, 0
negative_list:
    .word -1, -4, -5, 0
end_list:
    .word 3, 2, 1, 0
begin_list:
    .word 3, 0


.text
# routine:    main
#             controls main program flow, no change needed
main:
    
    
    # Testfall 1: Standard - Einfügen in der Mitte
    #  1 -> 2 -> 4 -> 5 -> 9
    #  ==> 1 -> 2 -> 4 -> 5 -> 6 -> 9

    la a0, standard_list    # address to x(N-1), ... x(0) 
    li a1, 6              # x(new)
    jal testMethod

    # Testfall 2: Einfügen in Liste mit negativen Elementen
    # -5 -> -4 -> -1 
    # ==> -5 -> -4 -> -2 -> -1 

    la a0, negative_list    # address to x(N-1), ... x(0) 
    li a1, -2               # x(new)
    jal testMethod

    # Testfall 3: Einfügen ans Ende der Liste
    # 1 -> 2 -> 3
    # ==> 1 -> 2 -> 3 -> 42
    la a0, end_list         # address to x(N-1), ... x(0) 
    li a1, 42               # x(new)
    jal testMethod

    # Testfall 4: Einfügen an Anfang der Liste (neuer Head)
    # 3
    # ==> 1 -> 3

    la a0, begin_list       # address to x(N-1), ... x(0) 
    li a1, 1                # x(new)
    jal testMethod

    li a0, 10               # exit
    ecall

### Testataufgabe ###

# subroutine: addToSortedList
# arguments:  head of list (a0)
#             value of new list element  (a1)
# return:     head of list
addToSortedList:
    #>>>>>>>>> Start Codeanpassung >>>>>>>>>>>>>>>>>>
    # Prolog
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    #Function
    mv s0, a0 #copy address of the head of list to s0
    mv s1, a1 #copy the value to be added to s1
    lw s2, 0(s0) #load the value of the head to s2
    lw s3, 4(s0) #load the address of next element to s3
   
    bge s1, s2, loop #( if s1 >= s2 , then go to loop ) otherwise prepend node

    mv a0, s0
    mv a1, s1
    jal prependNode
    j epilog

    loop:
        lw s2, 0(s3) #loop through the values in the list
        beqz s3, endNode # if address == 0 end 
        bge s2, s1, addNodeinMiddle
        mv s4, s3
        lw s3, 4(s3)
        j loop

    endNode:
        mv a0, s1 #load the value to a1 as parameter for createNode subroutine
        jal createNode 
        sw a0, 4(s4) #update the nextAddress of previous node to the last element( newly added element)
        mv a0, s0
        j epilog

    addNodeinMiddle:
        mv a0, s3 #currentaddress
        mv a1, s1
        jal  prependNode #add a node and make it head
        sw a0, 4(s4) #change the next_address eg:( 5 -> 9 ) now 5 -> 6
        mv a0, s0 #move
        j epilog 
        
    # Epilog
    epilog:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    #<<<<<<<<< Ende Codeanpassung <<<<<<<<<<<<<<<<<<<<

    ret

### Hilfsmethoden ###

# subroutine: createNode
# arguments:  value for new list element
# return:     pointer to start of new list element
createNode:
    mv t0, a0       # store value

    li a0, 9        # sbrk
    li a1, 8        # size: 8
    ecall           # p = sbrk(8)
                    # a0 is base address of element

    sw t0, 0(a0)    # value
    sw zero, 4(a0)  # next

    ret

# subroutine:   testMethod
# arguments:    address of data
#               value to insert
# return:       -
testMethod:
    # Prolog
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)

    mv s1, a1               # value to insert

    jal createListOnHeap    # create list
    mv s0, a0               # store head

    mv a0, s0
    jal printList           # print original list

    mv a0, s0
    mv a1, s1
    jal addToSortedList     # call insert method

    jal printList           # print list after insertion

    # Epilog
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret


# subroutine: createListOnHeap
# argument:   address of data
# return:     head of list
createListOnHeap:
    # Prolog
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    mv s0, a0       # address of data
    lw a0, 0(s0)    # get value
    jal createNode  # create first element/create list

    mv s1, a0       # rescue head of list

    1:
        addi s0, s0, 4  # next data element
        lw s2, 0(s0)    # get value

        beqz s2, 2f     # if value == 0 then stop

        mv a0, s1
        mv a1, s2
        jal prependNode # add to list at beginning

        mv s1, a0       # store new head of list

        j 1b            # next iteration

    2:
    mv a0, s1       # return head of list

    # Epilog
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# subroutine: printList
# argument:   head of list
# return:     -
printList:
    mv t2, a0
    beqz a0, 3f     # no value to print available?

    mv t0, a0       # t0 = head
1:
    li a0, 1        # print_dec
    lw a1, 0(t0)    # get value
    ecall
    lw t1, 4(t0)    # t1 = next
    beqz t1, 3f

    li a0, 11       # print_char
    li a1, 45       # '-'
    ecall
    li a0, 11       # print_char
    li a1, 62       # '>'
    ecall
    mv t0, t1       # t0 = next
    j 1b
3:
    li a0, 11       # print_char
    li a1, 13       # '\n'
    ecall

    ret

# subroutine: prependNode
# arguments:  head of list
#             value for new list element
# return:     pointer to start address of new list element
prependNode:
    # Prolog
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)

    mv s0, a0
    mv a0, a1       # value for new list element
    call createNode # create new list element
                    # a0 is return address of new list element

    sw s0, 4(a0)

    # Epilog
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret
