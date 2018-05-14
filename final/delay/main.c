#include <regx51.h>

void delay_ms(int ms) {
	while (ms--) {
		// 1000us
		TH0 = 0xfc;
		TL0 = 0x18;
		TR0 = 1;
		while (!TF0);
		TF0 = 0;
		TR0 = 0;
	}
}

// when interrupt is not enabled
void delay_s(int s) {
	s *= 20;
	while (s--) {
		// 50000us
		TH0 = 0x3C;
		TL0 = 0xB0;
		TR0 = 1;
		while (!TF0);
		TF0 = 0;
		TR0 = 0;
	}
}

void main() {
	P2 = 0xff;
	TMOD = 0x11;	 // 16 bit

	EX0 = 1;

	EA = 1;

	ET0 = 1;
	TR0 = 1;

	ET1 = 1;
	TR1 = 0;

	while(1) {
	}
}

unsigned long counter0 = 0;

void timer0() interrupt 1 {
	// 10ms
	TH0 = 0xd8;
	TL0 = 0xf0;
	counter0++;
}

unsigned int external0_counter = 0;

void timer1() interrupt 3 {
	TR1 = 0;
	if (external0_counter >= 30000)
		P2_1 = ~P2_1;
	else
		P2_0 = ~P2_0;

	external0_counter = 0;
}

void external0() interrupt 0 {
	external0_counter++;			 	
	// 20ms
	TH1 = 0xB1;
	TL1 = 0xE0;
	TR1 = 1;
}