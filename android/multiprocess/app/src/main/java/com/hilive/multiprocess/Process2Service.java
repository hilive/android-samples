package com.hilive.multiprocess;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

public class Process2Service extends Service {
    private static final String TAG = "hilog.Process2Service";

    ProcessProxy.Stub mStub = new ProcessProxy.Stub() {
        @Override
        public void sendMsg(String msg) {
            Log.i(TAG, "sendMsg msg: (" + msg + ") pid: "  + android.os.Process.myPid());
        }
    };


    private ProcessProxy mProxy = null;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mProxy = ProcessProxy.Stub.asInterface(service);
            Log.i(TAG, "onServiceConnected clsName: " + name.getClassName() + " pkgName: " + name.getPackageName());
            Log.i(TAG, "onServiceConnected " + android.os.Process.myPid());
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.i(TAG, "onServiceDisconnected clsName: " + name.getClassName() + " pkgName: " + name.getPackageName());
            Log.i(TAG, "onServiceDisconnected " + android.os.Process.myPid());
        }

        @Override
        public void onBindingDied(ComponentName name) {
            Log.i(TAG, "onBindingDied clsName: " + name.getClassName() + " pkgName: " + name.getPackageName());
            Log.i(TAG, "onBindingDied " + android.os.Process.myPid());
        }

        @Override
        public void onNullBinding(ComponentName name) {
            Log.i(TAG, "onNullBinding clsName: " + name.getClassName() + " pkgName: " + name.getPackageName());
            Log.i(TAG, "onNullBinding " + android.os.Process.myPid());
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
        return mStub;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }
}
