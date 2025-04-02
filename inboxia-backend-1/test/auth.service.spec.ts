import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from '../src/auth/auth.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../src/auth/user.entity';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  const mockUserRepository = {
    findOne: jest.fn(),
  };
  const mockJwtService = {
    sign: jest.fn().mockReturnValue('signed-token'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: mockUserRepository },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should validate user and return token', async () => {
    const user = { id: '1', username: 'test', tenantId: 'tenant1', password: await bcrypt.hash('pass', 10), role: 'user' };
    mockUserRepository.findOne.mockResolvedValue(user);
    const result = await service.validateUser('test', 'pass', 'tenant1');
    expect(result.username).toEqual('test');
  });
});
