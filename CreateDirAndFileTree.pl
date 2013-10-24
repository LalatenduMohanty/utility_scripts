#!/usr/bin/perl

=head

License

#   This program is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.

Initial Creation - Lalatendu Mohanty
06/09/2013 : While doing on a file taking an exclusive lock and explictly checking
             if writes to file handle passing or failing
=cut
use strict;
use warnings;
use Fcntl qw(:flock SEEK_END);

my $target = $ARGV[0];
my $filescount = $ARGV[1];
my $minfilesize = $ARGV[2];
my $maxfilesize = $ARGV[3];
my $max_depth_dir = $ARGV[4];
my $max_breadth_dir = $ARGV[5];
my $onemb = 1024 * 1024;

if ($#ARGV < 5 ) {
    usage();
}

makeDirs($target, $max_breadth_dir, $max_depth_dir);


########################################################################
sub usage {
    print "\n\nUsage: $0 ", '<target_dir> <file_count/directory> <min_filesize_kb> <max_filesize_kb> <max_depth_dir> <max_breadth_dir>', "\n\n";
    print "Specify the same <min_filesize_kb> and <max_filesize_kb> value if you want to create files of equal size\n\n";
    print "Example : perl $0 /mnt/dir1 3 100 150 3 3\n\n";
    exit(1);
}
#########################################################################
sub makeDirs {
    my($base, $num_dirs, $depth) = @_;
    
    unless(-d $base) {
    	print "\nCreating directory at $base";
    	mkdir $base or die "Cannot create directory $base - $!\n";
    }

    createFiles($base,$filescount, $minfilesize, $maxfilesize); 

    #if depth = 0, no more subdirectories need to be created
    if($depth == 0)
    {
        return 0;
    }

    #Recurse through the directories
    my $dir_name = "TestDir0";
    for(my $x = 0; $x < $num_dirs; $x++)
    {
        makeDirs("$base/$dir_name", $num_dirs, $depth - 1);
        $dir_name++;
    }
}

###############################################################################
sub createFiles {
    my ($basePath, $filescount, $minfilesize, $maxfilesize) = @_;
    my $i;
    my $filename;
    my $size = $minfilesize * 1024;

    print "\nCreating files in $basePath......\n";
    for ($i=0; $i<$filescount; $i++) {
        $filename = "a0";
        for (my $i=0; $i<$filescount; $i++) {
            print ".";
            open(FH,">$basePath/$filename") or warn("Cannot open file: $!\n");
            flock(FH, LOCK_EX) or die "Cannot lock - $!\n";
            if ($minfilesize != $maxfilesize) {
                $size = (int(rand($maxfilesize - $minfilesize)) + $minfilesize) * 1024;
            }
            while ($size > $onemb) {
                print FH "x" x $onemb or die "Cannot write to $filename - $!\n";
                $size = $size - $onemb;
            }
            print FH "x" x $size or die "Cannot write to $filename - $!\n";
            flock(FH, LOCK_UN) or die "Cannot unlock - $!\n";
            close(FH) or die "Cannot close $filename - $!\n";
            $filename++;
        }
    }
    print "$i files created\n";
}
###############################################################################
#EOF
