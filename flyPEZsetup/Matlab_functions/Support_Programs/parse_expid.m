function [expt_id_info,new_expt_id] = parse_expid(inputVar)
persistent Collection Genotypes Protocols Exp_protocol Handling_protocols Rearing_protocols
%     persistent Incubators
expt_id_info = 'error';
new_expt_id = 'error';
if nargin == 0
    inputVar = '0003000000650012';
end
if ischar(inputVar)
    experiment_id = inputVar;
    if numel(experiment_id) ~= 16
        return
    end
    
    
    if isempty(Collection)
        op_sys = system_dependent('getos');
        if ~isempty(strfind(op_sys,'Microsoft Windows 7'))
            file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
        else
            file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
        end
        
        Collection = load([file_dir filesep 'Saved_Collection.mat']);
        Genotypes  = load([file_dir filesep 'Saved_Genotypes.mat']);
        Protocols  = load([file_dir filesep 'Saved_Protocols.mat']);
        %         Incubators  = load([file_dir filesep 'Saved_Incubators.mat']);
        
        Exp_protocol       = load([file_dir filesep 'Saved_Exp_protocols.mat']);
        Handling_protocols = load([file_dir filesep 'Saved_Handling_protocols.mat']);
        Rearing_protocols  = load([file_dir filesep 'Saved_Rearing_protocols.mat']);
    end
    
    collectionNames = get(Collection.Saved_Collection,'ObsName');
    collectionRef = strcmp(collectionNames,experiment_id(1:4));
    genotypeNames = get(Genotypes.Saved_Genotypes ,'ObsName');
    genotypeRef = strcmp(genotypeNames,experiment_id(5:12));
    protocolNames = get(Protocols.Saved_Protocols ,'ObsName');
    protocolRef = strcmp(protocolNames,experiment_id(13:16));
    testA = max(collectionRef) == 0;
    testB = max(genotypeRef) == 0;
    testC = max(protocolRef) == 0;
    if testA || testB || testC
        return
    end
    
    parsed_collection = Collection.Saved_Collection(collectionRef,:);
    parsed_genotype   = Genotypes.Saved_Genotypes(genotypeRef,:);
    parsed_protocol   = Protocols.Saved_Protocols(protocolRef,:);
    
    parsed_expment = Exp_protocol.Exp_protocol(strcmp(get(Exp_protocol.Exp_protocol ,'ObsName'),parsed_protocol.Exp_protocol),:);
    parsed_handl   = Handling_protocols.Handling_protocols(strcmp(get(Handling_protocols.Handling_protocols ,'ObsName'),parsed_protocol.Handling_protocol),:);
    parsed_rearing = Rearing_protocols.Rearing_protocols(strcmp(get(Rearing_protocols.Rearing_protocols ,'ObsName'),parsed_protocol.Rearing_protocol),:);
    
    parsed_collection = set(parsed_collection,'ObsName',experiment_id);
    parsed_genotype = set(parsed_genotype,'ObsName',experiment_id);
    parsed_protocol = set(parsed_protocol,'ObsName',experiment_id);
    parsed_expment = set(parsed_expment,'ObsName',experiment_id);
    parsed_handl = set(parsed_handl,'ObsName',experiment_id);
    parsed_rearing = set(parsed_rearing,'ObsName',experiment_id);
    
    expt_id_info = [parsed_collection parsed_genotype parsed_protocol parsed_expment parsed_handl parsed_rearing];
    expt_id_info.Videos_In_Collection = [];
    expt_id_info.Archived_Videos = [];
else
    expt_id_info = inputVar;
end
temp_expt_id_info = expt_id_info(:,1:15);
var_names = [{'Incubator_Info'},{'Food_Type'},{'Foiled'},{'Stimuli_Type'},{'Stimuli_Vars'},{'Photo_Activation'},{'Photo_Vars'},...
    {'Compression_Opts'},{'Download_Opts'},{'Record_Rate'},{'Trigger_Type'},{'Time_Before'},{'Time_After'},{'Notes'},{'Room_Temp'}];
varspecs = cell(length(temp_expt_id_info),numel(var_names));
conversion = dataset([{varspecs},var_names]);
temp_expt_id_info = [temp_expt_id_info,conversion];
temp_expt_id_info.Photo_Vars = cell2struct({'0'},{'Photo_Delay'},2);

temp_expt_id_info.Food_Type = expt_id_info.Food_Type;
if expt_id_info.Darkness == 0
    temp_expt_id_info.Foiled = {'No'};
else
    temp_expt_id_info.Foiled = {'Yes'};
end
%     incubator_index = ismember(Incubators.incubatorList.Name,expt_id_info.Incubator_Name);
%     if sum(incubator_index) > 0
%         temp_expt_id_info.Incubator_Info = dataset2struct(Incubators.incubatorList(incubator_index,:));
%     else
temp_expt_id_info.Incubator_Info = struct;
temp_expt_id_info.Incubator_Info.Name = expt_id_info.Incubator_Name{1};
temp_expt_id_info.Incubator_Info.Location = expt_id_info.Location{1};
temp_expt_id_info.Incubator_Info.LightsOn = expt_id_info.Time_Lights_On{1};
temp_expt_id_info.Incubator_Info.LightsOff = expt_id_info.Time_Lights_Off{1};
temp_expt_id_info.Incubator_Info.Temperature = expt_id_info.Incubator_Temp{1};
temp_expt_id_info.Incubator_Info.Humidity = {'55 %'};
%     end

stimeloverv = num2str(expt_id_info.Stimuli_l_v{1});
stimstart = num2str(expt_id_info.Stimuli_start{1});
stimend = num2str(expt_id_info.Stimuli_stop{1});
if str2double(stimeloverv) > 0
    temp_expt_id_info.Stimuli_Type = {['loom_' stimstart 'to' stimend '_lv' stimeloverv '_blackonwhite']};
    temp_expt_id_info.Photo_Activation = {'None'};
else
    temp_expt_id_info.Stimuli_Type = {'None'};
    temp_expt_id_info.Photo_Activation = cellfun(@(u,v) sprintf('%s -- Intensity %s',u,num2str(v)),expt_id_info.Stimuli_type,...
        expt_id_info.Photo_intensity,'uniformoutput',false);
end
temp_expt_id_info.Stimuli_Vars= struct('Elevation',num2str(expt_id_info.Stimuli_elevation{1}),'Azimuth',num2str(expt_id_info.Stimuli_azimuth{1}),'Azimuth_Opts',...
    expt_id_info.Azimuth_options,'Relative_Pos',1,'Stimuli_Delay','0');

if expt_id_info.Photo_time{1} > 0
    temp_expt_id_info.Photo_Activation{1} = {['pulse_General_widthBegin' num2str(expt_id_info.Photo_time{1}),...
        '_widthEnd2000_cycles1_intensity' num2str(expt_id_info.Photo_intensity{1})]};
end

temp_expt_id_info.Time_Before = {'50'};
temp_expt_id_info.Time_After = {'100'};
temp_expt_id_info.Record_Rate = {'6000'};
temp_expt_id_info.Room_Temp = {num2str(expt_id_info.Room_temp{1})};
temp_expt_id_info.Compression_Opts = {'Use Compression (MP4 format)'};
temp_expt_id_info.Download_Opts = {'Restricted Full Rate'};
temp_expt_id_info.Trigger_Type = {'When Ready'};
new_expt_id = temp_expt_id_info;
if ~ischar(new_expt_id.Collection_Description{1})
    new_expt_id.Collection_Description = new_expt_id.Collection_Description{1};
end
if ~ischar(new_expt_id.Collection_Description{1})
    new_expt_id.Collection_Description = new_expt_id.Collection_Description{1};
end
if isempty(new_expt_id.Notes{1})
    new_expt_id.Notes = {''};
end
end
