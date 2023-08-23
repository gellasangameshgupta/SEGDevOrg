/**
*
* @ Purpose : This Apex Trigger handler calculates the given date and adds 7 days with business hours in
*           : consideration
*
* @ Author: Raphael Rugova
*
*
*       Date                |   Developer Name                  |   Version     |   Changes
* ===========================================================================================================
*   (1.0) 20.08.2017        |   raphael.rugova@t-systems.com    | 	1.0         |   Initial Version
*	(1.1) 22.08.2017		| 	michal.swist@gtsce.com			|	1.1			|	Enhanced Business Hours query
*/
public with sharing class DateTimeTriggerHandler {
	public DateTimeTriggerHandler() {
		
	}

	public static DateTime dateTimeMethodCalculator(DateTime nowDate, BusinessHours bh, Integer days) {
		DateTime dateTimeBh = null;
		try {
			if (bh != null ) {
				if (days != null) {
					if (days > 0) {
						dateTimeBh = BusinessHours.add(bh.id, nowDate, days * 9 * 60 * 60 * 1000);
						// Fallback to 7 daysa
					} else {
						dateTimeBh = BusinessHours.add(bh.id, nowDate, 7 * 9 * 60 * 60 * 1000);
					}
					// Fallback to 7 days
				} else {
            		dateTimeBh = BusinessHours.add(bh.id, nowDate, 7 * 9 * 60 * 60 * 1000);
            	}
        	}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		
        
        return dateTimeBh;
	}
}