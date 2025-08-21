global class TetrisAddressVerificationResponseVO {
    
    global Boolean success{set;get;}
    global List<Result> result{set;get;}
   	global List<Errors> errors{set;get;}
    
    global Class Result{
        global String mailabilityScore{set;get;}
        global String resultPercentage{set;get;}
        global Address address{set;get;}
    }
    
    global class Address{
        global String street{set;get;}
        global String country{set;get;}
        global String province{set;get;}
        global String locality{set;get;}
        global String county{set;get;}
        global String postalCode{set;get;}
        global String houseNumber{set;get;}
        global String deliveryAddressLines{set;get;}
        global String countrySpecificLocalityLine{set;get;}
        global List<String> formattedAddress{set;get;}
        global Integer autoNumber{set;get;}
    }
    
     global class Errors{
        global String message{set;get;}
        global String errorCode{set;get;}
   	}
}