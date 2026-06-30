------------- Instructions -------------
-- -- Video Demonstration: https://www.youtube.com/watch?v=M4t7HYS73ZQ
--
-- -- Open clipboard inserter https://anacreondjt.gitlab.io/docs/texthooker/
-- -- Open your anime with japanese subtitles in MPV
-- -- Wait for unknown word and add it to anki through yomichan
-- -- Select all the subtitle lines you wish to add to the card.
-- -- Ctrl + c
-- -- Tab back to MPV and Ctrl + v
-- -- Done. The lines, their respective Audio and the current paused image
-- -- will be added to the back of the card.
-- -- Ctrl + t will toggle clipboard inserter on and off.
-- -- Be sure to configure the user config below.
---------------------------------------

------------- Credits -------------
-- This script was made by users of 4chan's Daily Japanese Thread (DJT) on /jp/
-- More information can be found here http://animecards.site/
-- Message @Anacreon with bug reports and feature requests on Discord (https://animecards.site/discord/) or 4chan (https://boards.4channel.org/jp/#s=djt)
--
-- If you like this work please consider subscribing on Patreon!
-- https://www.patreon.com/Quizmaster
------------------------------------

local utils = require 'mp.utils'
local msg = require 'mp.msg'

------------- User Config -------------
-- Set these to match your field names in Anki
local FRONT_FIELD = "Expression"
local SENTENCE_AUDIO_FIELD = "SentenceAudio"
local SENTENCE_FIELD = "Sentence"
local IMAGE_FIELD = "Picture"
-- Anki collection media path. Ensure Anki username is correct.
-- Linux users will want to set this to something like:
-- utils.join_path(os.getenv('HOME'), [[.local/share/Anki2/User 1/collection.media]])
-- and MacOS will need something like:
-- utils.join_path(os.getenv('HOME'), [[Library/Application Support/Anki2/User 1/collection.media]])
local anki_media = os.getenv('APPDATA') and utils.join_path(os.getenv('APPDATA'), [[Anki2\User 1\collection.media]]) or utils.join_path(os.getenv('HOME'), [[.local/share/Anki2/User 1/collection.media]])

local TEMP_DIR = '/tmp/mpv-animecards'
os.execute('mkdir -p ' .. TEMP_DIR)
-- Optional padding and fade settings in seconds.
-- Padding grabs extra audio around your selected subs.
-- Fade does a volume fade effect at the beginning and end of the resulting audio.
local AUDIO_CLIP_FADE = 0.2
local AUDIO_CLIP_PADDING = 0.75
-- Optional fetch Forvo word audio if word audio field is empty in Anki.
local WORD_AUDIO_FIELD = ""
-- Optional play sentence and forvo audio automatically after card update
local AUTOPLAY_AUDIO = false
-- Optional screenshot image format.
-- Change to "jpeg" if you plan to view cards on iOS or Mac.
local IMAGE_FORMAT = "webp"
-- Optional set to true if you want your volume in mpv to affect Anki card volume.
local USE_MPV_VOLUME = false
---------------------------------------

local subs = {}
local enable_subs_to_clip = true
local debug_mode = false
local use_powershell_clipboard = nil

if unpack ~= nil then table.unpack = unpack end

local o = {}
local platform
if mp.get_property_native('options/vo-mmcss-profile', o) ~= o then
  platform = 'windows'
elseif mp.get_property('options/cocoa-force-dedicated-gpu', o) ~= o then
  platform = 'macos'
else
  platform = 'linux'
end

local use_wl_clipboard = false
if platform == 'linux' and os.getenv('WAYLAND_DISPLAY') then
  local wl_copy_exists = os.execute('which wl-copy > /dev/null 2>&1')
  if wl_copy_exists then
    use_wl_clipboard = true
  end
end

local function set_clipboard(text)
  if platform == 'windows' then
    if use_powershell_clipboard == nil then
      determine_clip_type()
    end
    if use_powershell_clipboard then
      powershell_set_clipboard(text)
    else
      cmd_set_clipboard(text)
    end
  elseif platform == 'macos' then
    macos_set_clipboard(text)
  elseif use_wl_clipboard then
    os.execute('cat <<EOF | wl-copy -n\n' .. text .. '\nEOF\n')
  else
    linux_set_clipboard(text)
  end
end

local function get_clipboard_text()
  if platform == 'windows' then
    local res = utils.subprocess({ args = {
      'powershell', '-NoProfile', '-Command', [[& {
        Trap {
          Write-Error -ErrorRecord $_
          Exit 1
        }
        $clip = ""
        if (Get-Command "Get-Clipboard" -errorAction SilentlyContinue) {
          $clip = Get-Clipboard -Raw -Format Text -TextFormatType UnicodeText
        } else {
          Add-Type -AssemblyName PresentationCore
          $clip = [Windows.Clipboard]::GetText()
        }
        $clip = $clip -Replace "`r",""
        $u8clip = [System.Text.Encoding]::UTF8.GetBytes($clip)
        [Console]::OpenStandardOutput().Write($u8clip, 0, $u8clip.Length)
      }]]
    } })
    if not res.error then
      return res.stdout
    end
  elseif platform == 'macos' then
    return io.popen('LANG=en_US.UTF-8 pbpaste'):read("*a")
  elseif use_wl_clipboard then
    local handle = io.popen('wl-paste -n')
    if handle then
      local result = handle:read("*a")
      handle:close()
      return result
    end
  else
    local res = utils.subprocess({ args = {
      'xclip', '-selection', 'clipboard', '-out'
    } })
    if not res.error then
      return res.stdout
    end
  end
end

local function dlog(...)
  if debug_mode then
    print(...)
  end
end

local function clean(s)
  for _, ws in ipairs({'%s', ' ', '᠎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '​', ' ', ' ', '　', '﻿', '‪'}) do
    s = s:gsub(ws..'+', "")
  end
  return s
end

local function get_name(s, e)
  return mp.get_property("filename"):gsub('%W','').. tostring(s) .. tostring(e)
end

local function get_clipboard()
  return get_clipboard_text()
end

local function powershell_set_clipboard(text)
  utils.subprocess({ args = {
    'powershell', '-NoProfile', '-Command', [[Set-Clipboard -Value @"]] .. "\n" .. text .. "\n" .. [["@]]
  }})
end

local function cmd_set_clipboard(text)
  local cmd = 'echo ' .. text .. ' | clip';
  mp.command("run cmd /D /C " .. cmd);
end

local function determine_clip_type()
  powershell_set_clipboard([[Anacreon様]])
  use_powershell_clipboard = get_clipboard() == [[Anacreon様]]
end

local function linux_set_clipboard(text)
  os.execute('xclip -selection clipboard <<EOF\n' .. text .. '\nEOF\n')
end

local function macos_set_clipboard(text)
  os.execute('export LANG=en_US.UTF-8; cat <<EOF | pbcopy\n' .. text .. '\nEOF\n')
end

local function record_sub(_, text)
  if text and mp.get_property_number('sub-start') and mp.get_property_number('sub-end') then
    local sub_delay = mp.get_property_native("sub-delay")
    local audio_delay = mp.get_property_native("audio-delay")
    local newtext = clean(text)
    if newtext == '' then
      return
    end

    subs[newtext] = { mp.get_property_number('sub-start') + sub_delay - audio_delay, mp.get_property_number('sub-end') + sub_delay - audio_delay }
    dlog(string.format("%s -> %s : %s", subs[newtext][1], subs[newtext][2], newtext))
    if enable_subs_to_clip then
      text = string.gsub(text, "[\n\r]+", " ")
      set_clipboard(text)
    end
  end
end

local function clean_audio(filename)
  local destination = utils.join_path(TEMP_DIR, 'normalize_tmp.mp3')
  mp.commandv(
    'run',
    'mpv',
    filename,
    '--af-append=lowpass=1000',
    '--af-append=highpass=200',
    '--af-append=areverse',
    '--af-append=silenceremove=1:0:-35dB',
    '--af-append=areverse',
    string.format('-o=%s', destination)
  )
  local args
  if platform == 'windows' then
    args = {'powershell', '-NoProfile', '-Command', [[& {
      while (!(Test-Path "]] .. destination .. [[")) { Start-Sleep -Milliseconds 100 }
      }]]
    }
    utils.subprocess({ args = args, capture_stderr = true })
    args = {'powershell', '-NoProfile', '-Command', [[& {
      mv -Force "]] .. destination .. [[" "]] .. filename .. [["
      }]]
    }
    utils.subprocess({ args = args, capture_stderr = true })
  else
    args = {'/bin/sh', '-c', [[
until [ -f "]] .. destination .. [[" ] ; do sleep 1; done ]]}
    utils.subprocess({ args = args, capture_stderr = true })
    args = {'mv', destination, filename}
    utils.subprocess({ args = args, capture_stderr = true })
  end
end

local function shell_escape(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function create_audio(s, e)
  if s == nil or e == nil then
    return
  end

  local name = get_name(s, e)
  local destination = utils.join_path(TEMP_DIR, name .. '.mp3')
  s = s - AUDIO_CLIP_PADDING
  local t = e - s + AUDIO_CLIP_PADDING
  local source = mp.get_property("path")

  mp.set_property('pause', 'yes')

  -- Remove stale file from previous run
  os.execute("rm -f " .. shell_escape(destination))

  local cmd = string.format(
    "ffmpeg -y -i %s -ss %.3f -t %.3f -vn -ac 1 -ar 48000 -af afade=t=in:st=%.3f:d=%.3f,afade=t=out:st=%.3f:d=%.3f %s < /dev/null > /tmp/mpv-animecards-audio.log 2>&1 &",
    shell_escape(source), s, t, s, AUDIO_CLIP_FADE, s + t - AUDIO_CLIP_FADE, AUDIO_CLIP_FADE, shell_escape(destination)
  )

  os.execute(cmd)
  dlog('Audio capture: ' .. cmd)

  local poll_count = 0
  while not io.open(destination, 'r') and poll_count < 120 do
    os.execute("sleep 0.5")
    poll_count = poll_count + 1
  end

  -- Poll for actual content > 0 bytes
  if io.open(destination, 'rb') then
    local wait_content = 0
    while wait_content < 60 do
      local f = io.open(destination, 'rb')
      if f then
        local size = f:seek("end")
        f:close()
        if size and size > 0 then break end
      end
      os.execute("sleep 1")
      wait_content = wait_content + 1
    end
  end

  -- Verify file has content before returning
  local f = io.open(destination, 'rb')
  if not f then return nil end
  local size = f:seek("end")
  f:close()
  if not size or size == 0 then return nil end
  return destination
end

local function create_screenshot(s, e)
  local img = utils.join_path(TEMP_DIR, get_name(s,e) .. '.' .. IMAGE_FORMAT)
  local source = mp.get_property("path")
  local time_pos = mp.get_property_number("time-pos")

  mp.set_property('pause', 'yes')

  -- Remove stale file from previous run
  os.execute("rm -f " .. shell_escape(img))

  local cmd_parts = {
    string.format("ffmpeg -y -i %s -ss %.3f -frames:v 1", shell_escape(source), time_pos)
  }
  if IMAGE_FORMAT == 'webp' then
    table.insert(cmd_parts, '-vf scale=480*iw*sar/ih:480')
    table.insert(cmd_parts, '-vcodec libwebp -lossless 0 -compression_level 6 -preset drawing')
  elseif IMAGE_FORMAT == 'png' then
    table.insert(cmd_parts, '-vf format=rgb24,scale=480*iw*sar/ih:480')
  end
  table.insert(cmd_parts, shell_escape(img))

  local cmd = table.concat(cmd_parts, ' ') .. ' < /dev/null > /tmp/mpv-animecards-img.log 2>&1 &'
  os.execute(cmd)
  dlog('Screenshot capture: ' .. img)

  local poll_count = 0
  while not io.open(img, 'r') and poll_count < 60 do
    os.execute("sleep 0.5")
    poll_count = poll_count + 1
  end

  -- Verify file has content before returning
  local f = io.open(img, 'rb')
  if not f then return nil end
  local size = f:seek("end")
  f:close()
  if not size or size == 0 then return nil end
  return img
end

local function anki_connect(action, params)
  local request = utils.format_json({action=action, params=params, version=6})
  local args
  if platform == 'windows' then
    args = {
      'powershell', '-NoProfile', '-Command', [[& {
      $data = Invoke-RestMethod -Uri http://127.0.0.1:8765 -Method Post -ContentType 'application/json; charset=UTF-8' -Body @"]] .. "\n" .. request .. "\n" .. [["@ | ConvertTo-Json -Depth 10
      $u8data = [System.Text.Encoding]::UTF8.GetBytes($data)
      [Console]::OpenStandardOutput().Write($u8data, 0, $u8data.Length)
      }]]
    }
  else
    args = {'curl', '-s', 'localhost:8765', '-X', 'POST', '-d', request}
  end

  local result = utils.subprocess({ args = args, cancellable = true, capture_stderr = true })
  dlog(result.stdout)
  dlog(result.stderr)
  return utils.parse_json(result.stdout)
end

local function anki_connect_media(action, params)
  local script_dir = "/home/mortal/.config/mpv/scripts"
  local python_script = utils.join_path(script_dir, "anki_media_helper.py")

  if action == 'storeMediaFile' then
    msg.info("Running Python for storeMediaFile: " .. (params.filename or ''))
    
    local result = utils.subprocess({ 
      args = {'python3', '-u', python_script, 'storeMediaFile', params.filename or '', params.data or ''},
      cancellable = true, 
      capture_stderr = true 
    })
    
    dlog("Python anki response: '" .. (result.stdout or "") .. "'")
    if result.stderr and #result.stderr > 0 then
      msg.info("Python stderr: " .. result.stderr)
    end
    
    return utils.parse_json(result.stdout or '')
  elseif action == 'updateNoteFields' then
    local note = params.note or {}
    local fields_json = utils.format_json(note.fields)
    
    msg.info("Running Python for updateNoteFields, noteid: " .. tostring(note.id))
    
    local result = utils.subprocess({ 
      args = {'python3', '-u', python_script, 'updateNoteFields', tostring(note.id), fields_json},
      cancellable = true, 
      capture_stderr = true 
    })
    
    dlog("Python anki response: '" .. (result.stdout or "") .. "'")
    if result.stderr and #result.stderr > 0 then
      msg.info("Python stderr: " .. result.stderr)
    end
    
    return utils.parse_json(result.stdout or '')
  else
    -- Fallback for other actions - use curl via Python
    local tmp_file = "/tmp/mpv-anki-request-" .. tostring(os.time()) .. "-" .. tostring(math.random(10000)) .. ".json"
    local f = io.open(tmp_file, 'w')
    if not f then return nil end
    f:write(utils.format_json({action=action, params=params, version=6}))
    f:close()

    local args = {'python3', '-u', python_script, tmp_file}
    
    local result = utils.subprocess({ args = args, cancellable = true, capture_stderr = true })
    os.remove(tmp_file)
    
    dlog("Python anki response: '" .. (result.stdout or "") .. "'")
    return utils.parse_json(result.stdout or '')
  end
end

local function url_enc(url)
  local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
  end
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w _%%%-%.~])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

local function get_forvo_audio(word)
  local function b64dec(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
      if (x == '=') then return '' end
      local r,f='',(b:find(x)-1)
      for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
      return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
      if (#x ~= 8) then return '' end
      local c=0
      for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
      return string.char(c)
    end))
  end

  local args
  if platform == 'windows' then
    args = {
      'powershell', '-NoProfile', '-Command', [[& {
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $data = Invoke-WebRequest -Uri "https://forvo.com/search/]] .. url_enc(word) .. [[/ja/" -Headers @{
      "method"="GET"
      "authority"="forvo.com"
      "scheme"="https"
      "cache-control"="max-age=0"
      "upgrade-insecure-requests"="1"
      "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36 Edg/86.0.622.58"
      "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
      "sec-fetch-site"="same-origin"
      "sec-fetch-mode"="navigate"
      "sec-fetch-user"="?1"
      "sec-fetch-dest"="document"
      "referer"="https://forvo.com/"
      "accept-encoding"="gzip, deflate, br"
      "accept-language"="en-US,en;q=0.9"
    }
      $u8data = [System.Text.Encoding]::UTF8.GetBytes($data)
      [Console]::OpenStandardOutput().Write($u8data, 0, $u8data.Length)
      }]]
    }
  else
    args = {
      'curl', 'https://forvo.com/search/' .. word .. '/ja/',
      '-H', 'authority: forvo.com',
      '-H', 'pragma: no-cache',
      '-H', 'cache-control: no-cache',
      '-H', 'dnt: 1',
      '-H', 'upgrade-insecure-requests: 1',
      '-H', 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
      '-H', 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
      '-H', 'sec-fetch-site: same-origin',
      '-H', 'sec-fetch-mode: navigate',
      '-H', 'sec-fetch-user: ?1',
      '-H', 'sec-fetch-dest: document',
      '-H', 'referer: https://forvo.com',
      '-H', 'accept-language: en-US,en;q=0.9,ny;q=0.8,ja;q=0.7,es;q=0.6'
    }
  end

  local result = utils.subprocess({ args = args, cancellable = true, capture_stderr = true })
  dlog(result.stdout)
  dlog(result.stderr)

  local audio_url
  for thing in string.match(result.stdout, "Play(.-)span"):gmatch("[^']+") do
    local url_part = b64dec(thing)
    if string.match(url_part, 'mp3$') then
      audio_url = 'https://audio00.forvo.com/mp3/' .. url_part
      break
    end
  end

  if platform == 'windows' then
    args = {
      'powershell', '-NoProfile', '-Command', [[& {
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Invoke-WebRequest -Uri "]] .. audio_url .. [[" -OutFile "]] .. utils.join_path(TEMP_DIR, "forvo_" .. word .. '.mp3') .. [["
    }]]
    }
  else
    args = {'curl', audio_url, '-o',  utils.join_path(TEMP_DIR, "forvo_" .. word .. '.mp3')}
  end

  utils.subprocess({ args = args, cancellable = true, capture_stderr = true })
  dlog(result.stdout)
  dlog(result.stderr)

  clean_audio(utils.join_path(TEMP_DIR, "forvo_" .. word .. '.mp3'))
  return utils.join_path(TEMP_DIR, "forvo_" .. word .. '.mp3')
end

local function b64enc(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r,f='',string.byte(x)-1
    for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
    return r;
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then return '' end
    local c=0
    for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
    return string.char(c);
  end)..string.rep('=',(3-data:len()%3)%3)))
end

local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  return content
end

local function add_to_last_added(img_path, audio_path, tfield)
  local forvo_path = nil
  local added_notes_result = anki_connect('findNotes', {query='added:1'})
  msg.info("findNotes result: " .. utils.to_string(added_notes_result))
  local added_notes = added_notes_result and added_notes_result["result"]

  table.sort(added_notes)
  if not added_notes or #added_notes == 0 then
    mp.osd_message("ERR! No notes found", 3)
    return nil
  end
  local noteid = added_notes[#added_notes]
  msg.info("Last note ID: " .. tostring(noteid))

  local note_result = anki_connect('notesInfo', {notes={noteid}})
  msg.info("notesInfo result: " .. utils.to_string(note_result))
  local note = note_result and note_result["result"]

  if not note or #note == 0 then
    mp.osd_message("ERR! Could not fetch note", 3)
    return nil
  end

  local word = note[1]["fields"][FRONT_FIELD] and note[1]["fields"][FRONT_FIELD]["value"] or "unknown"
  msg.info("Word: " .. tostring(word))
  local new_fields = {}

  -- Upload media via storeMediaFile and get the filenames Anki assigned
  if audio_path then
    local fname = audio_path:match("([^/]+)$")
    local audio_data = read_file(audio_path)
    if audio_data and #audio_data > 0 then
      msg.info("Audio size: " .. #audio_data .. " bytes")
      local resp = anki_connect_media('storeMediaFile', {filename=fname, data=audio_path})
      msg.info("storeMediaFile audio result: " .. utils.to_string(resp))
      if resp and (resp["result"] or resp["error"]) then
        if resp["error"] then
          msg.error("Audio store error: " .. tostring(resp["error"]))
        elseif resp["result"] then
          new_fields[SENTENCE_AUDIO_FIELD] = "[sound:" .. resp["result"] .. "]"
          msg.info("Audio stored as: " .. resp["result"])
        end
      else
        mp.osd_message("WARN! Audio upload failed", 3)
      end
    end
  end

  if img_path then
    local fname = img_path:match("([^/]+)$")
    local img_data = read_file(img_path)
    if img_data and #img_data > 0 then
      msg.info("Image size: " .. #img_data .. " bytes")
      local resp = anki_connect_media('storeMediaFile', {filename=fname, data=img_path})
      msg.info("storeMediaFile img result: " .. utils.to_string(resp))
      if resp and (resp["result"] or resp["error"]) then
        if resp["error"] then
          msg.error("Image store error: " .. tostring(resp["error"]))
        elseif resp["result"] then
          new_fields[IMAGE_FIELD] = '<img src=' .. resp["result"] .. '>'
          msg.info("Image stored as: " .. resp["result"])
        end
      else
        mp.osd_message("WARN! Image upload failed", 3)
      end
    end
  end

  new_fields[SENTENCE_FIELD] = tfield

  if WORD_AUDIO_FIELD ~= "" then
    local wafield = note[1]["fields"][WORD_AUDIO_FIELD]["value"]
    if wafield == "" then
      local success, res = pcall(get_forvo_audio, word)
      if success then
        forvo_path = res
        new_fields[WORD_AUDIO_FIELD] = "[sound:forvo_" .. word .. ".mp3]"
      end
    end
  end

  msg.info("Updating note fields: " .. utils.to_string(new_fields))
  local update_result = anki_connect_media('updateNoteFields', {
    note={
      id=noteid,
      fields=new_fields
    }
  })
  msg.info("updateNoteFields result: " .. utils.to_string(update_result))

  if not update_result or not update_result["_success"] then
    local err = update_result and update_result["error"] or "No response"
    mp.osd_message("ERR! Failed to update note: " .. tostring(err), 3)
    return nil
  end

  mp.osd_message("Card updated: " .. word, 3)
  msg.info("Updated note: " .. word)
  mp.set_property('pause', 'no')
  return forvo_path
end

local function get_sub_times(lines)
  local e = 0
  local s = 0
  for raw_line in lines:gmatch("[^\r\n]+") do
    local line = clean(raw_line)
    dlog(line)
    if subs[line] ~= nil then
      if subs[line][1] ~= nil and subs[line][2] ~= nil then
        if s == 0 then
          s = subs[line][1]
        else
          s = math.min(s, subs[line][1])
        end
        e = math.max(e, subs[line][2])
      end
    else
      mp.osd_message("ERR! Line not found: " .. line, 3)
      return nil, nil
    end
  end
  dlog(string.format('s=%d, e=%d', s, e))
  if e ~= 0 then
    return s, e
  end
  return nil, nil
end

local function get_extract()
  local lines = get_clipboard()
  local s, e = get_sub_times(lines)
  if not s or not e then return end

  mp.osd_message("Capturing media...", 3)
  
  local time_pos = (s + e) / 2
  local source = mp.get_property("path") or ""
  local script_dir = "/home/mortal/.config/mpv/scripts"
  local python_script = utils.join_path(script_dir, "anki_media_helper.py")

  -- Get note ID first
  local added_notes_result = anki_connect('findNotes', {query='added:1'})
  local added_notes = added_notes_result and added_notes_result["result"]
  if not added_notes or #added_notes == 0 then
    mp.osd_message("ERR! No notes found", 3)
    return
  end
  
  local noteid = added_notes[#added_notes]

  -- Single Python call handles ffmpeg + AnkiConnect internally
  local cmd = string.format(
    'python3 -u "%s" extract_and_update %d %.3f "%s"',
    python_script, noteid, time_pos, source
  )
  
  msg.info("Running: " .. cmd)

  local result = utils.subprocess({ args = {'bash', '-c', cmd}, cancellable = true, capture_stderr = true })
  
  dlog("Python response: '" .. (result.stdout or "") .. "'")
  if result.stderr and #result.stderr > 0 then
    msg.info("Python stderr:\n" .. result.stderr)
  end

  local resp = utils.parse_json(result.stdout or '{}')
  if not resp then
    mp.osd_message("ERR! Failed to parse response", 3)
    return
  end
  
  local audio_ok = resp["audio"] == true
  local img_ok = resp["image"] == true
  local updated = resp["updated"] == true
  local error_msg = resp["error"] or ""

  if not audio_ok and not img_ok then
    mp.osd_message("ERR! Capture failed: " .. error_msg, 5)
  elseif updated then
    local word = note[1]["fields"][FRONT_FIELD] and note[1]["fields"][FRONT_FIELD]["value"] or "unknown"
    mp.osd_message(string.format("Updated: %s (audio=%s img=%s)", word, audio_ok and "yes" or "no", img_ok and "yes" or "no"), 3)
  else
    mp.osd_message("ERR! Update failed: " .. error_msg, 5)
  end
  
  -- Resume playback after capture completes
  mp.set_property('pause', 'no')
end

local function extract_from_current_time()
  local time_pos = mp.get_property_number("time-pos")
  if not time_pos then
    mp.osd_message("ERR! Could not get current time", 3)
    return
  end
  
  mp.osd_message("Capturing media...", 3)

  local source = mp.get_property("path") or ""
  local script_dir = "/home/mortal/.config/mpv/scripts"
  local python_script = utils.join_path(script_dir, "anki_media_helper.py")

  -- Get note ID first
  local added_notes_result = anki_connect('findNotes', {query='added:1'})
  local added_notes = added_notes_result and added_notes_result["result"]
  if not added_notes or #added_notes == 0 then
    mp.osd_message("ERR! No notes found", 3)
    return
  end
  
  local noteid = added_notes[#added_notes]

  -- Single Python call handles ffmpeg + AnkiConnect internally
  local cmd = string.format(
    'python3 -u "%s" extract_and_update %d %.3f "%s"',
    python_script, noteid, time_pos, source
  )
  
  msg.info("Running: " .. cmd)

  local result = utils.subprocess({ args = {'bash', '-c', cmd}, cancellable = true, capture_stderr = true })
  
  dlog("Python response: '" .. (result.stdout or "") .. "'")
  if result.stderr and #result.stderr > 0 then
    msg.info("Python stderr:\n" .. result.stderr)
  end

  local resp = utils.parse_json(result.stdout or '{}')
  if not resp then
    mp.osd_message("ERR! Failed to parse response", 3)
    return
  end
  
  local audio_ok = resp["audio"] == true
  local img_ok = resp["image"] == true
  local updated = resp["updated"] == true
  local error_msg = resp["error"] or ""

  if not audio_ok and not img_ok then
    mp.osd_message("ERR! Capture failed: " .. error_msg, 5)
  elseif updated then
    mp.osd_message(string.format("Updated (audio=%s img=%s)", audio_ok and "yes" or "no", img_ok and "yes" or "no"), 3)
  else
    mp.osd_message("ERR! Update failed: " .. error_msg, 5)
  end
  
  -- Resume playback after capture completes
  mp.set_property('pause', 'no')
end

local function ex()
  if debug_mode then
    get_extract()
  else
    pcall(get_extract)
  end
end

local function ex_current_time()
  extract_from_current_time()
end

local function rec(...)
  if debug_mode then
    record_sub(...)
  else
    pcall(record_sub, ...)
  end
end

local function toggle_sub_to_clipboard()
  enable_subs_to_clip = not enable_subs_to_clip
  mp.osd_message("Clipboard inserter " .. (enable_subs_to_clip and "activated" or "deactived"), 3)
end

local function toggle_debug_mode()
  debug_mode = not debug_mode
  mp.osd_message("Debug mode " .. (debug_mode and "activated" or "deactived"), 3)
end

local function clear_subs(_)
  subs = {}
end

local last_clipboard_sub = nil

local function check_and_copy_sub()
  local sub_start = mp.get_property_number('sub-start')
  local sub_end = mp.get_property_number('sub-end')
  local text = mp.get_property('sub-text')

  if not text or text == '' then
    last_clipboard_sub = nil
    return
  end

  if not (sub_start and sub_end) then
    return
  end

  local time_pos = mp.get_property_number('time-pos')
  if time_pos >= sub_start and time_pos <= sub_end then
    local newtext = clean(text)
    if newtext == '' or newtext == last_clipboard_sub then
      return
    end

    last_clipboard_sub = newtext
    dlog(string.format("%s -> %s : %s", sub_start, sub_end, newtext))

    if enable_subs_to_clip then
      text = string.gsub(text, "[\n\r]+", " ")
      set_clipboard(text)
    end
  else
    last_clipboard_sub = nil
  end
end

mp.observe_property("time-pos", "number", function(_, val)
  if val ~= nil then
    pcall(check_and_copy_sub)
  end
end)

mp.observe_property("filename", "string", clear_subs)

mp.add_key_binding("ctrl+v", "update-anki-card", ex_current_time)
mp.add_key_binding("ctrl+t", "toggle-clipboard-insertion", toggle_sub_to_clipboard)
mp.add_key_binding("ctrl+d", "toggle-debug-mode", toggle_debug_mode)
mp.add_key_binding("ctrl+V", ex_current_time)
mp.add_key_binding("ctrl+T", toggle_sub_to_clipboard)
mp.add_key_binding("ctrl+D", toggle_debug_mode)
