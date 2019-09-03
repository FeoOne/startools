package com.feosoftware.startools.billing;

import com.android.billingclient.api.SkuDetails;

final class Product {
    static final int CONSUMABLE_TYPE = 1;
    static final int NONCONSUMABLE_TYPE = 2;
    static final int SUBSCRIPTION_TYPE = 4;

    private String _identifier;
    private int _type;

    private SkuDetails _details;

    Product(String identifier, int type) {
        _identifier = identifier;
        _type = type;

        _details = null;
    }

    String getIdentifier() {
        return _identifier;
    }

    int getType() {
        return _type;
    }

    SkuDetails getDetails() {
        return _details;
    }

    void setDetails(SkuDetails details) {
        _details = details;
    }
}
