%% Copyright (c) 2013 - Benoit Chesneau
%%
%%    Licensed under the Apache License, Version 2.0 (the "License");
%%    you may not use this file except in compliance with the License.
%%    You may obtain a copy of the License at
%%
%%        http://www.apache.org/licenses/LICENSE-2.0
%%
%%    Unless required by applicable law or agreed to in writing, software
%%    distributed under the License is distributed on an "AS IS" BASIS,
%%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%    See the License for the specific language governing permissions and
%%    limitations under the License.

-module(js_json).

-export([encode/1, decode/1]).

-ifndef('WITH_JIFFY').
-define(JSON_ENCODE(D), jsx:encode(D, [{pre_encode, fun jsx_pre_encode/1}])).
-define(JSON_DECODE(D), jsx:decode(D, [{post_decode, fun jsx_post_decode/1}])).

-else.
-define(JSON_ENCODE(D), jiffy:encode(D, [uescape])).
-define(JSON_DECODE(D), jiffy:decode(D)).
-endif.

%% @doc encode an erlang term to JSON. Throw an exception if there is
%% any error.
encode(D) ->
    ?JSON_ENCODE(D).

%% @doc decode a binary to an EJSON term. Throw an exception if there is
%% any error.
decode(D) ->
    try
        ?JSON_DECODE(D)
    catch
        throw:Error ->
            throw({invalid_json, Error});
        error:badarg ->
            throw({invalid_json, badarg})
    end.


%% internal func
jsx_pre_encode({[]}) ->
    [{}];
jsx_pre_encode({PropList}) ->
    PropList;
jsx_pre_encode(true) ->
    true;
jsx_pre_encode(false) ->
    false;
jsx_pre_encode(null) ->
    null;
jsx_pre_encode(Atom) when is_atom(Atom) ->
    erlang:atom_to_binary(Atom, utf8);
jsx_pre_encode(Term) ->
    Term.

jsx_post_decode([{}]) ->
    {[]};
jsx_post_decode([{_Key, _Value} | _Rest] = PropList) ->
    {PropList};
jsx_post_decode(Term) ->
    Term.
