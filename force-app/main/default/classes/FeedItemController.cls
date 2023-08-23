public class FeedItemController{
    public void feedItemVisibiltyUpdate(List<FeedItem> feedItemList){
        System.Debug('feedItemList' +feedItemList);
        Set<id> feedItemID = new Set<id>();
        List<FeedItem> newFeeds = new List<FeedItem>();    
        if(feedItemList != null || !feedItemList.isEmpty()){
            for(FeedItem fdList: feedItemList){
                feedItemID.add(fdList.id);
            }
            System.Debug('feedItemList1' +feedItemID);
        }
        List<FeedItem> feedRecList = [Select id, ParentId, Visibility From FeedItem Where id =: feedItemID];
        if(feedRecList != null || !feedRecList.isEmpty() ) {
            for(FeedItem fee:feedRecList){
                if(fee.ParentId.getSObjectType() == agf__ADM_Work__c.SObjectType)
                    fee.Visibility='AllUsers';
                System.Debug('feedItemList2' +fee.Visibility);
                newFeeds.add(fee);
                System.Debug('feedItemList3' +newFeeds);
            }
        }
        try{
            if(newFeeds.size() > 0)
                Database.update(newFeeds);
        }
        catch(Exception ex){
            System.Debug('The updation of news feed failed' +ex);
        }
    }
    //Added by external.debasmita.rawooth@seg-automotive.com.sgpro2 to count number of feeditems for news_announcements__c object
    
    //Commenting for Insight deprecation
    /*public void countFeeditems2(List<FeedItem> fis){
        set<id> parentIdsSet = new set<id>();
        set<id> parentIdsSet2 = new set<id>();
        set<id> feedids = new set<id>();
        List<news_announcements__c> newslisttoupdate = new List<news_announcements__c>();
        list<news_announcements__c> childnewslist = new list<news_Announcements__c>();
        //getting parent ids of feeditem - this has news with parentid and news without parentid
        for(FeedItem fi : fis){
            if(fi.ParentId!=null){
                parentIdsset.add(fi.ParentId);
                feedids.add(fi.id);
            }
        }
        map<id, news_announcements__c> pmap = new map<id, news_announcements__c>([Select id ,Name, English_News__c,English_News__r.Name,English_News__r.count_of_feeds__c,count_of_feeds__c from news_announcements__c ]);
        //getting all feeds related to those records. - this has news with parentid and news without parentids
        List<News_announcements__c> accountList1 = new List<News_announcements__c>([Select id ,Name, English_News__c,English_News__r.Name,English_News__r.count_of_feeds__c,count_of_feeds__c, (Select id From Feeds where id in : feedids	) from news_announcements__c Where id in:parentIdsSet]);
        system.debug('parentlist when feeditem inserted---'+accountList1);
        
        for(News_Announcements__c na : accountList1){
            if(na.English_News__c!=null){ //news which are child
                system.debug('inside childs--'+ na.feeds.size());
                if(pmap.containskey(na.English_News__c)){
                    pmap.get(na.English_News__c).count_of_Feeds__c =  (integer) pmap.get(na.English_News__c).count_of_Feeds__c + na.feeds.size();
                    childnewslist.add(pmap.get(na.English_News__c));
                }  else {
                    
                }
                
                
                
            }
            else {
                system.debug('inside parent if');
                parentIdsSet2.add(na.Id);
            }
            
        }
        
        
        
        
        if(parentIdsSet2.size()>0){
            List<News_announcements__c> accountList = new List<News_announcements__c>([Select id ,Name, English_News__c,count_of_feeds__c, (Select id From Feeds where id in : feedids) from news_announcements__c Where id in:parentIdsSet2]);
            system.debug('parent list$$'+accountList);
            FOR(news_announcements__c acc : accountList){
                system.debug('prev value --'+acc.count_of_feeds__c);
                acc.count_of_feeds__c = (integer)acc.count_of_feeds__c+acc.Feeds.size();
                system.debug('count--'+acc.count_of_feeds__c);
                newslisttoupdate.add(acc);
            }
            try{
                update newslisttoupdate;
            }catch(System.Exception e){
                
            }
            
        }  
        update childnewslist;
        system.debug('updated parent---'+childnewslist);
        
    }
    
    public void countAfterDelete(List<FeedItem> feeditemlist){
        set<id> parentIDs = new set<id>();
        set<id> feedids = new set<id>();
        set<id> parentid2 = new set<id>();
        string comntyid = Label.communityid;
        List<News_announcements__c> newslisttoupdate = new list<News_announcements__c>();
        list<news_announcements__c> childlist = new list<news_announcements__c>();

        for(FeedItem fid :feeditemlist ){
            if(fid.ParentId!=null){
                parentIDs.add(fid.ParentId);
                feedids.add(fid.id);
            }
        }
        system.debug('size in conttroller---'+feedids.size());
        map<id, news_announcements__c> pmap = new map<id, news_announcements__c>([Select id ,Name, English_News__c,English_News__r.Name,English_News__r.count_of_feeds__c,count_of_feeds__c from news_announcements__c ]);
        List<News_announcements__c> accountList = new List<News_announcements__c>([Select id ,Name,English_News__c, count_of_feeds__c, (Select id,commentcount From Feeds where id in :feedids ) from news_announcements__c Where id in:parentIDs all rows]);
       	map<id, news_announcements__c> pmap1 = new map<id, news_announcements__c>([Select id ,Name, English_News__c,English_News__r.Name,English_News__r.count_of_feeds__c,count_of_feeds__c,(Select id,commentcount From Feeds where id in :feedids ) from news_announcements__c where id in:parentIDs all rows]);
        
        
        for(news_announcements__c na : accountlist){
            for(FeedItem fi : [select id,commentcount, parentid from feeditem where parentid =:na.Id and id in : feeditemlist ALL ROWS]){
                system.Debug('inside for of fi');
            if(na.English_News__c!=null){
                if(pmap.containskey(na.English_News__c)){
                    system.debug('old val b4 del----'+pmap.get(na.English_News__c).count_of_feeds__c);
                    pmap.get(na.English_News__c).count_of_feeds__c = (integer) pmap.get(na.English_News__c).count_of_feeds__c - na.feeds.size()-fi.commentcount;
                    
                    system.debug('after del---'+pmap.get(na.English_News__c).count_of_feeds__c);
                    childlist.add(pmap.get(na.English_News__c));
                }else{}
                
                
            }else{
                parentid2.add(na.id);
            }
        }
        }
        
        
        if(parentid2.size()>0){
            List<News_announcements__c> accountList2 = new List<News_announcements__c>([Select id ,Name, count_of_feeds__c, (Select id From Feeds where id in :feedids ) from news_announcements__c Where id in:parentid2 all rows]);
            FOR(news_announcements__c acc : accountList2){
                for(FeedItem fi : [select id,commentcount, parentid,(select id from feedcomments ) from feeditem where parentid =:acc.Id and id in : feeditemlist ALL ROWS]){
                
                system.debug('comment count--'+fi.commentcount+'---');//ConnectApi.ChatterFeeds.getCommentsForFeedElement(null, fi.id));
                system.debug('feeds size---'+acc.feeds.size()+'---'+fi.CommentCount+'----'+fi.feedcomments.size());
                acc.count_of_feeds__c = (integer)acc.count_of_feeds__c -acc.Feeds.size()-fi.feedcomments.size();
                system.debug('count--'+acc.count_of_feeds__c);
                newslisttoupdate.add(acc);
            }
            }
            try{
                update newslisttoupdate;
            }catch(System.Exception e){
                
            }
        }
        update childlist;
        system.debug('updated---'+childlist);
    }*/
}