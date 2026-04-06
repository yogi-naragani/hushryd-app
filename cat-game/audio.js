// ============================================
// REALISTIC CAT SOUNDS - Web Audio API
// Formant-based synthesis for real meow sounds
// ============================================

const AudioCtx = window.AudioContext || window.webkitAudioContext;
let audioCtx;

function ensureAudio() {
  if (!audioCtx) audioCtx = new AudioCtx();
  if (audioCtx.state === 'suspended') audioCtx.resume();
}

// --- Helper: create noise buffer for hiss/breath sounds ---
function createNoiseBuffer(duration) {
  const ctx = audioCtx;
  const sampleRate = ctx.sampleRate;
  const length = sampleRate * duration;
  const buffer = ctx.createBuffer(1, length, sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < length; i++) {
    data[i] = (Math.random() * 2 - 1);
  }
  return buffer;
}

// --- REALISTIC MEOW ---
// Uses multiple formants to simulate a cat's vocal tract
function playMeow() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const duration = 0.45 + Math.random() * 0.2;
  const baseFreq = 350 + Math.random() * 100; // fundamental

  // Master gain
  const master = ctx.createGain();
  master.gain.setValueAtTime(0, now);
  master.gain.linearRampToValueAtTime(0.4, now + 0.04);
  master.gain.setValueAtTime(0.4, now + duration * 0.3);
  master.gain.linearRampToValueAtTime(0.35, now + duration * 0.6);
  master.gain.exponentialRampToValueAtTime(0.01, now + duration);
  master.connect(ctx.destination);

  // Fundamental voice - the "mee" part
  const voice = ctx.createOscillator();
  voice.type = 'sawtooth';
  voice.frequency.setValueAtTime(baseFreq * 0.8, now);
  voice.frequency.linearRampToValueAtTime(baseFreq * 1.5, now + duration * 0.15); // "me" rise
  voice.frequency.linearRampToValueAtTime(baseFreq * 1.3, now + duration * 0.4);
  voice.frequency.linearRampToValueAtTime(baseFreq * 0.9, now + duration * 0.7); // "ow" fall
  voice.frequency.exponentialRampToValueAtTime(baseFreq * 0.6, now + duration);
  voice.connect(master);
  voice.start(now);
  voice.stop(now + duration);

  // Formant 1 - shapes "ee" vowel
  const formant1 = ctx.createBiquadFilter();
  formant1.type = 'bandpass';
  formant1.frequency.setValueAtTime(700, now);
  formant1.frequency.linearRampToValueAtTime(1200, now + duration * 0.2);
  formant1.frequency.linearRampToValueAtTime(600, now + duration * 0.7);
  formant1.frequency.linearRampToValueAtTime(400, now + duration);
  formant1.Q.value = 5;

  const voice2 = ctx.createOscillator();
  voice2.type = 'sawtooth';
  voice2.frequency.setValueAtTime(baseFreq * 0.8, now);
  voice2.frequency.linearRampToValueAtTime(baseFreq * 1.5, now + duration * 0.15);
  voice2.frequency.linearRampToValueAtTime(baseFreq * 1.3, now + duration * 0.4);
  voice2.frequency.linearRampToValueAtTime(baseFreq * 0.9, now + duration * 0.7);
  voice2.frequency.exponentialRampToValueAtTime(baseFreq * 0.6, now + duration);

  const formantGain1 = ctx.createGain();
  formantGain1.gain.value = 0.3;
  voice2.connect(formant1).connect(formantGain1).connect(master);
  voice2.start(now);
  voice2.stop(now + duration);

  // Formant 2 - higher resonance
  const formant2 = ctx.createBiquadFilter();
  formant2.type = 'bandpass';
  formant2.frequency.setValueAtTime(1500, now);
  formant2.frequency.linearRampToValueAtTime(2500, now + duration * 0.2);
  formant2.frequency.linearRampToValueAtTime(1200, now + duration);
  formant2.Q.value = 8;

  const voice3 = ctx.createOscillator();
  voice3.type = 'triangle';
  voice3.frequency.setValueAtTime(baseFreq, now);
  voice3.frequency.linearRampToValueAtTime(baseFreq * 1.5, now + duration * 0.15);
  voice3.frequency.exponentialRampToValueAtTime(baseFreq * 0.6, now + duration);

  const formantGain2 = ctx.createGain();
  formantGain2.gain.value = 0.15;
  voice3.connect(formant2).connect(formantGain2).connect(master);
  voice3.start(now);
  voice3.stop(now + duration);

  // Breath noise at the start (the "m" consonant)
  const noise = ctx.createBufferSource();
  noise.buffer = createNoiseBuffer(0.08);
  const noiseFilter = ctx.createBiquadFilter();
  noiseFilter.type = 'bandpass';
  noiseFilter.frequency.value = 800;
  noiseFilter.Q.value = 2;
  const noiseGain = ctx.createGain();
  noiseGain.gain.setValueAtTime(0.15, now);
  noiseGain.gain.exponentialRampToValueAtTime(0.01, now + 0.06);
  noise.connect(noiseFilter).connect(noiseGain).connect(master);
  noise.start(now);
  noise.stop(now + 0.08);
}

// --- SCARED YOWL --- (high pitched, startled)
function playScaredMeow() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const duration = 0.6;
  const baseFreq = 500 + Math.random() * 150;

  const master = ctx.createGain();
  master.gain.setValueAtTime(0, now);
  master.gain.linearRampToValueAtTime(0.5, now + 0.02);
  master.gain.setValueAtTime(0.5, now + 0.15);
  master.gain.linearRampToValueAtTime(0.4, now + 0.3);
  master.gain.exponentialRampToValueAtTime(0.01, now + duration);
  master.connect(ctx.destination);

  // Startled yelp - sharp rise then wavering
  const yelp = ctx.createOscillator();
  yelp.type = 'sawtooth';
  yelp.frequency.setValueAtTime(baseFreq, now);
  yelp.frequency.linearRampToValueAtTime(baseFreq * 2.5, now + 0.04); // instant spike
  yelp.frequency.linearRampToValueAtTime(baseFreq * 2, now + 0.1);
  // Wavering panic
  yelp.frequency.linearRampToValueAtTime(baseFreq * 2.2, now + 0.15);
  yelp.frequency.linearRampToValueAtTime(baseFreq * 1.8, now + 0.2);
  yelp.frequency.linearRampToValueAtTime(baseFreq * 2.1, now + 0.25);
  yelp.frequency.linearRampToValueAtTime(baseFreq * 1.5, now + 0.35);
  yelp.frequency.exponentialRampToValueAtTime(baseFreq * 0.8, now + duration);
  yelp.connect(master);
  yelp.start(now);
  yelp.stop(now + duration);

  // Formant for "REOOW" shape
  const formant = ctx.createBiquadFilter();
  formant.type = 'bandpass';
  formant.frequency.setValueAtTime(1000, now);
  formant.frequency.linearRampToValueAtTime(2800, now + 0.05);
  formant.frequency.linearRampToValueAtTime(1500, now + 0.3);
  formant.frequency.linearRampToValueAtTime(600, now + duration);
  formant.Q.value = 6;

  const yelp2 = ctx.createOscillator();
  yelp2.type = 'sawtooth';
  yelp2.frequency.setValueAtTime(baseFreq, now);
  yelp2.frequency.linearRampToValueAtTime(baseFreq * 2.5, now + 0.04);
  yelp2.frequency.linearRampToValueAtTime(baseFreq * 2, now + 0.1);
  yelp2.frequency.linearRampToValueAtTime(baseFreq * 1.5, now + 0.35);
  yelp2.frequency.exponentialRampToValueAtTime(baseFreq * 0.8, now + duration);

  const fGain = ctx.createGain();
  fGain.gain.value = 0.35;
  yelp2.connect(formant).connect(fGain).connect(master);
  yelp2.start(now);
  yelp2.stop(now + duration);

  // Second voice (harmonic)
  const harm = ctx.createOscillator();
  harm.type = 'triangle';
  harm.frequency.setValueAtTime(baseFreq * 2, now);
  harm.frequency.linearRampToValueAtTime(baseFreq * 4, now + 0.04);
  harm.frequency.exponentialRampToValueAtTime(baseFreq, now + duration);
  const harmGain = ctx.createGain();
  harmGain.gain.setValueAtTime(0.12, now);
  harmGain.gain.exponentialRampToValueAtTime(0.01, now + duration * 0.6);
  harm.connect(harmGain).connect(master);
  harm.start(now);
  harm.stop(now + duration);
}

// --- HISS --- (when very close click)
function playHiss() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const duration = 0.35;

  const noise = ctx.createBufferSource();
  noise.buffer = createNoiseBuffer(duration);

  const filter = ctx.createBiquadFilter();
  filter.type = 'highpass';
  filter.frequency.value = 3000;
  filter.Q.value = 1;

  const filter2 = ctx.createBiquadFilter();
  filter2.type = 'bandpass';
  filter2.frequency.setValueAtTime(5000, now);
  filter2.frequency.linearRampToValueAtTime(4000, now + duration);
  filter2.Q.value = 3;

  const gain = ctx.createGain();
  gain.gain.setValueAtTime(0, now);
  gain.gain.linearRampToValueAtTime(0.4, now + 0.02);
  gain.gain.setValueAtTime(0.35, now + duration * 0.5);
  gain.gain.exponentialRampToValueAtTime(0.01, now + duration);

  noise.connect(filter).connect(filter2).connect(gain).connect(ctx.destination);
  noise.start(now);
  noise.stop(now + duration);
}

// --- CARTOON RUN SOUND --- (bongo feet like Tom & Jerry)
function playRunSound() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;

  // Rapid bongo-style footsteps
  for (let i = 0; i < 10; i++) {
    const t = now + i * 0.05;

    // Thump
    const osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(150 + (i % 2) * 80, t);
    osc.frequency.exponentialRampToValueAtTime(60, t + 0.04);
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.2 - i * 0.015, t);
    gain.gain.exponentialRampToValueAtTime(0.01, t + 0.04);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.04);

    // Click
    const click = ctx.createOscillator();
    click.type = 'square';
    click.frequency.setValueAtTime(800 + Math.random() * 400, t);
    click.frequency.exponentialRampToValueAtTime(200, t + 0.02);
    const clickGain = ctx.createGain();
    clickGain.gain.setValueAtTime(0.08, t);
    clickGain.gain.exponentialRampToValueAtTime(0.01, t + 0.025);
    click.connect(clickGain).connect(ctx.destination);
    click.start(t);
    click.stop(t + 0.025);
  }

  // Whoosh
  const noise = ctx.createBufferSource();
  noise.buffer = createNoiseBuffer(0.5);
  const whooshFilter = ctx.createBiquadFilter();
  whooshFilter.type = 'bandpass';
  whooshFilter.frequency.setValueAtTime(1000, now + 0.2);
  whooshFilter.frequency.linearRampToValueAtTime(3000, now + 0.5);
  whooshFilter.Q.value = 2;
  const whooshGain = ctx.createGain();
  whooshGain.gain.setValueAtTime(0, now);
  whooshGain.gain.linearRampToValueAtTime(0.15, now + 0.3);
  whooshGain.gain.exponentialRampToValueAtTime(0.01, now + 0.5);
  noise.connect(whooshFilter).connect(whooshGain).connect(ctx.destination);
  noise.start(now + 0.1);
  noise.stop(now + 0.6);
}

// --- COMBO JINGLE ---
function playComboSound() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const notes = [523, 659, 784, 1047, 1319]; // C5 E5 G5 C6 E6
  notes.forEach((freq, i) => {
    const t = now + i * 0.08;
    const osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, t);
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.2, t);
    gain.gain.exponentialRampToValueAtTime(0.01, t + 0.12);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.12);
  });
}

// --- IDLE PURR --- (subtle background)
function playPurr() {
  ensureAudio();
  const ctx = audioCtx;
  const now = ctx.currentTime;
  const duration = 0.8;

  const osc = ctx.createOscillator();
  osc.type = 'sine';
  osc.frequency.value = 26; // real purr frequency ~25Hz

  const lfo = ctx.createOscillator();
  lfo.type = 'sine';
  lfo.frequency.value = 26;
  const lfoGain = ctx.createGain();
  lfoGain.gain.value = 12;
  lfo.connect(lfoGain).connect(osc.frequency);

  const gain = ctx.createGain();
  gain.gain.setValueAtTime(0, now);
  gain.gain.linearRampToValueAtTime(0.08, now + 0.1);
  gain.gain.setValueAtTime(0.08, now + duration * 0.7);
  gain.gain.exponentialRampToValueAtTime(0.01, now + duration);

  osc.connect(gain).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + duration);
  lfo.start(now);
  lfo.stop(now + duration);
}
