BEGIN {

}

{
	if (match($0, /^\s*<h2\s+id="([^"]+)">(.*)<\/h2>\s*$/, a)) {
		print "<h2 id=\"" a[1] "\"><a href=\"#" a[1] "\"># </a>" a[2] "</h2>"
	} else {
		print $0
	}
}
