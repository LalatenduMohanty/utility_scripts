#!/usr/bin/perl
=head

This program is made available to anyone wishing
to use, modify, copy, or redistribute it subject to the terms
and conditions of the GNU General Public License version 2.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA.

About:

This script removes all extended attributes for directories.

=cut

if ($ARGV < 1) {
    print("\n$0 <directory path> [directory path] ..\n");
}
foreach my $file (@ARGV) {
    my $output = `getfattr -d -m . $file`;
    my @lines = split('\n', $output);
    foreach $line ( @lines ) {
            if ($line =~ /(.*)=.*==/){
                my $attr = $1;
                system("setfattr -x $attr $file");
        }
    }
}
