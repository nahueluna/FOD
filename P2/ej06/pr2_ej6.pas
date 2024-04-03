program pr2_ej6;
const
    valorAlto = 9999;
    DF = 2;
type
    rFecha = record
        dia: 1..31;
        mes: 1..12;
        anio: Integer;
    end;

    sesion = record
        codigo_user: Integer;
        fecha: rFecha;
        tiempo: Integer;
    end;

    dimension_array = 0..DF;

    archivo_sesiones = file of sesion;

    vDetalles = array[dimension_array] of archivo_sesiones;
    vRegDetalles = array[dimension_array] of sesion;

procedure asignarDetalles(var vDet: vDetalles);
var
    path, aux: String;
    i: Integer;
begin
    for i := 0 to DF do begin
        path := 'detalle_';
        Str(i, aux);
        path := path + aux;
        Assign(vDet[i], path);
    end;
end;

procedure leer(var detalle: archivo_sesiones; var regD: sesion);
begin
    if(not Eof(detalle)) then Read(detalle, regD)
    else begin
        regD.codigo_user := valorAlto;
        regD.fecha.dia := 31;
        regD.fecha.mes := 12;
        regD.fecha.anio := valorAlto;
    end;
end;

procedure minimo(var detalles:vDetalles; var regDetalles: vRegDetalles; var regMin: sesion);
    function fechaMenor(fecha_minima, fecha_detalle: rFecha): boolean;
    var
        anioMenor, mesMenor, diaMenor: boolean;
    begin
        anioMenor := fecha_detalle.anio < fecha_minima.anio;
        mesMenor := (fecha_detalle.anio = fecha_minima.anio) and (fecha_detalle.mes < fecha_minima.mes);
        diaMenor := ((fecha_detalle.anio = fecha_minima.anio) and (fecha_detalle.mes = fecha_minima.mes)) and (fecha_detalle.dia < fecha_detalle.dia);
        
        fechaMenor := anioMenor or mesMenor or diaMenor;
    end;
var
    i, minPos: Integer;
begin
    regMin.codigo_user := valorAlto;
    regMin.fecha.dia := 31;
    regMin.fecha.mes := 12;
    regMin.fecha.anio := valorAlto;

    for i := 0 to DF do begin
        if(regDetalles[i].codigo_user < regMin.codigo_user) or ((regDetalles[i].codigo_user = regMin.codigo_user) and (fechaMenor(regMin.fecha, regDetalles[i].fecha))) then begin
            regMin := regDetalles[i];
            minPos := i;
        end;
    end;

    if(regMin.codigo_user <> valorAlto) then
        leer(detalles[minPos], regDetalles[minPos]);
end;

procedure generarArchivoMaestro(var maestro: archivo_sesiones; var detalles: vDetalles);
    function fechasIguales(fecha_minima, fecha_maestro: rFecha): boolean;
    begin
        fechasIguales := (fecha_minima.anio = fecha_maestro.anio) and (fecha_minima.mes = fecha_maestro.mes) and (fecha_minima.dia = fecha_maestro.dia);
    end;
var
    regDetalles: vRegDetalles;
    regMin, regM: sesion;
    i: Integer;
begin
    Rewrite(maestro);
    for i := 0 to DF do begin
        Reset(detalles[i]);
        leer(detalles[i], regDetalles[i]);
    end;

    minimo(detalles, regDetalles, regMin);

    while(regMin.codigo_user <> valorAlto) do begin
        regM.codigo_user := regMin.codigo_user;

        while(regMin.codigo_user = regM.codigo_user) do begin
            regM.fecha := regMin.fecha;
            regM.tiempo := 0;

            while(regMin.codigo_user = regM.codigo_user) and (fechasIguales(regMin.fecha, regM.fecha)) do begin
                regM.tiempo := regM.tiempo + regMin.tiempo;
                minimo(detalles, RegDetalles, regMin);
            end;

            Write(maestro, regM);
        end;
    end;

    for i:= DF downto 0 do
        Close(detalles[i]);
    Close(maestro);
end;

var
    archivo_maestro: archivo_sesiones;
    detalles: vDetalles;
begin
    Assign(archivo_maestro, './var/log/maestro_sesiones');
    asignarDetalles(detalles);

    generarArchivoMaestro(archivo_maestro, detalles);
end.