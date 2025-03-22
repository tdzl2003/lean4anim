import Lean
import Anim.Demos.File1

open Lean Elab Command
open Server RequestM

structure Stage2Params where
  params: String
  name: Name
  pos : Lsp.Position
  deriving FromJson, ToJson


unsafe def evalExprUnsafe(e: Expr): MetaM TwoStageStructure :=
  Meta.evalExpr TwoStageStructure (mkConst ``TwoStageStructure) e

@[implemented_by evalExprUnsafe]
opaque evalExpr (e : Expr) : MetaM TwoStageStructure

@[server_rpc_method]
def execStage2 (params: Stage2Params): RequestM (RequestTask String) :=
  withWaitFindSnapAtPos params.pos fun snap => do
    runTermElabM snap do
      let name ← resolveGlobalConstNoOverloadCore params.name
      let c ← try getConstInfo name
        catch _ => throwThe RequestError ⟨.invalidParams, s!"No constant named '{name}' found"⟩
      match c with
      | ConstantInfo.defnInfo x => do
        let e := x.value
        let v ← evalExpr e
        return (v.stage2 params.params)
      | _ => do
        throwThe RequestError ⟨.invalidParams, s!"Constant named '{name}' is not a defined stage2 params"⟩
