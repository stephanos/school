/**********************************
 * © Stephan Behnke
 * Homepage: www.tcltk.de.vu
 * E-Mail: stephan.behnke@gmx.net
 **********************************/

#include <stdio.h>


/* Variablen für Zahlen */
short z1, z2;

/* Externe Assembler-Routine */
extern short aeg_mult(void);


/*------------------------------------------------------------------------------
 Hauptfunktion
------------------------------------------------------------------------------*/
int main(int argc, char** argv)
{
    short p = 0;

    /* Zahlen abfragen */
    printf("Berechnung des Produktes zweier Zahlen:\nZahl 1: ");
    scanf("%i", &z1);

    printf("Zahl 2: ");
    scanf("%i", &z2);

    /* Produkt ausrechnen und ausgeben */
    p = aeg_mult();
	printf("\n -> %i * %i = %i\n", z1, z2, p);

	#ifdef WIN32
	scanf("%i", &p);
	#endif

	return 0;
}
