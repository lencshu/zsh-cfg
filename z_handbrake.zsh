alias hb='/Applications/HandBrakeCLI'

alias hball='find . -type f \( -iname "*.ts" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.wmv" -o -iname "*.mov" \) -exec sh -c '\''file="{}"; dir=$(dirname "$file"); filename=$(basename "$file" | sed "s/\.[^.]*$//"); output="${dir}/${filename}_comp.mp4"; /Applications/HandBrakeCLI -i "$file" -o "$output" --all-subtitles --subtitle-burn 1 && rm "$file" && mv "$output" "${dir}/${filename}.mp4"'\'' \;'

alias hballburn='find . -type f \( -iname "*.ts" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.wmv" -o -iname "*.mov" \) -exec sh -c '\''file="{}"; dir=$(dirname "$file"); filename=$(basename "$file" | sed "s/\.[^.]*$//"); output="${dir}/${filename}_comp.mp4"; /Applications/HandBrakeCLI -i "$file" -o "$output" --all-subtitles --subtitle-burn 1 && rm "$file" && mv "$output" "${dir}/${filename}.mp4"'\'' \;'
