% test = depthFrameData(:,:,:,22); % Acquire 1 slice
% index = find(test>2500);
% test(index) = NaN;
%
% surf(test)
%
% % Edges = 500:2540;
% % H = histogram(test,Edges);
% %
% % test2 = test;
%
% % x = 1:size(test,1);
% % y = 1:size(test,2);
% % [X,Y] = meshgrid(x,y);

sample = struct('colorFrameData',[],'colorTimeData',[],'colorMetaData',...
    [],'depthFrameData',[],'depthTimeData',[],'depthMetaData',[]);
sample(1).Samplenumber = 2;
sample(2).Samplenumber = 3;

[colorFrameData, colorTimeData, colorMetaData] = getdata(colorVid);
[depthFrameData, depthTimeData, depthMetaData] = getdata(depthVid);