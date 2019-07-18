function [X,Y,Z] = depth2xyz(depth_matrix)
% DEPTH2XYZ This function takes in a 2 dimensional depth matrix and returns
% 3 column vectors X, Y, and Z. The X and Y vectors hold the matrix index
% values and the Z matrix holds the depth data.

% Saving the data in vector format
XY = zeros(size(depth_matrix,1)*size(depth_matrix,2),2);
Z = zeros(size(depth_matrix,1)*size(depth_matrix,2),1);
x_val = 0; % Initialize x value
y_val = 0; % Initialize y value

for i = 1:size(XY,1)
    if mod(i-1,size(depth_matrix,2)) == 0
        x_val = x_val + 1;
        y_val = mod(i,size(depth_matrix,2));
    else
        y_val = mod(i-1,size(depth_matrix,2))+1;
    end
    XY(i,:) = [x_val y_val];
    Z(i) = depth_matrix(x_val,y_val);
end

X = XY(:,1);
Y = XY(:,2);

end

