function [Fl, F_bar] = external_forces(X, Q, Const)

    R = quat2rot(Q);
    r = zeros(3, 1);

    F_bar = Const.F_bar_crosssec + Ad_g(R, r)'*Const.F_bar_inertial;
    Fl = zeros(6, 1);
    if X >= Const.l_j(Const.it_segment)
        Fl = Const.Fl_crosssec + Ad_g(R, r)'*Const.Fl_inertial;
    end

end
