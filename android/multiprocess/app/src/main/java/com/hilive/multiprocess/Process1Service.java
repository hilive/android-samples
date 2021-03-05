package com.hilive.multiprocess;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

public class Process1Service extends Service {
    private static final String TAG = "hilog.Process1Service";

    ProcessProxy.Stub mStub = new ProcessProxy.Stub() {
        @Override
        public void sendMsg(String msg) {
            Log.i(TAG, "sendMsg msg: (" + msg + ") pid: "  + android.os.Process.myPid());
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "onCreate " + android.os.Process.myPid());
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mStub;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }
}
