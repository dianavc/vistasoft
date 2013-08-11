function [talairach, spatialNorm] = loadTalairachXform(subject, tFile, skipTfileFlag)% [talairach, spatialNorm] = loadTalairachXform(subject, [fileName], [skipTfileFlag=0])%%% To generate the spatialNorm file, try this:%   ni = niftiRead('3DAnatomy/t1.nii.gz');%   [sn,template,inv] = mrAnatComputeSpmSpatialNorm(double(ni.data), ni.qto_xyz, 'MNI_T1');%   invLUT = rmfield(inv,{'deformX','deformY','deformZ'});%   save('3DAnatomy/t1_sn.mat','sn','invLUT');%%% SEE ALSO:%   mrLoadRet-3+ code tree: findTalairachVolume%   Anatomy code tree: computeTalairach, volToTalairach, talairachToVol%% HISTORY:%   2002.07.17 RFD (bob@white.stanford.edu) Added comments and support for%   the new naming convention.%   2010.08.16 AMR Added option (skipTfileFlag) to skip the Talairach file%   and just use the spatialNorm file so that user isn't prompted when%   scripting%   2010.09.13 AMR If not interested in Talairach space but just MNI%   (spatialNorm), you can now skip Talairach and then create the%   spatialNorm file automatically by computing transform to MNI brain%   (rather than going through computeTalairach, which requires more user%   involvementif notDefined('skipTfileFlag'), skipTfileFlag = 0; endtalairach = [];if(~exist('tFile','var') || isempty(tFile))    global vANATOMYPATH;    if(~isempty(vANATOMYPATH))        [p,f] = fileparts(vANATOMYPATH);        tFile = fullfile(p, [f '_talairach.mat']);    else        tFile = fullfile(getAnatomyPath(subject),'vAnatomy_talairach.mat');    end    if(~exist(tFile,'file'))        % try the old-style name        tFile = fullfile(fileparts(tFile), 'talairach.mat');    endendif ~skipTfileFlag    if(~exist(tFile,'file'))        ansButton = questdlg(['talairach.mat file not found in',getAnatomyPath(subject),...            ' What would you like to do?'], ...            'Talairach file not found', 'Skip (and use spatialNorm)', 'Find It', 'Create It', 'Find It');        %     if(strcmp(ansButton,'Abort'))        %         return;        if(strcmp(ansButton,'Skip (and use spatialNorm)'))        elseif(strcmp(ansButton,'Create It'))            uiwait(computeTalairach(fullfile(getAnatomyPath(subject),'vAnatomy.dat')));        else            [f,p] = uigetfile('*.mat', ['Find talairach.mat file for ',subject,'...']);            tFile = fullfile(p,f);        end    end    if(exist(tFile,'file'))        talairach = load(tFile);        if isempty(talairach)            myErrorDlg('No talairach transform. Aborting...');        end    endend% Also try to load the spatial normalization file, if it existssnFile = fullfile(fileparts(tFile),'vAnatomy_sn.mat');if(~exist(snFile,'file'))    snFile = fullfile(fileparts(tFile),'t1_sn.mat');endif(~exist(snFile,'file'))    ansButton = questdlg(['t1_sn.mat file not found in',getAnatomyPath(subject),...        ' What would you like to do?'], ...        'spatialNorm file not found', 'Skip', 'Find It', 'Create It', 'Find It');    %     if(strcmp(ansButton,'Abort'))    %         return;    if(strcmp(ansButton,'Skip'))    elseif(strcmp(ansButton,'Create It'))        ansButton2 = questdlg('What template to use?', 'MNI Template','avg152T1.nii', 'avg305T1.nii', 'single_subj_T1.nii','avg152T1.nii');        %uiwait(computeTalairach(fullfile(getAnatomyPath(subject),'vAnatomy.dat')));        anatPath = getAnatomyPath;        anatFile = fullfile(anatPath,'t1.nii.gz');        if ~exist(anatFile,'file')            error('Check to make sure you have an anatomy file named t1.nii.gz within anatomy path')        else            ni = niftiRead(fullfile(anatPath,'t1.nii.gz'));  % this assumes you are starting from your mrSESSION directory            templatePath = which(ansButton2);            [sn,template,inv] = mrAnatComputeSpmSpatialNorm(double(ni.data), ni.qto_xyz, templatePath);            invLUT = rmfield(inv,{'deformX','deformY','deformZ'});            save(fullfile(anatPath,'t1_sn.mat'),'sn','invLUT');        end    else        [f,p] = uigetfile('*.mat', ['Find talairach.mat file for ',subject,'...']);        snFile = fullfile(p,f);    endendif(exist(snFile,'file'))    spatialNorm = load(snFile);else    spatialNorm = [];endif(~exist(tFile,'file') && ~exist(snFile,'file'))    error('Talairach or spatialNorm file is necessary')endreturn;
