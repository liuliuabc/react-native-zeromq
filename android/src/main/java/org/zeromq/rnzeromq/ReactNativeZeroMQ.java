package org.zeromq.rnzeromq;

import android.annotation.SuppressLint;
import android.util.Base64;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import org.zeromq.ZMQ;
import org.zeromq.ZMsg;
import org.zeromq.ZFrame;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Nullable;

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

        constants.put("ZMQ_PUSH", ZMQ.PUSH);
        constants.put("ZMQ_PULL", ZMQ.PULL);

        constants.put("ZMQ_DEALER", ZMQ.DEALER);
        constants.put("ZMQ_ROUTER", ZMQ.ROUTER);

        constants.put("ZMQ_PAIR", ZMQ.PAIR);

        constants.put("ZMQ_EVENT_CONNECTED", ZMQ.EVENT_CONNECTED);
        constants.put("ZMQ_EVENT_CONNECT_DELAYED", ZMQ.EVENT_CONNECT_DELAYED);
        constants.put("ZMQ_EVENT_CONNECT_RETRIED", ZMQ.EVENT_CONNECT_RETRIED);
        constants.put("ZMQ_EVENT_LISTENING", ZMQ.EVENT_LISTENING);
        constants.put("ZMQ_EVENT_BIND_FAILED", ZMQ.EVENT_BIND_FAILED);
        constants.put("ZMQ_EVENT_ACCEPTED", ZMQ.EVENT_ACCEPTED);
        constants.put("ZMQ_EVENT_ACCEPT_FAILED", ZMQ.EVENT_ACCEPT_FAILED);
        constants.put("ZMQ_EVENT_CLOSED", ZMQ.EVENT_CLOSED);
        constants.put("ZMQ_EVENT_CLOSE_FAILED", ZMQ.EVENT_CLOSE_FAILED);
        constants.put("ZMQ_EVENT_DISCONNECTED", ZMQ.EVENT_DISCONNECTED);
        constants.put("ZMQ_EVENT_MONITOR_STOPPED", ZMQ.EVENT_MONITOR_STOPPED);
        constants.put("ZMQ_EVENT_ALL", ZMQ.EVENT_ALL);

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
    @SuppressLint("StaticFieldLeak")
    public void socketCreate(final Integer socType, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._socket(socType);
                return ReactNativeZeroMQ.this._newObject(socket);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketBind(final String uuid, final String addr, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.bind(addr);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setMaxReconnectInterval(final String uuid, final int value, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setReconnectIVLMax(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setSendTimeOut(final String uuid, final int value, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setSendTimeOut(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setReceiveTimeOut(final String uuid, final int value, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setReceiveTimeOut(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setImmediate(final String uuid, final Boolean immediate, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setImmediate((immediate));
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setLinger(final String uuid, final int value, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setLinger(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setRouterHandover(final String uuid, final Boolean value, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.setRouterHandover(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setRoutingId(final String uuid, final String id, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                if (base64) {
                    return socket.setConnectRid(id);
                } else {
                    return socket.setConnectRid(Base64.decode(id, Base64.DEFAULT));
                }
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketConnect(final String uuid, final String addr, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.connect(addr);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketDisconnect(final String uuid, final String addr, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.disconnect(addr);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketClose(final String uuid, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                socket.close();
                return ReactNativeZeroMQ.this._delObject(uuid);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void destroy(final Boolean forced, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                return ReactNativeZeroMQ.this._closeContext(forced);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void setSocketIdentity(final String uuid, final String id, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                final byte[] value = base64 ? Base64.decode(id, Base64.DEFAULT) : id.getBytes(ZMQ.CHARSET);
                return socket.setIdentity(value);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketSend(final String uuid, final ReadableArray body, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                ZMsg msg = new ZMsg();
                for (int i = 0; i < body.size(); i++) {
                    final String value = body.getString(i);
                    if (base64) {
                        msg.add(Base64.decode(value, Base64.DEFAULT));
                    } else {
                        msg.add(value);
                    }
                }
                return msg.send(socket);
            }
        }.startAsync();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketRecv(final String uuid, final Integer flag, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                ZMsg msg = ZMsg.recvMsg(socket, flag);
                if (msg == null) {
                    return null;
                }
                WritableArray arr = new WritableNativeArray();
                for (ZFrame f : msg) {
                    final String value = base64 ? Base64.encodeToString(f.getData(), Base64.DEFAULT) : f.getString(ZMQ.CHARSET);
                    arr.pushString(value);
                }
                return arr;
            }
        }.startAsync();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketRecvEvent(final String uuid, final Integer flags, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                ZMQ.Event event = ZMQ.Event.recv(socket, flags);
                if (event == null) {
                    return null;
                }
                WritableMap map = new WritableNativeMap();
                map.putInt("event", event.getEvent());
                map.putString("address", event.getAddress());
                Object value = event.getValue();
                if (value != null) {
                    map.putInt("value", (Integer) value);
                }
                return map;
            }
        }.startAsync();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketSubscribe(final String uuid, final String topic, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                if (base64) {
                    return socket.subscribe(Base64.decode(topic, Base64.DEFAULT));
                } else {
                    return socket.subscribe(topic);
                }
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketUnsubscribe(final String uuid, final String topic, final Boolean base64, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                if (base64) {
                    return socket.unsubscribe(Base64.decode(topic, Base64.DEFAULT));
                } else {
                    return socket.unsubscribe(topic);
                }
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketMonitor(final String uuid, @Nullable final String addr, final int events, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.monitor(addr, events);
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void socketHasMore(final String uuid, final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                ZMQ.Socket socket = ReactNativeZeroMQ.this._getObject(uuid);
                return socket.hasReceiveMore();
            }
        }.start();
    }

    @ReactMethod
    @SuppressWarnings("unused")
    @SuppressLint("StaticFieldLeak")
    public void getDeviceIdentifier(final Promise promise) {
        new ReactTask(promise) {
            @Override
            Object run() throws Exception {
                return ReactNativeZeroMQ.this._getDeviceIdentifier();
            }
        }.start();
    }
}
