#!/usr/bin/env raku
use v6.d;

# Define the desired extension
constant $DEFAULT_EXT = '.org';

# Define the default Logseq template using a multi-line string (heredoc)
sub get-default-template($topic-arg, $filename-arg) {
    # Extract the base name for the topic placeholder
    my $topic-name = $topic-arg.subst($DEFAULT_EXT, '', :c);
    my $filename = $filename-arg.subst($DEFAULT_EXT, '', :c);

    # Get the current date in YYYY-MM-DD format for the journal entry
    my $date = DateTime.now.Date.Str;

    # Define the template content
    my $template-content = qq:to/END_TEMPLATE/;
date: $date

* 🎯 Task in Focus
 ** What I’m doing:
    -
 ** Why I’m doing it:
    -

* 🔥 Problem
 ** What’s broken or missing:
    -

* 💡 Solution
 ** My approach:
    -
 ** Code / Commands:

   #+BEGIN_SRC shell
   #+END_SRC

* 📚 Resources:
 -

* 🧠 Key Insight
 - What I learned:
   -

* 💾 Next Steps
 -
END_TEMPLATE

    return $template-content;
}

my $path = "/run/media/nekomangini/D/logseq-files/pages/";
chdir($path);

sub create-log {
    my $raw-filename = prompt("Enter filename: ");
    my $raw-category = prompt("Enter category: ");

    # 1. Determine the final filename
    my $category = $raw-category.wordcase;
    my $topic = $raw-filename.wordcase;
    my $filename = "$category" ~ "___" ~ "$topic";
    unless $filename.lc.ends-with($DEFAULT_EXT) {
        $filename ~= $DEFAULT_EXT;
    }

    # 2. Check existence
    if $filename.IO.e {
        say "File '$filename' already exists. Aborting.";
        exit
    }

    # 3. Get content and create file
    my $content = get-default-template($topic, $filename);

    say "Creating file '$filename' with template content...";
    sleep 1;

    spurt($filename, $content);

    say "Successfully created: '$filename'";
}

create-log();
