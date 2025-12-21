# Create new solution file
$slnName = "SelectedProjects.sln"
$slnPath = Join-Path $PSScriptRoot ".." $slnName

# Projects to include
$projects = @(
    @{ Name = "SunamoRegex"; Path = "SunamoRegex\SunamoRegex\SunamoRegex.csproj" },
    @{ Name = "SunamoRoslyn"; Path = "SunamoRoslyn\SunamoRoslyn\SunamoRoslyn.csproj" },
    @{ Name = "SunamoReflection"; Path = "SunamoReflection\SunamoReflection\SunamoReflection.csproj" },
    @{ Name = "SunamoNumbers"; Path = "SunamoNumbers\SunamoNumbers\SunamoNumbers.csproj" },
    @{ Name = "SunamoCollections"; Path = "SunamoCollections\SunamoCollections\SunamoCollections.csproj" },
    @{ Name = "SunamoPlatformUwpInterop"; Path = "SunamoPlatformUwpInterop\SunamoPlatformUwpInterop\SunamoPlatformUwpInterop.csproj" },
    @{ Name = "SunamoLang"; Path = "SunamoLang\SunamoLang\SunamoLang.csproj" },
    @{ Name = "SunamoEnums"; Path = "SunamoEnums\SunamoEnums\SunamoEnums.csproj" },
    @{ Name = "SunamoDelegates"; Path = "SunamoDelegates\SunamoDelegates\SunamoDelegates.csproj" },
    @{ Name = "SunamoDotNetZip"; Path = "SunamoDotNetZip\SunamoDotNetZip\SunamoDotNetZip.csproj" }
)

# Create solution using dotnet CLI
Set-Location (Join-Path $PSScriptRoot "..")
dotnet new sln -n SelectedProjects -o . --force

# Add projects to solution
foreach ($project in $projects) {
    Write-Host "Adding $($project.Name)..."
    dotnet sln $slnName add $project.Path
}

Write-Host "Solution created successfully at: $slnPath"
