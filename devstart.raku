#!/usr/bin/env raku
use v6.d;

constant $DEFAULT_EXT = '.org';
constant $DATE = DateTime.now.Date.Str;
constant $NAME = "morning-log";

# Define the default Logseq template using a multi-line string (heredoc)
sub get-default-template ($filename-arg) {
    # Extract the base name for the topic placeholder
    my $filename = $filename-arg.subst($DEFAULT_EXT, '', :c);

    # Define the template content
    my $template-content = qq:to/END_TEMPLATE/;
    #+TITLE: $DATE - Daily Focus

    * 🎯 TODAY'S MITs (Most Important Tasks)
    ** 🎬 MOTION GRAPHICS
    - Task:
    - Success looks like:
    - Why this matters:
    - Estimated time:

    ** 📱 APP DEVELOPMENT
    - Task:
    - Success looks like:
    - Why this matters:
    - Estimated time:

    ** 🔐 NETWORKING
    - Task:
    - Success looks like:
    - Why this matters:
    - Estimated time:

    * ⚠️ POTENTIAL DISTRACTIONS
    - Editor tinkering temptation: [ ]
    - Over-researching instead of doing: [ ]

    * 🛡️ ANTI-PROCRASTINATION PLEDGE
    - I will start with REAL work before any editor configuration
    - I will ship something ugly rather than perfect nothing

    * 🔥 MOTIVATION REMINDER
    - Why I'm doing this:
    - How this moves me toward financial independence:
    - What I'm avoiding by staying in comfort zone:
    END_TEMPLATE

    return $template-content;
}

my $path = "/run/media/nekomangini/D/emacs-save-files/emacs-org-sync/2-areas/dev-logs/morning-logs/";
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
