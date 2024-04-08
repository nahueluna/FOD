program pr2_ej17;
const
    valorAlto = 9999;
type
    reporte_casos = record
        cod_localidad: Integer;
        nom_localidad: String[50];
        cod_municipio: Integer;
        nom_municipio: String[50];
        cod_hospital: Integer;
        nom_hospital: String[50];
        fecha: Integer;
        cant_casos: Integer;
    end;

    archivo_casos = file of reporte_casos;

procedure asignar(var maestro: archivo_casos);
var
    path: String;
begin
    Write('Ingrese nombre o ruta del archivo maestro: ');
    ReadLn(path);
    Assign(maestro, path);
end;

procedure leer(var archivo: archivo_casos; var reg: reporte_casos);
begin
    if(not Eof(archivo)) then Read(archivo, reg)
    else reg.cod_localidad := valorAlto;
end;

procedure reportarCasos(var maestro: archivo_casos; var casos_texto: Text);
var
    regM: reporte_casos;
    localidadActual, municipioActual: Integer;
    casosTotal, casosLocalidad, casosMunicipio: Integer;
    nomLocalidadActual, nomMunicipioActual: String[50];
begin
    Assign(casos_texto, 'municipios_casos_elevados.txt');
    Rewrite(casos_texto);
    Reset(maestro);
    
    leer(maestro, regM);
    casosTotal := 0;

    while(regM.cod_localidad <> valorAlto) do begin
        localidadActual := regM.cod_localidad;
        nomLocalidadActual := regM.nom_localidad;
        casosLocalidad := 0;

        WriteLn('Localidad: ', regM.nom_localidad);

        while(localidadActual = regM.cod_localidad) do begin
            municipioActual := regM.cod_municipio;
            nomMunicipioActual := regM.nom_municipio;
            casosMunicipio := 0;

            WriteLn(#9, 'Municipio: ', regM.nom_municipio);

            while(localidadActual = regM.cod_localidad) and (municipioActual = regM.cod_municipio) do begin
                casosMunicipio := casosMunicipio + regM.cant_casos;

                Writeln(#9#9, '- Hospital: ', regM.nom_hospital);
                WriteLn(#9#9#9#9 ,regM.cant_casos, ' casos positivos');

                leer(maestro, regM);
            end;
            casosLocalidad := casosLocalidad + casosMunicipio;

            if(casosMunicipio > 1500) then begin
                WriteLn(casos_texto, nomLocalidadActual);
                WriteLn(casos_texto, nomMunicipioActual, ' ', casosMunicipio);
            end;

            WriteLn(#9, 'Cantidad de casos municipio: ', casosMunicipio);
            WriteLn;
        end;
        casosTotal := casosTotal + casosLocalidad;

        WriteLn('Cantidad de casos localidad: ', casosLocalidad);
        WriteLn('-------------------------');
    end;

    WriteLn('Cantidad de casos de la provincia: ', casosTotal);

    Close(maestro);
    Close(casos_texto);
end;

var
    maestro: archivo_casos;
    municipios_casos_texto: Text;
begin
    asignar(maestro);

    WriteLn;

    reportarCasos(maestro, municipios_casos_texto);
end.