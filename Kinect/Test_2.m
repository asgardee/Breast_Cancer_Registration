outlier_thresh = 50;
outliers = zeros(size(image_slices,4),outlier_thresh);

outliers(1:4,1:2) = [1,2;1,2;1,2;1,2];

% Removing the zero terms from the outliers
temp = nonzeros(outliers);

% Checking if outliers for the data happen at the same index(s)
if mod(length(temp),4) == 0
    temp = reshape(temp,4,length(temp)/4);
    equality = zeros(1,size(temp,2)); % Checks if column elements are equal
    for j = 1:size(temp,2)
        if range(temp(:,j)) == 0
            equality(j) = 1;
        end
    end

    % If all outliers are at the same point it will be assumed that the
    % remaining outliers will only be at those index positions!
    if all(equality)
        pop = 1
    end
end

disp('end of test')