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
    return new Promise((resolve, reject) => {
      this._bridge.destroy(this._uuid, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        this._uuid = "";
        this._addr = "";
        resolve(answ.result);
      });
    });
  }

  get address() {
    return this._addr;
  }

  get uuid() {
    return this._uuid;
  }

  setTimeouts(sendTimeout, receiveTimeout) {
    return new Promise((resolve, reject) => {
      this._bridge.setSocketTimeouts(this._uuid, sendTimeout, receiveTimeout, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  bind(addr) {
    return new Promise((resolve, reject) => {
      this._bridge.socketBind(this._uuid, addr, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        this._addr = addr;
        resolve(answ.result);
      });
    });
  }

  connect(addr) {
    return new Promise((resolve, reject) => {
      this._bridge.socketConnect(this._uuid, addr, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        this._addr = addr;
        resolve(answ.result);
      });
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      this._bridge.socketClose(this._uuid, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        this._uuid = "";
        this._addr = "";
        resolve(answ.result);
      });
    });
  }

  setIdentity(id) {
    return new Promise((resolve, reject) => {
      this._bridge.setSocketIdentity(this._uuid, id, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  send(body) {
    return new Promise((resolve, reject) => {
      const msg = Array.isArray(body) ? body : [body];
      this._bridge.socketSend(this._uuid, msg, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  recv(opts = {}) {
    let flags   = opts.flags || 0;
    let poolInt = opts.poolInterval || (-1);

    return new Promise((resolve, reject) => {
      this._bridge.socketRecv(this._uuid, flags, poolInt, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  subscribe(topic) {
    return new Promise((resolve, reject) => {
      this._bridge.socketSubscribe(this._uuid, topic, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  unsubscribe(topic) {
    return new Promise((resolve, reject) => {
      this._bridge.socketUnsubscribe(this._uuid, topic, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

  hasMore() {
    return new Promise((resolve, reject) => {
      this._bridge.socketHasMore(this._uuid, answ => {
        if (!answ) {
          reject(new ZMQNoAnswerError());
          return;
        }

        if (answ.error) {
          reject(new ZMQError(answ.error));
          return;
        }

        resolve(answ.result);
      });
    });
  }

}
