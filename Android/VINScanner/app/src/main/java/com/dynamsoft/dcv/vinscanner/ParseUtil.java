package com.dynamsoft.dcv.vinscanner;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.dcp.ParsedResultItem;

import java.util.ArrayList;

@SuppressWarnings("UnusedReturnValue")
public class ParseUtil {

    @Nullable
    public static String[] parsedItemToDisplayStrings(@Nullable ParsedResultItem item) {
        if (item == null || item.getParsedFields().isEmpty()) {
            return null;
        }
        ArrayList<String> list = new ArrayList<>();
        if (item.getCodeType().equals("VIN")) {
            addFieldToStringList(list, item, "VIN String", "vinString");
            addFieldToStringList(list, item, "WMI", "WMI");
            addFieldToStringList(list, item, "Region", "region");
            addFieldToStringList(list, item, "VDS", "VDS");
            addFieldToStringList(list, item, "Check Digit", "checkDigit");
            addFieldToStringList(list, item, "Model Year", "modelYear");
            addFieldToStringList(list, item, "Manufacturer plant", "plantCode");
            addFieldToStringList(list, item, "Serial Number", "serialNumber");
        } else {
            return null;
        }
        return list.toArray(new String[0]);
    }

    /**
     * Adds the display message of a specified field from a parsed result item to the string list.
     *
     * @param list       the string list to add the field value to
     * @param item       the parsed result item to get the field value from
     * @param displayKey the display key to use for the field value
     * @param fieldName  the name of the field to get the value from
     * @return true if the field value was added to the list, false otherwise
     */
    private static boolean addFieldToStringList(ArrayList<String> list, @NonNull ParsedResultItem item, String displayKey, String fieldName) {
        String fieldValue = item.getFieldValue(fieldName);
        if (fieldValue != null) {
            list.add(String.format("%s: %s", displayKey, fieldValue));
            return true;
        } else {
            return false;
        }
    }

}
