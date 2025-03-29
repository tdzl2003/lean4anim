import { useLayoutEffect, useRef } from "react";
import { Color, RenderCall } from "./types";

export interface CanvasProp {
  width: number;
  height: number;
  frame: RenderCall[];
}

function colorToString(c: Color) {
  const { r, g, b, a } = c;
  return `rgba(${r * 255}, ${g * 255}, ${b * 255}, ${a})`;
}

function doRender(canvas: HTMLCanvasElement, frame: RenderCall[]) {
  const ctx = canvas.getContext("2d");
  console.assert(!!ctx, "Canvas context not available");
  if (!ctx) return;

  for (const call of frame) {
    if ("clear" in call) {
      ctx.fillStyle = colorToString(call.clear.color);
      ctx.fillRect(0, 0, canvas.width, canvas.height);
    } else if ("point" in call) {
      const { center, radius, color } = call.point;
      ctx.fillStyle = colorToString(color);
      ctx.beginPath();
      ctx.arc(center.x, center.y, radius, 0, Math.PI * 2);
      ctx.fill();
    } else if ("line" in call) {
      const { p1, p2, color } = call.line;
      ctx.strokeStyle = colorToString(color);
      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
      ctx.stroke();
    }
  }
}

export default function Canvas(props: CanvasProp) {
  const ref = useRef<HTMLCanvasElement>(null);
  useLayoutEffect(() => {
    const canvas = ref.current;
    if (!canvas) return;
    doRender(canvas, props.frame);
  }, [props.width, props.height, props.frame]);
  return <canvas ref={ref} width={props.width} height={props.height} />;
}
