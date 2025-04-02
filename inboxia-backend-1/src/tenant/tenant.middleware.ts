import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class TenantMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Extract tenant info from the request headers (default if not provided)
    req['tenantId'] = req.headers['x-tenant-id'] || 'default_tenant';
    next();
  }
}
