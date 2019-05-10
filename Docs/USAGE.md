# User guide

### Quickstart

    Usage:
     -h --help              Show this and exit.
     -r --regex <value>     The regular expression.
     -i --input <value>     An input string to match against. If the input matches,
                             it will be echoed. If an input is not given, input
                             will be read from standard input.
     -n --numbered          The lines will be numbered, starting from 1. Only used
                             on input from standard input.
     -e --eof               Reads all available input once until encountering an
                             EOF. Since input from stdin will be buffered in
                             chunks of different sizes depending on platform, this
                             option is recommended for large input - i.e. larger
                             than 4kB or so.
    
    Example usage for Swift Package Manager:
    · Using the input flag:
        swift run rift -r '(ab|cd)+' -i 'ababcdab'
    
    · Using piped input:
        cat Makefile | swift run rift -n -r '.*[Ll]inux.*'
    
    · Using a here-string:
        swift run rift -n -r '.*a.*' <<< 'This is a here-string.'


### Instructions

For any meaningful comparisons to be made, the executable needs to be compiled. This can be done in the root directory using the command `make rift`, after which the binary can be executed from the same directory.

The `-r` flag and a valid regular expression must always be supplied. An empty expression raises an exception. Invalid expressions also raise an exception during parsing, although "invalid" in this context doesn't apply to non-implemented features. The expression syntax is available in the [syntax sheet](SYNTAX.md).

The command-line interface itself supports a few different input sources. Using the `-i` flag a single string can be matched literally as a whole. If the `-i` flag is omitted, input is read from the standard input. This includes passing the input through a pipe or here-string. In this case, the matching occurs on a line-by-line basis.

Due to some peculiarities with reading data from file handles in Swift, the `-e` flag needs to be given for slightly larger input. Using this flag forces the program to read all input until an `EOF` is encountered. Otherwise the input is read in chunks, which are then used for matching before reading the next chunk. Thus, not supplying the `-e` flag will likely cause unwanted breaks in the middle of some lines. The reasoning for this workaround is solely that the buffer size for available data isn't clearly documented. E.g. the chunks seem to be 4096 bytes on macOS, and 8192 bytes on some Linux machines.

To prefix matched lines with the line number, the `-n` needs to be supplied. The indexing starts from 1, and the output is formatted similar to that of `grep`.

Three different examples for reading input are supplied in the [quickstart](#Quickstart) section above. With a compiled binary, the commands work identically, although obviously `swift run rift` needs to be replaced with the location of the executable.


### Release

The sample files and compiled executables for macOS and Linux can be found in the most recent release from [here](../../../releases).

The comparisons can be run by extracting `Samples.zip` into the [Samples](/Samples) directory, and copying (or compiling) the binary into the root directory of the repository. More files can also be added to the Samples directory, as long as the following criteria are met:

- The file needs to have `txt` as extension.
- The first line of the file must be a valid regular expression, which will be used for matching the rest of the file.

The file can the be compared against using the [comparison](/comparison.sh) script, by passing in the filename as the only argument. Alternatively, a full comparison can be run using the command `make comparison`. The comparison results will be appended to the CSV file [here](performance.csv). A `diff` will also be called for the results produced by each of the programs, based on which the script outputs whether the ouputs were identical or not.
