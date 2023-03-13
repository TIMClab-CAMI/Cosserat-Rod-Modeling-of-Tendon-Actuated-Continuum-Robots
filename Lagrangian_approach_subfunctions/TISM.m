function [Q_ext_T, J] = TISM(Const)

    n_nodes = Const.n_nodes; % number of nodes
    Q0 = Const.Q0; % orientation of the robot in the inertial frame

    X_grille_T = zeros(1, n_nodes*Const.n_segments);
    xi_T = zeros(6, n_nodes*Const.n_segments);
    QX_T = zeros(4, n_nodes*Const.n_segments);
    LambdaX_T = zeros(6, n_nodes*Const.n_segments);
    Q_ext_T = zeros(Const.basis_dim, 1);

    % forward kinematics
    for j = 1:Const.n_segments

        Const.it_segment = j;

        % compute space-rate twist xi on a grid [0, l_j]
        [DX, X_grille] = cheb(n_nodes - 1, Const.l_j(j));
        rangeN = 1 + (j - 1)*n_nodes:j*n_nodes;
        X_grille_T(rangeN) = X_grille';
        Phi = zeros(6, Const.basis_dim_j, n_nodes);
        xi = zeros(6, n_nodes);
        for it_x = 1:n_nodes
            Phi(:, :, it_x) = Phi_basis(X_grille(it_x), Const);
            epsilon = Phi(:, :, it_x)*Const.q(1 + (j - 1)* ...
                Const.basis_dim_j:j*Const.basis_dim_j);
            xi(:, it_x) = epsilon + Const.xi0;
        end
        xi_T(:, rangeN) = xi;

        % orientation (quaternions) Q
        IC = Q0;
        BC_idx=[1, n_nodes + 1, 2*n_nodes + 1, 3*n_nodes + 1];
        f_A = @(it) quaternion_dot_omega(xi(1:3, it));
        QX = spectral_integration_A_0(f_A, IC, DX, n_nodes, BC_idx);
        QX_T(:, rangeN) = QX;
        Q0 = QX(:, end);

    end

    % backward statics
    for j = Const.n_segments:-1:1

        Const.it_segment = j;

        rangeN = 1 + (j - 1)*n_nodes:j*n_nodes;
        X_grille = X_grille_T(rangeN)';
        QX = QX_T(:, rangeN);
        xi = xi_T(:, rangeN);

        for it_x = 1:n_nodes
            Phi(:, :, it_x) = Phi_basis(X_grille(it_x), Const);
            [Fl, F_bar(:, it_x)] = ...
                       external_forces(X_grille(it_x), QX(:, it_x), Const);
        end

        if j == Const.n_segments
            Fl_j = Fl;
        end

        % stresses Lambda
        IC = Fl_j;
        BC_idx = (1:6)*n_nodes;
        f_A = @(it) ad(xi(:, it))';
        f_B = @(it) -F_bar(:, it);
        LambdaX = spectral_integration(f_A, f_B, IC, DX, n_nodes, BC_idx);
        Fl_j = LambdaX(:, 1);
        LambdaX_T(:, rangeN) = LambdaX;

        % generalized external forces Q_ext
        IC = zeros(Const.basis_dim_j, 1);
        BC_idx = (1:Const.basis_dim_j)*n_nodes;
        f_B = @(it) -Phi(:, :, it)'*LambdaX(:, it);
        Q_extX = spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx);
        Q_ext = -Q_extX(:, 1);
        rangeB = 1 + (j - 1)*Const.basis_dim_j:j*Const.basis_dim_j;
        Q_ext_T(rangeB) = Q_ext;
    end

    % variational part:
    % generalized coordinate variations delta_q
    % -> construction of the Jacobian matrix J
    J = zeros(Const.basis_dim);

    for it_D_q = 1:Const.basis_dim

        delta_zetaX_T = zeros(6, n_nodes*Const.n_segments);
        delta_Q_ext_T = zeros(Const.basis_dim, 1);
        delta_xi_T = zeros(6, n_nodes*Const.n_segments);
        delta_q_T = zeros(Const.basis_dim, 1);
        delta_q_T(it_D_q, 1) = 1;
        delta_zeta0 = zeros(6, 1);

        % forward kinematics
        for j = 1:Const.n_segments

            Const.it_segment = j;

            % space-rate twist vraiation delta_xi
            rangeN = 1 + (j - 1)*n_nodes:j*n_nodes;
            rangeB = 1 + (j - 1)*Const.basis_dim_j:j*Const.basis_dim_j;
            delta_q = delta_q_T(rangeB, 1);
            xi = xi_T(:, rangeN);
            delta_xi = zeros(6, n_nodes);
            for it_x = 1:n_nodes
                Phi(:, :, it_x) = Phi_basis(X_grille(it_x), Const);
                delta_xi(:, it_x) = Phi(:, :, it_x)*delta_q;
            end
            delta_xi_T(:, rangeN) = delta_xi;

            % virtual displacements variation delta_zeta
            IC = delta_zeta0;
            BC_idx= (0:5)*n_nodes + 1;
            f_A = @(it) -ad(xi(:, it));
            f_B = @(it) delta_xi(:, it);
            delta_zetaX = ...
                   spectral_integration(f_A, f_B, IC, DX, n_nodes, BC_idx);
            delta_zeta0 = delta_zetaX(:, end);
            delta_zetaX_T(:, rangeN) = delta_zetaX;
        end

        % backward statics
        for j = Const.n_segments:-1:1

            Const.it_segment = j;

            % stresses variations delta_Lambda
            rangeN = 1 + (j - 1)*n_nodes:j*n_nodes;
            QX = QX_T(:, rangeN);
            xi = xi_T(:, rangeN);
            delta_xi = delta_xi_T(:, rangeN);
            delta_zetaX = delta_zetaX_T(:, rangeN);
            LambdaX = LambdaX_T(:, rangeN);
            for it_x = 1:n_nodes
                Phi(:, :, it_x) = Phi_basis(X_grille(it_x), Const);
                [Fl, F_bar(:, it_x)] = ...
                       external_forces(X_grille(it_x), QX(:, it_x), Const);
                delta_F_bar(:, it_x)= [zeros(3, 1); ...
                              hat(delta_zetaX(:, it_x))'*F_bar(4:6, it_x)];
            end
            if j == Const.n_segments
                delta_Fl_j = [zeros(3, 1); ...
                                       hat(delta_zetaX(:, it_x))'*Fl(4:6)];
            end
            IC = delta_Fl_j;
            BC_idx = (1:6)*n_nodes;
            f_A = @(it) ad(xi(:, it))';
            f_B = @(it) ad(delta_xi(:, it))'*LambdaX(:, it) ...
                                                      - delta_F_bar(:, it);
            delta_LambdaX = ...
                   spectral_integration(f_A, f_B, IC, DX, n_nodes, BC_idx);
            delta_Fl_j = delta_LambdaX(:, 1);

            % generalized external forces variations delta_Q_ext
            IC = zeros(Const.basis_dim_j, 1);
            BC_idx = (1:Const.basis_dim)*n_nodes;
            f_B = @(it) -Phi(:, :, it)'*delta_LambdaX(:, it);
            delta_Q_extX = ...
                    spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx);
            delta_Q_ext = -delta_Q_extX(:, 1);
            rangeB = ...
                 1 + (j - 1)*Const.basis_dim_j:j*Const.basis_dim_j;
            delta_Q_ext_T(rangeB) = delta_Q_ext;
        end
        J(:, it_D_q) = delta_Q_ext_T;

    end

end