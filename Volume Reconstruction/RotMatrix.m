function T_rot = RotMatrix(a,b,g)
%ROTMATRIX Takes in the alpha, beta, and gamma values [a,b,g] and returns
%the rotation matrix.

% Rotation_mat = [cos(a)*cos(b), cos(a)*sin(b)*sin(g)-sin(a)*cos(g), cos(a)*sin(b)*cos(g)+sin(a)*sin(g);...
%         sin(a)*cos(b), sin(a)*sin(b)*sin(g)+cos(a)*cos(g), sin(a)*sin(b)*cos(g)-cos(a)*sin(g);...
%         -sin(b), cos(b)*sin(g), cos(b)*cos(g)];
Rz = [cos(g), -sin(g), 0; sin(g), cos(g), 0; 0, 0, 1];
Ry = [cos(b), 0, sin(b); 0, 1, 0; -sin(b), 0, cos(b)];
Rx = [1, 0, 0; 0, cos(a), -sin(a); 0, sin(a), cos(a)];
T_rot = Rx*Ry*Rz;
T_rot = T_rot.';

end

