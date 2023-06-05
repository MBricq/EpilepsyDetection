#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdlib.h>

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_up_avalon_rs232.h"

#include "fifo.h"

#define AVERAGE_WINDOW_SIZE 4

// Define addresses of interface (for registers with two addresses, we define here the LSB one)
// (MSB being the same + 1)
// Note: addresses from 0 to 511 are for the samples
#define START_ADDR 512
#define STOP_ADDR 513
#define FINISHED_ADDR 514
#define RESULT_ADDR 515
#define BIAS_ADDR 517
#define SCALE_ADDR 519
#define BETA_ENE_D2_ADDR 521
#define MU_ENE_D2_ADDR 523
#define SIGMA_ENE_D2_ADDR 525
#define BETA_ENE_S_ADDR 527
#define MU_ENE_S_ADDR 529
#define SIGMA_ENE_S_ADDR 531


// Enum for the different states of the system
typedef enum {
    INIT,
    WAIT_VAL,
    SEND_VAL,
    WAIT_DONE,
    SEND_OUT
} state_t;

// Function to convert the output 43-bit value to a 64-bit signed integer
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


int main(void) {
    // Array to store last 4 values (type: int64_t) for averaging
    int64_t last_values[AVERAGE_WINDOW_SIZE] = {0, 0, 0, 0};
    // Index of the last value in the array
    int last_value_index = 0;
    int64_t average = 0;

    // Current state of the system
    state_t state = INIT;
    uint32_t has_done = 0;

    // Initialize the FIFO
    fifo_t fifo;
    fifo_init(&fifo);

    // Open the RS-232 communication
	alt_up_rs232_dev* rs232_device = alt_up_rs232_open_dev(RS232_0_NAME);
    // Create a pointer where received data will be stored
    uint8_t* data = (uint8_t*)malloc(sizeof(uint8_t));

    // SVM parameters
    const uint32_t scale_msb = 0b0000000000;
    const uint32_t scale_lsb = 0b00000000000000000000000001000111;
    const uint32_t bias_msb = 0b1111111111;
    const uint32_t bias_lsb = 0b11111111111111111111100111110101;
    const uint32_t betas_msb[2] = {0b1111111111, 0b0000000000};
    const uint32_t betas_lsb[2] = {0b11111111111111111111111000010000, 0b00000000000000000000000000110000};
    const uint32_t mus_msb[2] = {0b0000000000, 0b0000000000};
    const uint32_t mus_lsb[2] = {0b00000000000001001110000101010111, 0b00000000000011110011110010110101};
    const uint32_t sigmas_msb[2] = {0b0000000000, 0b0000000000};
    const uint32_t sigmas_lsb[2] = {0b00000000000010101111011101000100, 0b00000000000101101110011001010011};


    // Turns out the RS-232 FIFO can keep values between run, needs to be cleared
    while(alt_up_rs232_get_used_space_in_read_FIFO(rs232_device) > 0) {
    	alt_up_rs232_read_data(rs232_device, NULL, NULL);
    }

    // FSM loop
    while (1) {
        switch (state)
        {
        case INIT:

            // Send order of stopping predictor and then stop back to 0, to reset the predictor
        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * STOP_ADDR, 1);
        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * STOP_ADDR, 0);

            // Send SVMs to the predictor
        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * BIAS_ADDR, bias_lsb);
        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (BIAS_ADDR + 1), bias_msb);

        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * SCALE_ADDR, scale_lsb);
        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (SCALE_ADDR + 1), scale_msb);

        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * BETA_ENE_D2_ADDR, betas_lsb[0]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (BETA_ENE_D2_ADDR + 1), betas_msb[0]);

        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * MU_ENE_D2_ADDR, mus_lsb[0]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (MU_ENE_D2_ADDR + 1), mus_msb[0]);

        	IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * SIGMA_ENE_D2_ADDR, sigmas_lsb[0]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (SIGMA_ENE_D2_ADDR + 1), sigmas_msb[0]);


			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * BETA_ENE_S_ADDR, betas_lsb[1]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (BETA_ENE_S_ADDR + 1), betas_msb[1]);

			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * MU_ENE_S_ADDR, mus_lsb[1]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (MU_ENE_S_ADDR + 1), mus_msb[1]);

			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * SIGMA_ENE_S_ADDR, sigmas_lsb[1]);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (SIGMA_ENE_S_ADDR + 1), sigmas_msb[1]);

            // Turn on a LED to indicate that the system is ready to receive data
			IOWR_8DIRECT(LEDS_BASE, 0, 0xFF);

            // Go to wait for value state
            state = WAIT_VAL;

            printf("Init done, wait for vals\n");

            break;

        case WAIT_VAL:
            // Check if there is 2 values in the RS-232 FIFO (LSB and MSB)
            if (alt_up_rs232_get_used_space_in_read_FIFO(rs232_device) >= 2) {
                // Read the 2 bytes from the RS-232 FIFO
                alt_up_rs232_read_data(rs232_device, data, NULL);
                uint8_t lsb = *data;
                alt_up_rs232_read_data(rs232_device, data, NULL);
                uint8_t msb = *data;

                // Convert the 2 bytes to a 16-bit value
                uint16_t value = (msb << 8) | lsb;

                // Write the value to the FIFO
                fifo_write(&fifo, value);

                // If we stored 512 values in the FIFO, go to send value state
                if (fifo_num_elements(&fifo) >= 512) {
					state = SEND_VAL;
					printf("Received 512 vals\n");
                }
            }
            break;

        case SEND_VAL:
            // Writes each of the 512 values to the predictor
            for (int i = 0; i < 512; i++) {
                // Read the next value from the FIFO
                uint16_t value = fifo_read(&fifo);

                // Write the value to the predictor (the addresses are 0 to 511 * 4 due to 32 bits)
                IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * i, (uint32_t) value);
            }

            // Send order of starting predictor
            IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * START_ADDR, 1);

            // Go to wait for done state
            state = WAIT_DONE;
            printf("Sent vals to pred, wait for done\n");

            // Disable start signal to predictor
            IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * START_ADDR, 0);

            break;

        case WAIT_DONE:

            // Poll the done register of the predictor until it is 1
        	has_done = IORD_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * FINISHED_ADDR);
            if (has_done == 1) {

                // Read the output value from the predictor, needs two 32-bit reads
                uint32_t lsb = IORD_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * RESULT_ADDR);
                uint64_t msb = (uint64_t) IORD_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * (RESULT_ADDR + 1));

                // Convert the 64-bit value to a 64-bit signed integer
                int64_t value = convert43To64((msb << 32) | lsb);

                // Store the value in the array
                last_values[last_value_index] = value;
                last_value_index = (last_value_index + 1) % AVERAGE_WINDOW_SIZE;

                printf("Done\n");

                // Go to send out state
                state = SEND_OUT;
            }

            break;

        case SEND_OUT:
            // Compute the average of the last 4 values
            average = 0;
            for (int i = 0; i < AVERAGE_WINDOW_SIZE; i++) {
                average += last_values[i];
            }
            average /= AVERAGE_WINDOW_SIZE;

            // Compute sign of the average
            uint8_t sign = 0;
            if (average < 0) {
                sign = 1;
            }

            // Send the average to the computer
            alt_up_rs232_write_data(rs232_device, sign);

            // Send stop order to predictor and then stop to 0, to reset the predictor
            IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * STOP_ADDR, 1);
			IOWR_32DIRECT(ID2_PREDICTOR_INTERFACE_0_BASE, 4 * STOP_ADDR, 0);

			printf("Output sent\n");

			state = WAIT_VAL;

            break;

        default:
            break;
        }
    }

    return 0;
}
