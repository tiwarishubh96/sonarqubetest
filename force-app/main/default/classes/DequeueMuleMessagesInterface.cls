public interface DequeueMuleMessagesInterface {
    List<String> getEventIds();
    void updateCases(String resultResponse,List<String> dequeueEventIds);

}