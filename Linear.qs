namespace Quantum.LinearSystemsSolver {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    operation StatePreparation(y : Double[], A : Double[][]) : (Qubit[] => Unit is Adj + Ctl) {
        let n = Length(A);

        let numQubits = 2 * Log2(n) + 1;

        use qs = Qubit[numQubits];

        X(qs[numQubits - 1]);
        H(qs[numQubits - 1]);

        for (i in 0 .. n - 1) {
            H(qs[i]);
        }

        for (i in 0 .. n - 1) {
            let angle = 2.0 * ArcSin(Sqrt(A[i][i]) / Norm(A[i]));
            Controlled R1([qs[i]], (angle, qs[n .. 2 * n - 1]));
        }

        for (i in 0 .. n - 1) {
            for (j in i + 1 .. n - 1) {
                Controlled SWAP([qs[i], qs[j]], qs[n .. 2 * n - 1]);
            }
        }

        IQuantumFourierTransform(qs[0 .. n - 1]);

        return (_ => ());
    }

    operation HHL(y : Double[], A : Double[][]) : Double[] {
        let n = Length(A);

        use qs = Qubit[2 * Log2(n) + 1];

        StatePreparation(y, A)(qs);

        let measurementResult = MultiM(qs[0 .. n - 1]);

        let beta = BinaryFractionFromInt(MostSignificantBitFirst, measurementResult);

        let D = DiagonalMatrix([Sqrt(A[i][i]) / Norm(A[i]) | i in 0 .. n - 1]);

        let invD = DiagonalMatrix([1.0 / D[i][i] | i in 0 .. n - 1]);

        let U = MatrixMultiply(D, A, invD);

        ApplyUnitary(Matrix(U), qs[n .. 2 * n - 1]);

        let measurementResult2 = MultiM(qs[n .. 2 * n - 1]);

        let gamma = BinaryFractionFromInt(MostSignificantBitFirst, measurementResult2);

        // Calculate the solution vector x.
        let x = MatrixMultiply(invD, MatrixMultiply(ConjugateTranspose(U), Matrix([beta, gamma])));
        return x;
    }
}
