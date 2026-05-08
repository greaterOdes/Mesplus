# Mesplus 鸿蒙 ArkTS App 设计文档

## 范围

首版目标是为一个鸿蒙 ArkTS 工业软件 App 搭建可运行的基础框架。App 的信息架构和交互风格接近微信，但业务定位不是通讯软件，而是工业场景软件。

首版重点包括：应用壳、配置化渠道登录、网关解析、Cookie 会话、自动登录续期、请求头安全校验，以及四个主签页的占位业务页面。

## 当前项目情况

项目位于 `E:\WorkSpace\Harmony_WorkSpace\Mesplus`，是标准 HarmonyOS ArkTS 工程。

当前仍是 DevEco Studio 默认模板，主要文件包括：

- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/entryability/EntryAbility.ets`
- `entry/src/main/module.json5`

后续实现会把默认 `Hello World` 页面替换为应用初始化流程。

## 首版交付内容

- 从 `entry/src/main/resources/rawfile/channels.json` 读取渠道配置。
- 登录页支持渠道选择。
- 支持三种登录方式：
  - `password_sms_first_device`
  - `sso_webview`
  - `password_only`
- 所有登录结果统一归一化为同一套用户和会话模型。
- 后续网络请求使用 Cookie 做 SSO 认证。
- 当距离上次登录或自动登录超过 28 分钟时，请求前先自动登录或续期。
- 每个渠道支持四类服务：
  - `auth`
  - `business`
  - `sso`
  - `file`
- 每个服务可以独立选择 `MAG` 或 `ORIGINAL` 网关模式。
- 网络请求支持安全校验后的自定义请求头。
- 登录后展示四个底部签页：
  - 首页
  - 通讯录
  - 工作日志
  - 个人中心
- 首页支持类似微信下拉搜索小程序的工业功能入口搜索。

## 架构设计

首版使用轻量分层结构，不引入重型框架。目录规划如下：

```text
entry/src/main/
  resources/
    rawfile/
      channels.json
  ets/
    app/
      AppState.ets
      SessionStore.ets
    auth/
      AuthService.ets
      CredentialStore.ets
      UserNormalizer.ets
      WebBridge.ets
    components/
      ChannelPicker.ets
      LoginPanel.ets
      MiniProgramSearch.ets
      WechatTabBar.ets
    config/
      AppConstants.ets
      ChannelConfigLoader.ets
    models/
      Channel.ets
      Session.ets
      UserProfile.ets
    network/
      HeaderGuard.ets
      HttpClient.ets
      ServiceResolver.ets
    pages/
      ContactsPage.ets
      HomePage.ets
      Index.ets
      LoginPage.ets
      MainPage.ets
      ProfilePage.ets
      SsoWebViewPage.ets
      WorkLogPage.ets
```

职责划分：

- `config` 负责读取和校验本地 `rawfile` 配置。
- `models` 负责定义类型模型。
- `app` 负责当前渠道、当前会话和持久化相关状态。
- `auth` 负责登录、自动登录、用户归一化、凭证存储和 SSO WebView 回调。
- `network` 负责 URL 解析、Cookie 附加、请求头安全校验、自动登录前置判断和请求执行。
- `pages` 和 `components` 只负责界面展示与交互，不直接拼接网关 URL，也不直接管理 Cookie。

## 渠道配置

渠道 URL 和网关配置不能硬编码在 ArkTS 代码中，必须放在 `entry/src/main/resources/rawfile/channels.json`。

推荐配置结构：

```json
{
  "channels": [
    {
      "id": "factory_a",
      "name": "工厂A",
      "loginMethods": [
        {
          "mode": "password_sms_first_device",
          "title": "账号密码登录",
          "authService": "auth",
          "loginPath": "/login/password",
          "smsVerifyPath": "/login/first-device/sms",
          "autoLoginPath": "/session/auto-login",
          "credentialPolicy": "rsa_encrypted_password"
        },
        {
          "mode": "sso_webview",
          "title": "统一身份认证",
          "ssoService": "sso",
          "loginPath": "/login",
          "renewalService": "auth",
          "renewalPath": "/session/sso-renewal",
          "credentialPolicy": "sso_renewal_credential"
        },
        {
          "mode": "password_only",
          "title": "普通账号密码登录",
          "authService": "auth",
          "loginPath": "/login/password-only",
          "autoLoginPath": "/session/auto-login",
          "credentialPolicy": "rsa_encrypted_password"
        }
      ],
      "userMapping": {
        "userId": ["userId", "user_id", "id"],
        "userName": ["userName", "realName", "name"],
        "mobile": ["mobile", "phone"],
        "department": ["department", "deptName"],
        "avatarUrl": ["avatarUrl", "avatar", "headImage"]
      },
      "cookieMapping": {
        "cookie": ["cookie", "setCookie", "sessionCookie"]
      },
      "autoLogin": {
        "enabled": true,
        "intervalMinutes": 28
      },
      "services": {
        "auth": {
          "gatewayMode": "MAG",
          "magGateway": "https://mag.proxy.com/auth-gateway",
          "originalGateway": "https://auth-a.example.com/auth-gateway"
        },
        "business": {
          "gatewayMode": "MAG",
          "magGateway": "https://mag.proxy.com/biz-gateway",
          "originalGateway": "https://biz-a.example.com/biz-gateway"
        },
        "sso": {
          "gatewayMode": "ORIGINAL",
          "magGateway": "https://mag.proxy.com/sso-gateway",
          "originalGateway": "https://sso-a.example.com/sso"
        },
        "file": {
          "gatewayMode": "ORIGINAL",
          "magGateway": "https://mag.proxy.com/file-gateway",
          "originalGateway": "https://file-a.example.com/file-gateway"
        }
      }
    }
  ]
}
```

配置规则：

- `gatewayMode` 只允许 `MAG` 和 `ORIGINAL` 两个值。
- `magGateway` 和 `originalGateway` 都是完整网关 URL 前缀。
- 每个服务都可以独立选择走 MAG 代理网关或原始网关。
- 必填服务配置缺失或不合法时，视为配置错误。
- 当前选择的渠道需要持久化，下次打开 App 时默认选中上次渠道。

## 登录方式扩展架构

登录模块采用“策略注册表 + 配置驱动流程”的设计，避免把不同登录方式写成集中式 `if/else` 分支。

核心结构：

```text
LoginStrategy
  mode
  login(channel, loginMethod, input)
  autoLogin(channel, loginMethod, credential)
  supportsAutoLogin(loginMethod)

LoginStrategyRegistry
  register(strategy)
  get(mode)

AuthService
  login(channel, loginMethod, input)
  ensureSessionFresh()
  autoLogin()
```

扩展规则：

- `channels.json` 使用 `loginMethods` 配置每个渠道可用的登录方式和接口路径。
- 每种登录方式对应一个独立 `LoginStrategy` 实现。
- `AuthService` 只负责调度策略、保存 Session、触发自动登录和处理失败跳转，不写具体登录方式细节。
- `LoginPanel` 根据 `loginMethods` 渲染可用登录入口，不直接判断具体接口地址。
- 新增登录方式时，新增策略类和配置项，并在 `LoginStrategyRegistry` 注册；现有策略、网络层、用户归一化逻辑不需要修改。

首版内置三种登录策略。

`password_sms_first_device`：

- 用户输入账号和密码。
- 后端判断当前设备是否首次登录。
- 如果需要首次设备校验，界面继续展示短信验证码输入。
- 后端返回用户信息和 Cookie 后，登录成功。

`sso_webview`：

- App 根据当前渠道的 `sso` 服务地址打开内嵌 WebView。
- App 注入固定名称的 JavaScript 回调函数。
- 企业统一身份认证页面认证完成后调用该回调，并传入登录结果 JSON 字符串。
- App 解析 JSON，归一化用户信息，保存 SSO 续期凭证，并创建会话。

`password_only`：

- 用户输入账号和密码。
- 后端直接返回用户信息和 Cookie，不需要额外验证。

所有登录方式最终都进入同一条内部流程：

```text
LoginStrategy -> RawLoginResult -> UserNormalizer -> Session -> AppState.currentSession -> MainPage
```

新增登录方式的流程：

```text
新增 XxxLoginStrategy
  -> 在 LoginStrategyRegistry 注册 mode
  -> 在 channels.json 的 loginMethods 中配置 mode 和接口路径
  -> LoginPanel 自动展示该登录方式
  -> AuthService 通过 registry 调度该策略
```

## 用户信息归一化

不同渠道、不同登录方式返回的用户信息含义相同，但字段名可能不同。业务模块不能各自适配原始返回字段，必须统一读取归一化后的用户模型。

内部统一用户模型 `UserProfile`：

```text
UserProfile
  userId
  userName
  mobile
  department
  avatarUrl
  rawChannelUserInfo
```

内部统一会话模型 `Session`：

```text
Session
  channelId
  loginMode
  user
  cookies
  lastAuthAt
  createdAt
```

归一化规则：

- `UserNormalizer` 根据当前渠道的 `userMapping` 和 `cookieMapping` 提取字段。
- `userId`、`userName`、`cookies` 是有效登录会话的必填字段。
- `rawChannelUserInfo` 只用于诊断或特殊扩展场景，普通业务页面不直接读取。
- 页面只能通过 `AppState.currentSession.user` 读取用户信息。

## Cookie SSO 认证

App 后续网络服务请求统一使用 Cookie 做 SSO 认证。

规则：

- 页面不直接处理 Cookie。
- `HttpClient` 从 `Session.cookies` 读取 Cookie，并生成最终 `Cookie` 请求头。
- 如果响应更新 Cookie，`HttpClient` 负责更新 `SessionStore`。
- 退出登录时清理 Cookie 和失效会话状态。

## 自动登录与续期

自动登录是请求前主动触发的机制，不依赖后端返回 Cookie 过期错误。

触发条件：

```text
任意后续网络请求发起前：
  如果 now - Session.lastAuthAt > 28 分钟：
    先执行自动登录或续期
  否则：
    直接发送原请求
```

`lastAuthAt` 只在以下场景更新：

- 用户手动登录成功。
- 自动登录或续期成功。

普通业务请求成功不更新 `lastAuthAt`。

账号密码类登录的自动登录：

- App 私有目录保存 RSA 公钥加密后的账号密码凭证字符串。
- App 不保存明文密码。
- 自动登录时，把加密后的字符串传给后端。
- 后端使用私钥解密，并返回刷新后的 Cookie。

SSO WebView 登录的续期：

- App 保存 SSO WebView 登录结果中返回的续期凭证。
- 续期时调用配置的 API 服务，并传入 SSO 续期凭证。
- 后端返回刷新后的 Cookie。

请求流程：

```text
HttpClient.request()
  -> HeaderGuard 校验自定义请求头
  -> ServiceResolver 解析网关
  -> AuthService.ensureSessionFresh()
       -> 如果会话年龄 <= 28 分钟：继续
       -> 如果会话年龄 > 28 分钟：自动登录或续期
  -> 附加最新 Cookie
  -> 发送原请求
```

失败处理：

- 自动登录或续期失败时，清理无效 Cookie 和会话认证状态。
- 保留当前选择渠道。
- 不继续转发原业务请求。
- 跳转到 `LoginPage`。
- 提示 `登录状态已过期，请重新登录`。
- 用户需要手动重新登录。

并发规则：

- 多个请求同时发现会话超过 28 分钟时，只允许一个自动登录或续期流程执行。
- 其他请求等待该流程结果。
- 如果自动登录成功，等待中的请求使用新 Cookie 继续执行。
- 如果自动登录失败，等待中的请求全部中止，并跳转登录页。
- 自动登录请求本身不能再次触发自动登录检查。

## 服务地址解析

网络请求使用“服务类型 + API path”的方式调用。

服务类型：

```text
auth
business
sso
file
```

解析规则：

```text
如果 gatewayMode == MAG：
  resolvedUrl = magGateway + apiPath

如果 gatewayMode == ORIGINAL：
  resolvedUrl = originalGateway + apiPath
```

示例：

```text
HttpClient.post('auth', '/login/password', body)
=> https://mag.proxy.com/auth-gateway/login/password

HttpClient.get('business', '/home/modules')
=> https://mag.proxy.com/biz-gateway/home/modules

使用 service = 'sso' 和 path = '/login' 打开 SSO 页面
=> https://sso-a.example.com/sso/login
```

`ServiceResolver` 是唯一负责把服务类型和接口路径转换成完整 URL 的模块。

## 自定义请求头与安全拦截

`HttpClient` 支持可选自定义请求头：

```text
HttpClient.get(serviceType, apiPath, options?)
HttpClient.post(serviceType, apiPath, body, options?)

options.headers?: Record<string, string>
options.timeoutMs?: number
```

默认行为：

- 调用方可以不传自定义请求头。
- `HttpClient` 自动附加默认请求头和最新 Cookie。
- 调用方不能手动提供 Cookie。

允许的业务请求头示例：

```text
X-Request-Id
X-Trace-Id
X-Client-Scene
X-Business-Type
```

受保护或禁止的请求头：

```text
Cookie
Set-Cookie
Authorization
Host
Origin
Referer
Content-Length
Connection
```

请求头安全规则：

- 危险请求头直接拒绝，不静默忽略。
- 请求头名称必须符合合法格式。
- 请求头值不能包含换行符，避免 header injection。
- `Cookie` 永远在自定义请求头校验后由 `Session.cookies` 生成。
- 请求头合并顺序为：默认请求头、安全自定义请求头、Session Cookie。

## SSO WebView 桥接

App 使用固定 JS 回调函数名：

```text
window.MesplusSSOCallback(loginResultJson)
```

回调参数中可以包含用户字段、Cookie 和续期凭证。字段名允许因渠道不同而不同，由 `UserNormalizer` 统一归一化。

规则：

- 只有当前 SSO WebView 登录流程接受该回调。
- JSON 为空或格式错误时，登录失败。
- 缺少必填归一化字段时，登录失败。
- 原始 JSON 会转换成 `Session`，不会在 App 内到处分发。

## UI 设计

UI 在结构和视觉语言上高度接近微信，但业务内容体现工业软件属性。

登录页：

- 展示 App 名称和工业软件副标题。
- 展示渠道选择器。
- 根据当前渠道的 `loginMethods` 动态渲染登录面板。
- 如果当前渠道有多种登录方式，提供轻量登录方式切换。
- 配置错误、网络错误、登录失败通过 Toast 或弹窗提示。

主页面：

```text
MainPage
  HomePage
  ContactsPage
  WorkLogPage
  ProfilePage
```

底部签页：

- 使用类似微信的底部 Tab 样式。
- 图标在上，文字在下。
- 选中态使用绿色强调色。
- 页面背景使用浅灰色，列表和卡片区域使用白色。

首页：

- 顶部标题为 `首页` 或当前渠道名称。
- 下拉交互展示类似微信小程序搜索的搜索框。
- 搜索入口首版使用工业功能占位数据：
  - 设备巡检
  - 工单处理
  - 生产看板
  - 异常上报
- 首页主体展示工业功能卡片或入口占位。

通讯录：

- 不是聊天模块。
- 展示组织、部门、人员、常用联系人等占位列表。

工作日志：

- 展示日志标题、时间和状态。
- 可以保留 `新增日志` 入口占位，但首版不实现完整提交流程。

个人中心：

- 展示头像、归一化用户名、渠道名称和登录方式。
- 提供设置、关于、退出登录入口。
- 退出登录后清理会话并回到登录页。

布局约束：

- 避免过多层布局容器嵌套。
- 结构简单时使用 `Column` 和 `Row`。
- 对适合相对定位的区域使用 `RelativeContainer`，例如首页下拉搜索层和个人中心头部。
- 不为了制造间距额外增加空容器层，优先使用组件自身的 margin 和 padding。
- 列表页面使用 `List` 和 `ListItem`。

## 错误处理

- `channels.json` 缺失或非法：展示配置错误页或登录页错误状态。
- 当前选择渠道缺失：如果存在有效渠道，回退到第一个有效渠道。
- 服务配置非法：阻止相关请求，并提示内部配置错误。
- 登录失败：优先展示后端返回信息，否则展示通用登录失败提示。
- SSO WebView 加载失败：提示 `统一认证页面加载失败`。
- SSO 回调解析失败：提示 `统一认证返回数据异常`。
- 自动登录或续期失败：清理无效会话认证状态，保留渠道选择，跳转登录页，并提示 `登录状态已过期，请重新登录`。
- 请求头安全校验失败：按内部请求配置错误处理。

## 测试策略

自动化和手工检查需要覆盖：

- 渠道 rawfile 配置解析。
- 必填渠道和服务配置校验。
- `MAG` 和 `ORIGINAL` 网关 URL 解析。
- 不同字段名登录结果的用户归一化。
- Cookie 提取和 Session 创建。
- `HeaderGuard` 对允许和禁止请求头的处理。
- 包含换行符的请求头值被拒绝。
- `lastAuthAt` 超过 28 分钟时触发自动登录。
- 自动登录成功后更新 Cookie 并继续转发原请求。
- 自动登录失败后回到登录页，并且不转发原请求。
- 三种登录方式使用 mock 响应完成登录流程验证。
- 手工检查登录页、四个签页、首页下拉搜索、个人中心用户显示和退出登录。

## 首版不包含

- 通讯录、工作日志、个人中心详情的真实生产业务接口集成。
- 完整工作日志新增和提交流程。
- 真正的小程序运行框架。
- 聊天或即时通讯能力。
- 远程渠道配置服务。
- 非 Cookie 的 token 认证模式。
