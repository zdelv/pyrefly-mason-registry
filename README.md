## Notes

Mason is a package manager for Neovim that specializes in _only_ LSPs, linters,
and other related tools. It is different from standard Neovim package managers
like Lazy.nvim. It's common to have both Mason and another package manager. At
it's core, all Mason does is install binaries then adds them to `PATH` when
Neovim runs (including in places like `:term`).

Mason relies on an external registry defined in a Git repo. The registry
compiles down to a zipped json file and is released whenever the configs change
on main. This repo is a Mason registry following the same architecture but only
containing a config for `pyrefly`.

To reference this registry, add it to the list of registries that Mason searches:
```lua
require("lazy").setup({
    spec = {
        {
            "mason-org/mason.nvim",
            opts = {
                registries = {
                    "github:mason-org/mason-registry",
                    "github:zdelv/pyrefly-mason-registry"
                }
            },
        },
    },
})
```

The above assumes that Lazy.nvim is being used for the package manager. In the
opts.registries setting, we use both the base repo and this custom registry.
When running `:Mason`, both registries are pulled and pyrefly is available.

Note: The registry config file in this repo hardcodes the version of pyrefly.
This is required in the Mason registry spec. Mason automatically updates the
package version in the registry using the Renovate GHA tool. See
[here](https://github.com/mason-org/mason-registry/blob/main/CONTRIBUTING.md#the-anatomy-of-a-package)
for more info.

## `nvim-lspconfig` vs `vim.lsp.config`

Neovim's LSP support has been bolted on over the last few versions. Initially,
LSPs did not have a method for configuring how they operated. `nvim-lspconfig`
was created as a first-party plugin that 1. provided a way to configure LSPs
and 2. consolidated pre-made configs for many LSPs into a single location.
Users would generally install `nvim-lspconfig` then rely on it to configure and
start the LSP server when entering the correct files. Mason also used
`nvim-lspconfig` through the `mason-lspconfig.nvim` plugin, which would fetch
the correct config from `nvim-lspconfig` when installing a LSP server.

In Neovim 0.11+, LSP configuration was standardized and an API for configuring
LSPs was added to the nvim core. This API is the `vim.lsp.config` function,
which is described [here](https://neovim.io/doc/user/lsp.html#lsp-config). LSPs
can either be configured inline:

```lua
-- Defined in .config/nvim/init.lua
vim.lsp.config("pyrefly", {
    cmd = { "pyrefly", "lsp" },
    root_markers = { "pyproject.toml" },
    filetypes = { "python" }
})
```

Or in a separate file located in `.config/nvim/lsp/<lsp_name>.lua`:

```lua
-- Defined in .config/nvim/lsp/pyrefly.lua
return {
    cmd = { "pyrefly", "lsp" },
    root_markers = { "pyproject.toml" },
    filetypes = { "python" }
}
```

Regardless of the config method, the final step is to call
`vim.lsp.enable('pyrefly')` to enable autoloading of that LSP based on it's
configuration.

Neovim 0.11+ doesn't necessarily obsolete `nvim-lspconfig` though. That repo is
now a "data-only" repo, containing pre-made configs for supported LSPs. Users
who don't want to fully configure their LSPs from scratch (e.g., from the
binary) can rely on `nvim-lspconfig` still, albeit with a different setup than
before (which is documented
[here](https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#configuration)).

## Files

This repo contains a demo Mason registry for pyrefly (along with a GHA that
releases it) and a proof-of-concept minimum Neovim config setup that uses it. A
docker container is used to prevent local configs from potentially causing
issues with testing. To run the setup, use the following:

```bash
git clone https://github.com/zdelv/pyrefly-mason-registry
cd pyrefly-mason-registry
docker build -t neovim .
docker run -it --rm -v $(pwd)/config:/root/.config neovim bash
```

From within the docker container, start `nvim` then let Lazy.nvim automatically
bootstrap and install Mason. Hit q to quit Lazy.nvim, then run `:Mason`. Mason
should also already have pulled the registries and installed `pyrefly`.

To test the LSP, edit a Python file (`:e test.py`), save it, then add some bunk
Python code. The LSP should show an error `E` in the gutter. You can also run
`:checkhealth vim.lsp` to see the current LSP status. Code hover also should
work by hitting `shift+k` when on Python code.

Note: This does not include any general LSP setup. That's generally done within
the [`LspAttach` autocmd](https://neovim.io/doc/user/lsp.html#lsp-attach).
