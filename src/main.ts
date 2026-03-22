import * as Input from "./input";

love.load = () => {
  print("ts test");
  Input.init();
  love.graphics.setDefaultFilter("nearest", "nearest");
};
love.update = () => {
  print("main update");
};
