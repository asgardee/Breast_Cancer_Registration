vid = videoinput('winvideo', 1, 'RGB24_1280x1024');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;
preview(vid);

start(vid);

stoppreview(vid);

preview(vid);

start(vid);

stoppreview(vid);

preview(vid);

start(vid);

stoppreview(vid);

preview(vid);

start(vid);

stoppreview(vid);

vid.FramesPerTrigger = Inf;

preview(vid);

start(vid);

stoppreview(vid);

stop(vid);

preview(vid);

start(vid);

stoppreview(vid);

stop(vid);

stoppreview(vid);

stoppreview(vid);

preview(vid);

start(vid);

stoppreview(vid);

stop(vid);

preview(vid);

stoppreview(vid);

