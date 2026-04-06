// ============================================
// GAME LOGIC - Cat Chase! Tom & Jerry Style
// ============================================

let score = 0;
let combo = 0;
let comboTimer = null;
let gameRunning = false;
const gameArea = document.getElementById('game-area');
const scoreEl = document.getElementById('score');

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

// ---- Spawn Cat ----
function spawnCat() {
  if (!gameRunning) return;

  const colorScheme = getRandomCatColor();
  const catSize = 55 + Math.random() * 30;

  const container = document.createElement('div');
  container.className = 'cat-container idle';
  container.innerHTML = createCatSVG(colorScheme, catSize);
  container.dataset.colorBody = colorScheme.body;
  container.dataset.colorDark = colorScheme.dark;
  container.dataset.colorEye = colorScheme.eye;
  container.dataset.colorStripe = colorScheme.stripe;
  container.dataset.catSize = catSize;

  // Store color scheme as JSON for scared SVG swap
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

  // Prowl movement - some cats slowly walk
  if (Math.random() > 0.5) {
    container.classList.remove('idle');
    container.classList.add('prowl');
    const speed = 0.3 + Math.random() * 0.5;
    const dir = facingLeft ? -1 : 1;
    let posX = x;
    const walkInterval = setInterval(() => {
      if (container.dataset.clicked || !container.parentNode) {
        clearInterval(walkInterval);
        return;
      }
      posX += dir * speed;
      container.style.left = posX + 'px';
      if (posX < -100 || posX > window.innerWidth + 100) {
        clearInterval(walkInterval);
        container.remove();
      }
    }, 16);
    container.dataset.walkInterval = walkInterval;
  }

  // Occasional purr sound
  if (Math.random() > 0.7) {
    setTimeout(() => {
      if (container.parentNode && !container.dataset.clicked) {
        playPurr();
      }
    }, 1000 + Math.random() * 2000);
  }

  // Occasional idle meow
  if (Math.random() > 0.6) {
    setTimeout(() => {
      if (container.parentNode && !container.dataset.clicked) {
        playMeow();
      }
    }, 500 + Math.random() * 3000);
  }

  container.addEventListener('click', (e) => onCatClick(e, container));
  gameArea.appendChild(container);

  // Auto-leave after timeout
  const lifespan = 4000 + Math.random() * 5000;
  setTimeout(() => {
    if (container.parentNode && !container.dataset.clicked) {
      // Cat casually walks away
      container.classList.remove('idle', 'prowl');
      const dir = Math.random() > 0.5 ? 'run-right' : 'run-left';
      container.classList.add(dir);
      combo = 0;
      setTimeout(() => container.remove(), 1100);
    }
  }, lifespan);
}

// ---- Cat Click Handler ----
function onCatClick(e, container) {
  if (container.dataset.clicked) return;
  container.dataset.clicked = 'true';

  // Clear any walk interval
  if (container.dataset.walkInterval) {
    clearInterval(parseInt(container.dataset.walkInterval));
  }

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
    playComboSound();
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

  // --- PHASE 1: SCARED JUMP ---

  // Swap to scared SVG (wide eyes, open mouth)
  const colors = JSON.parse(container.dataset.colors);
  const catSize = parseFloat(container.dataset.catSize);
  container.innerHTML = createScaredCatSVG(colors, catSize);

  // Play scared meow + sometimes hiss
  playScaredMeow();
  if (Math.random() > 0.5) {
    setTimeout(playHiss, 100);
  }

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
  container.classList.remove('idle', 'prowl');
  container.classList.add('scared');

  // --- PHASE 2: RUN AWAY (Tom & Jerry style) ---
  setTimeout(() => {
    // Play cartoon run sound
    playRunSound();

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
    const runDir = catLeft > window.innerWidth / 2 ? 'run-right' : 'run-left';
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

    setTimeout(() => container.remove(), 1100);
  }, 500);
}

// ---- Start Game ----
function startGame() {
  ensureAudio();
  document.getElementById('intro').style.display = 'none';
  gameRunning = true;
  score = 0;
  combo = 0;
  scoreEl.textContent = '0';

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
      cat.remove();
    }
  });
});
