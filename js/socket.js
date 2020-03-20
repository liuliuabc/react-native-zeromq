import { ZMQError, ZMQNoAnswerError } from './errors'

export class ZMQSocket {

  _bridge = null;
  _uuid   = "";
  _addr   = "";

  constructor(bridge, uuid) {
    this._bridge = bridge;
    this._uuid   = uuid;
  }

  destroy() {
    return this._bridge.destroy(this._uuid).then(answ => {
      this._uuid = "";
      this._addr = "";
      return answ;
    });
  }

  get address() {
    return this._addr;
  }

  get uuid() {
    return this._uuid;
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

  close() {
    return this._bridge.socketClose(this._uuid).then(answ => {
      this._uuid = "";
      this._addr = "";
      return answ;
    });
  }

  setIdentity(id) {
    return this._bridge.setIdentity(this._uuid, id);
  }

  send(body) {
    const msg = Array.isArray(body) ? body : [body];
    return this._bridge.socketSend(this._uuid, msg);
  }

  recv(opts = {}) {
    let flags   = opts.flags || 0;
    let poolInt = opts.poolInterval || (-1);
    return this._bridge.socketRecv(this._uuid, flags, poolInt);
  }

  subscribe(topic) {
    return this._bridge.socketSubscribe(this._uuid, topic);
  }

  unsubscribe(topic) {
    returnthis._bridge.socketUnsubscribe(this._uuid, topic);
  }

  hasMore() {
    return this._bridge.socketHasMore(this._uuid);
  }

}
