#!/usr/bin/env raku
use v6.d;

our %env;

sub BUILD-ENV {
    # 1. Use the script's own directory to find .env
    my $env-file = $*PROGRAM-NAME.IO.parent.add('.env');

    if $env-file.e {
        %env = $env-file.lines
            .grep({ .contains('=') && !.starts-with('#') })
            .map({
                my ($key, $val) = .split('=', 2);
                # Remove quotes if you used them in .env and expand ~
                $val = $val.subst(/^'~'/, $*HOME);
                $key.trim => $val.trim
            })
            .hash;
    } else {
        note "⚠️ .env file not found at {$env-file.absolute}";
    }
}

sub MAIN(Str $choice?) {
    BUILD-ENV(); # Load the variables

    my @sessions = <vue flutter notes dotfiles main>;

    # 1. Selection Logic
    my $selected = $choice // do {
        # my $proc = run 'fuzzel', '--dmenu', '--index', '--prompt=Tmux session: ', :in, :out; # fuzzel
        # my $proc = run 'dmenu', '-p', 'Select tmux session:', '-i', :in, :out; # dmenu
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

    # 2. Check and Create
    my $check = run 'tmux', 'has-session', '-t', $selected, :out, :err;

    if $check.exitcode != 0 {
        say "🚀 Creating new session: $selected";
        create-session($selected);
    }

    # 3. Attach
    shell "tmux attach-session -t $selected";
    exit;
}

sub create-session(Str $name) {
    # 1. Get the path from %env based on the session name
    my $path = do given $name {
        when 'flutter'  { %env<FLUTTER_PATH> }
        when 'vue'      { %env<VUE_PATH>     }
        when 'notes'    { %env<NOTES_PATH>   }
        when 'dotfiles' { %env<DOTFILES_PATH>}
        default         { "$*HOME"           }
    } // "$*HOME";

    # 2. Start the session directly in that directory (-c flag)
    # This is much more reliable than sending a 'cd' command
    run 'tmux', 'new-session', '-d', '-s', $name, '-c', $path;

    # 3. Handle window-specific setups
    given $name {
        when 'vue' {
            run 'tmux', 'rename-window', '-t', "{$name}:0", 'editor';
            run 'tmux', 'send-keys', '-t', "{$name}:0", "hx", 'C-m';
            # Terminal
            # run 'tmux', 'new-window', '-t', $name, '-n', 'terminal', '-c', $path;
        }
        when 'flutter' {
            run 'tmux', 'send-keys', '-t', $name, "y", 'C-m';
        }
        when 'dotfiles' {
            run 'tmux', 'rename-window', '-t', "{$name}:0", 'files';
            run 'tmux', 'send-keys', '-t', "{$name}:0", "y", 'C-m';

            run 'tmux', 'new-window', '-t', $name, '-n', 'editor', '-c', $path;
            run 'tmux', 'send-keys', '-t', "{$name}:editor", "hx .", 'C-m';
            run 'tmux', 'select-window', '-t', "{$name}:editor";
        }
        when 'notes' {
            run 'tmux', 'send-keys', '-t', $name, "y", 'C-m';
        }
    }
}
