alias cc='command claude --dangerously-skip-permissions'
alias claude='command claude --dangerously-skip-permissions'

# ccommit — generate a Conventional Commits message from the staged diff using
# Claude (opus, medium effort) and commit it. You are the sole author: the
# commit is created by git itself, and Claude is instructed to never add a
# Co-Authored-By / attribution trailer.
ccommit() {
  emulate -L zsh

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 "✗ ccommit: not inside a git repository"
    return 1
  }

  # Stage everything if nothing is staged yet.
  if git diff --cached --quiet; then
    print "• No staged changes — staging everything (git add -A)"
    git add -A
  fi

  if git diff --cached --quiet; then
    print -u2 "✗ ccommit: nothing to commit"
    return 1
  fi

  print "• Generating commit message with Claude (opus · medium effort)…"

  local sysprompt='You are a git commit message generator. Output ONLY the commit message and NOTHING else: no prose, no greetings, no explanations, no markdown code fences, and NEVER a Co-Authored-By or any attribution trailer. The user is the sole author. Format using Conventional Commits: a subject line "<type>(<scope>): <description>" in the imperative mood, lowercase description, <=72 characters, scope optional. For non-trivial changes add a blank line then 1-4 concise "- " bullets describing what changed and why. Allowed types: feat, fix, refactor, chore, docs, style, test, perf, build, ci.'

  local msg
  msg=$(git --no-pager diff --cached | command claude -p \
    --model opus \
    --effort medium \
    --disable-slash-commands \
    --append-system-prompt "$sysprompt" \
    'Write a single commit message for the following staged git diff:')

  # Strip stray markdown fences and surrounding blank lines.
  msg=$(print -r -- "$msg" | sed '/^[[:space:]]*```/d')
  msg="${msg##[[:space:]]##}"
  msg="${msg%%[[:space:]]##}"

  if [[ -z "${msg//[[:space:]]/}" ]]; then
    print -u2 "✗ ccommit: Claude returned an empty message — aborting"
    return 1
  fi

  print
  print "┌─ Proposed commit ──────────────────────────────"
  print -r -- "$msg" | sed 's/^/│ /'
  print "└────────────────────────────────────────────────"
  print

  local reply
  print -n "Commit? [Y]es / [e]dit / [n]o: "
  read -r reply
  case "$reply" in
    n|N)
      print "✗ Aborted — changes remain staged"
      return 1
      ;;
    e|E)
      local tmp
      tmp=$(mktemp -t ccommit) || return 1
      print -r -- "$msg" > "$tmp"
      "${EDITOR:-nvim}" "$tmp"
      git commit -F "$tmp"
      local rc=$?
      rm -f "$tmp"
      return $rc
      ;;
    *)
      print -r -- "$msg" | git commit -F -
      ;;
  esac
}
