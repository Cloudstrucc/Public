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
export declare class PolicyEngine {
    private rules;
    addRule(rule: PolicyRule): void;
    evaluate(context: PolicyContext): Promise<boolean>;
    private matchesRule;
}
export * from './types';
export * from './rules';
