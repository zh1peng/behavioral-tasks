function [DD summary_table]=do_DD_analysis(searchdir,takeoutstr)
% updated 2017/08/10 minor bug fixed (last 10 median value)
% new script for DD 2016/09/08
% updated 2016/05/04 
% cautions:1. check filename, make sure there is no '.' in the file name
%               2. remove invalid files
DD1=logfiles2matlab('DD', 'DelayDiscounting',takeoutstr,searchdir);
DD2=logfiles2matlab('DD', 'DD_',takeoutstr,searchdir);
subid1=DD1.subids;
subid2=DD2.subids;
for i1=1:length(subid1)
    DD.(subid1{i1})=DD1.(subid1{i1});
end
for i2=1:length(subid2)
    DD.(subid2{i2})=DD2.(subid2{i2});
end
subids=[subid1,subid2];
DD.subids=subids;

subid=DD.subids;
numtrials=149;
for s=1:length(subid)
    clearvars -except DD subid s numtrials searchdir
    a = ['DD.' subid{s} '.data'];
    t = struct2cell(eval(sprintf(a))); t=squeeze(t);t=t';
    trial_num=t(:,5);
    stat=cell(numtrials,11);
    for trial=1:numtrials
        try    %in case it is not finished
            %find the trial starts and get the trial info
            i=find(strcmp(trial_num,num2str(trial))==1);
            stat(trial,1:9)= t(i,6:14);
            
            %check next event if it is a response
            i_n=i+1;
            if strcmp(t(i_n,3),'Response')==1
                stat{trial,10}=num2str(cell2mat(t(i_n,17))/10);
                stat(trial,11)=t(i_n,4);
            elseif isempty(cell2mat(t(i_n,6)))&strcmp(t(i_n+1,3),'Response')
                stat{trial,10}= num2str(cell2mat(t(i_n+1,17))/10);
                stat(trial,11)=t(i_n+1,4);
            end
        end
    end
    summary_table=cell2table(stat,'VariableNames',{'SSR','LLR','Delay','k','OLL','ILL','IUL','OUL','PCLLR','RT','ReType'});
    eval(sprintf(['DD.' subid{s}, '.summary_table =summary_table;']));
    eval(sprintf(['DD.' subid{s},'.k=stat(:,4);']));
    clearvars -except DD subid s numtrials searchdir
end


% averge last 2 k values providing DD structure is existing. Load data_structure if needed.
subid=DD.subids';
sub_k=cellfun(@(x) strcat('DD.',x,'.k'),subid,'Unif',0)
for n=1:length(sub_k)
    a=eval(sub_k{n});
    k=a(~cellfun('isempty',a)); %exclude empty k value
    k=cellfun(@str2num,k,'Unif',0);
    k=cell2mat(k);
    average=mean(k(end-1:end));
    last10k_mid=median(k(end-9:end));

    
    
    k_results{1,n}=subid{n};
    k_results{2,n}=average;
    k_results{3,n}=last10k_mid;
    tmp_average(n,1)=average;
    tmp_mid(n,1)=last10k_mid;
    clear average last last_1 a k last10k_mid
end
summary_table=table;
summary_table(:,1)=cell2table(subid);
summary_table(:,2)=array2table(tmp_average);
summary_table(:,3)=array2table(tmp_mid);
summary_table.Properties.VariableNames={'case_id','DD_last2k_mean','DD_last10k_mid'};
writetable(summary_table, [searchdir filesep 'DD_K_results.csv']);
eval(sprintf(['DD.summary_table =summary_table;']));
cd(searchdir)
save('DD.mat','DD')
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
                break
            end
        end
    end
    if stop>1
        subid{n}=names{n}(1:stop);
    else
        start=[];
        for m=1:length(paths{n});
            if strcmp(paths{n}(m), '\')==1 | strcmp(paths{n}(m), '/')==1
                start=[start,m];
            end;
        end;
        subid{n}=paths{n}(max(start)+1:length(paths{n}));
    end
    
    if isnan(str2double(names{n}(1)))==0
        subid{n}=['X' subid{n}];
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
end;
subid=subid(~cellfun('isempty',subid));
s=[task '.subids'];
eval([sprintf(s) '=subid;']);

datastruct= eval([task]);
cd(datadir)
save(task, task)
end









