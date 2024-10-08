import serial
import time
import sys

#arguments: SerialPortName, FileName, Address
if len(sys.argv)<3 :
	print("Not enough arguments")
	
port_name = sys.argv[1]
val_str = sys.argv[2]
if "x" in val_str :
	val = int(val_str,16)
else :
	val = int(val_str)

print("Write ", val, " to ", port_name)

port = serial.Serial()
port.baudrate=115200
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
port.open()
print(port.name)

b0 = (val    ) & 0xF
b1 = (val>>4 ) & 0xF
b2 = (val>>8 ) & 0xF
b3 = (val>>12) & 0xF
b0 = b0 | 0x80

cmd = bytearray([b3,b2,b1,b0])
port.write( cmd )
time.sleep(0.5)
port.close()
