package com.dynamsoft.scandocument.scan;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.core.basic_structures.EnumCrossVerificationStatus;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.ddn.DeskewedImageResultItem;
import com.dynamsoft.ddn.ProcessedDocumentResult;
import com.dynamsoft.scandocument.R;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.ImageIO;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;
import com.dynamsoft.utility.UtilityException;
import com.google.android.material.appbar.MaterialToolbar;

import java.util.Locale;

public class DocumentScannerActivity extends AppCompatActivity {

    private CaptureVisionRouter mRouter;
    private CameraEnhancer mCamera;
    private boolean mIsBtnClicked;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_document_scanner);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess && error != null) {
                    error.printStackTrace();
                }
            });
        }

        PermissionUtil.requestCameraPermission(this);

        CameraView cameraView = findViewById(R.id.camera_view);
        mCamera = new CameraEnhancer(cameraView, this);

        mRouter = new CaptureVisionRouter();
        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_DESKEWED_IMAGE, true);
        mRouter.addResultFilter(filter);

        try {
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        findViewById(R.id.btn_capture).setOnClickListener(v -> {
            mIsBtnClicked = true;
        });

        mRouter.addResultReceiver(new CapturedResultReceiver() {
            final ImageIO imageIO = new ImageIO();

            @Override
            public void onProcessedDocumentResultReceived(@NonNull ProcessedDocumentResult result) {
                if (result.getDeskewedImageResultItems().length > 0 &&
                        (mIsBtnClicked || result.getDeskewedImageResultItems()[0].getCrossVerificationStatus() == EnumCrossVerificationStatus.CVS_PASSED)) {
                    mRouter.stopCapturing();
                    mIsBtnClicked = false;
                    DeskewedImageResultItem deskewedItem = result.getDeskewedImageResultItems()[0];
                    try {
                        imageIO.saveToFile(mRouter.getIntermediateResultManager().getOriginalImage(result.getOriginalImageHashId()),
                                ImageTempPaths.getOriginalImagePath(DocumentScannerActivity.this).getAbsolutePath(), true);
                        imageIO.saveToFile(deskewedItem.getImageData(),
                                ImageTempPaths.getDeskewedImagePath(DocumentScannerActivity.this).getAbsolutePath(), true);
                    } catch (UtilityException e) {
                        e.printStackTrace();
                    }
                    Intent intent = new Intent(DocumentScannerActivity.this, ResultDisplayActivity.class);
                    Quadrilateral sourceDeskewQuad = deskewedItem.getSourceDeskewQuad();
                    intent.putExtra("sourceDeskewQuad.points", sourceDeskewQuad.points);
                    startActivity(intent);
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        mCamera.open();
        mRouter.startCapturing(EnumPresetTemplate.PT_DETECT_AND_NORMALIZE_DOCUMENT, new CompletionListener() {
            @Override
            public void onSuccess() {
                /*no-op*/
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
    protected void onPause() {
        super.onPause();
        mCamera.close();
        mRouter.stopCapturing();
    }
}