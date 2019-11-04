# Homework 1
# Compile kernel

## Создание vagrant box

Детали создания vagrant образа детально расписаны в файле manual/manual.md

## Компиляция ядра из исходников

Команды для компиляции ядра указаны в скрипте packer/scripts/stage-1-kernel-compile-and-update.sh

Устанавливаются необходимые зависимости

yum install -y wget gcc flex bison ncurses-devel openssl-devel bc elfutils-libelf-devel perl

Используются исходники из архива https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz

Необходимо обратить внимание на указание кол-во потоков при компиляции (желательно равным количеству ядер минус одно)

make --jobs=6

## Проблема с синхронизированием каталогов между хостом и гостевой машиной

После сборки, при старте виртуальной машины возникает проблема:

<pre>
==> default: Mounting shared folders...
    default: /vagrant => /root/linux-otus/manual_kernel_update/test
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant

The error output from the command was:

mount: unknown filesystem type 'vboxsf'
</pre>

## Исправление проблемы с синхронизацией каталогов

Для исправления проблемы в provision packer-а добавлен дополнительный скрипт: stage-1a-virtualbox.sh

Выполняются следующие операции:

*  Скачивается расширение VBoxGuestAdditions
*  Монтируется и запускается скрипт установки: /mnt/VBoxLinuxAdditions.run

## Выявленные проблемы

### Ошибка при запуске сборки packer-ом образа vagrant-а в консоли

<pre><code>
==> centos-7.7: Error starting VM: VBoxManage error: VBoxManage: error: The virtual machine ‘packer-centos-shared-vm’ has terminated unexpectedly during startup because of signal 6
==> centos-7.7: VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MachineWrap, interface IMachine
</code></pre>

Ошибка возникает из-за попытки запустить GUI-а, а его не предполагается.
Для исправления необходимо указать packer-у, что сборка будет идти в консольном режиме:

<pre><code>
{
 "variables": {
   "artifact_description": "CentOS 7.7 with kernel 5.x",
   "artifact_version": "7.7.1613.02",
   "image_name": "centos-7.7",
   "headless": "true",
   "ssh_timeout": "10800s"
 },
 "builders": [
   {
     "name": "{{user image_name}}",
     "type": "virtualbox-iso",
     "vm_name": "packer-centos-vm",
     "headless": "{{user headless}}",
</code></pre>

### При вызове перезагрузки VM в скрипте provisioner сборка образа не происходит

Наблюдалось в 5-ой версии vagrant-а. В 6-ой не воспроизводится.

### Ошибка при установке VBoxGuestAdditions

При запуске в 5-ой версии Vagrant-а версии ядра 5.3.8  возникает ошибка:

<pre><code>
error: void value not ignored as it ought to be
  287 |         int rc = smp_call_function(rtmpLinuxAllWrapper, &Args, 0 /* wait */);
</code></pre>

Не возникает при использовании 6-ой версии Vagrant-а.

