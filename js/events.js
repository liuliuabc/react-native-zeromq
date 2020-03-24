import { EventEmitter } from 'events'

import { ZeroMQ } from './zeromq'
import { ZMQError } from './errors';

export class ZMQEvents extends EventEmitter {

    _bridge = null;
    _socket = null;
    _pair   = null;
    _recvLoop = null; // Promise
    _addr   = "";

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
        const mon = await this._socket.monitor(this._addr, this._bridge.ZMQ_EVENT_ALL);
        if (!mon) throw ZMQError("socket.monitor() failed");

        this._pair = await ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.PAIR);
        try {
            await this._pair.connect(this._addr);
            try {
                while (true) {
                    const msg = await this._pair.recvEvent();
                    if (!msg) break;
                    this._emitEvent(msg);
                }
            }
            catch (e) {
                console.debug(e)
                if (e.errno !== 4) throw ZMQError(e);
            }
        } finally {
            await this._pair.close();
            await this._bridge.socketMonitor(this._socket.uuid, null, 0);
            this._pair = null;
        }
    }

    async close() {
        if (this._recvLoop !== null) {
            await this._recvLoop;
            this._recvLoop = null;
        }
    }
}
