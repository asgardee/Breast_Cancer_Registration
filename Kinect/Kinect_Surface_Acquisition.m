clc; clearvars; % Cleaning workspace and command window

%% RGB-D Image Acquisition
hwInfo = imaqhwinfo('kinect'); % Obtaining info for kinect hardware
% Use imaqtool to open the GUI

% Creating the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);

% Setting the triggering mode to 'manual'
triggerconfig([colorVid depthVid],'manual');
counter = 0; % Counts how many manual triggers were initiated

% Setting the frames per trigger
frames = 25;
colorVid.FramesPerTrigger = frames;
depthVid.FramesPerTrigger = frames;

sample = struct('colorFrameData',[],'colorTimeData',[],'colorMetaData',...
    [],'depthFrameData',[],'depthTimeData',[],'depthMetaData',[]);

while 1
    % Prompts user for signal acquisition
    answer = questdlg('Acquire sample?','Signal Acquisition GUI','Yes','No','Yes');
    
    % Checks exit condition
    if isempty(answer) || strcmp(answer,'No')
        break
    else
        counter = counter + 1; % Increment counter
        
        % Start the color and depth device. This begins acquisition, but does not
        % start logging of acquired data.
        start([colorVid depthVid]);
        pause(1); % Allows time for values to normalize
        trigger([colorVid depthVid]); % Trigger the devices to start logging of data.
        
        % Retrieve the acquired data
        [sample(counter).colorFrameData, sample(counter).colorTimeData,...
            sample(counter).colorMetaData] = getdata(colorVid);
        [sample(counter).depthFrameData, sample(counter).depthTimeData,...
            sample(counter).depthMetaData] = getdata(depthVid);
    end
end
clear answer counter;

% Stop the devices
stop([colorVid depthVid]);

%% Image Pre-Processing
% help calibrate_kinect
    % This is the toolbox accompanying our TPAMI 2012 paper - Herrera C., et al.
    % "Joint depth and color camera calibration with distortion correction", 
    % TPAMI, 2012. Please cite our paper if you use this toolbox.
options = calibrate_kinect_options(); % Sets default options for RGB to D

[params,params_error] = calibrate_kinect(options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,params0);

%% Straightening out the image
% Getting all images slices from the first acquisition
D_image_slices = sample(1).depthFrameData(:,:,1,:);
D_image_slice = D_image_slices(:,:,:,1);
C_image_slices = sample(1).colorFrameData(:,:,1,:);
C_image_slice = C_image_slices(:,:,:,1);

% Prompting the user to pick the ROI that contains a flat surface
answer = questdlg('The first region of interest contains the phantom and a flat surface.'...
    ,'ROI_prompt','Ok','Ok');
[X,Y,Z] = depth2xyz(D_image_slice);
[X_ROI,Y_ROI,Z_ROI,ROI_Broad] = ROI(X,Y,Z);
%%

% Initializing column vectors with zeros
[X,Y,Z,Z_interp] = deal(zeros(length(ROI_Broad),1));
% Defining the indicies of the outliers and the maximum amount of outliers
% allowed in a sample
outlier_thresh = 50;
outliers = zeros(size(D_image_slices,4),outlier_thresh);

% Saving all column vectors for the depth data for each image slice
for i = 1:size(D_image_slices,4)
    disp(i)
    tstart = tic;
    
    % Getting the column vector X,Y,Z for slice i
    D_image_slice = D_image_slices(:,:,:,i);
    [X_temp,Y_temp,Z_temp] = depth2xyz(D_image_slice);
    X(:,i) = X_temp(ROI_Broad);
    Y(:,i) = Y_temp(ROI_Broad);
    Z(:,i) = Z_temp(ROI_Broad);
    
    verticies = [X(:,i),Y(:,i),Z(:,i)];
    
    % Using density based clustering to identify outliers
    epsl = 10; % Epsilon neigbourhood: Radius from an object
    minpts = 5; % Minimum amount of points within radius
    
    % Using dbscan with X,Y,Z data
    time_xyz_start = tic;
    [idx, corepts] = dbscan(Z(:,i),eps,minpts);
    time_xyz = toc(time_xyz_start);
    
    % Finding outliers and replacing values with NaN
    temp = find(idx == -1);
    if length(temp) > outlier_thresh % Checks if outliers exceed threshold
        disp('To many outliers, please look at sample data')
        return
    elseif i == 4 % Checks to see if all outliers are at the same index
        for j = 1:length(temp)
            outliers(i,j) = temp(j);
        end
        
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
        
    else
        for j = 1:length(temp)
            outliers(i,j) = temp(j);
        end
    end
    % Cubic interpolation for all missing values
    if ~isempty(nonzeros(outliers(i,:)))
        verticies(nonzeros(outliers(i,:)),:) = NaN;
        verticies_interp = fillmissing(verticies,'spline');
        Z_interp(:,i) = verticies_interp(:,3);
    else
        Z_interp(:,i) = verticies(:,3);
    end
    
    telapsed = toc(tstart)
    
%     % Plotting the nonprocessed data
%     markersize = 3;
%     figure;
%     scatter3(Y(:,i),Z(:,i),-X(:,i),marker_size,'filled','k')
%     view([45 30]);
%     axis square
%     xlabel('Y')
%     ylabel('Z')
%     zlabel('X')
%     title(sprintf('Raw Depth Data for slice %d',i))
    
    
%     % Use to increase number of data points!
%     temp = scatteredInterpolant(verticies(:,1),verticies(:,2),...
%         verticies(:,3));
%     Z_interp(:,i) = temp.Values;
    
%     % Plotting the processed data
%     figure;
%     scatter3(Y(:,i),Z_interp(:,i),-X(:,i),marker_size,'filled','k')
%     view([45 30]);
%     axis square
%     xlabel('Y')
%     ylabel('Z')
%     zlabel('X')
%     title(sprintf('Interpolated Depth Data for slice %d',i))
    
    
end

% Getting the average value for each slice
X_mean = mean(X,2);
Y_mean = mean(Y,2);
Z_mean = mean(Z,2);



