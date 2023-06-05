#include "fifo.h"

// Initialize the FIFO
void fifo_init(fifo_t *fifo) {
    fifo->head = 0;
    fifo->tail = 0;
}

// Check if the FIFO is empty
bool fifo_empty(fifo_t *fifo) {
    return fifo->head == fifo->tail;
}

// Check if the FIFO is full
bool fifo_is_full(fifo_t *fifo) {
    return (fifo->head + 1) % FIFO_SIZE == fifo->tail;
}

// Read the next value from the FIFO
uint16_t fifo_read(fifo_t *fifo) {
    uint16_t data = fifo->buffer[fifo->tail];
    fifo->tail = (fifo->tail + 1) % FIFO_SIZE;
    return data;
}

// Write a value to the FIFO
void fifo_write(fifo_t *fifo, uint16_t data) {
    fifo->buffer[fifo->head] = data;
    fifo->head = (fifo->head + 1) % FIFO_SIZE;
}

// Get the number of elements in the FIFO
uint16_t fifo_num_elements(fifo_t *fifo) {
    return (fifo->head - fifo->tail + FIFO_SIZE) % FIFO_SIZE;
}
