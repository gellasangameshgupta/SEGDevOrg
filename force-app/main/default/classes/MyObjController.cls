/**
*
*	purpose: get whatId for Component
*	Author: Raphael Rugova
*
*   Date 	               |   Developer Name                  |   Version     |   Changes
* 	===========================================================================================================
*   (1.0) 17.08.2017       |   raphael.rugova@t-systems.com    | 	1.0        |   Initial Version
*
*/


public with sharing class MyObjController {
    @AuraEnabled public String idForJs {get;set;}
    public MyObjController (string recordId) {
        this.idForJs = recordId;
    }
    @AuraEnabled
    public static String getMyObjects(String recordId) {
	        // Perform isAccessible() checks here
	        Task task = [SELECT Id, WhatId FROM Task WHERE Id = :recordId];
        	String lookUpIdField = task.WhatId;
	        return lookUpIdField;
	    }
	}