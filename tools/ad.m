function M = ad(G)

    W = G(1:3);
    U = G(4:6);

    ad11 = hat(W);
    ad12 = zeros(3);
    ad21 = hat(U);

    M = [ad11, ad12; ad21, ad11];

end
