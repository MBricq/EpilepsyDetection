#include <stdio.h>
#include <stdbool.h>
#include <inttypes.h>
#include <stdlib.h>

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_up_avalon_rs232.h"

#define NUM_DATA_TO_ADD 2

void disp_7segments(uint16_t val) {
	uint8_t digit0 = val % 10;
	uint8_t digit1 = (val / 10) % 10;
	uint8_t digit2 = val / 100;

	IOWR_8DIRECT(FULL_DISPLAY_0_BASE, 1, digit0);
	IOWR_8DIRECT(FULL_DISPLAY_0_BASE, 2, digit1);
	IOWR_8DIRECT(FULL_DISPLAY_0_BASE, 3, digit2);
}

int64_t convert43To64(int64_t number43Bit) {
    // Check the sign bit (bit 42)
    int sign = (number43Bit >> 42) & 1;

    // Extend the sign if necessary
    int64_t number64Bit = number43Bit;
    if (sign == 1) {
        number64Bit |= (int64_t)0xFFFFFFF800000000;  // Sign extension
    }

    return number64Bit;
}

int main()
{
	printf("Hello from Nios II!\n");

	// Enable the digits display
	IOWR_8DIRECT(FULL_DISPLAY_0_BASE, 0, 1);

	// Open the RS-232 communication
	alt_up_rs232_dev* rs232_device = alt_up_rs232_open_dev(RS232_0_NAME);

	/*
	bool leds_on = false;
	uint8_t* data_read = (uint8_t *)malloc(sizeof(uint8_t));
	uint8_t last_data_received[NUM_DATA_TO_ADD] = {0, 0};
	uint8_t index = 0;
	uint16_t sum = 0;

	int64_t tmp = 0b1111111111111111111111111111011000000000000;

	tmp = convert43To64(tmp);

	printf("64-bit number: %lld.\n", (tmp>>12));
	*/

	uint8_t counter = 0;

	while(1) {

		printf("Counter = %u", counter);

		alt_up_rs232_write_data(rs232_device, counter);

		counter++;

		for (int i = 0; i < 5000000; i++) {
			asm("NOP");
		}

		/*
		unsigned num_data_to_red = alt_up_rs232_get_used_space_in_read_FIFO(rs232_device);

		if (num_data_to_red > 0) {
			if(alt_up_rs232_read_data(rs232_device, data_read, NULL) != 0) {
				printf("Error while reading data\n");
				leds_on = false;
			} else {
				printf("Data read: %u\n", *data_read);
				last_data_received[index] = *data_read;
				index = (index + 1) % NUM_DATA_TO_ADD;
				leds_on = true;
			}
		}

		if (leds_on) {
			IOWR_8DIRECT(LEDS_BASE, 0, *data_read);

			sum = 0;
			for (int i = 0; i < NUM_DATA_TO_ADD; i++) {
				sum = sum + last_data_received[i];
			}

			disp_7segments(sum);
		} else {
			IOWR_8DIRECT(LEDS_BASE, 0, 0);
		}

		counter = counter + 1;
		if (counter == 500000) {
			counter = 0;
			alt_up_rs232_write_data(rs232_device, sum);
		}
		*/

	}


	//free(data_read);
	return 0;
}
