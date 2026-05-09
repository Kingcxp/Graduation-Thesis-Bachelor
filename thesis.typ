#import "@preview/modern-nju-thesis:0.4.1": documentclass

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// 你首先应该安装 https://github.com/nju-lug/modern-nju-thesis/tree/main/fonts/FangZheng 里的所有字体，
// 如果是 Web App 上编辑，你应该手动上传这些字体文件，否则不能正常使用「楷体」和「仿宋」，导致显示错误。

#let (
  // 布局函数
  twoside, doc, preface, mainmatter, appendix,
  // 页面函数
  fonts-display-page, cover, decl-page, abstract, abstract-en, bilingual-bibliography,
  outline-page, list-of-figures, list-of-tables, notation, acknowledgement,
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  // anonymous: true,  // 盲审模式
  twoside: true,  // 双面模式，会加入空白页，便于打印
  // 你会发现 Typst 有许多警告，这是因为 modern-nju-thesis 加入了很多不必要的 fallback 字体
  // 你可以自定义字体消除警告，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: (name: "Times New Roman", covers: "latin-in-cjk"), "FZKai-Z03S")),
  info: (
    title: ("基于 Moneta 的", "GPU驱动模糊测试框架"),
    title-en: "Fuzzing GPU drivers with Moneta",
    grade: "2026",
    student-id: "221900018",
    author: "陈骐",
    author-en: "Ming Xing",
    department: "智能软件与工程学院",
    department-en: "School of Intelligent Software and Engineering",
    major: "软件工程（智能化软件）",
    major-en: "Software Engineering (Intelligent Software)",
    supervisor: ("钮鑫涛", "助理教授"),
    supervisor-en: "Assistant Professor Xin-Tao Niu",
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: "Professor My Supervisor",
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)

#show: doc

// 封面页
#cover()

// 声明页
#decl-page()


// 前言
#show: preface

// 中文摘要
#abstract(
  keywords: ("Moneta", "GPU", "模糊测试", "驱动程序", "内核态", "Linux系统")
)[
  在异构计算成为算力核心支撑的当下，GPU 已从传统图形渲染场景，全面延伸至深度学习、高性能计算、科学仿真、自动驾驶等关键领域，GPU 驱动作为衔接上层应用与底层硬件的核心中间件，其安全性、稳定性与可靠性直接决定了上层全栈系统的正常运行。GPU 驱动兼具用户态 runtime 与内核态模块的复杂架构，代码规模庞大、逻辑分支密集、硬件相关的状态机复杂度极高，同时 NVIDIA、AMD 等主流厂商的核心驱动均为闭源形态，给传统白盒测试、静态分析等方法带来了极大的局限性。

  模糊测试作为当前最有效的自动化漏洞挖掘技术之一，已成为 GPU 驱动安全测试的核心手段，但现有 GPU 驱动模糊测试相关方案仍存在显著的架构短板：其一，现有方案多面向特定场景（如 AI 推理、图形 API）定制开发，通用化能力不足，跨厂商、跨驱动版本的适配成本极高；其二，多数方案对 GPU 驱动的有状态执行逻辑支持不足，难以遍历驱动深层状态机，导致核心执行路径覆盖率低，无法挖掘复杂交互场景下的深层漏洞；其三，现有方案普遍存在用户态与内核态测试割裂的问题，无法实现驱动全栈执行路径的协同覆盖，容易遗漏内核态高危漏洞；其四，现有工具的可扩展性弱，新增测试接口、变异策略与异常检测规则的门槛高，难以支撑研究者开展定制化测试。

  在此背景下，本研究基于 Moneta 项目开展 GPU 驱动模糊测试框架的设计与实现研究，具备重要的理论与实践意义。本研究将实现一套模块化、高可扩展的 GPU 驱动模糊测试框架，解决现有方案的核心痛点，实现驱动用户态与内核态的协同测试，提升 GPU 驱动漏洞挖掘的覆盖率与效率，为 GPU 驱动的安全测试与加固提供底层工具支撑，最终保障各类基于 GPU 的关键业务系统的稳定、安全运行。
]

// 英文摘要
#abstract-en(
  keywords: ("Moneta", "GPU", "fuzzing", "driver", "kernel mode", "Linux system")
)[

  In the era of heterogeneous computing, GPU has extended from traditional graphics rendering scenarios to key areas such as deep learning, high-performance computing, scientific simulation, and autonomous driving. As the core middleware connecting upper-layer applications and lower-layer hardware, GPU drivers directly determine the normal operation of the upper-layer full-stack systems. The complexity of the architecture of GPU drivers, which includes both user-space runtime and kernel-space modules, poses significant challenges to traditional white-box testing, static analysis, and other methods. The closed-source nature of the core drivers of mainstream vendors such as NVIDIA and AMD further exacerbates these challenges.

  Fuzz testing, as one of the most effective automated vulnerability mining techniques, has become a core method in GPU-driven security testing. However, existing GPU-driven fuzz testing solutions still exhibit significant architectural shortcomings: Firstly, most existing solutions are customized for specific scenarios (such as AI inference and graphics APIs), lacking generalizability and incurring extremely high adaptation costs across different vendors and driver versions. Secondly, most solutions provide insufficient support for GPU-driven stateful execution logic, making it difficult to traverse deep state machines of the driver, resulting in low coverage of core execution paths and an inability to mine deep vulnerabilities in complex interaction scenarios. Thirdly, existing solutions generally suffer from a fragmented problem between user-mode and kernel-mode testing, failing to achieve collaborative coverage of the driver's full-stack execution paths and easily overlooking high-risk vulnerabilities in the kernel mode. Fourthly, the scalability of existing tools is weak, with high thresholds for adding new testing interfaces, mutation strategies, and anomaly detection rules, making it difficult for researchers to conduct customized testing.

  Against this backdrop, this study focuses on the design and implementation of a GPU-driven fuzz testing framework based on the Moneta project, which holds significant theoretical and practical implications. This research aims to develop a modular and highly scalable GPU-driven fuzz testing framework that addresses the core pain points of existing solutions. It facilitates collaborative testing between user-mode and kernel-mode drivers, enhancing the coverage and efficiency of GPU driver vulnerability discovery. This provides foundational tool support for GPU driver security testing and reinforcement, ultimately ensuring the stable and secure operation of various GPU-based critical business systems.
]


// 目录
#outline-page()

// 正文
#show: mainmatter

// ==========================================
// 正文部分开始
// ==========================================
#show: mainmatter

= 绪论

== 研究背景与意义
随着现代计算机图形学和人工智能领域的飞速发展，图形处理单元（GPU）已经成为现代计算基础设施不可或缺的核心算力底座。其应用场景已从传统的3D图形渲染扩展到深度学习训练、大规模矩阵运算、科学仿真乃至自动驾驶等高敏感领域。为了支持这些复杂的计算负载，现代GPU驱动程序的代码库变得越来越庞大且逻辑错综复杂。作为连接用户态应用与底层硬件的关键内核级中间件，GPU驱动一旦存在内存越界、条件竞争或逻辑漏洞，攻击者便可轻易实现权限提升、沙箱逃逸甚至造成整个物理机宕机，从而带来严重的安全隐患。

模糊测试（Fuzzing）作为一种行之有效的自动化漏洞挖掘技术，在操作系统内核的安全测试中取得了巨大成功（如 Syzkaller @syzkaller）。然而，当传统的模糊测试技术应用于GPU驱动时，面临着几个致命瓶颈：强烈的硬件依赖性（难以在无GPU的服务器集群中扩展）、复杂的设备初始化状态（难以绕过浅层检查）以及低下的执行保真度。为了解决这些问题，学术界提出了如 Agamotto @song2020agamotto 等基于轻量级虚拟机检查点的测试方案，而 Yonsei SSLab 在顶级安全会议 NDSS 2025 上提出的 Moneta 框架 @jung2025moneta 则进一步将“快照重托管（Snapshot-and-Rehost）”与“记录重放（Record-and-Replay）”技术深度结合，首次实现了高保真的离体（Ex-vivo）GPU驱动模糊测试。

尽管 Moneta 展现了卓越的理论可行性，但其开源原型却缺乏工程化与通用化考量，存在严重的架构耦合（深度侵入特定版本宿主机内核）、大量的构建缺陷以及僵化的环境配置。这使得该系统几乎无法在现代通用设备上成功部署。因此，本文旨在对 Moneta 系统进行深度的工程化重构与架构优化，提出一种基于解耦虚拟通信机制和自适应容器化技术的新型部署与测试框架，这对于推动GPU驱动安全测试技术的落地应用具有极大的实践价值和现实意义。

== 国内外研究现状
GPU驱动模糊测试是当前系统安全领域的研究热点与难点，现有研究主要沿着两个方向演进：

*1. 面向硬件或API定制的传统模糊测试*：
早期的研究往往将GPU驱动视为普通的黑盒/灰盒内核模块，通过拦截或伪造特定的图形API（如 Vulkan、OpenGL）来生成测试用例。然而，由于闭源驱动内部维护着极其复杂的环形缓冲区（Ring Buffer）和异步状态机，这些传统的测试方法往往在到达深层逻辑前就被驱动的预检机制拦截。

*2. 基于虚拟机快照与状态重放的离体测试*：
为了突破硬件限制并深入驱动的深层状态，近期的研究开始探索硬件解耦的测试途径。例如，部分研究尝试剥离硬件，使用软件模拟器进行代替，但这种方式由于缺乏真实的设备响应，保真度极低。Moneta @jung2025moneta 提出的基于“在体（In-Vivo）捕获”与“离体（Ex-Vivo）重放”的技术路线，被公认为是目前解决这一困境的最优解。然而，学术界往往只关注原型的可行性，导致诸如宿主机内核强绑定等问题严重阻碍了该类技术的工业化落地。

== 本文主要工作与贡献
针对原项目存在的底层缺陷与部署障碍，本文通过重新设计通信架构和优化构建流，完成了一套高可用、自动化的GPU驱动模糊测试系统。本文的主要贡献如下：
+ *首创非侵入式虚拟串口通信架构*：彻底移除了原系统对定制版 Linux 5.19 宿主机内核的强依赖。通过引入 QEMU @bellard2005qemu 的 Virtio-serial 虚拟设备与宿主机代理（Proxy）守护进程，实现了客主机状态与宿主机控制面板的应用层解耦。
+ *全链路组件修复与测试负载扩充*：系统性修复了原版 Syzkaller 适配版本中 `syz-manager` 的调度逻辑错误与编译断层。同时，将单一的图形渲染测试负载拓展为模拟现代 AI 模型训练的复杂张量计算负载，大幅提升了测试覆盖的业务价值。
+ *参数化重构与一键式全自动构建*：将繁杂的硬件依赖（如 PCI 设备地址、驱动版本）提取为动态环境变量，并开发了状态机驱动的 `build.sh`，实现从依赖安装、快照捕获到离体变异的端到端自动化。
+ *自适应硬件感知的容器化部署*：设计并开源了具有 VFIO 直通能力的智能化 Docker @merkel2014docker 部署方案，实现了对不同物理硬件拓扑的自适应感知，将原本数天的部署周期压缩至分钟级。

== 论文组织结构
本文的组织结构如下：第一章介绍了研究的背景、现状及本文贡献；第二章详细剖析了相关技术基础及 Moneta 原版工作机制；第三章重点阐述了本文提出的基于 Virtio-serial 的通信解耦重构方案；第四章介绍了测试系统内部的逻辑修复、环境参数化与自动化构建方案；第五章详细说明了容器化部署架构，并对重构后的系统进行了全面的可用性与性能评估测试；第六章为本文的总结与展望。


// ==========================================
// 第二章 相关技术基础与Moneta原理解析
// ==========================================
= 相关技术基础与Moneta原理解析

== 离体驱动模糊测试的核心支撑技术
为了在不依赖真实物理GPU的情况下对驱动进行深层测试，本文依赖以下两项核心底层技术：

*1. 快照重托管技术（Snapshot-and-Rehost）*
由于高端GPU硬件成本高昂，且难以支持大规模并发测试，快照重托管机制通过 QEMU/KVM 虚拟化层实现了执行状态的剥离。在挂载物理GPU的“在体”环境中，当驱动程序完成复杂的初始化（如显存池预热、上下文映射）后，虚拟化管理程序会冻结当前虚拟机的 CPU 寄存器和内存，并保存为“快照”。随后，该快照可被无限复制，并在无物理GPU的服务器（“离体”环境）中被唤醒恢复。

*2. 记录重放引擎（Record-and-Replay）*
由于离体环境缺失硬件，驱动一旦被唤醒并尝试读取硬件寄存器（MMIO）或处理中断，必然会导致内核崩溃。记录重放技术会在“在体”执行期间，静默拦截并记录所有 CPU 与 PCIe 设备间的交互数据流。在离体阶段，重放引擎充当一个完美的“虚拟硬件响应器”，按时序向驱动注入此前记录的真实硬件数据，从而成功“欺骗”驱动程序恢复执行流。

== Moneta 系统原理剖析
Moneta 将上述两项技术深度结合，其整体工作流高度依赖客主机（Guest）与宿主机（Host）之间的紧密协同。当 Guest 内运行特定负载并到达预设触发点时，Guest 需要立刻通知 Host 挂起虚拟机并拍摄快照。在原版设计中，这一同步操作具有极大的侵入性。

== 原版项目存在的工程化阻碍与缺陷
在实际复现 Moneta 的过程中，本文发现该开源项目存在致命的架构与工程缺陷：
+ *宿主机内核的深度侵入陷阱*：Moneta 强行修改了 Linux 5.19 源码，增加了一个自定义的 KVM Hypercall（超级调用），让 Guest 用它来通知 Host 进行快照。这意味着测试人员必须将服务器的宿主机内核降级并替换为该魔改版本。在搭载新一代处理器和主板的服务器上，强制降级往往导致网卡失联或系统无法启动，使其彻底丧失可移植性。
+ *调度器逻辑崩溃与编译断层*：项目不仅遗漏了生成核心文件 `syz-moneta` 的 `make` 目标，其对 Syzkaller 源码的魔改也引入了严重的竞态条件，导致调度器 `syz-manager` 频繁崩溃。
+ *硬编码带来的僵化配置*：包括 Bash 绝对路径（错误地定死为 `/bin/bash`）、物理 GPU 的 PCI 直通地址（硬编码为特定的单卡拓扑），导致不同机型上均无法顺利执行。


// ==========================================
// 第三章 宿主解耦重构与虚拟通信机制设计
// ==========================================
= 宿主解耦重构与虚拟通信机制设计

针对前文指出的最严重的宿主机内核依赖问题，本文提出并实现了一种非侵入式的虚拟设备通信架构。本章将详细介绍该重构方案的底层逻辑。

== 原生 Hypercall 机制的局限性分析
Hypercall 是虚拟机向 Hypervisor 请求特权操作的底层指令（如 x86 架构下的 `VMCALL`）。在 Moneta 的原始设计中，测试负载执行至目标状态时，会通过内核模块触发自定义 Hypercall。然而，标准的 KVM 模块在截获到未定义的 Hypercall 时，会抛出异常并向 Guest 注入中断（`#UD`），导致测试终止。这正是为什么原作者必须魔改宿主机内核的原因。显然，这种紧耦合设计严重违背了软件工程中的模块化与可移植性原则。

== 改进版 Virtio-serial 虚拟串口通信通道
为了实现 Guest 与 Host 控制平面的解耦，本文引入了基于 `Virtio-serial` 的应用层通信通道。Virtio 是一种半虚拟化标准，能够在不修改底层 KVM 内核模块的前提下，提供高效的字符流传输。

具体而言，本文在 QEMU 的启动命令行中注入了如下设备配置：
```bash
-chardev socket,id=trigger0,path=/tmp/guest-trigger-channel,server,nowait \
-device virtserialport,bus=virtio-serial2.0,chardev=trigger0,name=guest.snapshot.trigger
```
如上述配置所示，QEMU 在 Host 端开放了一个 Unix Domain Socket (`/tmp/guest-trigger-channel`)，并将其映射为 Guest 内部的一个虚拟字符设备（通常为 `/dev/vportXpY`）。

== 基于状态机的宿主机代理守护进程实现
在建立了虚拟通道后，本文在 Host 侧设计并实现了一个名为 `snapshot_proxy.py` 的轻量级守护进程（Daemon）。
它的核心工作逻辑是一个非阻塞的状态机：
1. *持续监听*：守护进程持续监听 Socket 端口。
2. *指令捕获与快照生成*：当 Guest 端的 Moneta Agent 向字符设备写入预定义的“触发标记”时，字符流透传至 Host 端。`snapshot_proxy.py` 捕获该标记后，利用 QMP (QEMU Machine Protocol) API，向 QEMU Monitor 发送挂起指令（`stop`），随后下发快照拍摄指令（`savevm`）。
3. *恢复状态的重分发*：当快照被迁移至“离体环境”唤醒时，Guest 会再次读取该字符设备以确认当前环境。此时的 Host 守护进程会根据当前处于“收集阶段”还是“模糊测试阶段”，向 Socket 写入不同的环境模式代码，引导 Guest 内的进程走向不同的分支。

#figure(
  align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      spacing: (2.5em, 2em),

      // 旧架构
      node((0,0),[Guest OS\n(执行触发指令)]),
      node((0,1),[自定义 Hypercall\n(引发虚拟机退出)], stroke: red),
      node((0,2),[定制 Host Linux 5.19\n(强侵入性内核修改)], stroke: red, fill: red.lighten(80%)),
      node((0,3), [QEMU 进程\n(拍摄快照)]),
      edge((0,0), (0,1), "->"),
      edge((0,1), (0,2), "->"),
      edge((0,2), (0,3), "->"),

      // 对比标签
      edge((1,0), (1,4), stroke: (dash: "dotted", thickness: 0.5pt)),

      // 新架构 (本文贡献)
      node((2,0),[Guest OS\n(读写 /dev/vportXpY)]),
      node((2,1),[Virtio-serial 设备\n(标准半虚拟化)], stroke: blue),
      node((2,2),[Host: Unix Socket\n(/tmp/guest-trigger)], stroke: blue, fill: blue.lighten(80%)),
      node((2,3),[Host 用户态进程\n(snapshot_proxy.py)], stroke: blue, fill: blue.lighten(80%)),
      node((2,4),[QEMU QMP API\n(触发 savevm)]),

      edge((2,0), (2,1), "->", label: "标准I/O"),
      edge((2,1), (2,2), "->", label: "透传"),
      edge((2,2), (2,3), "->", label: "事件监听"),
      edge((2,3), (2,4), "->", label: "API调用")
    )
  ],
  caption:[原版侵入式 Hypercall 与本文非侵入式 Virtio-serial 架构对比]
)

这一重构在本质上将系统控制平面从内核态上浮至用户态，彻底解放了宿主机的环境限制。


// ==========================================
// 第四章 测试环境扩展与全流程自动化构建
// ==========================================
= 测试环境扩展与全流程自动化构建

除了核心架构重构外，原代码库中繁杂的脚本和逻辑漏洞同样阻碍了项目的正常运行。本章阐述本文对核心组件的修复、测试负载业务价值的提升以及全自动构建引擎的设计。

== 核心组件逻辑缺陷与构建流修复
首先，本文全面审查并补齐了 Syzkaller 的 Makefile 构建链。在原代码中缺少 `make moneta` 的入口，导致后续的所有测试依赖文件缺失。
其次，原版 Syzkaller 中被修改过的 `syz-manager`（负责调度和管理模糊测试实例的守护进程）存在严重的逻辑崩溃问题。

#box(stroke: red, fill: rgb("ffeeee"), inset: 8pt)[
  【需要补充】：请在这里详细描述你修复 syz-manager 的细节。比如：
  “在原版实现中，当 `syz-manager` 尝试获取共享内存中的覆盖率反馈时，未加入互斥锁或未正确处理空指针（或者是死锁问题等，根据你实际改的代码来写），导致程序在收到第一次变异输入时立即抛出 panic。本文通过在 xxx.go 文件中添加条件判断（或修正状态机跳转），成功修复了该竞态条件，保证了模糊测试的稳定运行。”
  （如果可以的话，贴一小段几行的 Go 代码对比 Diff 最好不过了）
]

此外，本文利用 `sed` 工具流统一替换了项目内几十个辅助脚本中的 `#!/bin/bash` 声明为兼容性更好的 `#!/usr/bin/env bash`。

== 硬件参数动态化与依赖解耦
为彻底抛弃原项目的硬件死锁，本文引入了全生命周期的环境变量解析机制。将宿主机负责渲染的显示输出 GPU 与分配给 QEMU 直通测试的被测 GPU（如 `PCI_ID=0000:01:00.0`）进行动态参数化提取。系统启动时，配置解析器会自动使用正则表达式修改 QEMU 的 `-device vfio-pci` 参数，同时动态组装对应版本的 NVIDIA 驱动下载链接并静默安装至 Guest 内部，赋予了框架对异构计算集群的强适应力。

== AI 算力测试负载的引入
原项目在录制阶段仅使用了一个非常基础且意义不大的计算负载，难以触发现代 GPU 核心（如 Tensor Core）及统一内存架构（UVM）的深层交互逻辑。
为了贴合当下的工业界实际业务，本文重新设计了目标应用程序。本文使用pytorch 编写了一系列模拟现代 AI 训练的核心算子负载（如张量矩阵乘法、大规模显存分配与并发核函数调度）。通过这些具有极高计算密度和资源争用的真实负载，Moneta 能够捕获到驱动程序最复杂、最容易发生条件竞争的深层状态机，极大提升了所挖掘漏洞的业务价值。

== 模糊测试全生命周期自动化封装
在此基础上，本文利用 Bash 状态机开发了统一入口脚本 `build.sh`。该脚本按顺序挂载以下任务节点：自动安装宿主编译工具链、拉取并交叉编译特定的客主内核、自动绑定 VFIO 直通通道、拉起 QEMU 并后台运行 Proxy 代理、执行 AI 负载并触发快照、提取语料库以及最终启动 `syz-manager` 开启大规模变异测试。使用者只需运行一条指令，所有流程即可行云流水般自动完成。


// ==========================================
// 第五章 容器化部署架构与系统测试评估
// ==========================================
= 容器化部署架构与系统测试评估

为了进一步规范工业级部署环境并验证重构后系统的实际表现，本章详细介绍基于 Docker 的封装设计，并展示一系列对系统可用性和稳定性的评估结果。

== 容器化隔离机制与自适应硬件探测
在实际部署中，哪怕一个特定版本的 GCC 编译器或 Go 环境冲突都会导致测试系统编译失败。为此，本文包装了 `moneta-modified-docker` 独立容器项目。
通过在 Dockerfile 中固定所有依赖的哈希树，本文提供了一个极致洁净的沙箱。更为创新的是，我们在 Docker 启动的 `Entrypoint` 中加入了 PCI 硬件拓扑扫描逻辑：
+ 容器启动时，探测宿主设备目录下的 `/sys/bus/pci/devices/` 以获取真实 GPU 资源。
+ 使用高权限模式（`--privileged`）挂载宿主机的设备节点。
+ 动态加载 VFIO 内核驱动，解绑宿主机原生 NVIDIA 驱动对指定 GPU 的占用，并将其无缝透传给容器内运行的 QEMU 实例。
这一系列高度自动化的配置，使得该框架完全具备了“即插即用”的云原生部署能力。

== 实验环境与测试方案设定
为了评估重构后系统的性能与可靠性，本文在真实物理环境中部署了该框架，并设置了对比测试实验。

#box(stroke: red, fill: rgb("ffeeee"), inset: 8pt)[
  【需要补充】：请在此处详细列出你的测试机器配置。例如：
  *实验硬件配置*：
  - CPU: Intel Core i9-13900K / AMD Ryzen 9 7950X
  - 内存: 64GB DDR5
  - 宿主机操作系统: Ubuntu 22.04 LTS (Linux 6.2 内核，*注意强调这里证明了不再依赖5.19内核！*)
  - 直通测试 GPU: NVIDIA RTX 4090 / 3090
  - 测试驱动版本: NVIDIA Driver 535.xx
]

评估主要包含两项指标：环境部署的成功率与耗时，以及模糊测试引擎运行的稳定性。

== 系统可用性与部署效率评估
在原生 Moneta 项目中，由于内核替换和繁琐的硬编码修改，一名熟练的工程师通常需要数天时间才能勉强跑通一次测试（且极易因为硬件不兼容而完全失败）。
而在本文的容器化重构架构下，部署耗时被急剧压缩。

#box(stroke: red, fill: rgb("ffeeee"), inset: 8pt)[
  【需要补充】：请根据你的实际经验写几句评估结果。例如：
  “实验结果表明，在标准 Ubuntu 22.04 宿主机上，通过执行本文提供的 `docker run` 命令与 `build.sh`，系统能够 100% 成功识别 GPU 并完成直通配置。包含编译内核、捕获快照到启动测试的全流程平均耗时仅为 XX 分钟。这证明了本文在工程可用性上的决定性突破。”
]

== 测试吞吐量与稳定性分析
在成功拉起 Ex-Vivo 离体模糊测试实例后，我们对系统的运行稳定性进行了压力测试。

#box(stroke: red, fill: rgb("ffeeee"), inset: 8pt)[
  【需要补充】：在这里放上一张成功运行模糊测试的截图（比如终端里 syz-manager 正在跑，exec/s 有数值的那个界面截图）。并配文解释：

  // #figure(
  //   // image("syzkaller_running.png", width: 80%),
  //   caption:[Syzkaller 在离体环境下的稳定运行状态]
  // )

  “如图 X 所示，系统在剥离物理 GPU 的环境下成功恢复了驱动内部状态，并开展了高并发模糊测试。在长达 XX 小时 的连续测试中，`syz-manager` 始终保持稳定，未出现原项目中的崩溃死锁现象。测试吞吐量维持在约 XX exec/s，有效证明了虚拟串口通信同步机制的正确性以及代码逻辑修复的成功。”
]


// ==========================================
// 第六章 总结与展望
// ==========================================
= 总结与展望

本毕业设计深入分析了顶会论文项目 Moneta 在 GPU 驱动模糊测试方向的理论创新，并针对其在工程落地上面临的严峻缺陷进行了系统性重构与架构升级。本文的核心贡献在于首创了一种非侵入式的 Virtio-serial 虚拟通信通道，彻底拔除了原项目对底层定制版 Linux 5.19 宿主机内核的强依赖。同时，本文在代码级别修复了核心组件的崩溃漏洞，将环境参数动态化，引入了具备现代实际意义的 AI 模型训练测试负载，并最终设计了具备自适应硬件探测能力的智能化 Docker 容器架构。

本文的研究成果将一个极难复现的“学术实验室原型”成功蜕变为一个高可用、跨平台、易扩展的工业级安全测试框架。这不仅极大降低了安全工程师开展大规模 GPU 驱动漏洞挖掘的部署门槛，也为防御针对 AI 算力底座的基础设施攻击提供了强有力的工具支撑。未来，本项目有望进一步扩展支持不同厂商（如 AMD、Intel）的异构算力集群，并尝试引入大语言模型（LLM）指导的变异策略，持续提升漏洞挖掘的智能化水平。


#if twoside {
  pagebreak() + " "
}

#bilingual-bibliography(full: true)


// 附录
#show: appendix

= 附录
