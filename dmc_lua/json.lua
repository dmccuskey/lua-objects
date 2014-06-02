local has_json, json

has_json, json = pcall( require, 'dkjson' )
if not has_json then 
	has_json, json = pcall( require, 'cjson' )
end
if not has_json then 
	has_json, json = pcall( require, 'json' )
end
return json 
