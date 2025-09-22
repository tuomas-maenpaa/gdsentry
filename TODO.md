# GDSentry TODO

## High-level assessment of README.md

- Strengths
  - Clear positioning and problem space for game testing.
  - Solid overview of capabilities and design principles.
  - Has quick start, examples, and an architecture section.
  - Project appears stable and maintained.

- Gaps vs common OSS practice
  - No badges (build, docs, license, version, Godot compatibility).
  - No explicit “Contributing”, “License”, “Code of Conduct”, “Security”, “Changelog” links.
  - Long-form content that belongs in docs (architecture) bloats the README.
  - Some code fences use wrong language tags and class names; a command likely references a non-existent script.
  - No link to hosted docs (now that Sphinx builds cleanly) and no “What’s new/roadmap” pointer.

### Concrete fixes (actionable)

- Content structure
  - Add a crisp one-paragraph pitch at the top; move much of “Design Philosophy” and “Technical Architecture” to your docs and link to them.
  - Add a “Why GDSentry vs alternatives?” blurb and a compatibility matrix (Godot 3.5/4.x; known limitations).

- Badges (top of README)
  - Build CI (GitHub Actions), Docs (link to gh-pages), License, Godot version support, “Tests: headless”.
  - Example: Build | Docs | License | Godot 3.5/4.x

- Quickstart and commands
  - Replace or remove the non-existent line: `./gdsentry/run_examples.sh` (not in repo).
  - Keep a single, verified run command (headless):

    ```bash
    godot --headless --script gdsentry/core/test_runner.gd --discover --verbose
    ```

  - Add a minimal “Add to your project” path: copy `gdsentry/` to project root, confirm `project.godot` autoload if applicable.

- Code fences and examples
  - Use correct language tags: replace ```c++ with```gdscript for GDScript; keep ```bash/```zsh, ```json,```text where appropriate.
  - Align extends usage consistently. Prefer:

    ```gdscript
    extends SceneTreeTest
    ```

    (instead of `extends GDSentry.SceneTreeTest`) to match the rest of your docs.
  - Ensure the “Interactive test” snippet includes a test body (currently stops mid-example).

- Link the documentation
  - Add a prominent “Full Documentation” link (gh-pages or artifact), e.g., `docs/build/html/index.html` via GitHub Pages.
  - Add “API Reference”, “Tutorials” quick links.

- OSS hygiene links
  - Add sections/links to:
    - Contributing (CONTRIBUTING.md)
    - Code of Conduct (CODE_OF_CONDUCT.md)
    - Security Policy (SECURITY.md)
    - License (LICENSE) and badge
    - Changelog (CHANGELOG.md) and semantic versioning note
    - Issue templates / PR template
  - If these files exist in the repo root, link them; if not, add them.

- Screenshots/GIFs
  - A small GIF or screenshot of a test run and a generated report in the README makes a big difference for OSS adoption.

- Remove internal-looking “Metadata” section
  - Replace with badges. Avoid emojis if you want a professional OSS tone across assets.

### Suggested README skeleton (concise)

- Badges row
- One-paragraph pitch
- Features (short bullets)
- Install (copy `gdsentry/` to project, autoload config if needed)
- Quickstart (one minimal test + one run command)
- Compatibility matrix
- Documentation links (Guides, API, Tutorials)
- Contributing / Code of Conduct / Security / License
- Roadmap / Changelog

### Project-level improvements (beyond README)

- CI/CD
  - Matrix test across Godot 3.5 and 4.x in headless mode running the self-tests under `gdsentry-self-test/`.
  - Sphinx docs job (nitpicky mode) + deploy to GitHub Pages on tags.
  - Attach HTML/JUnit reports as CI artifacts.

- Releases and versioning
  - Add CHANGELOG.md; adopt Semantic Versioning; tag releases; auto-generate release notes.
  - Define compatibility policy (e.g., “4.x supported; 3.5 limited; breaking changes only on major”).

- Documentation
  - Now the docs build cleanly: enable a public docs site; link it in the repo header.
  - Add a “Troubleshooting” and “FAQ” landing section from README.
  - Add a short “Migration guide” if API changes are planned.

- Developer experience
  - Add pre-commit hooks (rstcheck, trailing whitespace, basic lint); run Sphinx in `-n` (nitpicky) mode in CI to catch broken references early.
  - Consider intersphinx or external links to Godot docs for common classes.
  - Maintain consistent code style and class names across README and docs.

- Community
  - Add Discussions/Discord link if you want community support.
  - Add “Good first issue” labels and a short contributor guide (how to run self-tests, docs build, code style).

- Packaging/distribution
  - If you plan Asset Library distribution, add an “Install from AssetLib” section with status.
  - Provide a minimal example Godot project folder that uses GDSentry for newcomers.

- Compliance/housekeeping
  - Ensure LICENSE exists and is referenced in README.
  - Ensure all referenced scripts/paths exist or remove the references.
  - Replace emojis in docs/README if you want a consistent no-emoji policy.

If you want, I can:

- Draft a tightened README aligning to the skeleton above.
- Add missing repo files (CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, ISSUE/PR templates).
- Set up a GitHub Actions matrix workflow to run headless tests and publish docs.
