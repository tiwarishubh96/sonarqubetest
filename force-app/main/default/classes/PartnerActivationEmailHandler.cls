global class PartnerActivationEmailHandler {
    @InvocableMethod
    global static void ActivationEmailHandler(List<id> accountId)   
    {
        
system.debug('accountId :'+accountId);
        list<account> acn=[select name,(select id,invite_user_to_Partner_Community__c,EmailBouncedDate,EmailBouncedReason from contacts) from Account where id in: accountId];
        list<contact> listb=new list<contact>();
        system.debug('acn :'+acn);
        for(account a:acn){
              system.debug('a :'+a);
            for ( contact c :a.contacts) {
                  system.debug('EmailBouncedDate :'+c.EmailBouncedDate);
                 system.debug('EmailBouncedReason :'+c.EmailBouncedReason);
                if(c.Invite_user_to_Partner_Community__c == false && c.EmailBouncedDate==null && c.EmailBouncedReason == null ){
                   
                    c.Invite_user_to_Partner_Community__c=true;
                    listb.add(c);
                        system.debug('listb :'+listb);
                }
            }
        }
        update listb;
    }
}