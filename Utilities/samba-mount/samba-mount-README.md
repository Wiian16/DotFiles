# How to use `samba-mount.service`

1. Install `samba` package

    ```bash
    sudo pacman -S samba
    ```

2. Create `/etc/smbcredentials`

    ```bash
    sudo touch /etc/smbcredentials
    ```

    - For security reasons, it's recommended to only allow root access to this file, hence the `sudo` command

3. Add your share username and password to `/etc/smbcredentials` using the following format:

    ```
    username=<your-username>
    password=<your-password>
    ```

4. Replace `/path/to/mount/point` and `//<your-server-ip/path/to/share` in `samba-mount`

5. Replace `/path/to/mount/point` in `samba-mount.service`

    - It's recommended to mount your share under /mnt 

6. Create an `fstab` entry

    - Add the following line to `/etc/fstab/`, adding your share location and mount point

        ```
        //<your-server-ip>/path/to/share /path/to/mount/point cifs credentials=/etc/smbcredentials,noperm,file_mode=0777,iocharset=utf8,noauto,nofail 0 0
        ```

7. Move `samba-mount` into your scripts directory

    - It's recommended to palce it under `/usr/local/bin/`

8. Replace `/path/to/samba-mount` with where you placed your script

9. Give `samba-mount executable permission

    ```bash
    sudo chmod +x /path/to/samba-mount
    ```

10. Move `samba-mount.service` into `/etc/systemd/system/`

    ```bash
    sudo mv samba-mount.service /etc/systemd/system/
    ```

11. Run `sudo systemctl daemon-reload`

12. Run `sudo systemctl enable --now samba-mount.service`

13. Ensure that your share is mounted and has the correct contents

# **WARNING** 

This script is not yet finished, and does still have issues

## Known issues

- When restarting the service without access to the network share, both bspwm and NetworkManager are stopped. 
Restarting fixes this and the issue does not occur during startup.


