# Superpowers Sync Script
# This script syncs skills from awesome-skills to mis-superpoderes and installs relevant ones to the current project.

$ErrorActionPreference = "Stop"

$AWESOME_REPO = "https://github.com/sickn33/antigravity-awesome-skills.git"
$USER_REPO = "https://github.com/ASanchez144/mis-superpoderes.git"
$TEMP_DIR = Join-Path $env:TEMP "superpowers-sync"
$CURRENT_PROJECT_SKILLS = ".agent/skills"

# 1. Prepare Temp Directory
if (Test-Path $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR
}
New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null

# 2. Clone Awesome Skills
Write-Host "Cloning Awesome Skills..."
git clone --depth 1 $AWESOME_REPO "$TEMP_DIR/awesome"

# 3. Clone User Repo
Write-Host "Cloning User Superpowers Repo..."
git clone $USER_REPO "$TEMP_DIR/user"

# 4. Sync Content (Awesome -> User)
Write-Host "Syncing Awesome Skills to User Repo..."
# Try common paths for skills
$awesomeSkillsPath = Join-Path "$TEMP_DIR/awesome" "skills"
if (-not (Test-Path $awesomeSkillsPath)) {
    $awesomeSkillsPath = Join-Path "$TEMP_DIR/awesome" ".agent/skills"
}

$userSkillsPath = Join-Path "$TEMP_DIR/user" "skills"
if (-not (Test-Path $userSkillsPath)) {
    $userSkillsPath = Join-Path "$TEMP_DIR/user" ".agent/skills"
}

if (Test-Path $awesomeSkillsPath) {
    $sourceSkills = Get-ChildItem -Path $awesomeSkillsPath -Directory
    foreach ($skill in $sourceSkills) {
        $targetPath = Join-Path $userSkillsPath $skill.Name
        if (-not (Test-Path $targetPath)) {
            Write-Host "Adding new skill: $($skill.Name)"
            Copy-Item -Path $skill.FullName -Destination "$userSkillsPath/" -Recurse -Force
        }
    }
} else {
    Write-Warning "Awesome skills path not found."
}

# 5. Push changes to User Repo
Write-Host "Updating User Repo on GitHub..."
$oldCwd = Get-Location
Set-Location "$TEMP_DIR/user"
git add .
$status = git status --porcelain
if ($status) {
    git commit -m "chore: sync with awesome-skills [automated]"
    Write-Host "Changes committed. Pushing..."
    try {
        git push
    } catch {
        Write-Warning "Failed to push. You might need to authenticate manually."
    }
} else {
    Write-Host "No new skills to update in user repo."
}
Set-Location $oldCwd

# 6. Security & Vulnerability Scan
Write-Host "Running security scan on synchronized skills..."
$vulnerabilityFound = $false
$scanResults = @()

# Simple scan for high-risk patterns in the newly synced skills
$riskyPatterns = @(
    @{ Pattern = "eval\(|exec\(|Function\("; Description = "Dynamic Code Execution" },
    @{ Pattern = "api_key|apikey|secret|password|token"; Description = "Hardcoded Secrets" },
    @{ Pattern = "http:"; Description = "Insecure Communication" },
    @{ Pattern = "verify=False|--insecure"; Description = "Disabled Security" }
)

$allSkills = Get-ChildItem -Path $userSkillsPath -Recurse -File -Include "*.md", "*.py", "*.js", "*.ts", "*.json"
foreach ($file in $allSkills) {
    if ($file.FullName -match "node_modules|\.git") { continue }
    $content = Get-Content $file.FullName -Raw
    foreach ($item in $riskyPatterns) {
        if ($content -match $item.Pattern) {
            $vulnerabilityFound = $true
            $scanResults += "[!] $($item.Description) found in $($file.FullName)"
        }
    }
}

if ($vulnerabilityFound) {
    Write-Warning "Security scan detected potential issues in synchronized skills:"
    $scanResults | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    Write-Host "Please review these findings before using these skills in production."
} else {
    Write-Host "Security scan passed. No immediate high-risk patterns detected. ✅"
}

# 7. Analyze Current Project and Install Skills
Write-Host "Analyzing current project for appropriate skills..."
$detectedSkills = @()

# Logic to detect stack
if (Test-Path "package.json") {
    $pj = Get-Content "package.json" | ConvertFrom-Json
    $deps = @()
    if ($pj.dependencies) { $deps += $pj.dependencies.PSObject.Properties.Name }
    if ($pj.devDependencies) { $deps += $pj.devDependencies.PSObject.Properties.Name }
    
    if ($deps -contains "react") { $detectedSkills += "react-patterns", "frontend-dev-guidelines", "ui-ux-pro-max" }
    if ($deps -contains "next") { $detectedSkills += "nextjs-best-practices", "vercel-deployment" }
    if ($deps -contains "supabase") { $detectedSkills += "nextjs-supabase-auth" }
    if ($deps -contains "typescript") { $detectedSkills += "typescript-expert" }
    if ($deps -contains "tailwind") { $detectedSkills += "tailwind-patterns" }
}

if (Test-Path "requirements.txt") { $detectedSkills += "python-patterns" }
if (Test-Path "docker-compose.yml") { $detectedSkills += "docker-expert" }

# Default essential skills
$detectedSkills += "using-superpowers", "brainstorming", "writing-plans", "systematic-debugging", "verification-before-completion"

# Remove duplicates
$detectedSkills = $detectedSkills | Select-Object -Unique

# 8. Install to Current Project
if (-not (Test-Path $CURRENT_PROJECT_SKILLS)) {
    New-Item -ItemType Directory -Path $CURRENT_PROJECT_SKILLS -Force | Out-Null
}

Write-Host "Installing detected skills to $CURRENT_PROJECT_SKILLS : $($detectedSkills -join ', ')"
foreach ($skillName in $detectedSkills) {
    # Check if exists in user repo first, then awesome
    $sourcePath = Join-Path $userSkillsPath $skillName
    if (-not (Test-Path $sourcePath)) {
        $sourcePath = Join-Path $awesomeSkillsPath $skillName
    }
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $CURRENT_PROJECT_SKILLS -Recurse -Force
    } else {
        Write-Warning "Skill $skillName not found in sources."
    }
}

Write-Host "Superpowers sync complete! ✅"
