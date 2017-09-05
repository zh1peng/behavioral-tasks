function [eMID summary_table]=do_eMID_analysis(searchdir,takeoutstr);
% updated 06/09/2016
eMID=logfiles2matlab('eMID', 'eMID',takeoutstr,searchdir);
subid=eMID.subids;
for s=1:length(subid)
    
    a = ['eMID.' subid{s} '.data'];
    t = struct2cell(eval(sprintf(a))); t=squeeze(t);t=t';
    
    code=t(:,6);
    indx_win=find(strcmp(code, 'win')==1)+1;
    indx_loss=find(strcmp(code, 'loss')==1)+1;
    indx_neut=find(strcmp(code, 'neutral')==1)+1;
   
    %check all the resonse time ------------------------------
    allresp=t(:,3); resp_time = t(:,17);
    indx_allresp=find(strcmp(allresp,'Response')==1);
    rrt=cell2mat(resp_time(indx_allresp));
    
    if    isempty(find(rrt==12126))==0;
        disp('find resptime=12126');
        pause
    elseif isempty(find(rrt==12127))==0;
        disp('find resptime=12127');
        pause
    end
    
    %remove no-response trails
    winRT=cell2mat(resp_time(indx_win));
    lossRT=cell2mat(resp_time(indx_loss));
    neutRT=cell2mat(resp_time(indx_neut));
    
    winRT(find(winRT==12126|winRT==12127))=[]; winRT=winRT/10; meanwinRT(s)=mean(winRT);
    lossRT(find(lossRT==12126|lossRT==12127))=[]; lossRT=lossRT/10; meanlossRT(s)=mean(lossRT);
    neutRT(find(neutRT==12126|neutRT==12127))=[]; neutRT=neutRT/10; meanneutRT(s)=mean(neutRT);
    
    a = ['eMID.' subid{s} '.winRT=winRT;'];eval(sprintf(a));
    a = ['eMID.' subid{s} '.lossRT=lossRT;']; eval(sprintf(a));
    a = ['eMID.' subid{s} '.neutRT=neutRT;'];eval(sprintf(a));
    a = ['eMID.' subid{s} '.meanwinRT=meanwinRT(s);'];eval(sprintf(a));
    a = ['eMID.' subid{s} '.meanlossRT=meanlossRT(s);'];eval(sprintf(a));
    a = ['eMID.' subid{s} '.meanneutRT=meanneutRT(s);'];eval(sprintf(a));    
end
clear summary_table
summary_table=table;
summary_table(:,1)=array2table(subid');
summary_table(:,2)=array2table(meanwinRT');
summary_table(:,3)=array2table(meanlossRT');
summary_table(:,4)=array2table(meanneutRT');

summary_table.Properties.VariableNames={'case_id', 'eMID_meanwinRT', 'eMID_meanlossRT', 'eMID_meanneutRT'};
writetable(summary_table, [searchdir filesep 'eMID_summary.csv']);
eval(sprintf('eMID.summary_table=summary_table'))
cd(searchdir)
save('eMID','eMID')
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









