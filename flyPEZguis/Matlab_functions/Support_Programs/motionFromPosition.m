function motion_array = motionFromPosition(position_array,flipBool,mm_per_pixel,sample_freq)
%motionFromPosition Receives position information from tracked FlyPEZ data
%in pixels and return position, speed, and acceleration
%   'position_vector' should be a 2-by-n or 3-by-n array where n is the
%   number of tracked frames and each column represents either x,y or
%   x,y,z which should be obtained from the graphTable, as well as
%   'flipBool' and 'mm_per_pixel'. 'sample_freq' (usually 6000) is the
%   record rate, found in the excel file.  If 'position_vector' is 1-by-n,
%   it is assumed to be rotation in radians.
%
%   'motion_vector' is a 3-by-n array.  The first column is position, the
%   second is speed, and the third is acceleration
%
%   If 'position_vector' is 1-by-n, the columns in 'motion_vector' are:
%   deg, deg/s, and deg/s^2.  Otherwise it is mm, m/sec, and m/sec^2 (the
%   first is intentionally left in millimeters).

if flipBool
    for iFlip = 1:size(position_array,2)
        position_array(:,iFlip) = position_array(:,iFlip)*(-1);
    end
end
    
if size(position_array,2) > 1
    distVec = abs(diff(position_array));% change in position per frame
    distVec = sqrt(sum(distVec.^2,2));% distance calculation
    distVec = cumsum(distVec);% cumulative distance traveled per frame
    distVec = cat(1,0,distVec);% adds back the frame 1 value lost by 'diff'
    distVec = distVec*mm_per_pixel;% convert to mm
else
    distVec = unwrap(position_array);
    distVec = rad2deg(distVec);% convert to degrees
end

speedVec = cat(1,0,diff(distVec));% relative to previous frame
accelVec = cat(1,0,diff(speedVec));% relative to 2 previous frames
speedVec = speedVec/1000*sample_freq;% convert to meter /s
accelVec = accelVec/1000*sample_freq.^2;% convert to meter /s^2

motion_array = [distVec speedVec accelVec];

end

