program pr2_ej9;
const
    valorAlto = 9999;
type
    mesa = record
        codigo_provincia: Integer;
        codigo_localidad: Integer;
        numero: Integer;
        votos: Integer;
    end;

    archivo_mesa = file of mesa;

procedure asignar(var maestro: archivo_mesa);
var
    path: String;
begin
    Write('Ingrese el nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure leer(var maestro: archivo_mesa; var regM: mesa);
begin
    if(not Eof(maestro)) then Read(maestro, regM)
    else regM.codigo_provincia := valorAlto;
end;

procedure imprimirMesas(var maestro: archivo_mesa);
var
    regM: mesa;
    provinciaActual, localidadActual, votosProvincia, votosLocalidad, votosTotal: Integer;
begin
    Reset(maestro);

    votosTotal := 0;
    leer(maestro, regM);

    while(regM.codigo_provincia <> valorAlto) do begin
        provinciaActual := regM.codigo_provincia;
        votosProvincia := 0;

        WriteLn('Provincia: ', provinciaActual);

        while(provinciaActual = regM.codigo_provincia) do begin
            localidadActual := regM.codigo_localidad;
            votosLocalidad := 0;

            Write('Localidad: ', localidadActual);

            while(provinciaActual = regM.codigo_provincia) and (localidadActual = regM.codigo_localidad) do begin
                votosLocalidad := votosLocalidad + regM.votos;
                leer(maestro, regM);
            end;
            votosProvincia := votosProvincia + votosLocalidad;

            Writeln(' - Total de votos: ', votosLocalidad);
        end;
        votosTotal := votosTotal + votosProvincia;

        WriteLn;
        WriteLn('Total de votos provincia: ', votosProvincia);
        WriteLn('----------------------------');
    end;

    WriteLn('Total general de votos: ', votosTotal);

    Close(maestro);
end;

var
    archivo_maestro: archivo_mesa;
begin
    asignar(archivo_maestro);

    WriteLn;

    imprimirMesas(archivo_maestro);
end.