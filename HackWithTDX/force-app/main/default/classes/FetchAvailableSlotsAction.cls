public class FetchAvailableSlotsAction {
    public class SlotResponse {
        @InvocableVariable
        public String slotDetails; 
    }

    @InvocableMethod(
        label = 'Fetch Available Slots' 
        description = 'Fetches available slots for a given date.'
    )
    public static List<SlotResponse> fetchAvailableSlots(List<Date> appointmentDates) {
        List<SlotResponse> slotResponses = new List<SlotResponse>();
        
        for (Date appointmentDate : appointmentDates) {
            // Query to fetch slots for the given date where Status__c is 'Available'
            List<Slot__c> slots = [
                SELECT Name, Start_Time__c, End_Time__c 
                FROM Slot__c 
                WHERE Slot_Date__c = :appointmentDate
                AND Status__c = 'Available'
            ];
            
            if (!slots.isEmpty()) {
                
                String slotDetailsForDate =': ';
                
                List<String> slotDetailsList = new List<String>();
                for (Slot__c slot : slots) {
                   
                    String formattedStartTime = formatTime(slot.Start_Time__c);
                    String formattedEndTime = formatTime(slot.End_Time__c);
                    
                  
                    slotDetailsList.add('Slot Name: ' + slot.Name + 
                                        ', Start Time: ' + formattedStartTime + 
                                        ', End Time: ' + formattedEndTime);
                }
                
              
                slotDetailsForDate += String.join(slotDetailsList, ' | ');

                
                SlotResponse response = new SlotResponse();
                response.slotDetails = slotDetailsForDate;
                slotResponses.add(response);
            }
        }
        
        return slotResponses;
    }

    // Helper method to format Time fields to HH:mm
    private static String formatTime(Time timeValue) {
        if (timeValue == null) return '00:00';

        // Convert Time to DateTime for formatting
        Datetime tempDateTime = Datetime.newInstance(Date.today(), timeValue);
        return tempDateTime.format('HH:mm'); 
    }
}