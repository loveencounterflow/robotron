


'use strict'

### https://ponyfoo.com/articles/understanding-javascript-async-await ###


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'YAU/DEMO-2'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
#...........................................................................................................
copy_merge                = require 'merge-options'
blessed                   = require 'blessed'
XTerm                     = require 'blessed-xterm'
every                     = ( dts, f ) -> setInterval f, dts * 1000

#-----------------------------------------------------------------------------------------------------------
line_count = 20

#-----------------------------------------------------------------------------------------------------------
settings =
  #.........................................................................................................
  '*':
    smartCSR:             true
    # log:                  process.env.HOME + '/blessed-terminal.log'
    fullUnicode:          true
    dockBorders:          true
    ignoreDockContrast:   true
    autoPadding:          false
    mouse:                true
  #.........................................................................................................
  boxes:
    _extends:         '*'
    _uses:            'box'
    top:              10
    left:             20
    width:            '50%'
    height:           '50%'
    label:            ' {bold}{cyan-fg} LABEL HERE {/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
    draggable:        true
    border:           'line'
    tags:             true
    style:
        fg:        'default'
        bg:        'default'
        border:    { fg: 'default', }
        focus:     { border: { fg: 'cyan', }, }
    # cursor:        { color: 'red', }
  #.........................................................................................................
  terminals:
    style:
        scrolling: { border: { fg: 'red', }, }
    _extends:         'boxes'
    _uses:            'xterm'
    shell:            process.env.SHELL || 'sh'
    args:             []
    env:              process.env
    cwd:              process.cwd()
    cursorType:       'block'
    scrollback:       1000
    label:            "terminal"
    mousePassthrough: false
  #.........................................................................................................
  screen:
    _extends:           '*'
    log:                '/tmp/blessed-terminal.log'
    _title:             'robotron'
  #.........................................................................................................
  screen_one:
    _extends:         'boxes'
    _show:            yes
    top:              10
    left:             20
    width:            '50%'
    height:           line_count
    label:            ' {bold}{cyan-fg}ANSI Art{/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
  #.........................................................................................................
  top_screen:
    _extends:         'boxes'
    _show:            yes
    top:              3
    left:             80
    width:            '50%'
    height:           10
    label:            ' {bold}{cyan-fg}top{/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
  #.........................................................................................................
  fmanager:
    _extends:         'boxes'
    _show:            yes
    # // parent: screen
    border:           'line'
    top:              0
    left:             80
    width:            '25%'
    height:           '50%'
    draggable:        true
    mouse:            true
    cwd:              __dirname
  #.........................................................................................................
  top:
    _extends:         'terminals'
    _show:            yes
    shell:            'top',
    args:             [ '-d', '0.1', ],
    left:             0
    top:              0
    width:            ( screen ) -> Math.floor screen.width / 2
    height:           ( screen ) -> screen.height
    label:            "Sample XTerm #1"
  #.........................................................................................................
  htop:
    _extends:         'terminals'
    _show:            yes
    shell:            'htop',
    left:             ( screen ) -> Math.floor screen.width / 2
    top:              0
    width:            ( screen ) -> Math.floor screen.width / 2
    height:           ( screen ) -> screen.height
    mousePassthrough: true
    label:            "htop"
  #.........................................................................................................
  terminal:
    _extends:         'terminals'
    _show:            yes
    left:             ( screen ) -> Math.floor screen.width / 3
    top:              0
    width:            108
    height:           20
    mousePassthrough: true
    label:            "terminal"
  #.........................................................................................................
  mylist:
    _extends:         'boxes'
    _show:            yes

#-----------------------------------------------------------------------------------------------------------
@resolve_dependencies = ( settings, key ) ->
  @_resolve_dependencies settings, key, []

#-----------------------------------------------------------------------------------------------------------
@_resolve_dependencies = ( settings, key, R ) ->
  entry = settings[ key ]
  throw new Error "unknown settings key #{rpr key}" unless entry?
  R.unshift key
  return ( @_resolve_dependencies settings, sub_key, R ) if ( sub_key = entry._extends )?
  return R

#-----------------------------------------------------------------------------------------------------------
@_list_settings_from_key = ( settings, key ) ->
  return ( settings[ k ] for k in @resolve_dependencies settings, key )

#-----------------------------------------------------------------------------------------------------------
@settings_from_key = ( parent, settings, key ) ->
  switch arity = arguments.length
    when 2 then [ parent, settings, key, ] = [ null, parent, settings, ]
    when 3 then null
    else throw new Error "expected 2 or 3 arguments, got #{arity}"
  #.........................................................................................................
  R = copy_merge ( @_list_settings_from_key settings, key )...
  for k in [ 'left', 'top', 'width', 'height', ]
    continue unless CND.isa_function ( f = R[ k ] )
    R[ k ] = f parent
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
screen = blessed.screen @settings_from_key    settings, 'screen'
screen.title          = settings.screen._title ? 'kannwas'
screen.key [ 'escape', 'C-q', ], ( chr, key ) -> process.exit 0
#...........................................................................................................
body          = blessed.box         @settings_from_key screen, settings,  'screen_one'
fmanager      = blessed.filemanager @settings_from_key screen, settings,  'fmanager'
top_screen    = blessed.box         @settings_from_key screen, settings,  'top_screen'
top           = new XTerm           @settings_from_key screen, settings,  'top'
htop          = new XTerm           @settings_from_key screen, settings,  'htop'
terminal      = new XTerm           @settings_from_key screen, settings,  'terminal'
# #...........................................................................................................
# terminal.pty.on 'data', ( data ) ->
#   screen.log JSON.stringify data

#...........................................................................................................
screen.append top
screen.append htop
screen.append body
screen.append fmanager
screen.append top_screen
screen.append terminal

###
elements = {}
for key, entry of settings
  continue unless entry._show
  element_settings  = @settings_from_key screen, settings, key
  classname         = entry._uses ? 'box'
  switch classname
    when 'xterm'
      element = new XTerm element_settings
    else
      instantiator  = blessed[ classname ]
      throw new Error "unknown classname #{classname}" unless instantiator?
      element = instantiator.call blessed, element_settings
  screen.append element
  elements[ key ] = element
# terminal.focus()
screen.render()

items   = []
counter = 1
write_to_screen_one = ( text ) ->
  items.push text
  items.shift() if items.length > line_count + 1
  for i in [ 1 ... line_count ] by +1
    elements.screen_one.setLine i, items[ i ]
  screen.render()

set_status = ( text ) ->
  elements.screen_one.setLine 0, text
  screen.render()

every 0.01, ->
  set_status new Date().toISOString()
  counter += +1
  write_to_screen_one "Line number: #{counter}"
###


