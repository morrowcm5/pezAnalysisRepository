clear all
clc

total_video = [];
total_manual = [];
file_list = struct2dataset(dir(fullfile('Y:\Data_pez3000_analyzed','0061*')));
for iterA = 1:length(file_list.name)
    load(['Y:\Data_pez3000_analyzed\' file_list.name{iterA} filesep file_list.name{iterA} '_videoStatisticsMerged.mat']);
    load(['Y:\Data_pez3000_analyzed\' file_list.name{iterA} filesep file_list.name{iterA} '_manualAnnotations.mat']);
    total_video = [total_video;videoStatisticsMerged];
    total_manual = [total_manual;manualAnnotations];
end




done_logic = cellfun(@(x) ~isempty(x),total_manual.frame_of_leg_push);
total_manual = total_manual(done_logic,:);
total_video =total_video(total_manual.Properties.RowNames,:);

done_logic = cellfun(@(x) ~isnan(x),total_manual.frame_of_leg_push);
total_manual = total_manual(done_logic,:);
total_video = total_video(total_manual.Properties.RowNames,:);





%%
wing_up_count = cellfun(@(y,z) sum(ismember(y,z)),cellfun(@(x) x,total_video.supplement_frame_reference,'uniformoutput',false),...
    total_manual.frame_of_wing_movement,'uniformoutput',false);

leg_push_count = cellfun(@(y,z) sum(ismember(y,z)),cellfun(@(x) x,total_video.supplement_frame_reference,'uniformoutput',false),...
    total_manual.frame_of_leg_push,'uniformoutput',false);

wing_down_count = cellfun(@(y,z) sum(ismember(y,z)),cellfun(@(x) x,total_video.supplement_frame_reference,'uniformoutput',false),...
    total_manual.wing_down_stroke,'uniformoutput',false);

take_off_count = cellfun(@(y,z) sum(ismember(y,z)),cellfun(@(x) x,total_video.supplement_frame_reference,'uniformoutput',false),...
    total_manual.frame_of_take_off,'uniformoutput',false);

wing_pct = sum(cell2mat(wing_up_count)) / length(wing_up_count);
leg_pct = sum(cell2mat(leg_push_count)) / length(leg_push_count);
down_pct = sum(cell2mat(wing_down_count)) / length(wing_down_count);
jump_pct = sum(cell2mat(take_off_count)) / length(take_off_count);