function [SST, summary_table]=do_SST_analysis(searchdir, takeoutstr, toofast, tooslow, minpctfail, maxpctfail)
%% NOTE: ONLY USED IN updating results
% example usage: [SST, all_ssrt]=do_SST_analysis('C:\Users\EJ\Google Drive\UCD\UG logfiles', 'SST_algorithm', 'test', 100, 750, 0, 100);
% cd(filedir);
% %%
% %SST with feedback analysis

SS1=logfiles2matlab('SST', 'SST', takeoutstr, searchdir);

% try SS2=logfiles2matlab('SST', 'SST_algorithm', takeoutstr, searchdir);
% %%
% subid1=SS1.subids;
% subid2=SS2.subids;
% for i1=1:length(subid1)
%     SST.(subid1{i1})=SS1.(subid1{i1});
% end
% for i2=1:length(subid2)
%     SST.(subid2{i2})=SS2.(subid2{i2});
% end
% subids=[subid1,subid2];
% SST.subids=subids;
% catch
    
    SST=SS1;
% end
SSTversion='algorithm_and_new_thresh';
subid=SST.subids; %save new variable with all the subject IDs

for s=1:length(subid) %do the analysis individually for each participant
    
    a = ['SST.' subid{s} '.data'];
    t = struct2cell(eval(sprintf(a))); t=squeeze(t);t=t';
    trial_nums=t(:,5);
    T=[t(:,5),t(:,7),t(:,8),t(:,11),t(:,12),t(:,13),t(:,14),t(:,15),t(:,16),t(:,17),t(:,18), t(:,22)];
    
    for n=1:length(trial_nums)
        if isempty(trial_nums{n})==1
            empty(n)=1;
        else
            empty(n)=0;
        end
    end
    empty=find(empty==1);
    
    T(empty,:)=[];
    T=array2table(T);
    T.Properties.VariableNames={'trial_number', 'direction', 'outcome', 'RT', 'if_stop', 'SSD', 'if_STE', 'OLL', 'ILL', 'IUL', 'OUL', 'count_stop_success'};
    str = ['SST.' subid{s} '.tbytdata']; eval([sprintf(str) '=T;']);
    ssd=T{:,6}; ssd=ssd(~cellfun('isempty', ssd));
    
    RT=str2double(table2array(T(:,4)));
    SSD=str2double(table2array(T(:,6)));
    f1=find(isnan(SSD)~=1);%find stop trials
    f2=find(isnan(RT)~=1);%trials with a response
    f=intersect(f1, f2);%failed stop trials ***AND*** STE trials
    for n=1:length(f)
        if strcmp(table2array(T(f(n),3)), 'STE')==0
            RT(f(n))=RT(f(n))+SSD(f(n));%RTs calc'ed to onset of last stimulus; here the stop signal; so RT is time from onset of go stimulus to response
        end
    end
    RTs2keep=[];
    for n=1:length(RT)
        if isnan(RT(n))==0
            if RT(n)>toofast & RT(n)<tooslow %remove outliers here
                RTs2keep=[RTs2keep, n];
            end
        else
            RTs2keep=[RTs2keep, n];
        end
    end
    T=T(RTs2keep,:);
    RT=RT(RTs2keep);
    
    outcome_str=table2array(T(:,3));
    outcome_int=zeros(size(outcome_str));
    outcome_int(find(strcmp(outcome_str, 'trial hit')==1))=1;
    outcome_int(find(strcmp(outcome_str, 'trial miss')==1))=5;
    outcome_int(find(strcmp(outcome_str, 'trial incorrect')==1))=2;
    outcome_int(find(strcmp(outcome_str, 'failed stop')==1))=3;
    outcome_int(find(strcmp(outcome_str, 'successful stop')==1))=4;
    outcome_int(find(strcmp(outcome_str, 'STE')==1))=6;
    
    %find out if STEs were trial hit or trial miss
    findSTE1=find(strcmp(table2array(T(:,3)), 'STE')==1);
    findSTE2=find(outcome_int==6);
    for n=1:length(findSTE1)
        if isequal(t(findSTE1(n),7), t((findSTE1(n)-1),4))==1 %trial hit
            outcome_int(findSTE2(n))=1;
        else %trial miss
            outcome_int(findSTE2(n))=2;
        end
    end
    
    SST.trial_hit_count(s)=length(find(outcome_int==1));%find all the 'trial hit' in outcome_int to see how many there are
    SST.trial_miss_count(s)=length(find(outcome_int==2));
    SST.stop_fail_count(s)=length(find(outcome_int==3));
    SST.stop_success_count(s)=length(find(outcome_int==4));
%     SST.prcsuccess(s)=100-SST.prcfail(s);%this calculates the % success stop
    SST.prcfail(s)=(SST.stop_fail_count(s)/(SST.stop_success_count(s)+SST.stop_fail_count(s))*100);%this calculates the % fail
    SST.prcsuccess(s)=100-SST.prcfail(s);%this calculates the % success stop
    SST.RTs{s}=RT(find(outcome_int<4));%fill out the matrix from 1 to number of trials
    SST.goRTs{s}=RT(find(outcome_int<3));
    tmp=[];
    for toN=1:length(SST.goRTs{s})
        if isnan(SST.goRTs{s}(toN))==0
            tmp=[tmp, SST.goRTs{s}(toN)];
        end
    end
    SST.goRT_SD(s)=std(tmp);
    SST.mean_trial_hit_RT(s)=mean(RT(find(outcome_int==1)));%find all the reaction times corresponding to 'trial hit' and average them
    SST.mean_trial_incorrect_RT(s)=mean(RT(find(outcome_int==2)));
    SST.mean_failed_stop_RT(s)=mean(RT(find(outcome_int==3)));
    SST.RT_prc(s)=prctile(SST.goRTs{s},SST.prcfail(s));%get the percentile of failed stops
    SST.SSRT_mean(s)=nanmean(SST.goRTs{s})-nanmean(SSD);%calc the regular SSRT
    SST.GB_SSRT_mean(s)=SST.RT_prc(s)-nanmean(SSD);%calc the GB SSRT:Band, Guido PH, Maurits W. Van Der Molen, and Gordon D. Logan. "Horse-race model simulations of the stop-signal procedure." Acta psychologica 112.2 (2003): 105-142.
    SST.SSRT_med(s)=nanmean(SST.goRTs{s})-nanmedian(SSD);%calc the regular SSRT
    SST.GB_SSRT_med(s)=SST.RT_prc(s)-nanmedian(SSD);%calc the GB SSRT:Band, Guido PH, Maurits W. Van Der Molen, and Gordon D. Logan. "Horse-race model simulations of the stop-signal procedure." Acta psychologica 112.2 (2003): 105-142.

    SST.meanSSD(s)=nanmean(SSD);
end
f1=find(SST.prcfail<minpctfail);
f2=find(SST.prcfail>maxpctfail);
all_ssrt=SST.GB_SSRT_mean;
all_ssrt(f1)=NaN;
all_ssrt(f2)=NaN;
hist(all_ssrt)
nanmean(all_ssrt)
SST.codeversion=SSTversion;

clear T
T=table
T(:,1)=cell2table(SST.subids');
T(:,2)=array2table(SST.trial_hit_count');
T(:,3)=array2table(SST.trial_miss_count');
T(:,4)=array2table(SST.stop_fail_count');
T(:,5)=array2table(SST.stop_success_count');
T(:,6)=array2table(SST.prcfail');
T(:,7)=array2table(SST.prcsuccess');
T(:,8)=array2table(SST.goRT_SD');
T(:,9)=array2table(SST.mean_trial_hit_RT');
T(:,10)=array2table(SST.mean_trial_incorrect_RT');
T(:,11)=array2table(SST.mean_failed_stop_RT');
T(:,12)=array2table(SST.SSRT_mean');
T(:,13)=array2table(SST.GB_SSRT_mean');
T(:,14)=array2table(SST.SSRT_med');
T(:,15)=array2table(SST.GB_SSRT_med');
T(:,16)=array2table(SST.meanSSD');
T.Properties.VariableNames={'case_id', 'SST_trial_hit_count', 'SST_trial_miss_count', 'SST_stop_fail_count', 'SST_stop_success_count',...
    'SST_prcfail', 'SST_prcsuccess', 'SST_goRT_SD', 'SST_mean_trial_hit_RT', 'SST_mean_trial_incorrect_RT', 'SST_mean_failed_stop_RT', ...
    'SST_SSRT_mean', 'SST_GB_SSRT_mean', 'SST_SSRT_med', 'SST_GB_SSRT_med' 'SST_meanSSD'};
summary_table=T;

writetable(T, [searchdir filesep,'allversion_SST_stats.csv']);

eval(sprintf(['SST.summary_table=T']));

save([searchdir filesep 'allversion'], 'SST')
end

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


