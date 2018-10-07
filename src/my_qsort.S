#include <mips/regdef.h>
    .text
    .align 2
    .abicalls
    .globl my_qsort
    .ent my_qsort

my_qsort:
    #creo StackFrame
 

        subu    sp, sp, 40              # Inicializo stack
        sw      ra, 32(sp)
        sw      $fp, 28(sp) 
        sw      gp, 24(sp)
        sw      a0, 40(sp) 
        sw      a1, 44(sp)
        sw      a2, 48(sp)

        subu    t0, a1, a0 
        bltz    t0, EXIT
        lw      t0, 0(a0)               # t0: pivot
        addi    t1, a0, 1               # t1: curmin
        addi    t2, a1, 0               # t2: curmax

GLOBAL_WHILE:
        subu    t4,t2,t1                # First while checks for curmin < curmax
        bltz    t4, END_GLOBAL_WHILE

FIRST_WHILE:
        subu    t4,a1,t1                # checks for curMin <= right
        bltz    t4, END_FIRST_WHILE
        lw      t4, 0(t1)                  # set params to compare them later (curmin and pivot)
        lw      t5, 0(t0)
        li      t8, 0
        j       COMP_STR
FIRST_COMP:
        bgtz    v0, END_FIRST_WHILE        
        addi    t1,t1,4
        j       FIRST_WHILE
END_FIRST_WHILE:


SECOND_WHILE:
        subu    t4,t2,a0                # checks for curMax >= left
        bltz    t4, END_SECOND_WHILE
        lw      t4, 0(t2)                  # set params to compare them later (curmax and pivot)
        lw      t5, 0(t0)
        li      t8, 1
        j       COMP_NUMBER
SECOND_COMP:
        bltz    v0, END_SECOND_WHILE        
        subu    t2,t2,4
        j       SECOND_WHILE
END_SECOND_WHILE:
        subu    t4,t1,t2                # checks for curMin < curMax
        bgez    t4, GLOBAL_WHILE
        lw      t3, 0(t1)                  # get curmin value
        lw      t4, 0(t2)                  # get curmax value
        sw      t4, 0(t1)                  # swaps values between curmin and curmax
        sw      t3, 0(t2)
        j       GLOBAL_WHILE


END_GLOBAL_WHILE:

        lw     t3, 0(a0)                  # get left value
        lw     t4, 0(t2)                  # get curmax value
        sw     t4, 0(a0)                 # swaps values between left and curmax
        sw     t3, 0(t2)

RECURSIVE:
        sw      t2, 16(sp)      
        subi    a1, t2, 1               
        jal     my_qsort                # my_qsort(left, curMax-1, num)
        lw      a1, 24(sp)              # right
        lw      t2, 16(sp)
        addiu   a0,t2,1
        jal     my_qsort                # my_qsort(curMax+1, right, num);
EXIT:

        lw      ra, 32(sp)
        lw      $fp, 28(sp) 
        lw      gp, 24(sp)
        addiu   sp, sp, 40              
        jr      ra


COMP: 

END_COMP:
        beqz    t8, FIRST_COMP
        j       SECOND_COMP




COMP_STR:

COMP_NUMBER: 
        # Compare numbers
                                # t4: first element char pointer 
                                # t5: second element chat pointer

        li      t3, 0
        j       ATOI
FIRST_END_ATOI:
        addi    t6, v0, 0     # t6: first int value
        li      t3, 1
        sw      s3, 0(a0)
        addi    t4, t5, 0
        j       ATOI
SECOND_END_ATOI:        
        addi    t7, v0, 0     # t7: second int value
        subu    t7, t7, t6
        li      v0, -1
        bgtz    t7, END_COMP_NUMBER
        li      v0, 1
 END_COMP_NUMBER:
        j       END_COMP

ATOI:
        li      v0, 0       # v0 va a tener el resultado final
LOOP:
        lb      t7, 0(t4)
        beqz    t7, END
        subi    t7, t7, 48
        li      a3, 10      # muli doesn't wotk...
        mult    v0, a3
        mflo    v0
        addu    v0,v0,t7
        addi    t4, t4, 1
END:    
        beqz    t3, FIRST_END_ATOI
        j       SECOND_END_ATOI

.end my_qsort
