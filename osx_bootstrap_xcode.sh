log_header() {
    echo ""
    echo "---  $1  ---"
    echo "---------------------------------------------"   
}

log_line() {
    echo "### $1 #"
}

log_line "Starting bootstrapping"

log_header "Installing XCode command line tools"
xcode-select --install