/**
 * Created by taa on 07/05/2020.
 */

public with sharing class TetrisValidateResult {
    public class Response{
        public String success{set;get;}
        public Result result{set;get;}
        public List<Errors> errors{set;get;}
    }

    public class Errors{
        public String message{set;get;}
        public String errorCode{set;get;}
    }

    public class Result {
        public Boolean valid {set;get;}
        public String requestType {set;get;}
        public String message {set;get;}
        public Boolean warning {set;get;}
        public String warningMessage {set;get;}
    }
}