return {
	-- LSP
	{
		"vi013t/forge.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			"stevearc/conform.nvim",
		},
		opts = {
			ui = {
				window_config = {
					border = "rounded"
				}
			},
		},
		config = function(_, opts)
			require("forge").setup(opts)
			vim.cmd("hi DiagnosticUnderlineError gui=undercurl term=undercurl cterm=undercurl")
			vim.cmd("hi DiagnosticUnderlineWarn gui=undercurl term=undercurl cterm=undercurl")
			vim.cmd("hi DiagnosticUnderlineHint gui=undercurl term=undercurl cterm=undercurl")
			vim.cmd("hi DiagnosticUnderlineInfo gui=undercurl term=undercurl cterm=undercurl")
		end
	},

	-- Incremental LSP rename
	{
		"smjonas/inc-rename.nvim",
		dependencies = { "stevearc/dressing.nvim" },
		opts = {
			input_buffer_type = "dressing",
		},
		keys = {
			{ "<leader>lr", ":IncRename ", desc = "Incremental Rename" },
		},
	},

	-- Rust support
	{
		"rust-lang/rust.vim",
		dependencies = {
			"simrat39/rust-tools.nvim", -- Rust tooling
			"neovim/nvim-lspconfig", -- LSP Configuration
		},
		config = function()
			local mode = "dev"

			-- Switches between dev and release mode. Release mode has more strict lints that are annoying
			-- to deal with while developing, but are useful for production code.
			local function switch_mode()
				if mode == "dev" then
					mode = "release"
					require("lspconfig").rust_analyzer.setup({
						settings = {
							["rust-analyzer"] = {
								checkOnSave = {
									allFeatures = true,
									-- stylua: ignore start
									overrideCommand = {
										-- Run clippy linting on save
										"cargo",
										"clippy",
										"--workspace",
										"--message-format=json",
										"--all-targets",
										"--all-features",
										"--",

										-- Warnings: Enable Clippy to warn on all of the following groups:
										"-W", "clippy::pedantic", -- Very technical and just pedantic lints
										"-W", "clippy::nursery", -- Lints that have not yet been stabilized/made it into production clippy
										"-W", "clippy::cargo", -- Lints from the cargo command
										"-W", "clippy::correctness", -- Lints to check for code that is likely incorrect
										"-W", "clippy::perf", -- Lints for unperformant ways of doing things
										"-W", "clippy::style", -- Lints for bad code style or consistency
										"-W", "clippy::suspicious", -- Lints for things that you probably didn't mean to do / meant something else

										-- And enable these specific restrictive warnings
										"-W", "clippy::allow_attributes_without_reason", -- Warnings that are ignored for no reason
										"-W", "clippy::create_dir", -- create_dir instead of create_dir_all to create intermediate directories
										"-W", "clippy::deref_by_slicing", -- Slicing when dereferencing achieves the same
										"-W", "clippy::empty_structs_with_brackets", -- Empty structs with needless brackets instead of a semicolon
										"-W", "clippy::exit", -- Using the exit function at all
										"-W", "clippy::float_cmp_const", -- Comparing a float to a constant, which is subject to floating point precision
										"-W", "clippy::fn_to_numeric_cast_any", -- Casting a function pointer to a number
										"-W", "clippy::if_then_some_else_none", -- If-else's that could be written with bool::then
										"-W", "clippy::impl_trait_in_params", -- Using impl trait in parmeter instead of generic
										"-W", "clippy::indexing_slicing", -- Indexing or slicing which may panic instead of .get() which returns an option
										"-W", "clippy::integer_division", -- Dividing two integers without casting them to floats
										"-W", "clippy::let_underscore_must_use", -- Not using a value from a function marked as must_use
										"-W", "clippy::lossy_float_literal", -- Precision loss in floats
										"-W", "clippy::map_err_ignore", -- map_err() calls that discard the original error
										"-W", "clippy::mem_forget", -- Using mem::forget when the parameter implements Drop, meaning Drop isn't called
										"-W", "clippy::missing_assert_message", -- Asserting without an error message
										"-W", "clippy::missing_docs_in_private_items", -- Missing documentation comments
										"-W", "clippy::missing_enforced_import_renames", -- Missing import renames that are enforced
										"-W", "clippy::mixed_read_write_in_expression", -- Reading and writing a variable in the same expression which may cause confusion
										"-W", "clippy::multiple_inherent_impl", -- Multiple non-trait impls for the same struct
										"-W", "clippy::mutex_atomic", -- Using a Mutex when an Atomic will do the job
										"-W", "clippy::panic", -- Using the panic! macro
										"-W", "clippy::panic_in_result_fn", -- Using the panic! macro when a function returns a Result
										"-W", "clippy::print_stderr", -- Printing to stderr (should not be present in production code)
										"-W", "clippy::rc_mutex", -- Using Rc<Mutex>, in which Rc is not thread save but Mutex is
										"-W", "clippy::rest_pat_in_fully_bound_structs", -- Using a rest (..) pattern on a fully matched struct
										"-W", "clippy::same_name_method", -- Two methods with the same name on a struct due to traits
										"-W", "clippy::semicolon_outside_block", -- Semicolons that are placed inside of blocks (such as unsafe) instead of outside
										"-W", "clippy::shadow_reuse", -- Shadowing a variable to reuse it
										"-W", "clippy::shadow_same", -- Shadowing a variable with one with the same name
										"-W", "clippy::shadow_unrelated", -- Shadowing a variable and using it in an unrelated context
										"-W", "clippy::single_char_lifetime_names", -- Lifetime parameter names that are a single character (nondescriptive)
										"-W", "clippy::string_to_string", -- Converting a String to itself with .to_string()
										"-W", "clippy::suspicious_xor_used_as_pow", -- Using a XOR where pow() was probably intended
										"-W", "clippy::tests_outside_test_module", -- Using test functions outside of a module marked #[cfg(test)]
										"-W", "clippy::todo", -- The todo! macro (shouldn't be present in production code)
										"-W", "clippy::unimplemented", -- The unimplemented! macro (shouldn't be present in production code)
										"-W", "clippy::unnecessary_safety_comment", -- Safety comments on inherently safe operations
										"-W", "clippy::unnecessary_safety_doc", -- Safety documentation on inherently safe functions
										"-W", "clippy::unnecessary_self_imports", -- Unnecessarily importing "self" which does nothing
										"-W", "clippy::unneeded_field_pattern", -- Unnecessary fields in pattern matching instead of resting (..)
										"-W", "clippy::unreachable", -- The unreachable! macro (shouldn't be present in production code)
										"-W", "clippy::use_debug", -- Using the dbg! macro (shouldn't be present in production code)
										"-W", "clippy::verbose_file_reads", -- Reading a file with File::read_to or File::read_to_string instead of std::fs::read_to_string()

										-- BUT allow these that I deem stupid
										"-A", "clippy::multiple_crate_versions", -- Multiple versions of a dependency crate
										"-A", "clippy::module_name_repetitions", -- Repeating module name in identifiers
										"-A", "clippy::cast_precision_loss", -- Casting between numeric types where precision may be lost (such as an i32 to an i16)
										"-A", "clippy::cast_lossless",

										-- stylua: ignore end
									},
								},
							},
						},
					})
				else
					mode = "dev"
					require("lspconfig").rust_analyzer.setup({
						settings = {
							["rust-analyzer"] = {
								checkOnSave = {
									allFeatures = true,
									-- stylua: ignore start
									overrideCommand = {
										-- Run clippy linting on save
										"cargo",
										"clippy",
										"--workspace",
										"--message-format=json",
										"--all-targets",
										"--all-features",
										"--",

										-- Warnings: Enable Clippy to warn on all of the following groups:
										"-W", "clippy::pedantic", -- Very technical and just pedantic lints
										"-W", "clippy::nursery", -- Lints that have not yet been stabilized/made it into production clippy
										"-W", "clippy::cargo", -- Lints from the cargo command
										"-W", "clippy::correctness", -- Lints to check for code that is likely incorrect
										"-W", "clippy::perf", -- Lints for unperformant ways of doing things
										"-W", "clippy::style", -- Lints for bad code style or consistency
										"-W", "clippy::suspicious", -- Lints for things that you probably didn't mean to do / meant something else

										-- And enable these specific restrictive warnings
										"-W", "clippy::allow_attributes_without_reason", -- Warnings that are ignored for no reason
										"-W", "clippy::create_dir", -- create_dir instead of create_dir_all to create intermediate directories
										"-W", "clippy::deref_by_slicing", -- Slicing when dereferencing achieves the same
										"-W", "clippy::empty_structs_with_brackets", -- Empty structs with needless brackets instead of a semicolon
										"-W", "clippy::exit", -- Using the exit function at all
										"-W", "clippy::float_cmp_const", -- Comparing a float to a constant, which is subject to floating point precision
										"-W", "clippy::fn_to_numeric_cast_any", -- Casting a function pointer to a number
										"-W", "clippy::if_then_some_else_none", -- If-else's that could be written with bool::then
										"-W", "clippy::impl_trait_in_params", -- Using impl trait in parmeter instead of generic
										"-W", "clippy::indexing_slicing", -- Indexing or slicing which may panic instead of .get() which returns an option
										"-W", "clippy::integer_division", -- Dividing two integers without casting them to floats
										"-W", "clippy::let_underscore_must_use", -- Not using a value from a function marked as must_use
										"-W", "clippy::lossy_float_literal", -- Precision loss in floats
										"-W", "clippy::map_err_ignore", -- map_err() calls that discard the original error
										"-W", "clippy::mem_forget", -- Using mem::forget when the parameter implements Drop, meaning Drop isn't called
										"-W", "clippy::missing_assert_message", -- Asserting without an error message
										"-W", "clippy::missing_enforced_import_renames", -- Missing import renames that are enforced
										"-W", "clippy::mixed_read_write_in_expression", -- Reading and writing a variable in the same expression which may cause confusion
										"-W", "clippy::multiple_inherent_impl", -- Multiple non-trait impls for the same struct
										"-W", "clippy::mutex_atomic", -- Using a Mutex when an Atomic will do the job
										"-W", "clippy::panic", -- Using the panic! macro
										"-W", "clippy::panic_in_result_fn", -- Using the panic! macro when a function returns a Result
										"-W", "clippy::print_stderr", -- Printing to stderr (should not be present in production code)
										"-W", "clippy::rc_mutex", -- Using Rc<Mutex>, in which Rc is not thread safe but Mutex is
										"-W", "clippy::rest_pat_in_fully_bound_structs", -- Using a rest (..) pattern on a fully matched struct
										"-W", "clippy::same_name_method", -- Two methods with the same name on a struct due to traits
										"-W", "clippy::semicolon_outside_block", -- Semicolons that are placed inside of blocks (such as unsafe) instead of outside
										"-W", "clippy::shadow_reuse", -- Shadowing a variable to reuse it
										"-W", "clippy::shadow_same", -- Shadowing a variable with one with the same name
										"-W", "clippy::shadow_unrelated", -- Shadowing a variable and using it in an unrelated context
										"-W", "clippy::string_to_string", -- Converting a String to itself with .to_string()
										"-W", "clippy::suspicious_xor_used_as_pow", -- Using a XOR where pow() was probably intended
										"-W", "clippy::tests_outside_test_module", -- Using test functions outside of a module marked #[cfg(test)]
										"-W", "clippy::todo", -- The todo! macro (shouldn't be present in production code)
										"-W", "clippy::unimplemented", -- The unimplemented! macro (shouldn't be present in production code)
										"-W", "clippy::unnecessary_safety_comment", -- Safety comments on inherently safe operations
										"-W", "clippy::unnecessary_safety_doc", -- Safety documentation on inherently safe functions
										"-W", "clippy::unnecessary_self_imports", -- Unnecessarily importing "self" which does nothing
										"-W", "clippy::unneeded_field_pattern", -- Unnecessary fields in pattern matching instead of resting (..)
										"-W", "clippy::unreachable", -- The unreachable! macro (shouldn't be present in production code)
										"-W", "clippy::use_debug", -- Using the dbg! macro (shouldn't be present in production code)
										"-W", "clippy::verbose_file_reads", -- Reading a file with File::read_to or File::read_to_string instead of std::fs::read_to_string()

										-- BUT allow these that I deem stupid
										"-A", "clippy::multiple_crate_versions", -- Multiple versions of a dependency crate
										"-A", "clippy::module_name_repetitions", -- Repeating module name in identifiers
										"-A", "clippy::cast_precision_loss", -- Casting between numeric types where precision may be lost (such as an i32 to an i16)
										"-A", "clippy::cast_lossless",
										"-A", "clippy::missing_docs_in_private_items", -- Missing documentation comments

										-- stylua: ignore end
									},
								},
							},
						},
					})
				end
				print("Switched to " .. mode .. " mode")
			end

			vim.keymap.set("n", "<leader>lm", switch_mode, { silent = true })
		end,
		ft = "rust",
	},

	-- Live preview for LaTeX
	{
		"xuhdev/vim-latex-live-preview",
		opts = {},
		cmd = { "LLPStartPreview" },
	},

	-- Pest support
	{
		"pest-parser/pest.vim",
		ft = "pest",
	},

}
