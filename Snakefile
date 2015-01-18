# lua-objects

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-objects"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-objects",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"lua_objects.lua"
		],
		"requires": []
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-objects", module_config )

