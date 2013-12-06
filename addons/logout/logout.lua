-- logout

--[[void minnows::Logout()
<JoshK6656> {
<JoshK6656>     char buffer[8];
<JoshK6656>     memset(buffer, 0, 8);
<JoshK6656>     buffer[0] = 0xB5;
<JoshK6656>     buffer[1] = 4;
<JoshK6656>     buffer[4] = 255;
<JoshK6656>     buffer[5] = 0;
<JoshK6656>     m_Windower->GetPacketStreamHandler()->AddOutgoingChunk(buffer);
<JoshK6656> }]]

windower.packets.inject_outgoing(0xB5,string.char(0xB5,0x04,0x00,0x00,0xFF,0x00))