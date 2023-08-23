@isTest(SeeAllData=true)
public class FeedCommentHandlerTest {
    
    public static testmethod void testfeedCommentTest1(){
        
        Test.starttest();
        
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
        
        List<IFv2_Request__c> reqList = IFv2_testDataUtility.createRequest();
        insert reqList ;
        
        //Commenting for Insight deprecation
        /*List<News_Announcements__c> insertNews = new List<News_Announcements__c>();
        
        News_Announcements__c nws =TestData.createNews(u.id, 'Global_News', 'Organisational');
        insertNews.add(nws);
        News_Announcements__c nws1 =TestData.createNews(u.id, 'Global_News', 'Organisational');
        insertNews.add(nws1);
        
        nws1.English_News__c=nws.Id;
        
        insert insertNews;*/
        
        List<FeedItem> feedlist = new list<feeditem>();
        List<FeedComment> feedCommentlist = new list<FeedComment>();
        
        FeedItem post = new FeedItem();
        post.body = 'Welcome to test Knowledge';
        Post.parentid = reqList[0].Id;
        feedlist.add(post);
        
    
        FeedItem post1 = new FeedItem();
        post1.body = 'Welcome to test Knowledge';
        Post1.parentid = reqList[0].Id;
        feedlist.add(post1);
        
        insert feedlist;
        ///////////
        //
         FeedComment comment=new FeedComment();
        comment.CommentBody='test';
        comment.CommentType='ContentComment';
        comment.FeedItemId=feedlist[0].id;
        //comment.RelatedRecordId=feedlist[0].id;
        insert(comment);
        
       
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test.txt';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.id=comment.RelatedRecordId;
        insert cv;
        comment.CommentBody='testup';
        System.debug('comment relted>'+comment.RelatedRecordId);
        update(comment);
        
        
        FeedComment fc1 = new FeedComment();
        fc1.FeedItemId=post.id;
        fc1.CommentBody='sample comment';
        feedCommentlist.add(fc1);
        
        FeedComment fc2 = new FeedComment();
        fc2.FeedItemId=post1.id;
        fc2.CommentBody='sample comment';
        feedCommentlist.add(fc2);
        
        FeedComment fc3 = new FeedComment();
        fc3.FeedItemId=post.id;
        fc3.CommentBody='sample comment';
        feedCommentlist.add(fc3);
        
        FeedComment fc4 = new FeedComment();
        fc4.FeedItemId=post1.id;
        fc4.CommentBody='sample comment';
        feedCommentlist.add(fc4);
        
        insert feedCommentlist;
        
        list<feedcomment> deletelist = new list<feedcomment>();
        
        //Commenting for Insight deprecation
        //FeedCommentHandler.FeedCommentCount(feedCommentlist);
        deletelist.add(fc1);
        deletelist.add(fc3);
        delete deletelist;
        //Commenting for Insight deprecation
        //FeedCommentHandler.countAfterDelete(feedCommentlist);
        
        Test.stoptest();
    }


}