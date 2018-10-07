
        ... construyo SRA (dejo el sp entre SRA y LTA) ...
        addi    t0,a0,0     # t0: cur, a0: left
        addi    t1,a1,0     # t1: pivot, a1: right
        subu    t2,a1,a0    # t2: size of qicksort stack
        addi    t2,t2,4
        addi    t3,sp,0     # t3: qspt
        add     t4,sp,t2    # t4: qspb
QS_LOOP:
        beq     t0,a1,END_PIVOT
        j       COMP_STR
        blez    v0,QSPB
        sw      cur,0(t3)
        addi    t3,t3,4
        j       INC_CUR
QSPB:   sw      cur,0(t4)
        addi    t4,t4,-4
INC_CUR:
        addi    t0,t0,4
        j       QS_LOOP

END_PIVOT:
        # A esta altura qspt = qspb
        sw t1,0(t3)
        # Copio el qs en heap (entre left y right)
        addi    t5,sp,0     # t5: cursor de copia de qs (TODO: asumo que sp = qspt. FIX)
        addi    t7,a0,0     # t7: cursor de copia del heap
COPY:   slt     t6,a1,t7    # t6: temporal
        bgtz    t6,RECURSIVE
        lw      t6,0(t5)
        sw      t6,0(t7)
        addi    t5,t5,4
        addi    t7,t7,4
        j       COPY

RECURSIVE:
        ... qsort left qspt solo si $t2/4 >= 4 (cuatro o mas elementos) ...
        ... qsort qspt+4 right idem ...

COMP_STR:
        ... compare two strings ...

COMP_NUMBER: 
        # Compare numbers
        addi    s2,t0,0     # s2: cur pointer
        addi    s3,t1,0     # s3: pivot pointer
        sw      s2, a0
        jal     ATOI
        addi    s2,v0,0     # s2: cur int value
        sw      s3, a0
        jal     ATOI
        addi    s3,v0,0     # s3: pivot int value
        subu    s3, s3, s2
        li      v0, -1
        bgtz    s3, END_COMP_NUMBER
        li      v0, 1
 END_COMP_NUMBER:
        j       somewhere

.... Function ....
.... Inicializar stack and stuff
ATOI:
        li      s0, 0 # s0 va a tener el resultado final
LOOP:
        lb      s1, a0
        beqz    s1, END
        subi    s1, s1, 48
        muli    s0, s0, 10
        addi    s1,t0,0
        addi    a0, a0, 1
END:    
        addi    vo, s0, 0

.... Cerrar stack and stuff ....






.... myqsort .....

        subu    t0, a1, a0 
        bltz    t0, EXIT
        lbu     t0, a0                  # t0: pivot
        addi    t1, a0, 1               # t1: curmin
        addi    t2, a1, 0               # t2: curmax

GLOBAL_WHILE:
        subu    s0,t2,t1                # First while checks for curmin < curmax
        bltz    s0, END_GLOBAL_WHILE

FIRST_WHILE:
        subu    s0,a1,t1                # checks for curmin < right
        bltz    s0, END_FIRST_WHILE
        #pasarle los args
        j       COMP_STR
FIRST_COMP:
        bgtz    v0, END_FIRST_WHILE        
        addi    t1,t1,1
        j       FIRST_WHILE
END_FIRST_WHILE:


SECOND_WHILE:
        subu    s0,t2,a0                # checks for curm < right
        bltz    s0, END_SECOND_WHILE
        #pasarle los args
        j       COMP_STR
SECOND_COMP:
        bltz    v0, END_SECOND_WHILE        
        subi    t2,t2,1
        j       SECOND_WHILE
END_SECOND_WHILE:
        subu    s0,t1,t2                # checks for curMin < curMax
        bgez    s0, GLOBAL_WHILE
        lbu     t3, t1                  # get curmin value
        lbu     t4, t2                  # get curmax value
        sb      t4, t1                  # swaps values between curmin and curmax
        sb      t3, t2
        j       GLOBAL_WHILE


END_GLOBAL_WHILE:

        lbu     t3, a0                  # get left value
        lbu     t4, t2                  # get curmax value
        sb      t4, a0                  # swaps values between curmin and curmax
        sb      t3, t2

RECURSIVE:
        ... qsort left qspt solo si $t2/4 >= 4 (cuatro o mas elementos) ...
        ... qsort qspt+4 right idem ...

EXIT:
        jal ra
.... end ....