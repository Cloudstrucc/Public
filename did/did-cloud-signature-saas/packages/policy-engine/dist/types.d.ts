export interface ClaimRequirement {
    claim: string;
    value: any;
    operator: 'equals' | 'contains' | 'greaterThan' | 'lessThan';
}
export interface PolicyEvaluationResult {
    allowed: boolean;
    reason: string;
    appliedRules: string[];
}
