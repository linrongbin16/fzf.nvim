# A General Schema for Creating FZF Command

## Introduction

A fzf-based search command usually consists of below components:

- **Provider**: a shell command that can generate the lines list for (the left side of) the fzf binary.

  - (Optional) **Provider Decorator**: a lua function that modify the generated lines. For example `FzfxFiles` will prepend filetype icons for each line generated from the plain provider `fd`/`find`.

- **Previewer**: a shell command that generate the content to preview the current line (on the left side) for (the right side of) the fzf binary.

  - (Optional) **Previewer Label**: a label (string value on the top) for the preview window, which gives extra hint and summary info.

- **Action**: a key that user press to quit fzf binary, and invoke its registered callback lua functions on selected lines, e.g. the `ENTER` keys in most of commands.
- (Optional) **Interaction**: an interactive key that user press and do something without quit the fzf binary, e.g. the `CTRL-U`/`CTRL-R` keys in `FzfxLiveGrep` to switch on restricted/unrestricted `rg` searching results.
- (Optional) **Fzf Option**: other fzf options.
- (Optional) **Other Option**: other special options.

Put all above components together, it's named **Pipeline**.

> In producer/consumer design pattern, **Provider** is the data producer, **Previewer** and **Action**/**Interaction** are the data consumers.

With this pattern, all the details of constructing fzf command and interacting across different child processes with nvim editor are hidden, only a friendly config layer is provide to user and allow creating any commands on their own needs.

Let's defines this pattern more specifically.

> Please also see: https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/schema.lua

## Context

A **context** is some data that passing to pipeline.

After launching the fzf binary command, there's no way to get the current buffer's `bufnr` and current window's `winnr` by nvim API, since the current buffer/window is actually the terminal that running the fzf binary, not the buffer/file you're editing.

So we need to create a context before actually launching fzf binary in terminal.

```lua
--- @class fzfx.PipelineContext
--- @field bufnr integer
--- @field winnr integer
--- @field tabnr integer
--- ...
--
--- @alias fzfx.PipelineContextMaker fun():fzfx.PipelineContext
```

## Provider

A **provider** is a shell command that run and generate the lines list for (the left side of) the fzf binary.

We have below types of providers:

- Plain provider: a simple shell command (as a string or a string list), execute and generate the lines for fzf.
- Command provider: a lua function to run and returns the shell command (as a string or a string list), then execute and generate the lines for fzf.
- List provider: a lua function to run and directly returns the lines for fzf.

```lua
--- @alias fzfx.PlainProvider string|string[]
--- @alias fzfx.CommandProvider fun(query:string?,context:fzfx.PipelineContext?):string?|string[]?
--- @alias fzfx.ListProvider fun(query:string?,context:fzfx.PipelineContext?):string[]?
--- @alias fzfx.Provider fzfx.PlainProvider|fzfx.CommandProvider|fzfx.ListProvider
---
--- @alias fzfx.ProviderType "plain"|"command"|"list"|"plain_list"|"command_list"
--
-- Note: the 1st parameter 'query' is the user input query in fzf prompt.
```

### Provider Decorator

We cannot actually run a lua function **_inside the nvim editor_** as provider decorator for now, this is the limitation of current architecture.

Because both providers and decorators are running in a child process launched by the fzf binary, which is outside of the nvim editor process (the editor you're using), and all nvim plugins are been disabled, so it's not able to found the lua function.

> Making RPC request for every line generated from provider, it will bring much complicated architectural design cross the child process launched by fzf binary and the parent process, e.g. the nvim editor itself.

So, to invoke a lua function, you need to first expose it to the environment runtime path (e.g. `$PATH`) so lua module system could find it.

Thus when specify the decorator in provider configs, we are actually specifying the lua modules, which contains the `decorate` lua function. The child process will load the lua module then run the provider decorator function for each generated line.

```lua
--- @alias fzfx._FunctionProviderDecorator fun(line:string?):string?
--- @alias fzfx.ProviderDecorator {module:string,rtp:string?,builtin:boolean?}
--
-- Note: the 1st parameter `line` (in `fzfx._FunctionProviderDecorator`) is the raw generated line from providers.
```

**Note-1**

For `fzfx.ProviderDecorator`, please always keep in mind:

1. It's running in a child process outside of the nvim editor instance
2. No plugins are loaded, e.g. none are available.

**Note-2**

In `fzfx.ProviderDecorator`:

1. The `module` must be a lua module that contains the `decorate` lua function, and is the `fzfx._FunctionProviderDecorator` type.
2. All the builtin provider decorators are placed in [fzfx.helper.provider_decorators](https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/helper/provider_decorators) package, for example:
   1. [fzfx.helper.provider_decorators.prepend_icon_find](https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/helper/provider_decorators/prepend_icon_find.lua): prepend filetype icon for `fd`/`find` providers.
   2. [fzfx.helper.provider_decorators.prepend_icon_grep](https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/helper/provider_decorators/prepend_icon_grep.lua): prepend filetype icon for `rg`/`grep` providers.
3. the `builtin` is optional, with set `builtin=true`, you can simply write `module='prepend_icon_find'` instead of `module='fzfx.helper.provider_decorators.prepend_icon_find'`. The builtin package prefix will be added internally.
4. the `stdpath('config')` (default nvim config folder) is by default added to runtime path, thus all lua modules can be loaded in your nvim config.
5. the `rtp` is optional, set this option if the lua module is in other places.

> 1. Please see `provider_decorator` option in [files.lua](https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/cfg/files.lua) (the `FzfxFiles`).
> 2. Please see `provider_decorator` option in [live_grep.lua](https://github.com/linrongbin16/fzfx.nvim/blob/main/lua/fzfx/cfg/live_grep.lua) (the `FzfxLiveGrep`).

## Previewer

A **previewer** is a shell command that read current line and generate the preview contents for (the right side of) the fzf binary.

We have below types of previewers:

- Command previewer: a lua function to run and returns a shell command (as a string or a string list), then execute and generate the preview contents for fzf.
- List previewer: a lua function to run and directly returns the preview contents for fzf.
- Buffer previewer (todo): a nvim buffer to show the preview contents. (the biggest benefits are nvim builtin highlightings and allow navigate to the buffer and edit directly)

```lua
--- @alias fzfx.CommandPreviewer fun(line:string?,context:fzfx.PipelineContext?):string?
--- @alias fzfx.ListPreviewer fun(line:string?,context:fzfx.PipelineContext?):string[]?
--- @alias fzfx.Previewer fzfx.CommandPreviewer|fzfx.ListPreviewer
---
--- @alias fzfx.PreviewerType "command"|"command_list"|"list"
--
-- Note: the 1st parameter 'line' is the current selected line in (the left side of) the fzf binary.
```

### Previewer Label

A **previewer label** is the label (title) for the preview window.

We have 2 types of previewers:

- Plain label: a static string value which is the label for the preview window.
- Function label: a lua function to run and returns the string value for the preview window.

```lua
--- @alias fzfx.PlainPreviewerLabel string
--- @alias fzfx.FunctionPreviewerLabel fun(line:string?,context:fzfx.PipelineContext?):string?
--- @alias fzfx.PreviewerLabel fzfx.PlainPreviewerLabel|fzfx.FunctionPreviewerLabel
---
--- @alias fzfx.PreviewerLabelType "plain"|"function"
--- @enum PreviewerLabelTypeEnum
local PreviewerLabelTypeEnum = {
  PLAIN = "plain",
  FUNCTION = "function",
}
--
-- Note: the 1st parameter 'line' is the current selected line.
```

## Command Feed

A **command feed** defines what to feed to the search commands, e.g. the multiple variants.

```lua
--- @alias fzfx.CommandFeed "args"|"visual"|"cword"|"put"|"resume"
```

## Fzf Option

A fzf option is directly passing to the fzf binary, e.g. `--multi`, `--bind=ctrl-e:toggle`.

We have 3 types of fzf options:

- Plain option: plain fzf option as a string, e.g. `--multi`.
- Pair option: plain fzf option as a pair of two strings, e.g. `{ '--bind', 'ctrl-e:toggle' }`.
- Function option: a lua function to run and returns above two types of fzf options.

```lua
--- @alias fzfx.PlainFzfOpt string
--- @alias fzfx.PairFzfOpt string[]
--- @alias fzfx.FunctionFzfOpt fun():fzfx.PlainFzfOpt|fzfx.PairFzfOpt
---
--- @alias fzfx.FzfOpt fzfx.PlainFzfOpt|fzfx.PairFzfOpt|fzfx.FunctionFzfOpt
```

## Interaction/Action

An (inter)action is the lua callback function binding on a key that user press and then been invoked.

We have 2 types of actions:

- Interaction: user press the key and invoke the lua function, do something on current line without quit fzf.
- Action: user press the key to quit fzf, then invoke lua function to do something on the selected lines.

```lua
--- @alias fzfx.ActionKey string
--- @alias fzfx.Interaction fun(line:string?,context:fzfx.PipelineContext):any
--- @alias fzfx.Action fun(line:string[]|nil,context:fzfx.PipelineContext):any
--
-- Note: the 1st parameter in `Interaction` is the current line.
-- Note: the 1st parameter in `Action` is the selected line(s).
```

## Pipeline

A **pipeline** binds a provider with a previewer, with an interaction to switch the data sources, and the help message.

> Note: when you only have 1 provider, the interaction key and help message can be omitted.

The **provider-interaction-previewer** is a (dataflow) pipeline.

## Command Group

The real-world command we're using, say `FzfxLiveGrep`, actually contains multiple variants:

- Basic variant: `args`, feed with command arguments.
- Visual select variant: `visual`, feed with visual selection.
- Cursor word variant: `cword`, feed with cursor word.
- Put (yank text) variant: `put`, feed with yank text.
- Resume previous search variant: `resume`, feed with previous search query content.
- And combine with other multiple data sources, e.g. restricted/unrestricted for live grep.

They're the powerful **command group**:

- It has multiple data sources from different providers, switch by different interactive keys.
- It has multiple previewers, each bind to a specific provider.
- It has multiple action keys to exit fzf and invoke lua callbacks with selected lines.
- (Optionally) It has multiple interactive keys to do something without quit fzf.
- (Optionally) It has some extra fzf options and other options for some specific abilities.
