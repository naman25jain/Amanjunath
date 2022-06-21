public class ApplicantIrregularTestClass{
	public String responseStatus;	//SUCCESS
	public String errorDescription;	//
	public String transactionId;	//CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT-5001700000BvrzqAAB-0031700001IZ03VAAT
	public Payload payload;
	 Public class Payload {
		public list<Biographic> biographic;
		public list<IrregularBehavior> irregularBehavior;
	}
	Public class Biographic {
		public String USMLEId;	//53256350
		public String lastName;	//Yeh
		public String restOfName;	//Paul
		public String firstName;	//Paul
		public string middleName;
		public String generationSuffix;
		public String gender;	//Male
		public String deceasedDate;	//
		public String birthDate;	//1989-04-18
		public String deceasedFlag;	//N
		public String schoolId;	//044070
		public String SSN;	//000000000
		public String graduationYear;	//2016
		public String graduationMonth;	//05
		public String graduationVerifiedFlag;	//Y
		public String internetAddress;	//yaypaul@gmail.com
		public String SSNLast4Digit;	//0000
	}

	Public class IrregularBehavior {
		public String USMLEId;	//53256350
		public Integer IrregularBehavior;	//4
		public String Description;	//Security Violation
		public String Explanation;	//Impersonating/Engaging proxy. Seeking/obtaining unauthorized access.  Possesssing unauthorized items, equipment or materials.  Theft of examination materials.  Unauthorized reproduction/dissemination of copyrighted materials.
	}
	public static ApplicantIrregularTestClass parse(String json){
		return (ApplicantIrregularTestClass) System.JSON.deserialize(json, ApplicantIrregularTestClass.class);
	}
	}