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
    jl .fatal_error
	mov qword [sockfd], rax

	setsockopt [sockfd], SOL_SOCKET, SO_REUSEADDR, enable, 4
    cmp rax, 0
    jl .fatal_error

    setsockopt [sockfd], SOL_SOCKET, SO_REUSEPORT, enable, 4
    cmp rax, 0
    jl .fatal_error

	mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 14619
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    cmp rax, 0
    jl .fatal_error

	listen [sockfd], MAX_CONN
    cmp rax, 0
    jl .fatal_error

	write STDOUT, waiting_msg, 36
    accept [sockfd], cliaddr.sin_family, cliaddr_len
	
	write STDOUT, ok_msg, 4
    close [connfd]
    close [sockfd]
	exit 0

.fatal_error:
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

start_msg 			db "Starting Webserver", 10
start_msg_len = $ - start_msg
error_msg       	db "Error!", 10
ok_msg        		db "OK!", 10
waiting_msg        	db "Waiting for incoming connections...", 10