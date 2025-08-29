"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PolicyEngine = void 0;
class PolicyEngine {
    constructor() {
        this.rules = [];
    }
    addRule(rule) {
        this.rules.push(rule);
    }
    async evaluate(context) {
        for (const rule of this.rules) {
            if (this.matchesRule(rule, context)) {
                return rule.action === 'allow';
            }
        }
        return false;
    }
    matchesRule(rule, context) {
        // Simple implementation - enhance as needed
        return rule.resources.includes(context.resource) || rule.resources.includes('*');
    }
}
exports.PolicyEngine = PolicyEngine;
__exportStar(require("./types"), exports);
__exportStar(require("./rules"), exports);
