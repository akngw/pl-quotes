#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use PPI;

main() unless caller;

sub main {
    foreach my $filename (@ARGV) {
        my $document = eval { PPI::Document->new( $filename, readonly => 1 ) };
        unless ($document) {
            warn "parsing failed ($filename):" . PPI::Document->errstr;
            next;
        }
        $document->index_locations;
        my $elements = quotes_of($document);
        print_elements( $filename, $elements );
    }
}

sub quotes_of {
    my ($document) = @_;
    my $elements = $document->find( \&wanted );
    unless ( defined $elements ) {
        warn "find failed (@{[$document->{filename}]})";
    }
    unless ($elements) {
        return [];
    }
    return $elements;
}

sub wanted {
    $_[1]->isa('PPI::Token::Quote')
      || $_[1]->isa('PPI::Token::QuoteLike')
      || $_[1]->isa('PPI::Token::HereDoc');
}

sub print_elements {
    my ( $filename, $elements ) = @_;
    foreach my $element (@$elements) {
        print_element( $filename, $element );
    }
}

sub print_element {
    my ( $filename, $element ) = @_;
    print "$filename:@{[line_number_of($element)]}:@{[content_of($element)]}\n";
}

sub line_number_of {
    my ($element) = @_;
    $element->{_location}->[0];
}

sub content_of {
    my ($element) = @_;
    if ( $element->isa('PPI::Token::HereDoc') ) {
        return oneline( join '', @{ $element->{_heredoc} } );
    } else {
        return oneline( $element->{content} );
    }
}

sub oneline {
    my ($s) = @_;
    $s =~ s/\s+/ /g;
    $s;
}

1;
