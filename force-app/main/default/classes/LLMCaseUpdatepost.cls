/**
 *@Author : Manjusha Guthikonda
  @Description: Once the Case gets Resolved/Escalated/ Timed out in LLM this class will take care of updating the case 
  @last Modified On: 12/22/2020
**/
@RestResource(urlMapping='/limitlesscaseUpdate/*')
    global with sharing class LLMCaseUpdatepost {
        public static string TestPayload;
        @Httppost
            global static contactcasewrapper CaseUpdateLimitlesswrapper(){
            contactcasewrapper ccw = new contactcasewrapper();
                RestResponse res;
                string strReqBody;
                 
                if(system.test.isRunningTest()){
                    strReqBody = TestPayload;  
                }
                else{
                    RestRequest req = RestContext.request;
                    res = Restcontext.response;
                    res.addHeader('Content-Type', 'application/json');
                    strReqBody = req.requestBody.toString();
                }
                
                EntitlementServiceRequest ReqObj = (EntitlementServiceRequest)JSON.deserialize(strReqBody,EntitlementServiceRequest.class);
                List<Case> CaseUpdatelist = new List<Case>();
                List<Case> Caselist = new list<Case>();
                try{
                    if(ReqObj.tenantMsgId!= null){
                     Caselist = [Select Id, Owner.name FROM case where id = :ReqObj.tenantMsgId];
                    }
                    if(Caselist != null && !Caselist.isEmpty()){
                        for(Case c: Caselist){
                           if(ReqObj.msgState == 'Resolved'){
                              c.Status = 'Closed';
                              c.Status_Reason__c = 'Resolved';                     
                              CaseUpdatelist.add(c);
                              ccw.tenantMsgId = c.Id;
                              createPrivatecomment(ReqObj.tenantMsgId,ReqObj.body); 
                           }
                           if(ReqObj.msgState == 'Escalated' || ReqObj.msgState == 'timeout'){                            
                              c.OwnerId = Label.Case_UKI_Services_Queue;
                              CaseUpdatelist.add(c);
                              ccw.tenantMsgId = c.Id;
                              createPrivatecomment(ReqObj.tenantMsgId,ReqObj.body);
                           }
                           
                           
                        }
                        if (!CaseUpdatelist.isEmpty()) {
                           Update CaseUpdatelist;
                        }
                    }
                    
                }
                catch(Exception e){
                    if(res!=null){
                        res.addHeader('Content-Type', 'application/json');
                        res.statusCode = 500;   
                        string error = 'Case not found';
                    }   
                }   
                
                if(ccw.tenantMsgId != null){
                ccw.status = 'case Updated';
                ccw.statuscode = 201;
                }
                if(ccw.tenantMsgId == null){
                ccw.status = 'Case ID/msgState is missing in request';
                ccw.statuscode = 500;
                }
                 return ccw;
            }
            
            global static void createPrivatecomment(id Cid,string body){
            system.debug('Private commententered'+ body);
                Map<integer,string> stringmap = new Map<integer,string>();
                list<CaseComment> casecommentlist = new list<CaseComment>();
                
                integer abc = integer.valueof(Math.ceil(((Double)body.length())/3000));
                integer j = 0;
                for(integer i = 1; i<=abc; i++){
                   if(i==abc){
                     stringmap.put(i-1,body.substring(j,body.length()));
                   }
                   else{
                       stringmap.put(i-1,body.substring(j,j+3000));

                   }
                   j = j+ 3000;
                }
                
                for(integer k = 0; k< stringmap.size(); k++){
                 system.debug('insidestringmap'+ stringmap.size());
                    CaseComment cc = new CaseComment();  
                        cc.parentid = Cid;
                        cc.commentbody = stringmap.get(k);
                        casecommentlist.add(cc);
                }
                
                if(casecommentlist !=null && !casecommentlist.isEmpty()){
                    insert casecommentlist;
                }
                 
            
            }
            //wrapper for request body
            global class EntitlementServiceRequest{
                string tenantMsgId;
                string body;
                string msgState;       
            }
            
            //wrapper for response body
            global class contactcasewrapper{
                string status;
                integer statuscode;
                string tenantMsgId;
    }
            // "/services/apexrest/limitlesscaseUpdate/"
       
        }