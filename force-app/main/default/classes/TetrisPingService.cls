@RestResource(urlMapping='/TetrisPingService')
global with sharing class TetrisPingService {

    @HttpGet
    global static String ping()
    {
        return 'pong';
    }

}