onerror resume
wave tags  sim
wave update off
wave zoom range 0 1
wave group top -backgroundcolor #004466
wave add -group top top.WB_ADDR_WIDTH -tag sim -radix hexadecimal -select
wave add -group top top.WB_DATA_WIDTH -tag sim -radix hexadecimal -select
wave add -group top top.NUM_I2C_BUSSES -tag sim -radix hexadecimal -select
wave add -group top top.clk -tag sim -radix hexadecimal -select
wave add -group top top.rst -tag sim -radix hexadecimal -select
wave add -group top top.cyc -tag sim -radix hexadecimal -select
wave add -group top top.stb -tag sim -radix hexadecimal -select
wave add -group top top.we -tag sim -radix hexadecimal -select
wave add -group top top.ack -tag sim -radix hexadecimal -select
wave add -group top top.adr -tag sim -radix hexadecimal -select
wave add -group top top.dat_wr_o -tag sim -radix hexadecimal -select
wave add -group top top.dat_rd_i -tag sim -radix hexadecimal -select
wave add -group top top.irq -tag sim -radix hexadecimal -select
wave add -group top {top.scl[0]} -tag sim -radix hexadecimal -select
wave add -group top {top.sda[0]} -tag sim -radix hexadecimal -select
wave insertion [expr [wave index insertpoint] + 1]
wave update on
wave top 0
