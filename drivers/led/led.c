#include "led.h"
#include "stm32f407xx.h"

void LED_Init(void)
{
    RCC->AHB1ENR |= (1U << 3);

    GPIOD->MODER &= ~(3U << (15U * 2U));
    GPIOD->MODER |=  (1U << (15U * 2U));
}

void LED_On(void)
{
}

void LED_Off(void)
{
}