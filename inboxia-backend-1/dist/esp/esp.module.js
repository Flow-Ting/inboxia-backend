"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EspModule = void 0;
const common_1 = require("@nestjs/common");
const esp_service_1 = require("./esp.service");
let EspModule = class EspModule {
};
EspModule = __decorate([
    (0, common_1.Module)({
        providers: [esp_service_1.EspService],
        exports: [esp_service_1.EspService],
    })
], EspModule);
exports.EspModule = EspModule;
//# sourceMappingURL=esp.module.js.map