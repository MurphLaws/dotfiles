#include <errno.h>
#include <getopt.h>
#include <libgen.h>
#include <locale.h>
#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>

#include "common.h"
#include "game.h"
#include "keyboard.h"

#ifndef VERSION
#define VERSION "n/a"
#endif

const char *program_name;
struct game game;

void version(void);
void usage(const char *);
void draw_greeting(void);
static void centered_mvprintw(int y, const char *str);
static void record_time(long secs);
static void times_path(char *path, size_t size);
static void print_times(void);

int main(int argc, char *argv[]) {
  int option;
  int option_index;
  int passes_through_deck = -1; /* -1 means infinite passes */
  static int four_color_deck;
  static const struct option options[] = {
      {"help", no_argument, NULL, 'h'},
      {"version", no_argument, NULL, 'v'},
      {"passes", required_argument, NULL, 'p'},
      {"four-color-deck", no_argument, &four_color_deck, 1},
      {0, 0, 0, 0}};

  program_name = basename(argv[0]);

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--times") == 0 || strcmp(argv[i], "-times") == 0 ||
        strcmp(argv[i], "-t") == 0) {
      print_times();
      return (0);
    }
  }

  while ((option = getopt_long(argc, argv, "hvp:", options, &option_index)) !=
         -1) {
    switch (option) {
    case 'v':
      version();
      exit(0);
    case 'p':
      passes_through_deck = atoi(optarg);
      break;
    case 'h':
    case '?':
      usage(program_name);
      exit(0);
    case 0:
      if (options[option_index].flag != 0)
        break;
    default:
      usage(program_name);
      exit(0);
    }
  }

  setlocale(LC_ALL, "");
  initscr();
  raw();
  noecho();
  keypad(stdscr, TRUE);
  start_color();
  curs_set(FALSE);
  set_escdelay(0);

  /* Always use the terminal's default background (no color background). */
  use_default_colors();

  /* Transparent cards: text color only, terminal background shows through. */
  init_pair(1, -1, -1);             /* Black-suit text (terminal default fg) */
  init_pair(2, COLOR_RED, -1);      /* Red-suit text */
  init_pair(3, COLOR_GREEN, -1);    /* Spades in four-color mode */
  init_pair(4, COLOR_YELLOW, -1);   /* Diamonds in four-color mode */
  init_pair(5, COLOR_CYAN, -1);     /* Card back pattern */
  init_pair(6, -1, -1);

  int key;

  while (!term_size_ok()) {
    clear();
    mvprintw(1, 1, SMALL_TERM_MSG);
    refresh();
    if ((key = getch()) == 'q' || key == 'Q') {
      endwin();
      return (0);
    }
  }

  clear();
  draw_greeting();
  refresh();

  for (;;) {
    if ((key = getch()) == 'q' || key == 'Q') {
      endwin();
      return (0);
    }
    if (term_size_ok()) {
      clear();
      draw_greeting();
      refresh();
      if (key == KEY_SPACEBAR) {
        clear();
        refresh();
        game_init(&game, passes_through_deck, four_color_deck);
        break;
      }
    } else if (key == KEY_RESIZE) {
      clear();
      mvprintw(1, 1, SMALL_TERM_MSG);
      refresh();
    }
  }

  time_t started = 0;
  do {
    key = getch();
    if (started == 0)
      started = time(NULL); /* the clock starts on the first move */
    keyboard_event(key);
  } while (!game_won());

  long secs = started ? (long)(time(NULL) - started) : 0;
  record_time(secs);

  endwin();
  game_end();
  printf("You won in %ld:%02ld.\n", secs / 60, secs % 60);

  return (0);
}

/* Append the solve time to ~/.local/share/solitaire/times.csv
 * (same record style as the other games: date,seconds) */
static void times_path(char *path, size_t size) {
  const char *xdg = getenv("XDG_DATA_HOME");
  const char *home = getenv("HOME");
  char dir[1024];

  if (xdg != NULL && *xdg != '\0')
    snprintf(dir, sizeof(dir), "%s/solitaire", xdg);
  else if (home != NULL)
    snprintf(dir, sizeof(dir), "%s/.local/share/solitaire", home);
  else {
    path[0] = '\0';
    return;
  }
  mkdir(dir, 0755); /* best effort; parents normally exist */
  snprintf(path, size, "%s/times.csv", dir);
}

/* Print all recorded times (--times flag) */
static void print_times(void) {
  char path[1200];
  char line[256];
  long best = -1;
  FILE *f;

  times_path(path, sizeof(path));
  f = path[0] != '\0' ? fopen(path, "r") : NULL;
  if (f == NULL) {
    printf("No recorded times yet.\n");
    return;
  }
  printf("%-19s  %6s\n", "date", "time");
  while (fgets(line, sizeof(line), f) != NULL) {
    char date[32];
    long secs;
    if (sscanf(line, "%31[^,],%ld", date, &secs) == 2) {
      if (best < 0 || secs < best)
        best = secs;
      printf("%-19s  %3ld:%02ld\n", date, secs / 60, secs % 60);
    }
  }
  fclose(f);
  if (best >= 0)
    printf("\nbest: %ld:%02ld\n", best / 60, best % 60);
}

static void record_time(long secs) {
  char path[1200];
  char date[32];
  FILE *f;
  time_t now = time(NULL);

  times_path(path, sizeof(path));
  if (path[0] == '\0')
    return;
  f = fopen(path, "a");
  if (f == NULL)
    return;
  strftime(date, sizeof(date), "%Y-%m-%d %H:%M:%S", localtime(&now));
  fprintf(f, "%s,%ld\n", date, secs);
  fclose(f);
}

static void centered_mvprintw(int y, const char *str) {
  int len = (int)strlen(str);
  int x = (COLS - len) / 2;
  if (x < 0) x = 0;
  mvprintw(y, x, "%s", str);
}

void draw_greeting(void) {
  centered_mvprintw(8,  "Welcome to solitaire.");
  centered_mvprintw(10, "Move with the arrow keys or <hjkl>.");
  centered_mvprintw(12, "Use the space bar to select and place cards.");
  centered_mvprintw(14, "After selecting a card you can use <m> to select more");
  centered_mvprintw(15, "and <n> to select fewer. Press <Shift+M> to select all.");
  centered_mvprintw(17, "Press the space bar to play or q to quit.");
}

void usage(const char *program_name) {
  printf("usage: %s [OPTIONS]\n", program_name);
  printf("  -v, --version              Show version\n");
  printf("  -h, --help                 Show this message\n");
  printf("  -p, --passes               Number of passes through the deck  "
         "(default: infinite, use -1 for infinite)\n");
  printf("      --four-color-deck      Draw unique card suit colors       "
         "(default: false)\n");
}

void version(void) { printf("%s\n", VERSION); }
