program pr2_ej8;
const
    valorAlto = 9999;
type
    rCliente = record
        codigo: Integer;
        nombre: String[25];
        apellido: String[25];
    end;

    venta = record
        cliente: rCliente;
        anio: Integer;
        mes: 1..12;
        dia: 1..31;
        monto: Real;
    end;

    archivo_venta = file of venta;

procedure asignar(var maestro: archivo_venta);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure leer(var maestro: archivo_venta; var regM: venta);
begin
    if(not Eof(maestro)) then Read(maestro, regM)
    else regM.cliente.codigo := valorAlto;
end;

procedure reporteVentas(var maestro: archivo_venta);
var
    regM: venta;
    ventaMes, ventaAnio, ventaTotal: Real; 
    codActual, anioActual, mesActual: Integer; 
begin
    Reset(maestro);

    ventaTotal := 0;
    leer(maestro, regM);

    while(regM.cliente.codigo <> valorAlto) do begin
        codActual := regM.cliente.codigo;

        WriteLn('Cliente nro ', codActual);
        WriteLn('Nombre: ', regM.cliente.nombre, ' - Apellido: ', regM.cliente.apellido);
        WriteLn('=>');
        
        while(codActual = regM.cliente.codigo) do begin
            ventaAnio := 0;
            anioActual := regM.anio;
            
            while(codActual = regM.cliente.codigo) and (anioActual = regM.anio) do begin
                ventaMes := 0;
                mesActual := regM.mes;

                while(codActual = regM.cliente.codigo) and (anioActual = regM.anio) and (mesActual = regM.mes) do begin
                    ventaMes := ventaMes + regM.monto;
                    leer(maestro, regM);
                end;

                WriteLn('Mes: ', mesActual, ' - Monto: $', ventaMes:0:2);
                ventaAnio := ventaAnio + ventaMes;
            end;

            WriteLn('Anio: ', anioActual, ' - Monto: $', ventaAnio:0:2);
            WriteLn;
            ventaTotal := ventaTotal + ventaAnio;
        end;
    end;

    WriteLn('---------------------');
    WriteLn('Total recaudado por la empresa: $', ventaTotal:0:2);

    Close(maestro);
end;

procedure leerArchivo(var archivo: archivo_venta);
    procedure leerRegistro(var reg: venta);
    begin
        Write('Codigo cliente: '); ReadLn(reg.cliente.codigo);
        if(reg.cliente.codigo <> 0) then begin
            Write('Nombre: '); ReadLn(reg.cliente.nombre);
            Write('Apellido: '); ReadLn(reg.cliente.apellido);
            Write('Anio: '); ReadLn(reg.anio);
            Write('Mes: '); ReadLn(reg.mes);
            Write('Dia: '); ReadLn(reg.dia);
            Write('Monto: '); ReadLn(reg.monto);
        end;
        WriteLn;
    end;
var
    reg: venta;
begin
    Rewrite(archivo);

    leerRegistro(reg);
    while(reg.cliente.codigo <> 0) do begin
        Write(archivo, reg);
        leerRegistro(reg);
    end;

    WriteLn;
    WriteLn;

    Close(archivo);
end;

var
    archivo_maestro: archivo_venta;
begin
    asignar(archivo_maestro);

    //leerArchivo(archivo_maestro);

    WriteLn;

    reporteVentas(archivo_maestro);
end.