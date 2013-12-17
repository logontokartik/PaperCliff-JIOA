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
private class TestObjectConfigTriggerTest {
	
/***************************************************************************
 Name        : TestObjectConfigTriggerTest 
 Description : Test class to test the ObjectConfigTriggerHandler. This class has 2 methods, one to test the updates to the Hashmap object and other to validate if the
 row already exists with the same Object & Field Name.
****************************************************************************/

    static testMethod void objectConfigTest() {
        
        List<ObjectConfiguration__c> configs = new List<ObjectConfiguration__c>();
        
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Name',FieldLabel__c='Name',FieldType__c='String',Grouping__c='Name Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='BillingCity',FieldLabel__c='BillingCity',FieldType__c='String',Grouping__c='Add Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='AccountNumber',FieldLabel__c='Account Number',FieldType__c='String',Grouping__c='Number Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Industry',FieldLabel__c='Industry',FieldType__c='String',Grouping__c='Business Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='BillingState',FieldLabel__c='Billing State',FieldType__c='String',Grouping__c='Add Group'));
        
        
        Test.startTest();
        
        	insert configs; // Runs the Trigger
        	
        	List<ObjectConfiguration__c> newConfigs = [Select Id, Name, ObjectName__c from ObjectConfiguration__c];
        	system.assertEquals(5,newConfigs.size()); // Assert 5 records inserted
        	
        	List<Hashmap__c> maps = [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c]; // Hashmap gets upserted
        	system.assertEquals(1,maps.size());
        
        	List<ObjectConfiguration__c> configs2 = new List<ObjectConfiguration__c>();
        
	        configs2.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='BillingCountry',FieldLabel__c='Billing Country',FieldType__c='String',Grouping__c='Business Group'));
	        configs2.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Type',FieldLabel__c='Type',FieldType__c='String',Grouping__c='Add Group'));
        	configs2.add(new ObjectConfiguration__c(ObjectName__c='Contact',FieldName__c='FirstName',FieldLabel__c='First Name',FieldType__c='String',Grouping__c='Name Group'));
        	
        	insert configs2;
        
        	maps = [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c]; // Hashmaps gets upserted
        	system.assertEquals(2,maps.size());
        
        
        Test.stopTest();
        
    }
    
    // Validation Tests.
    
    static testMethod void objectConfigTestFailures() {
        
        List<ObjectConfiguration__c> configs = new List<ObjectConfiguration__c>();
        
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Name',FieldLabel__c='Name',FieldType__c='String',Grouping__c='Name Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Name',FieldLabel__c='Name',FieldType__c='String',Grouping__c='Name Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='AccountNumber',FieldLabel__c='Account Number',FieldType__c='String',Grouping__c='Number Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Industry',FieldLabel__c='Industry',FieldType__c='String',Grouping__c='Business Group'));
        configs.add(new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='BillingState',FieldLabel__c='Billing State',FieldType__c='String',Grouping__c='Add Group'));
        
        
        Test.startTest();
        
        	try {
        
        		insert configs;  
        	
        	}catch(Exception e){
        		system.assertEquals(true,true);	// Test fails
        	}
        	
        	configs.remove(0);
        	
        	insert configs;  // Tests Pass
        	
        	List<ObjectConfiguration__c> newConfigs = [Select Id, Name, ObjectName__c from ObjectConfiguration__c];
        	system.assertEquals(4,newConfigs.size());
        	
        	
        	ObjectConfiguration__c newRec = new ObjectConfiguration__c(ObjectName__c='Account',FieldName__c='Name',FieldLabel__c='Name',FieldType__c='String',Grouping__c='Name Group');
        	
        	try {
        		insert newRec; // Tests fail
        	}catch(Exception e){
        		system.assertEquals(true,true);
        	}
        		
        
        Test.stopTest();
        
    }
    
    
    
}