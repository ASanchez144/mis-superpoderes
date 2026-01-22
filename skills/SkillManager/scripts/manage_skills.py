import os
import shutil
import subprocess
import argparse
import sys
import json

# Configuration
# We will use a dedicated .cache folder inside the SkillManager skill to keep the repo
SKILLS_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) # ../
CACHE_DIR = os.path.join(SKILLS_ROOT, ".cache", "mis-superpoderes")
REMOTE_URL = "https://github.com/ASanchez144/mis-superpoderes.git"
# The parent directory where skills should be installed (e.g., .../Proyectos/Skills)
INSTALL_ROOT = os.path.dirname(SKILLS_ROOT) 

def run_command(command, cwd=None):
    """Runs a shell command."""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        print(e.stderr)
        raise

def update_repo():
    """Clones or pulls the latest version of the skills repo."""
    if os.path.exists(CACHE_DIR):
        print(f"Updating skills repository in {CACHE_DIR}...")
        # Check if it's a git repo
        if os.path.exists(os.path.join(CACHE_DIR, ".git")):
            run_command(["git", "pull"], cwd=CACHE_DIR)
        else:
            # If directory exists but not a git repo (broken state), clean it
            shutil.rmtree(CACHE_DIR)
            run_command(["git", "clone", REMOTE_URL, CACHE_DIR])
    else:
        print(f"Cloning skills repository to {CACHE_DIR}...")
        os.makedirs(os.path.dirname(CACHE_DIR), exist_ok=True)
        run_command(["git", "clone", REMOTE_URL, CACHE_DIR])

def list_skills(search_term=None):
    """Lists available permissions, optionally filtering."""
    update_repo()
    
    skills_dir = os.path.join(CACHE_DIR, "skills")
    if not os.path.exists(skills_dir):
        print("Error: Skills directory not found in repository.")
        return

    skills = []
    for item in os.listdir(skills_dir):
        item_path = os.path.join(skills_dir, item)
        if os.path.isdir(item_path) and not item.startswith("."):
            skills.append(item)
    
    if search_term:
        skills = [s for s in skills if search_term.lower() in s.lower()]
    
    print(json.dumps(skills, indent=2))

def install_skill(skill_name):
    """Installs a skill to the user's Skills directory."""
    update_repo()
    
    source_path = os.path.join(CACHE_DIR, "skills", skill_name)
    dest_path = os.path.join(INSTALL_ROOT, skill_name)

    if not os.path.exists(source_path):
        print(f"Error: Skill '{skill_name}' not found.")
        return

    if os.path.exists(dest_path):
        print(f"Skill '{skill_name}' is already installed at {dest_path}.")
        # Optional: Ask to update? For now, we assume if it's there, it's good.
        # But maybe we want to force update if requested.
        print("To force update, delete the directory first.")
        return

    print(f"Installing '{skill_name}' to {dest_path}...")
    shutil.copytree(source_path, dest_path)
    print(f"Successfully installed '{skill_name}'.")

def main():
    parser = argparse.ArgumentParser(description="Manage Agent Skills")
    parser.add_argument("--list", action="store_true", help="List available skills")
    parser.add_argument("--search", type=str, help="Search for a skill by name")
    parser.add_argument("--install", type=str, help="Install a specific skill")
    
    args = parser.parse_args()

    if args.list:
        list_skills()
    elif args.search:
        list_skills(args.search)
    elif args.install:
        install_skill(args.install)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
