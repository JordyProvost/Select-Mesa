
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

Usage Example :

```
# ./select_mesa.sh

Available MESA Versions :

1	21.1.0
2	21.2.3
3	21.3.5
4	21.3.8
5	21.3.9
6	22.1.2
7	22.1.5
8	22.2.0
9	22.3.1
10	22.3.5 <-- Current Version
11	master

Enter the number of the MESA version you want to use (1-11) :
```

```
# ./select_mesa.sh --mesa 22.3.1

Do you want to activate MESA version 22.3.1 (y/n) :
```
