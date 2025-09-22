require("lze").load({
	{
		"nvim-nio",
		dep_of = { "nvim-dap-ui" },
		-- dep_of = { "nvim-dap" },
	},
	{
		"nvim-dap",
		-- dep_of = { "nvim-dap-ui", "nvim-nio", "lazydev.nvim", "nvim-dap-virtual-text" },
		dep_of = { "nvim-dap-ui" },
		lazy = true,
		after = function(_)
			local function exists(path)
				local f = io.open(path, "rb")
				if f then
					f:close()
					return true
				end
				return false
			end

			local dap = require("dap")

			-- c, c++, rust
			dap.adapters.codelldb = {
				type = "executable",
				command = "lldb-dap", -- or if not in $PATH: "/absolute/path/to/codelldb"
			}

			local function ask_rebuild_and_build(exe, build_cmd)
				if vim.fn.filereadable(exe) == 1 then
					local choice = vim.fn.input(exe .. " exists. Rebuild? (y/N): ")
					if not (choice == "y" or choice == "Y") then
						return true
					end
				end
				local ok = os.execute(build_cmd) == 0
				if not ok then
					vim.notify("Build failed: " .. build_cmd, vim.log.levels.ERROR)
				end
				return ok
			end

			dap.configurations.c = {
				{
					name = "Build(if needed) & Launch (C)",
					type = "codelldb",
					request = "launch",
					program = function()
						local cwd = vim.fn.getcwd()
						local exe = cwd .. "/a.out"
						local src = cwd .. "/main.c" -- 必要なら変更
						local cmd = string.format("clang -g -O0 -fno-omit-frame-pointer -o %s %s", exe, src)
						if ask_rebuild_and_build(exe, cmd) then
							return exe
						end
						return nil
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dap.configurations.cpp = {
				{
					name = "Build(if needed) & Launch (C++)",
					type = "codelldb",
					request = "launch",
					program = function()
						local cwd = vim.fn.getcwd()
						local exe = cwd .. "/a.out"
						local src = cwd .. "/main.cpp" -- 必要なら変更
						local cmd = string.format("clang++ -g -O0 -fno-omit-frame-pointer -o %s %s", exe, src)
						if ask_rebuild_and_build(exe, cmd) then
							return exe
						end
						return nil
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dap.configurations.rust = {
				{
					name = "Build(if needed) & Launch (Rust - Cargo)",
					type = "codelldb",
					request = "launch",
					program = function()
						local cwd = vim.fn.getcwd()
						-- default: cargo build の出力バイナリ名を自分のクレート名に合わせてください
						local crate = vim.fn.trim(
							vim.fn.system("basename $(git rev-parse --show-toplevel 2>/dev/null || echo .)")
						)
						local exe = cwd .. "/target/debug/" .. crate
						local cmd = "cargo build"
						if ask_rebuild_and_build(exe, cmd) then
							return exe
						end
						return nil
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			-- python
			dap.adapters.python = function(cb, config)
				if config.request == "attach" then
					---@diagnostic disable-next-line: undefined-field
					local port = (config.connect or config).port
					---@diagnostic disable-next-line: undefined-field
					local host = (config.connect or config).host or "127.0.0.1"
					cb({
						type = "server",
						port = assert(port, "`connect.port` is required for a python `attach` configuration"),
						host = host,
						options = {
							source_filetype = "python",
						},
					})
				else
					cb({
						type = "executable",
						command = "debugpy",
						-- args = { "-m", "debugpy.adapter" },
						options = {
							source_filetype = "python",
						},
					})
				end
			end

			dap.configurations.python = {
				{
					-- The first three options are required by nvim-dap
					type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
					request = "launch",
					name = "Launch file",

					-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

					program = "${file}", -- This configuration will launch the current file if used.
					pythonPath = function()
						-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
						-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
						-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
						local cwd = vim.fn.getcwd()
						if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
							return cwd .. "/venv/bin/python"
						elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
							return cwd .. "/.venv/bin/python"
						else
							return "python3"
						end
					end,
				},
			}
		end,
		keys = {
			{
				"<leader>dt",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>du",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>dq",
				function()
					require("dap").terminate()
					require("dapui").close()
					require("nvim-dap-virtual-text").toggle()
				end,
				desc = "Terminate",
			},
			{
				"<leader>db",
				function()
					require("dap").list_breakpoints()
				end,
				desc = "List Breakpoints",
			},
			{
				"<leader>de",
				function()
					require("dap").set_exception_breakpoints({ "all" })
				end,
				desc = "Set Exception Breakpoints",
			},
		},
	},
	{
		"nvim-dap-ui",
		-- dep_of = { "nvim-dap" },
		lazy = true,
		after = function(_)
			require("dapui").setup({})

			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
		},
	},
	{
		"lazydev.nvim",
		dep_of = { "nvim-dap-ui" },
		-- dep_of = { "nvim-dap" },
		lazy = true,
		after = function(_)
			require("lazydev").setup({
				library = { "nvim-dap-ui" },
			})
		end,
	},
	{
		"nvim-dap-virtual-text",
		dep_of = { "nvim-dap-ui" },
		lazy = true,
		after = function(_)
			require("nvim-dap-virtual-text").setup({})
		end,
	},
})
