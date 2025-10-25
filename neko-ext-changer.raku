#!/usr/bin/env raku
use v6.d;

# get the directory path and execute cd
# get the filename extension you want to change
# change all the file with the extension you input
sub MAIN {
    my $path = prompt("Directory path: ");
    my $file-ext-arg = prompt("File extension name: ");
    my $new-ext = prompt("New extension name: ");

    say "Changing to $path";
    chdir($path);

    # Filter files by extension
    my @files = dir().grep(*.extension eq $file-ext-arg);

    say "Found {+@files} files with .$file-ext-arg extension";

    for @files -> $file {
        say "Processing: $file";
        # Remove old extension and add new one
        my $new-name = $file.basename.subst(/\.$file-ext-arg$/, ".$new-ext");
        say "  Would rename to: $new-name";
        # Uncomment to actually rename:
        $file.rename($new-name);
    }
}
