#!/usr/bin/perl -w

# Author:
# Jay Steiner
# 21/10/2021

# Notes:
# This is the interface for working with the family tree

use lib '.';
use RoyalFamily::Member;

use strict;
use warnings;
use utf8;

use Getopt::Long;
use Pod::Usage;
use Log::Log4perl;
use Data::Dumper;

# Set up Logging
Log::Log4perl->init('conf\log.conf');
my $log = Log::Log4perl->get_logger("RF_Member");

my $supported_commands = {
    ADD_CHILD => 3,
    ADD_MEMBER_VIA_MARRIAGE => 3,
    GET_RELATIONSHIP => 2
};

my $file_path;
my $help;
GetOptions (
    "file_path=s" => \$file_path,
    "help|?" => \$help
);

pod2usage(1) if ( $help || !$file_path );

=head1 SYNOPSIS

perl run_me.pl --file_path=text_input.txt

 Options:
   --file_path       A Relative or Absolute file path, including the filehandle
                     Accepts .txt format only

   --help            Shows this guide again
=cut

main($file_path);

sub main {
    $log->info("BEGINNING RUN");

    # Accept Filename as params
    my $filename = shift;
    $log->info("Filename has been accepted");
    
    # Read in file or die
    open (my $fh, '<:encoding(UTF-8)', $filename) or $log->logdie("Could not open file '$filename' $!");
    $log->info("File has been opened sucessfully");
    
    my @rows;
    $log->info("Reading in Rows");
    # Assume line breaks as delimiter
    while (my $row = <$fh>) {
        chomp $row;
        $log->info("COMMAND ADDED: $row");
        # Push in commands to an array
        push @rows, $row;
    }

    # Loop Through Commands
    foreach my $command ( @rows ) {
        my $line_index = 1;

        # Split into parts
        my @args;
        ( $command, @args ) = split_command($command, $line_index);

        # Check command is supported
        if ( !$supported_commands->{$command} ) {
            $log->logwarn("Command Not Supported on Line: $line_index");
            next;
        }

        # %supported_commands acts as both an indicator of supported commands
        # and as a references to the no. of params expected
        if ( scalar @args != $supported_commands->{$command} ) {
            $log->logwarn("$command Command on Line: $line_index Accepts only $supported_commands->{$command} parameters - Please consider fixing before next run");
            next;
        }

        # ADD_CHILD
        if ( $command eq 'ADD_CHILD' ) {

            # Assume all is well now~!
            my ($member, $child_name, $child_gender) = @args;
            $log->info("Actioning Command: $command, -- With Parent Of: $member, Child Name: $child_name, Child Gender: $child_gender" );
            
            # Perform Action
            $log->info("Instantiating Mother RoyalFamily::Member Object");
            my $rf_member = RoyalFamily::Member->new( Name => $member );
            if ( ref($rf_member) ne 'RoyalFamily::Member' ) {
                print "PERSON_NOT_FOUND\n";
                next;
            }
            $log->debug("RoyalFamily::Member Mother object created: \n", Dumper $rf_member);
            
            $log->info("Adding new child RoyalFamily::Member object via Mother");
            my $child = $rf_member->add_child( Name => $child_name, Gender => $child_gender );
            $log->debug("Child Object Returned: \n", Dumper $child);
            
            # Check an object has been returned
            if ( ref($child) ne 'RoyalFamily::Member' ) {
                print "CHILD_ADDITION_FAILED\n";
                next;
            }
            
            # All Done!
            $log->info("CHILD ADDED SUCESSFULLY\n");
            print "CHILD_ADDED\n",

        # GET_RELATIONSHIP
        } elsif ( $command eq 'GET_RELATIONSHIP' ) {
            # Assume all is well now~!
            my ($member, $relationship) = @args;
            $log->info("Actioning Command: $command, -- With Member Of: $member, looking for relationship type: $relationship");
            
            # Create Member object
            $log->info('Instantiating RoyalFamily::Member Object');
            my $rf_member = RoyalFamily::Member->new( Name => $member );
            if ( ref($rf_member) ne 'RoyalFamily::Member' ) {
                print "PERSON_NOT_FOUND\n";
                next;
            }
            $log->debug("RoyalFamily::Member Mother object created: \n", Dumper $rf_member);
            
            # Perform action
            $log->info("Finding RoyalFamily::Member relations");
            my @relations = @{ $rf_member->get_relationship($relationship) };
            $log->debug("Relations object array returned: \n", Dumper @relations);


            my $result_string;
            # Check atleast one object has been returned
            if ( ref($relations[0]) ne 'RoyalFamily::Member' ) {
                print "NONE\n";
                next;
            }

            $log->info("Creating Relations String");
            $result_string = relations_string(@relations);
            $log->debug("Relations string returned: $result_string");


            # All Done!
            $log->info("RELATIONS RETURNED SUCESSFULLY\n");
            print $result_string . "\n";

        } elsif ( $command eq 'ADD_MEMBER_VIA_MARRIAGE' ) {

            # Assume all is well now~!
            my ($member, $spouse_name, $spouse_gender) = @args;
            $log->info("Actioning Command: $command, -- With Member Of: $member, Spouse Name: $spouse_name, Spouse Gender: $spouse_gender" );
            
            # Create Member
            $log->info("Instantiating RoyalFamily::Member Object");
            my $rf_member = RoyalFamily::Member->new( Name => $member );
            if ( ref($rf_member) ne 'RoyalFamily::Member' ) {
                print "PERSON_NOT_FOUND\n";
                next;
            }
            $log->debug("RoyalFamily::Member object created: \n", Dumper $rf_member);
            
            # Perform action
            $log->info("Adding new spouse RoyalFamily::Member object via Current RF Member");
            my $spouse = $rf_member->add_member_via_marriage( Name => $spouse_name, Gender => $spouse_gender );
            $log->debug("Spouse Object Returned: \n", Dumper $spouse);
            
            # Check an object has been returned
            if ( ref($spouse) ne 'RoyalFamily::Member' ) {
                print "MEMBER_ADDITION_VIA_MARRIAGE_FAILED\n";
                next;
            }
            
            # All Done!
            $log->info("MEMBER ADDED VIA MARRIAGE SUCESSFULLY\n");
            print "MEMBER_ADDED_VIA_MARRIAGE\n",
        }
    }

    $log->info("RUN COMPLETE\n");
}

sub split_command {
    my ($command, $line_index) = @_;

    # Assume whitespace as delimiter
    if ($command !~ /\s/) {
        $log->logwarn("No Whitepace present on Line: $line_index please make sure you are separating your commands correctly \nOrder is: <UPPERCASE COMMAND> <VAR 1> <VAR 2>\nSkipping Line");
        return next;
    }
    # Split line
    my @args;
    ( $command, @args ) = split ( " ", $command );

    # NOTE - Warn in Future:
    # "Command on Line: $line_index - is lowercase, please use uppercase in future to avoid issues";
    $command = uc($command);
    return ( $command, @args );
}

sub relations_string {
    my @relations = @_;

    my $result_string = '';
    foreach my $relation ( @relations ) {
        $result_string .= $relation->{Name} . " ";
    }

    chop($result_string);
    return $result_string;
}