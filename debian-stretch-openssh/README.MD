# Debian 9.x OpenSSH Server (SSH[+Logging] + SFTP)

- [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH)
- [SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)

# Environment Variables

This environment variable is available for your use:

- `DEBBASE_SSH`

- `ROOT_SSH`

- `SSH_USERS`

- `SSH_HISTORY`


# Usage

- Define users in (1) command arguments, (2) `SSH_USERS` environment variable
  or (3) in file mounted as `/etc/openssh/users.conf` (syntax:
  `user:pass[:e][:uid[:gid[:dir1[,dir2]...]]] ...`, see below for examples)
  - Set UID/GID manually for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
  - Directory names at the end will be created under user's home directory with
    write permission, if they aren't already present.
- Mount volumes
  - The users are chrooted to their home directory, so you can mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**) or just mount the whole **/home** directory.
    Just remember that the users can't create new files directly under their
    own home directory, so make sure there are at least one subdirectory if you
    want them to upload files.
  - For consistent server fingerprint, mount your own host keys (i.e. `/etc/ssh/ssh_host_*`)

# Examples
