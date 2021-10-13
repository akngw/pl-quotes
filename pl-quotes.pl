#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use PPI;

main() unless caller;

sub main {
    foreach my $filename (@ARGV) {
        my $document = PPI::Document->new($filename);
        $document->index_locations;
        my $elements = quotes_of($document);
        print_elements( $filename, $elements );
    }
}

sub quotes_of {
    my ($document) = @_;
    my $elements = $document->find( \&wanted );
    use Data::Dumper;
    print Dumper $elements;
    unless ( defined $elements ) {
        warn "findがエラーを返しました @{[$document->{filename}]}";
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
        if ( $element->isa('PPI::Token::HereDoc') ) {
            print_heredoc( $filename, $element );
        } else {
            print_element( $filename, $element );
        }
    }
}

sub print_heredoc {
    my ( $filename, $element ) = @_;
    print
"$filename:@{[$element->{_location}->[0]]}:@{[oneline(join '', @{$element->{_heredoc}})]}\n";
}

sub print_element {
    my ( $filename, $element ) = @_;
    print
"$filename:@{[$element->{_location}->[0]]}:@{[oneline($element->{content})]}\n";
}

sub oneline {
    my ($s) = @_;
    $s =~ s/\s+/ /g;
    $s;
}

1;
