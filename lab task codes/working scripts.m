%% DD
searchdir='C:\Users\Zhipeng\Desktop\DD 7.6';
takeoutstr='test'
[DD summary_table]=do_DD_analysis(searchdir,takeoutstr)
ssid='C:\Users\Zhipeng\Desktop\all logfiles\my scripts\ssid.mat'
data2copy=[2,3];
taskname='DD'
output_path='C:\Users\Zhipeng\Desktop\all logfiles\output'
varnames={'las2k_mean','last10k_mid'}
T=summary_table;
csv_generate(ssid,output_path,taskname,data2copy,varnames,T)

%% eMID
searchdir='C:\Users\Zhipeng\Desktop\eMID 7.6';
takeoutstr='test'
[eMID summary_table]=do_eMID_analysis(searchdir,takeoutstr);
ssid='C:\Users\Zhipeng\Desktop\all logfiles\my scripts\ssid.mat'
data2copy=[2:4];
taskname='eMID'
output_path='C:\Users\Zhipeng\Desktop\all logfiles\output'
varnames={'meanWinRT','meanlossRT','meanneutRT'}
T=summary_table;
csv_generate(ssid,output_path,taskname,data2copy,varnames,T)

%% SST
searchdir='C:\Users\Zhipeng\Desktop\SST 7.6';
takeoutstr='test'

[SST, summary_table]=do_SST_analysis(searchdir, takeoutstr, 100, 750, 0, 100)
ssid='C:\Users\Zhipeng\Desktop\all logfiles\my scripts\ssid.mat'
data2copy=[2:16];
taskname='SST'
output_path='C:\Users\Zhipeng\Desktop\all logfiles\output'
varnames={'trial_hit_count', 'trial_miss_count', 'stop_fail_count', 'stop_success_count',...
    'prcfail', 'prcsuccess', 'goRT_SD', 'mean_trial_hit_RT', 'mean_trial_incorrect_RT', 'mean_failed_stop_RT', ...
    'SSRT_mean', 'GB_SSRT_mean', 'SSRT_med', 'GB_SSRT_med' 'meanSSD'};
T=SST.summary_table;
csv_generate(ssid,output_path,taskname,data2copy,varnames,T)
%% CSST 
searchdir='C:\Users\Zhipeng\Desktop\all logfiles';
takeoutstr='test'
[CSST, summary_table]=do_CSST_analysis(searchdir, takeoutstr, 100, 750)

ssid='C:\Users\Zhipeng\Desktop\all logfiles\my scripts\ssid.mat'
data2copy=[2:20];
taskname='CSST'
output_path='C:\Users\Zhipeng\Desktop\all logfiles\output'
T=CSST.summary_table;

varnames={'trial_hit_count','trial_miss_count','stop_f_count','stop_s_count','nostop_hit_count','nostop_miss_count','incorrect_count','prcs','prcf','trial_hit_mRT','stop_f_mRT','nostop_hit_mRT','incorrect_mRT','goRT',' SSRT_mean','SSRT_med','RT_prc','GB_SSRT_mean','GB_SSRT_med'}

csv_generate(ssid,output_path,taskname,data2copy,varnames,T)
