import { Canvas, Quad } from "love.graphics";
import { Camera } from "./camera";
import { tileRenderSize } from "./constants";

export class BattleMap {
  private tiles: number[][];
  private camera: Camera;
  private canvas: Canvas;
  private blueTiles: number[] = [];
  private redTiles: number[] = [];

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
}
