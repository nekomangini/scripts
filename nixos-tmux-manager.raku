#!/usr/bin/env raku
use v6.d;

our %env;

sub BUILD-ENV {
    my $env-file = %*ENV<TMUX_PATHS_FILE> // "/run/agenix/my-paths";
    my $file = $env-file.IO;

    unless $file.e {
        note "⚠️ Secret not found at: $env-file";
        return;
    }

    %env = $file.lines
        .grep({ .contains('=') && !.starts-with('#') })
        .map({
            my ($key, $val) = .split('=', 2);
            $val = $val.trim;
            $val ~~ s/^ <['"]> //;
            $val ~~ s/ <['"]> $ //;
            $val = $val.subst(/^ '~'/, $*HOME.Str) if $val.starts-with('~');
            $key.trim => $val;
        })
        .hash;
}

sub MAIN(Str $choice?) {
    BUILD-ENV();

    my @sessions = <vue flutter notes dotfiles main>;

    my $selected = $choice // do {
        my $proc = run 'rofi', '-dmenu', '-i', '-p', 'Tmux session:', :in, :out;
        $proc.in.say: @sessions.join("\n");
        $proc.in.close;
        $proc.out.slurp(:close).trim;
    };

    exit 0 unless $selected;

    unless $selected ∈ @sessions {
        note "❌ '$selected' is not a predefined session.";
        exit 1;
    }

    my $check = run 'tmux', 'has-session', '-t', $selected, :out, :err;
    create-session($selected) if $check.exitcode != 0;

    if %*ENV<TMUX> {
        shell "tmux switch-client -t $selected";
    } else {
        shell "tmux attach-session -t $selected";
    }
}

sub create-session(Str $name) {
    my $path = do given $name {
        when 'flutter'  { %env<FLUTTER_PATH>  }
        when 'vue'      { %env<VUE_PATH>      }
        when 'notes'    { %env<NOTES_PATH>    }
        when 'dotfiles' { %env<DOTFILES_PATH> }
        when 'main'     { %env<PROJECTS_DIR>  }
        default         { $*HOME.Str          }
    } // $*HOME.Str;

    unless $path.IO.e && $path.IO.d {
        note "📂 Path not found: '$path'. Falling back to \$HOME.";
        $path = $*HOME.Str;
    }

    say "🚀 Creating '$name' in: $path";
    run 'tmux', 'new-session', '-d', '-s', $name, '-c', $path;
    sleep 0.1;

    given $name {
        when 'vue' {
            run 'tmux', 'rename-window', '-t', "{$name}:0", 'editor';
            run 'tmux', 'send-keys', '-t', "{$name}:0", 'hx .', 'C-m';
        }
        when 'flutter' {
            run 'tmux', 'send-keys', '-t', $name, 'y', 'C-m';
        }
        when 'dotfiles' {
            run 'tmux', 'rename-window', '-t', "{$name}:0", 'files';
            run 'tmux', 'send-keys', '-t', "{$name}:0", 'y', 'C-m';
            run 'tmux', 'new-window', '-t', $name, '-n', 'editor', '-c', $path;
            run 'tmux', 'send-keys', '-t', "{$name}:editor", 'hx .', 'C-m';
            run 'tmux', 'select-window', '-t', "{$name}:editor";
        }
        when 'notes' {
            run 'tmux', 'send-keys', '-t', $name, 'y', 'C-m';
        }
        default {
            run 'tmux', 'send-keys', '-t', $name, 'y', 'C-m';
        }
    }
}
