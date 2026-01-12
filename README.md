# 🛡️Sentinel.sh by ne0mesys

***This script has been created by ne0mesys and serves as a blue team software that allows users to scan their device and understand whether they have been tried to be hacked or not. I hope you guys enjoy it ;)***

## Welcome
This software allows users to check *.log* files hided in their current device to see the type of connections and connection requests that have been established and determine whether they have been tried to be hacked or not. This sofware is NOT an anti-malware software, it is just a simple software that has been coded with the proper instructions to avoid wasting time checking these hided files manually. 

In case this software detects an attack, it will report immediately the IP Address associated to the attack for further risk and security preventions.

The paths that this software gains access to are the following: 
* /var/log/samba **-> Samba Service**
* /var/log/apache2 **-> Apache Service**
* /var/log/nginx **-> Nginx Service**
* /var/log/auth.log **-> SSH Service**
* var/log/vsftpd.log **-> FTP Service**

This tool is developed strictly for educational and ethical purposes. I DO NOT take any responsibility for the misuse of this tool.

By ne0mesys

## Requirements

### For Linux

***journalctl*** is required in order to have a 100% accuracy at the time to scan the user's device. In case you don't have it installed, you can find the instruction below for Linux users:

```
sudo apt update
sudo apt install journalctl
```

### For Arch Linux

***journalctl*** is required in order to have a 100% accuracy at the time to scan the user's device. In case you don't have it installed, you can find the instruction below for Linux users:

```
sudo pacman -S journalctl
```

## Installation

### For Linux

Here's a short documentation about how to install the script for Linux users:

```
sudo apt install git
sudo git clone https:/github.com/ne0mesys/Sentinel
cd Sentinel
```

### For Arch Linux

Here's a short documentation about how to install the script for Arch Linux users:

```
sudo pacman -S git
sudo git clone https://github.com/ne0mesys/Sentinel
cd Sentinel
```

## Execution

### For Arch Linux & Linux

Once we are in the same folder of the software, we can proceed to enable its execution. We can do this with the following command:

```
sudo chmod +x sentinel.sh
```

The software includes the Shebang line, #!/bin/bash which allows the user to execute it directly. We can do this using the command ```./sentinel.sh``` 

However, it would be necessary to have the script always in the same directory we are in. Therefore, I highly suggest to move a copy with execution permits to the $PATH so we use it as a command: ```sentinel```

In order to do this perform the next commands in the terminal:

```
sudo chmod +x sentinel.sh
sudo mv sentinel.sh /usr/local/bin/sentinel
```

**Now you are able to use the script as a command in the terminal!**

**Try it with the command** ```sentinel```

## About

This software has been created in order to check the *.log* files hided in Unix system. It is a simple software that does not support (yet) a Microsoft Windows version. This software scans the *.log* files from the next services: **Samba**, **Nginx**, **FTP**, **SSH** & **Apache**. 

This script rather than just checking *.log* files, it is focused on the security and risk awareness that our devices are exposed to. Therefore it serves as a Blue Team tool, which speeds up the process of checking manually every hided *.log* file in the device. 

## Author

* Ne0mesys

Feel free to open an Issue...

```
E-Mail me at: ne0mesys.acc@gmail.com
```

