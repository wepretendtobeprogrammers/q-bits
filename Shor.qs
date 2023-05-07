namespace Shor {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arithmetic;

    operation QuantumPeriodFinding (a : Int, N : Int, registerSize : Int) : (Int, Bool[]) {
        let periodRegister = Qubit[registerSize];

        repeat {
            ApplyToEachA(ModularExp(a, _, N), periodRegister);
        } until (PhaseEstimationAsInt(Reverse([periodRegister]))) < registerSize;

        let result = PhaseEstimation(Reverse([periodRegister]), registerSize);

        let period = ContinuedFractionPeriod(result);
        let even = (period % 2 == 0);

        return (period, [even]);
    }

    function ShorAlgorithm (N : Int) : Int[] {
        mutable factors = new Int[2];
        mutable foundFactors = false;

        repeat {
            let a = RandomInt(2, N - 1);
            let gcdValue = GCD(a, N);
            if (gcdValue > 1) {
                set factors = [gcdValue, N / gcdValue];
                set foundFactors = true;
                break;
            }

            for (i in 1..Log2(N)) {
                let (period, even) = QuantumPeriodFinding(a, N, i);

                if (even) {
                    let candidateFactor = PowI(a, period / 2) + 1;
                    let factor1 = GCD(candidateFactor, N);
                    let factor2 = GCD(candidateFactor - 2, N);

                    if (factor1 != 1 and factor1 != N) {
                        set factors = [factor1, N / factor1];
                        set foundFactors = true;
                        break;
                    } elseif (factor2 != 1 and factor2 != N) {
                        set factors = [factor2, N / factor2];
                        set foundFactors = true;
                        break;
                    }
                }
            }
        } until (foundFactors);

        return factors;
    }
}
