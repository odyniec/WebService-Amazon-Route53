package WebService::Amazon::Route53::API;

use warnings;
use strict;

use Carp;
use HTTP::Tiny;
use XML::Simple;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(_ordered_hash);

sub new {
    my ($class, %args) = @_;

    my $self = {};

    if (!defined $args{id}) {
        carp "Required parameter 'id' is not defined";
    }
    
    if (!defined $args{key}) {
        carp "Required parameter 'key' is not defined";
    }

    $self->{id} = $args{id};
    $self->{key} = $args{key};

    # Initialize an instance of XML::Simple
    $self->{xs} = XML::Simple->new;

    # Initialize the user agent object
    $self->{ua} = HTTP::Tiny->new(
        agent => 'WebService::Amazon::Route53/' .
            $WebService::Amazon::Route53::VERSION . ' (Perl)'
    );

    # Keep track of the last error
    $self->{error} = {};

    $self->{base_url} = 'https://route53.amazonaws.com/';

    return bless $self, $class;
}

sub _get_server_date {
    my ($self) = @_;
    
    my $response = $self->{ua}->get($self->{base_url} . 'date');
    my $date = $response->{headers}->{'date'};
    
    if (!$date) {
        carp "Can't get Amazon server date";
    }
    
    return $date;    
}

# Amazon expects XML elements in specific order, so we'll need to pass the data
# to XML::Simple as ordered hashes
sub _ordered_hash (%) {
    tie my %hash => 'Tie::IxHash';
    %hash = @_;
    \%hash
}

1;
