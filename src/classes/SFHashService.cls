/***************************************************************************
 Name       : SFHashService 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 10/31/2013
 Description  : The Custom Apex REST Service, that accepts the List of Ids and Hashes of the Records and compares with the current Data in the system and returns back the Ids that are changed.
 
 
 URL :  '/services/apexrest/1.0/Hash'
 Method : POST only
 
 Format : {"<Salesforce Id","<Hash Value>}"
 
 Sample JSON : 
 
 {
  "001i000000InkG8AAJ": "86776e0df020c9d68e05f6cd545e8c375236e460",
  "001i000000InkG4AAJ": "860bd55244770ff8076522bb80c803f2e18dee79",
  "001i000000InkGAAAZ": "ddb1acd4155ec71286eb72506bbc23cc47e428d5",
  "001i000000InkG5AAJ": "3cbd4a67f60897d987d72e5da8a073a95756a912",
  "001i000000InkGEAAZ": "1a22d9010238a66957b0363cd6d65e4a908efc70",
  "001i000000InkGFAAZ": "dc685cce828d2d4214f206751825992594179cdb",
  "001i000000InkG7AAJ": "ce6e74802b6d5bbc9f3ced7f2f07c4c58d4ce761",
  "001i000000InkG6AAJ": "6af9c0164c105c347e5b67747c0c114b08422eb9",
  "001i000000InkGDAAZ": "029efde36fa63d28412bd0f1ba14937a1fccdb61",
  "001i000000InkGCAAZ": "0aad4b73a26c0583b004c7269bbfa3d3c96d13e1",
  "001i000000InkG9AAJ": "f42d8ddf3bf619f9429b9a06024456c1550c87d7",
  "001i000000InkGBAAZ": "d5250279ae9b5352634f05ad2d90be0c2e90579c"
}
 
 
The Service uses the SHA1 algorithm that is combined with various Crypto Methods to generate the SHA1 Hash. Also the settings for each object are defined in the HashMap Custom Object, where you can select the fields you want to use the map for.

All the errors are returned as custom Exceptions HashException.
                   
           
****************************************************************************/


@RestResource(urlMapping='/1.0/Hash')
global with sharing class SFHashService {
    
    // Static hash variable 
    public static String HashAlgorithmSHA1='SHA1';
    
    
    // Post Method
    @HttpPost
    global static List<String> doPost(){
        
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        
        String jsonBody = req.requestBody.toString().trim();
        Map<String,String> inputMaps;
        
        try {
            inputMaps = (Map<String,String>)JSON.deserialize(jsonBody,Map<String,String>.class);
        }catch(Exception e){
            throw new HashException('Exception parsing JSON; check body ' + e.getMessage());
        }
        
        return differences(inputMaps);
                
                
    }
    
    // Method to return the Differences.
    
    private static List<String> differences(Map<String,String> hashMapValues){
        
        // Local Definitions
        List<String> differentIds           = new List<String>();
        Map<String,String> newhashMapValues = new Map<String,String>();
        Map<String,String> objectSettings   = new Map<String,String>();
        Map<String,Set<String>> idTypeMap   = new Map<String,Set<String>>();
        
        
        // Populate all the Types into the Map, so it would be Map of ObjectName => List<Ids>
        system.debug('Processing ' + hashMapValues);
        for(Id s : hashMapValues.keySet()){
            
            String sobjectName = s.getSObjectType().getDescribe().getName();
            
            Set<String> ids;
            
            if(idTypeMap.get(sobjectName) != null){
                ids = idTypeMap.get(sobjectName);
            }else{
                ids = new Set<String>();
            }
            
            ids.add(s);
            
            idTypeMap.put(sobjectName,ids);
            
        }
        
        // Get the Config Settings for the Object types that are sent.
        
        for(Hashmap__c m : [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c where ObjectName__c in :idTypeMap.keySet()]){
            objectSettings.put(m.ObjectName__c,m.CommaSeparatedFields__c);
        }       
        
        // Throw exceptions if not found or if more than 100 types are sent. 
        
        if(objectSettings.size()==0){
            throw new HashException('Hashmap Config not defined for sent SObject Types');
        }
        
        if(idTypeMap.keySet().size() > 100){
            throw new HashException('Cannot have more than 100 different SObject Types');
        }
        
        try {
            // Get the current Record in Salesforce for each SobjectType Set
            for(String s : idTypeMap.keySet()){ 
                
                Set<String> idSet     = idTypeMap.get(s);
                String soql           = 'Select Id, ' + objectSettings.get(s).trim() + ' from ' + s + ' WHERE ID IN :idSet';
                List<SObject> records = Database.query(soql);
                String[] fields = objectSettings.get(s).trim().split(',');
                
                for(SObject o : records){
                    Blob convertedSO = convertObject(o, fields);
                    newhashMapValues.put(o.Id, EncodingUtil.convertToHex(Crypto.generateDigest(HashAlgorithmSHA1, convertedSO)));
                }
                 
            }
            // Compare and return.
            for(String s : hashMapValues.keySet()){
                if(newhashMapValues.get(s) == null || (newhashMapValues.get(s) != hashMapValues.get(s)))
                    differentIds.add(s);
            }
        
        }catch(Exception e){
            throw new HashException('Error in main handle ' + e.getMessage());
        }
        
        return differentIds;
        
    }
    
    // Utility Methods 

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
       return Blob.valueof(csvValues);
    }
    
    public class HashException extends Exception {
        
    }
    

}