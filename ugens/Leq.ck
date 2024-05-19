public class Leq extends Rhs {
    fun @construct(float rhs) {
        Rhs(rhs);
    }

    fun float tick(float in) {
        return in <= rhs();
    }
}
