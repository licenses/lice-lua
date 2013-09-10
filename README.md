Lice-Lua
========

*lice-lua* is a command-line license generator. It is a port of the original [lice](http://github.com/licenses/lice) to Lua.

## Installation

### LuaRocks

    luarocks install lice-lua

### MoonRocks

	moonrocks install lice-lua

or 

    luarocks install --server=http://rocks.moonscript.org/manifests/Yonaba lice-lua

### Manual download

* Latest [v0.1.1](http://github.com/licenses/lice-lua/tree/lice-lua-0.1.1-1) (stable, recommended): [zip](http://github.com/licenses/lice-lua/archive/lice-lua-0.1.1-1.zip) | [tar](http://github.com/licenses/lice-lua/archive/lice-lua-0.1.1-1.tar.gz)
* Cutting-edge development release (*might be unstable, not recommended*): [zip](http://github.com/licenses/lice-lua/archive/master.zip) | [tar](http://github.com/licenses/lice-lua/archive/master.tar)
* All releases: [tags](http://github.com/Yonaba/lice-lua/releases)

### From git:

````
git clone git@github.com/licenses/lice-lua
````

**Note**: This repository uses [licenses-templates](http://github.com/licenses/license-templates) as a submodule. <br/>In order to fetch those file aswell when cloning from Git, use `--recursive` option.

```bash
git clone git@github.com/licenses/lice-lua --recursive
````

## Overview

*Lice-Lua* is used with command-line. Call the file [lice.lua](http://github.com/Yonaba/lice-lua/blob/master/src/lice.lua) from Lua, passing it desired opts.

Generates a BSD-3 license, the default:

    lua lice.lua

Generates an MIT license:

    lua lice.lua mit

### Specifying authors/organization

Generate a BSD-3 license, specifying the year and organization/author to be used (whitespaces are allowed):

    lua lice.lua -y 2012 -o Sunlight Foundation
    lua lice.lua -y 2013 -o This is My Name

It also handles multiple authors. Names have to be separated by commas. Whitespaces are allowed in the sequence.
    
    lua lice.lua -o Moe, Foe, Doe

When opt `-o` is not supplied, it is inferred from `Git`, if found in the `PATH` (via `git config user.name`). If not found, the environment variable `USERNAME` (on Windows) or `USER` (on Unix and OSX) using Lua's native [os.getenv](http://pgl.yoyo.org/luai/i/os.getenv). If all fails, the empty string `''` will be used.

### Specifying year

It also allows a range of years as input. The separator should be any (single or sequence of) non-digit characters, except dash(es) (whitespaces are allowed):

    lua lice.lua -y 2012 2013
    lua lice.lua -y 2012.2013
    lua lice.lua -y 2012+2013
    lua lice.lua -y 2012,2013
    lua lice.lua -y 2012&2013
    lua lice.lua -y 2012...2017

When opt `-y` is not supplied, year is inferred from Lua's native [os.date](http://pgl.yoyo.org/luai/i/os.date).<br/>

### Specifying project
The project name is supplied through opt `-p` (whitespaces are allowed).

    lua lice.lua -p Project
    lua lice.lua -p This Is My Project
    
If the project name is not specified, the name of the current directory (from where *Lice-Lua* is called) is used.

### File output
The output can be redirected to an external file. Just supply opt `-f`.

    lua lice.lua -f LICENSE

In case an extension is provided with the filename, it will be used to infer a language comment style formatting. The following will create a `main.c` file with the `bsd3` license at the header formatted as a comment block.

    lua lice.lua -f main.c

*Notes*:<br>

* In case *no extension is provided*, or the given extension is *not supported*, the **plain text style** will be used.
* Also, if the output file *already exists*, the new license text is **prepended** at the top of the file. 

### Language and comment-styles
Shell output can be formatted to a specific language comment style using opt `-l`.

    lua lice.lua mit -l lua
    lua lice.lua apache -l py

* See all [supported languages](http://github.com/licenses/lice-lua/blob/master/lice-languages.md).

*Note*: *One should bear in mind that `-l` is mostly used for **shell output** and is therefore overriden by `-f`. So when `-l` is provided, `-f` should be missing, or an error is likely to be reported*. 

### Listing template variables

You can see what variables are available to you for a specific license:

    lua lice.lua mit --vars
    
### Listing templates

You can display a list of available license templates with the following:    

    lua lice.lua --list

### Headers
For a specific license, in case you want to use the header, supply opt `--header`:   
    
    lua lice.lua agpl3 -o Foo --header
    
To check for available args in a template header, same logic applies:

    lua lice.lua agpl3 --vars --header
    
## Detailled usage

The following can be printed from Lice-Lua using:

    lua lice.lua -h

What outputs the following:

    usage: lua lice.lua license [-h] [-o ORGANIZATION] [-p PROJECT]
                                 [-t TEMPLATE_PATH] [-y YEAR]
                                 [--vars] [--header]

    positional arguments:
      license                   the license to generate. Defaults to 
                                bsd3 when not given.
                                
    optional arguments:
      -h, --help                show this help message and exit.
      -o, --org ORGANIZATION    organization. Defaults to 
                                "git config user.name", then environment 
                                variable "USERNAME" (Windows) or "USER" 
                                (on Unix and OSX).
      -p, --proj PROJECT        name of project, defaults to name of current 
                                directory.
      -l, --lang LANGUAGE       format output with language comment style,
                                if available. Mostly meant for shell output.
      -y, --year YEAR           copyright year, defaults to current date read 
                                from system locale.
      -f, --file OFILEPATH      path to the output source file. Extension, if 
                                provided, is used to infer a language specific 
                                formatting style for the license header,
                                if supported.
      
    optional arguments taking no values (no args)
      --vars                    list template variables for the specified 
                                license and exit.
      --header                  will only use the header license (if available).
      --list                    list all available licenses templates and exit

## Submitting a new license

Is the license you want to submit commonly used?<br/>
If so, feel free to open an [issue](http://github.com/licenses/lice-lua/issues) or, if you are feeling generous, [fork](http://github.com/licenses/lice-lua/fork), commit on your own and submit a [pull request](http://github.com/licenses/lice-lua/pulls).


## Dependencies
__Lice-lua__ requires a single dependency, [LFS](http://github.com/downloads/keplerproject/luafilesystem) (Lua File System).

## Credits
As I said before, this my own attempt at porting [lice](http://github.com/licenses/lice) to Lua.<br/>
All credits goes then to [Jeremy Carbaugh](http://github.com/jcarbaugh) for the original idea.

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