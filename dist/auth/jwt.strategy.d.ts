import { Strategy } from 'passport-jwt';
declare const JwtStrategy_base: new (...args: unknown[] | [opt: import("passport-jwt").StrategyOptions] | [opt: import("passport-jwt").StrategyOptions]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class JwtStrategy extends JwtStrategy_base {
    constructor();
    validate(payload: any): Promise<{
        userId: any;
        username: any;
        tenantId: any;
        role: any;
    }>;
}
export {};
