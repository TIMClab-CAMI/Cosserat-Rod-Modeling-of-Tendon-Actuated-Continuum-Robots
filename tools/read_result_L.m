function [rl, Ql, rX, QX, q, time, tau, ls] = read_result_L(filename)

    % open
    fileID = fopen(filename);
    n_nodes = 10;
    % find routing from filename (craches for two digit routings)
    fn_parts = split(filename, "_T=", 1); % split after routing number
    fn_first = double(char(fn_parts(1))); % double->extract last character
    routing = fn_first(end) - double('0'); % character number -> routing
    [~, ~, ~, n_segments, n_tendons] = tendons(routing);

    % rl
    rl = zeros(3, 1);
    for i = 1:3
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        rl(i) = line(end);
    end
    % Ql
    R0 = [0 0 -1; 0 1 0; 1 0 0];
    Ql = zeros(4, 1);
    for i = 1:4
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        Ql(i) = line(end);
    end
    Ql = rot2quat(quat2rot(Ql)*R0');
    % rX
    rX_L = zeros(3, n_nodes*n_segments);
    for i = 1:3
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        rX_L(i, :) = line;
    end
    [~, X] = cheb(n_nodes - 1, 1);
    rX = zeros(100*n_segments, 3);
    for i = 1:n_segments
        rg_L = (1:n_nodes) + n_nodes*(i - 1);
        rg_N = (1:100) + 100*(i - 1);
        rX(rg_N, :) = interp1(X, rX_L(:, rg_L)', linspace(0, 1), 'makima');
    end
    rX = rX(:);
    % QX
    QX = zeros(4, n_nodes*n_segments);
    for i = 1:4
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        QX(i, :) = line;
    end
    for i = 1:n_nodes*n_segments
        RX_lag = quat2rot(QX(:, i));
        QX(:, i) = rot2quat(RX_lag*R0');
    end
    % bases
    bases = str2double(split(fgetl(fileID), ' '));
    bases(isnan(bases)) = [];
    % q
    q = zeros(sum(bases)*n_segments,1);
    for i = 1:sum(bases)*n_segments
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        q(i) = line;
    end
    % time
    time = str2double(fgetl(fileID));
    % tau
    tau = zeros(n_tendons(1), n_segments);
    for i = 1:n_segments
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        tau(:, i) = line;
    end
    tau = tau';
    tau = tau(:);
    % loading_steps
    ls = cell2mat(textscan(fileID, '%f', 1));

    % close
    fclose(fileID);

end
