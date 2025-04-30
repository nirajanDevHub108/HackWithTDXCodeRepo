public class GetAppointmentDetailsAction {
    public class AppointmentDetailsRequest {
        @InvocableVariable(required = true)
        public String customerName; 
        @InvocableVariable(required = true)
        public String email; 
    }

    public class AppointmentDetailsResponse {
        @InvocableVariable
        public String appointmentId; 
        @InvocableVariable
        public String slotName; 
        @InvocableVariable
        public Date appointmentDate; 
        @InvocableVariable
        public Time appointmentTime; 
        @InvocableVariable
        public String status; 
        @InvocableVariable
        public String customerName; 
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String phone; 
    }

    @InvocableMethod(
        label = 'Get Appointment Details' 
        description = 'Retrieves the details of an appointment based on customer name and email.'
    )
    public static List<AppointmentDetailsResponse> getAppointmentDetails(List<AppointmentDetailsRequest> requests) {
        List<AppointmentDetailsResponse> responses = new List<AppointmentDetailsResponse>();

        for (AppointmentDetailsRequest request : requests) {
            AppointmentDetailsResponse response = new AppointmentDetailsResponse();

            try {
                
                List<Appointment__c> matchingAppointments = [
                    SELECT Id, Name, Slot__r.Name, Slot__r.Slot_Date__c, Slot__r.Start_Time__c, Slot__r.Status__c,
                           Email__c, Phone__c
                    FROM Appointment__c
                    WHERE Name = :request.customerName AND Email__c = :request.email
                    LIMIT 1
                ];

                if (matchingAppointments.isEmpty()) {
                    response.status = 'No appointment found for the provided details.';
                } else {
                    Appointment__c appointment = matchingAppointments[0];
                    response.appointmentId = appointment.Id;
                    response.slotName = appointment.Slot__r.Name;
                    response.appointmentDate = appointment.Slot__r.Slot_Date__c;
                    response.appointmentTime = appointment.Slot__r.Start_Time__c;
                    response.status = appointment.Slot__r.Status__c;
                    response.customerName = appointment.Name;
                    response.email = appointment.Email__c;
                    response.phone = appointment.Phone__c;
                }
            } catch (Exception ex) {
                response.status = 'Error: ' + ex.getMessage();
            }

            responses.add(response);
        }

        return responses;
    }
}