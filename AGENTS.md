# OpenCode 工作规则

## 语言

- 后续规格、计划、说明文档默认使用中文。
- 代码中的技术名词、枚举值、路径和命令保持英文原文。

## 完成需求或修复 bug 后的 Git 流程

默认采用分支推送策略，不直接推送 `main` / `master`。

完成一次需求或 bug 修复后，OpenCode 应执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\opencode-finish.ps1 -TaskName "简短任务名" -Message "type: 简短提交说明"
```

脚本行为：

- 如果当前在 `main` 或 `master`，自动创建 `opencode/YYYYMMDD-HHmm-<task>` 分支。
- 如果当前在功能分支，使用当前分支。
- 提交前优先在 CMD 中运行 `hvigorw` HarmonyOS 编译验证命令。
- 拦截常见敏感文件，例如 `.env`、密钥文件、`local.properties`。
- 自动 `git add -A`、`git commit`、`git push -u origin <branch>`。
- 推送完成后报告分支名。

## 安全规则

- 不要提交 `.env`、密钥、证书、私钥、凭据文件或 `local.properties`。
- 不要在未明确要求时直接推送 `main` 或 `master`。
- 不要使用 `--force` 推送。
- 如果验证命令不可用，必须在最终回复中说明，并提示用户在 DevEco Studio 中执行验证。
- 如果脚本拦截敏感文件，停止并询问用户如何处理。

## ArkTS / ArkUI 开发规则

开发 HarmonyOS NEXT ArkTS / ArkUI 代码前，必须先阅读并遵守：

`docs/opencode/arkts-arkui-rules.md`

## 常用命令

HarmonyOS 编译验证，在 CMD 中执行：

```cmd
hvigorw --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon
```

已手工验证但命令行没有 `hvigor` 时：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\opencode-finish.ps1 -TaskName "任务名" -Message "chore: 说明" -SkipVerify
```

允许直接在当前分支提交并推送，仅在用户明确同意时使用：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\opencode-finish.ps1 -TaskName "任务名" -Message "chore: 说明" -AllowMain
```
