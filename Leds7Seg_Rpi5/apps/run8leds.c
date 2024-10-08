#include <stdio.h>
#include <gpiod.h>
#include <unistd.h>


int main( int argc, char* argv[] )
{
	struct gpiod_chip *chip;
	struct gpiod_line *line[8];
	int offset = 16; // Replace with your GPIO pin number

	chip = gpiod_chip_open("/dev/gpiochip4"); // Replace 0 with the appropriate chip number

	if (!chip) {
		printf("Open chip failed");
		return 1;
	}

	for(int i=0; i<8; i++) {
		line[i] = gpiod_chip_get_line(chip, offset+i);

		if (!line[i]) {
			printf("Get line %d failed\n",offset+i);
			gpiod_chip_close(chip);
			return -1;
		}
		// Request the line for output
		if (gpiod_line_request_output(line[i], "example", 0) < 0) {
			printf("Request line %d as output failed\n",offset+i);
			gpiod_line_release(line[i]);
			gpiod_chip_close(chip);
			return -1;
		}
	}

	unsigned char value = 1;
	bool dir = true;
	while(1) {
		for(int i=0; i<8; i++) {
			int mask = 0x80>>i;
			gpiod_line_set_value(line[i], (value&mask) ? 1 :0 );
		}
		if(dir) {
			if( value != 0x80)
				value = value << 1;
			else {
				dir = false;
				value = value >> 1;
			}
		}
		else {
			if( value != 0x01)
				value = value >> 1;
			else {
				dir = true;
				value = value << 1;
			}
		}
		usleep(500000);
	}

	// Cleanup
	for( int i=0; i<8; i++)
		gpiod_line_release(line[i]);
		gpiod_chip_close(chip);

	return 0;
}
