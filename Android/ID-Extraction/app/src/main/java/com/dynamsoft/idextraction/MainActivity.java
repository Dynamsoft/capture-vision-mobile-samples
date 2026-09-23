package com.dynamsoft.idextraction;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.dcp.CodeParser;
import com.dynamsoft.dcp.CodeParserException;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.dcp.ParsedResultItem;
import com.dynamsoft.dlr.RecognizedTextLinesResult;
import com.dynamsoft.dlr.TextLineResultItem;
import com.dynamsoft.idextraction.model.DriverLicenseData;
import com.dynamsoft.idextraction.model.MRZData;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    public static final String EXTRA_MRZ_DATA = "MRZ_DATA";
    public static final String EXTRA_DRIVER_LICENSE_DATA = "DRIVER_LICENSE_DATA";

    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private CodeParser parser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        PermissionUtil.requestCameraPermission(this);

        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccuss, e) -> {
            if (!isSuccuss) {
                Log.e(TAG, "onCreate: License initialization failed", e);
            }
        });

        router = new CaptureVisionRouter();

        //Enable result cross verification for MRZ text.
        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_TEXT_LINE, true);
        router.addResultFilter(filter);

        CameraView cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);
        try {
            router.setInput(camera);
            //See template file in assets/Templates.
            router.initSettingsFromFile("read_id.json");
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }

        parser = new CodeParser();
        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onParsedResultsReceived(@NonNull ParsedResult result) {
                if(result.getItems().length == 0) {
                    return;
                }
                ParsedResultItem parsedResultItem = result.getItems()[0];
                CapturedResultItem refencesItem = parsedResultItem.getReferenceItem();
                if(refencesItem == null) {
                    return;
                }
                // Determine whether the ParsedResultItem is parsed from a barcode or text lines
                if(refencesItem.getType() == EnumCapturedResultItemType.CRIT_TEXT_LINE) {
                    MRZData mrzData = MRZData.fromParsedResultItem(parsedResultItem);
                    if(mrzData != null) {
                        //Prevent entering the next result callback, which may cause multiple page redirects
                        router.stopCapturing();
                        Intent intent = new Intent(MainActivity.this, ResultActivity.class);
                        intent.putExtra(EXTRA_MRZ_DATA, mrzData);
                        startActivity(intent);
                    } else {
                        Log.i(TAG, "onParsedResultsReceived: The parsed result is not a MRZ data. Raw text: " + ((TextLineResultItem)refencesItem).getText());
                    }
                } else if(refencesItem.getType() == EnumCapturedResultItemType.CRIT_BARCODE) {
                    DriverLicenseData driverLicenseData = DriverLicenseData.fromParsedResultItem(parsedResultItem, ((BarcodeResultItem)refencesItem).getText());
                    if(driverLicenseData != null) {
                        //Prevent entering the next result callback, which may cause multiple page redirects
                        router.stopCapturing();
                        Intent intent = new Intent(MainActivity.this, ResultActivity.class);
                        intent.putExtra(EXTRA_DRIVER_LICENSE_DATA, driverLicenseData);
                        startActivity(intent);
                    } else {
                        Log.i(TAG, "onParsedResultsReceived: The parsed result is not a driver license data. Raw text: " + ((BarcodeResultItem)refencesItem).getText());
                    }
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        camera.open();

        //Passing "" to templateName means using the first template in the template file,
        //or you can directly use the specific template name "ReadID"
        router.startCapturing("", new CompletionListener() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "onSuccess called.");
            }

            @Override
            public void onFailure(int errorCode, String message) {
                runOnUiThread(() -> new AlertDialog.Builder(MainActivity.this)
                        .setTitle("StartCapturing Failed")
                        .setMessage("errorCode: " + errorCode + "\nerror Message: " + message)
                        .show());
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        camera.close();
        router.stopCapturing();
    }

}