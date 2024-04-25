#!/usr/bin/env python3

import os, sys, getpass

def get_info(dir_path):
	dir_content = []

	ok_dir: bool = (
		os.path.exists(dir_path) and
		os.path.isdir(dir_path) and
		os.access(dir_path, os.R_OK)
	)

	if ok_dir:
		dir_content = os.listdir(dir_path)

	return {
		'user_name'  : getpass.getuser(),
		'path_exe'   : os.path.abspath(sys.argv[0]),
		'dir_content': dir_content
	}

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print(f"Usage: {sys.argv[0]} [directory]")
		sys.exit(1)

	print(get_info(sys.argv[1]))
