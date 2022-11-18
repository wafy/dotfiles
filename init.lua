hs.hotkey.bind({'option', 'cmd'}, 'R', function()
    hs.reload()
end)

hs.hotkey.bind({'shift', 'option'}, 'N', function()
    hs.application.launchOrFocus('Notes')
end)in

hs.hotkey.bind({'shift', 'option'}, 'C', function()
    hs.application.launchOrFocus('Google Chrome')
end)

hs.hotkey.bind({'shift', 'option'}, 'T', function()
    hs.application.launchOrFocus('Terminal')
end)

hs.hotkey.bind({'option', 'command'}, 'T', function()
    hs.application.launchOrFocus('Timer')
end)

hs.hotkey.bind({'shift', 'option'}, 'K', function()
    hs.application.launchOrFocus('kakaoTalk')
end)

hs.hotkey.bind({'shift', 'option'}, 'B', function()
    hs.application.launchOrFocus('Bear')
end)

hs.hotkey.bind({'shift'}, 'F1', hs.hints.windowHints)

local function move_win(xx, yy, ww, hh)
    return function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local max = win:screen():frame()
        f.x = max.x + (max.w/2) * xx
        f.y = max.y + (max.h/2) * yy
        f.w = max.w / ww
        f.h = max.h / hh
        win:setFrame(f)
    end
end

local left = 0
local right = 1

local top = 0
local mid = 1

local half_width = 2
local full_width = 1
local half_height = 2
local full_height = 1

local mod = {'option', 'shift'}


local inputEnglish = "com.apple.keylayout.ABC"
hs.keycodes.inputSourceChanged(
  function()
    local source = hs.keycodes.currentSourceID()
    show_status_bar(not (inputEnglish == source))
  end
)
function draw_rectangle(target_draw, screen, offset, width, fill_color)
  local screeng                  = screen:fullFrame()
  local screen_frame_height      = screen:frame().y
  local screen_full_frame_height = screeng.y
  local height_delta             = screen_frame_height - screen_full_frame_height
  local height                   = 23
  target_draw:setSize(hs.geometry.rect(screeng.x + offset, screen_full_frame_height, width, height))
  target_draw:setTopLeft(hs.geometry.point(screeng.x + offset, screen_full_frame_height))
  target_draw:setFillColor(fill_color)
  target_draw:setFill(true)
  target_draw:setAlpha(0.5)
  target_draw:setLevel(hs.drawing.windowLevels.overlay)
  target_draw:setStroke(false)
  target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
  target_draw:show()
end
local boxes = {}
function show_status_bar(stat)
  if stat then
      show_status_bar(false)
      hs.fnutils.each(hs.screen.allScreens(), function(scr)
          local box = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
          if not (box == nil) then
            draw_rectangle(box, scr, 0, scr:fullFrame().w, hs.drawing.color.osx_green)
            table.insert(boxes, box)
          end
      end)
  else
      hs.fnutils.each(boxes, function(box)
          if not (box == nil) then
              box:delete()
          end
      end)
      boxes = {}
  end
end

ifiWatcher = nil
homeSSID = "Kurly@InDoor"
lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == homeSSID and lastSSID ~= homeSSID then
        -- We just joined our home WiFi network
        hs.audiodevice.defaultOutputDevice():setVolume(0)
    elseif newSSID ~= homeSSID and lastSSID == homeSSID then
        -- We just departed our home WiFi network
        hs.audiodevice.defaultOutputDevice():setVolume(25)
    end

    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

-- hs.hotkey.bind({}, 'f17', function() f15_mode:enter() end, function() f15_mode:exit() end)

local f17_mode = hs.hotkey.modal.new()
hs.hotkey.bind({}, 'f17', function() f17_mode:enter() end, function() f17_mode:exit() end)
do  -- app manager
    local app_man = require('modules.appman')
    local mode = f17_mode
    mode:bind({}, 'c', app_man:toggle('Google Chrome'))
    mode:bind({}, 'i', app_man:toggle('IntelliJ IDEA'))
    mode:bind({}, 's', app_man:toggle('Slack'))
    mode:bind({}, 'f', app_man:toggle('Finder'))
    mode:bind({}, 'k', app_man:toggle('KakaoTalk'))
    -- mode:bind({}, 'd', app_man:toggle('MySQLWorkbench'))
    mode:bind({'shift'}, 'd', app_man:toggle('DataGrip'))
    mode:bind({}, 'space', app_man:toggle('Terminal'))
    mode:bind({}, 'm', app_man:toggle('NoSQLBooster for MongoDB'))
    mode:bind({}, 'z', app_man:toggle('zoom.us'))
    mode:bind({}, 'n', app_man:toggle('Notion'))
    mode:bind({}, 'w', app_man:toggle('Code With Me Guest'))
end
do  -- winmove
    local win_move = require('modules.winmove')
    local mode = f17_mode
    mode:bind({}, '0', win_move.default)
    mode:bind({'shift'}, '0', move_win(1/3, 0, 3/2, 1))
    mode:bind({}, '1', win_move.left_bottom)
    mode:bind({}, '2', win_move.bottom)
    mode:bind({}, '3', win_move.right_bottom)
    mode:bind({}, '4', win_move.left)
    mode:bind({}, '5', win_move.full_screen)
    mode:bind({}, '6', win_move.right)
    mode:bind({}, '7', win_move.left_top)
    mode:bind({}, '8', win_move.top)
    mode:bind({}, '9', win_move.right_top)
    mode:bind({}, '-', win_move.prev_screen)
    mode:bind({}, '=', win_move.next_screen)
end


local f13_mode = hs.hotkey.modal.new()
local vim_mode = require('modules.vim'):init(f13_mode)
do  -- f13 (vimlike)
    hs.hotkey.bind({}, 'f13', vim_mode.on, vim_mode.off)
    hs.hotkey.bind({'cmd'}, 'f13', vim_mode.on, vim_mode.off)
    hs.hotkey.bind({'shift'}, 'f13', vim_mode.on, vim_mode.off)

    f13_mode:bind({'shift'}, 'r', hs.reload, vim_mode.close)
end
do  -- f13 (tab move)
    local tabTable = {}


    tabTable['Slack'] = {
        left = { mod = {'option'}, key = 'up' },
        right = { mod = {'option'}, key = 'down' }
    }
    tabTable['Safari'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['터미널'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['Terminal'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['iTerm2'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['IntelliJ IDEA'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['PhpStorm'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['NoSQLBooster for MongoDB'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['_else_'] = {
        left = { mod = {'control'}, key = 'pageup' },
        right = { mod = {'control'}, key = 'pagedown' }
    }

    local function tabMove(dir)
        return function()
            local activeAppName = hs.application.frontmostApplication():name()
            local tab = tabTable[activeAppName] or tabTable['_else_']
            hs.eventtap.keyStroke(tab[dir]['mod'], tab[dir]['key'])
        end
    end

    f13_mode:bind({}, ',', tabMove('left'), vim_mode.close, tabMove('left'))
    f13_mode:bind({}, '.', tabMove('right'), vim_mode.close, tabMove('right'))
end
