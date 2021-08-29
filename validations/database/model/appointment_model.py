class AppointmentModel:
    def __init__(self,
                 appointment_id=0,
                 patient_name=None,
                 patient_contact_no=None,
                 email_address=None,
                 branch_code=None,
                 branch_name=None,
                 appointment_date=None,
                 start_timeslot=None,
                 end_timeslot=None,
                 appoint_by=None,
                 is_cancelled=False,
                 cancelled_date=None,
                 cancelled_by=None,
                 reference_code=None,
                 *args,
                 **kwargs
                 ):
        self.appointment_id=appointment_id
        self.patient_name=patient_name
        self.patient_contact_no=patient_contact_no
        self.email_address=email_address
        self.branch_code=branch_code
        self.branch_name=branch_name
        self.appointment_date=appointment_date
        self.start_timeslot=str(start_timeslot)
        if len(self.start_timeslot) < 4:
            self.start_timeslot='0'+self.start_timeslot
        self.end_timeslot=str(end_timeslot)
        if len(self.end_timeslot) < 4:
            self.end_timeslot='0'+self.end_timeslot

        self.appoint_by=appoint_by
        self.is_cancelled=is_cancelled
        if not self.is_cancelled:
            self.is_cancelled=False
        self.cancelled_date=cancelled_date
        self.cancelled_by=cancelled_by
        self.reference_code=reference_code