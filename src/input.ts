// TODO(feature): Tap and hold (tap, hold and drag)
// TODO(feature): keyboard, mouse input
// TODO(fix): Don't register drag when one finger is removed after two finger gesture
// TEST: How does mouse and touchpad affect touch inputs
import { LightUserData } from "love";
import {
  doubleTapDistance,
  doubleTapTime,
  tapMaxDuration,
  tapMoveThreshold,
} from "./constants";
import { addListner, EngineEvents } from "./dispatcher";

interface Vec2 {
  x: number;
  y: number;
}

interface Touch {
  x: number;
  y: number;
  dx: number;
  dy: number;
  startX: number;
  startY: number;
  moved: boolean;
  startTime: number;
}

export const gestures = {
  get drag(): Readonly<typeof _drag> {
    return _drag;
  },
  get pan(): Readonly<typeof _pan> {
    return _pan;
  },
  get pinch(): Readonly<typeof _pinch> {
    return _pinch;
  },
};

const _drag: Vec2 = { x: 0, y: 0 };
const _pan: Vec2 = { x: 0, y: 0 };
let _pinch = 0;

let onTap: ((x: number, y: number) => void) | undefined = undefined;
let onDoubleTap: ((x: number, y: number) => void) | undefined = undefined;
let onDrag: ((dx: number, dy: number) => void) | undefined = undefined;
let onPan: ((dx: number, dy: number) => void) | undefined = undefined;
let onPinch: ((dist: number) => void) | undefined = undefined;

const touches = new Map<LightUserData<"Touch">, Touch>();
let pendingTap: { x: number; y: number; tapTime: number } | undefined =
  undefined;
let lastPinchDist: number | undefined = undefined;

const touchpressed: EngineEvents["touchpressed"] = (
  id,
  x,
  y,
  dx,
  dy,
  _pressure,
) => {
  touches.set(id, {
    x,
    y,
    dx,
    dy,
    startX: x,
    startY: y,
    moved: false,
    startTime: love.timer.getTime(),
  });
  lastPinchDist = undefined;

  for (const [_, touch] of touches) {
    touch.dx = 0;
    touch.dy = 0;
  }
};

const touchmoved: EngineEvents["touchmoved"] = (
  id,
  x,
  y,
  dx,
  dy,
  _pressure,
) => {
  const t = touches.get(id);
  if (!t) {
    return;
  }

  t.x = x;
  t.y = y;
  t.dx += dx;
  t.dy += dy;
  if (
    !t.moved &&
    (Math.abs(t.x - t.startX) > tapMoveThreshold ||
      Math.abs(t.y - t.startY) > tapMoveThreshold)
  ) {
    t.moved = true;
  }
};

const touchreleased: EngineEvents["touchreleased"] = (
  id,
  _x,
  _y,
  _dx,
  _dy,
  _pressure,
) => {
  const t = touches.get(id);
  if (!t) {
    return;
  }
  touches.delete(id);
  lastPinchDist = undefined;
  for (const [_, touch] of touches) {
    touch.dx = 0;
    touch.dy = 0;
  }

  const now = love.timer.getTime();
  const held = now - t.startTime;
  if (t.moved || held > tapMaxDuration || touches.size !== 1) {
    return;
  }

  if (!pendingTap) {
    pendingTap = {
      x: t.startX,
      y: t.startY,
      tapTime: now,
    };
  } else {
    const dx = pendingTap.x - t.x;
    const dy = pendingTap.y - t.y;
    const dist = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));

    if (dist < doubleTapDistance && now - pendingTap.tapTime < doubleTapTime) {
      onDoubleTap?.(pendingTap.x, pendingTap.y);
      pendingTap = undefined;
    }
  }
};

const focus: EngineEvents["focus"] = (focused) => {
  if (!focused) {
    reset();
  }
};

function resetGestures() {
  _drag.x = 0;
  _drag.y = 0;
  _pan.x = 0;
  _pan.y = 0;
  _pinch = 0;
}
function reset() {
  _drag.x = 0;
  _drag.y = 0;
  _pan.x = 0;
  _pan.y = 0;
  _pinch = 0;
  pendingTap = undefined;
  lastPinchDist = 0;
  touches.clear();
}

export function resetCallbacks() {
  onTap = undefined;
  onDoubleTap = undefined;
  onDrag = undefined;
  onPan = undefined;
  onPinch = undefined;
}

const update: EngineEvents["update"] = (_dt) => {
  resetGestures();

  if (pendingTap) {
    const now = love.timer.getTime();
    if (now - pendingTap.tapTime > doubleTapTime) {
      onTap?.(pendingTap.x, pendingTap.y);
      pendingTap = undefined;
    }
  }

  if (touches.size === 1) {
    // --------DRAG---------
    const [touch] = touches.values();
    if (touch.moved) {
      _drag.x = touch.dx;
      _drag.y = touch.dy;
      onDrag?.(_drag.x, _drag.y);
      touch.dx = 0;
      touch.dy = 0;
    }
  }

  if (touches.size === 2) {
    const [touch1, touch2] = touches.values();

    // ---------PAN---------
    _pan.x = (touch1.dx + touch2.dx) * 0.5;
    _pan.y = (touch1.dy + touch2.dy) * 0.5;
    onPan?.(_pan.x, _pan.y);

    // --------PINCH--------
    // TODO(feature): Also report the center of the pinch gesture
    const dx = touch1.x - touch2.x;
    const dy = touch1.y - touch2.y;
    const dist = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
    if (lastPinchDist !== undefined) {
      _pinch = dist - lastPinchDist;
      onPinch?.(_pinch);
    }

    touch1.dx = 0;
    touch1.dy = 0;
    touch2.dx = 0;
    touch2.dy = 0;
  }
};

export function initInput() {
  addListner("update", update);
  addListner("focus", focus);
  addListner("touchpressed", touchpressed);
  addListner("touchmoved", touchmoved);
  addListner("touchreleased", touchreleased);
}
