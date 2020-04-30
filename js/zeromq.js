import Core from "./core";
import { ZMQSocket } from "./socket";
import { ZMQSocketTypeError } from "./errors";

export class ZeroMQ {
  static SOCKET = {
    TYPE: {
      REP: Core.bridge.ZMQ_REP,
      REQ: Core.bridge.ZMQ_REQ,

      XREP: Core.bridge.ZMQ_XREP,
      XREQ: Core.bridge.ZMQ_XREQ,

      PUB: Core.bridge.ZMQ_PUB,
      SUB: Core.bridge.ZMQ_SUB,

      XPUB: Core.bridge.ZMQ_XPUB,
      XSUB: Core.bridge.ZMQ_XSUB,

      PUSH: Core.bridge.ZMQ_PUSH,
      PULL: Core.bridge.ZMQ_PULL,

      DEALER: Core.bridge.ZMQ_DEALER,
      ROUTER: Core.bridge.ZMQ_ROUTER,

      PAIR: Core.bridge.ZMQ_PAIR
    },
    OPTS: {
      DONT_WAIT: Core.bridge.ZMQ_DONTWAIT,
      NO_BLOCK: Core.bridge.ZMQ_NOBLOCK,
      SEND_MORE: Core.bridge.ZMQ_SNDMORE
    }
  };

  // @TODO: add more ...

  static Reply(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.REP, options);
  }

  static Request(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.REQ, options);
  }

  static Publisher(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.PUB, options);
  }

  static Subscriber(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.SUB, options);
  }

  static Push(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.PUSH, options);
  }

  static Pull(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.PULL, options);
  }

  static Dealer(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.DEALER, options);
  }

  static Router(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.ROUTER, options);
  }

  static Pair(options = {}) {
    return ZeroMQ.socket(ZeroMQ.SOCKET.TYPE.PAIR, options);
  }

  static socket(socType, options) {
    let _validSocTypes = Object.values(ZeroMQ.SOCKET.TYPE);
    if (!~_validSocTypes.indexOf(socType)) {
      return Promise.reject(new ZMQSocketTypeError());
    }

    return Core.bridge
      .socketCreate(socType)
      .then(uuid => new ZMQSocket(Core.bridge, uuid))
      .then(socket => socket.setOptions(options));
  }

  static destroy(forced) {
    return Core.bridge.destroy(!!forced);
  }

  static getDeviceIdentifier() {
    return Core.bridge.getDeviceIdentifier();
  }

  static onNotification(callback) {
    Core.notificationListeners.push(callback);
  }
}
