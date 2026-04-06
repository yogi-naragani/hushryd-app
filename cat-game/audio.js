// ============================================
// AUDIO SYSTEM - Real Cat Sounds Only
// ============================================

const AudioCtx = window.AudioContext || window.webkitAudioContext;
let audioCtx;

function ensureAudio() {
  if (!audioCtx) audioCtx = new AudioCtx();
  if (audioCtx.state === 'suspended') audioCtx.resume();
}

// =============================================
// REAL CAT MEOW SOUNDS (from GitHub dataset)
// =============================================
const MEOW_URLS = [
  // Personal recordings (clear single meows)
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_1.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_2.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/newton_3.wav',
  // YouTube cat meows (varied tones and intensities)
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_1.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_2.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_3.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_5.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_8.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_10.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_15.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_20.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_DXUAyRRkI6k_25.wav',
  // More varied cats for different sounds
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_nX1YzS_CYIw_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_nX1YzS_CYIw_5.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_nX1YzS_CYIw_10.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_nX1YzS_CYIw_15.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_acm9dCI5_dc_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_acm9dCI5_dc_5.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_acm9dCI5_dc_10.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_yKb90ItHtn0_0.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_yKb90ItHtn0_5.wav',
  'https://raw.githubusercontent.com/haydenroche5/meow_dataset/master/meow/youtube_yKb90ItHtn0_10.wav',
];

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

// Helper: play a real meow buffer with given settings
function playRealMeow(rate, volume) {
  const ctx = audioCtx;
  const available = meowBuffers.filter(b => b);
  if (available.length === 0) return false;

  const buf = available[Math.floor(Math.random() * available.length)];
  const source = ctx.createBufferSource();
  source.buffer = buf;
  source.playbackRate.value = rate;
  const gain = ctx.createGain();
  gain.gain.value = volume;
  source.connect(gain).connect(ctx.destination);
  source.start();
  return true;
}

// --- Normal meow (idle cats) ---
function playMeow() {
  ensureAudio();
  // Slight pitch variation for natural feel
  playRealMeow(0.85 + Math.random() * 0.35, 0.7);
}

// --- Scared yowl (when clicked) - high pitched double meow ---
function playScaredMeow() {
  ensureAudio();
  const ctx = audioCtx;
  const available = meowBuffers.filter(b => b);
  if (available.length === 0) return;

  // First scared meow - high pitched
  const buf1 = available[Math.floor(Math.random() * available.length)];
  const src1 = ctx.createBufferSource();
  src1.buffer = buf1;
  src1.playbackRate.value = 1.4 + Math.random() * 0.5;

  const gain1 = ctx.createGain();
  gain1.gain.value = 0.9;

  const compressor = ctx.createDynamicsCompressor();
  compressor.threshold.value = -20;
  compressor.knee.value = 10;
  compressor.ratio.value = 8;
  compressor.attack.value = 0;
  compressor.release.value = 0.1;

  src1.connect(compressor).connect(gain1).connect(ctx.destination);
  src1.start();

  // Second layered meow for "REOOOW" effect
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
}

// --- Purr (idle cats sometimes) - real meow slowed way down ---
function playPurr() {
  ensureAudio();
  const ctx = audioCtx;
  const available = meowBuffers.filter(b => b);
  if (available.length === 0) return;

  const buf = available[Math.floor(Math.random() * available.length)];
  const src = ctx.createBufferSource();
  src.buffer = buf;
  src.playbackRate.value = 0.3;
  const g = ctx.createGain();
  g.gain.value = 0.15;
  const lp = ctx.createBiquadFilter();
  lp.type = 'lowpass';
  lp.frequency.value = 200;
  src.connect(lp).connect(g).connect(ctx.destination);
  src.start();
}

// --- Hiss (when clicked - cat sound) - real meow reversed-style with noise ---
function playHiss() {
  ensureAudio();
  const ctx = audioCtx;
  const available = meowBuffers.filter(b => b);
  if (available.length === 0) return;

  // Play a meow very fast + highpass = sounds like a hiss/spit
  const buf = available[Math.floor(Math.random() * available.length)];
  const src = ctx.createBufferSource();
  src.buffer = buf;
  src.playbackRate.value = 2.5 + Math.random() * 1.0;
  const hp = ctx.createBiquadFilter();
  hp.type = 'highpass';
  hp.frequency.value = 2000;
  const g = ctx.createGain();
  g.gain.value = 0.6;
  src.connect(hp).connect(g).connect(ctx.destination);
  src.start();
}

// --- Run away meow (when fleeing) - quick panicked meow ---
function playRunMeow() {
  ensureAudio();
  playRealMeow(1.8 + Math.random() * 0.5, 0.5);
}

// --- Cat fight: rapid layered yowls, hisses, and screams ---
function playCatFight() {
  ensureAudio();
  const ctx = audioCtx;
  const available = meowBuffers.filter(b => b);
  if (available.length === 0) return;

  // Layer 3-4 meows at different pitches rapidly = cat fight chaos
  const count = 3 + Math.floor(Math.random() * 2);
  for (let i = 0; i < count; i++) {
    const delay = i * (60 + Math.random() * 80);
    setTimeout(() => {
      const buf = available[Math.floor(Math.random() * available.length)];
      const src = ctx.createBufferSource();
      src.buffer = buf;
      // Vary pitch wildly: some low growls, some high screams
      src.playbackRate.value = 0.7 + Math.random() * 1.8;
      const g = ctx.createGain();
      g.gain.value = 0.4 + Math.random() * 0.3;
      src.connect(g).connect(ctx.destination);
      src.start();
    }, delay);
  }

  // Add a fast hiss in the middle
  setTimeout(playHiss, 100 + Math.random() * 150);
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
