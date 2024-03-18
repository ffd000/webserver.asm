FROM alpine

RUN apk add --no-cache curl && \
    curl -sL "https://flatassembler.net/fasm-1.73.30.tgz" | tar xz && \
    ln -s /fasm/fasm /bin/fasm

CMD fasm index.asm && chmod +x index && ./index