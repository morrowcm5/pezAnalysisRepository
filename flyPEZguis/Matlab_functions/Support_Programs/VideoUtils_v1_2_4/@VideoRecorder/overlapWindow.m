function finalVideo = overlapWindow( obj, oriframe, inputframe, position ) 
% Copyright (C) 2012  Marc Vivet - marc.vivet@gmail.com
% All rights reserved.
%
%   $Revision: 2 $
%   $Date: 2012-04-16 21:44:46 +0100 (Mon, 16 Apr 2012) $
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are 
% met: 
%
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer. 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution. 
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are
% those of the authors and should not be interpreted as representing 
% official policies, either expressed or implied, of the FreeBSD Project.
    if ( isinteger ( oriframe ) ) 
        oriframe = double ( oriframe ) / 255.0;
    end
    
    if ( isinteger ( inputframe ) ) 
        inputframe = double ( inputframe ) / 255.0;
    end
        
    finalVideo = oriframe;

    frame = imresize(inputframe, [position(4), position(3)]);

    R = frame(:, :, 1);
    G = frame(:, :, 2);
    B = frame(:, :, 3);

    R(1:2, :) = 1;        
    R(end - 2:end, :) = 1;
    R(:, 1:2) = 1;        
    R(:, end - 2:end) = 1;

    G(1:2, :) = 1;        
    G(end - 2:end, :) = 1;
    G(:, 1:2) = 1;        
    G(:, end - 2:end) = 1;

    B(1:2, :) = 1;        
    B(end - 2:end, :) = 1;
    B(:, 1:2) = 1;        
    B(:, end - 2:end) = 1;

    frame(:, :, 1) = R;
    frame(:, :, 2) = G;
    frame(:, :, 3) = B;

    finalVideo(position(2):(position(2) + position(4) - 1), ...
        position(1):(position(1) + position(3) - 1), :) = frame(1:position(4), 1:position(3), :);
end