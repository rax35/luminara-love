import { Canvas, Quad } from "love.graphics";
import { Camera } from "./camera";
import { tileRenderSize } from "./constants";

export class BattleMap {
  private tiles: number[][];
  private camera: Camera;
  private canvas: Canvas;
  private blueTiles = new Set<number>();
  private redTiles = new Set<number>();

  constructor(
    private w: number,
    private h: number,
  ) {
    this.camera = new Camera(w, h);
    this.canvas = love.graphics.newCanvas(
      w * tileRenderSize,
      h * tileRenderSize,
    );

    this.tiles = Array.from({ length: h }, () => {
      return Array.from({ length: w }, () => math.random(4));
    });
  }

  public get width() {
    return this.w;
  }

  public get heigth() {
    return this.h;
  }

  private drawCanvas() {
    const image = love.graphics.newImage("res/atlas.png");
    const quad: Quad[] = [];
    quad.push(love.graphics.newQuad(0, 0, 16, 16, image));
    quad.push(love.graphics.newQuad(0, 16, 16, 16, image));
    quad.push(love.graphics.newQuad(16, 0, 16, 16, image));
    quad.push(love.graphics.newQuad(16, 16, 16, 16, image));

    const tileScale = tileRenderSize / 16;
    for (let i = 0; i < this.h; i++) {
      for (let j = 0; j < this.w; j++) {
        this.canvas.renderTo(() => {
          love.graphics.draw(
            image,
            quad[this.tiles[i][j]],
            j * tileRenderSize,
            i * tileRenderSize,
            0,
            tileScale,
            tileScale,
          );
        });
      }
    }
  }

  public draw() {
    this.camera.attach();

    love.graphics.draw(this.canvas, 0.5, 0.5);

    love.graphics.setColor(0, 0.1, 0.8, 0.4);
    for (const idx of this.blueTiles) {
      const [x, y] = this.idxToPos(idx);
      love.graphics.rectangle("fill", x, y, tileRenderSize, tileRenderSize);
    }

    love.graphics.setColor(0.8, 0, 0, 0.4);
    for (const idx of this.redTiles) {
      const [x, y] = this.idxToPos(idx);
      love.graphics.rectangle("fill", x, y, tileRenderSize, tileRenderSize);
    }

    this.camera.detach();
  }

  private idxToPos(idx: number): [number, number] {
    return [
      Math.floor(idx / this.w) * tileRenderSize,
      (idx % this.w) * tileRenderSize,
    ];
  }

  private posToIdx(x: number, y: number): number {
    return (
      Math.floor(y / tileRenderSize) * this.w + Math.floor(x / tileRenderSize)
    );
  }

  public onTap(sx: number, sy: number) {
    const [wx, wy] = this.camera.screenToWorld(sx, sy);
    const idx = this.posToIdx(wx, wy);
    this.blueTiles.add(idx);
  }
}
