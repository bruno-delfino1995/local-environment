local padLeft(final, char, str) =
	local length = std.length(str);
	local missing = std.max(0, final - length);
	local pad = std.repeat(char, missing);
	"%s%s" % [pad, str];

{
	inOrder(arr):
		local pad = std.length(std.toString(std.length(arr)));

		local withKeys = std.mapWithIndex(
			function(i, el) ["%s-%s" % [padLeft(pad, "0", std.toString(i)), el.name], el.value],
			arr
		);

		std.foldl(
			function(acc, el) acc + {[el[0]]: el[1]},
			withKeys,
			{}
		)
}
