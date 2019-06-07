test_full = zeros(3,5);

X_data = zeros(size(test_full,1)*size(test_full,2),2);
Y_data = zeros(size(test_full,1)*size(test_full,2),1);
x_val = 0; % Initialize x value
y_val = 0; % Initialize y value
for i = 1:size(X_data,1)
    if mod(i-1,size(test_full,2)) == 0
        x_val = x_val + 1;
        y_val = mod(i,size(test_full,2));
    else
        y_val = mod(i-1,size(test_full,2))+1;
    end
    X_data(i,:) = [x_val y_val];
end