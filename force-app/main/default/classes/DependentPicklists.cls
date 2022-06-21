/**
 * Created by Matthew on 11/18/18.
 * See: https://salesforce.stackexchange.com/questions/214872/how-to-present-state-and-country-picklists-with-dependency-logic-in-a-lightning
 */

public class DependentPicklists {

    private static final String BASE_64_CHARS = ''
            + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            + 'abcdefghijklmnopqrstuvwxyz'
            + '0123456789+/';

    private class PicklistEntryBean {
        public Boolean active {get; set;}
        public String value {get; set;}
        public String label {get; set;} // added my matthew pomar
        public String validFor {get; set;}
    }

    private Map<String, Set<Integer>> cache;

    public Map<String, List<String>> controllingToDependentValues(SObjectField controlling, SObjectField dependent) {

/*        System.debug('here');*/

        Map<String, List<String>> results = new Map<String, List<String>>();

/*
        System.debug('here 2');

        System.debug(controlling != null);

        System.debug(dependent != null);
*/

        if (controlling != null && dependent != null) {

            cache = new Map<String, Set<Integer>>();

            List<String> controllingValues = new List<String>();


            for (PicklistEntry pe : controlling.getDescribe().getPicklistValues()) {
                if (pe.isActive()) {
                    results.put(pe.getValue(), new String[] {});
                    controllingValues.add(pe.getValue());
                    //System.debug(pe.getValue());
                }
            }

            for (PicklistEntryBean pe : picklistEntryBeans(dependent.getDescribe().getPicklistValues())) {
                if (pe.active) {
                    for (Integer index : validForToIndices(pe.validFor)) {
                        //results.get(controllingValues.get(index)).add(pe.value);

                        String x = (new SelectOption(pe.value, pe.label)).toJson();

                        results.get(controllingValues.get(index)).add(x);
                    }
                }
            }
        }

        return results;
    }

    private Set<Integer> validForToIndices(String validFor) {

        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();

            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1'); i >= 0; i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }

            cache.put(validFor, indices);
        }

        return indices;
    }

    private static String decimalToBinary(Integer val) {

        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    private static String base64ToBits(String validFor) {

        if (String.isEmpty(validFor)) return '';

        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE_64_CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }

    private static PicklistEntryBean[] picklistEntryBeans(List<PicklistEntry> pes) {

        return (List<PicklistEntryBean>) JSON.deserialize(JSON.serialize(pes), List<PicklistEntryBean>.class);
    }
}