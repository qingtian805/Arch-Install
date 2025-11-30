#!/usr/bin/bash

fontconfig='./fontconfig.conf'

fcitx_env=$(echo << 'EOF'
# Setting up fcitx5 environments

# Wayland
export XMODIFIERS=@im=fcitx

# Xorg
if test "$XDG_SESSION_TYPE" = "x11"; then
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
fi
EOF
)

config_fonts() {
    echo "Installing fonts..."
    sudo pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji
    echo "Configuring fonts..."
    sudo ln -sf /usr/share/fontconfig/conf.default/50-user.conf /etc/fonts/conf.d
    sudo ln -sf /usr/share/fontconfig/conf.default/51-local.conf /etc/fonts/conf.d
    sudo cp ./fontconfig.conf /mnt/etc/fonts/local.conf
}

fcitx() {
    echo "Installing Fcitx..."
    sudo pacman -Syu fcitx5-im

    # Environment Variables
    echo "$fcitx_env" | sudo tee /etc/profile.d/fcitx.sh
}