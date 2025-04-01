"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmailService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const email_entity_1 = require("./email.entity");
const typeorm_2 = require("typeorm");
const esp_service_1 = require("../esp/esp.service");
let EmailService = class EmailService {
    constructor(emailRepo, espService) {
        this.emailRepo = emailRepo;
        this.espService = espService;
    }
    async sendWarmupEmail(tenantId, domainId, emailData) {
        try {
            const result = await this.espService.sendEmail(emailData);
            let metric = await this.emailRepo.findOne({ where: { tenantId, domainId } });
            if (!metric) {
                metric = this.emailRepo.create({ tenantId, domainId });
            }
            metric.sentCount++;
            await this.emailRepo.save(metric);
            return result;
        }
        catch (err) {
            throw new common_1.InternalServerErrorException(err.message);
        }
    }
    async recordEmailEvent(tenantId, domainId, event) {
        let metric = await this.emailRepo.findOne({ where: { tenantId, domainId } });
        if (!metric) {
            metric = this.emailRepo.create({ tenantId, domainId });
        }
        if (event === 'open') {
            metric.openCount++;
        }
        else if (event === 'bounce') {
            metric.bounceCount++;
        }
        return this.emailRepo.save(metric);
    }
};
EmailService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(email_entity_1.EmailMetric)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        esp_service_1.EspService])
], EmailService);
exports.EmailService = EmailService;
//# sourceMappingURL=email.service.js.map