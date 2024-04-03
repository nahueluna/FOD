program pr2_ej7;
const
    valorAlto = 9999;
    DF = 1;
type
    casos = record
        cod_local: Integer;
        nombre_local: String[50];
        cod_cepa: Integer;
        nombre_cepa: String[50];
        activos: Integer;
        nuevos: Integer;
        recuperados: Integer;
        fallecidos: Integer;
    end;

    info_casos = record
        cod_local: Integer;
        cod_cepa: Integer;
        activos: Integer;
        nuevos: Integer;
        recuperados: Integer;
        fallecidos: Integer;
    end;

    archivo_casos = file of casos;
    detalle_casos = file of info_casos;

    dimension_array = 0..DF;

    vArchivoDetalles = array[dimension_array] of detalle_casos;
    vRegistroDetalles = array[dimension_array] of info_casos;

procedure asignarMaestro(var maestro: archivo_casos);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure asignarDetalles(var vDetalles: vArchivoDetalles);
var
    path, aux: String;
    i: Integer;
begin
    for i:= 0 to DF do begin
        path := 'detalle_';
        Str(i, aux);
        path := path + aux;
        Assign(vDetalles[i], path);
    end;
end;

procedure leer(var detalle: detalle_casos; var regD: info_casos);
begin
    if(not Eof(detalle)) then Read(detalle, regD)
    else begin
        regD.cod_local := valorAlto;

        //evita que, cuando se llega al final del archivo, exista la posibilidad de que
        //se asigne un nuevo minimo por un valor anterior
        regD.cod_cepa := valorAlto;
    end;
end;

procedure minimo(var detalles: vArchivoDetalles; var regDetalles: vRegistroDetalles; var regMin: info_casos);
var
    i, minPos: Integer;
begin
    regMin.cod_local := valorAlto;
    regMin.cod_cepa := valorAlto;
    
    for i := 0 to DF do begin
        if(regDetalles[i].cod_local < regMin.cod_local) or ((regDetalles[i].cod_local = regMin.cod_local) and (regDetalles[i].cod_cepa < regMin.cod_cepa)) then begin
            regMin := regDetalles[i];
            minPos := i;
        end;
    end;

    //Evita inicializar minPos por fuera del for y evitar entrar cuando el minimo ya sea valorAlto
    //(se evita otra asignacion identica)
    if(regMin.cod_local <> valorAlto) then
        leer(detalles[minPos], regDetalles[minPos]);
end;

procedure actualizarMaestro(var maestro: archivo_casos; var detalles: vArchivoDetalles);
var
    regDetalles: vRegistroDetalles;
    regMin: info_casos;
    regM: casos;
    i: Integer;
begin
    Reset(maestro);
    for i := 0 to DF do begin
        Reset(detalles[i]);
        leer(detalles[i], regDetalles[i]);
    end;

    minimo(detalles, regDetalles, regMin);

    while(regMin.cod_local <> valorAlto) do begin
        Read(maestro, regM);
        
        while(regMin.cod_local <> regM.cod_local) and (regMin.cod_cepa <> regM.cod_cepa) do
            Read(maestro, regM);

        while(regMin.cod_local = regM.cod_local) and (regMin.cod_cepa = regM.cod_cepa) do begin
            regM.activos := regMin.activos;
            regM.nuevos := regMin.nuevos;
            regM.recuperados := regM.recuperados + regMin.recuperados;
            regM.fallecidos := regM.fallecidos + regMin.fallecidos;

            minimo(detalles, regDetalles, regMin);
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);
    end;

    for i := DF downto 0 do
        Close(detalles[i]);
    Close(maestro);
end;

procedure calcularCasosLocalidades(var maestro: archivo_casos; var cantLocal: Integer);
    procedure leerMaestro(var maestro: archivo_casos; var regM: casos);
    begin
        if(not Eof(maestro)) then Read(maestro, regM)
        else regM.cod_local := valorAlto;
    end;
var
    regM: casos;
    localidadActual, cantCasos: Integer;
begin
    cantLocal := 0;
    cantCasos := 0;

    Reset(maestro);
    leerMaestro(maestro, regM);

    while(regM.cod_local <> valorAlto) do begin
        localidadActual := regM.cod_local;

        while(regM.cod_local = localidadActual) do begin
            cantCasos := cantCasos + regM.activos;
            leerMaestro(maestro, regM);
        end;

        if(cantCasos > 50) then cantLocal:= cantLocal + 1;
    end;

    Close(maestro);
end;

var
    archivo_maestro: archivo_casos;
    detalles: vArchivoDetalles;
    cantLocalidades: Integer;
begin
    asignarMaestro(archivo_maestro);
    asignarDetalles(detalles);

    actualizarMaestro(archivo_maestro, detalles);

    calcularCasosLocalidades(archivo_maestro, cantLocalidades);

    Writeln('Hay ', cantLocalidades, ' localidad/es con mas de 50 casos activos');
end.