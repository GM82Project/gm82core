import io
import os
import shutil
import sys
import zlib

def gm_running():
    return os.system('tasklist /fi "ImageName eq GameMaker.exe" /fo csv 2>NUL | find /I "GameMaker.exe" >NUL') == 0

def read_int(f):
    return int.from_bytes(f.read(4), byteorder='little')

def skip_int(f):
    f.seek(4, 1)

def read_string(f):
    return f.read(read_int(f))

def skip_string(f):
    f.seek(read_int(f), 1)

def read_ext_file(f):
    skip_int(f)
    skip_string(f)
    origname = read_string(f)
    kind = read_int(f)
    skip_string(f)
    skip_string(f)
    for _ in range(read_int(f)):
        skip_function(f)
    for _ in range(read_int(f)):
        skip_constant(f)
    return (origname, kind)

def skip_function(f):
    skip_int(f)
    skip_string(f)
    skip_string(f)
    skip_int(f)
    skip_string(f)
    skip_int(f)
    skip_int(f)
    for _ in range(17):
        skip_int(f)
    skip_int(f)

def skip_constant(f):
    skip_int(f)
    skip_string(f)
    skip_string(f)
    skip_int(f)

def copy_file(f, path):
    with open(path, "rb") as g:
        dat = zlib.compress(g.read())
    f.write(len(dat).to_bytes(4, 'little'))
    f.write(dat)

def generate_swap_table(seed):
	a = 6 + (seed % 250)
	b = seed // 250
	table = (list(range(0, 256)), list(range(0, 256)))
	for i in range(1, 10001):
		j = 1 + ((i * a + b) % 254)
		table[0][j], table[0][j + 1] = table[0][j + 1], table[0][j]
	for i in range(1, 256):
		table[1][table[0][i]] = i
	return table

def build_gex(ged_path, gex_path):
    must_restart_gm = False
    if os.path.dirname(ged_path) != '':
        os.chdir(os.path.dirname(ged_path))
    with open(ged_path, "rb") as f:
        ged = bytearray(f.read())
    ged[4] = 0
    with io.BytesIO(ged) as f:
        skip_int(f)
        with f.getbuffer() as view:
            view[4] = 0
        skip_int(f)
        name = read_string(f).decode('utf-8')
        for _ in range(6):
            skip_string(f)
        help_file = read_string(f).decode()
        f.seek(4, 1)
        for _ in range(read_int(f)):
            skip_string(f)
        files = [read_ext_file(f) for _ in range(read_int(f))]
    seed = 0
    table = generate_swap_table(seed)
    with io.BytesIO() as out:
        out.write(b'\x91\xd5\x12\x00\xbd\x02\x00\x00')
        out.write(seed.to_bytes(4, 'little'))
        out.write(ged)
        if help_file != '':
            copy_file(out, help_file)
        for f in files:
            copy_file(out, f[0])
        with out.getbuffer() as view:
            for i in range(13, len(view)):
                view[i] = table[0][view[i]]
        with open(gex_path, 'wb') as f:
            f.write(out.getvalue())
    extensions_path = os.path.join(os.getenv('LOCALAPPDATA'), 'GameMaker8.2', 'extensions/')
    new_ged_path = os.path.join(extensions_path, name + '.ged')
    if os.path.isfile(new_ged_path):
        with open(new_ged_path, 'rb') as f:
            if f.read() != ged:
                must_restart_gm = True
    with open(new_ged_path, 'wb') as f:
        f.write(ged)
    if help_file != '':
        shutil.copy(help_file, os.path.join(extensions_path, name + os.path.splitext(help_file)[1]))
    with io.BytesIO() as out:
        seed = 0
        out.write(seed.to_bytes(4, 'little'))
        for f in files:
            if f[1] != 3:
                copy_file(out, f[0])
        with out.getbuffer() as view:
            for i in range(5, len(view)):
                view[i] = table[0][view[i]]
        with open(os.path.join(extensions_path, name + '.dat'), 'wb') as f:
              f.write(out.getvalue())
    if must_restart_gm and gm_running():
        print('GameMaker must be restarted!')
        input()

        
def decrypt_gex(gex_path, out_path):
    with open(gex_path, 'rb') as f:
        dat = bytearray(f.read())
    seed = int.from_bytes(dat[8:12], 'little')
    table = generate_swap_table(seed)
    for i in range(12, len(dat)):
        dat[i] = table[1][dat[i]]
    with open(out_path, 'wb') as f:
        f.write(dat)


build_gex(sys.argv[1], sys.argv[1][:-1] + 'x')
