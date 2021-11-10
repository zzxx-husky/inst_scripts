[![CI](https://github.com/zzxx-husky/inst_scripts/actions/workflows/test_all_scripts.yml/badge.svg)](https://github.com/zzxx-husky/inst_scripts/actions/workflows/test_all_scripts.yml)

This repo stores scripts for installing different libraries.

Each script roughly contains the following steps:

1. Install the dependencies of the library, if any.

2. Download the library source code by wget, git, etc.

3. Configure the source code if necessary, e.g., generate Makefile for compilation

4. Compile the source code if the library is not header-only.

5. Install the headers and libs into specified directory.

6. Mark down in `instrc.sh` where the headers and libs of the library are located

Compared to commonly used package managers (e.g., apt, brew, etc), these scripts make it clear
where the libraries are downloaded and installed, and also make it clear to keep multiple versions
and switch among different versions (which are installed by different users for different usage).
