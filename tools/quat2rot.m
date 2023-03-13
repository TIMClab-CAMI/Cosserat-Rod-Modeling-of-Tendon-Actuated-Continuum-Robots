function R = quat2rot(Q)

    R = zeros(3, 3);

    Q0 = Q(1)/norm(Q);
    Q1 = Q(2)/norm(Q);
    Q2 = Q(3)/norm(Q);
    Q3 = Q(4)/norm(Q);

    R(1, 1) = Q0^2 + Q1^2 - Q2^2 - Q3^2;
    R(1, 2) = 2*(Q1*Q2 - Q0*Q3);
    R(1, 3) = 2*(Q1*Q3 + Q0*Q2);
    R(2, 1) = 2*(Q1*Q2 + Q0*Q3);
    R(2, 2) = Q0^2 + Q2^2 - Q3^2 - Q1^2;
    R(2, 3) = 2*(Q2*Q3 - Q0*Q1);
    R(3, 1) = 2*(Q1*Q3 - Q0*Q2);
    R(3, 2) = 2*(Q2*Q3 + Q0*Q1);
    R(3, 3) = Q0^2 + Q3^2 - Q1^2 - Q2^2;

end
