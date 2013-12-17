/***************************************************************************
 Name       : SFObjectConfigService 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/16/2013
 Description  : Returns the Object Configurations as created in the ObjectConfiguration object as JSON String with the Current User Info.
 
 
 URL :  '/services/apexrest/1.0/Objects'
 Method : GET only
 
 Sample JSON Response: 
 
 {
    "user": {
        "username": "kartik@nov2013.com",
        "role": "COO",
        "name": "Kartik Viswanadha",
        "id": "005i0000001gOdXAAU",
        "email": "kartik.viswanadha@gmail.com"
    },
    "objects": [
        {
            "name": "Account",
            "fields": [
                {
                    "type": "STRING",
                    "name": "BillingCity",
                    "label": "Billing City",
                    "grouping": "AddressGroup"
                },
                {
                    "type": "STRING",
                    "name": "AccountNumber",
                    "label": "Account Number",
                    "grouping": "NumberGroup"
                },
                {
                    "type": "STRING",
                    "name": "Name",
                    "label": "Account Name",
                    "grouping": "NameGroup"
                },
                {
                    "type": "STRING",
                    "name": "BillingCountry",
                    "label": "Billing Country",
                    "grouping": "AddressGroup"
                }
            ]
        }
    ]
} 

 All the errors are returned as custom Exceptions ObjectConfigException.
 				   
 		   
****************************************************************************/

@RestResource(urlMapping='/1.0/Objects')
global with sharing class SFObjectConfigService {
	
	// Post Method
	@HttpGet
	global static String doGet(){
		
		RestRequest req  = RestContext.request;
		RestResponse res = RestContext.response;
		
		String jsonBody; 
		
		jsonBody = getObjectConfigurations();
		
		return jsonBody; // Return the JSON String.
				
	}
	
	// Method that creates the JSON String
	
	private static String getObjectConfigurations(){
		
		Map<String,List<ObjectConfiguration__c>> objectFieldsMap = new Map<String,List<ObjectConfiguration__c>>(); // Main Map
		List<ObjectConfiguration__c> fieldSet;
		
		Configuration conf = new Configuration();
		
		try {
		
			User currentUser = [Select Id, Name, Email, Username, UserRole.Name from User where Id = :UserInfo.getUserId()]; // get Current User Info
			
			UserWrap uwrap 	= new UserWrap();
			uwrap.name 	   	= currentUser.Name;
			uwrap.email    	= currentUser.Email;
			uwrap.username	= currentUser.Username;
			uwrap.role		= currentUser.UserRole.Name;
			uwrap.id		= currentUser.Id;
			
			conf.user		= uwrap;	// Add User Info
			
			// Build Configuration Objects Info
			conf.objects	= new List<Objects>();
			
			for(ObjectConfiguration__c oc : [Select Id, ObjectName__c, FieldName__c,FieldLabel__c,FieldType__c,Grouping__c from ObjectConfiguration__c order by ObjectName__c]){ // Get all Configuration Records
			
				if(objectFieldsMap.get(oc.ObjectName__c) != null){
					fieldSet = objectFieldsMap.get(oc.ObjectName__c);
				}else{
					fieldSet = new List<ObjectConfiguration__c>();
				}
				
				fieldSet.add(oc); // Add new 
				
				objectFieldsMap.put(oc.ObjectName__c,fieldSet); // Add to Map.
					 
			}
			
			// Iterate over map and build the lists.
			
			for(String s : objectFieldsMap.keySet()){
				
				Objects newObj 	= new Objects();
				newObj.fields	= new List<Fields>();
				newObj.name	   = s;
				
				for(ObjectConfiguration__c oc : objectFieldsMap.get(s)){
					Fields newField 	= new Fields();
					newField.name		= oc.FieldName__c;
					newField.label		= oc.FieldLabel__c;
					newField.type		= oc.FieldType__c;
					newField.grouping	= oc.Grouping__c;
					newObj.fields.add(newField);
				}
				
				conf.objects.add(newObj);	
				
			}
			
			return JSON.serialize(conf); // Return serialized JSON String.
		
		}catch(Exception e){
			throw new ObjectConfigException('Error when getting Configuration Data ' + e.getMessage()); // throw an exception if any error
		}
	
	}
	
	
	// Inner classes.
	
	public class ObjectConfigException extends Exception {}
	
	
	// Data Structure - for JSON.
	
	public class UserWrap {
		public String name;
		public String email;
		public String username;
		public String id;
		public String role;
	}

	public class Fields {
		public String name;
		public String label;
		public String type;
		public String grouping;
	}

	public class Objects {
		public String name;
		public List<Fields> fields;
	}
	
	public class Configuration {
		
		public UserWrap user;
		public List<Objects> objects;

	}

}