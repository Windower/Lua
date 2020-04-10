# Python 3
import array
import os
import struct
import winreg

from settings import search, zones


def find_dat(dat_id):
    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, 'SOFTWARE\\WOW6432Node\\PlayOnlineUS\\InstallFolder')
    ffxi_path = winreg.QueryValueEx(key, '0001')[0]
    key.Close()
    for i in range(1, 10):
        vtable = None
        if i == 1:
            vtable = open(os.path.join(ffxi_path, 'VTABLE.DAT'), 'rb')
        else:
            vtable = open(os.path.join(ffxi_path, 'ROM{}'.format(i), 'VTABLE{}.DAT'.format(i)), 'rb')
        vtable.seek(dat_id)
        temp = vtable.read(1)[0]
        vtable.close()
        if temp != i:
            continue
        ftable = None
        if i == 1:
            ftable = open(os.path.join(ffxi_path, 'FTABLE.DAT'), 'rb')
        else:
            ftable = open(os.path.join(ffxi_path, 'ROM{}'.format(i), 'FTABLE{}.DAT'.format(i)), 'rb')
        ftable.seek(dat_id * 2)
        path = struct.unpack('H', ftable.read(2))[0]
        ftable.close()
        if i == 1:
            return os.path.join(ffxi_path, 'ROM', '{}'.format(path >> 7), '{}.DAT'.format(path & 0x7f))
        else:
            return os.path.join(ffxi_path, 'ROM{}'.format(i), '{}'.format(path >> 7), '{}.DAT'.format(path & 0x7f))
    return None

def decipher_dialog(dat_file):
    dat = open(dat_file, 'rb')
    dat_size, first_entry = struct.unpack('II', dat.read(8))
    dat_size -= 0x10000000
    first_entry ^= 0x80808080
    dat.seek(4)
    data = bytearray(dat.read())
    dat.close()
    for i in range(len(data)):
        data[i] ^= 0x80
    offsets = array.array('I', data[:first_entry])
    offsets.append(dat_size)
    for i in range(len(offsets)):
        offsets[i] -= first_entry
    return offsets, bytes(data[first_entry:])

def search_dialog(zones, search):
    messages = {}
    for zone_id, dat_id in zones.items():
        offsets, data = decipher_dialog(find_dat(dat_id))
        for i in range(len(offsets) - 1):
            message = data[offsets[i]:offsets[i+1]]
            if message == search:
                messages[zone_id] = str(i)
    return messages

def write_lua(messages):
    o = open('messages.lua', 'w')
    print('messages = { -- These dialogue IDs match "You were unable to enter a combination" for the associated zone IDs', file=o)
    zone_ids = list(messages.keys())
    zone_ids.sort()
    for zone_id in zone_ids:
        line = messages[zone_id]+','
        print("    [{}] = {}".format(zone_id, line), file=o)
    print('}',file=o)
    print('offsets = {greater_less=1, failure=2, success=4, second_even_odd=5, first_even_odd=6, range=7, less=8, greater=9, equal=10, second_multiple=11, first_multiple=12, tool_failure=13}',file=o)
    o.close()

write_lua(search_dialog(zones, search))
