
EMPTY = 0
P1 = 1
P2 = 2
BOARD_WIDTH = 7
BOARD_HEIGHT = 6
SPACE_RADIUS = 20 -- pixels
SPACE_SPACING = 5

turn = P1
board = {}
selected_column = 1


function love.load()
  reset_board()
end

function love.keypressed(key, scancode, isrepeat)
  if key == "return" and not isrepeat then
    reset_board()
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  local hovered_column = math.floor((x - SPACE_SPACING / 2) / (SPACE_RADIUS*2 + SPACE_SPACING)) + 1
  if hovered_column < 1 then
    hovered_column = 1
  elseif hovered_column > BOARD_WIDTH then
    hovered_column = BOARD_WIDTH
  end
  selected_column = hovered_column
end

function love.mousepressed(x, y, button, istouch)
  -- Make sure there's space
  if board[selected_column][1] ~= EMPTY then
    return
  end

  for row = BOARD_HEIGHT,1,-1 do
    if board[selected_column][row] == EMPTY then
      board[selected_column][row] = turn
      break
    end
  end

  if turn == P1 then
    turn = P2
  else
    turn = P1
  end
end

function reset_board()
  board = {}
  for x = 1,BOARD_WIDTH do
    board[x] = {}
    for y = 1,BOARD_HEIGHT do
      board[x][y] = EMPTY
    end
  end
  turn = P1
end

function love.draw()
  draw_board()
end

function draw_board()
  if turn == P1 then
    love.graphics.setColor(255, 0, 0)
  else
    love.graphics.setColor(255, 255, 0)
  end
  love.graphics.circle(
      "fill",
      (selected_column-1) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
      SPACE_RADIUS + SPACE_SPACING,
      SPACE_RADIUS)

  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle("smooth")
  for x = 1,BOARD_WIDTH do
    for y = 1,BOARD_HEIGHT do
      if board[x][y] == P1 then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle(
            "fill",
            (x-1) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
            (y-0) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
            SPACE_RADIUS)
      end

      if board[x][y] == P2 then
        love.graphics.setColor(255, 255, 0)
        love.graphics.circle(
            "fill",
            (x-1) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
            (y-0) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
            SPACE_RADIUS)
      end

      -- Outline
      love.graphics.setColor(128, 128, 128)
      love.graphics.circle(
          "line",
          (x-1) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
          (y-0) * (SPACE_RADIUS * 2 + SPACE_SPACING) + SPACE_RADIUS + SPACE_SPACING,
          SPACE_RADIUS)
    end
  end
end
