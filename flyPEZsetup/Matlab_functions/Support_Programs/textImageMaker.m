function textImageMaker

clear all
close all
clc

func_name = mfilename('fullpath');
parent_dir = fileparts(func_name);
dest_dir = fullfile(parent_dir,'textImages_labelmaker');
if isdir(dest_dir) == 0, mkdir(dest_dir), end
font_sizes = (8:50);
text_asc = char(32:127);
char_count = length(text_asc);
font_count = length(font_sizes);
filtSize = 5;

blank_im_big = ones(100*1.5,100*2);
text_frame_cell = cell(char_count,1);
for i = 1:char_count
    imshow(blank_im_big)
    text(100,100*0.75,text_asc(i),'FontSize',100,...
        'HorizontalAlignment','center')
    text_frame = getframe;
    text_imA = double(text_frame.cdata(:,:,1)./255);
    text_imA = imfilter(text_imA,fspecial('disk',filtSize));
    text_imA(1:filtSize,:) = 1;
    text_imA(end-filtSize+1:end,:) = 1;
    text_imA(:,end-filtSize+1:end) = 1;
    text_imA(:,1:filtSize) = 1;
    text_frame_cell{i} = text_imA;
end

for j = 1:font_count
    font_size = font_sizes(j);
    spacing = round(font_size/8);
    blank_im_sml = ones(round(font_size*1.5),round(font_size*2));
    ascii_cell = cell(char_count,1);
    ascii_cell_even = cell(char_count,1);
    for i = 1:char_count
        old_size = size(blank_im_sml);
        text_imB = imresize(text_frame_cell{i},old_size);
        if i > 1
            text_imB = imadjust(text_imB);
            width_finder = round(min(text_imB));
            text_begin = find(width_finder == 0,1,'first')-spacing;
            text_end = find(width_finder == 0,1,'last')+spacing;
        else
            text_begin = 1;
            text_end = round(old_size(2)/2);
        end
        text_imC = text_imB(:,text_begin:text_end);
        text_imC = abs(text_imC-1);
        ascii_cell{i} = text_imC;
        ascii_cell_even{i} = abs(text_imB-1);
%         imshow(text_imC)
%         pause(0.5)
    end
    dest_name = ['asciiImages_fontsize_' int2str(font_size)];
    full_dest = fullfile(dest_dir,dest_name);
    save(full_dest,'ascii_cell')
    
    dest_name = ['evenspace_asciiImages_fontsize_' int2str(font_size)];
    full_dest = fullfile(dest_dir,dest_name);
    ascii_cell = ascii_cell_even;
    save(full_dest,'ascii_cell')
end
close(gcf)