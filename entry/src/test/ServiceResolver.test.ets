import { describe, it, expect } from '@ohos/hypium';
import { resolveServiceUrl } from '../main/ets/network/ServiceResolver';
import { GatewayMode, ServiceType } from '../main/ets/config/AppConstants';
import { ServiceMap } from '../main/ets/models/Channel';

const SERVICES: ServiceMap = {
  auth: {
    type: ServiceType.AUTH,
    baseUrl: 'https://auth.example.com',
    gatewayMode: GatewayMode.MAG,
    magGateway: 'https://mag.example.com/auth',
    originalGateway: 'https://origin.example.com/auth'
  },
  business: {
    type: ServiceType.BUSINESS,
    baseUrl: 'https://business.example.com',
    gatewayMode: GatewayMode.ORIGINAL,
    magGateway: 'https://mag.example.com/business',
    originalGateway: 'https://origin.example.com/business'
  },
  sso: {
    type: ServiceType.SSO,
    baseUrl: 'https://sso.example.com',
    gatewayMode: GatewayMode.MAG,
    magGateway: 'https://mag.example.com/sso',
    originalGateway: 'https://origin.example.com/sso'
  },
  file: {
    type: ServiceType.FILE,
    baseUrl: 'https://file.example.com',
    gatewayMode: GatewayMode.ORIGINAL,
    magGateway: 'https://mag.example.com/file',
    originalGateway: 'https://origin.example.com/file'
  }
};

function didResolveThrow(services: ServiceMap, serviceType: ServiceType, apiPath: string): boolean {
  try {
    resolveServiceUrl(services, serviceType, apiPath);
  } catch (error) {
    return true;
  }
  return false;
}

export default function serviceResolverTest() {
  describe('ServiceResolver', () => {
    it('resolves MAG service URL', 0, () => {
      const url = resolveServiceUrl(SERVICES, ServiceType.AUTH, '/login');

      expect(url).assertEqual('https://mag.example.com/auth/login');
    });

    it('resolves ORIGINAL service URL', 0, () => {
      const url = resolveServiceUrl(SERVICES, ServiceType.BUSINESS, '/orders');

      expect(url).assertEqual('https://origin.example.com/business/orders');
    });

    it('throws when apiPath does not start with slash', 0, () => {
      expect(didResolveThrow(SERVICES, ServiceType.AUTH, 'login')).assertEqual(true);
    });

    it('throws when gatewayMode is missing', 0, () => {
      const services = {
        auth: {
          type: ServiceType.AUTH,
          baseUrl: 'https://auth.example.com',
          magGateway: 'https://mag.example.com/auth',
          originalGateway: 'https://origin.example.com/auth'
        },
        business: SERVICES.business,
        sso: SERVICES.sso,
        file: SERVICES.file
      } as unknown as ServiceMap;

      expect(didResolveThrow(services, ServiceType.AUTH, '/login')).assertEqual(true);
    });

    it('throws when service is missing', 0, () => {
      const services = {
        business: SERVICES.business,
        sso: SERVICES.sso,
        file: SERVICES.file
      } as unknown as ServiceMap;

      expect(didResolveThrow(services, ServiceType.AUTH, '/login')).assertEqual(true);
    });

    it('throws when selected gateway is empty', 0, () => {
      const services: ServiceMap = {
        auth: {
          type: ServiceType.AUTH,
          baseUrl: 'https://auth.example.com',
          gatewayMode: GatewayMode.MAG,
          magGateway: '',
          originalGateway: 'https://origin.example.com/auth'
        },
        business: SERVICES.business,
        sso: SERVICES.sso,
        file: SERVICES.file
      };

      expect(didResolveThrow(services, ServiceType.AUTH, '/login')).assertEqual(true);
    });
  });
}
