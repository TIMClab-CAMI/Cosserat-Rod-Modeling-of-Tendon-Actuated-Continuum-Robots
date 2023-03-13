function [ap, rl, Ql, rX, time, tau, ls] = read_results(directory, routing)

    addpath('./tools');

    % directory containing the results
    current_directory = pwd;
    cd(directory);
    fileprefix_N = strcat('N_routing=', num2str(routing), '*');
    fileprefix_L = strcat('L_routing=', num2str(routing), '*');
    [~, values_N] = fileattrib(fileprefix_N);
    [~, values_L] = fileattrib(fileprefix_L);
    cd(current_directory) % back to current directory
    filenames = [values_N, values_L];
    [~, ~, ~, n_segments, n_tendons] = tendons(routing);

    % preallocate
    fn = length(filenames);
    ap = strings(1, fn); % 'N' == Newtonian , 'L' == Lagrangian
    rl = zeros(3, fn);
    Ql = zeros(4, fn);
    rX = zeros(300*n_segments, fn);
    time = zeros(1, fn);
    tau = zeros(sum(n_tendons), fn);
    ls = zeros(1, fn);

    for f = 1:fn
        filename = filenames(f).Name;
        filename = split(filename, '\');
        filename = string(filename(end));
        if strtok(filename, "_") == 'N'
            ap(f) = 'N';
            [rl(:, f), Ql(:, f), rX(:, f), ~, ~, time(f), tau(:, f), ...
                  ls(f)] = read_result_N(strcat(directory, '/', filename));
        elseif strtok(filename, '_') == 'L'
            ap(f) = 'L';
            [rl(:, f), Ql(:, f), rX(:, f), ~, ~, time(f), tau(:, f), ...
                  ls(f)] = read_result_L(strcat(directory, '/', filename));
        end
    end

end
