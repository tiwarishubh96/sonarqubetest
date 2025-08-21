public with sharing class helpController {

    public string selectedTopic {get;set;}
    
    public PageReference renderDetail() {
        system.debug('renderDetail');
        topic= selectedTopic;
        init();
        return null;
    }


    public PageReference init() {
        system.debug('init');
        string qryHelp ='';
        HasAttachment = False;
        string trying = 'None';
        if (topic != null && articleID == null)
        {
            system.debug('init1');
            //search in the 2 article type      
            qryHelp = 'select id,title, summary, description__c, attachment_1__Name__s,attachment_1__Length__s, attachment_2__Name__s,attachment_2__Length__s,attachment_3__Name__s,attachment_3__Length__s from Product_Documentation__kav where title=\'' +topic + '\' and PublishStatus = \'online\' and Language = \'' + language + '\' ';
            try 
            {
                helpPagesPD = Database.query(qryHelp);               
                if (helpPagesPD.size()==1)
                {
                    showMain= True;
                    helpPagePD= helpPagesPD.get(0);
                    type = 'Product Documentation';
                    trying='PD';
                    checkAttachmentsPD(helpPagePD,null);
                    if (HasAttachment1 == true  || HasAttachment2 == true || HasAttachment3 == true) {HasAttachment = True;}
                }
            }
            catch (exception e){}
            if (trying == 'None')
            {                             
                system.debug('init-type==none');
                qryHelp = 'select id,title, summary, description__c,Cause__c, Resolution__c,attachment_1__Name__s,attachment_1__Length__s, attachment_2__Name__s,attachment_2__Length__s,attachment_3__Name__s,attachment_3__Length__s from Knowledge_Article__kav where title=\'' +topic + '\' and PublishStatus = \'online\' and Language = \'' + language + '\' ';
                try 
                {
                    helpPagesKA = Database.query(qryHelp);
                                    //test='bon';
                    if (helpPagesKA.size()==1)
                    {
                        helpPageKA= helpPagesKA.get(0);
                        type = 'Article';
                        showMain= True;
                        trying='KA';
                        checkAttachmentsPD(null,helpPageKA);
                        if (HasAttachment1 == true  || HasAttachment2 == true || HasAttachment3 == true) {HasAttachment = True;}
                    }
                }
                catch (exception e){}
            }
            
            
                
        } 
        else {
            // articleID != null           
            if (type =='Product Documentation')
            {
                system.debug('init type=product documentation' + articleID + language);
                qryHelp = 'select id,title, summary, description__c,attachment_1__Name__s,attachment_1__Length__s, attachment_2__Name__s,attachment_2__Length__s,attachment_3__Name__s,attachment_3__Length__s from Product_Documentation__kav where knowledgeArticleId=\'' +articleID + '\' and PublishStatus = \'online\' and Language = \'' + language + '\' ';
                try 
                {
                    helpPagesPD = Database.query(qryHelp);
                    if (helpPagesPD.size()==1)
                    {
                        showMain= True;
                        helpPagePD= helpPagesPD.get(0);
                        type = 'Product Documentation';
                        checkAttachmentsPD(helpPagePD,null);
                        if (HasAttachment1 == true  || HasAttachment2 == true || HasAttachment3 == true) {HasAttachment = True;}
                    }
                }
                catch (exception e){}
            } else if (type == 'Article')
            {
                system.debug('init type=article');
                qryHelp = 'select id,title, summary, description__c,cause__c, resolution__c,attachment_1__Name__s,attachment_1__Length__s, attachment_2__Name__s,attachment_2__Length__s,attachment_3__Name__s,attachment_3__Length__s from Knowledge_Article__kav where knowledgeArticleId=\'' +articleID + '\' and PublishStatus = \'online\' and Language = \'' + language + '\' ';
                try 
                {
                    helpPagesKA = Database.query(qryHelp);
                    if (helpPagesKA.size()==1)
                    {
                        showMain= True;
                        helpPageKA= helpPagesKA.get(0);
                        type = 'Article';
                        checkAttachmentsPD(null,helpPageKA);
                        if (HasAttachment1 == true  || HasAttachment2 == true || HasAttachment3 == true) {HasAttachment = True;}
                    }
                }
                catch (exception e){}
            } 
        }

        return null;
    }
    
    Private  void checkAttachmentsPD(Product_Documentation__kav PD, Knowledge_Article__kav KA){
        if (PD != null) {
            if (PD.Attachment_1__Length__s >0) {HasAttachment1 = true;}
            if (PD.Attachment_2__Length__s >0) {HasAttachment2 = true;}
            if (PD.Attachment_3__Length__s >0) {HasAttachment3 = true;}
        }
        if (KA != null) {
            if (KA.Attachment_1__Length__s >0) {HasAttachment1 = true;}
            if (KA.Attachment_2__Length__s >0) {HasAttachment2 = true;}
            if (KA.Attachment_3__Length__s >0) {HasAttachment3 = true;}
        }
   }

    //Page Size
    private Static Final Integer PAGE_NUMBER = 10;
    public integer pageNumber {get;set;}
    private string topic;
    public string type {get;set;}
    private string showHeaderTemp;
    public string language {get;set;}
    public boolean showHeader {get;set;}
    public string articleID {get;set;}
    Public boolean showMain {get;set;}
    public string test {get;set;}
    public boolean HasAttachment {get;set;}
    public boolean HasAttachment1 {get;set;}
    public boolean HasAttachment2 {get;set;}
    public boolean HasAttachment3 {get;set;}

    
    
    public Product_Documentation__kav helpPagePD {get;set;}
    private list<Product_Documentation__kav> helpPagesPD;
    
    public Knowledge_Article__kav helpPageKA {get;set;}
    private list<Knowledge_Article__kav> helpPagesKA;
    
    //Search String used in ArticleList tag
    public String searchstring { 
        get;
        set{
            if (value != null) {
                searchstring=string.escapeSingleQuotes(value);               
            }  else {
                searchString = null;
            }
        }
    }    
   
    public helpController() {
        system.debug('helpController');
            showheader= True;
            showMain= True;
            topic= ApexPages.currentPage().getParameters().get('topic');
            if (topic != null) {topic = string.escapeSingleQuotes(topic);}
            type= ApexPages.currentPage().getParameters().get('type');
            if (type != null) {type = string.escapeSingleQuotes(type);}
            language= ApexPages.currentPage().getParameters().get('language');
            if (language != null) {language = string.escapeSingleQuotes(language);}
            articleID= ApexPages.currentPage().getParameters().get('id');
            if (articleID != null) {articleID = string.escapeSingleQuotes(articleID);}
            searchString= ApexPages.currentPage().getParameters().get('search');
            if (searchString != null) {searchString = string.escapeSingleQuotes(searchString);}
            showHeaderTemp = ApexPages.currentPage().getParameters().get('showHeader');
            if (showHeaderTemp != null) { showHeaderTemp = string.escapeSingleQuotes(showHeaderTemp);}
            if (Topic == null && articleID== null) {
                test='pas bon';
                showMain=False;
            }
            if (showHeaderTemp== 'false') { 
                showHeader = False;
            }
            if (language == null|| language == '') { language='en_US';} //to solve no language
            if (searchstring == null) {searchstring = topic;}
            String qryString = 'SELECT Id,title, UrlName, LastPublishedDate,LastModifiedById,ArticleType FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + language + '\' )';
            List<KnowledgeArticleVersion> articleList= Database.query(qryString);
            maxSize = articleList.size(); 
            pageNumber= PAGE_NUMBER;
            currentPage = 1; 
            maxPage = math.ceil(decimal.valueOf(MaxSize).divide(PAGE_NUMBER,1)).intValue(); 
            FirstArticle = 1;
            if (maxSize < PAGE_NUMBER) {
                LastArticle = maxSize;
            } else {
                LastArticle =PAGE_NUMBER;
            }
          
    }
    
    // Search for a text inside All exposed KB Articles
    public PageReference searchArticle() {
        if (searchString.length() >1) {
            string searchquery ='FIND \''+searchString +'\' RETURNING KnowledgeArticleVersion (Id WHERE PublishStatus=\'online\' AND Language= \'' +language+ '\' )';
            system.debug('searchquery: '+searchquery);
            List<List<sObject>> searchList = search.query(searchquery);
            maxSize = searchList.get(0).size(); 
                pageNumber= PAGE_NUMBER;
                currentPage = 1; 
                maxPage = math.ceil(decimal.valueOf(MaxSize).divide(PAGE_NUMBER,1)).intValue(); 
                FirstArticle = 1;
                if (maxSize < PAGE_NUMBER) {
                    LastArticle = maxSize;
                } else {
                    LastArticle =PAGE_NUMBER;
                }
        }
        return null;
    }
    
    //load a selected article 
    
    Public PageReference LoadArticle(){
        articleID=Apexpages.currentPage().getParameters().get('ID');
        return null;
    }
    //Keeps track of current page & max size of article list
    public integer maxSize {get;set;}
    public integer CurrentPage {get;set;}
    public integer MaxPage {get;set;}
    public integer FirstArticle {get;set;}
    public integer LastArticle {get;set;}


    // Returns whether we need to see previous button or not
    public boolean getPrevRequired() {
        return currentPage > 1;
    }
    // Returns whether we need to see next button or not
    public boolean getNextRequired() {
        return currentPage * PAGE_NUMBER < maxSize;
    }
    //Returns current page number
    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }
    //action for next click
    public PageReference next() {
        if(maxSize > this.currentPage * PAGE_NUMBER) {
            FirstArticle = (currentPage *PAGE_NUMBER) + 1;
            this.currentPage = this.currentPage + 1;
             if (maxSize < CurrentPage*PAGE_NUMBER) {
                 LastArticle = maxSize;
             } else {
                 LastArticle = CurrentPage *PAGE_NUMBER;
             }
        }
    return null;
    }
    //action for previous click
    public PageReference previous() {
        //Building a Search Page with Visualforce Tags Add a Search Field to the Visualforce Article Search page
        if(this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            FirstArticle = (currentPage-1)*PAGE_NUMBER+1;
            if (maxSize < CurrentPage*PAGE_NUMBER) {
                 LastArticle = maxSize;
             } else {
                 LastArticle = CurrentPage *PAGE_NUMBER;
             }
        }
        return null;
    }
    //action for First click
    public PageReference first() {
        //Building a Search Page with Visualforce Tags Add a Search Field to the Visualforce Article Search page
        if(this.currentPage > 1) {
            this.currentPage = 1;
            FirstArticle = 1;
            if (maxSize < CurrentPage*PAGE_NUMBER) {
                 LastArticle = maxSize;
             } else {
                 LastArticle = CurrentPage *PAGE_NUMBER;
             }
        }
        return null;
    }
    //action for Last click
    public PageReference last() {
        if(maxSize > this.currentPage * PAGE_NUMBER) {
            FirstArticle = ((maxPage-1)*PAGE_NUMBER) + 1;
            this.currentPage = maxPage;
            LastArticle = maxSize;
        }
    return null;
    }
    
    
    
}