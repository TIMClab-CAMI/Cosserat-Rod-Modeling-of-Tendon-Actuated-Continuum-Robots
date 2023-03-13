function [rl, Ql, rX, QX, xi0, time, tau, ls] = read_result_N(filename)

    % open
    fileID = fopen(filename);
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
    Ql = zeros(4, 1);
    for i = 1:4
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        Ql(i) = line(end);
    end
    % rX
    rX = zeros(3, 100*n_segments);
    for i = 1:3
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        rX(i, :) = line;
    end
    rX = rX';
    rX = rX(:);
    % QX
    QX = zeros(4, 100*n_segments);
    for i = 1:4
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        QX(i, :) = line;
    end
    QX = QX';
    QX = QX(:);
    % xi0
    xi0 = zeros(6, 1);
    for i = 1:6
        line = str2double(split(fgetl(fileID), ' '));
        line(isnan(line)) = [];
        xi0(i, :) = line;
    end
    xi0 = xi0(:);
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
