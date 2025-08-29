import { PolicyRule } from './index';

export const defaultRules: PolicyRule[] = [
  {
    id: 'allow-admin',
    name: 'Allow Admin Access',
    condition: 'user.roles.includes("admin")',
    action: 'allow',
    resources: ['*']
  },
  {
    id: 'deny-guest',
    name: 'Deny Guest Access',
    condition: 'user.roles.includes("guest")',
    action: 'deny',
    resources: ['secure-notes']
  }
];
