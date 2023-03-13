function dQ = quaternion_dot_omega(Omega)

    A_Omega = [       0, -Omega(1), -Omega(2), -Omega(3)
               Omega(1),         0,  Omega(3), -Omega(2)
               Omega(2), -Omega(3),         0,  Omega(1)
               Omega(3),  Omega(2), -Omega(1),        0];


    dQ = 1/2*A_Omega;

end
