Lice-Lua
========

__Lice-Lua__ is a port of [Lice](http://github.com/licenses/lice) to Lua.
It generates license files.

## Installation

### Manual download

* Latest (v0.0.2, stable, recommended): [Zip](https://github.com/licenses/lice-lua/archive/lice-lua-0.0.2-1.zip) | [Tar.gz](https://github.com/licenses/lice-lua/archive/lice-lua-0.0.2-1.tar.gz)
* Download repository as-is (might be unstable, not recommended): [Zip](https://github.com/licenses/lice-lua/archive/master.zip) | [Tar.gz](https://github.com/licenses/lice-lua/archive/master.tar)
* Previous releases: [Tags](https://github.com/Yonaba/lice-lua/releases)

### From git:

```bash
git clone git@github.com/licenses/lice-lua
````

**Note**: This repository uses [licenses-templates](https://github.com/licenses/license-templates) as a submodule. <br/>In order to fetch those file aswell when cloning from Git, use `--recursive` option.

```bash
git clone git@github.com/licenses/lice-lua --recursive
````

## Overview

Lice-Lua is used with command-line. Call the file [lice.lua](https://github.com/Yonaba/lice-lua/blob/master/src/lice.lua) from Lua, passing it desired opts.

Generates a BSD-3 license, the default:

    lua lice.lua

Generates an MIT license:

    lua lice.lua mit

Generate a BSD-3 license, specifying the year and organization/author to be used (whitespaces are allowed):

    lua lice.lua -y 2012 -o Sunlight Foundation
    lua lice.lua -y 2013 -o This is My Name

It also allows a range of years as input. The separator should be any (single or sequence of) non-digit characters, except dash(es) (whitespaces are allowed):

    lua lice.lua -y 2012 2013
    lua lice.lua -y 2012.2013
    lua lice.lua -y 2012+2013
    lua lice.lua -y 2012,2013
    lua lice.lua -y 2012&2013
    lua lice.lua -y 2012...2017

When `opt -y` is not supplied, it makes use of Lua's native [os.date](http://pgl.yoyo.org/luai/i/os.date) to return the current year.<br/>
It also handles multiple authors. Names have to be separated by commas. Whitespaces are allowed in the sequence.
    
    lua lice.lua -o Moe, Foe, Doe

When `opt -o` is not supplied, it defaults to the environment variable `USERNAME` on Windows systems or `USER` on Unix'es and OSX using Lua's native [os.getenv](http://pgl.yoyo.org/luai/i/os.getenv).

The project name is supplied through `opt -p`. Whitespaces are allowed.

    lua lice.lua -p Project
    lua lice.lua -p This Is My Project
    
If the project name is not specified, the name of the current directory (from where Lice-Lua is called) is used.

You can see what variables are available to you for a specific license:

    lua lice.lua mit --vars
    
You can display a list of available license templates with the following:    

    lua lice.lua --list

For a specific license, in case you want to use the header, supply opt `--header`:   
    
    lua lice.lua agpl3 -o Foo --header
    
To check for available args in a template header, same logic applies:

    lua lice.lua agpl3 --vars --header
    
## Detailled usage

The following can be printed from Lice-Lua using:

    lua lice.lua -h

What outputs the following:

    usage: licelua license [-h] [-o ORGANIZATION] [-p PROJECT]
                           [-t TEMPLATE_PATH] [-y YEAR]
                           [--vars] [--header]

        positional arguments:
          license                   the license to generate. Defaults to bsd3 
                                    when not given.
                                    
        optional arguments:
          -h, --help                show this help message and exit
          -o, --org ORGANIZATION    organization, defaults environment variable
                                    "USERNAME" (on Windows) or "USER" (on Unix'es)
          -p, --proj PROJECT        name of project, defaults to name of current 
                                    directory
          -y, --year YEAR           copyright year
          
        optional arguments taking no values (no args)
          --vars                    when supplied, list template variables for 
                                    specified license and exit
          --header                  when supplied, will only use the header license
                                    if available
          --list                    when supplied, list the available licenses 
                                    templates and exit]]

## Submitting a new license

Is the license you want to submit commonly used?<br/>
If so, feel free to open an issue or, if you are feeling generous, fork, commit on your own and submit a pull request.


## Dependencies
__Lice-lua__ requires a single dependency, [LFS](https://github.com/downloads/keplerproject/luafilesystem) (Lua File System), for filesystem facilities.

## Credits
As I said before, this my own attempt at porting [Lice](http://github.com/licenses/lice) to Lua.<br/>
All credits goes then to [Jeremy Carbaugh](https://github.com/jcarbaugh) for the original idea.

## LICENSE
This work is under [MIT-LICENSE](http://www.opensource.org/licenses/mit-license.php)<br/>
Copyright (c) 2013 Roland Yonaba

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.