import { User } from './user.entity';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
export declare class AuthService {
    private readonly userRepo;
    private readonly jwtService;
    constructor(userRepo: Repository<User>, jwtService: JwtService);
    validateUser(username: string, pass: string, tenantId: string): Promise<any>;
    login(user: any): Promise<{
        access_token: string;
    }>;
}
