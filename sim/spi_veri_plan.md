# Introduce
本文档记录spi控制器的验证要求和验证计划，方便后续验证。

# QSPI verification COMMAND list
## INIT config
    addi    t0, r0, 0x1fe00000// t0 = spi start address
    addi    t1, r0, 0x1
    st.b    t1, t0, 0xf
    st.b    t1, t0, 0x3
switch register space & switch spi interface to QSPI



## READ (03h)

|Instruction code|address valid|data valid|data input|
|:-------:|:--:|:------:|:-------:|
|03h| true| true|true|
### Instruction Sequence
    st.b    r0, t0, 0x1     //drive cs# to low
    addi    t1, r0, 0x3
    st.b    t1, t0, 0x2     //write 03h to data reg
    addi    t1, r0, 0x3f    //start at sector 63
    st.b    t1, t0, 0x2     //write addr to data reg
    st.b    r0, t0, 0x2     //read address:0x3f0000
    st.b    r0, t0, 0x2
    addi    t1, r0, 0x10    //set load 16 bytes
    addi    t2, r0, 0x0     //init t2
    bl      LBL             //load byte
    addi    t1, r0, 0x8     //set cs# to high
    st.b    t1, t0, 0x2     //finish READ COMMAND
    /*


    */
    //spi load byte loop:t1 load times
    LBL:
    ld.b    t3, t0, 0x2     //load byte from data reg
    addi    t2, t2, 0x1
    bne     t1, t2, LBL     

## WRITE ENABLE (06h)
|Instruction code|address valid|data valid|data input|
|:-------:|:--:|:------:|:-------:|
|06h| false| false|-|

    st.b    r0, t0, 0x1     //drive cs# to low
    addi    t1, r0, 0x6 
    st.b    t1, t0, 0x2     //write 06h to data reg
    addi    t1, r0, 0x8     //set cs# to high
    st.b    t1, t0, 0x2     //finish WRITE ENABLE COMMAND



## SECTOR ERASE (d8)
|Instruction code|address valid|data valid|data input|
|:-------:|:--:|:------:|:-------:|
|D8h| true| false|-|

    st.b    r0, t0, 0x1     //drive cs# to low
    addi    t1, r0, 0xd8    
    st.b    t1, t0, 0x2     //write D8h to data reg
    addi    t1, r0, 0x3f    //erase sector 63
    st.b    t1, t0, 0x2 
    st.b    r0, t0, 0x2
    st.b    r0, t0, 0x2
    addi    t1, r0, 0x8     //set cs# to high
    st.b    t1, t0, 0x2     //finish SECTOR ERASE COMMAND

## WIP LOOP (05h)
|Instruction code|address valid|data valid|data input|
|:-------:|:--:|:------:|:-------:|
|05h| false| true|true|

    WIP_LOOP:
    st.b    r0, t0, 0x1     //drive cs# to low
    addi    t1, r0, 0x5
    st.b    t1, t0, 0x2     //write 05h to data reg
    ld.b    t1, t0, 0x2     //read flash status reg
    addi    t2, r0, 0x8     //set cs# to high
    st.b    t2, t0, 0x2     //finish READ STATUS COMMAND
    andi    t1, t1, 0x1     //get WIP bit
    bne     t1, r0, WIP_LOOP

## PAGE PROGRAM (02h)
|Instruction code|address valid|data valid|data input|
|:-------:|:--:|:------:|:-------:|
|02h| true| true|flase|

    st.b    r0, t0, 0x1     //drive cs# to low
    addi    t1, r0, 0x2     
    st.b    t1, t0, 0x2     //write 02h to data reg
    addi    t1, r0, 0x3f    //start program address:0x3f0000
    st.b    t1, t0, 0x2     //
    st.b    r0, t0, 0x2
    st.b    r0, t0, 0x2
    addi    t1, r0, 0x10    //program 16 bytes
    addi    t2, r0, 0x1     //program 0x1
    addi    t3, r0, 0x0     //init t3    
    BL      PROG
    addi    t1, r0, 0x8     //drive cs# to high
    st.b    t1, t0, 0x2     finish PAGE PROGRAM


    PROG:
    st.b    t2, t0, 0x2
    addi    t3, t3, 0x1
    bne     t3, t1, PROG
    
# simple SPI verification COMMAND list
## INIT config
    addi    t0, r0, 0x1fe00000
    addi    t1, r0, 0x40
    st.b    t1, t0, 0x0     // set spe zero
    addi    t1, r0, 0xc0
    st.b    t1, t0, 0x1
    addi    t1, t0, 0x40    // set spe 1




    simple_spi_wbyte:
    




    



 