program pr2_ej16;
const
    valorAlto = 9999;
    //DF = 9;
    DF = 2;
type
    moto = record
        codigo: Integer;
        nombre: String[30];
        descripcion: String;
        modelo: String[30];
        marca: String[20];
        stock: Integer;
    end;

    info_moto = record
        codigo: Integer;
        precio: Real;
        fecha_venta: Integer;
    end;

    moto_destacada = record
        codigo: Integer;
        nombre: String[30];
        descripcion: String;
        modelo: String[30];
        marca: String[20];
        ventas: Integer;
    end;

    archivo_motos = file of moto;
    detalle_motos = file of info_moto;

    vector_detalles = array[0..DF] of detalle_motos;
    vector_reg_detalles = array[0..DF] of info_moto;

procedure asignarMaestro(var maestro: archivo_motos);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarDetalles(var detalles: vector_detalles);
var
    path, aux: String;
    i: Integer;
begin
    for i := 0 to DF do begin
        path := 'detalle_';
        Str(i, aux);
        path := path + aux;
        Assign(detalles[i], path);
    end;
end;

procedure leer(var detalle: detalle_motos; var reg_detalle: info_moto);
begin
    if(not Eof(detalle)) then Read(detalle, reg_detalle)
    else reg_detalle.codigo := valorAlto;
end;

procedure minimo(var detalles: vector_detalles; var reg_detalles: vector_reg_detalles; var regMin: info_moto);
var
    i, minPos: Integer;
begin
    regMin.codigo := valorAlto;

    for i := 0 to DF do begin
        if(reg_detalles[i].codigo < regMin.codigo) then begin
            regMin := reg_detalles[i];
            minPos := i;
        end;
    end;

    if(regMin.codigo <> valorAlto) then
        leer(detalles[minPos], reg_detalles[minPos]);
end;

procedure actualizarMaestroYCalcularMotoMasVendida(var maestro: archivo_motos; var detalles: vector_detalles; var maxMoto: moto_destacada);
var
    regM: moto;
    regMin: info_moto;
    reg_detalles: vector_reg_detalles;
    i, cantVentas: Integer;
begin
    Reset(maestro);
    for i := 0 to DF do begin
        Reset(detalles[i]);
        leer(detalles[i], reg_detalles[i]);
    end;

    maxMoto.ventas := -1;

    minimo(detalles, reg_detalles, regMin);

    while(regMin.codigo <> valorAlto) do begin
        Read(maestro, regM);
        while(regM.codigo <> regMin.codigo) do
            Read(maestro, regM);

        cantVentas := 0;
        while(regM.codigo = regMin.codigo) do begin
            //Se presupone que ventas <= stock para cada moto
            regM.stock := regM.stock - 1;
            cantVentas := cantVentas + 1;

            minimo(detalles, reg_detalles, regMin);
        end;

        if(cantVentas > maxMoto.ventas) then begin
            maxMoto.codigo := regM.codigo;
            maxMoto.nombre := regM.nombre;
            maxMoto.descripcion := regM.descripcion;
            maxMoto.modelo := regM.modelo;
            maxMoto.marca := regM.marca;
            maxMoto.ventas := cantVentas;
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;

    WriteLn('Actualizacion finalizada. Moto mas vendida procesada.');

    for i := DF downto 0 do
        Close(detalles[i]);
    Close(maestro);
end;

procedure imprimirMoto(reg: moto_destacada);
begin
    WriteLn('Codigo: ', reg.codigo);
    WriteLn('Nombre: ', reg.nombre);
    WriteLn('Descripcion: ', reg.descripcion);
    WriteLn('Modelo: ', reg.modelo);
    WriteLn('Marca: ', reg.marca);
    WriteLn('Ventas: ', reg.ventas);
end;

var
    maestro: archivo_motos;
    detalles: vector_detalles;
    moto_mas_vendida: moto_destacada;
begin
    asignarMaestro(maestro);
    asignarDetalles(detalles);

    WriteLn;

    actualizarMaestroYCalcularMotoMasVendida(maestro, detalles, moto_mas_vendida);

    WriteLn;
    
    WriteLn('Moto mas vendida: ');
    imprimirMoto(moto_mas_vendida);
end.