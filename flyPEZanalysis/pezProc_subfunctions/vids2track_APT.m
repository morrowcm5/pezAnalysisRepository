function vids2track_APT(exptID)

trkdir = fullfile('/groups/card/cardlab/Data_pez3000_analyzed/',exptID,'APT_Results/'); %directory where trk files should go
trkdir = replace(trkdir,'\','/');
if ~exist(fullfile('Z:\Data_pez3000_analyzed\',exptID,'APT_Results'),'dir')
    mkdir(fullfile('Z:\Data_pez3000_analyzed\',exptID,'APT_Results'))
end

try
    load('Z:\Pez3000_Gui_folder\Gui_saved_variables\APT2Track.mat')
catch
    movies2track = table;
end

load(fullfile('Z:\Data_pez3000_analyzed',exptID,[exptID '_rawDataAssessment']))
assessTable.APT_Tracking(~strcmp(assessTable.Analysis_Status,'Analysis complete'))=0;

load(fullfile('Z:\Data_pez3000_analyzed',exptID,[exptID '_dataForVisualization']))

load(fullfile('Z:\Data_pez3000_analyzed',exptID,[exptID '_videoStatisticsMerged']))
vidstats = dataset2table(videoStatisticsMerged);

ind = find(assessTable.APT_Tracking==1);
for i = 1:length(ind) %if there is already APT tracking, change flag to 0
    if exist(fullfile(trkdir, assessTable.Properties.RowNames{ind(i)},'.trk'),'file')
        assessTable.APT_Tracking(ind(i)) = 0;
    end
end
assessTable.APT_Tracking(assessTable.APT_RetrackFlag==1) = 1; %if retrack flag is set, set tracking flag
save(fullfile('Z:\Data_pez3000_analyzed',exptID,[exptID '_rawDataAssessment']),'assessTable')

%Combine all assessment tables
fullset = innerjoin(graphTable,assessTable,'Keys','Row'); %all videos from graph table for experiment list
fullset.VideoName = fullset.Properties.RowNames;
vidstats.VideoName = vidstats.Properties.RowNames;
fullset = innerjoin(fullset,vidstats,'Keys','VideoName');
fullset.Video_Path = replace(fullset.Video_Path,'\\tier2\card','\\dm11\cardlab');
fullset.Video_Path = replace(fullset.Video_Path,'\','/');
fullset.Video_Path = replace(fullset.Video_Path,'/dm11','groups/card');

fullset(fullset.APT_Tracking==0,:)=[]; %remove all videos without APT Tracking flag

%Set ROI for full list
ROI = cell(height(fullset),1);
frmct = zeros(height(fullset),1);
for i = 1:height(fullset)
    adjusted_ROI = fullset.Adjusted_ROI{i,1};
    xlo = adjusted_ROI(2,1);
    yhi = adjusted_ROI(2,2);
    xhi = xlo+275;
    ylo = yhi-275;
    ROI{i,1} = [xlo xhi ylo yhi];
    frmct(i) = fullset.frame_count(i)/10;
end

movielist = fullset.Video_Path;

trkfilename = fullset.VideoName;
for i = 1:height(fullset)
    trkfile{i,1} = [trkdir trkfilename{i,1},'.trk'];
end

movies2track_add = table;
movies2track_add.movielist = movielist;
movies2track_add.cropRois = ROI;
movies2track_add.trk = trkfile;
movies2track_add.f0 = ones(height(fullset),1);
movies2track_add.f1 = frmct;

movies2track(contains(movies2track.movielist,exptID),:) = []; % removes all movies from experiment ID so that only ones with tracking flag are readded

movies2track = [movies2track; movies2track_add];
% [~,ia,~] = unique(movies2track.movielist);
% movies2track = movies2track(ia,:); %only include videos not already on list

save('Z:\Pez3000_Gui_folder\Gui_saved_variables\APT2Track.mat','movies2track');