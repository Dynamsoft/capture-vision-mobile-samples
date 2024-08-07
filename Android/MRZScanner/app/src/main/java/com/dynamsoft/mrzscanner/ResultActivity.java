package com.dynamsoft.mrzscanner;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.content.res.ResourcesCompat;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dynamsoft.dcp.ParsedResultItem;

import java.util.HashMap;

/**
 * @author dynamsoft
 */
public class ResultActivity extends AppCompatActivity {
	private LinearLayout content;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_result);
		TextView nameView = findViewById(R.id.tv_name);
		TextView secView = findViewById(R.id.tv_second_line);
		findViewById(R.id.iv_back).setOnClickListener((v) -> {
			finish();
		});
		content = findViewById(R.id.ll_content);
		HashMap<String, String> properties = (HashMap<String, String>) getIntent().
				getSerializableExtra("labelMap");
		if (properties != null) {
			String name = properties.get("Name");
			String sexAdAge = "";
			if(properties.get("Sex") !=null){
				sexAdAge = Character.toUpperCase(properties.get("Sex").charAt(0)) + properties.get("Sex").substring(1) + ", Age: " + properties.get("Age");
			}
			nameView.setText(name);
			secView.setText(sexAdAge);
			fillViews(properties);
		}

	}

	@NonNull
	private View childView(String label, String labelText) {
		LinearLayout layout = new LinearLayout(this);
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);
		params.setMargins(0, 30, 0, 0);
		layout.setLayoutParams(params);
		layout.setOrientation(LinearLayout.VERTICAL);
		TextView labelView = new TextView(this);
		labelView.setPadding(0, 30, 0, 0);
		labelView.setTextColor(ContextCompat.getColor(this, R.color.dy_grey_AA));
		labelView.setTextSize(16);
		labelView.setText(label);
		TextView textView = new TextView(this);
		textView.setTextSize(16);
		textView.setTextColor(Color.WHITE);
		textView.setText(labelText);
		layout.addView(labelView);
		layout.addView(textView);
		return layout;
	}

	private void fillViews(HashMap<String, String> properties) {
		content.addView(childView("Document Type:", properties.get("Document Type")));
		content.addView(childView("Document Number:", properties.get("Document Number")));
		content.addView(childView("Issuing State:", properties.get("Issuing State")));
		content.addView(childView("Nationality:", properties.get("Nationality")));
		content.addView(childView("Date of Birth(YYYY-MM-DD):", properties.get("Date of Birth(YYYY-MM-DD)")));
		content.addView(childView("Date of Expiry(YYYY-MM-DD):", properties.get("Date of Expiry(YYYY-MM-DD)")));
//		content.addView(childView("Personal Number:", properties.get("Personal Number")));
//		content.addView(childView("Primary Identifier(s):", properties.get("Primary Identifier(s)")));
//		content.addView(childView("Secondary Identifier(s):", properties.get("Secondary Identifier(s)")));
	}
}