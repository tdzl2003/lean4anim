import Lean
open Lean Widget Elab Command

structure TwoStageStructure where
  stage1: String
  stage2: String -> String

@[widget_module]
def TwoStageComponent : Widget.Module where
  javascript := include_str ".." / ".." / ".lake" / "build" / "js" / "index.js"

syntax (name := tsWidgetCmd) "#ts_widget " term : command

private def elabTermForEval (term : Syntax) : TermElabM Expr := do
  let e ← Term.elabTermEnsuringType term none
  return e

unsafe def evalTermUnsafe(stx: Syntax): TermElabM TwoStageStructure :=
  let tp := (mkConst ``TwoStageStructure)
  Term.evalTerm TwoStageStructure tp stx

@[implemented_by evalTermUnsafe]
opaque evalTerm (v : Syntax) : TermElabM TwoStageStructure

@[command_elab tsWidgetCmd]
def elabHtmlCmd : CommandElab := fun
  | stx@`(#ts_widget $s:term) => do
    let id := s.raw.getId
    -- 将术语s转换为表达式
    let v ← liftTermElabM do
      (evalTerm s)

    liftCoreM do
      savePanelWidgetInfo
        TwoStageComponent.javascriptHash
        (return json%{id: $(id), stage1: $(v.stage1)})
        stx
  | stx => throwError "Unexpected syntax {stx}."
