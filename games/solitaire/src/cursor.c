#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <ncurses.h>
#include <assert.h>

#include "cursor.h"
#include "game.h"
#include "common.h"

void cursor_malloc(struct cursor **cursor) {
  if (!(*cursor = malloc(sizeof(**cursor)))) {
    tty_solitaire_generic_error(errno, __FILE__, __LINE__);
  }
  (*cursor)->window = newwin(1, 1, CURSOR_BEGIN_Y,
                             CURSOR_BEGIN_X + game.x_offset);
}

void cursor_init(struct cursor *cursor) {
  mvwin(cursor->window, CURSOR_BEGIN_Y, CURSOR_BEGIN_X + game.x_offset);
  cursor->y = CURSOR_BEGIN_Y;
  cursor->x = CURSOR_BEGIN_X + game.x_offset;
  cursor->marked = false;
}

void cursor_free(struct cursor *cursor) {
  delwin(cursor->window);
  free(cursor);
}

void cursor_mark(struct cursor *cursor) {
  cursor->marked = true;
}

void cursor_unmark(struct cursor *cursor) {
  cursor->marked = false;
}

void cursor_move(struct cursor *cursor, enum movement movement) {
  int left_bound = CURSOR_BEGIN_X + game.x_offset;
  int right_bound = CURSOR_MANEUVRE_6_X + game.x_offset;

  switch (movement) {
  case LEFT:
    if (cursor->x > left_bound) {
      cursor->x -= 8;
    } else {
      cursor->x = right_bound;
    }
    if (cursor->y > CURSOR_BEGIN_Y) {
      cursor_move(cursor, UP);
      cursor_move(cursor, DOWN);
    }
    break;
  case DOWN:
    if (cursor->y == CURSOR_BEGIN_Y) {
      int idx = (cursor->x - game.x_offset - CURSOR_BEGIN_X) / 8;
      if (idx >= 0 && idx < MANEUVRE_STACKS_NUMBER) {
        cursor->y = 6 + deck->maneuvre[idx]->card->frame->begin_y;
      }
    }
    break;
  case RIGHT:
    if (cursor->x < right_bound) {
      cursor->x += 8;
    } else {
      cursor->x = left_bound;
    }
    if (cursor->y > CURSOR_BEGIN_Y) {
      cursor_move(cursor, UP);
      cursor_move(cursor, DOWN);
    }
    break;
  case UP:
    if (cursor->y > CURSOR_BEGIN_Y) {
      cursor->y = CURSOR_BEGIN_Y;
    }
    break;
  }
}

enum movement cursor_direction(int key) {
  switch (key) {
  case 'h':
  case KEY_LEFT:
    return(LEFT);
  case 'j':
  case KEY_DOWN:
    return(DOWN);
  case 'k':
  case KEY_UP:
    return(UP);
  case 'l':
  case KEY_RIGHT:
    return(RIGHT);
  default:
    endwin();
    game_end();
    assert(false && "invalid cursor direction");
  }
}

struct stack **cursor_stack(struct cursor *cursor) {
  int rx = cursor->x - game.x_offset;
  if (cursor->y == CURSOR_BEGIN_Y) {
    if (rx == CURSOR_STOCK_X) return(&(deck->stock));
    if (rx == CURSOR_WASTE_PILE_X) return(&(deck->waste_pile));
    if (rx == CURSOR_FOUNDATION_0_X) return(&(deck->foundation[0]));
    if (rx == CURSOR_FOUNDATION_1_X) return(&(deck->foundation[1]));
    if (rx == CURSOR_FOUNDATION_2_X) return(&(deck->foundation[2]));
    if (rx == CURSOR_FOUNDATION_3_X) return(&(deck->foundation[3]));
    if (rx == CURSOR_INVALID_SPOT_X) return(NULL);
    endwin();
    game_end();
    assert(false && "invalid stack");
  } else {
    if (rx == CURSOR_MANEUVRE_0_X) return(&(deck->maneuvre[0]));
    if (rx == CURSOR_MANEUVRE_1_X) return(&(deck->maneuvre[1]));
    if (rx == CURSOR_MANEUVRE_2_X) return(&(deck->maneuvre[2]));
    if (rx == CURSOR_MANEUVRE_3_X) return(&(deck->maneuvre[3]));
    if (rx == CURSOR_MANEUVRE_4_X) return(&(deck->maneuvre[4]));
    if (rx == CURSOR_MANEUVRE_5_X) return(&(deck->maneuvre[5]));
    if (rx == CURSOR_MANEUVRE_6_X) return(&(deck->maneuvre[6]));
    endwin();
    game_end();
    assert(false && "invalid stack");
  }
}

bool cursor_on_stock(struct cursor *cursor) {
  return(cursor_stack(cursor) && *cursor_stack(cursor) == deck->stock);
}

bool cursor_on_invalid_spot(struct cursor *cursor) {
  return(!cursor_stack(cursor));
}
