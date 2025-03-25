import Anim.Types
import Anim.Widget

open Anim

def SomeRequest: AnimM String := do
  AnimM.request {type := "SomeRequest"} (fun resp => AnimM.pure resp.resp)

def Demo : Anim := do
  let resp ← SomeRequest
  return {width:= 1080, height:= 1920: Scene}


#anim Demo
