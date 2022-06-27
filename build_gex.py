import io
import json
import os
import shutil
import sys
import zlib


def generate_ged(gej):
    with io.BytesIO() as ged:
        def write_int(i):
            ged.write(i.to_bytes(4, 'little', signed=True))

        def write_string(s):
            write_int(len(s))
            ged.write(s.encode('utf-8'))

        ged.write(b'\xbc\02\0\0\0\0\0\0')
        write_string(gej['name'])
        write_string(gej['folder'])
        write_string(gej['version'])
        write_string(gej['author'])
        write_string(gej['date'])
        write_string(gej['license'])
        write_string(gej['description'])
        write_string(gej['helpfile'])
        write_int(gej['hidden'])
        write_int(len(gej['dependencies']))
        for d in gej['dependencies']:
            write_string(d)
        write_int(len(gej['files']))
        for fi in gej['files']:
            write_int(700)
            write_string(fi['filename'])
            write_string(fi['origname'])
            write_int(fi['kind'])
            write_string(fi['init'])
            write_string(fi['final'])
            write_int(len(fi['functions']))
            for fu in fi['functions']:
                write_int(700)
                write_string(fu['name'])
                write_string(fu['extname'])
                write_int(fu['calltype'])
                write_string(fu['helpline'])
                write_int(fu['hidden'])
                write_int(len(fu['argtypes'])
                          if fu['argtypes'] is not None else -1)
                for i in range(17):
                    write_int(
                        fu['argtypes'][i] if fu['argtypes'] and i < len(fu['argtypes']) else 0)
                write_int(fu['returntype'])
            write_int(len(fi['constants']))
            for c in fi['constants']:
                write_int(700)
                write_string(c['name'])
                write_string(c['value'])
                write_int(c['hidden'])
        return bytearray(ged.getvalue())


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
    if os.path.dirname(ged_path) != '':
        os.chdir(os.path.dirname(ged_path))
    # load ged
    if ged_path.endswith('.ged'):
        with open(ged_path, "rb") as f:
            ged = bytearray(f.read())
    else:
        with open(ged_path) as f:
            ged = generate_ged(json.load(f))
    # this dword marks it as either a project or an installed extension (either .gex or appdata)
    ged[4] = 0
    # collect extension name, help file, and name/kind of every file
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
    # encryption init
    seed = 0
    table = generate_swap_table(seed)
    with io.BytesIO() as out:
        # write out all files
        out.write(b'\x91\xd5\x12\x00\xbd\x02\x00\x00')
        out.write(seed.to_bytes(4, 'little'))
        out.write(ged)
        if help_file != '':
            copy_file(out, help_file)
        for f in files:
            copy_file(out, f[0])
        # encrypt
        with out.getbuffer() as view:
            for i in range(13, len(view)):
                view[i] = table[0][view[i]]
        # write to file
        with open(gex_path, 'wb') as f:
            f.write(out.getvalue())
    if "--noinstall" not in sys.argv:
        must_restart_gm = False
        # install newly generated extension
        extensions_path = os.path.join(
            os.getenv('LOCALAPPDATA'), 'GameMaker8.2', 'extensions/')
        new_ged_path = os.path.join(extensions_path, name + '.ged')
        # check if ged will be updated
        if os.path.isfile(new_ged_path):
            with open(new_ged_path, 'rb') as f:
                if f.read() != ged:
                    must_restart_gm = True
        # update ged
        with open(new_ged_path, 'wb') as f:
            f.write(ged)
        # update help file, if applicable
        if help_file != '':
            shutil.copy(help_file, os.path.join(extensions_path,
                        name + os.path.splitext(help_file)[1]))
        # update .dat file
        with io.BytesIO() as out:
            seed = 0
            out.write(seed.to_bytes(4, 'little'))
            # write every file
            for f in files:
                if f[1] != 3:
                    copy_file(out, f[0])
            # encrypt
            with out.getbuffer() as view:
                for i in range(5, len(view)):
                    view[i] = table[0][view[i]]
            # write to file
            with open(os.path.join(extensions_path, name + '.dat'), 'wb') as f:
                f.write(out.getvalue())
        # show warning if needed
        if must_restart_gm and gm_running():
            print('GameMaker must be restarted!')


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
