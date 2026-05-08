import { LoginMode } from '../config/AppConstants';
import { LoginStrategy } from './LoginStrategy';

export class LoginStrategyRegistry {
  private strategies: Map<LoginMode, LoginStrategy> = new Map<LoginMode, LoginStrategy>();

  register(strategy: LoginStrategy): void {
    this.strategies.set(strategy.mode, strategy);
  }

  get(mode: LoginMode): LoginStrategy {
    const strategy = this.strategies.get(mode);
    if (strategy === undefined) {
      throw new Error(`login strategy for mode ${mode} is missing`);
    }
    return strategy;
  }
}
