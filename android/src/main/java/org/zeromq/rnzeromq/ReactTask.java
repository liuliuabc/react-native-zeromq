package org.zeromq.rnzeromq;

import android.os.AsyncTask;

import com.facebook.react.bridge.Promise;


abstract class ReactTask extends AsyncTask<Object, Void, Object> {
    private Promise _promise = null;

    ReactTask(Promise promise) {
        _promise = promise;
    }

    @Override
    protected Object doInBackground(Object... params) {
        this.start();
        return null;
    }

    abstract Object run() throws Exception;

    void start() {
        try {
            Object result = this.run();
            this._promise.resolve(result);
        } catch (Exception e) {
            this._promise.reject("ERNINT", e);
        }
    }

    void startAsync() {
        this.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

}
