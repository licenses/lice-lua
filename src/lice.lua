-- =========================================
-- Lice-Lua, A license generator for Lua
-- Copyright (c) 2013 Roland Y., MIT License
-- version 0.1.1 - Uses Lua 5.1, 5.2
-- =========================================

-- =========================================
-- Internals declaration
-- =========================================

-- Catch the passed in root path (handling calls out from the root folder)
local ROOT_PATH = (arg[0]:match('(.+)[/\\]%w+%.*%w*') or '')
local templates_list = require (ROOT_PATH .. '.lice-tpl')

-- Check for dependencies
local lfs
do
  assert(pcall(require, 'lfs'),
    'Dependency LuaFileSystem not found.\nCannot execute Lice-Lua')
  lfs = require 'lfs'
end

-- Local binding to global native variables
local package = package
local os_getenv = os.getenv
local io_open = io.open
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local table_sort = table.sort
local table_concat = table.concat
local assert = assert
local error = error
local print = print

-- Pattern-matching templates
local TPL_VARS_PATTERN     = '{{%s([^{}]+)%s}}'
local GET_OPT_PATTERN      = '(%-%-?)(%a+)%s*([^%-]*)'
local GET_OPT_LIC_PATTERN  = '^([a-zA-Z0-9%_]+)'
local GET_OPT_DASHES       = '^%-%-?$'
local OUT_FILE_NAME        = '^([^.]+)%.*'
local OUT_FILE_EXT         = '%.([^.]+)$'
local LIC_YEAR_RANGE       = '^[%d]+[%D+]*[%d+]*$'

-- Default License template
local DEFAULT_LIC_TEMPLATE     = 'bsd3'

-- Binds file exts to LANGS dict
local LANGS_EXT = {}

-- Languages, comment style and file extensions
local LANGS_CMT_STYLE = {} 

-- =========================================
-- Os's facilities
-- =========================================

-- Get directory separator
local function get_dir_sep()
  return (package.config:sub(1,1))
end

-- Is the actual Windows
local function is_windows()
  return (get_dir_sep():match('\\')~=nil)
end

-- Parses major & minor from _VERSION
local function get_lua_version()
  local major, minor = _VERSION:match('^Lua%s(%d)%.(%d)%.*%d*$')
  return tonumber(major), tonumber(minor)
end

-- Executes command (Lua 5.1 & 5.2 compatible)
local function execute(cmd)
  local code = os.execute(cmd)
  local _, lua_v_minor = get_lua_version()
  if (lua_v_minor == 1) then
    return (code==0)
  elseif (lua_v_minor == 2) then
    return code
  end
end

-- To be visible from `silent_execute`
local get_file_contents

-- Executes a command
-- Output is redirected to temporary file
-- Taken from S. Donovan's Penlight
-- See https://github.com/stevedonovan/Penlight/blob/master/lua/pl/utils.lua#L229)
function silent_execute(cmd)
  local outfile = os.tmpname()
  local errfile = os.tmpname()
  if is_windows() then
    outfile = os_getenv('TEMP')..outfile
    errfile = os_getenv('TEMP')..errfile
  end
  cmd = cmd .. ' >"'..outfile..'" 2>"'..errfile..'"'
  local success = execute(cmd)
  local contents = success and get_file_contents(outfile)
  os.remove(outfile)
  os.remove(errfile)
  return contents
end

-- Get username from Git, if found in the path.
local function get_username_from_git()
  return silent_execute('git config user.name')
end

-- Infers the username
local function get_username()
  -- Tries to infer from Git
  local username = get_username_from_git()
  if not username then
    username = is_windows() and 
      os_getenv('USERNAME') or 
      os_getenv('USER') or ('')
  end
  return username
end

-- Returns the current folder name.
-- Uses Os's directory separator
local function get_current_folder_name()
  return lfs.currentdir():match(('([^%s]+)$')
          :format(get_dir_sep()))
end

-- =========================================
-- Internal functions
-- =========================================

-- Collects and returns an array of keys from a given table
local function collect_keys(list, sorted)
  local l = {}
  for v in pairs(list) do l[#l+1] = v end
  if sorted then
    table_sort(l)
  end
  return l
end

-- Lookup value in table
local function table_find(t, v)
  for k,_v in pairs(t) do
    if (_v == v) then
      return true
    end
  end
  return false
end

-- File extensions to comment style binding helper
local function add_exts(lang, style, ...)
  local exts = {...}
  LANGS_CMT_STYLE[lang] = style   -- Set the style
  for _,ext in ipairs(exts) do
    LANGS_EXT[ext] = lang         -- set extensions
  end
end

-- Returns the contents of a file
function get_file_contents(file_path, flag)
  local fhandle = assert(io_open(file_path, 'r'),
    ('Error on attempt to open <%s>'):format(file_path))
  local contents = fhandle:read(flag or '*a')
  fhandle:close()
  return contents
end

-- Writes contents to file
local function write_to_file(f, contents, append)
  if append then
    local previous_contents = get_file_contents(f)
    contents = contents .. '\n\n' .. previous_contents
  end
  local fhandle = assert(io_open(f, 'w+'),
    ('Cannot open file <%s>'):format(f))
  fhandle:write(contents)
  fhandle:close()
end

-- Returns a list of available templates vars
local function get_template_vars(template_name)
  local contents = templates_list[template_name]
  local vars = {}
  for var in contents:gmatch(TPL_VARS_PATTERN) do
    vars[#vars+1] = var
  end
  return vars
end

-- Applies language specific comment-style to template contents
local function apply_comment_style(input, lang)
  local cmt_style = LANGS_CMT_STYLE[lang]
  input = input:gsub('([^\n\r]*[\n\r])', function(match)
    return cmt_style[2] .. match
  end)
  return (cmt_style[1] .. '\n' .. input .. cmt_style[3])
end

-- Interpolates template variables with the provided set of options
local function write_license(opts)
  local source = templates_list[opts.fname]
  local license_text = (source:gsub(TPL_VARS_PATTERN,opts))
  
  -- File extension has precedence for language and comment-style inference
  if opts.file_ext then
    assert((opts.lang == opts.file_ext) or (not opts.lang), 
      ('Inconsistency error: <-l %s> and <-f *.%s>'):format((opts.lang or ''), opts.file_ext))
    -- Apply formatting if extension is featured, otherwise leave it in plain text style.
    if LANGS_EXT[opts.file_ext] then
      license_text = apply_comment_style(license_text, LANGS_EXT[opts.file_ext])
    end
  -- If no file extension was provided, use language
  elseif opts.lang then
    license_text = apply_comment_style(license_text, opts.lang)    
  end

  if opts.out then
    local output_file = opts.out ..
      (opts.file_ext and ('.' .. opts.file_ext) or '')
    -- Does an object with a similar name already exists ?
    local is_item = lfs.attributes(output_file)
    -- If it is a file, we should append the license inside as a header
    local append = is_item and (is_item.mode == 'file') or false
    write_to_file(output_file, license_text, append)
  else
    print(license_text)
  end
end

-- =============================================
-- Very minimal (and ugly) GetOpt implementation
-- =============================================

-- Checker for input opt
local function check_opt_style(dash, opt)
  assert(not dash:match('[^%-]'), 'Input is not valid')
  assert(dash:match(GET_OPT_DASHES), 'Input is not valid')
  if dash == '-' then
    assert(opt:len() == 1,
      ('The following was probably mistyped : <%s>'):format(dash..opt))
  elseif (dash == '--') then
    assert(opt:len() > 1,
      ('The following was probably mistyped : <%s>'):format(dash..opt))
  end
end

-- Processes input opt
local function process_opt(cfg, template, opt, value)
  if (opt == 'help' or opt == 'h') then
    print([[usage: lua lice.lua license [-h] [-o ORGANIZATION] [-p PROJECT]
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
      ]])
    os.exit()
  elseif opt == 'vars' then
    local vars = get_template_vars(template)
    print(('License <%s> vars:\n'):format(template))
    for _, var in ipairs(vars) do
      print('  >> ' .. var)
    end
    os.exit()
  elseif (opt == 'list') then
    local sort_list = true
    local list = collect_keys(templates_list, sort_list)
    print(('Available licenses templates:\n'):format(template))    
    for _,template in pairs(list) do
      print('  >> ' .. template)
    end
    os.exit()
  elseif (opt == 'org' or opt == 'o') then
    cfg.organization = value
  elseif (opt == 'proj' or opt == 'p') then
    cfg.project = value
  elseif (opt == 'year' or opt == 'y') then
    local year = value
    assert(year:match(LIC_YEAR_RANGE),
      ('Wrong year: <%s>'):format(value))
    cfg.year = (year:gsub('[^%d]+','-'))
  elseif (opt == 'file' or opt == 'f') then
    cfg.out = cfg.out or value:match(OUT_FILE_NAME)
    local file_ext = value:lower():match(OUT_FILE_EXT)
    if file_ext then
      local lang = LANGS_EXT[file_ext] 
      cfg.file_ext = value:match(OUT_FILE_EXT)
    end
  elseif (opt == 'lang' or opt == 'l') then
    local lang = value:lower()
    local supported_lang = LANGS_CMT_STYLE[lang] and lang or false
    if not supported_lang then
      supported_lang = LANGS_EXT[lang] 
    end
    assert(supported_lang,('Language <%s> is not supported'):format(lang))
    cfg.lang = supported_lang
  else  
    error(
    ([[Could not resolved unknown opt: <%s>
    Use -h (or --help) to print help]]):format(opt))
  end
end

-- Main routine, catch and process args
local function main(_args)
  local template = (_args:match(GET_OPT_LIC_PATTERN) or DEFAULT_LIC_TEMPLATE):lower()

  -- Handle headers template name auto-completion
  if _args:match('%-%-header') and not template:match('%-header$') then
    template = template .. '-header'
  end
  
  -- Asserts the required license is available
  assert(templates_list[template],
    ('License <%s> is not available'):format(template))

  -- Default config
  local cfg = {
    fname = template,                          -- The template
    organization = get_username(),             -- Defaults to USERNAME or USER
    project = get_current_folder_name(),       -- Defaults to current directory
    year = os.date('%Y'),                      -- Defaults to current year
  }
  
  -- Catch, check and resolve options
  for dash, _opt, value in _args:gmatch(GET_OPT_PATTERN) do
    local opt = _opt:lower()
    check_opt_style(dash, opt)
    process_opt(cfg, template, opt, (value:gsub('%s$','')))
  end

  -- Write license to output
  write_license(cfg)
end

-- Creates the list of templates
do
  
  -- Registering styles and extensions
  add_exts('c',         { '/*', ' * ', ' */'},                 'c', 'cc', 'cpp', 'h', 'hpp', 'js', 'css', 'm')
  add_exts('fortran',   {'! ', '! ', '!'},                     'f'                                           )
  add_exts('fortran90', {'!* ', '!* ', '!* '},                 'f90'                                         )
  add_exts('java',      {'/**', '  * ','  */'},                'java'                                        )  
  add_exts('erlang',    {'%% ', '% ', '%% '},                  'erl'                                         )
  add_exts('html',      {'<!--', ' ', '-->'},                  'html'                                        )
  add_exts('lua',       {('-'):rep(80), '-- ', ('-'):rep(80)}, 'lua'                                         )  
  add_exts('perl',      {'=item', ' ', '=cut'},                'pl'                                          )
  add_exts('ruby',      {'=begin', ' ', '=end'},               'rb'                                          )
  add_exts('text',      {'', '', ''},                          'txt'                                         )  
  add_exts('unix',      {'', '# ',''},                         'py', 'sh'                                    )
end

-- Calls main and process input
main(table_concat(arg,' '))