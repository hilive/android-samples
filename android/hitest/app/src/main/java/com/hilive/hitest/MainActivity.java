package com.hilive.hitest;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import java.nio.ByteBuffer;

public class MainActivity extends AppCompatActivity {
    private Handler handler = new Handler(Looper.myLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        handler.post(new Runnable() {
            @Override
            public void run() {
                byte[] bytes = {1, 2, 3, 4, 5, 6, 7, 8, 9};
                ByteBuffer bb = ByteBuffer.allocate(100);

                bb.put(bytes, 3, 2);
            }
        });
    }
}