package com.dynamsoft.dcv.vinscanner;

import android.content.Intent;
import android.os.Bundle;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.dlr.RecognizedTextLinesResult;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {
    private static final String TEMPLATE_READ_VIN_BARCODE = "ReadVINBarcode";
    private static final String TEMPLATE_READ_VIN_TEXT = "ReadVINText";
    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private String parsedText;
    private String currentTemplate = TEMPLATE_READ_VIN_BARCODE;
    private final ExecutorService switchModeThread = new ThreadPoolExecutor(1, 1, 0, TimeUnit.MILLISECONDS,
            new LinkedBlockingQueue<>(1), new ThreadPoolExecutor.DiscardOldestPolicy());
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccessful, error) -> {
                if (!isSuccessful) {
                    error.printStackTrace();
                }
            });
        }

        //Request camera permission
        PermissionUtil.requestCameraPermission(this);

        CameraView cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);
        try {
            camera.setScanRegion(new DSRect(0.1f, 0.4f, 0.9f, 0.6f, true));
        } catch (CameraEnhancerException e) {
            throw new RuntimeException(e);
        }
        router = new CaptureVisionRouter(this);

        try {
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }

        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE | EnumCapturedResultItemType.CRIT_TEXT_LINE, true);
        router.addResultFilter(filter);

        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (result.getItems().length > 0) {
                    parsedText = result.getItems()[0].getText();
                }
            }

            @Override
            public void onRecognizedTextLinesReceived(@NonNull RecognizedTextLinesResult result) {
                if (result.getItems().length > 0) {
                    parsedText = result.getItems()[0].getText();
                }
            }

            @Override
            public void onParsedResultsReceived(@NonNull ParsedResult result) {
                if (result.getItems().length > 0) {
                    String[] displayStrings = ParseUtil.parsedItemToDisplayStrings(result.getItems()[0]);
                    if (displayStrings == null || displayStrings.length <= 1/*Only have Document Type content*/) {
                        showParsedText();
                    } else {
                        goToResultActivity(displayStrings);
                        router.stopCapturing();
                    }
                } else {
                    showParsedText();
                }
            }
        });

        initSwitchModeRadioGroup();
    }

    @Override
    public void onResume() {
        super.onResume();
        //Reset tip text.
        ((TextView) findViewById(R.id.tv_parsed)).setText("");
        parsedText = "";

        camera.open();
        router.startCapturing(currentTemplate, new CompletionListener() {
            @Override
            public void onSuccess() {
                //Do nothing
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> {
                    TextView tvError = findViewById(R.id.tv_error);
                    tvError.setText(String.format(Locale.getDefault(), "ErrorCode: %d\nErrorString: %s", errorCode, errorString));
                });
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        camera.close();
        router.stopCapturing();
    }

    private void initSwitchModeRadioGroup() {
        RadioButton btnBarcode = findViewById(R.id.btn_vin_barcode);
        RadioButton btnText = findViewById(R.id.btn_vin_text);
        ((RadioGroup) findViewById(R.id.rg_modes)).setOnCheckedChangeListener((group, checkedId) -> {
            if(btnBarcode.isPressed()) {
                camera.disableEnhancedFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
                currentTemplate = TEMPLATE_READ_VIN_BARCODE;
            } else if(btnText.isPressed()) {
                try {
                    camera.enableEnhancedFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
                currentTemplate = TEMPLATE_READ_VIN_TEXT;
            } else {
                return;
            }
            switchModeThread.submit(() -> {
                if (!this.isFinishing()) {
                    router.stopCapturing();
                    router.startCapturing(currentTemplate, null);
                }
            });
        });
    }

    private void showParsedText() {
        if (parsedText != null && !parsedText.isEmpty()) {
            runOnUiThread(() -> {
                TextView tvParsedText = findViewById(R.id.tv_parsed);
                tvParsedText.setText(String.format("Failed to parse the result. The text is:%n%s", parsedText));
            });
        }
    }

    private void goToResultActivity(String[] displayStrings) {
        Intent intent = new Intent(this, ResultActivity.class);
        intent.putExtra("displayStrings", displayStrings);
        startActivity(intent);
    }
}