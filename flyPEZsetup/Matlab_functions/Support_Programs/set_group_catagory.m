function Saved_Group_IDs = set_group_catagory(Saved_Group_IDs)
    op_sys = system_dependent('getos');
    if ~isempty(strfind(op_sys,'Microsoft Windows 7'))
        white_path = '\\DM11\cardlab\Pez3000_Gui_folder\Experiment_Line_Data';
        var_path = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
    else
        white_path = '/Volumes/cardlab/Pez3000_Gui_folder/Experiment_Line_Data';
        var_path = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
    end    
    if nargin == 0
        load([var_path filesep 'Saved_Group_IDs']);
    end    
    exp_list = Saved_Group_IDs.Experiment_ID;
    
    white_dir = struct2dataset(dir(fullfile(white_path,'*.mat')));
    white_dir = white_dir.name;
    
    Saved_Group_IDs.Catagory(ismember(exp_list,regexprep(white_dir,'.mat',''))) = {'White_Stimuli'};
    save([var_path filesep 'Saved_Group_IDs'],'Saved_Group_IDs');
end