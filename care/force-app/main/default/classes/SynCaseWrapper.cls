/*
Wrapper class to support Syncase class 
Description:  This class all the fields and tables related to PS  
CreatedBy : shahid
*/
public class SynCaseWrapper {
public ClsCreateCompIntfcLCSFCASECI Create_CompIntfc_LC_SFCASE_CI;
	public class ClsCreateCompIntfcLCSFCASECI {
		public Integer LC_SFCASE_ID;	
		public String LC_SFORCE_CASE_NBR;	
		public String FIRST_NAME;	
		public String LAST_NAME;	
		public String LC_EMPLID;	
		public String ADDRESS1;	
		public String ADDRESS2;	
	    public String CITY;	
		public String STATE;	
		public String COUNTRY;	
		public String POSTAL;	
		public String ADDRESS_TYPE;	
		public String CUST_ID;	
		public String GENDER;	
		public String LC_SFCASE_TYPE;	
		public String EMAILID;
        public String STATUS_FIELD;
		public String RC_DESCRLONG;	
		public String LC_PRGM_NAME;	
        public String LC_PRGM_ID;
		public String LC_SERVICE_TYPE_NM;	
	    public String LC_SERVICE_ID_DESC;	
        public String SERVICE_ID;
        public String CLOSED_DTTM;
        public String CREATEDTTM;
        public String DUE_DATE;
        public String QUICK_CD;
        public String RC_SUMMARY;
        public String CASE_TYPE;
        public String DESCR ;
        public String LC_SF_CTBDATE;
        public String LC_CASE_OWNER;
        public cls_LC_SF_DEP_INFO[] LC_SF_DEP_INFO;
        public cls_LC_SFCASE_SVACT[] LC_SFCASE_SVACT;
		public cls_LC_SFCASE_PROD[] LC_SFCASE_PROD;
        public cls_LC_SFCASE_QUES[] LC_SFCASE_QUES;
        
     }
    
     public class cls_LC_SF_DEP_INFO {
		public String FIRST_NAME1;	
		public String LAST_NAME1;	
		public String ROLE_TYPE_NAME;	
		public String BIRTHDATE;
        public String ADDRESS1_AC;
        public String ADDRESS2_AC;
        public String CITY_AC;
        public String STATE2;
        public String COUNTRY2;
        public String POSTAL_OTHER;
        public String LC_ADDR_TYPE;
        
	}
	public class cls_LC_SFCASE_SVACT {
		public String ACTIVITY_CODE;	
		public String START_DT;	
		public String END_DT;	
		public String LC_ACT_STATUS_DESC;	
	}
	public class cls_LC_SFCASE_PROD {
		public String PRODUCT_NAME;	
		public String ACTIVITY_CODE_0;	
		public String START_DT_0;	
		public String END_DT_0;	
		public String LC_ACT_STATUS_DESC_0;
        
	}
    
    public class cls_LC_SFCASE_QUES {
		public string QUESTION_ID;	
		public String RC_ANSWERSET_ID;	
		public String ANSWER_VALUE;
		        
	}
   
}