global class CancelCaseInvocable {
    @InvocableMethod
    public static List<String> cancelCaseFromFlow(List<List<String>> args) {
        List<String> valueList = args[0];
        if(valueList[0] == null){
            throw new CommunityException('Must provide a case id for the first argument.');
        }
        if(valueList[1] == null){
            throw new CommunityException('Must provide a reason for the second argument.');
        }
        if(valueList[3] == null){
            throw new CommunityException('Must specify either Agent or Analyst.');
        }
        List<String> results = new List<String>();
        results.add(ApplicantMyProfileController.cancelCase(valueList[0], valueList[1], valueList[2], valueList[3]));
        return results;
    }
}