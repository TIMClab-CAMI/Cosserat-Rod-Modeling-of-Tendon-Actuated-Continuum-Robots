function flag = Newtonian(routing, ls, tau_tot, save_true)

    if nargin < 4
        save_true = true;
    end

    addpath('./tools')

    % independent parameters
    [E, Gj, R_b, rho] = materials();
    grav = [0; 0; -9.81]; % [N/kg] % gravity acceleration constant
    [~, ~, ~, n_segments, n_tendons, l_j] = tendons(routing);

    % boundary conditions
    r0 = zeros(n_segments, 3);
    Q0 = [rot2quat(eye(3))';
          zeros(n_segments - 1, 4)];

    % dependent parameter calculations
    area = pi*R_b^2;
    I = pi*R_b^4/4;
    J = 2*I;
    Kse = diag([Gj*area, Gj*area, E*area]);
    Kbt = diag([E*I, E*I, Gj*J]);

    % solve with shooting method
    init_guess = zeros(6, 1);
    global Y j; %#ok % forward declaration for future scoping rule changes
    Y = cell(n_segments, 1);

    flag = 1;
    t = 1;
    opt = optimoptions('fsolve', ...
                                   'Algorithm', 'levenberg-marquardt', ...
                                   'Display', 'off');
    tic;
    while flag > 0 && t <= ls
        tau = t*tau_tot/ls;
        [init_guess, ~, flag] = fsolve(@shooting_fun, init_guess, opt);
        t = t + 1;
    end
    time = toc;
    if flag <= 0
        warning('solver did not exit properly');
    else
        % display
        l = sum(l_j);
        n_nodes = size(Y{1}, 1);
        Y = cell2mat(Y)';
        rX = Y(1:3, :);
        plot_TACR(rX, n_segments, l, n_nodes, 'Newtonian');
        % save
        if save_true
            QX = Y(4:7, :);
            rl_j = Y(1:3, end);
            Ql_j = Y(4:7, end);
            xi0 = Y(8:13, 1);
            save_TACR(routing, rl_j, Ql_j, rX, QX, xi0, time, tau, ls);
        end
    end

    function dy = TACR_ODE(X, y)
        % unpack state vector
        Q = y(4:7);
        R = quat2rot(Q);
        K = y(8:10);
        G = y(11:13);

        % setup tendon linear system
        a = zeros(3, 1);
        b = zeros(3, 1);
        A = zeros(3, 3);
        O = zeros(3, 3);
        H = zeros(3, 3);

        % iterate over all the tendons. to avoid calling tendons() with
        % tendons that are terminated in the current segment (i.e.
        % tendons() = [0 0 0]), we first only consider the current segment
        % and all following segments (for j = s:n_segments) and then
        % iterate over all the tendons in each of these segments
        for jj = j:n_segments
            for i = 1 : n_tendons(jj)
                it = i + sum(n_tendons(1:jj - 1));
                % current D
                [D, dD, ddD] = tendons(routing, j, it, X);
                G_i = cross(K, D) + dD + G;
                G_i_norm = norm(G_i);
                A_i = -hat(G_i)^2 * (tau(jj, i) / G_i_norm^3);
                O_i = -A_i * hat(D);
                a_i = A_i * (cross(K, G_i + dD) + ddD);

                a = a + a_i;
                b = b + cross(D, a_i);
                A = A + A_i;
                O = O + O_i;
                H = H + hat(D) * O_i;
            end
        end

        Mat = [H + Kbt,     O.';
                     O, A + Kse];

        N = Kse*(G - [0; 0; 1]);
        C = Kbt*K;

        rhs = [-cross(K, C) - cross(G, N) - b;
               -cross(K, N) - R.'*rho*area*grav - a];

        % calculate ODE terms
        dr = R*G;
        dQ = quaternion_dot_q_omega(Q, K);
        dxi = Mat\rhs;

        % pack state vector derivative
        dy = [dr; dQ; dxi];
    end

    function distal_error = shooting_fun(guess)
        % " One of the unknown state variables is v(0), but we guess n(0)
        % and solve for v(0) since I suspect this will lead to better
        % numerical conditioning of the objective function. " - J. Till
        % (note: here, v = G and n = N)

        for j = 1:n_segments %#ok<FXUP>
            if j == 1 % guess for the first segment
                N0_j = guess(1:3);
                G0_j = Kse\N0_j + [0; 0; 1];
                K0_j = guess(4:6);
            else % propagation for the other segments
                G0_j = Kse\N0_jp1 + [0; 0; 1]; % (see l. + 97)
                K0_j = Kbt\C0_jp1;
            end

            y0 = [r0(j, :)'; Q0(j, :)'; K0_j; G0_j];

            op = odeset('RelTol', 1e-8, 'AbsTol', 1e-8);
            [~, Y{j}] = ode45(@TACR_ODE, linspace(0, l_j(j)), y0, op);

            % find the internal forces in the backbone prior to the final
            % plate
            Kl_j = Y{j}(end, 8:10).';
            Gl_j = Y{j}(end, 11:13).';

            % update the state variables for the next segment
            if j < n_segments
                r0(j + 1, :) = Y{j}(end, 1:3);
                Q0(j + 1, :) = Y{j}(end, 4:7);
            end

            Nl_j = Kse*(Gl_j - [0; 0; 1]);
            Cl_j = Kbt*Kl_j;

            % find the equilibrium error at the tip, considering tendon
            % forces (terminating in the current segment only)
            for i = 1 : n_tendons(j)
                it = i + sum(n_tendons(1:j - 1));
                % current D
                [D, dD] = tendons(routing, j, it, l_j(j));
                G_i = cross(Kl_j, D) + dD + Gl_j;
                Fb_i = -tau(j, i)*G_i/norm(G_i);
                Nl_j = Nl_j - Fb_i;
                Cl_j = Cl_j - cross(D, Fb_i);
            end

            % equilibrium : tendons + bb
            if j == n_segments % last segment : BC
                distal_error = -1*[Nl_j; Cl_j];
            else % other segments : propagation
                % for all tendons passing from one segment to the next one,
                % we need to compute the force applied to the backbone due
                % to the routing shift.
                FtX = zeros(3, 1);
                LtX = zeros(3, 1);
                % calculate Kl_j_p & Gl_j_p (p -> +)
                a = zeros(3, 1);
                b = zeros(3, 1);
                A = zeros(3, 3);
                O = zeros(3, 3);
                H = zeros(3, 3);
                for jj = j:n_segments
                    for i = 1 : n_tendons(jj)
                        it = i + sum(n_tendons(1:jj - 1));
                        % current D
                        [D, dD_j_m] = tendons(routing, j, it, l_j(j));
                        [~, dD_j_p] = tendons(routing, j + 1, it, 0);
                        G_i = cross(Kl_j, D) + Gl_j;
                        G_i_norm = norm(G_i);
                        A_i = -hat(G_i)^2*(tau(jj, i)/G_i_norm^3);
                        O_i = -A_i * hat(D);
                        a_i = A_i * (dD_j_p - dD_j_m);

                        a = a + a_i;
                        b = b + cross(D, a_i);
                        A = A + A_i;
                        O = O + O_i;
                        H = H + hat(D) * O_i;
                    end
                end

                Mat = [H + Kbt,     O.';
                             O, A + Kse];

                rhs = [-b;
                       -a];

                delta_xi = -Mat\rhs;
                Kl_j_p = Kl_j + delta_xi(1:3);
                Gl_j_p = Gl_j + delta_xi(4:6);

                for jj = j + 1:n_segments
                    for i = 1:n_tendons(jj)
                        it = i + sum(n_tendons(1:jj - 1));
                        [D, dD_j_p] = tendons(routing, j + 1, it, 0);
                        [~, dD_j_m] = tendons(routing, j, it, l_j(j));
                        if any(dD_j_p ~= dD_j_m)
                            G_i_p = hat(Kl_j_p)*D + dD_j_p + Gl_j_p;
                            G_i_m = hat(Kl_j)*D + dD_j_m + Gl_j;
                            Ci = G_i_p/norm(G_i_p) - G_i_m/norm(G_i_m);
                            F = Ci*tau(jj, i);
                            FtX = FtX + F;
                            LtX = LtX + hat(D)*F;
                        end
                    end
                end

                % propagate the resultant internal loads to the next sect.
                N0_jp1 = Nl_j - FtX;
                C0_jp1 = Cl_j - LtX;
            end
        end
    end

end
