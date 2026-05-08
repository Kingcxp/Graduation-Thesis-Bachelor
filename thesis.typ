#import "@preview/modern-nju-thesis:0.4.1": documentclass

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

// 文稿设置
#show: doc

// 字体展示测试页
// #fonts-display-page()

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

// 插图目录
// #list-of-figures()

// 表格目录
// #list-of-tables()

// 正文
#show: mainmatter

// 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]

= 导　论

== 研究背景与意义

== 本文研究目标与主要工作

= 相关技术基础

== Moneta GPU 驱动模糊测试框架简介

== Docker 容器化技术

= Moneta 工具现存问题分析与改进方案

== 现存问题分析

== 整体改进方案设计

= 实现改进方案

== 代码兼容性与稳定性修复

== 自动化流程优化

== Docker 实现

= 实验验证与效果评估

== 实验环境

== 功能正确性验证

== 易用性与效率评估

= 结论与展望

== 工作总结

== 未来展望


#if twoside {
  pagebreak() + " "
}

#bilingual-bibliography(full: true)


// 附录
#show: appendix

= 附录
