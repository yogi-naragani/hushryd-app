// ============================================
// GAME LOGIC - Cat Chase! Tom & Jerry Style
// ============================================

let score = 0;
let combo = 0;
let comboTimer = null;
let gameRunning = false;
const gameArea = document.getElementById('game-area');
const scoreEl = document.getElementById('score');

// Track all active cats for proximity detection
const activeCats = new Set();
const HISS_PROXIMITY = 150; // px distance to trigger hissing

// ---- Clouds ----
function spawnCloud() {
  const cloud = document.createElement('div');
  cloud.className = 'cloud';
  const size = 60 + Math.random() * 120;
  cloud.style.width = size + 'px';
  cloud.style.height = (size * 0.45) + 'px';
  cloud.style.top = (5 + Math.random() * 25) + '%';
  cloud.style.left = '-200px';
  const dur = 25 + Math.random() * 35;
  cloud.style.animationDuration = dur + 's';
  gameArea.appendChild(cloud);
  setTimeout(() => cloud.remove(), dur * 1000);
}

// ---- Get cat center position ----
function getCatPos(container) {
  const rect = container.getBoundingClientRect();
  return { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
}

// ---- Check proximity between cats ----
function checkCatProximity() {
  if (!gameRunning) return;

  const catArray = Array.from(activeCats).filter(c => c.parentNode && !c.dataset.clicked);

  for (let i = 0; i < catArray.length; i++) {
    for (let j = i + 1; j < catArray.length; j++) {
      const a = catArray[i];
      const b = catArray[j];
      const posA = getCatPos(a);
      const posB = getCatPos(b);
      const dist = Math.hypot(posA.x - posB.x, posA.y - posB.y);

      if (dist < HISS_PROXIMITY) {
        // Both cats react! Hiss at each other
        const now = Date.now();
        if (!a.dataset.lastHiss || now - parseInt(a.dataset.lastHiss) > 2000) {
          a.dataset.lastHiss = now;
          b.dataset.lastHiss = now;

          // Visual: both arch their backs momentarily
          a.classList.add('hissing');
          b.classList.add('hissing');
          setTimeout(() => {
            a.classList.remove('hissing');
            b.classList.remove('hissing');
          }, 800);

          // Sound: hiss!
          playHiss();
          setTimeout(() => playHiss(), 200);

          // Swap to hissing SVG briefly
          if (!a.dataset.hissSwapped) {
            a.dataset.hissSwapped = 'true';
            const colorsA = JSON.parse(a.dataset.colors);
            const sizeA = parseFloat(a.dataset.catSize);
            const origA = a.innerHTML;
            a.innerHTML = createHissingCatSVG(colorsA, sizeA);
            setTimeout(() => {
              if (a.parentNode && !a.dataset.clicked) {
                a.innerHTML = origA;
                a.dataset.hissSwapped = '';
              }
            }, 800);
          }
          if (!b.dataset.hissSwapped) {
            b.dataset.hissSwapped = 'true';
            const colorsB = JSON.parse(b.dataset.colors);
            const sizeB = parseFloat(b.dataset.catSize);
            const origB = b.innerHTML;
            b.innerHTML = createHissingCatSVG(colorsB, sizeB);
            setTimeout(() => {
              if (b.parentNode && !b.dataset.clicked) {
                b.innerHTML = origB;
                b.dataset.hissSwapped = '';
              }
            }, 800);
          }
        }
      }
    }
  }

  requestAnimationFrame(checkCatProximity);
}

// ---- Spawn Cat ----
function spawnCat() {
  if (!gameRunning) return;

  const colorScheme = getRandomCatColor();
  const catSize = 55 + Math.random() * 30;

  const container = document.createElement('div');
  container.className = 'cat-container idle';
  container.innerHTML = createCatSVG(colorScheme, catSize);
  container.dataset.catSize = catSize;
  container.dataset.colors = JSON.stringify(colorScheme);

  const groundHeight = 80;
  const x = 60 + Math.random() * (window.innerWidth - 200);
  const y = window.innerHeight - groundHeight - catSize * 1.3 - Math.random() * (window.innerHeight * 0.35);

  container.style.left = x + 'px';
  container.style.top = y + 'px';

  // Random facing
  const facingLeft = Math.random() > 0.5;
  if (facingLeft) {
    container.style.transform = 'scaleX(-1)';
    container.dataset.facing = 'left';
  } else {
    container.dataset.facing = 'right';
  }

  // Cat behaviors - weighted random
  const behavior = Math.random();
  let posX = x;

  if (behavior < 0.3) {
    // SITTING: cat just sits, breathes, occasionally licks/blinks
    container.classList.remove('idle');
    container.classList.add('sitting');
    // Blink occasionally
    const blinkInterval = setInterval(() => {
      if (!container.parentNode || container.dataset.clicked) {
        clearInterval(blinkInterval);
        return;
      }
      container.classList.add('blinking');
      setTimeout(() => container.classList.remove('blinking'), 300);
    }, 2000 + Math.random() * 3000);
    container.dataset.blinkInterval = blinkInterval;

  } else if (behavior < 0.6) {
    // PROWLING: cat slowly walks
    container.classList.remove('idle');
    container.classList.add('prowl');
    const speed = 0.3 + Math.random() * 0.5;
    const dir = facingLeft ? -1 : 1;
    const walkInterval = setInterval(() => {
      if (container.dataset.clicked || !container.parentNode) {
        clearInterval(walkInterval);
        return;
      }
      posX += dir * speed;
      container.style.left = posX + 'px';
      if (posX < -100 || posX > window.innerWidth + 100) {
        clearInterval(walkInterval);
        activeCats.delete(container);
        container.remove();
      }
    }, 16);
    container.dataset.walkInterval = walkInterval;

  } else if (behavior < 0.8) {
    // GROOMING: cat licks itself
    container.classList.remove('idle');
    container.classList.add('grooming');

  } else {
    // IDLE: gentle breathing + tail sway (default)
  }

  // --- Sound behaviors ---

  // Purring when sitting still (30% chance, repeats)
  if (behavior < 0.3 || behavior >= 0.8) {
    const purrLoop = () => {
      if (!container.parentNode || container.dataset.clicked) return;
      playPurr();
      setTimeout(purrLoop, 3000 + Math.random() * 4000);
    };
    setTimeout(purrLoop, 1500 + Math.random() * 2000);
  }

  // Occasional idle meow (any cat)
  if (Math.random() > 0.5) {
    const meowLoop = () => {
      if (!container.parentNode || container.dataset.clicked) return;
      playMeow();
      // Next meow after random delay
      if (Math.random() > 0.4) {
        setTimeout(meowLoop, 4000 + Math.random() * 6000);
      }
    };
    setTimeout(meowLoop, 1000 + Math.random() * 3000);
  }

  container.addEventListener('click', (e) => onCatClick(e, container));
  gameArea.appendChild(container);
  activeCats.add(container);

  // Auto-leave after timeout
  const lifespan = 5000 + Math.random() * 6000;
  setTimeout(() => {
    if (container.parentNode && !container.dataset.clicked) {
      // Quiet meow as cat wanders off
      playMeow();
      container.classList.remove('idle', 'prowl', 'sitting', 'grooming');
      const dir = container.dataset.facing === 'left' ? 'run-left' : 'run-right';
      container.classList.add(dir);
      combo = 0;
      setTimeout(() => {
        activeCats.delete(container);
        container.remove();
      }, 1100);
    }
  }, lifespan);
}

// ---- Cat Click Handler ----
function onCatClick(e, container) {
  if (container.dataset.clicked) return;
  container.dataset.clicked = 'true';

  // Clear any intervals
  if (container.dataset.walkInterval) clearInterval(parseInt(container.dataset.walkInterval));
  if (container.dataset.blinkInterval) clearInterval(parseInt(container.dataset.blinkInterval));

  // Score
  combo++;
  const points = combo >= 5 ? combo * 3 : combo >= 3 ? combo * 2 : 1;
  score += points;
  scoreEl.textContent = score;

  // Combo timer
  clearTimeout(comboTimer);
  comboTimer = setTimeout(() => { combo = 0; }, 2500);

  // Combo text
  if (combo >= 3) {
    const comboEl = document.createElement('div');
    comboEl.className = 'combo-text';
    if (combo >= 7) {
      comboEl.textContent = combo + 'x INSANE!';
      comboEl.style.color = '#FF0000';
    } else if (combo >= 5) {
      comboEl.textContent = combo + 'x AMAZING!';
      comboEl.style.color = '#FF6B00';
    } else {
      comboEl.textContent = combo + 'x COMBO!';
    }
    document.body.appendChild(comboEl);
    setTimeout(() => comboEl.remove(), 1000);
  }

  // --- PHASE 1: SCARED JUMP + YOWL ---
  const colors = JSON.parse(container.dataset.colors);
  const catSize = parseFloat(container.dataset.catSize);
  container.innerHTML = createScaredCatSVG(colors, catSize);

  // Scared yowl sound - matched to the jump motion
  playCatFight();

  // Exclamation effects
  const symbols = ['!', '!!', '?!', '*'];
  for (let i = 0; i < 4; i++) {
    const ex = document.createElement('div');
    ex.className = 'exclaim';
    ex.textContent = symbols[Math.floor(Math.random() * symbols.length)];
    ex.style.left = (e.clientX - 20 + (Math.random() - 0.5) * 60) + 'px';
    ex.style.top = (e.clientY - 40 + (Math.random() - 0.5) * 40) + 'px';
    ex.style.fontSize = (24 + Math.random() * 16) + 'px';
    ex.style.color = ['#FF0000', '#FF6600', '#FFD700', '#FF00FF'][Math.floor(Math.random() * 4)];
    gameArea.appendChild(ex);
    setTimeout(() => ex.remove(), 700);
  }

  // Scratch marks
  for (let i = 0; i < 2; i++) {
    const scratch = document.createElement('div');
    scratch.className = 'scratch-mark';
    scratch.innerHTML = `<svg width="30" height="30" viewBox="0 0 30 30">
      <line x1="5" y1="5" x2="25" y2="25" stroke="#FFD700" stroke-width="2"/>
      <line x1="10" y1="3" x2="28" y2="22" stroke="#FFD700" stroke-width="2"/>
      <line x1="3" y1="10" x2="22" y2="28" stroke="#FFD700" stroke-width="2"/>
    </svg>`;
    scratch.style.left = (e.clientX - 15 + (Math.random() - 0.5) * 30) + 'px';
    scratch.style.top = (e.clientY - 15 + (Math.random() - 0.5) * 30) + 'px';
    gameArea.appendChild(scratch);
    setTimeout(() => scratch.remove(), 500);
  }

  // Apply scared animation
  container.classList.remove('idle', 'prowl', 'sitting', 'grooming');
  container.classList.add('scared');

  // --- PHASE 2: PANICKED RUN ---
  setTimeout(() => {
    // Panicked meow as cat sprints away
    playRunMeow();

    // Nearby cats also get startled and hiss
    const myPos = getCatPos(container);
    activeCats.forEach(other => {
      if (other === container || other.dataset.clicked) return;
      const otherPos = getCatPos(other);
      const dist = Math.hypot(myPos.x - otherPos.x, myPos.y - otherPos.y);
      if (dist < 250) {
        // Nearby cat gets startled - arches back briefly
        other.classList.add('startled');
        playHiss();
        setTimeout(() => other.classList.remove('startled'), 600);
      }
    });

    // Dust clouds
    const catLeft = container.offsetLeft;
    const catTop = container.offsetTop;
    for (let i = 0; i < 5; i++) {
      const dust = document.createElement('div');
      dust.className = 'dust-cloud';
      dust.innerHTML = createDustSVG();
      dust.style.left = (catLeft + (Math.random() - 0.3) * 40) + 'px';
      dust.style.top = (catTop + 30 + Math.random() * 20) + 'px';
      dust.style.animationDelay = (i * 0.05) + 's';
      gameArea.appendChild(dust);
      setTimeout(() => dust.remove(), 800);
    }

    // Speed lines
    const runDir = container.dataset.facing === 'left' ? 'run-left' : 'run-right';
    const lineColors = ['rgba(0,0,0,0.4)', 'rgba(100,100,100,0.3)', 'rgba(50,50,50,0.35)'];
    for (let i = 0; i < 6; i++) {
      const line = document.createElement('div');
      line.className = 'speed-line';
      line.style.top = (catTop + 10 + i * 10 + Math.random() * 5) + 'px';
      line.style.background = `linear-gradient(${runDir === 'run-right' ? '90deg' : '270deg'}, ${lineColors[i % 3]}, transparent)`;
      if (runDir === 'run-right') {
        line.style.left = (catLeft - 30 - Math.random() * 20) + 'px';
      } else {
        line.style.left = (catLeft + 60 + Math.random() * 20) + 'px';
      }
      gameArea.appendChild(line);
      setTimeout(() => line.remove(), 600);
    }

    // RUN!
    container.classList.remove('scared');
    container.classList.add(runDir);

    setTimeout(() => {
      activeCats.delete(container);
      container.remove();
    }, 1100);
  }, 500);
}

// ---- Start Game ----
async function startGame() {
  ensureAudio();
  document.getElementById('intro').style.display = 'none';
  gameRunning = true;
  score = 0;
  combo = 0;
  scoreEl.textContent = '0';

  // Preload real cat sounds
  showLoadingStatus('Loading real cat sounds...');
  preloadMeows().then(() => {
    showLoadingStatus('');
  });

  // Start proximity checker
  requestAnimationFrame(checkCatProximity);

  // Spawn schedule
  function scheduleNext() {
    if (!gameRunning) return;
    const delay = 600 + Math.random() * 1200;
    setTimeout(() => {
      spawnCat();
      scheduleNext();
    }, delay);
  }
  scheduleNext();

  // Initial batch
  setTimeout(spawnCat, 100);
  setTimeout(spawnCat, 400);
  setTimeout(spawnCat, 800);

  // Clouds
  spawnCloud();
  spawnCloud();
  setInterval(spawnCloud, 7000);
}

// ---- Resize ----
window.addEventListener('resize', () => {
  document.querySelectorAll('.cat-container').forEach(cat => {
    if (cat.offsetLeft > window.innerWidth + 100 || cat.offsetTop > window.innerHeight + 100) {
      activeCats.delete(cat);
      cat.remove();
    }
  });
});
