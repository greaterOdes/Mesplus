import { describe, it, expect } from '@ohos/hypium';
import { createInitialMagState, createMagMfaState, MagLoginStep, MagMfaMethod, selectMagMfaMethod } from '../main/ets/auth/LoginFlowModels';

export default function loginFlowModelsTest() {
  describe('LoginFlowModels', () => {
    it('creates initial MAG credential state', 0, () => {
      expect(createInitialMagState().step).assertEqual(MagLoginStep.CREDENTIALS);
    });

    it('creates MAG MFA state from masked contacts', 0, () => {
      const state = createMagMfaState('138****0000', 'a***@mail.com');

      expect(state.step).assertEqual(MagLoginStep.MFA);
      expect(state.availableMethods.length).assertEqual(2);
      expect(state.selectedMethod).assertEqual(MagMfaMethod.SMS);
    });

    it('selects MAG MFA method', 0, () => {
      const state = createMagMfaState('138****0000', 'a***@mail.com');

      expect(selectMagMfaMethod(state, MagMfaMethod.EMAIL).selectedMethod).assertEqual(MagMfaMethod.EMAIL);
    });
  });
}
