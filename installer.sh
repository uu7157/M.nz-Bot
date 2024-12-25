# COLORS
White="\033[1;37m"
Red="\033[1;31m"
Cyan="\033[1;36m"
Yellow="\033[1;93m"
Green="\033[1;32m"
Un_Purple="\033[4;35m"
Reset="\033[0m"

# Output functions
function show_process() {
    echo -e "${White}==> ${1}${Reset}"
}

function show_hint() {
    echo -e "  Tip 💡: ${Yellow}${1}${Reset}"
}

function show_error() {
    echo -e "${Red}ERROR: ${1}${Reset}"
    exit 1
}

# Clone git repository
function clone_repo() {
    show_process "Cloning Mega.nz-Bot repository"
    git clone https://github.com/Itz-fork/Mega.nz-Bot.git || show_error "git: Clone failed"
    cd Mega.nz-Bot || show_error "fs: 'Mega.nz-Bot' not found"
}

# Check dependencies and install them
function check_deps() {
    show_process "Checking dependencies 🔍"
    if ! command -v git &> /dev/null; then
        apt-get update && apt-get install -y git || show_error "Unable to install git"
    fi
    if ! command -v pip3 &> /dev/null; then
        apt-get install -y python3-pip || show_error "Unable to install pip3"
    fi
    if ! command -v ffmpeg &> /dev/null; then
        apt-get install -y ffmpeg || show_error "Unable to install ffmpeg"
    fi
    if ! command -v megatools &> /dev/null; then
        apt-get install -y megatools || show_error "Unable to install megatools"
    fi

    show_process "Setting up python virtual environment"
    python3 -m venv .venv
    source .venv/bin/activate

    pip3 install -U -r requirements.txt || show_error "Unable to install Python requirements"
}

# Run the bot
function run_bot() {
    show_process "Starting Mega.nz-Bot"

    # Export environment variables for the bot
    export APP_ID=${APP_ID}
    export API_HASH=${API_HASH}
    export BOT_TOKEN=${BOT_TOKEN}
    export AUTH_USERS="${AUTH_USERS}"
    export LOG_CHAT=${LOG_CHAT}
    export MONGO_URI=${MONGO_URI}
    export CYPHER_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

    if [ -n "${MEGA_EMAIL}" ] && [ -n "${MEGA_PASSWORD}" ]; then
        export MEGA_EMAIL=${MEGA_EMAIL}
        export MEGA_PASSWORD=${MEGA_PASSWORD}
    fi

    # Start the bot
    python3 -m megadl
}

# Main installer function
function run_installer() {
    echo -e "${White}${Un_Purple}Welcome to ${Red}Mega.nz-Bot${Reset}${White}${Un_Purple} Setup!${Reset}"
    clone_repo
    check_deps
    run_bot
}

run_installer
