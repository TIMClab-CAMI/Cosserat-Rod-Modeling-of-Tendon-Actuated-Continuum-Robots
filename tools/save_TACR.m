function save_TACR(routing, rl_j, Ql_j, rX, QX, inpt, time, tau, ls, bases)

    if nargin == 9
        app = 'N';
    elseif nargin == 10
        app = 'L';
    else
        warning('not enough input arguments');
    end

    folder = 'simulation_results';
    if ~exist(folder, 'dir')
        mkdir(directory);
    end

    strT = '_T=';
    T = tau(:);
    for T_i = T(1:end - 1)'
        strT = strcat(strT, num2str(fix(T_i), '%0+4.0f'), ', ');
    end
    strT = strcat(strT, num2str(fix(T(end)), '%0+4.0f'));
    strRout = num2str(routing, '%1.0f');
    filename = strcat(folder, '/', app, '_routing=', strRout, ...
                     strT, string(datetime, '_-_yyyyMMdd-HHmmss'), '.txt');
    if app == 'N'
        save(filename, 'rl_j', 'Ql_j', 'rX', 'QX', 'inpt', ...
                                            'time', 'tau', 'ls', '-ascii');
    elseif app == 'L'
        save(filename, 'rl_j', 'Ql_j', 'rX', 'QX', 'bases', 'inpt', ...
                                            'time', 'tau', 'ls', '-ascii');
    end

end
