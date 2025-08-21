/**
* @author Prasanti Avula, Docmation
* @creationDate August 12, 2017
*
* @description Wrapper Class with Address Related info. This is used in TETRIS R2.
*
* Modification Log
* ------------------------------------------------------------------------------------------------------------
* 1.0 - August 12, 2017 - Prasanti Avula
*       Created the initial version of Wrapper Class.
* ------------------------------------------------------------------------------------------------------------
*/
global class TetrisAddressModel {
    
    global String addressLine1{set;get;}
    global String addressLine2{set;get;}
    //added this variable for Address verification
    global String street{set;get;}
    global String city{set;get;}
    global String state{set;get;}
    global String country{set;get;}
    global String postalCode{set;get;}

}