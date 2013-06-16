:- module(uri_qq, [uri/4]).
:- use_module(library(quasi_quotations)).
:- use_module(library(readutil), [read_stream_to_codes/2]).
:- use_module(library(record)).
:- use_module(library(uri), [uri_components/2, uri_data/3]).


% We parse the quasiquotation content into a URI term, replace $-escaped
% variables with their values, then convert the URI term back into an
% atom. The round trip makes sure that all necessary escaping
% and normalization is done properly.
%
% I wanted to use library(uri) directly, but it leaves too many of the
% URI's components hidden inside opaque atoms (authority, path segments,
% query name-value pairs). The uriqq record splits everything down to
% the smallest structural level.

% represents a URI with more structure than library(uri) provides
:- record uriqq( scheme:atom=http
	       , user
	       , password
	       , host
	       , port
	       , path
	       , search
	       , fragment
	       ).

% atom_uri(+Atom, -Uri)
% atom_uri(-Atom, +Uri)
%
% True if Atom represents the structured Uri.
atom_uri(Atom, Uri) :-
	parse_uri(Atom, Components),
	uri_data(scheme, Components, Scheme),

	uri_data(authority, Components, Authority),
	authority_parts(Authority, User, Pass, Host, Port),

	uri_data(path, Components, Path0),
	adjust_path(Path0, Path),

	uri_data(search, Components, Search0),
	adjust_search(Search0, Search),

	uri_data(fragment, Components, Fragment),
	make_uriqq([ scheme(Scheme)
		   , user(User)
		   , password(Pass)
		   , host(Host)
		   , port(Port)
		   , path(Path)
		   , search(Search)
		   , fragment(Fragment)
	           ], Uri).

% parse a URI, accounting for user's preferred base URL
parse_uri(Atom, Components) :-
	uri_components(Atom, Components0),
	uri_data(scheme, Components0, Scheme),
	parse_uri(Scheme, Atom, Components0, Components).
parse_uri(Scheme, Atom, _, Components) :-
	var(Scheme),
	!,
	atom_concat('http://', Atom, Uri),
	uri_components(Uri, Components).
parse_uri(Scheme, _, Components, Components) :-
	nonvar(Scheme).

% relation between the path for uri_components/2 and uriqq
adjust_path('', []) :- !.
adjust_path(Path, List) :-
	atomic_list_concat(List, '/', Path).

% relation between the search for uri_components/2 and uriqq
adjust_search(Search0, Search) :-
	var(Search0),
	!,
	Search = ''.
adjust_search(Search, Search).

% relation between the authority for uri_components/2 and uriqq
authority_parts(Authority, User, Pass, Host, Port) :-
	uri_authority_components(Authority, As),
	uri_authority_data(user, As, User),
	uri_authority_data(password, As, Pass),
	uri_authority_data(host, As, Host),
	uri_authority_data(port, As, Port).


% parse quasiquotation into a result
qq(Stream, Vars, Result-Vars) :-
	read_stream_to_codes(Stream, Codes),
	atom_codes(Atom, Codes),
	atom_uri(Atom, Uri0),
	replace_variables(Vars, Uri0, Uri),
	atom_uri(Result, Uri).

:- quasi_quotation_syntax(uri).
uri(Content,_Args,Vars,Result) :-
	with_quasi_quotation_input(Content, Stream, qq(Stream,Vars,Result)).
