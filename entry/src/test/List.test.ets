import localUnitTest from './LocalUnit.test';
import channelConfigLoaderTest from './ChannelConfigLoader.test';
import userNormalizerTest from './UserNormalizer.test';
import serviceResolverTest from './ServiceResolver.test';
import headerGuardTest from './HeaderGuard.test';
import loginStrategyRegistryTest from './LoginStrategyRegistry.test';
import authServiceTest from './AuthService.test';
import appStateTest from './AppState.test';
import httpClientTest from './HttpClient.test';
import webBridgeTest from './WebBridge.test';
import loginFlowModelsTest from './LoginFlowModels.test';

export default function testsuite() {
  localUnitTest();
  channelConfigLoaderTest();
  userNormalizerTest();
  serviceResolverTest();
  headerGuardTest();
  loginStrategyRegistryTest();
  authServiceTest();
  appStateTest();
  httpClientTest();
  webBridgeTest();
  loginFlowModelsTest();
}
