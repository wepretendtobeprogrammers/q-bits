namespace qBits {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;

    // Custom operation that applies a random unitary to a qubit
    operation ApplyRandomUnitary(q : Qubit) : Unit is Adj {
        let unitary = RandomUnitary(2);
        ApplyUnitary(unitary, q);
    }

    // Custom operation that applies a bit flip error to a qubit with some probability
    operation ApplyBitFlipError(q : Qubit, probability: Double) : Unit is Adj {
        if (RandomDouble() < probability) {
            X(q);
        }
    }

    // Custom operation that prepares a GHZ state
    operation PrepareGHZState(qs : Qubit[]) : Unit {
        H(qs[0]);
        for i in 1 .. Length(qs) - 1 {
            CNOT(qs[i-1], qs[i]);
        }
    }

    // Custom operation that measures a set of qubits and returns the measurement results as an array of booleans
    operation Measure(qs : Qubit[]) : Bool[] {
        mutable resultArray = new Bool[Length(qs)];
        
        for i in IndexRange(qs) {
            set resultArray w/= i <- M(qs[i]) == One;
        }

        ResetAll(qs);

        return resultArray;
    }

    @EntryPoint()
    operation Perform() : Bool[] {
        // Allocate qubits
        use qs = Qubit[3];
        
        // Prepare a GHZ state
        PrepareGHZState(qs);

        // Apply random unitaries
        ApplyRandomUnitary(qs[0]);
        ApplyRandomUnitary(qs[1]);
        ApplyRandomUnitary(qs[2]);

        Controlled R1([qs[1], qs[2]], (PI()/4.0, qs[0]));
        Controlled R1([qs[0], qs[2]], (PI()/2.0, qs[1]));
        Controlled R1([qs[0], qs[1]], (PI()/2.0, qs[2]));

        ApplyBitFlipError(qs[0], 0.1);
        ApplyBitFlipError(qs[1], 0.05);
        ApplyBitFlipError(qs[2], 0.2);

        // Measure qubits and get the measurement results
        let results = Measure(qs);

        Message("Measurement Results: ");
        for r in results {
            Message($"{r}");
        }

        return results;
    }
}
