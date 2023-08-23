public class TopicNotificationController {
	@AuraEnabled
    public static Topic getTopic(Id topicId) {
    	List<Topic> topicList = [Select Name From Topic where Id =: topicId];
        return topicList[0];
    }
}