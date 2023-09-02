# MCY316 видеофреймбуффер

На плату MCY316 может устанавливается платка VGA от Raspberry Pi.
Вот так:

![MCY316+VGA photo](../images/mcy316_vga_small.jpg "MCY316 FPGA board photo")

К VGA разъему платы подключается монитор.

Этот FPGA проект реализует видео фреймбуффер из SDRAM платы MCY316.
Откомпилируйте проект в среде Altera Quartus Web Edition 13.1 и загрузите в ПЛИС платы.

На экране монитора появится изображение случайных пикселей памяти SDRAM, матрасик.
Теперь с помощью скрипта на питоне можно через последовательный порт платы загрузить изображение во фреймбуффер:

>python img2serial COM22 cat5.jpg 100 200

На экране монитора будет картинка:

![MCY316 VGA photo](../images/fbcats.jpg "MCY316 FPGA board photo")

Этот проект портирован из проекта предыдущей платы MCY112:
https://marsohod.org/projects/mcy112-prj/429-vga-framebuffer-mcy112

