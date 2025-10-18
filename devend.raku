#!/usr/bin/env raku
use v6.d;

constant $DEFAULT_EXT = '.org';
constant $DATE = DateTime.now.Date.Str;
constant $NAME = "evening-log";

# Define the default Logseq template using a multi-line string (heredoc)
sub get-default-template ($filename-arg) {
    # Extract the base name for the topic placeholder
    my $filename = $filename-arg.subst($DEFAULT_EXT, '', :c);

    # Define the template content
    my $template-content = qq:to/END_TEMPLATE/;
    #+TITLE: $DATE - Evening Review

    * ✅ WHAT I ACTUALLY DID TODAY
    ** 🎬 Motion Graphics
    - Created:
    - Published:
    - Learned:
    - Time spent:

    ** 📱 App Development
    - Coded:
    - Solved:
    - Designed:
    - Time spent:

    ** 🔐 Networking
    - Studied:
    - Practiced:
    - Understood:
    - Time spent:

    * 🎭 COMFORT ZONE ANALYSIS
    ** Did I do REAL work or just tinker?
    - Real productive work: /10
    - Tool/config tinkering: /10
    - Avoidance activities:

    ** Editor Usage Breakdown
    - Helix (primary): hours
    - Doom Emacs (if used): hours
    - Justification for switching:

    ** Resistance Faced
    - What I avoided:
    - How I avoided it:
    - What story I told myself:

    * 📊 PROGRESS TOWARD GOALS
    ** Goal 1:
    - Movement: [ ] No progress [ ] Small step [ ] Significant [ ] Breakthrough
    - Evidence:

    ** Goal 2:
    - Movement: [ ] No progress [ ] Small step [ ] Significant [ ] Breakthrough
    - Evidence:

    ** Goal 3:
    - Movement: [ ] No progress [ ] Small step [ ] Significant [ ] Breakthrough
    - Evidence:

    * 🚨 HONEST ASSESSMENT
    ** Did I work on what TRULY matters?
    - Answer:
    - Excuses I made:
    - Truth I avoided:

    ** Did I ship or just prepare to ship?
    - Shipped:
    - Prepared:
    - Procrastinated:

    * 💡 TOMORROW'S IMPROVEMENT
    ** One thing I'll do differently:
    -

    ** One boundary I'll set:
    -

    ** One uncomfortable action I'll take:
    -

    * 🌟 SUCCESS MOMENT
    ** One thing I'm proud of today:
    -
    END_TEMPLATE

    return $template-content;
}

my $path = "/run/media/nekomangini/D/emacs-save-files/emacs-org-sync/2-areas/dev-logs/evening-logs/";
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
