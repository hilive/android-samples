package com.hilive.multiprocess;

import androidx.appcompat.app.AppCompatActivity;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "hilog.MainActivity";
    private ProcessProxy mProxy1 = null;
    private ProcessProxy mProxy2 = null;

    private ServiceConnection serviceConnection1 = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mProxy1 = ProcessProxy.Stub.asInterface(service);
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

    private ServiceConnection serviceConnection2 = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mProxy2 = ProcessProxy.Stub.asInterface(service);
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
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i(TAG, "onCreate " + android.os.Process.myPid());

        this.bindService(new Intent(this, Process1Service.class), serviceConnection1, Context.BIND_AUTO_CREATE);
        this.bindService(new Intent(this, Process2Service.class), serviceConnection2, Context.BIND_AUTO_CREATE);
        this.startService(new Intent(this, ChildService.class));

        Button btChild1 = (Button) findViewById(R.id.btChild1);
        btChild1.setOnClickListener(clickListener);
    }

    View.OnClickListener clickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.btChild1: {
                    try {
                        mProxy1.sendMsg("hello process1 pid: " + android.os.Process.myPid() + " tick: " + System.currentTimeMillis());
                    } catch (RemoteException e) {}
                } break;
                case R.id.btChild2: {

                } break;
            }
        }
    };
}