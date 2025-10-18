#!/usr/bin/env raku
use v6.d;

constant $DEFAULT_EXT = '.org';
constant $DATE = DateTime.now.Date.Str;
constant $NAME = "weekly-log";

# Define the default Logseq template using a multi-line string (heredoc)
sub get-default-template ($filename-arg) {
    # Extract the base name for the topic placeholder
    my $filename = $filename-arg.subst($DEFAULT_EXT, '', :c);

    # Define the template content
    my $template-content = qq:to/END_TEMPLATE/;
    #+TITLE: $DATE - Weekly Review

    * 📈 COMFORT ZONE TRENDS
    ** Editor Tinkering vs Real Work
    - Real work hours:
    - Tinkering hours:
    - Ratio:

    ** Goal Progress Velocity
    - Motion graphics: shorts created
    - App development: features shipped
    - Networking: concepts mastered

    * 🔁 PATTERNS NOTICED
    - When I procrastinate:
    - What triggers avoidance:
    - What helps me focus:

    * 🎯 NEXT WEEK'S FOCUS
    - Primary goal:
    - Anti-procrastination strategy:
    - Editor rule:
    END_TEMPLATE

    return $template-content;
}

my $path = "/run/media/nekomangini/D/emacs-save-files/emacs-org-sync/2-areas/dev-logs/weekly-logs/";
chdir($path);

sub create-log {
    my $filename = $DATE ~ "-" ~ $NAME;
    unless $filename.lc.ends-with($DEFAULT_EXT) {
        $filename ~= $DEFAULT_EXT;
    }

    # 2. Check existence
    if $filename.IO.e {
        say "File '$filename' already exists. Aborting.";
        exit
    }

    # 3. Get content and create file
    my $content = get-default-template($filename);

    say "Creating file '$filename' with template content...";
    sleep 1;

    spurt($filename, $content);

    say "Successfully created: '$filename'";
}

create-log();
