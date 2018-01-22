


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
  base:
    top:                  10
    left:                 20
    width:                '50%'
    height:               '50%'
    label:                ' {bold}{cyan-fg} LABEL HERE {/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
    draggable:            true
    mouse:                true
    smartCSR:             true
    # log:                  process.env.HOME + '/blessed-terminal.log'
    fullUnicode:          true
    dockBorders:          true
    ignoreDockContrast:   true
    autoPadding:          false
    border:               'line'
    # style:
    #     fg:        'default'
    #     bg:        'default'
    #     border:    { fg: 'default', }
    #     focus:     { border: { fg: 'green', }, }
    #     scrolling: { border: { fg: 'red', }, }
    cursor:        { color: 'red', }
  #.........................................................................................................
  screen:
    _extends:           'base'
    log:                '/tmp/blessed-terminal.log'
    _title:             'fancy!'
  #.........................................................................................................
  screen_one:
    'cursor.color':   'red'
    top:              10
    left:             20
    width:            '50%'
    height:           line_count
    tags:             true
    border:           'line'
    label:            ' {bold}{cyan-fg}ANSI Art{/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
    # handler:        ->
    draggable:        true
    mouse:            true
  #.........................................................................................................
  top_screen:
    top:              3
    left:             80
    width:            '50%'
    height:           10
    label:            ' {bold}{cyan-fg}top{/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
    # handler:        ->
    mouse:            true
    smartCSR:             true
    # log:                  process.env.HOME + '/blessed-terminal.log'
    fullUnicode:          true
    dockBorders:          true
    ignoreDockContrast:   true
    style:
      fg: 'default'
      bg: 'yellow'
      focus:
        border:
          fg: 'green'
  #.........................................................................................................
  fmanager:
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
  terminal:
    parent:       screen
    cursor:       'line'
    cursorBlink:  true
    screenKeys:   false
    label:        ' multiplex.js '
    left:         0
    top:          0
    width:        '50%'
    height:       '50%'
  #.........................................................................................................
  xterm:
    # shell:         process.env.SHELL || 'sh'
    # args:          []
    shell:          'top',
    args:           [ '-d', '0.1', ],
    env:            process.env
    cwd:            process.cwd()
    cursorType:     'block'
    border:         'line'
    scrollback:     1000
    left:           0
    top:            0
    width:          -> Math.floor screen.width / 2
    height:         -> screen.height
    label:          "Sample XTerm #1"

#-----------------------------------------------------------------------------------------------------------
screen = blessed.screen({
  smartCSR:           true
  log:                '/tmp/blessed-terminal.log'
  fullUnicode:        true
  dockBorders:        true
  ignoreDockContrast: true
  autoPadding:        false
});

settings.xterm.width  = settings.xterm.width()
settings.xterm.height = settings.xterm.height()

screen.title          = settings.screen._title ? 'kannwas'
screen.key [ 'escape', 'C-q', ], ( chr, key ) -> process.exit 0


#...........................................................................................................
# terminal      = blessed.terminal    copy_merge settings.base, settings.terminal
body          = blessed.box         copy_merge settings.base, settings.screen_one
fmanager      = blessed.filemanager copy_merge settings.base, settings.fmanager
top_screen    = blessed.box         copy_merge settings.base, settings.top_screen
xterm         = new XTerm           copy_merge settings.base, settings.xterm
# #...........................................................................................................
# terminal.pty.on 'data', ( data ) ->
#   screen.log JSON.stringify data

#...........................................................................................................
screen.append body
screen.append fmanager
screen.append top_screen
screen.append xterm
# screen.append terminal

# terminal.focus()
screen.render()

items   = []
counter = 1


write_to_screen_one = ( text ) ->
  items.push text
  items.shift() if items.length > line_count + 1
  for i in [ 1 ... line_count ] by +1
    body.setLine i, items[ i ]
  screen.render()

set_status = ( text ) ->
  body.setLine 0, text
  screen.render()

every 0.01, ->
  set_status new Date().toISOString()
  counter += +1
  write_to_screen_one "Line number: #{counter}"


