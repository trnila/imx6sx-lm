#include "linux/include/dt-bindings/pinctrl/omap.h"
#include "linux/include/dt-bindings/pinctrl/am33xx.h"
int main() {
AM33XX_PADCONF(AM335X_PIN_GPMC_WPN, PIN_OUTPUT, MUX_MODE6)
AM33XX_PADCONF(AM335X_PIN_GPMC_WAIT0, PIN_INPUT, MUX_MODE6)

}
