package com.dynamsoft.scandocument.scan;

import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.View;
import android.widget.ImageView;
import android.widget.PopupMenu;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CoreException;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.ddn.EnumImageColourMode;
import com.dynamsoft.scandocument.R;
import com.dynamsoft.scandocument.utils.FileUtils;
import com.dynamsoft.utility.ImageIO;
import com.dynamsoft.utility.ImageProcessor;
import com.dynamsoft.utility.UtilityException;
import com.google.android.material.appbar.MaterialToolbar;
import com.google.android.material.bottomnavigation.BottomNavigationView;

import java.io.IOException;

public class ResultDisplayActivity extends AppCompatActivity {

    private PopupMenu mSwitchColorMenu;

    private ImageView mImageView;
    private ImageData mDeskewedImage; //Colourful
    private ImageData mShowingImage; //Colourful or Grayscale or Binary, for saving
    private final Quadrilateral mSourceDeskewQuad = new Quadrilateral(); //It is not used in this activity, but its value needs to be logged to pass to the EditorActivity
    private final ImageIO mImageIO = new ImageIO();
    private final ImageProcessor mImageProcessor = new ImageProcessor();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_result_display);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());

        Parcelable[] parcelables = getIntent().getParcelableArrayExtra("sourceDeskewQuad.points");
        for (int i = 0; i < 4; i++) {
            mSourceDeskewQuad.points[i] = (Point) parcelables[i];
        }

        mImageView = findViewById(R.id.iv);
        try {
            mDeskewedImage = mImageIO.readFromFile(ImageTempPaths.getDeskewedImagePath(this).getAbsolutePath());
            mShowingImage = mDeskewedImage;
            mImageView.setImageBitmap(mShowingImage.toBitmap());
        } catch (UtilityException | CoreException e) {
            throw new RuntimeException(e);
        }

        initBottomView(); //go to EditorActivity, switch colour mode, save showing image
        initSwitchColorMenu(findViewById(R.id.anchor_view));
    }

    private void initSwitchColorMenu(View anchorView) {
        mSwitchColorMenu = new PopupMenu(this, anchorView);
        mSwitchColorMenu.getMenuInflater().inflate(R.menu.color_selector, mSwitchColorMenu.getMenu());
        mSwitchColorMenu.setOnMenuItemClickListener(item -> {
            item.setChecked(true);
            int colorMode = item.getItemId() == R.id.item_colour ? EnumImageColourMode.ICM_COLOUR :
                    item.getItemId() == R.id.item_grayscale ? EnumImageColourMode.ICM_GRAYSCALE : EnumImageColourMode.ICM_BINARY;
            if (colorMode == EnumImageColourMode.ICM_COLOUR) {
                mShowingImage = mDeskewedImage;
            } else if (colorMode == EnumImageColourMode.ICM_GRAYSCALE) {
                mShowingImage = mImageProcessor.convertToGray(mDeskewedImage);
            } else {
                mShowingImage = mImageProcessor.convertToBinaryLocal(mDeskewedImage);
            }
            try {
                mImageView.setImageBitmap(mShowingImage.toBitmap());
            } catch (CoreException e) {
                throw new RuntimeException(e);
            }
            return true;
        });
    }

    private void initBottomView() {
        BottomNavigationView bottomView = findViewById(R.id.bottom_view);
        bottomView.setItemIconTintList(null);
        bottomView.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.back_to_edit) {
                Intent intent = new Intent(this, EditorActivity.class);
                intent.putExtra("sourceDeskewQuad.points", mSourceDeskewQuad.points);
                startActivityForResult(intent, 1024);
            } else if (itemId == R.id.switch_colour_mode) {
                mSwitchColorMenu.show();
            } else if (itemId == R.id.export) {
                try {
                    FileUtils.saveImageToGallery(this, mShowingImage);
                } catch (IOException | CoreException | UtilityException e) {
                    throw new RuntimeException(e);
                }
            }
            return true;
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1024 && resultCode == RESULT_OK && data != null) {
            //Update mSourceDeskewQuad, it might be edited in EditorActivity
            Parcelable[] parcelables = data.getParcelableArrayExtra("sourceDeskewQuad.points");
            for (int i = 0; i < 4; i++) {
                mSourceDeskewQuad.points[i] = (Point) parcelables[i];
            }

            //Update mDeskewedImage, it might be edited in EditorActivity and rewrote to DeskewedImagePath
            try {
                mDeskewedImage = mImageIO.readFromFile(ImageTempPaths.getDeskewedImagePath(this).getAbsolutePath());
                mShowingImage = mDeskewedImage;
                mImageView.setImageBitmap(mShowingImage.toBitmap());
            } catch (UtilityException | CoreException e) {
                throw new RuntimeException(e);
            }
        }
    }
}