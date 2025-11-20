#!/usr/bin/env raku
use v6.d;

# rg --vimgrep <word> | fzf --preview 'cat {}' --height 70% | xargs hx
sub MAIN(Str $word) {
    # 1. rg --vimgrep <word> | fzf ...

    # Run rg, capturing its output handle (:out)
    my $proc1 = run 'rg', '--vimgrep', $word, :out;

    # Run fzf, receiving input from rg's output ($proc1.out).
    # Crucially, we capture fzf's output here for final use.
    my $proc2 = run 'fzf', '--preview', 'cat {}',
                        '--height', '70%',
                        :in($proc1.out), :out, :err;

    # Wait for the first two processes to flush their pipes and finish
    $proc1.out.slurp;

    # 2. Capture the selected file/line from fzf
    # .slurp(:close) reads the entire output and closes the pipe.
    my $selected-line = $proc2.out.slurp(:close).trim;

    my $exitcode = $proc2.exitcode;

    if $exitcode != 0 {
        # This usually means the user pressed ESC or Ctrl+C in fzf.
        warn "Fzf selection cancelled or failed (Exit Code: $exitcode):\n{$proc2.err.slurp}";
        exit 1;
    }

    # 3. Launch Editor (hx) using the captured selection
    if $selected-line.chars {
        # 3. FIX: Parse the selected line (e.g., file:line:col:code)
        # We split the string by ':' into at most 4 parts.
        my @parts = $selected-line.split(":", 4);

        # We take only the first three parts (file, line, column) and join them back.
        # This creates the correct 'file:line:column' format required by hx.
        my $hx-args = @parts[0..2].join(":");

        say "Launching hx with clean arguments: $hx-args";

        # Use 'exec' in shell to launch hx and replace the current Raku process
        shell "exec hx $hx-args";

        say "Editor closed.";
    } else {
        say "No selection made. Exiting.";
    }
}
