package com.dynamsoft.scandocument.scan;

import android.content.Context;

import java.io.File;

public class ImageTempPaths {

    public static File getOriginalImagePath(Context context) {
        return new File(getSavedDir(context), "original.png");
    }

    public static File getDeskewedImagePath(Context context) {
        return new File(getSavedDir(context), "deskewed.png");
    }

    private static File getSavedDir(Context context) {
        File cacheDir = context.getCacheDir();
        File savedDir = new File(cacheDir, "tempImages");
        boolean ignore = savedDir.mkdirs();
        return savedDir;
    }
}
