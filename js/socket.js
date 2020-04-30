import msgpack from "msgpack-lite";

import { ZMQEvents } from "./events";

export class ZMQSocket {
  _bridge = null;
  _events = null;
  _uuid = "";
  _addr = "";

  constructor(bridge, uuid) {
    this._bridge = bridge;
    this._uuid = uuid;
    this._msgPack = false;
  }

  get address() {
    return this._addr;
  }

  get uuid() {
    return this._uuid;
  }

  get events() {
    if (this._events === null) {
      this._events = new ZMQEvents(this, this._bridge);
    }
    return this._events;
  }

  setOptions(options) {
    return Promise.all(
      Object.keys(options).map((key) => {
        const value = options[key];
        switch (key) {
          case "identity":
            return this.setIdentity(value);
          case "sendTimeout":
            return this.setSendTimeout(value);
          case "reconnectMaxInterval":
            return this.setMaxReconnectInterval(value);
          case "receiveTimeout":
            return this.setReceiveTimeout(value);
          case "immediate":
            return this.setImmediate(value);
          case "linger":
            return this.setLinger(value);
          case "handover":
            return this.setRouterHandover(value);
          case "routingId":
            return this.setRoutingId(value);

          default:
            return Promise.resolve(); // shoud we ignore unknown options ?
        }
      })
    ).then(() => this);
  }

  setMsgPack(value) {
    this._msgPack = value;
  }

  setSendTimeout(value) {
    return this._bridge.setSendTimeOut(this._uuid, value);
  }

  setMaxReconnectInterval(value) {
    return this._bridge.setMaxReconnectInterval(this._uuid, value);
  }

  setReceiveTimeout(value) {
    return this._bridge.setReceiveTimeOut(this._uuid, value);
  }

  setImmediate(immediate) {
    return this._bridge.setImmediate(this._uuid, immediate);
  }

  setLinger(value) {
    return this._bridge.setLinger(this._uuid, value);
  }

  setRouterHandover(value) {
    return this._bridge.setRouterHandover(this._uuid, value);
  }

  setRoutingId(value) {
    let base64 = false;
    if (value instanceof Buffer) {
      base64 = true;
      value = value.toString("base64");
    }
    return this._bridge.setRoutingId(this._uuid, value, base64);
  }

  bind(addr) {
    return this._bridge.socketBind(this._uuid, addr).then((answ) => {
      this._addr = addr;
      return answ;
    });
  }

  connect(addr) {
    return this._bridge.socketConnect(this._uuid, addr).then((answ) => {
      this._addr = addr;
      return answ;
    });
  }

  disconnect(addr) {
    return this._bridge.socketDisconnect(this._uuid, addr).then((answ) => {
      this._addr = addr;
      return answ;
    });
  }

  async close() {
    if (this._events !== null) {
      await this._events.close();
      this._events = null;
    }

    const answ = await this._bridge.socketClose(this._uuid);
    this._uuid = "";
    this._addr = "";
    return answ;
  }

  setIdentity(value) {
    let base64 = false;
    if (value instanceof Buffer) {
      base64 = true;
      value = value.toString("base64");
    }
    return this._bridge.setSocketIdentity(this._uuid, value, base64);
  }

  send(body, base64 = false) {
    if (!this._msgPack) {
      return base64 ? this.sendBase64(body) : this.sendStr(body);
    }

    const msg = Array.isArray(body) ? body : [body];
    const data = msg.map((m) => {
      const buffer = Buffer(msgpack.encode(m));
      return buffer.toString("base64");
    });
    return this.sendBase64(data);
  }

  sendStr(body) {
    const msg = Array.isArray(body) ? body : [body];
    return this._bridge.socketSend(this._uuid, msg, false);
  }

  sendBase64(body) {
    const msg = Array.isArray(body) ? body : [body];
    return this._bridge.socketSend(this._uuid, msg, true);
  }

  recv(flag, base64 = false) {
    if (!this._msgPack) {
      return base64 ? this.recvBase64(flag) : this.recvStr(flag);
    }

    return this.recvBase64(flag).then((msg) =>
      msg.map((m) => msgpack.decode(Buffer.from(m, "base64")))
    );
  }

  recvStr(flag) {
    return this._bridge.socketRecv(this._uuid, flag || 0, false);
  }

  recvBase64(flag) {
    return this._bridge.socketRecv(this._uuid, flag || 0, true);
  }

  recvEvent(flags) {
    return this._bridge.socketRecvEvent(this._uuid, flags || 0);
  }

  subscribe(topic) {
    let base64 = false;
    if (topic instanceof Buffer) {
      base64 = true;
      topic = topic.toString("base64");
    }
    return this._bridge.socketSubscribe(this._uuid, topic, base64);
  }

  unsubscribe(topic) {
    let base64 = false;
    if (topic instanceof Buffer) {
      base64 = true;
      topic = topic.toString("base64");
    }
    return this._bridge.socketUnsubscribe(this._uuid, topic, base64);
  }

  monitor(addr, events) {
    return this._bridge.socketMonitor(this._uuid, addr, events);
  }

  hasMore() {
    return this._bridge.socketHasMore(this._uuid);
  }
}
