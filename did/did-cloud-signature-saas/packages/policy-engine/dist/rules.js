"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultRules = void 0;
exports.defaultRules = [
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
