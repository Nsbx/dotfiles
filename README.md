# Dotfiles
This is my dotfiles for my WSL environment powered by [chezmoi](https://github.com/twpayne/chezmoi)

## Add - Env Variable
```
export GITHUB_USERNAME=nsbx
export EDITOR=nano
```

## Install - Chezmoi
```
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /bin
```

## Apply - Chezmoi script
```
chezmoi init --apply $GITHUB_USERNAME
```
