{ inputs, ... }:
{
  flake-file.inputs.nvf.url = "gh:notashelf/nvf";

  den.aspects.nvim = {
    homeManager =
      {
        lib,
        ...
      }:
      {
        imports = [ inputs.nvf.homeManagerModules.nvf ];

        programs.nvf = {
          enable = lib.mkDefault true;
          settings.vim = {
            viAlias = lib.mkDefault true;
            vimAlias = lib.mkDefault false;

            globals = {
              mapleader = " ";
              maplocalleader = ",";
              autoformat = true;
              editorconfig = true;
            };

            options = {
              autoindent = true;
              backup = false;
              clipboard = "unnamedplus";
              cmdheight = 1;
              cursorline = true;
              cursorlineopt = "line";
              encoding = "utf-8";
              errorbells = false;
              expandtab = true;
              foldcolumn = "1";
              foldlevel = 99;
              foldlevelstart = 99;
              foldenable = true;
              hidden = true;
              ignorecase = false;
              laststatus = 3;
              mouse = "nvi";
              number = true;
              relativenumber = true;
              ruler = false;
              shiftwidth = 2;
              showmode = false;
              signcolumn = "yes";
              smartcase = false;
              splitbelow = true;
              splitright = true;
              swapfile = false;
              tabstop = 2;
              termguicolors = true;
              timeoutlen = 500;
              updatetime = 300;
              visualbell = false;
              wrap = false;
              writebackup = false;
            };

            diagnostics = {
              enable = true;
              config = {
                underline = true;
                update_in_insert = false;
                virtual_text = {
                  spacing = 4;
                  source = "if_many";
                  prefix = "●";
                };
                severity_sort = true;
                signs.text = lib.generators.mkLuaInline ''
                  {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN] = "󰀪 ",
                    [vim.diagnostic.severity.HINT] = "󰆈 ",
                    [vim.diagnostic.severity.INFO] = "󰋼 ",
                  }
                '';
              };
            };

            lsp = {
              enable = true;
              formatOnSave = true;
              otter-nvim.enable = true;
              trouble.enable = true;
            };

            languages = {
              enableTreesitter = true;
              enableFormat = true;
              enableExtraDiagnostics = true;

              xml.enable = true;
              json.enable = true;
              jq.enable = true;
              toml.enable = true;
              yaml.enable = true;
              html.enable = true;
              markdown = {
                enable = true;
                lsp.servers = [
                  "marksman"
                  "rumdl"
                ];
                format.type = [ "rumdl" ];
                extensions.markview-nvim.enable = true;
              };
              typst.enable = true;
              bash.enable = true;
              nu.enable = true;
              css.enable = true;
              nix = {
                enable = true;
                lsp.servers = [
                  "nil"
                  "nixd"
                ];
                format.type = [ "nixfmt" ];
              };
              lua.enable = true;
              rust.enable = true;
              openscad.enable = true;
              typescript = {
                enable = true;
                lsp.servers = [ "typescript-language-server" ];
                format.enable = false;
                extraDiagnostics.enable = false;
              };
            };

            treesitter = {
              enable = true;
              textobjects.enable = true;
            };

            formatter.conform-nvim = {
              enable = true;
              setupOpts = {
                format_on_save = {
                  timeout_ms = 3000;
                  lsp_format = "fallback";
                };
                formatters_by_ft = {
                  lua = [ "stylua" ];
                  sh = [ "shfmt" ];
                  nix = [ "nixfmt" ];
                  typescript = [ "oxfmt" ];
                  javascript = [ "oxfmt" ];
                };
                formatters = {
                  oxfmt = {
                    command = "oxfmt";
                    args = [
                      "--stdin-filepath"
                      "$FILENAME"
                    ];
                    stdin = true;
                  };
                };
                formatters.injected.options.ignore_errors = true;
              };
            };

            diagnostics.nvim-lint = {
              enable = true;
              lint_after_save = true;
              linters_by_ft = {
                typescript = [ "oxlint" ];
                javascript = [ "oxlint" ];
              };
              linters = {
                oxlint = {
                  cmd = "oxlint";
                  args = [
                    "--format"
                    "github"
                  ];
                  stdin = false;
                  ignore_exitcode = true;
                };
              };
            };

            autocomplete.blink-cmp = {
              enable = true;
              friendly-snippets.enable = true;
              setupOpts = {
                appearance.nerd_font_variant = "mono";
                fuzzy.implementation = "prefer_rust";
                sources.default = [
                  "snippets"
                  "lsp"
                  "buffer"
                  "path"
                ];
                keymap = {
                  preset = "enter";
                  "<C-y>" = [ "select_and_accept" ];
                  "<Tab>" = [ "snippet_forward" ];
                  "<S-Tab>" = [ "snippet_backward" ];
                };
                signature.enabled = true;
                completion = {
                  accept.auto_brackets.enabled = true;
                  menu = {
                    auto_show = true;
                    draw.treesitter = [ "lsp" ];
                  };
                  ghost_text = {
                    enabled = true;
                    show_with_menu = true;
                  };
                  documentation = {
                    auto_show = true;
                    auto_show_delay_ms = 500;
                  };
                };
                cmdline = {
                  enabled = true;
                  keymap.preset = "cmdline";
                  completion = {
                    list.selection.preselect = false;
                    menu.auto_show = lib.generators.mkLuaInline ''
                      function(ctx) return vim.fn.getcmdtype() == ":" end
                    '';
                    ghost_text.enabled = true;
                  };
                };
                snippets.preset = "mini_snippets";
              };
            };

            snippets.luasnip.enable = false;

            mini = {
              ai = {
                enable = true;
                setupOpts.mappings = {
                  around = "z";
                  inside = "x";
                  around_next = "zn";
                  inside_next = "xn";
                  around_last = "zl";
                  inside_last = "xl";
                  goto_left = "";
                  goto_right = "";
                };
              };
              pairs.enable = true;
              icons = {
                enable = true;
                setupOpts = {
                  file = {
                    ".keep" = {
                      glyph = "󰊢";
                      hl = "MiniIconsGrey";
                    };
                    "devcontainer.json" = {
                      glyph = "";
                      hl = "MiniIconsAzure";
                    };
                  };
                  filetype.dotenv = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                };
              };
              snippets = {
                enable = true;
                setupOpts.snippets = lib.generators.mkLuaInline ''
                  { require("mini.snippets").gen_loader.from_lang() }
                '';
              };
            };

            comments.comment-nvim = {
              enable = true;
              mappings = {
                toggleCurrentLine = "acc";
                toggleCurrentBlock = "aic";
                toggleOpLeaderLine = "ac";
                toggleOpLeaderBlock = "ai";
                toggleSelectedLine = "ac";
                toggleSelectedBlock = "ai";
              };
              setupOpts = {
                padding = true;
                sticky = true;
                toggler = {
                  line = "acc";
                  block = "aic";
                };
                opleader = {
                  line = "ac";
                  block = "ai";
                };
                mappings = {
                  basic = true;
                  extra = false;
                };
              };
            };

            notes.todo-comments.enable = true;

            utility = {
              motion.leap = {
                enable = false;
              };
              surround = {
                enable = false;
              };
              undotree.enable = true;
              yanky-nvim = {
                enable = true;
                setupOpts = {
                  highlight.timer = 150;
                  ring.storage = "memory";
                };
              };
              yazi-nvim = {
                enable = true;
                setupOpts = {
                  open_for_directories = true;
                  yazi_floating_window_border = "single";
                };
              };
              grug-far-nvim = {
                enable = true;
                setupOpts.headerMaxWidth = 80;
              };

              direnv.enable = true;
              qmk-nvim = {
                enable = false;
              };
            };

            git = {
              enable = true;
              gitsigns = {
                enable = true;
                setupOpts = {
                  signs = {
                    add.text = "│";
                    change.text = "│";
                    delete.text = "";
                    topdelete.text = "";
                    changedelete.text = "▎";
                    untracked.text = "▎";
                  };
                  signs_staged = {
                    add.text = "│";
                    change.text = "│";
                    delete.text = "";
                    topdelete.text = "";
                    changedelete.text = "│";
                  };
                };
              };
            };

            visuals.fidget-nvim.enable = true;
            ui = {
              nvim-ufo.enable = true;
              ui2.enable = true;
            };
            statusline.lualine.enable = true;
            tabline.nvimBufferline.enable = true;
            binds.whichKey = {
              enable = true;
              setupOpts = {
                preset = "helix";
                delay = 200;
                plugins = {
                  marks = true;
                  registers = true;
                  presets = {
                    operators = false;
                    motions = true;
                    text_objects = false;
                    windows = true;
                    nav = true;
                    z = false;
                    g = true;
                  };
                };
              };
            };

            luaConfigPost = builtins.readFile ./nvim/keymaps.lua;
          };
        };
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.dataHome}/nvim";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.stateHome}/nvim";
            how = "symlink";
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.cacheHome}/nvim" ];
      };
  };
}
