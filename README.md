# CS152-CompilerProject
CS152 Compiler Design Project

# Usage

Please `cd` into the phase for the project you wish to run.

## Phase 3
Use `./usage.sh <min file>`. For example, to test phase3 with `read_write_test.min`, use the following once you are in `phase3/`:

`./usage.sh read_write_test.min`

To print out grammar rules, go to `mini_l.yy` and search for the phrase `#define debug`. Set to `true` to print out grammar rules _and_ machine code, or `false` to only print out the machine code.
