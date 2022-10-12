function hpol = polar_pat(varargin)
    %POLAR  Polar coordinate plot.
    %   POLAR(THETA, RHO) makes a plot using polar coordinates of
    %   the angle THETA, in radians, versus the radius RHO.
    %   POLAR(THETA, RHO, S) uses the linestyle specified in string S.
    %   See PLOT for a description of legal linestyles.
    %
    %   POLAR(AX, ...) plots into AX instead of GCA.
    %
    %   H = POLAR(...) returns a handle to the plotted object in H.
    %
    %   Example:
    %      t = 0 : .01 : 2 * pi;
    %      polar(t, sin(2 * t) .* cos(2 * t), '--r');
    %
    %   See also POLARPLOT, PLOT, LOGLOG, SEMILOGX, SEMILOGY.
    
    %   Copyright 1984-2015 MathWorks, Inc.
    
    % Parse possible Axes input
    [cax, args, nargs] = axescheck(varargin{:});
    
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 5
        error(message('MATLAB:narginchk:tooManyInputs'));
    end        
    
    if nargs < 1 || nargs > 5
        error(message('MATLAB:polar:InvalidDataInputs'));
    elseif nargs == 2
        theta = args{1};
        rho = args{2};
        if ischar(rho)
            line_style = rho;
            rho = theta;
            [mr, nr] = size(rho);
            if mr == 1
                theta = 1 : nr;
            else
                th = (1 : mr)';
                theta = th(:, ones(1, nr));
            end
        else
            line_style = 'auto';
        end
    elseif nargs == 1
        theta = args{1};
        line_style = 'auto';
        rho = theta;
        [mr, nr] = size(rho);
        if mr == 1
            theta = 1 : nr;
        else
            th = (1 : mr)';
            theta = th(:, ones(1, nr));
        end
    elseif nargs == 5
        [theta, rho, line_style,plot_size,show_opt] = deal(args{1 : 5});
    elseif nargs == 4
        [theta, rho, line_style,plot_size] = deal(args{1 : 4});
         show_opt = 'show';
    else % nargs == 3
        [theta, rho, line_style] = deal(args{1 : 3});
        plot_size = .3;
        show_opt = 'show';
    end
    if ischar(theta) || ischar(rho)
        error(message('MATLAB:polar:InvalidInputType'));
    end
    if ~isequal(size(theta), size(rho))
        error(message('MATLAB:polar:InvalidInputDimensions'));
    end
    try
        theta = full(double(theta));
        rho = full(double(rho));
    catch
        error(message('MATLAB:specgraph:private:specgraph:nonNumericInput'));
    end
    
    % get hold state
    cax = newplot(cax);
    
    next = lower(get(cax, 'NextPlot'));
    hold_state = ishold(cax);

    if isa(handle(cax),'matlab.graphics.axis.PolarAxes')
        error(message('MATLAB:polar:PolarAxes'));
    end
    
    % The grid color will be based on the axes background and grid color.
    axColor = cax.Color;
    if strcmp(axColor,'none')
        % If the axes is transparent, fall back to the parent container
        parent = cax.Parent;
        
        if isprop(parent,'BackgroundColor')
            % Panels and Tabs use BackgroundColor
            axColor = parent.BackgroundColor;
        else
            % Figures use Color
            axColor = parent.Color;
        end
        
        if strcmp(axColor,'none')
            % A figure/tab with Color none is black.
            axColor = [0 0 0];
        end
    end
    
    gridColor = cax.GridColor;
    gridAlpha = cax.GridAlpha;
    if strcmp(gridColor,'none')
        % Grid color is none, ignore transparency.
        tc = gridColor;
    else
        % Manually blend the color of the axes with the grid color to mimic
        % the effect of GridAlpha.
        tc = gridColor.*gridAlpha + axColor.*(1-gridAlpha);
    end
    ls = cax.GridLineStyle;
    
    % Hold on to current Text defaults, reset them to the
    % Axes' font attributes so tick marks use them.
    fAngle = get(cax, 'DefaultTextFontAngle');
    fName = get(cax, 'DefaultTextFontName');
    fSize = get(cax, 'DefaultTextFontSize');
    fWeight = get(cax, 'DefaultTextFontWeight');
    fUnits = get(cax, 'DefaultTextUnits');
    set(cax, ...
        'DefaultTextFontAngle', get(cax, 'FontAngle'), ...
        'DefaultTextFontName', get(cax, 'FontName'), ...
        'DefaultTextFontSize', get(cax, 'FontSize'), ...
        'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
        'DefaultTextUnits', 'data');
    
    % only do grids if hold is off
    if ~hold_state
        
        % make a radial grid
        hold(cax, 'on');
        % ensure that Inf values don't enter into the limit calculation.
        arho = abs(rho(:));
        maxrho = max(arho(arho ~= Inf));
        if nargs < 4
            plot_size = maxrho;
        end        
        
        hhh = line([-maxrho, -maxrho, maxrho, maxrho], [-maxrho, maxrho, maxrho, -maxrho], 'Parent', cax);
        set(cax, 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatioMode', 'auto');
        set(cax,'Xlim',[-plot_size plot_size],'Ylim',[-plot_size plot_size]);
        v = [get(cax, 'XLim') get(cax, 'YLim')];
        ticks = sum(get(cax, 'YTick') >= 0);
        delete(hhh);
        % check radial limits and ticks
        rmin = 0;
        rmax = v(4);
        rticks = max(ticks - 1, 2);
        if rticks > 5   % see if we can reduce the number
            if rem(rticks, 2) == 0
                rticks = rticks / 2;
            elseif rem(rticks, 3) == 0
                rticks = rticks / 3;
            end
        end
        
        % define a circle
        th = 0 : pi / 50 : 2 * pi;
        xunit = cos(th);
        yunit = sin(th);
        % now really force points on x/y axes to lie on them exactly
        inds = 1 : (length(th) - 1) / 4 : length(th);
        xunit(inds(2 : 2 : 4)) = zeros(2, 1);
        yunit(inds(1 : 2 : 5)) = zeros(3, 1);
        % plot background if necessary
        if ~ischar(get(cax, 'Color'))
            patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
                'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
                'HandleVisibility', 'off', 'Parent', cax);
        end
        
        % draw radial circles
        c82 = cos(82 * pi / 180);
        s82 = sin(82 * pi / 180);
        rinc = (rmax - rmin) / rticks;
        for i = (rmin + rinc) : rinc : rmax
            hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
                'HandleVisibility', 'off', 'Parent', cax);
%             text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ...
%                 ['  ' num2str(i)], 'VerticalAlignment', 'bottom', ...
%                 'HandleVisibility', 'off', 'Parent', cax);

%             text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ...
%                 ['  ' num2str(i)], 'VerticalAlignment', 'bottom', ...
%                 'HandleVisibility', 'off', 'Parent', cax,'fontsize',12);

        end
        set(hhh, 'LineStyle', '-'); % Make outer circle solid
        
        % plot spokes
        th = (1 : 6) * 2 * pi / 12;
        cst = cos(th);
        snt = sin(th);
        cs = [-cst; cst];
        sn = [-snt; snt];
        line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
        
        % annotate spokes in degrees
        rt = 1.1 * rmax;
        for i = 1 : length(th)
%             text(rt * cst(i), rt * snt(i), int2str(i * 30),...
%                 'HorizontalAlignment', 'center', ...
%                 'HandleVisibility', 'off', 'Parent', cax);
            text(rt * cst(i), rt * snt(i), int2str(i * 30),...
                'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax,'fontsize',10);
            if i == length(th)
                loc = int2str(0);
            else
                loc = int2str(180 + i * 30);
            end
%            text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
%                'HandleVisibility', 'off', 'Parent', cax);
            
            text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax,'fontsize',10);
        end
        
        % set view to 2-D
        view(cax, 2);
        % set axis limits
        axis(cax, rmax * [-1, 1, -1.15, 1.15]);
    end
    
    % Reset defaults.
    set(cax, ...
        'DefaultTextFontAngle', fAngle , ...
        'DefaultTextFontName', fName , ...
        'DefaultTextFontSize', fSize, ...
        'DefaultTextFontWeight', fWeight, ...
        'DefaultTextUnits', fUnits );
    
    % transform data to Cartesian coordinates.
    xx = rho .* cos(theta);
    yy = rho .* sin(theta);
    
    if strcmp(show_opt,'show')
    % plot data on top of grid
        if strcmp(line_style, 'auto')
            q = plot(xx, yy, 'Parent', cax);
        elseif contains(line_style,'o')  && contains(line_style,'-')        %if dashed circle, zero pad the lines to center
            padded_x = zeros(length(xx)*2,1);        padded_x(2:2:length(xx)*2) = xx;
            padded_y = zeros(length(yy)*2,1);        padded_y(2:2:length(yy)*2) = yy;
            q = plot(padded_x, padded_y, line_style, 'Parent', cax);
        else
            q = plot(xx, yy, line_style, 'Parent', cax);
        end
    else 
        q = [];
    end
    
    if nargout == 1
        hpol = q;
    end
    
    if ~hold_state
        set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
        set(cax, 'NextPlot', next);
    end
    set(get(cax, 'XLabel'), 'Visible', 'on');
    set(get(cax, 'YLabel'), 'Visible', 'on');
    
    % Disable pan and zoom
    p = hggetbehavior(cax, 'Pan');
    p.Enable = false;
    z = hggetbehavior(cax, 'Zoom');
    z.Enable = false;
    
    if ~isempty(q) && ~isdeployed
        makemcode('RegisterHandle', cax, 'IgnoreHandle', q, 'FunctionName', 'polar');
    end
end