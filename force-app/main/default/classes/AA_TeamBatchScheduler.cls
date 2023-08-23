/*******************************************************************************************************
* 
* @ Name    		: AA_TeamBatchScheduler
* @ Purpose 		: Schedule Class for AA_TeamBatch
* @ Author  		: Debasmita Rawooth
* @ Test Class Name : 
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.05.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
global class AA_TeamBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        AA_TeamBatch teamBatch = new AA_TeamBatch(); 
        Database.executebatch(teamBatch);
    }

}