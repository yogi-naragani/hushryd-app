// ============================================
// CAT SVG BUILDER - Cartoon cats drawn in SVG
// ============================================

const CAT_COLORS = [
  { body: '#FF8C00', dark: '#CC6600', stripe: '#E07000', eye: '#44AA44', name: 'orange-tabby' },
  { body: '#333333', dark: '#111111', stripe: '#444444', eye: '#FFDD44', name: 'black' },
  { body: '#C0C0C0', dark: '#888888', stripe: '#AAAAAA', eye: '#66BBFF', name: 'gray' },
  { body: '#FFFFFF', dark: '#CCCCCC', stripe: '#EEEEEE', eye: '#4488FF', name: 'white' },
  { body: '#8B4513', dark: '#5C2D0E', stripe: '#6B3410', eye: '#AADD44', name: 'brown' },
  { body: '#FFD700', dark: '#CCA800', stripe: '#EEBB00', eye: '#44CC88', name: 'ginger' },
  { body: '#2F2F2F', dark: '#111111', stripe: '#FFFFFF', eye: '#44DDDD', name: 'tuxedo' },
];

function createCatSVG(colorScheme, size) {
  const s = size || 90;
  const c = colorScheme;

  // Build SVG string for a full cartoon cat with body, head, ears, legs, tail
  const svg = `
  <svg viewBox="0 0 140 130" width="${s * 1.4}" height="${s * 1.3}" class="cat-svg">
    <!-- Tail -->
    <g class="cat-tail">
      <path d="M20,85 Q5,60 15,40 Q20,30 28,35"
            stroke="${c.dark}" stroke-width="6" fill="none" stroke-linecap="round"/>
      <path d="M20,85 Q5,60 15,40 Q20,30 28,35"
            stroke="${c.body}" stroke-width="4" fill="none" stroke-linecap="round"/>
    </g>

    <!-- Back legs -->
    <g class="cat-legs cat-back-legs">
      <rect x="35" y="98" width="12" height="25" rx="5" fill="${c.dark}" />
      <rect x="36" y="99" width="10" height="23" rx="4" fill="${c.body}" />
      <ellipse cx="41" cy="123" rx="8" ry="4" fill="${c.dark}" />

      <rect x="55" y="98" width="12" height="25" rx="5" fill="${c.dark}" />
      <rect x="56" y="99" width="10" height="23" rx="4" fill="${c.body}" />
      <ellipse cx="61" cy="123" rx="8" ry="4" fill="${c.dark}" />
    </g>

    <!-- Body -->
    <g class="cat-body">
      <ellipse cx="70" cy="85" rx="38" ry="25" fill="${c.dark}" />
      <ellipse cx="70" cy="84" rx="36" ry="23" fill="${c.body}" />
      <!-- Stripes -->
      <path d="M55,65 Q58,72 55,78" stroke="${c.stripe}" stroke-width="2.5" fill="none" opacity="0.5"/>
      <path d="M65,63 Q68,70 65,77" stroke="${c.stripe}" stroke-width="2.5" fill="none" opacity="0.5"/>
      <path d="M75,63 Q78,70 75,77" stroke="${c.stripe}" stroke-width="2.5" fill="none" opacity="0.5"/>
      <!-- Belly -->
      <ellipse cx="70" cy="90" rx="18" ry="12" fill="${c.body}" opacity="0.6"/>
    </g>

    <!-- Front legs -->
    <g class="cat-legs cat-front-legs">
      <rect x="80" y="96" width="12" height="27" rx="5" fill="${c.dark}" />
      <rect x="81" y="97" width="10" height="25" rx="4" fill="${c.body}" />
      <ellipse cx="86" cy="123" rx="8" ry="4" fill="${c.dark}" />

      <rect x="98" y="96" width="12" height="27" rx="5" fill="${c.dark}" />
      <rect x="99" y="97" width="10" height="25" rx="4" fill="${c.body}" />
      <ellipse cx="104" cy="123" rx="8" ry="4" fill="${c.dark}" />
    </g>

    <!-- Head -->
    <g class="cat-head">
      <!-- Ears -->
      <polygon points="85,42 78,12 95,30" fill="${c.dark}" />
      <polygon points="86,40 80,16 93,32" fill="${c.body}" />
      <polygon points="87,38 82,20 92,33" fill="#FFB6C1" opacity="0.7"/>

      <polygon points="115,42 108,12 125,30" fill="${c.dark}" />
      <polygon points="116,40 110,16 123,32" fill="${c.body}" />
      <polygon points="117,38 112,20 122,33" fill="#FFB6C1" opacity="0.7"/>

      <!-- Head shape -->
      <ellipse cx="100" cy="50" rx="28" ry="24" fill="${c.dark}" />
      <ellipse cx="100" cy="49" rx="26" ry="22" fill="${c.body}" />

      <!-- Eyes -->
      <g class="cat-eyes">
        <ellipse cx="90" cy="46" rx="8" ry="9" fill="white" stroke="${c.dark}" stroke-width="1"/>
        <ellipse cx="110" cy="46" rx="8" ry="9" fill="white" stroke="${c.dark}" stroke-width="1"/>
        <!-- Iris -->
        <ellipse cx="91" cy="47" rx="5" ry="7" fill="${c.eye}"/>
        <ellipse cx="111" cy="47" rx="5" ry="7" fill="${c.eye}"/>
        <!-- Pupil (slit) -->
        <ellipse class="cat-eye-pupil" cx="91" cy="47" rx="2" ry="6" fill="#111"/>
        <ellipse class="cat-eye-pupil" cx="111" cy="47" rx="2" ry="6" fill="#111"/>
        <!-- Highlight -->
        <circle cx="93" cy="44" r="2" fill="white" opacity="0.8"/>
        <circle cx="113" cy="44" r="2" fill="white" opacity="0.8"/>
      </g>

      <!-- Nose -->
      <ellipse cx="100" cy="55" rx="4" ry="2.5" fill="#FFB6C1" stroke="#CC8899" stroke-width="0.5"/>

      <!-- Mouth -->
      <path d="M96,58 Q100,63 104,58" stroke="${c.dark}" stroke-width="1.5" fill="none"/>
      <line x1="100" y1="55" x2="100" y2="59" stroke="${c.dark}" stroke-width="1"/>

      <!-- Whiskers -->
      <line x1="60" y1="50" x2="84" y2="53" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
      <line x1="58" y1="56" x2="84" y2="56" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
      <line x1="60" y1="62" x2="84" y2="59" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
      <line x1="116" y1="53" x2="140" y2="50" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
      <line x1="116" y1="56" x2="142" y2="56" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
      <line x1="116" y1="59" x2="140" y2="62" stroke="${c.dark}" stroke-width="1.2" opacity="0.6"/>
    </g>
  </svg>`;

  return svg;
}

// Create a scared version with wide eyes and open mouth
function createScaredCatSVG(colorScheme, size) {
  const s = size || 90;
  const c = colorScheme;

  const svg = `
  <svg viewBox="0 0 140 130" width="${s * 1.4}" height="${s * 1.3}" class="cat-svg">
    <!-- Tail - puffed up straight -->
    <g class="cat-tail">
      <path d="M20,80 Q5,45 20,15"
            stroke="${c.dark}" stroke-width="10" fill="none" stroke-linecap="round"/>
      <path d="M20,80 Q5,45 20,15"
            stroke="${c.body}" stroke-width="7" fill="none" stroke-linecap="round"/>
    </g>

    <!-- Back legs - spread -->
    <g class="cat-legs">
      <rect x="30" y="95" width="14" height="28" rx="5" fill="${c.dark}" />
      <rect x="31" y="96" width="12" height="26" rx="4" fill="${c.body}" />
      <ellipse cx="37" cy="123" rx="9" ry="5" fill="${c.dark}" />

      <rect x="55" y="95" width="14" height="28" rx="5" fill="${c.dark}" />
      <rect x="56" y="96" width="12" height="26" rx="4" fill="${c.body}" />
      <ellipse cx="62" cy="123" rx="9" ry="5" fill="${c.dark}" />
    </g>

    <!-- Body - arched back (scared) -->
    <g class="cat-body">
      <ellipse cx="70" cy="82" rx="40" ry="28" fill="${c.dark}" />
      <ellipse cx="70" cy="81" rx="38" ry="26" fill="${c.body}" />
      <!-- Fur standing up -->
      <path d="M45,60 L42,52 L48,58" fill="${c.body}" stroke="${c.dark}" stroke-width="0.5"/>
      <path d="M55,56 L53,47 L58,54" fill="${c.body}" stroke="${c.dark}" stroke-width="0.5"/>
      <path d="M65,54 L64,45 L68,52" fill="${c.body}" stroke="${c.dark}" stroke-width="0.5"/>
      <path d="M75,54 L74,45 L78,52" fill="${c.body}" stroke="${c.dark}" stroke-width="0.5"/>
      <path d="M85,56 L84,47 L88,54" fill="${c.body}" stroke="${c.dark}" stroke-width="0.5"/>
    </g>

    <!-- Front legs -->
    <g class="cat-legs">
      <rect x="82" y="93" width="14" height="30" rx="5" fill="${c.dark}" />
      <rect x="83" y="94" width="12" height="28" rx="4" fill="${c.body}" />
      <ellipse cx="89" cy="123" rx="9" ry="5" fill="${c.dark}" />

      <rect x="102" y="93" width="14" height="30" rx="5" fill="${c.dark}" />
      <rect x="103" y="94" width="12" height="28" rx="4" fill="${c.body}" />
      <ellipse cx="109" cy="123" rx="9" ry="5" fill="${c.dark}" />
    </g>

    <!-- Head - bigger with shock -->
    <g class="cat-head">
      <!-- Ears - pointed up alert -->
      <polygon points="82,38 74,4 94,26" fill="${c.dark}" />
      <polygon points="83,36 76,8 92,28" fill="${c.body}" />
      <polygon points="84,34 78,12 91,29" fill="#FFB6C1" opacity="0.8"/>

      <polygon points="118,38 110,4 130,26" fill="${c.dark}" />
      <polygon points="119,36 112,8 128,28" fill="${c.body}" />
      <polygon points="120,34 114,12 127,29" fill="#FFB6C1" opacity="0.8"/>

      <!-- Head -->
      <ellipse cx="100" cy="48" rx="30" ry="26" fill="${c.dark}" />
      <ellipse cx="100" cy="47" rx="28" ry="24" fill="${c.body}" />

      <!-- WIDE SCARED EYES -->
      <g class="cat-eyes">
        <ellipse cx="88" cy="43" rx="11" ry="13" fill="white" stroke="${c.dark}" stroke-width="1.5"/>
        <ellipse cx="112" cy="43" rx="11" ry="13" fill="white" stroke="${c.dark}" stroke-width="1.5"/>
        <!-- Tiny scared pupils -->
        <circle cx="89" cy="44" r="3" fill="#111"/>
        <circle cx="113" cy="44" r="3" fill="#111"/>
        <!-- Highlight -->
        <circle cx="91" cy="41" r="2.5" fill="white" opacity="0.9"/>
        <circle cx="115" cy="41" r="2.5" fill="white" opacity="0.9"/>
      </g>

      <!-- Open mouth - YOWLING -->
      <ellipse cx="100" cy="58" rx="8" ry="10" fill="#CC3333" stroke="${c.dark}" stroke-width="1.5"/>
      <ellipse cx="100" cy="56" rx="5" ry="4" fill="#FF6666"/>
      <!-- Tongue -->
      <ellipse cx="100" cy="63" rx="4" ry="3" fill="#FF8888"/>

      <!-- Whiskers - spread wide -->
      <line x1="52" y1="45" x2="82" y2="50" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="50" y1="52" x2="82" y2="54" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="52" y1="60" x2="82" y2="58" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="118" y1="50" x2="148" y2="45" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="118" y1="54" x2="150" y2="52" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="118" y1="58" x2="148" y2="60" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
    </g>
  </svg>`;

  return svg;
}

// Create a HISSING version - arched back, ears flat, mouth open showing teeth
function createHissingCatSVG(colorScheme, size) {
  const s = size || 90;
  const c = colorScheme;

  const svg = `
  <svg viewBox="0 0 140 130" width="${s * 1.4}" height="${s * 1.3}" class="cat-svg">
    <!-- Tail - puffed and curved up angrily -->
    <g class="cat-tail">
      <path d="M18,78 Q2,50 10,25 Q15,15 25,20"
            stroke="${c.dark}" stroke-width="9" fill="none" stroke-linecap="round"/>
      <path d="M18,78 Q2,50 10,25 Q15,15 25,20"
            stroke="${c.body}" stroke-width="6" fill="none" stroke-linecap="round"/>
    </g>

    <!-- Back legs - crouched -->
    <g class="cat-legs">
      <rect x="32" y="100" width="13" height="22" rx="5" fill="${c.dark}" />
      <rect x="33" y="101" width="11" height="20" rx="4" fill="${c.body}" />
      <ellipse cx="38" cy="122" rx="8" ry="4" fill="${c.dark}" />

      <rect x="52" y="100" width="13" height="22" rx="5" fill="${c.dark}" />
      <rect x="53" y="101" width="11" height="20" rx="4" fill="${c.body}" />
      <ellipse cx="58" cy="122" rx="8" ry="4" fill="${c.dark}" />
    </g>

    <!-- Body - arched back (hissing posture) -->
    <g class="cat-body">
      <ellipse cx="68" cy="84" rx="38" ry="26" fill="${c.dark}" />
      <ellipse cx="68" cy="83" rx="36" ry="24" fill="${c.body}" />
      <!-- Fur bristling along spine -->
      <path d="M40,62 L37,53 L44,60" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
      <path d="M50,58 L48,48 L54,56" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
      <path d="M60,56 L59,46 L64,54" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
      <path d="M70,56 L69,46 L74,54" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
      <path d="M80,58 L79,48 L84,56" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
      <path d="M90,62 L89,53 L94,60" fill="${c.body}" stroke="${c.dark}" stroke-width="0.8"/>
    </g>

    <!-- Front legs - braced -->
    <g class="cat-legs">
      <rect x="84" y="96" width="13" height="27" rx="5" fill="${c.dark}" />
      <rect x="85" y="97" width="11" height="25" rx="4" fill="${c.body}" />
      <ellipse cx="90" cy="123" rx="8" ry="4" fill="${c.dark}" />

      <rect x="102" y="96" width="13" height="27" rx="5" fill="${c.dark}" />
      <rect x="103" y="97" width="11" height="25" rx="4" fill="${c.body}" />
      <ellipse cx="108" cy="123" rx="8" ry="4" fill="${c.dark}" />
    </g>

    <!-- Head - low and forward (aggressive) -->
    <g class="cat-head">
      <!-- Ears - FLAT back (angry) -->
      <polygon points="82,45 70,30 90,38" fill="${c.dark}" />
      <polygon points="83,44 73,32 89,39" fill="${c.body}" />
      <polygon points="84,43 75,34 88,40" fill="#FFB6C1" opacity="0.5"/>

      <polygon points="118,45 130,30 110,38" fill="${c.dark}" />
      <polygon points="117,44 128,32 111,39" fill="${c.body}" />
      <polygon points="116,43 126,34 112,40" fill="#FFB6C1" opacity="0.5"/>

      <!-- Head shape - slightly lower -->
      <ellipse cx="100" cy="52" rx="27" ry="22" fill="${c.dark}" />
      <ellipse cx="100" cy="51" rx="25" ry="20" fill="${c.body}" />

      <!-- Angry narrowed eyes -->
      <g class="cat-eyes">
        <ellipse cx="90" cy="48" rx="8" ry="6" fill="white" stroke="${c.dark}" stroke-width="1.5"/>
        <ellipse cx="110" cy="48" rx="8" ry="6" fill="white" stroke="${c.dark}" stroke-width="1.5"/>
        <!-- Angry slit pupils -->
        <ellipse cx="91" cy="48" rx="2" ry="5" fill="#111"/>
        <ellipse cx="111" cy="48" rx="2" ry="5" fill="#111"/>
        <!-- Angry eyebrow lines -->
        <line x1="82" y1="42" x2="94" y2="44" stroke="${c.dark}" stroke-width="2"/>
        <line x1="118" y1="42" x2="106" y2="44" stroke="${c.dark}" stroke-width="2"/>
      </g>

      <!-- Open mouth HISSING - showing teeth -->
      <ellipse cx="100" cy="60" rx="7" ry="8" fill="#CC3333" stroke="${c.dark}" stroke-width="1.5"/>
      <!-- Teeth -->
      <line x1="95" y1="56" x2="96" y2="59" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
      <line x1="104" y1="56" x2="103" y2="59" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
      <!-- Tongue -->
      <ellipse cx="100" cy="63" rx="3" ry="2.5" fill="#FF8888"/>

      <!-- Whiskers - spread and forward (aggressive) -->
      <line x1="55" y1="47" x2="83" y2="52" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="53" y1="54" x2="83" y2="55" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="55" y1="61" x2="83" y2="58" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="117" y1="52" x2="145" y2="47" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="117" y1="55" x2="147" y2="54" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>
      <line x1="117" y1="58" x2="145" y2="61" stroke="${c.dark}" stroke-width="1.5" opacity="0.7"/>

      <!-- Wrinkled nose -->
      <path d="M96,56 Q100,54 104,56" stroke="${c.dark}" stroke-width="1" fill="none"/>
    </g>
  </svg>`;

  return svg;
}

// Get random cat color
function getRandomCatColor() {
  return CAT_COLORS[Math.floor(Math.random() * CAT_COLORS.length)];
}

// Create dust cloud SVG
function createDustSVG() {
  return `<svg viewBox="0 0 60 40" width="60" height="40">
    <ellipse cx="20" cy="25" rx="15" ry="10" fill="#C8B89A" opacity="0.7"/>
    <ellipse cx="35" cy="18" rx="12" ry="9" fill="#D4C4A8" opacity="0.6"/>
    <ellipse cx="28" cy="30" rx="10" ry="7" fill="#BBA882" opacity="0.5"/>
    <ellipse cx="42" cy="28" rx="8" ry="6" fill="#C8B89A" opacity="0.4"/>
  </svg>`;
}
