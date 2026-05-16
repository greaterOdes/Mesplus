# HarmonyOS 本地 RAG 知识库

这个目录提供本地 HarmonyOS / OpenHarmony 开发知识检索工具链，用于提升 ArkTS / ArkUI 编程时的上下文质量。

## 知识源

工具默认索引以下资料：

- `docs/opencode/arkts-arkui-rules.md`：项目 ArkTS / ArkUI 规则，最高优先级。
- `harmony-rag/openharmonyDocs/**/*.md`：OpenHarmony 官方 Markdown 文档。
- `harmony-rag/HarmonyOS_Samples/**/*.{ets,json,json5,md}`：官方示例项目代码和配置。
- `entry/src/main/ets/**/*.ets`：Mesplus 当前项目代码，用于贴合项目风格。

图片、压缩包、Excel、构建产物和依赖目录默认忽略。

## 安装 Ollama

Windows 推荐使用：

```powershell
winget install Ollama.Ollama
```

重新打开 PowerShell 后验证：

```powershell
ollama --version
```

拉取本地 embedding 模型：

```powershell
ollama pull bge-m3
```

确认模型存在：

```powershell
ollama list
```

## 生成资料清单

```powershell
npm run rag:scan
```

输出：

- `reports/source-summary.json`
- `reports/source-manifest.json`

## 构建向量索引

确保 Ollama 正在运行，并且已拉取 `bge-m3`：

```powershell
npm run rag:build
```

输出：

- `indexes/vector/chunks.jsonl`
- `indexes/keyword/keywords.json`
- `reports/index-summary.json`

索引文件可能较大，默认被 `.gitignore` 忽略。

当前默认配置聚焦应用开发资料，扫描规模大约为数千个源文件、十万级 chunk。首次构建会比较耗时，建议保持 Ollama 常驻并接入性能较好的本地环境。

如果需要全量重建，删除以下文件后重新运行 `npm run rag:build`：

```text
indexes/vector/chunks.jsonl
indexes/keyword/keywords.json
reports/index-summary.json
```

## 查询知识库

```powershell
npm run rag:query -- "Navigation NavDestination 怎么写"
```

查询结果包含：

- 综合分数
- 来源类型
- 文件路径
- 标题
- 文档或代码片段

`project_rules` 类型会优先注入结果，避免官方示例覆盖项目开发规则。

## 查看索引状态

```powershell
npm run rag:inspect
```

## 配置说明

- `config/sources.json`：知识源路径、类型和优先级。
- `config/embedding.json`：Ollama 地址、模型名、chunk 大小和检索权重。

默认 Ollama 地址：

```text
http://127.0.0.1:11434
```

默认模型：

```text
bge-m3
```

## 使用建议

- 编写 ArkUI 页面前，先查询组件或布局关键词。
- 遇到 API 不确定时，优先检索官方文档和项目规则。
- 生成代码时把查询结果中的来源路径一起提供给 AI，减少编造 API 的概率。
- 如果更新了 `openharmonyDocs`、Samples 或 `arkts-arkui-rules.md`，重新运行 `npm run rag:build`。
