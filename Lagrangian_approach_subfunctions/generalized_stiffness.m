function Kee = generalized_stiffness(Const)

    % definition of the nodes on a grid [0, l_j]
    n_nodes = Const.n_nodes;
    [DX, X_grille] = cheb(n_nodes - 1, Const.l_j(Const.it_segment));

    % shape functions
    Phi = zeros(6, Const.basis_dim_j, n_nodes);
    for it_x = 1:n_nodes
        Phi(:, :, it_x) = Phi_basis(X_grille(it_x), Const);
    end

    % hookean stiffness matrix
    H = Const.H;

    % generalized stiffness matrix
    Kee = zeros(Const.basis_dim_j);
    a = 1;
    b = 0;
    for it_Kee = 1:6
        k = Const.basis_dim_k(it_Kee);
        b = b + k;
        dim_ab = b - a + 1;
        IC = zeros(dim_ab*dim_ab, 1);
        BC_idx = (0:dim_ab*dim_ab - 1)*n_nodes + 1;
        f_B = @(it) reshape(Phi(it_Kee, a:b, it)'*H(it_Kee, it_Kee) ...
                                *Phi(it_Kee, a:b, it), [dim_ab*dim_ab, 1]);
        KeeX = spectral_integration_0_B(f_B, IC, DX, n_nodes, BC_idx);
        Kee(a:b, a:b) = reshape(KeeX(:, end), [dim_ab dim_ab]);
        a = a + k;
    end

end
