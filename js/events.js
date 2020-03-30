import { EventEmitter } from "events";

export class ZMQEvents extends EventEmitter {
  _bridge = null;
  _socket = null;
  _pair = null;
  _recvLoop = null; // Promise
  _addr = "";
  _closed = false;

  constructor(socket, bridge) {
    super();

    this._socket = socket;
    this._bridge = bridge;
    this._addr = "inproc://monitor." + socket.uuid;
    this._recvLoop = this._run();
  }

  get addr() {
    return this._addr;
  }

  _emitEvent(msg) {
    const { event, address, value } = msg;
    switch (event) {
      case this._bridge.ZMQ_EVENT_CONNECTED:
        this.emit("connect", address);
        break;
      case this._bridge.ZMQ_EVENT_CONNECT_DELAYED:
        this.emit("connect:delay", address);
        break;
      case this._bridge.ZMQ_EVENT_CONNECT_RETRIED:
        this.emit("connect:retry", address, value);
        break;
      case this._bridge.ZMQ_EVENT_LISTENING:
        this.emit("bind", address);
        break;
      case this._bridge.ZMQ_EVENT_BIND_FAILED:
        this.emit("bind:error", address, value);
        break;
      case this._bridge.ZMQ_EVENT_ACCEPTED:
        this.emit("accept", address);
        break;
      case this._bridge.ZMQ_EVENT_ACCEPT_FAILED:
        this.emit("accept:error", address, value);
        break;
      case this._bridge.ZMQ_EVENT_CLOSED:
        this.emit("close", address);
        break;
      case this._bridge.ZMQ_EVENT_CLOSE_FAILED:
        this.emit("close:error", address);
        break;
      case this._bridge.ZMQ_EVENT_DISCONNECTED:
        this.emit("disconnect", address);
        break;
      case this._bridge.ZMQ_EVENT_MONITOR_STOPPED:
        this.emit("monitor:stop", address);
        break;

      default:
        break;
    }
  }

  async _run() {
    await this._bridge.socketMonitor(
      this._socket.uuid,
      this._addr,
      this._bridge.ZMQ_EVENT_ALL
    );
    try {
      this._pair = await this._bridge.socketCreate(this._bridge.ZMQ_PAIR);
      try {
        await this._bridge.socketConnect(this._pair, this._addr);
        try {
          while (!this._closed) {
            const msg = await this._bridge.socketRecvEvent(this._pair, 0);
            if (msg) {
              this._emitEvent(msg);
            }
          }
        } catch (e) {
          console.debug("Socket event monitoring error", e);
          if (e.errno !== 4) throw e;
        }
        await this._bridge.socketDisconnect(this._pair, this._addr);
      } finally {
        await this._bridge.socketClose(this._pair);
        this._pair = null;
      }
    } finally {
      await this._bridge.socketMonitor(this._socket.uuid, null, 0);
      console.log("socket monitor closed");
    }
  }

  async close() {
    this._closed = true;
    if (this._recvLoop !== null) {
      await this._recvLoop;
      this._recvLoop = null;
    }
  }
}
