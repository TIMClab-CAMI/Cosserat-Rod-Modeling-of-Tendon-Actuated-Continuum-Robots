function X = spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx)

    n = max(size(IC));

    b = zeros(n*n_nodes, 1);

    k = double(num2str(dec2bin(n))) - double('0'); % binary decomposition
    D = [];
    for i = flip(k) % reverse binary decomposition
        if i == 1
            D = blkdiag(D, DX); % concatenate
        end
        DX = blkdiag(DX, DX); % double
    end

    % changing de IC init
    P = eye(n*n_nodes);
    for i = 1:n
        P_sauv = P(:, i);
        P(:, i) = P(:, BC_idx(i));
        P(:, BC_idx(i)) = P_sauv;
    end

    for it_x = 1:n_nodes
        b_xi = f_B(it_x);
        for it_r = 1:n
            b(it_x + (it_r - 1)*n_nodes, 1) = b_xi(it_r, 1);
        end
    end

    b = P'*b;
    D = P'*D*P;

    BC = D(:, 1:n)*IC;
    res = D(n + 1:end, n + 1:end)\(b(n + 1:end, 1) - BC(n + 1:end, 1));
    X_x = P*[IC; res];
    X_x_M = reshape(X_x, [n_nodes, n]);
    X = X_x_M';

end
