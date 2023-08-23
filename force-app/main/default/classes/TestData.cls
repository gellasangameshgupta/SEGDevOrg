/**
 * Description - Test data creation Class 
 * Created By  - snpa
 */
@isTest
public class TestData {

    /**
     * Returns a User with given Profile
     *
     * @param   profileId  Id of profile      
     * @return  User       Initialize a User record
     *
     */
    public static User createUser(String profileId) {
        return new User(Alias = 'UTEST',
                Email = 'UTEST@seg-automotive.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                TimeZoneSidKey = 'Europe/Berlin',
                UserName = 'UserFortest@testbsch.com',
                Country = 'Germany');
    }
    
    public static User createMultipleUsers(String name,String profileId) {
        return new User(Alias = 'UTEST',
                Email = name+'UTEST@seg-automotive.com',
                EmailEncodingKey = 'UTF-8',
                LastName = name+'Test User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                TimeZoneSidKey = 'Europe/Berlin',
                UserName = name+'UserFortest@testbsch.com',
                Country = 'Germany');
    }
    
    /**
     * Returns an instance of Account 
     *
     * @param   userId   Id of Manager or Contact person      
     * @return  Account  Instance of account
     *
     */
    public static Account createAccount(Id userId, 
                                        String recordType, 
                                        String language) {
        
        Id devRecordTypeId = [SELECT Id FROM RecordType 
                                        WHERE RecordType.DeveloperName = :recordType].Id;
        return new Account(Name = 'Test Account',
                           MMS_Textblock_1__c = 'About Us',
                           MMS_Address__c = 'Address',
                           MMS_Contact_Person__c = userId,
                           MMS_Manager__c = userId,
                           MMS_Textblock_2__c = 'Our Functions',
                           MMS_Department_Title__c = 'Title',
                           MMS_Location_Title__c = 'Title',
                           MMS_Weather__c = 'weather',
                           RecordTypeId = devRecordTypeId,
                           MMS_Language__c = language                               
                           );
    }
    
    /**
     * Returns an instance of Account 
     *
     * @param   userId          Id of Manager or Contact person  
     * @param   recordType      Id of Manager or Contact person  
     * @param   translationOf   Id of parent english record  
     * @param   departmentName  Name of department 
     *    
     * @return  Account      Instance of Account
     *
     */
    public static Account createDepartment(Id userId, 
                                           String recordType,
                                           Id translationOf,
                                           Id parentDepartment,
                                           String departmentName,
                                           String language) {
        
        Id devRecordTypeId = [SELECT Id FROM RecordType 
                                        WHERE RecordType.DeveloperName = :recordType].Id;
        return new Account(Name = departmentName,
                           MMS_Translation_of__c = translationOf,
                           MMS_Contact_Person__c = userId,
                           MMS_Manager__c = userId,
                           RecordTypeId = devRecordTypeId,
                           MMS_Parent_Department__c = parentDepartment,
                           MMS_Language__c = language                           
                           );
    }
    
    /**
     * Returns an instance of News 
     *
     * @param   userId                  Id of Author of News
     * @param   recordType              News record type name
     * @param   categoryType            category of news
     * @return  News_Announcements__c   Instance of news
     *
     */
    public static News_Announcements__c createNews(Id userId, String recordType, String categoryType) {
        
        Id devRecordTypeId = [SELECT Id FROM RecordType 
                                        WHERE RecordType.DeveloperName = :recordType].Id;
        return new News_Announcements__c(Name = 'Test News',
                           Author__c = userId,
                           Category__c = categoryType,
                           Content__c = 'Test Content',
                           Language__c = 'en',
                           RecordTypeId = devRecordTypeId,
                           Title__c = 'New news',
                           Type__c = 'Digitalization'
                           );
    }
    
    /**
     * Returns an instance of Local News 
     *
     * @param   userId                  Id of Author of News
     * @param   recordType              News record type name
     * @param   categoryType            category of news
     * @return  News_Announcements__c   Instance of news
     *
     */
    public static News_Announcements__c createLocalNews(Id userId, String recordType, String categoryType,String Type) {
        
        Id devRecordTypeId = [SELECT Id FROM RecordType 
                                        WHERE RecordType.DeveloperName = :recordType].Id;
        return new News_Announcements__c(Name = 'Test Account',
                           Author__c = userId,
                           Content__c = 'Test Content',
                           Language__c = 'en',
                           RecordTypeId = devRecordTypeId,
                           Title__c = 'New news',
                           Local_News_Category__c = categoryType,
                           Type__c = Type
                                                      
                           );
    }
    
    /**
     * Returns an instance of Attachment 
     *
     * @param   parentId     Id of Attachment
     * @return  Attachment   Instance of Attachment
     *
     */
    public static Attachment createAttachment(Id parentId) {

        return new Attachment(Body = blob.valueOf('Test Attachment'),
                           ParentId = parentId,
                           Name = 'Test attachment'
                           );
    }
    
    /**
     * Returns an instance of Static_Content__c 
     *
     * @return  Static_Content__c   Instance of Static_Content__c
     *
     */
    public static Static_Content__c createStaticContent() {
        return new Static_Content__c(Content__c = 'Test Content',
                           Language__c = 'en',
                           Link__c = 'www.google.com'
                           );       
    }
    
    
    /**
     * Returns an instance of  agf__ADM_Scrum_Team__c
     *
     * @return Instance of agf__ADM_Scrum_Team__c
     *
     */
    public static agf__ADM_Scrum_Team__c createScrumTeam(String teamName) {
        return new agf__ADM_Scrum_Team__c(Name= teamName,
                                          agf__Cloud__c = 'IT',
                                          agf__Active__c=true
                           );       
    }
    
    /**
     * Returns an instance of  agf__ADM_Scrum_Team_Member__c
     *
     * @return Instance of agf__ADM_Scrum_Team_Member__c
     *
     */
    public static agf__ADM_Scrum_Team_Member__c createScrumTeamMember(Id scrumTeamId, Id userId) {
        return new agf__ADM_Scrum_Team_Member__c(agf__Scrum_Team__c= scrumTeamId,
                                                agf__Member_Name__c= userId,
                                                agf__Allocation__c=1
                           );       
    }
    
    /**
     * Returns an instance of  AA_TeamGroup__c
     *
     * @return Instance of AA_TeamGroup__c
     *
     */
    public static AA_TeamGroup__c createTeamGroupRecord(Id groupId, Id teamId, String teamName) {
        return new AA_TeamGroup__c(GroupId__c=groupId,
                                   TeamId__c=teamId,
                                   Name=teamName
                           );       
    }
    
    /**
     * Returns an instance of  agf__ADM_Epic__c
     *
     * @return Instance of agf__ADM_Epic__c
     *
     */
    public static agf__ADM_Epic__c createEpicRecord(Id teamId, String epicName) {
        return new agf__ADM_Epic__c(agf__Description__c=epicName,
                                    agf__Team__c=teamId
                           );       
    }
    
    /**
     * Returns an instance of  agf__ADM_Sprint__c
     *
     * @return Instance of agf__ADM_Sprint__c
     *
     */
    public static agf__ADM_Sprint__c createSprintRecord(Id teamId, String sprintName) {
        return new agf__ADM_Sprint__c(Name=sprintName,
                                      agf__Start_Date__c=system.today(),
                                      agf__End_Date__c=system.today()+30,
                                      agf__Scrum_Team__c=teamId
                           );       
    }
    
    /**
     * Returns an instance of  agf__ADM_Product_Tag__c
     *
     * @return Instance of agf__ADM_Product_Tag__c
     *
     */
    public static agf__ADM_Product_Tag__c createproductTagRecord(Id teamId, String prodTagName) {
        return new agf__ADM_Product_Tag__c(agf__Description__c=prodTagName,
                                           agf__Team__c=teamId
                                          );        
    }
    
    /**
     * Returns an instance of  agf__ADM_Work__c
     *
     * @return Instance of agf__ADM_Work__c
     *
     */
    public static agf__ADM_Work__c createWorkRecord(Id teamId, String workName) {
        return new agf__ADM_Work__c(agf__Subject__c=workName,
                                    agf__Auto_Build__c='Test',
                                    agf__Status__c='New',
                                    agf__Scrum_Team__c=teamId
                           );       
    }
    public static agf__ADM_Build__c createBuildRecord(Id teamId, String buildName) {
        return new agf__ADM_Build__c(Name=buildName,
                                    Scrum_Team__c=teamId
                                    
                           );       
    }
    public static agf__RCA__c createRootCauseAnalysisRecord(Id userId,Id teamId,string rootName) {
        return new agf__RCA__c(agf__Messaging_Owner__c=userId,
                                    agf__Scrum_Team__c=teamId,
                                     agf__Message_Requestor__c=userId,
                                     agf__RCM_Type__c='Verbal',
                                     agf__Request_Date__c=system.today(),
                                     agf__Event_Date__c=system.today(),
                                     agf__What_was_the_customer_impact__c=rootName
                                     
                                    
                           );       
    }
}