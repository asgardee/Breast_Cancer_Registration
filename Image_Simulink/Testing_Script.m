clc;

%% Countdown timer
Countdown_time = 7;
Countdown_time_cur = Countdown_time;
for i = 1:Countdown_time
    fprintf('%d seconds left.\n',Countdown_time_cur)
    pause(1);
    Countdown_time_cur = Countdown_time_cur - 1;
end
disp('Starting simulation!')

%% Starting simulation
Sim_name = 'Testing_Image_Acquire';
sim(Sim_name);
Epiphan_speed = 60;
Epiphan_speed = round(1/Epiphan_speed,3);

% Displaying values
fprintf('%f maximum for comparison function.\n',max(Time))
fprintf('%d changes detected \n\n',length(nonzeros(New_Frame)))
%%
% Visually comparing the different images
new_index = find(New_Frame == 1);
Image = cell(1,3);
for i = 1:length(new_index)
    Image{1} = Image_new.signals.values(:,:,new_index(i));
    Image{2} = Image_old.signals.values(:,:,new_index(i));
    Image{3} = imabsdiff(Image{1},Image{2});
%     Image{1} = Image_new.signals.values(:,:,i);
%     Image{2} = Image_old.signals.values(:,:,i);
%     Image{3} = imabsdiff(Image{1},Image{2});
    montage(Image);
    close all
end