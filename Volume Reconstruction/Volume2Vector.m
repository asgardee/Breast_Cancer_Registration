function [X,Y,Z,Val] = Volume2Vector(Volume)
% SPACE2VECTOR Takes in a volume whos x,y,z values represent the position
% in space, and the value in each cell represents the intensity at each
% position. Seperates the volume into 4 vector representing the x,y,z
% positions and intensity values.

tic;
x_len = size(Volume,1);
y_len = size(Volume,2);
z_len = size(Volume,3);
fprintf('Starting Vectorization through %d terms.\n',x_len*y_len*z_len)
% Initializing output vector size
[X,Y,Z] = deal(ones(length(Volume(Volume ~= -1)),1));
Val = ones(length(Volume(Volume ~= -1)),1,'uint8');

count = 0; % Counter to itterate through each value
for i = 1:x_len
    for j = 1:y_len
        for k = 1:z_len
            if Volume(i,j,k) ~= -1
                count = count +1; % Incrementing counter
                % Assigning values to output variables
                X(count) = i;
                Y(count) = j;
                Z(count) = k;
                Val(count) = Volume(i,j,k);
            end
        end
    end
end
telapsed = round(toc);
fprintf('Finished Vectorization in %d seconds.\n\n',telapsed)

end

