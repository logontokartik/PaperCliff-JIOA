trigger ObjectConfigTrigger on ObjectConfiguration__c (after delete, after insert, after undelete, after update,before insert, before update) {

	if(Trigger.isBefore && Trigger.isInsert){
		
		Set<String> failures = ObjectConfigTriggerManager.checkforDupes(Trigger.new);
		
		for(ObjectConfiguration__c oc: Trigger.new){
				if(failures.contains(oc.Unique__c))
					oc.addError('Duplicate record found for Object :' + oc.ObjectName__c + ' & Field :' + oc.FieldName__c);
		}
		
	}
	
	if(Trigger.isAfter){
	
		ObjectConfigTriggerManager.rollUpHash();
	
	}
	
	
}