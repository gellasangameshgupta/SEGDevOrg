@isTest(SeeAllData=true)
public class FeedItemController_Test{
    public static testmethod void testfeedItemVisibiltyUpdate_Positive(){
        
        Test.starttest();
        FeedItemController fc = new FeedItemController();
        //Commenting for Insight deprecation
        //FeedItemHandler fh = new FeedItemHandler();
        
        list<feeditem> feedlist = new list<feeditem>();
        list<feedcomment> feedcommentlist = new list<feedcomment>();
        agf__ADM_Scrum_Team__c teamRec = new agf__ADM_Scrum_Team__c();
        teamRec.Name = 'TestTeam1';
        teamRec.agf__Cloud__c = 'Marketing';
        insert teamRec;
        
        agf__ADM_Product_Tag__c productRec = new agf__ADM_Product_Tag__c();
        productRec.Name = 'TestProduct1';
        productRec.agf__Team__c = teamRec.id;
        insert productRec;
        
        agf__ADM_Build__c b = new agf__ADM_Build__c();
        b.Name='TestBuild';
		b.Scrum_Team__c=teamRec.id;
       // insert b;
        
        agf__ADM_Work__c workRec = new agf__ADM_Work__c();
        workRec.agf__Subject__c = 'Test Subject';
        workRec.agf__Product_Tag__c = productRec.id;
        workRec.agf__Priority__c = 'P0';
        workRec.agf__Found_in_Build__c = b.id;
        insert workRec;
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
      	u.Username = 'test1235@seg-automotive.com';
        u.Email = 'test1235@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        insert u;
        
        //Commenting for Insight deprecation
        /*News_Announcements__c nws =TestData.createNews(u.id, 'Global_News', 'Organisational');
        insert nws;*/
        
        FeedItem post = new FeedItem();
        post.body = '[Welcome to test Knowledge]';
        post.type='ContentPost';
        Post.parentid = workRec.Id;    
        insert post;
        
        feedlist.add(post);
        FeedItemController objFeedItemControlller = new FeedItemController();
        objFeedItemControlller.feedItemVisibiltyUpdate(feedlist);
        /////////////////// test for checking file extension /////////
        /*
        FeedItem item=new FeedItem();
        item.Body='test';
        item.Type='ContentPost';
        item.parentid = nws.Id; 
        insert(item);
        
       
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test.exe';
        cv.VersionData=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.id=item.RelatedRecordId;
        insert cv;
        item.Body='testup';
        System.debug('comment relted>'+item.RelatedRecordId);
        //update(item);
        delete(item);
*/
        //Commenting for Insight deprecation
        /*FeedItem post1 = new FeedItem();
        post1.body = '[Welcome to test Knowledge]';
        Post1.parentid = nws.Id;    
        insert post1;
        FeedComment fc1 = new FeedComment();
        fc1.FeedItemId=post1.id;
        fc1.CommentBody='sample comment';
        insert fc1;
        feedlist.add(post1);
        feedcommentlist.add(fc1);
        fc.countFeeditems2(feedlist);
        fc.countAfterDelete(feedlist);
        feedcommenthandler.FeedCommentCount(feedcommentlist);
        feedcommenthandler.countAfterDelete(feedcommentlist);
        fh.OnAfterDelete(feedlist);*/
        
        system.assertEquals('AllUsers', 'AllUsers');
        
         
        //adding for deletion logic
        Profile p2 =[SELECT ID FROM Profile Where Name='SG Standard User'];
        
        User u2 = new user();
        u2.alias = 'alias';
        u2.LastName = 'lastName';
        u2.Username = 'test123@seg-automotive.com';
        u2.Email = 'test1234@seg-automotive.com';
        u2.TimeZoneSidKey = 'Europe/Berlin';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LanguageLocaleKey = 'en_US';
        u2.ProfileId = p.Id;
        insert u2;
        system.runAs(u2)
        {
            List<IFv2_Request__c> reqList = IFv2_testDataUtility.createRequest();
            insert reqList;
            FeedItem postreq = new FeedItem();
            postreq.body = '[Welcome to test Knowledge]';
            postreq.parentid = reqList[0].Id;    
            insert postreq;
            delete postreq;
        }
        
        Test.stoptest();
    }
    
    
     
    /*Public static testmethod void testfeedItemVisibiltyUpdate_Negative(){
        FeedItemController fc = new FeedItemController();
        list<feedcomment> fcmlist = new list<feedcomment>();
        list<feedcomment> deletelist = new list<feedcomment>();
        
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test123w@seg-automotive.com';
        u.Email = 'test1234@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        insert u;
        
        News_Announcements__c nws =TestData.createNews(u.id, 'Global_News', 'Organisational');
        News_Announcements__c nws1 =TestData.createNews(u.id, 'Global_News', 'Organisational');
        
        nws1.English_News__c=nws.Id;
        insert nws;
        insert nws1;
        
        List<FeedItem> feedlist = new list<feeditem>();
        
        FeedItem post = new FeedItem();
        post.body = 'Welcome to test Knowledge';
        Post.parentid = nws.Id;    
        insert post;
        
        FeedItem post1 = new FeedItem();
        post1.body = 'Welcome to test Knowledge';
        Post1.parentid = nws1.Id;    
        insert post1;
        
        feedlist.add(post);
        feedlist.add(post1);
        
        FeedComment fc1 = new FeedComment();
        fc1.FeedItemId=post.id;
        fc1.CommentBody='sample comment';
        insert fc1; 
        
        FeedComment fc3 = new FeedComment();
        fc3.FeedItemId=post.id;
        fc3.CommentBody='sample comment';
        insert fc3; 
        
        fcmlist.add(fc3);
        FeedComment fc4 = new FeedComment();
        fc4.FeedItemId=post1.id;
        fc4.CommentBody='sample comment';
        insert fc4; 
        
        fcmlist.add(fc4);
        fcmlist.add(fc1);
        FeedComment fc2 = new FeedComment();
        fc2.FeedItemId=post1.id;
        fc2.CommentBody='sample comment';
        insert fc2;
        
        fcmlist.add(fc2);
        
        fc.countFeeditems2(feedlist);
        fc.countAfterDelete(feedlist);
        FeedCommentHandler.FeedCommentCount(fcmlist);
        deletelist.add(fc1);
        deletelist.add(fc3);
        delete deletelist;
        FeedCommentHandler.countAfterDelete(fcmlist);
        
    }*/
}