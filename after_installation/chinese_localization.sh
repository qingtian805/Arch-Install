#!/bin/bash

fontconfig='./fontconfig.conf'

fcitx_env=$(cat << 'EOF'
# Setting up fcitx5 environments

# Wayland
export XMODIFIERS=@im=fcitx

# Xorg extension
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
    sudo cp ./fontconfig.conf /etc/fonts/local.conf
}

fcitx() {

    if pacman -Qi fcitx5; then
        echo "Fcitx has installed"
    else
        echo "Installing Fcitx..."
        sudo pacman -Syu fcitx5-im
    fi

    # Environment Variables
    echo "Setting up environments variables..."
    sudo tee /etc/profile.d/fcitx.sh <<< "${fcitx_env}" > /dev/null
}

config_fonts
fcitx
