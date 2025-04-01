import { Controller, Post, Body, Req } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() body, @Req() req) {
    const user = await this.authService.validateUser(body.username, body.password, req.tenantId);
    return this.authService.login(user);
  }
}
