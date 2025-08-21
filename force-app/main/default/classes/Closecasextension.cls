public class Closecasextension
{

    public Closecasextension(ApexPages.StandardController controller) {

    }

        public Closecasextension()
   {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, '');
        ApexPages.addMessage(msg);
    }
}