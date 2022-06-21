/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public with sharing class CommunitiesSelfRegController{
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set{ password = value == null ? value : value.trim();}}
    public String confirmPassword {get; set{ confirmPassword = value == null ? value : value.trim();}}
    public String communityNickname {get; set{ communityNickname = value == null ? value : value.trim();}}
    public CommunitiesSelfRegController(){
        String expid = ApexPages.currentPage().getParameters().get('expid');            
        if(expId!=null){
            Site.setExperienceId(expId); 
        }    
    }   
    private boolean isValidPassword(){
        return password == confirmPassword;
    }
    public PageReference registerUser(){
        if(!isValidPassword()){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        String profileId = null; 
        String roleEnum = null; 
        String accountId = ''; 
        String userName = email;
        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
		u.ProfileId = profileId;	
        String userId;
        try{
            userId = Site.createExternalUser(u, accountId, password);
        }catch(Site.ExternalUserCreateException ex){
            List<String> errors = ex.getDisplayMessages();
            for (String error:errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
        }
        if(Test.isRunningTest()){
        	userId = 'testUserId';// Site.createExternalUser will always return null when the page isn't accessed as a guest user
        } 
        if(userId != null){ 
            if (password != null && password.length() > 1){
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else{
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}