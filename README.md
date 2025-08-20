# Dulcería Sui - Proyecto de Certificación

¡Bienvenido al contrato inteligente de la Dulcería Sui! Este es un proyecto de backend puro desarrollado en el lenguaje de programación Move para la blockchain de Sui. El contrato simula la lógica de una tienda de dulces, permitiendo a un administrador gestionar productos y a los usuarios comprarlos o reservarlos usando SUI.

Este proyecto fue creado para cumplir con los requisitos de la certificación de desarrollador de Move en Sui, demostrando un uso práctico del modelo de objetos de Sui.

## ¿Cómo Funciona?

El contrato se basa en el modelo de objetos de Sui, donde cada elemento principal es un objeto único en la blockchain con su propio ID y propietario.

### Objetos Principales

* **`AdminCap` (Capacidad de Administrador):** Un objeto único que funciona como la "llave" de la tienda. Solo el propietario de este objeto puede ejecutar funciones administrativas, como agregar nuevos productos. Se crea una sola vez al desplegar el contrato.
* **`Producto`:** Cada dulce en la tienda es un objeto individual (similar a un NFT). Contiene información como su nombre, descripción y precio en MIST (la unidad más pequeña de SUI).
* **`Pedido`:** Un objeto que actúa como un recibo de reserva. Se crea cuando un usuario realiza un pedido, guardando de forma segura el pago del usuario y la información del producto reservado.

### Funcionalidades

1.  **Agregar Productos:** El administrador de la tienda, usando su `AdminCap`, puede crear nuevos objetos `Producto` y ponerlos a la venta.
2.  **Comprar Productos:** Cualquier usuario puede comprar un `Producto` transfiriendo su propiedad a cambio de una `Coin` de SUI con el valor exacto del precio.
3.  **Realizar Pedidos:** Un usuario puede reservar un producto. En esta acción, el objeto `Producto` se consume (destruye) y se genera un objeto `Pedido` que se entrega al usuario como comprobante de su reserva y pago.

## Prerrequisitos

Para interactuar con este proyecto, necesitarás tener instalado:

* [Sui CLI](https://docs.sui.io/guides/developer/getting-started/sui-install)

## Instalación y Uso

A continuación se detallan los pasos para compilar, desplegar e interactuar con el contrato en la red de pruebas (Testnet).

### 1. Compilación

Primero, clona este repositorio y compila el proyecto para asegurarte de que no hay errores.

```bash
# Clona el repositorio (ejemplo)
git clone [https://github.com/](https://github.com/)[tu-usuario]/dulceria_candy.git
cd dulceria_candy

# Compila el código Move
sui move build

2. Despliegue en Testnet
Antes de interactuar, necesitas publicar el contrato en la Testnet.

# 1. Asegúrate de estar en el entorno de Testnet
sui client switch --env testnet

# 2. Si no tienes SUI de prueba, solicítalos en el Faucet web
# Ve a: [https://faucet.sui.io/?address=$(sui](https://faucet.sui.io/?address=$(sui) client active-address)

# 3. Publica el contrato
sui client publish --gas-budget 100000000

¡IMPORTANTE! Guarda la salida de este comando. Necesitarás el Package ID y el AdminCap ID para los siguientes pasos.

3. Interactuando con el Contrato
A. Agregar un Producto (Rol: Administrador)
Usa tu AdminCap ID para crear un nuevo producto.

sui client call \
  --package <PACKAGE_ID> \
  --module dulceria \
  --function agregar_producto \
  --args <ADMIN_CAP_ID> "Nombre del Dulce" "Descripción del Dulce" <PRECIO_EN_MIST> \
  --gas-budget 10000000

Reemplaza <PACKAGE_ID> y <ADMIN_CAP_ID>.

El precio se indica en MIST (1 SUI = 1,000,000,000 MIST).

Guarda el ObjectID del nuevo Producto creado.

B. Comprar un Producto (Rol: Usuario)
Para comprar, necesitas el ID del producto y una moneda para pagar.

# 1. Obtén el ID de una de tus monedas
sui client gas

# 2. Llama a la función de compra
sui client call \
  --package <PACKAGE_ID> \
  --module dulceria \
  --function comprar_producto \
  --args <ID_DEL_PRODUCTO> <ID_DE_LA_MONEDA_PARA_PAGO> \
  --gas-budget 10000000

C. Realizar un Pedido (Rol: Usuario)
Esta función requiere una moneda con el valor exacto del producto.

# 1. Si no tienes una moneda con el valor exacto, crea una dividiendo una más grande.
# Por ejemplo, para crear una moneda de 150,000,000 MIST:
sui client split-coin --coin-id <ID_MONEDA_GRANDE> --amounts 150000000 --gas-budget 10000000

# 2. Guarda el ID de la nueva moneda creada.

# 3. Llama a la función para realizar el pedido
sui client call \
  --package <PACKAGE_ID> \
  --module dulceria \
  --function realizar_pedido \
  --args <ID_DEL_PRODUCTO_A_PEDIR> <ID_DE_LA_NUEVA_MONEDA> \
  --gas-budget 10000000
