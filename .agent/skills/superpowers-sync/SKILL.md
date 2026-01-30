---
name: superpowers-sync
description: Sync and update the Superpowers ecosystem. Clones or pulls the latest skills from `antigravity-awesome-skills` and the user's `mis-superpoderes` repository, then installs the most appropriate skills into the current project's `.agent/skills` folder. Use when the user asks to "update skills", "sync superpowers", or "install appropriate skills".
---

# Superpowers Sync

This skill automates the synchronization of the Antigravity Superpowers ecosystem and installs relevant skills for the current project.

## Workflow

1.  **Repo Synchronization**:
    -   Clones `https://github.com/sickn33/antigravity-awesome-skills.git` to a local temporary directory.
    -   Clones `https://github.com/ASanchez144/mis-superpoderes` to a local temporary directory.
    -   Merges changes from the awesome-skills repo into the user's superpowers repo.
    -   Pushes the updated user repo back to GitHub.

2.  **Project Analysis**:
    -   Inspects the current project structure (e.g., `package.json`, `src/`, `.git`, file extensions).
    -   Determines the tech stack and project type.

3.  **Skill Installation**:
    -   Selects the most "appropriate" skills from the synchronized collection.
    -   Downloads/Copies these skills into the project's `.agent/skills/` directory.

## How to use

Simply ask:
-   "Sync my superpowers"
-   "Update the skills from awesome-skills and install the best ones for this project"
-   "Execute superpowers-sync"

## Selection Logic

The skill selects modules based on:
-   **Frontend**: React, Next.js, Tailwind, Vite, UI/UX patterns.
-   **Backend**: Node.js, Express, Python, Supabase, Firebase.
-   **DevOps**: Docker, Vercel, CI/CD.
-   **Security**: Ethical hacking, pentesting (if applicable).
-   **Product**: Marketing, SEO, A/B testing.

---
**Note**: This skill requires Git to be configured and access to the repositories.
