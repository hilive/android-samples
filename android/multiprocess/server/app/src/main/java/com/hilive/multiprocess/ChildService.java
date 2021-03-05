package com.hilive.multiprocess;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class ChildService extends Service {
    private static final String TAG = "hilog.ChildService";

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
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "onStartCommand " + android.os.Process.myPid());
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.i(TAG, "onBind " + android.os.Process.myPid());
        return mStub;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.i(TAG, "onUnbind " + android.os.Process.myPid());
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "onDestroy " + android.os.Process.myPid());
    }
}
