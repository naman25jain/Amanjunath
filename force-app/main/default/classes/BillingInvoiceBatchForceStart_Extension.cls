public with sharing class BillingInvoiceBatchForceStart_Extension {
    public BillingInvoiceBatchForceStart_Extension(ApexPages.StandardController controller) {

    }

    public static void forceStartBatch() {
        Database.executeBatch(new BillingInvoiceMonthlyBatch());
    }
}