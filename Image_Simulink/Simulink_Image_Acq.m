clc; clearvars; close all;
%%
[~,~,~] = mkdir(pwd,'US_Images'); % Creating a new directory to store data

% Defining current and total experiments
Cur_exp = 1;
Tot_exp_num = 8;

% Defining variables for simulink workspace
% THIS DOES NOT CHANGE IMAGE ACQUISITION SAMPLE TIME
Sam_time = 0.034;
UDP_in = 12;
    X_min = 366;
    Y_min = 107;
    X_max = 761;
    Y_max = 890;
ROI_pos = [Y_min X_min Y_max- Y_min X_max-X_min];
% fprintf('[%d %d %d %d]\n\n',ROI_pos)
clear X_min Y_min X_max Y_max
    

% % UNCOMMENT FOR SINGLE EXPIRIMENT ACQUISITION
% US_Capture(Cur_exp_num,Tot_exp_num)
for Cur_exp_num = Cur_exp:Tot_exp_num
    US_Capture;
end

% Force_Montage(US_Data) % Saves images to montage

%% Combines all .mat files in folder "US_Images" into one file
clearvars; clc;
image_folder = "US_Images\";
mat_file = dir(strcat(image_folder,'*.mat'));
US_Data = struct();
for i = 1:length(mat_file)
    tic;
    temp = load(strcat(image_folder,mat_file(i).name));
    if i == 1
        US_Data = temp.US_Data;
    else
        US_Data = [US_Data,temp.US_Data]; %#ok<AGROW>
    end
    telapsed = toc;
    fprintf('Stiched file %d of %d in %.2f seconds\n',i,length(mat_file),...
        telapsed)
end
clearvars -except US_Data

tic;
filename = sprintf('%s_experiment.mat',...
    datestr(now,'yyyy-mm-ddTHH-MM-SS'));
Image_dir = strcat(pwd,'\US_Images\',filename);
if ~isempty(US_Data(1).Host_time)
    save(Image_dir,'US_Data','-v7.3')
end
telapsed = toc;
fprintf('Saved variable to .mat file in %.2f seconds\n',telapsed)

%% Saves US_Images filtered by each force value
% Force_Files(US_Data)


