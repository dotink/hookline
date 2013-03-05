# Hookline

A simple wrapper for managing lsyncd instances.  Hookline is useful for developers who usually modify code in a working copy for some version control system but push to a centalized server for testing, scheduled builds, or continuous integration.

It is important to note that unlike traditional SFTP, this will sync regularly and consistently to your development environment.  This is an ideal solution for those who may normally mount and work directly on SFTP, but cannot or would not want the remote copy to also be their working copy.


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

### Viewing the status:

```
hookline stat
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

### Following the log:

```
hookline tail
```
