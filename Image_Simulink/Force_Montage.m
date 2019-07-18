function Force_Montage(US_Data)
%FORCE_MONTAGE Summary of this function goes here
%   Detailed explanation goes here

% Getting the max index value
max_index = {US_Data.Index};
max_index = max([max_index{:}]);
% Saving all images to cell array
US_Images = {US_Data.US_Image};
% Region of interest
x_roi = [100, 900];
y_roi = [360, 770];
for i = 1:length(US_Images)
    US_Images{i} = US_Images{i}(x_roi(1):x_roi(2),y_roi(1):y_roi(2));
end

% Number of different forces
num_forces = length(US_Data)/max_index;

for i = 1:num_forces
    images_at_force = {US_Images{i:num_forces:length(US_Data)}};
    montage_fig = figure;
    montage(images_at_force)
    filename = sprintf('%d_Newtons_Montage.png',i*2);
    title(sprintf('Force at %d [N]',i*2));
    
    [~,~,~] = mkdir(pwd,'Force_Image_Montage');
    Montage_dir = strcat(pwd,'\Force_Image_Montage\',filename);
    saveas(gcf,Montage_dir);
end

end

