public class CustomerCommunityEmailLandingController {
public String language{get;set;}
    public String nameOfUser{get;set;}
    private EmailTemplate template;
    public String emailbody;
   
    
    public String getEmailbody() {
       
        if(language!=null) {
            if(language.equals('en')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community : Welcome Email Sage Customer Community EN'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else if(language.equals('fr')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community : Welcome Email Sage Customer Community FR'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else if(language.equals('es')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community : Welcome Email Sage Customer Community ES'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else if(language.equals('de')) {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community : Welcome Email Sage Customer Community DE'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
            else {
                template = [select Id,HtmlValue from EmailTemplate where Name='Community : Welcome Email Sage Customer Community EN'];
                emailbody=template.HtmlValue;
                emailbody=emailbody.replace('{!Receiving_User.Name}', nameOfUser);
                return emailbody;
            }
        }
        else 
            return null;
    }
}