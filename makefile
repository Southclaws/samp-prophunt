dependencies:
	-git clone https://github.com/maddinat0r/sscanf gamemodes/vendor/sscanf
	-git clone https://github.com/Zeex/amx_assembly gamemodes/vendor/amx_assembly
	-git clone https://github.com/Misiur/YSI-Includes gamemodes/vendor/YSI-Includes
	-git clone https://github.com/samp-incognito/samp-streamer-plugin gamemodes/vendor/samp-streamer-plugin
	-git clone https://github.com/Southclaws/formatex gamemodes/vendor/formatex
	-git clone https://github.com/oscar-broman/strlib gamemodes/vendor/strlib

build:
	pawncc \
		-ivendor/YSI-Includes \
		-ivendor/sscanf \
		-ivendor/formatex \
		-ivendor/strlib \
		-Dgamemodes \
		-\;+ \
		-\(+ \
		-\\+ \
		-d3 \
		prophunt.pwn
