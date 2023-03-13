function theta = delta_quat(q1, q2)

    w1 = q1(1); x1 = q1(2); y1 = q1(3); z1 = q1(4);
    w2 = q2(1); x2 = q2(2); y2 = q2(3); z2 = q2(4);

    dw = w1*w2 + x1*x2 + y1*y2 + z1*z2;
    dx = w1*x2 - x1*w2 + y1*z2 - z1*y2;
    dy = w1*y2 - y1*w2 - x1*z2 + z1*x2;
    dz = w1*z2 - w2*z1 + x1*y2 - y1*x2;

    theta = atan2(sqrt(dx^2 + dy^2 + dz^2), dw^2);

end
