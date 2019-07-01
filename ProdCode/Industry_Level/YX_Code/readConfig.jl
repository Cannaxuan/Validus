"""
    Read Config file for input and output path
"""
function readConfig(f)
    for l in readlines(f)
        eval(Meta.parse(l))
    end

    # if removeNonAlphaNumeric(lowercase(DIR_PATH)) != removeNonAlphaNumeric(lowercase(@__DIR__))
    #     println("Configured file diractory is $(removeNonAlphaNumeric(lowercase(DIR_PATH)))")
    #     println("Actual file diractory is $(removeNonAlphaNumeric(lowercase(@__DIR__)))")
    #     error("Unmatched path configuration")
    # end

    if !(ENV["USERNAME"] in AUTHORIZED_USER)
        println("Configured user is $AUTHORIZED_USER")
        println("Actual user is $(ENV["USERNAME"])")
        error("Unmatched user configuration")

    end

    return (INPUT_PATH_PREFIX, OUTPUT_PATH_PREFIX)
end


"""
removeNonAlphaNumeric(s::String)

# Example
```julia-repl
julia > s = "hello, world!";
julia > removeNonAlphaNumeric(s)
"helloworld"
```
"""
function removeNonAlphaNumeric(s::String)
    for c in s
        if !isletter(c) && !isnumeric(c)
            s = replace(s, c=>"")
        end
    end
    return s
end
