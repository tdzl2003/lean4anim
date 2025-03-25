import Lean
import Lean.Server.Rpc

open Lean

namespace Anim

structure Scene where
  width: Nat
  height: Nat
deriving Repr

structure FinalOutput where
  width: Nat
  height: Nat
deriving FromJson, ToJson, TypeName

def Scene.toFinalOutput (s: Scene): FinalOutput := {
  width := s.width,
  height := s.height
}

-- Monad for Anim
structure Request where
  type: String
deriving Repr, FromJson, ToJson

structure Response where
  resp: String
deriving Repr, FromJson, ToJson

inductive AnimM(α: Type) where
  | pure (a: α)
  | request (r: Request) (f: Response → AnimM α)

abbrev Anim := AnimM Scene

def AnimM.bind {α β: Type} (x: AnimM α) (f: α → AnimM β): AnimM β := match x with
  | AnimM.pure a => f a
  | AnimM.request r k => AnimM.request r (fun resp => AnimM.bind (k resp) f)

instance : Monad AnimM where
  bind := AnimM.bind
  pure := AnimM.pure

end Anim

#check IO
