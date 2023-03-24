% Simple example script to run a single simulation with the Newtonian
% approach

% Inputs
routing = 3; % 3 = single segment variable (helix)
tau = [0 10]; % tension in the tendons
loading_steps = 1; % number of loading steps

% to further modify the robot geometry and material properties, refer to
% functions/files (tendons.m and materials.m)

% to modify the numerical parameters of the simulation, refer to the
% function/file Newtonian.m itself.

% Run the simulation
Newtonian(routing, loading_steps, tau);