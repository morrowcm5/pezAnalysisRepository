function pez3000_dailyFun_v2

[~,result] = system('tasklist /FI "imagename eq matlab.exe" /fo table /nh');
p = gcp('nocreate');
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers;
end

if numel(strfind(result,'MATLAB')) > (poolsize+1)
    exit
end

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
assessment_dir = fullfile(repositoryDir,'file_assessment_and_manipulation');
addpath(repositoryDir,subfun_dir,saved_var_dir,assessment_dir)
addpath(repositoryDir,subfun_dir,saved_var_dir,assessment_dir)
addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))
addpath(fullfile(repositoryDir,'graphing_and_visualization'))

disp('Raw data prep')
pez3000_rawDataPrep

%minimum_collectionID = '0095';
%  minimum_collectionID = '0108';
minimum_collectionID = '0200';

disp('Takeoff analysis')
takeoffAnalysis3000_v2(1,[],minimum_collectionID)

disp('Tracking')
pezProcessor3000_v8auto(1,1,1,minimum_collectionID)

disp('Finishing tasks')
pez3000_posthoc_corrections
makeExcelTable_v2

exit