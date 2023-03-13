function L = actuation_matrix(Const)

    L = zeros(Const.basis_dim, Const.dim_tendon);

    for j = 1:Const.n_segments

        n_nodes = Const.n_nodes; % number of nodes
        R0 = quat2rot(Const.Q0); % robot orientation in inertial frame

        % compute xi and position of the tendons Di on a grid [0, l_j]
        [DX, X_grille] = cheb(n_nodes - 1, Const.l_j(j));
        Phi = zeros(6, Const.basis_dim_j, n_nodes);
        xi = zeros(6, n_nodes);
        D_i = zeros(3, Const.dim_tendon, n_nodes);
        D_iX = zeros(3, Const.dim_tendon, n_nodes);
        for it_x = 1:n_nodes
            X = X_grille(it_x);
            % xi
            Phi(:, :, it_x) = Phi_basis(X, Const);
            epsilon = Phi(:, :, it_x)*Const.q(1 + (j - 1) ...
                *Const.basis_dim_j:j*Const.basis_dim_j);
            xi(:, it_x) = epsilon + Const.xi0;
            % position of the tendons
            active_tendons = j <= 1:Const.n_segments;
            active_tendons = repmat(active_tendons, Const.dim_tendon_i, 1);
            active_tendons = active_tendons(:);
            for it = 1:Const.dim_tendon
                [D, dD] = tendons(Const.routing, j, it, X);
                D_i(:, it, it_x) = R0'*D;
                D_iX(:, it, it_x) = R0'*dD;
            end
        end

        % actuation matrix (per segment)
        L_j = zeros(Const.basis_dim_j, Const.dim_tendon);
        IC = zeros(Const.basis_dim_j, 1);
        BC_idx = (0:Const.basis_dim_j - 1)*n_nodes + 1;
        for it_L =1:Const.dim_tendon
            f_B = @(it) -active_tendons(it_L).*Phi(:, :, it)' ...
                *[hat(D_i(:, it_L, it))*(xi(4:6, it) + hat(xi(1:3, it)) ...
                *D_i(:, it_L, it) + D_iX(:, it_L, it)); ...
                (xi(4:6, it) + hat(xi(1:3, it)) ...
                *D_i(:, it_L, it) + D_iX(:, it_L, it))] ...
                /norm(xi(4:6, it) + hat(xi(1:3, it)) ...
                *D_i(:, it_L, it) + D_iX(:, it_L, it));

            L_jX = spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx);
            L_j(:, it_L) = L_jX(:, end);
        end

        % fill full actuation matrix
        range = 1 + (j - 1)*Const.basis_dim_j:j*Const.basis_dim_j;
        L(range, :) = L_j;

    end

end
