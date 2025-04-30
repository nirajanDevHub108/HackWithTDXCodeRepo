public class BookAppointmentAction {
    public class AppointmentRequest {
        @InvocableVariable(required = true)
        public String customerName;
        @InvocableVariable(required = true)
        public String email; 
        @InvocableVariable(required = true)
        public String phone; 
        @InvocableVariable(required = true)
        public String slotName;
    }

    public class AppointmentResponse {
        @InvocableVariable
        public String appointmentId;
        @InvocableVariable
        public String slotName; 
        @InvocableVariable
        public String customerName;
        @InvocableVariable
        public String email; 
        @InvocableVariable
        public String phone; 
        @InvocableVariable
        public DateTime appointmentDateTime; 
        @InvocableVariable
        public String statusMessage; 
    }

    @InvocableMethod(
        label = 'Book Appointment' 
        description = 'Books an appointment after slot selection and customer confirmation.'
    )
    public static List<AppointmentResponse> bookAppointment(List<AppointmentRequest> requests) {
        List<AppointmentResponse> appointmentResponses = new List<AppointmentResponse>();

        for (AppointmentRequest request : requests) {
            AppointmentResponse response = new AppointmentResponse();
            response.customerName = request.customerName;
            response.email = request.email;
            response.phone = request.phone;

            try {
                
                List<Slot__c> matchingSlots = [
                    SELECT Id, Name, Slot_Date__c, Start_Time__c, End_Time__c, Status__c 
                    FROM Slot__c 
                    WHERE Name = :request.slotName
                    LIMIT 1
                ];

                if (matchingSlots.isEmpty()) {
                    response.statusMessage = 'Error: Slot with the specified name not found.';
                    appointmentResponses.add(response);
                    continue;
                }

                Slot__c selectedSlot = matchingSlots[0];

                if (selectedSlot.Status__c != 'Available') {
                    response.statusMessage = 'Error: Slot is not available for booking.';
                    appointmentResponses.add(response);
                    continue;
                }

                
                Contact contact;
                List<Contact> existingContacts = [
                    SELECT Id, Name, Email, Phone 
                    FROM Contact 
                    WHERE Email = :request.email AND Phone = :request.phone
                ];

                
                if (!existingContacts.isEmpty()) {
                    contact = existingContacts[0];
                } else {
                    contact = new Contact(
                        LastName = request.customerName,
                        Email = request.email,
                        Phone = request.phone
                    );
                    insert contact;
                }

               
                selectedSlot.Status__c = 'Booked';
                update selectedSlot;

               
                Appointment__c newAppointment = new Appointment__c(
                Slot__c = selectedSlot.Id,
                Name = request.customerName,
                Phone__c = request.phone,
                Email__c = request.Email,
                Customer_Name__c = contact.Id
               );
              insert newAppointment;

                
                response.slotName = selectedSlot.Name;
                response.appointmentDateTime = DateTime.newInstance(
                    selectedSlot.Slot_Date__c, 
                    selectedSlot.Start_Time__c
                );
                response.statusMessage = 'Appointment booked successfully.';
            } catch (Exception ex) {
                
                response.statusMessage = 'Error: ' + ex.getMessage();
            }

            
            appointmentResponses.add(response);
        }

        return appointmentResponses;
    }
}