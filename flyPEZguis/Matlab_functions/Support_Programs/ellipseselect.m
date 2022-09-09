function he=ellipseselect(varargin)
%ELLIPSESELECT An interactive ellipse selection tool
%
%   HE = ELLIPSESELECT('init', A, B, X0, Y0, PHI, STYLE)
%   Creates the ellipse and initialzes callbacks. Returns the handle of the
%   ellipse HE.
%   Ellipse parameters:
%       A           Length of the semi-major axis
%       B           Length of the semi-minor axis
%       X0          Abscissa of the center of the ellipse
%       Y0          Ordinate of the center of the ellipse
%       PHI         Angle (in radians) between x-axis and the major axis
%       STYLE       Definition of the plotted line style
%   Usage:
%   Once created, the ellipse shape can the adjusted interactively using the mouse. 
%   The center can be moved by dragging the 'x' at the center of the
%   ellipse. The lengths of the axes can be adjusted by dragging on the red
%   and black control points on the ellipse. The ellipse can be rotated
%   through an arbitrary angle by left clicking and dragging on the
%   ellipse boundary. 
%   The ellipse parameters are saved in the ellipse handle's userdata
%   property and can be obtained using:
%   PARAMS = ELLIPSESELECT('params', HE), where PARAMS is a structure
%   with the ellipse parameters.
%   The ellipse can be deleted by right clicking on the ellipse boundary
%   and selecting 'delete' from the context-menu. Alternatively, the ellipse
%   can be deleted programmatically by using the following call to ELLIPSESELECT.
%   STATUS = ELLIPSESELECT('deletehandle',HE)
%   STATUS returns 0 if the delete operation was successful, -1 otherwise.
%  
%   Example:
%       %generate some data
%       x=randn(500,2).*repmat([0.1,0.05],500,1);
%       phi=pi/4; rotmat = [cos(phi),sin(phi);-sin(phi),cos(phi)];
%       y=rotmat*x';
%       scatter(y(1,:),y(2,:),'c.'); hold on
%       axis([-1,1,-1,1])
%       %create an ellipse
%       he = ellipseselect('init',1,1,0,0,pi/4,'r-.');
%       % modify ellipse line style
%       set(he,'LineWidth',2);
%       % get current ellipse parameters
%       params = ellipseselect('params',he);
%       % delete the ellipse
%       status = ellipseselect('deletehandle',he);

%   Known issues: overwrites userdata of figure

% Author: Rajiv Narayan,  <askrajiv@gmail.com>
% Dept. of Biomedical Engineering, Boston University.
% Last Revision: 8-Oct-2006.
% Copyright (c)2006, Rajiv Narayan
% Ellipse plotting via ellipsedraw (Copyright (c)2003, Lei Wang
% <WangLeiBox@hotmail.com>)

nin=nargin;
    if(~nin)
        error('no action specified');
    else
        action=varargin{1};
    end

switch(action)
    
    case 'init'
        
        %get ellipse params
        ud.a=varargin{2};
        ud.b=varargin{3};
        ud.x0=varargin{4};
        ud.y0=varargin{5};
        ud.phi=varargin{6};
        ud.style=varargin{7};
        curr_axis = varargin{8};
        
        %draw ellipse and mark center
        [x,y]=ellipse(ud.a,ud.b,ud.x0,ud.y0,ud.phi);
        he=plot(x,y,ud.style,'linewidth',2,'parent',curr_axis);
%        lincolor=get(he,'color');
        hold on;
        hc=plot(ud.x0,ud.y0,'marker','x','color',rgb('purple'),'linewidth',2,'parent',curr_axis);

        %ellipse control pts
        ha=plot(ud.x0+cos(ud.phi)*ud.a,ud.y0+sin(ud.phi)*ud.a,'marker','o','color',rgb('light blue'),'linewidth',2,'markerfacecolor',rgb('light blue'),'parent',curr_axis);
        hb=plot(ud.x0-sin(ud.phi)*ud.b,ud.y0+cos(ud.phi)*ud.b,'marker','o','color',rgb('green'),'linewidth',2,'markerfacecolor',rgb('green'),'parent',curr_axis);
        
        %setup callbacks
        cbk=cbkstr(he, 'down');
        set(he,'buttondownfcn',cbk);
        cbk=cbkstr(ha, 'majordown');
        set(ha,'buttondownfcn',cbk);
        cbk=cbkstr(hb, 'minordown');
        set(hb,'buttondownfcn',cbk);
        
        cbk=cbkstr(hc, 'origindown');
        set(hc,'buttondownfcn',cbk);
        
        %setup contextmenu
        cmenu=uicontextmenu;
        set(he,'uicontextmenu',cmenu);
        cbk=cbkstr(he, 'delete');
        item=uimenu(cmenu, 'label', 'delete', 'callback', cbk);
        ud.axis=axis;
        ud.he=he;
        ud.hc=hc;
        ud.ha=ha;
        ud.hb=hb;
        
        %save userdata
        set(he,'userdata',ud)
        set(hc,'userdata',he);
        set(ha,'userdata',he);
        set(hb,'userdata',he);
        set(gcf,'userdata',ud);
   %mouse click on ellipse boundary        
   case 'down' 
        which_button = get(gcf,'selectiontype');
        switch which_button
            
            case 'normal' %left click
                cbk=cbkstr(gco, 'move');
                ud=get(gco,'userdata');
                set(gco, 'linewidth', 2);
                set (gcf, 'windowbuttonmotionfcn' , cbk);
                cbk=cbkstr(gco, 'up');
                %also save current mouse position
                pt=get(gca, 'currentpoint');
                ud.oldpt=pt(1,1:2);                
                set (gcf, 'windowbuttonupfcn' , cbk, 'doublebuffer', 'on','userdata',ud);
        end
	%Rotate ellipse
    case 'move' 
        
        pt=get(gca, 'currentpoint');
        pt=pt(1,1:2);
        ud=get(gcf,'userdata');

        ax=ud.a*cos(ud.phi);
		ay=ud.a*sin(ud.phi);
		dphi = atan2(((pt(2)-ud.y0)),((pt(1)-ud.x0))) - atan2(((ud.oldpt(2)-ud.y0)),((ud.oldpt(1)-ud.x0))) ;
        ud.phi =ud.phi +dphi;    
        ud.oldpt=pt;
        
        [x,y]=ellipse(ud.a,ud.b,ud.x0,ud.y0,ud.phi);
        set(gco,'xdata',x,'ydata',y);
        set(ud.ha,'xdata',ud.x0+cos(ud.phi)*ud.a,'ydata',ud.y0+ ...
                  sin(ud.phi)*ud.a);
        set(ud.hb,'xdata',ud.x0-sin(ud.phi)*ud.b,'ydata',ud.y0+cos(ud.phi)*ud.b);
        axis(ud.axis)
        set(gcf,'userdata',ud);
	% Done rotation
    case 'up' 
		ud=get(gcf,'userdata');
		set(ud.he,'userdata',ud);
		set(gcf,'windowbuttonupfcn','', 'windowbuttonmotionfcn', '', 'doublebuffer', 'off');
		set(gco, 'linewidth', 2);
 
    % mouse click on center           
    case 'origindown' 
        he=get(gco,'userdata');
        ud=get(he,'userdata');
        cbk=cbkstr(gco, 'originmove');
        set(gco, 'linewidth', 3);
        set (gcf, 'windowbuttonmotionfcn' , cbk);
        cbk=cbkstr(gco, 'originup');
        set (gcf, 'windowbuttonupfcn' , cbk, 'doublebuffer', 'on','userdata',ud);

    %move origin    
    case 'originmove' 
		
		pt=get(gca, 'currentpoint');
		pt=pt(1,1:2);
		ud=get(gcf,'userdata');
		ud.x0=pt(1);
		ud.y0=pt(2);
		
		[x,y]=ellipse(ud.a,ud.b,ud.x0,ud.y0,ud.phi);
		
		set(ud.he,'xdata',x,'ydata',y);
		set(ud.hc,'xdata',ud.x0,'ydata',ud.y0);
		set(ud.ha,'xdata',ud.x0+cos(ud.phi)*ud.a,'ydata',ud.y0+ ...
                  sin(ud.phi)*ud.a);
		set(ud.hb,'xdata',ud.x0-sin(ud.phi)*ud.b,'ydata',ud.y0+ ...
                  cos(ud.phi)*ud.b);            
		axis(ud.axis)
		set(gcf, 'userdata',ud);
	
	% Done move origin
    case 'originup' 
	
        ud=get(gcf,'userdata');
        set(ud.he,'userdata',ud);
        set(gcf,'windowbuttonupfcn','', 'windowbuttonmotionfcn', '', 'doublebuffer', 'off');
        set(gco, 'linewidth', 2);
	
    % major axis operations
    case 'majordown'
        he=get(gco,'userdata');
        ud=get(he,'userdata');
        cbk=cbkstr(gco, 'majormove');
        set(gco, 'linewidth', 3);
        set (gcf, 'windowbuttonmotionfcn' , cbk);
        cbk=cbkstr(gco, 'majorup');
        set (gcf, 'windowbuttonupfcn' , cbk, 'doublebuffer', 'on','userdata',ud);
         
    case 'majormove'
		ud=get(gcf,'userdata');
		pt=get(gca, 'currentpoint');
		pt=pt(1,1:2);
		
		%dist from center
		ud.a=sqrt((ud.x0-pt(1))^2+(ud.y0-pt(2))^2);
		[x,y]=ellipse(ud.a,ud.b,ud.x0,ud.y0,ud.phi);
		
		set(ud.he,'xdata',x,'ydata',y);
		set(ud.hc,'xdata',ud.x0,'ydata',ud.y0);
		set(ud.ha,'xdata',ud.x0+cos(ud.phi)*ud.a,'ydata',ud.y0+ ...
               sin(ud.phi)*ud.a);
		set(ud.hb,'xdata',ud.x0-sin(ud.phi)*ud.b,'ydata',ud.y0+ ...
               cos(ud.phi)*ud.b);            
		axis(ud.axis)
		set(gcf, 'userdata',ud);
		
    case 'majorup'
		ud=get(gcf,'userdata');
		set(ud.he,'userdata',ud);
		set(gcf,'windowbuttonupfcn','', 'windowbuttonmotionfcn', '', 'doublebuffer', 'off');
		set(gco, 'linewidth', 2);
		
    %minor axis ops
    case 'minordown'
        he=get(gco,'userdata');
        ud=get(he,'userdata');
        cbk=cbkstr(gco, 'minormove');
        set(gco, 'linewidth', 3);
        set (gcf, 'windowbuttonmotionfcn' , cbk);
        cbk=cbkstr(gco, 'majorup');
        set (gcf, 'windowbuttonupfcn' , cbk, 'doublebuffer', 'on','userdata',ud);
     
    case 'minormove'
		ud=get(gcf,'userdata');
		pt=get(gca, 'currentpoint');
		pt=pt(1,1:2);
		
		%dist from center
		d=sqrt((ud.x0-pt(1))^2+(ud.y0-pt(2))^2);
		ud.b=d;
		[x,y]=ellipse(ud.a,ud.b,ud.x0,ud.y0,ud.phi);
		
		set(ud.he,'xdata',x,'ydata',y);
		set(ud.hc,'xdata',ud.x0,'ydata',ud.y0);
		set(ud.ha,'xdata',ud.x0+cos(ud.phi)*ud.a,'ydata',ud.y0+ ...
               sin(ud.phi)*ud.a);
		set(ud.hb,'xdata',ud.x0-sin(ud.phi)*ud.b,'ydata',ud.y0+ ...
               cos(ud.phi)*ud.b);            
		axis(ud.axis)
		set(gcf, 'userdata',ud);
		
    case 'minorup'
		ud=get(gcf,'userdata');
		set(ud.he,'userdata',ud);
		set(gcf,'windowbuttonupfcn','', 'windowbuttonmotionfcn', '', 'doublebuffer', 'off');
		set(gco, 'linewidth', 2);
		
   % delete ellipse callback
   case 'delete' 
		ud=get(gco,'userdata');
		delete(ud.hc);
		delete(ud.he);
		delete (ud.ha);
		delete (ud.hb);
		hold off

    % delete handle programmatically   
   case 'deletehandle'
       if (ishandle(varargin{2}))
         ud = get(varargin{2},'userdata');    
         delete(ud.hc);
         delete(ud.he);
         delete(ud.ha);
         delete(ud.hb);
         hold off;
         he = 0;
       else
         he=-1;
       end
       
   %return ellipse parameters
   case 'params'
        if (ishandle(varargin{2}))
            he = get(varargin{2},'userdata');    
        else
            he = [];
        end
            
   otherwise
        disp (action);
end    


function s = cbkstr(hnd, action)
    %s=sprintf ('cbkswitch(''%s'' , ''%s'', %s)',mfilename, action, num2str(hnd));
    %s=sprintf ('cbkswitch(''%s'' , ''%s'', ''line'')',mfilename, action);
    s=sprintf ('cbkswitch(''%s'' , ''%s'')',mfilename, action);
