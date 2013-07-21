use warnings;
use strict;
 
use Digest::MD5;
use Data::Dumper;

sub md5($);

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

print "Loading data...\n";
while (my $filename = readdir(FOLDER)) {   
    next if ($filename eq "." or $filename eq "..");

    my $filepath = $folder.'/'.$filename;
    next if (!-f$filepath);    
    $count++;
    if ($count%100 == 0) { print "$count "; }
    if ($count%1000 == 0) { print "\n"; }
    # get the files digest
    my $digest = md5($filepath);
    #print "File # $count: $digest $filename\n";
    
    my $array = $digest_hash->{$digest};
    if (!$array) {
        my @new_array = ();
        $array = \@new_array;
        $digest_hash->{$digest} = $array;
    }
    
    push (@$array, $filepath);
    
}
closedir(FOLDER);

print "\nData loaded. Finding duplicates...";

#print Dumper($digest_hash);

my $duplicates = 0;

# loop through the file hashes
foreach my $digest (keys(%$digest_hash)) {
    my @files = @{$digest_hash->{$digest}};
    # if there is more than one entry in the hash
    if (@files > 1) {
        $duplicates++;
        print "$digest:\n";
        foreach my $file (@files) {
            print "\t$file\n";
            my $command = "open \"$file\"";
            system($command);
        }
    }
}

print "Found $duplicates duplicates.\n";

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

