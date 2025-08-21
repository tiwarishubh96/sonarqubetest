/**
 @author Veni Korapaty (veni.korapaty@sage.com)
 @date 23-Jan-2019
 @description controller will help pull the data from partner object and pass back to the aura componant.
 */

public without sharing class PartnerObjRelatedListController {

        public static final string OpportunityObjectType ='Opportunity';
        public static final string AccountObjectType ='Account';
        public static final string Success ='SUCCESS';
        public static final string Failed ='FAILED';
        public static final string CLASSNAME = 'PartnerObjRelatedListController';

        public class ReturnObject {
            String AccountToName;
            String OpportunityName;
            String Role;
            Boolean IsPrimary;
            Id Id;
            Id AccountToId;
            Id OppId;
        }

        @AuraEnabled
        public static String getSObjectType(Id recordId) {
            String recordObjectType = '';
            try {
                LogControl.push('getSObjectType', CLASSNAME);
                recordObjectType = recordId.getSobjectType().getDescribe().getName();
                return recordObjectType;
            }
            catch (Exception e) {
                LogControl.debugException(e);
                return recordObjectType;
            }
            finally {
                LogControl.pop();

            }

        }

        @AuraEnabled
        public static String getParentRecordId(Id recordId) {
           try{
            String recordObjectType = recordId.getSobjectType().getDescribe().getName();

            if (recordObjectType == OpportunityObjectType) {
                Opportunity opp = [select id, AccountId from Opportunity where id = :recordId];
                return opp.AccountId;
                }
                return null;
            }
            Catch (Exception e) {
            LogControl.debugException(e);
                return Failed;
             }
            finally {
                 LogControl.pop();

            }


        }

        @AuraEnabled
        public static String getPartners(Id recordId) {
           List<Partner> xas;
           String recordObjectType = '';

            try {
                LogControl.push('getPartners', CLASSNAME);
                recordObjectType = recordId.getSobjectType().getDescribe().getName();

                if (recordObjectType == OpportunityObjectType) {
                    Opportunity o = [select Account.Id from Opportunity where id = :recordId];
                    xas = [
                            select AccountToId, AccountTo.Name, IsPrimary, OpportunityId, Role, Opportunity.Name
                            from Partner
                            where OpportunityId = :recordId
                            and AccountFromId = :o.AccountId
                    ];
                }
                if (recordObjectType == AccountObjectType) {
                    xas = [
                            select AccountToId, AccountTo.Name, AccountFrom.Name, IsPrimary, Role,Opportunity.Name, OpportunityId
                            from Partner
                            where AccountFromId = :recordId
                    ];
                }

                List<ReturnObject>  lro = new List<ReturnObject>();
                for (SObject xa : xas) {
                    ReturnObject ro = new ReturnObject();
                    ro.Id = (id) xa.get('id');
                    ro.Role = (String) xa.get('role');
                    ro.IsPrimary = (Boolean) xa.get('isPrimary');
                    ro.AccountToName = String.valueOf(xa.getSObject('AccountTO').get('Name'));
                    ro.AccountToId = (id) xa.get('AccountToId');
                     if(xa.getSObject('Opportunity') != null)
                    {
                        ro.OpportunityName = String.valueOf(xa.getSObject('Opportunity').get('Name'));
                        ro.OppId=(id) xa.get('OpportunityId');

                    }
                    else
                    {
                        ro.OpportunityName = '';
                    }
                    lro.add(ro);
                }
                return JSON.serialize(lro);

            }
            catch(Exception e){
                LogControl.debugException(e);
                return Failed;
            }
            finally {
                LogControl.pop();

            }


      }

        @AuraEnabled
        public static String deletePartner(String recordId) {
            try {
                LogControl.push('deletePartner', CLASSNAME);
                Partner p = [select id from Partner where id = :recordId];
                delete p;
                return Success;
            }

            catch(Exception e){
                LogControl.debugException(e);
                return Failed;
            }

            finally {
                LogControl.pop();

            }
        }

      }