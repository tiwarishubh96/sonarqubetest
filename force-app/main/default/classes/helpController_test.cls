@isTest
private class helpController_test {
    static testMethod void checkHelp(){
        Product_Documentation__kav newArticleType1 = new Product_Documentation__kav();
        newArticleType1.title = 'test Title1';
        newArticleType1.Description__c = 'test Description';
        newArticleType1.IsVisibleInPkb = true;
        newArticleType1.Language = 'en_US';
        newArticleType1.UrlName = 'test-Title1'; 
        insert newArticleType1;
        
        Knowledge_Article__kav newArticleType2 = new Knowledge_Article__kav();
        newArticleType2.title = 'test Title2';
        newArticleType2.Description__c = 'test Description';
        newArticleType2.cause__c = 'test cause';
        newArticleType2.resolution__c = 'test resolution';
        newArticleType2.IsVisibleInPkb = true;
        newArticleType2.Language = 'en_US';
        newArticleType2.UrlName = 'test-Title2'; 
        insert newArticleType2;
        
        // Get the KnowledgeArticleIds
        Product_Documentation__kav insertedTest1 = [Select KnowledgeArticleId from Product_Documentation__kav where ID = :newArticleType1.Id];
        Knowledge_Article__kav insertedTest2 = [Select KnowledgeArticleId from Knowledge_Article__kav where ID = :newArticleType2.Id];
        system.assert( insertedTest1.KnowledgeArticleId != null);
        // Publish
        KbManagement.PublishingService.publishArticle(insertedTest1.KnowledgeArticleId, true); 
        KbManagement.PublishingService.publishArticle(insertedTest2.KnowledgeArticleId, true); 
        
        // calling the VF with PB type
        PageReference pageRef = Page.help;
        Test.setCurrentPage(pageRef);   
        apexPages.currentPage().getParameters().put('topic','test title1');
        apexPages.currentPage().getParameters().put('language','en_US');
        helpController controller = new helpController();
        controller.init();
        system.assert(controller.language=='en_US');
        system.assert(controller.showMain == True);
        system.assert(controller.helpPagePD.title == 'test title1');
        apexPages.currentPage().getParameters().put('topic',null);
        apexPages.currentPage().getParameters().put('id',insertedTest1.KnowledgeArticleId);
        controller = new helpController();
        controller.init();
        system.assert(controller.articleID == insertedTest1.KnowledgeArticleId);
        system.assert(Controller.articleID != null);
        apexPages.currentPage().getParameters().put('showHeader','false');
        apexPages.currentPage().getParameters().put('topic',null);
        apexPages.currentPage().getParameters().put('id',null);
        controller = new helpController();
        system.assert(controller.showMain == False); 
        controller.init();
        controller.articleID = newArticleType1.Id;
        controller.init();
        controller.helpPagePD = newArticleType1;
        controller.searchstring='test';
        controller.searchArticle();
        controller.LoadArticle();
        controller.CurrentPage=2;
        controller.last();
        controller.first();        
        controller.next();
        controller.previous();        
        controller.getCurrentPageNumber();
        controller.getNextRequired();
        controller.getPrevRequired(); 
        
        //checking for KA type
        apexPages.currentPage().getParameters().put('topic','test title2');
        controller = new helpController();
        controller.init();
        system.assert(controller.language=='en_US');
        system.assert(controller.showMain == True);
        system.assert(controller.helpPageKA.title == 'test title2');
        
        //checking for articleID for PD
        apexPages.currentPage().getParameters().put('topic',null);
        apexPages.currentPage().getParameters().put('id',insertedTest1.knowledgeArticleId);
        apexPages.currentPage().getParameters().put('language','en_US');
        apexPages.currentPage().getParameters().put('type','Product Documentation');
        controller = new helpController();
        controller.init();
        system.assert(controller.language=='en_US');
        system.assert(controller.showMain == True);
        system.assert(controller.type == 'Product Documentation');
        system.assert(controller.helpPagePD.title == 'test title1');
        
        //checking for articleID for KA
        apexPages.currentPage().getParameters().put('topic',null);
        apexPages.currentPage().getParameters().put('id',insertedTest2.knowledgeArticleId);
        apexPages.currentPage().getParameters().put('language','en_US');
        apexPages.currentPage().getParameters().put('type','Article');
        controller = new helpController();
        controller.init();
        system.assert(controller.language=='en_US');
        system.assert(controller.showMain == True);
        system.assert(controller.type == 'Article');
        
        //checking for a click
        controller.selectedTopic='';
        controller.renderDetail();
        system.assert(controller.language=='en_US');
        
    }
    
    static testMethod void checkHelpTestPaging(){
    	Product_Documentation__kav newArticleType1 = new Product_Documentation__kav();
        newArticleType1.title = 'test Title1';
        newArticleType1.Description__c = 'test Description';
        newArticleType1.IsVisibleInPkb = true;
        newArticleType1.Language = 'en_US';
        newArticleType1.UrlName = 'test-Title1'; 
        insert newArticleType1;
        
        Knowledge_Article__kav newArticleType2 = new Knowledge_Article__kav();
        newArticleType2.title = 'test Title1';
        newArticleType2.Description__c = 'test Description';
        newArticleType2.cause__c = 'test cause';
        newArticleType2.resolution__c = 'test resolution';
        newArticleType2.IsVisibleInPkb = true;
        newArticleType2.Language = 'en_US';
        newArticleType2.UrlName = 'test-Title2'; 
        insert newArticleType2;
        
        // Get the KnowledgeArticleIds
        Product_Documentation__kav insertedTest1 = [Select KnowledgeArticleId from Product_Documentation__kav where ID = :newArticleType1.Id];
        Knowledge_Article__kav insertedTest2 = [Select KnowledgeArticleId from Knowledge_Article__kav where ID = :newArticleType2.Id];
        system.assert( insertedTest1.KnowledgeArticleId != null);
        // Publish
        KbManagement.PublishingService.publishArticle(insertedTest1.KnowledgeArticleId, true); 
        KbManagement.PublishingService.publishArticle(insertedTest2.KnowledgeArticleId, true);
        
        // calling the VF with PB type
        PageReference pageRef = Page.help;
        Test.setCurrentPage(pageRef);   
        apexPages.currentPage().getParameters().put('topic','test title1');
        apexPages.currentPage().getParameters().put('language','en_US');
        helpController controller = new helpController();
        
        controller.init();
        controller.maxSize =1;
        controller.currentPage=0;
        controller.next();
        system.assertEquals(1, controller.currentPage, 'First page should be displayed');
        controller.currentPage=2;
        controller.previous();
        system.assertEquals(1, controller.currentPage, 'First page should be displayed');
        controller.currentPage=0;
        controller.last();
        system.assertEquals(1, controller.currentPage, 'First page should be displayed');
        controller.first();
        system.assertEquals(1, controller.currentPage, 'First page should be displayed');
        
        	
    }
    
}