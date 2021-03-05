package com.hilive.sharedsurface;

import androidx.appcompat.app.AppCompatActivity;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.SurfaceTexture;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

public class MainActivity extends AppCompatActivity implements TextureView.SurfaceTextureListener {
    private static final String TAG = "hilog.MainActivity";
    private ProcessProxy mWrapper = null;
    private Surface mSurface = null;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mWrapper = ProcessProxyWrapper.Stub.asInterface(service);
            ProcessProxyWrapper.Stub.asInterface(service);

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

        this.bindService(new Intent(this, ChildService.class), serviceConnection, Context.BIND_AUTO_CREATE);

        TextureView textureView = findViewById(R.id.texture);
        textureView.setSurfaceTextureListener(this);

        SurfaceView surfaceView = findViewById(R.id.surface);
        surfaceView.setClickable(true);
        surfaceView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                try {
                    mWrapper.sendTouchEvent(event);
                } catch (RemoteException e) {}
                return false;
            }
        });
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        Log.i(TAG, "onSurfaceTextureAvailable " + android.os.Process.myPid());

        try {
            mSurface = new Surface(surface);
            mWrapper.onSurfaceTextureAvailable(mSurface, width, height);
        } catch (RemoteException e) {}
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
        Log.i(TAG, "onSurfaceTextureSizeChanged " + android.os.Process.myPid());

        try {
            mWrapper.onSurfaceTextureSizeChanged(mSurface, width, height);
        } catch (RemoteException e) {}
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
    //    Log.i(TAG, "onSurfaceTextureUpdated " + android.os.Process.myPid());

        try {
            mWrapper.onSurfaceTextureUpdated(mSurface);
        } catch (RemoteException e) {}
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        Log.i(TAG, "onSurfaceTextureDestroyed " + android.os.Process.myPid());

        try {
            mWrapper.onSurfaceTextureDestroyed(mSurface);
        } catch (RemoteException e) {}
        return true;
    }
}