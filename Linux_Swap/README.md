#Azure Linux���������swap�����Ĳ���
1.Windows Azure Ĭ�ϴ�����Linux����ϵͳϵͳ�ǲ�����swap�����ڴ�ģ�����ͨ���޸������ļ���swap�ļ�������Azure�ṩ����ʱ�̡�
vi /etc/waagent.conf
�޸�
ResourceDisk.EnableSwap=y
ResourceDisk.SwapSizeMB=500

2.������Ч������
root@ubuntu:~# swapon �Ca
root@ubuntu:~# reboot
 
3.ȷ���Ƿ���Ч
Swapon �Cs��ʾ�����ռ��ʹ�����
/mnt/resurce����λ����/dev/sdb1��ʱ��
 
