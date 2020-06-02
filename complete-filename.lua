-- complete file path at primary selection location using vis-complete(1)

vis:map(vis.modes.INSERT, "<C-x><C-f>", function()
	local win = vis.win
	local file = win.file
	local pos = win.selection.pos
	if not pos then return end
	-- TODO do something clever here
	local range = file:text_object_longword(pos > 0 and pos-1 or pos);
	if not range then return end
	if range.finish > pos then range.finish = pos end
	if range.start == range.finish then return end
	local prefix = file:content(range)
	if not prefix then return end
	-- Strip leading delimiters for some languages
	i, j = string.find(prefix, "[[(<'\"{]+")
	if j then
		prefix = prefix:sub(j + 1)
		range.start = range.start + j
	end
	local cmd = string.format("fzf --query '%s'", prefix:gsub("'", "'\\''"))

	local proc = io.popen(cmd)
	local out = proc:read()
	local success, msg, status = proc:close()
	
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return
	end
	pos = range.start
	file:delete(range)
	file:insert(pos, out)
	win.selection.pos = pos + #out
	vis:feedkeys("<vis-redraw>")
end, "Complete file path")

