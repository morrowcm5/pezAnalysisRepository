%% Simple VideoRecorder Example
% In here you can see and example of how to use the *VideoRecorder* object.

%% Create a new VideoRecorder Object
% First of all we have to define the video name and the format of this new
% video, in this example the video name is set to *NewVideo* and the format
% to *mov*.
cd('C:\Users\cardlab\Documents')
vr = VideoRecorder('NewVideo', 'Format', 'avi');
% wobj = VideoWriter('C:\Users\cardlab\Documents\NewVideo.mp4','MPEG-4');
% open(wobj)
%% Insert frames to the VideoRecorder Object
% After we have created the *VideoRecorder* object, we are ready to insert
% frames to this object.

vp = VideoPlayer('Y:\Data_pez3000\20140515\run006_pez3004_20140515\run006_pez3004_20140515_expt0019000004300102_vid0001.mp4');

tic
for i = 1:100 
    vr.addFrame(vp.Frame);
%     writeVideo(wobj,vp.Frame)
    vp + 1;
end
toc
clear vp;
% close(wobj)

%% Close the VideoRecorder Object
% Finally we have to close the video sequence by releasing the
% *VideoRecorder* object.

clear vr;
return
%% See the Recorded Video
% Finally with this script you can see the recorded video.

vp = VideoPlayer('C:\Users\cardlab\Documents\NewVideo.mp4');

while (true)   
    plot(vp);
    drawnow;
    
    if (~vp.nextFrame)
       break;
    end
end

clear vp;
    