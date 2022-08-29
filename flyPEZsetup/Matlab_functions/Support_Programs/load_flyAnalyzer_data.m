function load_flyAnalyzer_data
    exp_id = {'0061000004300343';'0061000004300346'};
%    exp_id = {'0061000004300456';'0061000004300457'};
    analysis_path = '\\tier2\card\Data_pez3000_analyzed';
    auto_filter = {'departure_az_ele_rad','stimulus_azimuth','bot_points_and_thetas'};
    remove_filter = {'Data_Acquisition','Fly_Count','Balancer','Physical_Condition','Fly_Detect_Accuracy','NIDAQ','Raw_Data_Decision','Curation_Status'};
    
    file_list = cellfun(@(x) struct2table(dir(fullfile([analysis_path filesep x filesep x '_flyAnalyzer3000_v12'],'*.mat'))),exp_id,'uniformoutput',false);
    file_name = cellfun(@(x) x.name,file_list,'uniformoutput',false);
    
    combo_data = load_data(analysis_path,exp_id);
    new_data = vertcat(combo_data.data);
    file_name = vertcat(file_name{:});
    new_data = filter_data(new_data,file_name);
    
    file_name = file_name(ismember(cellfun(@(x) x(1:52),file_name,'uniformoutput',false),new_data.Properties.RowNames));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    total_data = [];
    parfor iterA = 1:length(file_name)
        curr_id = cellfun(@(x) x(29:44),file_name(iterA),'uniformoutput',false);
        load_str = [analysis_path filesep curr_id{1} filesep curr_id{1} '_flyAnalyzer3000_v12' filesep];    
        
        analyzed_data = load([load_str file_name{iterA}]);
        analyzed_data = analyzed_data.saveobj(:,auto_filter);
        total_data = [total_data;analyzed_data];
    end
    total_data = total_data(new_data.Properties.RowNames,:);
    new_data = [new_data,total_data];               clear total_data  
    new_data(:,remove_filter) = [];
    
    new_data = new_data(cellfun(@(x,y) x< length(y(:,1)), new_data.visStimFrameStart,new_data.bot_points_and_thetas),:);
    position_info = cell2mat(cellfun(@(x,y) y(x,:), new_data.visStimFrameStart,new_data.bot_points_and_thetas,'uniformoutput',false));
    
    start_pos = (position_info(:,3) - cell2mat(new_data.stimulus_azimuth));
    for iterA = 1:2
        start_pos(start_pos < 0) = start_pos(start_pos < 0) + 2*pi;
        start_pos(start_pos > 2*pi) = start_pos(start_pos > 2*pi) - 2*pi;
    end
    start_pos(start_pos > pi) = 2*pi - start_pos(start_pos > pi);
    
    
    position_vect = cellfun(@(x,y) x,new_data.bot_points_and_thetas,new_data.visStimFrameStart,'uniformoutput',false);
    dist_move = cellfun(@(x) sum(sqrt((x(1:(end-1),1) - x(2:end,1)).^2 + (x(1:(end-1),2) - x(2:end,2)).^2)),position_vect,'uniformoutput',false);
    rotation_amount = cellfun(@(x) sum(abs(x(1:(end-1),3) - x(2:end,3)))*180/pi,position_vect,'uniformoutput',false);
    
    

    jump_logic = cellfun(@(x) ~isnan(x), new_data.frame_of_leg_push);
    color_vect = zeros(length(dist_move),3);
    color_vect(jump_logic,:) = repmat(rgb('red'),sum(jump_logic),1);
    color_vect(~jump_logic,:) = repmat(rgb('blue'),sum(~jump_logic),1);
    figure
    filt_logic = cell2mat(rotation_amount) <= 15;
    scatter3(cell2mat(rotation_amount(filt_logic)),cell2mat(dist_move(filt_logic)),start_pos(filt_logic),20,color_vect(filt_logic,:),'filled');
    
    
    
    
    
    stim_dur = cellfun(@(x,y,z) (x-y - z)/6, new_data.frame_of_leg_push,new_data.visStimFrameStart,new_data.visStimFrameCount);
    scatter(cell2mat(rotation_amount(jump_logic)),stim_dur(jump_logic))    
%    scatter(cell2mat(dist_move),cell2mat(rotation_amount),36,color_vect,'filled');
    
    results = zeros(4,1);
    results(1) = sum(abs(cell2mat(rotation_amount)) <= 15 & jump_logic);
    results(2) = sum(abs(cell2mat(rotation_amount)) >  15 & jump_logic);
    results(3) = sum(abs(cell2mat(rotation_amount)) <= 15 & ~jump_logic);
    results(4) = sum(abs(cell2mat(rotation_amount)) > 15 & ~jump_logic);

    position_info = cell2mat(cellfun(@(x,y) y(x,:), new_data.visStimFrameStart,new_data.bot_points_and_thetas,'uniformoutput',false));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    figure
    org_pos = (new_data.fly_detect_azimuth.*pi/180 - cell2mat(new_data.stimulus_azimuth));
    org_pos(org_pos < 0) = org_pos(org_pos < 0) .*-1;
    subplot(2,2,1)
    circ_plot(org_pos,'hist',[],(360/15),true,true,'linewidth',2,'color','r');     %histogram with 15 degree bins
    fly_count = length(org_pos);
    title(sprintf('stimuli position at trigger frame\n number of flies :: %6.0f',fly_count),'parent',gca);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    start_pos = (position_info(:,3) - cell2mat(new_data.stimulus_azimuth));
    for iterA = 1:2
        start_pos(start_pos < 0) = start_pos(start_pos < 0) + 2*pi;
        start_pos(start_pos > 2*pi) = start_pos(start_pos > 2*pi) - 2*pi;
    end
    start_pos(start_pos > pi) = 2*pi - start_pos(start_pos > pi);
    subplot(2,2,2)
    circ_plot(start_pos,'hist',[],(360/15),true,true,'linewidth',2,'color','r');     %histogram with 15 degree bins
    pos_logic = (start_pos >= 75*pi/180) & (start_pos <= 105*pi/180);
    neg_logic = (start_pos >= 255*pi/180) & (start_pos <= 285*pi/180);
    in_range_data = new_data(pos_logic | neg_logic,:);
    title(sprintf('stimuli position at trigger frame\n number of flies in range :: %6.0f',height(in_range_data)),'parent',gca);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    jump_in_range = in_range_data(cellfun(@(x) ~isnan(x), in_range_data.frame_of_leg_push),:);
    jump_in_range = jump_in_range(cellfun(@(x,y) x< length(y(:,1)), jump_in_range.frame_of_leg_push,jump_in_range.bot_points_and_thetas),:);
    position_info = cell2mat(cellfun(@(x,y) y(x,:), jump_in_range.frame_of_leg_push,jump_in_range.bot_points_and_thetas,'uniformoutput',false));   
    
    leg_pos = (position_info(:,3) - cell2mat(jump_in_range.stimulus_azimuth));
    for iterA = 1:2
        leg_pos(leg_pos < 0) = leg_pos(leg_pos < 0) + 2*pi;
        leg_pos(leg_pos > 2*pi) = leg_pos(leg_pos > 2*pi) - 2*pi;
    end
    leg_pos(leg_pos > pi) = 2*pi - leg_pos(leg_pos > pi);
    subplot(2,2,3)
    circ_plot(leg_pos,'hist',[],(360/15),true,true,'linewidth',2,'color','r');     %histogram with 15 degree bins
    title(sprintf('stimuli position at frame of leg push, for flies in range\n number of jumpers :: %6.0f',length(leg_pos)),'parent',gca);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    
%   stim_size = cellfun(@(x,y,z) -atan(40./(((x-y) - z)/6)) * 360/pi, jump_in_range.frame_of_leg_push,jump_in_range.visStimFrameStart,jump_in_range.visStimFrameCount); 
%   stim_size(stim_size<0) = stim_size(stim_size<0)+360;
   stim_dur = cellfun(@(x,y,z) (x-y - z)/6, jump_in_range.frame_of_leg_push,jump_in_range.visStimFrameStart,jump_in_range.visStimFrameCount); 
   
   %subplot(2,2,4)
   full_diff = cellfun(@(x,y) ((y-x)/6), jump_in_range.frame_of_wing_movement,jump_in_range.frame_of_take_off); 
   
   logic_filt =  true(length(stim_dur),1);
%   logic_filt = stim_dur >= -300 & full_diff < 50;
   figure
   scatter3(leg_pos(logic_filt),stim_dur(logic_filt),full_diff(logic_filt));
   xlabel('azimuth of stimuli')
   ylabel('time to contact')
   zlabel('differential')   
   
   c = clusterdata([leg_pos(logic_filt),stim_dur(logic_filt),full_diff(logic_filt)],'linkage','ward','savememory','on','maxclust',8);
   figure
   subplot(2,2,1);boxplot(leg_pos,c);
   subplot(2,2,2);boxplot(stim_dur,c);
   subplot(2,2,3);boxplot(full_diff,c);
   
   
%    [idx,C,~,~] = kmeans([leg_pos(logic_filt),stim_dur(logic_filt),full_diff(logic_filt)],8,'distance','sqEuclidean','Replicates',10);
%    hold all
%    scatter3(C(:,1),C(:,2),C(:,3),36,rgb('red'),'filled');
%    drawnow
    
end
function combo_data = load_data(analysis_path,exp_id)                                 % runs a timer to load faster
    auto_filter = {'visStimFrameStart','visStimFrameCount','visStimProtocol'};
    vid_filter = {'temp_degC','fly_detect_azimuth','frame_count','supplement_frame_reference'};
    asses_filter = {'Data_Acquisition','Fly_Count','Gender','Balancer','Physical_Condition','Fly_Detect_Accuracy','NIDAQ','Raw_Data_Decision','Curation_Status'};
    manual_filter = {'frame_of_wing_movement','frame_of_leg_push','wing_down_stroke','frame_of_take_off'};
    combo_data = struct;
    for iteration = 1:length(exp_id)
        auto_annotate = load([analysis_path filesep exp_id{iteration} filesep exp_id{iteration} '_automatedAnnotations']);
        auto_annotate = auto_annotate.automatedAnnotations(:,auto_filter);

        annotations = load([analysis_path filesep exp_id{iteration} filesep exp_id{iteration} '_manualAnnotations']);
        annotations = annotations.manualAnnotations(:,manual_filter);

        vidStats = load([analysis_path filesep exp_id{iteration} filesep exp_id{iteration} '_videoStatisticsMerged']);
        vidStats = dataset2table(vidStats.videoStatisticsMerged(:,vid_filter));

        Exp_data = load([analysis_path filesep exp_id{iteration} filesep exp_id{iteration} '_rawDataAssessment.mat']);
        test_data = Exp_data.assessTable(:,asses_filter);

        order_list = annotations.Properties.RowNames;
        auto_annotate = auto_annotate(order_list,:);
        vidStats = vidStats(order_list,:);
        test_data = test_data(order_list,:);

        curr_data = test_data;
        curr_data = curr_data(strcmp(curr_data.Raw_Data_Decision,'Pass'),:);
        curr_data = curr_data(strcmp(curr_data.NIDAQ,'Good'),:);
        curr_data = curr_data(strcmp(curr_data.Fly_Detect_Accuracy,'Good'),:);
        new_names = cellfun(@(x) x(1:23),curr_data.Properties.RowNames,'uniformoutput',false);
        old_names = cellfun(@(x) x(1:23),test_data.Properties.RowNames,'uniformoutput',false);
        curr_table = tabulate(new_names);

        [locA,~] = ismember(old_names,curr_table(cell2mat(curr_table(:,2)) >= 5,1));        %exp with 5 or more good videos
        test_data = test_data(locA,:);                          vidStats = vidStats(locA,:);
        auto_annotate = auto_annotate(locA,:);                  annotations = annotations(locA,:);

        proto_id = cellfun(@(x) x(13:16),exp_id(iteration),'uniformoutput',false);
        if str2double(proto_id) > 100
        result = parse_expid_v2(exp_id{iteration});
        else
        [~,result] = parse_expid(exp_id{iteration});
        end

        new_food_var = cellfun(@(x,y) sprintf('%s -- Foilded :: %s',x,y),result.Food_Type,result.Foiled,'uniformoutput',false);

        combo_data(iteration).exp_id = exp_id{iteration};
        combo_data(iteration).ParentA.Name = result.ParentA_name{:};
        combo_data(iteration).ParentA.Robot_ID = result.ParentA_ID{:};
        combo_data(iteration).ParentA.Genotype = result.ParentA_genotype{:};
        combo_data(iteration).ParentB.Name = result.ParentB_name{:};
        combo_data(iteration).ParentB.Robot_ID = result.ParentB_ID{:};
        combo_data(iteration).ParentB.Genotype = result.ParentB_genotype{:};
        combo_data(iteration).Incubator = result.Incubator_Info.Name;
        combo_data(iteration).Food_Type = new_food_var;
        combo_data(iteration).Stim_Type = result.Stimuli_Type;
        combo_data(iteration).Photo_Type = result.Photo_Activation;
        combo_data(iteration).Elevation = result.Stimuli_Vars.Elevation;
        combo_data(iteration).Azimuth = result.Stimuli_Vars.Azimuth;
        combo_data(iteration).data = [test_data,annotations,auto_annotate,vidStats];
    end
end
function temp_data = filter_data(combo_data,file_name)                         % removes bad data
    temp_data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Single'),x.Fly_Count),:),{combo_data},'uniformoutput',false);
    temp_data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Pass'),x.Raw_Data_Decision),:),temp_data,'uniformoutput',false);
    temp_data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.NIDAQ),:),temp_data,'uniformoutput',false);
    temp_data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.Fly_Detect_Accuracy),:),temp_data,'uniformoutput',false);
    temp_data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.Physical_Condition),:),temp_data,'uniformoutput',false);
    temp_data = cellfun(@(x) x(cellfun(@(y,z) ~isempty(y) ,x.frame_of_wing_movement),:),temp_data,'uniformoutput',false);           %done records
%    temp_data = cellfun(@(x) x(cellfun(@(y,z) ~isnan(y) ,x.frame_of_leg_push),:),temp_data,'uniformoutput',false);           %done records
    temp_data = cellfun(@(x) x(cellfun(@(y,z) z > y | isnan(z) ,x.visStimFrameStart,x.frame_of_wing_movement),:),temp_data,'uniformoutput',false);

    temp_data = cellfun(@(x) x(cellfun(@(y,z) ismember(y,z) | isnan(y) ,x.frame_of_take_off,...
        cellfun(@(a) a,x.supplement_frame_reference,'uniformoutput',false)),:),temp_data,'uniformoutput',false);
    
    part_1 = cellfun(@(x) x.Properties.RowNames,temp_data,'uniformoutput',false);       
    part_2 = cellfun(@(x) x(1:52),file_name,'uniformoutput',false);
    temp_data = cellfun(@(x) x(ismember(part_1{1},part_2),:),temp_data,'uniformoutput',false);
    
    temp_data = temp_data{1};
end

