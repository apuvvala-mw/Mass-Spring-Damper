function [x, t] = simulateSystem(design)

% Design variables
c = design.c;
k = design.k;

% Constant variables
z0 = [-0.1; 0];  % Initial Position and Velocity
m = 1500;        % Mass

odefun = @(t,z) [0 1; -k/m -c/m]*z;
[t, z] = ode45(odefun, [0, 3], z0);

% The first column is the position (displacement from equilibrium)
x = z(:, 1);