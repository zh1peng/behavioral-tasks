function datastruct = logfiles2matlab(task, subid_length, datadir)
%
%Example usage:
%PST=logfiles2matlab('PST2', 8, 'C:\Users\EJ\GoogleDrive\UCD\endophenotypes project\data\pilot data\EMMA\pilot3');
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
[paths, names] = filesearch_substring([datadir],task, 0); %change file location

%% getting EEG datafiles
% bdf_select=false(size(names));
% for n=1:size(paths,2)
%     if isempty(strfind(names{n},'.bdf'))==0
%         bdf_select(n)= 1;
%     end  
% end
% paths(bdf_select)='';
% names(bdf_select)=''; 

%% getting data from logfiles
l=length(task)-1; %为什么使用的是-1？

for n=1:size(paths,2)
    cd(paths{n});%change to corresponding dir for each subs.
    stop=0;
    while stop==0;
        for m=subid_length:length(names{n});
            if strcmp(names{n}(m:m+l), task)==1;%l=length(task)-1
                stop=m-2;
                break;
            end;
        end;
    end
    subid{n}=names{n}(1:stop);
    
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

s=[task '.subids'];
eval([sprintf(s) '=subid;']);

datastruct= eval([task]);
cd(datadir)
save(task, task)
end

