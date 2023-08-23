/**
 * This class contains unit tests for validating the behavior of AccountHandler Class
 */
@isTest
private class AccountHandlerTest {

    static testMethod void insertTest() {
    	// Create a department with english values
    	User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        Account department = TestData.createDepartment(user.Id,
        											   'Department',
        											   null,
    									   			   null,
    									   			   'test department',
    									   			   'en');
        insert department;
        
    	// Create translations for Department values
        Account translation = TestData.createDepartment(user.Id,
        											   'Department',
        											   department.Id,
    									   			   null,
    									   			   'test department translation',
    									   			   'de');
        
        test.startTest();
        	insert translation;
       	test.stopTest();
       	
       	translation = [Select Id, MMS_Manager__c, MMS_Parent_Department__c, Name From Account Where Id = :translation.Id];
       	
       	System.assert(translation.MMS_Manager__c == department.MMS_Manager__c);
       	System.assert(translation.MMS_Parent_Department__c == department.MMS_Parent_Department__c);
       	System.assert(translation.Name == department.Name);
    }
    
    static testMethod void updateTest() {
    	// Create a department with english values
    	User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        Account department = TestData.createDepartment(user.Id,
        											   'Department',
        											   null,
    									   			   null,
    									   			   'test department',
    									   			   'en');
        insert department;
        
    	// Create translations for Department values
        Account translation = TestData.createDepartment(user.Id,
        											   'Department',
        											   department.Id,
    									   			   null,
    									   			   'test department translation',
    									   			   'de');
        insert translation;
        
        test.startTest();
        	department.name = 'Other department';	
        	department.MMS_Manager__c = user.Id;
        	update department;
       	test.stopTest();
       	
       	translation = [Select Id, MMS_Manager__c, MMS_Parent_Department__c, Name From Account Where Id = :translation.Id];
       	
       	System.assert(translation.MMS_Manager__c == department.MMS_Manager__c);
       	System.assert(translation.MMS_Parent_Department__c == department.MMS_Parent_Department__c);
       	System.assert(translation.Name == department.Name);
    }
    
}