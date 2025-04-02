import { Server } from 'socket.io';
export declare class EmailGateway {
    server: Server;
    broadcastMetrics(data: any): void;
    handlePing(client: any, payload: any): string;
}
