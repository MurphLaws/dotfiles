//! Dungeons & Diagrams puzzle generator.
//!
//! Generates random D&D puzzles on demand. Each puzzle satisfies:
//!
//! 1. Row/column clues count the total number of walls (shaded cells).
//! 2. Every unshaded cell is either a hallway or part of a 3×3 treasure room.
//! 3. Treasure rooms are 3×3 with a single entrance and one treasure inside.
//! 4. Hallways are one square wide (no 2×2 unshaded blocks outside rooms).
//! 5. Every dead end contains a monster, and every monster is in a dead end.
//! 6. All unshaded cells form a single connected component.
//! 7. Diagonal adjacency does not count.

use super::{get_index, Cell, Clues, Grid, PuzzleMode};
use crate::undo_redo_buffer::UndoRedoBuffer;
use terminal::util::{Point, Size};

const MAX_ATTEMPTS: usize = 500;

/// Fallback: returns a solid-wall puzzle with no rooms and no monsters. Only
/// used if random generation fails to produce a valid layout within the
/// attempt budget.
fn trivial_fallback(size: Size) -> (Vec<Cell>, Vec<Cell>) {
    let total = size.product() as usize;
    let solution = vec![Cell::Filled; total];
    let mut player = vec![Cell::Empty; total];
    // No hints to pre-place; player must shade every cell.
    for cell in player.iter_mut() {
        *cell = Cell::Empty;
    }
    (solution, player)
}

impl Grid {
    pub fn dnd(size: Size) -> Self {
        let (solution_cells, starting_cells) = generate(size).unwrap_or_else(|| trivial_fallback(size));

        let horizontal_clues_solutions: Vec<Clues> = (0..size.height)
            .map(|y| {
                let walls = (0..size.width)
                    .filter(|x| {
                        solution_cells[get_index(size.width, Point { x: *x, y })] == Cell::Filled
                    })
                    .count() as u16;
                vec![walls]
            })
            .collect();

        let vertical_clues_solutions: Vec<Clues> = (0..size.width)
            .map(|x| {
                let walls = (0..size.height)
                    .filter(|y| {
                        solution_cells[get_index(size.width, Point { x, y: *y })] == Cell::Filled
                    })
                    .count() as u16;
                vec![walls]
            })
            .collect();

        // Clue layout sizing: max width is 2 (max two-digit wall count), max
        // height is 1 (single number per column).
        let max_clues_size = Size {
            width: 2,
            height: 1,
        };

        Self {
            size,
            cells: starting_cells,
            horizontal_clues_solutions,
            vertical_clues_solutions,
            max_clues_size,
            undo_redo_buffer: UndoRedoBuffer::default(),
            measurement_counter: 0,
            mode: PuzzleMode::DungeonsAndDiagrams,
            solution_cells: Some(solution_cells),
        }
    }
}

/// Core random generation. Returns `Some((solution_cells, starting_cells))` if
/// a valid layout was produced within `MAX_ATTEMPTS`.
///
/// `solution_cells` is the full reference dungeon (walls, empties, monsters,
/// treasures). `starting_cells` is what the player sees initially: all walls
/// are swapped back to `Cell::Empty`, hint cells (Monster/Treasure) are kept.
fn generate(size: Size) -> Option<(Vec<Cell>, Vec<Cell>)> {
    if size.width < 5 || size.height < 5 {
        // Too small for treasure rooms; degrade to a hallway-only dungeon.
        return generate_no_rooms(size);
    }

    for _ in 0..MAX_ATTEMPTS {
        if let Some(pair) = try_generate(size) {
            return Some(pair);
        }
    }
    None
}

/// Attempt one full generation. Returns None if the result is invalid and the
/// caller should retry.
fn try_generate(size: Size) -> Option<(Vec<Cell>, Vec<Cell>)> {
    let w = size.width as usize;
    let h = size.height as usize;
    let total = w * h;
    let mut cells = vec![Cell::Filled; total];

    let idx = |x: usize, y: usize| y * w + x;

    // Decide how many treasure rooms to place.
    let room_count = if w.min(h) <= 7 { 1 } else { 2 };

    // Place treasure rooms (3×3) at random non-overlapping positions that
    // leave at least 1 cell of wall on every side (so the room's entrance
    // cannot be on the grid border).
    let mut rooms: Vec<(usize, usize)> = Vec::new();
    for _ in 0..room_count {
        let mut placed = false;
        for _ in 0..200 {
            if w < 5 || h < 5 {
                break;
            }
            let x = 1 + fastrand::usize(0..w - 4);
            let y = 1 + fastrand::usize(0..h - 4);
            // Reject if this room overlaps or touches any existing room.
            let touches = rooms.iter().any(|(rx, ry)| {
                let dx = (x as isize - *rx as isize).abs();
                let dy = (y as isize - *ry as isize).abs();
                dx < 4 && dy < 4
            });
            if touches {
                continue;
            }
            rooms.push((x, y));
            placed = true;
            break;
        }
        if !placed {
            // Couldn't place this room; continue with fewer.
            break;
        }
    }

    // Carve out each room's 3×3 interior.
    for (rx, ry) in &rooms {
        for dy in 0..3 {
            for dx in 0..3 {
                cells[idx(*rx + dx, *ry + dy)] = Cell::Empty;
            }
        }
    }

    // Pick one entrance cell per room (on the room's perimeter, one step
    // outside the 3×3 block into a wall cell). Lock all other perimeter
    // cells as permanent walls so the hallway carver cannot create multiple
    // entrances to the same room.
    let mut room_entrances: Vec<(usize, usize)> = Vec::new();
    let mut locked_walls: Vec<bool> = vec![false; total];
    for (rx, ry) in &rooms {
        let mut candidates: Vec<(usize, usize)> = Vec::new();
        // North / South rows directly adjacent to the 3×3 block.
        if *ry >= 1 {
            for dx in 0..3 {
                candidates.push((rx + dx, ry - 1));
            }
        }
        if ry + 3 < h {
            for dx in 0..3 {
                candidates.push((rx + dx, ry + 3));
            }
        }
        // West / East columns directly adjacent.
        if *rx >= 1 {
            for dy in 0..3 {
                candidates.push((rx - 1, ry + dy));
            }
        }
        if rx + 3 < w {
            for dy in 0..3 {
                candidates.push((rx + 3, ry + dy));
            }
        }
        if candidates.is_empty() {
            return None;
        }
        let (ex, ey) = candidates[fastrand::usize(0..candidates.len())];
        cells[idx(ex, ey)] = Cell::Empty;
        room_entrances.push((ex, ey));
        // Lock the other perimeter cells as permanent walls.
        for (cx, cy) in &candidates {
            if (*cx, *cy) != (ex, ey) {
                locked_walls[idx(*cx, *cy)] = true;
            }
        }
        // Also lock the four corner-adjacent cells (diagonals of the room
        // corners) so hallways can't sneak around corners into the room.
        let corners: &[(isize, isize)] = &[(-1, -1), (3, -1), (-1, 3), (3, 3)];
        for (dx, dy) in corners {
            let cx = *rx as isize + dx;
            let cy = *ry as isize + dy;
            if cx < 0 || cy < 0 || cx >= w as isize || cy >= h as isize {
                continue;
            }
            locked_walls[idx(cx as usize, cy as usize)] = true;
        }
    }

    // Carve hallways. Random walks from each entrance, subject to the
    // constraint that we never create a 2×2 empty block outside treasure rooms.
    let target_empty_ratio = 0.45_f32;
    let target_empty = (total as f32 * target_empty_ratio) as usize;
    let mut empty_count = cells.iter().filter(|c| **c == Cell::Empty).count();
    let mut frontier: Vec<(usize, usize)> = room_entrances.clone();
    // If there are no rooms, seed from a random interior cell.
    if frontier.is_empty() {
        let sx = 1 + fastrand::usize(0..w.saturating_sub(2).max(1));
        let sy = 1 + fastrand::usize(0..h.saturating_sub(2).max(1));
        cells[idx(sx, sy)] = Cell::Empty;
        frontier.push((sx, sy));
        empty_count += 1;
    }

    let in_room = |x: usize, y: usize, rooms: &[(usize, usize)]| -> bool {
        rooms
            .iter()
            .any(|(rx, ry)| x >= *rx && x < rx + 3 && y >= *ry && y < ry + 3)
    };

    let creates_bad_2x2 = |cells: &[Cell], x: usize, y: usize, rooms: &[(usize, usize)]| -> bool {
        // Would carving (x, y) create a 2×2 empty block any of whose corners
        // sit outside a treasure room?
        for (dx, dy) in &[(-1isize, -1isize), (-1, 0), (0, -1), (0, 0)] {
            let x0 = x as isize + dx;
            let y0 = y as isize + dy;
            if x0 < 0 || y0 < 0 || x0 + 1 >= w as isize || y0 + 1 >= h as isize {
                continue;
            }
            let (x0u, y0u) = (x0 as usize, y0 as usize);
            let quad = [
                (x0u, y0u),
                (x0u + 1, y0u),
                (x0u, y0u + 1),
                (x0u + 1, y0u + 1),
            ];
            let all_empty = quad.iter().all(|(qx, qy)| {
                (*qx == x && *qy == y) || cells[idx(*qx, *qy)] == Cell::Empty
            });
            let any_outside_room = quad.iter().any(|(qx, qy)| !in_room(*qx, *qy, rooms));
            if all_empty && any_outside_room {
                return true;
            }
        }
        false
    };

    let mut iterations = 0;
    while empty_count < target_empty && iterations < total * 20 {
        iterations += 1;
        if frontier.is_empty() {
            break;
        }
        let pick = fastrand::usize(0..frontier.len());
        let (cx, cy) = frontier[pick];
        let dirs = {
            let mut d = vec![(0isize, -1isize), (0, 1), (-1, 0), (1, 0)];
            fastrand::shuffle(&mut d);
            d
        };
        let mut advanced = false;
        for (dx, dy) in dirs {
            let nx = cx as isize + dx;
            let ny = cy as isize + dy;
            if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
                continue;
            }
            let (nxu, nyu) = (nx as usize, ny as usize);
            if cells[idx(nxu, nyu)] == Cell::Empty {
                continue;
            }
            if locked_walls[idx(nxu, nyu)] {
                continue;
            }
            if creates_bad_2x2(&cells, nxu, nyu, &rooms) {
                continue;
            }
            cells[idx(nxu, nyu)] = Cell::Empty;
            empty_count += 1;
            frontier.push((nxu, nyu));
            advanced = true;
            break;
        }
        if !advanced {
            frontier.swap_remove(pick);
        }
    }

    // Ensure connectivity: all unshaded cells must be in one component.
    if !is_single_component(&cells, w, h) {
        return None;
    }

    // Every dead end must become a monster (rule 5 & 6 combined: a dead end is
    // an unshaded cell outside a treasure room with exactly one unshaded
    // orthogonal neighbour).
    let unshaded: Vec<(usize, usize)> = (0..h)
        .flat_map(|y| (0..w).map(move |x| (x, y)))
        .filter(|(x, y)| cells[idx(*x, *y)] == Cell::Empty)
        .collect();

    for (x, y) in &unshaded {
        if in_room(*x, *y, &rooms) {
            continue;
        }
        let open_neighbours = count_open_neighbours(&cells, w, h, *x, *y);
        if open_neighbours == 1 {
            cells[idx(*x, *y)] = Cell::Monster;
        }
    }

    // Place treasure: one cell per room (avoid the entrance-adjacent cell if
    // possible for better puzzle shape; just pick a random interior cell).
    for (rx, ry) in &rooms {
        // 9 candidate cells inside the room. We pick any Empty one.
        let mut interior: Vec<(usize, usize)> = Vec::new();
        for dy in 0..3 {
            for dx in 0..3 {
                if cells[idx(rx + dx, ry + dy)] == Cell::Empty {
                    interior.push((rx + dx, ry + dy));
                }
            }
        }
        if interior.is_empty() {
            return None;
        }
        let (tx, ty) = interior[fastrand::usize(0..interior.len())];
        cells[idx(tx, ty)] = Cell::Treasure;
    }

    // Final validation: each room must still have exactly one entrance.
    for (rx, ry) in &rooms {
        let mut entrance_count = 0;
        // Check perimeter cells around the 3×3 block.
        let checks: Vec<(isize, isize)> = {
            let mut v = Vec::new();
            for dx in 0..3isize {
                v.push((dx, -1));
                v.push((dx, 3));
            }
            for dy in 0..3isize {
                v.push((-1, dy));
                v.push((3, dy));
            }
            v
        };
        for (dx, dy) in checks {
            let nx = *rx as isize + dx;
            let ny = *ry as isize + dy;
            if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
                continue;
            }
            match cells[idx(nx as usize, ny as usize)] {
                Cell::Empty | Cell::Monster => entrance_count += 1,
                _ => {}
            }
        }
        if entrance_count != 1 {
            return None;
        }
    }

    // Check there are no 2×2 empty blocks outside rooms.
    for y in 0..h - 1 {
        for x in 0..w - 1 {
            let quad = [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)];
            let all_open = quad.iter().all(|(qx, qy)| {
                matches!(
                    cells[idx(*qx, *qy)],
                    Cell::Empty | Cell::Monster | Cell::Treasure
                )
            });
            let all_in_room = quad.iter().all(|(qx, qy)| in_room(*qx, *qy, &rooms));
            if all_open && !all_in_room {
                return None;
            }
        }
    }

    // Build the player-facing starting grid: walls become Empty (so the
    // player can shade them in), hint cells stay as-is.
    let starting_cells: Vec<Cell> = cells
        .iter()
        .map(|c| match c {
            Cell::Monster => Cell::Monster,
            Cell::Treasure => Cell::Treasure,
            _ => Cell::Empty,
        })
        .collect();

    Some((cells, starting_cells))
}

/// Generator for very small boards: no treasure rooms, just a connected
/// hallway network.
fn generate_no_rooms(size: Size) -> Option<(Vec<Cell>, Vec<Cell>)> {
    let w = size.width as usize;
    let h = size.height as usize;
    let total = w * h;
    let idx = |x: usize, y: usize| y * w + x;

    for _ in 0..MAX_ATTEMPTS {
        let mut cells = vec![Cell::Filled; total];
        let sx = fastrand::usize(0..w);
        let sy = fastrand::usize(0..h);
        cells[idx(sx, sy)] = Cell::Empty;
        let mut frontier = vec![(sx, sy)];
        let target = (total as f32 * 0.45) as usize;
        let mut opened = 1;
        let mut iterations = 0;
        while opened < target && !frontier.is_empty() && iterations < total * 10 {
            iterations += 1;
            let pick = fastrand::usize(0..frontier.len());
            let (cx, cy) = frontier[pick];
            let mut dirs = vec![(0isize, -1isize), (0, 1), (-1, 0), (1, 0)];
            fastrand::shuffle(&mut dirs);
            let mut advanced = false;
            for (dx, dy) in dirs {
                let nx = cx as isize + dx;
                let ny = cy as isize + dy;
                if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
                    continue;
                }
                let (nxu, nyu) = (nx as usize, ny as usize);
                if cells[idx(nxu, nyu)] == Cell::Empty {
                    continue;
                }
                // Reject if creating a 2×2 empty block (no rooms, so always bad).
                let mut bad = false;
                for (ddx, ddy) in &[(-1isize, -1isize), (-1, 0), (0, -1), (0, 0)] {
                    let x0 = nxu as isize + ddx;
                    let y0 = nyu as isize + ddy;
                    if x0 < 0 || y0 < 0 || x0 + 1 >= w as isize || y0 + 1 >= h as isize {
                        continue;
                    }
                    let (x0u, y0u) = (x0 as usize, y0 as usize);
                    let quad = [
                        (x0u, y0u),
                        (x0u + 1, y0u),
                        (x0u, y0u + 1),
                        (x0u + 1, y0u + 1),
                    ];
                    let all_empty = quad
                        .iter()
                        .all(|(qx, qy)| (*qx == nxu && *qy == nyu) || cells[idx(*qx, *qy)] == Cell::Empty);
                    if all_empty {
                        bad = true;
                        break;
                    }
                }
                if bad {
                    continue;
                }
                cells[idx(nxu, nyu)] = Cell::Empty;
                opened += 1;
                frontier.push((nxu, nyu));
                advanced = true;
                break;
            }
            if !advanced {
                frontier.swap_remove(pick);
            }
        }

        if !is_single_component(&cells, w, h) {
            continue;
        }

        // Mark monsters on dead ends.
        let dead_ends: Vec<(usize, usize)> = (0..h)
            .flat_map(|y| (0..w).map(move |x| (x, y)))
            .filter(|(x, y)| cells[idx(*x, *y)] == Cell::Empty)
            .filter(|(x, y)| count_open_neighbours(&cells, w, h, *x, *y) == 1)
            .collect();
        for (x, y) in dead_ends {
            cells[idx(x, y)] = Cell::Monster;
        }

        let starting_cells: Vec<Cell> = cells
            .iter()
            .map(|c| match c {
                Cell::Monster => Cell::Monster,
                Cell::Treasure => Cell::Treasure,
                _ => Cell::Empty,
            })
            .collect();
        return Some((cells, starting_cells));
    }

    None
}

fn count_open_neighbours(cells: &[Cell], w: usize, h: usize, x: usize, y: usize) -> usize {
    let idx = |x: usize, y: usize| y * w + x;
    let mut count = 0;
    for (dx, dy) in &[(0isize, -1isize), (0, 1), (-1, 0), (1, 0)] {
        let nx = x as isize + dx;
        let ny = y as isize + dy;
        if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
            continue;
        }
        match cells[idx(nx as usize, ny as usize)] {
            Cell::Empty | Cell::Monster | Cell::Treasure => count += 1,
            _ => {}
        }
    }
    count
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::grid::Cell;

    fn render(cells: &[Cell], size: Size) -> String {
        let w = size.width as usize;
        let h = size.height as usize;
        let mut out = String::new();
        for y in 0..h {
            for x in 0..w {
                let ch = match cells[y * w + x] {
                    Cell::Filled => '█',
                    Cell::Empty => '·',
                    Cell::Monster => 'M',
                    Cell::Treasure => '$',
                    _ => '?',
                };
                out.push(ch);
            }
            out.push('\n');
        }
        out
    }

    #[test]
    fn generator_produces_valid_dnd_puzzles() {
        for iter in 0..50 {
            let size = Size { width: 8, height: 8 };
            let grid = Grid::dnd(size);
            let solution = grid.solution_cells.as_ref().unwrap();
            let w = size.width as usize;
            let h = size.height as usize;
            let rooms = find_rooms(solution, w, h);

            // Connectivity.
            assert!(
                is_single_component(solution, w, h),
                "iter {}: unshaded cells not connected",
                iter
            );

            // No 2×2 unshaded block outside a treasure room.
            for y in 0..h - 1 {
                for x in 0..w - 1 {
                    let quad = [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)];
                    let all_open = quad.iter().all(|(qx, qy)| {
                        matches!(
                            solution[qy * w + qx],
                            Cell::Empty | Cell::Monster | Cell::Treasure
                        )
                    });
                    let all_in_room = quad.iter().all(|(qx, qy)| {
                        rooms
                            .iter()
                            .any(|(rx, ry)| *qx >= *rx && *qx < rx + 3 && *qy >= *ry && *qy < ry + 3)
                    });
                    if all_open {
                        assert!(
                            all_in_room,
                            "iter {}: 2x2 open block at ({}, {}) outside a room\n{}",
                            iter,
                            x,
                            y,
                            render(solution, size)
                        );
                    }
                }
            }

            // Every 3×3 room must have exactly one entrance.
            for (rx, ry) in &rooms {
                let mut entrances = 0;
                let checks: Vec<(isize, isize)> = {
                    let mut v = Vec::new();
                    for dx in 0..3isize {
                        v.push((dx, -1));
                        v.push((dx, 3));
                    }
                    for dy in 0..3isize {
                        v.push((-1, dy));
                        v.push((3, dy));
                    }
                    v
                };
                for (dx, dy) in checks {
                    let nx = *rx as isize + dx;
                    let ny = *ry as isize + dy;
                    if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
                        continue;
                    }
                    if matches!(
                        solution[ny as usize * w + nx as usize],
                        Cell::Empty | Cell::Monster | Cell::Treasure
                    ) {
                        entrances += 1;
                    }
                }
                assert_eq!(
                    entrances, 1,
                    "iter {}: room at ({}, {}) has {} entrances\n{}",
                    iter,
                    rx,
                    ry,
                    entrances,
                    render(solution, size)
                );
            }

            // Every monster must be in a dead end (outside a room) and every
            // non-room dead end must be a monster.
            for y in 0..h {
                for x in 0..w {
                    let in_room = rooms
                        .iter()
                        .any(|(rx, ry)| x >= *rx && x < rx + 3 && y >= *ry && y < ry + 3);
                    let is_open = matches!(
                        solution[y * w + x],
                        Cell::Empty | Cell::Monster | Cell::Treasure
                    );
                    if !is_open || in_room {
                        continue;
                    }
                    let open_n = count_open_neighbours(solution, w, h, x, y);
                    let is_monster = matches!(solution[y * w + x], Cell::Monster);
                    if open_n == 1 {
                        assert!(
                            is_monster,
                            "iter {}: dead end at ({}, {}) missing monster\n{}",
                            iter,
                            x,
                            y,
                            render(solution, size)
                        );
                    } else if is_monster {
                        panic!(
                            "iter {}: monster at ({}, {}) is not a dead end ({} open neighbours)",
                            iter, x, y, open_n
                        );
                    }
                }
            }
        }
    }

    fn find_rooms(cells: &[Cell], w: usize, h: usize) -> Vec<(usize, usize)> {
        let mut rooms = Vec::new();
        for ry in 0..h.saturating_sub(2) {
            for rx in 0..w.saturating_sub(2) {
                let all_open = (0..3).all(|dy| {
                    (0..3).all(|dx| {
                        matches!(
                            cells[(ry + dy) * w + (rx + dx)],
                            Cell::Empty | Cell::Monster | Cell::Treasure
                        )
                    })
                });
                if all_open {
                    rooms.push((rx, ry));
                }
            }
        }
        rooms
    }

    #[test]
    fn print_sample_puzzle() {
        fastrand::seed(42);
        let size = Size { width: 8, height: 8 };
        let grid = Grid::dnd(size);
        println!("\nSolution:\n{}", render(grid.solution_cells.as_ref().unwrap(), size));
        println!("Starting board (player view):\n{}", render(&grid.cells, size));
        println!(
            "Horizontal clues: {:?}",
            grid.horizontal_clues_solutions
        );
        println!("Vertical clues:   {:?}", grid.vertical_clues_solutions);
    }
}

fn is_single_component(cells: &[Cell], w: usize, h: usize) -> bool {
    let idx = |x: usize, y: usize| y * w + x;
    let total = w * h;
    let mut visited = vec![false; total];
    let start = cells.iter().position(|c| {
        matches!(c, Cell::Empty | Cell::Monster | Cell::Treasure)
    });
    let Some(start) = start else {
        return false;
    };
    let mut stack = vec![(start % w, start / w)];
    visited[start] = true;
    let mut reached = 0;
    while let Some((x, y)) = stack.pop() {
        reached += 1;
        for (dx, dy) in &[(0isize, -1isize), (0, 1), (-1, 0), (1, 0)] {
            let nx = x as isize + dx;
            let ny = y as isize + dy;
            if nx < 0 || ny < 0 || nx >= w as isize || ny >= h as isize {
                continue;
            }
            let (nxu, nyu) = (nx as usize, ny as usize);
            let ni = idx(nxu, nyu);
            if visited[ni] {
                continue;
            }
            match cells[ni] {
                Cell::Empty | Cell::Monster | Cell::Treasure => {
                    visited[ni] = true;
                    stack.push((nxu, nyu));
                }
                _ => {}
            }
        }
    }
    let expected = cells
        .iter()
        .filter(|c| matches!(c, Cell::Empty | Cell::Monster | Cell::Treasure))
        .count();
    reached == expected
}
