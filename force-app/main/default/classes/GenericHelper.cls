/**
 * Created by snpa on 7/8/2017.
 */
public without sharing class GenericHelper {
	
	public static final String LANGUAGE_ENGLISH = 'en';
	public static final String GLOBAL_NEWS = 'global';
	public static final String LOCAL_NEWS = 'local';
	
	/**
     * Returns a substring of logged in User's Language key Locale
     *
     * @return  String  Substring of User Language key
     *
     */
	public static String getUserLanguage() {
        String userLanguage = UserInfo.getLanguage();
        // Get the initials for user language to compare with the language picklist from News object
        if(userLanguage != '' && userLanguage.contains('_')) {
            userLanguage = userLanguage.substringBefore('_');    
        }
        return userLanguage;
    }
}