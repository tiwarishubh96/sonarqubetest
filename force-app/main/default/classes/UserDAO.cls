public class UserDAO implements IUserDAO{

    public interface IUserDAO {
        Contact getContactById(String id);
        List<Contact> insertContacts(List<Contact> contacts);
    }

    public Contact getContactById(String id){
        return [SELECT Id FROM Contact WHERE Id =: id];
    }
    
    public List<Contact> insertContacts(List<Contact> contacts){
        insert contacts;
        return contacts;
    }
}