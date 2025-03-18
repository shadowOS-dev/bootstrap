# bootstrap-shadow
Build scripts for building a shadowOS userspace.

## Building
*Note: To build we use `xbstrap`, so make sure you have that installed.*
To build the entire sys root just do:
```sh
# Initialize xbstrap
xbstrap init .

# Build (and install) all packages
xbstrap install --all
```
*Note: This builds stuff into system-root*
