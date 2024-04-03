program pr2_ej3;
const
    valorAlto = '9999';
type
    producto = record
        codigo: String[10];
        nombre: String[30];
        precio: Real;
        stock_actual: Integer;
        stock_minimo: Integer;
    end;

    venta = record
        codigo_producto: String[10];
        cantidad: Integer;
    end;

    archivo_productos = file of producto;
    detalle_ventas = file of venta;

procedure asignarMaestro(var archivo: archivo_productos);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo maestro: ');
    ReadLn(path);

    Assign(archivo, path);
end;

procedure asignarDetalle(var archivo: detalle_ventas);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo detalle: ');
    ReadLn(path);

    Assign(archivo, path);
end;

procedure leer(var archivo: detalle_ventas; var regDetalle: venta);
begin
    if(not Eof(archivo)) then Read(archivo, regDetalle)
    else regDetalle.codigo_producto := valorAlto;
end;

procedure actualizarMaestro(var maestro: archivo_productos; var detalle: detalle_ventas);
var
    codigoActual: String[10];
    regM: producto;
    regD: venta;
    totalVenta: Integer;
begin
    Reset(maestro);
    Reset(detalle);

    leer(detalle, regD);
    Read(maestro, regM);

    while(regD.codigo_producto <> valorAlto) do begin
        codigoActual := regD.codigo_producto;
        totalVenta := 0;

        while(codigoActual = regD.codigo_producto) do begin
            totalVenta := totalVenta + regD.cantidad;
            leer(detalle, regD);
        end;

        while(codigoActual <> regM.codigo) do
            Read(maestro, regM);
        
        regM.stock_actual:= regM.stock_actual - totalVenta;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;

    Close(detalle);
    Close(maestro);
end;

procedure generarArchivoTexto(var maestro: archivo_productos; var texto_stock: Text);
var
    regProducto: producto;
begin
    Assign(texto_stock, 'productos_stock_bajo.txt');
    
    Rewrite(texto_stock);
    Reset(maestro);

    while(not Eof(maestro)) do begin
        Read(maestro, regProducto);
        
        with regProducto do begin
            if(stock_actual < stock_minimo) then begin
                WriteLn(texto_stock, codigo);
                WriteLn(texto_stock, nombre);
                WriteLn(texto_stock, precio, ' ', stock_actual, ' ', stock_minimo);
            end;
        end;
    end;
    
    Close(maestro);
    Close(texto_stock);
end;

procedure callMenu(var maestro: archivo_productos; var detalle: detalle_ventas);
var
    opcion: Integer;
    productos_stock: Text;
begin
    WriteLn('Menu archivo de productos y ventas');
    WriteLn('Elija una de las siguientes opciones: ');
    WriteLn('1- Actualizar archivo maestro');
    WriteLn('2- Exportar a texto productos con stock por debajo del minimo');
    WriteLn('3- Salir');

    Write('=> ');
    ReadLn(opcion);

    while(opcion <> 3) do begin

        case opcion of

            1: actualizarMaestro(maestro, detalle);

            2: generarArchivoTexto(maestro, productos_stock);

            else
                WriteLn('La opcion ingresada no es valida');
        
        end;

        Write('=> ');
        ReadLn(opcion);
    end;
end;

var
    archivo_maestro: archivo_productos;
    archivo_detalle: detalle_ventas;
begin
    asignarMaestro(archivo_maestro);
    asignarDetalle(archivo_detalle);

    callMenu(archivo_maestro, archivo_detalle);
end.