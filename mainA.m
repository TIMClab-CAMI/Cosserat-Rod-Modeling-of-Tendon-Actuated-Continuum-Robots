
addpath('./tools');

%% single segment parallel
routing = 1;
tau_max = 5; % Rucker 2011 -> 0 to 4.91
tau_p = 0:tau_max; % for each tendon, i
tau_s = combvec(tau_p, tau_p, tau_p)'; % combination of the 3 tendons
n_simulations = length(tau_s);

%%
% I. Simulations
for i = 1:n_simulations
    disp(['simulation:  ' num2str(i) ' / ' num2str(n_simulations)]);
    % tensions
    tau = tau_s(i, :);

    % 1. Newtonian
    % search required number of loading steps
    % this algorithm bugs if the required number of loading steps is not a
    % single treshold function but has multiple wells, which may happen ...
    flag = 0;
    loading_steps = 1;
    while flag < 1
        flag = Newtonian(routing, loading_steps, tau, false);
        loading_steps = loading_steps*2;
    end
    loading_steps = loading_steps/2;
    if loading_steps > 2
        prev = loading_steps/2;
        delta = loading_steps/4;
        while delta > 1
            flag = Newtonian(routing, prev + delta, tau, false);
            if flag < 1
                prev = prev + delta;
            end
            delta = delta/2;
        end
        flag = Newtonian(routing, prev + delta, tau, false);
        if flag > 0
            loading_steps = prev + delta;
        else
            loading_steps = prev + delta*2;
        end

    end
    % once the number of loading steps found, run simulation and save
    % results
    Newtonian(routing, loading_steps, tau);

    % 2. Lagrangian always ok with one loading step for this scenario ->
    % run simulation and save results
    Lagrangian(routing, 1, tau);
    close all
end

%% II. data
[approach, rl, Ql, rX, time, tau_r, loading_steps] = ...
                               read_results('simulation_results', routing);

%% III. metrics
% check results of N and L are saved in the same order
tau_N = tau_r(:, approach == "N");
tau_L = tau_r(:, approach == "L");
if length(tau_N) == length(tau_L)
    if any(any(tau_N - tau_L))
        warning('results are not saved in the same order');
    end
else
    warning('different number of results per approach, check folder');
end

% position
r_N = rl(:, approach == "N"); % [m]
r_L = rl(:, approach == "L"); % [m]
position_errors = vecnorm(r_L - r_N); % [m]
position_error_median = median(position_errors); % [m]
position_error_95CI = prctile(position_errors, [2.5 97.5]); % [m]
figure();
probplot('exponential', position_errors);
title('Probability plot for Position Errors (Exponential distribution ?)');
figure();
hist(position_errors); %#ok
title('Histogram for Position Errors');

% orientation
Q_N = Ql(:, approach == "N"); % [rad]
Q_L = Ql(:, approach == "L"); % [rad]
orientation_errors = zeros(1, length(Q_L));
for i = 1:length(Q_L)
    orientation_errors(i) = delta_quat(Q_N(:, i), Q_L(:, i)); % [rad]
end
orientation_error_median = median(orientation_errors); % [rad]
orientation_error_95CI = prctile(orientation_errors, [2.5 97.5]); % [rad]
figure();
probplot(orientation_errors);
title('Probability plot for Orientation Errors (Normal distribution ?)');
figure();
hist(orientation_errors); %#ok
title('Histogram for Orientation Errors');

% time
time_N = time(approach == "N");
time_L = time(approach == "L");
figure;
hist([time_N', time_L'], 20); %#ok
title('Histogram for Computation Times');
legend('Newtonian Approach', 'Lagrangian Approach');
time_N_mean = mean(time_N);
time_L_mean = mean(time_L);

% loading_steps
loading_steps_N = loading_steps(approach == "N");
loading_steps_L = loading_steps(approach == "L");
figure;
hist([loading_steps_N', loading_steps_L'], 20); %#ok
title('Histogram for Minimum Number of Loading Steps Required');
legend('Newtonian Approach', 'Lagrangian Approach');
loading_steps_N_mean = mean(loading_steps_N);
loading_steps_L_mean = mean(loading_steps_L);

% [mm] & [degree]
position_errors_mm = position_errors * 1e3; % [mm]
position_error_median_mm = median(position_errors_mm); % [mm]
position_error_95CI_mm = prctile(position_errors_mm, [2.5 97.5]); % [mm]
orientation_errors_deg = rad2deg(orientation_errors); % [deg]
orientation_error_median_deg = median(orientation_errors_deg); % [deg]
orientation_error_95CI_deg = prctile(orientation_errors_deg, [2.5 97.5]);

%% IV. plots
figure;
hold on; grid on;
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
n_simulations = length(approach)/2;
n_samples = 20;
bnds = 0;
for p = ceil(rand(n_samples, 1)*n_simulations)'
    plot_2_TACRs(rX(:, p), rX(:, n_simulations + p));
    bnds = max(bnds, max(max(rX(:, p)), max(rX(:, n_simulations + p))));
end
axis equal;
xlim([-1.1*bnds 1.1*bnds]);
ylim([-1.1*bnds 1.1*bnds]);
zlim([0 1.1*bnds]);
view(-35, 20);

%% V. find worst case
worst = find(position_errors == max(position_errors));
