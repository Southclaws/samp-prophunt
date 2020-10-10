GetOnlinePlayers()
{
    new connected = 0;
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
            connected++;
    }
    return connected;
}

isnull(const s[]) {
    return s[0] == EOS;
}