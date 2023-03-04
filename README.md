
This script permit to change - on the fly - MESA version used by your system.
You have to compile MESA yourself, usually, your compiled MESA versions are in /usr/local/mesa (but you can change the mesa_dir variable if you are using another directory).

```
# ./select_mesa.sh -h
Usage: select_mesa.sh [OPTION]...
This tool is intended to switch from compiled MESA versions from /usr/local/mesa on a i386/amd64 Debian system.
Versions of MESA are not build versions, but the name of sudirectories you put under /usr/local/mesa.

Options which require arguments take their arguments immediately following the option, separated by white space.

Arguments:
	-f, --force                 dont ask for confirmation
	-h, --help                  print Help (this message) and exit
	-m, --mesa                  indicate Mesa version to use (must be the name of a directory under /usr/local/mesa)
	-u, --update                force the change even if you have selected the same version as the current one
	-v, --version               print version information and exit
  ```
