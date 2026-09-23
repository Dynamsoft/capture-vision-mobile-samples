package com.dynamsoft.idextraction.model;

public enum EnumDocumentType {
    //MRZ
    MRTD_TD1_ID("MRTD_TD1_ID"),
    MRTD_TD2_ID("MRTD_TD2_ID"),
    MRTD_TD3_PASSPORT("MRTD_TD3_PASSPORT"),

    //DRIVER LICENSE
    AAMVA_DL_ID("AAMVA_DL_ID"),
    AAMVA_DL_ID_WITH_MAG_STRIPE("AAMVA_DL_ID_WITH_MAG_STRIPE"),
    SOUTH_AFRICA_DL("SOUTH_AFRICA_DL");

    private final String value;

    EnumDocumentType(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static boolean isMRZ(String docType) {
        return MRTD_TD1_ID.value.equals(docType) ||
                MRTD_TD2_ID.value.equals(docType) ||
                MRTD_TD3_PASSPORT.value.equals(docType);
    }

    public static boolean isDriverLicense(String docType) {
        return AAMVA_DL_ID.value.equals(docType) ||
                AAMVA_DL_ID_WITH_MAG_STRIPE.value.equals(docType) ||
                SOUTH_AFRICA_DL.value.equals(docType);
    }
}
