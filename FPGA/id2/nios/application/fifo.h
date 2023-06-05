#ifndef FIFO_H
#define FIFO_H

#include <stdint.h>
#include <stdbool.h>

#define FIFO_SIZE 1024

typedef struct {
    uint16_t buffer[FIFO_SIZE];
    uint16_t head;
    uint16_t tail;
} fifo_t;

void fifo_init(fifo_t *fifo);

bool fifo_is_empty(fifo_t *fifo);

bool fifo_is_full(fifo_t *fifo);

uint16_t fifo_read(fifo_t *fifo);

void fifo_write(fifo_t *fifo, uint16_t data);

uint16_t fifo_num_elements(fifo_t *fifo);

#endif // FIFO_H
