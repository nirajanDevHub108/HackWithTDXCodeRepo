public with sharing class FetchResourceComments {
    
    @InvocableMethod(label='Fetch Comments by Resource' description='Fetches comments from Appointment__c records where Resource__c matches the given resource name')
    public static List<String> getCommentsByResource(List<String> resourceNames) {
        List<String> commentsList = new List<String>();

        System.debug('🔍 Received Resource Names: ' + resourceNames);

        if (resourceNames == null || resourceNames.isEmpty() || String.isEmpty(resourceNames[0])) {
            return new List<String>{'No valid resource name provided.'};
        }

      
        String resourceName = resourceNames[0].trim();
        System.debug('🔍 Searching for Resource Name: ' + resourceName);

        
        List<Appointment__c> appointments = [
            SELECT Id, Comments__c, Resource__r.Name 
            FROM Appointment__c 
            WHERE Resource__r.Name = :resourceName
            LIMIT 100
        ];

        System.debug('📝 Found Appointments: ' + appointments.size());

        if (appointments.isEmpty()) {
            return new List<String>{'No comments found for resource: ' + resourceName};
        }

        // Add comments to result list
        for (Appointment__c app : appointments) {
            commentsList.add(app.Comments__c != null ? app.Comments__c : 'No comments available.');
        }

        return commentsList;
    }
}