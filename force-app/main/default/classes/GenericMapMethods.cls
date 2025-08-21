/**
@date 18-Jun-2019
@description Generic helper class for any Maps

*/

public class GenericMapMethods {
    
    // converts all maps keys to lowercase
    public  static map<string,SObject> convertTolowerAllkeys(Map<string,SObject> v){
      Map<string,SObject> newMap = new  map<string,SObject> ();
      for(string key : v.keySet()){
         newMap.put(key.toLowerCase(),v.get(key));
      }
      return newMap;
  }

}