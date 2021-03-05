package com.hilive.sharedsurface;

import com.hilive.multiprocess.*;
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
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i(TAG, "onCreate " + android.os.Process.myPid());

        Intent intent = new Intent();
        intent.setClassName("com.hilive.multiprocess", "com.hilive.multiprocess.ChildService");
        this.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
     //   this.startService(intent);

        Button btSend = (Button) findViewById(R.id.btSend);
        btSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    mProxy.sendMsg("onClick id: " + android.os.Process.myPid());
                } catch (RemoteException e) {

                } catch (Exception e) {

                } finally {
                }
            }
        });
    }
}