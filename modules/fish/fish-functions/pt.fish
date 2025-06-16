function pt
    set dc_flag "--dc=CuckooGBSupportSite"  # Default data center value
    
    # Check args for any --dc flag and respect it if present
    set has_dc_flag 0
    # Check if any argument starts with --dc=
    for arg in $argv
        if string match -q --regex -- "^--dc=" $arg
            set has_dc_flag 1
            break
        end
    end
    
    # If no dc flag was provided in args, add the default one
    if test $has_dc_flag -eq 0
        invoke localdev.pytest $dc_flag $argv -- -vvv -s -l
    else
        invoke localdev.pytest $argv -- -vvv -s -l
    end
end
