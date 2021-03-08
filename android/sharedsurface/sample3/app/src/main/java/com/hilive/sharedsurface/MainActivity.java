package com.hilive.sharedsurface;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.SurfaceTexture;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;
import android.widget.Switch;

import java.io.IOException;
import java.nio.ByteBuffer;

public class MainActivity extends AppCompatActivity implements TextureView.SurfaceTextureListener {
    private static final String TAG = "hilog.MainActivity";
    private ProcessProxy mWrapper = null;
    private VideoEncoder mVideoEncoder = new VideoEncoder();
    private DrawSurface mDrawSurface = new DrawSurface();

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mWrapper = ProcessProxy.Stub.asInterface(service);

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

        Intent intent = new Intent();
        intent.setClassName("com.hilive.sharedsurface", "com.hilive.sharedsurface.ChildService");

        this.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    //    this.bindService(new Intent(this, ChildService.class), serviceConnection, Context.BIND_AUTO_CREATE);

        TextureView textureView = findViewById(R.id.texture);
        textureView.setSurfaceTextureListener(this);

        SurfaceView surfaceView = findViewById(R.id.surface);
        surfaceView.setClickable(true);
        surfaceView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                try {
                    mDrawSurface.onTouchEvent(event);
                    mWrapper.sendTouchEvent(event);
                } catch (RemoteException e) {}
                return false;
            }
        });
    }

    private void onInit() {
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        Log.i(TAG, "onSurfaceTextureAvailable " + android.os.Process.myPid());

        try {
            mDrawSurface.init(new Surface(surface), width, height);
            mVideoEncoder.init(getApplicationContext(), width, height);
            mWrapper.onSurfaceTextureAvailable(mVideoEncoder.getSurface(), mVideoEncoder.getWidth(), mVideoEncoder.getHeight());
        } catch (RemoteException e) {}
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
        Log.i(TAG, "onSurfaceTextureSizeChanged " + android.os.Process.myPid());
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
    //    Log.i(TAG, "onSurfaceTextureUpdated " + android.os.Process.myPid());
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        Log.i(TAG, "onSurfaceTextureDestroyed " + android.os.Process.myPid());
        return true;
    }
}