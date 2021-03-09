package com.hilive.sharedsurface;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.RemoteException;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;

public class DrawSurface {
    private static final String TAG = "hilog.DrawSurface";

    Paint mPaint = new Paint();
    Path mPath = new Path();
    private Surface mSurface;
    private int mWidth = 0;
    private int mHeight = 0;

    public DrawSurface() {
    }

    public void init(final Surface surface, final int width, final int height) {
        mSurface = surface;
        mWidth = width;
        mHeight = height;
    }

    public void onTouchEvent(MotionEvent event) {
        int x = (int) event.getX();
        int y = (int) event.getY();

        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                mPath.moveTo(x, y);
                break;
            case MotionEvent.ACTION_MOVE:
                mPath.lineTo(x, y);
                draw();
                break;
            case MotionEvent.ACTION_UP:
                break;
        }
    }

    public void uint() {

    }

    // 绘图
    private void draw() {
        Canvas canvas = null;

        try {
            mPaint.setColor(Color.BLACK);
            mPaint.setStyle(Paint.Style.STROKE);
            mPaint.setStrokeWidth(5);
            mPaint.setAntiAlias(true);

            //获得canvas对象
            canvas = mSurface.lockCanvas(new Rect(0,0, mWidth, mHeight));
            Log.e(TAG, "canvas size" + canvas.getWidth() + "-" + canvas.getHeight());
            //绘制背景
            canvas.drawColor(Color.WHITE);

            canvas.drawRect(0, 0, mWidth, mHeight, mPaint);
            //绘制路径
            canvas.drawPath(mPath, mPaint);
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            if (canvas != null){
                //释放canvas对象并提交画布
                mSurface.unlockCanvasAndPost(canvas);
            }
        }
    }

}
