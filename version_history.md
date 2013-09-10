#Version history#

##0.1.0 (09/10/13)
* Added generated package for templates ([lice-tpl.lua](http://github.com/Yonaba/lice-lua/blob/master/src/lice-tpl.lua)) for easier [rockspec](http://www.luarocks.org/en/Rockspec_format) packaging.
* Added language comment style formatting option `-l` (aliased `--lang`)
* Added filename output option `-f` (aliased `--file`).
* Added language comment styles support, see [languages](http://github.com/licenses/lice-lua/blob/master/lice-languages.md).
* Added file extensions recognition on `-f` option value. Overrides `-l`.
* `-o` (aliased `--organization`) defaults to `git config user.name` first. If not found,
try to infer the username from the environment variable.
* Updated `-h` (aliased `--help`) output with the new options.
* Prettified `-h`, `--list`, `--vars` output.
* `-o`, `-p` (aliased `--project`) now supports whitespaces.
* Updated [README](http://github.com/licenses/lice-lua/blob/master/README.md).

##0.0.2 (08/20/13)
* Support for whitespaces in years range
* Added [licenses-templates](https://github.com/licenses/license-templates) as a submodule

##0.0.1 (08/17/13)
* Initial Release
