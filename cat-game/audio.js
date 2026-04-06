// ============================================
// AUDIO SYSTEM - Real Cat Sounds + Cartoon FX
// ============================================

const AudioCtx = window.AudioContext || window.webkitAudioContext;
let audioCtx;

function ensureAudio() {
  if (!audioCtx) audioCtx = new AudioCtx();
  if (audioCtx.state === 'suspended') audioCtx.resume();
}

// --- Helper: create noise buffer ---
function createNoiseBuffer(duration) {
  const ctx = audioCtx;
  const len = ctx.sampleRate * duration;
  const buf = ctx.createBuffer(1, len, ctx.sampleRate);
  const d = buf.getChannelData(0);
  for (let i = 0; i < len; i++) d[i] = Math.random() * 2 - 1;
  return buf;
}

// =============================================
// REAL CAT MEOW SOUNDS (from GitHub dataset)
// =============================================
const MEOW_URLS = [
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_1.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_2.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_3.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_1.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_2.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_3.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_5.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_8.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_10.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_15.wav',
];

// Audio buffers cache
const meowBuffers = [];
let meowsLoaded = false;

// Preload all meow sounds into AudioBuffers for instant playback
async function preloadMeows() {
  ensureAudio();
  const ctx = audioCtx;

  const loadPromises = MEOW_URLS.map(async (url, i) => {
    try {
      const resp = await fetch(url);
      const arrayBuf = await resp.arrayBuffer();
      const audioBuf = await ctx.decodeAudioData(arrayBuf);
      meowBuffers[i] = audioBuf;
    } catch (e) {
      console.warn('Failed to load meow:', url, e);
      meowBuffers[i] = null;
    }
  });

  await Promise.all(loadPromises);
  meowsLoaded = true;
  console.log(`Loaded ${meowBuffers.filter(b => b).length}/${MEOW_URLS.length} real cat meows`);
}

// Play a random REAL cat meow
function playMeow() {
  ensureAudio();
  const ctx = audioCtx;

  // Try real sound first
  const available = meowBuffers.filter(b => b);
  if (available.length > 0) {
    const buf = available[Math.floor(Math.random() * available.length)];
    const source = ctx.createBufferSource();
    source.buffer = buf;

    // Randomize pitch slightly for variety
    source.playbackRate.value = 0.85 + Math.random() * 0.35;

    const gain = ctx.createGain();
    gain.gain.value = 0.7;
    source.connect(gain).connect(ctx.destination);
    source.start();
    return;
  }

  // Fallback: synthesized meow
  playSynthMeow();
}

// Play a SCARED real cat meow (pitched up, louder)
function playScaredMeow() {
  ensureAudio();
  const ctx = audioCtx;

  const available = meowBuffers.filter(b => b);
  if (available.length > 0) {
    const buf = available[Math.floor(Math.random() * available.length)];
    const source = ctx.createBufferSource();
    source.buffer = buf;

    // Higher pitch = scared sound
    source.playbackRate.value = 1.4 + Math.random() * 0.5;

    const gain = ctx.createGain();
    gain.gain.value = 0.9;

    // Add slight distortion for intensity
    const compressor = ctx.createDynamicsCompressor();
    compressor.threshold.value = -20;
    compressor.knee.value = 10;
    compressor.ratio.value = 8;
    compressor.attack.value = 0;
    compressor.release.value = 0.1;

    source.connect(compressor).connect(gain).connect(ctx.destination);
    source.start();

    // Layer a second meow slightly delayed for "REOOW" effect
    setTimeout(() => {
      const buf2 = available[Math.floor(Math.random() * available.length)];
      const src2 = ctx.createBufferSource();
      src2.buffer = buf2;
      src2.playbackRate.value = 1.6 + Math.random() * 0.4;
      const g2 = ctx.createGain();
      g2.gain.value = 0.5;
      src2.connect(g2).connect(ctx.destination);
      src2.start();
    }, 80);
    return;
  }

  playSynthScaredMeow();
}

// =============================================
// SYNTHESIZED FALLBACKS (if WAVs fail to load)
// =============================================

function playSynthMeow() {
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const dur = 0.4 + Math.random() * 0.2;
  const base = 350 + Math.random() * 100;

  const master = ctx.createGain();
  master.gain.setValueAtTime(0, now);
  master.gain.linearRampToValueAtTime(0.4, now + 0.04);
  master.gain.setValueAtTime(0.4, now + dur * 0.3);
  master.gain.exponentialRampToValueAtTime(0.01, now + dur);
  master.connect(ctx.destination);

  const v = ctx.createOscillator();
  v.type = 'sawtooth';
  v.frequency.setValueAtTime(base * 0.8, now);
  v.frequency.linearRampToValueAtTime(base * 1.5, now + dur * 0.15);
  v.frequency.linearRampToValueAtTime(base * 0.9, now + dur * 0.7);
  v.frequency.exponentialRampToValueAtTime(base * 0.6, now + dur);
  v.connect(master);
  v.start(now);
  v.stop(now + dur);

  const f = ctx.createBiquadFilter();
  f.type = 'bandpass';
  f.frequency.setValueAtTime(700, now);
  f.frequency.linearRampToValueAtTime(1200, now + dur * 0.2);
  f.frequency.linearRampToValueAtTime(400, now + dur);
  f.Q.value = 5;

  const v2 = ctx.createOscillator();
  v2.type = 'sawtooth';
  v2.frequency.setValueAtTime(base * 0.8, now);
  v2.frequency.linearRampToValueAtTime(base * 1.5, now + dur * 0.15);
  v2.frequency.exponentialRampToValueAtTime(base * 0.6, now + dur);
  const fg = ctx.createGain();
  fg.gain.value = 0.3;
  v2.connect(f).connect(fg).connect(master);
  v2.start(now);
  v2.stop(now + dur);
}

function playSynthScaredMeow() {
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const dur = 0.5;
  const base = 500 + Math.random() * 150;

  const master = ctx.createGain();
  master.gain.setValueAtTime(0, now);
  master.gain.linearRampToValueAtTime(0.5, now + 0.02);
  master.gain.exponentialRampToValueAtTime(0.01, now + dur);
  master.connect(ctx.destination);

  const o = ctx.createOscillator();
  o.type = 'sawtooth';
  o.frequency.setValueAtTime(base, now);
  o.frequency.linearRampToValueAtTime(base * 2.5, now + 0.04);
  o.frequency.linearRampToValueAtTime(base * 1.5, now + 0.35);
  o.frequency.exponentialRampToValueAtTime(base * 0.8, now + dur);
  o.connect(master);
  o.start(now);
  o.stop(now + dur);
}

// =============================================
// CAT HISS (synthesized - always sounds good)
// =============================================
function playHiss() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const dur = 0.4;

  const noise = ctx.createBufferSource();
  noise.buffer = createNoiseBuffer(dur);

  const hp = ctx.createBiquadFilter();
  hp.type = 'highpass';
  hp.frequency.value = 3000;

  const bp = ctx.createBiquadFilter();
  bp.type = 'bandpass';
  bp.frequency.setValueAtTime(5000, now);
  bp.frequency.linearRampToValueAtTime(3500, now + dur);
  bp.Q.value = 3;

  const gain = ctx.createGain();
  gain.gain.setValueAtTime(0, now);
  gain.gain.linearRampToValueAtTime(0.45, now + 0.02);
  gain.gain.setValueAtTime(0.4, now + dur * 0.4);
  gain.gain.exponentialRampToValueAtTime(0.01, now + dur);

  noise.connect(hp).connect(bp).connect(gain).connect(ctx.destination);
  noise.start(now);
  noise.stop(now + dur);

  // Add a low growl underneath
  const growl = ctx.createOscillator();
  growl.type = 'sawtooth';
  growl.frequency.setValueAtTime(150, now);
  growl.frequency.linearRampToValueAtTime(80, now + dur);
  const gGain = ctx.createGain();
  gGain.gain.setValueAtTime(0.08, now);
  gGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
  growl.connect(gGain).connect(ctx.destination);
  growl.start(now);
  growl.stop(now + dur);
}

// =============================================
// CARTOON SOUND EFFECTS
// =============================================

// Tom & Jerry style bongo feet running
function playRunSound() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;

  // Rapid bongo drums - accelerating
  for (let i = 0; i < 12; i++) {
    const t = now + i * (0.04 - i * 0.001); // accelerates
    const isLeft = i % 2 === 0;

    // Bongo thump
    const osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(isLeft ? 180 : 240, t);
    osc.frequency.exponentialRampToValueAtTime(50, t + 0.05);
    const g = ctx.createGain();
    g.gain.setValueAtTime(Math.max(0.25 - i * 0.012, 0.05), t);
    g.gain.exponentialRampToValueAtTime(0.01, t + 0.05);
    osc.connect(g).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.05);

    // Tap click on top
    const click = ctx.createOscillator();
    click.type = 'square';
    click.frequency.setValueAtTime(1200 + Math.random() * 600, t);
    click.frequency.exponentialRampToValueAtTime(300, t + 0.015);
    const cg = ctx.createGain();
    cg.gain.setValueAtTime(0.1, t);
    cg.gain.exponentialRampToValueAtTime(0.01, t + 0.02);
    click.connect(cg).connect(ctx.destination);
    click.start(t);
    click.stop(t + 0.02);
  }

  // Whoooosh as cat zooms away
  const noise = ctx.createBufferSource();
  noise.buffer = createNoiseBuffer(0.6);
  const wf = ctx.createBiquadFilter();
  wf.type = 'bandpass';
  wf.frequency.setValueAtTime(500, now + 0.15);
  wf.frequency.exponentialRampToValueAtTime(4000, now + 0.55);
  wf.Q.value = 2;
  const wg = ctx.createGain();
  wg.gain.setValueAtTime(0, now);
  wg.gain.linearRampToValueAtTime(0.2, now + 0.3);
  wg.gain.exponentialRampToValueAtTime(0.01, now + 0.6);
  noise.connect(wf).connect(wg).connect(ctx.destination);
  noise.start(now + 0.1);
  noise.stop(now + 0.7);

  // Rising pitch whistle (cartoon zip away)
  const zip = ctx.createOscillator();
  zip.type = 'sine';
  zip.frequency.setValueAtTime(400, now + 0.2);
  zip.frequency.exponentialRampToValueAtTime(3000, now + 0.5);
  const zg = ctx.createGain();
  zg.gain.setValueAtTime(0, now);
  zg.gain.linearRampToValueAtTime(0.12, now + 0.3);
  zg.gain.exponentialRampToValueAtTime(0.01, now + 0.55);
  zip.connect(zg).connect(ctx.destination);
  zip.start(now + 0.2);
  zip.stop(now + 0.55);
}

// Cartoon spring jump sound (BOING!)
function playJumpSound() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;

  // Spring boing
  const osc = ctx.createOscillator();
  osc.type = 'sine';
  osc.frequency.setValueAtTime(150, now);
  osc.frequency.exponentialRampToValueAtTime(800, now + 0.08);
  osc.frequency.exponentialRampToValueAtTime(200, now + 0.2);
  osc.frequency.exponentialRampToValueAtTime(600, now + 0.25);
  osc.frequency.exponentialRampToValueAtTime(100, now + 0.4);
  const g = ctx.createGain();
  g.gain.setValueAtTime(0.3, now);
  g.gain.exponentialRampToValueAtTime(0.01, now + 0.4);
  osc.connect(g).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + 0.4);

  // Higher harmonic for twang
  const osc2 = ctx.createOscillator();
  osc2.type = 'triangle';
  osc2.frequency.setValueAtTime(300, now);
  osc2.frequency.exponentialRampToValueAtTime(1600, now + 0.08);
  osc2.frequency.exponentialRampToValueAtTime(400, now + 0.2);
  osc2.frequency.exponentialRampToValueAtTime(1200, now + 0.25);
  osc2.frequency.exponentialRampToValueAtTime(200, now + 0.35);
  const g2 = ctx.createGain();
  g2.gain.setValueAtTime(0.15, now);
  g2.gain.exponentialRampToValueAtTime(0.01, now + 0.35);
  osc2.connect(g2).connect(ctx.destination);
  osc2.start(now);
  osc2.stop(now + 0.35);
}

// Combo jingle
function playComboSound() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const notes = [523, 659, 784, 1047, 1319];
  notes.forEach((freq, i) => {
    const t = now + i * 0.08;
    const osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, t);
    const g = ctx.createGain();
    g.gain.setValueAtTime(0.2, t);
    g.gain.exponentialRampToValueAtTime(0.01, t + 0.12);
    osc.connect(g).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.12);
  });
}

// Subtle purr using real meow at very low pitch
function playPurr() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;

  // Try real sound at very low pitch
  const available = meowBuffers.filter(b => b);
  if (available.length > 0) {
    const buf = available[Math.floor(Math.random() * available.length)];
    const src = ctx.createBufferSource();
    src.buffer = buf;
    src.playbackRate.value = 0.3; // very low = purring rumble
    const g = ctx.createGain();
    g.gain.value = 0.15;
    const lp = ctx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.value = 200;
    src.connect(lp).connect(g).connect(ctx.destination);
    src.start();
    return;
  }

  // Fallback synth purr
  const dur = 0.8;
  const osc = ctx.createOscillator();
  osc.type = 'sine';
  osc.frequency.value = 26;
  const lfo = ctx.createOscillator();
  lfo.type = 'sine';
  lfo.frequency.value = 26;
  const lg = ctx.createGain();
  lg.gain.value = 12;
  lfo.connect(lg).connect(osc.frequency);
  const g = ctx.createGain();
  g.gain.setValueAtTime(0, now);
  g.gain.linearRampToValueAtTime(0.08, now + 0.1);
  g.gain.exponentialRampToValueAtTime(0.01, now + dur);
  osc.connect(g).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + dur);
  lfo.start(now);
  lfo.stop(now + dur);
}

// Show loading status
function showLoadingStatus(text) {
  let el = document.getElementById('loading-status');
  if (!el) {
    el = document.createElement('div');
    el.id = 'loading-status';
    el.style.cssText = 'position:fixed;bottom:20px;left:50%;transform:translateX(-50%);background:rgba(0,0,0,0.7);color:#fff;padding:8px 20px;border-radius:20px;font-size:14px;z-index:2000;font-family:sans-serif;';
    document.body.appendChild(el);
  }
  el.textContent = text;
  if (!text) el.remove();
}
