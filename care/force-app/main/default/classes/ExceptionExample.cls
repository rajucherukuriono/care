public class ExceptionExample {
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}

    public static void testCustomException(Integer i) {
            if (i < 5) throw new CustomException('This is bad');
        
    }
}