import { setupDispatcher } from "./dispatcher";
import { initInput } from "./input";

love.load = () => {
  setupDispatcher();
  print("ts test");
  initInput();
  love.graphics.setDefaultFilter("nearest", "nearest");
};
