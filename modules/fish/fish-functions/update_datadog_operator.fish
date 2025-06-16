function update_datadog_operator
    if not string match -q "*kraken-deployment/continuous-deployment*" (pwd)
        echo "Error: This function must be run inside the 'kraken-deployment/continuous-deployment' directory."
        return 1
    end

    if test (count $argv) -lt 1
        echo "Usage: update_datadog_operator NEW_LINE_1 [NEW_LINE_2]"
        echo "  NEW_LINE_1: Relative path to insert after the target line (no leading spaces)"
        echo "  NEW_LINE_2: (Optional) Second relative path to insert (no leading spaces)"
        return 1
    end

    set BASE_DIR "environment-applications"
    set TARGET_LINE "        - ../../monitoring/teams.yaml"

    set NEW_LINES "        - $argv[1]"
    if test (count $argv) -ge 2
        set -a NEW_LINES "        - $argv[2]"
    else
        set -a NEW_LINES ""
    end

    for file in (find "$BASE_DIR" -type f -path "*/prod/datadog-operator.yaml")
        if grep -q "$NEW_LINES[1]" "$file"
            continue
        end
        
        awk -v target="$TARGET_LINE" -v newline1="$NEW_LINES[1]" -v newline2="$NEW_LINES[2]" '
        {
            print $0
            if ($0 == target) {
                print newline1
                if (length(newline2) > 0) print newline2
            }
        }' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        
        echo "Updated $file"
    end
end
