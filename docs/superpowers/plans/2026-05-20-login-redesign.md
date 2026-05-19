# Login Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 按 `docs/superpowers/specs/2026-05-20-login-redesign-design.md` 实现 Apple HIG 风格登录页、MAG 双因子流程、IDASS WebView 回调认证框架。

**Architecture:** 保持现有 `LoginStrategyRegistry`，将登录模式收敛为 `MAG` 和 `IDASS`，新增状态化模型和纯函数解析，UI 只渲染状态并通过回调触发动作。先用 Hypium 覆盖 WebBridge、策略注册、登录状态模型和配置，再接入 ArkUI 组件。

**Tech Stack:** HarmonyOS NEXT ArkTS、ArkUI、Navigation、Hypium、WebView JS bridge、`resources/rawfile/channels.json`。

---

## File Map

- Modify: `entry/src/main/ets/config/AppConstants.ets`，登录模式改为 `MAG`、`IDASS`。
- Modify: `entry/src/main/ets/models/Channel.ets`，扩展 MAG 双因子和 IDASS 回调配置字段。
- Modify: `entry/src/main/resources/rawfile/channels.json`，只保留 MAG 和 IDASS 两个登录方法。
- Create: `entry/src/main/ets/auth/LoginFlowModels.ets`，定义 MAG 二次认证、IDASS 回调和登录视图状态模型。
- Modify: `entry/src/main/ets/auth/WebBridge.ets`，回调名改为 `window.Loader.intoApp`，新增 MTOKEN payload 解析。
- Modify: `entry/src/main/ets/auth/PasswordSmsFirstDeviceLoginStrategy.ets`，迁移为 MAG 策略语义。
- Modify: `entry/src/main/ets/auth/SsoWebViewLoginStrategy.ets`，迁移为 IDASS 策略语义。
- Delete: `entry/src/main/ets/auth/PasswordOnlyLoginStrategy.ets`，移除普通账号密码直登策略。
- Modify: `entry/src/main/ets/components/LoginPanel.ets`，实现 Apple HIG 毛玻璃卡片、MAG 表单、同卡片二次认证、IDASS 入口。
- Modify: `entry/src/main/ets/pages/LoginPage.ets`，调整背景、品牌区、登录卡片布局。
- Modify: `entry/src/main/ets/pages/SsoWebViewPage.ets`，从占位页升级为 IDASS 说明/桥接承载页；如 WebView API 不确定，保留明确接口边界，不编造 API。
- Modify: `entry/src/main/resources/base/element/string.json`、`zh_CN/element/string.json`、`en_US/element/string.json`，补充固定文案。
- Modify: `entry/src/test/WebBridge.test.ets`，覆盖 `window.Loader.intoApp` 和 MTOKEN payload。
- Modify: `entry/src/test/LoginStrategyRegistry.test.ets`，覆盖 MAG/IDASS 策略，不再引用普通密码策略。
- Create: `entry/src/test/LoginFlowModels.test.ets`，覆盖 MAG 二次认证状态模型。
- Modify: `entry/src/test/List.test.ets`，注册新测试。

## Task 1: WebBridge 和登录模式纯逻辑

**Files:**
- Modify: `entry/src/main/ets/config/AppConstants.ets`
- Modify: `entry/src/main/ets/auth/WebBridge.ets`
- Modify: `entry/src/test/WebBridge.test.ets`

- [ ] **Step 1: Write failing tests**

Update `entry/src/test/WebBridge.test.ets` expectations:

```ts
expect(SSO_CALLBACK_NAME).assertEqual('window.Loader.intoApp');
const payload = parseSsoCallbackPayload('{"mtoken":"m-1001","user":{"userId":"u-1001"}}');
expect(payload.mtoken).assertEqual('m-1001');
expect(payload.user['userId']).assertEqual('u-1001');
expect(didParseThrow('{"user":{"userId":"u-1001"}}')).assertEqual(true);
```

Run: `cmd /c hvigorw --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon`
Expected: compile fails because `payload.mtoken` typed parser or callback constant is not updated.

- [ ] **Step 2: Implement minimal WebBridge changes**

Set callback constant to `window.Loader.intoApp`, add `IdassCallbackPayload`, and make parser reject empty/non-object/missing `mtoken`.

- [ ] **Step 3: Verify**

Run the same `hvigorw` command. Expected: ArkTS compile succeeds through `CompileArkTS`; full build may warn if signing is absent.

## Task 2: Login mode and strategy cleanup

**Files:**
- Modify: `entry/src/main/ets/config/AppConstants.ets`
- Modify: `entry/src/main/ets/auth/PasswordSmsFirstDeviceLoginStrategy.ets`
- Modify: `entry/src/main/ets/auth/SsoWebViewLoginStrategy.ets`
- Delete: `entry/src/main/ets/auth/PasswordOnlyLoginStrategy.ets`
- Modify: `entry/src/test/LoginStrategyRegistry.test.ets`

- [ ] **Step 1: Write failing tests**

Change tests to use `LoginMode.MAG` and `LoginMode.IDASS`; remove `PasswordOnlyLoginStrategy` import and assertions. Assert MAG auto-login requires `rsa_encrypted_password` and `autoLoginPath`; assert IDASS requires `sso_renewal_credential` and `renewalPath`.

Run: `cmd /c hvigorw --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon`
Expected: compile fails until enum and strategies use `MAG`/`IDASS`.

- [ ] **Step 2: Implement strategy cleanup**

Replace `LoginMode.PASSWORD/SMS/SSO` with `MAG/IDASS`, set MAG strategy mode to `MAG`, IDASS strategy mode to `IDASS`, remove plain password strategy references.

- [ ] **Step 3: Verify**

Run `hvigorw` command again. Expected: compile succeeds through ArkTS.

## Task 3: MAG 二次认证状态模型

**Files:**
- Create: `entry/src/main/ets/auth/LoginFlowModels.ets`
- Create: `entry/src/test/LoginFlowModels.test.ets`
- Modify: `entry/src/test/List.test.ets`

- [ ] **Step 1: Write failing tests**

Create tests for `createInitialMagState()`, `createMagMfaState(maskedMobile, maskedEmail)`, and `selectMagMfaMethod(state, method)`:

```ts
expect(createInitialMagState().step).assertEqual(MagLoginStep.CREDENTIALS);
const state = createMagMfaState('138****0000', 'a***@mail.com');
expect(state.availableMethods.length).assertEqual(2);
expect(selectMagMfaMethod(state, MagMfaMethod.EMAIL).selectedMethod).assertEqual(MagMfaMethod.EMAIL);
```

Run `hvigorw`. Expected: compile fails because model file does not exist.

- [ ] **Step 2: Implement model**

Define exported enums/interfaces/functions with explicit types and comments for public exports. Keep pure functions under 50 lines.

- [ ] **Step 3: Verify**

Run `hvigorw`. Expected: compile succeeds through ArkTS.

## Task 4: Channel config update

**Files:**
- Modify: `entry/src/main/ets/models/Channel.ets`
- Modify: `entry/src/main/resources/rawfile/channels.json`
- Modify: `entry/src/test/ChannelConfigLoader.test.ets`

- [ ] **Step 1: Write failing config expectations**

Update config tests to expect exactly `MAG` and `IDASS`, and expect `idassCallbackName === 'window.Loader.intoApp'` plus `mtokenAuthPath` for IDASS.

- [ ] **Step 2: Implement config fields**

Extend `LoginMethodConfig` with optional `smsSendPath`, `emailSendPath`, `mfaVerifyPath`, `idassCallbackName`, and `mtokenAuthPath`. Update raw JSON methods.

- [ ] **Step 3: Verify**

Run `hvigorw`. Expected: compile succeeds through ArkTS.

## Task 5: Apple HIG Login UI

**Files:**
- Modify: `entry/src/main/ets/components/LoginPanel.ets`
- Modify: `entry/src/main/ets/pages/LoginPage.ets`
- Modify: string resources in `base`、`zh_CN`、`en_US`

- [ ] **Step 1: Add UI resource strings first**

Add fixed text for MAG, IDASS, two-factor verification, masked mobile/email labels, device secure subtitle, and IDASS web login prompt in all three string files.

- [ ] **Step 2: Implement HIG card**

Refactor `LoginPanel` into builders for channel segmented control, MAG credentials, MAG MFA expansion, IDASS action, and primary button. Use ArkUI only, no CSS/HTML. Keep each builder under 50 lines.

- [ ] **Step 3: Verify visual compile**

Run `hvigorw`. Expected: compile succeeds through ArkTS.

## Task 6: IDASS page bridge shell

**Files:**
- Modify: `entry/src/main/ets/pages/SsoWebViewPage.ets`
- Modify: `entry/src/main/ets/pages/navcomponent/SsoWebViewNavDestination.ets`

- [ ] **Step 1: Clarify API boundary in code**

If WebView JS injection API is already used in repo, follow it. If not, implement a polished IDASS shell page with clear comments and parser integration, without guessing unconfirmed WebView API names.

- [ ] **Step 2: Compile verify**

Run `hvigorw`. Expected: compile succeeds.

## Task 7: End-to-end verification and deployment

**Files:**
- No source files expected.

- [ ] **Step 1: Build**

Run:

```cmd
hvigorw --mode module -p product=default -p module=entry@default assembleHap --analyze=normal --parallel --incremental --daemon
```

Expected: `BUILD SUCCESSFUL` or successful unsigned HAP packaging if signing is intentionally absent.

- [ ] **Step 2: Deploy if emulator is running**

Run:

```powershell
hdc list targets
hdc install -r .\entry\build\default\outputs\default\entry-default-unsigned.hap
hdc shell aa start -a EntryAbility -b com.hms.mesplus
hdc shell pidof com.hms.mesplus
```

Expected: install succeeds, ability starts, `pidof` returns a process id.

- [ ] **Step 3: Finish**

Use `scripts/opencode-finish.ps1` so verified changes are committed, pushed, and PR-created according to project rules.
