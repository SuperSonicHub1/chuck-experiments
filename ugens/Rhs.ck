public class Rhs extends Chugen {
    float _rhs;

    fun @construct(float rhs) {
        rhs => this._rhs;
    }

    fun float rhs() {
        return this._rhs;
    }

    fun float rhs(float newRhs) {
        newRhs => this._rhs;
        return newRhs;
    }
}
