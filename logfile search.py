
import glob
import shutil
import os


def copy_logfiles(search_task, dest_dir):
    # example: copy_logfiles(r'Z:\Behavioral DATA_Back up\**\*CSST*.log', r'C:\Users\Zhipeng\Desktop\CSST')
    for filen in glob.iglob(search_task, recursive=True):
        shutil.copy(filen, dest_dir)


copy_logfiles(r'Z:\Behavioral DATA_Back up\**\*Delay*.log', r'C:\Users\Zhipeng\Desktop\DD')
