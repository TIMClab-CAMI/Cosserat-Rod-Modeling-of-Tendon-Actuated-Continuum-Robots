function dr = r_dot(Q, V)

    R = quat2rot(Q);

    dr = R*V;

end
