//Wraps CaseService.massUpdateCaseAssetsAndAffirmations as an invocable method that can be used in Flows.
global class UpdateCaseAssetsAndAffirmationsInvocable{
    @InvocableMethod
    public static List<String> execute(List<List<String>> args){
        // check parameters
        if(args.size()!=1){
            throw new InvalidParameterException('Size of args must be 1.');
        }
        if(args[0].size()!=3){
            throw new InvalidParameterException('Size of args[0] must be 3.');
        }
        try{
            CaseService.massUpdateCaseAssetsAndAffirmations(args[0][0], args[0][1], args[0][2]);
            return new List<String>();
        }
        catch(Exception ex){
            List<String> results = new List<String>();
            results.add(ex.getMessage());
            return results;
        }
    }
}