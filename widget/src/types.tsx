export interface Point {
  x: number;
  y: number;
}

export interface Color {
  r: number;
  g: number;
  b: number;
  a: number;
}

export type RenderCall =
  | {
      clear: {
        color: Color;
      };
    }
  | {
      point: {
        center: Point;
        radius: number;
        color: Color;
      };
    }
  | {
      line: {
        p1: Point;
        p2: Point;
        color: Color;
      };
    };

export interface SceneMeta {
  width: number;
  height: number;
}

export interface SceneOutput {
  meta: SceneMeta;
  frames: RenderCall[][];
}

export type AnimRpcResult =
  | {
      pure: SceneOutput;
    }
  | {
      request: string;
      cont: unknown;
    };
