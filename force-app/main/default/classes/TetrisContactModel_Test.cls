@isTest(SeeAllData=false) 
private class TetrisContactModel_Test {

    static testMethod void testSettersGetters() {
		TetrisContactModel tetrisContactModel = new TetrisContactModel();
		
		tetrisContactModel.firstName = 'Smith';
	    tetrisContactModel.lastName = 'Doe';
	    tetrisContactModel.email = 'smith.doe@test.com';
	    tetrisContactModel.phone = '222 223 2222';
	    tetrisContactModel.contactId = '0030E00000EpNl2';
	    tetrisContactModel.streetAddress = 'Street 1';
	    tetrisContactModel.city = 'Winerish';
	    tetrisContactModel.state = 'Winerish';
	    tetrisContactModel.country = 'United Kingdom';
	    tetrisContactModel.postalCode = '121122';  
        tetrisContactModel.emailOptout = true;  
        Datetime optOutTime = system.now();
        tetrisContactModel.optInOutTime = system.now();  
	    
	    system.assertEquals(tetrisContactModel.firstName , 'Smith');
	    system.assertEquals(tetrisContactModel.lastName , 'Doe');
	    system.assertEquals(tetrisContactModel.email , 'smith.doe@test.com');
	    system.assertEquals(tetrisContactModel.phone , '222 223 2222');
	    system.assertEquals(tetrisContactModel.contactId , '0030E00000EpNl2');
	    system.assertEquals(tetrisContactModel.streetAddress , 'Street 1');
	    system.assertEquals(tetrisContactModel.city , 'Winerish');
	    system.assertEquals(tetrisContactModel.state , 'Winerish');
	    system.assertEquals(tetrisContactModel.country , 'United Kingdom');
	    system.assertEquals(tetrisContactModel.postalCode , '121122');
        system.assertEquals(tetrisContactModel.emailOptout , true);
        system.assertEquals(tetrisContactModel.optInOutTime , optOutTime);
	    
    }
}