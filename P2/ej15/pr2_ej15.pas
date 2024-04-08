program pr2_ej15;
const
    valorAlto = 9999;
    DF = 99;
type
    semanario = record
        fecha: Integer;
        codigo: Integer;
        nombre: String[50];
        descripcion: String;
        precio: Real;
        stock: Integer;
        ventas: Integer;
    end;

    info_semanario = record
        fecha: Integer;
        codigo: Integer;
        ventas: Integer;
    end;

    semanario_destacado = record
        fecha: Integer;
        codigo: Integer;
        nombre: String[50];
        ventas: Integer;
    end;

    archivo_semanario = file of semanario;
    detalle_semanario = file of info_semanario;

    vector_detalles = array[0..DF] of detalle_semanario;
    vector_reg_detalles = array[0..DF] of info_semanario;

procedure asignarMaestro(var maestro: archivo_semanario);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo maestro: ');
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

procedure leer(var detalle: detalle_semanario; var reg_detalle: info_semanario);
begin
    if(not Eof(detalle)) then Read(detalle, reg_detalle)
    else begin
        reg_detalle.fecha := valorAlto;
        reg_detalle.codigo := valorAlto;
    end;
end;

function evaluarMinimo(reg_detalle, regMin: info_semanario): Boolean;
    var
        fechaMenor, codigoMenor: Boolean;
    begin
        fechaMenor := (reg_detalle.fecha < regMin.fecha);
        codigoMenor := (reg_detalle.fecha = regMin.fecha) and (reg_detalle.codigo < regMin.codigo);

        evaluarMinimo := fechaMenor or codigoMenor;
    end;

procedure minimo(var detalles: vector_detalles; var reg_detalles: vector_reg_detalles; var regMin: info_semanario);
var
    i, minPos: Integer;
begin
    regMin.fecha := valorAlto;
    regMin.codigo := valorAlto;

    for i := 0 to DF do begin
        if(evaluarMinimo(reg_detalles[i], regMin)) then begin
            regMin := reg_detalles[i];
            minPos := i;
        end;
    end;

    if(regMin.fecha <> valorAlto) then
        leer(detalles[minPos], reg_detalles[minPos]);
end;

procedure actualizarMaestroYProcesarVentas(var maestro: archivo_semanario; var detalles: vector_detalles; var minVentas, maxVentas: semanario_destacado);
var
    regMin: info_semanario;
    regM: semanario;
    reg_detalles: vector_reg_detalles;
    i: Integer;
begin
    Reset(maestro);
    for i := 0 to DF do begin
        Reset(detalles[i]);
        leer(detalles[i], reg_detalles[i]);
    end;

    maxVentas.ventas := -1;
    minVentas.ventas := 9999;

    minimo(detalles, reg_detalles, regMin);

    while(not Eof(maestro)) do begin
        Read(maestro, regM);

        if(regM.fecha = regMin.fecha) and (regM.codigo = regMin.codigo) then begin
            while((regM.fecha = regMin.fecha) and (regM.codigo = regMin.codigo)) do begin
                regM.stock := regM.stock - regMin.ventas;
                regM.ventas := regM.ventas + regMin.ventas;

                minimo(detalles, reg_detalles, regMin);
            end;

            Seek(maestro, FilePos(maestro) - 1);
            Write(maestro, regM);
        end;

        if(regM.ventas > maxVentas.ventas) then begin
            maxVentas.fecha := regM.fecha;
            maxVentas.codigo := regM.codigo;
            maxVentas.nombre := regM.nombre;
            maxVentas.ventas := regM.ventas;
        end;
        
        if(regM.ventas < minVentas.ventas) then begin
            minVentas.fecha := regM.fecha;
            minVentas.codigo := regM.codigo;
            minVentas.nombre := regM.nombre;
            minVentas.ventas := regM.ventas;
        end;
    end;

    WriteLn('Actualizacion finalizada. Semanarios con ventas maximas y minimas procesados.');

    for i := DF downto 0 do
        Close(detalles[i]);
    Close(maestro);
end;

var
    maestro: archivo_semanario;
    detalles: vector_detalles;
    semanario_minimo, semanario_maximo: semanario_destacado;
begin
    asignarMaestro(maestro);
    asignarDetalles(detalles);

    WriteLn;

    actualizarMaestroYProcesarVentas(maestro, detalles, semanario_minimo, semanario_maximo);

    WriteLn;

    WriteLn('Semanario con mayor ventas:');
    WriteLn('Fecha: ', semanario_maximo.fecha);
    WriteLn(semanario_maximo.codigo,#9,semanario_maximo.nombre);

    WriteLn;

    WriteLn('Semanario con menor ventas:');
    WriteLn('Fecha: ', semanario_minimo.fecha);
    WriteLn(semanario_minimo.codigo,#9,semanario_minimo.nombre);
end.