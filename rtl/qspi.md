# Introduction
本文档是QSPI 的设计说明文档。
# Signal Description
 | direction|name | description|
 |:---:|:---:|:----------:|
 |input| clk|时钟|
 |input| rst_n|异步复位，低有效|
 |input|i_qspi_vld| QSPI接收数据输入有效，并将其转换为QSPI信号|
 |output|i_qspi_rdy|QSPI准备接收数据|
 |input|i_qspi_dat| QSPI 接收的数据。既可以作为数据存在，也可以作为Dummy信息。|
 |input|i_qspi_continue| QSPI 接收完本次数据后将会等待下一个数据。|
 |input|i_qspi_dummy|QSPI 将发送dummy信号，dummy时钟数由i_qspi_dat决定|
 |input|i_qspi_type|本次SPI传输的类型。2'b00: standard spi; 2'b01: dual spi; 2'b10 :quad spi。仅当处于standard SPI模式时，才支持双工传输|
 |input|qspi_param_mod|qspi 模式。|
 |input|qspi_param_div|qspi 分频系数|
 |output|o_qspi_sck| QSPI 时钟|
 |output|o_qspi_cs_n| QSPI 片选，低有效|
 
# QSPI Config Register  (bias + 0x0)
|Bit Field| Name | Description| Default |Property|
|:-------:|:----:|:----------:|:-------:|:------:|
| 7 : 6   |Qmode |qspi mode.高位为CHOL，低位CHPA |0| R/W|
| 5       |dummy |接下来传给QSPI的数据是dummy|0| R/W |
| 4 : 3   |Qtype | QSPI 传输类型； 00: standard spi; 01: dual spi; 10: quad spi;|0| R/W |
| 2       |duxen |开启双工模式。仅仅在standard spi模式下有效。开启后，向QSPI写一字节数据的同时，QSPI会读一个字节回来。软件需要将这个字节读取。| 0 | R/W |
| 1       |Reserved |- | -| - |
|0        |Reserved|- | -| -|

# QSPI Config & Status Register  (bias + 0x1)
|Bit Field| Name | Description| Default |Property|
|:-------:|:----:|:----------:|:-------:|:------:|
|7:4| Qclk_div| QSPI时钟分频系数，独立于spre/spr|0|R/W|
|3| Qcs |QSPI 片选信号输出值       |1| R/W|
|2| Qbusy| QSPI 处于繁忙中|        0|R|
|1:0| Reserved| - | - |-|


# QSPI  Data Register(bias + 0x2)

|Bit Field| Name | Description| Default |Property|
|:-------:|:----:|:----------:|:-------:|:------:|
|7:0|Qdat|往这里写一个字节的数据，QSPI 会自动将其转换为spi写；往这里读一个字节的数据，QSPI会自动将其转换为spi读。| 0 |R/W|



<!-- # QSPI Write Data Register(bias + 0x2) -->

# SPI interface
以下为spi interface 的内容。

# SPI switch Register(bias + 0x3)
|Bit Field| Name | Description| Default |Property|
|:-------:|:----:|:----------:|:-------:|:------:|
|7：1|Reserved| - | - | -|
|0|Switch|0:切换为0号SPI控制器； 1：切换为QSPI| 0| R/W|

# Register Space Switch
# Register space switch Register(bias + 0xf)
|Bit Field| Name | Description| Default |Property|
|:-------:|:----:|:----------:|:-------:|:------:|
|7：1|Reserved| - | - | -|
|0|Rssr |0:切换为0号SPI flash ctrl Register space； 1：切换为QSPI Register space| 0| R/W|