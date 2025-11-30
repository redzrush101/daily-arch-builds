if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    echo "--------------------------------------------------------"
    echo "  Welcome to Arch Sway Live"
    echo "  User: arch  |  Pass: arch"
    echo ""
    echo "  -> Type 'sway' to start the desktop"
    echo "  -> Connect to WiFi with 'nmtui' before starting sway"
    echo "--------------------------------------------------------"
fi
