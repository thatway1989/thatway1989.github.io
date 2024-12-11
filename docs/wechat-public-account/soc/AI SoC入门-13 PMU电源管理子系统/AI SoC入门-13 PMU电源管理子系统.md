#  AI SoC入门-13 PMU电源管理子系统   
原创 thatway1989  那路谈OS与SoC嵌入式软件   2024-12-03 19:36  
  
![](9117723ccea1197b6b0d0110d72e8dd9.other)  
  
**电源管理**是SoC中比较重要的一个部分，特别是在**bringup**阶段，芯片的**供电、复位、时钟等**如果配置不对，系统就会启动失败，并且在**流片失败**的例子中电源管理会占一大部分，如果出问题对系统是**致命**的。  
  
**PMU**（Power Management Unit）有两种实现方法，**一种就是传统的基础在A核附属的一个硬件模块，**  
**另外一种就是独立核和固件的SCP**，在大规模AI SoC中一般采用的是**独立固件**的控制。其区别如下表所示：![](8ee26be977324452f7a25c5fa754a02e.other)  
独立固件的实现就是SCP，之前关于SCP介绍过几篇文章：  
  
[ARM SCP入门-简介和代码下载编译](https://mp.weixin.qq.com/s?__biz=MzUzMDMwNTg2Nw==&mid=2247484440&idx=1&sn=e08b89ca8526eb6ad19ed2f55c61b80e&scene=21#wechat_redirect)  
  
  
[ARM SCP入门-framework框架代码分析](https://mp.weixin.qq.com/s?__biz=MzUzMDMwNTg2Nw==&mid=2247484453&idx=1&sn=2ffa12dee95867544bb54b430d6cd5f4&scene=21#wechat_redirect)  
  
  
[ARM SCP入门-AP与SCP通信](https://mp.weixin.qq.com/s?__biz=MzUzMDMwNTg2Nw==&mid=2247484475&idx=1&sn=09183060a3506b1fdcd0af4d4877c89f&scene=21#wechat_redirect)  
  
  
本文进行一些汇总，并从**芯片设计角度**继续阐述下一下设计要点。  
# 1. PMU介绍  
  
![](55cf884c64cd5612e4a556723dda5041.other)  
## 1.1 PMU概念  
  
**PMU**（电源管理芯片）是一种高度集成化的电源管理方案，它集成多路的**LDO和DC-DC，以及相应的检测和控制电路，其核心结构通常是PWM控制器和MOSFET**。高集成度的PMU器件可以有效减小电路板占用面积和器件数量，因此特别适合应用在便携电子产品中。而且随着PMU对电源组控制的**细分程度越高**，PMU对系统各模块的**供电控制更加精准**，能够有效地降低电路系统的整体功耗。在现代的SoC中更是集成了PMU。其组成如下：  
1. Buck结构**DC-DC**电源（降压型稳压器）；  
  
1. **LDO**低压差线性稳压电源；  
  
1. **控制电路**和过压、欠压、过温等有额外的保护电路；  
  
1. **电流检测**和电池**管理**；  
  
1. 电路所需要的**电阻、小容量电容、电感**等。  
  
PMU能有效担负起电子设备所需的**电能变换、分配、检测等管理功**能，是电子设备中的关键器件，其性能优劣对电子产品的性能和可靠性有着直接影响。一个有效的电源管理系统可以**延长电池寿命、提高设备效率**，并确保设备在各种复杂工作条件下都能够保持**稳定可靠运行**。  
## 1.2 LDO及DC-DC  
  
**LDO线性降压电路**，通过电阻分压实现降压，工作过程中会将降下的电压转化为热量，因此当输入输出压差和负载电流越大，芯片**发热会越明显**，造成较大的能量损耗。目前高性能LDO通常采用电压驱动型P沟道MOSFET作为调整管，不仅可以将静态电流能做到微安级，输入输出电压降也可以做到100mV水平。  
  
在大电流或输入/输出压降较大，以及需要进行升压的应用场景时，LDO无法满足电路要求，此时就需要选择更高效率的**DC-DC转换器**。DC-DC转换器包括升压、降压、升/降压和反相等类型电路，采用PWM数字控制方式。其优点很多，包括高效率、大电流输出、低静态电流、低发热量、封装小巧等。  
  
![](74c13f82ea93294e711eac17ff7cca89.other)  
**Buck**：输入和输出极性相同，降压型  
  
**Boost**：升压型  
  
**Buck-Boost**：降升压型  
  
**Sepic**：相当于是Boost和Flyback组合，转化效率高，具备升降压，同极性输出，输入电流脉动小，输出易于扩展，成本高；  
  
**Cuk**：显著减小输入和输出电流脉动，转化效率更高，输入输出电压更灵活；  
  
**Zeta**：输入和输出极性相同，可升降压，应用少；  
  
![](51031489977826ecad1fb2532b5bb29e.other)  
## 1.3 PMU使用及趋势  
  
PMU上电后系统进入**待机状态**，用户触发开机键后，系统首先按照开机顺序将对应的LDO、DC-DC电源打开。系统进入**正常工作状态**，在CPU电源供应正常后，输出复位信号给CPU，让CPU开始启动和工作，CPU会返回一个保持信号让PMU处于持续工作状态。关机时，CPU会给PMU信号，让PMU关闭进入关机状态。系统正常工作时，CPU还可以通过I2C接口对PMU的各个子模块进行控制，PMU也可以将**异常事件**产生中断信息反馈给系统处理。  
  
![](8756e0c13f0435296889ceb691384787.other)  
  
目前PMU的技术发展方向是朝着**提升转换效率**，**降低待机功耗**方向持续发展。同时为了降低简化设计和降低综合成本，也会继续提升PMU的集成度和应用更小巧的封装。在性能方面，需要承载各种大电流负载应用，提高电压调节精度，满足高负载瞬态要求也不可或缺。同时为了适应各类智能化新应用场景带来的多样化需求，PMU与处理器进行实时通讯，灵活配置也是重要的发展趋势。  
  
举例使用：**RT1052芯片电源管理系统**的第一个组成部分，称为集成PMU（集成电源管理单元）。是为了简化外部电源接口而设计的。它由一组辅助电源组成，可通过两个或三个主电源实现SoC操作。使用集成PMU的电源树的高级框图如图所示。  
  
![](6bb95982205d6044f7564c25557d25ce.other)  
  
电源管理单元（PMU）旨在**简化外部电源接口**。电源系统可分为输入电源及其特性，集成电源变换和控制元件，以及最终负载互连和要求。典型的电源系统使用PMU如下图所示。  
  
![](7d08139c69540828324e81c9df7a8939.other)  
  
RT1052使用**四个LDO稳压器**，这样大大减少了外部电源的数量。在**纽扣电池**和USB输入不算在内的情况下，外部电源的数量可以减少到两个。缺少这种外部电源总数是因为所需要的存储器接口供电所需的外部电源数量；该数量取决于所选的外部存储器的类型。如果其I/O的电压必须与上面提供的不同，则可能还需要其他电源来为这种I/O电源端提供电压。  
  
在PMU中可以集成硬件基本的**电源模式**。RT1052的电源模式主要分为两大块，分别是运行和低功耗两种，其中运行模式包括**超载运行、满载运行、低速运行和低功耗运行；低功耗模式包括系统空闲模式、低功耗空闲模式、暂停模式和SNVS模式**。上电复位后RT1052处于运行状态，具体要切换到什么运行模式可以通过串口来修改当前的运行模式。在低功耗的四种模式中，具有电源消耗不同、唤醒时间可设置、唤醒源可选的的特性，用户可以根据自己的应用需求选择最佳的低功耗模式或者运行模式。  
<table><thead><tr style="border-width: 1px 0px 0px;border-right-style: initial;border-bottom-style: initial;border-left-style: initial;border-right-color: initial;border-bottom-color: initial;border-left-color: initial;border-top-style: solid;border-top-color: rgb(204, 204, 204);"><th style="text-align: left;border-top-width: 1px;border-color: rgb(204, 204, 204);padding: 5px 10px;background-color: rgb(240, 240, 240);">运行模式</th><th style="text-align: left;border-top-width: 1px;border-color: rgb(204, 204, 204);padding: 5px 10px;background-color: rgb(240, 240, 240);">说明</th></tr></thead><tbody style="border-width: 0px;border-style: initial;border-color: initial;"><tr style="border-width: 1px 0px 0px;border-right-style: initial;border-bottom-style: initial;border-left-style: initial;border-right-color: initial;border-bottom-color: initial;border-left-color: initial;border-top-style: solid;border-top-color: rgb(204, 204, 204);"><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">超载运行(Overdrive Run)</span></td><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">•CPU运行速度为600 MHz，过驱动电压为1.275 V.•全速总线频率•启用所有外设并以目标频率运行•所有PLL均已启用</span></td></tr><tr style="border-width: 1px 0px 0px;border-right-style: initial;border-bottom-style: initial;border-left-style: initial;border-right-color: initial;border-bottom-color: initial;border-left-color: initial;border-top-style: solid;border-top-color: rgb(204, 204, 204);background-color: rgb(248, 248, 248);"><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">满载运行(Full-Speed Run)</span></td><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">•CPU运行速度为528 MHz，满载，低电压为1.15 V. •全速总线频率 •启用所有外设并以目标频率运行 •所有PLL均已启用</span></td></tr><tr style="border-width: 1px 0px 0px;border-right-style: initial;border-bottom-style: initial;border-left-style: initial;border-right-color: initial;border-bottom-color: initial;border-left-color: initial;border-top-style: solid;border-top-color: rgb(204, 204, 204);"><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">低速运行(Low-Speed Run)</span></td><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">•CPU运行频率为132 MHz，电压降至1.15 V. •半速内部总线频率 •某些PLL断电 •20％外设处于活动状态，其他外设处于低功耗模式</span></td></tr><tr style="border-width: 1px 0px 0px;border-right-style: initial;border-bottom-style: initial;border-left-style: initial;border-right-color: initial;border-bottom-color: initial;border-left-color: initial;border-top-style: solid;border-top-color: rgb(204, 204, 204);background-color: rgb(248, 248, 248);"><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">低功耗运行(Low-Power Run)</span></td><td style="border-color: rgb(204, 204, 204);padding: 5px 10px;"><span style="font-size: 15px;">•CPU以24 MHz运行，较低电压为0.95 V. •内部总线频率为12 MHz •所有PLL均断电，OSC24M断电，RCOSC24使能 •高速外围设备断电</span></td></tr></tbody></table>  
![](e3bcc2e5478378037f21627bcb035c1d.other)  
  
参考：  
  
 https://doc.embedfire.com/mcu/i.mxrt/i.mxrt1052/zh/latest/doc/chapter38/chapter38.html  
  
  
## 1.4 底板PMIC芯片  
  
**PMIC（Power Management Integrated Circuit）**芯片是一种集成电路，主要用于**电源管理和功耗管理**。它在电子设备中起着关键的作用。PMIC芯片在电子设备中的作用是管理电源**供电、监测和控制电池充电状态和电量、管理温度，并执行一些系统控制功能**，以确保设备的稳定运行和有效管理功耗。电源管理通过一定的电路拓扑，将不同的电源输入转换成满足系统工作需要的输出电压。  
  
![](21424a6118691a37be281ea6405dc22f.other)  
  
PMIC跟PMU功能基本一致，很容易混淆，使用时有侧重点。  
- **SoC内部的是PMU（跟CPU总线通信），SoC外部的是PMIC（跟CPU用I2C/SPI等通信）**  
  
- **便携设备内部的是PMU，给便携设备外部供电的电源是PMIC**  
  
> 对于外部和内部，电源管理的功能那些放外部，那些放内部可以通过设计来规划，**你强我弱**的关系，其实放哪里都可以，只是有侧重点。外部侧重供电基础电压供给，内部侧重管理。  
  
  
这里我们介绍的AI SoC是一个芯片，其要放在一个底板上，那**底板就有PMIC芯片负责供电、clock等**。底板如果是开发板，一般是220V家用电的一个变压器，或者像电脑一样的一个交流转直流带风扇的电源进行供电，这里只涉及电压。  
  
关于底板上电源电路的一些注意点：  
- 底板上的电源芯片主要是**DCDC和LDO提供电源**，需要规定好给芯片供电的上电和下电顺序。  
  
- 底板上的OCS**有源晶振芯片提供时钟给芯片**，然后芯片内部PLL再进行频率细调  
  
- 对应芯片的**功耗测量**也需要电压电量的监控芯片以及电流采用板。  
  
- 底板上会有**按钮**控制整体的供电及复位  
  
参考：  
1. https://www.sohu.com/a/770027860_121097735  
  
# 2. 芯片内部PMU  
  
之前也提到芯片内部PMU的实现有分为**是否有独立固件**两种形式，但是其功能基本是一致的。  
- 如果没有固件，在ATF里面集成PMU驱动去控制，Linux中通过**smc陷入到ATF**里面进行处理就可以  
  
- 如果有固件，那么就使用**ARM的SCP**，Linux直接通过scmi协议跟SCP进行通信  
  
## 2.1 无固件PMU  
  
这里以地平线J5 PMU为例进行一些说明。  
  
首先PMU从供电来说位于**AON（Always on Domain）电源常开**。主要用于**上下电顺序、芯片引导、子系统电源开关控制、电源模式转换，休眠唤醒等。还可以控制测试模拟、功率测试等。**  
  
对于PMU的设计首先要划分**电压域和电源域**。  
- PD就是一个**电源域**，其中包括时钟、复位、隔离控制信号、电源开关和供电都是由PMU控制。  
  
- VD就是**电压域**，几个PD可以共享一个VD。  
  
PMU的主要功能：  
- 控制**PLL**上下电  
  
- 控制**外部振荡器**上下电  
  
- 控制**电源域的根时钟门控**，避免PLL在通电期间的高频传播  
  
- **IO电源**管理：控制设备进入超深睡眠时候，保留IO；控制IO唤醒能力  
  
- 每个电源域的电源管理，包括：  
  
- **时钟**对齐，上下电的时候的时钟管理和顺序  
  
- **隔离**电源域的启用/禁用序列  
  
- **LBIST**自检的隔离控制和时钟  
  
- 控制电源域内的**电源开关链顺序**  
  
- **内存修复**控制  
  
- 电源域**上下电**，重置控制  
  
- A55CPU电源管理，包括：  
  
- **CPU核心电源模式的转换**，如ON、OFF、OFF_EMU、DB_RECOV等  
  
- **集群电源模式转换**，如FULL_ON 和OFF  
  
- 整个CPU子系统**断电并中断唤醒**  
  
- 芯片**正常和深度睡眠**的进入和退出  
  
- 芯片超深睡眠的退出  
  
- 分级依赖功率域的安全功率控制机制  
  
- 控制**Noc**电源接口  
  
- 虚拟电源关闭  
  
关于电源控制：  
  
![](cd461ccbb0deaeee7ab271ffe06f88bc.other)  
**电源域的断开和连接**  
- PMU中针对各个power domain都会有**独立的一个或者多个LPC**，用于控制各个Power Domain；  
  
- 而每个Power Domain内部都会包含一个或者多个与**LPC**对应的Power Controller用于接收 LPC的控制命令，对内部的NIU、NOC、NSP单元进行控制；  
  
- 各个Power Domain与PMU是通过**P-Channel**进行连接的。  
  
一个模块化的**通用桥接电源接**口如上图所示。举个下电的例子：  
1. IdleReq 0->1.  
  
1. 向启动器niu传播请求。  
  
1. IdleAck0->1（表示成功分发到启动器niu）。  
  
1. 在启动器中，SlvRdy 1->0。  
  
1. 插座箱1->在所有转会完成后的0。  
  
1. 启动器向电源控制器报告空闲状态0->1。  
  
1. 向目标niu传播空闲请求。  
  
1. 在目标上，在所有转移完成后的插座1->0（独立于SlvRdy）。  
  
1. 目标目标向电源控制器报告。  
  
1. 电源控制器报告怠速0->1（已完成）。  
  
**关于系统电源状态：**  
1. Run：就是运行态  
  
1. IDLE：没有线程运行。CPU进入WFI，等待中断。外设都还保持活动。  
  
1. Normal deep sleep：CPU和所有PLL关闭。高速外设进入门控，低速外设以低频率运行，DRAM进入自刷新，子系统断电。  
  
1. Ultra deep sleep：除VDD_AON外都断电。RTC/PMU/STCU/EFUSE/OSC_TRIM/WAKEUPIO可以工作。  
  
**关于上下电流程：上电流程：**  
  
BIGAON->PERISYS->CPUSYS->SRAMSYS->DDRSYS0/1->BPUSYS0/1->CVSYS->VideoSYS and CAMSYS  
  
下电流程与上电流程相反：（其中PERISYS有所不同）  
  
VideoSYS and CAMSYS ->CVSYS ->BPUSYS0/1->PERISYS->DDRSYS0/1->SRAMSYS->CPUSYS->BIGAON  
  
关于**DDR休眠唤醒**：休眠的时候DDR中的数据需要保持，所以处于供电进入自刷新状态。  
- 确保没有DDR数据访问  
  
- DDR连接的brideg进入idle  
  
- DDR PHY进入保留模式  
  
- DDR进行入自刷新  
  
- 使能DDR隔离  
  
- 使能软复位  
  
- 禁止时钟 唤醒的时候：  
  
- 打开相关电源域电压  
  
- 运行DDR LBIST  
  
- 解复位DDR使能时钟  
  
- 禁止隔离  
  
- DDR状态退出休眠  
  
- brideg进入正常访问模式  
  
**关于测试：**出于安全考虑，在电源域打开的时候，需要运行LBIST和MBIST。  
- STCU触发：PD_BIGAON, PD_PERI,PD_CPUTOP,PD_CPU_C0  
  
- CPU A55触发：其他的功率域和LBIST，MBIST测试。  
  
基于软件的LBIST，MBIST测试，必须在虚拟断电模式下运行。数据流图如下：![](b425e393550042b66b5b2b22d2e1e00f.other)  
  
  
CPU A55从系统闪存中加载模式，并把模式和命令写入电源域。电源域反馈数据到CPU A55，让其对比。  
## 2.2 有固件PMU  
## 2.2.1 ARM PCSA规范  
  
这里的实现可以用ARM的PCSA规范来说明。  
> 什么是**PCSA**？  
> 随着SOC的复杂性增加，例如**多种异构核**上又运行了不同的OS，不同的子系统间（例如**Linux、ISP、NPU、FSI、eSecur**e等）相互独立，为了满足功耗的控制管理，这些子系统间需要进行协调，难度增大。为了更好的功耗管理，需要从系统中其他的控制器和应用处理器中抽象出来各种电源或其他系统管理任务，进行**集中管理**，利用一个独立的控制器核心实现。因此ARM提出了  
**功耗控制系统架构**（power control system architecture，简称  
**PCSA**），用来规范芯片功耗控制的逻辑实现。  
  
  
注：PCSA参考ARM规范文档  
  
《  
DEN0050D_Power_Control_System_Architecture.pdf》可以去ARM官网下载。  
  
PCSA描述了一种使用标准基础设施组件、低功耗接口和相关方法进行功率控制集成的方法。PCSA基于ARM的组件实现，规范包括：  
- **电压、电源和时钟的划分；**  
  
- **电源的状态和模式；**  
  
- **ARM电源控制框架和集成规范；**  
  
- **ARM特定组件的电源和时钟集成；**  
  
- **带有低功耗Q-channel和P-channel接口的IP。**  
  
> 什么是ARM主推的SCP  
> PCSA 定义了系统控制处理器 (SCP) 的概念，一般是一个硬件模块，例如cortex-M0微处理器再加上一些外围逻辑电路做成的功耗控制单元。SCP用于从应用程序处理器中抽象出电源和系统管理任务，配合操作系统的功耗管理软件或驱动，来完成顶层的**功耗控制**。  
  
  
![](b97716821d4df9f18732acc605c89d38.other)  
- **AP**软件是SCP服务的请求者。  
  
- 系统中的其他  
Agent也可以请求SCP的服务。代理例如一个modem子系统，或者其他的硬件模块。  
  
- **SCP**基于处理器，有自己的固件，控制自己的一组硬件资源，例如本地私有内存、计时器、中断控制以及系统配置、控制和状态的寄存器。  
  
- 最底层是**SCP**控制的硬件资源，例如时钟源、电源域门控、电压电压和传感器等  
  
**SCP** **提供的服务：**  
1. **系统初始化**：SCP负责通电复位系统初始化任务，从主系统和AP核心电源域的通电顺序到AP启动。  
  
1. **OSPM定向操作**：SCP在OSPM指导下执行电压供应变化、电源控制操作和时钟源管理。这些服务也可以被其他请求的Agent使用。  
  
1. **对系统事件的响应**：  
  
1. 计时器事件：SCP有本地计时器资源，可用于触发系统唤醒和任何周期性动作，如监控。  
  
1. 唤醒事件：响应唤醒请求，包括由路由到断电核心的中断引起的GIC唤醒请求，以及来自其他代理的系统访问请求。  
  
1. 调试访问电源控制：响应来自调试访问端口的请求和相关控件的请求，包括调试基础设施的电源管理。  
  
1. 看门狗事件和系统恢复操作：在本地看门狗超时时，SCP可以执行一个重置和重新初始化序列。  
  
1. **系统感知功能**：  
  
1. SCP可以协调来自OSPM和其他代理对共享资源的请求。例如，它可以控制到主存的路径，或进入SoC睡眠模式和退出，而不需要AP核心活动。  
  
1. SCP可负责监测传感器和测量功能。监控任务可能包括过程和温度传感器的数据收集和相关的操作，如操作点优化和报警条件。  
  
1. SCP在操作点选择中的作用可以扩展到必要时覆盖OSPM方向，以确保系统的电气和热保护。  
  
![](c937d785f88e96f0c612f9a56b4622b9.other)  
  
![](8cfe0810c9be6bd8db3d5b9ee324fb31.other)  
  
SCP的硬件实现举例：  
  
![](29f15c0257673e6d2769f229cacc35e8.other)  
  
PPU的实现：  
  
![](d294f7b248213b93020ce63a6370a826.other)  
  
电压域划分举例：  
  
![](e6ad0fabeddc403bcc1545d372676058.other)  
  
## 2.2.2 imx8q实现  
  
![](65efdae7eef3243cc2e6ee4d19ab5e9b.other)  
  
有固件的实现，这里以**imx8q**为例。除了处理器组件外，Cortex-M4子系统还具有几个平台外组件。这些平台外组件和子系统功能包括：  
- **WDOG**（看门狗）定时器  
  
- **LPI****T**（低功率定期中断定时器）定期  
  
- **定时器**服务（定时器PWM模块）和PWM服务  
  
- **LPCG**（低功耗时钟门控）本地时钟管理  
  
- **ASMC**（辅助系统模式控制）（辅助系统模式控制）TSTMR（定时器）全球定时器服务接收系统时间总线系统计数器驱动的计数器电源模式控制编程模型电源模式请求低功率总线连接到SC来支持电源模式转换重置控制和状态  
  
- **MU**（消息传递单元）跨处理器通信的两个实例 MU0在GP CM4域MU1内，有1个通道在DSC内。后者将通过异步总线进行通信。此MU专用于CM4子系统。  
  
- **LPI2C**（低功耗I2C）串行通信标准功能从模式逻辑启用TX FIFO大小4条目的RX FIFO大小4条目  
  
- **LPUART**（低功耗UART）串行通信和调试标准功能与MODEM/IrDATXFIFO大小32条目RX FIFO大小32条目  
  
- **RGPIO**（快速通用输入/输出）快速销I/O能力双访问-本地访问和远程访问能力。  
  
- **本地访问**：Cortex M4本地到子系统远程子系统：设备中的任何其他处理器。  
  
- **INTMUX**（中断Mux）来选择在子系统  
  
- **SEMA42**（硬件信号量）之外路由的本地中断，以便将HMP同步到共享资源  
  
![](4dd7db172ff4ae27216d4d22d1e6c54d.other)  
  
![](4de70834a45348b956546f6b25850748.other)  
  
电源模式：  
  
![](bc0c0f384575f1cac194ca2f1e807f54.other)  
  
clock：  
  
![](2eabc7b1cca72eb0a94096ec29ced887.other)  
  
RESET：  
  
![](4c299670ff53de2298b98e668ced6b15.other)  
  
唤醒源：  
  
![](2e9cc05dccdd16eb97679dd1b4c02ace.other)  
  
内存访问：  
  
![](c1fb557c1439564aa0930c1004189f7c.other)  
# 3. 软件部分  
  
这部分就是之前关于SCP的一系列文章，这里摘抄出来一些  
## 3.1 ARM SCP入门-简介和代码下载编译  
  
  
![](ad52766c1f1af967288df7e1c01e7d1a.other)  
  
SoC诞生后，一个问题愈发的严重，就像“  
**一个和尚挑水吃，两个和尚抬水吃，三个和尚没水吃**”，模块多了就会有资源的争夺。  
  
CPU上的OS软件之前一直是皇帝般的存在，硬件之上都自己掌控，现在不同了，出现了藩王，像GPU各种人工智能专属的NPU，地平线自己还命名了一个BPU，总之各种**PU**一堆，CPU还是皇帝，但是其他PU拥有自己独立的硬件和OS就像藩王，有点不受控啊。  
  
争夺最厉害的就是电源，这可是大奶妈，然后就是存储、时钟、传感器等。  
  
这时候CPU皇帝很头大了，需要搬出来**太上皇**了，就是我们本篇介绍的**SCP**（**system control** processor）。  
  
那么CPU可以代理太上皇吗，答案是不能，有的情况下比如休眠关机，CPU都得关了但是还有的NPU还在运行，CPU还没那个资格统领全局。  
  
上面图里面根据网络小说的名字，看来作者知道**太上皇**才是权利巅峰，从而意淫夺舍，夺舍在计算机里面算是黑客入侵控制了，但是SoC里面这个太上皇可不好夺舍，是极度安全的幕后人物，拥有自己的全套基础设施，而又让你甚至感觉不到他的存在。  
  
但是当你一直沿着软件  
**OS-》ATF**往下分析发现还有这个**幕后黑手**SCP。  
  
  
可以在ARM官网下载PCSA规范文档：https://developer.arm.com/documentation/den0050/d/?lang=en  
  
官方开源代码路径：https://github.com/ARM-software/SCP-firmware，代码下载：  
```
git clone https://github.com/ARM-software/SCP-firmware.gitgit submodule update --init

```  
  
**实时功能（runtime services）：**  
- Power domain     management（电源域管理）  
  
- System power     management（系统电源管理），涉及开关机  
  
- Performance     domain management (Dynamic voltage and frequency scaling)，性能管理，这个主要就是ddr的调频了（调频对应电压）。  
  
- Clock     management（时钟管理），Linux中也有，这里只提供重要的时钟管理  
  
- Sensor     management（传感器管理）  
  
- Reset domain     management（域重置管理）  
  
- Voltage     domain management（电压域管理）  
  
**系统相关功能（system services）：**  
- 系统初始化，启用应用核心引导  
  
- 系统控制和管理接口(SCMI，平台端)  
  
- 支持GNU Arm嵌入式和Arm Compiler 6工具链  
  
- 支持具有多个控制处理器的平台  
  
## 3.2 ARM SCP入门-framework框架代码分析  
  
![](677371a2c6b2f436182608dc15c6457b.other)  
  
SCP的每个**功能**都实现为一个单独的**module**，module间**耦合性**尽量低，确保安全特性，通常固件所需的整体功能应来自模块之间的交互。module间隔离就像上图中的**狗咬架**，一旦伸手产生交互就祸福不能预测了，所以加上**栏杆**，**规定**好那些module间可以交互伸手，这都是通过**API**函数实现的，在系统初始化的时候设**定死**，下面模块间绑定章节会讲到。  
  
SCP中的module分为两部分：在代码根目录module文件夹下，共**77**个公共模块，另外每个产品下面还有module，小100个可真不少。  
  
![](b29555dd748259fd5a6287255503d3bc.other)  
  
软件分层：  
  
![](c1578eca65679f376521bfedd76e0c6f.other)  
  
bind：  
  
![](0e5f8cd277711c3337957039c5538412.other)  
## 3.3 ARM SCP入门-AP与SCP通信  
  
![](64421a8ac0163da591248e36f73eda84.other)  
  
电源管理相关软件协议栈：  
  
![](a9729b2ba68f7e92172034ddbd4b34c8.other)  
  
当Linux想要关机或者休眠的时候，这涉及到整个系统电源状态的变化，为了**安全性**  
Linux内核没有权利去直接执行了，需要陷入到**EL3等级**  
去执行，可以参考之前文章[ARM ATF入门-安全固件软件介绍和代码运行](http://mp.weixin.qq.com/s?__biz=MzUzMDMwNTg2Nw==&mid=2247484384&idx=1&sn=c6a2c66b967a28f8f46430263bad7df6&chksm=fa5285c4cd250cd27a333f15bfcef80e8a8f92ac9afe8ac766f93e75a0dbc7500de2d4df0eff&scene=21#wechat_redirect)  
  
，在EL3中处理的程序是**BL31**  
，把SMC系统调用的参数转化为PSCI协议去执行，这时如果有SCP那A核就憋屈了，自己没权利执行需要通过**SCMI**  
协议上报给SCP了。这就是整个过程的软件协议栈如上图中：  
- **用户层**：首先用户发起的一些操作，通过用户空间的各service处理，会经过内核提供的sysfs，操作cpu hotplug、device pm、EAS、IPA等。  
  
- **内核层**：在linux内核中，EAS（energy aware scheduling）通过感知到当前的负载及相应的功耗，经过cpu idle、cpu dvfs及调度选择idle等级、cpu频率及大核或者小核上运行。IPA（intrlligent power allocation）经过与EAS的交互，做热相关的管理。  
  
- **ATF层**：Linux kernel中发起的操作，会经过电源状态协调接口（Power State Coordination Interface，简称PSCI），由操作系统无关的framework（ARM Trusted Firmware，简称ATF）做相关的处理后，通过系统控制与管理接口（System Control and Management Interface，简称SCMI），向系统控制处理器（system control processor，简称SCP）发起低功耗操作。  
  
- **SCP****层**：SCP（系统控制处理器system control processor）最终会控制芯片上的sensor、clock、power domain、及板级的pmic做低功耗相关的处理。  
  
**总结：**   
**用户进程 --sysfs--> 内核（EAS、IPA）--PSCI--> ATF --SCMI-->SCP --LPI--> 功耗输出器件**  
  
SCMI协议：  
  
![](8eef6bf392d75b0dde642f1c0c0a4a0f.other)  
  
***设计时一些要点：**  
- 电源域和电压域划分  
  
- 电源轨及上下电时序明确  
  
- 电源模式根据需求确定，并明确某种模式那些关闭和打开，及模式转换条件图  
  
- 确定好PMU跟其他子系统的Mailbox通信通路  
  
- 中断、GPIO等的资源分配  
  
- 安全世界内存和寄存器的访问，如果M核32bit访问64bit地址的需要转换  
  
- SRAM和共享内存的分配使用  
  
- PPU负责电源域的管理，需要根据power domain确定好使用多少个及连线，决定电源模式的灵活性  
  
- clock、reset控制全SoC的方法梳理及是否一些分散在各个子系统内部，一般全局的放SCP  
  
- 使用reset的时候需要对子系统的总线进行清空，特别是NoC总线  
  
- CRU和PLL的分配，对于比较重要的子系统，例如FSI需要有独立的CRU；对于DDR也需要独立的CRU。CRU内部需要有若干个PLL提供频率，并提供clock gating功能。  
  
- 时钟树和复位树的梳理，并制定对应的寄存器控制  
  
- IST及STL测试程序的集成  
  
> 后记：  
> 又是一篇概念很大的文章，其中一段话就能独立展开写一篇。  
> 文章标题改为AI SoC之后，还没怎么写过**AI的东西**，但是AI之外的都是为AI服务的。例如A核可以运行AI的APP，这里是SCP可以控制AI相关子系统的时钟复位，及之前写的其他部分。后续开始**发力AI**。  
  
  
“啥都懂一点，啥都不精通，  
  
干啥都能干，干啥啥不是，  
  
专业入门劝退，堪称程序员杂家”。  
  
欢迎各位有自己公众号的留言：**申请转载**！  
  
纯干货持续更新，欢迎**分享给朋友**、**点赞、收藏、在看、划线和评论交流**！  
  
彩蛋：  
1. 本公众号提供微信技术交流群，一起探讨汽车软件技术（先加微信：thatway1989，备注感兴趣的技术方向）。  
  
1. 有需要**投放广告、商业合作**的也可以联系博主。  
  
1. 赞赏1元钱交个朋友  
  
