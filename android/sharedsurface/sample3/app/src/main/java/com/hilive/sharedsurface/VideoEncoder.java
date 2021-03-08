package com.hilive.sharedsurface;

import android.content.Context;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.os.RemoteException;
import android.util.Log;
import android.view.Surface;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

public class VideoEncoder {
    private static final String TAG = "hilog.VideoEncoder";

    private boolean mInited = false;
    private int mWidth = 0;
    private int mHeight = 0;
    private Surface mSurface = null;
    private MediaCodec mMediaCodec = null;
    private MediaFormat mMediaFormat = null;
    private FileOutputStream mFileOutputStream = null;

    public VideoEncoder() {
    }

    synchronized public Surface getSurface() {
        return mSurface;
    }

    synchronized public int getWidth() {
        return mWidth;
    }

    synchronized public int getHeight() {
        return mHeight;
    }

    synchronized public boolean init(final Context context, final int width, final int height) {
        if (mInited) {
            return mInited;
        }

    //    String cacheDir = context.getCacheDir().getAbsolutePath() + "/hilive";
        String cacheDir = "/sdcard/tmp";
        String fileName = cacheDir + "/temp.h264";
        Log.i(TAG, "init cacheDir: " + cacheDir + " fileName: " + fileName);



        try {
            File file = new File(cacheDir, "temp.h264");
            mFileOutputStream = new FileOutputStream(file);

            mInited = true;
            mWidth = width;
            mHeight = height;

            String mimeType = "video/avc";
            mMediaFormat = MediaFormat.createVideoFormat(mimeType, width, height);
            mMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
            mMediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, 3000);
            mMediaFormat.setInteger(MediaFormat.KEY_FRAME_RATE, 30);
            mMediaFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 30);

            mMediaCodec = MediaCodec.createEncoderByType(mimeType);

            mMediaCodec.setCallback(new MediaCodec.Callback() {
                @Override
                public void onInputBufferAvailable(@NonNull MediaCodec codec, int index) {
                    Log.i(TAG, "onInputBufferAvailable");
                }

                @Override
                public void onOutputBufferAvailable(@NonNull MediaCodec codec, int index, @NonNull MediaCodec.BufferInfo info) {
                    Log.i(TAG, "onOutputBufferAvailable index: " + index + " size: " + info.size + " pts: " + info.presentationTimeUs + " flags: " + info.flags);

                    ByteBuffer byteBuffer = codec.getOutputBuffer(index);

                    byte[] bytes = new byte[info.size];
                    byteBuffer.get(bytes);

                    Log.i(TAG, "onOutputBufferAvailable bytes: [" + bytes[0] + ", " + bytes[1] + ", " + bytes[2] + ", " + bytes[3] + "]");

                    if ((info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) == 1) {
                        Log.i(TAG, "onOutputBufferAvailable BUFFER_FLAG_END_OF_STREAM");
                    } else if ((info.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) == 1) {
                        Log.i(TAG, "onOutputBufferAvailable BUFFER_FLAG_CODEC_CONFIG");
                    } else if ((info.flags & MediaCodec.BUFFER_FLAG_KEY_FRAME) == 1) {
                        Log.i(TAG, "onOutputBufferAvailable BUFFER_FLAG_KEY_FRAME");
                    }

                    try {
                        mFileOutputStream.write(bytes);
                    } catch (IOException e) {
                        e.printStackTrace();
                        Log.i(TAG, "onOutputBufferAvailable IOException " + e.getMessage());
                    }

                    codec.releaseOutputBuffer(index, info.size > 0);
                }

                @Override
                public void onError(@NonNull MediaCodec codec, @NonNull MediaCodec.CodecException e) {
                    Log.i(TAG, "onError");
                }

                @Override
                public void onOutputFormatChanged(@NonNull MediaCodec codec, @NonNull MediaFormat format) {
                    Log.i(TAG, "onOutputFormatChanged");
                }
            });

            mMediaCodec.configure(mMediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
            mSurface = mMediaCodec.createInputSurface();

            mMediaCodec.start();
            mInited = true;
        } catch (IOException e) {
            e.printStackTrace();
            Log.i(TAG, "init IOException " + e.getMessage());
        }

        return mInited;
    }

    synchronized public void uint() {
        if (!mInited) {
            return;
        }

        mInited = false;

        mMediaCodec.stop();
        mMediaCodec.release();


    }
}
