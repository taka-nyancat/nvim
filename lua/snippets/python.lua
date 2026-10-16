local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node

return {
  s("lic", {
    t({
      "# Copyright (c) 2026 Your Company.",
      "# Proprietary and confidential. Internal use only.",
    }),
  }),
}
