(S(S(Z)) + S(S(Z))) * Z evalto Z by E-Times {
    S(S(Z)) + S(S(Z)) evalto S(S(S(S(Z)))) by E-Plus {
        S(S(Z)) evalto S(S(Z)) by E-Const {};
        S(S(Z)) evalto S(S(Z)) by E-Const {};
        S(S(Z)) plus S(S(Z)) is S(S(S(S(Z)))) by P-Succ {
            S(Z) plus S(S(Z)) is S(S(S(Z))) by P-Succ {
                Z plus S(S(Z)) is S(S(Z)) by P-Zero {}
            }
        }
    };
    Z evalto Z by E-Const {};
    S(S(S(S(Z)))) times Z is Z by T-Succ {
        S(S(S(Z))) times Z is Z by T-Succ {
            S(S(Z)) times Z is Z by T-Succ {
                S(Z) times Z is Z by T-Succ {
                    Z times Z is Z by T-Zero {};
                    Z plus Z is Z by P-Zero {}
                };
                Z plus Z is Z by P-Zero {}
            };
            Z plus Z is Z by P-Zero {}
        };
        Z plus Z is Z by P-Zero {}
    }
}
