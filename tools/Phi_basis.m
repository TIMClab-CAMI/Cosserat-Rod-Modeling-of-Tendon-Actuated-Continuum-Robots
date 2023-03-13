function Phi = Phi_basis(X, Const)

    X = X/Const.l_j(Const.it_segment);

    % Legendre coefficients
    M_cheb = [ 1    0     0      0      0       0       0        0;
              -1    2     0      0      0       0       0        0;
               1   -6     6      0      0       0       0        0;
              -1   12   -30     20      0       0       0        0;
               1  -20    90   -140     70       0       0        0;
              -1   30  -210    560   -630     252       0        0;
               1  -42   420  -1680   3150   -2772     924        0;
              -1   56  -756   4200 -11550   16632  -12012     3432;
               1  -72  1260  -9240  34650  -72072   84084   -51480;
              -1   90 -1980  18480 -90090  252252 -420420   411840;
               1 -110  2970 -34320 210210 -756756 1681680 -2333760];

    b = M_cheb*[1 X X^2 X^3 X^4 X^5 X^6 X^7]';

    Phi = zeros(6, Const.basis_dim_j);
    idx = 1;
    for i = 1:6 % for each of the xyz linear and angular strains
        k = Const.basis_dim_k(i);
        Phi(i, idx:idx + k - 1) = b(1:k)';
        idx = idx + k;
    end

end
