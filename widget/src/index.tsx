import React, { useEffect } from "react";
import { useRpcSession, useAsync, mapRpcError } from "@leanprover/infoview";

type Scene = {
  width: number;
  height: number;
};

type Anim =
  | {
      pure: Scene;
    }
  | {
      request: string;
      cont: unknown;
    };

export default function AnimWidget(props: Anim) {
  const rs = useRpcSession();

  const st = useAsync(async () => {
    let curr = props;
    for (;;) {
      if ("pure" in curr) {
        return curr.pure;
      }

      curr = await rs.call<unknown, Anim>("Anim.runContinue", {
        resp: { resp: "Resp" },
        cont: curr.cont,
      });
    }
  }, [(props as any).pure, (props as any).request, (props as any).cont]);

  return (
    <div>
      <div>Stage 1 props:{JSON.stringify(props)}</div>
      <div>st.state</div>
      {st.state === "resolved" && <div>{JSON.stringify(st.value)}</div>}
      {st.state === "rejected" && <div>{mapRpcError(st.error).message}</div>}
      {st.state === "loading" && <div>Loading...</div>}
    </div>
  );
}
