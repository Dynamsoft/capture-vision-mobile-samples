package com.dynamsoft.documentscanner.scan;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.ImageEditorView;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.ddn.NormalizedImageResultItem;
import com.dynamsoft.documentscanner.R;
import com.google.android.material.snackbar.Snackbar;

import java.util.ArrayList;

public class EditFragment extends Fragment {
    private DocumentScannerViewModel mViewModel;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mViewModel = new ViewModelProvider(requireActivity()).get(DocumentScannerViewModel.class);
        mViewModel.actionBarTitle.setValue(requireContext().getString(R.string.editor_page_title));
        return inflater.inflate(R.layout.fragment_edit, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        ImageEditorView editorView = view.findViewById(R.id.image_editor_view);
        editorView.setOriginalImage(mViewModel.originalImage);
        DrawingLayer drawingLayer = editorView.getDrawingLayer(DrawingLayer.DDN_LAYER_ID);
        ArrayList<DrawingItem> drawingItems = new ArrayList<>();
        drawingItems.add(new QuadDrawingItem(mViewModel.resultLocation));
        drawingLayer.setDrawingItems(drawingItems);

        view.findViewById(R.id.btn_confirm).setOnClickListener(v -> {
            Quadrilateral selectedQuad = getSelectedItemOrFirst(editorView);
            ImageData normalized = normalizeImageDataByQuad(mViewModel.originalImage, selectedQuad);
            if (normalized != null) {
                mViewModel.normalizedResultImage = normalized;
                mViewModel.resultLocation = selectedQuad;
                requireActivity().getSupportFragmentManager().popBackStack();
            } else {
                Snackbar.make(requireView(), R.string.normalize_error_tip, Snackbar.LENGTH_LONG)
                        .setAction(R.string.ok, v1 -> {}).show();
            }
        });
        super.onViewCreated(view, savedInstanceState);
    }

    private ImageData normalizeImageDataByQuad(ImageData imageData, Quadrilateral quadrilateral) {
        if (imageData == null || quadrilateral == null) {
            return null;
        }
        CaptureVisionRouter router = new CaptureVisionRouter(requireContext());
        String template = EnumPresetTemplate.PT_NORMALIZE_DOCUMENT;
        try {
            SimplifiedCaptureVisionSettings settings = router.getSimplifiedSettings(template);
            // Set the detected boundary received in the previous step as the new ROI.
            settings.roi = quadrilateral;
            settings.roiMeasuredInPercentage = false;
            router.updateSettings(template, settings);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        // Use the capture method to process the image.
        CapturedResult result = router.capture(imageData, template);

        if (result.getItems().length > 0) {
            return ((NormalizedImageResultItem) result.getItems()[0]).getImageData();
        } else {
            return null;
        }
    }

    private Quadrilateral getSelectedItemOrFirst(ImageEditorView editorView) {
        if (editorView.getSelectedDrawingItem() == null) {
            return ((QuadDrawingItem) editorView.getDrawingLayer(DrawingLayer.DDN_LAYER_ID).getDrawingItems().get(0)).getQuad();
        }
        return ((QuadDrawingItem) editorView.getSelectedDrawingItem()).getQuad();
    }
}