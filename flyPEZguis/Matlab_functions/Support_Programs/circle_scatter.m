function circle_scatter(azimuth_angle,elevation_angle,curr_axis)
    [x_data,y_data] = pol2cart(azimuth_angle,elevation_angle);
    
    set(curr_axis,'nextplot','add');
    zz = exp(1i*linspace(0, 2*pi, 101));

    plot(curr_axis,real(zz), imag(zz));
    set(curr_axis, 'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1])
    axis square;
    set(curr_axis,'box','off')
    set(curr_axis,'xtick',[])
    set(curr_axis,'ytick',[])
    text(1.2, 0, '0'); text(-.05, 1.2, '\pi/2');  text(-1.35, 0, '\pi');  text(-.075, -1.2, '-\pi/2');
    th = 0 : pi / 50 : 2 * pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1 : (length(th) - 1) / 4 : length(th);
    xunit(inds(2 : 2 : 4)) = zeros(2, 1);
    yunit(inds(1 : 2 : 5)) = zeros(3, 1);    
    rmin = 0;       rmax = 1;           rticks = (90/15); %each ring is 15 degrees
    rinc = (rmax - rmin) / rticks;

    for i = (rmin + rinc) : rinc : rmax
        line(xunit * i, yunit * i, 'LineStyle', '-', 'Color', rgb('light gray'), 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', gca);
    end    
    
    scatter(curr_axis,x_data,y_data);
    line([0 0],[-1 1],'color',rgb('black'),'linewidth',.5,'parent',curr_axis)
    line([-1 1],[0 0],'color',rgb('black'),'linewidth',.5,'parent',curr_axis)
end

