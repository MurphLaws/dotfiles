---
name: job-finder
description: "Tailor Nicolás Lasso's base CV to a specific job listing for maximum ATS pass-rate. Activate when the user says: '/job-finder', 'job-finder', 'tailor my CV', 'optimize my CV for this job', 'create a CV for this position', or pastes a job listing / job URL with the implicit ask of generating a tailored CV. The skill: (1) ingests a job listing (URL, pasted text, or file path); (2) extracts ATS-critical keywords, must-have and nice-to-have skills, the exact job title, and seniority level; (3) reads the base CV at ~/jobmaxxing/base_cv.tex; (4) generates a tailored variant cv_nl_<role-slug>.tex by re-writing the Summary, re-ordering and re-phrasing Experience bullets, and re-prioritizing the Skills section — using ONLY facts already in the base CV (zero fabrication); (5) compiles with tectonic and opens the PDF. Designed for US-style ATS systems (Greenhouse, Lever, Workday, Taleo)."
argument-hint: "[job-listing-URL or 'paste' or 'file:<path>']"
user_invocable: true
---

# Job Finder — ATS-tuned CV variant generator

You generate a CV variant tailored to a specific job listing, optimized to clear ATS (Applicant Tracking System) filters used by US companies like Slalom, Microsoft, AWS, Snowflake, etc.

## Inputs and base files

- **Base CV (source):** `~/jobmaxxing/base_cv.tex` — the canonical LaTeX CV. Always read it fresh; do not assume its contents from memory.
- **Output directory:** `~/jobmaxxing/`
- **Output naming:** `cv_nl_<role-slug>.tex` and `.pdf` (lowercase, snake_case, max 3 words). Examples: `cv_nl_analytics.tex`, `cv_nl_data_engineer.tex`, `cv_nl_ml_engineer.tex`.
- **Compiler:** `tectonic` (the only LaTeX engine available on this machine; pdflatex/xelatex are not installed). Run from inside `~/jobmaxxing/`.

## Hard rules — never violate

1. **ZERO fabrication.** Only use skills, projects, dates, and achievements that already appear in `base_cv.tex`. If the JD requires a skill Nicolás doesn't have, surface it to the user as a gap — never invent it. Examples of gaps to surface: "JD requires Snowflake, base CV doesn't list it — I'll omit unless you confirm you have it."
2. **Preserve all facts.** Dates, GPA, company names, degree names, locations, the double-degree framing — copy verbatim.
3. **Re-frame, don't re-invent.** Bullets can be re-phrased to use JD-keyword vocabulary IF the underlying work genuinely matches. Example: "Built full-stack tooling that lets clients test AI" → "Built data-driven internal tools enabling stakeholders to validate analytics outputs" is OK only if the work actually involved stakeholders + analytics-style validation.
4. **US-style ATS-friendly format only.** Keep section names exactly: `SUMMARY`, `EXPERIENCE`, `EDUCATION`, `SKILLS & LANGUAGES`. Single column, no photo, no graphics, no tables, no multi-column layouts. The base CV preamble is already ATS-safe — never alter it.
5. **Mirror the JD's job title in the subtitle line** under the name. If the JD is "Analytics Engineer", change the subtitle from "Machine Learning Engineer · AI Consultant" to "Analytics Engineer · Data & AI Consultant" (only if the underlying experience supports it; pivot, don't lie).
6. **Exact-match keywords.** ATS systems do literal string matching. If the JD says "Python", use "Python" — not "Python 3" or "Py". If it says "SQL", don't substitute "T-SQL" or "PostgreSQL" unless the JD also uses those.
7. **Include both acronym and spelled-out forms** for high-value keywords on first mention: e.g., "Natural Language Processing (NLP)", "Machine Learning (ML)", "Extract, Transform, Load (ETL)" — only if Nicolás genuinely has the experience.
8. **No commits.** Don't initialize git or commit anything in `~/jobmaxxing/` unless the user explicitly asks.
9. **No "Remote" location string on the current Innovaitors role.** Per Nicolás's explicit preference (May 2026), the third argument to `\role{Innovaitors}{...}` should be empty `{}`, not `Remote`. Past roles keep their real city/country (e.g., Cergy, France; Cali, Colombia).

## Operational flow

### Step 0 — Acquire the job listing

Detect the argument form:

- **URL** (starts with `http://` or `https://`): use `WebFetch` with a prompt like "Extract the full job description text including job title, company, required skills, preferred skills, responsibilities, seniority level, and location. Preserve technical terms verbatim."
- **`file:<path>`**: read the file with the Read tool.
- **`paste`** or no argument: ask the user to paste the full JD text into the chat. Wait for their reply before proceeding.
- **Raw pasted text** (looks like a job description): use it directly.

If the user provided no input at all, ask: "Paste the job description, or give me a URL / file path."

### Step 1 — Extract structured JD data

Parse the JD and produce a structured extraction. Show it to the user for confirmation before generating the CV.

**Required fields:**
- `job_title` (exact, e.g., "Analytics Engineer", "Senior Data Scientist")
- `role_slug` (snake_case, max 3 words for the filename)
- `company` (e.g., "Slalom")
- `seniority` (junior / mid / senior / staff — inferred from the JD)
- `location` (city / remote / hybrid)
- `must_have_skills` (the hard requirements — usually under "Requirements" or "Qualifications")
- `nice_to_have_skills` (the "preferred" or "bonus" list)
- `keywords` (high-frequency technical terms, methodologies, tools mentioned in the JD — these are what ATS scans for)
- `responsibilities` (3–5 key responsibilities — used to re-order bullets)
- `ats_system` (if detectable from the URL: greenhouse.io, lever.co, workday.com, taleo.net, ashbyhq.com — note that all use literal keyword matching)

**Present the extraction back to the user as a brief summary** (markdown bullet list), and ask: "Does this match how you read the JD? Anything to adjust before I tailor the CV?"

### Step 2 — Coverage analysis (gap surfacing)

Before writing the new CV, compare `must_have_skills` and `keywords` against the base CV content. Produce a coverage table:

| Skill / Keyword | In base CV? | Action |
|---|---|---|
| Python | Yes | Promote in Skills, lead bullet |
| dbt | No | **GAP — confirm with user before omitting or honest-add** |
| SQL | Yes | Promote in Skills |
| ... | ... | ... |

For each **GAP**, ask the user inline: "JD requires X. Base CV doesn't mention it. Do you have hands-on X experience? If yes, I'll add it honestly; if no, I'll leave it out (which may hurt ATS score for this listing)." Never auto-add skills.

### Step 3 — Generate the tailored LaTeX file

1. Read `~/jobmaxxing/base_cv.tex` fresh with the Read tool.
2. Write `~/jobmaxxing/cv_nl_<role_slug>.tex` with these modifications, **preserving the entire preamble byte-for-byte**:

   - **Subtitle line** (under the name in `\cvheader`): mirror the JD's job title, possibly with a complementary descriptor. Examples:
     - JD "Analytics Engineer" → "Analytics Engineer  ·  Data & AI Consultant"
     - JD "Senior ML Engineer" → "Senior Machine Learning Engineer  ·  AI Consultant"
     - JD "Data Scientist" → "Data Scientist  ·  Machine Learning Engineer"
   - **Summary paragraph**: rewrite to lead with the exact `job_title` keyword and weave in 5–8 of the top `must_have_skills` and `keywords`. Keep ~3–5 sentences. Preserve voice (first person implicit, no "I am" openers). Keep the research depth or the consulting breadth depending on what the JD emphasizes.
   - **Experience bullets**: keep the same companies, dates, and order. Within each role, **re-order bullets** to put the most JD-relevant ones first. **Re-phrase up to 50% of the bullets** to use JD vocabulary, but only when the underlying work truly matches. Add quantification where it exists in the base CV — never invent numbers.
   - **Skills & Languages**: re-order the lines so the category most relevant to the JD comes first. Within each line, re-order tools to put JD-matched tools first. Keep all original skills — do not delete any.
   - **Education**: leave unchanged.

3. **Compile**:
   ```bash
   cd ~/jobmaxxing && tectonic cv_nl_<role_slug>.tex
   ```

4. If compile fails, fix the LaTeX issue (most common: special characters like `&`, `%`, `_`, `#` in pasted JD text need escaping) and retry.

5. **Open** the resulting PDF:
   ```bash
   open ~/jobmaxxing/cv_nl_<role_slug>.pdf
   ```

### Step 4 — Report changes

After opening, give the user a concise change report:

- **File written:** `~/jobmaxxing/cv_nl_<role_slug>.{tex,pdf}`
- **Subtitle changed:** old → new
- **Summary keywords injected:** (list)
- **Bullets re-ordered:** (count per role)
- **Bullets re-phrased:** (count per role)
- **Skills re-ordered:** (which category moved up)
- **Gaps surfaced:** (any JD skills not in base CV)
- **ATS readiness estimate:** rough match rate (e.g., "covers 9/11 must-have keywords").

Then: "Open and review — let me know if any bullet feels too far from the base truth and I'll dial it back."

## Style guidance (deeper)

### Action verbs that score well in US ATS
Prefer: **Built, Designed, Deployed, Optimized, Reduced, Increased, Automated, Architected, Led, Delivered, Implemented, Migrated, Modeled, Engineered, Productionized, Benchmarked, Validated, Shipped.**
Avoid: "Helped", "Worked on", "Assisted", "Responsible for" (these are weak and signal low seniority to recruiters).

### Quantification
Where the base CV has implicit results (e.g., "outperformed the state-of-the-art Hammoudeh & Lowd 2022"), retain that — it's already quantified. Where the base CV is unquantified, leave it — never invent numbers.

### Keyword density
Aim for each must-have keyword to appear **2–3 times** across the CV (Summary + Experience + Skills). More than 3 is keyword stuffing — ATS systems (Workday in particular) penalize stuffing.

### Length
Single page is ideal for US recruiters. Two pages acceptable for senior+. If the tailored CV overflows by a small margin, tighten bullets first; don't shrink fonts below 10pt or margins below 0.5in.

## Examples of valid role slugs

- `analytics` → `cv_nl_analytics.{tex,pdf}`
- `data_engineer` → `cv_nl_data_engineer.{tex,pdf}`
- `ml_engineer` → `cv_nl_ml_engineer.{tex,pdf}`
- `ai_consultant` → `cv_nl_ai_consultant.{tex,pdf}`
- `data_scientist` → `cv_nl_data_scientist.{tex,pdf}`

## When the user iterates

If they say "the summary is too research-heavy, lean more on consulting" or "drop the influence-functions language for this one", **edit the existing tailored file** with the Edit tool — don't regenerate from scratch. Recompile and reopen.

## Failure modes to avoid

- **Don't re-do the base CV.** The base is locked. Always modify the variant, not `base_cv.tex`.
- **Don't add Spanish.** The CV target audience is English-speaking. Even if the user chats with you in Spanish, the CV stays in English.
- **Don't include a photo.** Period.
- **Don't switch to a two-column layout** even if the user thinks it looks fancier — it breaks ATS parsers. Push back gently if requested.
- **Don't add a "References" section.** US convention drops it.
- **Don't change the contact info** (phone, email, LinkedIn, GitHub) — those are in the base CV and stable.
