function X = spectral_integration_A_0(f_A, IC, DX, n_nodes, BC_idx)

    n = max(size(IC));

    A = zeros(n*n_nodes);

    k = double(num2str(dec2bin(n))) - double('0'); % binary decomposition
    D = [];
    for i = flip(k) % reverse binary decomposition
        if i == 1
            D = blkdiag(D, DX); % concatenate
        end
        DX = blkdiag(DX, DX); % double
    end

    % changing de IC init
    P = eye(size(A));
    for i = 1:n
        P_sauv = P(:, i);
        P(:, i) = P(:, BC_idx(i));
        P(:, BC_idx(i)) = P_sauv;
    end

    for it_x = 1:n_nodes
        A_xi = f_A(it_x);
        for it_r = 1:n
            for it_c = 1:n
                l = it_x + (it_r - 1)*n_nodes;
                m = it_x + (it_c - 1)*n_nodes;
                A(l, m) = A_xi(it_r, it_c);
            end
        end
    end

    A = P'*A*P;
    D = P'*D*P;

    BC = (D(:, 1:n) - A(:, 1:n))*IC;
    res = (D(n + 1:end, n + 1:end) - A(n + 1:end, n + 1:end)) ...
                                                        \-BC(n + 1:end, 1);
    X_x = P*[IC; res];
    X_x_M = reshape(X_x, [n_nodes, n]);
    X = X_x_M';

end
