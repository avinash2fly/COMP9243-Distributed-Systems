-module(server).

-export([service/1, db_insert/3, db_delete/2, db_lookup/2, db_stop/1]).

service(AddressList) ->
    receive
        {From, insert, Name, Address} ->
            From ! string:join(["Got insert for name:", Name, "Address:", Address], " "),

            % Need to deal with the case where Name is already in the list
            case lists:keymember(Name, 1, AddressList) of
                true -> % Name is already in the list, remove it
                    From ! "Inserted Successfully",
                    service([
                                lists:keyreplace(Name, 1, AddressList, {Name, Address}) 
                            ]);
                false -> % Name is not in list, just add
                    From ! "Inserted Successfully",
                    service([
                                {Name, Address} | AddressList
                            ])
            end;
        {From, delete, Name} ->
            From ! string:join(["Got delete for name", Name], " "),

            service(lists:keydelete(Name, 1, AddressList));
        {From, lookup, Name} ->

            case lists:keymember(Name, 1, AddressList) of
                true ->
                    {_, FoundAddress} = lists:keyfind(Name, 1, AddressList),
                    From ! string:join(["lookup found Name:", Name, 
                            "Address:", FoundAddress], " ");
                false ->
                    From ! string:join(["lookup not found for Name:", Name], " ")
            end,

            service(AddressList);
        {From, stop} ->
            From ! "Got stop!"
    end.

db_insert(Pid, Name, Address) ->
    Pid ! {self(), insert, Name, Address}.

db_delete(Pid, Name) ->
    Pid ! {self(), delete, Name}.

db_lookup(Pid, Name) ->
    Pid ! {self(), lookup, Name}.

db_stop(Pid) ->
    Pid ! {self(), stop}.

