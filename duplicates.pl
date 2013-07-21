use warnings;
use strict;
 
use Digest::MD5;

sub md5($);
sub get_files_with_digest($$);

# duplicates.pl
print "This is duplicates.\n";
# Get the folder
my $folder = $ARGV[0];
print $folder."\n";
# loop over the files
opendir(FOLDER,$folder) or die "Folder $folder not found.\n";
print "Folder \'$folder\' opened.\n";
my $count = 0;
my $digest_hash = {};

while (my $filename = readdir(FOLDER)) {   
    next if ($filename eq "." or $filename eq "..");

    my $filepath = $folder.'/'.$filename;
    next if (!-f$filepath);    
    $count++;
    # get the files digest
    my $digest = md5($filepath);
    #print "File # $count: $digest $filename\n";
    
    # get all filepaths with that digest
    my @files_with_digest = get_files_with_digest($digest_hash, $digest);
    my $dups = @files_with_digest;
    print "$dups ";
    if ($dups > 0) {
        print "\nfound duplicate at $count with digest $digest\n";
    }
    # Add the current file name
    push (@files_with_digest, $filepath);
}
closedir(FOLDER);
# loop through the file hashes
#   if there is more than one entry in the hash
#       print the file names
#   delete the filenames
#   delete the hash entry
# exit

sub md5($) {
    my $file = shift;
    my $digest = "";
    eval {
        open(FILE, $file) or die "Can't find file $file\n";
        my $md5 = new Digest::MD5();
        $md5->addfile(*FILE);
        $digest= $md5->hexdigest();
        close(FILE);
    };
    if ($@) {
        print "$@: $file\n";
        return "";
    }
    return $digest;
}

sub get_files_with_digest($$) {
    my $digest_hash = shift;
    my $digest = shift;
    
    if (!exists $digest_hash->{$digest}) {
        my @new_array = ();
        $digest_hash->{$digest} = \@new_array;
    }
    my $files = $digest_hash->{$digest};
    my @array = @$files;
    return @array;
}
