## SnelInstaller - lightweight powerfull text-based installer

![01](mostfiles/pictures/terminal-output.png)


[Go to Sample-definition-file] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/test_projects/basic_sample/basic-sample-01_install-def-si_2.4.txt)

[Go to sample terminal-output after running] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/terminal-output.txt)

[Go to the user-manual] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/manual-snel-installer.txt)

[Go to what-is-new.txt] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/what-is-new.txt)

[Go to downloadable releases for windows and linux](https://github.com/some-avail/snelinstaller/releases "Downloads for SnelInstaller")


SnelInstaller (SI) is text-based program meant to easify the creation of installation-packages, or the adjustment of configurations in your operating-system. For example you can easily create a .deb package (once you've created a definition), or the preparation of a windows-setup. However it is not like Inno-setup, but once you have created an Inno-setup, you can update the Inno-setup-definitions automatically using SnelInstaller.

With SI you can create dirs, copy files, edit files and execute commands automatically, that is, based on a install-definition-file. Also you can call other installations / def-files. You are not limited to any specific programming-langage or environment. Besides installation-packages it can be helpfull in creating any computer-configuration for example to customize a standard-computer to the needs of an organisation. It can even be helping in the creation of a Linux-distribution.

Features:
- simplicity; easy-to-understand definition-files do the trick, and the manual is compact.
- variables can be defined for file-handling, especially usable for paths, to avoid repetitive input of long paths.
- flexibility; because of recurrency, one def-file can call one or more other ones, and you can execute shell-commands of your operating-system.
- cross-platform; for now for windows and linux; (modern) macintosh expected to work, but is not released because i have no macintosh-pc.


SnelInstaller is written in the advanced programming-language Nim; a modern, compiled, garbage-collected language with Python-like syntax.

Success with using SnelInstaller.




