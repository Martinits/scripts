FROM archlinux:latest
USER root
WORKDIR /root/tmp
RUN mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN echo '[archlinuxcn]' >> /etc/pacman.conf
RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
RUN sed -i 's/^#Color$/Color/g' /etc/pacman.conf
RUN pacman-key --init
RUN pacman -Syy --noconfirm
RUN pacman -S --noconfirm archlinuxcn-keyring
RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm yay neovim vim zsh git wget
RUN pacman -S --noconfirm cmake man-db python python-pip
RUN pacman -S --noconfirm bat ranger-git fzf ripgrep ripgrep-all
RUN pacman -S --noconfirm fd zoxide thefuck direnv github-cli
RUN pacman -S --noconfirm exa duf dust rust-analyzer
RUN pacman -S --noconfirm nodejs npm yarn python-neovim
RUN pacman -S --noconfirm git-delta vivid tree-sitter translate-shell
RUN npm i -g neovim
RUN mv /etc/locale.gen /etc/locale.gen.old
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
RUN locale-gen
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo '%martinit ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# add martinit
RUN useradd -m martinit
RUN echo 'root:myarch' | chpasswd
RUN echo 'martinit:myarch' | chpasswd
WORKDIR /root
RUN rm -rf tmp

USER martinit
RUN mkdir -p ~/my
WORKDIR /home/martinit/my
# zsh things
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/arzzen/calc.plugin.zsh.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/calc.plugin.zsh
# dotfiles
RUN git clone https://github.com/martinits/dotfiles.git
WORKDIR /home/martinit/my/dotfiles
RUN git submodule init && git submodule update
RUN cp .zshrc .func.zsh .fzf.zsh .gdbinit .gitconfig /home/martinit
RUN echo 'export TERM=alacritty' >> /home/martinit/.zshrc
RUN mkdir ~/.config
RUN cp -r .config/bat ~/.config
RUN cp -r .config/delta ~/.config
RUN cp -r .config/nvim ~/.config
RUN cp -r .config/ranger ~/.config

USER root
RUN chsh -s /bin/zsh martinit

USER martinit
WORKDIR /home/martinit/my/tmp
