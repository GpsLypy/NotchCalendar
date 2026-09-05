const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const sharp = require('sharp');
const ROOT=__dirname, WORK=path.join(ROOT,'work'), SCENES=path.join(WORK,'scenes'), VOICE=path.join(WORK,'voice'), SUBTITLES=path.join(WORK,'subtitles'), SEGMENTS=path.join(WORK,'segments'), OUTPUT=path.join(ROOT,'output');
const FFMPEG=process.env.FFMPEG || '/Applications/Downie 4.app/Contents/Resources/ffmpeg';
const WIDTH=1080, HEIGHT=1920, FPS=30, APP_VERSION='0.6.0', SCENE_COUNT=12;
const INTRO_GAP=1.0, OUTRO_GAP=2.2, INTER_LINE_GAP=0.2;
const C={ink:'#070708',panel:'#131316',panel2:'#1A1A20',coral:'#F43B5B',coralSoft:'#FF8297',white:'#F7F4F6',muted:'#ADA5AC',line:'#343039',green:'#66D694',blue:'#78AFFF'};
const fontSans="'PingFang SC', 'Hiragino Sans GB', sans-serif", fontMono="'SF Mono','Menlo',monospace";
const titles=JSON.parse(fs.readFileSync(path.join(ROOT,'scene-titles.json')));
function captionWrap(s){let out=[],line='',units=0;for(const ch of s){let n=/[\x00-\xff]/.test(ch)?0.55:1;if(units+n>23){out.push(line);line='';units=0;}line+=ch;units+=n;}if(line)out.push(line);return out.join('\n');}
const narration=JSON.parse(fs.readFileSync(path.join(ROOT,'narration.json'))).map(x=>({...x,caption:captionWrap(x.caption)}));
function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    stdio: options.capture ? ['ignore', 'pipe', 'pipe'] : 'inherit',
    encoding: options.capture ? 'utf8' : undefined,
    ...options,
  });
  if (result.status !== 0) {
    const detail = options.capture ? `\n${result.stdout || ''}\n${result.stderr || ''}` : '';
    throw new Error(`${command} failed with exit code ${result.status}${detail}`);
  }
  return result;
}

function cleanAndCreate(directory) {
  fs.rmSync(directory, { recursive: true, force: true });
  fs.mkdirSync(directory, { recursive: true });
}

function escapeXml(value) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function dataUri(file) {
  const ext = path.extname(file).toLowerCase();
  const mime = ext === '.jpg' || ext === '.jpeg' ? 'image/jpeg' : 'image/png';
  return `data:${mime};base64,${fs.readFileSync(file).toString('base64')}`;
}


function parseAudioDuration(file) {
  const result = run('/usr/bin/afinfo', [file], { capture: true });
  const match = `${result.stdout}\n${result.stderr}`.match(/estimated duration:\s+([0-9.]+) sec/);
  if (!match) throw new Error(`Unable to determine audio duration: ${file}`);
  return Number(match[1]);
}


function formatSrtTime(seconds) {
  const ms = Math.max(0, Math.round(seconds * 1000));
  const hours = Math.floor(ms / 3600000);
  const minutes = Math.floor((ms % 3600000) / 60000);
  const secs = Math.floor((ms % 60000) / 1000);
  const millis = ms % 1000;
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')},${String(millis).padStart(3, '0')}`;
}

function renderSubtitleSvg(caption) {
  const rows = caption.split('\n');
  const longestRow = Math.max(...rows.map((row) => [...row].reduce(
    (units, character) => units + (/^[\u0000-\u00ff]$/.test(character) ? 0.58 : 1),
    0
  )));
  const fontSize = Math.max(34, Math.min(41, Math.floor(820 / Math.max(1, longestRow))));
  const boxHeight = rows.length > 1 ? rows.length * 54 + 48 : 108;
  const top = Math.round((220 - boxHeight) / 2);
  const textStart = rows.length > 1 ? top + 57 : top + 68;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="220" viewBox="0 0 1080 220">
    <defs><filter id="s"><feDropShadow dx="0" dy="8" stdDeviation="12" flood-color="#000" flood-opacity=".55"/></filter></defs>
    <rect x="88" y="${top}" width="854" height="${boxHeight}" rx="34" fill="#060607" fill-opacity=".88" stroke="#3B333A" stroke-opacity=".92" filter="url(#s)"/>
    <rect x="88" y="${top + 28}" width="5" height="${boxHeight - 56}" rx="2.5" fill="${C.coral}"/>
    ${rows.map((row, index) => `<text x="515" y="${textStart + index * 54}" fill="${C.white}" font-family="${fontSans}" font-size="${fontSize}" font-weight="650" text-anchor="middle">${escapeXml(row)}</text>`).join('')}
  </svg>`;
}

function createSilentWav(file, duration) {
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y',
    '-f', 'lavfi', '-i', 'anullsrc=r=48000:cl=mono',
    '-t', duration.toFixed(3), '-c:a', 'pcm_s16le', file,
  ]);
}


function writeWav(file, samples, sampleRate = 48000, channels = 2) {
  const bytesPerSample = 2;
  const dataSize = samples.length * bytesPerSample;
  const buffer = Buffer.allocUnsafe(44 + dataSize);
  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write('WAVE', 8);
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(channels, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * channels * bytesPerSample, 28);
  buffer.writeUInt16LE(channels * bytesPerSample, 32);
  buffer.writeUInt16LE(bytesPerSample * 8, 34);
  buffer.write('data', 36);
  buffer.writeUInt32LE(dataSize, 40);
  for (let i = 0; i < samples.length; i += 1) {
    const value = Math.max(-1, Math.min(1, samples[i]));
    buffer.writeInt16LE(Math.round(value * 32767), 44 + i * 2);
  }
  fs.writeFileSync(file, buffer);
}

function synthesizeMusic(file, duration, sceneStarts) {
  console.log('[3/9] Synthesizing an original ambient soundtrack…');
  const sampleRate = 48000;
  const frames = Math.ceil(duration * sampleRate);
  const out = new Float32Array(frames * 2);
  const bpm = 76;
  const beatRate = bpm / 60;
  const chords = [
    [174.61, 220.00, 261.63, 329.63], // Fmaj7
    [220.00, 261.63, 329.63, 392.00], // Am7
    [130.81, 196.00, 246.94, 329.63], // Cmaj7
    [196.00, 220.00, 293.66, 392.00], // Gsus2
  ];
  const chordBeats = 8;
  const chimeTimes = sceneStarts.slice(1);
  let noiseState = 0x13579BDF;

  const pseudoNoise = () => {
    noiseState ^= noiseState << 13;
    noiseState ^= noiseState >>> 17;
    noiseState ^= noiseState << 5;
    return ((noiseState >>> 0) / 0xFFFFFFFF) * 2 - 1;
  };

  for (let i = 0; i < frames; i += 1) {
    const t = i / sampleRate;
    const beat = t * beatRate;
    const chordPosition = beat / chordBeats;
    const chordIndex = Math.floor(chordPosition) % chords.length;
    const nextChordIndex = (chordIndex + 1) % chords.length;
    const localChord = chordPosition - Math.floor(chordPosition);
    const blend = localChord > 0.84 ? (localChord - 0.84) / 0.16 : 0;
    const smoothBlend = blend * blend * (3 - 2 * blend);
    let left = 0;
    let right = 0;

    for (let n = 0; n < 4; n += 1) {
      const f1 = chords[chordIndex][n];
      const f2 = chords[nextChordIndex][n];
      const level = 0.023 / (1 + n * 0.16);
      const lfo = 1 + 0.0025 * Math.sin(2 * Math.PI * (0.07 + n * 0.013) * t);
      const phaseL1 = 2 * Math.PI * f1 * lfo * t + n * 0.71;
      const phaseR1 = 2 * Math.PI * f1 * (2 - lfo) * t + n * 0.71 + 0.12;
      const phaseL2 = 2 * Math.PI * f2 * lfo * t + n * 0.53;
      const phaseR2 = 2 * Math.PI * f2 * (2 - lfo) * t + n * 0.53 + 0.12;
      left += level * ((1 - smoothBlend) * Math.sin(phaseL1) + smoothBlend * Math.sin(phaseL2));
      right += level * ((1 - smoothBlend) * Math.sin(phaseR1) + smoothBlend * Math.sin(phaseR2));
    }

    const beatIndex = Math.floor(beat * 2);
    const halfBeatPhase = beat * 2 - beatIndex;
    const arpChord = chords[chordIndex];
    const arpFreq = arpChord[(beatIndex + chordIndex) % arpChord.length] * 2;
    const pluckEnv = Math.exp(-5.8 * halfBeatPhase);
    const pluck = (Math.sin(2 * Math.PI * arpFreq * t) + 0.28 * Math.sin(2 * Math.PI * arpFreq * 2 * t)) * 0.018 * pluckEnv;
    const pan = 0.5 + 0.34 * Math.sin(beatIndex * 1.7);
    left += pluck * (1 - pan) * 1.5;
    right += pluck * pan * 1.5;

    const downbeatPhase = beat - Math.floor(beat);
    if (Math.floor(beat) % 4 === 0 && downbeatPhase < 0.32) {
      const kickEnv = Math.exp(-13 * downbeatPhase);
      const kickFreq = 64 - 24 * downbeatPhase;
      const kick = Math.sin(2 * Math.PI * kickFreq * t) * 0.035 * kickEnv;
      left += kick;
      right += kick;
    }

    const offbeat = (beat + 0.5) - Math.floor(beat + 0.5);
    if (offbeat < 0.08) {
      const hat = pseudoNoise() * Math.exp(-45 * offbeat) * 0.004;
      left += hat;
      right -= hat * 0.7;
    }

    for (const start of chimeTimes) {
      const dt = t - start;
      if (dt >= 0 && dt < 1.8) {
        const env = Math.exp(-2.4 * dt) * Math.sin(Math.PI * Math.min(1, dt / 0.05));
        const chime = (Math.sin(2 * Math.PI * 880 * dt) + 0.45 * Math.sin(2 * Math.PI * 1320 * dt)) * 0.018 * env;
        left += chime * 0.65;
        right += chime;
      }
    }

    const fade = Math.min(1, t / 2.2, (duration - t) / 3.2);
    const breathe = 0.86 + 0.14 * Math.sin(2 * Math.PI * 0.028 * t);
    out[i * 2] = left * fade * breathe;
    out[i * 2 + 1] = right * fade * breathe;
  }

  writeWav(file, out, sampleRate, 2);
}

function sceneTiming(timeline, totalDuration) {
  const result = [];
  for (let scene = 1; scene <= SCENE_COUNT; scene += 1) {
    const items = timeline.filter((item) => item.scene === scene);
    const start = scene === 1 ? 0 : items[0].start - 0.18;
    const next = timeline.find((item) => item.scene === scene + 1);
    const end = next ? next.start - 0.18 : totalDuration;
    result.push({ scene, start, end, duration: end - start });
  }
  return result;
}

function renderSceneSegments(timings) {
  console.log('[4/9] Animating scenes with subtle vertical motion…');
  timings.forEach((item) => {
    const input = path.join(SCENES, `scene-${String(item.scene).padStart(2, '0')}.png`);
    const output = path.join(SEGMENTS, `scene-${String(item.scene).padStart(2, '0')}.mp4`);
    const frames = Math.max(1, Math.round(item.duration * FPS));
    const zoomDirection = item.scene % 2 === 0 ? -1 : 1;
    const zoomExpr = zoomDirection > 0
      ? `1.012+0.032*on/${frames}`
      : `1.044-0.032*on/${frames}`;
    const fadeOutStart = Math.max(0, item.duration - 0.36).toFixed(3);
    const filters = [
      `zoompan=z='${zoomExpr}':x='iw/2-(iw/zoom/2)+6*sin(on/95)':y='ih/2-(ih/zoom/2)+5*cos(on/110)':d=1:s=${WIDTH}x${HEIGHT}:fps=${FPS}`,
      'format=yuv420p',
      'fade=t=in:st=0:d=0.30',
      `fade=t=out:st=${fadeOutStart}:d=0.36`,
    ].join(',');
    run(FFMPEG, [
      '-hide_banner', '-loglevel', 'error', '-y',
      '-loop', '1', '-framerate', String(FPS), '-i', input,
      '-t', item.duration.toFixed(3), '-vf', filters,
      '-an', '-c:v', 'h264_videotoolbox', '-b:v', '7000k', '-maxrate', '8500k',
      '-pix_fmt', 'yuv420p', '-r', String(FPS), '-g', String(FPS * 2), output,
    ]);
  });

  const concatFile = path.join(WORK, 'video-concat.txt');
  fs.writeFileSync(concatFile, `${timings.map((item) => `file '${path.join(SEGMENTS, `scene-${String(item.scene).padStart(2, '0')}.mp4`)}'`).join('\n')}\n`);
  const baseVideo = path.join(WORK, 'base-video.mp4');
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y',
    '-f', 'concat', '-safe', '0', '-i', concatFile,
    '-c', 'copy', '-movflags', '+faststart', baseVideo,
  ]);
  return baseVideo;
}


function mixAudio(voiceMaster, musicFile, totalDuration) {
  console.log('[6/9] Mixing voice, music ducking, and platform loudness…');
  const mixedAudio = path.join(WORK, 'mixed-audio.m4a');
  const filter = [
    `[0:a]atrim=0:${totalDuration.toFixed(3)},volume=0.19,afade=t=in:st=0:d=2.2,afade=t=out:st=${Math.max(0, totalDuration - 3.2).toFixed(3)}:d=3.2[music]`,
    '[1:a]aformat=sample_rates=48000:channel_layouts=stereo,highpass=f=75,lowpass=f=11000,volume=1.08,asplit=2[voice][sidechain]',
    '[music][sidechain]sidechaincompress=threshold=0.018:ratio=8:attack=18:release=360[ducked]',
    '[ducked][voice]amix=inputs=2:duration=longest:dropout_transition=0,loudnorm=I=-14:TP=-1.2:LRA=8[out]',
  ].join(';');
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', musicFile, '-i', voiceMaster,
    '-filter_complex', filter, '-map', '[out]',
    '-c:a', 'aac_at', '-b:a', '192k', '-ar', '48000', mixedAudio,
  ]);
  return mixedAudio;
}

function composeFinal(baseVideo, subtitleLayer, mixedAudio, totalDuration) {
  console.log('[7/9] Burning subtitles and encoding the social master…');
  const finalVideo = path.join(OUTPUT, `notch-calendar-v${APP_VERSION}-xhs-douyin-3min.mp4`);
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', baseVideo, '-i', subtitleLayer, '-i', mixedAudio,
    '-filter_complex', '[0:v][1:v]overlay=0:1450:format=auto,format=yuv420p[v]',
    '-map', '[v]', '-map', '2:a:0', '-t', totalDuration.toFixed(3),
    '-c:v', 'h264_videotoolbox', '-b:v', '6200k', '-maxrate', '8000k', '-bufsize', '16000k',
    '-pix_fmt', 'yuv420p', '-r', String(FPS), '-g', String(FPS * 2),
    '-c:a', 'copy', '-movflags', '+faststart', finalVideo,
  ]);
  return finalVideo;
}


function validate(finalVideo, totalDuration) {
  console.log('[8/9] Validating the final MP4…');
  const metadata = run(FFMPEG, ['-hide_banner', '-i', finalVideo, '-f', 'null', '-'], { capture: true });
  const combined = `${metadata.stdout}\n${metadata.stderr}`;
  if (!combined.includes('1080x1920')) throw new Error('Validation failed: output is not 1080x1920');
  if (!combined.includes('Video: h264')) throw new Error('Validation failed: H.264 stream missing');
  if (!combined.includes('Audio: aac')) throw new Error('Validation failed: AAC stream missing');
  if (!combined.includes('yuv420p')) throw new Error('Validation failed: yuv420p missing');

  const stat = fs.statSync(finalVideo);
  const report = [
    '# 成片校验',
    '',
    `- 文件：${path.basename(finalVideo)}`,
    `- 预计时长：${totalDuration.toFixed(3)} 秒`,
    `- 文件大小：${(stat.size / 1024 / 1024).toFixed(1)} MB`,
    '- 视频：H.264，1080 × 1920，30 fps，yuv420p',
    '- 音频：AAC，48 kHz，192 kbps',
    '- 字幕：逐句烧录，并附独立 SRT',
    '- 视觉安全区：核心文案与字幕避开平台常用顶部、右侧和底部控件区',
    '',
  ].join('\n');
  fs.writeFileSync(path.join(OUTPUT, 'validation.md'), report);
}

async function exportCover(finalVideo, timings) {
  console.log('[9/9] Exporting the cover and preview frames…');
  const cover = path.join(OUTPUT, `notch-calendar-v${APP_VERSION}-video-cover.jpg`);
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y', '-i', path.join(SCENES, 'scene-01.png'),
    '-frames:v', '1', '-q:v', '2', cover,
  ]);
  const previewDir = path.join(OUTPUT, 'preview-frames');
  fs.mkdirSync(previewDir, { recursive: true });
  const stamps = timings.map((item) => Math.max(item.start + 0.8, Math.min(item.end - 0.8, item.start + item.duration * 0.5)));
  stamps.forEach((stamp, index) => {
    run(FFMPEG, [
      '-hide_banner', '-loglevel', 'error', '-y', '-ss', stamp.toFixed(3), '-i', finalVideo,
      '-frames:v', '1', '-q:v', '2', path.join(previewDir, `${String(index + 1).padStart(2, '0')}-${Math.round(stamp)}s.jpg`),
    ]);
  });
  run(FFMPEG, [
    '-hide_banner', '-loglevel', 'error', '-y',
    '-pattern_type', 'glob', '-i', path.join(previewDir, '[0-9][0-9]-*s.jpg'),
    '-vf', 'scale=270:480,tile=4x3:padding=8:margin=8:color=#111014',
    '-frames:v', '1', path.join(OUTPUT, 'preview-contact-sheet.jpg'),
  ]);
}


function text(x,y,s,size=30,color=C.white,weight=500){return `<text x="${x}" y="${y}" fill="${color}" font-size="${size}" font-weight="${weight}" font-family="${fontSans}">${escapeXml(s)}</text>`;}
function svg(body,w=WIDTH,h=HEIGHT){return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}"><rect width="100%" height="100%" fill="${C.ink}"/>${body}</svg>`;}
function shot(name,y=530){const p=path.join(ROOT,'assets',name+'.png');return `<rect x="46" y="${y}" width="988" height="665" rx="22" fill="${C.panel}" stroke="${C.line}"/><image href="${dataUri(p)}" x="56" y="${y+10}" width="968" height="645" preserveAspectRatio="xMidYMid meet"/>`;}
const sceneData=[
 ['好奇心，也值得一个入口','给工作留秩序，给发现留空间。',null,['三个新功能','0.6.0 · 本次构建']],
 ['日历之外，多一扇窗','八个直接入口，在同一个工作台。','briefing',['⌘6 自选行情','⌘7 舆论室','⌘8 信息差简报']],
 ['最多八项，留给真正关心的','自选代码 · 本地保存 · 手动刷新','markets',['添加与移除','调整自选顺序','来源与交易日期']],
 ['价格旁边，时间一样重要','Alpha Vantage · 个人 API Key','markets',['默认收盘行情，非实时','密钥保存在系统钥匙串','限流或断网保留旧内容']],
 ['看热度，也读真实声音','Hacker News 社区的有限讨论样本','discussion',['有作者 · 有原帖','有限评论，明确来源','点击话题，进入讨论']],
 ['读完别人的，留下自己的','私人立场与笔记，只存在本机。','discussion-detail',['我的立场','当时的判断','下次回来继续想']],
 ['信息差，从源头开始','公开一手资讯，不是神秘内幕。','briefing',['按来源阅读','按关键词寻找','保留发布或更新时间']],
 ['好内容，不必马上读完','收藏与已读，让发现有迹可循。','briefing-saved',['收藏待读','已读状态','原文入口']],
 ['看完世界，回到今天','日程依然在刘海旁，安静等你。',null,['停稳后展开 / 仅点击','不新增行情滚动条','信息页主动打开才看']],
 ['让想法，接上行动','记下来，然后安心专注一会儿。',null,['25 / 50 分钟专注 · 5 分钟休息','本地随手记','保持原有工作节奏']],
 ['断网，也有下一步','来源、缓存和失败状态，都说清楚。','briefing',['旧数据保留并标注','超时与限流反馈','个人数据不随资讯上传']],
 ['把一天，收进刘海旁','Notch Calendar · 0.6.0',null,['macOS 15+','行情需要个人密钥','合成配音 · 部分品牌概念画面']]
];
function sceneGraphic(i){
 const [title,sub,shotName,tags]=sceneData[i-1];
 if(i===1)return svg(`<image href="${dataUri(path.join(OUTPUT,'01-cover-concept.png'))}" x="0" y="0" width="1080" height="1440"/>${text(76,1754,'Notch Calendar · 0.6.0',26,C.muted)}`);
 let body=`<rect x="422" y="-28" width="236" height="100" rx="40" fill="#000"/>${text(60,120,'NOTCH CALENDAR',25,C.white,700)}${text(60,167,'0.6.0  /  个人工作台',20,C.muted)}${text(935,126,String(i).padStart(2,'0'),25,C.coralSoft,700)}`;
 const headlineParts=title.length>12?[title.slice(0,title.indexOf('，')>=0?title.indexOf('，')+1:10),title.slice(title.indexOf('，')>=0?title.indexOf('，')+1:10)]:[title];
 headlineParts.forEach((l,j)=>body+=text(60,304+j*84,l,62,C.white,750));
 body+=text(64,455,sub,26,C.muted);
 if(shotName)body+=shot(shotName);
 else if(i===10){body+=`<circle cx="540" cy="814" r="220" fill="${C.panel}" stroke="${C.line}" stroke-width="3"/><circle cx="540" cy="814" r="220" fill="none" stroke="${C.coral}" stroke-width="8" stroke-dasharray="1090 400" transform="rotate(-90 540 814)"/>${text(343,854,'25:00',120,C.white,650)}${text(422,945,'专注一会儿',30,C.muted)}${text(445,1130,'功能示意',21,C.muted)}`;}
 else {['日程','专注','发现'].forEach((s,j)=>{const x=94+j*308;body+=`<rect x="${x}" y="680" width="280" height="282" rx="42" fill="${C.panel}" stroke="${C.line}"/>${text(x+67,800,s,56,C.white,650)}${text(x+67,863,['看安排','做事情','读世界'][j],28,C.coralSoft)}`;});body+=text(225,1070,'每次主动打开，都有一个明确目的。',30,C.muted);}
 tags.forEach((s,j)=>body+=text(76,1268+j*56,'—  '+s,29,j===0?C.coralSoft:C.muted,500));
 body+=`<rect x="76" y="1450" width="928" height="3" fill="${C.line}"/><rect x="76" y="1450" width="${928*i/12}" height="3" fill="${C.coral}"/>${text(76,1790,shotName?'本版原生视图渲染 · 公开内容':'产品介绍 · 图形示意',21,C.muted)}`;
 return svg(body);
}
async function renderScenes(){for(let i=1;i<=12;i++){await sharp(Buffer.from(sceneGraphic(i))).png().toFile(path.join(SCENES,`scene-${String(i).padStart(2,'0')}.png`));}}
async function renderNarrationAndSubtitles(){
 // Decode first so timing comes from PCM samples, not MP3 estimates.
 let rawTotal=0;
 const originals=narration.map((item,index)=>{
  const raw=path.join(VOICE,`raw-${index}.wav`);
  run(FFMPEG,['-v','error','-y','-i',path.join(ROOT,'assets','voice',item.voiceFile),'-ar','48000','-ac','1','-c:a','pcm_s16le',raw]);
  const duration=parseAudioDuration(raw);rawTotal+=duration;return raw;
 });
 const tempo=rawTotal/(180-INTRO_GAP-OUTRO_GAP-INTER_LINE_GAP*(narration.length-1));
 if(tempo<0.7||tempo>1.45)throw Error(`Narration pace outside accepted bounds: ${tempo}`);
 console.log('Narration natural duration',rawTotal.toFixed(2),'tempo adjustment',tempo.toFixed(3));
 const timeline=[],concat=[],subtitleConcat=[];let cursor=INTRO_GAP;
 const blank=path.join(SUBTITLES,'blank.png');await sharp({create:{width:1080,height:220,channels:4,background:{r:0,g:0,b:0,alpha:0}}}).png().toFile(blank);
 for(const [name,duration] of [['intro',INTRO_GAP],['gap',INTER_LINE_GAP],['outro',OUTRO_GAP]])createSilentWav(path.join(VOICE,name+'.wav'),duration);
 concat.push(`file '${path.join(VOICE,'intro.wav')}'`);subtitleConcat.push(`file '${blank}'`,`duration ${INTRO_GAP}`);
 for(let index=0;index<narration.length;index++){
  const item=narration[index],stem=`line-${String(index+1).padStart(2,'0')}`,wav=path.join(VOICE,stem+'.wav');
  run(FFMPEG,['-v','error','-y','-i',originals[index],'-af',`atempo=${tempo}`,'-c:a','pcm_s16le',wav]);
  const duration=parseAudioDuration(wav),start=cursor,end=start+duration;
  timeline.push({...item,index:index+1,start,end,duration});cursor=end+INTER_LINE_GAP;
  const png=path.join(SUBTITLES,stem+'.png');await sharp(Buffer.from(renderSubtitleSvg(item.caption))).png().toFile(png);
  concat.push(`file '${wav}'`);subtitleConcat.push(`file '${png}'`,`duration ${duration}`);
  if(index<narration.length-1){concat.push(`file '${path.join(VOICE,'gap.wav')}'`);subtitleConcat.push(`file '${blank}'`,`duration ${INTER_LINE_GAP}`);}
 }
 const totalDuration=cursor-INTER_LINE_GAP+OUTRO_GAP;
 concat.push(`file '${path.join(VOICE,'outro.wav')}'`);subtitleConcat.push(`file '${blank}'`,`duration ${OUTRO_GAP}`,`file '${blank}'`);
 const cc=path.join(WORK,'voice-concat.txt'),sc=path.join(WORK,'subtitle-concat.txt');fs.writeFileSync(cc,concat.join('\n'));fs.writeFileSync(sc,subtitleConcat.join('\n'));
 const voiceMaster=path.join(OUTPUT,'notch-calendar-v0.6.0-voice.wav'),subtitleLayer=path.join(WORK,'subtitles.mov');
 run(FFMPEG,['-v','error','-y','-f','concat','-safe','0','-i',cc,'-c:a','pcm_s16le',voiceMaster]);
 run(FFMPEG,['-v','error','-y','-f','concat','-safe','0','-i',sc,'-vf',`fps=${FPS},format=argb`,'-c:v','qtrle',subtitleLayer]);
 fs.writeFileSync(path.join(OUTPUT,'notch-calendar-v0.6.0-3min.zh-Hans.srt'),timeline.map(x=>`${x.index}\n${formatSrtTime(x.start)} --> ${formatSrtTime(x.end)}\n${x.caption}\n`).join('\n'));
 fs.writeFileSync(path.join(OUTPUT,'timeline.json'),JSON.stringify({totalDuration,tempo,timeline},null,2));
 return {timeline,totalDuration,voiceMaster,subtitleLayer};
}
async function posters(){
 for(const [n,title,sub,name,lines] of [
  ['02-markets','只看真正关心的市场','自选行情 · 最多 8 项','markets',['自选代码 / 添加移除 / 调整顺序','个人 API Key 保存在钥匙串','默认收盘数据，非实时行情']],
  ['03-discussion','看讨论，也留自己的判断','舆论室 · Hacker News 社区样本','discussion-detail',['真实话题、署名评论与原帖','私人立场和笔记保存在本机','不把少量评论包装成全网意见']],
  ['04-briefing','信息差，从一手来源开始','信息差简报 · 公开原始资讯','briefing',['按来源筛选 / 关键词搜索','收藏与已读记录 / 打开原文','有限阅读列表，读完有出口']],
  ['05-saved','先留下，等有空再读','本地收藏 · 阅读记录','briefing-saved',['好内容收藏起来，下次接着读','断网保留已缓存的资讯','自己的阅读轨迹，留在自己的电脑']],
  ['06-overview','给好奇心留一个位置','Notch Calendar 0.6.0','briefing',['日历 · 专注 · 随手记 · 情报台','新增：自选行情 · 舆论室 · 简报','macOS 15+ / 行情需个人密钥']]
 ]){
  let b=`${text(62,100,'NOTCH CALENDAR  /  0.6.0',24,C.coralSoft,700)}${text(62,253,title,58,C.white,750)}${text(65,331,sub,29,C.muted)}${shot(name,446)}`;
  lines.forEach((l,i)=>b+=text(70,1230+i*72,l,33,i===0?C.white:C.muted));
  b+=text(70,1575,'本版原生视图渲染 · 公开内容 · AI 辅助制作',22,C.muted);
  await sharp(Buffer.from(svg(b,1080,1656))).resize(1242,1656,{fit:'fill'}).png().toFile(path.join(OUTPUT,n+'.png'));
 }
}
async function main(){
 for(const d of [WORK,SCENES,VOICE,SUBTITLES,SEGMENTS,OUTPUT])fs.mkdirSync(d,{recursive:true});
 await posters();await renderScenes();
 if(process.env.POSTERS_ONLY==='1')return;
 const {timeline,totalDuration,voiceMaster,subtitleLayer}=await renderNarrationAndSubtitles();
 const timings=sceneTiming(timeline,totalDuration),music=path.join(WORK,'ambient.wav');synthesizeMusic(music,totalDuration,timings.map(x=>x.start));
 const baseVideo=renderSceneSegments(timings),mixedAudio=mixAudio(voiceMaster,music,totalDuration);
 const finalVideo=composeFinal(baseVideo,subtitleLayer,mixedAudio,totalDuration);validate(finalVideo,totalDuration);await exportCover(finalVideo,timings);
 fs.writeFileSync(path.join(OUTPUT,'视频脚本.md'),'# Notch Calendar 0.6.0 中文介绍\n\n普通话合成配音：Xiaoxiao Neural。逐句字幕按实际音频对齐。\n\n'+timings.map(x=>`## ${formatSrtTime(x.start)} ${titles[x.scene-1]}\n\n`+timeline.filter(t=>t.scene===x.scene).map(t=>t.caption.replaceAll('\n','')).join('\n\n')).join('\n\n'));
 console.log('Complete',finalVideo,totalDuration);
}
main().catch(e=>{console.error(e);process.exitCode=1;});
