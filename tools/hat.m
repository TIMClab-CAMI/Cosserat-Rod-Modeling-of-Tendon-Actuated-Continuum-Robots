function A = hat(x)

    A = zeros(3, 3);

    A(1, 2) = -x(3);
    A(1, 3) = x(2);
    A(2, 3) = -x(1);

    A(2, 1) = x(3);
    A(3, 1) = -x(2);
    A(3, 2) = x(1);

end
