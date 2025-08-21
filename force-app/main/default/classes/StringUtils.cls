/***********************************************************************************************************
Name    : StringUtils
Author  : Junaid Mohammed
Date    : 09/18/2017
Usage   : Standard developer tools not supplied by the framework for manipulating Strings

************************************************************************************************************/
global class StringUtils  
{
    
    /** 
     * Returns true if strArg is '' or null, else false 
     * @param strArg is the String to inspect
     * @return true if strArg is '' or null, else false 
     */
    public static boolean isEmpty(String strArg)
    {
        if(strArg == null || strArg == '')
            return true;
        else
            return false;
    }
    
    /** 
     * Returns true if strArg contains only numbers, else false 
     * @param strArg is the String to inspect
     * @return true if strArg contains only numbers, else false
     */
    public static boolean isIntegerOnly(String strArg) 
    {
        if(isEmpty(strArg))
            return false;
        else
        {
            try
            {
                Integer.valueOf(strArg);
            }
            catch(TypeException te)
            {
                return false;
            }

            return true;
        }
    }
    
    /** 
     * Returns a random string based on the integer provided 
     * @param len - length of the string to return
     * @return - the randomly generated string
     */
    public static List<String> createListAlphaNumerics(Integer size , Integer len) 
    {
    		List<String> lstAlphaNumeric = new List<String>();
    		for(integer i=0; i<size; i++)
    		{
	        String strAlphaNumeric = createRandomString(len) ;
	        strAlphaNumeric+= createRandomNumber(len);
	        system.debug('strAlphaNumeric : '+strAlphaNumeric);
	        lstAlphaNumeric.add(strAlphaNumeric);
    		}
    		system.debug('lstAlphaNumeric : '+lstAlphaNumeric);
        return lstAlphaNumeric;
    }
    
    /** 
     * Returns a random string based on the integer provided 
     * @param len - length of the string to return
     * @return - the randomly generated string
     */
    public static String createAlphaNumeric(Integer len) 
    {
        String strAlphaNumeric = createRandomString(len) ;
        strAlphaNumeric+= createRandomNumber(len);
        system.debug('strAlphaNumeric : '+strAlphaNumeric);
        return strAlphaNumeric;
    }

    /** 
     * Returns a random string based on the integer provided 
     * @param len - length of the string to return
     * @return - the randomly generated string
     */
    public static String createRandomString(Integer len) 
    {
        String strBase = 'abcdefghijklmnopqrstuvwxyz';
        String strReturn = '';
        for (Integer iCtr1 = 0; iCtr1 < len; iCtr1 ++)
        {
            Integer intStart = Math.round((Math.random()*25));
            strReturn= strReturn + strBase.substring(intStart,intStart+1);
        }   
        return strReturn;
    }

    /** 
     * Returns a random number string of 'len' length 
     * @param len - length of the string to return
     * @return - the randomly generated string
     */ 
    public static String createRandomNumber(Integer len) 
    {
        Integer size = 10;
        for (Integer iCtr1 = 1; iCtr1 < len; iCtr1 ++)
        {
            size = size *10;
        }   
        return String.valueOf((Math.random()*size).intValue());
    }
    
}