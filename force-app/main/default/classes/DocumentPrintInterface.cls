public interface DocumentPrintInterface {
    map<Id, List<Asset>> processDocumetPrints(Map<String, list<SObject>> mapUniquekeyAndObjects, Map<String, list<ECFMG_Print_Config__mdt>> mapuniquekeyAndMdts);
}