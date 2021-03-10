package com.hilive.sharedsurface;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.os.RemoteException;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;

public class ProcessProxyWrapper extends ProcessProxy.Stub {
    private static final String TAG = "hilive.SurfaceManager";
    private DrawSurface mDrawSurface = new DrawSurface();

    @Override
    public void onSurfaceTextureAvailable(Surface surface, int width, int height) throws RemoteException {
        Log.i(TAG, "onSurfaceTextureAvailable: pid: " + android.os.Process.myPid());

        mDrawSurface.init(surface, width, height);
    }

    @Override
    public void onSurfaceTextureSizeChanged(Surface surface, int width, int height) throws RemoteException {
        Log.i(TAG, "onSurfaceTextureSizeChanged: pid: " + android.os.Process.myPid());
    }

    @Override
    public void onSurfaceTextureUpdated(Surface surface) throws RemoteException {
        Log.i(TAG, "onSurfaceTextureUpdated: pid: " + android.os.Process.myPid());
    }

    @Override
    public boolean onSurfaceTextureDestroyed(Surface surface) throws RemoteException {
        Log.i(TAG, "onSurfaceTextureDestroyed: pid: " + android.os.Process.myPid());
        return true;
    }

    @Override
    public void sendMessage(int evtType, String evtMsg) throws RemoteException {
        Log.i(TAG, "onMessage: type: [" + evtType + "] msg: [" + evtMsg + "] pid: [" + android.os.Process.myPid() + "]");
    }

    @Override
    public void sendTouchEvent(MotionEvent event) throws RemoteException {
        mDrawSurface.onTouchEvent(event);
    }


}
