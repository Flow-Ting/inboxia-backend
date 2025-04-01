import { WebSocketGateway, WebSocketServer, SubscribeMessage } from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway()
export class EmailGateway {
  @WebSocketServer() server: Server;

  // Broadcast real-time email metrics to clients
  broadcastMetrics(data: any) {
    this.server.emit('emailMetrics', data);
  }

  @SubscribeMessage('ping')
  handlePing(client: any, payload: any): string {
    return 'pong';
  }
}
