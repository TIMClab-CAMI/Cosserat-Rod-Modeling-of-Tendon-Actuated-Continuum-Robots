%
%
%TENDONS Position of the tendons of a tendon actuated coninuum robot in the
%cross-sectional frame. Different routing patterns are defined. The tendons
%ending in the proximal segments have no influence on the distal segments.
%The tendons ending in the distal segments are routed parallel in the
%proximal segments at the location of their entry point in the segment they
%terminate in.
%The function also returns other configuration parameters for the specified
%routing. For the configuration parameters and/or the tension outputs, the
%specified routing configuration is the only necessary input.
%
%   [D, dD, ddD, n_segments, n_tendons, l_j] = ...
%                                      tendons(routing)
%                                      tendons(routing, segment, tendon, X)
%
%input:
%routing, the selected routing (see comments in the swith-case statement
% below)
%segment, the current considered segment.
%tendon, the current considered tendon.
%X, the location of the considered cross-section of the considered segment
% on a normalized length from 0 to 1.
%
%output:
%D, the position of the tendon.
%dD, the first derivative of the position of the tendon.
%ddD, the second derivative of the position of the tendon.
%n_segments, the number of sectinos.
%n_tendons, the number of tendons per segment.
%l_j, the lenght of each segment.
%
%

function [D, dD, ddD, n_segments, n_tendons, l_j] = ...
                                       tendons(routing, segment, tendon, X)
% dummy values for parameters 2 -> 4 when only the confiuation is needed
if nargin == 1
    segment = 1;
    tendon = 1;
    X = 1;
end
switch routing % swith configuration
%% P1 : 1 segment - 3 tendons - parallel routing at 120 deg
case 1
    n_segments = 1;
    n_tendons = 3;
    l_j = 0.242;
    tendon_offset = 8e-3;
    tendon_angles = [0, 2*pi/3, 4*pi/3];

    rot = @(tendon_offset, theta) tendon_offset.* ...
        [cos(theta); sin(theta); zeros(1, length(theta))];
    D = rot(tendon_offset, tendon_angles(tendon));
    dD = zeros(3, 1);
    ddD = zeros(3, 1);

%% C1 : 1 segment - 2 tendons - convergent routing at 180 deg
case 2
    n_segments = 1;
    n_tendons = 2;
    l_j = 0.242;
    posneg = (-1)^(tendon + 1);
    tendon_offset = 8e-3;
    D = [posneg*tendon_offset*(1 - X/l_j); 0; 0];
    dD = [-posneg*tendon_offset/l_j; 0; 0];
    ddD = zeros(3, 1);

%% H1 : 1 segments - 2 tendons - helical routing of 720 deg at 180 deg
case 3
    n_segments = 1;
    n_tendons = 2;
    l_j = 0.242;
    tendon_offset = 8e-3;
    phaseshift = R_theta_3(180*(tendon - 1));
    f = 2*pi/l_j;
    c = cos(X*f);
    s = sin(X*f);
    dc = -f*s;
    ds = f*c;
    ddc = -f*f*c;
    dds = -f*f*s;
    D = phaseshift*tendon_offset*[c; s; 0];
    dD = phaseshift*tendon_offset*[dc; ds; 0];
    ddD = phaseshift*tendon_offset*[ddc; dds; 0];

%% P3 : 3 segments - 3 tendons per segment - parallel routing at 120 deg
%                                                   - segment phase = 0 deg
case 4
    n_segments = 3;
    n_tendons = [3 3 3]';
    l_j = [0.1 0.1 0.1]';
    if tendon < sum(n_tendons(1:segment - 1)) + 1 % not in distal section
        D = zeros(3, 1);
    else
        tendon_offsets = 8e-3*ones(n_segments, 1);
        tendon_angles = [0; 2*pi/3; 4*pi/3;
                         0; 2*pi/3; 4*pi/3;
                         0; 2*pi/3; 4*pi/3];

        rot = @(tendon_offset, theta) tendon_offset.* ...
            [cos(theta); sin(theta); zeros(1, length(theta))];
        D = rot(tendon_offsets(segment), tendon_angles(tendon));
    end
    dD = zeros(3, 1);
    ddD = zeros(3, 1);

%% C3 : 3 segments - 2 tendons per segment - convergent routing at 180 deg
%                                                  - segment phase = 60 deg
case 5
    n_segments = 3;
    n_tendons = [2 2 2]';
    l_j = [0.1 0.1 0.1]';
    posneg = (-1)^(tendon + 1);
    tendon_offset = 8e-3;
    % the segment the current tendon terminates in (~= current segment)
    tendon_segment = ...
                 find((tendon - tril(ones(n_segments))*n_tendons) <= 0, 1);
    phaseshift = R_theta_3(120*(tendon_segment - 1));
    if tendon < sum(n_tendons(1:segment - 1)) + 1 % not in distal section
        D = zeros(3, 1);
        dD = zeros(3, 1);
    elseif tendon > sum(n_tendons(1:segment)) % parallel in proximal sect
        D = phaseshift * [posneg*tendon_offset; 0; 0];
        dD = zeros(3, 1);
    else % convergent in concerned segment
        D = phaseshift * [posneg*tendon_offset*(1 - X/l_j(segment)); 0; 0];
        dD = phaseshift * [-posneg*tendon_offset/l_j(segment); 0; 0];
    end
    ddD = zeros(3, 1);

%% error if the demanded robot number corresponds to no implemented robot
otherwise
        error('please implement routing in "tendons.m" before using it');
end

end

function R = R_theta_3(theta)
    R = [ cosd(theta) -sind(theta)  0          ;
          sind(theta)  cosd(theta)  0          ;
          0            0            1         ];

end
