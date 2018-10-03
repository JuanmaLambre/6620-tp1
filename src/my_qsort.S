
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

