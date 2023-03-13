function [QX_T, rX_T] = reconstruction(Const)

    n_nodes = Const.n_nodes; % number of nodes
    Q0 = Const.Q0; % orientation of the robot in the inertial frame
    r0 = Const.r0; % position of the robot in the inertial frame

    QX_T = zeros(4, Const.n_segments*n_nodes);
    rX_T = zeros(3, Const.n_segments*n_nodes);
    for j = 1:Const.n_segments

        Const.it_segment = j;

        % compute space-rate twist xi on a grid [0, l_j]
        [DX, X_grille] = cheb(n_nodes - 1, Const.l_j(j));
        xi = zeros(6, n_nodes);
        for it_x = 1:n_nodes
            Phi = Phi_basis(X_grille(it_x), Const);
            epsilon = Phi*Const.q(1 + (j - 1)*Const.basis_dim_j: ...
                j*Const.basis_dim_j);
            xi(:, it_x) = epsilon + Const.xi0;
        end
        BC_idx = [1, n_nodes + 1, 2*n_nodes + 1, 3*n_nodes + 1];

        % orientation (quaternions) Q
        IC = Q0;
        f_A = @(it) quaternion_dot_omega(xi(1:3, it));
        QX = spectral_integration_A_0(f_A, IC, DX, n_nodes, BC_idx);
        QX_T(:, (j - 1)*n_nodes + 1:(j)*n_nodes) = QX;
        Q0 = QX(:, end);

        % position r
        IC = r0;
        f_B = @(it) r_dot(QX(:, it), xi(4:6, it));
        rX = spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx);
        rX_T(:, (j - 1)*n_nodes + 1:(j)*n_nodes) = rX;
        r0 = rX(:, end);

    end

end
