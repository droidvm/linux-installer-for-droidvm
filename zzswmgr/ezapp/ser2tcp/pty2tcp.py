import socket
import time
import serial
import threading
import signal
import pty
import os

bool_stop = False
tcpserver=socket.socket(socket.AF_INET,socket.SOCK_STREAM)

tcpserver.bind(('0.0.0.0', 8899))
tcpserver.listen(5)

def serial2clisock(clientsocket, clientaddr, serial_fd):
    global bool_stop
    print("serial2clisock 线程已启动");
    try:
        while True:
            if bool_stop:
                break
            data=os.read(serial_fd, 1)
            if data is not None:
                datalen=len(data)
                if (datalen < 1):
                    continue
                
                nsend=clientsocket.send(data)
                print("tx " + str(nsend) + "/" + str(datalen));
    except Exception as e:
        bool_stop = True
        print("serial2clisock: " + str(e))

    os.close(serial_fd)
    


def clisock2serial(clientsocket, clientaddr, serial_fd):
    global bool_stop
    print("clisock2serial 线程已启动");
    try:
        while True:
            if bool_stop:
                break
            data=clientsocket.recv(1024)
            if data is not None:
                datalen=len(data)
                if (datalen < 1):
                    continue

                nsend=os.write(serial_fd, data)
                print("rx " + str(nsend) + "/" + str(datalen));
                # os.flush(serial_fd) # https://blog.csdn.net/XIAOXIANG233233/article/details/134986172
    except Exception as e:
        bool_stop = True
        print("serial2clisock: " + str(e))

    clientsocket.close()



# 自定义的信号处理函数
def my_handler(signum, frame):
    global bool_stop
    bool_stop = True
    print("收到终止进程的信号")


signal.signal(signal.SIGINT, my_handler)    #设置Ctrl+c信号回调函数


print("正在等待tcp客户端连接，如果正在测试：nc -nvv 127.0.0.1 8899")
sock,addr=tcpserver.accept()
print("客户端已连入，正在为其打开串口") #地址: " + addr + " 

# ser=serial.Serial('/dev/ttyACM0',250000)

# ser=open("/dev/pts/27", "rw")
ser = pty.slave_open("/dev/pts/27")

# if ser.isOpen():
print("串口打开成功，正在为客户端启动两个转发线程")
thread_2serial = threading.Thread(target=clisock2serial, args=(sock,addr,ser,))
thread_2socket = threading.Thread(target=serial2clisock, args=(sock,addr,ser,))

thread_2serial.start()
thread_2socket.start()

thread_2serial.join()
thread_2socket.join()
# else:
#     print("串口打开失败")

tcpserver.close()
# time.sleep(1)

# 查看占用特定端口的进程
# netstat -anp|grep 8899

# ser=serial.Serial('/dev/ttyACM0',250000)
# if ser.isOpen():
#     data=ser.read(1)
#     print("tx ")

