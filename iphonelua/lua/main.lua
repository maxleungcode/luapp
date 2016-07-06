


function main()
	

	local status,err = pcall(function ()
		--for e= 100,1000,100 do 
		-- local ins = UILuaLabel(100,100,200,100)
		-- ins:settxt("test font")
		-- addtoview(ins)
		--end
		--table.insert(event,ins);
		local button = UILuaButton(150,200,100,100)
		addtoview(button)
		button:setevent(function() print("this is button") end)
	end)

end

if err ~= nil then
	print(err)
end

main()