#!/usr/bin/env raku
use v6.d;

constant @DIRECTORIES = (
    "/home/nekomangini/neko-dotfiles",
    "/run/media/nekomangini/D/Programming/neko-gitjournal",
    "/run/media/nekomangini/D/Programming/Projects",
    "/run/media/nekomangini/D/Programming/blender-python",
    "/run/media/nekomangini/D/Programming/scripts",
    "/run/media/nekomangini/D/Programming/git-practice",
    "/run/media/nekomangini/D/emacs-save-files/emacs-org-sync",
    "/run/media/nekomangini/D/Programming/programming-exercises",
    "/run/media/nekomangini/D/game-development/save-files",
);

sub MAIN {
    my $fzf-input = @DIRECTORIES.join("\n");

    my $proc = run 'fzf', '--height', '40%', '--reverse',
                   '--prompt=Select a directory: ',
                   :in, :out, :err;

    $proc.in.print($fzf-input);
    $proc.in.close;

    my $selected-dir = $proc.out.slurp(:close).trim;

    if $selected-dir {
        # Output a cd command
        say "cd '$selected-dir'";
    }
}

# Run eval "$(./neko-directory-fzf.raku)" on the terminal
