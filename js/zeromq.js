import Core from './core'
import { ZMQSocket } from './socket'
import { ZMQError, ZMQNoAnswerError, ZMQSocketTypeError } from './errors'

export class ZeroMQ {

  static SOCKET = {
    TYPE: {
      REP:    Core.bridge.ZMQ_REP,
      REQ:    Core.bridge.ZMQ_REQ,

      XREP:   Core.bridge.ZMQ_XREP,
      XREQ:   Core.bridge.ZMQ_XREQ,

      PUB:    Core.bridge.ZMQ_PUB,
      SUB:    Core.bridge.ZMQ_SUB,

      XPUB:   Core.bridge.ZMQ_XPUB,
      XSUB:   Core.bridge.ZMQ_XSUB,

      DEALER: Core.bridge.ZMQ_DEALER,
      ROUTER: Core.bridge.ZMQ_ROUTER
    },
    OPTS: {
      DONT_WAIT:  Core.bridge.ZMQ_DONTWAIT,
      NO_BLOCK:   Core.bridge.ZMQ_NOBLOCK,
      SEND_MORE:  Core.bridge.ZMQ_SNDMORE,
    }
  };

  // @TODO: add more ...

  static socket(socType) {
    let _validSocTypes = Object.values(ZeroMQ.SOCKET.TYPE);
    if (!~_validSocTypes.indexOf(socType)) {
      return Promise.reject(new ZMQSocketTypeError());
    }

    return Core.bridge.socketCreate(socType)
    .then(sock => new ZMQSocket(Core.bridge, sock));
  }

  static getDeviceIdentifier() {
    return Core.bridge.getDeviceIdentifier();
  }

  static onNotification(callback) {
    Core.notificationListeners.push(callback);
  }
}
