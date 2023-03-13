function [E, Gj, R_b, rho] = materials()

    E = 210e9; % [Pa] % Young modulus
    nu = 0.3125; % [-] % Poisson's ratio
    Gj = E*(1 + nu)/2; % [Pa] shear modulus
    R_b = .4e-3; % [m] backbone radius
    rho = 95000; % [kg/m^3] % equivalent mass density

end
