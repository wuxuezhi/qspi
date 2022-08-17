# INTRODUCTION
本文档是(SFPe)SPI flash programming engine的介绍。

# SPI 整体结构
![](./doc/spi.png)spi.png


# SFPe COMMAND 寄存器
<!-- |     |Command VALID| Instruction Code | Data Size| Address SPI type|Data SPI type|Reserved|
|:---:|:-----------:|:----------------:|:--------:|:---------------:|:-----------:|:------:|
|Bit Field| 31      | 30:23            |22:15     | 14:13           | 12:11  | 10:0| -->


* 指令完成后Command Valid 会由硬件自动清零。
* 本次Programming 的字节数 = Data Size + 1.
* 地址强制24 bit
* 指令码强制8 bit
* xxx SPI type: 2'b00 standard spi; 2'b01 dual spi; 2'b10 quad spi; 2'b11 reserved.


# SFPe reg 0(Instruction Code)
|Bit Field|Name|Property|Reset Value|Description|
|:-------:|:--:|:------:|:---------:|:---------:|
|7:0      |code|RW      |0x02       |设置SFPe给spi flash发送的指令|

# SFPe reg 1(Programing Size)
|Bit Field|Name|Property|Reset Value|Description|
|:-------:|:--:|:------:|:---------:|:---------:|
|7:0      |Size| RW     |0xFF|设置本次SFPe编程的字节数|

# SFPe reg 2(Instruction Ctrl)
|Bit Field|Name|Property|Reset Value|Description|
|:-------:|:--:|:------:|:---------:|:---------:|
|7:6  |Address SPI type| RW|0x0|SFPe发送地址阶段的SPI类型。00:SPI; 01:dual spi; 10: quad spi; 11: reserved|
|5:4| Date SPI type| RW| 0x0| SFPE 发送地址阶段的SPI类型。|
|3| start| RW|0x0|开始Programming,完成后自动清零|
|2:0|Reserved|0x0| 0x0|

# SFPe reg 3(Date Queue)
|Bit Field|Name|Property|Reset Value|Description|
|:-------:|:--:|:------:|:---------:|:---------:|
|7:0| write data queue| W| - | Programming数据缓冲队列|


