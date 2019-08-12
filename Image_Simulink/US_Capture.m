% Running the simulation
Sim_name = 'US_Image_Acquire_Trigger_V2';
fprintf('Starting simulation %d of %d\n',Cur_exp_num,Tot_exp_num)
tic;
sim(Sim_name)
telapsed = toc;
fprintf('Finished simulation %d of %d in %.2f seconds.\n\n',Cur_exp_num,Tot_exp_num,telapsed)
clear Sim_name tout;

%% Saving data to file
Field_names = {'Host_time','X_pos','Y_pos','Z_pos','Roll','Pitch','Yaw'...
    'Force','Index','US_Image','US_Image_time'};

US_Data = struct(Field_names{1},[],...
    Field_names{2},[],...
    Field_names{3},[],... 
    Field_names{4},[],...
    Field_names{5},[],... 
    Field_names{6},[],...
    Field_names{7},[],... 
    Field_names{8},[],...
    Field_names{9},[],... 
    Field_names{10},[],... 
    Field_names{11},[]);

for i = 1:length(US_Aux_Data(:,1))
    US_Data(i).Host_time = US_Aux_Data(i,1);
    US_Data(i).X_pos = US_Aux_Data(i,2);
    US_Data(i).Y_pos = US_Aux_Data(i,3);
    US_Data(i).Z_pos = US_Aux_Data(i,4);
    US_Data(i).Roll = US_Aux_Data(i,5);
    US_Data(i).Pitch = US_Aux_Data(i,6);
    US_Data(i).Yaw = US_Aux_Data(i,7);
    US_Data(i).Force = US_Aux_Data(i,8);
    US_Data(i).Index = US_Aux_Data(i,9);
    
    US_Data(i).US_Image = US_Image_Data.signals.values(:,:,i);
    US_Data(i).US_Image_time = US_Image_Data.time(i);
end
clear i US_Aux_Data US_Image_Data;

filename = sprintf('%s_experiment%d_of_%d.mat',...
    datestr(now,'yyyy-mm-ddTHH-MM-SS'),Cur_exp_num, Tot_exp_num);
Image_dir = strcat(pwd,'\US_Images\',filename);
if ~isempty(US_Data(1).Host_time)
    save(Image_dir,'US_Data','-v7.3')
end

filename = sprintf('%s_Bad_Frame.mat',datestr(now,'yyyy-mm-ddTHH-MM-SS'));