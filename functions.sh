# Erstellt einen Ordner und wechselt sofort hinein
make-dir() {
  if [ -z "$1" ]; then
    echo "Verwendung: mkdircd <ordnername>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

# Öffnet Ordner $1, dann pwd und ls -la
hello() {
  if [ -z "$1" ]; then
    echo "Verwendung: hello <ordnername>"
    return 1
  fi
  cd -- "$1" || return
  pwd
  ls -la
}

# Geht einen Ordner zurück, dann pwd und ls -la
back() {
  cd .. || return
  pwd
  ls -la
}
