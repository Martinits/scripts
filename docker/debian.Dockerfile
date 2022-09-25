FROM debian:bullseye

USER root
WORKDIR /root/tmp
RUN apt update
RUN apt install -y ca-certificates curl
RUN mv /etc/apt/sources.list /etc/apt/sources.list.old
RUN echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free \
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free \
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free \
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free' > /etc/apt/sources.list
# github-cli source
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt update
RUN apt upgrade -y
RUN apt install -y vim neovim zsh git wget iputils-ping iproute2 sudo
RUN apt install -y python3 gcc g++ make cmake
RUN apt install -y bat ranger fzf ripgrep fd-find nodejs zoxide thefuck direnv gh
RUN ln -s /usr/bin/fdfind /bin/fd
# git-delta
RUN wget https://github.com/dandavison/delta/releases/download/0.14.0/git-delta_0.14.0_amd64.deb -O git-delta.deb
RUN dpkg -i git-delta.deb
# ripgrep-all
RUN wget https://github.com/phiresky/ripgrep-all/releases/download/v0.9.6/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl.tar.gz -O rga.tgz
RUN tar zxf rga.tgz && mv ripgrep_all-v0.9.6-x86_64-unknown-linux-musl/rga ripgrep_all-v0.9.6-x86_64-unknown-linux-musl/rga-preproc /usr/bin
# vivid
RUN wget "https://github.com/sharkdp/vivid/releases/download/v0.8.0/vivid_0.8.0_amd64.deb" -O vivid.deb
RUN dpkg -i vivid.deb
# add martinit
RUN echo '%martinit ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN useradd -m martinit
RUN echo 'root:mydebian' | chpasswd
RUN echo 'martinit:mydebian' | chpasswd
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
RUN mkdir ~/.config
RUN cp -r .config/bat ~/.config
RUN cp -r .config/delta ~/.config
RUN cp -r .config/nvim ~/.config
RUN cp -r .config/ranger ~/.config

USER root
RUN chsh -s /bin/zsh martinit

USER martinit
WORKDIR /home/martinit/my/tmp
