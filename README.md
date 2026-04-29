# AIDataInsight-iOS
An iOS demo for AI-powered data query using LLM Function Calling, transforming natural language into structured queries and visualizing results.

## 🧠 AI Data Insight (iOS)

AI Data Insight 是一个基于 LLM 函数调用的自然语言数据分析 Demo，展示如何将用户输入转为结构化查询并完成数据可视化。

## 🚀 Features

* 自然语言数据查询（AI Query）
* LLM 解析（Prompt → JSON）
* Function Calling 思想（AI → 业务能力映射）
* 数据模拟查询（Mock Data）
* 图表展示（柱状图 / 趋势图）


## 🏗 Architecture

项目采用模块化设计，核心模块包括：

```
User Input → AI Parsing → Query Intent → Data Query → Chart Rendering
```

### Modules：

* **AIService**：负责 LLM 调用与结果解析
* **QueryIntent**：结构化查询模型（函数抽象）
* **DataService**：数据查询（Mock）
* **ChartModule**：图表渲染
* **ChatModule**：对话交互 UI


## 🔥 Key Idea

本项目基于 Function Calling 思想：

* 将业务能力抽象为“函数模型”
* 由 AI 解析用户意图并生成参数
* 客户端负责执行查询并展示结果

👉 实现“自然语言驱动业务能力”的能力


## 🛠 Tech Stack

* Swift / UIKit
* Modular Architecture（解耦设计）
* LLM API（OpenAI / Mock）
* Chart Rendering（自绘 / Charts）


## 📸 Demo

![对话界面](https://github.com/Janlor/AIDataInsight-iOS/blob/main/images/chat.png)

![历史会话](https://github.com/Janlor/AIDataInsight-iOS/blob/main/images/history.png)


## ⚠️ Note

* 数据为 Mock 数据（无真实业务依赖）
* 该项目基于真实业务场景抽象而来，用于展示 AI 数据查询的架构设计与交互实现。
