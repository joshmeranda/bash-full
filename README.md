# bash-full
A collection of useful bash scripts.

## draindir
Move the contents of a directory into another, deleting the original source
directories.

```
Usage: draindir.sh SOURCE... DEST
```

## gmerged
Merge and delete a git branch. Allows for deleting the remote head branch. The
newly merged changes can then be optionally pushed to the remote repository.

```
Usage: gmerged.sh [OPTIONS] BRANCH
     --help      display this help text.
  -r --remove    delete the remote branch on push.
  -p --push      push to remote after merge.
```

## mktest
Simple script meant to quickly create directories with files for testing other
scripts.

## modtouch
Create a file with specific permissions, given in octal.

```
Usage: modtouch.sh [-o] OCTAL-MODE FILE [FILE ...]
  -o --overwrite    specify that existing files should be overwritten if file
                    of the same name exists
```

## pakdir
Compress files according to those listed in a '.pak' file which specifies files
to include or ignore depending on the presence of the `--include`` flag. This
script can also be used to zip all tracked files in a git repository.

```
Usage: pakdir.sh [options] [TARGET] [ZIP]
     --help              diaplay this help text.
  -p --pak-file=[FILE]   use a specific pak file.
     --include           include specified paths.
     --no-ignore-pak     include the pak file in the resulting archive.
  -g --git               pak a directory according according to a '.gitignore'
                         file.
     --tarball           package as a tarball filtered through gzip instead of
                         a simple compressed archive.
```
