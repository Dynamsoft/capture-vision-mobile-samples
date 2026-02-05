package com.dynamsoft.scandocument.scan;

import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.os.Parcelable;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.ImageEditorView;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.scandocument.R;
import com.dynamsoft.utility.ImageIO;
import com.dynamsoft.utility.ImageProcessor;
import com.dynamsoft.utility.UtilityException;
import com.google.android.material.appbar.MaterialToolbar;

import java.util.ArrayList;

public class EditorActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_editor);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        MaterialToolbar toolbar = findViewById(R.id.toolbar1);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());

        Quadrilateral sourceDeskewQuad = new Quadrilateral();
        Parcelable[] parcelables = getIntent().getParcelableArrayExtra("sourceDeskewQuad.points");
        for (int i = 0; i < 4; i++) {
            sourceDeskewQuad.points[i] = (Point) parcelables[i];
        }


        ImageIO imageIO = new ImageIO();
        ImageProcessor imageProcessor = new ImageProcessor();
        ImageData originalImage;
        try {
            originalImage = imageIO.readFromFile(ImageTempPaths.getOriginalImagePath(this).getAbsolutePath());
        } catch (UtilityException e) {
            throw new RuntimeException(e);
        }

        ImageEditorView editorView = findViewById(R.id.image_editor_view);

        editorView.setOriginalImage(originalImage);

        DrawingLayer drawingLayer = editorView.getDrawingLayer(DrawingLayer.DDN_LAYER_ID);
        ArrayList<DrawingItem> drawingItems = new ArrayList<>();
        drawingItems.add(new QuadDrawingItem(sourceDeskewQuad));
        drawingLayer.setDrawingItems(drawingItems);

        findViewById(R.id.btn_confirm).setOnClickListener(v -> {
            Quadrilateral selectedQuad;
            if (editorView.getSelectedDrawingItem() != null) {
                selectedQuad = ((QuadDrawingItem) editorView.getSelectedDrawingItem()).getQuad();
            } else {
                selectedQuad = ((QuadDrawingItem) editorView.getDrawingLayer(DrawingLayer.DDN_LAYER_ID).getDrawingItems().get(0)).getQuad();
            }

            try {
                ImageData updatedDeskewedImage = imageProcessor.cropAndDeskewImage(originalImage, selectedQuad);
                imageIO.saveToFile(updatedDeskewedImage, ImageTempPaths.getDeskewedImagePath(this).getAbsolutePath(), true);
            } catch (UtilityException e) {
                throw new RuntimeException(e);
            }

            Intent resultIntent = new Intent();
            resultIntent.putExtra("sourceDeskewQuad.points", selectedQuad.points);
            setResult(RESULT_OK, resultIntent);
            finish();
        });

    }
}