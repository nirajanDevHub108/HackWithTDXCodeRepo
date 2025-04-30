public class GetResourceDetailsAction {

    public class ResourceRequest {
        @InvocableVariable(required = true)
        public String resourceName; 
    }

    public class ResourceResponse {
        @InvocableVariable
        public String resourceType;
        @InvocableVariable
        public String skills; 
        @InvocableVariable
        public String resourceDescription; 
        @InvocableVariable
        public String status; 
    }

    @InvocableMethod(
        label = 'Get Resource Details'
        description = 'Fetches Resource details based on the Resource name.'
    )
    public static List<ResourceResponse> getResourceDetails(List<ResourceRequest> requests) {
        List<ResourceResponse> resourceResponses = new List<ResourceResponse>();

        for (ResourceRequest request : requests) {
            ResourceResponse response = new ResourceResponse();

            try {
              
                List<Resource__c> matchingResources = [
                    SELECT Name, Resource_Type__c, Skills__c, Resource_Description__c
                    FROM Resource__c
                    WHERE Name = :request.resourceName
                    LIMIT 1
                ];

                if (matchingResources.isEmpty()) {
                    response.status = 'Error: Resource with the specified name not found.';
                } else {
                    Resource__c selectedResource = matchingResources[0];

                    
                    response.resourceType = selectedResource.Resource_Type__c;

                  
                    if (selectedResource.Skills__c != null) {
                        
                        List<String> skillsList = selectedResource.Skills__c.split(';');
                        response.skills = String.join(skillsList, ', ');
                    } else {
                        response.skills = '';
                    }

                    
                    response.resourceDescription = selectedResource.Resource_Description__c;

                    
                    response.status = 'Success';
                }
            } catch (Exception ex) {
                
                response.status = 'Error: ' + ex.getMessage();
            }

            
            resourceResponses.add(response);
        }

        return resourceResponses;
    }
}