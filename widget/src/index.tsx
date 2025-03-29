import React, { useEffect } from "react";
import { useRpcSession, useAsync, mapRpcError } from "@leanprover/infoview";
import { AnimRpcResult } from "./types";
import Canvas from "./Canvas";

export default function AnimWidget(props: AnimRpcResult) {
  const rs = useRpcSession();

  const st = useAsync(async () => {
    let curr = props;
    for (;;) {
      if ("pure" in curr) {
        return curr.pure;
      }

      curr = await rs.call<unknown, AnimRpcResult>("Anim.runContinue", {
        resp: { resp: "Resp" },
        cont: curr.cont,
      });
    }
  }, [(props as any).pure, (props as any).request, (props as any).cont]);

  return (
    <div>
      {st.state === "resolved" && (
        <div>
          <Canvas
            width={st.value.meta.width}
            height={st.value.meta.height}
            frame={st.value.frames[0]}
          />
        </div>
      )}
      {st.state === "rejected" && <div>{mapRpcError(st.error).message}</div>}
      {st.state === "loading" && <div>Loading...</div>}
    </div>
  );
}
