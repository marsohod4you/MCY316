# MCY316 Leds7Seg

Плата MCY316 подключается переходником к GPIO разъему Raspberry Pi.
Я сейчас тестирую на Raspberry Pi5 с последней на момент написания 64-bit ОС Bookworm.

На Raspberry Pi5 установлены gpiod, libgpiod-dev, openocd.

С помощью OpenOCD можно загрузить SVF файл в FPGA платы MCY316.
После загрузки ПЛИС программы на Распберри могут взаимодействовать с ПЛИС через последовательный порт или GPIO сигналы.

В этом FPGA проекте есть приёмопередатчик последовательного порта. Через последовательный порт на скорости 115200 можно посылать команды для отображения чисел на 7-ми сегментном индикаторе.

Эта функция продемонстрирована двумя питоновскими программами:
1) lock_7seg.py
>python3 clock_7seg.py /dev/ttyAMA0
Отображает текущее время на 7ми сегментном индикаторе.
2) write_7seg.py
>python3 write_7seg.py /dev/ttyAMA0 0x1255
Записывает число взятое из командной строки на 7-ми сегментный индикатор.

Вторая функция реализованная в ПЛИС платы MCY316 это отображать 8 линий GPIO из Распбери на светодиодах платы. Эта функция конечно не мудрёная, но демонстрирует возможность коммуникации между микропроцессором и FPGA через сигналы GPIO.

Так же есть две программы:
1) set_8leds.c
Записывает в FPGA плату 8-ми битное число, которое будет отражаться на светодиодах.
2) run8leds.c
Перемещает единственный зажжённый светодиод слева направа и назад в цикле.

Компилировать программы можно прямо на распберри командами 
>gcc run8leds.c -o run8leds -lgpiod

Для использования OpenOCD создайте 3 конфигурационных файла:
1) /usr/share/openocd/scripts/interface/mcy316-gpiod.cfg
--------------------------
adapter driver linuxgpiod

adapter gpio trst 5 -chip 4
adapter gpio tdi 11 -chip 4
adapter gpio tck 7  -chip 4
adapter gpio tms 0  -chip 4
adapter gpio tdo 1  -chip 4

reset_config trst_only separate trst_push_pull
--------------------------

2) /usr/share/openocd/scripts/board/mcy316.cfg
--------------------------
source [find interface/mcy316-gpiod.cfg]
adapter speed 2000
transport select jtag
source [find fpga/altera-ep3c16.cfg]
--------------------------

3) /usr/share/openocd/scripts/fpga/altera-ep3c16.cfg
--------------------------
\# SPDX-License-Identifier: GPL-2.0-or-later

\# Altera Cyclone III EP3C16
\# see Cyclone III Device Handbook, Volume 1;
\# Table 14–5. 32-Bit Cyclone III Device IDCODE
jtag newtap ep3c16 tap -expected-id 0x020f20dd -irlen 10
--------------------------

Запуск OpenOCD командой:
pi@raspberrypi:~ $ sudo openocd -f board/mcy316.cfg
Open On-Chip Debugger 0.12.0
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : Linux GPIOD JTAG/SWD bitbang driver
Info : This adapter doesn't support configurable speed
Info : JTAG tap: ep3c16.tap tap/device found: 0x020f20dd (mfg: 0x06e (Altera), part: 0x20f2, ver: 0x0)
Warn : gdb services need one or more targets defined


После этого можно к этому OpenOCD серверу подключиться телнетом и выполнить команду загрузки FPGA проекта
pi@raspberrypi:~ $ telnet localhost 4444
Trying ::1...
Connection failed: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Open On-Chip Debugger
> svf io.svf
svf processing file: "io.svf"
FREQUENCY 2.50E+07 HZ;
Translation from khz to adapter speed not implemented

TRST ABSENT;
ENDDR IDLE;
ENDIR IRPAUSE;
STATE IDLE;
SIR 10 TDI (002);
RUNTEST IDLE 25000 TCK ENDSTATE IDLE;
        BEFEFEFEFEFEFCFCFCFCFCFCFCFDFFFFFFFFFCFDFEFCFCFCFDFCF9F9F1FAFAF9F3FBFBFFFFFFFFFFFF6AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
SIR 10 TDI (004);
RUNTEST 125 TCK;
        00000000000000000000000000000000000000000000000000000000000000000000000000);
SIR 10 TDI (003);
RUNTEST 125000 TCK;
RUNTEST 512 TCK;
SIR 10 TDI (3FF);
RUNTEST 25000 TCK;
STATE IDLE;

Time used: 0m3s589ms
svf file programmed successfully for 17 commands with 0 errors

>


