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
private class TestObjectConfigCon {

 /***************************************************************************
 Name        : TestObjectConfigCon 
 Description : Test Class to Test the ObjectConfigCon Controller.
****************************************************************************/

    static testMethod void objectConfigConTest() {
        
        
        Test.startTest();
        	
        	ObjectConfigCon testCon = new ObjectConfigCon();
        	
        	system.assertEquals(false,testCon.isObjectSelected);
        	system.assertEquals(false,testCon.isGroupsShown);
        	
        	// Get the objects
        	testCon.getAllObjects();
        	
        	testCon.selectedObject	= 'Account';
        	
        	// Get the fields for the Selected Object
        	testCon.getFields();
        	
        	system.assertEquals(true,testCon.isObjectSelected);
        	
        	// Get the Fields SelectOptions and Groups SelectOption
        	testCon.getAvailableFields();
        	testCon.getAvailableGroups();
        	
        	//
        	testCon.addRow();
        	
        	system.assertEquals(2,testCon.configurations.size());
        	
        	Apexpages.currentPage().getParameters().put('row','1');
        	
        	testCon.deleteRow();
        	
        	system.assertEquals(1,testCon.configurations.size());
        	
        	testCon.showPopUp();
        	
        	system.assertEquals(true,testCon.isGroupsShown);
        	
        	testCon.hidePopUp();
        	
        	testCon.configurations[0].FieldName__c = 'BillingCity';
        	testCon.configurations[0].Grouping__c = 'Address Group';
        	
        	testCon.saveAll();
        	
        	List<ObjectConfiguration__c> configs = [Select Id, Name, ObjectName__c, FIeldName__c,FieldType__c,FieldLabel__c,Grouping__c from ObjectConfiguration__c];
        	
        	system.assertEquals(1,configs.size());
        	system.assertEquals('Account',configs[0].ObjectName__c);
        
        	
        	// Test 2 to get the already inserted row.
        	
        	ObjectConfigCon testCon2 = new ObjectConfigCon();
        	
        	
        	testCon2.selectedObject	= 'Account';
        	testCon2.getFields();
        	
        	testCon2.getAvailableGroups();
        	system.assertEquals(1,testCon2.availableGroupsSet.size()); // Since Group is already available
        	
        	Apexpages.currentPage().getParameters().put('row','1');
        	
        	testCon2.showPopUp();
        	
        	Apexpages.currentPage().getParameters().put('selectedG','Address Group');
        	
        	testCon2.hidePopUp();
        	
        
        Test.stopTest();
        
        
        
    }
}