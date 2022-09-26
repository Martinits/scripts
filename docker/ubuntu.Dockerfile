FROM ubuntu:jammy

USER root
WORKDIR /root/tmp
RUN apt update
RUN apt install -y ca-certificates curl apt-utils
RUN cp /etc/apt/sources.list /etc/apt/sources.list.old
RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
# github-cli source
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt update
RUN apt upgrade -y
RUN apt install -y vim zsh git wget iputils-ping iproute2 gpg
RUN apt install -y build-essential cmake man-db
RUN apt install -y python3 python3-dev python3-pip python2 python2-dev
RUN apt install -y bat ranger fzf ripgrep fd-find zoxide thefuck direnv gh exa duf
RUN apt install -y rust-all golang software-properties-common
RUN apt install -y locales locales-all && update-locale LANG=en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN apt install -y sudo && echo '%martinit ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN ln -s /usr/bin/fdfind /bin/fd
# neovim
RUN add-apt-repository -y ppa:neovim-ppa/stable
# nodejs npm yarn
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install -y nodejs yarn neovim python3-neovim
RUN npm i -g neovim
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
RUN useradd -m martinit
RUN echo 'root:myubuntu' | chpasswd
RUN echo 'martinit:myubuntu' | chpasswd
WORKDIR /root
RUN rm -rf tmp

USER martinit
RUN mkdir -p ~/my
WORKDIR /home/martinit/my
# cargo packages
RUN cargo install tree-sitter-cli
RUN cargo install du-dust
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
