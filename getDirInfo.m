function dirInfo = getDirInfo(params)
% dirInfo = getDirInfo(params)
%
% Populates directory information (with or without subject-specific params
% struct). ASSUMES RUN FROM CODE DIR which is in turn 1 deep within base
% directory.
%
% jbh 9/2/14

[baseDir thisDir] = fileparts(pwd);
dirInfo.runFrom = fullfile(baseDir,thisDir);
dirInfo.baseDir = baseDir;
dirInfo.codeDir = fullfile(baseDir,'code');
dirInfo.dataDir = fullfile(baseDir,'data');

if exist('params','var')
    dirInfo.subDataDir = fullfile(dirInfo.dataDir,params.subjectID);
end

