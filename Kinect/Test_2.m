rng('default') % For reproducibility

% Parameters for data generation
N = 300;  % Size of each cluster
r1 = 0.5; % Radius of first circle
r2 = 5;   % Radius of second circle
theta = linspace(0,2*pi,N)';

X1_t = r1*[cos(theta),sin(theta)]+ rand(N,1); 
X2_t = r2*[cos(theta),sin(theta)]+ rand(N,1);
X_t = [X1_t;X2_t]; % Noisy 2-D circular data set