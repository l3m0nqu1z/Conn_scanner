# Connection scanner

Debian-like OSs only. \
Shows current connections and checks which Organization the IP addresses belong to.\
Also counting connections per Organization. \
Run the script with an argument as a searching item.

There are items to search: 
- PID 
- PROCESS NAME
- CONNECTION STATE ( ESTAB | LISTEN | UNCONN )
- NETID (tcp/udp)

Launching: \
$ `./scan_conn.sh firefox`
