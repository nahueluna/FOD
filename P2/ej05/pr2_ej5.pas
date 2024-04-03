program pr2_ej5;
const
    valorAlto = 9999;
    DF = 30;
type
    producto = record
        codigo: Integer;
        nombre: String;
        descripcion: String;
        stock_disponible: Integer;
        stock_minimo: Integer;
        precio: Real;
    end;

    info_producto = record
        codigo: Integer;
        cantidad_vendida: Integer;
    end;

    dimension_array = 0..DF;

    archivo_productos = file of producto;
    detalle_productos = file of info_producto;

    vArchivo_detalles = array[dimension_array] of detalle_productos;
    vRegistro_detalles = array[dimension_array] of info_producto;

procedure asignarMaestro(var maestro: archivo_productos);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarDetalle(var detalles: vArchivo_detalles);
var
    path, aux: String;
    i: integer;
begin
    for i := 0 to DF do begin
        path := 'detalle_productos_';
        Str(i, aux);
        path := path + aux;
        Assign(detalles[i], path);
    end;
end;

procedure leer(var detalle: detalle_productos; var regD: info_producto);
begin
    if(not Eof(detalle)) then Read(detalle, regD)
    else regD.codigo := valorAlto;
end;

procedure minimo(var detalles: vArchivo_detalles; var regDetalles: vRegistro_detalles; var regMin: info_producto);
var
    i, minPos: Integer;
begin
    regMin.codigo := valorAlto;
    for i:= 0 to DF do begin
        if(regDetalles[i].codigo < regMin.codigo) then begin
            regMin := regDetalles[i];
            minPos := i
        end;
    end;

    if(regMin.codigo <> valorAlto) then
        leer(detalles[minPos], regDetalles[minPos]);

end;

procedure exportarTexto(var texto: Text; regM: producto);
begin
    with regM do begin
        WriteLn(texto, nombre);
        WriteLn(texto, descripcion);
        WriteLn(texto, stock_disponible, ' ', precio);
    end;
end;

procedure procesarArchivos(var maestro: archivo_productos; var vDetalles: vArchivo_detalles; var producto_texto: Text);
var
    vRegD: vRegistro_detalles;
    regMin: info_producto;
    regM: producto;
    i: Integer;
begin
    Rewrite(producto_texto);
    Reset(maestro);
    for i := 0 to DF do begin
        Reset(vDetalles[i]);
        leer(vDetalles[i], vRegD[i]);
    end;
    minimo(vDetalles, vRegD, regMin);

    while(regMin.codigo <> valorAlto) do begin
        Read(maestro, regM);

        while(regMin.codigo <> regM.codigo) do
            Read(maestro, regM);

        while(regMin.codigo = regM.codigo) do begin
            regM.stock_disponible := regM.stock_disponible - regMin.cantidad_vendida;
            minimo(vDetalles, vRegD, regMin);
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);

        if(regM.stock_disponible < regM.stock_minimo) then
            exportarTexto(producto_texto, regM);
    end;
    
    for i := DF downto 0 do
        Close(vDetalles[i]);
    Close(maestro);
    Close(producto_texto);

end;

var
    archivo_maestro: archivo_productos;
    archivos_detalle: vArchivo_detalles;
    producto_texto: Text;
begin
    asignarMaestro(archivo_maestro);
    asignarDetalle(archivos_detalle);
        Assign(producto_texto, 'productos_stock_bajo.txt');

    procesarArchivos(archivo_maestro, archivos_detalle, producto_texto);
end.