## SnelInstaller - lightweight text-based installer

SnelInstaller (SI) is text-based program meant to easify the creation of installation-packages. For example you can easily create a .deb package (once you've created a definition), or the preparation of a windows-setup. However it is not like Inno-setup, but once you have created an Inno-setup, you can update the Inno-setup-definitions automatically using SnelInstaller.

With SI you can create dirs, copy files, edit files and executes commands automatically, that is, based on a install-definition-file. You are not limited to any specific programming-langage or environment. Besides installation-packages it can be helpfull in creating any computer-confugration for example to customize a standard-computer to the needs of an organisation. It can even be helping in the creation of a Linux-distribution.

Features:
- simplicity; easy-to-understand definition-files do the trick, and the manual is compact.
- variables can be defined for file-handling, especially usable for paths, to avoid repetitive input of long paths.
- flexibility; because of recurrency, one def-file can call one or more other ones, and so on..
- multi-platform; for now windows and linux versions are forseen, but other target-platforms are possible.


SnelInstaller is written in the State-of-the-art programming-language Nim; a modern, compiled, garbage-collected language with Python-like syntax.

For now it only has been tested on linux, but is expected to run on Windows. Packages / release still have to be uploaded, so currently it only is usable for Nim-developers, instead of regular users. Also a windows-version is foreseen. Releases for both OSs are forth-coming.



[Go to Sample-definition-file] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/install-definition-si.txt)

[Go to preliminary user-manual] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/manual-snel-installer.txt)

[Go to sample terminal-output after running] (https://github.com/some-avail/snelinstaller/blob/main/mostfiles/terminal-output.txt)






