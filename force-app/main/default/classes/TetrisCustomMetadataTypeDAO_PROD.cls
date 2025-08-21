global class TetrisCustomMetadataTypeDAO_PROD implements ITetrisCustomMetadataTypeDAO{
  //// Avalara Base URL that the other configs can reference and use via relative url
    global static String getAvalaraBaseEndpoint() {
      String resourceName = 'PROD_Avalara_Base_Endpoint';
      return resourceName;
    }
}