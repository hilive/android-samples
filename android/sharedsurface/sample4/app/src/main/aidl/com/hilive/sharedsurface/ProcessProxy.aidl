// ProcessProxy.aidl
package com.hilive.sharedsurface;

// Declare any non-default types here with import statements

interface ProcessProxy {
    void sendMessage(in int evtType, in String evtMsg);

    void sendTouchEvent(in MotionEvent event);

    void onSurfaceTextureAvailable(in Surface surface, in int width, in int height);

    void onSurfaceTextureSizeChanged(in Surface surface, in int width, in int height);

    void onSurfaceTextureUpdated(in Surface surface);

    boolean onSurfaceTextureDestroyed(in Surface surface);
}
