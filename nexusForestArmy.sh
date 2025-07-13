#!/bin/bash

# 🌈 Random RGB line printer
function rgb_line() {
    COLORS=(31 32 33 34 35 36)
    C=${COLORS[$((RANDOM % ${#COLORS[@]}))]}
    echo -e "\033[1;${C}m$1\033[0m"
}

# 🌲 FOREST ARMY BANNER
clear
rgb_line "███████╗ ██████╗ ██████╗ ███████╗███████╗████████╗     █████╗ ██████╗ ███╗   ███╗██╗   ██╗"
rgb_line "██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗████╗ ████║╚██╗ ██╔╝"
rgb_line "█████╗  ██║   ██║██████╔╝█████╗  █████╗     ██║       ███████║██████╔╝██╔████╔██║ ╚████╔╝ "
rgb_line "██╔══╝  ██║   ██║██╔═══╝ ██╔══╝  ██╔══╝     ██║       ██╔══██║██╔═══╝ ██║╚██╔╝██║  ╚██╔╝  "
rgb_line "██║     ╚██████╔╝██║     ███████╗███████╗   ██║       ██║  ██║██║     ██║ ╚═╝ ██║   ██║   "
rgb_line "╚═╝      ╚═════╝ ╚═╝     ╚══════╝╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝   ╚═╝   "
echo ""
rgb_line "                 🚀 WELCOME TO THE FOREST ARMY NODE LAUNCHER 🚀"
echo ""

CONFIG_DIR="$HOME/.forest_army"
mkdir -p "$CONFIG_DIR"
WALLET_FILE="$CONFIG_DIR/wallet.txt"
NODE_DIR="$CONFIG_DIR/node_ids"
mkdir -p "$NODE_DIR"

function rgb_option() {
    rgb_line "[${1}] ${2}"
}

# Install CLI
function install_cli() {
    if ! command -v nexus-network &> /dev/null; then
        echo "🛠 Installing Nexus CLI..."
        curl https://cli.nexus.xyz/ | sh
        source ~/.bashrc
        echo "✅ Nexus CLI installed."
    else
        echo "✅ Nexus CLI already installed."
    fi
}

# Register wallet
function register_wallet() {
    read -p "🔐 Enter your wallet address: " WALLET
    echo "$WALLET" > "$WALLET_FILE"
    nexus-network register-user --wallet-address "$WALLET"
    echo "✅ Wallet registered & saved."
}

# Run nodes
function run_nodes() {
    if [ ! -f "$WALLET_FILE" ]; then
        echo "❗ Register your wallet first (Option 2)"
        return
    fi

    WALLET=$(cat "$WALLET_FILE")
    nexus-network register-user --wallet-address "$WALLET"

    read -p "🔢 Number of nodes to run (1–100): " NUM_NODES
    if ! [[ "$NUM_NODES" =~ ^[1-9][0-9]?$|^100$ ]]; then
        echo "❌ Invalid input! Enter between 1–100."
        return
    fi

    for ((i=1; i<=NUM_NODES; i++)); do
        FILE="$NODE_DIR/node${i}.id"
        echo ""
        echo "📦 Node $i:"
        if [ -f "$FILE" ]; then
            OLD_ID=$(cat "$FILE")
            echo "🗂️ Found previous ID: $OLD_ID"
            read -p "♻️ Reuse it? (Y/n): " USE_OLD
            if [[ "$USE_OLD" =~ ^[Nn]$ ]]; then
                read -p "🆕 Enter new node ID for node-$i: " NODE_ID
                echo "$NODE_ID" > "$FILE"
            else
                NODE_ID="$OLD_ID"
            fi
        else
            read -p "🆕 Enter node-$i ID: " NODE_ID
            echo "$NODE_ID" > "$FILE"
        fi

        echo "🚀 Launching node-$i in screen 'no$i'..."
        screen -dmS "no$i" bash -c "nexus-network start --node-id $NODE_ID"
    done
    echo "✅ All nodes launched. Use: screen -ls"
}

# View logs
function view_logs() {
    screen -ls
    read -p "🔍 Enter screen name to view logs (e.g., no1): " SCREEN_NAME
    screen -r "$SCREEN_NAME"
}

function restart_all() {
    pkill -f "nexus-network start"
    run_nodes
}

function node_status() {
    ps -ef | grep "nexus-network start" | grep -v grep
}

function stop_one() {
    read -p "🛑 Enter node screen name to stop (e.g., no1): " SCREEN_NAME
    screen -S "$SCREEN_NAME" -X quit
    echo "✅ Node $SCREEN_NAME stopped."
}

function change_wallet() {
    read -p "💼 Enter new wallet address: " WALLET
    echo "$WALLET" > "$WALLET_FILE"
    echo "✅ Wallet updated."
}

function show_ids() {
    echo "📁 Saved Node IDs:"
    cat "$NODE_DIR"/*.id 2>/dev/null || echo "❌ No node IDs found."
}

function uninstall_nexus() {
    echo "⚠️ This will remove Nexus CLI & all data."
    read -p "Are you sure? (Y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "🧹 Removing Nexus..."
        rm -f ~/.local/bin/nexus-network
        rm -rf ~/.nexus "$CONFIG_DIR"
        sed -i '/nexus-network/d' ~/.bashrc
        echo "✅ All Nexus data removed."
    else
        echo "❌ Cancelled."
    fi
}

# 🔁 Main Menu Loop
while true; do
    echo ""
    rgb_line "================ FOREST ARMY MENU ================"
    rgb_option "1" "🛠 Install Nexus CLI (if not installed)"
    rgb_option "2" "🔐 Register Wallet (only once)"
    rgb_option "3" "🚀 Run Node(s)"
    rgb_option "4" "👀 View Live Logs"
    rgb_option "5" "❌ Exit"
    rgb_option "6" "🔃 Restart All Nodes"
    rgb_option "7" "📊 View Node Status"
    rgb_option "8" "🛑 Stop a Specific Node"
    rgb_option "9" "💼 Change Wallet Address"
    rgb_option "10" "📁 Show All Saved Node IDs"
    rgb_option "11" "🧹 Full Uninstall Nexus CLI"
    echo "=================================================="

    read -p "Choose an option (1–11): " CHOICE
    case $CHOICE in
        1) install_cli ;;
        2) register_wallet ;;
        3) run_nodes ;;
        4) view_logs ;;
        5) exit ;;
        6) restart_all ;;
        7) node_status ;;
        8) stop_one ;;
        9) change_wallet ;;
        10) show_ids ;;
        11) uninstall_nexus ;;
        *) echo "❌ Invalid choice!" ;;
    esac
done
