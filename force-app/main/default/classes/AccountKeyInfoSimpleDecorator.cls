/**
 * AbstractKeyInfoDecorator 
 * Abstract class holding common method for Decorators
 */
public with sharing class AccountKeyInfoSimpleDecorator {
    
   Map<String, Integer> cardDefinitions = new Map<String,Integer>();

    Map<String, Integer> typePriorities = new Map<String,Integer>();
    

    static final String CANNED_RESPONSE = Label.PreSummaryResponse;

    public AccountKeyInfoSimpleDecorator() {

        //Holds a map of card order and what category of message each can contain
        cardDefinitions.put(AccountKIBaseSvc.PASSWORD_TYPE,1);
        cardDefinitions.put(AccountKIBaseSvc.CREDIT_TYPE,1);
        cardDefinitions.put(AccountKIBaseSvc.EXPORT_TYPE,1);
        cardDefinitions.put(AccountKIBaseSvc.OTHER_TYPE,1);
        cardDefinitions.put(AccountKIBaseSvc.PARTNER_TYPE,1);
        cardDefinitions.put(AccountKIBaseSvc.PROMPT_TYPE,2);
        cardDefinitions.put(AccountKIBaseSvc.COMPLAINT_TYPE,2);
        cardDefinitions.put(AccountKIBaseSvc.INCIDENT_TYPE,2);

    }


    /**
     * groupMessagesByHeadline 
     * @description  Groups a list of KeyInformation messages by their 'Headline'
     * @param  keyInfos keyInfos description
     * @return A map for headline -> List of messages
     */
    public Map<String, List<AccountKeyInfoWrapper>>  groupMessagesByHeadline(List<AccountKeyInfoWrapper> keyInfos){
        keyInfos.sort();
        Map<String, List<AccountKeyInfoWrapper>> messagesByHeadline = new Map<String, List<AccountKeyInfoWrapper>> ();

        for(AccountKeyInfoWrapper wrap:keyInfos){
            if(messagesByHeadline.containsKey(wrap.headline)){
                messagesByHeadline.get(wrap.headline).add(wrap);
            }else{
                messagesByHeadline.put(wrap.headline,new AccountKeyInfoWrapper[]{wrap});
            }
        }
        return messagesByHeadline;
    }

    
    /**
     * groupMessagesByCard 
     * @description Sorts a list of messages (grouped by headline) and assigns them to cards for the UI 
     * @return   A Map of card->Headline->messages
     */
    public Map<Integer, Map<String,List<AccountKeyInfoWrapper>>> groupMessagesByCard(Map<String, List<AccountKeyInfoWrapper>>  keyInfos){
        Map<Integer, Map<String,List<AccountKeyInfoWrapper>>> cardsAndMessages = new Map<Integer, Map<String,List<AccountKeyInfoWrapper>>>();
        for(String headline:keyInfos.keySet()){
            Integer card = cardDefinitions.get(headline);
            //put the messages (by type on the card)
            if(cardsAndMessages.containsKey(card)){
                cardsAndMessages.get(card).put(headline,keyInfos.get(headline));
            }
            else{
                Map<String, List<AccountKeyInfoWrapper>> msgs = new Map<String, List<AccountKeyInfoWrapper>>();
                msgs.put(headline,keyInfos.get(headline));
                cardsAndMessages.put(card,msgs);
            }
        }
        return cardsAndMessages;
        
    }

    public List<AccountKeyInfoWrapper> decorate(List<AccountKeyInfoWrapper> keyInfos){
        Map<Integer,Map<String,List<AccountKeyInfoWrapper>>> cardsAndMessages = groupMessagesByCard(groupMessagesByHeadline(keyInfos));
        //our decorated cards (for this decorator) dumbs down the messages for the cards
        List<AccountKeyInfoWrapper> cardWrappers = new List<AccountKeyInfoWrapper>();
        for(Integer card:cardsAndMessages.keySet()){
            Map<String,List<AccountKeyInfoWrapper>> headlinesAndMessages = cardsAndMessages.get(card);
            AccountKeyInfoWrapper cardInfo = new AccountKeyInfoWrapper();
            cardInfo.priority = card;
            if(card == 1){
                cardInfo.headline = Label.Card1Headline;
            }
            if(card == 2){
                cardInfo.headline = Label.Card2Headline;
            }
            List<String> cardMessages = new List<String>();
            for(String headline:headlinesAndMessages.keySet()){
                List<AccountKeyInfoWrapper> typeMessages = headlinesAndMessages.get(headline);
                cardMessages.add(format(typeMessages,headline));
            }
            cardInfo.dataItems = cardMessages;
            cardWrappers.add(cardInfo);             
        }
        return cardWrappers;
    }


    public String format(List<AccountKeyInfoWrapper> keyInfos, String headline){
        String formattedMessage;
        if(headline.equals(AccountKIBaseSvc.PASSWORD_TYPE)){
            formattedMessage = formatAsElements(keyInfos,Label.Password);
        }
        if(headline.equals(AccountKIBaseSvc.CREDIT_TYPE)){
            formattedMessage = formatAsElements(keyInfos,Label.CreditScore);
        } 
        if(headline.equals(AccountKIBaseSvc.EXPORT_TYPE)){
            formattedMessage = formatAsElements(keyInfos,Label.ExportCustomer);
        }      
        if(headline.equals(AccountKIBaseSvc.PARTNER_TYPE)){
            formattedMessage = formatAsSummary(keyInfos,CANNED_RESPONSE + ' '+ Label.Partner);
        }                 
        if(headline.equals(AccountKIBaseSvc.OTHER_TYPE)){
            formattedMessage = formatAsSummary(keyInfos,CANNED_RESPONSE + ' '+  Label.OtherItems);
        } 
        if(headline.equals(AccountKIBaseSvc.PROMPT_TYPE)){
            formattedMessage = formatAsSummary(keyInfos,CANNED_RESPONSE + ' '+  Label.Prompts);
        } 
        if(headline.equals(AccountKIBaseSvc.COMPLAINT_TYPE)){
            formattedMessage = formatAsSummary(keyInfos,CANNED_RESPONSE + ' '+  Label.Complaints);
        }     
        if(headline.equals(AccountKIBaseSvc.INCIDENT_TYPE)){
            formattedMessage = formatAsSummary(keyInfos,CANNED_RESPONSE + ' '+  Label.Incidents);
        } 
        return formattedMessage;
    }    

    /**
     * formatAsSummary if messages are present, returns the 'canned' style message
     * @param  keyInfo keyInfo description
     * @param  message message description
     * @return         return description
     */
    public String formatAsSummary(List<AccountKeyInfoWrapper> keyInfo,String message){
        
        Boolean hasMessages = false;
        if(keyInfo != null && keyInfo.size() > 0){
            for(AccountKeyInfoWrapper wrapper:keyInfo){
                if(wrapper.dataItems != null && wrapper.dataItems.size() > 0){
                    hasMessages = true;
                    break;
                }
            }
        }
        if(hasMessages){
            return message;
        }
        return null;
    }   

    /**
     * formatAsElements Formats a list of KeyInformation Messages out into their individual elements
     * @param  keyInfo  keyInfo description
     * @param  headline headline description
     * @return          return description
     */
    public String formatAsElements(List<AccountKeyInfoWrapper> keyInfo,String headline){
        String message = '';
    
        if(keyInfo != null && keyInfo.size() > 0 ){
            for(AccountKeyInfoWrapper wrapper:keyInfo){
                if(wrapper.dataItems != null && wrapper.dataItems.size() > 0){
                    for(String dataElement:wrapper.dataItems){
                        message += headline + ' : ' + dataElement + '\n';
                    }
                }
            }
        }
        return message;
    }

}