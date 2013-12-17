/***************************************************************************
 Name        : ObjectConfigTriggerManager 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/16/2013
 Description  : Trigger Manager class for the ObjectConfiguration Object. 

****************************************************************************/
public with sharing class ObjectConfigTriggerManager {

	// Make sure you dont create dupes. Validates if dupes already exist.
	public static Set<String> checkforDupes(List<ObjectConfiguration__c> newRecords){
		
		Set<String> dupes 	    = new Set<String>();
		Set<String> uniqueSet	= new Set<String>();
		
		for(ObjectConfiguration__c oc : newRecords){
			if(uniqueSet.contains(oc.Unique__c))
				dupes.add(oc.Unique__c);
			else	
				uniqueSet.add(oc.Unique__c);
			
		}
		
		for(ObjectConfiguration__c oc: [Select Id, Name, ObjectName__c, FieldName__c,Unique__c from ObjectConfiguration__c where Unique__c IN : uniqueSet]){
			dupes.add(oc.Unique__c);
		}
		
		return dupes;
		
	}
	
	public static void rollUpHash(){
		
		Map<String,List<String>> objectFieldsMap = new Map<String,List<String>>();
		Map<String,Hashmap__c> updatedHashMap = new Map<String,Hashmap__c>();
		List<Hashmap__c> newHashmaps 		  = new List<Hashmap__c>();
		List<String> fieldSet;
		
		for(ObjectConfiguration__c oc : [Select Id, ObjectName__c, FieldName__c from ObjectConfiguration__c order by ObjectName__c]){
			
			
			if(objectFieldsMap.get(oc.ObjectName__c) != null){
				fieldSet = objectFieldsMap.get(oc.ObjectName__c);
			}else{
				fieldSet = new List<String>();
			}
			
			fieldSet.add(oc.FieldName__c);
			objectFieldsMap.put(oc.ObjectName__c,fieldSet);
					 
		}
		
		for(Hashmap__c hm :[Select Id, ObjectName__c,CommaSeparatedFields__c from Hashmap__c where ObjectName__c IN : objectFieldsMap.keySet()]){
			
			String csv = '';
			
			for(String s : objectFieldsMap.get(hm.ObjectName__c)){
				csv += s + ',';
			}
			
			csv = csv.removeEnd(',');
			
			hm.CommaSeparatedFields__c = csv;
			
			updatedHashMap.put(hm.ObjectName__c,hm);
			
			
		}
		
		for(String s : objectFieldsMap.keySet()){
			if(!updatedHashMap.containsKey(s)){
				
				String csv = '';
				
				for(String f : objectFieldsMap.get(s)){
					csv += f + ',';
				}
				
				newHashmaps.add(new Hashmap__c(ObjectName__c=s,CommaSeparatedFields__c=csv));
				
			}
		}
		
		newHashmaps.addAll(updatedHashMap.values());
		
		upsert newHashmaps;
	}


}