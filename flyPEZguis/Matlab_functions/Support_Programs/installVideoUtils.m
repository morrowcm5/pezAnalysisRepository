function installVideoUtils

utilsDir = fullfile(fileparts(mfilename('fullpath')),'VideoUtils_v1_2_4');
path(path, utilsDir);

if ispc
%     disp('Intallation for Windows x64');
    
    path(path, [utilsDir '/Bin/Win64']);
end

if ismac
%     disp('Intallation for Mac Os X x64');
    
    path(path, [utilsDir '/Bin/Mac64']);
else 
    if isunix
%         disp('Intallation for Linux x64');
        
        path(path, [utilsDir '/Bin/Unix64']);
    end
end


% disp('Instalation completed!');