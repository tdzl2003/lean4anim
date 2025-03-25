import Lean
import Anim.Types
open Lean Widget Elab Command Server

namespace Anim

syntax (name := animCmd) "#anim " term : command

@[widget_module]
private def AnimComponent : Widget.Module where
  javascript := include_str ".." / ".lake" / "build" / "js" / "index.js"

private def elabTermForEval (term : Syntax) : TermElabM Expr := do
  let e ← Term.elabTermEnsuringType term none
  return e

private unsafe def evalTermUnsafe(stx: Syntax): TermElabM Anim :=
  let tp := (mkConst ``Anim)
  Term.evalTerm Anim tp stx

@[implemented_by evalTermUnsafe]
private opaque evalTerm (v : Syntax) : TermElabM Anim

private structure ContinuableAnim where
  f: Response -> Anim
deriving TypeName

private structure ContinuableAnimState where
  req: Request
  cont: WithRpcRef ContinuableAnim
deriving RpcEncodable

def Anim.encode (a: Anim): StateM RpcObjectStore Json := match a with
  | AnimM.pure a => return json%{pure: $a.toFinalOutput}
  | AnimM.request r k => rpcEncode {req:=r, cont:= ⟨⟨k⟩⟩ : ContinuableAnimState}

@[command_elab animCmd]
def elabHtmlCmd : CommandElab := fun
  | stx@`(#anim $s:term) => do
    let v ← liftTermElabM do
      (evalTerm s)

    liftCoreM do
      savePanelWidgetInfo
        AnimComponent.javascriptHash
        v.encode
        stx
  | stx => throwError "Unexpected syntax {stx}."

private structure ContinueAnimState where
  resp: Response
  cont: WithRpcRef ContinuableAnim
deriving RpcEncodable

@[server_rpc_method]
def runContinue (params: ContinueAnimState): RequestM (RequestTask $ StateM RpcObjectStore Json) := do
  let v := params.cont.val.f params.resp
  return RequestTask.pure v.encode

end Anim
