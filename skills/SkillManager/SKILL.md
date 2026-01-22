---
name: Skill Manager
description: A meta-skill that allows you to dynamically discover and install other specialized skills from the mis-superpoderes repository.
---

# Skill Manager

This skill gives you access to a vast library of over 200 specialized capabilities (skills) hosted in the `mis-superpoderes` repository.

## Capabilities

1.  **Search/List Skills**: Find skills relevant to the user's current request.
2.  **Install Skills**: Download and activate a skill so you can use it immediately.

## How to Use

### 1. Discovery
When the user asks for something that might require specialized knowledge (e.g., "build a Next.js app", "check for security vulnerabilities", "write a marketing email", "create a canvas design"), FIRST check if there is a skill for it.

Run the `manage_skills.py` script to list or search for skills.

**List all skills:**
```bash
python scripts/manage_skills.py --list
```

**Search for a skill:**
```bash
python scripts/manage_skills.py --search "keyword"
```
*Tip: Use broad keywords like "security", "web", "design", "agent" to find relevant categories.*

### 2. Selection
Analyze the list of skills. Choose the one that **best matches** the user's specific intent.
*   If the user wants a website, maybe `web-artifacts-builder` or `nextjs-best-practices`.
*   If the user wants a secure app, maybe `security-audit` or similar.
*   If the user implies "something extra" or a specific feature, look for a niche skill (e.g., `seo-fundamentals`, `stripe-integration`).

### 3. Installation
Once you have identified the `skill-name`, install it:

```bash
python scripts/manage_skills.py --install skill-name
```

### 4. Activation
After installation, you **MUST** read the new skill's `SKILL.md` file to understand how to use it.
```bash
# Example
type logic tells you the path is likely ../skill-name/SKILL.md, but check the output of the install command.
```

## Example Workflow

**User:** "I want to create a viral video script."

1.  **You:** "I'll check for a relevant skill."
2.  **Command:** `python scripts/manage_skills.py --search "viral"` or `... --search "content"`
3.  **Result:** Found `viral-generator-builder`.
4.  **Command:** `python scripts/manage_skills.py --install viral-generator-builder`
5.  **Action:** Read `../viral-generator-builder/SKILL.md` and follow its instructions to generate the script.
