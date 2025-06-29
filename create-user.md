# For dockerfile
```
sudo useradd -M -s /bin/bash username
```
# For system
```
sudo useradd -m -d /home/<custom> -s /bin/bash -G sudo,docker user-name
```
```
sudo visudo
```
# User privilege specification
root    ALL=(ALL:ALL) ALL
<username> ALL=(ALL) NOPASSWD:ALL
```