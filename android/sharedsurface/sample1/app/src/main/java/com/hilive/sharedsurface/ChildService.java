package com.hilive.sharedsurface;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import android.view.Surface;

public class ChildService extends Service {
    private static final String TAG = "hilog.ChildService";

    private ProcessProxyWrapper mWrapper = new ProcessProxyWrapper();

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
        return mWrapper.asBinder();
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
