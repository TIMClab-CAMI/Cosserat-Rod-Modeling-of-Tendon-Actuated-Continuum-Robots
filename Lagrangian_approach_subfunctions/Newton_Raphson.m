function q = Newton_Raphson(Const)

    res_min = 1e-8; % residual tolerance
    q = Const.q; % initial value of generalized coordinates
    loading_steps = Const.loading_steps; % number of loading steps

    for t = 1:loading_steps

        L = actuation_matrix(Const); % generalized matrix of actuation
        tau = t*Const.tau(:)/loading_steps; % tendon tensions

        % generalized forces of actuation
        Q_act = L*tau;

        % assigning current state to the structure and
        % computing output of ISM and Jacobian
        Const.q = q;
        [Q_ext, J] = TISM(Const);

        residual = Q_ext + Const.Kee*Const.q - Q_act;

        while norm(residual) > res_min
            % the variation Delta_q
            Delta_q = (-J - Const.Kee)\residual;

            % updating the current state
            q = q + Delta_q;

            % assigning current state to the structure and
            % computing new output of ISM and Jacobian
            Const.q = q;
            [Q_ext, J] = TISM(Const);

            residual = Q_ext + Const.Kee*Const.q - Q_act;
        end

    end

end
