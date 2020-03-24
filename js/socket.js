import { ZMQEvents } from './events'

export class ZMQSocket {

  _bridge = null;
  _events = null;
  _uuid   = "";
  _addr   = "";

  constructor(bridge, uuid) {
    this._bridge = bridge;
    this._uuid   = uuid;
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

  setSendTimeout(sendTimeout) {
    return this._bridge.setSendTimeOut(this._uuid, sendTimeout);
  }

  setReceiveTimeout(receiveTimeout) {
    return this._bridge.setReceiveTimeOut(this._uuid, receiveTimeout);
  }

  setImmediate(immediate) {
    return this._bridge.setImmediate(this._uuid, immediate);
  }

  setLinger(linger) {
    return this._bridge.setLinger(this._uuid, linger);
  }

  bind(addr) {
    return this._bridge.socketBind(this._uuid, addr).then(answ => {
      this._addr = addr;
      return answ;
    });
  }

  connect(addr) {
    return this._bridge.socketConnect(this._uuid, addr).then(answ => {
      this._addr = addr;
      return answ;
    });
  }

  disconnect(addr) {
    return this._bridge.socketDisconnect(this._uuid, addr).then(answ => {
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
  
  setIdentity(id) {
    return this._bridge.setIdentity(this._uuid, id);
  }

  send(body) {
    const msg = Array.isArray(body) ? body : [body];
    return this._bridge.socketSend(this._uuid, msg);
  }

  recv(flag) {
    return this._bridge.socketRecv(this._uuid, flag || 0);
  }

  recvEvent(flags) {
    return this._bridge.socketRecvEvent(this._uuid, flags || 0);
  }

  subscribe(topic) {
    return this._bridge.socketSubscribe(this._uuid, topic);
  }

  unsubscribe(topic) {
    return this._bridge.socketUnsubscribe(this._uuid, topic);
  }

  monitor(addr, events) {
    return this._bridge.socketMonitor(this._uuid, addr, events);
  }

  hasMore() {
    return this._bridge.socketHasMore(this._uuid);
  }

}
