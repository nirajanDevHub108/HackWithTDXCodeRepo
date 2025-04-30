public class GetSlotDetailsAction {

    public class SlotRequest {
        @InvocableVariable(required = true)
        public String slotName; 
    }

    public class SlotResponse {
        @InvocableVariable
        public String slotDate;
        @InvocableVariable
        public String startTime;
        @InvocableVariable
        public String endTime;
        @InvocableVariable
        public String resource;  
        @InvocableVariable
        public String status;
    }

    @InvocableMethod(
        label = 'Get Slot Details'
        description = 'Fetches Slot details based on the Slot name.'
    )
    public static List<SlotResponse> getSlotDetails(List<SlotRequest> requests) {
        List<SlotResponse> slotResponses = new List<SlotResponse>();

        for (SlotRequest request : requests) {
            SlotResponse response = new SlotResponse();

            try {
               
                List<Slot__c> matchingSlots = [
                    SELECT Slot_Date__c, Start_Time__c, End_Time__c, Status__c, 
                           Resource__r.Name  // Fetch Resource Name (Resource__r is the relationship to Resource__c)
                    FROM Slot__c 
                    WHERE Name = :request.slotName
                    LIMIT 1
                ];

                if (matchingSlots.isEmpty()) {
                    response.status = 'Error: Slot with the specified name not found.';
                } else {
                    Slot__c selectedSlot = matchingSlots[0];

                    
                    response.slotDate = selectedSlot.Slot_Date__c.format(); 

                    
                    response.startTime = String.valueOf(selectedSlot.Start_Time__c); 
                    response.endTime = String.valueOf(selectedSlot.End_Time__c);

                    
                    response.resource = selectedSlot.Resource__r.Name; 

                    
                    response.status = selectedSlot.Status__c;
                }
            } catch (Exception ex) {
                
                response.status = 'Error: ' + ex.getMessage();
            }

            
            slotResponses.add(response);
        }

        return slotResponses;
    }
}