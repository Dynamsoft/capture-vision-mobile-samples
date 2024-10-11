package com.dynamsoft.dcv.vinscanner.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.dcv.vinscanner.MainViewModel;
import com.dynamsoft.dcv.vinscanner.ParseUtil;
import com.dynamsoft.dcv.vinscanner.R;
import com.dynamsoft.dcv.vinscanner.databinding.FragmentScannerBinding;
import com.dynamsoft.dlr.RecognizedTextLinesResult;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ScannerFragment extends Fragment {
    private static final String TEMPLATE_READ_VIN_BARCODE = "ReadVINBarcode";
    private static final String TEMPLATE_READ_VIN_TEXT = "ReadVINText";
    private final ExecutorService switchModeThread = new ThreadPoolExecutor(1, 1, 0, TimeUnit.MILLISECONDS,
            new LinkedBlockingQueue<>(1), new ThreadPoolExecutor.DiscardOldestPolicy());
    private FragmentScannerBinding binding;
    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;
    private MainViewModel viewModel;
    private String mTemplate = TEMPLATE_READ_VIN_BARCODE;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        binding = FragmentScannerBinding.inflate(inflater, container, false);
        viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);
        viewModel.reset();

        mCamera = new CameraEnhancer(binding.cameraView, getViewLifecycleOwner());
        try {
            mCamera.setScanRegion(new DSRect(0.1f, 0.4f, 0.9f, 0.6f, true));
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }

        if (mRouter == null) {
            initCaptureVisionRouter();
        }
        try {
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        binding.rgModes.setOnCheckedChangeListener((group, checkedId) -> {
            if (binding.btnVinBarcode.isPressed()) {
                mCamera.disableEnhancedFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
                mTemplate = TEMPLATE_READ_VIN_BARCODE;
            } else if (binding.btnVinText.isPressed()) {
                try {
                    mCamera.enableEnhancedFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
                } catch (CameraEnhancerException e) {
                    e.printStackTrace();
                }
                mTemplate = TEMPLATE_READ_VIN_TEXT;
            } else {
                //Do not handle non manually triggered onCheckedChanged events.
                return;
            }
            switchModeThread.submit(() -> {
                if (!this.isRemoving()) {
                    changeCaptureTemplate(mRouter, mTemplate);
                }
            });
        });

        return binding.getRoot();
    }

    @Override
    public void onResume() {
        super.onResume();
        try {
            mCamera.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.startCapturing(mTemplate, null);
    }

    @Override
    public void onPause() {
        super.onPause();
        try {
            mCamera.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.stopCapturing();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    private void initCaptureVisionRouter() {
        mRouter = new CaptureVisionRouter(requireContext());
        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE | EnumCapturedResultItemType.CRIT_TEXT_LINE, true);
        mRouter.addResultFilter(filter);
        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                if (result.getItems().length > 0) {
                    viewModel.parsedText = result.getItems()[0].getText();
                }
            }

            @Override
            public void onRecognizedTextLinesReceived(RecognizedTextLinesResult result) {
                if (result.getItems().length > 0) {
                    viewModel.parsedText = result.getItems()[0].getText();
                }
            }

            @Override
            public void onParsedResultsReceived(ParsedResult result) {
                if (result.getItems().length > 0) {
                    String[] displayStrings = ParseUtil.parsedItemToDisplayStrings(result.getItems()[0]);
                    if (displayStrings == null) {
                        showParsedText();
                        return;
                    }
                    viewModel.results = displayStrings;
                    requireActivity().runOnUiThread(() -> NavHostFragment.findNavController(ScannerFragment.this)
                            .navigate(R.id.action_ScannerFragment_to_ResultFragment));
                    mRouter.stopCapturing();
                } else {
                    showParsedText();
                }
            }
        });
    }

    private void changeCaptureTemplate(@NonNull CaptureVisionRouter router, String template) {
        router.stopCapturing();
        router.startCapturing(template, null);
    }

    private void showParsedText() {
        if (viewModel.parsedText != null && !viewModel.parsedText.isEmpty()) {
            requireActivity().runOnUiThread(() -> {
                if (binding != null) {
                    binding.tvParsed.setText(String.format("Failed to parse the result. The text is:%n%s", viewModel.parsedText));
                }
            });
        }
    }
}