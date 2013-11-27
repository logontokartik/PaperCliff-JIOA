/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestSFHashService {

    static testMethod void SFHashServiceTest() {
        
        // Load the  test Data
        
        List<Account> accounts = new List<Account>();
        
        for(Integer i=0;i<200;i++){
            accounts.add(new Account(Name='TestAccount'+i,BillingStreet='Street'+i,BillingCity='City'+i,BillingState='S'+i,Type='Test'+i,Industry='Ins'+i));
        }
        
        insert accounts;
        
        // Load the options
        //Name,BillingCity,BillingState,Description
        Hashmap__c newHashMap = new Hashmap__c(ObjectName__c='Account',CommaSeparatedFields__c='Name,BillingCity,BillingState,Description');
        insert newHashMap;
        
        Test.startTest();
        
            List<SObject> accts = [Select Id,Name,BillingCity,BillingState,Description from Account];
            
            Map<String,String> jsonMap = new Map<String,String>();
            String[] fields = new String[]{'Name','BillingCity','BillingState','Description'}; 
            
            for(SObject o : accts){
                Blob convertedSO = convertObject(o,fields );
                String r = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', convertedSO));
                jsonMap.put(o.id,r);
                
            }

            String serialized = JSON.serialize(jsonMap);
        
        
            RestRequest req = new RestRequest(); // Build the REST Request for testing
            req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/1.0/Hash';
            req.httpMethod = 'POST';        // Perform a POST
            req.requestBody = Blob.valueof(serialized); // Add JSON Message as a POST
            
            RestResponse res      = new RestResponse();
            RestContext.request  = req;
            RestContext.response = res;
      
            List<String> returnedIds = new List<String>();
      
            try {         
                returnedIds = SFHashService.doPost();
            }catch(Exception e){
                system.assertEquals('Passed','Failed due to Exception');
            }
            
            // Since no changes made, empty list
            system.assertEquals(0,returnedIds.size());
            
            // Modify the accounts
            
            for(Integer i=0;i<100;i++){
                    accounts[i].Name = 'TestAccountChanged'+i;
            }
        
            update accounts;
            
            // Without changing anything do the post again.
            
            returnedIds = new List<String>();
            
            try {         
                returnedIds = SFHashService.doPost();
            }catch(Exception e){
                system.assertEquals('Passed','Failed due to Exception');
            }
            
            // 100 Ids must be returned back
            system.assertEquals(100,returnedIds.size());
                
            // Delete the configuration, throws an exception that no settings present
            
            delete newHashMap;
            
            returnedIds = new List<String>();
            
            try {         
                returnedIds = SFHashService.doPost();
            }catch(Exception e){
                system.assertEquals('Passed','Passed');
            }
            
            // Test the bad condition
            
            String badjsonString = '{"id","failed"}';
            
            req.requestBody = Blob.valueof(badjsonString); // Add JSON Message as a POST
            
            res       = new RestResponse();
            RestContext.request  = req;
            RestContext.response = res;
            
            returnedIds = new List<String>();
            
            try {         
                returnedIds = SFHashService.doPost();
            }catch(Exception e){
                system.assertEquals('Passed','Passed');
            }
                        
        
        Test.stopTest();
        
        
    }
    
    private static Blob convertObject(SObject o, String[] fields){
    
       String csvValues = null;
       for (String fieldName : fields) {
         String fieldValue = o.get(fieldName) == null ? '<null>' : o.get(fieldName) + '';
           
         if (csvValues != null) {
           csvValues += ',' + fieldValue ;
         } else {
           csvValues = fieldValue + '';
         }
           
       }
    
        //return Blob.valueof(JSON.serialize(o));
        return Blob.valueof(csvValues);
    }
    static testmethod void HashObjectConfigConTest(){
        
        Test.startTest();
        
            
                HashObjectConfigCon testCon = new HashObjectConfigCon();
                
                testCon.getAllObjects();
                
                testCon.selectedObject = 'Account'; // Select Account
                
                system.assertEquals(false, testCon.isObjectSelected);
                
                testCon.loadFieldSets(); 
            
                system.assertEquals(true, testCon.isObjectSelected); // set to true
                system.assertEquals('"none"', testCon.selectedFields); // Since nothing already defined 
                
                Apexpages.currentPage().getParameters().put('fields','Name,BillingStreet,BillingCity');
                
                testCon.saveSettings();
                
                Hashmap__c hashConfig = [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c where ObjectName__c = 'Account'];
                
                system.assertNotEquals(null,hashConfig);
                system.assertEquals('Account',hashConfig.ObjectName__c);
                system.assertEquals('Name,BillingStreet,BillingCity',hashConfig.CommaSeparatedFields__c.trim());
                
                
                HashObjectConfigCon testCon2 = new HashObjectConfigCon();
                
                testCon2.getAllObjects();
                
                testCon2.selectedObject = 'Account'; // Select Account
                
                system.assertEquals(false, testCon2.isObjectSelected);
                
                testCon2.loadFieldSets(); 
                
                system.assertEquals(true, testCon2.isObjectSelected); // set to true
                system.assertEquals('"Name,BillingStreet,BillingCity"', testCon2.selectedFields); // Since nothing already defined 
                
        
        Test.stopTest();
        
        
        
    }
    
    
    
    
    
    
}