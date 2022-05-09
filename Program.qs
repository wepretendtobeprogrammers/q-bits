namespace uhOh {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    
    @EntryPoint()
    operation Perform() : Result[] {
        // qubits are automatically allocated in the |0> state
        use qs = Qubit[3];

        mutable resultArray = [Zero, size = 3];
        //  ^ allows us to modify the variable later (ex: for the results). 
        
        // qubit 1
        H(qs[0]);
        Controlled R1([qs[1]], (PI()/2.0, qs[0]));
        Controlled R1([qs[2]], (PI()/4.0, qs[0]));

        // qubit 2
        H(qs[1]);
        Controlled R1([qs[2]], (PI()/2.0, qs[1]));
        //                      ^ PI is used to define the rotations (terms of radians)

        // qubit 3
        H(qs[2]);

        SWAP(qs[2], qs[0]);

        Message("Right before measurement: ");
        // prints systems current state to the console
        DumpMachine();
        
        // this may be complex, but really isnt. 
        // this syntax is unique to Q#, though the set resultArray ... can be seen in F# or R.
        for i in IndexRange(qs) {
            set resultArray w/= i <- M(qs[i]);
        //  ^ is to reassign variables that are bound with "mutable"
        }

        Message("Now, after measurement: ");
        DumpMachine(); // as we said above, current state of the system
        ResetAll(qs);

        Message("Post result of measurement: [qubit0, qubit1, qubit2]: ");
        return resultArray;
    }
}

