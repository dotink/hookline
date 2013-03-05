# Hookline

A simple wrapper for lsyncd.  Hookline is useful for developers who usually modify code in a working copy for some version control system but push to a centalized server for testing either individually or amongst other developers.

This is written primarily for my own usage.  It's not very robust and works using very simple principles.  In my particular case, I work on servers where the dev environments shouldn't and don't contain meta-folders or information for the version control system.  If I use SFTP mounted drives, then I have to pull changes down I save on the server to commit to version control.  If I modify them locally then I have to push them to the server to test and coordinate with other developers.  The `lsyncd` daemon solves the problem I have which is basically that I want to sync changes on save, however, this creates a nice interface with persistent information while avoiding the more complex configuration.  It's a perfect solution, hookline and syncer (get it?).

## Requirements

- lsyncd
- rsync
- sudo (for install) or `cp ./hookline/hookline.sh /usr/bin/hookline` as root
- standard GNU utilities

## Installation

```
git clone https://github.com/dotink/hookline.git
./hookline/hookline.sh install
```

## Usage

### Adding a syncer:

```
hookline add <alias> <source> <test>
```

```
hookline add dev.example.com /home/user/code/example.com user@example.com:/var/www/example.com/dev
```

### Deleting a syncer:

```
hookline del <alias>
```

```
hookline del dev.example.com
```

### Starting a syncer:

```
hookline start <alias>
```

```
hookline start dev.example.com
```

### Stopping a syncer:

```
hookline stop <alias>
```

```
hookline stop dev.example.com
```

### Viewing the status:

```
hookline stat
```
