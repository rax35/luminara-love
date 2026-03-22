import { clamp } from "./math_extensions";

export class Camera {
  private targetX: number | undefined = undefined;
  private targetY: number | undefined = undefined;

  constructor(
    private worldW = 0,
    private worldH = 0,
    private x = 0,
    private y = 0,
    private w = 0,
    private h = 0,
    private screenX = 0,
    private screenY = 0,
    private zoom = 1,
    private clip = true,
    private sx = 0,
    private sy = 0,
    private sw = 0,
    private sh = 0,
  ) {}

  public move(dx: number, dy: number) {
    const x = this.x - dx;
    const y = this.y - dy;

    this.x = clamp(x, 0, this.worldW - this.w);
    this.y = clamp(y, 0, this.worldH - this.h);
  }

  public attach() {
    [this.sx, this.sy, this.sw, this.sh] = love.graphics.getScissor();
    love.graphics.setScissor(this.screenX, this.screenY, this.w, this.h);
    love.graphics.push();

    love.graphics.scale(this.zoom);
    love.graphics.translate(
      Math.ceil(-(this.x - this.screenX)),
      Math.ceil(-(this.y - this.screenY)),
    );
  }

  public detach() {
    love.graphics.pop();
    love.graphics.setScissor();
  }

  public screenToWorld(x: number, y: number): [number, number] {
    return [x + this.x - this.screenX, y + this.y - this.screenY];
  }
}
