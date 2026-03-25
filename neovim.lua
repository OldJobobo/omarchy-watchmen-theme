return {
  {
    dir = vim.fn.expand("~/.config/omarchy/current/theme"),
    name = "watchmen",
    priority = 1000,
    lazy = false,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "watchmen",
    },
  },
}
