program pr2_ej14;
const
    valorAlto = 9999;
    DF = 10;
type
    vivienda = record
        cod_provincia: Integer;
        nom_provincia: String[40];
        cod_localidad: Integer;
        nom_localidad: String[40];
        cant_sin_luz: Integer;
        cant_sin_gas: Integer;
        cant_de_chapa: Integer;
        cant_sin_agua: Integer;
        cant_sin_sanitarios: Integer;
    end;

    info_vivienda = record
        cod_provincia: Integer;
        cod_localidad: Integer;
        cant_con_luz: Integer;
        cant_con_gas: Integer;
        cant_construidas: Integer;
        cant_con_agua: Integer;
        cant_sanitarios: Integer;
    end;

    archivo_viviendas = file of vivienda;
    detalle_viviendas = file of info_vivienda;

    vector_detalles = array[0..DF] of detalle_viviendas;
    vector_reg_detalles = array[0..DF] of info_vivienda;

procedure asignarMaestro(var maestro: archivo_viviendas);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarDetalles(var detalles: vector_detalles);
var
    i: Integer;
    path, aux: String;
begin
    for i := 0 to DF do begin
        path := 'detalle_';
        Str(i, aux);
        path := path + aux;
        Assign(detalles[i], path);
    end;
end;

procedure leer(var detalle: detalle_viviendas; var reg_detalle: info_vivienda);
begin
    if(not Eof(detalle)) then Read(detalle, reg_detalle)
    else begin
        reg_detalle.cod_provincia := valorAlto;
        reg_detalle.cod_localidad := valorAlto;
    end;
end;

procedure minimo(var detalles: vector_detalles; var reg_detalles: vector_reg_detalles; var regMin: info_vivienda);
    function evaluarMinimo(reg_detalle, regMin: info_vivienda): Boolean;
    var
        provinciaMenor, localidadMenor: Boolean;
    begin
        provinciaMenor := (reg_detalle.cod_provincia < regMin.cod_provincia);
        localidadMenor := (reg_detalle.cod_provincia = regMin.cod_provincia) and (reg_detalle.cod_localidad < regMin.cod_localidad);

        evaluarMinimo := provinciaMenor or localidadMenor;
    end;

var
    i, minPos: Integer;
begin
    regMin.cod_provincia := valorAlto;
    regMin.cod_localidad := valorAlto;

    for i:= 0 to DF do begin
        if(evaluarMinimo(reg_detalles[i], regMin)) then begin
            regMin := reg_detalles[i];
            minPos := i;
        end;
    end;

    if(regMin.cod_provincia <> valorAlto) then
        leer(detalles[minPos], reg_detalles[minPos]);
end;

procedure actualizarMaestro(var maestro: archivo_viviendas; var detalles: vector_detalles);
var
    reg_detalles: vector_reg_detalles;
    regM: vivienda;
    regMin: info_vivienda;
    i: Integer;
begin
    Reset(maestro);
    for i:= 0 to DF do begin
        Reset(detalles[i]);
        leer(detalles[i], reg_detalles[i]);
    end;

    minimo(detalles, reg_detalles, regMin);

    while(regMin.cod_provincia <> valorAlto) do begin
        Read(maestro, regM);
        while(regM.cod_provincia <> regMin.cod_provincia) and (regM.cod_localidad <> regMin.cod_localidad) do
            Read(maestro, regM);

        //Precondicion misma combinacion de provincia y localidad como maximo una vez
        regM.cant_sin_luz := regM.cant_sin_luz - regMin.cant_con_luz;
        regM.cant_sin_gas := regM.cant_sin_gas - regMin.cant_con_gas;
        regM.cant_sin_agua := regM.cant_sin_agua - regMin.cant_con_agua;
        regM.cant_sin_sanitarios := regM.cant_sin_sanitarios - regMin.cant_sanitarios;
        regM.cant_de_chapa := regM.cant_de_chapa - regMin.cant_construidas;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);

        minimo(detalles, reg_detalles, regMin);
    end;

    WriteLn('Actualizacion de maestro finalizada');

    for i:= DF downto 0 do
        Close(detalles[i]);
    Close(maestro);
end;

procedure informarLocalidadesSinViviendaChapa(var maestro: archivo_viviendas);
var
    regM: vivienda;
    cantSinChapa: Integer;
begin
    Reset(maestro);
    
    cantSinChapa := 0;

    while(not Eof(maestro)) do begin
        Read(maestro, regM);
        if(regM.cant_de_chapa = 0) then cantSinChapa := cantSinChapa + 1;
    end;

    WriteLn('Hay ', cantSinChapa, ' localidad/es sin viviendas de chapa.');

    Close(maestro);
end;

var
    maestro: archivo_viviendas;
    detalles: vector_detalles;
begin
    asignarMaestro(maestro);
    asignarDetalles(detalles);

    actualizarMaestro(maestro, detalles);

    informarLocalidadesSinViviendaChapa(maestro);
end.