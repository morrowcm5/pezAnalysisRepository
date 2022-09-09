clear all
close all

analysis_path = '\\tier2\card\Data_pez3000';
new_file_path = struct2dataset(dir(analysis_path));
exp_dir =  new_file_path.name;

month_ids = [{20150101};{20150201};{20150301};{20150401};{20150501};{20150601};{20150701}];
video_count = zeros(length(month_ids),1);
for iterA = 1:(length(month_ids))
    if iterA ==(length(month_ids))
         filt_list = exp_dir(cellfun(@(x) str2double(x) >= month_ids{iterA},exp_dir));
    else
        filt_list = exp_dir(cellfun(@(x) str2double(x) >= month_ids{iterA} & str2double(x) < month_ids{iterA+1} ,exp_dir));
    end
    for iterZ = 1:length(filt_list)
        files_to_load = struct2dataset(dir(fullfile([analysis_path filesep filt_list{iterZ}],'run*')));
        for iterQ = 1:length(files_to_load)
            if iscell(files_to_load.name)
                videos_found = struct2dataset(dir(fullfile([analysis_path filesep filt_list{iterZ} filesep files_to_load.name{iterQ}],'*.mp4')));
            else
                videos_found = struct2dataset(dir(fullfile([analysis_path filesep filt_list{iterZ} filesep files_to_load.name],'*.mp4')));
            end
            video_count(iterA) = video_count(iterA) + length(videos_found.name);
        end
    end
end
