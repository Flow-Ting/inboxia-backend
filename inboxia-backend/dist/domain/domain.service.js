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
exports.DomainService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const domain_entity_1 = require("./domain.entity");
const typeorm_2 = require("typeorm");
const dns = require("dns/promises");
let DomainService = class DomainService {
    constructor(domainRepo) {
        this.domainRepo = domainRepo;
    }
    async createDomain(tenantId, name) {
        const domain = this.domainRepo.create({ tenantId, name });
        return this.domainRepo.save(domain);
    }
    async verifyDomain(domainId) {
        const domain = await this.domainRepo.findOne({ where: { id: domainId } });
        if (!domain) {
            throw new common_1.InternalServerErrorException('Domain not found');
        }
        try {
            const spfRecords = await dns.resolveTxt(domain.name);
            domain.spfVerified = spfRecords.some(rec => rec.join('').includes('v=spf1'));
            domain.dkimVerified = true;
            domain.dmarcVerified = true;
            return this.domainRepo.save(domain);
        }
        catch (err) {
            domain.verificationError = err.message;
            return this.domainRepo.save(domain);
        }
    }
};
DomainService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(domain_entity_1.Domain)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], DomainService);
exports.DomainService = DomainService;
//# sourceMappingURL=domain.service.js.map