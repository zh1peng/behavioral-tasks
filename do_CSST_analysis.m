function [CSST, summary_table]=do_CSST_analysis(searchdir, takeoutstr, toofast, tooslow)
%% NOTE: THIS VERSION ONLY USED FOR UPDATING RESULTS
% toofast=100 
% tooslow=750 
% searchdir='F:\Google Drive\whelan_lab_data\Behavioural_Tasks_Scripts\tmp_zhipeng\CSST\sample log files'
% searchstr='CSST';
% takeoutstr='test';

%% logfiles to matlab
CSST=logfiles2matlab('CSST', 'CSST', takeoutstr, searchdir);
subid=CSST.subids;
%% s=1
for s=1:length(subid) 
a = ['CSST.' subid{s} '.data'];
t = struct2cell(eval(sprintf(a))); t=squeeze(t);t=t'; %convert to cell
t=t(~cellfun('isempty',t(:,29)),:); %exclude empty cells using ReqDur

%% add missing SSD values associated with nostop trials
outcome_str=t(:,8);
ReqDur=cell2mat(t(:,29));
nostop_hit_i=find(strcmp(outcome_str, 'nostop hit')==1);
nostop_miss_i=find(strcmp(outcome_str,'missed nostop')==1);
trial_hit_i=find(strcmp(outcome_str, 'trial hit')==1);
trial_miss_i=find(strcmp(outcome_str, 'trial miss')==1);
stop_f_i=find(strcmp(outcome_str, 'failed stop')==1);
stop_s_i=find(strcmp(outcome_str, 'successful stop')==1);
STE_i=find(strcmp(outcome_str, 'STE')==1);
trial_incorrect_i=find(strcmp(outcome_str, 'trial incorrect')==1);

% calculate SSD
for k=1:length(nostop_hit_i)
    indx=nostop_hit_i(k);
    if ReqDur(indx-1)~=10000
        t{indx,13}=num2str(1000-(ReqDur(indx-1))/10);
    end
end
clear indx k
for k=1:length(nostop_miss_i)
    indx=nostop_miss_i(k);
    if ReqDur(indx-1)~=10000
        t{indx,13}=num2str(1000-(ReqDur(indx-1))/10);
    end
end
T=[t(:,8),t(:,11),t(:,13)]; %type,RT,ssd
T=T(~cellfun('isempty',T(:,1)),:); %exclude empty
outcome_str=T(:,1);
nostop_hit_i=find(strcmp(outcome_str, 'nostop hit')==1);
nostop_miss_i=find(strcmp(outcome_str,'missed nostop')==1);
trial_hit_i=find(strcmp(outcome_str, 'trial hit')==1);
trial_miss_i=find(strcmp(outcome_str, 'trial miss')==1);
stop_f_i=find(strcmp(outcome_str, 'failed stop')==1);
stop_s_i=find(strcmp(outcome_str, 'successful stop')==1);
trial_incorrect_i=find(strcmp(outcome_str, 'trial incorrect')==1);
STE_i=find(strcmp(outcome_str, 'STE')==1);

%% calculate all RTs (stop hit=ssd+RT) and exclude outliers
% failed stop/nostop hit RT=ssd+RT

%find STE is hit or miss and change the type accordingly
STE_hit=[];STE_miss=[];
for kk=1:length(STE_i)
    indx=STE_i(kk);
    if isempty(T(indx,2))|(cell2mat(T(indx,2))==0)
        STE_miss=[STE_miss,indx];
        T{indx,1}='trial miss'
    else
        STE_hit=[STE_hit,indx];
        T{indx,1}='trial hit';
    end
end


%recalculate the RTs including STE_hit
RT_recal=[nostop_hit_i;stop_f_i;STE_hit'];
for k=1:length(RT_recal)
    indx=RT_recal(k);
    T{indx,2}=num2str(str2num(T{indx,2})+str2num(T{indx,3}));
end

% exclude outlier 
% toofast=100 
% tooslow=750
RT=T(:,2);
RTs2keep=[];
    for n=1:length(RT)
        test=RT{n};
        if ischar(test)
            test=str2num(test);
        end 
        if isempty(test)==1|test==0
            RTs2keep=[RTs2keep, n]; 
        elseif test>toofast & test<tooslow
             RTs2keep=[RTs2keep, n];
        end
    end
T=T(RTs2keep,:); %update T

%update indxs
outcome_str=T(:,1); 
nostop_hit_i=find(strcmp(outcome_str, 'nostop hit')==1);
nostop_miss_i=find(strcmp(outcome_str,'missed nostop')==1);
trial_hit_i=find(strcmp(outcome_str, 'trial hit')==1);
trial_miss_i=find(strcmp(outcome_str, 'trial miss')==1);
stop_f_i=find(strcmp(outcome_str, 'failed stop')==1);
stop_s_i=find(strcmp(outcome_str, 'successful stop')==1);
trial_incorrect_i=find(strcmp(outcome_str, 'trial incorrect')==1);

    
    
%% stat 
%count
trial_hit_count(s,1)=length(trial_hit_i);
trial_miss_count(s,1)=length(trial_miss_i);
stop_f_count(s,1)=length(stop_f_i);
stop_s_count(s,1)=length(stop_s_i);
nostop_hit_count(s,1)=length(nostop_hit_i);
nostop_miss_count(s,1)=length(nostop_miss_i);
incorrect_count(s,1)=length(trial_incorrect_i);
%prc
prcs(s,1)=stop_s_count(s,1)/(stop_s_count(s,1)+stop_f_count(s,1))*100;
prcf(s,1)=stop_f_count(s,1)/(stop_s_count(s,1)+stop_f_count(s,1))*100;
%RT
trial_hit_mRT(s,1)=mean(cellfun(@str2num,T(trial_hit_i,2)));
stop_f_mRT(s,1)=mean(cellfun(@str2num,T(stop_f_i,2)));
nostop_hit_mRT(s,1)=mean(cellfun(@str2num,T(nostop_hit_i,2)));
incorrect_mRT(s,1)=mean(cellfun(@str2num,T(trial_incorrect_i,2)));
goRT(s,1)=mean(cellfun(@str2num,T([trial_hit_i;trial_incorrect_i],2))); %goRT=hit+incorrect according to SST code
%SSRT nostop_SSD not included here
stop_SSD=cellfun(@str2num,T([stop_s_i;stop_f_i],3));

SSRT_mean(s,1)=goRT(s,1)-nanmean(stop_SSD);
SSRT_med(s,1)=goRT(s,1)-nanmedian(stop_SSD);
% GB_SSRT  nostop_SSD not included here
RT_prc(s,1)=prctile(goRT(s,1),prcf(s,1));
GB_SSRT_mean(s,1)=RT_prc(s,1)-nanmean(stop_SSD);
GB_SSRT_med(s,1)=RT_prc(s,1)-nanmedian(stop_SSD);

end

%% 
% minpctfail=0
% maxpctfail=100
% all_ssrt=GB_SSRT_med
% f1=find(prcfail<minpctfail);
% f2=find(prcfail>maxpctfail);
% all_ssrt(f1)=NaN;
% all_ssrt(f2)=NaN;
% hist(all_ssrt)
% nanmean(all_ssrt)

T1=table;
T1(:,1)=cell2table(subid');
T1(:,2:20)=array2table([trial_hit_count,trial_miss_count,stop_f_count,stop_s_count,nostop_hit_count,nostop_miss_count,incorrect_count,prcs,prcf,trial_hit_mRT,stop_f_mRT,nostop_hit_mRT,incorrect_mRT,goRT, SSRT_mean,SSRT_med,RT_prc,GB_SSRT_mean,GB_SSRT_med]);
T1.Properties.VariableNames={'case_id','CSST_trial_hit_count','CSST_trial_miss_count','CSST_stop_f_count','CSST_stop_s_count','CSST_nostop_hit_count','CSST_nostop_miss_count','CSST_incorrect_count','CSST_prcs','CSST_prcf','CSST_trial_hit_mRT','CSST_stop_f_mRT','CSST_nostop_hit_mRT','CSST_incorrect_mRT','CSST_goRT',' CSST_SSRT_mean','CSST_SSRT_med','CSST_RT_prc','CSST_GB_SSRT_mean','CSST_GB_SSRT_med'}
summary_table=T1;
writetable(T1, [searchdir filesep 'CSST_stats.csv']);
eval(sprintf(['CSST.summary_table=T']));
save([searchdir filesep 'CSST'], 'CSST')
end





%% --------------------------------------------------functions--------------------------------------------------------------------------------------------------
function datastruct = logfiles2matlab(task, searchstr, takeoutstr, datadir)
%
%Example usage:
%PST=logfiles2matlab('PST2', 'C:\Users\Laura\Google Drive\EMMAS LOGFILES');
%
%task = the name of the task as appears in the title of all logfiles
%
%subid_length = the length of the subject id for all participants. If the
%naming convention is used this will normally be 8 (i.e.EJ061114). Make
%sure that subids do not vary in length or the function will be unhappy!
%
%datastruct = returns a structure with data and subject ids for all
%logfiles that were found in the directory

clear paths names
[paths, names] = filesearch_substring([datadir],searchstr, 0); %change file location
[pathschk, nameschk] = filesearch_substring([datadir],takeoutstr, 0); %change file location
for n=1:length(names)
    for m=1:length(nameschk)
        if strcmp(names{n}, nameschk{m})==1
            names{n}=[];
            paths{n}=[];
        end
    end
end
names=names(~cellfun('isempty',names));
paths=paths(~cellfun('isempty',paths));

% getting nly logfiles
log_select=false(size(names));
for n=1:size(paths,2)
    if isempty(strfind(names{n},'.log'))==1
        log_select(n)= 1;
    end
end
paths(log_select)='';
names(log_select)='';

%% getting data from logfiles
l=length(searchstr)-1;

for n=1:size(paths,2)
    cd(paths{n});
    stop=0;
    while stop==0;
        for m=1:length(names{n});
            if strcmp(names{n}(m:m+l), searchstr)==1;
                stop=m-2;
                break;
            end;
        end;
    end
    if stop>1 & strcmp('tst', names{n}(1:stop))==0 %this file is not missing a subject ID
        if isnan(str2double(names{n}(1)))==1
            subid{n}=names{n}(1:stop);
        else
            subid{n}=['X' names{n}(1:stop)];
        end
        
        clear out1 out2
        [out1, out2] = importPresentationLog(names{n}); %handy function to import log files, is in matlab files on drive folder
        
        clear a b
        a=[task '.' subid{n} '.data'];
        b=[task '.' subid{n} '.variables'];
        eval([sprintf(a) '=out1;']);
        eval([sprintf(b) '=out2;']);
        out1=struct2cell(out1);
        out1=squeeze(out1);
        out2=struct2cell(out2);
        out2=squeeze(out2);
    else
        stop
    end
end;
subid=subid(~cellfun('isempty',subid));
s=[task '.subids'];
eval([sprintf(s) '=subid;']);

datastruct= eval([task]);
cd(datadir)
save(task, task)
end

function [out2, out1] = importPresentationLog(fileName, extraNames)
% Import any Presentation log file into MATLAB and enjoy your analysis ;)
% This function imports all columns of any presentation log file into
% MATLAB and names the variables to the column names used in the log file.
% The following columns are automaticaly converted to doubles:
% Trial, Time, TTime, Uncertainty, Duration, ReqTime, ReqDur
% The others however are strings.
%
% To convert additional columns as doubles, add a list of column
% names (as displayed in the log file) as second argument in a cell.
%
% The data are represented as a vector of structs or a struct with vectors
% for every colum.
%
% Usage: [out1, out2] = presLog(fileName, columnsToBeConverted2Doubles);
% * INPUT
%       * filename  -> full qualified file name as string
%
% * OUTPUT
%       * out1      -> data represented as 1xn struct
%       * out2      -> struct that contains vectors for every column
%
% Example: [out1, out2] = presLog('resultFile.log');
%
% Example: [out1, out2] = presLog('resultFile.log', {'extraCol1', 'extraCol2'});
% Converts not only the standard columns to doubles but also the columns
% that are passed as extra argument

% Tobias Otto, tobias.otto@ruhr-uni-bochum.de
% 1.2
% 11.07.2012

% 21.09.2010, Tobias: first draft
% 02.02.2011, Tobias: added check for wrong header entries
% 11.07.2012, Tobias: added extraCol conversion, checking for duplicates in
%                     column names, speed optimization,
%                     bugfix from Ben Cowley (thank you!)

%% Init variables
tmp         = [];
names       = {};
out1        = [];
out2        = [];
j           = 0;
dubCount    = 0;
convNames   = {'trial', 'Time', 'TTime', 'Uncertainty', 'Duration', ...
    'ReqTime', 'ReqDur'};   % Defines entries that are numeric and not a string
convNames   = lower(convNames);

%% Check input arguments
if(nargin == 2)
    if(~iscell(extraNames))
        disp(' *************************************************************');
        disp(' Please use cells to indicate the columns that have to be ');
        disp(' converted to doubles');
        disp(' E.g. ');
        disp(' [a, b] = presLog(''file.log'', {''column1'', ''coumn2''});');
        disp(' *************************************************************');
        error('Please solve error and try again');
    else
        for i=1:length(extraNames)
            extraNames{i}  = convertString(extraNames{i});
        end
        % Copy to cell that contains the "conversion names"
        convNames   = [convNames extraNames];
    end
end

%% Load file
fid = fopen(fileName,'r');
if(fid == -1)
    disp(' *************************************************************');
    disp(['The file ' fileName ' can''t be loaded']);
    disp(' *************************************************************');
    error('Please check the input file name and try again');
end

%% Read file
header{1} = fgetl(fid);
header{2} = fgetl(fid);
header{3} = fgetl(fid);

%% Get variable names
[numEntries, indexEntries, logLine] = sepHeader(fid);

for i = 1:numEntries
    tmp             = logLine(indexEntries(i):indexEntries(i+1));
    tmp             = convertString(tmp);
    
    % Check for duplicates
    for k=1:length(names)
        if(strcmpi(tmp, names{k}))
            rename      = tmp;
            dubCount    = dubCount + 1;
            tmp         = [tmp '_' num2str(dubCount)];
            disp([' --> Renamed "' rename '" to "' tmp '"']);
        end
    end
    
    % Finally copy entry to names
    names{i} = tmp;   % remove tab
end

% Remove white line
fgetl(fid);

%% Get entries by line
try
    while(ischar(logLine) && ~isempty(logLine))
        j = j+1;
        
        %% Separate values from line
        [numEntries, indexEntries, logLine] = sepEntries(fid);
        
        %% Copy entries to struct (for each line in file)
        for i=1:numEntries
            tmp = logLine(indexEntries(i):indexEntries(i+1));
            tmp = tmp(tmp~=9);  % Remove tab
            
            %% Check, entries in current line
            % Some lines have more entries than defined in header file
            % Warn user and ignore entry !!!
            if(length(names) < i)
                i = length(names);
                disp(' **********************************************************************');
                disp(' !!! The log file has more entries than defined in the header !!!');
                disp([' Skipping additional entries. Please check your log file in line ' num2str(j+5)]);
                disp(' **********************************************************************');
            end
            
            %% Check, if entry has to be converted to a double value
            % Compare entry with variable convNames: if entry exists save
            % as double. Otherwise as string
            k=1;
            while(k<=length(convNames) && ~strcmpi(convNames{k},names{i}))
                k=k+1;
            end
            
            %% Copy entries to struct
            if(k<=length(convNames))
                out1.(names{i})(j,:)    = str2double(tmp);
                out2(j).(names{i})      = out1.(names{i})(j,:);
            else
                % Copy to output struct
                out1.(names{i}){j,:}    = tmp;
                out2(j).(names{i})      = tmp;
            end
        end
    end
    
catch
    disp(' *************************************************************');
    disp([' Sorry I''m giving up on line ' num2str(j+5)]);
    disp(' This is a permanent error ... I give up :(');
    disp(' If you are able to find the error feel free to contact me');
    disp(' and I will add the changes.');
    disp(' *************************************************************');
end

%% Clean up
fclose(fid);

end
%% SUB FUNCTIONS
function [numEntries, indexEntries, logLine] = sepHeader(fid)
% Get header line
logLine         = fgetl(fid);
% Find valid separators
separators      = [find(double(logLine)==9) length(logLine)];
separators      = separators(diff(separators)~=1);
% Compute last variables
numEntries      = length(separators)+1;
indexEntries    = [1 separators length(logLine)];
end

function [numEntries, indexEntries, logLine] = sepEntries(fid)
% Get header line
logLine         = fgetl(fid);
% Find valid separators
separators      = find(double(logLine)==9);
% Compute last variables
numEntries      = length(separators)+1;
indexEntries    = [1 separators length(logLine)];
end

function out = convertString(in)
% Removes white line, (, ) and removed tab
in(in==32)	= '_';         	% Replace ' ', '(' , ')' with '_'
in(in==40)	= '_';        	% Replace ( with _
in(in==41) 	= '';       	% Replace ) with nothing
in         	= in(in~=9);  	% Remove tab
out     	= lower(in);    % Lower all character
end