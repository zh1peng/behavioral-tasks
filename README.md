## How to use..

1. open logfile search.py

   run `copy_logfiles(r'Z:\Behavioral DATA_Back up\**\*search_str*.log', r'C:\Users\Zhipeng\Desktop\DD')`

   change `search_str` to task abbreviation. 

   There a few search bugs could be fixed by rex search, but fix mannually is much easier .

   :warning:Search DD task using DD and Delay seperately.

   :warning: CSST will be coppied to SST, need to remove manually.

   :warning: In DD folder, remove some tasks start with DD manually. 

2. Remove files less than 10K (which I think is not completed)

3. run matlab codes 

```matlab
addpath('F:\Google Drive\zhipeng git folders\deal-with-logfiles')
[eMID summary_table]=do_eMID_analysis('C:\Users\Zhipeng\Desktop\eMID','test');
[DD summary_table]=do_DD_analysis('C:\Users\Zhipeng\Desktop\DD','test')
[SST, summary_table]=do_SST_analysis('C:\Users\Zhipeng\Desktop\SST', 'test', 100, 750, 0, 100)
[CSST, summary_table]=do_CSST_analysis('C:\Users\Zhipeng\Desktop\CSST', 'test', 100, 750)
```



