function [DX, X] = cheb(N, l)

    if N == 0
        D = 0;
        y = 1;
    else
        y = -cos(pi*(0:N)/N)';
        c = [2; ones(N - 1, 1); 2].*(-1).^(0:N)';
        Y = repmat(y, 1, N + 1);
        dY = Y - Y';
        D = (c*(1./c)')./(dY + eye(N + 1));
        D = D - diag(sum(D, 2));
    end

    DX = (2/l)*D;
    X = l*(y + 1)/2;

end
