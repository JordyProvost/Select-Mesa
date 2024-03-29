
This script permit to change - on the fly - MESA version used by your *Debian* system.

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

Usage Examples

Seleting MESA version via the menu

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

Specifying MESA version directly

```
# ./select_mesa.sh --mesa 22.3.1

Do you want to activate MESA version 22.3.1 (y/n) :
```

The script display all changes made to the system :

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

Enter the number of the MESA version you want to use (1-11) : 5

Do you want to activate MESA version 21.3.9 (y/n) : y

Creating links from /usr/local/mesa/21.3.9/share/vulkan/icd.d/ jsons in /usr/share/vulkan/icd.d/.

Installing amd64 MESA 21.3.9 in /etc/ld.so.conf.d/x86_64-linux-gnu.conf

Installing i386 MESA 21.3.9 in /etc/ld.so.conf.d/i386-linux-gnu.conf

Copying drirc configuration files from MESA 21.3.9 in /usr/share/drirc.d/

########################## Summary ##########################

File /etc/ld.so.conf.d/x86_64-linux-gnu.conf :
# Generated by select_mesa.sh
/usr/local/mesa/21.3.9/lib/x86_64-linux-gnu
/usr/local/lib/x86_64-linux-gnu
/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu

File /etc/ld.so.conf.d/i386-linux-gnu.conf :
# Generated by select_mesa.sh
/usr/local/mesa/21.3.9/lib/i386-linux-gnu
/usr/local/lib/i386-linux-gnu
/lib/i386-linux-gnu
/usr/lib/i386-linux-gnu
/usr/local/lib/i686-linux-gnu
/lib/i686-linux-gnu
/usr/lib/i686-linux-gnu

Folder /usr/share/vulkan/icd.d/ (.json only) :
intel_icd.i686.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/intel_icd.i686.json
intel_icd.x86_64.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/intel_icd.x86_64.json
lvp_icd.i686.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/lvp_icd.i686.json
lvp_icd.x86_64.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/lvp_icd.x86_64.json
radeon_icd.i686.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/radeon_icd.i686.json
radeon_icd.x86_64.json -> /usr/local/mesa/21.3.9/share/vulkan/icd.d/radeon_icd.x86_64.json

Drirc configuration files in /usr/share/drirc.d/ :
lrwxrwxrwx 1 root root 58  4 mars  12:14 00-mesa-defaults.conf -> /usr/local/mesa/21.3.9/share/drirc.d/00-mesa-defaults.conf
lrwxrwxrwx 1 root root 58  4 mars  12:14 00-radv-defaults.conf -> /usr/local/mesa/21.3.9/share/drirc.d/00-radv-defaults.conf

MESA Version
OpenGL core profile version string: 4.6 (Core Profile) Mesa 21.3.9 (git-78c96ae5b6)
OpenGL core profile shading language version string: 4.60
OpenGL version string: 4.6 (Compatibility Profile) Mesa 21.3.9 (git-78c96ae5b6)
OpenGL shading language version string: 4.60
OpenGL ES profile version string: OpenGL ES 3.2 Mesa 21.3.9 (git-78c96ae5b6)
OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.20
```



