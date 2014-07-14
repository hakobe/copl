Z * (S(S(Z)) + S(S(Z))) evalto Z by E-Times {
    Z evalto Z by E-Const {};
    S(S(Z)) + S(S(Z)) evalto S(S(S(S(Z)))) by E-Plus {
        S(S(Z)) evalto S(S(Z)) by E-Const {};
        S(S(Z)) evalto S(S(Z)) by E-Const {};
        S(S(Z)) plus S(S(Z)) is S(S(S(S(Z)))) by P-Succ {
            S(Z) plus S(S(Z)) is S(S(S(Z))) by P-Succ {
                Z plus S(S(Z)) is S(S(Z)) by P-Zero {}
            }
        }
    };
    Z times S(S(S(S(Z)))) is Z by T-Zero {}
}
