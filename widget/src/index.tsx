import React, { useEffect } from "react";
import { useRpcSession, useAsync, mapRpcError } from "@leanprover/infoview";

interface AnimWidgetProps {
  pos: { uri: string };
  id: string;
  stage1: string;
}

export default function AnimWidget(props: AnimWidgetProps) {
  const { pos, id, stage1 } = props;
  const rs = useRpcSession();

  const stage2 = useAsync(
    () =>
      rs.call<unknown, string>("execStage2", {
        pos,
        name: id,
        params: stage1 + "-> js -> lean -> ",
      }),
    [pos, id, stage1]
  );

  return (
    <div>
      <div>Stage 1 props:{JSON.stringify(props)}</div>
      <div>
        Stage 2 result:{" "}
        {stage2.state === "resolved"
          ? stage2.value
          : stage2.state === "rejected"
          ? mapRpcError(stage2.error).message
          : "Loading"}
      </div>
    </div>
  );
}
