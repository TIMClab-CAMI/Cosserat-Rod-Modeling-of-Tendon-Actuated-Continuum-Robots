function tau_s = tension_combinations_2x3(max_tension)

    max_tension = max_tension*linspace(1, 0.5, 3);
    tau_1 = linspace(0, max_tension(1), 3);
    tau_2 = linspace(0, max_tension(2), 3);
    tau_3 = linspace(0, max_tension(3), 3);
    tau_s = combvec(tau_1, tau_1, ...
                    tau_2, tau_2, ...
                    tau_3, tau_3)';
    N = length(tau_s);
    indices_to_suppress = zeros(N, 1);
    for i = 1:N
        tau = reshape(tau_s(i, :), 2, 3)';
        for k = 1:3 % segments
            if any(tau(k, :)) && tau(k, 1) == tau(k, 2)
                indices_to_suppress(i) = 1;
            end
        end
    end
    indices_to_suppress = logical(indices_to_suppress);
    tau_s(indices_to_suppress, :) = [];

end
