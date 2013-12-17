/***************************************************************************
 Name        : ObjectConfigCon 
 Visualforce : ObjectConfig
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/16/2013
 Description  : Controller class for ObjectConfig Visualforce page, that makes it for user to create Configurations by selecting Objects and fields.

****************************************************************************/
 
 
public with sharing class ObjectConfigCon {
	
	// Public Variables
	public List<String> availableFieldsSet			   {get;set;}
	public List<String> availableGroupsSet			   {get;set;}
	public boolean isObjectSelected					   {get;set;}
	public boolean isGroupsShown					   {get;set;}
	public String selectedObject					   {get;set;}
	public String selectedGroup						   {get;set;}
	public List<ObjectConfiguration__c> configurations {get;set;}
	public String rowNumber							   {get;set;}
	
	// Private Variables
	private List<ObjectConfiguration__c> deletedConfs;
	private List<SelectOption> objectsList;
	private Map<String,String> fieldLabelMap;
	private Map<String,String> fieldTypeMap;
	
	// Constructor
	public ObjectConfigCon(){
		
		reset();
		
	}
	
	// Reset method 
	public void reset(){
		
		isObjectSelected = false;
		isGroupsShown	 = false;
		selectedObject	 = '';
		
		configurations 	= new List<ObjectConfiguration__c>();
		objectsList 	= new List<SelectOption>();
		deletedConfs	= new List<ObjectConfiguration__c>();
		
		objectsList.add(new SelectOption('','--Select Object--'));
		
		init();
		
	}
	
	// Returns the objects
	public List<SelectOption> getAllObjects(){
		return objectsList;
	}
	
	// Display the popup to select from available Groups
	public void showPopUp(){
		
		rowNumber = Apexpages.currentPage().getParameters().get('row');
				
		isGroupsShown	 = true;
	
	}
	
	// Hide Popup. If a Group is selected, populate onto the row.
	
	public void hidePopUp(){
		
		selectedGroup = Apexpages.currentPage().getParameters().get('selectedG');
		
		if(selectedGroup != null && selectedGroup != ''){
			
			Integer row = Integer.valueof(rowNumber) - 1;
			configurations[row].Grouping__c = selectedGroup;
			selectedGroup = '';
			
		}
			isGroupsShown	 = false;
		
	}
	
	// Returns the fields
	public List<SelectOption> getAvailableFields(){
		
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('','--Choose Field'));
		
		availableFieldsSet.sort();
		
		for(String s : availableFieldsSet){
			options.add(new SelectOption(s,s));
		}
		
		return options;
	}
	
	// Returns the groups
	public List<SelectOption> getAvailableGroups(){
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('','--Choose or create group'));
		
		availableGroupsSet.sort();
		
		for(String s : availableGroupsSet){
			options.add(new SelectOption(s,s));
		}
		
		return options;
	}
	
	// This method gets all the Objects using GlobalDescribe.
	
	private void init(){
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         Set<String> objectKeys = gd.keySet();
         
         for(String objectKey: objectKeys) {              
             Schema.SobjectType sobjecttype = gd.get(objectKey);
             Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
             if(r.isAccessible() && r.isCreateable()){                                                 
                 objectsList.add(new SelectOption(r.getName(),r.getLabel()));                                  
             }            
       	 }
       	 
       	 objectsList.sort();

	}
	
	// When an Object is selected, get the fields for that object. Also gets the existing records for the Selected Object
	public void getFields(){
		
		if(selectedObject == null)
			return;
		
		availableFieldsSet 	= new List<String>();
		availableGroupsSet  = new List<String>();
		fieldLabelMap		= new Map<String,String>();
		fieldTypeMap		= new Map<String,String>();
		
		configurations = [Select Id, Name, FieldName__c,ObjectName__c, Grouping__c from ObjectConfiguration__c where ObjectName__c = :selectedObject];
		
		List<AggregateResult> groupedResults = [Select Grouping__c groupName,Count(Id) groupCount from ObjectConfiguration__c group by Grouping__c];
		
		for(AggregateResult ag : groupedResults){
			availableGroupsSet.add(String.valueof(ag.get('groupName')));
		}
		
		if(configurations.size() == 0){
			configurations.add(new ObjectConfiguration__c(ObjectName__c=selectedObject));
		}
		
		Map<String, Schema.SobjectField> fieldsMap = Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap();
		
		for( String ky : fieldsMap.keySet() ){
			 DescribeFieldResult f = fieldsMap.get(ky).getDescribe();
			 
			 if(f.isAccessible() && f.isUpdateable()) {
			 	availableFieldsSet.add(f.getLocalName());
			 	fieldLabelMap.put(f.getLocalName(),f.getLabel());
			 	fieldTypeMap.put(f.getLocalName(),f.getType().name());
			 } 	
		}
		
		isObjectSelected = true;
		
	}
	
	// Remove Row from the Table
	public void deleteRow(){
		
		rowNumber = Apexpages.currentPage().getParameters().get('row');
		Integer row = Integer.valueof(rowNumber)-1;
		
		if(configurations[row].Id != null)
			deletedConfs.add(configurations[row]);
		
		configurations.remove(row);
		  
	}
	
	// Add the row to the Table
	public void addRow(){
		
		configurations.add(new ObjectConfiguration__c(ObjectName__c=selectedObject));
	
	}
	
	// Save all the rows, Upserts and Deletes
	public void saveAll(){
		
		for(ObjectConfiguration__c oc : configurations){
			oc.FieldLabel__c = fieldLabelMap.get(oc.FieldName__c);
			oc.FieldType__c	 = fieldTypeMap.get(oc.FieldName__c);
		}
		
		try {
			
			upsert configurations;
			delete deletedConfs;
		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Object Configurations saved'));
		
		}catch(DMLException e){
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error during Save. Please try again by fixing errors ' + e.getMessage()));
			
		}
	}
	

}