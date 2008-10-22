use strict;
use warnings;
use Test::More tests => 11;
use HTTP::Session;
use HTTP::Session::State::Test;
use HTTP::Session::State::Null;
use HTTP::Session::Store::Memory;
use CGI;

sub gen_session () {
    HTTP::Session->new(
        state => HTTP::Session::State::Test->new(session_id => 'FOOBAR'),
        store => HTTP::Session::Store::Memory->new,
        request => CGI->new(),
    );
}

sub {
    my $session = gen_session();
    $session->set('foo', 'bar');
    ok $session->is_fresh;
}->();

sub {
    my $session = gen_session();
    ok ! $session->is_fresh;
    is $session->get('foo'), 'bar';
    $session->set('hoge' => 'fuga');
}->();

sub {
    my $session = gen_session();
    ok ! $session->is_fresh;
    is $session->get('foo'), 'bar';
    is $session->get('hoge'), 'fuga';
}->();

sub {
    my $session = gen_session();
    $session->expire();
    isa_ok $session, 'HTTP::Session::Expired';
    ok !$session->is_fresh;
}->();

sub {
    my $session = gen_session();
    is $session->get('foo'), undef;
}->();

sub {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::Null->new( ),
        store   => HTTP::Session::Store::Memory->new,
        request => CGI->new(),
    );
    ok $session->is_fresh, 'null session is fresh';
    is_deeply $session->as_hashref, {};
}->();

