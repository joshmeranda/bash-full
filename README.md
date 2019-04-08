# bash-ful
A collection of usefual bash scripts.

Before running make sure proper execute permissions are allowed for each script.

## modtouch
Create a file with specified permissions. Can be run in interactive mode, and will not overwrite a file unless told to do so.

(eg) `modtouch 644 foo_0 foo_1 # will create both files without prompts`
     `modtouch --interactive always --overwrite mode foo_0 foo_1 foo_2 # will attempt to create each file and prompt before ovwerite or creation`

## draindir
Copy the content of source directories into dest. If no dest specified drains sources into cwd.

(eg) `draindir dir_0 dir_1 -d dir_3 # drains contents of dir_0 and dir_1 into dir_2`
     `draindir dir_0 dir_1 # drains contents of dir_0 and dir_1 into './'`