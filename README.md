# ResearchManager

> 管理科研项目的全生命周期——从灵感捕捉到论文发表。

---

## 概述

ResearchManager 帮助系统性地管理科研项目。它将科研流程分解为**灵感 → 目标 → 文献 → 技术路线 → 实验 → 写作**的标准化链路，每个环节都有对应的操作指南和脚本工具，让科研管理有章可循。

## 功能特性

| 模块 | 功能 | 参考文件 |
|------|------|---------|
| 💡 **灵感** (ideas) | 捕捉原始想法，记录来源和后续行动 | — |
| 🎯 **目标** (goals) | 从新颖性、可行性、价值、时机四个维度评估研究方向 | `references/goal-framework.md` |
| 📚 **文献** (literature) | 检索论文、记录笔记、追踪阅读进度 | `references/literature-protocol.md` |
| 🧭 **路线** (route) | 发散收敛探索技术方案，记录决策理由防止重复探索 | `references/route-exploration.md` |
| 🔬 **实验** (experiment) | 设计实验模板、追踪运行状态、结果对比分析 | `references/experiment-templates.md` |
| ✍️ **写作** (writing) | 多论文管理、投稿追踪、审稿回复工作流 | `references/writing-protocol.md` |
| 📊 **状态** (status) | 全局进度概览，一键查看项目健康状况 | — |
| 🔗 **Wiki 联动** | 自动检测 `~/LLM-Wiki/`，预查已有知识避免重复劳动 | `references/wiki-interaction.md` |

## 安装

### 前置要求

- Python 3 — 用于脚本中的 JSON 处理
- （可选）`~/LLM-Wiki/` — 跨项目知识库，用于知识复用

### 安装步骤

将 ResearchManager 安装到你的研究项目中（每个项目单独安装）：

```bash
# 1. 进入你的研究项目目录
cd /path/to/your/research/project

# 2. 创建 skill 目录
mkdir -p .claude/skills/research-manager

# 3. 将 ResearchManager 复制到 skill 目录中
cp -r /path/to/ResearchManager/* .claude/skills/research-manager/
```

> **注**：复制安装后，ResearchManager 仓库的更新不会自动同步到已安装的项目。更新时需要手动重新复制。

或者让 Claude Code agent 代劳以上步骤。

### 验证安装

在项目目录中运行入口命令，如果看到初始化提示，说明安装成功。

## 快速开始

1. 使用 `scripts/init.sh` 一键搭建研究项目框架（包括代码目录、数据目录、论文目录等）
2. 安装 skill 到项目（见上方安装步骤）
3. 运行 `/research-manager`，激活研究管理器
4. 捕获第一个想法或定义研究目标开始

### 首次使用后的项目结构

```
your-research-project/
├── .research/                    ← ResearchManager 元数据目录
│   ├── state.json                ← 项目状态（由 skill 管理）
│   ├── config.json               ← 配置（Wiki 路径等）
│   ├── log.md                    ← 研究日志
│   ├── routes.json               ← 路线数据（机器可读）
│   ├── ideas/                    ← 灵感笔记
│   ├── goals/                    ← 研究目标
│   ├── literature/
│   │   ├── index.json            ← 文献索引
│   │   ├── readings/             ← 论文阅读笔记
│   │   └── searches/             ← 检索历史
│   ├── experiments/
│   │   ├── index.json            ← 实验索引
│   │   └── <exp-name>/           ← 各实验详情
│   ├── writing/
│   │   ├── index.json            ← 论文索引
│   │   └── <paper-name>/         ← 各论文详情
│   └── talks/                    ← 演讲/海报大纲
│
├── src/                          ← 实验代码
├── configs/                      ← 实验配置
├── data/                         ← 数据集（.gitignore 中排除）
├── results/                      ← 实验结果（.gitignore 中排除）
├── notebooks/                    ← 分析笔记本
├── paper/                        ← 论文 LaTeX 源码
├── slides/                       ← 演讲/海报
├── scripts/                      ← 项目辅助脚本
│
└── .gitignore                    ← 由 init.sh 自动生成
```

## 模块详解

### 💡 灵感 (Ideas)

捕捉原始研究想法——一个直觉、一篇刚读的论文、和导师的谈话。记录为 Markdown 文件并标注来源和状态。

**流程**：`captured → filtered → adopted / abandoned`

### 🎯 目标 (Goals)

通过四个维度系统评估研究目标：

- **新颖性**：是否与已知工作重叠？
- **可行性**：数据、算力、专业能力是否匹配？
- **价值**：假设成功，贡献是什么？
- **时机**：现在做还是等半年？

评估结果保存在 `.research/goals/current.md`。

### 📚 文献 (Literature)

支持 arXiv API 检索和 WebSearch，自动去重（检查已有索引和 Wiki 知识库），保存检索历史避免重复搜索。

**状态生命周期**：`to-read → reading → reviewed → integrated`

### 🧭 路线 (Routes)

**发散阶段**：针对一个研究目标，提出 2-4 个有本质差异的技术方案（机械多样性）。

**收敛阶段**：根据用户反馈，淘汰/精炼方案，记录决策理由。

被放弃的路线也会记录原因，防止几个月后重复探索同一个死胡同。

### 🔬 实验 (Experiment)

使用模板化设计确保实验规范性：

```
实验设计模板：
├── Motivation（要回答什么问题）
├── Baseline（对比基准）
├── Setup（模型、数据、算力、框架）
├── Metrics（主要指标 + 次要指标）
└── Ablations（控制变量设计）
```

**状态生命周期**：`planned → running → completed / abandoned`

### ✍️ 写作 (Writing)

多论文并行管理，支持：

- 论文提纲和草稿版本
- 投稿目标与截止日期追踪
- **审稿回复工作流**：逐条记录 reviewer 意见，结构化回复

**状态生命周期**：`planning → drafting → polishing → submitted → under-review → accepted / rejected → camera-ready`

### 📊 状态 (Status)

每次交互后自动显示进度概览：

```
📋 项目名称
Phase: literature-survey  |  Progress: 25%
• ideas: 3     • goals: active 1 / archived 2
• literature: 5 surveyed, 2 to-read
• routes: active 1 / abandoned 1
• experiments: 2 completed, 1 planned
• writing: 1 paper(s)
Latest: [2026-07-02] **[experiment]** Baseline completed
```

## 脚本参考

ResearchManager 提供了 6 个辅助脚本，用于高效的机械化操作（如索引更新、状态切换）。它们用 Bash + 内联 Python 编写。

| 脚本 | 命令 | 用途 |
|------|------|------|
| `scripts/init.sh` | `init.sh <project-dir>` | 搭建研究项目框架（代码目录 + 数据目录 + `.research/` 元数据） |
| `scripts/state.sh` | `get/set/stats/increment/summary` | 读取和更新项目状态（JSON） |
| `scripts/exp.sh` | `add/list/status/rm` | 实验 CRUD 和状态转换 |
| `scripts/lit.sh` | `add/list/update/rm` | 文献索引管理（按 arXiv ID 索引） |
| `scripts/route.sh` | `add/list/status/rm` | 路线状态转换，自动生成 `routes.md` |
| `scripts/log.sh` | `add/recent/grep` | 追加和检索研究日志 |

## Wiki 集成

ResearchManager 会自动检测 `~/LLM-Wiki/`（Karpathy 风格的个人知识库），实现跨项目知识复用：

### 预查（只读）

在以下操作前自动检查 Wiki：

| 操作 | 检查 Wiki 路径 |
|------|---------------|
| 文献检索 | `wiki/sources/`, `wiki/concepts/` |
| 路线评估 | `wiki/concepts/` |
| 目标设定 | `wiki/concepts/` |

### 贡献（需确认）

创建了新知识后，会询问是否写回 Wiki：
- 详细文献笔记 → `wiki/sources/<arxiv-id>.md`
- 新概念解释 → `wiki/concepts/<slug>.md`
- 路线分析 → 追加到相关概念页

### Wiki 路径检测优先级

1. `.research/config.json` 中的 `wiki_path` 字段
2. `$LLM_WIKI_PATH` 环境变量
3. `~/LLM-Wiki/` 默认路径
4. 都没有则询问用户，缓存到 `config.json`

## 升级策略

当单个任务的复杂度超出手动操作范围时，可以升级到更强大的方式：

| 场景 | 建议 |
|------|------|
| 需要广泛调研不熟悉的领域 | 并行搜索 / Deep Research |
| 目标可行性不确定，需要多方意见 | 派独立分析 Agent 挑战论点 |
| 多项技术路线需系统比较 | 并行评估后综合 |
| 文献搜索结果庞杂 | 用独立 Agent 打分排序 |
| 实验结果需要对抗性分析 | 派 Agent 压力测试结论 |

核心原则：**定义要评估的维度**（新颖性、可行性、可复现性等），而不是指定要调用的 Agent。

## 项目结构

```
ResearchManager/
├── README.md                               ← 本文档
├── SKILL.md                                ← 主入口（技能定义）
├── .gitignore
├── .claude/
│   └── settings.local.json                 ← 权限配置
├── references/                             ← 参考协议文件
│   ├── goal-framework.md                   │   目标评估框架
│   ├── literature-protocol.md              │   文献调研协议
│   ├── route-exploration.md                │   技术路线探索
│   ├── experiment-templates.md             │   实验模板
│   ├── writing-protocol.md                 │   写作/投稿协议
│   └── wiki-interaction.md                 │   Wiki 联动协议
└── scripts/                                ← 辅助脚本
    ├── init.sh                             │   项目初始化
    ├── state.sh                            │   状态读写
    ├── exp.sh                              │   实验管理
    ├── lit.sh                              │   文献管理
    ├── route.sh                            │   路线管理
    └── log.sh                              │   日志管理
```

## SKILL.md 的作用

`SKILL.md` 是这个项目的核心入口——它定义了每个模块的操作协议、与 Wiki 的交互规则、辅助脚本的使用场景。

修改 SKILL.md 即可改变行为，无需编译或部署。

## 开发与贡献

### 修改内容

修改 `SKILL.md`、`references/` 或 `scripts/` 下的文件后，更新已安装项目时需要重新复制文件。

### 提交变更

1. 修改文件
2. 提交前展示变更内容并确认 commit message
3. 再执行 `git commit`

## 许可

[MIT License](LICENSE)
