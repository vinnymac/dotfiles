import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


class NodeTransitionTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.bin = self.home / 'bin'
        self.bin.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home), 'VOLTA_HOME': str(self.home / '.volta'),
                    'PATH': f'{self.bin}:/usr/bin:/bin', 'TEST_LOG': str(self.home / 'calls')}
        self.make_executable(self.bin / 'mise', '#!/bin/sh\nprintf "mise %s\\n" "$*" >> "$TEST_LOG"\n')

    def make_executable(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        path.chmod(0o755)

    def run_exports(self, shell):
        return subprocess.check_output([shell, '-c', f'. "{ROOT}/.exports"; node'], env=self.env, text=True).strip()

    def test_volta_node_keeps_precedence_for_both_shells(self):
        self.make_executable(self.home / '.volta/bin/node', '#!/bin/sh\necho volta-project\n')
        self.make_executable(self.home / '.local/share/mise/shims/node', '#!/bin/sh\necho mise-project\n')
        for shell in ('bash', 'zsh'):
            with self.subTest(shell=shell):
                self.assertEqual(self.run_exports(shell), 'volta-project')

    def test_mise_shims_work_when_volta_absent(self):
        self.make_executable(self.home / '.local/share/mise/shims/node', '#!/bin/sh\necho mise-project\n')
        for shell in ('bash', 'zsh'):
            with self.subTest(shell=shell):
                self.assertEqual(self.run_exports(shell), 'mise-project')

    def test_bootstrap_updates_both_defaults_without_uninstalling_volta(self):
        self.make_executable(self.home / '.volta/bin/node', '#!/bin/sh\nexit 0\n')
        self.make_executable(self.bin / 'volta', '#!/bin/sh\nprintf "volta %s\\n" "$*" >> "$TEST_LOG"\n')
        subprocess.run(['bash', str(ROOT / 'node.sh')], env=self.env, check=True)
        calls = (self.home / 'calls').read_text().splitlines()
        self.assertIn('mise use --global node@26.13.0 yarn@4', calls)
        self.assertIn('volta install node@26.13.0', calls)
        self.assertFalse(any('uninstall' in call for call in calls))


if __name__ == '__main__':
    unittest.main()
