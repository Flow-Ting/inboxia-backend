"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = require("dotenv");
dotenv.config();
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const common_1 = require("@nestjs/common");
const helmet_1 = require("helmet");
const cors = require("cors");
const winston_logger_service_1 = require("./common/logger/winston-logger.service");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule, {
        logger: new winston_logger_service_1.WinstonLoggerService(),
    });
    app.useGlobalPipes(new common_1.ValidationPipe());
    app.use(helmet_1.default());
    app.use(cors());
    await app.listen(process.env.PORT || 3000);
}
bootstrap();
//# sourceMappingURL=main.js.map