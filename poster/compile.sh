#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

# MD5 hash cache file
HASH_CACHE_FILE="$HOME/.md5_hashes"

# Check for the --view parameter
view=false
for arg in "$@"; do
	if [[ $arg == "--view" ]]; then
		view=true
		break
	fi
done

# Function to compile LaTeX files
compile_latex() {
	local dir="$1"
	echo -e "${GREEN}Compiling LaTeX in directory: $dir${NC}"

	if [[ -e "$dir/$dir.tex" ]]; then
		cd "$dir" || exit

	# Create a string for the hash that includes the main tex file and any input files
	hash_string="$(cat "$dir.tex" | grep -oP '\\input\{.*?\}' | sed 's/\\input{//;s/}//' | xargs cat)"
	hash_string+=$(cat "$dir.tex")
	hash_string_hash=$(echo -n "$hash_string" | md5sum | awk '{print $1}')

	# Check if the hash exists in the cache
	cached_hash=$(grep "^$dir.tex" "$HASH_CACHE_FILE" | cut -d':' -f2)

	if [[ "$hash_string_hash" != "$cached_hash" ]]; then
		echo -e "${YELLOW}Running pdflatex...${NC}"
		pdflatex "$dir.tex" && pdflatex "$dir.tex"

	    # Cache the new hash
	    sed -i "/^$dir\/$dir\.tex/d" "$HASH_CACHE_FILE" || true
	    echo "$dir.tex:$hash_string_hash" >> "$HASH_CACHE_FILE"

	    # Open the PDF if --view parameter is set
	    if [[ $view == true && -e "$dir.pdf" ]]; then
		    echo -e "${YELLOW}Opening PDF: $dir/$dir.pdf${NC}"
		    xdg-open "$dir.pdf" &
	    fi
	else
		echo -e "${YELLOW}No changes detected. Skipping compilation for $dir.tex${NC}"
	fi
	# Convert PDF to PNG
	if command -v convert &> /dev/null; then
		echo -e "${YELLOW}Converting PDF to PNG...${NC}"
		convert -density 300 "$dir.pdf" -quality 90 -colorspace RGB "page-%03d.png" || true

		# Check if PNGs were generated
		if ls page-*.png &> /dev/null; then
			echo -e "${GREEN}PNG files created.${NC}"

			echo -e "${YELLOW}Merging PNGs...${NC}"
			# Combine PNGs into a single PNG file
			convert $(ls page-*.png | tr '\n' ' ') -gravity center -append $dir.png

			echo -e "${YELLOW}Cleaning up temporary files...${NC}"

			if ls page-*.png 2>/dev/null >/dev/null; then
				echo -e "${YELLOW}Deleting page files...${NC}"
				rm page-*.png
			else
				echo -e "${RED}No page-*.png files found...${NC}"
			fi

			if [[ -e $dir.png ]]; then
				echo -e "${YELLOW}Cropping png...${NC}"
				convert $dir.png -fuzz 10% -trim +repage $dir.png
			fi

			if [[ -e $dir.png ]]; then
				convert $dir.png -background white -alpha remove -alpha off $dir.png
			fi
		else
			echo -e "${RED}No PNG files created for $dir.pdf${NC}"
		fi
	else
		echo -e "${RED}ImageMagick is not installed. Please install it to enable PNG conversion.${NC}"
	fi

	cd - || exit
else
	echo -e "${RED}No $dir.tex found${NC}"
	fi
}

# Check if arguments were provided
if [[ $# -eq 0 ]]; then
	echo -e "${RED}Please provide at least one directory as an argument.${NC}"
	exit 1
fi

# Create the hash cache file if it doesn't exist
touch "$HASH_CACHE_FILE"

# Iterate over the provided arguments
for arg in "$@"; do
	if [[ -d $arg ]]; then
		compile_latex "$arg"
	else
		echo -e "${RED}$arg is not a directory${NC}"
	fi
done

