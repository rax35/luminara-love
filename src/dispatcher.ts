export interface EngineEvents {
  update: NonNullable<typeof love.update>;
  touchpressed: NonNullable<typeof love.touchpressed>;
  touchmoved: NonNullable<typeof love.touchmoved>;
  touchreleased: NonNullable<typeof love.touchreleased>;
  focus: NonNullable<typeof love.focus>;
}

const Listners: {
  [K in keyof EngineEvents]?: ((
    ...args: Parameters<EngineEvents[K]>
  ) => void)[];
} = {};

export function addListner<K extends keyof EngineEvents>(
  event: K,
  callback: (...args: Parameters<EngineEvents[K]>) => void,
) {
  if (!Listners[event]) {
    Listners[event] = [];
  }

  Listners[event].push(callback);
}

function callListeners<K extends keyof EngineEvents>(
  event: K,
  ...params: Parameters<EngineEvents[K]>
) {
  Listners[event]?.forEach((listener) => {
    listener(...params);
  });
}

export function setupDispatcher() {
  love.update = (dt) => {
    callListeners("update", dt);
  };
  love.touchpressed = (...args) => {
    callListeners("touchpressed", ...args);
  };
  love.touchmoved = (...args) => {
    callListeners("touchmoved", ...args);
  };
  love.touchreleased = (...args) => {
    callListeners("touchreleased", ...args);
  };
  love.focus = (focused) => {
    callListeners("focus", focused);
  };
}
