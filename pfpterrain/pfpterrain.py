# SPDX-License-Identifier: Unlicense

from argparse import ArgumentParser
from pathlib import Path
from string import Template
import shutil
import subprocess
import sys


def main():
    argp = ArgumentParser()
    argp.add_argument('--server-exe', default=r'C:\Program Files (x86)\Steam\steamapps\common\Stormworks Dedicated Server\server64.exe', type=Path)
    argp.add_argument('--server-dir', default=Path(__file__).parent, type=Path)
    argp.add_argument('--seed-start', default=0, type=int)
    argp.add_argument('--seed-end', default=1000, type=int)
    argp.add_argument('--out', default=Path(Path(__file__).parent, 'out.lua'), type=Path)
    args = argp.parse_args()

    pfpterrain = PFPTerrain(args.server_exe, args.server_dir)
    code = pfpterrain.run(args.seed_start, args.seed_end + 1, log=sys.stdout)
    with args.out.open(mode='w') as fobj:
        fobj.write(code)


class PFPTerrain:
    def __init__(self, server_exe, server_dir):
        self._exe = server_exe
        self._server_dir = server_dir

    def run(self, seed_start, seed_stop, log=sys.stdout):
        self._remove_server()
        for seed in range(seed_start, seed_stop):
            self._make_server(seed)
            try:
                print(f'seed {seed}: running server (1st time)', file=log)
                self._run_server()
                self._restore_table()
                print(f'seed {seed}: running server (2nd time)', file=log)
                code = self._run_server()
                self._backup_table()
            finally:
                self._remove_server()
        return code

    def _remove_server(self):
        save_dir = Path(self._server_dir, 'saves')
        if save_dir.is_dir():
            shutil.rmtree(save_dir)
        working_dir = Path(self._server_dir, 'working_server')
        if working_dir.is_dir():
            shutil.rmtree(working_dir)
        server_file = Path(self._server_dir, 'server_config.xml')
        server_file.unlink(missing_ok=True)

    def _make_server(self, seed):
        template_file = Path(self._server_dir, 'server_config_template.xml')
        with template_file.open() as fobj:
            template = fobj.read()
        server_file = Path(self._server_dir, 'server_config.xml')
        server = Template(template).substitute(seed=str(seed))
        with server_file.open(mode='w') as fobj:
            fobj.write(server)

    def _backup_table(self):
        src_file = Path(self._server_dir, 'saves/autosave_server/script_data/0.xml')
        dst_file = Path(self._server_dir, 'lua_table.xml')
        shutil.copyfile(src_file, dst_file)

    def _restore_table(self):
        src_file = Path(self._server_dir, 'lua_table.xml')
        dst_file = Path(self._server_dir, 'saves/autosave_server/script_data/0.xml')
        if src_file.is_file():
            shutil.copyfile(src_file, dst_file)

    def _run_server(self):
        log = []
        log_prefix = '[Announce] [pfpterrain] : '
        with subprocess.Popen([self._exe.resolve(), '+server_dir', self._server_dir.resolve()], bufsize=0, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, cwd=self._exe.parent, text=True) as popen:
            try:
                while True:
                    line = popen.stdout.readline()
                    line = line.replace('\x0C', '')
                    if line.startswith(log_prefix):
                        log.append(line[len(log_prefix):])
                    if line == 'Autosave complete\n':
                        break
            finally:
                popen.terminate()
        return ''.join(log)


if __name__ == '__main__':
    main()
