/***
Created by: Vivek Suryawanshi.
Date:6/1/2012
Description: It consist of static flag which is used to prevent recursion of trigger named "winningOpportunity". 
***/


public class disableTrigger {

    // Static variables are local to the context of a Web request  
    
    // (or testMethod during a runTests call)  
    
    // Therefore, this variable will be initialized as false  
    
    // at the beginning of each Web request which accesses it.  
    

    private static boolean Toggle = false;
    private static boolean Toggle2 = false;


    public static boolean hasToggle() {
        return Toggle;
    }
    
    public static boolean hasToggle2() {
        return Toggle2;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setToggleTrue() {
        Toggle= true;
    }
     
      public static void setToggleFalse() {
        Toggle = false;
    } 
    
    public static void setToggle2True() {
        Toggle2 = true;
    }
     
      public static void setToggle2False() {
        Toggle2 = false;
    } 

    

}