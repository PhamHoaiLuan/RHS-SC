pragma solidity ^0.4.18;

contract HealthMonitoringSystem {
    
    address public Hospital;
    modifier onlyHospital() {
        require(msg.sender == Hospital);
        _;
    }
    
    function HealthMonitoringSystem() public {
        Hospital = msg.sender;
    }
    
    //******************************************************//
    //******************************************************//
    //                                                      //
    //          Paitent Register Smart Contract             //
    //                                                      //
    //******************************************************//
    //******************************************************//
    
    uint    public NumberOfPatients;
    mapping (address => bool)   public Patient_Account_IsRegistered;
    uint    public Patient_Id;
    
    event Patient_Added(address _address,uint _Patient_ID,string _Patient_Name, uint8 _Patient_Age,string _Patient_Address);
    event Patient_Modified(address _address,string _Patient_Name, uint8 _Patient_Age,string _Patient_Address);
    event Patient_Removed(address _address);
    
    struct Patient {
        address Patient_Account;
        uint    Patient_ID;
        string  Patient_Name;
        uint8   Patient_Age;
        string  Patient_Address;
    }
    
    mapping (address => Patient) patients;
    
    function Add_Patient(address _address,string _Patient_Name, uint8 _Patient_Age,string _Patient_Address) onlyHospital public {
        
        require(_address != 0);
        require(Patient_Account_IsRegistered[_address] != true);
        require(Doctor_Account_IsRegistered[_address] != true);
        Patient_Account_IsRegistered[_address] = true;
        
        var patient             = patients[_address];
        patient.Patient_Account = _address;
        Patient_Id++;
        patient.Patient_ID      = Patient_Id;
        patient.Patient_Name    = _Patient_Name;
        patient.Patient_Age     = _Patient_Age;
        patient.Patient_Address = _Patient_Address;
        
        NumberOfPatients++;

        Patient_Added(_address, Patient_Id,_Patient_Name,_Patient_Age,_Patient_Address);
        
    }
    
    function Modify_Patient(address _address,string _Patient_Name, uint8 _Patient_Age,string _Patient_Address) onlyHospital public {
        
        require(Patient_Account_IsRegistered[_address] == true);
        
        patients[_address].Patient_Name     = _Patient_Name;
        patients[_address].Patient_Age      = _Patient_Age;
        patients[_address].Patient_Address  = _Patient_Address;
        
        Patient_Modified(_address,_Patient_Name,_Patient_Age,_Patient_Address);
        
    }
    
    function Remove_Patient(address _address) onlyHospital public {
        
        require(Patient_Account_IsRegistered[_address] == true);
        
        Patient_Account_IsRegistered[_address] = false;
        delete patients[_address]; 
        NumberOfPatients--;
        Patient_Removed(_address);
    }
    
    function Get_Patient(address _address) onlyHospital view public returns (address, uint, string, uint8, string) {
        
        require(Patient_Account_IsRegistered[_address]);
        require((msg.sender == Hospital)||(listpatientfordoctors[msg.sender].Patient_Account_IsAuthorized[_address]==true)|| (msg.sender == _address));
        
        return (patients[_address].Patient_Account,patients[_address].Patient_ID, patients[_address].Patient_Name, patients[_address].Patient_Age, patients[_address].Patient_Address);
    }

    //******************************************************//
    //******************************************************//
    //                                                      //
    //           Doctor Register Smart Contract             //
    //                                                      //
    //******************************************************//
    //******************************************************//
    
    uint    public NumberOfDoctors;
    mapping (address => bool) public Doctor_Account_IsRegistered;
    uint    public Doctor_Id;
    
    event Doctor_Added(address _address,uint _Doctor_ID,string _Doctor_Name, uint8 _Doctor_Age,string _Doctor_Address);
    event Doctor_Modified(address _address,string _Doctor_Name, uint8 _Doctor_Age,string _Doctor_Address);
    event Doctor_Removed(address _address);
    
    struct Doctor {
        address Doctor_Account;
        uint    Doctor_ID;
        string  Doctor_Name;
        uint8   Doctor_Age;
        string  Doctor_Address;
    }
    
    mapping (address => Doctor) doctors;
    
    function Add_Doctor(address _address,string _Doctor_Name, uint8 _Doctor_Age,string _Doctor_Address) onlyHospital public {
        
        require(_address != 0);
        require(Doctor_Account_IsRegistered[_address] != true);
        require(Patient_Account_IsRegistered[_address] != true);
        Doctor_Account_IsRegistered[_address] = true;
        
        var doctor              = doctors[_address];
        doctor.Doctor_Account   = _address;
        Doctor_Id++;
        doctor.Doctor_ID        = Doctor_Id;
        doctor.Doctor_Name      = _Doctor_Name;
        doctor.Doctor_Age       = _Doctor_Age;
        doctor.Doctor_Address   = _Doctor_Address;
        
        NumberOfDoctors++;
        Doctor_Added(_address, Doctor_Id,_Doctor_Name,_Doctor_Age,_Doctor_Address);
        
    }
    
    function Modify_Doctor(address _address,string _Doctor_Name, uint8 _Doctor_Age,string _Doctor_Address) onlyHospital public {
        
        require(Doctor_Account_IsRegistered[_address] == true);
        
        doctors[_address].Doctor_Name       = _Doctor_Name;
        doctors[_address].Doctor_Age        = _Doctor_Age;
        doctors[_address].Doctor_Address    = _Doctor_Address;
        
        Doctor_Modified(_address,_Doctor_Name,_Doctor_Age,_Doctor_Address);
        
    }
    function Remove_Doctor(address _address) onlyHospital public {
        
        require(Doctor_Account_IsRegistered[_address] == true);
        Doctor_Account_IsRegistered[_address] = false;
        delete doctors[_address]; 
        Doctor_Removed(_address);
    }
    function Get_Doctor(address _address) onlyHospital view public returns (address, uint, string, uint8, string) {
        require( Doctor_Account_IsRegistered[_address]);
        require((msg.sender == Hospital)||(msg.sender == _address));
        return (doctors[_address].Doctor_Account,doctors[_address].Doctor_ID, doctors[_address].Doctor_Name, doctors[_address].Doctor_Age, doctors[_address].Doctor_Address);
    }
    
    //******************************************************//
    //******************************************************//
    //                                                      //
    //    Authorized Patient for Doctor Smart Contract      //
    //                                                      //
    //******************************************************//
    //******************************************************//
    
    struct ListPatientForDoctor {
        mapping (address => bool)  Patient_Account_IsAuthorized;
    }
    mapping (address => ListPatientForDoctor) listpatientfordoctors;
    
    function Authorize_Patient_For_Doctor (address _Doctor_address,address _Patient_address) onlyHospital{
        
        require(Patient_Account_IsRegistered[_Patient_address] == true);
        require(Doctor_Account_IsRegistered[_Doctor_address] == true);
        
        var listpatientfordoctor            = listpatientfordoctors[_Doctor_address];
        listpatientfordoctor.Patient_Account_IsAuthorized[_Patient_address] = true;
    }
    
    function Cancel_Patient_For_Doctor (address _Doctor_address,address _Patient_address) onlyHospital{
        
        require(Patient_Account_IsRegistered[_Patient_address] == true);
        require(Doctor_Account_IsRegistered[_Doctor_address] == true);
        
        var listpatientfordoctor            = listpatientfordoctors[_Doctor_address];
        listpatientfordoctor.Patient_Account_IsAuthorized[_Patient_address] = false;
    }
    
    function Get_Authorize_Patient_For_Doctor (address _Doctor_address,address _Patient_address) onlyHospital view public returns(bool) {
        
        require(Patient_Account_IsRegistered[_Patient_address] == true);
        require(Doctor_Account_IsRegistered[_Doctor_address] == true);
        
        return (listpatientfordoctors[_Doctor_address].Patient_Account_IsAuthorized[_Patient_address]);
    }
    
    //******************************************************//
    //******************************************************//
    //                                                      //
    //          Patient Monitoring Smart Contract           //
    //                                                      //
    //******************************************************//
    //******************************************************//
   
     modifier onlyPatient() {
        require(Patient_Account_IsRegistered[msg.sender] == true);
        _;
    }
    
    event Sensor_Data_Collected (address _Patient_Account, uint8 _Patient_HeartBeat,uint8 _Patient_BloodPressure,uint8 _Patient_Temperature);
    event Alert_Patient_HeartBeat(address _address);
    event Alert_Patient_BloodPressure(address _address);
    event Alert_Patient_Temperature(address _address);
    
    struct Patient_Monitoring {
        address     Patient_Account;
        uint8       Patient_HeartBeat;
        uint8       Patient_BloodPressure;
        uint8       Patient_Temperature;
    }
    
    mapping (address => Patient_Monitoring) patients_monitoring;
    
    function Collect_Sensor_Data(uint8 _Patient_HeartBeat,uint8 _Patient_BloodPressure,uint8 _Patient_Temperature) onlyPatient public{

        var patient_monitoring                      = patients_monitoring[msg.sender];
        patient_monitoring.Patient_Account          = msg.sender;
        patient_monitoring.Patient_HeartBeat        = _Patient_HeartBeat;
        patient_monitoring.Patient_BloodPressure    = _Patient_BloodPressure;
        patient_monitoring.Patient_Temperature      = _Patient_Temperature;
        Sensor_Data_Collected (msg.sender, _Patient_HeartBeat, _Patient_BloodPressure,_Patient_Temperature);
        
        //*****************************************//
        //      Medical Knowledge For Alert        //
        //      These below code are imagery       //
        //*****************************************//
        
        if(_Patient_HeartBeat < 60 && _Patient_HeartBeat > 100 )
            Alert_Patient_HeartBeat(msg.sender);
            
        if(_Patient_BloodPressure > 130)
            Alert_Patient_BloodPressure(msg.sender);
            
        if(_Patient_Temperature > 38)
            Alert_Patient_Temperature(msg.sender);
    }
    function Data_Sensors(address _address) view public returns (address, uint8, uint8, uint8) {
        
        require((msg.sender == Hospital)||(listpatientfordoctors[msg.sender].Patient_Account_IsAuthorized[_address]==true)|| (msg.sender == _address));
        
        return (patients_monitoring[_address].Patient_Account,patients_monitoring[_address].Patient_HeartBeat, patients_monitoring[_address].Patient_BloodPressure, patients_monitoring[_address].Patient_Temperature);
    }
    
}

