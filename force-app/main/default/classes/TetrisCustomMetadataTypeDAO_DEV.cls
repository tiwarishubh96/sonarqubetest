global class TetrisCustomMetadataTypeDAO_DEV implements ITetrisCustomMetadataTypeDAO {
        
  //// Avalara Base URL that the other configs can reference and use via relative url
    global static String getAvalaraBaseEndpoint() {
      String resourceName = 'DEV_Avalara_Base_Endpoint';
      return resourceName;
    }
}