:- use_module(library(uri_qq)).

% define helper predicates here

:- use_module(library(tap)).

'fully static URI' :-
    U = {|uri||http://example.com/path?query=yes|},
    U = 'http://example.com/path?query=yes'.

/*
'implicit URI scheme' :-
    U = {|uri||example.com/path|},
    U = 'http://example.com/path'.
*/

/*
'relative URIs' :-
    uri_qq(base, 'https://example.org'),
    U = {|uri||/path/to/resource|},
    U = 'https://example.org/path/to/resource'.
*/

'interpolate path (no query)' :-
    Path = 'somewhere',
    U = {|uri||http://example.net/$Path|},
    U = 'http://example.net/somewhere'.

'interpolate path (with query)' :-
    Path = path_to_resource,
    U = {|uri||http://example.org/$Path?a=b|},
    U = 'http://example.org/path_to_resource?a=b'.

'interpolate entire query' :-
    Query = [a=one, b=two],
    U = {|uri||http://example.org/q?$Query|},
    U = 'http://example.org/q?a=one&b=two'.

'interpolate query parameters' :-
    A = one,
    B = two,
    U = {|uri||https://example.org/q?a=$A&b=$B|},
    U = 'https://example.org/q?a=1&b=2'.

:- listing.
