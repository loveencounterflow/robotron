


'use strict'

### https://ponyfoo.com/articles/understanding-javascript-async-await ###


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'ROBOTRON'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
#...........................................................................................................
copy_merge                = require 'merge-options'
# blessed                   = require 'blessed'
# blessed                   = require 'node-blessed'
XTerm                     = require 'blessed-xterm'
every                     = ( dts, f ) -> setInterval f, dts * 1000


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
settings =
  #.........................................................................................................
  '*':
    # smartCSR:             true
    fastCSR:              true
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
  statuses:
    _extends:         'boxes'
    top:              ( screen ) -> screen.height - 1
    left:             0
    width:            '100%'
    # width:            'shrink'
    height:           1
    border:           null
    style:            { bg: 'blue', }
    label:            null
    content:          "status"
    draggable:        false
  #.........................................................................................................
  status:
    _extends:         'statuses'
    _show:            yes
  #.........................................................................................................
  screen:
    _extends:           '*'
    log:                '/tmp/blessed-terminal.log'
    _title:             'robotron'
  #.........................................................................................................
  top_screen:
    _extends:         'boxes'
    # _show:            yes
    top:              3
    left:             80
    width:            '50%'
    height:           10
    label:            ' {bold}{cyan-fg}top{/cyan-fg}{/bold} {#0088ff-fg}(Drag Me){/#0088ff-fg} '
  #.........................................................................................................
  fmanager:
    _extends:         'boxes'
    # _show:            yes
    _uses:            'filemanager'
    label:            CND.plum ' filemanager '
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
    # _show:            yes
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
    # _show:            yes
    shell:            'htop',
    left:             ( screen ) -> Math.floor screen.width / 2
    top:              0
    width:            ( screen ) -> Math.floor screen.width / 2
    height:           ( screen ) -> screen.height
    mousePassthrough: true
    label:            "htop"
  #.........................................................................................................
  terminal_1:
    _extends:         'terminals'
    # _show:            yes
    left:             0
    top:              0
    width:            30
    height:           20
    mousePassthrough: true
    label:            "terminal"
  #.........................................................................................................
  terminal_2:
    _extends:         'terminals'
    # _show:            yes
    left:             ( screen ) -> Math.floor screen.width / 3
    top:              0
    width:            108
    height:           20
    mousePassthrough: true
    label:            "terminal"
  #.........................................................................................................
  lists:
    _extends:         'boxes'
    # style:
    #     scrolling: { border: { fg: 'red', }, }
    # style.selected  ### Style for a selected item.                                                                                                                                                                                                                      ###
    # style.item      ### Style for an unselected item.                                                                                                                                                                                                                   ###
    mouse:            yes           ### Whether to automatically enable mouse support for this list (allows clicking items).                                                                                                                                                            ###
    # keys            ### Use predefined keys for navigating the list.                                                                                                                                                                                                    ###
    # vi              ### Use vi keys with the keys option.                                                                                                                                                                                                               ###
    # items           ### An array of strings which become the list's items.                                                                                                                                                                                              ###
    # search          ### A function that is called when vi mode is enabled and the key / is pressed. This function accepts a callback function which should be called with the search string. The search string is then used to jump to an item that is found in items.  ###
    interactive:      yes           ### Whether the list is interactive and can have items selected (Default: true).                                                                                                                                                                    ###
    invertSelected:   yes           ### Whether to automatically override tags and invert fg of item when selected (Default: true).                                                                                                                                                     ###
    scrollbar:        { ch: ' ', track: { bg: 'red', }, style: { inverse: true, }, }
    style:            { shadow: true, blink: false, item: { hover: { bg: 'red', }, }, selected: { bg: 'blue', bold: true }, }
  #.........................................................................................................
  mylist:
    _extends:         'lists'
    _show:            yes
    label:            CND.bold CND.cyan ' Nodes '
    tags:             true
    draggable:        true
    top:              0
    left:             0
    width:            30
    height:           10
    keys:             true

#-----------------------------------------------------------------------------------------------------------
screen = blessed.screen @settings_from_key    settings, 'screen'
screen.title          = settings.screen._title ? 'kannwas'
screen.key [ 'escape', 'C-q', ], ( chr, key ) -> process.exit 0
status = null
mylist = null

#-----------------------------------------------------------------------------------------------------------
@method_a = ->
  #...........................................................................................................
  # top_screen    = blessed.box         @settings_from_key screen, settings,  'top_screen'
  top           = new XTerm           @settings_from_key screen, settings,  'top'
  fmanager      = blessed.filemanager @settings_from_key screen, settings,  'fmanager'
  htop          = new XTerm           @settings_from_key screen, settings,  'htop'
  terminal_1    = new XTerm           @settings_from_key screen, settings,  'terminal_1'
  terminal_2    = new XTerm           @settings_from_key screen, settings,  'terminal_2'
  mylist        = blessed.list        @settings_from_key screen, settings,  'mylist'
  status        = blessed.box         @settings_from_key screen, settings,  'status'
  # #...........................................................................................................
  # terminal.pty.on 'data', ( data ) ->
  #   screen.log JSON.stringify data
  mylist.on 'action', ( P... ) -> screen.log '22821', 'mylist', P

  #...........................................................................................................
  screen.append top
  # screen.append body
  # screen.append top_screen
  # screen.append htop
  screen.append terminal_1
  screen.append terminal_2
  # screen.append fmanager
  screen.append status
  # screen.append mylist
  #...........................................................................................................
  fmanager.refresh()
  #...........................................................................................................
  mylist.focus()
  screen.render()

#-----------------------------------------------------------------------------------------------------------
@method_b = ->
  R = {}
  #.........................................................................................................
  for key, entry of settings
    continue unless entry._show
    element_settings  = @settings_from_key screen, settings, key
    classname         = entry._uses ? 'box'
    #.......................................................................................................
    switch classname
      #.....................................................................................................
      when 'xterm'
        element = new XTerm element_settings
      #.....................................................................................................
      else
        instantiator = blessed[ classname ]
        throw new Error "unknown classname #{classname}" unless instantiator?
        element = instantiator.call blessed, element_settings
    #.......................................................................................................
    screen.append element
    R[ key ] = element
  #.........................................................................................................
  # terminal.focus()
  screen.render()
  return R

@method_a()
# @method_b()

###
line_count  = 20
items       = []
counter     = 1
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



# list = blessed.list(
#   label:      ' {bold}{cyan-fg}Art List{/cyan-fg}{/bold} (Drag Me) '
#   tags:       true
#   draggable:  true
#   top:        0
#   right:      0
#   width:      30
#   height:     '50%'
#   keys:       true
#   vi:         true
#   mouse:      true
#   border:     'line'
#   scrollbar:
#     ch:    ' '
#     track: { bg: 'cyan'}
#     style: { inverse: true}
#   style:
#     item:  { hover: bg: 'blue'}
#     selected: { bg: 'blue', bold: true }
#   search: ( callback ) ->
#     prompt.input 'Search:', '', ( error, value ) ->
#       return if error?
#       callback null, value
#     return
# )

map =
  'node 01 a': { id: 'node01a', machine: 'node01', }
  'node 02 a': { id: 'node02a', machine: 'node02', }
  'node 03 a': { id: 'node03a', machine: 'node03', }
  'node 04 a': { id: 'node04a', machine: 'node04', }
  'node 05 a': { id: 'node05a', machine: 'node05', }
  'node 06 a': { id: 'node06a', machine: 'node06', }
  'node 07 a': { id: 'node07a', machine: 'node07', }
  'node 08 a': { id: 'node08a', machine: 'node08', }
  'node 09 a': { id: 'node09a', machine: 'node09', }
  'node 11 a': { id: 'node11a', machine: 'node11', }
  'node 12 a': { id: 'node12a', machine: 'node12', }
  'node 13 a': { id: 'node13a', machine: 'node13', }
  'node 14 a': { id: 'node14a', machine: 'node14', }
  'node 15 a': { id: 'node15a', machine: 'node15', }
  'node 16 a': { id: 'node16a', machine: 'node16', }
  'node 17 a': { id: 'node17a', machine: 'node17', }
  'node 18 a': { id: 'node18a', machine: 'node18', }
  'node 19 a': { id: 'node19a', machine: 'node19', }

mylist.setItems ( ( CND.bold CND.yellow k ) for k in Object.keys map )

mylist.on 'select', ( element, selected ) ->
  # if mylist._.rendering
  #   return
  key   = element.getText()
  entry = map[ key ]
  status.setContent JSON.stringify entry
  screen.render()
  # mylist._.rendering = true
  return

mylist.items.forEach (item, i) ->
  text = item.getText()
  item.setHover map[text]
  return

      # art.term.reset(); art.term.write body; art.term.cursorHidden = true
      # if process.argv[2] == '--debug' or process.argv[2] == '--save'
      #   takeScreenshot name


