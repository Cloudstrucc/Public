export interface PolicyRule {
  id: string;
  name: string;
  condition: string;
  action: 'allow' | 'deny';
  resources: string[];
  claims?: Record<string, any>;
}

export interface PolicyContext {
  user: {
    id: string;
    email: string;
    roles: string[];
  };
  resource: string;
  action: string;
  claims?: Record<string, any>;
}

export class PolicyEngine {
  private rules: PolicyRule[] = [];
  
  addRule(rule: PolicyRule): void {
    this.rules.push(rule);
  }
  
  async evaluate(context: PolicyContext): Promise<boolean> {
    for (const rule of this.rules) {
      if (this.matchesRule(rule, context)) {
        return rule.action === 'allow';
      }
    }
    return false;
  }
  
  private matchesRule(rule: PolicyRule, context: PolicyContext): boolean {
    // Simple implementation - enhance as needed
    return rule.resources.includes(context.resource) || rule.resources.includes('*');
  }
}

export * from './types';
export * from './rules';
