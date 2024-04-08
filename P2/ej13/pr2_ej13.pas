program pr2_ej13;
const
    valorAlto = 'ZZZ';
type
    vuelo = record
        destino: String[60];
        fecha: Integer; //a modo de simplificacion. Fecha sería un registro con dia, mes, anio
        hora: Integer;
        asientos: Integer;
    end;

    archivo_vuelos = file of vuelo;

procedure asignar(var maestro: archivo_vuelos);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    Readln(path);
    Assign(maestro, path);
end;

procedure leer(var detalle: archivo_vuelos; var regD: vuelo);
begin
    if(not Eof(detalle)) then Read(detalle, regD)
    else regD.destino := valorAlto;
end;

procedure minimo(var detalle1, detalle2: archivo_vuelos; var regD1, regD2, regMin: vuelo);
    //determina si cual de los dos registros es menor en un criterio de destino, fecha y hora
    function evaluarMenorIgual(regD1, regD2: vuelo): boolean;
    var
        menorDestino, menorFecha, menorHora: boolean;
    begin
        menorDestino := (regD1.destino < regD2.destino);
        menorFecha := (regD1.destino = regD2.destino) and (regD1.fecha < regD2.fecha);
        menorHora := (regD1.destino = regD2.destino) and (regD1.fecha = regD2.fecha) and (regD1.hora <= regD2.hora);

        evaluarMenorIgual := menorDestino or menorFecha or menorHora;
    end;
begin
    if(evaluarMenorIgual(regD1, regD2)) then begin
        regMin := regD1;
        leer(detalle1, regD1);
    end
    else begin
        regMin := regD2;
        leer(detalle2, regD2);
    end;
end;

procedure actualizarMaestro(var maestro, detalle1, detalle2: archivo_vuelos);
var
    regM, regD1, regD2, regMin: vuelo;
begin
    Reset(maestro);
    Reset(detalle1);
    Reset(detalle2);

    leer(detalle1, regD1);
    leer(detalle2, regD2);
    minimo(detalle1, detalle2, regD1, regD2, regMin);

    while(regMin.destino <> valorAlto) do begin
        Read(maestro, regM);
        
        while(regM.destino <> regMin.destino) and (regM.fecha <> regMin.fecha) and (regM.hora <> regMin.hora) do
            Read(maestro, regM);

        while(regM.destino = regMin.destino) and (regM.fecha = regMin.fecha) and (regM.hora = regMin.hora) do begin
            //asientos disponibles = asientos disponibles - asientos comprados
            regM.asientos := regM.asientos - regMin.asientos;
            minimo(detalle1, detalle2, regD1, regD2, regMin);
        end;

        Seek(maestro, FilePos(maestro) - 1);
        Write(maestro, regM);

    end;

    WriteLn('Actualizacion de archivo maestro finalizada');

    Close(detalle2);
    Close(detalle1);
    Close(maestro);
end;

procedure generarListaVuelos(var maestro: archivo_vuelos; var vuelos_texto: Text);
var
    regM: vuelo;
    cantAsientos: Integer;
begin
    Reset(maestro);
    Rewrite(vuelos_texto);

    Write('Ingrese una cantidad de asientos limite: ');
    ReadLn(cantAsientos);

    while(not Eof(maestro)) do begin
        Read(maestro, regM);
        if(regM.asientos < cantAsientos) then begin
            WriteLn(vuelos_texto, regM.destino);
            WriteLn(vuelos_texto, regM.fecha);
            WriteLn(vuelos_texto, regM.hora);
        end;
    end;

    WriteLn('Generacion de lista finalizada');

    Close(vuelos_texto);
    Close(maestro);
end;

var
    maestro, detalle1, detalle2: archivo_vuelos;
    vuelos_menos_asientos: Text;
begin
    asignar(maestro);
    Assign(detalle1, 'detalle1');
    Assign(detalle2, 'detalle2');
    Assign(vuelos_menos_asientos, 'vuelos_menos_asientos.txt');

    actualizarMaestro(maestro, detalle1, detalle2);
    generarListaVuelos(maestro, vuelos_menos_asientos);
end.