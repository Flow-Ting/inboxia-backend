import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { WinstonLoggerService } from './common/logger/winston-logger.service';
import * as helmet from 'helmet';
import * as cors from 'cors';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new WinstonLoggerService(),
  });
  app.useGlobalPipes(new ValidationPipe());
  app.use(helmet());
  app.use(cors());
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
