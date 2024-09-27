#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

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
        echo -e "${YELLOW}Running pdflatex...${NC}"
        pdflatex "$dir.tex" && pdflatex "$dir.tex"
        cd - || exit

        # Open the PDF if --view parameter is set
        if [[ $view == true && -e "$dir/$dir.pdf" ]]; then
            echo -e "${YELLOW}Opening PDF: $dir/$dir.pdf${NC}"
            xdg-open "$dir/$dir.pdf" &
        fi

        # Convert PDF to PNG
        if command -v convert &> /dev/null; then
            echo -e "${YELLOW}Converting PDF to PNG...${NC}"
            # Use -colorspace to convert to a suitable format
            convert -density 300 "$dir/$dir.pdf" -quality 90 -colorspace RGB "$dir/page-%03d.png" || true

            # Check if PNGs were generated
            if ls "$dir/page-*.png" &> /dev/null; then
                echo -e "${GREEN}PNG files created.${NC}"
                echo -e "${YELLOW}Creating white background PNGs...${NC}"
                
                # Create PNGs with white background
                for img in "$dir/page-*.png"; do
                    convert "$img" -background white -flatten "${img%.png}-white.png"
                done

                echo -e "${YELLOW}Merging PNGs...${NC}"
                # Combine PNGs into a single PNG file
                montage "$dir/page-*-white.png" -tile 1x -geometry +0+0 "$dir/$dir.png"
                
                # Delete temporary PNGs
                echo -e "${GREEN}Cleaning up temporary files...${NC}"
                rm "$dir/page-*.png"
                rm "$dir/page-*-white.png"
            else
                echo -e "${RED}No PNG files created for $dir/$dir.pdf${NC}"
            fi
        else
            echo -e "${RED}ImageMagick is not installed. Please install it to enable PNG conversion.${NC}"
        fi
    else
        echo -e "${RED}No $dir/$dir.tex found${NC}"
    fi
}

# Check if arguments were provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}Please provide at least one directory as an argument.${NC}"
    exit 1
fi

# Iterate over the provided arguments
for arg in "$@"; do
    if [[ -d $arg ]]; then
        compile_latex "$arg"
    else
        echo -e "${RED}$arg is not a directory${NC}"
    fi
done

