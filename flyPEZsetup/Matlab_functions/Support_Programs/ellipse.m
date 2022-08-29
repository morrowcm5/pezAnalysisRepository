function [X,Y] = ellipse(a,b,x0,y0,phi)
%ELLIPSE computes an arbitrary ellipse with given parameters.
%       [X,Y] = ELLIPSE(a,b,x0,y0,phi)
%
%   Input parameters:
%       a           Value of the major axis
%       b           Value of the minor axis
%       x0          Abscissa of the center point of the ellipse
%       y0          Ordinate of the center point of the ellipse
%       phi         Angle between x-axis and the major axis
%
%   Output:
%       X           X coordinates of ellipse
%       Y           Y coordinates of ellipse
%
%   Simple usage:
%       [x,y]=ellipse(5,3);
%       [x,y]=ellipse(5,3,pi/4);
%       [x,y]=ellipse(5,3,1,-2,pi/4);

% Author: Rajiv Narayan. 
% Code based on ellipsedraw Copyright (c)2003, Lei Wang <WangLeiBox@hotmail.com>

if (nargin < 2)|(nargin > 6),
    error('Please see help for INPUT DATA.');
    
elseif nargin == 2
    x0 = 0;     y0 = 0;
    phi = 0;    
    
elseif nargin == 3
    if ischar(x0) == 1

        x0 = 0; y0 = 0;
        phi = 0; 
    else
        phi = x0;  
        x0 = 0; y0 = 0;

    end
    
elseif nargin == 4     
    phi = 0;    
    
elseif nargin == 5

end



theta = [-0.03:0.01:2*pi];

% Parametric equation of the ellipse
%----------------------------------------
 x = a*cos(theta);
 y = b*sin(theta);



% Coordinate transform 
%----------------------------------------
 X = cos(phi)*x - sin(phi)*y;
 Y = sin(phi)*x + cos(phi)*y;
 X = X + x0;
 Y = Y + y0;
