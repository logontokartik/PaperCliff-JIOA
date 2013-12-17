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
private class TestSFObjectConfigService {

    static testMethod void SFObjectConfigServiceTest() {
        
        List<ObjectConfiguration__c> configs = new List<ObjectConfiguration__c>();
        
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Name',FieldLabel__c='Name',FieldType__c='String',Grouping__c='Name Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='BillingCity',FieldLabel__c='BillingCity',FieldType__c='String',Grouping__c='Add Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='AccountNumber',FieldLabel__c='Account Number',FieldType__c='String',Grouping__c='Number Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Industry',FieldLabel__c='Industry',FieldType__c='String',Grouping__c='Business Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Contact',FieldName__c='FirstName',FieldLabel__c='First Name',FieldType__c='String',Grouping__c='Name Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Contact',FieldName__c='Phone',FieldLabel__c='Phone',FieldType__c='String',Grouping__c='Phone Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Contact',FieldName__c='Company',FieldLabel__c='Company',FieldType__c='String',Grouping__c='Business Group'));
        
        insert configs;
        
        Test.startTest();
        	
        	RestRequest req = new RestRequest(); // Build the REST Request for testing
	        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
	        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/1.0/Objects';
	        req.httpMethod = 'GET';        // Perform a POST
	        
	        RestResponse res 	  = new RestResponse();
	        RestContext.request  = req;
	        RestContext.response = res;
      
      		String jsonBody;
      		
      		try {	      
       			jsonBody = SFObjectConfigService.doGet();
       		}catch(Exception e){
       			system.assertEquals('Passed','Failed due to Exception');
       		}
        
        	system.assertNotEquals(null, jsonBody); // JSON Body is returned
        	
        	// Deserialize into Apex Object
        	SFObjectConfigService.Configuration conf = (SFObjectConfigService.Configuration)JSON.deserialize(jsonBody,SFObjectConfigService.Configuration.class);
        	
        	// Assert that objects size is equals 2.
        	system.assertEquals(2,conf.objects.size());
        	system.assertEquals(UserInfo.getUserId(),conf.user.id);
        	
        
        Test.stopTest();
        
        
    }
}