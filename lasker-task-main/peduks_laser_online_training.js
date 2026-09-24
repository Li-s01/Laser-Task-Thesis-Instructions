/*******************************
 * Peduks_Laser_Online_Training *
 *******************************/

import { core, data, util, visual } from './lib/psychojs-2026.1.3.js';
const { PsychoJS } = core;
const { TrialHandler } = data;
const { Scheduler } = util;



// Session configuration

const expName = 'peduks_laser_online_training';  // from the Builder filename that created this script
const expInfo = {
  'participant': '000',
};

const SONA_CREDIT_URL = 'https://osnabrueck.sona-systems.com/webstudy_credit.aspx?experiment_id=181&credit_token=94876417da0f481882efae48cd399f93&survey_code=';



// Instruction texts

const WELCOME_TEXT = 'Welcome to the Save-the-World Game, and thank you for participating in this study.\n\nThe study consists of one session of about 60 minutes. Please make sure you have enough time before you start.\n\nYou will now go through a short introduction explaining how the game works, followed by the game itself.\n\nPlease do not use the back button or close the window at any point during the study. If something goes wrong, please contact:livschroeder@uni-osnabrueck.de\n Please write this email down as you will not be able to come back to this page.\n\n[Press SPACE to start]';
const STORY_TEXT = 'Mysterious alien creatures have landed near Earth and are using radiation weapons to attack our planet. Your task is to protect the Earth, using an absorption shield.\n\n[Press SPACE to continue]';
const SHIELD_TEXT = 'In the centre of the screen you will see the alien radiation source. A red beam is emitted from the source, and your white shield must catch it before it hits Earth.\n\nYour goal is to position the shield to catch as many radiation beams as possible. You will be rewarded for every beam you absorb.\n\n[Press SPACE to continue]';
const MOVE_TEXT = 'To move the shield around, you can use the "D" and "K" keys on your keyboard. Press "D" to move the shield COUNTER-CLOCKWISE and "K" to move it CLOCKWISE.';
const REWARD_TEXT = 'In every block, your reward starts at 100 points. Every time a beam hits Earth, you lose 0.25 points. Try to position your shield strategically to catch as many beams as possible.\n\nOn the right of the screen, a bar shows your current reward.\n\n[Press SPACE to continue]';
const PRIZE_TEXT = 'At the end of the study, the participant with the highest total score across all blocks will receive a small prize from us.\n\nGood luck!\n\n[Press SPACE to continue]';
const MOVE_COST_TEXT = 'Note: Moving your shield costs energy. After each block, a small penalty is subtracted based on how much you moved.\nThe best strategy to save Earth is to keep your shield where you think the aliens are probably aiming on average and only move it if you think that the main direction has changed. \n\n[Press SPACE to continue]';
const PRACTICE_START_TEXT = 'Before the main experiment begins, we will introduce you to two types of alien attackers. For each one, you will first read a short description, followed by a practice round to get familiar with their behaviour.\n\n[Press SPACE to continue]';
const PRACTICE_VOL_INSTR_TEXT = 'Meet the Cooperative Aliens.\n\nThese aliens love working together. They take turns controlling the Laser. One alien aims and fires for a while, until the next one takes over and picks a new direction.\n\nWhen a new teammate takes over, the beam jumps to an entirely different position and stays there for a while.\n\nNote: They are decent shots, but not perfect. Beams may land slightly off target even when no one has switched yet.\nPress K to move the shield clockwise.\nPress D to move the shield counter-clockwise.\n\n[Press SPACE to start practice]';
const PRACTICE_NOISE_INSTR_TEXT = 'Now meet the Solo Alien.\n\nThis alien insists on doing everything alone. It never lets anyone else touch the Laser.\n\nIt picks a direction and sticks with it for a very long time and only occasionally switches to a new one. But it is a terrible shot and its beams scatter all over the place, even while it is trying to stay in one place.\n\n[Press SPACE to practice]';
const PRACTICE_MOVE_COST_TEXT = 'Remember the Move Cost: Only move your shield, if you think, that the main direction has changed, to catch the most beams.';
const BLOCK_TEXTS = {
  'A': 'The Cooperative Aliens are up next.\n\nThey take turns controlling the laser. When a new teammate takes over, the beam jumps to an entirely different position.\n\nNote: Beams may land slightly off target even when no one has switched yet.\n\n[Press SPACE to start]',
  'B': 'The Solo Alien is up next.\n\nIt picks a direction and sticks with it for a very long time and only occasionally switches to a new one. Its beams scatter all over the place, even while it is trying to stay in one place \n\n[Press SPACE to start]',
};
const REFRESH_RATE_ERROR_TEXT = 'Oh no! Your monitor refresh rate setting is currently incompatiable with this task.\n\nPlease close this window, and set your monitor refresh rate to 60Hz. Then, return to this task.';
const EXP_END_TEXT = "Congratulations, you have finished the save-the-world game.\n\n\n\n\n\n\n\n\n\nTo complete the task, please press SPACE and wait until you receive a message to close the window.\n\nThank you for your participation! \n";
const CONTINUE_TEXT = '[Press SPACE to continue]';


// Counterbalancing
// order = (participant % 4) + 1


const CP_FIRST_SEQUENCE = [
  ['ambiguous_cp_final_block1.csv',        'A'],
  ['ambiguous_cp_final_block2.csv',        'A'],
  ['ambiguous_cp_final_block3.csv',        'A'],
  ['ambiguous_cp_final_block4.csv',        'A'],
  ['ambiguous_rw_final_block1.csv',        'B'],
  ['ambiguous_rw_final_block2.csv',        'B'],
  ['ambiguous_cp_final_block1_rot180.csv', 'B'],
  ['ambiguous_cp_final_block2_rot180.csv', 'B'],
  ['ambiguous_rw_final_block1_rot180.csv', 'A'],
  ['ambiguous_rw_final_block2_rot180.csv', 'A'],
  ['ambiguous_cp_final_block3_rot180.csv', 'B'],
  ['ambiguous_cp_final_block4_rot180.csv', 'B'],
];

const RW_FIRST_SEQUENCE = [
  ['ambiguous_rw_final_block1.csv',        'A'],
  ['ambiguous_rw_final_block2.csv',        'A'],
  ['ambiguous_cp_final_block1.csv',        'B'],
  ['ambiguous_cp_final_block2.csv',        'B'],
  ['ambiguous_cp_final_block3.csv',        'B'],
  ['ambiguous_cp_final_block4.csv',        'B'],
  ['ambiguous_rw_final_block1_rot180.csv', 'B'],
  ['ambiguous_rw_final_block2_rot180.csv', 'B'],
  ['ambiguous_cp_final_block1_rot180.csv', 'A'],
  ['ambiguous_cp_final_block2_rot180.csv', 'A'],
  ['ambiguous_cp_final_block3_rot180.csv', 'A'],
  ['ambiguous_cp_final_block4_rot180.csv', 'A'],
];

function buildSessionBlocks(order) {
  const sequence = { 1: CP_FIRST_SEQUENCE, 2: CP_FIRST_SEQUENCE, 3: RW_FIRST_SEQUENCE, 4: RW_FIRST_SEQUENCE }[order];
  const swapInstr = (order === 2 || order === 4);
  return sequence.map(([blockFileName, baseInstr], i) => {
    const seqType = blockFileName.includes('_cp_') ? 'CP' : 'RW';
    const instr = swapInstr ? (baseInstr === 'A' ? 'B' : 'A') : baseInstr;
    return {
      blockID: i + 1,
      seqType: seqType,
      volatility: seqType === 'CP' ? 1 : 0,
      stochasticity: 1,
      sourceImage: instr === 'A' ? 'radioactive1.png' : 'radioactive2.png',
      blockFileName: blockFileName,
      instr: instr,
    };
  });
}

const PRACTICE_VOL_BLOCK = {
  blockID: 0,
  seqType: 'CP',
  instr: '',
  volatility: 1,
  stochasticity: 1,
  sourceImage: 'radioactive1.png',
  blockFileName: 'practice_cp_volatile_block1.csv',
};

const PRACTICE_NOISE_BLOCK = {
  blockID: 0,
  seqType: 'RW',
  instr: '',
  volatility: 0,
  stochasticity: 1,
  sourceImage: 'radioactive2.png',
  blockFileName: 'practice_cp_noise_block1.csv',
};


// Task parameters

const KEY_RIGHT = 'k';  // clockwise
const KEY_LEFT = 'd';   // counter-clockwise
const KEYS_MOVE = [KEY_RIGHT, KEY_LEFT];

const ROTATION_SPEED = 1;
const CIRCLE_RADIUS = 3;
const SHIELD_DEGREES = 20;
const PI_VAL = 3.14159265359;  

const LOSS_PER_MISS = 0.25;     // points lost per beam that hits Earth
const BAR_DECREMENT = 0.0125;   

const SRC_IMG_ROOT = 'images/visit1/';

// Shield outline: 
function computeShieldCoords(degrees) {
  const radians = ((degrees * PI_VAL) / 180);
  const coords = [[0, 0]];
  for (let i = 0; i < 40; i++) {
    const angle = ((- radians) + ((radians / 20) * i));
    coords.push([((Math.sin(angle) * CIRCLE_RADIUS) * 1.1), ((Math.cos(angle) * CIRCLE_RADIUS) * 1.1)]);
  }
  return coords;
}


// PsychoJS setup

const psychoJS = new PsychoJS({
  debug: true
});

psychoJS.openWindow({
  fullscr: true,
  color: new util.Color([-0.9, -0.9, -0.6]),
  units: 'height',
  waitBlanking: true,
  backgroundImage: '',
  backgroundFit: 'none',
});

psychoJS.schedule(psychoJS.gui.DlgFromDict({
  dictionary: expInfo,
  title: expName,
  show: false
}));

const flowScheduler = new Scheduler(psychoJS);
const dialogCancelScheduler = new Scheduler(psychoJS);
psychoJS.scheduleCondition(function() { return (psychoJS.gui.dialogComponent.button === 'OK'); }, flowScheduler, dialogCancelScheduler);



// Routine helpers

// state shared by all routines
let t;
let frameN;
let continueRoutine;
let routineForceEnded;
let currentLoop;
let globalClock;
let routineTimer;

// Start a visual component
function updateStim(stim, { start = true, update, stopWhen } = {}) {
  if (start && stim.status === PsychoJS.Status.NOT_STARTED) {
    if (update) update();
    stim.tStart = t;
    stim.frameNStart = frameN;
    stim.setAutoDraw(true);
  }
  if (update && stim.status === PsychoJS.Status.STARTED) {
    update();
  }
  if (stopWhen && stim.status === PsychoJS.Status.STARTED && stopWhen(stim)) {
    stim.tStop = t;
    stim.frameNStop = frameN;
    stim.status = PsychoJS.Status.FINISHED;
    stim.setAutoDraw(false);
  }
}

// Component that should only appear after `startTime` seconds
function delayed(component, startTime) {
  return { component, startTime };
}


function makeRoutine({ name, components, logKeys, customDraw = false, checkEscape = true,
                       onBegin, afterStarted, onEachFrame, onEnd }) {
  const clock = new util.Clock();
  let entries = [];
  let comps = [];
  let keyboard = null;
  let allKeys = [];

  function begin(snapshot) {
    return async function () {
      TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
      t = 0;
      frameN = -1;
      continueRoutine = true;
      routineForceEnded = false;
      clock.reset();
      routineTimer.reset();

      entries = components().map(c => (c.component && 'startTime' in c) ? c : { component: c, startTime: 0.0 });
      comps = entries.map(e => e.component);
      keyboard = comps.find(c => c instanceof core.Keyboard) || null;

      if (onBegin) onBegin();
      if (keyboard) {
        keyboard.keys = undefined;
        keyboard.rt = undefined;
        allKeys = [];
      }
      psychoJS.experiment.addData(`${name}.started`, globalClock.getTime());
      if (afterStarted) afterStarted();

      for (const thisComponent of comps)
        if ('status' in thisComponent)
          thisComponent.status = PsychoJS.Status.NOT_STARTED;
      return Scheduler.Event.NEXT;
    };
  }

  function eachFrame() {
    return async function () {
      t = clock.getTime();
      frameN = frameN + 1;  // number of completed frames (so 0 is the first frame)

      if (onEachFrame) onEachFrame();

      for (const { component, startTime } of entries) {
        if (component instanceof core.Keyboard) {
          if (t >= startTime && component.status === PsychoJS.Status.NOT_STARTED) {
            component.tStart = t;
            component.frameNStart = frameN;
            // keyboard checking is just starting
            psychoJS.window.callOnFlip(function() { component.clock.reset(); });  // t=0 on next screen flip
            psychoJS.window.callOnFlip(function() { component.start(); });        // start on screen flip
            psychoJS.window.callOnFlip(function() { component.clearEvents(); });
          }
          if (component.status === PsychoJS.Status.STARTED) {
            const theseKeys = component.getKeys({ keyList: ['space'], waitRelease: false });
            allKeys = allKeys.concat(theseKeys);
            if (allKeys.length > 0) {
              const lastKey = allKeys[allKeys.length - 1];
              component.keys = lastKey.name;
              component.rt = lastKey.rt;
              component.duration = lastKey.duration;
              continueRoutine = false;  // a response ends the routine
            }
          }
        } else if (!customDraw) {
          updateStim(component, { start: t >= startTime });
        }
      }

      // check for quit 
      if (checkEscape && (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList: ['escape']}).length > 0)) {
        return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
      }

      // check if the Routine should terminate
      if (!continueRoutine) {  // a component has requested a forced-end of Routine
        routineForceEnded = true;
        return Scheduler.Event.NEXT;
      }

      // continue as long as at least one component is still running
      continueRoutine = comps.some(c => 'status' in c && c.status !== PsychoJS.Status.FINISHED);
      return continueRoutine ? Scheduler.Event.FLIP_REPEAT : Scheduler.Event.NEXT;
    };
  }

  function end(snapshot) {
    return async function () {
      for (const thisComponent of comps)
        if (typeof thisComponent.setAutoDraw === 'function')
          thisComponent.setAutoDraw(false);
      psychoJS.experiment.addData(`${name}.stopped`, globalClock.getTime());

      if (onEnd) onEnd();

      if (keyboard) {
        if (logKeys) {
          psychoJS.experiment.addData(`${logKeys}.keys`, keyboard.keys);
          if (typeof keyboard.keys !== 'undefined') {  
            psychoJS.experiment.addData(`${logKeys}.rt`, keyboard.rt);
            psychoJS.experiment.addData(`${logKeys}.duration`, keyboard.duration);
          }
        }
        keyboard.stop();
      }
      // reset the non-slip timer
      routineTimer.reset();

      // Routines running outside a loop should always advance the datafile row
      if (currentLoop === psychoJS.experiment) {
        psychoJS.experiment.nextEntry(snapshot);
      }
      return Scheduler.Event.NEXT;
    };
  }

  return { begin, eachFrame, end };
}

function addRoutine(scheduler, routine, snapshot) {
  scheduler.add(routine.begin(snapshot));
  scheduler.add(routine.eachFrame());
  scheduler.add(routine.end(snapshot));
}

// Runs `routines` once per entry of trialList() inside a TrialHandler loop called `name`
function addLoop(scheduler, { name, trialList, routines, onBegin, onEnd }) {
  const loopScheduler = new Scheduler(psychoJS);
  let loop;

  scheduler.add(async function () {
    TrialHandler.fromSnapshot(undefined);
    if (onBegin) onBegin();
    loop = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 1, method: TrialHandler.Method.SEQUENTIAL,
      extraInfo: expInfo, originPath: undefined,
      trialList: trialList(),
      seed: undefined, name: name
    });
    psychoJS.experiment.addLoop(loop);
    currentLoop = loop;

    for (const _entry of loop) {
      const snapshot = loop.getSnapshot();
      loopScheduler.add(importConditions(snapshot));
      for (const routine of routines) addRoutine(loopScheduler, routine, snapshot);
      loopScheduler.add(loopEndIteration(loopScheduler, snapshot));
    }
    return Scheduler.Event.NEXT;
  });

  scheduler.add(loopScheduler);

  scheduler.add(async function () {
    psychoJS.experiment.removeLoop(loop);
    if (psychoJS.experiment._unfinishedLoops.length > 0)
      currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
    else
      currentLoop = psychoJS.experiment;  // so we use addData from the experiment
    if (onEnd) onEnd();
    return Scheduler.Event.NEXT;
  });
}

function loopEndIteration(scheduler, snapshot) {
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // check if user ended loop early
      if (snapshot.finished) {
        // check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
      return Scheduler.Event.NEXT;
    }
  };
}

function importConditions(currentLoop) {
  return async function () {
    psychoJS.importAttributes(currentLoop.getCurrentTrial());
    return Scheduler.Event.NEXT;
  };
}



// Stimulus factories

function makeText({ name, text = '', pos = [0, 0], height = 0.04, wrapWidth = undefined, depth = 0.0, font = 'Inter' }) {
  return new visual.TextStim({
    win: psychoJS.window,
    name: name,
    text: text,
    font: font,
    units: undefined,
    pos: pos, draggable: false, height: height, wrapWidth: wrapWidth, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('white'), opacity: undefined,
    depth: depth
  });
}

function makeImage({ name, image, pos, size, depth }) {
  return new visual.ImageStim({
    win: psychoJS.window,
    name: name, units: undefined,
    image: image, mask: undefined,
    anchor: 'center',
    ori: 0.0,
    pos: pos,
    draggable: false,
    size: size,
    color: new util.Color([1, 1, 1]), opacity: undefined,
    flipHoriz: false, flipVert: false,
    texRes: 128.0, interpolate: true, depth: depth
  });
}

// Square ShapeStim; the actual shape is set per frame via setVertices
function makeShape({ name, size, pos, lineWidth, lineColor, fillColor, opacity = undefined, depth }) {
  return new visual.ShapeStim({
    win: psychoJS.window, name: name,
    vertices: [[(- 0.5), (- 0.5)], [(- 0.5), 0.5], [0.5, 0.5], [0.5, (- 0.5)]], size: size,
    ori: 1.0,
    pos: pos,
    draggable: false,
    anchor: 'center',
    lineWidth: lineWidth,
    lineColor: new util.Color(lineColor),
    fillColor: new util.Color(fillColor),
    colorSpace: 'rgb',
    opacity: opacity,
    depth: depth,
    interpolate: true,
  });
}

function makeRect({ name, pos, anchor = 'center', lineWidth, lineColor, fillColor, opacity = undefined, depth }) {
  return new visual.Rect({
    win: psychoJS.window, name: name,
    width: 1.0, height: 1.0,
    ori: 0.0,
    pos: pos,
    draggable: false,
    anchor: anchor,
    lineWidth: lineWidth,
    lineColor: new util.Color(lineColor),
    fillColor: new util.Color(fillColor),
    colorSpace: 'rgb',
    opacity: opacity,
    depth: depth,
    interpolate: true,
  });
}

function makeKeyboard() {
  return new core.Keyboard({psychoJS: psychoJS, clock: new util.Clock(), waitForStart: true});
}



// Experiment initialisation

let sessionBlocks;
let refRate;
let refreshMsgDur;
let isPracticeBlock = false;
let blockN = 0;
let totalReward_tot = 0;  // total reward across all blocks

// colours used in the updates
let WHITE, GREY, RED;  // GREY = rgb [0, 0, 0]

// stimuli & keyboards
let kb;        // continuous keyboard for moving the shield
let spaceKey;  // "press SPACE to continue" responses
let refRateErrorMsg;
let formPlaceholder;
let text_instructions_1, text_story, text_instructions_2, shield_miss_earth;
let shield_move, shield_centre_move, shield_bg_short_move, radioactive_move, text_move, key_mapping, text_advance_move;
let reward_bar_image, text_reward;
let prize_image, prize_text;
let text_reward_3;
let text_pracStart;
let practiceVolInstr_text, practiceVolInstr_image;
let practiceNoiseInstr_text, practiceNoiseInstr_image;
let practiceMoveCost_text;
let blockInstr_text, blockInstr_image_vol, blockInstr_image_noise;
let earth_background, harmless_area, shield, shield_centre, shield_bg_short, laser, laser_long, radioactive;
let reward_bar_red, reward_bar, progress_bar_edge, progress_bar, reward_text_top, reward_text_bottom, start_text, end_text;
let textPause, reward_text, textContinue;
let textEndExp, finalReward_text;

async function updateInfo() {
  currentLoop = psychoJS.experiment;  // right now there are no loops
  expInfo['date'] = util.MonotonicClock.getDateStr();  // timestamp
  expInfo['expName'] = expName;
  expInfo['psychopyVersion'] = '2026.1.3';
  expInfo['OS'] = window.navigator.platform;

  // store frame rate of monitor if we can measure it 
  expInfo['frameRate'] = psychoJS.window.getActualFrameRate();

  // add info from the URL:
  util.addInfoFromUrl(expInfo);
  // counterbalancing order from SONA survey code
  expInfo['order'] = String((parseInt(expInfo['participant']) % 4) + 1);
  psychoJS.setRedirectUrls(SONA_CREDIT_URL + expInfo['participant'], '');

  expInfo['visit'] = '1';
  expInfo['session'] = '1';

  psychoJS.experiment.dataFileName = `./log/sub-${expInfo['participant']}_vis-1_ses-1_task-laser_type-onlineTrain_${expInfo['date']}`;
  psychoJS.experiment.field_separator = '\t';

  return Scheduler.Event.NEXT;
}

async function experimentInit() {
  sessionBlocks = buildSessionBlocks(Number(expInfo['order']));

  WHITE = new util.Color([1, 1, 1]);
  GREY = new util.Color([0, 0, 0]);
  RED = new util.Color([1, (- 1), (- 1)]);

  // refresh rate
  refRate = psychoJS.window.getActualFrameRate();
  console.log("refRate = ", refRate);
  refRateErrorMsg = makeText({ name: 'refRateErrorMsg', text: REFRESH_RATE_ERROR_TEXT, pos: [0, (- 0.08)], height: 0.03, wrapWidth: 1.5, depth: -1.0 });

  kb = makeKeyboard();
  spaceKey = makeKeyboard();
  psychoJS.window.mouseVisible = false;

  // introduction / consent / demographics / instructions
  text_instructions_1 = makeText({ name: 'text_instructions_1', text: WELCOME_TEXT, wrapWidth: 1.5, depth: -2.0 });
  formPlaceholder = makeText({ name: 'form_placeholder', height: 0.05, depth: -1.0 });
  text_story = makeText({ name: 'text_story', text: STORY_TEXT, wrapWidth: 1.5, depth: -2.0 });
  text_instructions_2 = makeText({ name: 'text_instructions_2', text: SHIELD_TEXT, pos: [0, 0.25], wrapWidth: 1.5 });
  shield_miss_earth = makeImage({ name: 'shield_miss_earth', image: 'images/shield_miss_earth.png', pos: [0, -0.25], size: [0.4, 0.373], depth: -1.0 });

  // practiceMove
  shield_move = makeShape({ name: 'shield_move', size: [0.053, 0.053], pos: [0, (- 0.025)], lineWidth: 1.0, lineColor: [0, 0, 0], fillColor: 'white', depth: -1 });
  shield_centre_move = makeShape({ name: 'shield_centre_move', size: [0.053, 0.053], pos: [0, (- 0.025)], lineWidth: 3.0, lineColor: 'blue', fillColor: 'blue', depth: -2 });
  shield_bg_short_move = makeShape({ name: 'shield_bg_short_move', size: [0.048, 0.048], pos: [0, (- 0.025)], lineWidth: 1.0, lineColor: 'white', fillColor: 'white', depth: -3 });
  radioactive_move = makeImage({ name: 'radioactive_move', image: 'images/radioactive1.png', pos: [0, (- 0.025)], size: [0.1, 0.1], depth: -4.0 });
  text_move = makeText({ name: 'text_move', text: MOVE_TEXT, pos: [0, 0.3], wrapWidth: 1.5, depth: -5.0 });
  key_mapping = makeImage({ name: 'key_mapping', image: 'images/key_mapping.png', pos: [0, (- 0.21)], size: [0.25, 0.15], depth: -6.0 });
  text_advance_move = makeText({ name: 'text_advance_move', text: CONTINUE_TEXT, pos: [0, (- 0.4)], wrapWidth: 1.5, depth: -7.0 });

  // reward / prize / moveCost / start
  reward_bar_image = makeImage({ name: 'reward_bar_image', image: 'images/reward_bar_red_3.png', pos: [0.67, (- 0.05)], size: [0.28, 0.6], depth: 0.0 });
  text_reward = makeText({ name: 'text_reward', text: REWARD_TEXT, wrapWidth: 1.1, depth: -1.0 });
  prize_image = makeText({ name: 'prize_image', text: '🎁', font: 'Arial', pos: [0, 0.28], height: 0.12 });
  prize_text = makeText({ name: 'prize_text', text: PRIZE_TEXT, pos: [0, -0.05], wrapWidth: 1.1, depth: -1.0 });
  text_reward_3 = makeText({ name: 'text_reward_3', text: MOVE_COST_TEXT, wrapWidth: 1.5 });
  text_pracStart = makeText({ name: 'text_pracStart', text: PRACTICE_START_TEXT, wrapWidth: 1.5 });

  // practice instructions
  practiceVolInstr_text = makeText({ name: 'practiceVolInstr_text', text: PRACTICE_VOL_INSTR_TEXT, pos: [0, 0.02], height: 0.032, wrapWidth: 1.3 });
  practiceVolInstr_image = makeImage({ name: 'practiceVolInstr_image', image: 'images/image_vol.png', pos: [0, 0.35], size: [0.22, 0.22], depth: -1.0 });
  practiceNoiseInstr_text = makeText({ name: 'practiceNoiseInstr_text', text: PRACTICE_NOISE_INSTR_TEXT, pos: [0, 0.02], height: 0.032, wrapWidth: 1.3 });
  practiceNoiseInstr_image = makeImage({ name: 'practiceNoiseInstr_image', image: 'images/image_noise.png', pos: [0, 0.35], size: [0.22, 0.22], depth: -1.0 });
  practiceMoveCost_text = makeText({ name: 'practiceMoveCost_text', text: PRACTICE_MOVE_COST_TEXT, wrapWidth: 1.3 });

  // block instructions (text is set per block based on instr 'A' or 'B')
  blockInstr_text = makeText({ name: 'blockInstr_text', pos: [0, 0.19], wrapWidth: 1.5 });
  blockInstr_image_vol = makeImage({ name: 'blockInstr_image_vol', image: 'images/image_vol.png', pos: [0, -0.24], size: [0.38, 0.38], depth: -1.0 });
  blockInstr_image_noise = makeImage({ name: 'blockInstr_image_noise', image: 'images/image_noise.png', pos: [0, -0.24], size: [0.38, 0.38], depth: -2.0 });

  // trial
  earth_background = makeImage({ name: 'earth_background', image: 'images/earth.png', pos: [0, 0], size: [0.75, 0.75], depth: -1.0 });
  harmless_area = new visual.Polygon({
    win: psychoJS.window, name: 'harmless_area',
    edges: 100, size: [0.32, 0.32],
    ori: 0.0,
    pos: [0, (- 0.025)],
    draggable: false,
    anchor: 'center',
    lineWidth: 1.0,
    lineColor: new util.Color([0, 0, 0]),
    fillColor: new util.Color([0, 0, 0]),
    colorSpace: 'rgb',
    opacity: undefined,
    depth: -2,
    interpolate: true,
  });
  shield = makeShape({ name: 'shield', size: [0.053, 0.053], pos: [0, (- 0.025)], lineWidth: 1.0, lineColor: 'white', fillColor: 'white', depth: -3 });
  shield_centre = makeShape({ name: 'shield_centre', size: [0.048, 0.048], pos: [0, (- 0.025)], lineWidth: 3.0, lineColor: 'blue', fillColor: 'blue', depth: -4 });
  shield_bg_short = makeShape({ name: 'shield_bg_short', size: [0.048, 0.048], pos: [0, (- 0.025)], lineWidth: 1.0, lineColor: 'white', fillColor: 'white', depth: -5 });
  laser = makeShape({ name: 'laser', size: [0.048, 0.048], pos: [0, (- 0.025)], lineWidth: 10.0, lineColor: 'red', fillColor: 'red', depth: -6 });
  laser_long = makeShape({ name: 'laser_long', size: [0.048, 0.048], pos: [0, (- 0.025)], lineWidth: 10.0, lineColor: 'red', fillColor: 'red', opacity: 1.0, depth: -7 });
  radioactive = makeImage({ name: 'radioactive', image: 'default.png', pos: [0, (- 0.025)], size: [0.1, 0.1], depth: -8.0 });
  reward_bar_red = makeRect({ name: 'reward_bar_red', pos: [0, 0], anchor: 'bottom-center', lineWidth: 1.0, lineColor: 'white', fillColor: 'white', opacity: 1.0, depth: -9 });
  reward_bar = makeRect({ name: 'reward_bar', pos: [0, 0], lineWidth: 1.0, lineColor: 'blue', fillColor: 'blue', depth: -10 });
  progress_bar_edge = makeRect({ name: 'progress_bar_edge', pos: [0, (- 0.45)], lineWidth: 2.0, lineColor: 'green', fillColor: [0, 0, 0], depth: -11 });
  progress_bar = makeRect({ name: 'progress_bar', pos: [0, 0], lineWidth: 1.0, lineColor: 'green', fillColor: 'green', depth: -12 });
  reward_text_top = makeText({ name: 'reward_text_top', pos: [0.6, 0.25], height: 0.05, depth: -13.0 });
  reward_text_bottom = makeText({ name: 'reward_text_bottom', pos: [0.6, (- 0.35)], height: 0.05, depth: -14.0 });
  start_text = makeText({ name: 'start_text', text: 'Start', pos: [(- 0.47), (- 0.45)], depth: -15.0 });
  end_text = makeText({ name: 'end_text', text: 'End', pos: [0.47, (- 0.45)], depth: -16.0 });

  // block end
  textPause = makeText({ name: 'textPause', pos: [0, 0.3], height: 0.05, depth: -1.0 });
  reward_text = makeText({ name: 'reward_text', height: 0.05, depth: -2.0 });
  textContinue = makeText({ name: 'textContinue', text: CONTINUE_TEXT, pos: [0, (- 0.43)], height: 0.05, wrapWidth: 1.5, depth: -3.0 });

  // experiment end
  textEndExp = makeText({ name: 'textEndExp', text: EXP_END_TEXT, pos: [0, (- 0.05)], height: 0.05, depth: -1.0 });
  finalReward_text = makeText({ name: 'finalReward_text', pos: [0, 0.15], height: 0.05, depth: -2.0 });

  // Create timers
  globalClock = new util.Clock();  // to track the time since experiment started
  routineTimer = new util.CountdownTimer();  // to track time remaining of each (non-slip) routine

  return Scheduler.Event.NEXT;
}



// Shield movement (shared by practiceMove and trial)

// Returns whether a movement key was released this frame, whether any movement key is
// currently registered, and the direction (+1 clockwise, -1 counter-clockwise, 0 none).
function readShieldKeys() {
  const released = kb.getKeys({keyList: KEYS_MOVE, waitRelease: true, clear: true}).length > 0;
  const keys = kb.getKeys({keyList: KEYS_MOVE, waitRelease: false, clear: released});
  let direction = 0;
  if (keys.length > 0) {
    const lastKey = keys[keys.length - 1];
    if (lastKey.name === KEY_RIGHT && lastKey.duration == undefined) {
      direction = 1;
    } else if (lastKey.name === KEY_LEFT && lastKey.duration == undefined) {
      direction = -1;
    }
  }
  return { released, pressed: keys.length > 0, direction };
}

function restartShieldKeyboard() {
  kb.clock.reset();
  kb.start();
  kb.clearEvents();
}



// Simple routines

const checkRefRateRoutine = makeRoutine({
  name: 'checkRefRate',
  components: () => [refRateErrorMsg],
  customDraw: true,
  onBegin: () => {
    // if refresh rate over 70 or under 50, show the error message, otherwise skip this routine
    refreshMsgDur = (refRate > 70 || refRate < 50) ? 10000 : 0;
  },
  onEachFrame: () => {
    if (refRate <= 70 && refRate >= 50) {
      continueRoutine = false;  // skip this routine if refresh rate is okay
    }
    updateStim(refRateErrorMsg, {
      stopWhen: () => t >= 0.0 + refreshMsgDur - psychoJS.window.monitorFramePeriod * 0.75,  // most of one frame period left
    });
  },
  onEnd: () => {
    // if refresh rate over 70 or under 50, stop the task after message is shown
    if (refRate > 70 || refRate < 50) {
      psychoJS.quit();
    }
  },
});

const introductionRoutine = makeRoutine({
  name: 'introduction',
  components: () => [text_instructions_1, spaceKey],
  logKeys: 'key_resp_i1',
});

// Shows an HTML form (consent / demographics) in an iframe and saves its fields
function showHtmlForm(src) {
  const params = new Map;
  $(window).data('continueRoutine', true);
  $(document).ready(function () {
    $('body').append('<div id="iframe-o" style="visibility:hidden;position:relative;display:flex;justify-content:center;align-items:center;width:100%;height:calc(100vh - 20px);"><iframe id="iframe" src="' + src + '" style="width:100%;height:calc(100% - 4px);border:0px;"></iframe></div>');
    $('#iframe').on('load', function () {
      let contents = $(this).contents().find('html');
      let width = contents.width();
      if (width < $('#iframe').width() - 20) $('#iframe').width(contents.width() + 20);
      if (contents.width() != width) contents.css('width', '');
      let height = contents.height();
      if (height < $('#iframe').height() - 20) $('#iframe').height(contents.height() + 20);
      if (contents.height() != height) contents.css('height', '');
      $('#iframe-o').css('visibility', 'visible');
      $(this).contents().find('form').on('submit', function (e) {
        e.preventDefault();
        $.each($(this).serializeArray(), function (i, param) {
          if (!params.has(param.name)) { params.set(param.name, param.value); }
          else { params.set(param.name, $.makeArray(params.get(param.name))); params.get(param.name).push(param.value); }
        });
        for (const [name, value] of params) { psychoJS.experiment.addData(name, value); }
        $(window).data('continueRoutine', false);
      });
    });
  });
}

function makeFormRoutine(name, src) {
  return makeRoutine({
    name: name,
    components: () => [formPlaceholder],
    checkEscape: false,
    onBegin: () => showHtmlForm(src),
    onEachFrame: () => {
      continueRoutine = $(window).data('continueRoutine');
      if (!continueRoutine) $('#iframe-o').remove();
    },
  });
}

const consentRoutine = makeFormRoutine('consent', 'piscf.html');
const demographicsRoutine = makeFormRoutine('demographics', 'demographics.html');

const instructions1Routine = makeRoutine({
  name: 'instructions_1',
  components: () => [text_story, spaceKey],
});

const instructions2Routine = makeRoutine({
  name: 'instructions_2',
  components: () => [text_instructions_2, shield_miss_earth, spaceKey],
});

const rewardRoutine = makeRoutine({
  name: 'reward',
  components: () => [reward_bar_image, text_reward, spaceKey],
  logKeys: 'key_resp_reward',
});

const prizeRoutine = makeRoutine({
  name: 'prize',
  components: () => [prize_image, prize_text, spaceKey],
  logKeys: 'key_resp_prize',
});

const moveCostRoutine = makeRoutine({
  name: 'moveCost',
  components: () => [text_reward_3, spaceKey],
  logKeys: 'key_resp_reward_2',
});

const startRoutine = makeRoutine({
  name: 'start',
  components: () => [text_pracStart, spaceKey],
  logKeys: 'key_resp_pracStart',
});

const practiceVolInstrRoutine = makeRoutine({
  name: 'practiceVolInstr',
  components: () => [practiceVolInstr_text, practiceVolInstr_image, spaceKey],
});

const practiceNoiseInstrRoutine = makeRoutine({
  name: 'practiceNoiseInstr',
  components: () => [practiceNoiseInstr_text, practiceNoiseInstr_image, spaceKey],
});

const practiceMoveCostRoutine = makeRoutine({
  name: 'practiceMoveCost',
  components: () => [practiceMoveCost_text, spaceKey],
});

// `instr` is set per block by importConditions
const blockInstrRoutine = makeRoutine({
  name: 'blockInstr',
  components: () => [blockInstr_text, (instr === 'A') ? blockInstr_image_vol : blockInstr_image_noise, spaceKey],
  logKeys: 'key_resp_blockInstr',
  onBegin: () => blockInstr_text.setText(BLOCK_TEXTS[instr] || BLOCK_TEXTS['A']),
  afterStarted: () => psychoJS.experiment.addData('blockInstr.instr', instr),
});



// practiceMove routine

let shieldRotation;
const SHIELD_COORDS = computeShieldCoords(SHIELD_DEGREES);
const SHIELD_CENTRE_MOVE_VERTICES = [[0, 0], [0, (CIRCLE_RADIUS * 1.1)]];

const practiceMoveRoutine = makeRoutine({
  name: 'practiceMove',
  components: () => [shield_move, shield_centre_move, shield_bg_short_move, radioactive_move, text_move, key_mapping, text_advance_move, spaceKey],
  logKeys: 'key_resp_move',
  customDraw: true,
  onBegin: () => {
    shieldRotation = 0;
    restartShieldKeyboard();
  },
  onEachFrame: () => {
    // keep the radiation source on top of the shield
    radioactive_move.setAutoDraw(false);
    radioactive_move.setAutoDraw(true);

    const { direction } = readShieldKeys();
    if (direction === 1) {
      shieldRotation += ROTATION_SPEED;
    } else if (direction === -1) {
      shieldRotation -= ROTATION_SPEED;
    }

    updateStim(shield_move, { update: () => {
      shield_move.setOri(shieldRotation, false);
      shield_move.setVertices(SHIELD_COORDS, false);
    }});
    updateStim(shield_centre_move, { update: () => {
      shield_centre_move.setOri(shieldRotation, false);
      shield_centre_move.setVertices(SHIELD_CENTRE_MOVE_VERTICES, false);
    }});
    updateStim(shield_bg_short_move, { update: () => {
      shield_bg_short_move.setFillColor(GREY, false);
      shield_bg_short_move.setOri(shieldRotation, false);
      shield_bg_short_move.setVertices(SHIELD_COORDS, false);
      shield_bg_short_move.setLineColor(GREY, false);
    }});
    updateStim(radioactive_move);
    updateStim(text_move);
    updateStim(key_mapping);
    updateStim(text_advance_move);
  },
});



// trial routine: one block of the laser task

const SHIELD_CENTRE_VERTICES = [[0, 0], [0, (CIRCLE_RADIUS * 1.2)]];
const LASER_VERTICES = [[0, 0], [0, (CIRCLE_RADIUS * 1.1)]];
const LASER_LONG_VERTICES = [[0, 0], [0, (CIRCLE_RADIUS * 1.4)]];

let shieldDegrees;
let shieldCoords;
let obsPos, truePos, trueVar;  // beam sequence of the current block
let nFrames;
let currentFrame;
let laserRotation;
let trueMean;
let trueVariance;
let currentHit;
let laser_on;         // number of frames a beam stays visible
let laser_frame_ct;
let laser_long_opacity;
let totalReward;
let bar_length;
let bar_position;
let red_bar_length = 0;
let red_bar_opac;
let bottom_amount;
let bottom_amount_text;
let top_amount_text;
let progress_bar_length;
let progress_bar_position;
let triggerValue;
let newTriggerValue;
let sendTrigger;
let sendResponseTriggers;
let keyReleaseThisFrame;

// reward bar reached zero but there are points left: start the next 10-point level
function refillRewardBar() {
  bar_length = 0.5;
  bar_position = -0.05;
  bottom_amount = (bottom_amount - 10);
  bottom_amount_text = `${bottom_amount.toFixed(0)} points`;
}

// no points left: show the last (0-10 points) level
function emptyRewardBar() {
  bar_length = 0.25;
  bar_position = -0.175;
  bottom_amount = 0;
  bottom_amount_text = `${bottom_amount.toFixed(0)} points`;
  totalReward = 0;
}

function logFrameData() {
  psychoJS.experiment.addData('blockN', blockN);
  psychoJS.experiment.addData('blockID', blockID);
  psychoJS.experiment.addData('sourceImage', sourceImage);
  psychoJS.experiment.addData('currentFrame', currentFrame);
  psychoJS.experiment.addData('laserRotation', laserRotation);
  psychoJS.experiment.addData('shieldRotation', shieldRotation);
  psychoJS.experiment.addData('shieldDegrees', shieldDegrees);
  psychoJS.experiment.addData('currentHit', currentHit);
  psychoJS.experiment.addData('totalReward', totalReward);
  psychoJS.experiment.addData('sendTrigger', sendTrigger);
  psychoJS.experiment.addData('triggerValue', triggerValue);
  psychoJS.experiment.addData('trueMean', trueMean);
  psychoJS.experiment.addData('trueVariance', trueVariance);
  psychoJS.experiment.addData('volatility', volatility);
  psychoJS.experiment.addData('seqType', seqType);
  psychoJS.experiment.addData('instruction_framing', instr);
  psychoJS.experiment.addData('reward', totalReward);
  psychoJS.experiment.nextEntry();  // save data as new row
}

// `blockFileName`, `sourceImage`, `blockID`, `volatility`, `seqType` and `instr`
// are set per block by importConditions
const trialRoutine = makeRoutine({
  name: 'trial',
  components: () => [earth_background, harmless_area, shield, shield_centre, shield_bg_short, laser, laser_long, radioactive,
                     reward_bar_red, reward_bar, progress_bar_edge, progress_bar, reward_text_top, reward_text_bottom, start_text, end_text],
  customDraw: true,

  onBegin: () => {
    shieldDegrees = SHIELD_DEGREES;
    shieldCoords = computeShieldCoords(shieldDegrees);

    const storedStream = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 1, method: TrialHandler.Method.SEQUENTIAL,
      extraInfo: expInfo, originPath: undefined,
      trialList: 'sequences/' + blockFileName,
      seed: undefined, name: 'storedStream_np'});
    obsPos = storedStream.trialList.map(row => Number.parseFloat(row.obs_pos));
    truePos = storedStream.trialList.map(row => Number.parseFloat(row.true_pos));
    trueVar = storedStream.trialList.map(row => Number.parseFloat(row.true_var));

    shieldRotation = 360;
    nFrames = (obsPos.length - 1);
    currentFrame = 0;
    laserRotation = obsPos[0];
    trueMean = truePos[0];
    trueVariance = trueVar[0];

    sendResponseTriggers = true;

    bar_length = 0.5;
    bar_position = -0.05;
    bottom_amount = 90;
    bottom_amount_text = `${bottom_amount.toFixed(0)} points`;
    totalReward = 100;

    // a beam stays visible as long as the shortest run of identical positions in the sequence
    const counts = new Map();
    for (const angle of obsPos) counts.set(angle, (counts.get(angle) || 0) + 1);
    laser_on = Math.min(...counts.values());
    laser_frame_ct = 0;

    laser.setAutoDraw(false);
    laser_long.setAutoDraw(false);

    progress_bar_length = 0;
    progress_bar_position = -0.4;

    red_bar_opac = 0;  // set red bar to transparent to start with

    restartShieldKeyboard();
    radioactive.setImage(SRC_IMG_ROOT + sourceImage);
  },

  onEachFrame: () => {
    // redraw laser and source every frame so they stay on top of the shield
    laser.setAutoDraw(false);
    laser_long.setAutoDraw(false);
    radioactive.setAutoDraw(false);
    laser.setAutoDraw(true);
    laser_long.setAutoDraw(true);
    radioactive.setAutoDraw(true);

    if (bar_length <= 0) refillRewardBar();
    if (totalReward <= 0) emptyRewardBar();

    // --- shield movement ---
    sendTrigger = false;
    keyReleaseThisFrame = false;
    triggerValue = 0;

    const { released, pressed, direction } = readShieldKeys();
    if (released) {
      triggerValue = 7;
      sendTrigger = true;
      keyReleaseThisFrame = true;
    }
    if (pressed) {
      if (direction === 1) {
        shieldRotation += ROTATION_SPEED;
        newTriggerValue = 3;
      } else if (direction === -1) {
        shieldRotation -= ROTATION_SPEED;
        newTriggerValue = 4;
      }
      if (sendResponseTriggers) {
        triggerValue = newTriggerValue;
        sendTrigger = true;
        sendResponseTriggers = false;
      }
    }

    // --- laser ---
    if (currentFrame < nFrames) {
      laserRotation = obsPos[currentFrame];
      trueMean = truePos[currentFrame];
      trueVariance = trueVar[currentFrame];
      if (currentFrame > 0) {
        if (obsPos[currentFrame] !== obsPos[currentFrame - 1]) {
          laser_frame_ct = 0;
        } else {
          laser_frame_ct = (laser_frame_ct + 1);
        }
        const showLaser = (laser_frame_ct <= laser_on);
        laser.setAutoDraw(showLaser);
        laser_long.setAutoDraw(showLaser);
      }
    }

    currentHit = ((((shieldRotation - laserRotation + shieldDegrees) % 360)) + 360) % 360 <= (2 * shieldDegrees);

    // --- reward: evaluated once per new beam ---
    const newBeam = (currentFrame === 0) || (obsPos[currentFrame] !== obsPos[currentFrame - 1]);
    if (newBeam) {
      if (!sendTrigger) {
        triggerValue = currentHit ? 1 : 2;
        sendTrigger = true;
      }
      if (currentHit) {
        red_bar_length = 0;
        red_bar_opac = 0;  // if beam hit shield, hide red bar
      } else if (totalReward >= LOSS_PER_MISS) {
        bar_length = (bar_length - BAR_DECREMENT);
        bar_position = bar_position - 0.5 * BAR_DECREMENT;
        totalReward = (totalReward - LOSS_PER_MISS);
        red_bar_length = BAR_DECREMENT;
        red_bar_opac = 1;  // if beam didn't hit shield, show red bar
      } else {
        // points at 0 — bar stays at minimum, no red flash
        totalReward = 0;
        red_bar_length = 0;
        red_bar_opac = 0;
      }
    }

    // clamp bar within the same frame it hits 0 — prevents one-frame invisible flash
    if (bar_length <= 0) {
      if (totalReward > 0) refillRewardBar();
      else emptyRewardBar();
    }

    laser_long_opacity = currentHit ? 0 : 1;

    if (keyReleaseThisFrame) {
      sendResponseTriggers = true;
    }

    // --- save data ---
    if (currentFrame < nFrames) {
      currentFrame = (currentFrame + 1);
    }
    logFrameData();

    progress_bar_length = (progress_bar_length + (0.8 / nFrames));
    progress_bar_position = progress_bar_position + (0.4 / nFrames);

    if (currentFrame === nFrames) {
      laser.setAutoDraw(false);
      laser_long.setAutoDraw(false);
      radioactive.setAutoDraw(false);
    }

    // keep top label in sync with current totalReward every frame
    top_amount_text = `${Math.max(0, totalReward).toFixed(2)} points`;

    // --- draw components (all stop after nFrames) ---
    const endOfBlock = stim => frameN >= (stim.frameNStart + nFrames);

    updateStim(earth_background, { stopWhen: endOfBlock });
    updateStim(harmless_area, { stopWhen: endOfBlock });
    updateStim(shield, { stopWhen: endOfBlock, update: () => {
      shield.setFillColor(WHITE, false);
      shield.setOri(shieldRotation, false);
      shield.setVertices(shieldCoords, false);
      shield.setLineColor(GREY, false);
    }});
    updateStim(shield_centre, { stopWhen: endOfBlock, update: () => {
      shield_centre.setOri(shieldRotation, false);
      shield_centre.setVertices(SHIELD_CENTRE_VERTICES, false);
    }});
    updateStim(shield_bg_short, { stopWhen: endOfBlock, update: () => {
      shield_bg_short.setFillColor(GREY, false);
      shield_bg_short.setOri(shieldRotation, false);
      shield_bg_short.setVertices(shieldCoords, false);
      shield_bg_short.setLineColor(GREY, false);
    }});
    updateStim(laser, { stopWhen: endOfBlock, update: () => {
      laser.setOri(laserRotation, false);
      laser.setVertices(LASER_VERTICES, false);
    }});
    updateStim(laser_long, { stopWhen: endOfBlock, update: () => {
      laser_long.setOpacity(laser_long_opacity, false);
      laser_long.setOri(laserRotation, false);
      laser_long.setVertices(LASER_LONG_VERTICES, false);
    }});
    updateStim(radioactive, { stopWhen: endOfBlock });
    updateStim(reward_bar_red, { stopWhen: endOfBlock, update: () => {
      reward_bar_red.setFillColor(RED, false);
      reward_bar_red.setOpacity(red_bar_opac, false);
      reward_bar_red.setPos([0.6, ((- 0.3) + bar_length)], false);
      reward_bar_red.setSize([0.05, red_bar_length], false);
      reward_bar_red.setLineColor(RED, false);
    }});
    updateStim(reward_bar, { stopWhen: endOfBlock, update: () => {
      reward_bar.setPos([0.6, bar_position], false);
      reward_bar.setSize([0.05, bar_length], false);
    }});
    updateStim(progress_bar_edge, { stopWhen: endOfBlock, update: () => {
      progress_bar_edge.setSize([0.8, 0.05], false);
    }});
    updateStim(progress_bar, { stopWhen: endOfBlock, update: () => {
      progress_bar.setPos([progress_bar_position, (- 0.45)], false);
      progress_bar.setSize([progress_bar_length, 0.05], false);
    }});
    updateStim(reward_text_top, { stopWhen: endOfBlock, update: () => {
      reward_text_top.setText(top_amount_text, false);
    }});
    updateStim(reward_text_bottom, { stopWhen: endOfBlock, update: () => {
      reward_text_bottom.setText(bottom_amount_text, false);
    }});
    updateStim(start_text, { stopWhen: endOfBlock });
    updateStim(end_text, { stopWhen: endOfBlock });
  },

  onEnd: () => {
    totalReward_tot = (totalReward_tot + totalReward);
  },
});



// Block end & experiment end

const blockEndTextRoutine = makeRoutine({
  name: 'blockEndText',
  components: () => [textPause, reward_text, delayed(textContinue, 1.0), delayed(spaceKey, 1.0)],
  logKeys: 'key_resp_blockEnd',
  onBegin: () => {
    if (!isPracticeBlock) blockN += 1;
    let blockEnd_text;
    if (isPracticeBlock) {
      blockEnd_text = "Well done, you just finished the practice block!\n\nThe real experiment will now begin.";
    } else {
      let blockFeedback;
      if (totalReward > 38) {
        blockFeedback = "Well done!";
      } else if (totalReward >= 13) {
        blockFeedback = "Not bad!";
      } else {
        blockFeedback = "Keep going! Try to follow the beam more closely next round.";
      }
      blockEnd_text = blockFeedback + "\n\nYou just finished block " + blockN + " of 12.\nIf you wish, you can now take a short break.";
    }
    textPause.setText(blockEnd_text);
    reward_text.setText("In this block, you earned: " + totalReward.toFixed(2) + " points");
  },
});

const expEndTextRoutine = makeRoutine({
  name: 'expEndText',
  components: () => [textEndExp, finalReward_text, spaceKey],
  onBegin: () => {
    const totalReward_tot_round = totalReward_tot.toFixed(2);
    // save the final total reward
    psychoJS.experiment.addData('bonus', totalReward_tot_round);
    finalReward_text.setText("In total you collected " + totalReward_tot_round + " points");
  },
});



// Quit

async function quitPsychoJS(message, isCompleted) {
  try {
    if (psychoJS.experiment.isEntryEmpty()) {
      psychoJS.experiment.nextEntry();
    }
    psychoJS.window.close();
    psychoJS.quit({message: message, isCompleted: isCompleted});
  } catch(e) {
    console.error('Error during quit:', e);
    // Redirect to SONA even if saving failed
    if (isCompleted) {
      window.location.href = SONA_CREDIT_URL + expInfo['participant'];
    }
  }
  return Scheduler.Event.QUIT;
}



// Experiment flow


// flowScheduler gets run if the participants presses OK
flowScheduler.add(updateInfo); // add timeStamp
flowScheduler.add(experimentInit);
addRoutine(flowScheduler, checkRefRateRoutine);
addRoutine(flowScheduler, introductionRoutine);
addRoutine(flowScheduler, consentRoutine);
addRoutine(flowScheduler, demographicsRoutine);
addRoutine(flowScheduler, instructions1Routine);
addRoutine(flowScheduler, instructions2Routine);
addRoutine(flowScheduler, practiceMoveRoutine);
addRoutine(flowScheduler, rewardRoutine);
addRoutine(flowScheduler, prizeRoutine);
addRoutine(flowScheduler, moveCostRoutine);
addRoutine(flowScheduler, startRoutine);

// ---- Practice phase
addRoutine(flowScheduler, practiceVolInstrRoutine);
addRoutine(flowScheduler, practiceMoveCostRoutine);
addLoop(flowScheduler, {
  name: 'practiceVolBlocks',
  trialList: () => [PRACTICE_VOL_BLOCK],
  routines: [trialRoutine],
  onBegin: () => { isPracticeBlock = true; },
  // isPracticeBlock stays true until after stable, high noise practice
});
addRoutine(flowScheduler, practiceNoiseInstrRoutine);
addRoutine(flowScheduler, practiceMoveCostRoutine);
addLoop(flowScheduler, {
  name: 'practiceNoiseBlocks',
  trialList: () => [PRACTICE_NOISE_BLOCK],
  routines: [trialRoutine, blockEndTextRoutine],
  onBegin: () => { isPracticeBlock = true; },
  onEnd: () => { isPracticeBlock = false; },
});

// ---- Experiment blocks ----
addLoop(flowScheduler, {
  name: 'blocks',
  trialList: () => sessionBlocks,
  routines: [blockInstrRoutine, trialRoutine, blockEndTextRoutine],
});

addRoutine(flowScheduler, expEndTextRoutine);
flowScheduler.add(quitPsychoJS, 'Thank you for your patience.', true);

// quit if user presses Cancel in dialog box:
dialogCancelScheduler.add(quitPsychoJS, 'Thank you for your patience.', false);

const DEFAULT_PNG_URL = 'https://pavlovia.org/assets/default/default.png';
const RESOURCE_FILES = [
  'images/radioactive1.png',
  'images/key_mapping.png',
  'images/reward_bar_red_3.png',
  'default.png',
  'images/earth.png',
  'images/visit1/radioactive1.png',
  'images/visit1/radioactive2.png',
  'sequences/ambiguous_cp_final_block1.csv',
  'sequences/ambiguous_cp_final_block2.csv',
  'sequences/ambiguous_cp_final_block3.csv',
  'sequences/ambiguous_cp_final_block4.csv',
  'sequences/ambiguous_cp_final_block1_rot180.csv',
  'sequences/ambiguous_cp_final_block2_rot180.csv',
  'sequences/ambiguous_cp_final_block3_rot180.csv',
  'sequences/ambiguous_cp_final_block4_rot180.csv',
  'sequences/ambiguous_rw_final_block1.csv',
  'sequences/ambiguous_rw_final_block2.csv',
  'sequences/ambiguous_rw_final_block1_rot180.csv',
  'sequences/ambiguous_rw_final_block2_rot180.csv',
  'sequences/practice_cp_volatile_block1.csv',
  'sequences/practice_cp_noise_block1.csv',
  'piscf.html',
  'demographics.html',
  'images/shield_miss_earth.png',
  'images/image_vol.png',
  'images/image_noise.png',
];

psychoJS.start({
  expName: expName,
  expInfo: expInfo,
  resources: RESOURCE_FILES.map(file => ({'name': file, 'path': file === 'default.png' ? DEFAULT_PNG_URL : file})),
});

psychoJS.experimentLogger.setLevel(core.Logger.ServerLevel.WARNING);
