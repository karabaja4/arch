#!/bin/sh

# ln  LINK
# or  ORPHAN
# tw  STICKY_OTHER_WRITABLE
# ow  OTHER_WRITABLE
# st  STICKY
# di  DIR
# pi  FIFO
# so  SOCK
# bd  BLK
# cd  CHR
# su  SETUID
# sg  SETGID
# ex  EXEC
# fi  FILE

export LF_ICONS="\
ln=📌:\
or=💔:\
tw=📁:\
ow=📁:\
st=📁:\
di=📁:\
pi=⏩:\
so=🔌:\
bd=🔌:\
cd=📌:\
su=📜:\
sg=📜:\
ex=📜:\
fi=📄:\
*.txt=📝:\
*.log=📄:\
*.avi=📺:\
*.mkv=📺:\
*.mp4=📺:\
*.mov=📺:\
*.srt=💬:\
*.mp3=🎶:\
*.m4a=🎶:\
*.flac=🎶:\
*.ogg=🎶:\
*.wav=🎵:\
*.png=🌄:\
*.jpg=🌄:\
*.bmp=🌄:\
*.gif=🌄:\
*.jpeg=🌄:\
*.svg=🌄:\
*.ico=🌄:\
*.webp=🌄:\
*.pdf=📘:\
*.md=📘:\
*.c=📜:\
*.cpp=📜:\
*.h=📜:\
*.sh=📜:\
*.js=📜:\
*.py=📜:\
*.cs=📜:\
*.css=📜:\
*.php=📜:\
*.json=📜:\
*.xml=📜:\
*.yml=📜:\
*.yaml=📜:\
*.pid=🔧:\
*.conf=🔧:\
*.cfg=🔧:\
*.cnf=🔧:\
*.ini=🔧:\
*.rules=🔧:\
*.profile=🔧:\
*.service=🔧:\
*.socket=🔌:\
*.exe=🍷:\
*.so=📚:\
*.dll=📚:\
*.gz=📦:\
*.zip=📦:\
*.rar=📦:\
*.7z=📦:\
*.bz2=📦:\
*.xz=📦:\
*.zst=📦:\
*.deb=📦:\
*.iso=💿:\
*.img=💿:\
*.htm=🌍:\
*.html=🌍:\
*.torrent=🌐:\
*.pub=🔒:\
*.key=🔑:\
*.crt=🔑:\
*.pem=🔑:\
*.gpg=🔑:\
*.vbox=💻:\
*.vdi=💽:\
*.xls=📊:\
*.xlsx=📊:\
*.doc=📋:\
*.docx=📋:\
"