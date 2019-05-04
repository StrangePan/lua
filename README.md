# lua
as far as the eye can see

Maybe I'll split this repository up at some point. For now, it's a monolithic repo containing a
bunch of fun lua-based projects I've built.

----------------------------------------------------------------------------------------------------

# Style Guide

## Require

### Assign to local variables

Assign `require` calls to local variables. This allows imports to be scoped to the current file and
lets us rename imports.

```lua
-- GOOD
local my_class = require 'path.to.my_class'

-- BAD
require 'path.to.my_class'
```

### Use dot notation

Use dots as delimiters between package names in a require statement. Dots are platform-agnostic,
unlike forward or back slashes which are handled differently in different contexts.

```lua
-- GOOD
local my_class = require 'path.to.my_class'

-- BAD
local my_class = require 'path/to/my_class'
local my_class = require 'path\\to\\my_class'
```

### Omit file extension

Omit the `.lua` file extension from require paths. They just add clutter. The path variable should
automatically append queries with the `.lua` extension.

```lua
-- GOOD
local my_class = require 'path.to.my_class'

-- BAD
local my_class = require 'path.to.my_class.lua'
```

### Omit parenthesis

Do not put parenthesis around string literals for `require` calls. They're cumbersome to write and
even more cumbersome to read.

```lua
-- GOOD
local my_class = require 'path.to.my_class'

-- BAD
local my_class = require('path.to.my_class')
```
