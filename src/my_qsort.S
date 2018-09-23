
        ... construyo SRA (dejo el sp entre SRA y LTA) ...
        addi    t0,a0,0     # t0: cur, a0: left
        addi    t1,a1,0     # t1: pivot, a1: right
        subu    t2,a1,a0    # t2: size of qicksort stack
        addi    t3,sp,0     # t3: qspt
        add     t4,sp,t2    # t4: qspb
QS_LOOP:
        beq     t0,a1,END_PIVOT
        add     sp,sp,t2    # Preparo el stack para la llamada
        sw      t1,0(sp)
        addi    sp,sp,4
        sw      t0,0(sp)
        addi    sp,sp,4
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
        addi    t5,sp,0     # t5: cursor de copia de qs (TODO: asumo que sp = qspt)
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

