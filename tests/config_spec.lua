local config = require("gitlab-snippets.config")

describe("gitlab-snippets.config", function()
	before_each(function()
		-- Reset config before each test
		config.options = {}
	end)

	describe("setup", function()
		it("should load default configuration when no options provided", function()
			config.setup()

			assert.are.same({
				instances = {},
				default_action = "insert",
			}, config.options)
		end)

		it("should merge user configuration with defaults", function()
			local user_opts = {
				instances = {
					gitlab_com = {
						url = "https://gitlab.com",
						token = "test-token",
					},
				},
				default_action = "new_file",
			}

			config.setup(user_opts)

			assert.are.equal("new_file", config.options.default_action)
			assert.are.same(user_opts.instances, config.options.instances)
		end)

		it("should preserve defaults when user provides partial config", function()
			local user_opts = {
				instances = {
					gitlab_com = {
						url = "https://gitlab.com",
						token = "test-token",
					},
				},
			}

			config.setup(user_opts)

			assert.are.equal("insert", config.options.default_action)
			assert.are.same(user_opts.instances, config.options.instances)
		end)
	end)

	describe("get_instance", function()
		it("should return nil for non-existent instance", function()
			config.setup()

			local instance = config.get_instance("non_existent")

			assert.is_nil(instance)
		end)

		it("should return correct instance configuration", function()
			local user_opts = {
				instances = {
					gitlab_com = {
						url = "https://gitlab.com",
						token = "test-token",
					},
					gitlab_self = {
						url = "https://gitlab.example.com",
						token = "another-token",
					},
				},
			}

			config.setup(user_opts)

			local instance = config.get_instance("gitlab_com")

			assert.are.same({
				url = "https://gitlab.com",
				token = "test-token",
			}, instance)
		end)
	end)
end)
