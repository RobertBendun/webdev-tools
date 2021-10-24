#!/bin/sh

Source="src"
Intermediate="int"
Target="dst"

# swap-for-file <phrase> <file1> <file2>
# replaces <phrase> in file2 with content of file1
swapf() {
	sed -i -f <(cat <<EOS
/$1/ {
	r $2
	d
}
EOS
	) "$3"
}

swap() {
	sed -i -f <(cat <<EOS
/$1/ {
	a $2
	d
}
EOS
	) "$3"
}

mkdir -p "$Target"
mkdir -p "$Intermediate"

find "$Source" -type d | sed "s/^$Source/$Target/" | xargs -I{} mkdir -p "{}"

# Build devlog
lowdown "$Source/devlog.md" -o "$Intermediate/devlog.0.html"
awk -f anchor.awk "$Intermediate/devlog.0.html" > "$Intermediate/devlog.html"

# Build regular files

for src_file in $(find "$Source" -type f -not -name "__*"); do
	dst_file="$Target${src_file//$Source}"
	cp -f "$src_file" "$dst_file"

	# File type specific operations
	case "$dst_file" in
		*.html)
			swapf __GITHUB_LAST_UPDATES__ "$Source/__github_last_updates.html" "$dst_file"
			swapf __HEADER__ "$Source/__header.html" "$dst_file"
			swapf __FOOTER__ "$Source/__footer.html" "$dst_file"
			swapf __DEVLOG__ "$Intermediate/devlog.html" "$dst_file"
			;;
	esac

	# General operations
	swap __DATE__ "$(date +"%Y-%m-%d %H:%M")" "$dst_file"
done
