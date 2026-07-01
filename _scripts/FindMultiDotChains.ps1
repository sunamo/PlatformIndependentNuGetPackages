# Hleda viceteckove retezce (namespace.Trida.Clen) mimo using direktivy.
# Pouziva Roslyn semanticku analyzu (MSBuildWorkspace) pres CommandsToAllCsFiles.Cmd FindMultiDotChains.
# Toto je hlavni (master) implementace - wnp a sunamo.cz jen volaji tento skript.
param(
    [string]$Path = (Get-Location).Path
)

CommandsToAllCsFiles.Cmd FindMultiDotChains $Path
