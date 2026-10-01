# One week with Rust

Give this 2 to 4 focused hours a day. The point is to find out whether you like writing Rust, not to finish every chapter or collect tools.

Use three things all week:

- [The Rust Programming Language](https://doc.rust-lang.org/book/) for explanations
- Rustlings for short exercises
- one small project that becomes useful by day seven

When you get stuck, ask for an explanation of the compiler message before asking for a finished solution. Rust's errors are part of the learning loop.

## Before day one

Check the toolchain:

```fish
rustc --version
cargo --version
rust-analyzer --version
rustlings --version
```

Create a place for the exercises and open it in Zed:

```fish
mkdir -p ~/code/rust-week
cd ~/code/rust-week
rustlings init
cd rustlings
zed .
```

In Zed, use the command palette for `task: spawn`. The managed task list has Cargo run, check, test, Clippy, formatting, and docs commands. Rust files format when saved, and rust-analyzer runs Clippy for diagnostics.

## Day 1: Cargo and the basic language

Read chapters 1 through 3 of the Rust Book. Type the examples rather than copying them. In Rustlings, work through the intro, variables, functions, `if`, and primitive types.

Make a separate `temperature` binary with `cargo new temperature`. It should accept a hard-coded Celsius value, convert it to Fahrenheit, and print both. Add a function for each conversion direction and two unit tests.

You are done when these pass:

```fish
cargo fmt --check
cargo clippy -- -D warnings
cargo test
```

## Day 2: ownership and borrowing

Read chapter 4 slowly. Ownership is the part worth spending time on. Draw where each `String` lives and mark when a function takes ownership versus borrowing with `&str`.

Do the Rustlings move semantics exercises. Then change `temperature` so a conversion function accepts a borrowed string such as `"21.5"`, parses it, and returns a `Result<f64, _>`.

Before fixing a move error, predict which line the compiler will point at. That habit pays off quickly.

## Day 3: structs, enums, and errors

Read chapters 5, 6, and 9. Do the matching `structs`, `enums`, and `error_handling` Rustlings sections.

Start the week's project:

```fish
cd ~/code/rust-week
cargo new dupe-scout
cd dupe-scout
zed .
```

`dupe-scout` will find duplicate files without deleting anything. For now, define:

- a `FileRecord` struct containing a path and byte size
- an enum for the requested output format, initially `Text` or `Json`
- a function that reads metadata for one path and returns `Result<FileRecord, ...>`

Write tests for normal files and missing files. Temporary directories in tests are fine.

## Day 4: collections and iterators

Read chapter 8 and the iterator parts of chapter 13. Work through the Rustlings `vecs`, `hashmaps`, and `iterators` sections.

Make `dupe-scout` walk a directory and group regular files by size in a `HashMap<u64, Vec<PathBuf>>`. Ignore groups containing one file. This cheap first pass avoids hashing files that cannot be duplicates.

Add dependencies only when they save work unrelated to the lesson. `walkdir` is a reasonable choice for directory traversal. Read its docs and keep the dependency list short.

## Day 5: traits and a real CLI

Read chapters 7 and 10. Do the Rustlings modules, generics, and traits exercises.

Add command-line parsing with `clap`. The program should support:

```text
dupe-scout scan <directory>
dupe-scout scan <directory> --json
```

Keep scanning separate from presentation. A small trait or two output functions should let the same scan result render as text or JSON. Use `serde` only for JSON serialization; do not turn every type into a framework abstraction.

Run `Rust: clippy (strict)` from Zed and deal with each warning. If a suggestion is unclear, open the Clippy lint documentation before applying it.

## Day 6: hashes, tests, and debugging

Hash only files from same-size groups, then group matching hashes. `blake3` gives you a straightforward hashing API. Decide what should happen when a file becomes unreadable during the scan, and make that behavior explicit in the output.

Add tests for:

- two files with identical contents
- same-sized files with different contents
- an empty directory
- a nested directory
- one unreadable or disappearing path, if macOS permissions make the test reliable

Put a breakpoint inside the grouping code and run `debugger: start` (`F4`) in Zed. Step through one test and inspect the map. Debugging once on a small program is better than discovering the setup is broken on a large one.

If the core program is solid, use `rayon` to hash candidate files in parallel. Keep a serial implementation until the parallel version passes the same tests. This is the stretch goal, not a requirement.

## Day 7: finish and judge it

Read chapter 11 on tests and chapter 12 for a complete CLI example. Finish the Rustlings sections that cover mistakes you actually made this week; there is no prize for rushing through all of them.

Give `dupe-scout` a useful `--help`, a README with examples, and clear errors. Run the full gate:

```fish
cargo fmt --all --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets
cargo doc --open
cargo build --release
```

Try the release binary on a disposable directory with known duplicates. Do not point unfinished file tooling at valuable data.

Then answer these in a note while the week is fresh:

1. Did ownership become clearer by days five through seven, or did it still feel like constant negotiation?
2. Did compiler and Clippy messages usually help you reach a fix?
3. Did Cargo, rust-analyzer, tests, and docs make the work pleasant?
4. Would you choose Rust for another CLI, a service, or systems work where correctness matters?
5. Did you want to continue improving the project after it already worked?

Continue for another month if most answers are yes, especially the last one. If the language slowed you down without making the result feel safer or more satisfying, stop without guilt. A week spent learning ownership and explicit error handling still transfers to other languages.

## Commands worth remembering

```fish
cargo new NAME             # create a package
cargo run -- ARGS          # build and run with arguments
cargo check                # fast type-check
cargo test                 # run tests
cargo fmt                   # format source
cargo clippy                # run Rust-aware lints
cargo doc --open            # build and open dependency docs
cargo tree                  # inspect dependencies
```

Inside Zed, `F2` renames a symbol, `F12` goes to its definition, `Shift-F12` finds references, and `Cmd-.` opens code actions. Use `task: rerun` to repeat the last Cargo task without reopening the picker.
