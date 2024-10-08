import serial
import time
import sys

#arguments: SerialPortName
if len(sys.argv)<2 :
	print("Not enough arguments")
	
port_name = sys.argv[1]

port = serial.Serial()
port.baudrate=115200
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
port.open()
print(port.name)

N=0;
while 1 :
	N=N+1
	t = time.strftime('%H:%M:%S')
	b3 = ord(t[0])-0x30;
	b2 = ord(t[1])-0x30;
	b1 = ord(t[3])-0x30;
	b0 = ord(t[4])-0x30;
	if N&1 :
		b2 = b2 | 0x10;
	b0 = b0 | 0x80;
	cmd = bytearray([b3,b2,b1,b0])
	port.write( cmd )
	time.sleep(1)

port.close()
