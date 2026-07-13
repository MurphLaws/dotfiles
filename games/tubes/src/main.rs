use std::collections::HashSet;
use std::io;

use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use rand::rngs::StdRng;
use rand::seq::SliceRandom;
use rand::{Rng, SeedableRng};
use ratatui::prelude::*;
use ratatui::widgets::Paragraph;

const TUBE_CAP: usize = 4;
const GRID_COLS: usize = 4;
const TUBE_W: usize = 8; // inner width of a tube in cells
const H_GAP: usize = 2;
const SLOT_H: usize = 1; // rows per slot
const V_GAP: usize = 2;

const DEFAULT_COLORS: usize = 10;
const MIN_COLORS: usize = 4;
const MAX_COLORS: usize = 14;

const PALETTE: [Color; 14] = [
    Color::Rgb(235, 60, 60),   // red
    Color::Rgb(255, 150, 40),  // orange
    Color::Rgb(255, 225, 60),  // yellow
    Color::Rgb(70, 200, 80),   // green
    Color::Rgb(60, 220, 220),  // cyan
    Color::Rgb(70, 110, 255),  // blue
    Color::Rgb(160, 80, 220),  // purple
    Color::Rgb(255, 105, 200), // pink
    Color::Rgb(230, 230, 230), // white
    Color::Rgb(150, 95, 45),   // brown
    Color::Rgb(25, 130, 55),   // dark green
    Color::Rgb(140, 145, 155), // gray
    Color::Rgb(185, 160, 255), // lavender
    Color::Rgb(140, 25, 45),   // maroon
];

type Tubes = Vec<Vec<u8>>;

fn is_solved(tubes: &Tubes) -> bool {
    tubes
        .iter()
        .all(|t| t.is_empty() || (t.len() == TUBE_CAP && t.iter().all(|c| *c == t[0])))
}

fn is_uniform(t: &[u8]) -> bool {
    t.iter().all(|c| *c == t[0])
}

/// Length of the run of same-colored units at the top of a tube
fn top_run(t: &[u8]) -> usize {
    match t.last() {
        None => 0,
        Some(&color) => t.iter().rev().take_while(|c| **c == color).count(),
    }
}

/// Whether pouring src -> dst is a legal move, and how many units would move
fn pour_amount(tubes: &Tubes, src: usize, dst: usize) -> usize {
    if src == dst {
        return 0;
    }
    let (s, d) = (&tubes[src], &tubes[dst]);
    let Some(&color) = s.last() else { return 0 };
    let free = TUBE_CAP - d.len();
    if free == 0 {
        return 0;
    }
    if !d.is_empty() && *d.last().unwrap() != color {
        return 0;
    }
    // matching colors move together: the whole top run must fit,
    // otherwise the move is not allowed
    let run = top_run(s);
    if run <= free {
        run
    } else {
        0
    }
}

fn apply_pour(tubes: &mut Tubes, src: usize, dst: usize, n: usize) {
    for _ in 0..n {
        let c = tubes[src].pop().unwrap();
        tubes[dst].push(c);
    }
}

fn canonical_key(tubes: &Tubes) -> Vec<Vec<u8>> {
    let mut k = tubes.clone();
    k.sort();
    k
}

/// DFS check that a puzzle is solvable (bounded, plenty for 12 tubes)
fn solvable(tubes: &Tubes) -> bool {
    fn dfs(tubes: &mut Tubes, seen: &mut HashSet<Vec<Vec<u8>>>) -> bool {
        if is_solved(tubes) {
            return true;
        }
        if seen.len() > 200_000 {
            return false;
        }
        let key = canonical_key(tubes);
        if !seen.insert(key) {
            return false;
        }
        let n = tubes.len();
        for src in 0..n {
            // pointless to pour out of a finished or empty tube
            if tubes[src].is_empty()
                || (tubes[src].len() == TUBE_CAP && is_uniform(&tubes[src]))
            {
                continue;
            }
            for dst in 0..n {
                let amount = pour_amount(tubes, src, dst);
                if amount == 0 {
                    continue;
                }
                // pointless to move a uniform tube onto an empty tube
                if tubes[dst].is_empty() && is_uniform(&tubes[src]) {
                    continue;
                }
                apply_pour(tubes, src, dst, amount);
                if dfs(tubes, seen) {
                    return true;
                }
                apply_pour(tubes, dst, src, amount);
            }
        }
        false
    }
    let mut t = tubes.clone();
    dfs(&mut t, &mut HashSet::new())
}

fn gen_puzzle(n_colors: usize, n_empty: usize, rng: &mut StdRng) -> Tubes {
    loop {
        let mut units: Vec<u8> = (0..n_colors)
            .flat_map(|c| std::iter::repeat(c as u8).take(TUBE_CAP))
            .collect();
        units.shuffle(rng);
        let mut tubes: Tubes = units.chunks(TUBE_CAP).map(<[u8]>::to_vec).collect();
        for _ in 0..n_empty {
            tubes.push(Vec::new());
        }
        if !is_solved(&tubes) && solvable(&tubes) {
            return tubes;
        }
    }
}

struct App {
    tubes: Tubes,
    initial: Tubes,
    cursor: usize,
    selected: Option<usize>,
    history: Vec<(usize, usize, usize)>,
    moves: u32,
    seed: u64,
    daily: bool,
    /// number of colors in play — the difficulty level
    colors: usize,
    won: bool,
    message: String,
    /// set on the first pour of the puzzle
    started_at: Option<std::time::Instant>,
    /// final time, frozen when the puzzle is solved
    solve_time: Option<std::time::Duration>,
}

impl App {
    fn new(seed: u64, daily: bool, colors: usize) -> Self {
        let colors = colors.clamp(MIN_COLORS, MAX_COLORS);
        let mut rng = StdRng::seed_from_u64(seed);
        let tubes = gen_puzzle(colors, 2, &mut rng);
        Self {
            initial: tubes.clone(),
            tubes,
            cursor: 0,
            selected: None,
            history: Vec::new(),
            moves: 0,
            seed,
            daily,
            colors,
            won: false,
            message: String::new(),
            started_at: None,
            solve_time: None,
        }
    }

    fn reset(&mut self) {
        self.tubes = self.initial.clone();
        self.selected = None;
        self.history.clear();
        self.moves = 0;
        self.won = false;
        self.message.clear();
        self.started_at = None;
        self.solve_time = None;
    }

    fn elapsed(&self) -> std::time::Duration {
        self.solve_time.unwrap_or_else(|| {
            self.started_at
                .map(|t| t.elapsed())
                .unwrap_or_default()
        })
    }

    fn undo(&mut self) {
        if let Some((src, dst, n)) = self.history.pop() {
            apply_pour(&mut self.tubes, dst, src, n);
            self.moves = self.moves.saturating_sub(1);
            self.won = false;
            self.message.clear();
        }
        self.selected = None;
    }

    fn choose(&mut self) {
        if self.won {
            return;
        }
        match self.selected {
            None => {
                if !self.tubes[self.cursor].is_empty() {
                    self.selected = Some(self.cursor);
                    self.message.clear();
                }
            }
            Some(src) if src == self.cursor => self.selected = None,
            Some(src) => {
                let dst = self.cursor;
                let n = pour_amount(&self.tubes, src, dst);
                if n == 0 {
                    // convenience: treat as picking up the other tube instead
                    if !self.tubes[dst].is_empty() {
                        self.selected = Some(dst);
                    } else {
                        self.selected = None;
                    }
                    return;
                }
                apply_pour(&mut self.tubes, src, dst, n);
                self.history.push((src, dst, n));
                self.moves += 1;
                self.selected = None;
                if self.started_at.is_none() {
                    self.started_at = Some(std::time::Instant::now());
                }
                if is_solved(&self.tubes) {
                    self.won = true;
                    let elapsed = self.elapsed();
                    self.solve_time = Some(elapsed);
                    let (seed_best, overall_best) =
                        record_time(self.seed, self.daily, self.colors, self.moves, elapsed);
                    // a per-seed comparison only means something when this seed
                    // was played before; otherwise compare against all solves
                    let verdict = match (seed_best, overall_best) {
                        (Some(b), _) if elapsed < b => " New best for this seed!".to_string(),
                        (Some(b), _) => format!(" (best for this seed: {})", fmt_duration(b)),
                        (None, Some(b)) if elapsed < b => " New overall best!".to_string(),
                        (None, Some(b)) => format!(" (overall best: {})", fmt_duration(b)),
                        (None, None) => String::new(),
                    };
                    self.message = format!(
                        "Solved in {} moves, {}!{} [n]ew puzzle",
                        self.moves,
                        fmt_duration(elapsed),
                        verdict
                    );
                }
            }
        }
    }
}

fn fmt_duration(d: std::time::Duration) -> String {
    let s = d.as_secs();
    format!("{}:{:02}", s / 60, s % 60)
}

fn times_file() -> std::path::PathBuf {
    let dir = dirs_data_dir().join("tubes");
    let _ = std::fs::create_dir_all(&dir);
    dir.join("times.csv")
}

fn dirs_data_dir() -> std::path::PathBuf {
    std::env::var_os("XDG_DATA_HOME")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| {
            let home = std::env::var_os("HOME").expect("HOME not set");
            std::path::PathBuf::from(home).join(".local/share")
        })
}

/// Append a solve record and return the previous best time for this seed, if any
/// One row of the times file. Older rows have no level column: they were
/// all played at the default level.
fn parse_row(line: &str) -> Option<(String, String, u64, usize, u32, u64)> {
    let f: Vec<&str> = line.split(',').collect();
    match f.len() {
        5 => Some((
            f[0].to_string(),
            f[1].to_string(),
            f[2].parse().ok()?,
            DEFAULT_COLORS,
            f[3].parse().ok()?,
            f[4].parse().ok()?,
        )),
        6 => Some((
            f[0].to_string(),
            f[1].to_string(),
            f[2].parse().ok()?,
            f[3].parse().ok()?,
            f[4].parse().ok()?,
            f[5].parse().ok()?,
        )),
        _ => None,
    }
}

fn record_time(
    seed: u64,
    daily: bool,
    colors: usize,
    moves: u32,
    time: std::time::Duration,
) -> (Option<std::time::Duration>, Option<std::time::Duration>) {
    let path = times_file();
    let mut seed_best: Option<u64> = None;
    let mut overall_best: Option<u64> = None;
    if let Ok(content) = std::fs::read_to_string(&path) {
        for l in content.lines() {
            let Some((_date, _mode, s, lvl, _moves, secs)) = parse_row(l) else {
                continue;
            };
            // bests only mean something within the same difficulty level
            if lvl != colors {
                continue;
            }
            overall_best = Some(overall_best.map_or(secs, |b| b.min(secs)));
            if s == seed {
                seed_best = Some(seed_best.map_or(secs, |b| b.min(secs)));
            }
        }
    }
    let line = format!(
        "{},{},{},{},{},{}\n",
        chrono::Local::now().format("%Y-%m-%d %H:%M:%S"),
        if daily { "daily" } else { "random" },
        seed,
        colors,
        moves,
        time.as_secs(),
    );
    use std::io::Write as _;
    if let Ok(mut f) = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&path)
    {
        let _ = f.write_all(line.as_bytes());
    }
    (
        seed_best.map(std::time::Duration::from_secs),
        overall_best.map(std::time::Duration::from_secs),
    )
}

fn today_seed() -> u64 {
    use chrono::Datelike;
    let d = chrono::Local::now().date_naive();
    u64::from(d.year_ce().1) * 10_000 + u64::from(d.month()) * 100 + u64::from(d.day())
}

fn render(frame: &mut Frame, app: &App) {
    let area = frame.area();
    let n = app.tubes.len();
    let rows = n.div_ceil(GRID_COLS);

    let tube_h = TUBE_CAP * SLOT_H + 3; // top border + slots + bottom border + label
    let grid_w = (GRID_COLS * (TUBE_W + 2) + (GRID_COLS - 1) * H_GAP) as u16;
    let grid_h = (rows * tube_h + (rows - 1) * V_GAP) as u16;
    let x0 = area.x + area.width.saturating_sub(grid_w) / 2;
    let y0 = area.y + 2 + area.height.saturating_sub(grid_h + 4) / 2;

    // header
    let mode = if app.daily { "daily" } else { "random" };
    let timer = if app.started_at.is_some() || app.solve_time.is_some() {
        format!(" • time: {}", fmt_duration(app.elapsed()))
    } else {
        String::new()
    };
    let header = format!(
        " tubes • {} #{} • lvl {} • moves: {}{} ",
        mode, app.seed, app.colors, app.moves, timer
    );
    frame.render_widget(
        Paragraph::new(header)
            .style(Style::default().add_modifier(Modifier::BOLD))
            .alignment(Alignment::Center),
        Rect::new(area.x, area.y, area.width, 1),
    );

    for (i, tube) in app.tubes.iter().enumerate() {
        let col = i % GRID_COLS;
        let row = i / GRID_COLS;
        let tx = x0 + (col * (TUBE_W + 2 + H_GAP)) as u16;
        let ty = y0 + (row * (tube_h + V_GAP)) as u16;

        let border_style = if app.selected == Some(i) {
            Style::default()
                .fg(Color::Yellow)
                .add_modifier(Modifier::BOLD)
        } else if app.cursor == i {
            Style::default()
                .fg(Color::White)
                .add_modifier(Modifier::BOLD)
        } else {
            Style::default().fg(Color::DarkGray)
        };

        let mut lines: Vec<Line> = Vec::with_capacity(TUBE_CAP * SLOT_H + 3);
        lines.push(Line::from(Span::styled(
            format!("┌{}┐", "─".repeat(TUBE_W)),
            border_style,
        )));
        // no gravity: the column is anchored to the top of the tube and never
        // slides down. Pours drain from the BOTTOM of the column, and incoming
        // liquid attaches below the receiving column. Empty space stays at the
        // bottom of the tube.
        for slot_row in 0..TUBE_CAP {
            let inner = if slot_row < tube.len() {
                Span::styled(
                    "█".repeat(TUBE_W),
                    Style::default().fg(PALETTE[tube[slot_row] as usize]),
                )
            } else {
                Span::raw(" ".repeat(TUBE_W))
            };
            for _ in 0..SLOT_H {
                lines.push(Line::from(vec![
                    Span::styled("│", border_style),
                    inner.clone(),
                    Span::styled("│", border_style),
                ]));
            }
        }
        lines.push(Line::from(Span::styled(
            format!("└{}┘", "─".repeat(TUBE_W)),
            border_style,
        )));
        // label
        let label = format!("{:^w$}", i + 1, w = TUBE_W + 2);
        lines.push(Line::from(Span::styled(
            label,
            if app.cursor == i {
                Style::default().add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(Color::DarkGray)
            },
        )));

        let rect = Rect::new(tx, ty, (TUBE_W + 2) as u16, tube_h as u16);
        if rect.right() <= area.right() && rect.bottom() <= area.bottom() {
            frame.render_widget(Paragraph::new(lines), rect);
        }
    }

    // footer
    let footer = if app.won {
        app.message.clone()
    } else if !app.message.is_empty() {
        app.message.clone()
    } else {
        "←↓↑→/hjkl move • enter/space pick & pour • u undo • r restart • n new • d daily • q quit"
            .to_string()
    };
    let footer_style = if app.won {
        Style::default()
            .fg(Color::Green)
            .add_modifier(Modifier::BOLD)
    } else {
        Style::default().fg(Color::DarkGray)
    };
    frame.render_widget(
        Paragraph::new(footer)
            .style(footer_style)
            .alignment(Alignment::Center),
        Rect::new(area.x, area.bottom().saturating_sub(2), area.width, 1),
    );
}

fn print_times() {
    match std::fs::read_to_string(times_file()) {
        Ok(content) if !content.trim().is_empty() => {
            println!(
                "{:<19}  {:<6}  {:<20}  {:>3}  {:>5}  {:>6}",
                "date", "mode", "seed", "lvl", "moves", "time"
            );
            let mut best: Option<u64> = None;
            for line in content.lines() {
                if let Some((date, mode, seed, lvl, moves, secs)) = parse_row(line) {
                    best = Some(best.map_or(secs, |b| b.min(secs)));
                    println!(
                        "{:<19}  {:<6}  {:<20}  {:>3}  {:>5}  {:>6}",
                        date,
                        mode,
                        seed,
                        lvl,
                        moves,
                        fmt_duration(std::time::Duration::from_secs(secs))
                    );
                }
            }
            if let Some(b) = best {
                println!(
                    "\nbest: {}",
                    fmt_duration(std::time::Duration::from_secs(b))
                );
            }
        }
        _ => println!("No recorded times yet."),
    }
}

fn main() -> io::Result<()> {
    if std::env::args().any(|a| a == "--times" || a == "-times" || a == "-t") {
        print_times();
        return Ok(());
    }
    let daily = std::env::args().any(|a| a == "--daily" || a == "-d");
    // difficulty level: a bare number argument = how many colors are in play
    let colors = std::env::args()
        .skip(1)
        .find_map(|a| a.parse::<usize>().ok())
        .unwrap_or(DEFAULT_COLORS)
        .clamp(MIN_COLORS, MAX_COLORS);
    let seed = if daily {
        today_seed()
    } else {
        rand::thread_rng().gen()
    };
    let mut app = App::new(seed, daily, colors);

    let mut terminal = ratatui::init();
    let result = run(&mut terminal, &mut app);
    ratatui::restore();
    result
}

fn run(terminal: &mut ratatui::DefaultTerminal, app: &mut App) -> io::Result<()> {
    loop {
        terminal.draw(|f| render(f, app))?;
        // tick so the timer stays live while waiting for input
        if !event::poll(std::time::Duration::from_millis(250))? {
            continue;
        }
        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }
        let n = app.tubes.len();
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => break,
            KeyCode::Left | KeyCode::Char('h') => app.cursor = (app.cursor + n - 1) % n,
            KeyCode::Right | KeyCode::Char('l') => app.cursor = (app.cursor + 1) % n,
            KeyCode::Down | KeyCode::Char('j') => app.cursor = (app.cursor + GRID_COLS) % n,
            KeyCode::Up | KeyCode::Char('k') => app.cursor = (app.cursor + n - GRID_COLS) % n,
            KeyCode::Enter | KeyCode::Char(' ') => app.choose(),
            KeyCode::Char('u') => app.undo(),
            KeyCode::Char('r') => app.reset(),
            KeyCode::Char('n') => *app = App::new(rand::thread_rng().gen(), false, app.colors),
            KeyCode::Char('d') => *app = App::new(today_seed(), true, app.colors),
            KeyCode::Char(c) if c.is_ascii_digit() => {
                let d = c.to_digit(10).unwrap() as usize;
                let idx = if d == 0 { 9 } else { d - 1 };
                if idx < n {
                    app.cursor = idx;
                    app.choose();
                }
            }
            _ => {}
        }
    }
    Ok(())
}
