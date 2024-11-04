# Dotfiles
This is my dotfiles for my WSL environment powered by [chezmoi](https://github.com/twpayne/chezmoi)

## Run
```
echo 'export GITHUB_USERNAME=nsbx' >> ~/.bashrc
echo 'export EDITOR=nano' >> ~/.bashrc
source ~/.bashrc
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /bin
chezmoi init $GITHUB_USERNAME
chezmoi apply
```
