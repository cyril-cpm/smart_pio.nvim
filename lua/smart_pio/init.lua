local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

M.select_env = function()

	pickers.new({}, {
		prompt_title = "Choose an env :",
		theme = nil,
		finder = finders.new_oneshot_job(
			{ "sh", "/home/cpm/smart_pio.nvim/GetPioEnvList.sh" }
		),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if selection then
					local  choice = selection.value
					
--					vim.fn.jobstart({"/home/cpm/smart_pio.nvim/SelectEnv.sh", choice})

					local on_exit = function(obj)
						if (obj.code ~= 0) then
							print(obj.code) 
						else
							print("SPIO Switching env success")
							M.selectedEnv = choice
						end
					end

					vim.system({"/home/cpm/smart_pio.nvim/SelectEnv.sh" , choice}, { text = true }, on_exit)
				end
			end)
			return true
		end,
	}):find()
end

vim.api.nvim_create_user_command("SPioSelectEnv", function()
	require("smart_pio").select_env()
end, {})

M.get_current_env = function()
	if (M.selectedEnv == nil) then
		M.selectedEnv =  vim.fn.system({"sh", "/home/cpm/smart_pio.nvim/GetCurrentEnv.sh"})
	end
	return M.selectedEnv
end

vim.api.nvim_create_user_command("SPioGetCurrentEnv", function()
	require("smart_pio").get_current_env()
end, {})

function GoToCWD()
	vim.call('VimuxRunCommand', 'cd ' .. vim.uv.cwd())
end

M.build_current_env = function()
	GoToCWD()
	vim.call('VimuxRunCommand', 'platformio run -t app -e ' .. M.get_current_env())
end

vim.api.nvim_create_user_command("SPioBuild", function()
	require('smart_pio').build_current_env()
end, {})

M.upload_current_env = function()
	GoToCWD()
	vim.call('VimuxRunCommand', 'platformio run -t upload -e ' .. M.get_current_env())
end

vim.api.nvim_create_user_command("SPioUpload", function()
	require('smart_pio').upload_current_env()
end, {})


return M


