#Azure Linux虚拟机设置swap分区的步骤
1.Windows Azure 默认创建的Linux操作系统系统是不存在swap虚拟内存的，可以通过修改配置文件将swap文件保存在Azure提供的临时盘。    
vi /etc/waagent.conf  
修改  
ResourceDisk.EnableSwap=y   
ResourceDisk.SwapSizeMB=500  

2.设置生效并重启    
root@ubuntu:~# swapon –a    
root@ubuntu:~# reboot    
 
3.确认是否生效    
Swapon –s显示交换空间的使用情况    
/mnt/resurce所在位置是/dev/sdb1临时盘    
 
