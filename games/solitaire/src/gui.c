#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "card.h"
#include "deck.h"
#include "game.h"
#include "gui.h"

static const char *card_suits[4] = {"\u2666", "\u2660", "\u2665", "\u2663"};
static const char *card_values[13] = {"A", "2", "3",  "4", "5", "6", "7",
                                      "8", "9", "10", "J", "Q", "K"};

/*
 * Cards are drawn as ASCII art on the terminal's default background.
 * Frame is 7 wide x 5 tall:
 *   +-----+
 *   |V    |   value top-left
 *   |  s  |   suit centered
 *   |    V|   value bottom-right
 *   +-----+
 * Backs use an X pattern.
 */

static int card_color_pair(struct card *card) {
  if (game.four_color_deck == 0) {
    if (card->suit % 2 == 0) {
      return (RED_ON_WHITE);
    }
    return (BLACK_ON_WHITE);
  }
  switch (card->suit) {
  case SPADES:
    return (GREEN_ON_WHITE);
  case DIAMONDS:
    return (YELLOW_ON_WHITE);
  case CLUBS:
    return (BLACK_ON_WHITE);
  case HEARTS:
  default:
    return (RED_ON_WHITE);
  }
}

static void draw_front(struct card *card) {
  WINDOW *w = card->frame->window;
  const char *value = card_values[card->value];
  const char *suit = card_suits[card->suit];
  int vlen = (int)strlen(value); /* "A","2"-"9","J","Q","K" = 1; "10" = 2 */
  int pair = card_color_pair(card);

  werase(w);
  wbkgd(w, COLOR_PAIR(0));

  /*
   * Layout (7 wide x 5 tall) — value+suit live in the TOP border so they
   * remain visible when overlapping cards cover rows 1..4.
   *
   *   +Vs---+      row 0: top border with value and suit
   *   |     |      row 1
   *   |  s  |      row 2: middle suit
   *   |    V|      row 3: bottom-right value
   *   +-----+      row 4: bottom border
   *
   * For "10" (vlen=2), the suit sits one column further right.
   */
  mvwaddstr(w, 0, 0, "+");
  wattron(w, COLOR_PAIR(pair));
  mvwprintw(w, 0, 1, "%s", value);
  mvwprintw(w, 0, 1 + vlen, "%s", suit);
  wattroff(w, COLOR_PAIR(pair));
  for (int c = 2 + vlen; c < 6; c++) {
    mvwaddstr(w, 0, c, "-");
  }
  mvwaddstr(w, 0, 6, "+");

  /* Sides */
  mvwaddstr(w, 1, 0, "|");
  mvwaddstr(w, 1, 6, "|");
  mvwaddstr(w, 2, 0, "|");
  mvwaddstr(w, 2, 6, "|");
  mvwaddstr(w, 3, 0, "|");
  mvwaddstr(w, 3, 6, "|");
  /* Bottom border */
  mvwaddstr(w, 4, 0, "+-----+");

  /* Middle suit and bottom-right value — only visible on topmost card. */
  wattron(w, COLOR_PAIR(pair));
  mvwprintw(w, 2, 3, "%s", suit);
  mvwprintw(w, 3, 6 - vlen, "%s", value);
  wattroff(w, COLOR_PAIR(pair));
}

static void draw_back(struct card *card) {
  WINDOW *w = card->frame->window;

  werase(w);
  wbkgd(w, COLOR_PAIR(0));

  wattron(w, COLOR_PAIR(WHITE_ON_BLUE));
  /* Pattern covers row 0 too so covered cards stacked beneath others
   * still show the back pattern in the visible top strip. */
  mvwaddstr(w, 0, 0, "+XXXXX+");
  mvwaddstr(w, 1, 0, "|XXXXX|");
  mvwaddstr(w, 2, 0, "|XXXXX|");
  mvwaddstr(w, 3, 0, "|XXXXX|");
  mvwaddstr(w, 4, 0, "+XXXXX+");
  wattroff(w, COLOR_PAIR(WHITE_ON_BLUE));
}

void draw_card(struct card *card) {
  if (card->face == EXPOSED) {
    draw_front(card);
  } else {
    draw_back(card);
  }
  wrefresh(card->frame->window);
}

/* Draw an empty-slot placeholder (dashed outline). */
static void draw_empty_slot(WINDOW *w) {
  werase(w);
  wbkgd(w, COLOR_PAIR(0));
  mvwaddstr(w, 0, 0, "+-----+");
  mvwaddstr(w, 1, 0, "|     |");
  mvwaddstr(w, 2, 0, "|     |");
  mvwaddstr(w, 3, 0, "|     |");
  mvwaddstr(w, 4, 0, "+-----+");
}

void draw_stack(struct stack *stack) {
  if (stack_empty(stack)) {
    WINDOW *w = stack->card->frame->window;
    draw_empty_slot(w);
    if (stock_stack(stack)) {
      if (game.passes_through_deck_left != 0) {
        mvwprintw(w, 2, 3, "O");
      } else {
        mvwprintw(w, 2, 3, "X");
      }
    }
    wrefresh(w);
  } else {
    if (maneuvre_stack(stack)) {
      struct stack *stack_reversed_stack = stack_reverse(stack);
      for (struct stack *i = stack_reversed_stack; i; i = i->next) {
        draw_card(i->card);
      }
      stack_free(stack_reversed_stack);
    } else {
      draw_card(stack->card);
    }
  }
}

void draw_deck(struct deck *deck) {
  draw_stack(deck->stock);
  draw_stack(deck->waste_pile);
  for (int i = 0; i < FOUNDATION_STACKS_NUMBER; i++) {
    draw_stack(deck->foundation[i]);
  }
  for (int i = 0; i < MANEUVRE_STACKS_NUMBER; i++) {
    draw_stack(deck->maneuvre[i]);
  }
}

void draw_cursor(struct cursor *cursor) {
  if (cursor->marked) {
    mvwin(cursor->window, cursor->y, cursor->x);
    waddch(cursor->window, '@');
  } else {
    mvwin(cursor->window, cursor->y, cursor->x);
    waddch(cursor->window, '*');
  }
  wrefresh(cursor->window);
}

void erase_card(struct card *card) {
  werase(card->frame->window);
  wbkgd(card->frame->window, COLOR_PAIR(0));
  wrefresh(card->frame->window);
}

void erase_stack(struct stack *stack) {
  if (maneuvre_stack(stack)) {
    for (; stack; stack = stack->next) {
      erase_card(stack->card);
    }
  } else {
    erase_card(stack->card);
  }
}

void erase_cursor(struct cursor *cursor) {
  wdelch(cursor->window);
  wrefresh(cursor->window);
}
