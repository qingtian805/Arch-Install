---
name: pacman
description: Describes how to use `pacman` to manage packages on Arch and Arch based distributions.
---
## Search
- To search which package contains the command, use `pacman -Fy`
- To search a package in repo, use `pacman -Si package`

## Query
- To query all local installed packages, use `pacman -Q`
- To query explicitly installed packages, use `pacman -Qe`
- To query info of a installed packages, use `pacman -Qi`
- To query files in a installed package, use `pacman -Fl`

## Install and Update
- To update system and install package, use `pacman -Syu`
- To install a local package, use `pacman -U`

## Remove
- To remove package and configuration, use `pacman -Rn`
- To remove redundent dependencies use `pacman -Qtdq | pacman -Rn`

## See Also
- Details about updating packages: `references/update-restrictions.md`
