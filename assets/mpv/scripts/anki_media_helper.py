#!/usr/bin/env python3
import sys, json, os, base64, subprocess, time
import requests

TEMP_DIR = "/tmp/mpv-animecards"
AUDIO_CLIP_PADDING = 1.5
IMAGE_FORMAT = "webp"

def anki_connect(action, params):
    payload = json.dumps({"action": action, "params": params, "version": 6}, ensure_ascii=False).encode('utf-8')
    try:
        r = requests.post('http://localhost:8765', data=payload, headers={'Content-Type': 'application/json; charset=utf-8'})
        resp = r.json()
        sys.stderr.write(f"AnkiConnect {action}: {resp}\n")
        sys.stderr.flush()
        return resp
    except Exception as e:
        sys.stderr.write(f"AnkiConnect error: {e}\n")
        sys.stderr.flush()
        return {"error": str(e)}

def create_audio(source, start_time, end_time):
    name = f"clip_{start_time:.3f}_{end_time:.3f}"
    dest = os.path.join(TEMP_DIR, name + ".mp3")
    
    s = start_time - AUDIO_CLIP_PADDING
    t = end_time - s + AUDIO_CLIP_PADDING
    
    cmd = [
        'ffmpeg', '-y', '-ss', f'{s:.3f}', '-i', source,
        '-t', f'{t:.3f}',
        '-vn', '-ac', '1', '-ar', '48000',
        '-af', f'afade=t=in:st=0:d=0.1,afade=t=out:st={t-0.1}:d=0.1',
        dest
    ]
    
    sys.stderr.write(f"ffmpeg audio: {' '.join(cmd)}\n")
    sys.stderr.flush()
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(f"ffmpeg audio error (rc={result.returncode}): {result.stderr[:500]}\n")
    elif os.path.exists(dest):
        size = os.path.getsize(dest)
        sys.stderr.write(f"ffmpeg audio created file ({size} bytes)\n")
    
    for _ in range(60):
        if os.path.exists(dest) and os.path.getsize(dest) > 0:
            return dest
        time.sleep(1)
    sys.stderr.write(f"Audio capture failed - no file or empty at {dest}\n")
    return None

def create_screenshot(source, time_pos):
    name = f"clip_{time_pos:.3f}_{time_pos+AUDIO_CLIP_PADDING*2:.3f}"
    img_path = os.path.join(TEMP_DIR, name + "." + IMAGE_FORMAT)
    
    cmd = ['ffmpeg', '-y', '-ss', f'{time_pos:.3f}', '-i', source, '-frames:v', '1']
    if IMAGE_FORMAT == 'webp':
        cmd.extend(['-vf', 'scale=480*iw*sar/ih:480', '-vcodec', 'libwebp', 
                     '-lossless', '0', '-compression_level', '6', '-preset', 'drawing'])
    elif IMAGE_FORMAT == 'png':
        cmd.extend(['-vf', 'format=rgb24,scale=480*iw*sar/ih:480'])
    cmd.append(img_path)
    
    sys.stderr.write(f"ffmpeg img: {' '.join(cmd)}\n")
    sys.stderr.flush()
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(f"ffmpeg img error (rc={result.returncode}): {result.stderr[:500]}\n")
    elif os.path.exists(img_path):
        size = os.path.getsize(img_path)
        sys.stderr.write(f"ffmpeg img created file ({size} bytes)\n")
    
    for _ in range(30):
        if os.path.exists(img_path) and os.path.getsize(img_path) > 0:
            return img_path
        time.sleep(1)
    sys.stderr.write(f"Image capture failed - no file or empty at {img_path}\n")
    return None

def store_media(filename, raw_file):
    with open(raw_file, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('ascii')
    resp = anki_connect('storeMediaFile', {"filename": filename, "data": b64})
    return json.dumps(resp)

def update_note_fields(noteid, fields):
    sys.stderr.write(f"Updating note {noteid} with fields: {json.dumps(fields)}\n")
    sys.stderr.flush()
    
    resp = anki_connect('updateNoteFields', {"note": {"id": noteid, "fields": fields}})
    
    if isinstance(resp, dict):
        err = resp.get('error')
        if isinstance(err, str) and len(err) > 0:
            sys.stderr.write(f"AnkiConnect error: {err}\n")
            sys.stderr.flush()
            return json.dumps({"_success": False, "error": err})
    
    sys.stderr.write("Update succeeded\n")
    sys.stderr.flush()
    return json.dumps({"_success": True})

def extract_and_update(noteid, time_pos, source):
    """Full capture + update pipeline."""
    sys.stderr.write(f"\n=== Extracting from time {time_pos:.3f} ===\n")
    sys.stderr.flush()
    
    s = time_pos - AUDIO_CLIP_PADDING
    e = time_pos + AUDIO_CLIP_PADDING
    
    # Capture audio first (more likely to fail)
    audio_path = create_audio(source, s, e)
    if not audio_path:
        sys.stderr.write("WARNING: Audio capture failed, continuing with image only\n")
    
    # Capture screenshot
    img_path = create_screenshot(source, time_pos)
    if not img_path:
        sys.stderr.write("WARNING: Image capture failed\n")
    
    fields_to_update = {}
    
    # Upload and update audio
    if audio_path:
        fname = os.path.basename(audio_path)
        resp = store_media(fname, audio_path)
        parsed = json.loads(resp)
        if isinstance(parsed, dict) and 'result' in parsed and parsed['result']:
            fields_to_update['SentenceAudio'] = f"[sound:{parsed['result']}]"
            sys.stderr.write(f"Audio stored: {parsed['result']}\n")
    
    # Upload and update image
    if img_path:
        fname = os.path.basename(img_path)
        resp = store_media(fname, img_path)
        parsed = json.loads(resp)
        if isinstance(parsed, dict) and 'result' in parsed and parsed['result']:
            fields_to_update['Picture'] = f'<img src={parsed["result"]}>'
            sys.stderr.write(f"Image stored: {parsed['result']}\n")
    
    # Update note with collected media references
    if fields_to_update:
        update_result = json.loads(update_note_fields(noteid, fields_to_update))
        success = update_result.get('_success', False)
        error = update_result.get('error', '')
        
        sys.stderr.write(f"Update result: {update_result}\n")
        return json.dumps({
            "audio": audio_path is not None,
            "image": img_path is not None,
            "updated": success,
            "error": error if not success else None
        })
    else:
        return json.dumps({"audio": False, "image": False, "updated": False, 
                          "error": "No media captured to upload"})

if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    
    if cmd == 'storeMediaFile' and len(sys.argv) >= 4:
        print(store_media(sys.argv[2], sys.argv[3]))
    elif cmd == 'updateNoteFields' and len(sys.argv) >= 4:
        noteid = int(sys.argv[2])
        fields = json.loads(sys.argv[3])
        print(update_note_fields(noteid, fields))
    elif cmd == 'extract_and_update' and len(sys.argv) >= 5:
        noteid = int(sys.argv[2])
        time_pos = float(sys.argv[3])
        source = sys.argv[4] if len(sys.argv) > 4 else None
        
        if not source:
            print(json.dumps({"error": "No video file specified"}))
        else:
            print(extract_and_update(noteid, time_pos, source))
