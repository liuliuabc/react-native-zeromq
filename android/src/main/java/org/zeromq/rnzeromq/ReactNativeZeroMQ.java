package org.zeromq.rnzeromq;


import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

import org.zeromq.ZMQ;
import org.zeromq.ZMsg;
import org.zeromq.ZFrame;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;


class ReactNativeZeroMQ extends ReactContextBaseJavaModule {

    final String TAG = "ReactNativeZeroMQ";

    private Map<String, Object> _storage;
    private ZMQ.Context _context;

    ReactNativeZeroMQ(final ReactApplicationContext reactContext) {
        super(reactContext);
        _context = ZMQ.context(1);
        _storage = new HashMap<>();
    }

    @Override
    protected void finalize() throws Throwable {
        _destroy();
        super.finalize();
    }

    void _destroy() {
        Iterator it = _storage.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();
            ZMQ.Socket socket = (ZMQ.Socket) pair.getValue();

            socket.close();
            it.remove();
        }

        _closeContext(true);
    }

    @Override
    public String getName() {
        return "ReactNativeZeroMQAndroid";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("ZMQ_REP", ZMQ.REP);
        constants.put("ZMQ_REQ", ZMQ.REQ);
        constants.put("ZMQ_XREP", ZMQ.XREP);
        constants.put("ZMQ_XREQ", ZMQ.XREQ);

        constants.put("ZMQ_PUB", ZMQ.PUB);
        constants.put("ZMQ_SUB", ZMQ.SUB);
        constants.put("ZMQ_XPUB", ZMQ.XPUB);
        constants.put("ZMQ_XSUB", ZMQ.XSUB);

        constants.put("ZMQ_DONTWAIT", ZMQ.DONTWAIT);
        constants.put("ZMQ_NOBLOCK", ZMQ.NOBLOCK);
        constants.put("ZMQ_SNDMORE", ZMQ.SNDMORE);

        constants.put("ZMQ_DEALER", ZMQ.DEALER);
        constants.put("ZMQ_ROUTER", ZMQ.ROUTER);

        // @TODO: add socket options constants

        return constants;
    }

    private String _newObject(Object obj) {
        UUID uuid = UUID.randomUUID();
        _storage.put(uuid.toString(), obj);
        return uuid.toString();
    }

    @SuppressWarnings("unchecked")
    private <T> T _getObject(final String uuid) throws Exception {
        if (!_storage.containsKey(uuid)) {
            throw new ReactException("ENULLPTR", "No such object with key \"" + uuid + "\"");
        }
        return (T) _storage.get(uuid);
    }

    private Boolean _delObject(final String uuid) {
        if (_storage.containsKey(uuid)) {
            _storage.remove(uuid);
            return true;
        }
        return false;
    }

    private Boolean _closeContext(Boolean forced) {
        if (_storage.size() == 0 || forced) {
            if (_context != null) {
                _context.term();
                _context = null;
            }
            return true;
        }
        return false;
    }

    private ZMQ.Socket _socket(final Integer socType) {
        if (_context == null) {
            _context = ZMQ.context(1);
        }
        return _context.socket(socType);
    }

    private String _getDeviceIdentifier() {
        String devFriendlyName = ReactNativeUtils.getDeviceName();
        devFriendlyName = devFriendlyName.replaceAll("\\s", "_");
        return ("android.os.Build." + devFriendlyName + " " + ReactNativeUtils.getIPAddress(true));
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketCreate(final Integer socType, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._socket(socType);

                if (socket == null) {
                    return "";
                }

                return ReactNativeZeroMQ.this._newObject(socket);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketBind(final String uuid, final String addr, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.bind(addr);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void setSocketTimeouts(final String uuid, final int sendTimeout, final int receiveTimeout, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.setSendTimeOut(sendTimeout);
                socket.setReceiveTimeOut(receiveTimeout);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketConnect(final String uuid, final String addr, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.connect(addr);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketClose(final String uuid, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.close();
                ReactNativeZeroMQ.this._delObject(uuid);
                ReactNativeZeroMQ.this._closeContext(false);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void destroy(final String uuid, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.close();
                ReactNativeZeroMQ.this._delObject(uuid);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void setSocketIdentity(final String uuid, final String id, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.setIdentity(id.getBytes(ZMQ.CHARSET));

                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketSend(final String uuid, final ReadableArray body, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                ZMsg msg = new ZMsg();
                for (int i = 0; i < body.size(); i++) {
                    msg.add(body.getString(i));
                }
                boolean success = msg.send(socket, true);
                return success;
            }
        }).startAsync();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketRecv(final String uuid, final Integer flag, final Integer poolInterval, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                ZMsg msg = ZMsg.recvMsg(socket, flag);
                WritableArray arr = new WritableNativeArray();
                for (ZFrame f : msg) {
                    arr.pushString(f.getString(ZMQ.CHARSET));
                }
                return arr;
            }
        }).startAsync();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketSubscribe(final String uuid, final String topic, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.subscribe(topic);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketUnsubscribe(final String uuid, final String topic, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.unsubscribe(topic);
                return this._successResult(true);
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void socketHasMore(final String uuid, final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.hasReceiveMore();
            }
        }).start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    public void getDeviceIdentifier(final Callback callback) {
        (new ReactTask(callback) {
            @Override
            Object run() throws Exception {
                return ReactNativeZeroMQ.this._getDeviceIdentifier();
            }
        }).start();
    }
}
