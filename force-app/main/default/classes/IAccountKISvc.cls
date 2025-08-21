/**
 * Created by craigb on 2019-03-14.
 */

public interface IAccountKISvc {

    /**
    * getKeyData - returns keyData from implementing interfaces
    */
    List<AccountKeyInfoWrapper> getKeyData(String recordId);



}