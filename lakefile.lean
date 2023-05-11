import Lake

open System Lake DSL

package «bookshelf»

-- ========================================
-- Imports
-- ========================================

require Cli from git
  "https://github.com/mhuisi/lean4-cli" @
    "nightly"
require CMark from git
  "https://github.com/xubaiw/CMark.lean" @
    "main"
require UnicodeBasic from git
  "https://github.com/fgdorais/lean4-unicode-basic" @
    "main"
require lake from git
  "https://github.com/leanprover/lake" @
    "master"
require leanInk from git
  "https://github.com/hargonix/LeanInk" @
    "doc-gen"
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @
    "master"
require std4 from git
  "https://github.com/leanprover/std4.git" @
    "main"

-- ========================================
-- Document Generator
-- ========================================

lean_lib DocGen4

lean_exe «doc-gen4» {
  root := `Main
  supportInterpreter := true
}

module_facet docs (mod) : FilePath := do
  let some docGen4 ← findLeanExe? `«doc-gen4»
    | error "no doc-gen4 executable configuration found in workspace"
  let exeJob ← docGen4.exe.fetch
  let modJob ← mod.leanBin.fetch
  let buildDir := (← getWorkspace).root.buildDir
  let docFile := mod.filePath (buildDir / "doc") "html"
  exeJob.bindAsync fun exeFile exeTrace => do
  modJob.bindSync fun _ modTrace => do
    let depTrace := exeTrace.mix modTrace
    let trace ← buildFileUnlessUpToDate docFile depTrace do
      logInfo s!"Documenting module: {mod.name}"
      proc {
        cmd := exeFile.toString
        args := #["single", mod.name.toString, "--ink"]
        env := #[("LEAN_PATH", (← getAugmentedLeanPath).toString)]
      }
    return (docFile, trace)

-- TODO: technically speaking this facet does not show all file dependencies
target coreDocs : FilePath := do
  let some docGen4 ← findLeanExe? `«doc-gen4»
    | error "no doc-gen4 executable configuration found in workspace"
  let exeJob ← docGen4.exe.fetch
  let basePath := (←getWorkspace).root.buildDir / "doc"
  let dataFile := basePath / "declarations" / "declaration-data-Lean.bmp"
  exeJob.bindSync fun exeFile exeTrace => do
    let trace ← buildFileUnlessUpToDate dataFile exeTrace do
      logInfo "Documenting Lean core: Init and Lean"
      proc {
        cmd := exeFile.toString
        args := #["genCore"]
        env := #[("LEAN_PATH", (← getAugmentedLeanPath).toString)]
      }
    return (dataFile, trace)

library_facet docs (lib) : FilePath := do
  let some bookshelfPkg ← findPackage? `«bookshelf»
    | error "no bookshelf package found in workspace"
  let some docGen4 := bookshelfPkg.findLeanExe? `«doc-gen4»
    | error "no doc-gen4 executable configuration found in workspace"
  let exeJob ← docGen4.exe.fetch

  -- XXX: Workaround remove later
  let coreJob ← if h : bookshelfPkg.name = _package.name then
    have : PackageName bookshelfPkg _package.name := ⟨h⟩
    let job := fetch <| bookshelfPkg.target `coreDocs
    job
  else
    error "wrong package"

  let mods ← lib.modules.fetch
  let moduleJobs ← BuildJob.mixArray <| ← mods.mapM (fetch <| ·.facet `docs)
  -- Shared with DocGen4.Output
  let basePath := (←getWorkspace).root.buildDir / "doc"
  let dataFile := basePath / "declarations" / "declaration-data.bmp"
  let staticFiles := #[
    basePath / "style.css",
    basePath / "declaration-data.js",
    basePath / "nav.js",
    basePath / "how-about.js",
    basePath / "search.js",
    basePath / "mathjax-config.js",
    basePath / "instances.js",
    basePath / "importedBy.js",
    basePath / "index.html",
    basePath / "404.html",
    basePath / "navbar.html",
    basePath / "search.html",
    basePath / "find" / "index.html",
    basePath / "find" / "find.js",
    basePath / "src"  / "alectryon.css",
    basePath / "src"  / "alectryon.js",
    basePath / "src"  / "docutils_basic.css",
    basePath / "src"  / "pygments.css"
  ]
  coreJob.bindAsync fun _ coreInputTrace => do
    exeJob.bindAsync fun exeFile exeTrace => do
      moduleJobs.bindSync fun _ inputTrace => do
        let depTrace := mixTraceArray #[inputTrace, exeTrace, coreInputTrace]
        let trace ← buildFileUnlessUpToDate dataFile depTrace do
          logInfo "Documentation indexing"
          proc {
            cmd := exeFile.toString
            args := #["index"]
          }
        let traces ← staticFiles.mapM computeTrace
        let indexTrace := mixTraceArray traces

        return (dataFile, trace.mix indexTrace)

-- ========================================
-- Bookshelf
-- ========================================

@[default_target]
lean_lib «Bookshelf» {
  roots := #[`Bookshelf, `Common]
}

/--
The contents of our `.env` file.
-/
structure Config where
  port : Nat := 5555

/--
Read in the `.env` file into an in-memory structure.
-/
private def readConfig : StateT Config ScriptM Unit := do
  let env <- IO.FS.readFile ".env"
  for line in env.trim.split (fun c => c == '\n') do
    match line.split (fun c => c == '=') with
    | ["PORT", port] => modify (fun c => { c with port := String.toNat! port })
    | _ => error "Malformed `.env` file."
  return ()

/--
Start an HTTP server for locally serving documentation. It is expected the
documentation has already been generated prior via

```bash
> lake build Bookshelf:docs
```

USAGE:
  lake run server
-/
script server (_args) do
  let ((), config) <- StateT.run readConfig {}
  IO.println s!"Running Lean on `http://localhost:{config.port}`"
  _ <- IO.Process.run {
    cmd := "python3",
    args := #["-m", "http.server", toString config.port, "-d", "build/doc"],
  }
  return 0
