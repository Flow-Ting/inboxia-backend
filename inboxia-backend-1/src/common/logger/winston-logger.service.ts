import "reflect-metadata";
import { Injectable, LoggerService } from '@nestjs/common';
import * as winston from 'winston';

@Injectable()
export class WinstonLoggerService implements LoggerService {
  private readonly logger: winston.Logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.printf(({ timestamp, level, message }) => {
        return `${timestamp} [${level}]: ${message}`;
      })
    ),
    transports: [new winston.transports.Console()],
  });

  log(message: any, context?: string) {
    this.logger.info(message);
  }

  error(message: any, trace?: string, context?: string) {
    this.logger.error(message);
  }

  warn(message: any, context?: string) {
    this.logger.warn(message);
  }

  debug(message: any, context?: string) {
    this.logger.debug(message);
  }

  verbose(message: any, context?: string) {
    this.logger.verbose(message);
  }
}
