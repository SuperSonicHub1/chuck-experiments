// Reference wrapper for int in the style of java.lang.Integer
public class IntRef {
    int i;
    
    fun @construct(int i) {
        i => this.i;
    }
    
    fun @construct() {
        IntRef(0);
    }
}
