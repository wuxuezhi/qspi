# Introduce
这是 QSPI的验证要求文档

# QSPI总体架构
![](../doc/archi.png)


# 输入
 输入接口为AXI 3.0 Slave interface


# 输出
|Name|in/out|Description|
|:-------:|:--:|:------:|
|spi_if_sck      |out|SPI的时钟信号      |
|spi_if_csn_en|out|见2K1000LA用户手册SPI-SFC_SOFTCS寄存器|
|spi_if_csn_o|out|同上|
|spi_if_csn_i|out|同上|
|spi_if_sdo_en|out|SPI sdo使能。为低时，sdo为高阻态|
|spi_if_sdo_o|out|SPI sdo输出值。|
|spi_if_sdo_i|input|SPI sdo 输入值|
|spi_if_sdi_en|output|见sdo相关描述|
|spi_if_sdi_o|output|见sdo相关描述|
|spi_if_sdi_i|input|见sdi相关描述|


# 功能描述
该设计包含两大主要功能。
1. SPI flash 控制器。
2. QSPI。
## SPI flash controller
该部分描述见原来的spi 文档。（如2K1000LA用户手册）
## QSPI
出于兼容性的考虑，该设计复位后会切换到SPI flash controller通道，以使原来的软件无需更改即可使用。想使用QSPI功能，需要配置switch寄存器。如需要从QSPI切换为spi flash controller，出入安全考虑，请先读取QSPI的状态，发现其为idle时，再切换。（对于从QSPI读取数据或配置寄存器（除了DATA 寄存器），QSPI仅会在其完成的时候返回响应，意味着返回数据的时候QSPI一定已经idle；但对于向QSPI写DATA 寄存器，其会立刻返回响应，即使并未完成此次写）

## 地址空间
该设计的地址空间分为两个部分
* memory 空间：对于memory空间的输入进行以下限制，仅允许AXI READ transaction 。
* IO 空间 ：对于IO空间的输入进行以下限制，AXI transaction 的burst len = 1, burst size = 1 Byte。

## EXAMPLE
以下例子说明了怎么在Micron N25Q128A 输入QUAD INPUT/OUTPUT FAST READ 指令从flash中读取数据。
0. 复位。复位后自动切换到SPI flash.
1. SPI flash controller 将自己的任务处理完后，可以选择将片选拉高后直接切换到QSPI；但若想混合使用SPI flash controller & QSPI, 则不用将片选拉高，但需要让QSPI和SPI flash controller工作在同一种极性和相位（防止在片选有效的时候，切换导致sck跳动使spi从设备错误获取信息）。
2. 向switch register写入8'b00000001;
3. 向 Config & Status Register写入8'b00000000(2分频，将片选拉低)。
4. 向 Data register 写入8’h0B（QUAD INPUT/OUTPUT FAST READ）。
5. 向 config register 写入8'h00010000（进入Quad mode)。
6. 向 Data register 连续写3个字节的地址（从高字节往低字节开始，将24bit地址分为3B分别写入）。
7. 向 config register 写入8'b00110000（进入dummy模式)。
8. 向 Data register 写入8'b00000111（dummy拍数为8）。
9. 向 config register 写入8'b00010000（推出dummy模式)。
10. 从 Data 读取数据。一次只能读取一个字节。



