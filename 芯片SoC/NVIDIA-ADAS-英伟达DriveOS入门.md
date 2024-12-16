
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0167001f230d4cefa29edc0687665b4e~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1218&h=428&s=102945&e=png&b=fcfcfc)

之前的文章中介绍过汽车中需要3种OS：智能座舱、智能驾驶、车控。

其中智能驾驶一直都是当今智能汽车最重要的一个竞争领域，也是智能车愿景的开端：无人驾驶。车控属于旧汽车电子系统的代表，经历了多年的积淀比较稳定也比较容易买到，智能座舱手机的技术直接顶上也可以用，智能驾驶最有噱头可以搞，不管客户用不用，这个谁搞出来就是牛B，特别是如今的AI时代战争的白热化比拼：大算力硬件+大数据学习算法，牵扯到国运之争，必须大干一场。特斯拉、华为、蔚小理等无疑投入最大的方向都是智能驾驶，算力多少TOPS，然后各种摄像头红外雷达等自动算法，基本可以决定一辆车的价格。

如果不是芯片研发和AI算法研发人员，对于普通软件开发人员我们还是要把焦点聚集到智驾OS上来进行学习，来支撑各种智能驾驶应用的实现。这里找到一个很好的学习对象英伟达的DriveOS。

>为什么是英伟达？
>
>可以说时代选择了英伟达。1999年NVIDIA发明了GPU极大地推动了 PC 游戏市场的发展，重新定义了现代计算机图形技术，并彻底改变了并行计算。英伟达基于强大的GPU和高性能计算开发了各种AI相关产品，其中包括最新的英伟达赋能自动驾驶领域的NVIDIA DRIVE平台。

官方文档：https://developer.nvidia.com/docs/drive/drive-os/archives/6.0.4/linux/sdk/index.html

# 1. ADAS介绍
<p align=center><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d96ff27a71fd484eaaafd945c48b2332~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=692&h=482&s=116269&e=png&b=fdfcfc" alt="image.png" width="70%" /></p>

上图中将自动驾驶分为L0-L5级六种不同级别，根据“开启自动驾驶功能后，驾驶员是否应该处于驾驶状态”这一标准，自动 驾驶以L3级为分界线，分为辅助驾驶和自动驾驶。理论上讲，只有L3级以上 （包括L3级）才能称之为自动驾驶。

>自动驾驶汽车定义：
>
>搭载先进车载传感器、控制器、执行器等装置，并融合现 代通信与网络技术，具备复杂环境感知、智能决策、协同控制等功能，实现车与 X（人、车、路、云端等）智能信息交换、共享，并最终可实现替代人来操作的 新一代汽车。自动驾驶汽车又被称为智能网联汽车。


<p align=center><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0fd3f485cf414df9a754e428e9e8deb7~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=643&h=355&s=122815&e=png&b=f9f8f8" alt="image.png"  /></p>

自动驾驶系统是相当于人类驾驶员的存在。类比人类执行驾驶动作的 全过程，自动驾驶汽车也需要“看清”周围路况，将信息传导至“大脑”思考接 下来最合理的路线，最终做出决定“控制”车辆行驶路径。因此，业界普遍认为， “感知-决策-执行”是自动驾驶汽车最为重要的三大系统，分别对应人类的“眼 睛-大脑-四肢”三种人体部位。

- ADAS，即高级驾驶辅助系统，也被称为主动安全系统。它利用安装在车上的各式传感器，第一时间收集车内外环境数据，识别或侦测追踪静止或行进的物体，使驾驶者在最快的时间内察觉可能发生的危险，引起注意，提高安全性。

- ADAS包含了许多不同的技术，例如ACC自适应巡航、AEB/CMbB自动紧急制动、TSR/TSI交通标志识别、BSD/BLIS盲区检测、LCA/LCMA变道辅助、LDW车道偏离报警、LKA/S-LKA车道保持辅助以及BA/CTA后向辅助等。

在自动驾驶中，ADAS起到了预防和辅助的作用，在紧急情况下，能在驾驶员主观反应之前由系统主动判断并做出防御措施。

# 2. DriveOS介绍

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b79960667251437cb8955f4ca6d2421f~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=633&h=391&s=58270&e=png&b=fdfdfd)

上图中是英伟达的软件协议栈，可见其芯片有三部分：MCU、FSI、Orin，也就是这个SoC是多核的，并且运行多个OS的，MCU上运行的AUTOSAR就是车控OS里面的东西，Orin这个应该是ARM架构的芯片+GPU其上运行的Linux操作系统，然后CUDA发挥显卡的算力优势支撑智能驾驶。

对于软件我们关注的首先就是Linux，这个可以说是其核心OS，Linux的技术很成熟，资料很多这里不多说明。然后就是CUDA来释放硬件的算力支撑智能驾驶APP，可以说其是英伟达的核心技术-算力。

英伟达的软件协议栈特性：
1.  支持大量传感器，包括Camera、Lidar、Radar、GPS、IMU
1.  支持大量的外部接口，包括PCIe、MIPI、CAN、Ethernet、NOR、eMMC、GPIO等
1.  车规级自驾SoC和车规级MUC，SoC内包括CPU、GPU、DLA、PVA、ISP、Codec等
1.  支持Hypervisor虚拟化和AutoSAR框架
1.  支持车规级Drive OS、QNX、Linux
1.  支持大量API，包括OpenGL、EGL、CUDA、cuDNN、TensorRT、NvMedia等
1.  支持大量自驾算法和应用，包括感知、地图、规划、执行等方方面面


参考官网文档：https://developer.nvidia.com/docs/drive/drive-os/archives/6.0.4/linux/sdk/common/topics/archi/PlatformSoftwareStacks1.html

对于硬件一个更加详细的图：

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/886e702222534e47b203ef4097716beb~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=900&h=423&s=291361&e=png&b=faf6f4)

这个估计就是Orin芯片里面的具体内容：12个ARM A核，然后直接2048个GPU，战力值干到满！要想驾驭这一堆硬件那DriveOS就登场了，其中核心是Linux OS。

DriveOS结构图：

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2dc1458ed0fa4e9ea7b559e562fd0e40~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1440&h=679&s=619435&e=png&b=efedec)

可见这里说的DriveOS是一个大OS的概念：不仅包括内核也包括其上的应用和底层的bootloader、Hypervisor等所有软件，而这些软件在车规上都有一些相关的认证。

在Drive OS之上是Nvidia完全自己开发的DriveWorks中间件，它最重要的作用就是为自驾提供核心的感知->规划->执行相关的服务，其中感知又是负载最重的部分，包括了sensor的抽象层，sensor静态和动态标定，sensor数据的采集等，根据Radar和Lidar数据构建的点云处理，以及感知核心-神经网络框架。在规划和执行环节，Nvidia开发了一套Egomotion算法，其中结合了SLAM、光流、追踪等模块来预测车的位姿和速度、加速度等物理信息，再通过Vehicle IO模块读取车的底盘信息后决策下一步机构操作。

有了OS和中间件，自然就能方便的开发出各种应用了。Nvidia根据车载服务需求开发了两套软件供开发者使用，包括自驾部分（Drive AV）和座舱部分（Drive IX）。需要注意的是，虽然Nvidia提供了座舱软件服务，但从整个软件栈来看，它缺少Android的支持或者第三方APP的支持，多屏显示部分的支持也缺失。所以，个人认为Nvidia的座舱软件部分提供的是与自驾类似的感知部分，这也许能弥补某些座舱SoC算力不足的场景。这说明Nvidia的定位很清楚，它不想触及更上层的应用开发，而是聚焦大算力平台建设，发挥自己的强项。

**韭菜别走，镰刀来了：**

虽然Nvidia提供了几乎所有自驾所需要的硬件和软件，但是软件栈部分是基于模块化的，开发者可以根据自身的优势购买其中任何模块，做出有竞争力的产品。如果实力不足也不要紧，可以购买全家桶。所以，Nvidia在自驾上的服务做得非常周到，这是Nvidia在技术栈上的实力，也是老黄为它的刀法留下了无限可能，只要你出钱，总有一套组合满足你的需求！

老美的这一套收费策略的一个关键技术就是：IDE，做成界面化的，只需要点一点就可以了，也不让你看到代码和编译验证过程，你也学不会。然后直接扔给国内分销商，按套卖按模块卖。最后NVID还有更绝的，就是数据自动驾驶最大一块工作量在采集存储数据->训练网络->部署网络这个循环不停的迭代，这块蛋糕岂能丢了？当然训练本来就是Nvidia的强项，但是自驾训练更难的是长尾效应，采集不常见和危险场景下的数据成本是无法承担的，即便拥有几百万俩上路的Tesla也需要“人造”来解决问题，对于还没有量产的车厂，仿真就是必不可少的了。


![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a705f1ab755f445487e261b852b297c5~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=820&h=431&s=139036&e=png&b=f7f6f6)

自驾仿真环境是Nvidia另一个未来级产品的一个应用而已，这个产品是如今火爆的Metaverse概念的一个平台级产品，老黄给它取了个宏大又类似的名字Ominiverse。基于先进的光追渲染和AI一体平台能力，Nvidia希望构建各种应用场景的孪生数字世界（Digital twin），而城市交通网正是一个难度很大但是价值也巨大的应用场景。

对于自驾来说，最重要的是真实性。包括光影的真实性，车、人、路、标识、物的物理真实性，被仿真车量从各种sensor到底盘到控制的真实性。这些对仿真平台的算力和算法是极大的考验。另外一个要点是，仿真环境是否能迅速复现问题触发时的世界，这对于问题的解决也至关重要。

到此，Nvidia闭环了自驾在线和离线，软件和硬件各个方面的服务。Nvidia自驾平台的确走在了行业最前沿，在没有超越之前，我们需要的更多是学习，学习，学习！

# 3. DriveOS基础服务

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8a2afd70ab84920b9442aef2b599596~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=900&h=527&s=28527&e=png&b=bcbbbb)

NVIDIA DRIVE AGX ™平台基础服务运行时软件堆栈为平台的所有组件提供基础架构。借助此基础架构，Guest操作系统可以在硬件上运行，并由虚拟机管理程序管理硬件资源的使用。

- Hypervisor：将系统分为多个分区的可信软件服务器。每个分区可以包含一个操作系统或一个裸机应用程序。Hypervisor提供 CPU 和内存资源的分区虚拟视图、 硬件交互、运行列表、通道恢复等
- guest OS：分配Guest OS需要控制的外设。
- Services：DRIVE 更新服务。
- [Bootloader](https://developer.nvidia.com/docs/drive/drive-os/archives/6.0.4/linux/sdk/common/topics/bootloader_setup/BootloaderProgramming1.html)：在引导期间运行以加载固件组件的固件，例如引导映像、分区映像和其他固件。
- [Trusted OS](https://developer.nvidia.com/docs/drive/drive-os/archives/6.0.4/linux/sdk/common/topics/security_concepts/TrustedOS84.html)：PCT中的可信操作系统配置描述了虚拟可信操作系统设备的配置。
- Orin SoC：片上系统硬件资源。

# 4. NvMedia架构

<p align=center><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5ea0586ddb9941a889abd2b2226040a1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=510&h=654&s=35558&e=png&b=f0ebe9" alt="image.png"  /></p>

NvMedia 提供强大的多媒体数据处理能力，可在 NVIDIA DRIVE ® Orin ™设备上实现真正的硬件加速。借助 NvMedia 和 Orin 固件组件，多媒体应用程序支持多个同步摄像头馈送以进行同步处理。NvMedia 功能包括：

-   供应用程序使用的强大图像处理和传感器控制块。
-   硬件表面处理所有类型的图像格式，如 RGB、YUV 和 RAW。
-   用于图像捕获、处理、加速、编码以及与其他库互操作的功能组件。

应用程序利用 NvMedia 应用程序编程接口 (API) 来处理图像和视频数据。此外，NvMedia 还可以将图像数据路由到其他组件或从其他组件路由图像数据，例如 OpenGL ES 和 NVIDIA ® CUDA ®。
Tegra 硬件           | 描述                                                         |
| ------------------ | ---------------------------------------------------------- |
| 视频输入（VI）           | 从相机接收 CSI 数据。                                              |
| 图像信号处理器（互联网服务供应商）  | 根据从图像传感器捕获的图像数据生成经过处理的图像。例如，它可以进行像素级更改，例如反转像素位、自动曝光和白平衡校正。 |
| NVIDIA 编码器 (NVENC) | 将原始图像数据转换为支持的图像格式之一。                                       |
| NVIDIA 解码器 (NVDEC) | 将编码图像数据转换为原始图像数据。                                          |
| 视频交错合成器 (VIC)      | 转换视频数据以进行去隔行、合成和格式转换。                                      |
| 光流加速器 (OFA)        | 加速帧之间的光流和立体视差计算。

# 5. 关于一些软件规格亮点

首先，DRIVE已针对自动驾驶系统的设计、管理和存档的全面安全认证方法体系的建立制定了步骤。

## 5.1 硬件的安全技术

这部分主要针对硬件冗余，硬件平台将包含多种处理器，以保证在某些故障时保证机器运行。据官方介绍，这些冗余处理器包括NVIDIA 自主设计的 NVIDIA Xavier相关 IP，并涵盖 CPU 和 GPU 处理器、深度学习加速器、图像处理 ISP、计算机视觉 PVA 和视频处理器。内存和总线中包括锁步处理（lock-step，表示微控制器同时并行运行同一组操作，锁步操作的输出可以通过所谓的“冗余校验单元”进行对比，以此测定是否已出现故障）和纠错码，内置测试功能。

ASIL-C 级 NVIDIA DRIVE Xavier 处理器和具有适当安全逻辑的 ASIL-D 级安全微控制器均可实现系统最高安全级——ASIL-D 级。

## 5.2 软件的安全技术
软件层面，很多安全架构来自英伟达的合作伙伴，例如黑莓QNX 以及TTTech。据官方介绍，DRIVE OS 系统软件集成了经ASIL-D 安全认证的 BlackBerry QNX 64 位实时操作系统，以及 TTTech 的 MotionWise 安全应用程序框架，后者对系统中的每个应用程序进行了独立分装，将彼此隔离，同时提供实时计算能力。

此外，NVIDIA DRIVE OS 可全面支持 Adaptive AUTOSAR，这也是汽车系统架构和应用框架的公开标准。

# 6. NVIDIA DRIVE平台黑科技总结：

NVIDIA DRIVE平台主要包括包括DRIVE Orin芯片 、DRIVE AGX Orin车端集中式AI 计算平台， DRIVE OS 基础软件平台、Driveworks中间件、DRIVE AV自动驾驶软件栈， DRIVE Hyperion 数据采集和开发验证套件 、DRIVE Constellation虚拟仿真平台和DGX高性能AI训服务器。

产品很多很全，很费钱！

## 6.1 DRIVE Hyperion
DRIVE Hyperion 是NVIDIA 自动驾驶数据采集和验证开发套件，该套件包含NVIDIA DRIVE AGX 开发平台、主流传感器比如Camera，Radar，Lidar，GPS，IMU等硬件。同时，也包括DRIVE OS基础软件平台 、Driveworks中间件及数据采集相关的软件。 我们的客户、合作伙伴可以基于DRIVE Hyperion 开发套件快速搭建自动驾驶数据采集车和测试车辆，从而进行多传感器数据采集和自动驾驶算法测试验证。

## 6.2 DGX A100 AI集群
DGX A100是全球首款高性能AI计算机，内部集成A100 Tensor Core GPU可达到640GB GPU 内存，内置 Mellanox ConnectX-6 InfiniBand超高带宽以太网适配器，其双向带宽峰值为 500Gb/s。基于高性能的DGX AI服务器，客户可以进行深度网络学习的训练、推理和数据分析，同时多台DGX A100再结合NVIDIA DGX SuperPOD™  、NVIDIA BlueField® 数据处理单元 DPU及 NVIDIA Base Command™ 就可以构建超级计算机或者AI 集群，为具有挑战性的自动驾驶海量数据进行深度学习网络模型训练和建图提供出色的基础设施和灵活可扩展的AI计算性能。

## 6.3 DRIVE Constellation仿真平台
DRIVE Constellation仿真平台，主要完成对各种虚拟场景的渲染、仿真，产生模拟传感器数据，它主要提供两大功能： 1) 虚拟仿真- DRIVE Constellation Simulator上运行DRIVE Sim 软件仿真虚拟世界、交通场景和道路上的车辆行驶。虚拟汽车在仿真环境中行驶可产生Camera, Radar, Lidar, GPS 和IMU 等模拟传感器数据。这些模拟传感器数据发送到DRIVE Constellation Computer 内的DRIVE AGX车端计算平台进行感知、定位、规划和产生决策控制数据并回传给DRIVE Constellation Simulator上进行评估验证。2）供数据回放- 自动驾驶车辆数据采集过程中物理传感器的真实数据也可以通过DRIVE Constellation Simulator 进行数据回放输出给DRIVE Constellation Computer 内的DRIVE AGX 车端计算平台进行感知、定位、规划和产生决策控制数据并回送DRIVE Constellation Simulator上进行评估验证。DRIVE Constellation™ 仿真平台提供可扩展、全面且多样化的测试环境。借助开放的模块化架构，DRIVE Sim 软件可让客户利用自己的仿真模型或生态合作伙伴的自定义车辆、环境、传感器或交通场景。

## 6.4 DRIVE AGX AI计算平台
DRIVE AGX平台主要是给自动驾驶汽车提供高性能的车端AI计算平台。经过仿真测试后的深度学习网络模型和算法，可以部署在 DRIVE AGX 车端平台进行相应的自动驾驶功能道路测试和验证。此外，在DRIVE AGX车端平台之上，也可以创建或绘制世界模型并显示当前车辆的3D 环绕模型。自动驾驶车辆在道路测试验证的同时也可以进行传感器数据采集，因此，数据采集、数据训练，模拟仿真，自动驾驶道路测试验证就形成了一个数据闭环。

## 6.5 DRIVE ORIN芯片
2019年我们发布了DRIVE ORIN芯片，主要是为了满足L2辅助驾驶，L2+ 高阶辅助驾驶和高阶自动驾驶的需求。Orin由245亿个晶体管构成，集成12个64位的ARM A78 CPU核， 提供228K DMIPS CPU计算能力；Orin Tensor Core GPU 和DLA 提供254 TOPS INT8 AI 推理能力；Orin提供高达205 GB/S的内存带宽并内部集成4路万兆以太网；Orin支持H264/H265/VP9 格式的8K 像素 30帧/秒的图像解码和4K 像素60帧/秒 图像编码；Orin的功能安全岛集成4个Lock-Step Cortex-R52 核并达到随机硬件失效ASIL-D。最重要的是Orin芯片严格按照ISO26262功能安全设计开发，可达到随机硬件失效ASIL-B 和系统级ASIL-D 功能安全认证。我们基于Orin芯片开发硬件架构可扩展和软件可编程的自动驾驶集中式架构AI计算平台，该AI计算平台单颗Orin芯片提供 254 TOPS INT8 AI 推理能力可以满足L2辅助驾驶、 L2+高阶辅助驾驶产品需求。多个Orin芯片或者Orin 加安培GPU 可以构建超过2000 TOPS INT8 算力的AI计算平台以便满足RoboTaxi 产品需求。

## 6.6 ECU扩展兼容其他软硬件系统
当前传统的L2辅助驾驶系统一般由多个ECU构成，包括360环视、ADAS域控制器、Smart Camera。基于DRIVE Orin 可扩展的参考平台设计， 我们的客户可以根据不同车型需求快速设计开发灵活可扩展、统一硬件和软件架构的自动驾驶集中式AI计算平台来满足L2 辅助驾驶至L4高阶自动驾驶产品功能需求。

刚才谈到了ORIN芯片从单颗芯片提供254Tops推理能力，借助可扩展的 DRIVE Orin产品系列，客户可以在多个车型系列中利用DRIVE Orin硬件平台的灵活扩展性和统一架构的巨大优势速构建智能驾驶域控制器硬件平台，同一硬件架构的域控制器平台可以兼容从L2辅助驾驶、L2+高级辅助驾驶、L4高阶自动驾驶和无人驾驶系统，从而大大加速了域控制器硬件平台开发速度并降低硬件研发测试成本和软件维护成本。

基于ORIN灵活可拓展性，我们也开发了对应的基础软件平台和中间件。我们的客户可以通过统一API接口的SDK快速开发自己的应用程序和算法，为了方便客户更好地使用DRIVE OS，我们进行了抽象封装，提供模块化抽象封装库，包括硬件传感器抽象层、图像处理和点云处理，并提供方便使用的计算图框架。我们的客户可以利用DRIVE OS 的这些优势快速构建可最大化复用的应用软件及算法，同一软件架构的域控制器平台软件可以支持从L2辅助驾驶、高阶自动驾驶和无人驾驶系统，从而加速了软件产品开发迭代速度并且降低软件研发和测试验证成本。

## 6.7 集中式构架
为了满足集中式架构，我们的DRIVE OS平台从设计角度也考虑了SOA理念，所有软件基于模块化设计。DRIVE OS是英伟达为车端芯片开发的模块化的AI计算平台软件。深绿色部分是 ORIN芯片，浅绿色是DRIVE OS各个软件模块，灰色是第三方软件或者客户自己开发的软件模块。为实现DRIVE OS 功能安全和软硬件相互隔离，Orin SOC 上运行NVIDIA自研的符合功能安全的实时微内核Type 1 Hypervisor。Hypervisor 之上运行符合功能安全的QNX QOS作为Guest OS。Hypervisor 之上还有负责OTA更新的DRIVE UPDAE Service 和Foundation Services 等多个虚拟机。NVIDIA 在QNX Guest OS 之上开发了NvMedia、NvStreams、VulkanSC SDK和CUDA 、TensorRT AI 引擎加速库。在ORIN功能安全岛可以运行OEM跟功能安全相关的算法，比如说车控算法，比对算法，传感器后融合算法。另外，在功能安全岛上运行英伟达自己的Safety框架，主要是对ORIN芯片进行实时监控，硬件模块以及寄存器状态，同时也对DRIVE OS软件进行监控。

## 6.8 NVDIA Driveworks SDK

NVDIA Driveworks SDK主要实现对Camera、毫米波雷达、激光雷达、GPS 和IMU 等传感器的抽象封装，并支持图像处理和点云预处理。当自动驾驶汽车在路上行驶一段时间，某些视觉传感器可能因为振荡原因产生图像输出畸变，我们可以利用Self Calibration进行在线标定。同时还提供对于当前车辆位置的估计和[预测](http://gaia.gasgoo.com/forecast/production)，基于DRIVE Works采集到的传感器数据，我们在DRIVE AV层进行相应障碍物感知、车道线感知、交通灯的感知，同时基于这些感知结果结合高清地图实现定位并创建世界模型，最后再通过行为规划，车道线规划、路径规划和车辆控制。

## 6.9 DRIVE Works
基于DRIVE Works，我们针对自动驾驶的典型使用场景和Corner Case场景开发了多种丰富的神经网络，包括障碍物感知、车道线检测、交叉路口感知、距离感知、交通牌以及交通灯的感知以及对驾驶员的监测等常用网络，同时我们也开发了针对交警手势指挥的检测网络、远光灯的检测网络、相机失明检测网络等等。

## 6.10 总结
NVIDIA DRIVE 是我们为价值数10万亿美元的交通运输行业推出的端到端自动驾驶平台，从DRIVE Orin/Atlan芯片 、DRIVE AGX硬件参考平台，到DRIVE OS、Driveworks、DRIVE AV自动驾驶软件栈再到DRIVE Hyperion 数据采集和开发验证套件 、DRIVE Constellation虚拟仿真平台和DGX高性能训练服务器，我们已经在各个层面与行业的客户、合作伙伴展开深度合作。NVIDIA将继续为更安全、更高效的自动驾驶提供集中式高性能AI计算平台，从而使车辆能够实时运行自动驾驶所必需的各种冗余和多样化的深度学习网络模型和算法。

参考：https://auto.gasgoo.com/news/202108/28I70270155C103.shtml

>后记：
>
>强大的对手值得学习，英伟达这波操作布局可以说强大的可怕，文中出现的各种词汇也非常的多，大家多查询多学习吧。牢记英文官网始终是获取一手资料的地方，要深入研究就看[DriveOS官网资料](https://developer.nvidia.com/docs/drive/drive-os/archives/6.0.4/linux/sdk/index.html)吧，非常的全。

<p align=center>“啥都懂一点，啥都不精通，</p>

<p align=center>干啥都能干，干啥啥不是，</p>

<p align=center>专业入门劝退，堪称程序员杂家”。</p>

<p align=center>欢迎各位有自己公众号的留言：申请转载，多谢！</p>

<p align=center>后续会继续更新，纯干货分析，欢迎分享给朋友，欢迎点赞、收藏、在看、划线和评论交流！</p>
