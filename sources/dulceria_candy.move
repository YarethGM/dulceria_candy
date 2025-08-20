/// Módulo para la gestión de una dulcería en la blockchain de Sui.
module dulceria_candy::dulceria {

    // --- Imports Simplificados ---
    use sui::object;
    use sui::transfer;
    use sui::tx_context;
    use sui::coin;
    use sui::balance;
    use sui::sui;

    // --- Errores Personalizados ---
    const EPrecioIncorrecto: u64 = 1;

    // --- Objetos (Structs) ---

    public struct AdminCap has key, store {
        id: object::UID
    }

    public struct Producto has key, store {
        id: object::UID,
        nombre: vector<u8>,
        descripcion: vector<u8>,
        precio: u64
    }

    public struct Pedido has key, store {
        id: object::UID,
        producto_id: object::ID,
        nombre_producto: vector<u8>,
        pago: balance::Balance<sui::SUI>,
        comprador: address
    }

    // --- Funciones ---

    fun init(ctx: &mut tx_context::TxContext) {
        transfer::public_transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public entry fun agregar_producto(
        _admin_cap: &AdminCap,
        nombre: vector<u8>,
        descripcion: vector<u8>,
        precio: u64,
        ctx: &mut tx_context::TxContext
    ) {
        let producto = Producto {
            id: object::new(ctx),
            nombre,
            descripcion,
            precio
        };
        transfer::public_transfer(producto, tx_context::sender(ctx));
    }

    public entry fun comprar_producto(
        producto: Producto,
        pago: coin::Coin<sui::SUI>,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(coin::value(&pago) == producto.precio, EPrecioIncorrecto);
        let comprador = tx_context::sender(ctx);

        // *** ACCIÓN REQUERIDA ***
        // Reemplaza esta dirección con la tuya. El formato @0x... es el correcto.
        let admin_address: address = @0x0000000000000000000000000000000000000000000000000000000000000000;

        transfer::public_transfer(producto, comprador);
        transfer::public_transfer(pago, admin_address);
    }

    public entry fun realizar_pedido(
        producto: Producto, // El producto que se va a reservar
        deposito: coin::Coin<sui::SUI>,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(coin::value(&deposito) == producto.precio, EPrecioIncorrecto);

        let comprador = tx_context::sender(ctx);
        let producto_id = object::id(&producto);
        let nombre_producto = *&producto.nombre;

        let pedido = Pedido {
            id: object::new(ctx),
            producto_id,
            nombre_producto,
            pago: coin::into_balance(deposito),
            comprador
        };

        // Transferimos el recibo del pedido al comprador
        transfer::public_transfer(pedido, comprador);

        // *** CORRECCIÓN FINAL ***
        // Para borrar un objeto, primero lo desarmamos para obtener su 'id'.
        // Los otros campos (nombre, descripcion, precio) no los necesitamos aquí,
        // así que los ignoramos con el guion bajo '_'.
        let Producto { id, nombre: _, descripcion: _, precio: _ } = producto;

        // Ahora sí, llamamos a delete solo con el id, que es lo que espera la función.
        object::delete(id);
    }
}