public class CommunityEmailLandingController {
    public String language{get;set;}
    public String nameOfUser{get;set;}
    private EmailTemplate template;
    public String emailbody;
    
    public String getEmailbody() {
        if(language!=null) {
            if(language.equals('en_US')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community: Welcome Email'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else if(language.equals('fr_CA')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community: Welcome Email FR CA'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community: Welcome Email'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
        }
        else 
            return null;
    }
}