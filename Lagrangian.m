function Lagrangian(routing, ls, tau)

    addpath('./tools');
    addpath('./Lagrangian_approach_subfunctions');

    Const.n_nodes = 10; % number of nodes

    % robot and tendon configuration
    Const.routing = routing;
    [~, ~, ~, n_segments, n_tendons, l_j] = tendons(Const.routing);

    Const.n_segments = n_segments; % number of segments
    Const.dim_tendon_i = max(n_tendons); % number of tendons per segment
    Const.dim_tendon = Const.n_segments*Const.dim_tendon_i; % total tendons
    Const.l_j = l_j; % length of each segment
    l = sum(l_j); % length of the robot (all segments combined)
    Const.tau = tau'; % cabel tensions
    Const.loading_steps = ls;

    % definition of the order of the shape functions for each strain comp.:
    % torsion-x, bending-y, bending-z, extension-x, shear-y, shear-z
    Const.basis_dim_k = [5, 7, 7, 3, 3, 3];
    Const.basis_dim_j = sum(Const.basis_dim_k); % total size per segement
    Const.basis_dim = Const.n_segments*Const.basis_dim_j; % total size

    % independent parameters
    [E, Gj, R_b, rho] = materials();
    grav = 9.81; % [N/kg] % gravity acceleration constant

    % boundary conditions (BC)
    Const.r0 = [0; 0; 0]; % position of the robot in the inertial frame
    Const.Q0 = rot2quat([0 0 -1; 0 1 0; 1 0 0]); % orientation """
    Const.xi0 = [0; 0; 0; 1; 0; 0]; % initial space-rate twist

    % dependent parameter calculations
    area = pi*R_b^2; % cross-sectional area
    I = pi*R_b^4/4;
    J = 2*I;
    Const.H = diag([Gj*J, E*I, E*I, E*area, Gj*area, Gj*area]);

    % generalized stiffness matrix
    Kee = zeros(Const.basis_dim);
    for j = 1:Const.n_segments
        Const.it_segment = j;
        range = 1 + Const.basis_dim_j*(j - 1):Const.basis_dim_j*j;
        Kee(range, range) = generalized_stiffness(Const);
    end
    Const.Kee = Kee;

    % initialization of the generalized coordinates
    Const.q = zeros(Const.basis_dim, 1);

    % tip forces
    Const.Fl_crosssec = zeros(6, 1);
    Const.Fl_inertial = zeros(6, 1);

    % distributed forces
    Const.F_bar_crosssec = zeros(6, 1);
    Const.F_bar_inertial = [0; 0; 0; 0; 0; -grav*area*rho];

    tic;
    % solve problem
    Const.q = Newton_Raphson(Const);
    time = toc;

    % display and save
    [QX, rX] = reconstruction(Const);

    % display
    plot_TACR(rX, n_segments, l, Const.n_nodes, 'Lagrangian');

    % save
    rl_j = rX(:, (1:Const.n_segments)*Const.n_nodes);
    Ql_j = QX(:, (1:Const.n_segments)*Const.n_nodes);
    bases = Const.basis_dim_k;
    save_TACR(routing, rl_j, Ql_j, rX, QX, Const.q, time, tau, ls, bases);

end
