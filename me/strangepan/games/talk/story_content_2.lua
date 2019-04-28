-- general format:
-- {
--   ['unique identifier'] = {
--     text = 'dialog text',
--     options = {
--       [1] = {
--         text = 'option text',
--         destination = <unique identifier>,
--       },
--       ...
--     },
--   },
--   ...
-- }

return {
  ['start'] = {
    text = 'This was a triumph',
    options = {
      {
        text = 'What?',
        dest = 'seriously',
      },
      {
        text = 'I\'m making a note here',
        dest = 'huge_success',
      },
    },
  },
  ['seriously'] = {
    text = 'Sigh. Nevermind.',
    options = {
      {
        text = 'TRY AGAIN',
        dest = 'start',
      },
    },
  },
  ['huge_success'] = {
    text = 'Huge success.\nSo you know the song too.',
    options = {
      {
        text = 'I do',
        dest = 'win',
      },
    },
  },
  ['win'] = {
    text = 'Excellent. You\'ll make a perfect subject.',
    options = {},
  },
}