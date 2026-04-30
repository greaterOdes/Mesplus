# Mesplus HarmonyOS ArkTS App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 基于已确认的中文设计文档，实现 Mesplus 鸿蒙 ArkTS 工业 App 首版基础框架。

**架构：** 采用轻量分层结构：`config/models/app/auth/network/pages/components`。先实现可单元测试的纯逻辑模块，再接入页面和 ArkUI 组件，最后做整体构建和手工验证。

**技术栈：** HarmonyOS ArkTS、ArkUI、Hypium 单元测试、`resources/rawfile` 本地配置、Cookie SSO、WebView JS Bridge。

---

## 前置事实

- 设计文档：`docs/superpowers/specs/2026-04-30-mesplus-harmony-app-design.md`。
- 当前工程不是 git 仓库，提交步骤执行 `git status --short` 会返回 `fatal: not a git repository`。实施时仍保留提交检查步骤；如果用户后续初始化 git，再按任务粒度提交。
- 当前环境未识别 `hvigor` 和 `ohpm` 命令。构建和测试优先在 DevEco Studio 中执行；如果终端配置好 DevEco 命令行，再补跑对应 CLI。
- 当前主入口是默认模板：`entry/src/main/ets/pages/Index.ets`。
- 现有测试入口是 `entry/src/test/List.test.ets`，当前只引用 `LocalUnit.test.ets`。

## 文件结构

实施后新增或修改以下文件。

配置与模型：

- Create: `entry/src/main/resources/rawfile/channels.json`，本地渠道配置。
- Create: `entry/src/main/ets/models/Channel.ets`，渠道、服务、登录方式、映射配置类型。
- Create: `entry/src/main/ets/models/UserProfile.ets`，归一化用户模型。
- Create: `entry/src/main/ets/models/Session.ets`，Cookie 会话模型。
- Create: `entry/src/main/ets/config/AppConstants.ets`，枚举和常量。
- Create: `entry/src/main/ets/config/ChannelConfigLoader.ets`，配置解析和校验。

认证与网络：

- Create: `entry/src/main/ets/app/AppState.ets`，内存态应用状态。
- Create: `entry/src/main/ets/app/SessionStore.ets`，会话保存接口和内存实现。
- Create: `entry/src/main/ets/auth/UserNormalizer.ets`，登录结果归一化。
- Create: `entry/src/main/ets/auth/CredentialStore.ets`，自动登录凭证接口和内存实现。
- Create: `entry/src/main/ets/auth/AuthService.ets`，登录、自动登录、SSO 续期流程。
- Create: `entry/src/main/ets/auth/WebBridge.ets`，SSO 回调名和 payload 解析入口。
- Create: `entry/src/main/ets/network/HeaderGuard.ets`，请求头安全校验。
- Create: `entry/src/main/ets/network/ServiceResolver.ets`，MAG/ORIGINAL 网关解析。
- Create: `entry/src/main/ets/network/HttpClient.ets`，统一请求入口。

页面与组件：

- Modify: `entry/src/main/ets/pages/Index.ets`，应用初始化入口。
- Create: `entry/src/main/ets/pages/LoginPage.ets`，登录页。
- Create: `entry/src/main/ets/pages/MainPage.ets`，四签页容器。
- Create: `entry/src/main/ets/pages/HomePage.ets`，首页与下拉搜索入口。
- Create: `entry/src/main/ets/pages/ContactsPage.ets`，通讯录占位页。
- Create: `entry/src/main/ets/pages/WorkLogPage.ets`，工作日志占位页。
- Create: `entry/src/main/ets/pages/ProfilePage.ets`，个人中心页。
- Create: `entry/src/main/ets/pages/SsoWebViewPage.ets`，SSO WebView 占位页。
- Create: `entry/src/main/ets/components/ChannelPicker.ets`，渠道选择组件。
- Create: `entry/src/main/ets/components/LoginPanel.ets`，登录方式面板。
- Create: `entry/src/main/ets/components/MiniProgramSearch.ets`，首页搜索浮层。
- Create: `entry/src/main/ets/components/WechatTabBar.ets`，微信风格底部签页。
- Modify: `entry/src/main/resources/base/profile/main_pages.json`，注册新增页面。

测试：

- Create: `entry/src/test/ChannelConfigLoader.test.ets`。
- Create: `entry/src/test/UserNormalizer.test.ets`。
- Create: `entry/src/test/ServiceResolver.test.ets`。
- Create: `entry/src/test/HeaderGuard.test.ets`。
- Create: `entry/src/test/AuthService.test.ets`。
- Modify: `entry/src/test/List.test.ets`，引用全部测试。

---

### Task 1: 渠道配置模型和配置解析

**Files:**
- Create: `entry/src/main/resources/rawfile/channels.json`
- Create: `entry/src/main/ets/config/AppConstants.ets`
- Create: `entry/src/main/ets/models/Channel.ets`
- Create: `entry/src/main/ets/config/ChannelConfigLoader.ets`
- Create: `entry/src/test/ChannelConfigLoader.test.ets`
- Modify: `entry/src/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

在 `entry/src/test/ChannelConfigLoader.test.ets` 写入：

```ts
import { describe, it, expect } from '@ohos/hypium';
import { parseChannelConfig } from '../main/ets/config/ChannelConfigLoader';

export default function channelConfigLoaderTest() {
  describe('channelConfigLoaderTest', () => {
    it('parseValidConfig', 0, () => {
      const jsonText = JSON.stringify({
        channels: [{
          id: 'factory_a',
          name: '工厂A',
          loginModes: ['password_sms_first_device', 'sso_webview'],
          userMapping: { userId: ['userId', 'id'], userName: ['userName'], mobile: ['mobile'], department: ['department'], avatarUrl: ['avatarUrl'] },
          cookieMapping: { cookie: ['cookie', 'setCookie'] },
          autoLogin: {
            enabled: true,
            intervalMinutes: 28,
            passwordLogin: { service: 'auth', path: '/session/auto-login' },
            ssoRenewal: { service: 'auth', path: '/session/sso-renewal' }
          },
          services: {
            auth: { gatewayMode: 'MAG', magGateway: 'https://mag.proxy.com/auth-gateway', originalGateway: 'https://auth-a.example.com/auth-gateway' },
            business: { gatewayMode: 'MAG', magGateway: 'https://mag.proxy.com/biz-gateway', originalGateway: 'https://biz-a.example.com/biz-gateway' },
            sso: { gatewayMode: 'ORIGINAL', magGateway: 'https://mag.proxy.com/sso-gateway', originalGateway: 'https://sso-a.example.com/sso' },
            file: { gatewayMode: 'ORIGINAL', magGateway: 'https://mag.proxy.com/file-gateway', originalGateway: 'https://file-a.example.com/file-gateway' }
          }
        }]
      });

      const config = parseChannelConfig(jsonText);
      expect(config.channels.length).assertEqual(1);
      expect(config.channels[0].id).assertEqual('factory_a');
      expect(config.channels[0].services.auth.gatewayMode).assertEqual('MAG');
      expect(config.channels[0].autoLogin.intervalMinutes).assertEqual(28);
    });

    it('rejectInvalidGatewayMode', 0, () => {
      const jsonText = JSON.stringify({
        channels: [{
          id: 'factory_a',
          name: '工厂A',
          loginModes: ['password_only'],
          userMapping: { userId: ['userId'], userName: ['userName'] },
          cookieMapping: { cookie: ['cookie'] },
          autoLogin: { enabled: true, intervalMinutes: 28, passwordLogin: { service: 'auth', path: '/auto' }, ssoRenewal: { service: 'auth', path: '/renew' } },
          services: {
            auth: { gatewayMode: 'BAD', magGateway: 'https://mag/a', originalGateway: 'https://origin/a' },
            business: { gatewayMode: 'MAG', magGateway: 'https://mag/b', originalGateway: 'https://origin/b' },
            sso: { gatewayMode: 'ORIGINAL', magGateway: 'https://mag/s', originalGateway: 'https://origin/s' },
            file: { gatewayMode: 'ORIGINAL', magGateway: 'https://mag/f', originalGateway: 'https://origin/f' }
          }
        }]
      });

      let failed = false;
      try {
        parseChannelConfig(jsonText);
      } catch (err) {
        failed = true;
      }
      expect(failed).assertTrue();
    });
  });
}
```

修改 `entry/src/test/List.test.ets`：

```ts
import localUnitTest from './LocalUnit.test';
import channelConfigLoaderTest from './ChannelConfigLoader.test';

export default function testsuite() {
  localUnitTest();
  channelConfigLoaderTest();
}
```

- [ ] **Step 2: 运行测试并确认失败**

在 DevEco Studio 中运行 `entry/src/test/List.test.ets` 本地单元测试。

期望：编译失败，错误包含 `Cannot find module '../main/ets/config/ChannelConfigLoader'` 或 `parseChannelConfig` 未定义。

- [ ] **Step 3: 添加模型和解析实现**

创建 `entry/src/main/ets/config/AppConstants.ets`：

```ts
export enum LoginMode {
  PASSWORD_SMS_FIRST_DEVICE = 'password_sms_first_device',
  SSO_WEBVIEW = 'sso_webview',
  PASSWORD_ONLY = 'password_only'
}

export enum ServiceType {
  AUTH = 'auth',
  BUSINESS = 'business',
  SSO = 'sso',
  FILE = 'file'
}

export enum GatewayMode {
  MAG = 'MAG',
  ORIGINAL = 'ORIGINAL'
}

export const DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES: number = 28;
```

创建 `entry/src/main/ets/models/Channel.ets`：

```ts
import { GatewayMode, LoginMode, ServiceType } from '../config/AppConstants';

export interface FieldMapping {
  userId: string[];
  userName: string[];
  mobile?: string[];
  department?: string[];
  avatarUrl?: string[];
}

export interface CookieMapping {
  cookie: string[];
}

export interface ServiceGatewayConfig {
  gatewayMode: GatewayMode;
  magGateway: string;
  originalGateway: string;
}

export type ServiceMap = Record<ServiceType, ServiceGatewayConfig>;

export interface AutoLoginEndpointConfig {
  service: ServiceType;
  path: string;
}

export interface AutoLoginConfig {
  enabled: boolean;
  intervalMinutes: number;
  passwordLogin: AutoLoginEndpointConfig;
  ssoRenewal: AutoLoginEndpointConfig;
}

export interface Channel {
  id: string;
  name: string;
  loginModes: LoginMode[];
  userMapping: FieldMapping;
  cookieMapping: CookieMapping;
  autoLogin: AutoLoginConfig;
  services: ServiceMap;
}

export interface ChannelConfig {
  channels: Channel[];
}
```

创建 `entry/src/main/ets/config/ChannelConfigLoader.ets`：

```ts
import { DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES, GatewayMode, LoginMode, ServiceType } from './AppConstants';
import { AutoLoginConfig, Channel, ChannelConfig, ServiceGatewayConfig, ServiceMap } from '../models/Channel';

function requireString(value: object | string | number | boolean | null | undefined, name: string): string {
  if (typeof value !== 'string' || value.length === 0) {
    throw new Error(`Invalid ${name}`);
  }
  return value;
}

function requireStringArray(value: object | string[] | null | undefined, name: string): string[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(`Invalid ${name}`);
  }
  return value.map((item: string) => requireString(item, name));
}

function parseGatewayMode(value: string): GatewayMode {
  if (value === GatewayMode.MAG) {
    return GatewayMode.MAG;
  }
  if (value === GatewayMode.ORIGINAL) {
    return GatewayMode.ORIGINAL;
  }
  throw new Error(`Invalid gatewayMode: ${value}`);
}

function parseLoginModes(values: string[]): LoginMode[] {
  return values.map((value: string) => {
    if (value === LoginMode.PASSWORD_SMS_FIRST_DEVICE || value === LoginMode.SSO_WEBVIEW || value === LoginMode.PASSWORD_ONLY) {
      return value as LoginMode;
    }
    throw new Error(`Invalid loginMode: ${value}`);
  });
}

function parseService(service: Record<string, string>, name: string): ServiceGatewayConfig {
  return {
    gatewayMode: parseGatewayMode(requireString(service.gatewayMode, `${name}.gatewayMode`)),
    magGateway: requireString(service.magGateway, `${name}.magGateway`),
    originalGateway: requireString(service.originalGateway, `${name}.originalGateway`)
  };
}

function parseServices(services: Record<string, Record<string, string>>): ServiceMap {
  return {
    [ServiceType.AUTH]: parseService(services.auth, 'auth'),
    [ServiceType.BUSINESS]: parseService(services.business, 'business'),
    [ServiceType.SSO]: parseService(services.sso, 'sso'),
    [ServiceType.FILE]: parseService(services.file, 'file')
  };
}

function parseAutoLogin(raw: Record<string, object | string | number | boolean>): AutoLoginConfig {
  const passwordLogin = raw.passwordLogin as Record<string, string>;
  const ssoRenewal = raw.ssoRenewal as Record<string, string>;
  return {
    enabled: raw.enabled === true,
    intervalMinutes: typeof raw.intervalMinutes === 'number' ? raw.intervalMinutes : DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES,
    passwordLogin: { service: passwordLogin.service as ServiceType, path: requireString(passwordLogin.path, 'passwordLogin.path') },
    ssoRenewal: { service: ssoRenewal.service as ServiceType, path: requireString(ssoRenewal.path, 'ssoRenewal.path') }
  };
}

export function parseChannelConfig(jsonText: string): ChannelConfig {
  const root = JSON.parse(jsonText) as Record<string, object[]>;
  if (!Array.isArray(root.channels) || root.channels.length === 0) {
    throw new Error('Invalid channels');
  }

  const channels: Channel[] = root.channels.map((rawItem: object) => {
    const raw = rawItem as Record<string, object | string | string[]>;
    const userMapping = raw.userMapping as Record<string, string[]>;
    const cookieMapping = raw.cookieMapping as Record<string, string[]>;
    return {
      id: requireString(raw.id as string, 'id'),
      name: requireString(raw.name as string, 'name'),
      loginModes: parseLoginModes(requireStringArray(raw.loginModes as string[], 'loginModes')),
      userMapping: {
        userId: requireStringArray(userMapping.userId, 'userMapping.userId'),
        userName: requireStringArray(userMapping.userName, 'userMapping.userName'),
        mobile: userMapping.mobile,
        department: userMapping.department,
        avatarUrl: userMapping.avatarUrl
      },
      cookieMapping: { cookie: requireStringArray(cookieMapping.cookie, 'cookieMapping.cookie') },
      autoLogin: parseAutoLogin(raw.autoLogin as Record<string, object | string | number | boolean>),
      services: parseServices(raw.services as Record<string, Record<string, string>>)
    };
  });

  return { channels };
}
```

创建 `entry/src/main/resources/rawfile/channels.json`，内容使用设计文档中的示例 JSON。

- [ ] **Step 4: 运行测试并确认通过**

在 DevEco Studio 中运行 `entry/src/test/List.test.ets`。

期望：`localUnitTest` 和 `channelConfigLoaderTest` 均通过。

- [ ] **Step 5: 提交检查**

运行：`git status --short`

期望：如果仓库未初始化，输出 `fatal: not a git repository`；如果已初始化，暂存并提交：`git add entry/src/main/resources/rawfile/channels.json entry/src/main/ets/config entry/src/main/ets/models entry/src/test && git commit -m "feat: add channel configuration model"`。

---

### Task 2: 用户归一化和 Session 模型

**Files:**
- Create: `entry/src/main/ets/models/UserProfile.ets`
- Create: `entry/src/main/ets/models/Session.ets`
- Create: `entry/src/main/ets/auth/UserNormalizer.ets`
- Create: `entry/src/test/UserNormalizer.test.ets`
- Modify: `entry/src/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

创建 `entry/src/test/UserNormalizer.test.ets`，覆盖不同字段名归一化、Cookie 提取和必填字段失败：

```ts
import { describe, it, expect } from '@ohos/hypium';
import { normalizeLoginResult } from '../main/ets/auth/UserNormalizer';
import { LoginMode } from '../main/ets/config/AppConstants';
import { FieldMapping, CookieMapping } from '../main/ets/models/Channel';

export default function userNormalizerTest() {
  describe('userNormalizerTest', () => {
    const userMapping: FieldMapping = {
      userId: ['userId', 'user_id', 'id'],
      userName: ['userName', 'realName', 'name'],
      mobile: ['mobile', 'phone'],
      department: ['department', 'deptName'],
      avatarUrl: ['avatarUrl']
    };
    const cookieMapping: CookieMapping = { cookie: ['cookie', 'setCookie', 'sessionCookie'] };

    it('normalizeDifferentFieldNames', 0, () => {
      const session = normalizeLoginResult('factory_a', LoginMode.PASSWORD_ONLY, {
        user_id: 'u001',
        realName: '张三',
        phone: '13800000000',
        deptName: '制造一部',
        setCookie: 'MESPLUS_SSO=abc; Path=/'
      }, userMapping, cookieMapping, 1000);

      expect(session.user.userId).assertEqual('u001');
      expect(session.user.userName).assertEqual('张三');
      expect(session.user.department).assertEqual('制造一部');
      expect(session.cookies).assertEqual('MESPLUS_SSO=abc; Path=/');
      expect(session.lastAuthAt).assertEqual(1000);
    });

    it('rejectMissingCookie', 0, () => {
      let failed = false;
      try {
        normalizeLoginResult('factory_a', LoginMode.PASSWORD_ONLY, { userId: 'u001', userName: '张三' }, userMapping, cookieMapping, 1000);
      } catch (err) {
        failed = true;
      }
      expect(failed).assertTrue();
    });
  });
}
```

修改 `entry/src/test/List.test.ets` 引用 `userNormalizerTest()`。

- [ ] **Step 2: 运行测试并确认失败**

在 DevEco Studio 中运行本地单元测试。

期望：`UserNormalizer` 或 `normalizeLoginResult` 未定义。

- [ ] **Step 3: 添加实现**

创建 `entry/src/main/ets/models/UserProfile.ets`：

```ts
export interface UserProfile {
  userId: string;
  userName: string;
  mobile: string;
  department: string;
  avatarUrl: string;
  rawChannelUserInfo: Record<string, object | string | number | boolean>;
}
```

创建 `entry/src/main/ets/models/Session.ets`：

```ts
import { LoginMode } from '../config/AppConstants';
import { UserProfile } from './UserProfile';

export interface Session {
  channelId: string;
  loginMode: LoginMode;
  user: UserProfile;
  cookies: string;
  lastAuthAt: number;
  createdAt: number;
}
```

创建 `entry/src/main/ets/auth/UserNormalizer.ets`：

```ts
import { LoginMode } from '../config/AppConstants';
import { CookieMapping, FieldMapping } from '../models/Channel';
import { Session } from '../models/Session';

type RawLoginResult = Record<string, object | string | number | boolean>;

function readMappedString(raw: RawLoginResult, names: string[] | undefined): string {
  if (!names) {
    return '';
  }
  for (const name of names) {
    const value = raw[name];
    if (typeof value === 'string' && value.length > 0) {
      return value;
    }
  }
  return '';
}

export function normalizeLoginResult(
  channelId: string,
  loginMode: LoginMode,
  raw: RawLoginResult,
  userMapping: FieldMapping,
  cookieMapping: CookieMapping,
  now: number
): Session {
  const userId = readMappedString(raw, userMapping.userId);
  const userName = readMappedString(raw, userMapping.userName);
  const cookies = readMappedString(raw, cookieMapping.cookie);

  if (userId.length === 0 || userName.length === 0 || cookies.length === 0) {
    throw new Error('Invalid login result');
  }

  return {
    channelId,
    loginMode,
    cookies,
    lastAuthAt: now,
    createdAt: now,
    user: {
      userId,
      userName,
      mobile: readMappedString(raw, userMapping.mobile),
      department: readMappedString(raw, userMapping.department),
      avatarUrl: readMappedString(raw, userMapping.avatarUrl),
      rawChannelUserInfo: raw
    }
  };
}
```

- [ ] **Step 4: 运行测试并确认通过**

在 DevEco Studio 中运行本地单元测试。

期望：`UserNormalizer.test.ets` 通过。

- [ ] **Step 5: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/ets/models entry/src/main/ets/auth/UserNormalizer.ets entry/src/test && git commit -m "feat: normalize login user sessions"`。

---

### Task 3: 网关解析和请求头安全校验

**Files:**
- Create: `entry/src/main/ets/network/ServiceResolver.ets`
- Create: `entry/src/main/ets/network/HeaderGuard.ets`
- Create: `entry/src/test/ServiceResolver.test.ets`
- Create: `entry/src/test/HeaderGuard.test.ets`
- Modify: `entry/src/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

创建 `entry/src/test/ServiceResolver.test.ets`：

```ts
import { describe, it, expect } from '@ohos/hypium';
import { resolveServiceUrl } from '../main/ets/network/ServiceResolver';
import { GatewayMode, ServiceType } from '../main/ets/config/AppConstants';
import { ServiceMap } from '../main/ets/models/Channel';

export default function serviceResolverTest() {
  describe('serviceResolverTest', () => {
    const services: ServiceMap = {
      auth: { gatewayMode: GatewayMode.MAG, magGateway: 'https://mag.proxy.com/auth-gateway', originalGateway: 'https://auth-a.example.com/auth-gateway' },
      business: { gatewayMode: GatewayMode.MAG, magGateway: 'https://mag.proxy.com/biz-gateway', originalGateway: 'https://biz-a.example.com/biz-gateway' },
      sso: { gatewayMode: GatewayMode.ORIGINAL, magGateway: 'https://mag.proxy.com/sso-gateway', originalGateway: 'https://sso-a.example.com/sso' },
      file: { gatewayMode: GatewayMode.ORIGINAL, magGateway: 'https://mag.proxy.com/file-gateway', originalGateway: 'https://file-a.example.com/file-gateway' }
    };

    it('resolveMagUrl', 0, () => {
      expect(resolveServiceUrl(services, ServiceType.AUTH, '/login/password')).assertEqual('https://mag.proxy.com/auth-gateway/login/password');
    });

    it('resolveOriginalUrl', 0, () => {
      expect(resolveServiceUrl(services, ServiceType.SSO, '/login')).assertEqual('https://sso-a.example.com/sso/login');
    });
  });
}
```

创建 `entry/src/test/HeaderGuard.test.ets`：

```ts
import { describe, it, expect } from '@ohos/hypium';
import { mergeSafeHeaders } from '../main/ets/network/HeaderGuard';

export default function headerGuardTest() {
  describe('headerGuardTest', () => {
    it('allowBusinessHeaderAndAppendCookie', 0, () => {
      const headers = mergeSafeHeaders({ 'X-Trace-Id': 'trace-1' }, 'MESPLUS_SSO=abc');
      expect(headers['X-Trace-Id']).assertEqual('trace-1');
      expect(headers['Cookie']).assertEqual('MESPLUS_SSO=abc');
    });

    it('rejectCookieOverride', 0, () => {
      let failed = false;
      try {
        mergeSafeHeaders({ 'Cookie': 'bad=true' }, 'MESPLUS_SSO=abc');
      } catch (err) {
        failed = true;
      }
      expect(failed).assertTrue();
    });

    it('rejectHeaderInjection', 0, () => {
      let failed = false;
      try {
        mergeSafeHeaders({ 'X-Trace-Id': 'a\r\nb' }, 'MESPLUS_SSO=abc');
      } catch (err) {
        failed = true;
      }
      expect(failed).assertTrue();
    });
  });
}
```

修改 `entry/src/test/List.test.ets` 引用新增测试。

- [ ] **Step 2: 运行测试并确认失败**

在 DevEco Studio 中运行本地单元测试。

期望：`ServiceResolver` 和 `HeaderGuard` 未定义。

- [ ] **Step 3: 添加实现**

创建 `entry/src/main/ets/network/ServiceResolver.ets`：

```ts
import { GatewayMode, ServiceType } from '../config/AppConstants';
import { ServiceMap } from '../models/Channel';

export function resolveServiceUrl(services: ServiceMap, serviceType: ServiceType, apiPath: string): string {
  const service = services[serviceType];
  if (!service) {
    throw new Error(`Missing service: ${serviceType}`);
  }
  if (!apiPath.startsWith('/')) {
    throw new Error('apiPath must start with /');
  }
  const gateway = service.gatewayMode === GatewayMode.MAG ? service.magGateway : service.originalGateway;
  if (gateway.length === 0) {
    throw new Error(`Invalid gateway for ${serviceType}`);
  }
  return `${gateway}${apiPath}`;
}
```

创建 `entry/src/main/ets/network/HeaderGuard.ets`：

```ts
export type RequestHeaders = Record<string, string>;

const FORBIDDEN_HEADERS: string[] = [
  'cookie',
  'set-cookie',
  'authorization',
  'host',
  'origin',
  'referer',
  'content-length',
  'connection'
];

function isValidHeaderName(name: string): boolean {
  return /^[A-Za-z0-9-]+$/.test(name);
}

export function mergeSafeHeaders(customHeaders: RequestHeaders | undefined, cookies: string): RequestHeaders {
  const headers: RequestHeaders = { 'Content-Type': 'application/json' };
  if (customHeaders) {
    Object.keys(customHeaders).forEach((name: string) => {
      const normalized = name.toLowerCase();
      const value = customHeaders[name];
      if (!isValidHeaderName(name)) {
        throw new Error(`Invalid header name: ${name}`);
      }
      if (FORBIDDEN_HEADERS.indexOf(normalized) >= 0) {
        throw new Error(`Forbidden header: ${name}`);
      }
      if (value.indexOf('\n') >= 0 || value.indexOf('\r') >= 0) {
        throw new Error(`Invalid header value: ${name}`);
      }
      headers[name] = value;
    });
  }
  if (cookies.length > 0) {
    headers['Cookie'] = cookies;
  }
  return headers;
}
```

- [ ] **Step 4: 运行测试并确认通过**

在 DevEco Studio 中运行本地单元测试。

期望：`ServiceResolver.test.ets` 和 `HeaderGuard.test.ets` 通过。

- [ ] **Step 5: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/ets/network entry/src/test && git commit -m "feat: add gateway and header guards"`。

---

### Task 4: AppState、SessionStore、CredentialStore 和 AuthService 自动登录

**Files:**
- Create: `entry/src/main/ets/app/AppState.ets`
- Create: `entry/src/main/ets/app/SessionStore.ets`
- Create: `entry/src/main/ets/auth/CredentialStore.ets`
- Create: `entry/src/main/ets/auth/AuthService.ets`
- Create: `entry/src/test/AuthService.test.ets`
- Modify: `entry/src/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

创建 `entry/src/test/AuthService.test.ets`，验证 28 分钟触发、成功更新 Cookie、失败回登录状态：

```ts
import { describe, it, expect } from '@ohos/hypium';
import { AuthService, AutoLoginResult } from '../main/ets/auth/AuthService';
import { InMemoryCredentialStore } from '../main/ets/auth/CredentialStore';
import { InMemorySessionStore } from '../main/ets/app/SessionStore';
import { LoginMode, ServiceType } from '../main/ets/config/AppConstants';

export default function authServiceTest() {
  describe('authServiceTest', () => {
    it('skipAutoLoginBefore28Minutes', async () => {
      const sessionStore = new InMemorySessionStore();
      sessionStore.saveSession({ channelId: 'factory_a', loginMode: LoginMode.PASSWORD_ONLY, cookies: 'old=1', lastAuthAt: 1000, createdAt: 1000, user: { userId: 'u001', userName: '张三', mobile: '', department: '', avatarUrl: '', rawChannelUserInfo: {} } });
      const service = new AuthService(sessionStore, new InMemoryCredentialStore(), async (): Promise<AutoLoginResult> => ({ success: true, cookies: 'new=1' }));
      const result = await service.ensureSessionFresh(1000 + 27 * 60 * 1000, 28, { service: ServiceType.AUTH, path: '/auto' });
      expect(result).assertTrue();
      expect(sessionStore.getSession()?.cookies).assertEqual('old=1');
    });

    it('refreshAfter28Minutes', async () => {
      const sessionStore = new InMemorySessionStore();
      sessionStore.saveSession({ channelId: 'factory_a', loginMode: LoginMode.PASSWORD_ONLY, cookies: 'old=1', lastAuthAt: 1000, createdAt: 1000, user: { userId: 'u001', userName: '张三', mobile: '', department: '', avatarUrl: '', rawChannelUserInfo: {} } });
      const service = new AuthService(sessionStore, new InMemoryCredentialStore(), async (): Promise<AutoLoginResult> => ({ success: true, cookies: 'new=1' }));
      const result = await service.ensureSessionFresh(1000 + 29 * 60 * 1000, 28, { service: ServiceType.AUTH, path: '/auto' });
      expect(result).assertTrue();
      expect(sessionStore.getSession()?.cookies).assertEqual('new=1');
      expect(sessionStore.getSession()?.lastAuthAt).assertEqual(1000 + 29 * 60 * 1000);
    });

    it('clearSessionOnAutoLoginFailure', async () => {
      const sessionStore = new InMemorySessionStore();
      sessionStore.saveSession({ channelId: 'factory_a', loginMode: LoginMode.PASSWORD_ONLY, cookies: 'old=1', lastAuthAt: 1000, createdAt: 1000, user: { userId: 'u001', userName: '张三', mobile: '', department: '', avatarUrl: '', rawChannelUserInfo: {} } });
      const service = new AuthService(sessionStore, new InMemoryCredentialStore(), async (): Promise<AutoLoginResult> => ({ success: false, cookies: '' }));
      const result = await service.ensureSessionFresh(1000 + 29 * 60 * 1000, 28, { service: ServiceType.AUTH, path: '/auto' });
      expect(result).assertFalse();
      expect(sessionStore.getSession() === undefined).assertTrue();
    });
  });
}
```

修改 `entry/src/test/List.test.ets` 引用 `authServiceTest()`。

- [ ] **Step 2: 运行测试并确认失败**

在 DevEco Studio 中运行本地单元测试。

期望：`AuthService`、`InMemoryCredentialStore`、`InMemorySessionStore` 未定义。

- [ ] **Step 3: 添加实现**

创建 `entry/src/main/ets/app/SessionStore.ets`：

```ts
import { Session } from '../models/Session';

export interface SessionStore {
  getSession(): Session | undefined;
  saveSession(session: Session): void;
  clearSession(): void;
  updateCookies(cookies: string, lastAuthAt: number): void;
}

export class InMemorySessionStore implements SessionStore {
  private session: Session | undefined = undefined;

  getSession(): Session | undefined {
    return this.session;
  }

  saveSession(session: Session): void {
    this.session = session;
  }

  clearSession(): void {
    this.session = undefined;
  }

  updateCookies(cookies: string, lastAuthAt: number): void {
    if (!this.session) {
      return;
    }
    this.session = { ...this.session, cookies, lastAuthAt };
  }
}
```

创建 `entry/src/main/ets/auth/CredentialStore.ets`：

```ts
import { LoginMode } from '../config/AppConstants';

export interface PasswordCredential {
  channelId: string;
  loginMode: LoginMode;
  encryptedAccountPassword: string;
}

export interface SsoCredential {
  channelId: string;
  loginMode: LoginMode;
  renewalCredential: string;
}

export interface CredentialStore {
  getPasswordCredential(channelId: string): PasswordCredential | undefined;
  savePasswordCredential(credential: PasswordCredential): void;
  getSsoCredential(channelId: string): SsoCredential | undefined;
  saveSsoCredential(credential: SsoCredential): void;
}

export class InMemoryCredentialStore implements CredentialStore {
  private passwordCredential: PasswordCredential | undefined = undefined;
  private ssoCredential: SsoCredential | undefined = undefined;

  getPasswordCredential(channelId: string): PasswordCredential | undefined {
    return this.passwordCredential?.channelId === channelId ? this.passwordCredential : undefined;
  }

  savePasswordCredential(credential: PasswordCredential): void {
    this.passwordCredential = credential;
  }

  getSsoCredential(channelId: string): SsoCredential | undefined {
    return this.ssoCredential?.channelId === channelId ? this.ssoCredential : undefined;
  }

  saveSsoCredential(credential: SsoCredential): void {
    this.ssoCredential = credential;
  }
}
```

创建 `entry/src/main/ets/auth/AuthService.ets`：

```ts
import { SessionStore } from '../app/SessionStore';
import { CredentialStore } from './CredentialStore';
import { LoginMode, ServiceType } from '../config/AppConstants';

export interface AutoLoginEndpoint {
  service: ServiceType;
  path: string;
}

export interface AutoLoginResult {
  success: boolean;
  cookies: string;
}

export type AutoLoginExecutor = (channelId: string, loginMode: LoginMode, endpoint: AutoLoginEndpoint) => Promise<AutoLoginResult>;

export class AuthService {
  private refreshing: Promise<boolean> | undefined = undefined;

  constructor(
    private sessionStore: SessionStore,
    private credentialStore: CredentialStore,
    private executor: AutoLoginExecutor
  ) {}

  async ensureSessionFresh(now: number, intervalMinutes: number, endpoint: AutoLoginEndpoint): Promise<boolean> {
    const session = this.sessionStore.getSession();
    if (!session) {
      return false;
    }
    const intervalMs = intervalMinutes * 60 * 1000;
    if (now - session.lastAuthAt <= intervalMs) {
      return true;
    }
    if (!this.refreshing) {
      this.refreshing = this.runRefresh(now, endpoint);
    }
    const result = await this.refreshing;
    this.refreshing = undefined;
    return result;
  }

  private async runRefresh(now: number, endpoint: AutoLoginEndpoint): Promise<boolean> {
    const session = this.sessionStore.getSession();
    if (!session) {
      return false;
    }
    const result = await this.executor(session.channelId, session.loginMode, endpoint);
    if (!result.success || result.cookies.length === 0) {
      this.sessionStore.clearSession();
      return false;
    }
    this.sessionStore.updateCookies(result.cookies, now);
    return true;
  }
}
```

创建 `entry/src/main/ets/app/AppState.ets`：

```ts
import { Channel } from '../models/Channel';
import { Session } from '../models/Session';

export class AppState {
  channels: Channel[] = [];
  currentChannel: Channel | undefined = undefined;
  currentSession: Session | undefined = undefined;

  get isLoggedIn(): boolean {
    return this.currentSession !== undefined && this.currentSession.cookies.length > 0;
  }
}

export const appState = new AppState();
```

- [ ] **Step 4: 运行测试并确认通过**

在 DevEco Studio 中运行本地单元测试。

期望：`AuthService.test.ets` 通过。

- [ ] **Step 5: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/ets/app entry/src/main/ets/auth entry/src/test && git commit -m "feat: add session auto login flow"`。

---

### Task 5: HttpClient 请求编排和 WebBridge

**Files:**
- Create: `entry/src/main/ets/network/HttpClient.ets`
- Create: `entry/src/main/ets/auth/WebBridge.ets`

- [ ] **Step 1: 添加 HttpClient 最小实现**

创建 `entry/src/main/ets/network/HttpClient.ets`：

```ts
import { ServiceType } from '../config/AppConstants';
import { AutoLoginEndpoint, AuthService } from '../auth/AuthService';
import { SessionStore } from '../app/SessionStore';
import { ServiceMap } from '../models/Channel';
import { mergeSafeHeaders, RequestHeaders } from './HeaderGuard';
import { resolveServiceUrl } from './ServiceResolver';

export interface HttpRequestOptions {
  headers?: RequestHeaders;
  timeoutMs?: number;
  skipAutoLogin?: boolean;
}

export interface HttpRequestRecord {
  method: string;
  url: string;
  headers: RequestHeaders;
  body: string;
}

export type RequestSender = (record: HttpRequestRecord) => Promise<string>;

export class HttpClient {
  constructor(
    private services: ServiceMap,
    private sessionStore: SessionStore,
    private authService: AuthService,
    private autoLoginEndpoint: AutoLoginEndpoint,
    private sender: RequestSender
  ) {}

  async get(serviceType: ServiceType, apiPath: string, options?: HttpRequestOptions): Promise<string> {
    return this.request('GET', serviceType, apiPath, '', options);
  }

  async post(serviceType: ServiceType, apiPath: string, body: string, options?: HttpRequestOptions): Promise<string> {
    return this.request('POST', serviceType, apiPath, body, options);
  }

  private async request(method: string, serviceType: ServiceType, apiPath: string, body: string, options?: HttpRequestOptions): Promise<string> {
    const session = this.sessionStore.getSession();
    if (!options?.skipAutoLogin) {
      const fresh = await this.authService.ensureSessionFresh(Date.now(), 28, this.autoLoginEndpoint);
      if (!fresh) {
        throw new Error('登录状态已过期，请重新登录');
      }
    }
    const latestSession = this.sessionStore.getSession();
    const headers = mergeSafeHeaders(options?.headers, latestSession?.cookies ?? session?.cookies ?? '');
    return this.sender({ method, url: resolveServiceUrl(this.services, serviceType, apiPath), headers, body });
  }
}
```

- [ ] **Step 2: 添加 WebBridge 常量和解析入口**

创建 `entry/src/main/ets/auth/WebBridge.ets`：

```ts
export const SSO_CALLBACK_NAME: string = 'MesplusSSOCallback';

export type SsoCallbackPayload = Record<string, object | string | number | boolean>;

export function parseSsoCallbackPayload(jsonText: string): SsoCallbackPayload {
  if (jsonText.length === 0) {
    throw new Error('Empty SSO callback payload');
  }
  const parsed = JSON.parse(jsonText) as SsoCallbackPayload;
  return parsed;
}
```

- [ ] **Step 3: 编译检查**

在 DevEco Studio 中执行 Make Module `entry`。

期望：没有类型错误。如果报 ArkTS 类型约束错误，优先收紧 `Record` 类型，不放宽到 `any`。

- [ ] **Step 4: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/ets/network/HttpClient.ets entry/src/main/ets/auth/WebBridge.ets && git commit -m "feat: add http client request flow"`。

---

### Task 6: 页面注册和主入口初始化

**Files:**
- Modify: `entry/src/main/resources/base/profile/main_pages.json`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Create: `entry/src/main/ets/pages/LoginPage.ets`
- Create: `entry/src/main/ets/pages/MainPage.ets`

- [ ] **Step 1: 注册页面**

修改 `entry/src/main/resources/base/profile/main_pages.json`：

```json
{
  "src": [
    "pages/Index",
    "pages/LoginPage",
    "pages/MainPage",
    "pages/HomePage",
    "pages/ContactsPage",
    "pages/WorkLogPage",
    "pages/ProfilePage",
    "pages/SsoWebViewPage"
  ]
}
```

- [ ] **Step 2: 替换 Index 入口**

将 `entry/src/main/ets/pages/Index.ets` 替换为：

```ts
import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    RelativeContainer() {
      Text('Mesplus')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
```

- [ ] **Step 3: 创建 LoginPage 和 MainPage 骨架**

创建 `entry/src/main/ets/pages/LoginPage.ets`：

```ts
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @State selectedMode: string = '账号密码登录';

  build() {
    RelativeContainer() {
      Text('Mesplus')
        .id('title')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
        .alignRules({ top: { anchor: '__container__', align: VerticalAlign.Top }, middle: { anchor: '__container__', align: HorizontalAlign.Center } })
        .margin({ top: 96 });

      Text('工业协同平台')
        .id('subtitle')
        .fontSize(15)
        .fontColor('#666666')
        .alignRules({ top: { anchor: 'title', align: VerticalAlign.Bottom }, middle: { anchor: '__container__', align: HorizontalAlign.Center } })
        .margin({ top: 10 });

      Column({ space: 16 }) {
        Button('工厂A')
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .fontColor('#111111');

        TextInput({ placeholder: '账号' }).height(44).backgroundColor('#FFFFFF');
        TextInput({ placeholder: '密码' }).height(44).type(InputType.Password).backgroundColor('#FFFFFF');

        Button('登录')
          .width('100%')
          .height(46)
          .backgroundColor('#07C160')
          .onClick(() => router.replaceUrl({ url: 'pages/MainPage' }));
      }
      .id('loginPanel')
      .width('86%')
      .alignRules({ top: { anchor: 'subtitle', align: VerticalAlign.Bottom }, middle: { anchor: '__container__', align: HorizontalAlign.Center } })
      .margin({ top: 56 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED');
  }
}
```

创建 `entry/src/main/ets/pages/MainPage.ets`：

```ts
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  @Builder
  CurrentContent() {
    if (this.currentIndex === 0) {
      HomePageContent();
    } else if (this.currentIndex === 1) {
      PlaceholderPage('通讯录');
    } else if (this.currentIndex === 2) {
      PlaceholderPage('工作日志');
    } else {
      PlaceholderPage('个人中心');
    }
  }

  build() {
    Column() {
      this.CurrentContent();
      Row() {
        this.TabItem('首页', 0);
        this.TabItem('通讯录', 1);
        this.TabItem('工作日志', 2);
        this.TabItem('我', 3);
      }
      .height(64)
      .width('100%')
      .backgroundColor('#F7F7F7')
      .justifyContent(FlexAlign.SpaceAround);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED');
  }

  @Builder
  TabItem(title: string, index: number) {
    Column() {
      Text(index === this.currentIndex ? '●' : '○').fontSize(18).fontColor(index === this.currentIndex ? '#07C160' : '#666666');
      Text(title).fontSize(12).fontColor(index === this.currentIndex ? '#07C160' : '#666666');
    }
    .onClick(() => this.currentIndex = index);
  }
}

@Component
struct HomePageContent {
  build() {
    Column() {
      Text('首页').fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 16, bottom: 16 });
      Text('下拉搜索：设备巡检 / 工单处理 / 生产看板 / 异常上报').fontSize(15).fontColor('#666666');
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16);
  }
}

@Component
struct PlaceholderPage {
  private title: string = '';

  build() {
    Column() {
      Text(this.title).fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 16, bottom: 16 });
      Text('首版占位内容').fontSize(15).fontColor('#666666');
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16);
  }
}
```

- [ ] **Step 4: 编译检查**

在 DevEco Studio 中执行 Make Module `entry`。

期望：页面注册和 ArkUI 语法通过。如果 `@Entry` 多页面约束报错，保留 `Index` 为 `@Entry`，其余页面移除 `@Entry`。

- [ ] **Step 5: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/resources/base/profile/main_pages.json entry/src/main/ets/pages && git commit -m "feat: add app shell pages"`。

---

### Task 7: 拆出四个页面和微信风格组件

**Files:**
- Create: `entry/src/main/ets/components/WechatTabBar.ets`
- Create: `entry/src/main/ets/components/MiniProgramSearch.ets`
- Create: `entry/src/main/ets/components/ChannelPicker.ets`
- Create: `entry/src/main/ets/components/LoginPanel.ets`
- Create: `entry/src/main/ets/pages/HomePage.ets`
- Create: `entry/src/main/ets/pages/ContactsPage.ets`
- Create: `entry/src/main/ets/pages/WorkLogPage.ets`
- Create: `entry/src/main/ets/pages/ProfilePage.ets`
- Create: `entry/src/main/ets/pages/SsoWebViewPage.ets`
- Modify: `entry/src/main/ets/pages/LoginPage.ets`
- Modify: `entry/src/main/ets/pages/MainPage.ets`

- [ ] **Step 1: 拆出页面组件**

将 `MainPage.ets` 内的 `HomePageContent` 和 `PlaceholderPage` 迁移到独立页面文件。`MainPage.ets` 只保留签页状态、内容选择和底部导航。

- [ ] **Step 2: 实现微信风格底部 Tab**

创建 `WechatTabBar.ets`，公开 `currentIndex` 和点击回调。图标使用文字占位：`首页` 用 `⌂`，通讯录用 `☷`，工作日志用 `▣`，个人中心用 `○`。选中态颜色 `#07C160`，未选中态 `#666666`。

- [ ] **Step 3: 实现首页下拉搜索视觉区域**

创建 `MiniProgramSearch.ets`，使用 `RelativeContainer` 放置搜索框和四个功能入口。首版用点击按钮模拟展示/隐藏，不实现复杂手势。

- [ ] **Step 4: 实现登录组件拆分**

创建 `ChannelPicker.ets` 和 `LoginPanel.ets`。`LoginPanel` 展示账号、密码、短信验证码占位、SSO 登录入口和登录按钮。登录按钮首版仍跳转 `MainPage`，真实网络登录接入留到后续接口联调。

- [ ] **Step 5: 编译和手工检查**

在 DevEco Studio 中执行 Make Module `entry`，然后运行模拟器或真机。

期望：登录页可进入主页面，底部四个签页可切换，首页可看到搜索入口，页面布局没有明显多层嵌套导致的异常留白。

- [ ] **Step 6: 提交检查**

运行：`git status --short`

如果已初始化 git，提交：`git add entry/src/main/ets/components entry/src/main/ets/pages && git commit -m "feat: add wechat style app pages"`。

---

### Task 8: 最终验证和文档同步

**Files:**
- Modify: `docs/superpowers/specs/2026-04-30-mesplus-harmony-app-design.md`，仅当实现中有经用户确认的设计变化时修改。
- Modify: `docs/superpowers/plans/2026-04-30-mesplus-harmony-app.md`，勾选已完成步骤。

- [ ] **Step 1: 单元测试验证**

在 DevEco Studio 中运行 `entry/src/test/List.test.ets`。

期望：以下测试套件全部通过：

```text
localUnitTest
channelConfigLoaderTest
userNormalizerTest
serviceResolverTest
headerGuardTest
authServiceTest
```

- [ ] **Step 2: 构建验证**

在 DevEco Studio 中执行 Make Module `entry`。

期望：没有 ArkTS 类型错误、资源注册错误或页面注册错误。

- [ ] **Step 3: 手工 UI 验证**

运行 App，逐项检查：

```text
启动后进入登录页
登录页展示 Mesplus、工业协同平台、渠道按钮、账号密码输入和登录按钮
点击登录进入主页面
底部四个签页可切换：首页、通讯录、工作日志、我
首页展示工业功能搜索入口
个人中心展示用户信息区域和退出入口占位
```

- [ ] **Step 4: 安全行为复核**

复核 `HeaderGuard.ets` 和 `HttpClient.ets`：

```text
业务 headers 不允许覆盖 Cookie
Cookie 由 Session.cookies 生成
Authorization、Host、Content-Length、Connection 被拒绝
包含换行符的 header value 被拒绝
自动登录失败不转发原请求
自动登录失败后返回登录页的 UI 接入点已保留
```

- [ ] **Step 5: 记录 git 状态**

运行：`git status --short`

期望：如果不是 git 仓库，记录 `fatal: not a git repository`；如果是 git 仓库，确认所有本次实现文件已提交或明确列出未提交文件。

---

## 自检结果

- 规格覆盖：本计划覆盖渠道 rawfile 配置、多登录方式、用户归一化、Cookie SSO、28 分钟自动登录、MAG/ORIGINAL 网关、自定义请求头安全、SSO Bridge、四签页 UI、首页搜索和测试策略。
- 占位扫描：未发现未定义实现标记；首版业务页面使用“占位”是规格明确范围，不是未定义实现。
- 类型一致性：`LoginMode`、`ServiceType`、`GatewayMode`、`Session`、`UserProfile`、`Channel`、`AuthService.ensureSessionFresh()`、`resolveServiceUrl()`、`mergeSafeHeaders()` 在任务之间命名一致。
