function Force_Files(US_Data)
% FORCE_FILES Takes in all the ultrasound data image slices (varying forces
% and positions) and seperates the files according to force data. Each new
% file (having only one force) is saved into a folder named
% US_Images_Forces.

fprintf('\nStarted seperating data by force.\n\n')
% Creating a new directory to store force specific data
[~,~,~] = mkdir(pwd,'US_Images_Force');

% Saving all rows of index 1
index_vals = [US_Data(:).Index];
index_one = US_Data(index_vals == 1);
for i = 1:length(index_one)
    index_one(i).Force = round(index_one(i).Force);
end

% Finding all unique force values
Unique_Force_vals = sort(unique([index_one(:).Force]));
Force_vals = [US_Data(:).Force];

% Finding and saving US data for each force
for i = 1:length(Unique_Force_vals)
    US_Data_oneForce = US_Data(round(Force_vals) == Unique_Force_vals(i));
    filename = sprintf('%s_Force_%d.mat',...
        datestr(now,'yyyy-mm-ddTHH-MM-SS'),abs(Unique_Force_vals(i)));
    Image_dir = strcat(pwd,'\US_Images_Force\',filename);
    
    tic;
    if ~isempty(US_Data(1).Host_time)
        save(Image_dir,'US_Data_oneForce')
    end
    telapsed = toc;
    fprintf('Finished saving force %d data in %.2f seconds\n',...
        abs(Unique_Force_vals(i)),telapsed);
    
end


end

