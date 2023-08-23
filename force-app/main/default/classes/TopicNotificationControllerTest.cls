/**
 * This class contains unit tests for validating the behavior of TopicNotificationController Class
 */
@isTest
private class TopicNotificationControllerTest {
	static testMethod void getTopicTest() {
        // Create News record
        Topic objTopic = new Topic(Name = 'Test Topic');
        insert objTopic;
        
        Test.startTest();
        	objTopic = TopicNotificationController.getTopic(objTopic.Id);
        Test.stopTest();
        
        System.assert(objTopic.Name == 'Test Topic');
    }	
}