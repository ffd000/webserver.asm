format ELF64 executable

include "linux.inc"

MAX_CONN equ 5
REQUEST_CAP equ 128*1024

segment readable executable

entry main
main:
	write STDOUT, start_msg, start_msg_len

	socket AF_INET, SOCK_STREAM, 0
	cmp rax, 0
    jl .error
	mov qword [sockfd], rax

	setsockopt [sockfd], SOL_SOCKET, SO_REUSEADDR, enable, 4
    cmp rax, 0
    jl .error

    setsockopt [sockfd], SOL_SOCKET, SO_REUSEPORT, enable, 4
    cmp rax, 0
    jl .error

	mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 14619
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    cmp rax, 0
    jl .error

	listen [sockfd], MAX_CONN
    cmp rax, 0
    jl .error

.next_request:
	write STDOUT, waiting_msg, 36
    accept [sockfd], cliaddr.sin_family, cliaddr_len

    mov qword [connfd], rax
    write [connfd], response, response_len
    jmp .next_request
	
	write STDOUT, ok_msg, 4
	exit 0

.error:
    write 1, error_msg, 7
	close [connfd]
    close [sockfd]
    exit 1

segment readable writeable

enable dd 1
sockfd dq -1
connfd dq -1
servaddr servaddr_in
sizeof_servaddr = $ - servaddr.sin_family
cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr

response    db "HTTP/1.1 200 OK", 13, 10
            db "Content-Type: text/html; charset=utf-8", 13, 10
            db "Connection: close", 13, 10
            db 13, 10
            db "<style>", 10
            db "body {", 10
            db "margin: 0;", 10
            db "padding: 0;", 10
            db "display: flex;", 10
            db "justify-content: center;", 10
            db "align-items: center;", 10
            db "height: 100vh;", 10
            db "background-color: lightcoral;", 10
            db "background-size: cover;", 10
            db "background-position: center;", 10
            db "}", 10
            db ".content {", 10
            db "text-align: center;", 10
            db "position: relative;", 10
            db "z-index: 1;", 10
            db "margin-top: -2vh;", 10
            db "}", 10
            db ".text {", 10
            db "font: 'Shippori Mincho';", 10
            db "src: url('ShipporiMincho-Regular.ttf') format('ttf'),", 10
            db "font-weight: normal;", 10
            db "font-style: normal;", 10
            db "letter-spacing: -1px;", 10
            db "color: #fff;", 10
            db "text-shadow: 0px 0px 5px rgba(255, 255, 255, 1);", 10
            db "}", 10
            db ".footer {", 10
            db "position: absolute;", 10
            db "bottom: 20px;", 10
            db "left: 50%;", 10
            db "transform: translate(-50%);", 10
            db "text-align: center;", 10
            db "}", 10
            db "</style>", 10
            db "<body>", 10
            db "<div class='content'>", 10
            db "<div class='text' style='font-size: 2vw'>カウントダウン</div>", 10
            db "<div class='text' style='font-size: 6vw'>10:20:30</div>", 10
            db "</div>", 10
            db "<div class='footer'>", 10
            db "<div class='text' style='font-size: 2vw'>Language 'asm'</div>", 10
            db "<div class='text' style='font-size: 2vw'>语言 汇编语言</div>", 10
            db "<div class='text' style='font-size: 1.5vw'>(By github.com/ffd000)</div>", 10
            db "</div>", 10
            db "</body>", 10

response_len = $ - response

hello db "Hello from FASM!", 10
start_msg 			db "Starting Webserver", 10
start_msg_len = $ - start_msg
error_msg       	db "Error!", 10
ok_msg        		db "OK!", 10
waiting_msg        	db "Waiting for incoming connections...", 10