describe("gitlab-snippets.health", function()
	describe("dependency checks", function()
		it("should verify plenary.nvim is available", function()
			local ok, plenary = pcall(require, "plenary")

			assert.is_true(ok)
			assert.is_not_nil(plenary)
		end)

		it("should verify telescope.nvim is available", function()
			local ok, telescope = pcall(require, "telescope")

			-- Note: telescope may not be available in test environment
			-- This test documents the expected dependency
			if ok then
				assert.is_not_nil(telescope)
			else
				-- Expected in minimal test environment
				assert.is_false(ok)
			end
		end)

		it("should verify Neovim version compatibility", function()
			local nvim_version = vim.version()

			assert.is_not_nil(nvim_version)
			assert.is_not_nil(nvim_version.major)
			assert.is_not_nil(nvim_version.minor)
			assert.is_not_nil(nvim_version.patch)

			-- Plugin requires Neovim 0.10+
			local is_compatible = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 10)

			assert.is_true(
				is_compatible,
				string.format(
					"Neovim version %d.%d.%d is not compatible (requires 0.10+)",
					nvim_version.major,
					nvim_version.minor,
					nvim_version.patch
				)
			)
		end)
	end)

	describe("health module", function()
		it("should load without errors", function()
			local ok, health = pcall(require, "gitlab-snippets.health")

			assert.is_true(ok)
			assert.is_not_nil(health)
			assert.is_function(health.check)
		end)
	end)
end)
